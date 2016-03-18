library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity Caffe_Main_Controller is
	generic 
	(
		DATA_WIDTH  		: integer := 32;
		CSR_ADDRESS_WIDTH	: integer := 4;
		DESC_ADDRESS_WIDTH	: integer := 4
	);
	port 
	(
		clk            		: in std_logic;
		reset          		: in std_logic;
		csr_read			: in std_logic;
		csr_write			: in std_logic;
		csr_writedata		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		csr_byteenable		: in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
		csr_address			: in std_logic_vector(CSR_ADDRESS_WIDTH-1 downto 0);
		csr_irq				: out std_logic;
		csr_readdata		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		desc_write		  	: in std_logic;
		desc_writedata	  	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		desc_address	  	: in std_logic_vector(DESC_ADDRESS_WIDTH-1 downto 0);
		desc_byteenable  	: in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
		desc_waitrequest	: out std_logic;
		write_task			: in std_logic;
		looping_enable		: in std_logic;
		software_reset		: out std_logic;
		inProgress_task		: out std_logic;
		data_im_address		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		data_col_address	: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end Caffe_Main_Controller;

architecture structural of Caffe_Main_Controller is

-- Component declarations
COMPONENT Desc_Registers_Bank
	generic 
	(
		DATA_WIDTH  		: integer := 32;
		DESC_ADDRESS_WIDTH	: integer := 4
	);
	port 
	(
		clk					: in std_logic;
		reset          		: in std_logic;
		desc_write			: in std_logic;
		desc_waitrequest	: in std_logic;
		desc_writedata		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		desc_byteenable		: in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
		desc_address		: in std_logic_vector(DESC_ADDRESS_WIDTH-1 downto 0);
		GO_bit				: out std_logic;
		channels  			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		height_in 			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		width_in	 		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		kernel_h			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		kernel_w	 		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		pad_h		 		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		pad_w		 		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		stride_h	 		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		stride_w	 		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		data_im	 		  	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		data_col	 		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		zero_addr		  	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		data_type_width  	: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
END COMPONENT;

COMPONENT Hardware_Loop_Counts
	generic ( DATA_WIDTH  	: integer := 32 );
	port 
	(
		pad_h			 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		pad_w			 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		kernel_h		 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		kernel_w		 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		stride_h		 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		stride_w		 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		channels		 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		width_in		 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		height_in	 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		width_col    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		height_col   : out std_logic_vector(DATA_WIDTH-1 downto 0);
		channels_col : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
END COMPONENT;

COMPONENT Caffe_Accelerator_Calculations
	GENERIC ( DATA_WIDTH : INTEGER := 32 );
	PORT
	(
		pad_h					 :	IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		pad_w					 :	IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		kernel_h				 :	IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		kernel_w				 :	IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		stride_h				 :	IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		stride_w				 :	IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		width_in				 :	IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		height_in			 :	IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		width_col			 :	IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		height_col			 :	IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		channelsCol_index	 :	IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		heightCol_index	 :	IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		widthCol_index		 :	IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		data_im_base_addr	 : IN std_logic_vector(DATA_WIDTH-1 downto 0);
		data_col_base_addr : IN std_logic_vector(DATA_WIDTH-1 downto 0);
		data_type_width	 : IN std_logic_vector(DATA_WIDTH-1 downto 0);
		storeDataIm			 : out std_logic;
		data_col_address 	 : out std_logic_vector(DATA_WIDTH-1 downto 0);
		data_im_address	 : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
END COMPONENT;

component Altera_LPM_MUX_32B
	PORT
	(
		data0x	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data1x	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		sel		: IN STD_LOGIC ;
		result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

COMPONENT Hardware_Looping
	GENERIC ( DATA_WIDTH : INTEGER := 32 );
	PORT
	(
		clk					: IN STD_LOGIC;
		reset					: IN STD_LOGIC;
		master_En_Flag		: IN STD_LOGIC;
		channelsCol_count	: IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		heightCol_count	: IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		widthCol_count		: IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		channelsCol_index	: OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		heightCol_index	: OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		widthCol_index		: OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		loops_end			: OUT STD_LOGIC;
		loops_over			: OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT Register_With_Bytelanes
	GENERIC ( DATA_WIDTH : INTEGER := 32 );
	PORT
	(
		clk			 :	 IN STD_LOGIC;
		reset			 :	 IN STD_LOGIC;
		write_en 	 :	 IN STD_LOGIC;
		data_in		 :	 IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		byte_enables :	 IN STD_LOGIC_VECTOR(DATA_WIDTH/8-1 DOWNTO 0);
		data_out		 :	 OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0)
	);
END COMPONENT;

constant ZERO : STD_LOGIC := '0';
constant ONE  : STD_LOGIC := '1';
constant STATUS_REGISTER_ADDRESS  : unsigned(CSR_ADDRESS_WIDTH-1 downto 0) := to_unsigned(0, CSR_ADDRESS_WIDTH);
constant CONTROL_REGISTER_ADDRESS : unsigned(CSR_ADDRESS_WIDTH-1 downto 0) := to_unsigned(1, CSR_ADDRESS_WIDTH);

type state_type is (IDLE, WORKING, LAST_READ, WAIT_WRITES, DONE);
signal state : state_type;

signal irq_int, storeDataIm, clear_irq, set_irq, loops_end : STD_LOGIC;
signal master_reset, sw_reset, clear_sw_reset, set_sw_reset : STD_LOGIC;
signal desc_waitrequest_int, process_done, loops_over : STD_LOGIC;
signal GO_bit, master_read_read_int, task_hwloopin_En, csr_write_En : STD_LOGIC;

signal data_col_addr, widthCol_count : std_logic_vector(DATA_WIDTH-1 downto 0);
signal channelsCol_count, heightCol_count : std_logic_vector(DATA_WIDTH-1 downto 0);
signal data_im_address_int, data_col_base_addr : std_logic_vector(DATA_WIDTH-1 downto 0);
signal height_in, width_in, kernel_h, kernel_w : std_logic_vector(DATA_WIDTH-1 downto 0);
signal channelsCol_index, channels, control_register : std_logic_vector(DATA_WIDTH-1 downto 0);
signal pad_h, pad_w, stride_h, stride_w, data_im_addr : std_logic_vector(DATA_WIDTH-1 downto 0);
signal heightCol_index, widthCol_index, data_type_width : std_logic_vector(DATA_WIDTH-1 downto 0);
signal readdata_d1, data_im_base_addr, data_im_zero_addr : std_logic_vector(DATA_WIDTH-1 downto 0);

begin	
	Descriptor_Regs_Bank : Desc_Registers_Bank
	generic map 
	(
		DATA_WIDTH => DATA_WIDTH, 
		DESC_ADDRESS_WIDTH => DESC_ADDRESS_WIDTH 
	)
	port map
	(
		clk					=> clk,
		reset				=> master_reset,
		desc_write 		  	=> desc_write,
		desc_writedata   	=> desc_writedata,
		desc_byteenable  	=> desc_byteenable,
		desc_address	 	=> desc_address,
		desc_waitrequest	=> desc_waitrequest_int,
		GO_bit			  	=> GO_bit,
		channels 		  	=> channels,
		height_in		  	=> height_in,
		width_in			=> width_in,
		kernel_h 		  	=> kernel_h,
		kernel_w			=> kernel_w,
		pad_h				=> pad_h,
		pad_w				=> pad_w,
		stride_h			=> stride_h,
		stride_w			=> stride_w,
		data_im			  	=> data_im_base_addr,
		data_col			=> data_col_base_addr,
		zero_addr		  	=> data_im_zero_addr,
		data_type_width  	=> data_type_width
	);
	
	hw_Loop_Counts : Hardware_Loop_Counts
	generic map ( DATA_WIDTH => DATA_WIDTH )
	port map
	(
		pad_h			=> pad_h,
		pad_w			=> pad_w,
		kernel_h		=> kernel_h,
		kernel_w		=> kernel_w,
		stride_h		=> stride_h,
		stride_w		=> stride_w,
		channels		=> channels,
		width_in		=> width_in,
		height_in	 	=> height_in,
		width_col    	=> widthCol_count,
		height_col   	=> heightCol_count,
		channels_col	=> channelsCol_count
	);
	
	caffe_Calculations : Caffe_Accelerator_Calculations
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		pad_h					 => pad_h,
		pad_w					 => pad_w,
		kernel_h				 => kernel_h,
		kernel_w				 => kernel_w,
		stride_h				 => stride_h,
		stride_w				 => stride_w,
		width_in				 => width_in,
		height_in			 => height_in,
		width_col			 => widthCol_count,
		height_col			 => heightCol_count,
		channelsCol_index	 => channelsCol_index,
		heightCol_index	 => heightCol_index,
		widthCol_index		 => widthCol_index,
		data_im_base_addr	 => data_im_base_addr,
		data_col_base_addr => data_col_base_addr,
		data_type_width	 => data_type_width,
		storeDataIm			 => storeDataIm,
		data_col_address 	 => data_col_address,
		data_im_address	 => data_im_address_int
	);
	
	data_im_addr_sel : Altera_LPM_MUX_32B 
	PORT MAP 
	(
		data0x => data_im_zero_addr,
		data1x => data_im_address_int,
		sel	 => storeDataIm,
		result => data_im_address
	);
	
	hw_Looping : Hardware_Looping
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk					=> clk,
		reset					=> master_reset,
		master_En_Flag		=> looping_enable,
		channelsCol_count	=> channelsCol_count,
		heightCol_count	=> heightCol_count,
		widthCol_count		=> widthCol_count,
		channelsCol_index	=> channelsCol_index,
		heightCol_index	=> heightCol_index,
		widthCol_index		=> widthCol_index,
		loops_end			=> loops_end,
		loops_over			=> loops_over
	);
	
	U_Control_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => master_reset,
		write_en		 => csr_write_En,
		data_in		 => csr_writedata,
		byte_enables => csr_byteenable,
		data_out		 => control_register
	);
	
	-- State machine to manage the loops
	process (clk, master_reset)
	begin
		if master_reset = ONE then
			state <= IDLE;
			process_done <= ZERO;
			task_hwloopin_En <= ZERO;
		elsif ( rising_edge(clk) ) then
			case state is
				when IDLE =>
					process_done <= ZERO;
					if (GO_bit = ONE) then
						state <= WORKING;
						task_hwloopin_En <= ONE;
					else
						state <= IDLE;
						task_hwloopin_En <= ZERO;
					end if;
				when WORKING =>
					process_done <= ZERO;
					task_hwloopin_En <= ONE;
					if (loops_end = ZERO) then
						state <= WORKING;
					else
						state <= LAST_READ;
					end if;
				when LAST_READ =>
					if (loops_over = ZERO) then
						state <= LAST_READ;
						process_done <= ZERO;
						task_hwloopin_En <= ONE;
					else
						state <= WAIT_WRITES;
						process_done <= ONE;
						task_hwloopin_En <= ZERO;
					end if;
				when WAIT_WRITES =>
					if (write_task = ONE) then
						state <= WAIT_WRITES;
						process_done <= ZERO;
						task_hwloopin_En <= ZERO;
					else
						state <= DONE;
						process_done <= ONE;
						task_hwloopin_En <= ZERO;
					end if;
				when DONE =>
					state <= IDLE;
					process_done <= ONE;
					task_hwloopin_En <= ZERO;
			end case;
			
		end if;
	end process;
	
	-- Process to set the readdata used by the CSR port
	process (clk, reset)
	begin
		if (reset = ONE) then
			readdata_d1 <= (others => '0');
		elsif ( rising_edge(clk) ) then
			if (csr_read = ONE) then
				case to_integer(unsigned(csr_address)) is
					when 0  =>
						readdata_d1 <= (others => '0');
						readdata_d1(9) <= irq_int;
						readdata_d1(0) <= task_hwloopin_En;
					when 1 => readdata_d1 <= control_register;
					when 2 => readdata_d1 <= channelsCol_index;
					when 3 => readdata_d1 <= heightCol_index;
					when 4 => readdata_d1 <= widthCol_index;
					when others => readdata_d1 <= (others => '0');
				end case;
			end if;
		end if;
	end process;
	
	-- Process to set or clear IRQ
	process (clk, master_reset)
	variable bcat : std_logic_vector(1 downto 0);
	begin
		if (master_reset = ONE) then
			irq_int <= ZERO;
		elsif ( rising_edge(clk) ) then
			bcat := clear_irq & set_irq;
			case bcat is
				when "00" => irq_int <= irq_int;
				when "01" => irq_int <= ONE;
				when "10" => irq_int <= ZERO;
				when "11" => irq_int <= ONE;
				when others => null;
			end case;
		end if;
	end process;
	
	-- Process to reset the state machine and the counters by software
	process (clk, reset)
	begin
		if (reset = ONE) then
			sw_reset <= ZERO;
		elsif ( rising_edge(clk) ) then
			if (set_sw_reset = ONE) then
				sw_reset <= ONE;
			elsif (clear_sw_reset = ONE) then
				sw_reset <= ZERO;
			end if;
		end if;
	end process;
	
	software_reset <= sw_reset;
	master_reset <= reset OR sw_reset;
	
	csr_irq <= irq_int;
	csr_readdata <= readdata_d1;
	inProgress_task <= task_hwloopin_En;
	desc_waitrequest <= desc_waitrequest_int;
	set_irq <= process_done AND control_register(0);
	desc_waitrequest_int <= ONE when (sw_reset = ONE) else ZERO;
	
	clear_irq <= ONE when ( ( csr_address = std_logic_vector(STATUS_REGISTER_ADDRESS) ) AND 
									  (csr_write = ONE) AND 
									  (csr_byteenable(1) = ONE) AND 
									  (csr_writedata(9) = ONE) ) else ZERO;
						 
	csr_write_En <= ONE when ((csr_write = ONE) AND 
									  ( csr_address = std_logic_vector(CONTROL_REGISTER_ADDRESS) )) else ZERO;
	
	clear_sw_reset <= ONE when (sw_reset = ONE) else ZERO;
	
	set_sw_reset <= ONE when ( (csr_write = ONE) AND  
										(csr_byteenable(0) = ONE) AND (csr_writedata(1) = ONE) AND
								      ( csr_address = std_logic_vector(CONTROL_REGISTER_ADDRESS) )) else ZERO;
	
end structural;
