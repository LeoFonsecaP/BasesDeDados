--1:

SELECT T.NOME, T.ESTADO, U.TIPO, U.COR_PRINCIPAL 
FROM TIME T JOIN UNIFORME U ON U.TIME = T.NOME
WHERE UPPER(U.TIPO) LIKE 'TITULAR' AND U.COR_PRINCIPAL IS NULL;

-- Os valores inseridos em dados_futebol ja sao o suficiente para testar, uma vez que temos
-- CHAPECOENSE	RESERVA	NULL, que n�o retorna por n�o ser titular e
-- VASCO TITULAR BRANCO, que n�o retorna por ter cor principal.


--2:
SELECT J.NOME, J.DATA_NASC, J.TIME, T.ESTADO, C.DATA, C.LOCAL
FROM JOGADOR J JOIN TIME T ON J.TIME = T.NOME
                LEFT JOIN(
                SELECT P.TIME1, P.TIME2, P.DATA, P.LOCAL FROM JOGA J
                JOIN PARTIDA P ON J.TIME1 = P.TIME1 AND J.TIME2 = P.TIME2
                WHERE UPPER(J.CLASSICO) LIKE 'S'
                ) C ON T.NOME = C.TIME1 OR T.NOME = C.TIME2;

-- Os dados de dados_futebol j� testam jogadores do time mandante e visitante, no jogo Palmeiras X Santos,
-- testa tamb�m um classico sem jogadores, em Vasco X Flamengo e testa jogadores que n�o jogam classicos.
-- Desse modo, n�o � necess�ria nenhuma inser��o adicional.


-- 3:
SELECT J.CLASSICO, COUNT(*)
FROM JOGA J JOIN PARTIDA P ON J.TIME1 = P.TIME1 AND J.TIME2 = P.TIME2
WHERE EXTRACT (MONTH FROM P.DATA) = 1 OR EXTRACT (MONTH FROM P.DATA) = 2
GROUP BY J.CLASSICO;

-- Os �nicos dois jogos em janeiro ou fevereiro inseridos por dados_futebol s�o classicos,
-- por isso, para testar, vamos inserir um n�o classico em janeiro. Ja temos os dois tipos de
-- partida fora desses meses, ent�o s� essa inser��o ser� necess�ria

INSERT INTO PARTIDA (TIME1, TIME2, DATA, PLACAR, LOCAL) VALUES ('CRUZEIRO', 'SANTOS', TO_DATE('2019/02/01 14:30:00', 'YYYY/MM/DD HH24:MI:SS'), '3X1', 'BELO HORIZONTE');

-- Depois da inser��o temos 1 n�o cl�ssico e 2 cl�ssicos, resultado desejado.


--4:
SELECT EXTRACT (MONTH FROM P.DATA) AS MONTH, COUNT(*) AS NUMERO_CLASSICOS
FROM JOGA J JOIN PARTIDA P ON J.TIME1 = P.TIME1 AND J.TIME2 = P.TIME2
WHERE EXTRACT (YEAR FROM P.DATA) = 2018 AND UPPER(J.CLASSICO) LIKE 'S'
GROUP BY EXTRACT (MONTH FROM P.DATA)
ORDER BY COUNT(*) DESC;

-- Em dados_futebol s� temos dois cl�ssicos em 2018, ambos em fevereiro.
-- Para melhorar o teste, iremos inserir cl�ssicos em outros meses.

INSERT INTO PARTIDA (TIME1, TIME2, DATA, PLACAR, LOCAL) VALUES ('PALMEIRAS', 'SANTOS', TO_DATE('2018/01/01 14:30:00', 'YYYY/MM/DD HH24:MI:SS'), '4X0', 'SANTOS');
INSERT INTO PARTIDA (TIME1, TIME2, DATA, PLACAR, LOCAL) VALUES ('PALMEIRAS', 'SANTOS', TO_DATE('2018/03/01 14:30:00', 'YYYY/MM/DD HH24:MI:SS'), '0X2', 'SANTOS');
INSERT INTO PARTIDA (TIME1, TIME2, DATA, PLACAR, LOCAL) VALUES ('PALMEIRAS', 'SANTOS', TO_DATE('2018/08/01 14:30:00', 'YYYY/MM/DD HH24:MI:SS'), '1X2', 'SANTOS');
INSERT INTO PARTIDA (TIME1, TIME2, DATA, PLACAR, LOCAL) VALUES ('PALMEIRAS', 'SANTOS', TO_DATE('2018/12/01 14:30:00', 'YYYY/MM/DD HH24:MI:SS'), '2X2', 'SANTOS');
INSERT INTO PARTIDA (TIME1, TIME2, DATA, PLACAR, LOCAL) VALUES ('PALMEIRAS', 'SANTOS', TO_DATE('2018/04/01 14:30:00', 'YYYY/MM/DD HH24:MI:SS'), '0X0', 'SANTOS');
INSERT INTO PARTIDA (TIME1, TIME2, DATA, PLACAR, LOCAL) VALUES ('PALMEIRAS', 'SANTOS', TO_DATE('2018/05/01 14:30:00', 'YYYY/MM/DD HH24:MI:SS'), '0X0', 'SANTOS');
INSERT INTO PARTIDA (TIME1, TIME2, DATA, PLACAR, LOCAL) VALUES ('VASCO', 'FLAMENGO', TO_DATE('2018/08/10 16:00:00', 'YYYY/MM/DD HH24:MI:SS'), '2X1', 'RIO DE JANEIRO');
INSERT INTO PARTIDA (TIME1, TIME2, DATA, PLACAR, LOCAL) VALUES ('VASCO', 'FLAMENGO', TO_DATE('2018/01/10 16:00:00', 'YYYY/MM/DD HH24:MI:SS'), '5X1', 'RIO DE JANEIRO');
INSERT INTO PARTIDA (TIME1, TIME2, DATA, PLACAR, LOCAL) VALUES ('VASCO', 'FLAMENGO', TO_DATE('2018/06/10 16:00:00', 'YYYY/MM/DD HH24:MI:SS'), '1X1', 'RIO DE JANEIRO');
INSERT INTO PARTIDA (TIME1, TIME2, DATA, PLACAR, LOCAL) VALUES ('PALMEIRAS', 'SANTOS', TO_DATE('2018/01/09 14:30:00', 'YYYY/MM/DD HH24:MI:SS'), '0X0', 'SANTOS');

-- Depois das inser��es o resultado segue correto.


--5:
SELECT T.NOME, T.ESTADO, T.SALDO_GOLS, EXTRACT (YEAR FROM P.DATA) AS YEAR, COUNT(*) AS CLASSICOS
FROM TIME T JOIN JOGA J ON T.NOME = J.TIME1 OR T.NOME = J.TIME2
            JOIN PARTIDA P ON J.TIME1 = P.TIME1 AND J.TIME2 = P.TIME2
WHERE J.CLASSICO LIKE 'S'
GROUP BY T.NOME, T.ESTADO, T.SALDO_GOLS, EXTRACT (YEAR FROM P.DATA)
ORDER BY EXTRACT (YEAR FROM P.DATA) DESC, COUNT(*) DESC;

-- Os dados de Dados_futebol j� s�o o suficiente para confirmar a consulta.


--6:

SELECT DISTINCT T.NOME 
FROM TIME T JOIN JOGA J ON T.NOME = J.TIME1 OR T.NOME = J.TIME2
            JOIN PARTIDA P ON J.TIME1 = P.TIME1 AND J.TIME2 = P.TIME2
WHERE UPPER(T.TIPO) LIKE ('PROFISSIONAL') AND UPPER(J.CLASSICO) LIKE ('S') AND
( SELECT COUNT(*) FROM 
    (
        SELECT T1.NOME, P.DATA FROM TIME T1 JOIN PARTIDA P ON T1.NOME = P.TIME1 WHERE P.PLACAR LIKE '0X%'
        union
        SELECT T1.NOME, P.DATA FROM TIME T1 JOIN PARTIDA P ON P.TIME2 = T1.NOME WHERE P.PLACAR LIKE '%X0'
    ) 
    C GROUP BY C.NOME HAVING C.NOME LIKE T.NOME) > 1;

-- Os valores previamente inseridos s�o o suficiente para testar a consulta.


--7:

SELECT T.ESTADO, T.TIPO, COUNT(*) AS QTD_TIMES, AVG(T.SALDO_GOLS) AS MEDIA_SG
FROM TIME T
WHERE T.ESTADO IS NOT NULL AND T.TIPO IS NOT NULL
GROUP BY T.ESTADO, T.TIPO
ORDER BY T.ESTADO, T.TIPO;

-- Com os dados em Dados_futebol j� testamos a consulta, n�o � necess�ria nova inser��o


--8:

SELECT J.TIME1, J.TIME2,COUNT(*) AS JOGOS
FROM JOGA J JOIN PARTIDA P ON J.TIME1 = P.TIME1 AND J.TIME2 = P.TIME2
WHERE UPPER(J.CLASSICO) = 'S'
GROUP BY J.TIME1, J.TIME2;

-- Para testar, faremos a inser��o de um cl�ssico sem jogos, uma vez que os dois
-- cl�ssicos da tabela tem partidas jogadas.

INSERT INTO JOGA (TIME1, TIME2, CLASSICO) VALUES ('BOTAFOGO', 'FLAMENGO', 'S');

-- A tabela n�o � alterada, como esperado.


--9:

SELECT T.NOME FROM TIME T WHERE
UPPER(T.ESTADO) LIKE ('SP') AND
NOT EXISTS (( SELECT DISTINCT P.LOCAL FROM PARTIDA P
                WHERE (UPPER(P.TIME1) LIKE ('SANTOS') OR UPPER(P.TIME2) LIKE ('SANTOS')) AND P.LOCAL IS NOT NULL
                )
                MINUS
                (SELECT P.LOCAL FROM PARTIDA P
                    WHERE (UPPER(P.TIME1) LIKE T.NOME OR UPPER(P.TIME2) LIKE T.NOME)
                    )
            );

-- Obviamente o Santos teria que aparecer no resultado. Para testar, faremos as
-- inser��es necess�rias para que outro time atenda os requisitos.

INSERT INTO JOGA (TIME1, TIME2, CLASSICO) VALUES ('CRUZEIRO', 'PALMEIRAS', 'N');
INSERT INTO PARTIDA (TIME1, TIME2, DATA, PLACAR, LOCAL) VALUES ('CRUZEIRO', 'PALMEIRAS', TO_DATE('2018/07/01 14:30:00', 'YYYY/MM/DD HH24:MI:SS'), '0X4', 'BELO HORIZONTE');

-- Depois da inser��o, o Palmeiras aparece na tabela, porque, assim como o santos,
-- jogou em Santos e em Belo Horizonte.


--10:

SELECT B.NOME, A.ESTADO, A.SG
FROM TIME B JOIN 
(
SELECT T.ESTADO, MIN(T.SALDO_GOLS) AS SG 
FROM TIME T
WHERE T.ESTADO IS NOT NULL
GROUP BY T.ESTADO
) A ON A.ESTADO = B.ESTADO AND A.SG = B.SALDO_GOLS
ORDER BY A.ESTADO;

-- INSERIDO MAIS UM TIME COM O SG MINIMO DO ESTADO PARA TESTAR A CONSULTA
INSERT INTO TIME (NOME, ESTADO, TIPO, SALDO_GOLS) VALUES ('FLUMINENSE', 'RJ', 'PROFISSIONAL', 0);
-- FOI INTERPRETADO QUE, QUANDO DOIS TIMES TEM O MENOR SALDO DO ESTADO, AMBOS
-- APARECEM NO RETORNO DA CONSULTA





                