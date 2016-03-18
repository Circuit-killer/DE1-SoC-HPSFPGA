library IEEE;
use IEEE.std_logic_1164.all;

entity Register_With_Bytelanes is
	generic 
	(
		DATA_WIDTH  : integer := 32
	);
	port 
	(
		clk          : in std_logic;
		reset        : in std_logic;
		write_en     : in std_logic;
		data_in      : in std_logic_vector(DATA_WIDTH-1 downto 0);
		byte_enables : in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
		data_out 	 : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end Register_With_Bytelanes;

architecture structural of Register_With_Bytelanes is

constant ONE : STD_LOGIC := '1';

begin
	REGISTER_BYTE_ENABLE_GEN: 
	for lane in 0 to ( DATA_WIDTH/8 - 1 ) generate
		process (clk, reset)
		begin
			if (reset = ONE) then
				data_out( (lane*8)+7 downto (lane*8) ) <= (others => '0');
			elsif ( rising_edge(clk) ) then
				if ( ( byte_enables(lane) = ONE) AND (write_en = ONE)) then
					data_out( (lane*8)+7 downto (lane*8) ) <= data_in( (lane*8)+7 downto (lane*8) );
				end if;
			end if;
		end process;
	end generate REGISTER_BYTE_ENABLE_GEN;

end structural;

