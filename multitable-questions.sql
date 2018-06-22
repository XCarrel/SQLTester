USE SQLTester;

--
-- Table structure for table queries
--

DROP TABLE IF EXISTS queries;
CREATE TABLE queries (
  idqueries int(11) NOT NULL AUTO_INCREMENT,
  statement varchar(5000) NOT NULL,
  formulation varchar(5000) DEFAULT NULL,
  questionnumber int(11) DEFAULT NULL,
  PRIMARY KEY (idqueries)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

--
-- Dumping data for table queries
--

INSERT INTO `queries` (`statement`, `formulation`, `questionnumber`)
VALUES
	('Select count(id) as nbteams from teams','Combien y a-t-il d\'équipes ?',1),
	('Select count(id)*2 - (select count(id) from participants) as nb from teams','Quelle est la différence entre le nombre de personnes que l\'on devrait avoir (nombre d\'équipes * 2) et le nombre de personne que l\'on a vraiment ?',2),
	('select name from teams LEFT JOIN participant_team ON team_id = teams.id WHERE participant_id IS NULL','Quelles sont les équipes qui n\'ont aucun membre ?',3),
	('SELECT name, count(participant_team.id) as nb from teams INNER JOIN participant_team ON team_id=teams.id INNER JOIN participants ON participant_id=participants.id GROUP BY name HAVING nb <> 2','Quelles sont les équipes qui ont un nombre de membres incorrect (i.e: différent de 2) ?',4),
	('select teams.name FROM pools INNER JOIN contenders ON pool_id = pools.id INNER JOIN teams ON team_id = teams.id WHERE poolName = \'C\'','Quelles sont les équipes inscrites dans la poule \'C\' ?',5),
	('select count(games.id) as nbgames from games INNER JOIN contenders ON contender1_id=contenders.id INNER JOIN pools ON pool_id = pools.id WHERE poolName = \'A\'','Combien y a-t-il de matches dans la poule \'A\' ?',6),
	('select count(games.id) from games INNER JOIN contenders ON contender1_id=contenders.id INNER JOIN pools ON pool_id = pools.id WHERE poolName = \'A\' AND (score_contender1 = 15 OR score_contender2 = 15)\n','Combien y a-t-il de matches terminés (un des deux scores est à 15) dans la poule \'A\' ?',7),
	('SELECT teams.name, opponent.name\nFROM teams INNER JOIN contenders ON team_id=teams.id\n  INNER JOIN games ON contender1_id=contenders.id\n  INNER JOIN teams as opponent ON contender2_id=opponent.id\n  INNER JOIN pools ON pool_id=pools.id\nWHERE teams.id = 11\nUNION\nSELECT teams.name, opponent.name\nFROM teams INNER JOIN contenders ON team_id=teams.id\n  INNER JOIN games ON contender2_id=contenders.id\n  INNER JOIN teams as opponent ON contender1_id=opponent.id\n  INNER JOIN pools ON pool_id=pools.id\nWHERE teams.id = 11','Lister tous les adversaires de l\'équipe dont l\'id est 11',9),
	('SELECT stage, poolName, count(contenders.id) FROM pools INNER JOIN contenders ON pool_id=pools.id GROUP BY poolName ORDER BY stage ','Lister les poules par phase (stage) en indiquant le nombre de participants inscrits',8),
	('SELECT stage, poolName, poolSize, count(contenders.id) as nbcontenders FROM pools INNER JOIN contenders ON pool_id=pools.id GROUP BY poolName HAVING nbcontenders <> pools.poolSize ORDER BY stage','Lister les poules dont le nombre de participants est incorrect',10);

--
-- Table structure for table users
--

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  idusers int(11) NOT NULL AUTO_INCREMENT,
  firstname varchar(45) NOT NULL,
  lastname varchar(45) NOT NULL,
  intranetid int(11) NOT NULL COMMENT 'intranet user id\n',
  PRIMARY KEY (idusers)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;

--
-- Table structure for table results
--

DROP TABLE IF EXISTS results;
CREATE TABLE results (
  idresults int(11) NOT NULL AUTO_INCREMENT,
  fkuser int(11) NOT NULL,
  fkqueries int(11) NOT NULL,
  nbattempts int(11) NOT NULL DEFAULT '0' COMMENT 'Number of wrong answers until success',
  success int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (idresults),
  UNIQUE KEY uniqueanswer (fkuser,fkqueries),
  KEY resus_idx (fkuser),
  KEY resreq_idx (fkqueries),
  CONSTRAINT resreq FOREIGN KEY (fkqueries) REFERENCES queries (idqueries) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT resus FOREIGN KEY (fkuser) REFERENCES users (idusers) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=587 DEFAULT CHARSET=utf8;

INSERT INTO users (lastname, firstname, intranetid)
VALUES
('APOTHELOZ','Yann',2274),
('BARDI','Sadam',6484),
('BERGMANN','Florian',1167),
('CRISANTE','Jason',3951),
('DOS-SANTOS-MATIAS','Joel',4935),
('GAILLARD','Maxime',1016),
('GERMANN','Niels',1470),
('GRANDJEAN','Sebastien',4924),
('JOST','Anthony',5153),
('MAITRE','Nicolas',8110),
('PASTEUR','Kevin',3157),
('PHILIBERT','Alexandre',9484),
('RUCHAT','Roman',7563),
('SANCHEZ','Diego',5351),
('TISSOT','Olivier',5187);

