/*
 *  IFFNVHash.h
 *  ImageFlow
 *
 *  Created by Michel Schinz on 11.11.05.
 *  Copyright 2005 Michel Schinz. All rights reserved.
 *
 */

extern unsigned FNV_init();
extern unsigned FNV_step8(unsigned current, unsigned char byte);
extern unsigned FNV_step32(unsigned current, unsigned addition);
