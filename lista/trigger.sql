CREATE OR REPLACE TRIGGER atualiza_qtd_professor
BEFORE INSERT OR DELETE ON Professor
FOR EACH ROW
DECLARE
    v_qtd NUMBER;
BEGIN 
    IF INSERTING THEN
        SELECT D.qtdeProfessores INTO v_qtd
        FROM Departamento D
        WHERE D.codDepto = :NEW.depto;

        UPDATE Departamento
        SET qtdeProfessores = v_qtd + 1
        WHERE codDepto = :NEW.depto;

    ELSIF DELETING THEN
        SELECT D.qtdeProfessores INTO v_qtd
        FROM Departamento D
        WHERE D.codDepto = :OLD.depto;

        UPDATE Departamento
        SET qtdeProfessores = v_qtd - 1
        WHERE codDepto = :NEW.depto;
    END IF;
END;