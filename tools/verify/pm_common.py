"""pm_common.py -- the scripted user's choices and the file system's order, shared by both sides of
patch_manager_gate.py (the plugin's worker and the port's), and the panels' window sizes (zoom_fit_gate.py,
the oracles). No Unicorn, no libjuno: plain data rules.
"""


def pick(answer, n):
    """the scripted user's menu choice: an item of the n shown (k mod n), or a cancel (None, -1). A
    menu returns nothing else: an answer past the last item ran the plugin on a bank that does not
    exist (seeds 2 and 4, 2026-10-09: a harness defect)"""
    return None if answer is None or answer < 0 or n <= 0 else answer % n


def ntfs_key(name):
    """an NTFS directory's order: the names compared by their upper case, ordinal (FindFirstFile on
    an NTFS volume lists them so; the plugin runs on one). The harness listed in creation order
    until 2026-10-09: the order of the save's .bak moves then was no Windows'."""
    return name.upper()


def panel_sizes():
    """the main and the patch panel's Script.xml sizes: their windows' (docs/WINDOW_ZOOM.md)"""
    import re
    import truth
    x = open(truth.SCRIPT_XML, encoding='utf-8', errors='replace').read()
    out = {}
    for m in re.finditer(r'<panelType>(.*?)</panelType>', x, re.S):
        t, z = re.search(r'<type>([^<]*)</type>', m.group(1)), re.search(r'<size>([^<]*)</size>', m.group(1))
        if t and z and t.group(1).strip() in ('main', 'patch'):
            out[t.group(1).strip()] = tuple(int(v) for v in z.group(1).split(','))
    return out['main'], out['patch']
