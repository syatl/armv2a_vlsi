library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_16 is
  port ( a,b  : in  Std_Logic_vector(15 downto 0);
         cin  : in  Std_Logic;
         s : out Std_Logic_vector(15 downto 0);
         cout : out Std_Logic;
         vdd, vss : in bit
       );
end add_16;


architecture add_16_archi of add_16 is
  signal c1,c2,c3: std_logic; 
  component add_4
    port(a,b: in  Std_Logic_vector(3 downto 0);
         cin  : in  Std_Logic;
         s : out Std_Logic_vector(3 downto 0);
         cout : out Std_Logic;
         vdd, vss : in bit
         );
    end component;
begin
  add1 : add_4 port map (a(3 downto 0), b(3 downto 0), cin, s(3 downto 0), c1, vdd, vss);
  add2 : add_4 port map (a(7 downto 4), b(7 downto 4), c1, s(7 downto 4), c2, vdd, vss);
  add3 : add_4 port map (a(11 downto 8), b(11 downto 8), c2, s(11 downto 8), c3, vdd, vss);
  add4 : add_4 port map (a(15 downto 12), b(15 downto 12), c3, s(15 downto 12), cout, vdd, vss);
  
end add_16_archi;
