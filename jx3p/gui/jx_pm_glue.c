/* jx_pm_glue.c -- the JX-3P's patch window: the JUNO-60's patch manager port (gui/juno_pm.c, the same machine code
 * in both plugins: 70 of 77 functions at one offset, the rest found by their normalized code, jx3p/tools/fw_map.py;
 * jx3p/docs/HOST_LAYER.md 3r) on the JX bridge. Built as one unit with juno_pm.c and the bridge:
 *     cc ... -DJPM_PRODUCT='"PG-JX3P"' jx3p/gui/jx_pm_glue.c gui/juno_pm.c jx3p/gui/jx_bridge.c ...
 * The manager's view calls when the app gives none (juno_pm_io's record / load / model NULL): the JX model's record
 * image (the serializer, rva 0x335870), the patch browser's load of a record body (rva 0x335730), the model's get,
 * the editor's set (rva 0x283C90) and the panel's commit. The JX bridge is one instance: the context is unused. */
#include <string.h>
#include <stdint.h>

int jx3p_record(unsigned char *out, int cap);
int jx3p_product_load_record(const unsigned char *rec, int len);
int32_t jx3p_model_get(uint32_t id);
int jx3p_model_set(uint32_t id, int32_t v);
void jx3p_model_commit(void);

#define JX_BODY 20207          /* a record body: the bank file's record less its 16-byte name */

int juno_gui_record(const void *c, unsigned char *out, int cap)
{
    (void)c;
    return jx3p_record(out, cap);
}
/* a body to the patch browser's load: the record is the 16-byte name (its 16 nibble pairs at body offset 140, as a
 * bank file holds it) and the body; the load reads the body alone */
int juno_gui_queue_record(void *c, const unsigned char *body, int len)
{
    static unsigned char rec[16 + JX_BODY];
    int k;
    (void)c;
    if (!body || len != JX_BODY) return 0;
    for (k = 0; k < 16; ++k) rec[k] = (unsigned char)(body[140 + 2 * k] * 16 + body[141 + 2 * k]);
    memcpy(rec + 16, body, JX_BODY);
    return jx3p_product_load_record(rec, (int)sizeof rec) < 0 ? 0 : 1;
}
int juno_gui_model_get(const void *c, unsigned int id)
{
    (void)c;
    return (int)jx3p_model_get(id);
}
int juno_gui_model_set(void *c, unsigned int id, int v)
{
    (void)c;
    return jx3p_model_set(id, v);
}
void juno_gui_commit(void *c)
{
    (void)c;
    jx3p_model_commit();
}
