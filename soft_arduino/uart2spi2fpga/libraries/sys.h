//-----------------------------------------------------------------------------
//  Compagny    : levelup-fpga-design
//  Author      : gvr
//  Created     : 10/06/2025
//
//  Copyright (c) 2025 levelup-fpga-design
//
//  This file is part of the levelup-fpga-design distibuted sources.
//
//  License:
//    - Free to use, modify, and distribute for **non-commercial** purposes.
//    - For **commercial** use, you must obtain a license by contacting:
//        contact@levelup-fpga.fr or directly at gvanroyen@levelup-fpga.fr
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//-----------------------------------------------------------------------------

#ifndef _SYS_H    // Put these two lines at the top of your file.
#define _SYS_H    // (Use a suitable name, usually based on the file name.)


#include <SPI.h>
//#include "spi_gv.h"
//#include "leds.h"

// Define SPI settings: 2MHz, MSB first, Mode 3
const bool c_DBG_EN               = true;

const int c_CS_PIN                = 10;
const int c_PB_PIN                = 2;
const int c_BAUD_U1               = 9600;
const int c_BAUD_U2               = 9600;
const int c_SPI_CLK               = 8000000;

const int c_REG00 =  0; //bit 0 is start cmd on rising edge others unused
const int c_REG01 =  1; //Cmd to be executed
const int c_REG02 =  2; //TBD
const int c_REG03 =  3; //TDB
const int c_REG04 =  4;
const int c_REG05 =  5;
const int c_REG06 =  6;
const int c_REG07 =  7;
const int c_REG08 =  8;
const int c_REG09 =  9;
const int c_REG10 = 10;
const int c_REG11 = 11;
const int c_REG12 = 12;
const int c_REG13 = 13;
const int c_REG14 = 14;
const int c_REG15 = 15;

const int c_REG01_CMD00 =  0;
const int c_REG01_CMD01 =  1;
const int c_REG01_CMD02 =  2;
const int c_REG01_CMD03 =  3;
const int c_REG01_CMD04 =  4;
const int c_REG01_CMD05 =  5;
const int c_REG01_CMD06 =  6;
const int c_REG01_CMD07 =  7;

const int c_REG01_CMD08 =   8;
const int c_REG01_CMD09 =   9;
const int c_REG01_CMD10 =  10;
const int c_REG01_CMD11 =  11;
const int c_REG01_CMD12 =  12;
const int c_REG01_CMD13 =  13;
const int c_REG01_CMD14 =  14;
const int c_REG01_CMD15 =  15;





const int       c_BUFF_MAX_LGT  = 1024;
const String    c_CMD_BUFF_WR   = "BUW"    ;//
const String    c_CMD_BUFF_RD   = "BUR"    ;//
const String    c_CMD_BUFF_EOT  = "BUE"    ;// #END OF TR

uint32_t buff32_n1[c_BUFF_MAX_LGT] = {0};
uint32_t buff32_n2[c_BUFF_MAX_LGT] = {0};

const int       c_CTST_NUM_REG  = 16       ;
const String    c_CMD_CTST_WR   = "CSW"   ;
const String    c_CMD_CTST_RD   = "CSR"   ;
const String    c_CMD_CTST_EOT  = "CSE"   ;

uint32_t ctst_regs[c_CTST_NUM_REG] = {0};

const String    c_WAIT_CMD_DONE  = "CMD"  ;


SPISettings spiSettings(c_SPI_CLK, MSBFIRST, SPI_MODE3);


#endif // _HEADERFILE_H    // Put this line at the end of your file.
