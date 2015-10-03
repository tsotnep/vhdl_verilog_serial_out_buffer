library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--bitNumber          <= STD_LOGIC_VECTOR(unsigned(0));
--bitNumber <= STD_LOGIC_VECTOR(unsigned(bitNumber) + 1);
--OutD      <= concatenatedInputs(integer(unsigned(bitNumber)));
--sizeCount   : INTEGER := 5

entity arm_vhdl is
	generic(
		sizeA       : INTEGER := 7;
		sizeD       : INTEGER := 8;
		sizeOfpause : INTEGER := 1
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
	constant zPause           : STD_LOGIC_VECTOR(sizeOfpause - 1 downto 0) := (others => 'Z');
	--	signal bitNumber          : STD_LOGIC_VECTOR(sizeCount - 1 downto 0);
	signal concatenatedInputs : STD_LOGIC_VECTOR(sizeA + sizeD + 2 * sizeOfpause + 1 downto 0); --it should be  ..size-1, but, +2 for '0's in the start & end 
begin
	process(clk_in, reset_n, A, D, Go) is
	begin
		if reset_n = '0' then
			OutD               <= '0';
			OutC               <= '0';
			concatenatedInputs <= (others => '1');
		elsif Go = '1' then
			concatenatedInputs <= '0' & A & zPause & D & zPause & '0';
		elsif rising_edge(clk_in) then
			OutD               <= concatenatedInputs(sizeA + sizeD + 2 * sizeOfpause + 1); --outputs Left Most bit
			concatenatedInputs <= concatenatedInputs(sizeA + sizeD + 2 * sizeOfpause downto 0) & '1';
			--shifts left, we add '1' on the right, instead of '0', because of specification from diagram

			if concatenatedInputs(sizeA + sizeD + 2 * sizeOfpause) = 'Z' then
				OutC <= '1';
			--			else
			--				clk_in;
			end if;

		end if;
	end process;
end architecture RTL;
