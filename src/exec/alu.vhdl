library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Alu is
  port ( op1  : in  Std_Logic_Vector(31 downto 0);
         op2  : in  Std_Logic_Vector(31 downto 0);
         cin  : in  Std_Logic;
         cmd  : in  Std_Logic_Vector(1 downto 0);
         res  : out Std_Logic_Vector(31 downto 0);
         cout : out Std_Logic;
         z    : out Std_Logic;
         n    : out Std_Logic;
         v    : out Std_Logic;
         vdd  : in  bit;
         vss  : in  bit
         );
end Alu;


architecture alu_archi of alu is
signal res_temp, res_add : std_logic_vector(31 downto 0);
signal cout_temp, res_add_c : std_logic;  

component add_32
port(a,b: in  Std_Logic_vector(31 downto 0);
     cin  : in  Std_Logic;
     s : out Std_Logic_vector(31 downto 0);
     cout : out Std_Logic;
     vdd, vss : in bit
     );
end component;

begin
    
  add : add_32 port map (op1, op2, cin, res_add, res_add_c, vdd, vss);
  
  res_temp <= res_add when cmd = "00" else
              op1 and op2 when cmd = "01" else 
              op1 or  op2 when cmd = "10" else 
              op1 xor op2;    

  cout_temp <= res_add_c when cmd = "00" else '0';         

  n <= '1' when res_temp(31) = '1' else '0';
  z <= '1' when res_temp = x"00000000" else '0';
  v <= cout_temp;
  cout <= cout_temp;
  res <= res_temp;

end alu_archi;
