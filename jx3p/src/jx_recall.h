/* jx_recall.h -- JX-3P patch recall (voice-0 coefficient block). */
#ifndef JX_RECALL_H
#define JX_RECALL_H
/* Apply factory-bank patch `idx` into `blk` (>= JX_RECALL_BLOCK bytes, holding
 * the clean prepared-engine base). Returns the number of cells written, 0 on a
 * bad argument. Bit-exact vs the plugin's own recall dispatch, all 64 patches. */
int jx_bank_apply(unsigned char *blk, const unsigned char *bank, int idx);
#endif
