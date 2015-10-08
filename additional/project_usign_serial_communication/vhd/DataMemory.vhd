library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemory is
	generic(
		headerPattern : STD_LOGIC_VECTOR (3 downto 0);
		dataSZ   : integer;
		memSZ    : integer;
		headerSZ : integer
	);
	Port(
		mem_data_out  : OUT STD_LOGIC_VECTOR(dataSZ + headerSZ -1 downto 0);
		data_Addrs_in : in  STD_LOGIC_VECTOR(memSZ-1 downto 0);
		rst           : in  STD_LOGIC;
		clk           : in  STD_LOGIC
	);
end DataMemory;
architecture Behavioral of DataMemory is
	type Data_Mem_Array is array (0 to 2**memSZ -1) of STD_LOGIC_VECTOR(dataSZ-1 downto 0);
	constant my_DataMem : Data_Mem_Array := (
	--- 76543210
		"10001001", --H
		"11111001", --I
		"11111111", -- 
		"10100001", --d
		"11100011", --u
		"10100001", --d
		"10000110", --E
		"11111111"  -- 
	
	-- TSOT NEEE
--		"10000111",
--		"10010010",
--		"11000000",
--		"10000111",
--		"10101011",
--		"10000110",
--		"10000110",
--		"10000110"
	);
begin
	process(clk, rst)
	begin
		if rst = '1' then
			Mem_data_out <= (others => '0');
		elsif rising_edge(clk) then
			Mem_data_out <= my_DataMem(to_integer(unsigned(data_Addrs_in))) & headerPattern;
		end if;
	end process;
end Behavioral;
