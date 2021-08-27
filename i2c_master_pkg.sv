package i2c_master_pkg;

  parameter I2C_VER = 16'h0_0_0_1;

/*
  Control registers
*/

  parameter I2C_CR1_CR = 0;
          parameter I2C_CR1_CR_SWRST_EN = 15;
          parameter I2C_CR1_CR_ACK      = 10;
          parameter I2C_CR1_CR_STOP     = 9;
          parameter I2C_CR1_CR_START    = 8;
          parameter I2C_CR1_CR_PE       = 0;

  parameter I2C_CR2_CR = 1;
          parameter I2C_CR2_CR_LAST = 12;
          parameter I2C_CR2_CR_DMAEN = 11;
          parameter I2C_CR2_CR_FREQ5 = 5;
          parameter I2C_CR2_CR_FREQ0 = 0;

  parameter I2C_OAR1_CR = 2;

  parameter I2C_OAR2_CR = 3;

  parameter I2C_DR_CR   = 4;

  parameter I2C_SR1_CR  = 5;

  parameter I2C_SR2_CR  = 6;

  parameter I2C_CCR_CR  = 7;

  parameter I2C_TRISE_CR  = 8;

  parameter I2C_CR_CNT    = 9;

/*
  Status registers
*/

  parameter I2C_VER_SR = 0;

endpackage : i2c_master_pkg

