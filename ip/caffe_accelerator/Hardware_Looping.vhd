library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity Hardware_Looping is
	generic 
	(
		DATA_WIDTH  : integer := 32
	);
	port 
	(
		clk            	: in std_logic;
		reset          	: in std_logic;
		master_En_Flag		: in std_logic;
		channelsCol_count : in std_logic_vector(DATA_WIDTH-1 downto 0);
		heightCol_count   : in std_logic_vector(DATA_WIDTH-1 downto 0);
		widthCol_count    : in std_logic_vector(DATA_WIDTH-1 downto 0);
		channelsCol_index	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		heightCol_index 	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		widthCol_index  	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		loops_end      	: out std_logic;
		loops_over			: out std_logic
	);
end Hardware_Looping;

architecture structural of Hardware_Looping is

constant ZERO : STD_LOGIC := '0';
constant ONE  : STD_LOGIC := '1';

SIGNAL En_Counter_Height, En_Counter_Channel : std_logic;
SIGNAL width_counter, height_counter, channels_counter : unsigned(DATA_WIDTH-1 downto 0);

begin
	Width_Loop:
	PROCESS (clk, reset)
   BEGIN
		IF (reset = ONE) THEN
			width_counter <= (others => '0');
      ELSIF ( rising_edge(clk) ) THEN
         IF (master_En_Flag = ONE) THEN
				IF ( width_counter = (unsigned(widthCol_count) - 1) ) then
					width_counter <= (others => '0');
				ELSE
					width_counter <= width_counter + 1;
				END IF;
         END IF;
      END IF;
   END PROCESS;
	
	widthCol_index <= std_logic_vector(width_counter);
	En_Counter_Height <= ONE when 
								( width_counter =  (unsigned(widthCol_count) - 1) ) else ZERO;
								
	height_Loop:
	PROCESS (clk, reset)
   BEGIN
		IF (reset = ONE) THEN
			height_counter <= (others => '0');
      ELSIF ( rising_edge(clk) ) THEN
         IF ( (master_En_Flag = ONE) AND (En_Counter_Height = ONE) ) THEN
				IF ( height_counter = (unsigned(heightCol_count) - 1) ) then
					height_counter <= (others => '0');
				ELSE
					height_counter <= height_counter + 1;
				END IF;
         END IF;
      END IF;
   END PROCESS;
	
	heightCol_index <= std_logic_vector(height_counter);
	En_Counter_Channel <= ONE when ( (En_Counter_Height = ONE) AND
											   ( height_counter = (unsigned(heightCol_count) - 1) ) ) else ZERO;

	channel_Loop:
	PROCESS (clk, reset)
   BEGIN
		IF (reset = ONE) THEN
			channels_counter <= (others => '0');
      ELSIF ( rising_edge(clk) ) THEN
         IF ( (master_En_Flag = ONE) AND (En_Counter_Channel = ONE) ) THEN
				IF ( channels_counter = (unsigned(channelsCol_count) - 1) ) then
					channels_counter <= (others => '0');
				ELSE
					channels_counter <= channels_counter + 1;
				END IF;
         END IF;
      END IF;
   END PROCESS;
	
	channelsCol_index <= std_logic_vector(channels_counter);
	
	loops_end <= ONE when ( (En_Counter_Height = ONE) AND (En_Counter_Channel = ONE) AND
									( channels_counter = (unsigned(channelsCol_count) - 1) ) ) else ZERO;
	
	loops_over <= ONE when ( (width_counter = 0) 	AND 
									 (height_counter = 0)	AND 
									 (channels_counter = 0) ) else ZERO;
end structural;
