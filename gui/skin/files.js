// files.js -- the folders the patch manager reads and writes (gui/juno_pm.c, CLAIMS A39), in the page.
//
// The plugin keeps its banks in Windows folders; the page keeps the same folders, by the same
// paths, in memory: the data folder (the user's banks, saved there by the manager) persists in the
// browser's IndexedDB; the plugin's Patch folder holds the banks the page was given (read only, as
// the plugin's installation folder is to it); the desktop holds the files the user imports this
// session; a file the manager writes into the downloads folder (an export) is given to the browser
// as a download. Paths are Windows paths ('\' or '/'), their case ignored, as NTFS treats them;
// a folder lists its names in NTFS's order (upper case, ordinal), the order the plugin sees.

export const DIRS = {
  data: "C:/ProgramData/Roland Cloud/JUNO-60",
  patch: "C:/Program Files/Common Files/VST3/JUNO-60.vst3/Contents/x86_64-win/Patch",
  old: "C:/ProgramData/Roland/JUNO-60",
  desk: "C:/Users/u/Desktop",
  down: "C:/Users/u/Downloads",
};

const norm = p => p.replace(/\\/g, "/").replace(/\/+$/, "");
const key = p => norm(p).toLowerCase();
const parent = p => { const n = norm(p), i = n.lastIndexOf("/"); return i < 0 ? "" : n.slice(0, i); };
const base = p => { const n = norm(p), i = n.lastIndexOf("/"); return i < 0 ? n : n.slice(i + 1); };
// NTFS's directory order: the names by their upper case, compared ordinally (code units)
export const ntfsCmp = (a, b) => { const x = a.toUpperCase(), y = b.toUpperCase(); return x < y ? -1 : x > y ? 1 : 0; };

export class Files {
  constructor({ persist = true, onDownload = null } = {}) {
    this.f = new Map();                 // key(path) -> { path, bytes }
    this.ro = new Set([key(DIRS.patch)]);   // folders the manager cannot write
    this.db = null;
    this.persist = persist;
    this.onDownload = onDownload;
    this.log = null;                    // a check's file log: [op, path(, to)]
  }

  // the data folder from IndexedDB (the user's banks of an earlier session)
  async open() {
    if (!this.persist || typeof indexedDB === "undefined") return;
    try {
      this.db = await new Promise((res, rej) => {
        const r = indexedDB.open("juno60-files", 1);
        r.onupgradeneeded = () => r.result.createObjectStore("files");
        r.onsuccess = () => res(r.result);
        r.onerror = () => rej(r.error);
      });
      const all = await new Promise((res, rej) => {
        const out = [];
        const c = this.db.transaction("files").objectStore("files").openCursor();
        c.onsuccess = () => { const k = c.result; if (!k) return res(out); out.push(k.value); k.continue(); };
        c.onerror = () => rej(c.error);
      });
      for (const v of all) if (v && v.path && v.bytes) this.f.set(key(v.path), { path: norm(v.path), bytes: new Uint8Array(v.bytes) });
    } catch (e) {
      console.warn("files: IndexedDB unavailable, the data folder lives for this session only: " + e);
      this.db = null;
    }
  }
  _store(path, bytes) {
    if (!this.db || !key(path).startsWith(key(DIRS.data) + "/")) return;
    try {
      const st = this.db.transaction("files", "readwrite").objectStore("files");
      if (bytes) st.put({ path: norm(path), bytes: bytes.slice().buffer }, key(path));
      else st.delete(key(path));
    } catch (e) { console.warn("files: " + e); }
  }
  _writable(path) { return !this.ro.has(key(parent(path))); }

  // a file the page puts there itself (the given banks, an imported file)
  put(path, bytes) { this.f.set(key(path), { path: norm(path), bytes: new Uint8Array(bytes) }); }

  // ---- the manager's calls (juno_pm_io)
  read(path) { const e = this.f.get(key(path)); return e ? e.bytes.slice() : null; }
  write(path, bytes) {
    if (this.log) this.log.push(["write", norm(path)]);
    if (!this._writable(path)) return false;
    this.f.set(key(path), { path: norm(path), bytes: new Uint8Array(bytes) });
    this._store(path, bytes);
    return true;
  }
  remove(path) {
    if (this.log) this.log.push(["delete", norm(path)]);
    if (!this._writable(path) || !this.f.has(key(path))) return false;
    this.f.delete(key(path));
    this._store(path, null);
    return true;
  }
  move(from, to) {
    if (this.log) this.log.push(["move", norm(from), norm(to)]);
    const e = this.f.get(key(from));
    if (!e || this.f.has(key(to)) || !this._writable(from) || !this._writable(to)) return false;
    this.f.delete(key(from));
    this._store(from, null);
    this.f.set(key(to), { path: norm(to), bytes: e.bytes });
    this._store(to, e.bytes);
    if (key(parent(to)) === key(DIRS.down) && this.onDownload) {   // an export: the browser's download
      this.onDownload(base(to), e.bytes);
      this.f.delete(key(to));
    }
    return true;
  }
  exists(path) {
    const k = key(path);
    if (this.f.has(k)) return true;
    for (const d of Object.values(DIRS)) if (key(d) === k) return true;
    for (const e of this.f.keys()) if (e.startsWith(k + "/")) return true;
    return false;
  }
  list(dir) {
    const k = key(dir), out = [];
    for (const [fk, e] of this.f) if (key(parent(fk)) === k) out.push(base(e.path));
    return out.sort(ntfsCmp);
  }
}
