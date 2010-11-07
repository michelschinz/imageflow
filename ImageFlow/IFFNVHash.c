/*
 *  IFFNVHash.c
 *  ImageFlow
 *
 *  Created by Michel Schinz on 11.11.05.
 *  Copyright 2005 Michel Schinz. All rights reserved.
 *
 */

#include "IFFNVHash.h"

// FNV hashing
// Taken from http://www.isthe.com/chongo/tech/comp/fnv/

uint32_t FNV32_init() {
  return UINT32_C(2166136261);
}

uint32_t FNV32_step8(uint32_t current, uint8_t byte) {
  return (current ^ byte) * UINT32_C(16777619);
}

uint32_t FNV32_step32(uint32_t current, uint32_t addition) {
  uint32_t v1 = FNV32_step8(current, (addition >> 24) & 0xFF);
  uint32_t v2 = FNV32_step8(v1,(addition >> 16) & 0xFF);
  uint32_t v3 = FNV32_step8(v2,(addition >> 8) & 0xFF);
  return FNV32_step8(v3,addition & 0xFF);
}

extern uint64_t FNV64_init() {
  return UINT64_C(14695981039346656037);
}

extern uint64_t FNV64_step8(uint64_t current, uint8_t byte) {
  return (current ^ byte) * UINT64_C(1099511628211);
}
