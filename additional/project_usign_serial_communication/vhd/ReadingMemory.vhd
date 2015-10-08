library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ReadingMemory is
	generic(
		headerPattern : STD_LOGIC_VECTOR (3 downto 0) := "1111";
		dataSZ   : integer := 8;
		memSZ    : integer := 2;
		countSZ  : integer := 3;
		headerSZ : integer := 4
	);
	Port(
		mem_data_bit_out  : OUT STD_LOGIC;
		MemIsRead_F       : OUT STD_LOGIC;
		data_Addrs_in     : in  STD_LOGIC_VECTOR(memSZ - 1 downto 0);
		StartReadingMem_S : in  STD_LOGIC;
		rst               : in  STD_LOGIC;
		clk               : in  STD_LOGIC
	);
end ReadingMemory;
architecture Behavioral of ReadingMemory is
	constant outputSZ   : integer := dataSZ + headerSZ;
	signal mem_data_out : STD_LOGIC_VECTOR(dataSZ + headerSZ - 1 downto 0);
begin
	DataMemory_inst : entity work.DataMemory
		generic map(
			headerPattern => headerPattern,
			dataSZ   => dataSZ,
			memSZ    => memSZ,
			headerSZ => headerSZ
		)
		port map(
			mem_data_out  => mem_data_out,
			data_Addrs_in => data_Addrs_in,
			rst           => rst,
			clk           => clk
		);

	OutBuffer_inst : entity work.OutBuffer
		generic map(
			outputSZ => outputSZ,
			countSZ  => countSZ)
		port map(
			DataIsSent_F   => MemIsRead_F,
			PMOD_out       => mem_data_bit_out,
			Data_To_Send   => mem_data_out,
			StartSending_S => StartReadingMem_S,
			clk            => clk,
			rst            => rst
		);

end Behavioral;
