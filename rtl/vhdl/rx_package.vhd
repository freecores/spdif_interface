----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- SPDIF receiver component package.                            ----
----                                                              ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Geir Drange, gedra@opencores.org                           ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2004 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
--
 
library IEEE;
use IEEE.std_logic_1164.all; 

package rx_package is

-- type declarations
  type bus_array is array (0 to 7) of std_logic_vector(31 downto 0);

-- components
  component rx_ver_reg  
    generic (DATA_WIDTH: integer;
             ADDR_WIDTH: integer;
             CH_ST_CAPTURE: integer);
    port (
      ver_rd: in std_logic; -- version register read
      ver_dout: out std_logic_vector(DATA_WIDTH - 1 downto 0)); -- read data
  end component;

  component gen_control_reg 	 
    generic (DATA_WIDTH: integer;
             -- note that this vector is (0 to xx), reverse order
             ACTIVE_BIT_MASK: std_logic_vector); 
    port (
      clk: in std_logic;	 -- clock  
      rst: in std_logic; -- reset
      ctrl_wr: in std_logic; -- control register write	
      ctrl_rd: in std_logic; -- control register read
      ctrl_din: in std_logic_vector(DATA_WIDTH - 1 downto 0); 
      ctrl_dout: out std_logic_vector(DATA_WIDTH - 1 downto 0); 
      ctrl_bits: out std_logic_vector(DATA_WIDTH - 1 downto 0)); 
  end component;

  component rx_status_reg 	 
    generic (DATA_WIDTH: integer);
    port (
      status_rd: in std_logic;            -- status register read
      status_vector: in std_logic_vector(DATA_WIDTH - 1 downto 0); 
      status_dout: out std_logic_vector(DATA_WIDTH - 1 downto 0)); 
  end component;

  component gen_event_reg 	 
    generic (DATA_WIDTH: integer);	
    port (
      clk: in std_logic;	 -- clock  
      rst: in std_logic; -- reset
      evt_wr: in std_logic; -- event register write	
      evt_rd: in std_logic; -- event register read
      evt_din: in std_logic_vector(DATA_WIDTH - 1 downto 0); -- write data
      event: in std_logic_vector(DATA_WIDTH - 1 downto 0); -- event vector
      evt_mask: in std_logic_vector(DATA_WIDTH - 1 downto 0); -- irq mask
      evt_en: in std_logic;               -- irq enable
      evt_dout: out std_logic_vector(DATA_WIDTH - 1 downto 0); -- read data
      evt_irq: out std_logic); -- interrupt  request
  end component;

  component rx_cap_reg 	 
    port (
      clk: in std_logic;                  -- clock
      rst: in std_logic; -- reset
      cap_ctrl_wr: in std_logic; -- control register write	
      cap_ctrl_rd: in std_logic; -- control register read
      cap_data_rd: in std_logic;          -- data register read
      cap_din: in std_logic_vector(31 downto 0); -- write data
      frame_rst: in std_logic; -- start of frame signal
      ch_data: in std_logic;  -- channel status/user data
      ud_a_en: in std_logic;            -- user data ch. A enable
      ud_b_en: in std_logic;              -- user data ch. B enable
      cs_a_en: in std_logic;              -- channel status ch. A enable
      cs_b_en: in std_logic;              -- channel status ch. B enable
      cap_dout: out std_logic_vector(31 downto 0); -- read data
      cap_evt: out std_logic);             -- capture event (interrupt)
  end component;

  component rx_phase_det
    generic (WISH_BONE_FREQ: natural := 33);   -- WishBone frequency in MHz
    port (
      wb_clk_i: in std_logic;
      rxen: in std_logic;
      spdif: in std_logic;
      lock: out std_logic;
      rx_data: out std_logic;
      rx_data_en: out std_logic;
      rx_block_start: out std_logic;
      rx_frame_start: out std_logic;
      rx_channel_a: out std_logic;
      rx_error: out std_logic;
      ud_a_en: out std_logic;              -- user data ch. A enable
      ud_b_en: out std_logic;              -- user data ch. B enable
      cs_a_en: out std_logic;              -- channel status ch. A enable
      cs_b_en: out std_logic);             -- channel status ch. B enable);            
  end component;
  
end rx_package;
