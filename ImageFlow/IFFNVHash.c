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

unsigned FNV_init() {
  return 2166136261;
}

unsigned FNV_step8(unsigned current, unsigned char byte) {
  return (current ^ byte) * 16777619;  
}

unsigned FNV_step32(unsigned current, unsigned addition) {
  unsigned v1 = FNV_step8(current, (addition >> 24) & 0xFF);
  unsigned v2 = FNV_step8(v1,(addition >> 16) & 0xFF);
  unsigned v3 = FNV_step8(v2,(addition >> 8) & 0xFF);
  return FNV_step8(v3,addition & 0xFF);
}
