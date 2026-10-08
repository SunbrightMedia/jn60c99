/* launcher.c -- JUNO-60.exe: the synth's starter for a desktop.
 *
 * Browsers do not run a WebAssembly engine from a file:// page, so the synth
 * page (gui/skin) needs a web server. This program is that server, nothing
 * more: it serves the folder "app" next to the executable, listens ONLY on the
 * loopback address 127.0.0.1 (no other computer can connect), answers only
 * GET / HEAD for files inside "app" (no "..", no directory listing), and opens
 * the synth page in the default browser. Close its window to quit.
 *
 * Windows (the release):  x86_64-w64-mingw32-gcc -O2 -s -o JUNO-60.exe launcher.c -lws2_32 -lshell32
 * Linux (the local test): gcc -O2 -o juno60-launcher launcher.c -lpthread
 *   JUNO_NO_BROWSER=1 does not open a browser; JUNO_PORT=n asks for port n.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <shellapi.h>
typedef SOCKET sock_t;
#define CLOSESOCK closesocket
#define SEP '\\'
#else
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <pthread.h>
#include <limits.h>
typedef int sock_t;
#define INVALID_SOCKET (-1)
#define CLOSESOCK close
#define SEP '/'
#endif

#define PAGE "/gui/skin/?zoom=75&banks=../../banks/banks.json"

static char g_root[4096];

static const char *mime(const char *path)
{
    static const struct { const char *ext, *type; } T[] = {
        {".html", "text/html; charset=utf-8"}, {".js", "text/javascript"}, {".mjs", "text/javascript"},
        {".wasm", "application/wasm"}, {".png", "image/png"}, {".xml", "application/xml"},
        {".json", "application/json"}, {".css", "text/css"}, {".txt", "text/plain; charset=utf-8"},
        {".bin", "application/octet-stream"}, {".svg", "image/svg+xml"}, {".ico", "image/x-icon"},
    };
    const char *dot = strrchr(path, '.');
    size_t i;
    if (dot)
        for (i = 0; i < sizeof T / sizeof T[0]; ++i)
            if (!strcmp(dot, T[i].ext)) return T[i].type;
    return "application/octet-stream";
}

static void send_all(sock_t s, const char *p, size_t n)
{
    while (n > 0) {
        int k = send(s, p, n > 65536 ? 65536 : (int)n, 0);
        if (k <= 0) return;
        p += k;
        n -= (size_t)k;
    }
}

static void reply(sock_t s, const char *status, const char *type, const char *body)
{
    char h[512];
    int n = snprintf(h, sizeof h, "HTTP/1.1 %s\r\nContent-Type: %s\r\nContent-Length: %u\r\n"
                     "Connection: close\r\n\r\n", status, type, (unsigned)strlen(body));
    send_all(s, h, (size_t)n);
    send_all(s, body, strlen(body));
}

/* the request's path -> a file under the root; 0 when it must not be served */
static int map_path(const char *url, char *out, size_t cap)
{
    char path[2048];
    size_t i = 0, o = 0;
    if (url[0] != '/') return 0;
    while (url[i] && url[i] != '?' && url[i] != '#' && o + 1 < sizeof path) {
        char c = url[i];
        if (c == '%' && isxdigit((unsigned char)url[i + 1]) && isxdigit((unsigned char)url[i + 2])) {
            char hx[3] = {url[i + 1], url[i + 2], 0};
            c = (char)strtol(hx, NULL, 16);
            i += 3;
        } else {
            ++i;
        }
        if (c == '\\' || c == ':' || c == 0) return 0;
        path[o++] = c;
    }
    path[o] = 0;
    if (strstr(path, "..")) return 0;
    if (o > 0 && path[o - 1] == '/') {
        if (o + 10 >= sizeof path) return 0;
        strcat(path, "index.html");
    }
    if (strlen(g_root) + strlen(path) + 1 >= cap) return 0;
    strcpy(out, g_root);
    o = strlen(out);
    for (i = 0; path[i]; ++i) out[o++] = path[i] == '/' ? SEP : path[i];
    out[o] = 0;
    return 1;
}

static void serve(sock_t s)
{
    char req[8192], method[16], url[4096], file[4096], h[512];
    int n = 0, k;
    FILE *f;
    long len;
    /* the request line and headers (a browser sends them at once) */
    while (n < (int)sizeof req - 1) {
        k = recv(s, req + n, (int)sizeof req - 1 - n, 0);
        if (k <= 0) break;
        n += k;
        req[n] = 0;
        if (strstr(req, "\r\n\r\n")) break;
    }
    req[n] = 0;
    if (n <= 0 || sscanf(req, "%15s %4095s", method, url) != 2) return;
    if (strcmp(method, "GET") && strcmp(method, "HEAD")) {
        reply(s, "405 Method Not Allowed", "text/plain", "method not allowed\n");
        return;
    }
    if (!map_path(url, file, sizeof file) || !(f = fopen(file, "rb"))) {
        reply(s, "404 Not Found", "text/plain", "not found\n");
        return;
    }
    fseek(f, 0, SEEK_END);
    len = ftell(f);
    fseek(f, 0, SEEK_SET);
    n = snprintf(h, sizeof h, "HTTP/1.1 200 OK\r\nContent-Type: %s\r\nContent-Length: %ld\r\n"
                 "Cache-Control: no-cache\r\nConnection: close\r\n\r\n", mime(file), len);
    send_all(s, h, (size_t)n);
    if (!strcmp(method, "GET")) {
        char buf[32768];
        size_t r;
        while ((r = fread(buf, 1, sizeof buf, f)) > 0) send_all(s, buf, r);
    }
    fclose(f);
}

#ifdef _WIN32
static DWORD WINAPI worker(LPVOID p)
{
    sock_t s = (sock_t)(UINT_PTR)p;
    serve(s);
    shutdown(s, SD_SEND);
    CLOSESOCK(s);
    return 0;
}
#else
static void *worker(void *p)
{
    sock_t s = (sock_t)(long)p;
    serve(s);
    shutdown(s, SHUT_WR);
    CLOSESOCK(s);
    return NULL;
}
#endif

static void exe_dir(const char *argv0, char *out, size_t cap)
{
    char *slash;
#ifdef _WIN32
    (void)argv0;
    GetModuleFileNameA(NULL, out, (DWORD)cap);
    slash = strrchr(out, '\\');
#else
    ssize_t k = readlink("/proc/self/exe", out, cap - 1);
    if (k > 0) out[k] = 0;
    else snprintf(out, cap, "%s", argv0);
    slash = strrchr(out, '/');
#endif
    if (slash) *slash = 0;
    else snprintf(out, cap, ".");
}

int main(int argc, char **argv)
{
    sock_t ls;
    struct sockaddr_in a;
    int port = 0, p, one = 1;
    char url[256];
    const char *want = getenv("JUNO_PORT");
    FILE *probe;
    char check[4200];
    (void)argc;
#ifdef _WIN32
    WSADATA wd;
    if (WSAStartup(MAKEWORD(2, 2), &wd)) { printf("network start failed\n"); return 1; }
#endif
    exe_dir(argv[0], g_root, sizeof g_root - 8);
    strcat(g_root, SEP == '/' ? "/app" : "\\app");
    snprintf(check, sizeof check, "%s%cgui%cskin%cindex.html", g_root, SEP, SEP, SEP);
    if (!(probe = fopen(check, "rb"))) {
        printf("The folder \"app\" is missing next to this program:\n  %s\n"
               "Unpack the whole zip and run the program from there.\n", g_root);
#ifdef _WIN32
        system("pause");
#endif
        return 1;
    }
    fclose(probe);
    ls = socket(AF_INET, SOCK_STREAM, 0);
    if (ls == INVALID_SOCKET) { printf("socket failed\n"); return 1; }
#ifndef _WIN32
    setsockopt(ls, SOL_SOCKET, SO_REUSEADDR, (const char *)&one, sizeof one);
#else
    (void)one;
#endif
    memset(&a, 0, sizeof a);
    a.sin_family = AF_INET;
    a.sin_addr.s_addr = htonl(INADDR_LOOPBACK);          /* this computer only */
    for (p = want ? atoi(want) : 8060; p <= (want ? atoi(want) : 8079); ++p) {
        a.sin_port = htons((unsigned short)p);
        if (bind(ls, (struct sockaddr *)&a, sizeof a) == 0) { port = p; break; }
    }
    if (!port) {                                          /* any free port */
        socklen_t sl = sizeof a;
        a.sin_port = 0;
        if (bind(ls, (struct sockaddr *)&a, sizeof a) || getsockname(ls, (struct sockaddr *)&a, &sl)) {
            printf("no free port\n");
            return 1;
        }
        port = ntohs(a.sin_port);
    }
    if (listen(ls, 64)) { printf("listen failed\n"); return 1; }
    snprintf(url, sizeof url, "http://127.0.0.1:%d%s", port, PAGE);
    printf("JUNO-60 -- the C99 port with the plugin's own panel\n\n"
           "  The synth is open in your browser:\n  %s\n\n"
           "  Keep this window open while you play. Close it to quit.\n"
           "  (This window is a small web server on this computer only.)\n\n", url);
    fflush(stdout);
    if (!getenv("JUNO_NO_BROWSER")) {
#ifdef _WIN32
        ShellExecuteA(NULL, "open", url, NULL, NULL, SW_SHOWNORMAL);
#else
        char cmd[400];
        snprintf(cmd, sizeof cmd, "xdg-open '%s' >/dev/null 2>&1 &", url);
        if (system(cmd)) { /* no browser: the address is printed above */ }
#endif
    }
    for (;;) {
        sock_t s = accept(ls, NULL, NULL);
        if (s == INVALID_SOCKET) continue;
#ifdef _WIN32
        {
            DWORD ms = 15000;
            HANDLE t;
            setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, (const char *)&ms, sizeof ms);
            t = CreateThread(NULL, 0, worker, (LPVOID)(UINT_PTR)s, 0, NULL);
            if (t) CloseHandle(t);
            else CLOSESOCK(s);
        }
#else
        {
            struct timeval tv = {15, 0};
            pthread_t t;
            setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof tv);
            if (pthread_create(&t, NULL, worker, (void *)(long)s) == 0) pthread_detach(t);
            else CLOSESOCK(s);
        }
#endif
    }
    return 0;
}
