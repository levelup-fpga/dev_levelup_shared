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

#PRC = Protocol Related Constants
#PC to Arduino common Serial STRING Flags for SERIAL_TTY transaction protocol ====================================
c_CMD_BUFF_WR            = "BUW"  #start BUff Write
c_CMD_BUFF_RD            = "BUR"  #start BUff Read
c_CMD_BUFF_EOT           = "BUE"  #BUff End of transaction


c_CTST_NUM_REG           = 16
c_CMD_CTST_WR            = "CSW"  #start Control Status Write
c_CMD_CTST_RD            = "CSR"  #start Control Status Read
c_CMD_CTST_EOT           = "CSE"  #Control Status End of transaction

c_WAIT_CMD_DONE          = "CMD"  #CoMmand Done : is sent by CPU when command sent is acheived, PC Soft waits



#Arduino HW adressable capacities =================================================================================
c_NUM_BUFF_N1            = 1
c_NUM_BUFF_N2            = 2
c_BUFF_MAX_LGT           = 1024
#AI = Arduino Implemented (just for the AI trend ;-))
#CC = Computer (pythone her) Controled
c_REG00 =  0 # REG START CMD
c_REG01 =  1 # Defines what CMD to RUN
c_REG02 =  2 # NOT Needed definde in array ...  When(CC) : Defines ADDR [31:24] = Slave select [23:0] = Addr
c_REG03 =  3 # When(CC) : Defines SPI transfer Lenght
c_REG04 =  4 # When(AI) : If needed specifies number of transfers per RW
c_REG05 =  5 # When(AI) : If needed specifies number of loops doing RW transfers specified in c_REG04
c_REG06 =  6 # When(AI) : If needed bit[0] specifies if data is random or counter for transfers to be executed
c_REG07 =  7
c_REG08 =  8 # Status REG
c_REG09 =  9 # When(AI) : Error count Reg to be reset By(CC) when AI cmd is done
c_REG10 = 10
c_REG11 = 11
c_REG12 = 12
c_REG13 = 13
c_REG14 = 14
c_REG15 = 15



#Arduino undersandable/Implemented actions to received command =====================================================
c_REG01_CMD00 =  0 # Launch Arduino Implemented test : TBS
c_REG01_CMD01 =  1 # Launch Arduino Implemented test : DUMB Led test
c_REG01_CMD02 =  2 # Launch Arduino Implemented test : Perform c_REG04xc_REG05 RW transfers
                   # (Random or Counter defined by c_REG06)
                   # => Log errors in c_REG09. No Serial LOG Transfers are done as fast as possible
                   # (between each loop a new random array is recreated)
c_REG01_CMD03 =  3 # Launch Arduino Implemented test : TBS


#CC CMD (Computer Controled => arduino executed) ---------------------------------------------------------------
c_REG01_CMD08 =  8 # Write SPI from rawBuffer #1
c_REG01_CMD09 =  9 # Read  SPI to   rawBuffer #2 wr header is in rawBuffer#1
                   # Treated equaly, length is in c_REG03
                   # If a RD  was sent just read back buff#2 when CMD is treated

c_REG01_CMD10 = 10 # TBD