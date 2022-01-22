library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
    port(
      shift_lsl : in  Std_Logic;
      shift_lsr : in  Std_Logic;
      shift_asr : in  Std_Logic;
      shift_ror : in  Std_Logic;
      shift_rrx : in  Std_Logic;
      shift_val : in  Std_Logic_Vector(4 downto 0);
      din       : in  Std_Logic_Vector(31 downto 0);
      cin       : in  Std_Logic;
      dout      : out Std_Logic_Vector(31 downto 0);
      cout      : out Std_Logic;
      -- global interface
      vdd       : in  bit;
      vss       : in  bit 
    );
end shifter;

architecture archi of shifter is 
signal rshift, lshift, ashift, rot, rot_x : std_logic_vector(31 downto 0);
signal co : std_logic;

component r_shifter
  port(
    shift_val   : in std_logic_vector(4 downto 0);
    din         : in std_logic_vector(31 downto 0);
    dout        : out std_logic_vector(31 downto 0);

    -- global interface
    vdd       : in  bit;
    vss       : in  bit 
    );
end component;

component l_shifter
  port(
    shift_val   : in std_logic_vector(4 downto 0);
    din         : in std_logic_vector(31 downto 0);
    dout        : out std_logic_vector(31 downto 0);

    -- global interface
    vdd       : in  bit;
    vss       : in  bit 
    );
end component;

component a_shifter
  port(
    shift_val   : in std_logic_vector(4 downto 0);
    din         : in std_logic_vector(31 downto 0);
    dout        : out std_logic_vector(31 downto 0);

    -- global interface
    vdd       : in  bit;
    vss       : in  bit 
    );
end component;

component rotate
  port(
    shift_val   : in std_logic_vector(4 downto 0);
    din, rshift : in std_logic_vector(31 downto 0); 
    dout        : out std_logic_vector(31 downto 0);

    -- global interface
    vdd       : in  bit;
    vss       : in  bit 
    );
end component;

begin

-- logical shift right
  
  sright: r_shifter port map(shift_val, din, rshift, vdd, vss);
  
-- logical shift left
  sleft : l_shifter port map(shift_val, din, lshift, vdd, vss);

-- arithmetic shift right
  arith: a_shifter port map(shift_val, din, ashift, vdd, vss);

-- rotate right 
  rota : rotate port map(shift_val, din, rshift, rot, vdd, vss);

-- rotate right extented
rot_x <= cin & din(31 downto 1);
co <= din(0);

cout <= co when shift_rrx = '1' else '0';

dout <= lshift when shift_lsl = '1' else rshift when shift_lsr = '1' else ashift when shift_asr = '1' else rot when shift_ror = '1' else rot_x when shift_rrx = '1' else din;
        
end archi;
