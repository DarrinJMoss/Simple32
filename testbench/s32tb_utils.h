#ifndef __S32TB_UTILS_H
#define __S32TB_UTILS_H

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

void fprintf_binary(FILE* ftarget, uint64_t num, uint8_t bit_cnt, const char* delim) {
    for (int i = 0; i < bit_cnt; i++) {
        fprintf(ftarget, "%lu", (num >> i) & 1);
    }
    if (delim != NULL) {
        fprintf(ftarget, "%s", delim);
    }
}

#endif