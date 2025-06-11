##-----------------------------------------------------------------------------
##  Compagny    : levelup-fpga-design
##  Author      : gvr
##  Created     : 10/06/2025
##
##  Copyright (c) 2025 levelup-fpga-design
##
##  This file is part of the levelup-fpga-design distibuted sources.
##
##  License:
##    - Free to use, modify, and distribute for **non-commercial** purposes.
##    - For **commercial** use, you must obtain a license by contacting:
##        contact@levelup-fpga.fr or directly at gvanroyen@levelup-fpga.fr
##
##  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
##  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
##  DEALINGS IN THE SOFTWARE.
##-----------------------------------------------------------------------------

from def_format_nprc import *
from def_serial_nprc import *
from def_prc import *
from def_serial_wprc import *



import time

c_LED_REG_MODE         =  0
c_LED_REG_FIXED        =  1
c_LED_REG_SPEED        =  2
c_LED_MODE_K2000       =  0
c_LED_MODE_CPT         =  1
c_LED_MODE_FIXED       =  2

c_SLV03                =  3




def set_led_register(ser,reg_addr,value):

    reg_data = []
    reg_data.append(int_to_0xhex32(value))
    raw_wr = build_SPI_rawdata_wrcmd_buffer(False, c_SLV03, reg_addr, reg_data)
    print(raw_wr)
    print(len(raw_wr))
    write_buff_data(ser, c_NUM_BUFF_N1, "0x00000000", raw_wr) #RAW Buff data
    write_register(ser,c_REG03,len(raw_wr))                   #Set length
    write_register(ser,c_REG01,c_REG01_CMD08)                 #Set CMD
    execute_sent_cmd(ser)




ports = list_serial_ports()
selected_port = select_serial_port(ports)
serial_con = open_serial_port(selected_port, 9600, 1)



# AI (Arduino Implemented) version
# Blinks leds

write_register(serial_con,c_REG01,c_REG01_CMD01)              #Set CMD
execute_sent_cmd(serial_con)







# CC (Computer Conroled) version
# Blinks leds

loop_nb = 10
set_led_register(serial_con,c_LED_REG_MODE,c_LED_MODE_FIXED)

for i in range(loop_nb):
    set_led_register(serial_con,c_LED_REG_FIXED,"0xAA")
    time.sleep(0.2)
    set_led_register(serial_con,c_LED_REG_FIXED,"0x55")
    time.sleep(0.2)

set_led_register(serial_con,c_LED_REG_MODE,c_LED_MODE_K2000)



close_serial_port(serial_con)
