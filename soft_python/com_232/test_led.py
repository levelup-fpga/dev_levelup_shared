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
from def_leds_wprc import *



import time





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
for i in range(loop_nb):
    set_led_fixed(serial_con, "0xAA")
    time.sleep(0.2)
    set_led_fixed(serial_con, "0x55")
    time.sleep(0.2)

set_led_frequency(serial_con, c_DEFAULT_FREQU)
set_led_k2000(serial_con)
print(get_led_frequency(serial_con))



close_serial_port(serial_con)
