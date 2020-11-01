DROP PROCEDURE IF EXISTS GetMaxClique_Alpha;

DELIMITER //
CREATE PROCEDURE GetMaxClique_Alpha()
BEGIN

DELETE FROM temporal;

SELECT @ROW := 0;

-- construir todos los 2 cliques existentes con la topologia de grafo actual
INSERT INTO temporal (fila, u, v1) SELECT (@ROW := @ROW + 1) as fila, t1.u as u, t1.v as v
		  FROM arcos as t1;
		  
-- CREAR CLIQUES DE TAMAÑO 2

DELETE FROM cliques;

INSERT INTO cliques SELECT fila, u FROM temporal
		      UNION	
		    SELECT fila, v1 FROM temporal;

SET @SIZE := 2;

-- AGREGAR UN NUEVO NODO, e INSERTARLO EN CLIQUES

SET @max := 2;

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
    
    DELETE FROM temporal;
    INSERT INTO temporal (fila) SELECT MIN(fila) 
					FROM (
					  SELECT cliques.fila,  sum(b1) as b1, sum(b2) as b2, sum(b3) as b3, sum(b4) as b4 
					  FROM cliques, nodos 
					  WHERE cliques.v = nodos.v 
					  GROUP BY cliques.fila) AS t1 
					GROUP BY b1, b2, b3, b4; 

    DELETE FROM cliques WHERE fila NOT IN (SELECT fila FROM temporal);
					    
--    INSERT INTO temporal (fila, u) SELECT * FROM cliques 
--					WHERE fila IN (
--					    SELECT MIN(fila) 
--					    FROM (
--						SELECT cliques.fila,  sum(b1) as b1, sum(b2) as b2, sum(b3) as b3, sum(b4) as b4 
--						FROM cliques, nodos 
--						WHERE cliques.v = nodos.v 
--						GROUP BY cliques.fila) AS t1 
--					    GROUP BY b1, b2, b3, b4) 
--					ORDER BY fila, v;
									  
    SELECT @size, @max := count(*) FROM cliques;  
    SELECT "DUPLICADOS ELIMINADOS", @max;
  -- ******************************************************************************************************************************
  -- ******************************************************************************************************************************  
  
  
  
END WHILE;

SELECT * FROM solucion ORDER BY fila, v;
SELECT @size-1;

END //
DELIMITER ; 

