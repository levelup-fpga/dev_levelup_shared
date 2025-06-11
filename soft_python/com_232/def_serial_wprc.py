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

#Protocol related, uses CONSTANS Shared by PC and remote CPU to communicate over RS232 ============================
#Bassicly uses HW/Protocol specic CONSTANTS
#WPRC : With Protocol Related Constants

from def_prc import *
from def_serial_nprc import *
from def_format_nprc import *
import random


#TODO_AFTER_DEBUG !!!!!!!!!!!!!!: remove prints and send an error (loss of time) => ALL!!!!!!!!!!!!

def generate_hex_data_array(length, use_random=True):
    if length > c_BUFF_MAX_LGT:
        print(f"❌ Requested length {length} exceeds MAX_LENGTH of {c_BUFF_MAX_LGT}.")
        return []

    hex_array = []
    for i in range(length):
        value = random.randint(0, 0xFFFFFFFF) if use_random else i
        hex_str = f"0x{value:08X}"  # 8-digit uppercase hex with 0x
        hex_array.append(hex_str)

    return hex_array




def send_hex_data_from_array(ser, hex_array): #the input array is guaranteed to be correctly formatted (e.g., "0x00014D55")
    if len(hex_array) > c_BUFF_MAX_LGT:
        print(f"❌ Input exceeds maximum allowed size of {c_BUFF_MAX_LGT} entries.")
        return

    for hex_str in hex_array:
        hex_str = hex_str.strip()[2:].upper()  # Strip '0x' and convert to uppercase
        ser.write((hex_str + '\r').encode('utf-8'))


def receive_hex_data_to_array(ser, length): #the input array is guaranteed to be correctly formatted (e.g., "0x00014D55")
    if length > c_BUFF_MAX_LGT:
        print(f"❌ Input exceeds maximum allowed size of {c_BUFF_MAX_LGT} entries.")
        return
    hex_array = []
    for i in range(length):
        buffer = receive_data(ser)
        hex_array.append("0x"+buffer)
    return hex_array



def read_buff_data(ser, buff_num, addr_start, length):
    print("📥 Reading data...")
    ser.write((c_CMD_BUFF_RD + '\r').encode('utf-8'))
    ser.write((int_to_hex32(buff_num) + '\r').encode('utf-8'))
    ser.write((strip_0x_prefix(addr_start) + '\r').encode('utf-8'))
    ser.write((int_to_hex32(length) + '\r').encode('utf-8'))
    rd_array = receive_hex_data_to_array(ser, length)
    ser.write((c_CMD_BUFF_EOT + '\r').encode('utf-8'))
    wait_for_specific_string(ser,c_CMD_BUFF_EOT)
    return rd_array





def write_buff_data(ser, buff_num, addr_start, data_array):
    print("📤 Writing data...")
    ser.write((c_CMD_BUFF_WR + '\r').encode('utf-8'))
    ser.write((int_to_hex32(buff_num) + '\r').encode('utf-8'))
    ser.write((strip_0x_prefix(addr_start) + '\r').encode('utf-8'))
    ser.write((int_to_hex32(len(data_array)) + '\r').encode('utf-8'))
    send_hex_data_from_array(ser, data_array)
    ser.write((c_CMD_BUFF_EOT + '\r').encode('utf-8'))
    wait_for_specific_string(ser,c_CMD_BUFF_EOT)



def write_register(ser, reg_addr, reg_data):
    if reg_addr > c_CTST_NUM_REG-1:
        print(f"❌ Register Addr is out of bound : must be betwee {c_CTST_NUM_REG-1} and {c_CTST_NUM_REG-c_CTST_NUM_REG}")
        return
    print("📤 Writing register...")
    ser.write((c_CMD_CTST_WR + '\r').encode('utf-8'))
    ser.write((int_to_hex32(reg_addr) + '\r').encode('utf-8'))
    ser.write((strip_0x_prefix(int_to_0xhex32(reg_data)) + '\r').encode('utf-8')) #TODO : Maybe do not add 0x then strip them.. check across all used calls
    ser.write((c_CMD_CTST_EOT + '\r').encode('utf-8'))
    wait_for_specific_string(ser,c_CMD_CTST_EOT)

def read_register(ser, reg_addr):
    if reg_addr > c_CTST_NUM_REG-1:
        print(f"❌ Register Addr is out of bound : must be betwee {c_CTST_NUM_REG-1} and {c_CTST_NUM_REG-c_CTST_NUM_REG}")
        return
    print("📥 Reading register...")
    ser.write((c_CMD_CTST_RD + '\r').encode('utf-8'))
    ser.write((int_to_hex32(reg_addr) + '\r').encode('utf-8'))
    buffer = receive_data(ser)
    ser.write((c_CMD_CTST_EOT + '\r').encode('utf-8'))
    wait_for_specific_string(ser,c_CMD_CTST_EOT)
    return buffer


def wait_end_of_cmd(ser):
    wait_for_specific_string(ser, c_WAIT_CMD_DONE)

def execute_sent_cmd(ser):
    write_register(ser,c_REG00,"0x00000000")
    write_register(ser,c_REG00,"0x00000001")
    wait_end_of_cmd(ser)
    write_register(ser,c_REG00,"0x00000000")



