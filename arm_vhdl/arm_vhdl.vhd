--	
	
	-- circuit looks like it's a serial communication module, where we are providing
	-- clock and data



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

	OutC <= '1' when becomeIdle = '1'
		else '1' when reset_n = '0'
		else clk_in;

	process(clk_in, reset_n, A, D, Go) is
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
	end process;
end architecture RTL;
