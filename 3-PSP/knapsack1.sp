DROP PROCEDURE IF EXISTS GetMaxKnapSack;

DELIMITER //
CREATE PROCEDURE GetMaxKnapSack()
BEGIN    
  DELETE FROM global_solucion;
  DELETE FROM solucion;
  DELETE FROM valores;
  DELETE FROM pesos;
  DELETE FROM heuristica;
  DELETE FROM temp;
  
  INSERT INTO solucion SELECT * FROM objeto;
  
  SET @row := 0;    
  INSERT INTO valores SELECT @row := @row + 1, v FROM objeto ORDER BY v DESC;
  
  SET @row := 0;
  INSERT INTO pesos SELECT @row := @row + 1, w FROM objeto ORDER BY w;
  
  INSERT INTO heuristica SELECT valores.fila, v, w, 0, 0 FROM valores, pesos WHERE valores.fila = pesos.fila;
  
  INSERT INTO temp SELECT t1.fila, t1.v, t1.w, t2.v, t2.w FROM heuristica as t1, (SELECT t2.fila, SUM(t1.v) as v, SUM(t1.w) as w FROM heuristica as t1, heuristica as t2 WHERE t1.fila <= t2.fila GROUP BY t2.fila) as t2 WHERE t1.fila = t2.fila;
  
  DELETE FROM heuristica;
  INSERT INTO heuristica VALUES (0, 0, 0, 0, 0);
  INSERT INTO heuristica SELECT * FROM temp;
  
  INSERT INTO global_solucion VALUES (0, 0, 0, 0, 0, 0, 0);
    
  SET @max := 1;
  WHILE @max > 0 DO
  
    DELETE FROM new_solucion;
    
    INSERT INTO new_solucion SELECT DISTINCT 1 as id, (t1.b1 + t2.b1) as b1, (t1.b2 + t2.b2) as b2, (t1.b3 + t2.b3) as b3, (t1.b4 + t2.b4) as b4, (t1.v + t2.v) as v, (t1.w + t2.w) as w FROM
				solucion as t1,
				objeto as t2 
				WHERE (t1.b1 & t2.b1) = 0
				      AND (t1.b2 & t2.b2) = 0
				      AND (t1.b3 & t2.b3) = 0				      
				      AND (t1.b4 & t2.b4) = 0
				      AND t1.w + t2.w <= 200
				      HAVING (SELECT t1.v + t2.v + MAX(vsuma) FROM heuristica WHERE wsuma <= (200 - t1.w - t2.w)) > (SELECT MAX(v) FROM global_solucion);
	  
    DELETE FROM solucion;
    INSERT INTO solucion SELECT * FROM new_solucion;
    
    SELECT @max := count(*) FROM solucion;
    INSERT INTO global_solucion SELECT * FROM solucion WHERE v IN (SELECT max(v) FROM solucion);      
  END WHILE;
  
  SELECT * FROM global_solucion;
  SELECT * FROM objeto as t1, global_solucion as t2
	    WHERE t2.v IN (SELECT MAX(v) FROM global_solucion) AND ((t1.b1 & t2.b1) != 0 
		  OR (t1.b2 & t2.b2) != 0 
		  OR (t1.b3 & t2.b3) != 0 
		  OR (t1.b4 & t2.b4) != 0);

END //
DELIMITER ; 
  