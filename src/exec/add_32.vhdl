library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_32 is
  port ( a,b  : in  Std_Logic_vector(31 downto 0);
         cin  : in  Std_Logic;
         s : out Std_Logic_vector(31 downto 0);
         cout : out Std_Logic;
         vdd, vss : in bit
       );
end add_32;


architecture add_32_archi of add_32 is
  signal c1: std_logic; 
  component add_16
    port(
      a,b  : in  Std_Logic_vector(15 downto 0);
      cin  : in  Std_Logic;
      s : out Std_Logic_vector(15 downto 0);
      cout : out Std_Logic;
      vdd, vss : bit
      );
    end component;
begin
  add1 : add_16 port map (a(15 downto 0), b(15 downto 0), cin, s(15 downto 0), c1, vdd, vss);
  add2 : add_16 port map (a(31 downto 16), b(31 downto 16), c1, s(31 downto 16), cout, vdd, vss);
end add_32_archi;
    
