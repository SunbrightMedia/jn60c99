/* juno_pm.h -- the plugin's patch manager (its patch window's librarian), ported.
 * CLAIMS A39, docs/PATCH_MANAGER.md: every rule READ from the binary and graded against the
 * plugin's own code (tools/verify/patch_manager_gate.py).
 *
 * The manager holds the banks (each 64 record bodies of 20207 bytes and a name), a history of
 * 64 states per bank (undo / redo), the clipboard, the init record, the selection; it reads and
 * writes bank files (KoaBankFile00003 + PG-JU60 + 64 x (16-byte name + body)) through the app's
 * file calls, and asks the app's dialogs where the plugin asks its own (a text edit, a menu, a
 * message box, the file dialogs). The engine side is the bridge's: the model's record image
 * (juno_gui_record) and the patch load (juno_gui_queue_record). */
#ifndef JUNO_PM_H
#define JUNO_PM_H

#define JPM_BODY 20207          /* a record body: what a bank slot holds */
#define JPM_NPATCH 64
#define JPM_HIST 64             /* states per bank's history */

typedef struct juno_pm juno_pm;

/* The app's side. Paths use '/' as the plugin does. Every call may be NULL (then it fails or,
 * for a dialog, cancels). Strings returned through out buffers are NUL-terminated. */
typedef struct juno_pm_io {
    void *u;
    /* files: a whole file (malloc'd, *len its size; NULL when absent), a whole write, a delete, a
     * move (fails when `to` exists), whether a path exists, a folder's names (malloc'd array of
     * malloc'd names, in the folder's listing order) */
    unsigned char *(*read)(void *u, const char *path, long *len);
    int (*write)(void *u, const char *path, const unsigned char *data, long len);
    int (*remove)(void *u, const char *path);
    int (*move)(void *u, const char *from, const char *to);
    int (*exists)(void *u, const char *path);
    char **(*list)(void *u, const char *dir, int *n);
    /* the dialogs: a text edit offering `offered` (1 and the text in out, or 0 cancel); a menu of
     * n items, item k checked when checked[k] (the index or -1); the message box of message `msg`
     * (1 OK, else cancel); the open dialog (1 and a malloc'd array of n malloc'd entries, as the
     * plugin reads its items, rva 0x40B5D0: the first item's file-system path (SIGDN_FILESYSPATH),
     * then each other item's normal display name (SIGDN_NORMALDISPLAY), which the manager joins to
     * the first item's folder) and the save dialog (1 and the path in out) */
    int (*text)(void *u, int what, const char *offered, char *out, int cap);
    int (*menu)(void *u, const char *const *items, const int *checked, int n);
    int (*confirm)(void *u, int msg);
    int (*open_files)(void *u, const char *title, const char *ext, char ***paths, int *n);
    int (*save_file)(void *u, const char *title, const char *suggested, char *out, int cap);
    /* the view (the engine's model): its record image (the serializer, rva 0x335990) and a record
     * body's load (the patch browser's, rva 0x335850). NULL: the bridge's own (juno_gui_record,
     * juno_gui_queue_record); an app whose engine runs on another thread gives locked ones */
    int  (*record)(void *u, unsigned char *out, int cap);
    int  (*load)(void *u, const unsigned char *body, int len);
    /* every other model call the window's code makes, in its order: JPM_GET a value, JPM_SET one
     * (`flag`: the set's fourth argument, rva 0x283DB0's r9), JPM_NOTIFY (rva 0x2853C0), JPM_COMMIT
     * (rva 0x283120). The window's own values (JPM_ID_PANEL .. JPM_ID_LIST_SUB) live in the manager:
     * their gets never come here, their sets do (an app may mirror them). NULL: the bridge's
     * (juno_gui_model_get / _set, nothing, juno_gui_commit) */
    int  (*model)(void *u, int op, unsigned int id, int v, int flag);
} juno_pm_io;

enum { JPM_TEXT_PATCH = 0, JPM_TEXT_BANK = 1 };          /* what a text edit renames */
enum { JPM_GET = 0, JPM_SET = 1, JPM_NOTIFY = 2, JPM_COMMIT = 3 };   /* io.model's op */
/* the model values the window's code reads and sets (vm.vs.*; EXECUTED: each value object's field
 * +0x18 points into the vs record at the id's low byte) */
#define JPM_ID_PANEL     0x0FFFC002u   /* panelPatch: the window open (the PATCH button's value) */
#define JPM_ID_MANAGER   0x0FFFC004u   /* patchManager: set to 1 after a change (its listeners redraw) */
#define JPM_ID_LIST_MAIN 0x0FFFC005u   /* patchListMain */
#define JPM_ID_LIST_SUB  0x0FFFC006u   /* patchListSub */
#define JPM_ID_BANK      0x0FFFC010u   /* bankId: the bank the view last read */
#define JPM_ID_PATCH     0x0FFFC014u   /* patchId: the patch the view last read */
enum { JPM_MSG_IMPORT = 2, JPM_MSG_EXPORT = 3, JPM_MSG_BANK_NAME = 37, JPM_MSG_DELETE_BANK = 38 };  /* the plugin's text codes */

/* The key codes of the list's key handler (rva 0x3278C0): letters as ASCII, these for the rest */
enum { JPM_KEY_UP = 0x100, JPM_KEY_DOWN = 0x101, JPM_KEY_LEFT = 0x102, JPM_KEY_RIGHT = 0x103,
       JPM_KEY_ENTER = 0x108, JPM_KEY_ESC = 0x109, JPM_KEY_DELETE = 0x10B, JPM_KEY_SPACE = 0x20 };
enum { JPM_SHIFT = 1, JPM_CTRL = 2 };

/* folders: the data folder (the user's banks; saves go there), the plugin's Patch folder (its
 * factory banks, installed once), the old folder; the Script folder (Initial.bin). A NULL or ""
 * folder holds nothing. */
juno_pm *juno_pm_create(void *ctx, const juno_pm_io *io, const char *data_dir, const char *patch_dir,
                        const char *old_dir, const char *script_dir);
void juno_pm_free(juno_pm *pm);

int  juno_pm_attach(juno_pm *pm);            /* the editor opens (rva 0x32FD50): the first boots */
void juno_pm_initialize(juno_pm *pm);        /* IComponent::initialize's load of the selection */
const char *juno_pm_pref(const juno_pm *pm); /* the setting PatchManager/BankName (detach writes it) */
void juno_pm_set_pref(juno_pm *pm, const char *bank_name);   /* its value at the app's start */
void juno_pm_detach(juno_pm *pm);            /* the editor closes (rva 0x32EEC0): the last saves */
void juno_pm_tick(juno_pm *pm);              /* the 50 ms timer (rva 0x32F280): autosave */
int  juno_pm_save_all(juno_pm *pm);          /* rva 0x336FD0 */

/* The list's key (rva 0x3278C0): returns 1 when handled. *close set when the window closes. */
int  juno_pm_key(juno_pm *pm, int code, int flags, int *close);
/* A button's function: "ManagePatch" / "ManagePatchBank" with its arguments */
int  juno_pm_func(juno_pm *pm, const char *fn, const char *args);
/* the list's mouse: select (a click), read (a double click), move (a drag from -> to) */
int  juno_pm_select(juno_pm *pm, int idx);
int  juno_pm_mouse(juno_pm *pm, int type, int x, int y, const int rect[4]);   /* rva 0x327D70 */
/* the bank name control's mouse (rva 0x33F0A0): a down or a double click on its button (button: the
 * bitmap frame's rectangle) renames the bank, elsewhere on it opens the bank menu */
int  juno_pm_bank_mouse(juno_pm *pm, int type, int x, int y, const int rect[4], const int button[4]);
int  juno_pm_move(juno_pm *pm, int from, int to);
void juno_pm_drag(const juno_pm *pm, int *src, int *tgt);   /* a drag's source and target cells (-1: none) */
void juno_pm_view_values(const juno_pm *pm, int *bank, int *patch, int *tick);   /* the view's values, the timer's count */

/* reads for the window */
int  juno_pm_nbanks(const juno_pm *pm);
int  juno_pm_cur_bank(const juno_pm *pm);
int  juno_pm_cur(const juno_pm *pm, int sub);   /* the current bank of the main list (0) or the sub list (1) */
int  juno_pm_sel(const juno_pm *pm);
int  juno_pm_patch(const juno_pm *pm);       /* the patch the view last read (its patch value) */
/* the window's own values (JPM_ID_PANEL .. JPM_ID_LIST_SUB): read, and the app's own set (the PATCH
 * button's: no model call from here). panelPatch from 0 opens the window: the bank and the selection
 * take the view's values, every bank's history keeps its current state alone (rva 0x33F200,
 * 0x3308C0); the app's commit follows */
int  juno_pm_value(const juno_pm *pm, unsigned int id);
void juno_pm_set_value(juno_pm *pm, unsigned int id, int v);
const char *juno_pm_bank_name(const juno_pm *pm, int bank);
int  juno_pm_patch_name(const juno_pm *pm, int bank, int idx, char out[17]);
int  juno_pm_number(int idx, char *out, int cap);   /* the list's number in the current format */
/* a list cell's text (rva 0x326930 / 0x335640): the number, ": ", the 16-char name; the name alone
 * when the format is none of the three */
int  juno_pm_cell_text(const juno_pm *pm, int bank, int idx, char *out, int cap);
int  juno_pm_format(void);           /* the number format: the setting "Patch/Format" at exit (rva 0x338220) */
/* the setting "Patch/Format" as the plugin reads it at its start (rva 0x332D30): its text (NULL:
 * absent, the format stays) as an integer the plugin's way (rva 0x3E33F0) */
void juno_pm_load_format(const char *pref);
const unsigned char *juno_pm_body(const juno_pm *pm, int bank, int idx);
int  juno_pm_hist(const juno_pm *pm, int bank, int *cur);   /* the history's size, its cursor */
const unsigned char *juno_pm_clip(const juno_pm *pm);

#endif
