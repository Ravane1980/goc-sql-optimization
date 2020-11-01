CREATE TABLE IF NOT EXISTS Journals (id_journal INT, name VARCHAR(100), publisher VARCHAR(100), address VARCHAR(100));
CREATE TABLE IF NOT EXISTS  Articles (id_article INT, title VARCHAR(100), id_author INT, id_journal INT, year INT, volume INT, pages INT);
CREATE TABLE IF NOT EXISTS  Authors (id_author INT, name VARCHAR(100), affiliation VARCHAR(100));
CREATE TABLE IF NOT EXISTS AuthorsPerArticle (id_article INT, id_author INT);
CREATE TABLE IF NOT EXISTS  Citations (id_article INT, cited_by INT);

DELETE FROM Journals;
DELETE FROM Articles;
DELETE FROM Authors;
DELETE FROM AuthorsPerArticle;
DELETE FROM Citations;

INSERT INTO Journals (id_journal, name, publisher, address) VALUES (1, 'IJCM', 'Taylor', 'England'),
								    (2, 'DM', 'Elsevier', 'Europe'), 
								    (3, 'iJMEST', 'Taylor', 'USA');

INSERT INTO Authors (id_author, name, affiliation) VALUES (1, 'Nelson', 'UPV-Mexico'),
							  (2, 'Himer', 'UPV-España'),
							  (3, 'Anita', 'CINVESTAV');

INSERT INTO Articles (id_article, title, id_author, id_journal, year, volume, pages) VALUES (1, 'A', 1, 1, 2009, 1, 12),
											    (2, 'B', 2, 1, 2009, 1, 12), 
											    (3, 'C', 3, 1, 2009, 1, 8),
											    (4, 'D', 1, 1, 2010, 1, 14),  
											    (5, 'E', 1, 1, 2010, 1, 25),  
											    (6, 'F', 1, 1, 2011, 1, 13),  
											    (7, 'G', 2, 2, 2009, 1, 32),  
											    (8, 'H', 3, 2, 2010, 1, 32),  
											    (9, 'I', 1, 3, 2010, 1, 19),  
											    (10, 'J', 2, 3, 2009, 1, 32),  
											    (11, 'K', 2, 2, 2011, 1, 22),  
											    (12, 'L', 1, 1, 2011, 1, 12);

INSERT INTO AuthorsPerArticle (id_article, id_author) VALUES (1, 1),
								(1, 2),
								(2, 2),
								(2, 3),
								(3, 3),
								(4, 1),
								(5, 1),
								(5, 2),
								(6, 1),
								(7, 2),
								(7, 3),
								(8, 3),
								(9, 1),
								(9, 2),
								(9, 3),
								(9, 1),
								(10, 2),
								(11, 2),
								(12, 1);



INSERT INTO Citations (id_article, cited_by) VALUES (1, 6),
								  (2, 4),
								  (3, 12),
								  (4, 11),
								  (5, 6),
								  (7, 11),
								  (7, 6),
								  (8, 12),
								  (9, 6),
								  (10, 8),
								  (8, 11),
								  (1, 4),
								  (3, 5),
								  (5, 11),
								  (8, 6),
								  (11, 1),
								  (1, 5),
								  (2, 9),
								  (7, 11),
								  (5, 12),
								  (9, 1),
								  (1, 8),
								  (1, 4);


SELECT p.id_journal, count(*) as NumOfPublications FROM Articles as p WHERE p.year >= 2009 and p.year <= 2010 GROUP BY p.id_journal;