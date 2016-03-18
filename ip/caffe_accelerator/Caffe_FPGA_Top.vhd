library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity Caffe_FPGA_Top is
	generic 
	(
		DATA_WIDTH  	 		: integer := 32;
		ADDRESS_WIDTH	 		: integer := 32;
		FIFO_DEPTH				: integer := 32;
		FIFO_DEPTH_LOG2		: integer := 5;
		CSR_ADDRESS_WIDTH		: integer := 4;
		DESC_ADDRESS_WIDTH	: integer := 4
		
	);
	port 
	(
		clk            		  	  	: in std_logic;
		reset          		  	  	: in std_logic;
		
		-- signals to connect to an Avalon-MM slave interface: Descriptor
		descriptor_write				: in std_logic;
		descriptor_writedata			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		descriptor_address			: in std_logic_vector(DESC_ADDRESS_WIDTH-1 downto 0);
		descriptor_byteenable		: in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
		descriptor_waitrequest		: out std_logic;
		
		-- signals to connect to an Avalon-MM slave interface: Control and Status Reg
		csr_read							: in std_logic;
		csr_write						: in std_logic;
		csr_writedata					: in std_logic_vector(DATA_WIDTH-1 downto 0);
		csr_byteenable					: in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
		csr_address						: in std_logic_vector(CSR_ADDRESS_WIDTH-1 downto 0);
		csr_irq							: out std_logic;
		csr_readdata					: out std_logic_vector(DATA_WIDTH-1 downto 0);
		
		-- signals to connect to an Avalon-MM master interface: Read master port
		master_read_waitrequest	  	: in std_logic;
		master_read_readdatavalid	: in std_logic;
		master_read_readdata			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		master_read_read				: out std_logic;
		master_read_byteenable		: out std_logic_vector(DATA_WIDTH/8-1 downto 0);
		master_read_address			: out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
		
		-- signals to connect to an Avalon-MM master interface: Write master port
		master_write_waitrequest	: in std_logic;
		master_write_write			: out std_logic;
		master_write_writedata		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		master_write_byteenable		: out std_logic_vector(DATA_WIDTH/8-1 downto 0);
		master_write_address			: out std_logic_vector(ADDRESS_WIDTH-1 downto 0)
	);
end Caffe_FPGA_Top;

architecture structural of Caffe_FPGA_Top is

-- Component declarations
component Altera_SCFIFO_32B
	PORT
	(
		aclr	: IN STD_LOGIC;
		sclr	: IN STD_LOGIC ;
		clock	: IN STD_LOGIC;
		rdreq	: IN STD_LOGIC;
		wrreq	: IN STD_LOGIC;
		data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		empty	: OUT STD_LOGIC;
		full	: OUT STD_LOGIC;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		usedw	: OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
	);
end component;

component Caffe_Main_Controller
	generic 
	(
		DATA_WIDTH  			: integer := 32;
		CSR_ADDRESS_WIDTH		: integer := 4;
		DESC_ADDRESS_WIDTH	: integer := 4
	);
	port 
	(
		clk            	: in std_logic;
		reset          	: in std_logic;
		csr_read				: in std_logic;
		csr_write			: in std_logic;
		csr_writedata		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		csr_byteenable		: in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
		csr_address			: in std_logic_vector(CSR_ADDRESS_WIDTH-1 downto 0);
		csr_irq				: out std_logic;
		csr_readdata		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		desc_write			: in std_logic;
		desc_writedata		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		desc_address		: in std_logic_vector(DESC_ADDRESS_WIDTH-1 downto 0);
		desc_byteenable	: in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
		desc_waitrequest	: out std_logic;
		write_task			: in std_logic;
		looping_enable		: in std_logic;
		software_reset		: out std_logic;
		inProgress_task	: out std_logic;
		data_im_address	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		data_col_address	: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end component;

constant ZERO : STD_LOGIC := '0';
constant ONE  : STD_LOGIC := '1';

signal data_col_address : std_logic_vector(DATA_WIDTH-1 downto 0);
signal fifo_data_used, reads_pending : std_logic_vector(FIFO_DEPTH_LOG2-1 downto 0);
signal too_many_pending_reads_d1, too_many_pending_reads : STD_LOGIC;
signal inProgress_task, fifo_data_empty, increment_address : STD_LOGIC;
signal fifo_global_read, flush_global, software_reset, master_write_write_int : STD_LOGIC;

begin
	main_controller : Caffe_Main_Controller
	GENERIC MAP 
	(
		DATA_WIDTH 			=> DATA_WIDTH,
		CSR_ADDRESS_WIDTH	=> CSR_ADDRESS_WIDTH,
		DESC_ADDRESS_WIDTH	=> DESC_ADDRESS_WIDTH
	)
	PORT MAP
	(
		clk			 		=> clk,
		reset					=> reset,
		csr_read				=> csr_read,
		csr_write			=> csr_write,
		csr_writedata		=> csr_writedata,
		csr_byteenable		=> csr_byteenable,
		csr_address			=> csr_address,
		csr_irq				=> csr_irq,
		csr_readdata		=> csr_readdata,
		desc_write			=> descriptor_write,
		desc_address		=> descriptor_address,
		desc_writedata		=> descriptor_writedata,
		desc_byteenable	=> descriptor_byteenable,
		desc_waitrequest	=> descriptor_waitrequest,
		write_task			=> master_write_write_int,
		looping_enable		=> increment_address,
		software_reset		=> software_reset,
		inProgress_task	=> inProgress_task,
		data_im_address	=> master_read_address,
		data_col_address	=> data_col_address
	);
	
	Read_Master_to_ST : Altera_SCFIFO_32B
	port map 
	(
		clock	 => clk,
		aclr	 => reset,
		sclr	 => flush_global,
		usedw	 => fifo_data_used,
		full	 => open,
		rdreq	 => fifo_global_read,
		wrreq	 => master_read_readdatavalid,
		empty	 => fifo_data_empty,
		data	 => master_read_readdata,
		q	 	 => master_write_writedata
	);
	
	data_col_addr_store : Altera_SCFIFO_32B
	port map 
	(
		clock	 => clk,
		aclr	 => reset,
		sclr	 => flush_global,
		usedw	 => open,
		full	 => open,
		rdreq	 => fifo_global_read,
		wrreq	 => increment_address,
		empty	 => open,
		data	 => data_col_address,
		q	 	 => master_write_address
	);
	
	process (clk, reset)
	begin
		if (reset = ONE) then
			too_many_pending_reads_d1 <= ZERO;
		elsif ( rising_edge(clk) ) then
			too_many_pending_reads_d1 <= too_many_pending_reads;
		end if;
	end process;
	
	process (clk, reset)
	begin
		if (reset = ONE) then
			reads_pending <= (others => '0');
		elsif ( rising_edge(clk) ) then
			if (increment_address = ONE) then
				if (master_read_readdatavalid = ZERO) then
					reads_pending <= std_logic_vector(unsigned(reads_pending) + 1);
				else
					reads_pending <= reads_pending;
				end if;
			else
				if (master_read_readdatavalid = ZERO) then
					reads_pending <= reads_pending;
				else
					reads_pending <= std_logic_vector(unsigned(reads_pending) - 1);
				end if;
			end if;
		end if;
	end process;
	
	process (clk, reset)
	begin
		if (reset = ONE) then
			flush_global <= ZERO;
		elsif ( rising_edge(clk) ) then
			if ( (software_reset = ONE) AND ( (fifo_global_read = ONE) OR (master_write_write_int = ZERO) ) ) then
				flush_global <= ONE;
			else
				flush_global <= ZERO;
			end if;
		end if;
	end process;
	
	master_read_byteenable <= (others => '1');
	
	too_many_pending_reads <= ONE 
							when ( ( unsigned(fifo_data_used) + unsigned(reads_pending) ) >=
								    (FIFO_DEPTH - 4) ) else ZERO;
	
	master_read_read <= ONE when ( (inProgress_task = ONE) AND
								   (too_many_pending_reads_d1 = ZERO) ) else ZERO;
	
	increment_address <= ONE when ( (inProgress_task = ONE) AND
									(too_many_pending_reads_d1 = ZERO)  AND
									(master_read_waitrequest = ZERO) ) else ZERO;
	
	master_write_write_int <= ONE when (fifo_data_empty = ZERO) else ZERO;
	
	master_write_byteenable <= (others => '1');
	
	master_write_write <= master_write_write_int;
	
	fifo_global_read <= ONE when ( (fifo_data_empty = ZERO) AND 
											 (master_write_waitrequest = ZERO) ) else ZERO;
end structural;
