library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_arm_vhdl is
	generic(
		sizeA : INTEGER := 7;
		sizeD : INTEGER := 8;
		sizeHeader : INTEGER := 1;
		sizeZPause : INTEGER := 1
	);
end entity tb_arm_vhdl;

architecture RTL of tb_arm_vhdl is
	--outputs
	signal OutD    : STD_LOGIC;
	signal OutC    : STD_LOGIC;
	
	--inputs
	signal A       : STD_LOGIC_VECTOR(sizeA - 1 downto 0);
	signal D       : STD_LOGIC_VECTOR(sizeD - 1 downto 0);
	signal Go      : STD_LOGIC;
	signal clk_in  : STD_LOGIC;
	signal reset_n : STD_LOGIC;
	constant t     : time := 10 ns;
begin
	arm_vhdl_inst : entity work.arm_vhdl
		port map(
			OutD    => OutD,
			OutC    => OutC,
			A       => A,
			D       => D,
			Go      => Go,
			clk_in  => clk_in,
			reset_n => reset_n
		);

	clock_driver : process
		constant period : time := 10 ns;
	begin
		clk_in <= '0';
		wait for period / 2;
		clk_in <= '1';
		wait for period / 2;
	end process clock_driver;

	stimul_p : process
	begin
		reset_n <= '0';	wait for t;	reset_n <= '1'; wait for 35 ns; --reset and wait for a while
	
		A  <= "1111111"; D  <= "11111111"; 	Go <= '1'; 	wait for t;  Go <= '0'; --test 1
		wait for t*(sizeA + sizeD + sizeHeader + sizeZPause + 5);
		
		A  <= "1110111"; D  <= "11100111"; 	Go <= '1'; 	wait for t;  Go <= '0'; --test 2
		wait for t*(sizeA + sizeD + sizeHeader + sizeZPause + 5);
		
		A  <= "0110100"; D  <= "10111001"; 	Go <= '1'; 	wait for t;  Go <= '0'; --test 3
		wait for t*(sizeA + sizeD + sizeHeader + sizeZPause + 5); 
		
		
		wait;
	end process stimul_p;

end architecture RTL;
