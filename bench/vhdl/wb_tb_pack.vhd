----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- Wishbone testbench funtions.                                 ----
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
use IEEE.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

package wb_tb_pack is

  constant WRITE_TIMEOUT : integer := 20;  -- Max cycles to wait during write operation
  constant READ_TIMEOUT : integer := 20;  -- Max cycles to wait during read operation

  function str(slv: std_logic_vector) return string;
  function chr(sl: std_logic) return character;
  
  procedure WB_write (
    constant ADDRESS: in integer; 
    constant DATA: in std_logic_vector;
    signal wb_adr_o: out std_logic_vector;
    signal wb_dat_o: out std_logic_vector;
    signal wb_cyc_o: out std_logic;
    signal wb_sel_o: out std_logic;
    signal wb_we_o: out std_logic;
    signal wb_clk_i: in std_logic;
    signal wb_ack_i: in std_logic);

  procedure WB_read (
    constant ADDRESS: in integer;
    variable READ_DATA : out std_logic_vector;
    signal wb_adr_o: out std_logic_vector;
    signal wb_dat_i: in std_logic_vector;
    signal wb_cyc_o: out std_logic;
    signal wb_sel_o: out std_logic;
    signal wb_we_o: out std_logic;
    signal wb_clk_i: in std_logic;
    signal wb_ack_i: in std_logic);

  procedure WB_check (
    constant ADDRESS: in integer;
    constant EXP_DATA : in std_logic_vector;
    signal wb_adr_o: out std_logic_vector;
    signal wb_dat_i: in std_logic_vector;
    signal wb_cyc_o: out std_logic;
    signal wb_sel_o: out std_logic;
    signal wb_we_o: out std_logic;
    signal wb_clk_i: in std_logic;
    signal wb_ack_i: in std_logic);

end wb_tb_pack;

package body wb_tb_pack is

-- converts std_logic into a character
  function chr(sl: std_logic) return character is
    variable c: character;
  begin
    case sl is
      when 'U' => c:= 'U';
      when 'X' => c:= 'X';
      when '0' => c:= '0';
      when '1' => c:= '1';
      when 'Z' => c:= 'Z';
      when 'W' => c:= 'W';
      when 'L' => c:= 'L';
      when 'H' => c:= 'H';
      when '-' => c:= '-';
    end case;
    return c;
  end chr;
  
  -- converts std_logic_vector into a string (binary base)
  -- (this also takes care of the fact that the range of
  --  a string is natural while a std_logic_vector may
  --  have an integer range)
  function str(slv: std_logic_vector) return string is
    variable result : string (1 to slv'length);
    variable r : integer;
  begin
    r := 1;
    for i in slv'range loop
      result(r) := chr(slv(i));
      r := r + 1;
    end loop;
    return result;
  end str;
  
-- Classic Wishbone write cycle
  procedure WB_write (
    constant ADDRESS: in integer; 
    constant DATA: in std_logic_vector;
    signal wb_adr_o: out std_logic_vector;
    signal wb_dat_o: out std_logic_vector;
    signal wb_cyc_o: out std_logic;
    signal wb_sel_o: out std_logic;
    signal wb_we_o: out std_logic;
    signal wb_clk_i: in std_logic;
    signal wb_ack_i: in std_logic) is
    --variable ResizeAdr : unsigned(wb_adr_o'high downto 0);
    variable txt : line;
    --variable tmp : integer;
    constant WEAK_BUS: std_logic_vector(wb_adr_o'range) := (others => 'W');
    constant LOW_BUS: std_logic_vector(wb_dat_o'range) := (others => 'L');
  begin
    wait until rising_edge(wb_clk_i);
    write(txt, "@");
    write(txt, now, right, 12);
    write(txt, " Wrote ");
    write(txt, str(DATA));
    write(txt, "b to addr. ");
    write(txt, str(CONV_STD_LOGIC_VECTOR(ADDRESS, wb_adr_o'length)));
    write(txt, "b ");
    wb_adr_o <= CONV_STD_LOGIC_VECTOR(ADDRESS, wb_adr_o'length);
    wb_dat_o <= DATA;
    wb_we_o <= '1';
    wb_cyc_o <= '1';
    wb_sel_o <= '1';
    -- wait for acknowledge
    wait until rising_edge(wb_clk_i);
    if wb_ack_i /= '1' then
      for i in 1 to WRITE_TIMEOUT loop
        wait until rising_edge(wb_clk_i);
        exit when wb_ack_i = '1';
        if (i = WRITE_TIMEOUT) then
          --write(txt, string'("- @ "));
          --write(txt, now, right, DEFAULT_TIMEWIDTH, DEFAULT_TIMEBASE);
          write (txt, string'("Warning: No acknowledge recevied!"));
        end if;    
      end loop;
    end if;
    -- release bus
    wb_adr_o <= WEAK_BUS;
    wb_dat_o <= LOW_BUS;
    wb_we_o <= 'L';
    wb_cyc_o <= 'L';
    wb_sel_o <= 'L';
    writeline(OUTPUT, txt);
  end;

-- Classic Wishbone read cycle
  procedure WB_read (
    constant ADDRESS: in integer;
    variable READ_DATA : out std_logic_vector;
    signal wb_adr_o: out std_logic_vector;
    signal wb_dat_i: in std_logic_vector;
    signal wb_cyc_o: out std_logic;
    signal wb_sel_o: out std_logic;
    signal wb_we_o: out std_logic;
    signal wb_clk_i: in std_logic;
    signal wb_ack_i: in std_logic) is
    variable txt : line;
    variable tout : integer;
    constant WEAK_BUS: std_logic_vector(wb_adr_o'range) := (others => 'W');
  begin
    -- start cycle
    wait until rising_edge(wb_clk_i);
    write(txt, "@");
    write(txt, now, right, 12);
    wb_adr_o <= CONV_STD_LOGIC_VECTOR(ADDRESS, wb_adr_o'length);
    wb_we_o <= '0';
    wb_cyc_o <= '1';
    wb_sel_o <= '1';
    -- wait for acknowledge 
    wait until rising_edge(wb_clk_i);
    tout := 0;
    if wb_ack_i /= '1' then
      for i in 1 to READ_TIMEOUT loop
        wait until rising_edge(wb_clk_i);
        exit when wb_ack_i = '1';
        if (i = READ_TIMEOUT) then
          --write(txt, string'("- @ "));
          --write(txt, now, right, DEFAULT_TIMEWIDTH, DEFAULT_TIMEBASE);
          write (txt, string'("Warning: WB_read timeout!"));
          writeline(OUTPUT, txt);
          tout := 1;
        end if;    
      end loop;
    end if;
    --READ_DATA := wb_dat_i;
    if tout = 0 then
      write(txt, " Read  ");
      write(txt, str(wb_dat_i));
      write(txt, "b from addr. ");
      write(txt, str(CONV_STD_LOGIC_VECTOR(ADDRESS, wb_adr_o'length)));
      write(txt, "b ");
      writeline(OUTPUT, txt);
    end if;
    -- release bus
    wb_adr_o <= WEAK_BUS;
    wb_we_o <= 'L';
    wb_cyc_o <= 'L';
    wb_sel_o <= 'L';
  end;

-- Check: A read operation followed by a data compare
  procedure WB_check (
    constant ADDRESS: in integer;
    constant EXP_DATA : in std_logic_vector;
    signal wb_adr_o: out std_logic_vector;
    signal wb_dat_i: in std_logic_vector;
    signal wb_cyc_o: out std_logic;
    signal wb_sel_o: out std_logic;
    signal wb_we_o: out std_logic;
    signal wb_clk_i: in std_logic;
    signal wb_ack_i: in std_logic) is
    variable txt : line;
    variable tout : integer;
    constant WEAK_BUS: std_logic_vector(wb_adr_o'range) := (others => 'W');
    variable RData : std_logic_vector(EXP_DATA'left downto 0);
  begin
    -- start cycle
    wait until rising_edge(wb_clk_i);
    write(txt, "@");
    write(txt, now, right, 12);
    wb_adr_o <= CONV_STD_LOGIC_VECTOR(ADDRESS, wb_adr_o'length);
    wb_we_o <= '0';
    wb_cyc_o <= '1';
    wb_sel_o <= '1';
    -- wait for acknowledge 
    wait until rising_edge(wb_clk_i);
    tout := 0;
    if wb_ack_i /= '1' then
      for i in 1 to READ_TIMEOUT loop
        wait until rising_edge(wb_clk_i);
        exit when wb_ack_i = '1';
        if (i = READ_TIMEOUT) then
          --write(txt, string'("- @ "));
          --write(txt, now, right, DEFAULT_TIMEWIDTH, DEFAULT_TIMEBASE);
          write (txt, string'(" Warning: WB_check timeout!"));
          writeline(OUTPUT, txt);
          tout := 1;
        end if;    
      end loop;
    end if;
    --READ_DATA := wb_dat_i;
    if tout = 0 then
      if wb_dat_i = EXP_DATA then
        write(txt, " Check ");
        write(txt, str(wb_dat_i));
        write(txt, "b at addr. ");
        write(txt, str(CONV_STD_LOGIC_VECTOR(ADDRESS, wb_adr_o'length)));
        write(txt, "b ");
      else
        write(txt, " Check failed at addr. ");
        write(txt, str(CONV_STD_LOGIC_VECTOR(ADDRESS, wb_adr_o'length)));
        write(txt, "b! Got ");
        write(txt, str(wb_dat_i));
        write(txt, "b, expected ");
        write(txt, str(EXP_DATA));
        write(txt, "b");
      end if;
        writeline(OUTPUT, txt);
    end if;
    -- release bus
    wb_adr_o <= WEAK_BUS;
    wb_we_o <= 'L';
    wb_cyc_o <= 'L';
    wb_sel_o <= 'L';
    --if RData /= EXP_DATA then
    --  write (txt, string'("Error: WB_check failed!"));
    --  writeline(OUTPUT, txt);
    --end if;
  end;  
  
end wb_tb_pack;

