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
		  
-- CREAR CLIQUES DE TAMAÑO 3

DELETE FROM cliques;

INSERT INTO cliques SELECT fila, u FROM temporal
		      UNION	
		    SELECT fila, v1 FROM temporal
		      UNION
		    SELECT fila, v2 FROM temporal;

SET @SIZE := 3;

-- AGREGAR UN NUEVO NODO, e INSERTARLO EN CLIQUES

SET @max := 3;

WHILE @max > 0 DO
  -- ******************************************************************************************************************************      
  -- COPIAR SOLUCION ACTUAL
  -- ******************************************************************************************************************************

  DELETE FROM solucion;
  INSERT INTO solucion SELECT * FROM cliques;
  
  -- ******************************************************************************************************************************
  -- ******************************************************************************************************************************  
  
  -- ******************************************************************************************************************************      
  -- PEGAR CADA NODO CON LOS CLIQUES CREADOS Y SELECCIONAR AQUELLOS QUE SE CONECTEN A TODOS LOS DE UN CLIQUE
  -- ******************************************************************************************************************************
  DELETE FROM new_cliques;
  
  INSERT INTO new_cliques 
    SELECT fila, (@ROW := @ROW + 1) as new_fila, v FROM
      (SELECT fila, v, count(*) as vecinos FROM
	(SELECT t1.fila as fila, t1.v as u, nodos.v as v FROM 
	  nodos,
	  cliques as t1 
	  WHERE (t1.v, nodos.v) IN (SELECT * FROM arcos)
	  ORDER BY fila, u) as t1 GROUP BY fila, v) as t1
      WHERE t1.vecinos = @size; 
      
   SELECT "INSERCION HECHA";
  -- ******************************************************************************************************************************
  -- ******************************************************************************************************************************      

  -- ******************************************************************************************************************************      
  -- ELIMINAR AQUELLOS CLIQUES QUE SON MENORES AL LIMITE ACTUAL
  -- ******************************************************************************************************************************
  
    -- #AGRUPAR LOS NUEVOS NODOS AÑADIDOS A CADA CLIQUE
    DELETE FROM temporal;  
    INSERT INTO temporal SELECT new_fila, cliques.fila, v, new_v FROM cliques, new_cliques WHERE cliques.fila = new_cliques.fila ORDER BY new_fila, v, new_v;
    SELECT "NODO NUEVO AGREGADO";
  
    -- #SEPARAR LOS CLIQUES EN SU NUEVO TAMAÑO
    DELETE FROM cliques;  
    INSERT INTO cliques SELECT fila, v1 FROM temporal;
    INSERT INTO cliques SELECT fila, v2 FROM temporal;        
  
    -- #ELIMINAR COMPONENTES DUPLICADAS AÑADIDAS EN EL PASO ANTERIOR (fila, nodo)
    DELETE FROM temporal;  
    INSERT INTO temporal (fila, u) SELECT DISTINCT * FROM cliques;
  
    -- #ASIGNAR LOS CLIQUES NUEVAMENTE EN LA TABLA ORIGINAL [cliques]
    DELETE FROM cliques;
    INSERT INTO cliques SELECT fila, u FROM temporal;    
    
    SELECT "CLIQUES CREADOS", count(*) FROM cliques;
    -- #ELIMINAR CLIQUES DUPLICADOS
    SET @size := @size + 1;
    
    DELETE FROM cliques 
	  WHERE fila IN (SELECT DISTINCT f2 
			    FROM (SELECT f1, f2, count(*) as igual 
				    FROM (SELECT t1.fila as f1, t2.fila as f2, t1.v as v1, t2.v as v2
					    FROM cliques as t1, cliques as t2 
					    WHERE t1.fila <= t2.fila AND t1.v = t2.v 
					    ORDER BY t1.fila, t2.fila, t1.v, t2.v) as t1 
				    GROUP BY f1, f2) as t1 
			    WHERE igual = @size AND f2 > f1);    
    
    SELECT "DUPLICADOS ELIMINADOS";
  -- ******************************************************************************************************************************
  -- ******************************************************************************************************************************  
  
  SELECT @size, @max := count(*) FROM cliques;
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

