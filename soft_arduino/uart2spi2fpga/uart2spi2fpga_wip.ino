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

#include "libraries/sys.h"
#include "libraries/type_conv.h"
#include "libraries/print_gv.h"
#include "libraries/spi_gv.h"
#include "libraries/leds.h"
#include "libraries/brams.h"
#include "libraries/link_232.h"


bool run_cmd = false;


void setup() {

  pinMode(c_CS_PIN, OUTPUT);
  digitalWrite(c_CS_PIN, HIGH);       // Keep slave unselected
  pinMode(c_PB_PIN, INPUT_PULLUP);    //PB
  SPI.begin();                      // Initialize SPI

  Serial.begin(c_BAUD_U1);
  while (!Serial); // Wait for Serial to be ready
  // Start Serial1 on RX=PB23 (D0), TX=PB22 (D1)
  Serial1.begin(c_BAUD_U2);
  while (!Serial1);
  Serial1.println("Dual UART Test");
  while (!Serial);

  inputString.reserve(200); //reserve input bufferspace if loop is busy while input is incoming


}

void loop()
{

  //manage serial com to pc : used to fill or dump arduino buffers and/or to configure arduino ragisters to be used afterwards (here manage SPI comm to FPGA)
  readSerialLine();
  if (stringComplete) {
    Identify232Commands(inputString);
    if(is_buff_rw) processBufferAccess(inputString);
    if(is_ctst_rw) processRegisterAccess(inputString);
    inputString = "";
    stringComplete = false;
  }

  if((ctst_regs[c_REG00] != 0) && (!run_cmd) && !ctst_acc_ip)
  {
    run_cmd = true;

    {//actual code to be ran upon cmd received
      Serial1.println("START executing CMD received over serial com"); // runs in loop when can TODO = Validate a cmd for running code on a bool flag

      switch (ctst_regs[c_REG01])
      {

        case c_REG01_CMD00:
          Serial1.println(" -c_REG01_CMD00"); //Blink LEDS

          break;


        case c_REG01_CMD01:

          Serial1.println(" -c_REG01_CMD01");

          blink_leds(10);

          break;
        case c_REG01_CMD02:
          Serial1.println(" -c_REG01_CMD02");

          break;

        case c_REG01_CMD08:
        case c_REG01_CMD09:
          Serial1.println(" -c_REG01_CMD08");

          spi_transfer_rw(buff32_n1, buff32_n2, ctst_regs[c_REG03]);



          break;




        default:
          // CMD_UNKNOWN — no action
          Serial1.println(" -c_REG01_CMD02 : COMMAND NOT IMPLEMENTED");
          break;
      }


      //delay(1000);
      Serial1.println("DONE  executing CMD received over serial com"); // runs in loop when can TODO = Validate a cmd for running code on a bool flag
    }


    Serial.print(c_WAIT_CMD_DONE); //is being sent to early need to check treating serial cm com is over
    Serial.write('\r');

  }
  else if((ctst_regs[c_REG00] == 0) && (run_cmd))
  {
    run_cmd = false;
  }


}


