library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity Hardware_Loop_Counts is
	generic 
	(
		DATA_WIDTH  : integer := 32
	);
	port 
	(
		pad_h				: in std_logic_vector(DATA_WIDTH-1 downto 0);
		pad_w				: in std_logic_vector(DATA_WIDTH-1 downto 0);
		kernel_h			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		kernel_w			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		stride_h			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		stride_w			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		channels			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		width_in			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		height_in		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		width_col    	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		height_col    	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		channels_col	: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end Hardware_Loop_Counts;

architecture structural of Hardware_Loop_Counts is

signal width_col_result    : std_logic_vector(DATA_WIDTH-1 downto 0);
signal height_col_result   : std_logic_vector(DATA_WIDTH-1 downto 0);
signal channels_Col_result : std_logic_vector(2*DATA_WIDTH-1 downto 0);

signal Height_Pad_Kernel_Stride : std_logic_vector(DATA_WIDTH-1 downto 0);
signal Widht_Pad_Kernel_Stride  : std_logic_vector(DATA_WIDTH-1 downto 0);

signal Height_Pad_Kernel : std_logic_vector(DATA_WIDTH-1 downto 0);
signal Widht_Pad_Kernel  : std_logic_vector(DATA_WIDTH-1 downto 0);

signal TwoTimes_pad_h : std_logic_vector(DATA_WIDTH-1 downto 0);
signal TwoTimes_pad_w : std_logic_vector(DATA_WIDTH-1 downto 0);
signal kernelProduct  : std_logic_vector(2*DATA_WIDTH-1 downto 0);

signal Widht_TwoTimes_pad_h  : std_logic_vector(DATA_WIDTH-1 downto 0);
signal Height_TwoTimes_pad_h : std_logic_vector(DATA_WIDTH-1 downto 0);

constant ONE  		 : STD_LOGIC := '1';
constant ZERO 		 : STD_LOGIC := '0';
constant ONE_DWORD : unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(1, DATA_WIDTH);

-- Component declarations
component Altera_LPM_AddSub_Signed_32B
	PORT
	(
		add_sub	: IN STD_LOGIC;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component Altera_LPM_Mult_Signed_2_32B
	PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component Altera_LPM_Mult_Signed_32B
	PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result	: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
	);
end component;

component Altera_LPM_Div_Signed_32B
	PORT
	(
		denom		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		quotient	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		remain	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

begin

	-- kernelProduct = kernel_h * kernel_w
	MultiA: Altera_LPM_Mult_Signed_32B
	PORT MAP
	(
		dataa  => kernel_h,
		datab  => kernel_w,
		result => kernelProduct
	);
	
	-- channels_Col_result = channels * kernelProduct
	MultiB: Altera_LPM_Mult_Signed_32B
	PORT MAP
	(
		dataa  => channels,
		datab  => kernelProduct(DATA_WIDTH-1 downto 0),
		result => channels_Col_result
	);
	
	-- TwoTimes_pad_h = 2 * pad_h
	MultiBy2_A: Altera_LPM_Mult_Signed_2_32B
	PORT MAP
	(
		dataa  => pad_h,
		result => TwoTimes_pad_h
	);
	
	-- TwoTimes_pad_w = 2 * pad_w
	MultiBy2_B: Altera_LPM_Mult_Signed_2_32B
	PORT MAP
	(
		dataa  => pad_w,
		result => TwoTimes_pad_w
	);
	
	-- Height_TwoTimes_pad_h = height + 2 * pad_h
	fullAdderA: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ONE,	-- Adder
		dataa	  => height_in,
		datab	  => TwoTimes_pad_h,
		result  => Height_TwoTimes_pad_h
	);
	
	-- Widht_TwoTimes_pad_h = width + 2 * pad_w
	fullAdderB: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ONE,	-- Adder
		dataa	  => width_in,
		datab	  => TwoTimes_pad_w,
		result  => Widht_TwoTimes_pad_h
	);
	
	-- Height_Pad_Kernel = width + 2 * pad_w - kernel_h
	fullAdderC: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ZERO,	-- Subtractor
		dataa	  => Height_TwoTimes_pad_h,
		datab	  => kernel_h,
		result  => Height_Pad_Kernel
	);
	
	-- Widht_Pad_Kernel = width + 2 * pad_w - kernel_w
	fullAdderD: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ZERO,	-- Subtractor
		dataa	  => Widht_TwoTimes_pad_h,
		datab	  => kernel_w,
		result  => Widht_Pad_Kernel
	);
	
	-- Height_Pad_Kernel_Stride = (height + 2 * pad_h - kernel_h) / stride_h
	DivA : Altera_LPM_Div_Signed_32B 
	PORT MAP 
	(
		denom	 	=> stride_h,
		numer	 	=> Height_Pad_Kernel,
		quotient	=> Height_Pad_Kernel_Stride,
		remain	=> OPEN
	);
	
	-- Widht_Pad_Kernel_Stride = (width + 2 * pad_w - kernel_w) / stride_w
	DivB : Altera_LPM_Div_Signed_32B 
	PORT MAP 
	(
		denom	 	=> stride_w,
		numer	 	=> Widht_Pad_Kernel,
		quotient	=> Widht_Pad_Kernel_Stride,
		remain	=> OPEN
	);
	
	-- height_col_result = [(width + 2 * pad_w - kernel_w) / stride_w] + 1
	fullAdderE: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ONE,	-- Adder
		dataa	  => Height_Pad_Kernel_Stride,
		datab	  => std_logic_vector(ONE_DWORD),
		result  => height_col_result
	);
	
	-- width_col_result = [(width + 2 * pad_w - kernel_w) / stride_w] + 1
	fullAdderF: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ONE,	-- Adder
		dataa	  => Widht_Pad_Kernel_Stride,
		datab	  => std_logic_vector(ONE_DWORD),
		result  => width_col_result
	);
	
	width_col  <= width_col_result;
	height_col <= height_col_result;
	channels_col <= channels_Col_result(DATA_WIDTH-1 downto 0);

end structural;
