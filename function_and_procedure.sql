
-- retorna o valor de ano e semestre por referência
CREATE OR REPLACE PROCEDURE 
    separa_ano_semestre(p_ano_semestre IN Turma.ano_semestre%TYPE,
    ano OUT NUMBER, semestre OUT NUMBER) IS
BEGIN
    ano := SUBSTR(P_ano_semestre,1,4);
	semestre := SUBSTR(P_ano_semestre,6,1);
END;

CREATE OR REPLACE FUNCTION anos_por_semestre (p_codigo IN Disciplina.codigo_disciplina%TYPE)
RETURN VarChar2 IS
    CURSOR c_ano_semestre IS -- declara o cursor explicitamente
        SELECT T.ano_semestre 
        FROM TURMA T 
        WHERE T.codigo_disciplina = p_codigo; 

    v_ano NUMBER;
    v_semestre NUMBER;
    v_ano_semestre Turma.ano_semestre%TYPE; 
	lista1 VARCHAR2(100) := '1º: ';
	lista2 VARCHAR2(100) := '2º: ';
BEGIN
    OPEN c_ano_semestre;

    LOOP
        FETCH c_ano_semestre INTO v_ano_semestre;
        EXIT WHEN c_ano_semestre%NOTFOUND;
        
        separa_ano_semestre(v_ano_semestre, v_ano, v_semestre);

        IF (v_semestre = 1) THEN  -- A comparação é realizada com = e não ==
            lista1 := lista1 || v_ano || ';';
        ELSE 
            lista2 := lista2 || v_ano || ';';
        END IF;
    END LOOP;

    CLOSE c_ano_semestre;

    RETURN lista1 || ' ' || lista2;
END;

-- Mesma função, porém com uso de cursor implícito e tabela

CREATE OR REPLACE FUNCTION anos_por_semestre (P_codigo disciplina.codigo_disciplina%TYPE)
RETURN VARCHAR2 IS
    TYPE turma_ano_semestre IS RECORD
    (cod_curso turma.codigo_curso%TYPE,
    ano NUMBER, semestre NUMBER);

	TYPE table_turma_ano_semestre IS TABLE OF turma_ano_semestre;

	t_turma table_turma_ano_semestre := table_turma_ano_semestre(); -- inicializa variável com a tabela vazia

	lista1 VARCHAR2(100) := '1º: ';
	lista2 VARCHAR2(100) := '2º: ';
BEGIN
    -- uso de cursor implícito
    FOR reg_turma IN 
    	(SELECT * FROM Turma T
    	WHERE T.codigo_disciplina = P_codigo) LOOP

    	t_turma.EXTEND(); -- Cria nova linha vazia;
		t_turma(t_turma.LAST).cod_curso := reg_turma.codigo_curso;

        separa_ano_semestre(reg_turma.ano_semestre, t_turma(t_turma.LAST).ano, t_turma(t_turma.LAST).semestre);
    END LOOP;

	WHILE t_turma.COUNT > 0 LOOP
        IF (t_turma(t_turma.LAST).semestre = 1) THEN
        	lista1 := lista1 || t_turma(t_turma.LAST).ano || ';';
        ELSE 
        	lista2 := lista2 || t_turma(t_turma.LAST).ano || ';';
        END IF;

		t_turma.TRIM(); -- remove última linha

	END LOOP;

	RETURN lista1 || ' ' || lista2; 

END;

SELECT anos_por_semestre(1) FROM DUAL;



