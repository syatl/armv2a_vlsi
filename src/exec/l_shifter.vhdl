library ieee;
use ieee.std_logic_1164.all;

entity l_shifter is 
    port(
        shift_val   : in std_logic_vector(4 downto 0);
        din         : in std_logic_vector(31 downto 0);
        dout        : out std_logic_vector(31 downto 0);

        -- global interface
        vdd       : in  bit;
        vss       : in  bit 
    );
end l_shifter;

architecture archi of l_shifter is 
signal shift1, shift2, shift4, shift8, shift16 : std_logic_vector(31 downto 0);

begin

    shift16 <= din(15 downto 0) & x"0000" when shift_val(4) = '1' else din;
    shift8  <= shift16(23 downto 0) & x"00" when shift_val(3) = '1' else shift16; 
    shift4  <= shift8(27 downto 0) & x"0" when shift_val(2) = '1' else shift8; 
    shift2  <= shift4(29 downto 0) & "00" when shift_val(1) = '1' else shift4;
    shift1  <= shift2(30 downto 0) & '0' when shift_val(0) = '1' else shift2;
    
    dout <= shift1;
end archi;
