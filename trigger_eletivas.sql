CREATE OR REPLACE FUNCTION calcula_creditos(par_matricula IN Aluno.matricula_aluno%TYPE)
RETURN NUMBER IS
    creditos_projeto NUMBER;
	creditos_monitoria NUMBER;
    creditos_cadeira NUMBER;
BEGIN 

    SELECT COUNT(*)*5,  COUNT(AT.codigo_projeto) 
    INTO creditos_cadeira, creditos_projeto
    FROM Aluno A
    	JOIN Aluno_turma AT
    		ON AT.matricula_aluno = A.matricula_aluno
    		AND A.matricula_aluno = par_matricula;
    
    SELECT COUNT(*)*2
    INTO creditos_monitoria
    FROM Aluno A
    	JOIN Monitoria M
    		ON M.matricula_aluno = A.matricula_aluno
    		AND A.matricula_aluno = par_matricula;

    RETURN creditos_cadeira + creditos_projeto + creditos_monitoria;
END;

CREATE OR REPLACE PROCEDURE separa_ano_semestre(p_ano_semestre IN Turma.ano_semestre%TYPE,
    ano OUT NUMBER, semestre OUT NUMBER) IS
BEGIN
    ano := SUBSTR(P_ano_semestre,1,4);
	semestre := SUBSTR(P_ano_semestre,6,1);
END;

-- Trigger que impede alunos com menos de 15 créditos de se matricularem em eletivas
-- para NÃO ser considerada eletiva, ela precisa ter sido ofertada pelo menos 3 vezes consecutivas em quaisquer períodos.
CREATE OR REPLACE TRIGGER checa_creditos_eletiva
BEFORE INSERT ON Aluno_turma
FOR EACH ROW
DECLARE
    -- Tipos definidos
    TYPE tipo_ano_semestre IS RECORD(
        ano NUMBER,
        semestre NUMBER
    );

    TYPE table_ano_semestre IS TABLE OF tipo_ano_semestre;

    t_as table_ano_semestre := table_ano_semestre();  -- Inicializando a coleção
    
    v_ano NUMBER;
    v_semestre NUMBER;
    reg_ano_semestre Turma.ano_semestre%TYPE;
    eletiva NUMBER := 1;
BEGIN
    -- Verifica se o aluno tem menos de 15 créditos
    IF calcula_creditos(:NEW.matricula_aluno) < 15 THEN  -- não pode pegar uma cadeira eletiva
        -- Loop para verificar os anos e semestres das turmas associadas à disciplina
        FOR reg_ano_semestre IN 
            (SELECT T.ano_semestre FROM Disciplina D 
             JOIN Turma T 
                ON D.codigo_disciplina = T.codigo_disciplina 
                AND D.codigo_disciplina = :NEW.codigo_disciplina
             ORDER BY T.ano_semestre ASC)
        LOOP
            -- Chama a função que separa ano e semestre
            separa_ano_semestre(reg_ano_semestre.ano_semestre, v_ano, v_semestre);

            -- Verifica se há espaço para adicionar um novo ano/semestre na coleção
            IF t_as.COUNT < 3 THEN
                t_as.EXTEND;  -- Adiciona um novo elemento à coleção
                t_as(t_as.LAST).ano := v_ano;
                t_as(t_as.LAST).semestre := v_semestre;
            ELSE
                -- Verifica se a sequência de anos e semestres é consecutiva
                IF (t_as(1).ano = t_as(2).ano
                    AND t_as(2).ano = t_as(3).ano - 1 
                    AND t_as(3).semestre = 1) OR
                   (t_as(2).ano = t_as(3).ano
                    AND t_as(2).ano = t_as(1).ano + 1 
                    AND t_as(1).semestre = 2) THEN
                    eletiva := 0;  -- Marca como não-eletiva
                END IF;
                
                -- Exclui o primeiro elemento após a verificação
                t_as.DELETE(1);
            END IF;
        END LOOP;

        -- Caso a matrícula seja inválida, lança erro
        IF eletiva = 1 THEN
            RAISE_APPLICATION_ERROR(-20105, 'ALUNO NAO PODE PAGAR CADEIRA ELETIVA. NAO CONSECUTIVA');
        ELSE
            DBMS_OUTPUT.PUT_LINE('MATRICULA REALIZADA COM SUCESSO');
        END IF;
    END IF;
END checa_creditos_eletiva;