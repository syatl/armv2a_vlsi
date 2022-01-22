library ieee;
use ieee.std_logic_1164.all;

entity a_shifter is 
    port(
        shift_val   : in std_logic_vector(4 downto 0);
        din         : in std_logic_vector(31 downto 0);
        dout        : out std_logic_vector(31 downto 0);

        -- global interface
        vdd       : in  bit;
        vss       : in  bit 
    );
end a_shifter;

architecture archi of a_shifter is 
signal shift1, shift2, shift4, shift8, shift16 : std_logic_vector(31 downto 0);
signal sign1 : std_logic;
signal sign2 : std_logic_vector(1 downto 0);
signal sign4 : std_logic_vector(3 downto 0);
signal sign8 : std_logic_vector(7 downto 0);
signal sign16 : std_logic_vector(15 downto 0);
begin
    sign1 <= din(31);
    sign2 <= sign1 & sign1;
    sign4 <= sign2 & sign2;
    sign8 <= sign4 & sign4;
    sign16 <= sign8 & sign8;

    shift16 <= sign16 & din(31 downto 16) when shift_val(4) = '1' else din;
    shift8  <= sign8 & shift16(31 downto 8) when shift_val(3) = '1' else shift16; 
    shift4  <= sign4 & shift8(31 downto 4) when shift_val(2) = '1' else shift8; 
    shift2  <= sign2 & shift4(31 downto 2) when shift_val(1) = '1' else shift4;
    shift1  <= sign1 & shift2(31 downto 1) when shift_val(0) = '1' else shift2;
    
    dout <= shift1;
end archi;
