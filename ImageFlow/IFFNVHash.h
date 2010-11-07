/*
 *  IFFNVHash.h
 *  ImageFlow
 *
 *  Created by Michel Schinz on 11.11.05.
 *  Copyright 2005 Michel Schinz. All rights reserved.
 *
 */

#include <stdint.h>

extern unsigned FNV_init();
extern unsigned FNV_step8(unsigned current, unsigned char byte);
extern unsigned FNV_step32(unsigned current, unsigned addition);

extern uint64_t FNV64_init();
extern uint64_t FNV64_step8(uint64_t current, uint8_t byte);