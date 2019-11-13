
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY PixelGen IS
	PORT(
		RESET : IN STD_LOGIC; -- Entrada para reiniciar o estado do controlador
		F_CLOCK : IN STD_LOGIC; -- Entrada de clock (50 MHz)
		F_ON : IN STD_LOGIC; --Indica a região ativa do frame
		F_ROW : IN STD_LOGIC_VECTOR(9 DOWNTO 0); -- Índice da linha que está sendo processada
		F_COLUMN : IN STD_LOGIC_VECTOR(10 DOWNTO 0); -- Índice da coluna que está sendo processada
		R_OUT : OUT STD_LOGIC; -- Componente R
		G_OUT : OUT STD_LOGIC; -- Componente G
		B_OUT : OUT STD_LOGIC -- Componente B
	);

END ENTITY PixelGen;

ARCHITECTURE arch OF PixelGen IS
SIGNAL RGBp : STD_LOGIC_VECTOR(2 DOWNTO 0); -- Valor atual do pixel
SIGNAL RGBn : STD_LOGIC_VECTOR(2 DOWNTO 0); -- Último valor definido
BEGIN

	-- Cada componente deve ser ativada somente se o frame estiver na região ativa
	R_OUT <= RGBp(2) AND F_ON;
	G_OUT <= RGBp(1) AND F_ON;
	B_OUT <= RGBp(0) AND F_ON;
		
	-- Define um novo valor RGB de acordo com índice da coluna
        RGBn <= "000" WHEN F_COLUMN = "0000000000" ELSE -- Preto (Coluna = 0)
                "001" WHEN F_COLUMN = "0001100100" ELSE -- Azul (Coluna = 100)
                "010" WHEN F_COLUMN = "0011001000" ELSE -- Verde (Coluna = 200)
                "011" WHEN F_COLUMN = "0100101100" ELSE -- Ciano (Coluna = 300)
                "100" WHEN F_COLUMN = "0110010000" ELSE -- Vermelho (Coluna = 400)
                "101" WHEN F_COLUMN = "0111110100" ELSE -- Magenta (Coluna = 500)
                "110" WHEN F_COLUMN = "1001011000" ELSE -- Amarelo (Coluna = 600)
                "111" WHEN F_COLUMN = "1010111100" ELSE -- Branco (Coluna = 700)
                RGBp; --Último valor definido
	
	PROCESS(F_CLOCK, RESET)
	BEGIN
		IF (RESET = '0') THEN
			RGBp <= (others => '0');
		ELSIF RISING_EDGE(F_CLOCK) THEN
			RGBp <= RGBn;
		END IF;
	END PROCESS;
	
END ARCHITECTURE arch;
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
 
ENTITY PixelGen IS
 PORT(
 RESET : IN STD_LOGIC; -- Entrada para reiniciar o estado do controlador
 F_CLOCK : IN STD_LOGIC; -- Entrada de clock (50 MHz)
 F_ON : IN STD_LOGIC; --Indica a região ativa do frame
 F_ROW : IN STD_LOGIC_VECTOR(9 DOWNTO 0); -- Índice da linha que está sendo processada
 F_COLUMN : IN STD_LOGIC_VECTOR(10 DOWNTO 0); -- Índice da coluna que está sendo processada
 R_OUT : OUT STD_LOGIC; -- Componente R
 G_OUT : OUT STD_LOGIC; -- Componente G
 B_OUT : OUT STD_LOGIC -- Componente B
 );
 
END ENTITY PixelGen;
 
ARCHITECTURE arch OF PixelGen IS
SIGNAL RGBp : STD_LOGIC_VECTOR(2 DOWNTO 0); -- Valor atual do pixel
SIGNAL RGBn : STD_LOGIC_VECTOR(2 DOWNTO 0); -- Último valor definido
BEGIN
 
 -- Cada componente deve ser ativada somente se o frame estiver na região ativa
 R_OUT <= RGBp(2) AND F_ON;
 G_OUT <= RGBp(1) AND F_ON;
 B_OUT <= RGBp(0) AND F_ON;
 
 -- Define um novo valor RGB de acordo com índice da coluna
        RGBn <= "000" WHEN F_COLUMN = "0000000000" ELSE -- Preto (Coluna = 0)
                "001" WHEN F_COLUMN = "0001100100" ELSE -- Azul (Coluna = 100)
                "010" WHEN F_COLUMN = "0011001000" ELSE -- Verde (Coluna = 200)
                "011" WHEN F_COLUMN = "0100101100" ELSE -- Ciano (Coluna = 300)
                "100" WHEN F_COLUMN = "0110010000" ELSE -- Vermelho (Coluna = 400)
                "101" WHEN F_COLUMN = "0111110100" ELSE -- Magenta (Coluna = 500)
                "110" WHEN F_COLUMN = "1001011000" ELSE -- Amarelo (Coluna = 600)
                "111" WHEN F_COLUMN = "1010111100" ELSE -- Branco (Coluna = 700)
                RGBp; --Último valor definido
 
 PROCESS(F_CLOCK, RESET)
 BEGIN
 IF (RESET = '0') THEN
 RGBp <= (others => '0');
 ELSIF RISING_EDGE(F_CLOCK) THEN
 RGBp <= RGBn;
 END IF;
 END PROCESS;
 
END ARCHITECTURE arch;