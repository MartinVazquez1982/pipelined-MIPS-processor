-- Code your design here
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0);
	I_RdStb     : out std_logic;
	I_WrStb     : out std_logic;
	I_DataOut   : out std_logic_vector(31 downto 0);
	I_DataIn    : in  std_logic_vector(31 downto 0);
	-- Data memory
	D_Addr      : out std_logic_vector(31 downto 0);
	D_RdStb     : out std_logic;
	D_WrStb     : out std_logic;
	D_DataOut   : out std_logic_vector(31 downto 0);
	D_DataIn    : in  std_logic_vector(31 downto 0)
);
end processor;

architecture processor_arq of processor is 

----------------------------------------------
	-- Declaración de los componentes --
----------------------------------------------

component ControlUnit
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
end component;

component registers
	port(
        clk, reset, wr: in std_logic;
        reg1_rd, reg2_rd, reg_wr: in std_logic_vector(4 downto 0);
        data_wr: in std_logic_vector(31 downto 0);
        data1_rd, data2_rd: out std_logic_vector(31 downto 0)
    );
end component;

component ALUControl
	port(
    	funct:in std_logic_vector(5 downto 0);
        Aluop: in std_logic_vector(2 downto 0);
        signalAlu: out std_logic_vector(3 downto 0)
    );
end component;

component ALU
	port(
    	a, b: in std_logic_vector(31 downto 0);
        control: in std_logic_vector(3 downto 0);
        shamt: in std_logic_vector(4 downto 0);
        result: out std_logic_vector(31 downto 0);
        zero: out std_logic
    );
end component;

component HazardDetecUnit 
	port(
    	readMem, branch: in std_logic;
    	regDstEx, regDstMem, readRs, readRt: in std_logic_vector(4 downto 0);
    	PcWrite, ifIdWrite, nop: out std_logic    	
    );
end component;

component ForwardingUnit
	port(
    	regDstMem, regDstWb, readRs, readRt: in std_logic_vector(4 downto 0);
        regWriteMem, regWriteWb: in std_logic;
        forwardA, forwardB: out std_logic_vector(1 downto 0)
    );
end component;

----------------------------------------------
		-- Declaración de las Señales --
----------------------------------------------

	--Señales Etapa Fetch
	signal IF_PCout, IF_PcIn, PcMas4: std_logic_vector(31 downto 0);
	signal PCSrc: std_logic;
    signal MuxPC4_Target: std_logic_vector(31 downto 0);
	--Señales Pipeline IF/ID
	signal IFID_Instr, IFID_Pcmas4: std_logic_vector(31 downto 0); 
    --Señales Etapa Decode
	signal ID_RegWrite, ID_MemToReg, ID_Branch, ID_MemRead, ID_MemWrite, ID_RegDst, ID_AluSrc, ID_Jump: std_logic;
    signal Data1_rd, Data2_rd: std_logic_vector(31 downto 0);
    signal resultExtension: std_logic_vector(31 downto 0);
    signal resultShiftLeft_Beq: std_logic_vector(31 downto 0);
    signal resultShiftLeft_Jump: std_logic_vector(27 downto 0);
    signal targetBEQ, targetJump: std_logic_vector(31 downto 0);
    signal resultComparacion: std_logic;
    signal ID_AluOp: std_logic_vector(2 downto 0);
    signal Reg_rd1: std_logic_vector(4 downto 0);
    signal Reg_rd2: std_logic_vector(4 downto 0);
  	--Señales Pipeline ID/EX
    signal IDEX_aluSrc, IDEX_MemRead, IDEX_MemToReg, IDEX_MemWrite, IDEX_RegWrite, IDEX_RegDst: std_logic;
    signal IDEX_data1_rd, IDEX_data2_rd, IDEX_immExt: std_logic_vector(31 downto 0);
    signal IDEX_aluControl: std_logic_vector(2 downto 0);
    signal IDEX_RT, IDEX_RD, IDEX_RS, IDEX_Shamt: std_logic_vector(4 downto 0);
    --Señales Etapa Execute 
    signal EntradaA, EntradaB, salidaForwB: std_logic_vector(31 downto 0);
    signal EXE_AluControl: std_logic_vector(3 downto 0);
    signal ALUResult: std_logic_vector(31 downto 0);
    signal RegDstMux: std_logic_vector(4 downto 0);
    --Señales Pipeline EX/MEM
    signal EXMEM_MemRead, EXMEM_MemToReg, EXMEM_MemWrite, EXMEM_RegWrite: std_logic;
    signal EXMEM_ALUResult, EXMEM_DataMemory: std_logic_vector(31 downto 0);
    signal EXMEM_RegDst: std_logic_vector(4 downto 0);
    --Señales Etapa Memory
    signal MEM_Data: std_logic_vector(31 downto 0);
    --Señales Pipeline MEM/WB
    signal MEMWB_MemToReg, MEMWB_RegWrite: std_logic;
    signal MEMWB_RegDst: std_logic_vector(4 downto 0);
    signal MEMWB_ALUResult, MEMWB_DataMemory: std_logic_vector(31 downto 0);
    --Señales Etapa WriteBack
    signal MemToRegMux: std_logic_vector(31 downto 0);
    --Señales Harzard
    signal PcWrite, IFID_Write, nop: std_logic;
    --Señales Forwarding
    signal ForwardA, ForwardB: std_logic_vector(1 downto 0);
    
    
----------------------------------------------
	-- Comportamiento del Procesador --
----------------------------------------------

begin 	
 
----------------------------------------------
			-- Etapa Fetch --
----------------------------------------------

	PC_reg: process(Clk, Reset) begin
    	if (Reset = '1') then
        	IF_PcOut <= (others => '0');
        elsif (rising_edge(Clk) and PcWrite = '1') then
        	IF_PcOut <= IF_PcIn;
        end if;
    end process;
    
    --- Direccion de la siguiente instruccion a realizar el fetching ---
    
    PcMas4 <= IF_PcOut + x"00000004";
    
    MuxPC4_Target <= PcMas4 when (PCSrc = '0') else targetBEQ;
    
    IF_PcIn <= MuxPC4_Target when (ID_Jump = '0') else targetJump; --Mux agregado para salto incondicional 
    
    -- Fetching de la Instruccion --
    
    I_Addr <= IF_PcOut;
    
    I_RdStb <= '1';
    
    I_WrStb <= '0';
    
    I_DataOut <= x"00000000";
    
    -- Registro Pipeline IF/ID --
    
    IF_ID: process(Clk, Reset) begin
    	if (Reset = '1') then
        	IFID_Instr <= (others => '0');
            IFID_Pcmas4 <= (others => '0');
        elsif (rising_edge(Clk) and IFID_Write = '1') then
        	if (PCSrc = '0' and ID_Jump = '0') then
        		IFID_Instr <= I_DataIn;
            	IFID_Pcmas4 <= PcMas4;
            else 
            	IFID_Instr <= (others => '0');
            	IFID_Pcmas4 <= (others => '0');
            end if;
        end if;
    end process; 
    
----------------------------------------------
			-- Etapa Decode --
----------------------------------------------

	unidadDetHazard: HazardDetecUnit port map(
    	readMem => IDEX_MemRead,
        branch => ID_Branch,
        regDstEx => RegDstMux,
        regDstMem => EXMEM_RegDst,
        readRs => Reg_rd1,
        readRt => Reg_rd2,
        PcWrite => PcWrite,
        ifIdWrite => IFID_Write,
        nop => nop
    );

	UnidadDeControl: ControlUnit port map(
    	opCode => IFID_Instr(31 downto 26),
        ID_RegWrite => ID_RegWrite,
        ID_MemToReg => ID_MemToReg,
        ID_Branch => ID_Branch,
        ID_MemRead => ID_MemRead,
        ID_MemWrite => ID_MemWrite,
        ID_RegDst => ID_RegDst,
        ID_AluOp => ID_AluOp,
        ID_AluSrc => ID_AluSrc,
        ID_Jump => ID_Jump
     );
        
	Reg_rd1 <= IFID_Instr(25 downto 21); 
	Reg_rd2 <= IFID_Instr(20 downto 16);
        
    BancoDeRegistros: registers port map(
    	clk => Clk,
        reset => Reset,
        wr => MEMWB_RegWrite,
        reg1_rd => Reg_rd1,
        reg2_rd => Reg_rd2,
        reg_wr => MEMWB_RegDst,
        data_wr => MemToRegMux,
        data1_rd => Data1_rd,
        data2_rd => Data2_rd
	);
        
        --Extension de signo
        resultExtension <= x"ffff" & IFID_Instr(15 downto 0) when (IFID_Instr(15) = '1') 
        					else  x"0000" & IFID_Instr(15 downto 0);
    
    	-- Calculo Direccion de Salto beq --
        
        resultShiftLeft_Beq <= resultExtension(29 downto 0) & "00"; --Desplazamiento x2
        
        targetBEQ <= resultShiftLeft_Beq + IFID_Pcmas4; --Calculo targetBeq
                         
        resultComparacion <= '1' when (data1_rd = data2_rd) else '0'; --Calculo de la Condicion salto (PCSrc)
        PCSrc <= resultComparacion and ID_Branch;
        
        
        -- Calculo Direccion de Salto jump
        
        resultShiftLeft_Jump <= IFID_Instr(25 downto 0) & "00"; --Desplazamiento x2
        
        targetJump <= IFID_Pcmas4(31 downto 28) & resultShiftLeft_Jump; --Calculo targetJump
        
        
    	-- Registro Pipeline ID/EX --
        
    	ID_EX: process(Clk, Reset) begin
        	if (Reset = '1' or (rising_edge(Clk) and nop = '1')) then
        		IDEX_data1_rd <= (others => '0');
            	IDEX_data2_rd <= (others => '0');
                IDEX_immExt <= (others => '0');
                IDEX_aluControl <= (others => '0');
                IDEX_aluSrc <= '0';
                IDEX_MemRead <= '0';
                IDEX_MemToReg <= '0';
                IDEX_MemWrite <= '0';
                IDEX_RegWrite <= '0';
                IDEX_RegDst <= '0';
                IDEX_RT <= (others => '0');
                IDEX_RD <= (others => '0');
                IDEX_RS <= (others => '0');
                IDEX_Shamt <= (others => '0');
        	elsif (rising_edge(Clk)) then
        		IDEX_data1_rd <= Data1_rd;
            	IDEX_data2_rd <= Data2_rd;
                IDEX_immExt <= resultExtension;
                IDEX_aluControl <= ID_AluOp;
                IDEX_aluSrc <= ID_AluSrc ;
                IDEX_MemRead <= ID_MemRead;
                IDEX_MemToReg <= ID_MemToReg;
                IDEX_MemWrite <= ID_MemWrite;
                IDEX_RegWrite <= ID_RegWrite;
                IDEX_RegDst <= ID_RegDst;
                IDEX_RT <= IFID_Instr(20 downto 16);
                IDEX_RD <= IFID_Instr(15 downto 11);
                IDEX_RS <= IFID_Instr(25 downto 21);
                IDEX_Shamt <= IFID_Instr(10 downto 6);
        	end if;
    	end process;

----------------------------------------------
			-- Etapa Execute --
----------------------------------------------
	
    UnidadAdelantamiento: ForwardingUnit port map(
    	regDstMem => EXMEM_RegDst,
        regDstWb => MEMWB_RegDst,
        readRs => IDEX_RS,
        readRt => IDEX_RT,
        regWriteMem => EXMEM_RegWrite,
        regWriteWb => MEMWB_RegWrite,
        forwardA => ForwardA,
        forwardB => ForwardB
    );

	ControlALU: ALUControl port map(
    	funct => IDEX_immExt(5 downto 0),
        Aluop => IDEX_aluControl,
        signalAlu => EXE_AluControl
    );
    
    ArimeticLogicUnit: ALU port map(
    	a => EntradaA, 
        b => EntradaB,
        control => EXE_AluControl,
        shamt => IDEX_Shamt,
        result => ALUResult,
        zero => open
    );
    
    --Mux registro destino
    RegDstMux <= IDEX_RT when IDEX_RegDst = '0' else IDEX_RD;
    
    -- Entrada A de la ALU --
    
    MuxEntradaA: process (IDEX_data1_rd, MemToRegMux, EXMEM_ALUResult, ForwardA) begin
    	case ForwardA is
        	when "00" => EntradaA <= IDEX_data1_rd;
            when "01" => EntradaA <= MemToRegMux;
            when others => EntradaA <= EXMEM_ALUResult;
        end case;
    end process;
    
    -- Entrada B de la ALU --
    
    MuxEntradaB: process (IDEX_data2_rd, MemToRegMux, EXMEM_ALUResult, ForwardB) begin
    	case ForwardB is
        	when "00" => salidaForwB <= IDEX_data2_rd;
            when "01" => salidaForwB <= MemToRegMux;
            when others => salidaForwB <= EXMEM_ALUResult;
        end case;
    end process;
    
    EntradaB <= salidaForwB when (IDEX_aluSrc = '0') else IDEX_immExt;  --MuxImediato
    
    
    -- Registro Pipeline EX/MEM --
    
    EX_MEM: process(Clk, Reset) begin
    	if (reset = '1') then
        	EXMEM_MemRead <= '0';
            EXMEM_MemToReg <= '0';
            EXMEM_MemWrite <= '0';
            EXMEM_RegWrite <= '0';
            EXMEM_ALUResult <= (others => '0');
            EXMEM_DataMemory <= (others => '0');
            EXMEM_RegDst <= (others => '0');
        elsif (rising_edge(Clk)) then 
        	EXMEM_MemRead <= IDEX_MemRead;
            EXMEM_MemToReg <= IDEX_MemToReg;
            EXMEM_MemWrite <= IDEX_MemWrite;
            EXMEM_RegWrite <= IDEX_RegWrite;
            EXMEM_ALUResult <= ALUResult;
            EXMEM_DataMemory <= salidaForwB;
            EXMEM_RegDst <= RegDstMux;
        end if;
     end process;

----------------------------------------------
			-- Etapa Memory --
----------------------------------------------

	-- Conexiones a Memoria de Datos --
    
	D_Addr <= EXMEM_ALUResult;
	D_RdStb <=  EXMEM_MemRead;
	D_WrStb <=  EXMEM_MemWrite;
	D_DataOut <= EXMEM_DataMemory;
	MEM_Data <= D_DataIn;
    
    -- Registro Pipeline MEM/WB --
    
    MEM_WB: process(Clk, Reset) begin
    	if (reset = '1') then
        	MEMWB_MemToReg <= '0';
            MEMWB_RegWrite <= '0';
            MEMWB_RegDst <= (others => '0');
            MEMWB_ALUResult <= (others => '0');
            MEMWB_DataMemory <= (others => '0');
        elsif (rising_edge(Clk)) then
        	MEMWB_MemToReg <= EXMEM_MemRead;
            MEMWB_RegWrite <= EXMEM_RegWrite;
            MEMWB_RegDst <= EXMEM_RegDst;
            MEMWB_ALUResult <= EXMEM_ALUResult;
            MEMWB_DataMemory <= MEM_Data;
        end if;
    end process;
    

----------------------------------------------
			-- Etapa WriteBack --
----------------------------------------------

	-- Mux de entrada al Banco de registros --

	MemToRegMux <= MEMWB_DataMemory when MEMWB_MemToReg = '1' else MEMWB_ALUResult;


end processor_arq;