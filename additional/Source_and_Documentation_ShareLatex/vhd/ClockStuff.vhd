library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity clkDebDiv is
	Port(
		clkslow : out STD_LOGIC;
		clk15th : out STD_LOGIC; --clk 15th bit, for seven segment its perfect
		clk10th : out STD_LOGIC;
		clk12   : out STD_LOGIC;
		clk25   : out STD_LOGIC;
		clk50   : out STD_LOGIC;
		clk100  : out STD_LOGIC;
		btn_out : out STD_LOGIC;
		btn_in  : in  STD_LOGIC;
		realCLK : in  STD_LOGIC;
		rst     : in  STD_LOGIC
	);
end clkDebDiv;

architecture Behavioral of clkDebDiv is
	signal counter    : STD_LOGIC_VECTOR(22 downto 0) := (others => '0'); --on 100mhz 1 sec is - 28 bits: "0101111101011110000100000000" 
	signal oldLastBit : std_logic                     := '0';
	signal shiftReg   : STD_LOGIC_VECTOR(2 downto 0)  := "000";
begin
	clk100 <= counter(0);
	clk50  <= counter(1);
	clk25  <= counter(2);
	clk12  <= counter(3);
	clk10th<= counter(10);
	clk15th<= counter(15);
	clkslow<= counter(22);
	
	process(realCLK, rst)
	begin
		if rst = '1' then
			counter    <= (others => '0');
			shiftReg   <= (others => '0');
			btn_out    <= '0';
			oldLastBit <= '0';
		elsif rising_edge(realCLK) then
			counter    <= STD_LOGIC_VECTOR(unsigned(counter) + 1); --counter increment
			oldLastBit <= counter(20);
			if oldLastBit = '1' and counter(20) = '0' then
				shiftReg(0) <= btn_in;
				shiftReg(1) <= shiftReg(0);
				shiftReg(2) <= shiftReg(1);
			end if;

			if shiftReg = "111" then
				btn_out <= '1';
			else
				btn_out <= '0';
			end if;

		end if;
	end process;
end Behavioral;

