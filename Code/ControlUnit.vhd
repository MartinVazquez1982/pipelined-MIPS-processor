library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

entity ControlUnit is
	port(
    	opCode: in std_logic_vector(5 downto 0);
        ID_RegWrite: out std_logic;
        ID_MemToReg: out std_logic;
        ID_Branch: out std_logic;
        ID_MemRead: out std_logic;
        ID_MemWrite: out std_logic;
        ID_RegDst: out std_logic;
        ID_AluOp: out std_logic_vector(2 downto 0);
        ID_AluSrc: out std_logic;
        ID_Jump: out std_logic
    );
end ControlUnit;

architecture Logic_ControlUnit of ControlUnit is

begin
	 
     Control: process (opCode) begin
     	case opCode is
        	when "000000" => -- R Type
        		ID_RegWrite <= '1';
                ID_MemToReg <= '0';
                ID_Branch <= '0';
                ID_MemRead <= '0';
                ID_MemWrite <= '0';
                ID_RegDst <= '1';
                ID_AluOp <= "010";
                ID_AluSrc <= '0';
                ID_Jump <= '0';
            when "100011" => -- Load Type
        		ID_RegWrite <= '1';
                ID_MemToReg <= '1';
                ID_Branch <= '0';
                ID_MemRead <= '1';
                ID_MemWrite <= '0';
                ID_RegDst <= '0';
                ID_AluOp <= "000";
                ID_AluSrc <= '1';
                ID_Jump <= '0';
            when "101011" => -- Store Type
        		ID_RegWrite <= '0';
                ID_MemToReg <= '0'; -- Es indistinto
                ID_Branch <= '0';
                ID_MemRead <= '0';
                ID_MemWrite <= '1';
                ID_RegDst <= '0'; -- Es indistinto
                ID_AluOp <= "000";
                ID_AluSrc <= '1';
                ID_Jump <= '0';
            when "001111" => -- LUI Type
            	ID_RegWrite <= '1';
                ID_MemToReg <= '0';
                ID_Branch <= '0';
                ID_MemRead <= '0';
                ID_MemWrite <= '0';
                ID_RegDst <= '0';
                ID_AluOp <= "001";
                ID_AluSrc <= '1';
                ID_Jump <= '0';
            when "000100" => -- BEQ Type
            	ID_RegWrite <= '0';
                ID_MemToReg <= '0'; -- Es indistinto
                ID_Branch <= '1';
                ID_MemRead <= '0';
                ID_MemWrite <= '0';
                ID_RegDst <= '0'; -- Es indistinto
                ID_AluOp <= "111"; -- Es indistinto
                ID_AluSrc <= '0';
                ID_Jump <= '0';
            when "001000" => -- ADDI Type
            	ID_RegWrite <= '1';
                ID_MemToReg <= '0'; 
                ID_Branch <= '0';
                ID_MemRead <= '0';
                ID_MemWrite <= '0';
                ID_RegDst <= '0'; 
                ID_AluOp <= "000"; 
                ID_AluSrc <= '1';
                ID_Jump <= '0';
            when "001100" => --ANDI Type
            	ID_RegWrite <= '1';
                ID_MemToReg <= '0'; 
                ID_Branch <= '0';
                ID_MemRead <= '0';
                ID_MemWrite <= '0';
                ID_RegDst <= '0'; 
                ID_AluOp <= "011"; 
                ID_AluSrc <= '1';
                ID_Jump <= '0';
            when "001101" => --ORI Type
            	ID_RegWrite <= '1';
                ID_MemToReg <= '0'; 
                ID_Branch <= '0';
                ID_MemRead <= '0';
                ID_MemWrite <= '0';
                ID_RegDst <= '0'; 
                ID_AluOp <= "100"; 
                ID_AluSrc <= '1';
                ID_Jump <= '0';
            when "001110" => --XORI Type
            	ID_RegWrite <= '1';
                ID_MemToReg <= '0'; 
                ID_Branch <= '0';
                ID_MemRead <= '0';
                ID_MemWrite <= '0';
                ID_RegDst <= '0'; 
                ID_AluOp <= "101"; 
                ID_AluSrc <= '1';
                ID_Jump <= '0';
            when "000010" => --JUMP Type
            	ID_RegWrite <= '0';
                ID_MemToReg <= '0'; 
                ID_Branch <= '0';
                ID_MemRead <= '0';
                ID_MemWrite <= '0';
                ID_RegDst <= '0'; 
                ID_AluOp <= "111"; -- Es indistinto
                ID_AluSrc <= '0';
                ID_Jump <= '1';
            when others => -- Nop Type
            	ID_RegWrite <= '0';
                ID_MemToReg <= '0';
                ID_Branch <= '0';
                ID_MemRead <= '0';
                ID_MemWrite <= '0';
                ID_RegDst <= '0';
                ID_AluOp <= "111";
                ID_AluSrc <= '0';
                ID_Jump <= '0';
        end case;
    end process;
end Logic_ControlUnit;