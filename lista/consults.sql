SELECT A.nome 
FROM Professor P 
    JOIN Disciplina D
        ON P.CPFP = D.professor
    JOIN Matricula M 
        ON M.DISC = D.codDisc
    JOIN Aluno A
        ON A.CPFA = M.matAluno
WHERE A.nivel = 'GRAD'
    AND EXTRACT(YEAR FROM D.data) = 2024
    AND P.nome = 'Valéria';
