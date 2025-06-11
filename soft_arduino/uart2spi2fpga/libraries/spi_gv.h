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

#ifndef _SPI_GV_H    // Put these two lines at the top of your file.
#define _SPI_GV_H    // (Use a suitable name, usually based on the file name.)


//"libraries/sys.h"


const int c_SLV00                =  0;
const int c_SLV01                =  1; //BRAM 1
const int c_SLV02                =  2; //BRAM 2
const int c_SLV03                =  3; //LEDS
const int c_SLV04                =  4;
const int c_SLV05                =  5;
const int c_SLV06                =  6;
const int c_SLV07                =  7;



void spi_transfer_rw(uint32_t *wr_buff, uint32_t *rd_buff, size_t count);
void printUint32ArrayHex(const uint32_t* array, size_t size);
uint32_t spi_4byte_transaction(uint32_t word_in);
void spi_transfer_head(uint8_t RwN, uint16_t Nb_32Tr, uint8_t cs, uint32_t addr, uint32_t *wr_buff, uint32_t *rd_buff);




//count is the size of 32 bit woeds to be tranfered (stocked or stored in buffers) include headers words
void spi_transfer_rw(uint32_t *wr_buff, uint32_t *rd_buff, size_t count) {
  SPI.beginTransaction(spiSettings);
  digitalWrite(c_CS_PIN, LOW);

  for (size_t i = 0; i < count; i++) {
    rd_buff[i] = spi_4byte_transaction(wr_buff[i]);
  }

  digitalWrite(c_CS_PIN, HIGH);
  SPI.endTransaction();
}


uint32_t spi_4byte_transaction(uint32_t word_in)
{
  //SPI transaction and CS  treated befor call to thith function

    uint32_t word_out = 0;
    for (int j = 3; j >= 0; j--) {
      word_out |= (uint32_t)(SPI.transfer((word_in >> (8 * j))  & 0xFF))<< (8 * j);
    }
    return word_out;

}




//Nb_32Tr only counts data transitions : the function creats the header based on paprameters passed
void spi_transfer_head(uint8_t RwN, uint16_t Nb_32Tr, uint8_t cs, uint32_t addr, uint32_t *wr_buff, uint32_t *rd_buff)
{

//buid headers
uint32_t header0 = 0;
uint32_t header1 = 0;
  if(RwN != 'W')
  {
    header0 = header0 | (1 << (32-1));
  }

  header0 |= (uint32_t)((Nb_32Tr&0x7FFF) << (16));
  header0 |= (uint32_t)(0xDEAD);
  header1 |= (uint32_t)(cs <<(24));
  header1 |= (uint32_t)(addr&0x00FFFFFF);

  SPI.beginTransaction(spiSettings);
  digitalWrite(c_CS_PIN, LOW);

  spi_4byte_transaction(header0);
  spi_4byte_transaction(header1);
  for (int i = 0; i < Nb_32Tr; i++)
  {
    rd_buff[i] = spi_4byte_transaction(wr_buff[i]);
  }

  digitalWrite(c_CS_PIN, HIGH);
  SPI.endTransaction();

}






#endif // _HEADERFILE_H    // Put this line at the end of your file.
