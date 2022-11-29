library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

entity ALUControl is 
	port(
    	funct: in std_logic_vector(5 downto 0);
        Aluop: in std_logic_vector(2 downto 0);
        signalAlu: out std_logic_vector(3 downto 0)
    );
end ALUControl;

architecture logic_ALUControl of ALUControl is

begin
	
    LogicaAluControl: process (funct, Aluop)
    begin
    	case(Aluop) is
        	when "010" => --Tipo R
            	case funct is
                	when "100000" => signalAlu <= "0010"; --ADD
                    when "100010" => signalAlu <= "0011"; --SUB
                    when "100100" => signalAlu <= "0000"; --AND
                    when "100101" => signalAlu <= "0001"; --OR
                    when "101010" => signalAlu <= "0111"; --SLT
                    when "000000" => signalAlu <= "0110"; --SLL
                    when "000010" => signalAlu <= "1000"; --SRL
                    when "100110" => signalAlu <= "1001"; --XOR
                    when "100111" => signalAlu <= "1010"; --NOR
                    when others => signalAlu <= "0101";
                end case;
            when "000" => signalAlu <= "0010"; --LW/SW/Addi
            when "001" => signalAlu <= "0100"; --LUI
            when "011" => signalAlu <= "0000"; --ANDI
            when "100" => signalAlu <= "0001"; --ORI
            when "101" => signalAlu <= "1001"; --XORI
            when others => signalAlu <= "0101";
       	end case;
    end process;
                
end logic_ALUControl;