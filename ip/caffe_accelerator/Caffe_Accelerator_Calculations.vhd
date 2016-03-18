library IEEE;
use IEEE.std_logic_1164.all;

entity Caffe_Accelerator_Calculations is
	generic 
	(
		DATA_WIDTH  : integer := 32
	);
	port 
	(
		pad_h					 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		pad_w					 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		kernel_h				 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		kernel_w				 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		stride_h				 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		stride_w				 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		width_in				 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		height_in			 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		width_col    		 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		height_col    		 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		channelsCol_index	 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		heightCol_index 	 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		widthCol_index  	 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		 
		data_im_base_addr	 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		data_col_base_addr : in std_logic_vector(DATA_WIDTH-1 downto 0);
		data_type_width	 : in std_logic_vector(DATA_WIDTH-1 downto 0);
		 
		storeDataIm			 : out std_logic;
		data_col_address 	 : out std_logic_vector(DATA_WIDTH-1 downto 0);
		data_im_address	 : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end Caffe_Accelerator_Calculations;

architecture structural of Caffe_Accelerator_Calculations is

-- Wires
signal h_im_GEZ, w_im_GEZ, height_G_h_im, width_G_w_im : std_logic;
signal data_col_offset_int, data_im_offset_int : std_logic_vector((2*DATA_WIDTH-1) downto 0);
signal c_col_Height, c_col_Height_iHeight_Width, c_im_Height : std_logic_vector((2*DATA_WIDTH-1) downto 0);
signal h_im_mult, w_im_mult, channelIndex_Height, c_im_Height_h_im_Width : std_logic_vector((2*DATA_WIDTH-1) downto 0);
signal h_im, c_im, w_im, h_offset, w_offset, data_col_int, c_im_Height_h_im : std_logic_vector(DATA_WIDTH-1 downto 0);
signal h_im_sub, w_im_sub, h_offset_Partial, c_col_Height_Height_index, data_im_int : std_logic_vector(DATA_WIDTH-1 downto 0);

-- Constants
constant ZERO : STD_LOGIC := '0';
constant ONE  : STD_LOGIC := '1';

-- Component declarations
component Altera_LPM_Div_Signed_32B
	PORT
	(
		denom		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		quotient	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		remain	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
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

component Altera_LPM_AddSub_Signed_32B
	PORT
	(
		add_sub	: IN STD_LOGIC;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component Altera_LPM_CMPGEZ_Signed_32B
	PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		ageb		: OUT STD_LOGIC 
	);
end component;

component Altera_LPM_CMPG_Signed_32B
	PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		agb		: OUT STD_LOGIC 
	);
end component;

begin
	--------------------- Outer Loop: channels_col ---------------------
	-- w_offset = c_col % kernel_w;
	-- h_offset_Partial = c_col / kernel_w
	DivA : Altera_LPM_Div_Signed_32B 
	PORT MAP 
	(
		denom	 	=> kernel_w,
		numer	 	=> channelsCol_index,
		quotient	=> h_offset_Partial,
		remain	=> w_offset
	);
	
	-- h_offset = (c_col / kernel_w) % kernel_h
	-- c_im = (c_col / kernel_w) / kernel_h
	DivB : Altera_LPM_Div_Signed_32B 
	PORT MAP 
	(
		denom	 	=> kernel_h,
		numer	 	=> h_offset_Partial,
		quotient	=> c_im,
		remain	=> h_offset
	);
	
	--------------------- Inner Loop: width_col ---------------------
	-- h_im_mult = heightCol_index * stride_h
	MultiA: Altera_LPM_Mult_Signed_32B
	PORT MAP
	(
		dataa  => heightCol_index,
		datab  => stride_h,
		result => h_im_mult
	);
	
	-- w_im_mult = widthCol_index * stride_w
	MultiB: Altera_LPM_Mult_Signed_32B
	PORT MAP
	(
		dataa  => widthCol_index,
		datab  => stride_w,
		result => w_im_mult
	);
	
	-- h_im_sub = h_offset - pad_h 
	fullAdderA: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ZERO,	-- Subtractor
		dataa	  => h_offset,
		datab	  => pad_h,
		result  => h_im_sub
	);
	
	-- w_im_sub = w_offset - pad_w
	fullAdderB: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ZERO,	-- Subtractor
		dataa	  => w_offset,
		datab	  => pad_w,
		result  => w_im_sub
	);
	
	-- h_im = (heightCol_index * stride_h) + (h_offset - pad_h)
	fullAdderC: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ONE,	-- Adder
		dataa	  => h_im_mult(DATA_WIDTH-1 downto 0),
		datab	  => h_im_sub,
		result  => h_im
	);
	
	-- w_im = (widthCol_index * stride_w) + (w_offset - pad_w)
	fullAdderD: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ONE,	-- Adder
		dataa	  => w_im_mult(DATA_WIDTH-1 downto 0),
		datab	  => w_im_sub,
		result  => w_im
	);
	
	-- h_im_GEZ = (h_im >= 0)
	cmpGEZ_A : Altera_LPM_CMPGEZ_Signed_32B 
	PORT MAP 
	(
		dataa	 => h_im,
		ageb	 => h_im_GEZ
	);
	
	-- w_im_GEZ = (w_im >= 0)
	cmpGEZ_B : Altera_LPM_CMPGEZ_Signed_32B 
	PORT MAP 
	(
		dataa	 => w_im,
		ageb	 => w_im_GEZ
	);
	
	-- height_G_h_im = (height_in > h_im)
	cmpG_A : Altera_LPM_CMPG_Signed_32B 
	PORT MAP 
	(
		dataa	 => height_in,
		datab	 => h_im,
		agb	 => height_G_h_im
	);
	
	-- width_G_w_im = (width_in > w_im)
	cmpG_B : Altera_LPM_CMPG_Signed_32B 
	PORT MAP 
	(
		dataa	 => width_in,
		datab	 => w_im,
		agb	 => width_G_w_im
	);
	
	storeDataIm <= h_im_GEZ AND w_im_GEZ AND height_G_h_im AND width_G_w_im;
	
	--------------------- Data_col Index calculations ---------------------
	-- c_col_Height = channelsCol_index * height_col
	MultiC: Altera_LPM_Mult_Signed_32B
	PORT MAP
	(
		dataa  => channelsCol_index,
		datab  => height_col,
		result => c_col_Height
	);
	
	-- c_col_Height_Height_index = (channelsCol_index * height_col) + heightCol_index
	fullAdderE: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ONE,	-- Adder
		dataa	  => c_col_Height(DATA_WIDTH-1 downto 0),
		datab	  => heightCol_index,
		result  => c_col_Height_Height_index
	);
	
	-- c_col_Height_iHeight_Width = ( (channelsCol_index * height_col) + heightCol_index ) * width_col
	MultiD: Altera_LPM_Mult_Signed_32B
	PORT MAP
	(
		dataa  => c_col_Height_Height_index,
		datab  => width_col,
		result => c_col_Height_iHeight_Width
	);
	
	-- data_col_int = ( ((channelsCol_index * height_col) + heightCol_index) * width_col ) + widthCol_index
	fullAdderF: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ONE,	-- Adder
		dataa	  => c_col_Height_iHeight_Width(DATA_WIDTH-1 downto 0),
		datab	  => widthCol_index,
		result  => data_col_int
	);
	
	data_col_offset_add: Altera_LPM_Mult_Signed_32B
	PORT MAP
	(
		dataa  => data_col_int,
		datab  => data_type_width,
		result => data_col_offset_int
	);
	
	data_col_address_add: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ONE,	-- Adder
		dataa	  => data_col_offset_int(DATA_WIDTH-1 downto 0),
		datab	  => data_col_base_addr,
		result  => data_col_address
	);
	
	--------------------- Data_im Index calculations ---------------------
	-- c_im_Height = c_im * height_in
	MultiE: Altera_LPM_Mult_Signed_32B
	PORT MAP
	(
		dataa  => c_im,
		datab  => height_in,
		result => c_im_Height
	);
	
	-- c_im_Height_h_im = (c_im * height_in) + h_im
	fullAdderG: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ONE,	-- Adder
		dataa	  => c_im_Height(DATA_WIDTH-1 downto 0),
		datab	  => h_im,
		result  => c_im_Height_h_im
	);
	
	-- c_im_Height_h_im_Width = ( (c_im * height_in) + h_im ) * width_in
	MultiF: Altera_LPM_Mult_Signed_32B
	PORT MAP
	(
		dataa  => c_im_Height_h_im,
		datab  => width_in,
		result => c_im_Height_h_im_Width
	);
	
	-- data_im_int = ( ( (c_im * height_in) + h_im ) * width_in ) + w_im
	fullAdderH: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ONE,	-- Adder
		dataa	  => c_im_Height_h_im_Width(DATA_WIDTH-1 downto 0),
		datab	  => w_im,
		result  => data_im_int
	);
	
	data_im_offset_add: Altera_LPM_Mult_Signed_32B
	PORT MAP
	(
		dataa  => data_im_int,
		datab  => data_type_width,
		result => data_im_offset_int
	);
	
	data_im_address_add: Altera_LPM_AddSub_Signed_32B
	PORT MAP
	(
		add_sub => ONE,	-- Adder
		dataa	  => data_im_offset_int(DATA_WIDTH-1 downto 0),
		datab	  => data_im_base_addr,
		result  => data_im_address
	);
	
end structural;
