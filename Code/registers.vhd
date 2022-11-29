library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

entity registers is 
	port(
    	clk, reset, wr: in std_logic;
        reg1_rd, reg2_rd, reg_wr: in std_logic_vector(4 downto 0);
        data_wr: in std_logic_vector(31 downto 0);
        data1_rd, data2_rd: out std_logic_vector(31 downto 0)
    );
end registers;

architecture logic_registers of registers is

type t_REG is ARRAY(0 to 31) of std_logic_vector(31 downto 0);
signal reg : t_REG;

begin

	EscrituraDelBdR: process (reset, clk) 
		begin
     		if(reset = '1') then
         		reg <= (others => x"00000000");
     		elsif (falling_edge(clk)) then
         		if (wr = '1') then
          			reg(to_integer(reg_wr)) <= data_wr;
         		end if;
     		end if;
	end process;
    
    -- Lectura del Banco de Registro --
            
	data1_rd <= x"00000000" when(reg1_rd = "00000")
      						  	else reg(to_integer(reg1_rd)); 
      
	data2_rd <= x"00000000" when(reg2_rd = "00000" )
						  		else reg(to_integer(reg2_rd)); 
                               
end logic_registers;
