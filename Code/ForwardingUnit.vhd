library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

entity ForwardingUnit is
    port(
        regDstMem, regDstWb, readRs, readRt: in std_logic_vector(4 downto 0);
        regWriteMem, regWriteWb: in std_logic;
        forwardA, forwardB: out std_logic_vector(1 downto 0)
    );
end ForwardingUnit;

architecture Logic_ForwardingUnit of ForwardingUnit is

signal condMemRt, condWbRt, condMemRs, condWbRs: std_logic;

begin

	-- Calculo condición para adelantar el dato desde Etapa Mem --
    
    condMemRs <= '1' when (regWriteMem = '1' and readRs /= "00000" and readRs = regDstMem) else '0';
    condMemRt <= '1' when (regWriteMem = '1' and readRt /= "00000" and readRt = regDstMem) else '0';
    
    -- Calculo condición para adelantar el dato desde Etapa Wb --
    condWbRs <= '1' when (regWriteWb = '1' and readRs /= "00000" and not(regWriteMem = '1' and readRs = regDstMem) and readRs = regDstWb) else '0';
    condWbRt <= '1' when (regWriteWb = '1' and readRt /= "00000" and not(regWriteMem = '1' and readRt = regDstMem) and readRt = regDstWb) else '0';

    SalidaForwardA: process (condMemRs, condWbRs) begin   
        if (condMemRs = '1') then
            forwardA <= "10";
        end if;

        if (condWbRs = '1') then
            forwardA <= "01";
        end if;

        if (not (condMemRs = '1' or condWbRs = '1')) then
            forwardA <= "00";
        end if;
    end process;
    
    SalidaForwardB: process (condMemRt, condWbRt) begin
    
    	if (condMemRt = '1') then
            forwardB <= "10";
        end if;
        
        if (condWbRt = '1') then
            forwardB <= "01";
        end if;
        
        if (not (condMemRt = '1' or condWbRt = '1')) then
            forwardB <= "00";
        end if;
    end process;
end Logic_ForwardingUnit;