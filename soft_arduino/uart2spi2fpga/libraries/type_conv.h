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

#ifndef _TYPE_CONV_H    // Put these two lines at the top of your file.
#define _TYPE_CONV_H    // (Use a suitable name, usually based on the file name.)


uint32_t hex2int(const String& hexStr);
String uint32ToHex8String(uint32_t num);

uint32_t hex2int(const String& hexStr) {
  String cleanStr = hexStr;
  // Remove "0x" or "0X" prefix if present
  if (cleanStr.startsWith("0x") || cleanStr.startsWith("0X")) {
    cleanStr.remove(0, 2);
  }
  // Convert to uint32_t
  return (uint32_t)strtoul(cleanStr.c_str(), NULL, 16);
}

String uint32ToHex8String(uint32_t num) {
  char buf[8];
  for (int i = 0; i < 8; i++) {
    uint8_t nibble = (num >> ((7 - i) * 4)) & 0xF;
    buf[i] = nibble < 10 ? ('0' + nibble) : ('A' + nibble - 10);
  }
  return String(buf, 8);  // Construct String from 8 chars (no null needed)
}

#endif // _HEADERFILE_H    // Put this line at the end of your file.
