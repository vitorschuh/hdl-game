LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
 
ENTITY VGASync IS
 PORT(
 RESET : IN STD_LOGIC; -- Entrada para reiniciar o estado do controlador
 F_CLOCK : IN STD_LOGIC; -- Entrada de clock (50 MHz)
 F_HSYNC : OUT STD_LOGIC; -- Sinal de controle VGA: H_SYNC
 F_VSYNC : OUT STD_LOGIC; -- Sinal de controle VGA: V_SYNC
 F_ROW : OUT STD_LOGIC_VECTOR(9 DOWNTO 0); -- Índice da linha que está sendo processada
 F_COLUMN : OUT STD_LOGIC_VECTOR(10 DOWNTO 0); -- Índice da coluna que está sendo processada
 F_DISP_ENABLE : OUT STD_LOGIC --Indica a região ativa do frame
 );
END ENTITY VGASync;
 
ARCHITECTURE arch OF VGASync IS
 
-- Sinais de controle Horizontal
SIGNAL H_CMP1 : STD_LOGIC; -- Indica que o contador Horizontal está com o valor D
SIGNAL H_CMP2 : STD_LOGIC; -- Indica que o contador Horizontal está com o valor D+E
SIGNAL H_CMP3 : STD_LOGIC; -- Indica que o contador Horizontal está com o valor D+E+B
SIGNAL H_CMP4 : STD_LOGIC; -- Indica que o contador Horizontal está com o valor D+E+B+C
SIGNAL HSync_Next : STD_LOGIC; -- Valor de H_SYNC no próximo pulso de clock
SIGNAL HSync_Prior : STD_LOGIC; -- Último valor atribuído em H_SYNC
SIGNAL HDataOn_Next : STD_LOGIC; -- Indica que o contador Horizontal está na região ativa
SIGNAL HDataOn_Prior : STD_LOGIC; -- Último valor atribuído em HDataOn
SIGNAL HCount_Next : STD_LOGIC_VECTOR(10 DOWNTO 0); --próximo valor do contador Horizontal
SIGNAL HCount_Prior : STD_LOGIC_VECTOR(10 DOWNTO 0); --valor atual do contador Horizontal
 
-- Sinais de controle Vertical
SIGNAL V_CMP1 : STD_LOGIC; -- Indica que o contador Vertical está com o valor R
SIGNAL V_CMP2 : STD_LOGIC; -- Indica que o contador Vertical está com o valor R+S
SIGNAL V_CMP3 : STD_LOGIC; -- Indica que o contador Vertical está com o valor R+S+P
SIGNAL V_CMP4 : STD_LOGIC; -- Indica que o contador Vertical está com o valor R+S+P+Q
SIGNAL VSync_Next : STD_LOGIC; -- Valor de V_SYNC no próximo pulso de clock
SIGNAL VSync_Prior : STD_LOGIC; -- Último valor atribuído em V_SYNC
SIGNAL VDataOn_Next : STD_LOGIC; -- Indica que o contador Vertical está na região ativa
SIGNAL VDataOn_Prior : STD_LOGIC; -- Último valor atribuído em VDataOn
SIGNAL VCount_Next : STD_LOGIC_VECTOR(9 DOWNTO 0); --próximo valor do contador Vertical
SIGNAL VCount_Prior : STD_LOGIC_VECTOR(9 DOWNTO 0); --valor atual do contador Vertical
 
 
BEGIN
 
 --=============================================
 --SINAIS DE CONTROLE DO MÓDULO VGA
 --=============================================
 F_HSYNC <= HSync_Prior;
 F_VSYNC <= VSync_Prior;
 F_ROW <= VCount_Prior;
 F_COLUMN <= HCount_Prior;
 F_DISP_ENABLE <= HDataOn_Prior AND VDataOn_Prior;
 
 --=============================================
 --Atualiza o sinal de saída dos FFD conforme o 
 --sinal de Clock/Reset
 --=============================================
 PROCESS(F_CLOCK, RESET)
 BEGIN
 
 IF (RESET = '0') THEN
 
 HCount_Prior <= (others => '0');
 VCount_Prior <= (others => '0');
 HSync_Prior <= '0';
 VSync_Prior <= '0';
 HDataOn_Prior <= '0';
 VDataOn_Prior <= '0';
 
 ELSIF RISING_EDGE(F_CLOCK) THEN
 
 --Contadores
 HCount_Prior <= HCount_Next;
 VCount_Prior <= VCount_Next;
 
 --Sinais de sincronismo
 HSync_Prior <= HSync_Next;
 VSync_Prior <= VSync_Next;
 HDataOn_Prior <= HDataOn_Next;
 VDataOn_Prior <= VDataOn_Next;
 
 END IF;
 
 END PROCESS;
 
 --=============================================
 --CONTADORES
 --=============================================
 
 --Contador - Horizontal
 -- O contador é reiniciado após 1040 pulsos
 HCount_Next <= (others => '0') WHEN H_CMP4 = '1' ELSE
                HCount_Prior + 1;
 
 -- Contador - Vertical
 -- O contador é reiniciado após 666 pulsos
 -- O contador é incrementado somente após a finalização de uma linha
 VCount_Next <= (others => '0') WHEN V_CMP4 = '1' ELSE
                VCount_Prior + 1 WHEN H_CMP4 = '1' ELSE
                VCount_Prior;
 
 --=============================================
 --COMPARADORES
 --=============================================
 
 --CONTADOR = D (800)
 H_CMP1 <= '1' WHEN HCount_Prior = 799 ELSE '0';
 
 --CONTADOR = D + E (D + E = 800 + 56 = 856)
 H_CMP2 <= '1' WHEN HCount_Prior = 855 ELSE '0';
 
 --CONTADOR = D + E + B (D + E + B = 800 + 56 + 120 = 976)
 H_CMP3 <= '1' WHEN HCount_Prior = 975 ELSE '0';
 
 --CONTADOR = D + E + B + C = (D + E + B + C = 800 + 56 + 120 + 64 = 1040)
 H_CMP4 <= '1' WHEN HCount_Prior = 1039 ELSE '0';
 
 --CONTADOR = R 600
 V_CMP1 <= '1' WHEN VCount_Prior = 599 ELSE '0';
 
 --CONTADOR = R + S 600 + 37 = 637
 V_CMP2 <= '1' WHEN VCount_Prior = 636 ELSE '0';
 
 --CONTADOR = R + S + P = 600 + 37 + 6 = 643
 V_CMP3 <= '1' WHEN VCount_Prior = 642 ELSE '0';
 
 --CONTADOR = R + S + P + Q = 600 + 37 + 6 + 23 = 666
 V_CMP4 <= '1' WHEN VCount_Prior = 665 ELSE '0';
 
 
 --=============================================
 --VALORES DE ENTRADA DOS FFD
 --=============================================
 
 --Sincronização - Horizontal
 -- HSYNC = 0 após 856 pulsos e permanece em zero até 976 pulsos
 HSync_Next <= '0' WHEN H_CMP2 = '1' ELSE --Reset
               '1' WHEN H_CMP3 = '1' ELSE --Set
               HSync_Prior;          --Memória
 
 --Sincronização Vertical
 --VSYNC = 0 após 637 pulsos e permanece em zero até 643 pulsos 
 VSync_Next <= '0' WHEN V_CMP2 = '1' ELSE --Reset
               '1' WHEN V_CMP3 = '1' ELSE --Set
               VSync_Prior;          --Memória
 
 --Região Ativa - Horizontal
 HDataOn_Next <= '0' WHEN H_CMP1 = '1' ELSE --Reset
                 '1' WHEN H_CMP4 = '1' ELSE --Set
                 HDataOn_Prior;    --Memória
 
 --Região Ativa - Vertical
 VDataOn_Next <= '0' WHEN V_CMP1 = '1' ELSE --Reset
                 '1' WHEN V_CMP4 = '1' ELSE --Set
                 VDataOn_Prior;    --Memória
 
 
END ARCHITECTURE arch;
