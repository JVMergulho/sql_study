CREATE TABLE Curso (
    codigo_curso NUMBER,
    nome VARCHAR2(100),
    CONSTRAINT curso_p_key PRIMARY KEY (codigo_curso)
);

CREATE TABLE Professor (
    matricula_professor NUMBER,
    nome VARCHAR2(100) NOT NULL,
    data_admissao DATE,
    matricula_lider NUMBER,
    CONSTRAINT professor_p_key PRIMARY KEY (matricula_professor),
    CONSTRAINT professor_f_key FOREIGN KEY (matricula_lider) REFERENCES Professor(matricula_professor)
);

CREATE TABLE Disciplina (
    codigo_disciplina NUMBER,
    matricula_professor NUMBER,
    CONSTRAINT disciplina_p_key PRIMARY KEY (codigo_disciplina),
    CONSTRAINT disciplina_professor_f_key FOREIGN KEY (matricula_professor) REFERENCES Professor(matricula_professor)
);

CREATE TABLE Turma (
    ano_semestre VARCHAR2(6),
    codigo_disciplina NUMBER,
    codigo_curso NUMBER,
    CONSTRAINT turma_p_key PRIMARY KEY (ano_semestre, codigo_disciplina, codigo_curso),
    CONSTRAINT turma_disciplina_f_key FOREIGN KEY (codigo_disciplina) REFERENCES Disciplina(codigo_disciplina),
    CONSTRAINT turma_curso_f_key FOREIGN KEY (codigo_curso) REFERENCES Curso(codigo_curso)
);

CREATE SEQUENCE seq_cod_curso
    INCREMENT BY 1
    START WITH 1;

INSERT INTO Curso VALUES(seq_cod_curso.NEXTVAL, 'Ciência da Computação');
INSERT INTO Curso VALUES(seq_cod_curso.NEXTVAL, 'Medicina');

INSERT INTO Professor (matricula_professor, nome, data_admissao) VALUES(321, 'Samantha Nunes', TO_DATE('12/04/2008', 'DD/MM/YYYY'));
INSERT INTO Professor VALUES(123, 'Generson Pereira', TO_DATE('20/02/2014', 'DD/MM/YYYY'), 321);