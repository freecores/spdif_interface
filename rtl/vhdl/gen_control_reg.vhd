----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- Generic control register.                                    ----
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
use IEEE.std_logic_arith.all;

entity gen_control_reg is	 
  generic (DataWidth: integer;
           ActiveBitsMask: std_logic_vector); -- note that this vector is (0 to xx), reverse order
  port (
    clk: in std_logic;	 -- clock  
    rst: in std_logic; -- reset
    ctrl_wr: in std_logic; -- control register write	
    ctrl_rd: in std_logic; -- control register read
    ctrl_din: in std_logic_vector(DataWidth - 1 downto 0); -- write data
    ctrl_dout: out std_logic_vector(DataWidth - 1 downto 0); -- read data
    ctrl_bits: out std_logic_vector(DataWidth - 1 downto 0)); -- control bits
end gen_control_reg;

architecture rtl of gen_control_reg is

  signal ctrl_internal, BitMask: std_logic_vector(DataWidth - 1 downto 0);

begin
	
  ctrl_dout <= ctrl_internal when ctrl_rd = '1' else (others => '0');	  
  ctrl_bits <= ctrl_internal;
  
-- control register generation
--BitMask <= CONV_STD_LOGIC_VECTOR(ActiveBitsMask, ctrl_din'length);
  CTRLREG: for k in ctrl_din'range generate  
    ACTIVE: if  ActiveBitsMask(k) = '1' generate		 -- active bits can be written to
      CBIT: process (clk, rst)
      begin		 
        if rst = '1' then
          ctrl_internal(k) <= '0';
        else
          if rising_edge(clk) then
            if ctrl_wr = '1' then
              ctrl_internal(k) <= ctrl_din(k);
            end if;
          end if;	  
        end if;
      end process CBIT;			 	
    end generate;	 
    INACTIVE: if ActiveBitsMask(k) = '0' generate	-- inactive bits are always 0
      ctrl_internal(k) <= '0';
    end generate;
  end generate;
  
end rtl;
