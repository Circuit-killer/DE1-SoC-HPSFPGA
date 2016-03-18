library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity Desc_Registers_Bank is
	generic 
	(
		DATA_WIDTH  		: integer := 32;
		DESC_ADDRESS_WIDTH: integer := 4
	);
	port 
	(
		clk            	: in std_logic;
		reset          	: in std_logic;
		desc_write		  	: in std_logic;
		desc_waitrequest : in std_logic;
		desc_writedata	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		desc_byteenable  : in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
		desc_address	  	: in std_logic_vector(DESC_ADDRESS_WIDTH-1 downto 0);
		GO_bit				: out std_logic;
		channels  			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		height_in 			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		width_in	 			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		kernel_h  			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		kernel_w	 			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		pad_h		 			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		pad_w		 			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		stride_h	 			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		stride_w	 			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		data_im	 			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		data_col	 			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		zero_addr			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		data_type_width	: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end Desc_Registers_Bank;

architecture structural of Desc_Registers_Bank is

COMPONENT Register_With_Bytelanes
	GENERIC ( DATA_WIDTH : INTEGER := 32 );
	PORT
	(
		clk			 :	 IN STD_LOGIC;
		reset			 :	 IN STD_LOGIC;
		write_en 	 :	 IN STD_LOGIC;
		data_in		 :	 IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		byte_enables :	 IN STD_LOGIC_VECTOR((DATA_WIDTH/8)-1 DOWNTO 0);
		data_out		 :	 OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0)
	);
END COMPONENT;

constant ZERO : STD_LOGIC := '0';
constant ONE  : STD_LOGIC := '1';

signal address_decode : std_logic_vector( (2**DESC_ADDRESS_WIDTH)-1 downto 0 );

begin
	Channels_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => reset,
		write_en		 => address_decode(0),
		data_in		 => desc_writedata,
		byte_enables => desc_byteenable,
		data_out		 => channels
	);
	
	Height_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => reset,
		write_en		 => address_decode(1),
		data_in		 => desc_writedata,
		byte_enables => desc_byteenable,
		data_out		 => height_in
	);
	
	Width_in_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => reset,
		write_en		 => address_decode(2),
		data_in		 => desc_writedata,
		byte_enables => desc_byteenable,
		data_out		 => width_in
	);
	
	Kernel_h_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => reset,
		write_en		 => address_decode(3),
		data_in		 => desc_writedata,
		byte_enables => desc_byteenable,
		data_out		 => kernel_h
	);
	
	Kernel_w_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => reset,
		write_en		 => address_decode(4),
		data_in		 => desc_writedata,
		byte_enables => desc_byteenable,
		data_out		 => kernel_w
	);
	
	Pad_h_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => reset,
		write_en		 => address_decode(5),
		data_in		 => desc_writedata,
		byte_enables => desc_byteenable,
		data_out		 => pad_h
	);
	
	Pad_w_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => reset,
		write_en		 => address_decode(6),
		data_in		 => desc_writedata,
		byte_enables => desc_byteenable,
		data_out		 => pad_w
	);
	
	Stride_h_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => reset,
		write_en		 => address_decode(7),
		data_in		 => desc_writedata,
		byte_enables => desc_byteenable,
		data_out		 => stride_h
	);
	
	Stride_w_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => reset,
		write_en		 => address_decode(8),
		data_in		 => desc_writedata,
		byte_enables => desc_byteenable,
		data_out		 => stride_w
	);
	
	Data_im_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => reset,
		write_en		 => address_decode(9),
		data_in		 => desc_writedata,
		byte_enables => desc_byteenable,
		data_out		 => data_im
	);
	
	Data_col_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => reset,
		write_en		 => address_decode(10),
		data_in		 => desc_writedata,
		byte_enables => desc_byteenable,
		data_out		 => data_col
	);
	
	Zero_addr_w_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => reset,
		write_en		 => address_decode(11),
		data_in		 => desc_writedata,
		byte_enables => desc_byteenable,
		data_out		 => zero_addr
	);
	
	Data_type_register : Register_With_Bytelanes
	GENERIC MAP ( DATA_WIDTH => DATA_WIDTH )
	PORT MAP
	(
		clk			 => clk,
		reset			 => reset,
		write_en		 => address_decode(12),
		data_in		 => desc_writedata,
		byte_enables => desc_byteenable,
		data_out		 => data_type_width
	);
	
	process (desc_write, desc_waitrequest, desc_address)
	begin
		if ( (desc_write = ONE) AND (desc_waitrequest = ZERO) ) then
			case to_integer(unsigned(desc_address)) is
				when 0 =>  address_decode <= X"0001";
				when 1 =>  address_decode <= X"0002";
				when 2 =>  address_decode <= X"0004";
				when 3 =>  address_decode <= X"0008";
				when 4 =>  address_decode <= X"0010";
				when 5 =>  address_decode <= X"0020";
				when 6 =>  address_decode <= X"0040";
				when 7 =>  address_decode <= X"0080";
				when 8 =>  address_decode <= X"0100";
				when 9 =>  address_decode <= X"0200";
				when 10 => address_decode <= X"0400";
				when 11 => address_decode <= X"0800";
				when 12 => address_decode <= X"1000";
				when 13 => address_decode <= X"2000";
				when 14 => address_decode <= X"4000";
				when 15 => address_decode <= X"8000";
				when others => address_decode <= (others => '0');
			end case;
		else
			address_decode <= (others => '0');
		end if;
	end process;
	
	GO_bit <= ONE when ( ( address_decode(15) = ONE ) AND
								( desc_writedata(DATA_WIDTH-1) = ONE ) AND
								( desc_byteenable( (DATA_WIDTH/8)-1 ) = ONE) ) else ZERO;
end structural;
