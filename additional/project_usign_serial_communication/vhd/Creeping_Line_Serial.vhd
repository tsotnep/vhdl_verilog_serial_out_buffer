library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CreepingLineMasterSlaveFSM is
	generic(
		memSZ         : integer                      := 3;
		inputSZ       : integer                      := 8; --size of data that will be received after header
		dataSZ        : integer                      := 8; --size of data stored in memory, same size as inputSZ, 
		countSZ       : integer                      := 3;
		outputSZ      : integer                      := 12;
		headerSZ      : integer                      := 4;
		headerPattern : STD_LOGIC_VECTOR(3 downto 0) := "1111"
	);
	Port(
		an                   : out STD_LOGIC_VECTOR(3 downto 0);
		SevSeg               : out STD_LOGIC_VECTOR(7 downto 0);
		LEDS_Header          : out STD_LOGIC_VECTOR(headerSZ - 1 downto 0);
		led8th_btn_deb_out   : out STD_LOGIC;
		led7th_data_received : out STD_LOGIC;
		led6th_clks_out      : out STD_LOGIC;
		PMOD_out             : out STD_LOGIC;
		clk_wire_out         : out STD_LOGIC;
--		switchAddrs          : in  STD_LOGIC_VECTOR(1 downto 0);
		clk_wire_in          : in  STD_LOGIC;
		masterSwitch         : in  STD_LOGIC;
		PMOD_in              : in  STD_LOGIC;
		realCLK              : in  STD_LOGIC;
		btn_in               : in  STD_LOGIC;
		rst                  : in  STD_LOGIC
	);
end CreepingLineMasterSlaveFSM;

architecture RTL of CreepingLineMasterSlaveFSM is
	signal clk100, clk50, clk25, clk12, clkslow, clk10th, clk15th : STD_LOGIC;

	signal btn_deb                                  : STD_LOGIC;
	signal ss0, ss1, ss2, ss3                       : STD_LOGIC_VECTOR(7 downto 0);
	signal header_reg                               : std_logic_vector(headerSZ - 1 downto 0);
	constant header_accept                          : std_logic_vector(headerSZ - 1 downto 0) := (others => '1');
	signal clkheader, clkSevSeg, clkBuffer : STD_LOGIC;
	signal Received_Data                            : STD_LOGIC_VECTOR(inputSZ - 1 downto 0);
	signal DataIsReceived_F                         : std_logic;
	signal StartSending_S                           : std_logic;
	signal Data_To_Send                             : STD_LOGIC_VECTOR(outputSZ - 1 downto 0);
	signal PMODorMEM                                : STD_LOGIC;
	signal mem_data_bit_out                         : STD_LOGIC;
	signal MemIsRead_F                              : STD_LOGIC;
	signal StartReadingMem_S                        : STD_LOGIC;
	signal StartReceiving_S                         : std_logic;
	signal DataIsSent_F                             : std_logic;
	signal data_Addrs_in                            : STD_LOGIC_VECTOR(memSZ - 1 downto 0);
	signal MemAddrsBySwitch                         : STD_LOGIC_VECTOR(memSZ - 1 downto 0);
--	Constant addrs0                                 : STD_LOGIC_VECTOR(memSZ - 1 downto 0)    := "00";
--	Constant addrs1                                 : STD_LOGIC_VECTOR(memSZ - 1 downto 0)    := "01";
--	Constant addrs2                                 : STD_LOGIC_VECTOR(memSZ - 1 downto 0)    := "10";
--	Constant addrs3                                 : STD_LOGIC_VECTOR(memSZ - 1 downto 0)    := "11";
	signal letterCounter : STD_LOGIC_VECTOR(memSZ - 1 downto 0);
begin
	led6th_clks_out      <= clk50 and clk25 and clk12 and clkslow and clk10th and clk100 and clk_wire_in and realCLK;
	led7th_data_received <= DataisReceived_F;
	led8th_btn_deb_out   <= (not btn_deb) and MemIsRead_F;
	clk_wire_out         <= clk12;

	clkheader <= clkslow;
	clkSevSeg <= clk15th;
	clkBuffer <= clkslow;
--	clkdata   <= clkslow;
	MemAddrsBySwitch <= letterCounter;
--	addrsSwitch : process(switchAddrs)
--	begin
--		if switchAddrs = "01" then
--			MemAddrsBySwitch <= addrs1;
--		elsif switchAddrs = "10" then
--			MemAddrsBySwitch <= addrs2;
--		elsif switchAddrs = "11" then
--			MemAddrsBySwitch <= addrs3;
--		else
--			MemAddrsBySwitch <= addrs0;
--		end if;
--	end process;

	muxMasterSlave : process(PMOD_in, mem_data_bit_out, masterSwitch, MemAddrsBySwitch)
	begin
		if masterSwitch = '1' then
			PMODorMEM         <= mem_data_bit_out;
			data_Addrs_in     <= MemAddrsBySwitch;
			StartReadingMem_S <= '1';
		else
			data_Addrs_in     <= (others => '0');
			PMODorMEM         <= PMOD_in;
			StartReadingMem_S <= '0';
		end if;
	end process;

	check_header : process(clkheader, rst)
	begin
		if rst = '1' then
			header_reg <= (others => '0');
		elsif rising_edge(clkheader) then
			if DataisReceived_F = '1' or MemIsRead_F = '1' then
				header_reg(headerSZ - 1)          <= PMODorMEM;
				header_reg(headersz - 2 downto 0) <= header_reg(headersz - 1 downto 1);
			else
				header_reg <= (others => '0');
			end if;
		end if;
	end process;

	selectSign : process(header_reg)
	begin
		LEDS_Header <= header_reg;
		if header_reg(headersz - 1 downto 0) = header_accept then
			StartReceiving_S <= '1';
		else
			StartReceiving_S <= '0';
		end if;
	end process;
	data_proc : process(rst, DataIsReceived_F)
	begin
		if rst = '1' then
			ss3            <= (others => '0'); --"00010001"; --(others => '0'); --
			ss2            <= (others => '0'); --"00100010"; --(others => '0');
			ss1            <= (others => '0'); --"01000100"; --(others => '0');
			ss0            <= (others => '0'); --"10001000"; --(others => '0');
			Data_To_Send   <= (others => '0');
			letterCounter  <= (others => '0');
			StartSending_S <= '0';
		--		elsif rising_edge(clkdata) then
		elsif (rising_edge(DataisReceived_F)) then
			ss3                       <= Received_Data(7 downto 0);
			ss2                       <= ss3;
			ss1                       <= ss2;
			ss0                       <= ss1;
			Data_To_Send(11 downto 0) <= (ss1 & "1111"); --we send ss1, because when we send ss0, 1 letter is not visible on displays while sending
			StartSending_S            <= '1';
			letterCounter <= STD_LOGIC_VECTOR(UNSIGNED(letterCounter)+1);


		end if;

--		if DataIsSent_F = '1' then
--			Data_To_Send(11 downto 0) <= (others => '0'); --headerPattern
--			StartSending_S            <= '0';
--		end if;
	end process;

	----------------------------------------------------------------------------------------------
	----------------------------------------INSTANTIATIONS----------------------------------------
	----------------------------------------------------------------------------------------------
	ReadingMemory_inst : entity work.ReadingMemory
		generic map(
			headerPattern => headerPattern,
			dataSZ        => dataSZ,
			memSZ         => memSZ,
			countSZ       => countSZ,
			headerSZ      => headerSZ
		)
		port map(
			mem_data_bit_out  => mem_data_bit_out,
			MemIsRead_F       => MemIsRead_F,
			data_Addrs_in     => data_Addrs_in,
			StartReadingMem_S => StartReadingMem_S,
			rst               => rst,
			clk               => clkBuffer
		);
	InBuffer_inst : entity work.InBuffer
		generic map(
			inputSZ => inputSZ,
			countSZ => countSZ
		)
		port map(
			Received_Data    => Received_Data,
			DataIsReceived_F => DataIsReceived_F,
			StartReceiving_S => StartReceiving_S,
			PMOD_in          => PMODorMEM,
			clk              => clkBuffer,
			rst              => rst
		);
	OutBuffer_inst : entity work.OutBuffer
		generic map(
			outputSZ => outputSZ,
			countSZ  => countSZ
		)
		port map(
			DataIsSent_F   => DataIsSent_F,
			PMOD_out       => PMOD_out,
			Data_To_Send   => Data_To_Send,
			StartSending_S => StartSending_S,
			clk            => clkBuffer,
			rst            => rst
		);
	clkDebDiv_inst : entity work.clkDebDiv
		port map(
			clkslow => clkslow,
			clk15th => clk15th,
			clk10th => clk10th,
			clk12   => clk12,
			clk25   => clk25,
			clk50   => clk50,
			clk100  => clk100,
			btn_out => btn_deb,
			btn_in  => btn_in,
			realCLK => realCLK,
			rst     => rst
		);
	SevSeg_inst : entity work.SevenSegment
		port map(
			an     => an,
			SevSeg => SevSeg,
			ss0    => ss0,
			ss1    => ss1,
			ss2    => ss2,
			ss3    => ss3,
			rst    => rst,
			clk    => clkSevSeg
		);
end RTL;

