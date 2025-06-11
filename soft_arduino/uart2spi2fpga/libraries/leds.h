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

#ifndef _LEDS_H    // Put these two lines at the top of your file.
#define _LEDS_H    // (Use a suitable name, usually based on the file name.)

//#include "libraries/sys.h"

const int c_LED_REG_MODE         =  0;
const int c_LED_REG_FIXED        =  1;
const int c_LED_REG_SPEED        =  2;

const int c_LED_MODE_K2000        =  0;
const int c_LED_MODE_CPT          =  1;
const int c_LED_MODE_FIXED        =  2;

void blink_leds(int loop_nb);

void blink_leds(int loop_nb)
{
          buff32_n1[0] = c_LED_MODE_FIXED; //#32b_data1 = fixed
          spi_transfer_head('W', 1, c_SLV03, c_LED_REG_MODE, buff32_n1, buff32_n2);
          for (size_t i = 0; i < loop_nb; i++)
          { //blink fixed mode
              //conf led mode = fixed data
            buff32_n1[0] = 0xFF; //#32b_data1 = fixed
            spi_transfer_head('W', 1, c_SLV03, c_LED_REG_FIXED, buff32_n1, buff32_n2);
            delay(200);  // 500ms
            buff32_n1[0] = 0x00; //#32b_data1 = fixed
            spi_transfer_head('W', 1, c_SLV03, c_LED_REG_FIXED, buff32_n1, buff32_n2);
            delay(200);  // 500ms
          }
          buff32_n1[0] = c_LED_MODE_K2000; //#32b_data1 = fixed
          spi_transfer_head('W', 1, c_SLV03, c_LED_REG_MODE, buff32_n1, buff32_n2);
}








#endif // _HEADERFILE_H    // Put this line at the end of your file.
