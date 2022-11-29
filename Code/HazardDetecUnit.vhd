library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

entity HazardDetecUnit is
	port(
    	readMem, branch: in std_logic;
    	regDstEx, regDstMem, readRs, readRt: in std_logic_vector(4 downto 0);
    	PcWrite, ifIdWrite, nop: out std_logic
    );
end HazardDetecUnit;

architecture Logic_HazardDetecUnit of HazardDetecUnit is

begin

    LogicaHazardUnit: process (readMem, branch, regDstEx, regDstMem, readRs, readRt) begin
        if (readMem = '1' and (regDstEx = readRs or regDstEx = readRt)) then -- Caso de riesgo insalvable de lw (Detener el pipeline) --
            PcWrite <= '0';
            ifIdWrite <= '0';
            nop <= '1';
        else if (branch = '1' and (regDstEx = readRs or regDstEx = readRt or regDstMem = readRs or regDstMem = readRt) and readRt /= "00000" and readRs /= "00000") then -- Caso de riesgo RAW de una inst. beq (Detener el pipeline) --
            PcWrite <= '0';
            ifIdWrite <= '0';
            nop <= '1';
        else -- No se detiene el Pipeline --
        	PcWrite <= '1';
            ifIdWrite <= '1';
            nop <= '0';
        end if;
        end if;
    end process; 
    
end Logic_HazardDetecUnit;
