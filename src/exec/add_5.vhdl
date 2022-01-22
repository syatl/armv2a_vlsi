library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_5 is
  port ( a,b  : in  Std_Logic_vector(4 downto 0);
         cin  : in  Std_Logic;
         s : out Std_Logic_vector(4 downto 0);
         cout : out Std_Logic;
         vdd, vss : in bit
       );
end add_5;


architecture add_5_archi of add_5 is
signal c1, c2, c3, c4: std_logic;
  component add_1
    port(a,b,cin : in std_logic;
         s,cout : out std_logic;
         vdd, vss : in bit);
    end component;
begin
  add1 : add_1 port map (a(0), b(0), cin, s(0), c1, vdd, vss);
  add2 : add_1 port map (a(1), b(1), c1, s(1), c2, vdd, vss);
  add3 : add_1 port map (a(2), b(2), c2, s(2), c3, vdd, vss);
  add4 : add_1 port map (a(3), b(3), c3, s(3), c4, vdd, vss);
  add5 : add_1 port map (a(4), b(4), c4, s(4), cout, vdd, vss);
end add_5_archi;
