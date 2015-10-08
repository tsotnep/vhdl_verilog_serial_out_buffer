library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SevenSegment is
	port(
		an     : out STD_LOGIC_VECTOR(3 downto 0);
		SevSeg : out STD_LOGIC_VECTOR(7 downto 0);
		
		ss0    : in  STD_LOGIC_VECTOR(7 downto 0);
		ss1    : in  STD_LOGIC_VECTOR(7 downto 0);
		ss2    : in  STD_LOGIC_VECTOR(7 downto 0);
		ss3    : in  STD_LOGIC_VECTOR(7 downto 0);
		
		rst    : in  STD_LOGIC;
		clk    : in  STD_LOGIC
	);
end SevenSegment;

architecture Behavioral of SevenSegment is
	signal segsel : STD_LOGIC_VECTOR(1 downto 0) := "00";
begin
	process(clk, rst)
	begin
		if rst = '1' then
			an     <= (others => '1');
			SevSeg <= (others => '1');
			segsel <= (others => '0');
		elsif rising_edge(clk) then
			case segsel is
				when "00" =>
					segsel <= "01";
					an     <= "1110";
					SevSeg <= ss0;
				when "01" =>
					segsel <= "10";
					an     <= "1101";
					SevSeg <= ss1;
				when "10" =>
					segsel <= "11";
					an     <= "1011";
					SevSeg <= ss2;
				when "11" =>
					segsel <= "00";
					an     <= "0111";
					SevSeg <= ss3;
				when others =>
					segsel <= "00";
					an     <= "1111";
					SevSeg <= "11111111";
			end case;
		end if;
	end process;
end Behavioral;

