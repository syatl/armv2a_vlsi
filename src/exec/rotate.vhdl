library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rotate is 
    port(
        shift_val   : in std_logic_vector(4 downto 0);
        din, rshift : in std_logic_vector(31 downto 0);
        dout        : out std_logic_vector(31 downto 0);

        -- global interface
        vdd			: in bit;
        vss			: in bit
    );
end rotate;

architecture archi of rotate is 
signal lout : std_logic_vector(31 downto 0);
signal val_left, shift_val_l : std_logic_vector(4 downto 0);
signal cout : std_logic; -- simple signal de connexion pour add_5

component add_5
  port ( a,b  : in  Std_Logic_vector(4 downto 0);
         cin  : in  Std_Logic;
         s : out Std_Logic_vector(4 downto 0);
         cout : out Std_Logic;
         vdd, vss : in bit
       );
end component;

component l_shifter
  port(
    shift_val   : in std_logic_vector(4 downto 0);
    din         : in std_logic_vector(31 downto 0);
    dout        : out std_logic_vector(31 downto 0);

    -- global interface
    vdd			: in bit;
    vss			: in bit
    );
end component;

begin

val_left <= not(shift_val); -- complement a 1

    add5 : add_5 port map(val_left, "00001", '0', shift_val_l, cout, vdd, vss);    
        -- complement a 2

    lshift: l_shifter port map(shift_val_l, din, lout, vdd, vss);

dout <= lout or rshift;

end archi;
