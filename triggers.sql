
-- Trigger de comando
CREATE TABLE Log_provas(
    operacao VARCHAR2(6),
    hora TIMESTAMP,
    CONSTRAINT check_operacao CHECK (operacao IN ('INSERT','UPDATE','DELETE'))
);

CREATE OR REPLACE TRIGGER controle_log_provas
AFTER INSERT OR DELETE OR UPDATE ON Prova
BEGIN
    IF (INSERTING) THEN
    	INSERT INTO Log_provas VALUES('INSERT', SYSDATE);

	ELSIF (UPDATING) THEN
        INSERT INTO Log_provas VALUES('UPDATE', SYSDATE);

	ELSIF (UPDATING) THEN
        INSERT INTO Log_provas VALUES('DELETE', SYSDATE);
	END IF;
END;


--Trigger composto
CREATE OR REPLACE TRIGGER apagar_professor
FOR DELETE ON Aluno
COMPOUND TRIGGER

    -- Declaração da variável global
    v_count NUMBER;

    -- Antes da execução da exclusão (conta quantos professores existem antes da operação)
    BEFORE STATEMENT IS
    BEGIN
        SELECT COUNT(*) INTO v_count FROM Professor;
    END BEFORE STATEMENT;

    AFTER EACH ROW IS
    BEGIN
        v_count := v_count - 1;
    END AFTER EACH ROW;

    -- Após todas as exclusões (impede que a tabela fique vazia)
    AFTER STATEMENT IS
    BEGIN
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-21000, 'A tabela PROFESSOR não pode ficar vazia');
        END IF;
    END AFTER STATEMENT;

END apagar_aluno;