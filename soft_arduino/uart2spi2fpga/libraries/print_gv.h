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

#ifndef _PRINT_GV_H    // Put these two lines at the top of your file.
#define _PRINT_GV_H    // (Use a suitable name, usually based on the file name.)



void printUint32ArrayHex(const uint32_t* array, int size);
void printUint32Hex(const uint32_t data);
void printArrayInGridHex(const uint32_t* array, int count, int columns);
void printArrayInGridHexLabel(const uint32_t* array, int count, int columns);
uint32_t countArrayDiff(const uint32_t* array1, const uint32_t* array2, int length);



uint32_t countArrayDiff(const uint32_t* array1, const uint32_t* array2, int length) {
  uint32_t diffCount = 0;
  for (int i = 0; i < length; ++i) {
    if (array1[i] != array2[i]) {
      diffCount++;
    }
  }
  return diffCount;
}





void printUint32ArrayHex(const uint32_t* array, int size) {
  char hexStr[11];  // "0x" + 8 hex digits + null terminator
  for (int i = 0; i < size; i++) {
    sprintf(hexStr, "0x%08lX", array[i]);  // Format as 8-digit uppercase hex
    Serial1.print("Index ");
    Serial1.print(i);
    Serial1.print(": ");
    Serial1.println(hexStr);
  }
}

void printUint32Hex(const uint32_t data) {
  char hexStr[11];  // "0x" + 8 hex digits + null terminator
    sprintf(hexStr, "0x%08lX", data);  // Format as 8-digit uppercase hex
    Serial1.println(hexStr);
}


void printArrayInGridHex(const uint32_t* array, int count, int columns)
{
  if (columns == 0) {
    Serial1.println("Number of columns must be greater than 0.");
    return;
  }

  for (int i = 0; i < count; ++i)
  {
    Serial1.print("0x");

    // Create 8-digit zero-padded hex
    char buf[9]; // 8 hex digits + null terminator
    sprintf(buf, "%08lX", array[i]);
    Serial1.print(buf);
    Serial1.print("\t");

    if ((i + 1) % columns == 0) {
      Serial1.println();
    }
  }
}





void printArrayInGridHexLabel(const uint32_t* array, int count, int columns) {
  if (columns == 0) {
    Serial1.println("Number of columns must be greater than 0.");
    return;
  }

  // Header: column numbers, centered
  Serial1.print("     |");
  for (int col = 0; col < columns; ++col) {
    // Centering each label with spaces around it
    if (col < 10) Serial1.print("   "); // Add space for single-digit column numbers
    else Serial1.print("  ");
    Serial1.print(col);
    Serial1.print("   ");
  }
  Serial1.println();

  // Top border
  Serial1.print("-----+");
  for (int col = 0; col < columns; ++col) {
    Serial1.print("----------");
  }
  Serial1.println();

  // Data rows
  int row = 0;
  for (int i = 0; i < count; ++i) {
    if (i % columns == 0) {
      // Start of a new row
      Serial1.print(" ");
      if (row < 10) Serial1.print(" ");
      Serial1.print(row++);
      Serial1.print("  |");
    }

    // Print 0x + zero-padded hex
    Serial1.print(" 0x");
    char buf[9]; // 8 digits + null
    sprintf(buf, "%08lX", array[i]);
    Serial1.print(buf);

    if ((i + 1) % columns == 0) {
      Serial1.println();
    }
  }

  // Finish last row if it's incomplete
  if (count % columns != 0) {
    Serial1.println();
  }

  // Bottom border (optional, same as top)
  Serial1.print("-----+");
  for (int col = 0; col < columns; ++col) {
    Serial1.print("----------");
  }
  Serial1.println();
}
































/*


// Write a single 32-bit word
void write8(const uint8_t data) {
  SPI.beginTransaction(spiSettings);
  digitalWrite(CS_PIN, LOW);
  SPI.transfer(data);
  digitalWrite(CS_PIN, HIGH);
  SPI.endTransaction();
}

void write32(const uint32_t data) {
  SPI.beginTransaction(spiSettings);
  digitalWrite(CS_PIN, LOW);
  for (int i = 3; i >= 0; i--) {
    uint8_t byteToSend = (data >> (8 * i)) & 0xFF;
    SPI.transfer(byteToSend);
  }
  digitalWrite(CS_PIN, HIGH);
  SPI.endTransaction();
}


// Read multiple 32-bit words (write dummy bytes to receive data)
void readN32(uint32_t *buffer, int count) {
  SPI.beginTransaction(spiSettings);
  digitalWrite(CS_PIN, LOW);

  for (int i = 0; i < count; i++) {
    uint32_t word = 0;
    for (int j = 3; j >= 0; j--) {
      word |= ((uint32_t)SPI.transfer(0x00)) << (8 * j);
    }
    buffer[i] = word;
  }

  digitalWrite(CS_PIN, HIGH);
  SPI.endTransaction();
}


*/













#endif // _HEADERFILE_H    // Put this line at the end of your file.
