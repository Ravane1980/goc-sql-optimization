DROP PROCEDURE IF EXISTS GetAllNodes;

DELIMITER //
CREATE PROCEDURE GetAllNodes()
BEGIN

DELETE FROM temporal;

SELECT @ROW := 0;

-- construir todos los 3 cliques existentes con la topologia de grafo actual
INSERT INTO temporal SELECT (@ROW := @ROW + 1) as fila, t1.u as u, t1.v as v1, t2.v as v2
		  FROM arcos as t1, arcos as t2 
		  WHERE t1.u < t1.v AND t1.v < t2.v AND t1.u = t2.u AND (t1.v, t2.v) IN (SELECT * FROM arcos);
		  
SELECT * FROM temporal;

-- CREAR CLIQUES DE TAMAÑO 3

DELETE FROM cliques;

INSERT INTO cliques SELECT fila, u FROM temporal
		      UNION	
		    SELECT fila, v1 FROM temporal
		      UNION
		    SELECT fila, v2 FROM temporal;

SELECT * FROM cliques ORDER BY fila, v;

SET @SIZE := 3;

-- AGREGAR UN NUEVO NODO, e INSERTARLO EN CLIQUES

SET @max := 3;

WHILE @max > 0 DO

  DELETE FROM solucion;
  INSERT INTO solucion SELECT * FROM cliques;
  
  INSERT INTO cliques 
    SELECT fila, v FROM
      (SELECT fila, v, count(*) as vecinos FROM
	(SELECT t1.fila as fila, t1.v as u, nodos.v as v FROM 
	  nodos,
	  cliques as t1 
	  WHERE (t1.v, nodos.v) IN (SELECT * FROM arcos)
	  ORDER BY fila, u) as t1 GROUP BY fila, v) as t1
      WHERE t1.vecinos = @size;
    
    
  SELECT * FROM cliques ORDER BY fila, v;

  -- ELIMINAR AQUELLOS CLIQUES QUE SON MENORES AL LIMITE ACTUAL

  DELETE FROM cliques 
	 WHERE fila IN (SELECT fila FROM (SELECT fila, count(*) as size FROM cliques GROUP BY fila ORDER BY fila) as t1 WHERE t1.size = @size OR t1.size > @size + 1);
      -- WHERE fila IN (SELECT fila FROM (SELECT fila, count(*) as size FROM cliques GROUP BY fila ORDER BY fila) as t1 WHERE t1.size = @size);

  SELECT * FROM cliques ORDER BY fila, v;

  SELECT @max := count(*) FROM cliques;

  SET @size := @size + 1;
END WHILE;

SELECT * FROM solucion ORDER BY fila, v;
SELECT @size-1;

END //
DELIMITER ; 

-- SELECT n1.v as nodo1, n2.v as nodo2, c1.c as color1, c2.c as color2
-- 	  FROM nodos as n1, nodos as n2, color as c1, color as c2 
-- 	  WHERE c1.c <= 2 AND c2.c <= 2 AND n1.v != n2.v 
--		AND ((c1.c = c2.c AND (n1.v, n2.v) NOT IN (SELECT * FROM arcos))
--					OR 
--		     (c1.c <= 2 AND c2.c <= 2 AND NOT EXISTS (SELECT * FROM arcos WHERE u = n2.v AND v IN (SELECT v FROM arcos WHERE u = n1.v)))
--		     )
--	  ORDER BY nodo1, nodo2, color1, color2; 
	  
-- SELECT * 
--	  FROM arcos 
--	  WHERE u IN (SELECT v FROM (SELECT * FROM arcos WHERE u = 2) as t1 WHERE (v) IN (SELECT v FROM arcos WHERE u = 1))
--	      AND v IN (SELECT v FROM (SELECT * FROM arcos WHERE u = 2) as t1 WHERE (v) IN (SELECT v FROM arcos WHERE u = 1));




--	CREAR TABLA TEMPORAL QUE SUSTITUYA A [cliques] Y CAMBIR cliques por una tabla de 2 campso [fila, v]
--	AGREGAR A cliques aquellos donde la suma de 3 (se formaron 4-cliques)
--	BORRAR de cliques aquellos que agrupados por el clique no sumen 4 (no pudieron formar nuevos)
--	ELIMINAR DUPLICADOS (4 cliques similares)
--	REPETIR ahora con 1 mas

