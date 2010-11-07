/*
 *  IFFNVHash.h
 *  ImageFlow
 *
 *  Created by Michel Schinz on 11.11.05.
 *  Copyright 2005 Michel Schinz. All rights reserved.
 *
 */

#include <stdint.h>

extern uint32_t FNV32_init();
extern uint32_t FNV32_step8(uint32_t current, uint8_t byte);
extern uint32_t FNV32_step32(uint32_t current, uint32_t addition);

extern uint64_t FNV64_init();
extern uint64_t FNV64_step8(uint64_t current, uint8_t byte);
