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

from def_serial_nprc import *


ports = list_serial_ports()
selected_port = select_serial_port(ports)
