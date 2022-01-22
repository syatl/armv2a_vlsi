library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_1 is
  port ( a,b,cin  : in  Std_Logic;
         s,cout : out Std_Logic;
         vdd, vss : in bit
       );
end add_1;


architecture add_1_archi of add_1 is
  signal z: std_logic;
begin
  z <= a xor b;
  s <= z xor cin;
  cout <= (z and cin) or (a and b);
end add_1_archi;
    
