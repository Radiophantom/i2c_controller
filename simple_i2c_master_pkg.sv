package simple_i2c_master_pkg;

  parameter I2C_VER = 16'h0_0_0_1;

/*
  Control registers
*/

  parameter I2C_CR1_CR = 0;
          parameter I2C_CR1_CR_SWRST  = 15;
          parameter I2C_CR1_CR_POS    = 11;
          parameter I2C_CR1_CR_ACK    = 10;
          parameter I2C_CR1_CR_STOP   = 9;
          parameter I2C_CR1_CR_START  = 8;
          parameter I2C_CR1_CR_PE     = 0;

  parameter I2C_CR2_CR = 1;
          parameter I2C_CR2_CR_LAST = 12;
          parameter I2C_CR2_CR_DMAEN = 11;
          parameter I2C_CR2_CR_ITBUFEN = 10;
          parameter I2C_CR2_CR_ITEVTEN = 9;
          parameter I2C_CR2_CR_ITERREN = 8;
          parameter I2C_CR2_CR_FREQ_5 = 5;
          parameter I2C_CR2_CR_FREQ_0 = 0;

  parameter I2C_OAR1_CR = 2;
          // Not used in ver1.0
          parameter I2C_OAR1_CR_ADDMODE = 15;
          // Not used in ver1.0
          parameter I2C_OAR1_CR_ADD_9    = 9;
          // Not used in ver1.0
          parameter I2C_OAR1_CR_ADD_8    = 8;
          // Not used in ver1.0
          parameter I2C_OAR1_CR_ADD_7    = 7;
          // Not used in ver1.0
          parameter I2C_OAR1_CR_ADD_1    = 1;
          parameter I2C_OAR1_CR_ADD_0    = 0;

  parameter I2C_DR_CR   = 4;
          parameter I2C_DR_CR_DR_7  = 7;
          parameter I2C_DR_CR_DR_0  = 0;

  parameter I2C_SR1_CR  = 5;
          parameter I2C_SR1_CR_TIMEOUT  = 14;
          parameter I2C_SR1_CR_OVR      = 11;
          parameter I2C_SR1_CR_AF       = 10;
          parameter I2C_SR1_CR_ARLO     = 9;
          parameter I2C_SR1_CR_TXE      = 7;
          parameter I2C_SR1_CR_RXNE     = 6;
          // Not used in ver1.0
          parameter I2C_SR1_CR_STOPF    = 4;
          parameter I2C_SR1_CR_BTF      = 2;
          parameter I2C_SR1_CR_ADDR     = 1;
          parameter I2C_SR1_CR_SB       = 0;

  parameter I2C_SR2_CR  = 6;
          parameter I2C_SR2_CR_TRA  = 2;
          parameter I2C_SR2_CR_BUSY = 1;
          // Not used in ver1.0
          parameter I2C_SR2_CR_MSL  = 0;

  parameter I2C_CR_CNT    = 9;

/*
  Status registers
*/

  parameter I2C_VER_SR = 0;

endpackage : i2c_master_pkg

