DROP PROCEDURE IF EXISTS GetMaxClique_Beta;

DELIMITER //
CREATE PROCEDURE GetMaxClique_Beta()
BEGIN

  SET @size := 1;
  SET @max := 1;
  
  DELETE FROM maxclique;
  INSERT INTO maxclique SELECT b1, b2, b3, b4 FROM grafo;  
  
  WHILE @max > 0 DO
    DELETE FROM maxclique_solucion;
    INSERT INTO maxclique_solucion SELECT * FROM maxclique;
    
    DELETE FROM new_maxclique;

    INSERT INTO new_maxclique SELECT DISTINCT (t1.b1 + t2.b1) as b1, (t1.b2 + t2.b2) as b2, (t1.b3 + t2.b3) as b3, (t1.b4 + t2.b4) as b4 FROM maxclique as t1, grafo as t2
	  WHERE (t1.b1 & t2.adj1) = t1.b1
		AND (t1.b2 & t2.adj2) = t1.b2
		AND (t1.b3 & t2.adj3) = t1.b3
		AND (t1.b4 & t2.adj4) = t1.b4
	 ORDER BY b1, b2, b3, b4;
	
    DELETE FROM maxclique;
    INSERT INTO maxclique SELECT * FROM new_maxclique;
    
    SET @size := @size + 1;
    
    SELECT @size, @max := count(*) FROM maxclique;  
  END WHILE;

  -- MOSTRAR CLIQUES	 
  SELECT maxclique_solucion.*, grafo.v 
	FROM maxclique_solucion, grafo 
	WHERE (grafo.b1 & maxclique_solucion.b1) != 0 
	      OR (grafo.b2 & maxclique_solucion.b2) != 0 
	      OR (grafo.b3 & maxclique_solucion.b3) != 0 
	      OR (grafo.b4 & maxclique_solucion.b4) != 0
	ORDER BY b1, b2, b3, b4;  
END //
DELIMITER ; 
