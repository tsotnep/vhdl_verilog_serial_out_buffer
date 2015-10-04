---------------- Copyright (c) Notice -----------------------------------------
--
-- The VHDL/Verilog code, the logic and concepts described OUT this file constitute
-- the intellectual property of the authors listed below, who is/are affiliated
-- to TUT (Tallinn University of Technology), School of ICT, Tallinn.
-- Any unauthorised use, copy or distribution is strictly prohibited.
-- Any authorised use, copy or distribution should carry this copyright notice
-- unaltered.
-- Authors: Tsotne Putkaradze, MSc student, Tallinn University of Technology, Tallinn, Estonia.
--			Balaji Venu, Sr. Engineer, ARM Research, Cambridge, UK.
-- Contact: tsotnep@gmail.com
-- Date: 4 October, 2015.
--
-- Code Description:
--		This code generates inputs for the entoty "arm_vhdl" which is has "parallel in serial out" behaviour
--		stimulation consists of two process: "clock_driver_p" for sending the clock, and "stimul_p" for generating inputs
--		This code also implements a checker, that verifies that the solution is correct, this consists of two parts:
--		first part is process "receiver_p", It acts as a serial receiver, and reconstructs the data from OutD.
--		second part is process called "asserting_p" which, via assert statement validates that 
--		INPUT Given to the program and bit-vector, reconstructed from output "OutD" of the program, are identical. 
--		
-- 
-- Tools used:
-- Coding:		Sigasi linux 64bit - Floating Licence (TTU)
-- Synthesis: 	Vivado Synthesis - Vivado 2015.2 linux 64bit - Floating Licence (TUT)
-- Simulation: 	Vivado Simulator - Vivado 2015.2 linux 64bit - Floating Licence (TUT)

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
	constant t     : time := 10 ns;
	
	--stimulation
	signal OutD    : STD_LOGIC;
	signal OutC    : STD_LOGIC;
	signal A       : STD_LOGIC_VECTOR(sizeA - 1 downto 0);
	signal D       : STD_LOGIC_VECTOR(sizeD - 1 downto 0);
	signal Go      : STD_LOGIC;
	signal clk_in  : STD_LOGIC;
	signal reset_n : STD_LOGIC;
	
	--checking output
	signal receivedA : STD_LOGIC_VECTOR(sizeA - 1 downto 0);
	signal receivedD : STD_LOGIC_VECTOR(sizeD - 1 downto 0);
	signal recTemp : STD_LOGIC_VECTOR(sizeD -1 downto 0); --this should have the biggest input size, in our case sizeD is bigger
	signal zA : STD_LOGIC := '0'; --zA is set to '1' when first 'z' signal is received, and that happens, when sendin "A" is done
	signal zD : STD_LOGIC := '0'; --zD is set to '1' when second 'z' signal is received, which means sending "D" is done.
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

	clock_driver_p : process
		constant period : time := 10 ns;
	begin
		clk_in <= '0';
		wait for period / 2;
		clk_in <= '1';
		wait for period / 2;
	end process clock_driver_p;

	stimul_p : process
	begin
		reset_n <= '0';	wait for t;	reset_n <= '1'; wait for 35 ns; --reset and wait for a while
	
		A  <= "1111111"; D  <= "11111111"; 	Go <= '1'; 	wait for t;  Go <= '0'; wait for t*(sizeA + sizeD + sizeHeader + sizeZPause + 5); --test 1
		
		A  <= "1110111"; D  <= "11100111"; 	Go <= '1'; 	wait for t;  Go <= '0'; wait for t*(sizeA + sizeD + sizeHeader + sizeZPause + 5); --test 2
		
		A  <= "0110100"; D  <= "10111001"; 	Go <= '1'; 	wait for t;  Go <= '0'; wait for t*(sizeA + sizeD + sizeHeader + sizeZPause + 5); --test 3
				
		wait;
	end process stimul_p;

	receiver_p : process (OutC, reset_n, Go)
	begin
		if reset_n = '0' or Go = '1' then
			recTemp <= (others => '0');
			receivedA <= (others => '0');
			receivedD <= (others => '0');
			zA <= '0';
			zD <= '0';
		elsif rising_edge(OutC) then
			if OutD /= 'Z' and zD = '0' then
				recTemp <= recTemp(recTemp'left - 1 downto 0) & OutD;
			else
				if zA = '0' then
					zA        <= '1';
					receivedA <= recTemp(recTemp'left - 1 downto 0);
				elsif zD = '0' then
					zD		  <= '1';
					receivedD <= recTemp;
					recTemp	  <= (others => '0');
				end if;
			end if;
		end if;
	end process receiver_p;

	asserting_p : process (A, D, receivedA, receivedD, zD, Go)
	begin
		if zD = '1' and Go = '0' then
			assert (A = receivedA) report "A is not equal to receivedA" severity note;
			assert (D = receivedD) report "D is not equal to receivedD" severity note;
		end if;
	end process asserting_p;
	
end architecture RTL;
