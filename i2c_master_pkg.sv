package i2c_master_pkg;

  parameter I2C_MASTER_VER = 16'h00_00_00_01;

/*
  Control registers
*/

  parameter I2C_MASTER_MAIN_CR = 0;
          parameter I2C_MASTER_MAIN_EN_CR = 0;

  parameter I2C_MASTER_ = 1;

/*
  Status registers
*/

  parameter I2C_MASTER_VER_SR = 0;

  parameter I2C_MASTER_IRQ_SR = 1;

endpackage : i2c_master_pkg

