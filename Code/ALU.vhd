library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

entity ALU is
	port(
    	a, b: in std_logic_vector(31 downto 0);
        control: in std_logic_vector(3 downto 0);
        shamt: in std_logic_vector(4 downto 0);
        result: out std_logic_vector(31 downto 0);
        zero: out std_logic
    );
end ALU;

architecture logic_ALU of ALU is
begin

  Operaciones: process(control,a,b) begin
        case control is
          when"0000" => result <= (a and b);
          when"0001" => result <= (a or b);
          when"0010" => result <= (a + b);
          when"0011" => result <= (a - b);
          when"0100" => result <= b(15 downto 0) & x"0000";
          when"0110" => result <= b sll to_integer(shamt); -- Corrimiento a izquierda
          when"1000" => result <= b srl to_integer(shamt); -- Corrimiento a derecha 
          when"1001" => result <= (a xor b);
          when"1010" => result <= (a nor b);
          when"0111" => if (a<b) then
                          result <= x"00000001";
                       else
                          result <= x"00000000";
                       end if;
          
          when others => result <= x"00000000";
        end case;
  end process;
  
  CalculoFuncionZero: process(result)
 	begin
    	if (result = x"00000000") then
        	zero <= '1';
        else
        	zero <= '0';
        end if;
    end process;
end logic_ALU; 