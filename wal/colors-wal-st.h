const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#03142D", /* black   */
  [1] = "#ECB079", /* red     */
  [2] = "#1F6E8B", /* green   */
  [3] = "#5E7089", /* yellow  */
  [4] = "#2D94A7", /* blue    */
  [5] = "#5AA5B1", /* magenta */
  [6] = "#58BDC8", /* cyan    */
  [7] = "#d7d2ce", /* white   */

  /* 8 bright colors */
  [8]  = "#969390",  /* black   */
  [9]  = "#ECB079",  /* red     */
  [10] = "#1F6E8B", /* green   */
  [11] = "#5E7089", /* yellow  */
  [12] = "#2D94A7", /* blue    */
  [13] = "#5AA5B1", /* magenta */
  [14] = "#58BDC8", /* cyan    */
  [15] = "#d7d2ce", /* white   */

  /* special colors */
  [256] = "#03142D", /* background */
  [257] = "#d7d2ce", /* foreground */
  [258] = "#d7d2ce",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
