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
--		This code is "parallel in serial out" buffer, where it takes two inputs and outputs them bit-by-bit when:
--		"Go" input signal is set to '1' as a pulse (. . . , 0, 1, 0, . . .)
--		after pulsing the "Go" signal inputs registered/saved.
--		to interrupt the transmission, can only be done by setting "Reset_n" to '0' or pulsing the "Go" signal and giving new input data. 
--		during transmission of data, code sends out clock as well. 
--		so, receiver can use this clock to read the sent data, even though if receiver is on different clock domain.
--		if data is not being sent program is 'idle', clock output "OutC" and data output "OutD" are set to constant '1'
--		
-- Code Details:
--		after finishing sending each input, code sends out 'Z'(signal name: "zPause") high impedance signal, notifying that one input is sent.  
--		BEFORE sending first input AND AFTER sending second input (with it's "Z" signal), 
--		output "OutD" gets the value of '0' (signal name: "header")
--		everything is parameterizable: "header", "zPause", input size.
--
-- Solution Details:
--		to fulfill the requirement, two solutions are used. 
--		solution A: by using shift registers 	to select THE BIT by constructing the send-vector, shifting it, and pointing always to LM/RM bit.
--		solution B: by using counter, 			to select THE BIT by pointing to it with counter value
--		in VHDL solution of the task, 		I used solution A.
--		in Verilog solution of the task, 	I used solution B.
-- 
-- Tools used:
-- Coding:		Sigasi linux 64bit - Floating Licence (TTU)
-- Synthesis: 	Vivado Synthesis - Vivado 2015.2 linux 64bit - Floating Licence (TUT)
-- Simulation: 	Vivado Simulator - Vivado 2015.2 linux 64bit - Floating Licence (TUT)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arm_vhdl is
	generic(
		sizeA      : INTEGER := 7;      --size of first input 
		sizeD      : INTEGER := 8;      --size of second input 
		sizeHeader : INTEGER := 1;      --size of header, LeftMost and RightMost bits, in our case we send only : '0'
		sizeZPause : INTEGER := 1       --size of pause/delay after sending A and B. in our case we send only : 'Z'
	);
	port(
		OutD    : out STD_LOGIC;
		OutC    : out STD_LOGIC;
		A       : in  STD_LOGIC_VECTOR(sizeA - 1 downto 0);
		D       : in  STD_LOGIC_VECTOR(sizeD - 1 downto 0);
		Go      : in  STD_LOGIC;
		clk_in  : in  STD_LOGIC;
		reset_n : in  STD_LOGIC
	);
end entity arm_vhdl;

architecture RTL of arm_vhdl is
	constant outputSize : integer := sizeA + sizeD + 2 * sizeZPause + 2 * sizeHeader; --this is number that identifies how large is a vector that will be sended

	constant zPause       : STD_LOGIC_VECTOR(sizeZPause - 1 downto 0) := (others => 'Z'); --this is a High Impedance after sending input
	constant header       : STD_LOGIC_VECTOR(sizeHeader - 1 downto 0) := (others => '0'); --this part is inserted in most Left and Right sides of concatenated string
	constant sendingEnded : STD_LOGIC_VECTOR(outputSize - 1 downto 0) := (others => '1'); --when concatenated vector becomes all ones, that means sending has ended

	signal concatenatedInputs : STD_LOGIC_VECTOR(outputSize - 1 downto 0) := (others => '1');
	signal becomeIdle         : STD_LOGIC                                 := '0';
begin

	OutC <= '1' when becomeIdle = '1'	--when sending is finished
		else '1' when reset_n = '0'		--when reset is '0'
		else clk_in;					--send out clk_in in rest of the cases : when data is being sent. 

	serial_out_p: process(clk_in, reset_n, A, D, Go) is
	begin
		if reset_n = '0' then
			OutD               <= '1';
			becomeIdle         <= '1';
			concatenatedInputs <= (others => '1'); --we reset it on '1' because when sending is ended, output is '1'
		elsif Go = '1' then
			concatenatedInputs <= header & A & zPause & D & zPause & header; --this line concatenates inputs, pauses, and headers
		elsif rising_edge(clk_in) then
			OutD <= concatenatedInputs(outputSize - 1); --this output, that gets Left Most bit of the concatenated vector. that was required.
			concatenatedInputs <= concatenatedInputs(outputSize - 2 downto 0) & '1'; --this line shifts the concatenated vector to the left, so that current LM bit that was outputed on this clock cycle, will be lost and next bit will become LM
			
			if concatenatedInputs = sendingEnded then
				becomeIdle <= '1';      --this signal is '1' when sending finished or has not started, we use it for controlling "OutC" 
			else
				becomeIdle <= '0';
			end if;
		end if;
	end process serial_out_p;
	
end architecture RTL;
