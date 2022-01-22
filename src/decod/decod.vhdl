library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decod is
	port(
	-- Exec  operands
			dec_op1			: out Std_Logic_Vector(31 downto 0);          -- first alu input
			dec_op2			: out Std_Logic_Vector(31 downto 0);          -- shifter input
			dec_exe_dest	        : out Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: out Std_Logic;                            -- Rd destination write back
			dec_flag_wb		: out Std_Logic;                            -- CSPR modifiy

	-- Decod to mem via exec
			dec_mem_data	        : out Std_Logic_Vector(31 downto 0); -- data to MEM
			dec_mem_dest	        : out Std_Logic_Vector(3 downto 0);
			dec_pre_index 	        : out Std_logic;

			dec_mem_lw		: out Std_Logic;
			dec_mem_lb		: out Std_Logic;
			dec_mem_sw		: out Std_Logic;
			dec_mem_sb		: out Std_Logic;

	-- Shifter command
			dec_shift_lsl	        : out Std_Logic;
			dec_shift_lsr	        : out Std_Logic;
			dec_shift_asr	        : out Std_Logic;
			dec_shift_ror	        : out Std_Logic;
			dec_shift_rrx	        : out Std_Logic;
			dec_shift_val	        : out Std_Logic_Vector(4 downto 0);
			dec_cy			: out Std_Logic;

	-- Alu operand selection
			dec_comp_op1	        : out Std_Logic;
			dec_comp_op2	        : out Std_Logic;
			dec_alu_cy 		: out Std_Logic;

	-- Exec Synchro
			dec2exe_empty	        : out Std_Logic;
			exe_pop			: in Std_logic;

	-- Alu command 
      dec_alu_cmd             : out std_logic_vector(1 downto 0);
                        
	-- Exe Write Back to reg
			exe_res			: in Std_Logic_Vector(31 downto 0);

			exe_c			: in Std_Logic;
			exe_v			: in Std_Logic;
			exe_n			: in Std_Logic;
			exe_z			: in Std_Logic;

			exe_dest		: in Std_Logic_Vector(3 downto 0);  -- Rd destination
			exe_wb			: in Std_Logic;                     -- Rd destination write back
			exe_flag_wb		: in Std_Logic;                   -- CSPR modifiy

	-- Ifetch interface
			dec_pc			: out Std_Logic_Vector(31 downto 0);
			if_ir			: in Std_Logic_Vector(31 downto 0);

	-- Ifetch synchro
			dec2if_empty	        : out Std_Logic;
			if_pop			: in Std_Logic;

			if2dec_empty	        : in Std_Logic;
			dec_pop			: out Std_Logic;

	-- Mem Write back to reg
			mem_res			: in Std_Logic_Vector(31 downto 0);
			mem_dest		: in Std_Logic_Vector(3 downto 0);
			mem_wb			: in Std_Logic;
			
	-- global interface
			ck			: in Std_Logic;
			reset_n			: in Std_Logic;
			vdd			: in bit;
			vss			: in bit);
end Decod;

----------------------------------------------------------------------

architecture Behavior OF Decod is

component reg
	port(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0);
		wadr1		: in Std_Logic_Vector(3 downto 0);
		wen1		: in Std_Logic;

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0);
		wadr2		: in Std_Logic_Vector(3 downto 0);
		wen2		: in Std_Logic;

	-- Write CSPR Port
		wcry		: in Std_Logic;
		wzero		: in Std_Logic;
		wneg		: in Std_Logic;
		wovr		: in Std_Logic;
		cspr_wb		: in Std_Logic;
		
	-- Read Port 1 32 bits
		reg_rd1		: out Std_Logic_Vector(31 downto 0);
		radr1		: in Std_Logic_Vector(3 downto 0);
		reg_v1		: out Std_Logic;

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0);
		radr2		: in Std_Logic_Vector(3 downto 0);
		reg_v2		: out Std_Logic;

	-- Read Port 3 5 bits (for shifter)
		reg_rd3		: out Std_Logic_Vector(31 downto 0);
		radr3		: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic;

	-- read CSPR Port
    reg_cry		: out Std_Logic;
		reg_zero	: out Std_Logic;
		reg_neg		: out Std_Logic;
		reg_ovr		: out Std_Logic;
		
		reg_cznv	: out Std_Logic;
		reg_vv		: out Std_Logic;

	-- Invalidate Port 
		inval_adr1	: in Std_Logic_Vector(3 downto 0);
		inval1		: in Std_Logic;

		inval_adr2	: in Std_Logic_Vector(3 downto 0);
		inval2		: in Std_Logic;

		inval_czn	: in Std_Logic;
		inval_ovr	: in Std_Logic;

	-- PC
		reg_pc		: out Std_Logic_Vector(31 downto 0);
		reg_pcv		: out Std_Logic;
		inc_pc		: in Std_Logic;
	
	-- global interface
		ck		: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd		: in bit;
		vss		: in bit);
end component;

component fifo_127
	port(
		din		: in std_logic_vector(126 downto 0);
		dout		: out std_logic_vector(126 downto 0);

		-- commands
		push		: in std_logic;
		pop		: in std_logic;

		-- flags
		full		: out std_logic;
		empty		: out std_logic;

		reset_n	        : in std_logic;
		ck		: in std_logic;
		vdd		: in bit;
		vss		: in bit
	);
end component;

component fifo_32
	port(
		din		: in std_logic_vector(31 downto 0);
		dout		: out std_logic_vector(31 downto 0);

		-- commands
		push		: in std_logic;
		pop		: in std_logic;

		-- flags
		full		: out std_logic;
		empty		: out std_logic;

		reset_n	        : in std_logic;
		ck		: in std_logic;
		vdd		: in bit;
		vss		: in bit
	);
end component;

signal cond	: Std_Logic;  --  predicats (vrai / faux)
signal condv	: Std_Logic;  --  predicats (valide / invalide)

signal regop_t  : Std_Logic;
signal mult_t   : Std_Logic;
signal swap_t   : Std_Logic;
signal trans_t  : Std_Logic;
signal mtrans_t : Std_Logic;
signal branch_t : Std_Logic;

-- Opcode
signal opcode : std_logic_vector(3 downto 0);

signal immediat : std_logic := '0';

-- regop instructions
signal and_i  : Std_Logic := '0';
signal eor_i  : Std_Logic := '0';
signal sub_i  : Std_Logic := '0';
signal rsb_i  : Std_Logic := '0';
signal add_i  : Std_Logic := '0';
signal adc_i  : Std_Logic := '0';
signal sbc_i  : Std_Logic := '0';
signal rsc_i  : Std_Logic := '0';
signal tst_i  : Std_Logic := '0';
signal teq_i  : Std_Logic := '0';
signal cmp_i  : Std_Logic := '0';
signal cmn_i  : Std_Logic := '0';
signal orr_i  : Std_Logic := '0';
signal mov_i  : Std_Logic := '0';
signal bic_i  : Std_Logic := '0';
signal mvn_i  : Std_Logic := '0';

-- mult instruction
signal mul_i  : Std_Logic := '0';
signal mla_i  : Std_Logic := '0';

-- trans instruction
signal ldr_i  : Std_Logic := '0';
signal str_i  : Std_Logic := '0';
signal ldrb_i : Std_Logic := '0';
signal strb_i : Std_Logic := '0';

-- mtrans instruction
signal ldm_i  : Std_Logic := '0';
signal stm_i  : Std_Logic := '0';

-- mtrans operands
signal mtrans_regs : std_logic_vector(15 downto 0);

-- branch instruction
signal b_i    : Std_Logic := '0';
signal bl_i   : Std_Logic := '0';

-- Flags
signal cry	: Std_Logic;
signal zero	: Std_Logic;
signal neg	: Std_Logic;
signal ovr	: Std_Logic;

signal r_cznv   : std_logic;
signal r_vv     : std_logic;

signal dec2exe_wb       : std_logic;          
signal dec2exe_fwb       : std_logic;         

signal pre_index : std_logic;                   
-- Regs
signal rd, rn, rm, rs : std_logic_vector(3 downto 0);

signal r_data1, r_data2, r_data3 : std_logic_vector(31 downto 0);
signal rv1, rv2, rv3 : std_logic;

-- Inval
signal i_adr1, i_adr2 : std_logic_vector(3 downto 0);
signal inva1, inva2   : std_logic;
signal i_czn, i_v     : std_logic;

signal opv            : std_logic;

-- PC
signal r_pc : std_logic_vector(31 downto 0);
signal r_pcv, pc_pp : std_logic;

-- DECOD FSM
--    states
type state is (fetch, run, link, branch, mtrans);
signal cur_state, next_state : state;
--    sorties
signal debug : std_logic_vector(3 downto 0) := "0000";
-- Fifo PC
signal dec2if_push  : std_logic;
  
signal dec2if_full  : std_logic;

-- Fifo IR
signal if2dec_pop : std_logic;

-- Fifo Dec exe
signal dec2exe_push  : std_logic;

signal dec2exe_full  : std_logic;

signal dec2exe_op1 : std_logic_vector(31 downto 0);
signal dec2exe_op2 : std_logic_vector(31 downto 0);

-- Shifter
signal dec2exe_shift_lsl : std_logic;
signal dec2exe_shift_lsr : std_logic;
signal dec2exe_shift_asr : std_logic;
signal dec2exe_shift_ror : std_logic;
signal dec2exe_shift_rrx : std_logic;
signal dec2exe_shift_val : std_logic_vector(4 downto 0);

signal dec2exe_cy : std_logic;
signal dec2exe_comp_op1 : std_logic;
signal dec2exe_comp_op2 : std_logic;

signal dec2exe_alu_cmd : std_logic_vector(1 downto 0);
signal dec2exe_alu_cy : std_logic;
-- Fifo dec mem
signal dec2mem_data :std_logic_vector(31 downto 0); -- store
signal dec2mem_dest :std_logic_vector(3 downto 0);  -- load

signal dec2mem_lw : std_logic;
signal dec2mem_lb : std_logic;
signal dec2mem_sw : std_logic;
signal dec2mem_sb : std_logic;
begin
  reg_i : reg
    port map
    (
      wdata1     => exe_res,
      wadr1      => exe_dest,
      wen1       => exe_wb,

      wdata2     => mem_res,
      wadr2      => mem_dest,
      wen2       => mem_wb,

      wcry       => exe_c,
      wzero      => exe_z,
      wneg       => exe_n,
      wovr       => exe_v,
      cspr_wb    => exe_flag_wb,

      reg_rd1     => r_data1,
      radr1      => rn,
      reg_v1    => rv1,

      reg_rd2     => r_data2,
      radr2      => rm,
      reg_v2    => rv2,

      reg_rd3     => r_data3,
      radr3      => rs,
      reg_v3    => rv3,

      reg_cry        => cry,
      reg_zero       => zero,
      reg_neg        => neg,
      reg_ovr        => ovr,

      reg_cznv   => r_cznv,
      reg_vv     => r_vv,

      inval_adr1 => i_adr1,
      inval1     => inva1,

      inval_adr2 => i_adr2,
      inval2     => inva2,

      inval_czn  => i_czn,
      inval_ovr  => i_v,

      reg_pc     => r_pc,
      reg_pcv    => r_pcv,
      inc_pc     => pc_pp,

      ck         => ck,
      reset_n    => reset_n,
      vdd        => vdd,
      vss        => vss
    );

  dec2exec : fifo_127
    port map
    (
      -- signaux
      din(126 downto 95) => dec2exe_op1,
      din(94 downto 63) => dec2exe_op2,
      din(62 downto 59) => rd,
      din(58) => dec2exe_wb,
      din(57) => dec2exe_fwb,
      din(56 downto 25) => dec2mem_data,
      din(24 downto 21) => dec2mem_dest,
      din(20)  => pre_index,
      
      din(19) =>  dec2mem_lw,
      din(18) =>  dec2mem_lb,
      din(17) =>  dec2mem_sw,
      din(16) =>  dec2mem_sb,
      
      din(15) =>  dec2exe_shift_lsl,
      din(14) =>  dec2exe_shift_lsr,
      din(13) =>  dec2exe_shift_asr,
      din(12) =>  dec2exe_shift_ror,
      din(11) =>  dec2exe_shift_rrx,
      din(10 downto 6) =>  dec2exe_shift_val,
      
      din(5) =>  dec2exe_cy,
      
      din(4) => dec2exe_comp_op1,
      din(3) => dec2exe_comp_op2,     
      din(2) => dec2exe_alu_cy,
      
      din(1 downto 0) => dec2exe_alu_cmd,
      
      -- port
      dout(126 downto 95) => dec_op1,
      dout(94 downto 63) => dec_op2,
      dout(62 downto 59) => dec_exe_dest,
      dout(58) => dec_exe_wb,
      dout(57) => dec_flag_wb,
      dout(56 downto 25) => dec_mem_data,
      dout(24 downto 21) => dec_mem_dest,
      dout(20) => dec_pre_index,
      
      dout(19) => dec_mem_lw,
      dout(18) => dec_mem_lb,
      dout(17) => dec_mem_sw,
      dout(16) => dec_mem_sb,
      
      dout(15) => dec_shift_lsl,
      dout(14) => dec_shift_lsr,
      dout(13) => dec_shift_asr,
      dout(12) => dec_shift_ror,
      dout(11) => dec_shift_rrx,
      dout(10 downto 6) => dec_shift_val,
      dout(5) => dec_cy,
      
      dout(4) => dec_comp_op1,
      dout(3) => dec_comp_op2,
      dout(2) => dec_alu_cy,
      
      dout(1 downto 0) => dec_alu_cmd,
      
      -- ctrl
      push   => dec2exe_push,
      pop    => exe_pop,
    
      full   => dec2exe_full,
      empty  => dec2exe_empty,
    
      -- env
      ck => ck,
      reset_n => reset_n,
      vdd => vdd,
      vss => vss
    );      

  dec2if : fifo_32
    port map
    (
      din     => r_pc, 
      dout    => dec_pc, 
      
      push    => dec2if_push,
      pop     => if_pop,

      full    => dec2if_full,
      empty   => dec2if_empty,

      ck      => ck,
      reset_n => reset_n, 
      vdd     => vdd, 
      vss     => vss
    );


  -- Execution condition

  -- predicats
  cond <= '1'  when (if_ir(31 downto 28) = x"0" and zero = '1') or
          (if_ir(31 downto 28) = x"1" and zero = '0') or
          (if_ir(31 downto 28) = x"2" and cry = '1') or
          (if_ir(31 downto 28) = x"3" and cry = '0') or
          (if_ir(31 downto 28) = x"4" and neg = '1') or
          (if_ir(31 downto 28) = x"5" and neg = '0') or
          (if_ir(31 downto 28) = x"6" and ovr = '1') or
          (if_ir(31 downto 28) = x"7" and ovr = '0') or
          (if_ir(31 downto 28) = x"8" and cry = '1' and zero = '0') or
          (if_ir(31 downto 28) = x"9" and (cry = '0' or zero = '1')) or
          (if_ir(31 downto 28) = x"A" and neg = ovr) or
          (if_ir(31 downto 28) = x"B" and neg /= ovr) or
          (if_ir(31 downto 28) = x"C" and (zero = '0' and (neg = ovr))) or
          (if_ir(31 downto 28) = x"D" and (zero = '1' or (neg /= ovr))) or
          (if_ir(31 downto 28) = x"E") else '0';


  condv <= r_cznv when (if_ir(31 downto 28) = x"0") or
           (if_ir(31 downto 28) = x"1") or
           (if_ir(31 downto 28) = x"2") or
           (if_ir(31 downto 28) = x"3") or
           (if_ir(31 downto 28) = x"4") or
           (if_ir(31 downto 28) = x"5") or
           (if_ir(31 downto 28) = x"8") or
           (if_ir(31 downto 28) = x"9") else
           r_vv when (if_ir(31 downto 28) = x"6") or
           (if_ir(31 downto 28) = x"7") else
           r_vv and r_cznv when (if_ir(31 downto 28) = x"A") or
           (if_ir(31 downto 28) = x"B") or
           (if_ir(31 downto 28) = x"C") or
           (if_ir(31 downto 28) = x"D") else
           '1' when if_ir(31 downto 28) = x"E" else '0';
                                
        -- decod instruction type
        regop_t  <= '1' when if_ir(27 downto 26) =  "00" else '0';
        mult_t   <= '1' when if_ir(27 downto 22) =  "000000" else '0';
        trans_t  <= '1' when if_ir(27 downto 26) =  "01" else '0';
        mtrans_t <= '1' when if_ir(27 downto 25) =  "100" else '0';
        branch_t <= '1' when if_ir(27 downto 25) =  "101" else '0';

        -- Opcode
        opcode <= if_ir(24 downto 21);
        
        -- decod regop opcode
        and_i <= '1' when regop_t = '1' and opcode = x"0" else '0';
        eor_i <= '1' when regop_t = '1' and opcode = x"1" else '0';
        sub_i <= '1' when regop_t = '1' and opcode = x"2" else '0';
        rsb_i <= '1' when regop_t = '1' and opcode = x"3" else '0';
        add_i <= '1' when regop_t = '1' and opcode = x"4" else '0';
        adc_i <= '1' when regop_t = '1' and opcode = x"5" else '0';
        sbc_i <= '1' when regop_t = '1' and opcode = x"6" else '0';
        rsc_i <= '1' when regop_t = '1' and opcode = x"7" else '0';
        tst_i <= '1' when regop_t = '1' and opcode = x"8" else '0';
        teq_i <= '1' when regop_t = '1' and opcode = x"9" else '0';
        cmp_i <= '1' when regop_t = '1' and opcode = x"A" else '0';
        cmn_i <= '1' when regop_t = '1' and opcode = x"B" else '0';
        orr_i <= '1' when regop_t = '1' and opcode = x"C" else '0';
        mov_i <= '1' when regop_t = '1' and opcode = x"D" else '0';
        bic_i <= '1' when regop_t = '1' and opcode = x"E" else '0';
        mvn_i <= '1' when regop_t = '1' and opcode = x"F" else '0';

        -- mult instr
        mul_i <= '1' when mult_t = '1' and if_ir(21) = '0' else '0';
        mla_i <= '1' when mult_t = '1' and if_ir(21) = '1' else '0';
        
        -- trans instr
        ldr_i  <= '1' when trans_t = '1' and if_ir(20) = '1' else '0';
        str_i  <= '1' when trans_t = '1' and if_ir(20) = '0' else '0';
        ldrb_i <= '1' when trans_t = '1' and if_ir(20) = '1' and if_ir(22) = '1' else '0';
        strb_i <= '1' when trans_t = '1' and if_ir(20) = '0' and if_ir(22) = '1'  else '0';
        
        -- mtrans instr
        ldm_i <= '1' when mtrans_t = '1' and if_ir(20) = '1' else '0';
        stm_i <= '1' when mtrans_t = '1' and if_ir(20) = '0' else '0';
        mtrans_regs <= if_ir(15 downto 0) when mtrans_t = '1' else x"0000";
        
        -- branch instr
        b_i  <= '1' when branch_t = '1' and if_ir(24) = '0' else '0';
        bl_i <= '1' when branch_t = '1' and if_ir(24) = '1' else '0';

        -- regs
        rn <= x"F" when b_i = '1' or bl_i = '1' else
              if_ir(19 downto 16);
  
        rd <= x"E" when bl_i = '1' else
              x"F" when b_i = '1' else
              if_ir(15 downto 12);
  
        rm <= if_ir(3 downto 0);
        rs <= if_ir(11 downto 8);

        -- invalid operands
        opv <=  rv1                 when regop_t = '1'  and if_ir(25) = '1' else
                rv1 and rv2 and rv3 when regop_t = '1'  and if_ir(25) = '0' and if_ir(4) = '1'  else
                rv1 and rv2         when regop_t = '1'  and if_ir(25) = '0' and if_ir(4) = '0'  else
                rv1                 when trans_t = '1'  and if_ir(25) = '0'                     else
                rv1 and rv2 and rv3 when trans_t = '1'  and if_ir(25) = '1' and if_ir(4) = '1'  else
                rv1 and rv2         when trans_t = '1'  and if_ir(25) = '1' and if_ir(4) = '0'  else 
                r_pcv               when b_i = '1'                                              else
                rv1                 when bl_i = '1'                                             else '0'; 

        -- inval regs
        dec2exe_wb <= branch_t or and_i or eor_i or sub_i or rsb_i or add_i or
                                 adc_i or sbc_i or rsc_i or orr_i or mov_i or
                                 bic_i or mvn_i;
        dec2exe_fwb <= regop_t and if_ir(20);

        i_adr1 <= rd;
        inva1 <= (dec2exe_wb and cond and condv and dec2exe_push);
        
        
        ------- MEM
        dec2mem_lw <= ldr_i or ldm_i;
        dec2mem_lb <= ldrb_i;
        dec2mem_sw <= str_i or stm_i;
        dec2mem_sb <= strb_i;

        i_adr2 <= mem_dest;
        inva2 <= (mem_wb and cond and condv and dec2exe_push) and (ldr_i or ldrb_i);
        pre_index <= if_ir(24);


        -- alu cmd 
        dec2exe_alu_cmd <=  "01" when (and_i = '1' or tst_i = '1' or bic_i = '1') else
                        "10" when (orr_i = '1') else
                        "11" when (eor_i = '1' or teq_i = '1') else
                        "00";
        -- alu_input
        dec2exe_op1 <=  x"00000000" when (mov_i = '1' or mvn_i = '1') else 
                        r_pc when b_i = '1'else r_data1;
  
        -- immediate instruction 
        immediat <= (if_ir(25) and regop_t) or (not (if_ir(25)) and trans_t);

        dec2exe_op2 <=  r_data2 when (immediat = '0' and (regop_t = '1' or trans_t = '1')) else
                        x"000000" & if_ir(7 downto 0) when (immediat = '1' and regop_t = '1') else 
                        x"00000" & if_ir(11 downto 0) when (immediat = '1' and trans_t = '1') else 
                        "0000000" & if_ir(24 downto 0) when b_i = '1' else 
                        x"00000004" when bl_i = '1' else 
                        x"00000000";



        dec2exe_comp_op1 <= rsb_i or rsc_i;
        dec2exe_comp_op2 <= sub_i or sbc_i or cmp_i or bic_i or mvn_i; 

        dec2exe_alu_cy <= dec2exe_comp_op2 and (sub_i or sbc_i or rsb_i or rsc_i or cmp_i);
        
        dec2exe_shift_lsl <= '1' when ((if_ir(6 downto 5) = "00" and immediat = '0') or b_i = '1') else '0';
        dec2exe_shift_lsr <= '1' when if_ir(6 downto 5) = "01" and immediat = '0' else '0';
        dec2exe_shift_asr <= '1' when if_ir(6 downto 5) = "10" and immediat = '0' else '0';
        
        dec2exe_shift_ror <= '1' when (if_ir(6 downto 5) = "11" and immediat = '0' and if_ir(11 downto 7) /= "00000") or 
                                      (immediat = '1' and if_ir(11 downto 8) /= "0000") else '0';

        dec2exe_shift_rrx <= '1' when (if_ir(6 downto 5) = "11" and immediat = '0' and if_ir(11 downto 7) = "00000") else '0';

        dec2exe_shift_val <= r_data3(4 downto 0) when immediat = '0' and if_ir(4) = '1' and (regop_t = '1' or trans_t = '1')else 
                             if_ir(11 downto 8) & '0' when dec2exe_shift_ror = '1' else
                             "00010" when b_i = '1' else if_ir(11 downto 7);

        -- invalidation des flags si besoin de les positionner / ecrire
        i_czn <= if_ir(20) and regop_t; 

		pc_pp <= dec2if_push;
    dec_pop <= if2dec_pop;
------------------------------------------------------------------------------------
-- MACHINE A ETATS 
        process(ck)
        begin
          if rising_edge(ck) then
            if reset_n = '0' then
              cur_state <= fetch;
            end if;
            
            cur_state <= next_state;
          end if;
        end process;

        process(cur_state, dec2if_full, cond, condv, opv, dec2exe_full, if2dec_empty, r_pcv, bl_i,
		branch_t, and_i, eor_i, sub_i, rsb_i, add_i, adc_i, sbc_i, rsc_i, orr_i, mov_i, bic_i,
		mvn_i, ldr_i, ldrb_i, ldm_i, stm_i, if_ir)
        begin
          case cur_state is
            -- FETCH
            when fetch =>
              debug <= "0000";
              if2dec_pop <= '0';
              dec2exe_push <= '0';
              
              if r_pcv = '1' and dec2if_full = '0' then -- T2 : premiere valeur de pc ecrite dans dec2if
                next_state <= run;
                dec2if_push <= '1';
                
              else                                       -- T1
                next_state <= fetch;

                dec2if_push <= '0';
              end if;

            -- RUN
            when run =>

			debug <= "0001";
            -- Instruction non executable (faussée ou instruction precedente non exec, ou flags invalides, ou operandes invalides)
              if if2dec_empty = '1' or dec2exe_full = '1' or condv = '0' or opv = '0' then -- T1  
                next_state <= run;
                if2dec_pop <= '0';
                dec2exe_push <= '0';
                
                if dec2if_full = '0' then
                  dec2if_push <= '1';
                else
                  dec2if_push <= '0';
                end if;
            
            -- Predicat faux 
              elsif cond = '0' then -- T2 : predicat est faux => jeter l'instrution 
                next_state <= run;
                
                dec2exe_push <= '0';
                if2dec_pop <= '1';
                if dec2if_full = '0' then
                  dec2if_push <= '1';
                else
                  dec2if_push <= '0';
                end if;

            -- Predicat vrai : execution
              elsif cond = '1' then -- T3 : predicat est vrai => executer l'instruction  
              -- Branch & link           
                if branch_t = '1' and bl_i = '1' then -- T4 
                  next_state <= link;
                
                  dec2exe_push <= '1';
                  if2dec_pop <= '1';
                  
                  if dec2if_full = '0' then
                    dec2if_push <= '1';
                  else
                    dec2if_push <= '0';
                  end if;
              -- Branch
                elsif branch_t = '1' then -- T5
                  next_state <= branch;
                  dec2exe_push <= '1';
                  if2dec_pop <= '1';
                  dec2if_push <= '0';
                
                elsif mtrans_t = '1' then -- T6
                  next_state <= mtrans;
                  -- sortie                                          
                else                      -- T3
                  next_state <= run;
                
                  dec2exe_push <= '1';
                  if2dec_pop <= '1';
                  
                  if dec2if_full = '0' then
                    dec2if_push <= '1';
                  else
                    dec2if_push <= '0';
                  end if;
                  
                end if;
              end if;

            -- LINK
            when link =>
              debug <= "0010";
              next_state <= branch;
                              
              dec2exe_push <= '1';
              if2dec_pop <= '1';
              dec2if_push <= '0';
                  
            -- BRANCH
            when branch =>
              debug <= "0011";
              dec2exe_push <= '0';

              if if2dec_empty = '1' then   -- T1
                next_state <= branch;
              
                if2dec_pop <= '0';
                dec2if_push <= '0';
                
              elsif r_pcv = '1' then       -- T2
                next_state <= run;
                
                if2dec_pop <= '1';
                dec2if_push <= '1';

              else 
                next_state <= fetch;
                if2dec_pop <= '1';
                dec2if_push <= '0';
              end if;
            
            --MTRANS
            when mtrans => -- not implemented return to run state
			            debug <= "0100";
                  next_state <= run;
          end case;         
        end process;
end Behavior;
