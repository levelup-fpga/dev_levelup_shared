
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

#All basic functions to acces Serial ports for PC to Remote CPU, HW centered, does not matter of any protocol above RS232 (This is our "OSI"_LVL2, "OSI"_LVL1 being the actual HW Link)
#NPRC : No   Protocol Related Constants

import serial
import serial.tools.list_ports


def list_serial_ports():
    ports = [p for p in serial.tools.list_ports.comports() if p.description.lower() != "n/a"]
    if not ports:
        print("❌ No valid serial ports found.")
        exit()
    print("Available serial ports:")
    for i, p in enumerate(ports):
        print(f"{i}: {p.device} - {p.description}")
    return ports


def select_serial_port(ports):
    while True:
        try:
            idx = int(input("Select a port by number: "))
            if 0 <= idx < len(ports):
                return ports[idx].device
            print("❌ Invalid selection.")
        except ValueError:
            print("❌ Please enter a number.")


def open_serial_port(port, baudrate=9600, timeout=1):
    try:
        ser = serial.Serial(port, baudrate, timeout=timeout)
        print(f"\n✅ Opened port {port} at {baudrate} baud.\n")
        return ser
    except serial.SerialException as e:
        print(f"❌ Failed to open port: {e}")
        exit()


def close_serial_port(ser):
    print("⏳ Closing serial connection.")
    ser.close()
    print("🔒 Port closed.")


def receive_data(ser):
    buffer = []
    while True:
        byte = ser.read(1)
        if not byte:
            continue
        char = byte.decode('utf-8', errors='ignore')
        if char == '\r':
            break
        buffer.append(char)
    return ''.join(buffer).strip()


def wait_for_specific_string(ser, expected):
    received = receive_data(ser)
    if received == expected:
        print("✅ Received DONE.")
        return True
    print(f"❌ Unexpected response: '{received}'")
    return False


def prompt_for_tty_sel(baudrate):
    ports = list_serial_ports()
    selected_port = select_serial_port(ports)
    return open_serial_port(selected_port, baudrate, 1)