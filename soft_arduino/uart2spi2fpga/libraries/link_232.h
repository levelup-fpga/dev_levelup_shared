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

#ifndef _LINK_232_H    // Put these two lines at the top of your file.
#define _LINK_232_H    // (Use a suitable name, usually based on the file name.)


#define VERBOSE_LOGGING 0

bool ctst_acc_ip = false; //CTST reg acces In Progress

//void readSerialLine() ;
String inputString = "";     // Message buffer
bool stringComplete = false; // CR received


//int getCommandCode(const String& input);
//void Identify232Commands(const String& inputString);
//State know what is going on in the rs232 link
#define CMD_UNKNOWN     0
#define CMD_BUFF_WR     1
#define CMD_BUFF_RD     2
#define CMD_BUFF_EOT    3
#define CMD_CTST_WR     4
#define CMD_CTST_RD     5
#define CMD_CTST_EOT    6
bool is_buff_rw = false;
bool is_ctst_rw = false;


//void processRegisterAccess(const String& inputString);
#define REG_WAIT_CMD    0
#define REG_SET_ADDR    1
#define REG_WR_DATA     2
int reg_currentState = REG_WAIT_CMD;
bool reg_is_wr = false;
int reg_start_addr = 0;


//void processBufferAccess(const String& inputString);
#define BUF_WAIT_CMD    0
#define BUF_SELECT      1
#define BUF_SET_ADDR    2
#define BUF_SET_LGT     3
#define BUF_WR_DATA     4
int buf_currentState = BUF_WAIT_CMD;
bool buf_is_wr = false;
int buf_sel_num = 0;
int buf_start_addr = 0;
int buf_trans_lgt = 0;


void readSerialLine() ;
int getCommandCode(const String& input);
void Identify232Commands(const String& inputString);
void processRegisterAccess(const String& inputString);
void processBufferAccess(const String& inputString);








//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

void readSerialLine()
{
  while (Serial.available())
  {
    char inChar = Serial.read();
    if (inChar == '\r')
    {
      stringComplete = true;  // End of message
      break;
    } else
    {
      inputString += inChar;  // Only store content
    }
  }
}


//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

void processRegisterAccess(const String& inputString)
{

      int int_in = hex2int(inputString);  // Convert incoming hex string to int

#if VERBOSE_LOGGING
  Serial1.println(inputString);
  Serial1.println(int_in);
#endif




  if (inputString.equals(c_CMD_CTST_WR) || inputString.equals(c_CMD_CTST_RD))
  {
    reg_currentState = REG_SET_ADDR;
    reg_is_wr = inputString.equals(c_CMD_CTST_WR);
    ctst_acc_ip = true;
    return;
  }



  if (inputString.equals(c_CMD_CTST_EOT))
  {
    buf_currentState = REG_WAIT_CMD;
    Serial.print(c_CMD_CTST_EOT);
    Serial.write('\r');
#if VERBOSE_LOGGING
    String operation = reg_is_wr ? "writing" : "reading";
    Serial1.println("Success in reg operation of type " + operation );
    if(!reg_is_wr)printArrayInGridHexLabel(ctst_regs, 16, 4);
#endif
    reg_is_wr   = false;
    ctst_acc_ip = false;
    return;
  }




  switch (reg_currentState)
  {
    case REG_SET_ADDR:
#if VERBOSE_LOGGING
      Serial1.println("REG_SET_ADDR");
#endif
      reg_start_addr = int_in;
      if (reg_is_wr)
      {
        reg_currentState = REG_WR_DATA;
      }
      else
      {
#if VERBOSE_LOGGING
        Serial1.println("REG_READ_DATA");
#endif
        uint32_t val = ctst_regs[reg_start_addr];
        Serial.print(uint32ToHex8String(val));
        Serial.write('\r');
        reg_currentState = REG_WAIT_CMD;
      }
      break;

    case REG_WR_DATA:
#if VERBOSE_LOGGING
      Serial1.println("REG_WR_DATA");
#endif
      ctst_regs[reg_start_addr] = int_in;
      break;

    default:
      break;
  }
}






//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

void processBufferAccess(const String& inputString)
{

      int int_in = hex2int(inputString);  // Convert incoming hex string to int

#if VERBOSE_LOGGING
  Serial1.println(inputString);
  Serial1.println(int_in);
#endif




  if (inputString.equals(c_CMD_BUFF_WR) || inputString.equals(c_CMD_BUFF_RD))
  {
    buf_currentState = BUF_SELECT;
    buf_is_wr = inputString.equals(c_CMD_BUFF_WR);
    return;
  }



  if (inputString.equals(c_CMD_BUFF_EOT))
  {
    buf_currentState = BUF_WAIT_CMD;
    Serial.print(c_CMD_BUFF_EOT);
    Serial.write('\r');
#if VERBOSE_LOGGING
    String operation = buf_is_wr ? "writing" : "reading";
    Serial1.println("Success in " + operation + " " + String(buf_trans_lgt) + "x32 bit words to buffer");
    printArrayInGridHexLabel(buff32_n1, 16, 4);
#endif
    is_buff_rw = false;
    return;
  }




  switch (buf_currentState)
  {
    case BUF_SELECT:
#if VERBOSE_LOGGING
      Serial1.println("BUF_SELECT");
#endif
      buf_sel_num = int_in;
      buf_currentState = BUF_SET_ADDR;
      break;

    case BUF_SET_ADDR:
#if VERBOSE_LOGGING
      Serial1.println("BUF_SET_ADDR");
#endif
      buf_start_addr = int_in;
      buf_currentState = BUF_SET_LGT;
      break;

    case BUF_SET_LGT:
#if VERBOSE_LOGGING
      Serial1.println("BUF_SET_LGT");
#endif
      buf_trans_lgt = int_in;
      if (buf_is_wr)
      {
        buf_currentState = BUF_WR_DATA;
      }
      else
      {
#if VERBOSE_LOGGING
        Serial1.println("BUF_READ_DATA");
#endif
        for (int k = 0; k < buf_trans_lgt; k++)
        {
          uint32_t val = (buf_sel_num == 1) ? buff32_n1[buf_start_addr] : buff32_n2[buf_start_addr];
          Serial.print(uint32ToHex8String(val));
          Serial.write('\r');
          buf_start_addr++;
        }
        buf_currentState = BUF_WAIT_CMD;
      }
      break;

    case BUF_WR_DATA:
#if VERBOSE_LOGGING
      Serial1.println("BUF_WR_DATA");
#endif
      if (buf_sel_num == 1)
        buff32_n1[buf_start_addr] = int_in;
      else
        buff32_n2[buf_start_addr] = int_in;
      buf_start_addr++;
      break;

    default:
      break;
  }
}








//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------

int getCommandCode(const String& input) {
  if (input.equals(c_CMD_BUFF_WR))   return CMD_BUFF_WR;
  if (input.equals(c_CMD_BUFF_RD))   return CMD_BUFF_RD;
  if (input.equals(c_CMD_BUFF_EOT))  return CMD_BUFF_EOT;
  if (input.equals(c_CMD_CTST_WR))   return CMD_CTST_WR;
  if (input.equals(c_CMD_CTST_RD))   return CMD_CTST_RD;
  if (input.equals(c_CMD_CTST_EOT))  return CMD_CTST_EOT;
  return CMD_UNKNOWN;
}

void Identify232Commands(const String& inputString) {
  int cmdCode = getCommandCode(inputString);

  switch (cmdCode) {
    /*
    case CMD_CTST_EOT:
      is_ctst_rw = false;
      break;

    case CMD_BUFF_EOT:
      is_buff_rw = false;
      break;
    */
    case CMD_BUFF_WR:
    case CMD_BUFF_RD:
      is_buff_rw = true;
      is_ctst_rw = false;
      break;

    case CMD_CTST_WR:
    case CMD_CTST_RD:
      is_buff_rw = false;
      is_ctst_rw = true;
      break;

    default:
      // CMD_UNKNOWN — no action
      break;
  }
}















#endif // _HEADERFILE_H    // Put this line at the end of your file.
