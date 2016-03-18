library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HPSFPGA is
	port
	(
		---------FPGA Connections-------------
		CLOCK_50				: in std_logic;
		
		---------HPS Connections---------------
		HPS_CONV_USB_N		:	inout std_logic;
		HPS_DDR3_ADDR		:	out std_logic_vector(14 downto 0);
		HPS_DDR3_BA			: 	out std_logic_vector(2 downto 0);
		HPS_DDR3_CAS_N		: 	out std_logic;
		HPS_DDR3_CKE		:	out std_logic;
		HPS_DDR3_CK_N		: 	out std_logic;
		HPS_DDR3_CK_P		: 	out std_logic;
		HPS_DDR3_CS_N		: 	out std_logic;
		HPS_DDR3_DM			: 	out   std_logic_vector(4 downto 0);
		HPS_DDR3_DQ			: 	inout std_logic_vector(39 downto 0);
		HPS_DDR3_DQS_N		: 	inout std_logic_vector(4 downto 0);
		HPS_DDR3_DQS_P		: 	inout std_logic_vector(4 downto 0);
		HPS_DDR3_ODT		: 	out std_logic;
		HPS_DDR3_RAS_N		: 	out std_logic;
		HPS_DDR3_RESET_N	: 	out std_logic;
		HPS_DDR3_RZQ		: 	in  std_logic;
		HPS_DDR3_WE_N		: 	out std_logic;
		HPS_ENET_GTX_CLK	: 	out std_logic;
		HPS_ENET_inT_N		:	inout std_logic;
		HPS_ENET_MDC		:	out std_logic;
		HPS_ENET_MDIO		:	inout std_logic;
		HPS_ENET_RX_CLK	: 	in std_logic;
		HPS_ENET_RX_DATA	: 	in std_logic_vector(3 downto 0);
		HPS_ENET_RX_DV		: 	in std_logic;
		HPS_ENET_TX_DATA	:	out std_logic_vector(3 downto 0);
		HPS_ENET_TX_EN		: 	out std_logic;
		HPS_KEY				: 	inout std_logic;
		HPS_SD_CLK			: 	out std_logic;
		HPS_SD_CMD			: 	inout std_logic;
		HPS_SD_DATA			: 	inout std_logic_vector(3 downto 0);
		HPS_UART_RX			: 	in   std_logic;
		HPS_UART_TX			: 	out std_logic;
		HPS_USB_CLKout		: 	in std_logic;
		HPS_USB_DATA		:	inout std_logic_vector(7 downto 0);
		HPS_USB_DIR			: 	in std_logic;
		HPS_USB_NXT			: 	in std_logic;
		HPS_USB_STP			: 	out std_logic
	);
end HPSFPGA;

architecture Main of HPSFPGA is
component hps_fpga is
  port 
  (
		clk_clk                             : in    std_logic                     := 'X';             -- clk
		reset_reset_n                       : in    std_logic                     := 'X';             -- reset_n
		hps_arm_f2h_cold_reset_req_reset_n  : in    std_logic                     := 'X';             -- reset_n
		hps_arm_f2h_debug_reset_req_reset_n : in    std_logic                     := 'X';             -- reset_n
		hps_arm_f2h_warm_reset_req_reset_n  : in    std_logic                     := 'X';             -- reset_n
		hps_arm_h2f_reset_reset_n           : out   std_logic;                                        -- reset_n
		hps_io_hps_io_emac1_inst_TX_CLK   	: out   std_logic;                                        -- hps_io_emac1_inst_TX_CLK
		hps_io_hps_io_emac1_inst_TXD0     	: out   std_logic;                                        -- hps_io_emac1_inst_TXD0
		hps_io_hps_io_emac1_inst_TXD1     	: out   std_logic;                                        -- hps_io_emac1_inst_TXD1
		hps_io_hps_io_emac1_inst_TXD2     	: out   std_logic;                                        -- hps_io_emac1_inst_TXD2
		hps_io_hps_io_emac1_inst_TXD3     	: out   std_logic;                                        -- hps_io_emac1_inst_TXD3
		hps_io_hps_io_emac1_inst_RXD0     	: in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD0
		hps_io_hps_io_emac1_inst_MDIO     	: inout std_logic                     := 'X';             -- hps_io_emac1_inst_MDIO
		hps_io_hps_io_emac1_inst_MDC      	: out   std_logic;                                        -- hps_io_emac1_inst_MDC
		hps_io_hps_io_emac1_inst_RX_CTL   	: in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CTL
		hps_io_hps_io_emac1_inst_TX_CTL   	: out   std_logic;                                        -- hps_io_emac1_inst_TX_CTL
		hps_io_hps_io_emac1_inst_RX_CLK   	: in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CLK
		hps_io_hps_io_emac1_inst_RXD1     	: in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD1
		hps_io_hps_io_emac1_inst_RXD2     	: in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD2
		hps_io_hps_io_emac1_inst_RXD3     	: in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD3
		hps_io_hps_io_sdio_inst_CMD       	: inout std_logic                     := 'X';             -- hps_io_sdio_inst_CMD
		hps_io_hps_io_sdio_inst_D0        	: inout std_logic                     := 'X';             -- hps_io_sdio_inst_D0
		hps_io_hps_io_sdio_inst_D1        	: inout std_logic                     := 'X';             -- hps_io_sdio_inst_D1
		hps_io_hps_io_sdio_inst_CLK       	: out   std_logic;                                        -- hps_io_sdio_inst_CLK
		hps_io_hps_io_sdio_inst_D2        	: inout std_logic                     := 'X';             -- hps_io_sdio_inst_D2
		hps_io_hps_io_sdio_inst_D3        	: inout std_logic                     := 'X';             -- hps_io_sdio_inst_D3
		hps_io_hps_io_usb1_inst_D0        	: inout std_logic                     := 'X';             -- hps_io_usb1_inst_D0
		hps_io_hps_io_usb1_inst_D1        	: inout std_logic                     := 'X';             -- hps_io_usb1_inst_D1
		hps_io_hps_io_usb1_inst_D2        	: inout std_logic                     := 'X';             -- hps_io_usb1_inst_D2
		hps_io_hps_io_usb1_inst_D3        	: inout std_logic                     := 'X';             -- hps_io_usb1_inst_D3
		hps_io_hps_io_usb1_inst_D4        	: inout std_logic                     := 'X';             -- hps_io_usb1_inst_D4
		hps_io_hps_io_usb1_inst_D5        	: inout std_logic                     := 'X';             -- hps_io_usb1_inst_D5
		hps_io_hps_io_usb1_inst_D6        	: inout std_logic                     := 'X';             -- hps_io_usb1_inst_D6
		hps_io_hps_io_usb1_inst_D7        	: inout std_logic                     := 'X';             -- hps_io_usb1_inst_D7
		hps_io_hps_io_usb1_inst_CLK       	: in    std_logic                     := 'X';             -- hps_io_usb1_inst_CLK
		hps_io_hps_io_usb1_inst_STP       	: out   std_logic;                                        -- hps_io_usb1_inst_STP
		hps_io_hps_io_usb1_inst_DIR       	: in    std_logic                     := 'X';             -- hps_io_usb1_inst_DIR
		hps_io_hps_io_usb1_inst_NXT       	: in    std_logic                     := 'X';             -- hps_io_usb1_inst_NXT
		hps_io_hps_io_uart0_inst_RX       	: in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
		hps_io_hps_io_uart0_inst_TX       	: out   std_logic;                                        -- hps_io_uart0_inst_TX
		memory_mem_a                      	: out   std_logic_vector(14 downto 0);                    -- mem_a
		memory_mem_ba                     	: out   std_logic_vector(2 downto 0);                     -- mem_ba
		memory_mem_ck                     	: out   std_logic;                                        -- mem_ck
		memory_mem_ck_n                   	: out   std_logic;                                        -- mem_ck_n
		memory_mem_cke                    	: out   std_logic;                                        -- mem_cke
		memory_mem_cs_n                   	: out   std_logic;                                        -- mem_cs_n
		memory_mem_ras_n                  	: out   std_logic;                                        -- mem_ras_n
		memory_mem_cas_n                  	: out   std_logic;                                        -- mem_cas_n
		memory_mem_we_n                   	: out   std_logic;                                        -- mem_we_n
		memory_mem_reset_n                	: out   std_logic;                                        -- mem_reset_n
		memory_mem_dq                     	: inout std_logic_vector(39 downto 0) := (others => 'X'); -- mem_dq
		memory_mem_dqs                    	: inout std_logic_vector(4 downto 0)  := (others => 'X'); -- mem_dqs
		memory_mem_dqs_n                  	: inout std_logic_vector(4 downto 0)  := (others => 'X'); -- mem_dqs_n
		memory_mem_odt                    	: out   std_logic;                                        -- mem_odt
		memory_mem_dm                     	: out   std_logic_vector(4 downto 0);                     -- mem_dm
		memory_oct_rzqin                  	: in    std_logic                     := 'X';             -- oct_rzqin
		conduit_merger_end_awcache          : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- awcache
		conduit_merger_end_awprot           : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- awprot
		conduit_merger_end_awuser           : in    std_logic_vector(4 downto 0)  := (others => 'X'); -- awuser
		conduit_merger_end_arcache          : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- arcache
		conduit_merger_end_aruser           : in    std_logic_vector(4 downto 0)  := (others => 'X'); -- aruser
		conduit_merger_end_arprot           : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- arprot
		pio_sys_ext_connection_in_port      : in    std_logic_vector(31 downto 0) := (others => 'X'); -- in_port
      pio_sys_ext_connection_out_port     : out   std_logic_vector(31 downto 0)                     -- out_port
  );
end component hps_fpga;

component hps_reset is
	port 
	(
		probe		  : in  std_logic := '0';
		source_clk : in  std_logic;
		source 	  : out std_logic_vector(2 downto 0)
	);
end component hps_reset;

component altera_edge_detector is
	generic 
	(
		PULSE_EXT 				 : positive := 0;
		EDGE_TYPE 				 : positive := 0;
		IGNORE_RST_WHILE_BUSY : positive := 0
	);
	port 
	(
		clk		 : in  std_logic;
		rst_n 	 : in  std_logic;
		signal_in : in  std_logic;
		pulse_out : out std_logic
	);
end component altera_edge_detector;

constant AWCACHE_BASE : integer := 0;
constant AWCACHE_SIZE : integer := 4;
constant AWPROT_BASE  : integer := 4;
constant AWPROT_SIZE  : integer := 3;
constant AWUSER_BASE  : integer := 7;
constant AWUSER_SIZE  : integer := 5;
constant ARCACHE_BASE : integer := 16;
constant ARCACHE_SIZE : integer := 4;
constant ARPROT_BASE  : integer := 20;
constant ARPROT_SIZE  : integer := 3;
constant ARUSER_BASE  : integer := 23;
constant ARUSER_SIZE  : integer := 5;

signal HPS_COLD_RESET, HPS_COLD_RESET_N 	: std_logic;
signal HPS_WARM_RESET, HPS_WARM_RESET_N 	: std_logic;
signal HPS_DEBUG_RESET, HPS_DEBUG_RESET_N, HPS_H2F_RST : std_logic;

signal HPS_H2F_RST_REQ : std_logic_vector(2 downto 0);
signal pio_cont_axi_signals : std_logic_vector(31 downto 0);

begin
soc_system : component hps_fpga
	port map 
	(
		--  Global signals
		clk_clk                             => CLOCK_50,   		--                         clk.clk
		reset_reset_n                       => HPS_H2F_RST,      --                       reset.reset_n
		
		hps_arm_h2f_reset_reset_n       		=> HPS_H2F_RST,      --         				hps_0_h2f_reset.reset_n
		hps_arm_f2h_cold_reset_req_reset_n  => HPS_COLD_RESET_N, --  			hps_0_f2h_cold_reset_req.reset_n
		hps_arm_f2h_warm_reset_req_reset_n  => HPS_WARM_RESET_N, --  			hps_0_f2h_warm_reset_req.reset_n
		hps_arm_f2h_debug_reset_req_reset_n => HPS_DEBUG_RESET_N,-- 			hps_0_f2h_debug_reset_req.reset_n
		
		-- DDR3 SDRAM
		memory_mem_a                    => HPS_DDR3_ADDR,        --                  memory.mem_a
		memory_mem_ba                   => HPS_DDR3_BA,          --                        .mem_ba
		memory_mem_ck                   => HPS_DDR3_CK_P,        --                        .mem_ck
		memory_mem_ck_n                 => HPS_DDR3_CK_N,        --                        .mem_ck_n
		memory_mem_cke                  => HPS_DDR3_CKE,         --                        .mem_cke
		memory_mem_cs_n                 => HPS_DDR3_CS_N,        --                        .mem_cs_n
		memory_mem_ras_n                => HPS_DDR3_RAS_N,       --                        .mem_ras_n
		memory_mem_cas_n                => HPS_DDR3_CAS_N,       --                        .mem_cas_n
		memory_mem_we_n                 => HPS_DDR3_WE_N,        --                        .mem_we_n
		memory_mem_reset_n              => HPS_DDR3_RESET_N,     --                        .mem_reset_n
		memory_mem_dq                   => HPS_DDR3_DQ,          --                        .mem_dq
		memory_mem_dqs                  => HPS_DDR3_DQS_P,       --                        .mem_dqs
		memory_mem_dqs_n                => HPS_DDR3_DQS_N,       --                        .mem_dqs_n
		memory_mem_odt                  => HPS_DDR3_ODT,         --                        .mem_odt
		memory_mem_dm                   => HPS_DDR3_DM,          --                        .mem_dm
		memory_oct_rzqin                => HPS_DDR3_RZQ,         --                        .oct_rzqin
		
		-- Ethernet
		hps_io_hps_io_emac1_inst_TX_CLK => HPS_ENET_GTX_CLK, 		--                  hps_io.hps_io_emac1_inst_TX_CLK
		hps_io_hps_io_emac1_inst_TXD0   => HPS_ENET_TX_DATA(0),  --                        .hps_io_emac1_inst_TXD0
		hps_io_hps_io_emac1_inst_TXD1   => HPS_ENET_TX_DATA(1),  --                        .hps_io_emac1_inst_TXD1
		hps_io_hps_io_emac1_inst_TXD2   => HPS_ENET_TX_DATA(2),  --                        .hps_io_emac1_inst_TXD2
		hps_io_hps_io_emac1_inst_TXD3   => HPS_ENET_TX_DATA(3),  --                        .hps_io_emac1_inst_TXD3
		hps_io_hps_io_emac1_inst_RXD0   => HPS_ENET_RX_DATA(0),  --                        .hps_io_emac1_inst_RXD0
		hps_io_hps_io_emac1_inst_MDIO   => HPS_ENET_MDIO,   		--                        .hps_io_emac1_inst_MDIO
		hps_io_hps_io_emac1_inst_MDC    => HPS_ENET_MDC,    		--                        .hps_io_emac1_inst_MDC
		hps_io_hps_io_emac1_inst_RX_CTL => HPS_ENET_RX_DV,  		--                        .hps_io_emac1_inst_RX_CTL
		hps_io_hps_io_emac1_inst_TX_CTL => HPS_ENET_TX_EN,  		--                        .hps_io_emac1_inst_TX_CTL
		hps_io_hps_io_emac1_inst_RX_CLK => HPS_ENET_RX_CLK, 		--                        .hps_io_emac1_inst_RX_CLK
		hps_io_hps_io_emac1_inst_RXD1   => HPS_ENET_RX_DATA(1),  --                        .hps_io_emac1_inst_RXD1
		hps_io_hps_io_emac1_inst_RXD2   => HPS_ENET_RX_DATA(2),  --                        .hps_io_emac1_inst_RXD2
		hps_io_hps_io_emac1_inst_RXD3   => HPS_ENET_RX_DATA(3),  --                        .hps_io_emac1_inst_RXD3
		
		-- SD Card
		hps_io_hps_io_sdio_inst_CMD     => HPS_SD_CMD,     		--                        .hps_io_sdio_inst_CMD
		hps_io_hps_io_sdio_inst_D0      => HPS_SD_DATA(0),      	--                        .hps_io_sdio_inst_D0
		hps_io_hps_io_sdio_inst_D1      => HPS_SD_DATA(1),      	--                        .hps_io_sdio_inst_D1
		hps_io_hps_io_sdio_inst_CLK     => HPS_SD_CLK,     		--                        .hps_io_sdio_inst_CLK
		hps_io_hps_io_sdio_inst_D2      => HPS_SD_DATA(2),      	--                        .hps_io_sdio_inst_D2
		hps_io_hps_io_sdio_inst_D3      => HPS_SD_DATA(3),      	--                        .hps_io_sdio_inst_D3
		
		-- USB
		hps_io_hps_io_usb1_inst_D0      => HPS_USB_DATA(0),      --                        .hps_io_usb1_inst_D0
		hps_io_hps_io_usb1_inst_D1      => HPS_USB_DATA(1),      --                        .hps_io_usb1_inst_D1
		hps_io_hps_io_usb1_inst_D2      => HPS_USB_DATA(2),      --                        .hps_io_usb1_inst_D2
		hps_io_hps_io_usb1_inst_D3      => HPS_USB_DATA(3),      --                        .hps_io_usb1_inst_D3
		hps_io_hps_io_usb1_inst_D4      => HPS_USB_DATA(4),      --                        .hps_io_usb1_inst_D4
		hps_io_hps_io_usb1_inst_D5      => HPS_USB_DATA(5),      --                        .hps_io_usb1_inst_D5
		hps_io_hps_io_usb1_inst_D6      => HPS_USB_DATA(6),      --                        .hps_io_usb1_inst_D6
		hps_io_hps_io_usb1_inst_D7      => HPS_USB_DATA(7),      --                        .hps_io_usb1_inst_D7
		hps_io_hps_io_usb1_inst_CLK     => HPS_USB_CLKout,     	--                        .hps_io_usb1_inst_CLK
		hps_io_hps_io_usb1_inst_STP     => HPS_USB_STP,     		--                        .hps_io_usb1_inst_STP
		hps_io_hps_io_usb1_inst_DIR     => HPS_USB_DIR,     		--                        .hps_io_usb1_inst_DIR
		hps_io_hps_io_usb1_inst_NXT     => HPS_USB_NXT,     		--                        .hps_io_usb1_inst_NXT
		
		-- UART
		hps_io_hps_io_uart0_inst_RX     => HPS_UART_RX,     		--                        .hps_io_uart0_inst_RX
		hps_io_hps_io_uart0_inst_TX     => HPS_UART_TX,      		--                        .hps_io_uart0_inst_TX
		
		-- AXI attributes
		pio_sys_ext_connection_in_port  => pio_cont_axi_signals,	--	 pio_sys_ext_connection.in_port
      pio_sys_ext_connection_out_port => pio_cont_axi_signals,	-- 							  .out_port
		conduit_merger_end_awcache		  => pio_cont_axi_signals( (AWCACHE_BASE + AWCACHE_SIZE - 1) downto AWCACHE_BASE ), -- conduit_merger_end.awcache
		conduit_merger_end_awprot 		  => pio_cont_axi_signals( (AWPROT_BASE  + AWPROT_SIZE  - 1) downto AWPROT_BASE ),  --                   .awprot
		conduit_merger_end_awuser 		  => pio_cont_axi_signals( (AWUSER_BASE  + AWUSER_SIZE  - 1) downto AWUSER_BASE ),  --                   .awuser
		conduit_merger_end_arcache		  => pio_cont_axi_signals( (ARCACHE_BASE + ARCACHE_SIZE - 1) downto ARCACHE_BASE ), --                   .arcache
		conduit_merger_end_arprot 		  => pio_cont_axi_signals( (ARPROT_BASE  + ARPROT_SIZE  - 1) downto ARPROT_BASE ),  --                   .arprot
		conduit_merger_end_aruser 		  => pio_cont_axi_signals( (ARUSER_BASE  + ARUSER_SIZE  - 1) downto ARUSER_BASE )   --                   .aruser
	);
	
hps_reset_inst : component hps_reset
	port map 
	(
		source_clk => CLOCK_50,
		source     => HPS_H2F_RST_REQ
	);

pulse_cold_reset : component altera_edge_detector
	generic map 
	(
		PULSE_EXT				 => 6,
		EDGE_TYPE				 => 1,
		IGNORE_RST_WHILE_BUSY => 1
	)
	port map 
	(
		clk			=> CLOCK_50,
		rst_n			=> HPS_H2F_RST,
		signal_in	=> HPS_H2F_RST_REQ(0),
		pulse_out	=> HPS_COLD_RESET
	);
	
HPS_COLD_RESET_N <= not(HPS_COLD_RESET);

pulse_warm_reset : component altera_edge_detector
	generic map 
	(
		PULSE_EXT				 => 2,
		EDGE_TYPE				 => 1,
		IGNORE_RST_WHILE_BUSY => 1
	)
	port map 
	(
		clk			=> CLOCK_50,
		rst_n			=> HPS_H2F_RST,
		signal_in	=> HPS_H2F_RST_REQ(1),
		pulse_out	=> HPS_WARM_RESET
	);
	
HPS_WARM_RESET_N <= not(HPS_WARM_RESET);

pulse_debug_reset : component altera_edge_detector
	generic map 
	(
		PULSE_EXT				 => 32,
		EDGE_TYPE				 => 1,
		IGNORE_RST_WHILE_BUSY => 1
	)
	port map 
	(
		clk			=> CLOCK_50,
		rst_n			=> HPS_H2F_RST,
		signal_in	=> HPS_H2F_RST_REQ(2),
		pulse_out	=> HPS_DEBUG_RESET
	);
	
HPS_DEBUG_RESET_N <= not(HPS_DEBUG_RESET);

end Main;
