----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- Bit buffer holding 2x192 bits of either channel status or    ----
---- user data for the transmitter.                               ----
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
--

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity tx_bitbuf is	 
  generic (ENABLE_BUFFER: integer range 0 to 1); 
  port (
    wb_clk_i: in std_logic;             -- clock
    wb_rst_i: in std_logic;             -- reset
    buf_wr: in std_logic;               -- buffer write strobe
    wb_adr_i: in std_logic_vector(4 downto 0);  -- address
    wb_dat_i: in std_logic_vector(15 downto 0);  -- data
    buf_data_a: out std_logic_vector(191 downto 0);
    buf_data_b: out std_logic_vector(191 downto 0));
end tx_bitbuf;

architecture rtl of tx_bitbuf is

begin

  -- the byte buffer is 192 bits (24 bytes) for each channel 
  EB: if ENABLE_BUFFER = 1 generate
    WBUF: process (wb_clk_i, wb_rst_i)
    begin
      if wb_rst_i = '1' then
        buf_data_a(191 downto 0) <= (others => '0');
        buf_data_b(191 downto 0) <= (others => '0');
      elsif rising_edge(wb_clk_i) then
        if buf_wr = '1'  then
          buf_data_a(8*to_integer(unsigned(wb_adr_i)) + 7 downto
                     8*to_integer(unsigned(wb_adr_i))) <= wb_dat_i(7 downto 0);
          buf_data_b(8*to_integer(unsigned(wb_adr_i)) + 7 downto
                     8*to_integer(unsigned(wb_adr_i))) <= wb_dat_i(15 downto 8);
        end if;
      end if;
    end process WBUF;
  end generate EB;
  
  -- if the byte buffer is not enabled, set all bits to zero
  NEB: if ENABLE_BUFFER = 0 generate
    buf_data_a(191 downto 0) <= (others => '0');
    buf_data_b(191 downto 0) <= (others => '0');
  end generate NEB;
  
end rtl;
