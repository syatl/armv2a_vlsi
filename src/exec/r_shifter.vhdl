library ieee;
use ieee.std_logic_1164.all;

entity r_shifter is 
    port(
        shift_val   : in std_logic_vector(4 downto 0);
        din         : in std_logic_vector(31 downto 0);
        dout        : out std_logic_vector(31 downto 0);

        -- global interface
        vdd       : in  bit;
        vss       : in  bit 
    );
end r_shifter;

architecture archi of r_shifter is 
signal shift1, shift2, shift4, shift8, shift16 : std_logic_vector(31 downto 0);

begin

    shift16 <= x"0000" & din(31 downto 16) when shift_val(4) = '1' else din;
    shift8  <= x"00" & shift16(31 downto 8) when shift_val(3) = '1' else shift16; 
    shift4  <= x"0" & shift8(31 downto 4) when shift_val(2) = '1' else shift8; 
    shift2  <= "00" & shift4(31 downto 2) when shift_val(1) = '1' else shift4;
    shift1  <= '0' & shift2(31 downto 1) when shift_val(0) = '1' else shift2;
    
    dout <= shift1;
end archi;
