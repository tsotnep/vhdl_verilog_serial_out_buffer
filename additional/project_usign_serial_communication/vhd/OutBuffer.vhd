--Max input size is 32 bits
--note: data should be holded until its sent
--manual: mode 1: http://prntscr.com/71138i -- here, in top entity you should hold input "Data_To_Send" until its fully sent
--manual: mode 2: http://prntscr.com/711dm6 -- here, in top entity you should hold input "Data_To_Send" only for 1 clock cycle
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity OutBuffer is
	generic(outputSZ : integer;
		    countSZ  : integer
	);
	port(
		DataIsSent_F   : out std_logic;
		PMOD_out       : out std_logic;
		Data_To_Send   : in  STD_LOGIC_VECTOR(outputSZ - 1 downto 0);
		StartSending_S : in  std_logic;
		clk            : in  std_logic;
		rst            : in  std_logic
	);
end entity OutBuffer;

architecture RTL of OutBuffer is
	signal count : STD_LOGIC_VECTOR(countSZ downto 0);
	signal t1 : STD_LOGIC;
begin
	
	proc_for_delaying_count : process(clk)
	begin
		if rising_edge(clk) then
			t1 <= StartSending_S;
		end if;
	end process;
	
	
	process(clk, rst)
	begin
		if rst = '1' then
			count <= (others => '0');
		elsif rising_edge(clk) then
			if (t1 = '1' or (not (unsigned(count) = 0))) then --for mode 1, remove "Temp_" from Temp_StartSending_S to allow changing already queued data  in middway
				if (unsigned(count) = to_unsigned(outputSZ, countSZ + 1)) then
					count <= (others => '0');
				else
					count <= STD_LOGIC_VECTOR(unsigned(count) + 1);
				end if;
			end if;
		end if;
	end process;

	pmod_outing : process(Data_To_Send, count, StartSending_S)
	begin
		if (StartSending_S = '1' or (not (unsigned(count) = 0))) then
			if (unsigned(count) = to_unsigned(outputSZ, countSZ + 1)) then
				PMOD_out <= '0';
			else
				PMOD_out <= Data_To_Send(to_integer(unsigned(count))); --for mode 1, remove "Temp_" from Temp_Data_To_Send to allow changing already queued data in middway
			end if;
		else
			PMOD_out <= '0';
		end if;
	end process;

	flags : process(count, StartSending_S)
	begin
		if (StartSending_S = '1' or (not (unsigned(count) = 0))) then
			if (unsigned(count) = to_unsigned(outputSZ, countSZ + 1)) then
				DataIsSent_F <= '1';
			else
				DataIsSent_F <= '0';
			end if;
		else
			DataIsSent_F <= '1';
		end if;
	end process;

end architecture RTL;
