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


c_BAURATE      = 9600
c_SPEED_ADJUST = 2000000



def add_func(ser):
    actual = get_led_frequency(ser)
    #print(actual)
    set_led_frequency(ser,(actual+c_SPEED_ADJUST))

def sub_func(ser):
    actual = get_led_frequency(ser)
    #print(actual)
    set_led_frequency(ser,(actual-c_SPEED_ADJUST))


def main():

    serial_con = prompt_for_tty_sel(c_BAURATE)

    while True:
        user_input = input('Enter "+" or "-" or "e" to exit: ').strip()
        if user_input == "+":
            add_func(serial_con)
        elif user_input == "-":
            sub_func(serial_con)
        elif user_input.lower() == "e":
            close_serial_port(serial_con)
            break
        else:
            print("Invalid input. Please enter '+', '-', or 'e'.")

if __name__ == "__main__":
    main()