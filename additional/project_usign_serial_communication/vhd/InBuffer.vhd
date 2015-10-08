--Max input size is 32 bits
--manual: http://prntscr.com/7112ao

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity InBuffer is
	generic(inputSZ : integer;
		    countSZ : integer
	);
	port(
		Received_Data    : out STD_LOGIC_VECTOR(inputSZ - 1 downto 0);
		DataIsReceived_F : out std_logic;
		StartReceiving_S : in  std_logic;
		PMOD_in          : in  std_logic;
		clk              : in  std_logic;
		rst              : in  std_logic
	);
end entity InBuffer;

architecture RTL of InBuffer is
	signal Temp_Received_Data : STD_LOGIC_VECTOR(inputSZ - 1 downto 0); --this register is not necesary we can write straightly in output, but..
	signal count              : STD_LOGIC_VECTOR(countSZ downto 0);
	
begin
	
--	delay_for_input : process (clk) is
--	begin
--		if rising_edge(clk) then
--			Temp1_StartReceiving_S <= StartReceiving_S;
--			Temp2_StartReceiving_S <= Temp1_StartReceiving_S;
--		end if;
--	end process delay_for_input;
	
	
	process(clk, rst)
	begin
		if rst = '1' then
			count              <= (others => '0');
			Temp_Received_Data <= (others => '0');
			DataIsReceived_F   <= '1';
		elsif rising_edge(clk) then
			if (StartReceiving_S = '1' or (not (unsigned(count) = 0))) then --to_integer(
				if (unsigned(count) = to_unsigned(inputSZ, 6)) then --to_integer(
					DataIsReceived_F <= '1';
					Received_Data    <= Temp_Received_Data;
					count            <= (others => '0');
				else
					DataIsReceived_F <= '0';
					Received_Data    <= (others => '0');
					Temp_Received_Data(to_integer(unsigned(count))) <= PMOD_in;
					count            <= STD_LOGIC_VECTOR(unsigned(count) + 1);
				end if;
			else
				DataIsReceived_F <= '1';
			end if;
		end if;
	end process;
end architecture RTL;
