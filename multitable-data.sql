DROP DATABASE IF EXISTS SQLTester;

CREATE DATABASE SQLTester /*!40100 DEFAULT CHARACTER SET utf8 */;
USE SQLTester;
-- MySQL dump 10.13  Distrib 5.6.19, for osx10.7 (i386)
--
-- Host: 127.0.0.1    Database: SQLTester
-- ------------------------------------------------------
-- Server version	5.6.33

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- -----------------------------------------------------
-- Table participants
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS participants (
  id INT NOT NULL AUTO_INCREMENT COMMENT 'Same as intranet user id, this explains why it isn\'t AI.',
  first_name VARCHAR(45) NOT NULL COMMENT 'Participant first name',
  last_name VARCHAR(45) NOT NULL COMMENT 'Participant last name',
  PRIMARY KEY (id))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table events
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS events (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(105) NOT NULL,
  PRIMARY KEY (id))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table sports
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS sports (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NOT NULL COMMENT 'Name of the sport',
  description VARCHAR(45) NULL,
  PRIMARY KEY (id))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table tournaments
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS tournaments (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NOT NULL COMMENT 'Name of the tournament',
  start_date DATETIME NOT NULL COMMENT 'Date at which the tournament starts',
  event_id INT NOT NULL,
  sport_id INT NOT NULL,
  PRIMARY KEY (id),
  INDEX fk_tournaments_events1_idx (event_id ASC),
  INDEX fk_tournaments_sports1_idx (sport_id ASC),
  CONSTRAINT fk_tournaments_events1
    FOREIGN KEY (event_id)
    REFERENCES events (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_tournaments_sports1
    FOREIGN KEY (sport_id)
    REFERENCES sports (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table courts
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS courts (
  id INT NOT NULL AUTO_INCREMENT,
  sport_id INT NOT NULL,
  name VARCHAR(20) NOT NULL COMMENT 'Name of the court (e.g. : Court A)',
  PRIMARY KEY (id),
  INDEX fk_terrains_sports1_idx (sport_id ASC),
  CONSTRAINT fk_terrains_sports1
    FOREIGN KEY (sport_id)
    REFERENCES sports (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table teams
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS teams (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NOT NULL COMMENT 'Team name',
  tournament_id INT NOT NULL,
  PRIMARY KEY (id),
  INDEX team_tournament_idx (tournament_id ASC),
  CONSTRAINT team_tournament
    FOREIGN KEY (tournament_id)
    REFERENCES tournaments (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table gameTypes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS gameTypes (
  id INT NOT NULL AUTO_INCREMENT,
  gameTypeDescription VARCHAR(500) NOT NULL,
  PRIMARY KEY (id))
ENGINE = InnoDB
COMMENT = 'This table contains the descriptions of how the games are played: number of sets, points per set, on the clock, whatever…\nDescription is free, but it must be linked to a sport.';


-- -----------------------------------------------------
-- Table poolModes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS poolModes (
  id INT NOT NULL AUTO_INCREMENT,
  modeDescription VARCHAR(1000) NOT NULL,
  planningAlgorithm INT NOT NULL COMMENT 'Allows the application to differentiate the way to schedule games without relying on the textual description',
  PRIMARY KEY (id))
ENGINE = InnoDB
COMMENT = 'Indicates how the pool is run:\nSingleGames -> each contender plays against all other contenders once\nReturnGames -> each contender plays against all other contenders twice\nElimination -> each contender plays against one other contender only\n';


-- -----------------------------------------------------
-- Table pools
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pools (
  id INT NOT NULL AUTO_INCREMENT,
  tournament_id INT NOT NULL,
  start_time TIME NULL,
  end_time TIME NULL,
  poolName VARCHAR(45) NOT NULL COMMENT 'Pool name for display (e.g. : « Poule A », or « Poule de classement »)',
  mode_id INT NOT NULL,
  stage INT NOT NULL DEFAULT 1 COMMENT 'Indicates when the pools takes place in the tournament. All pools of one stage must be completed before a pool of the next stage can start.',
  gameType_id INT NOT NULL,
  poolSize INT NOT NULL COMMENT 'Number of teams in the pool',
  PRIMARY KEY (id),
  INDEX fk_poules_tournois1_idx (tournament_id ASC),
  INDEX fkgametype_idx (gameType_id ASC),
  INDEX fkmode_idx (mode_id ASC),
  CONSTRAINT fk_poules_tournois1
    FOREIGN KEY (tournament_id)
    REFERENCES tournaments (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fkgametype
    FOREIGN KEY (gameType_id)
    REFERENCES gameTypes (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fkmode
    FOREIGN KEY (mode_id)
    REFERENCES poolModes (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table participant_team
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS participant_team (
  id INT NOT NULL AUTO_INCREMENT,
  participant_id INT NOT NULL,
  team_id INT NOT NULL,
  isCaptain TINYINT(1) NOT NULL DEFAULT 0,
  INDEX fk_participants_has_equipes_equipes1_idx (team_id ASC),
  INDEX fk_participants_has_equipes_participants_idx (participant_id ASC),
  PRIMARY KEY (id),
  INDEX nodouble (participant_id ASC, team_id ASC),
  CONSTRAINT fk_participants_has_equipes_participants
    FOREIGN KEY (participant_id)
    REFERENCES participants (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_participants_has_equipes_equipes1
    FOREIGN KEY (team_id)
    REFERENCES teams (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table contenders
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS contenders (
  id INT NOT NULL AUTO_INCREMENT,
  pool_id INT NOT NULL,
  team_id INT NULL COMMENT 'A designated team. It can be NULL because the participant in the pool may be unknown initially: it can be the Nth team in the ranking of a previous pool.',
  rank_in_pool INT NULL COMMENT 'If fk_from_pool is defined, this field says which rank must be taken.',
  pool_from_id INT NULL COMMENT 'If the participant comes from a pool, this field says from which. It can be NULL because it can be an explicit team.',
  PRIMARY KEY (id),
  INDEX fk_pools_idx (pool_id ASC),
  INDEX fk_pools_has_explicit_teams_idx (team_id ASC),
  INDEX fk_pools_has_implicit_teams_idx (pool_from_id ASC),
  CONSTRAINT fk_pools
    FOREIGN KEY (pool_id)
    REFERENCES pools (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_pools_has_explicit_teams
    FOREIGN KEY (team_id)
    REFERENCES teams (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_pools_has_implicit_teams
    FOREIGN KEY (pool_from_id)
    REFERENCES pools (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table games
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS games (
  id INT NOT NULL AUTO_INCREMENT,
  contender1_id INT NOT NULL,
  contender2_id INT NOT NULL,
  score_contender1 INT NULL COMMENT 'Score that the first team did',
  score_contender2 INT NULL COMMENT 'Score that the second team did',
  date DATE NOT NULL COMMENT 'Date at which the game will be played',
  start_time TIME NOT NULL COMMENT 'Time at which the game starts',
  court_id INT NOT NULL,
  PRIMARY KEY (id),
  INDEX fk_games_courts1_idx (court_id ASC),
  INDEX fk_contender1_idx (contender2_id ASC),
  CONSTRAINT fk_games_courts1
    FOREIGN KEY (court_id)
    REFERENCES courts (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_contender1
    FOREIGN KEY (contender2_id)
    REFERENCES contenders (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_contender2
    FOREIGN KEY (contender2_id)
    REFERENCES contenders (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Intermediate table between teams and pools. This allows to set the information about the different games of a tournament.';


-- -----------------------------------------------------
-- Table users
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id INT NOT NULL AUTO_INCREMENT,
  username VARCHAR(45) NOT NULL,
  password VARCHAR(255) NOT NULL,
  PRIMARY KEY (id))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- ========================================== Data ==============================================

--
--  Insert Data in events
--

INSERT INTO events(name) VALUES ('2017');

--
--  Insert Data in sports
--

INSERT INTO sports(name, description) VALUES ('Badminton', 'En double');

--
--  Insert Data in courts
--

INSERT INTO courts(name, sport_id) VALUES ('Terrain A', 1),('Terrain B', 1),('Terrain C', 1),('Terrain D', 1);

--
--  Insert Data in tournaments
--

INSERT INTO tournaments(name, start_date, event_id, sport_id) VALUES ('Tournoi de Bad', '2017-06-11', 1, 1);

--
--  Insert Data in gameTypes
--

INSERT INTO gameTypes(gameTypeDescription) values ('Modalités de jeu');

--
--  Insert Data in poolModes
--

INSERT INTO poolModes(modeDescription,planningAlgorithm) values ('Matches simples',1),('Aller-retour',2),('Elimination directe',3);

--
--  Insert Data in participants
--

INSERT INTO participants(first_name,last_name) VALUES ("Ahmed","Casey"),("Chester","Day"),("Riley","Garrison"),("Duncan","Roy"),("Remedios","Black"),("Mark","Molina"),("Dana","Justice"),("Linus","Leon"),("Cairo","Farmer"),("Nyssa","Gallagher");
INSERT INTO participants(first_name,last_name) VALUES ("Allegra","Waller"),("Emery","Copeland"),("Illana","Mcgowan"),("Magee","Bauer"),("Patricia","Briggs"),("Samuel","Meyers"),("Nelle","Holcomb"),("Shay","David"),("Kai","Quinn"),("Brendan","Macdonald");
INSERT INTO participants(first_name,last_name) VALUES ("Justin","Jones"),("Erich","Shepherd"),("Joseph","Compton"),("Moses","Pope"),("Hedley","Thornton"),("Deborah","Wells"),("Kay","Ortega"),("Dorothy","Johnston"),("Irene","Alston"),("Doris","Baird");
INSERT INTO participants(first_name,last_name) VALUES ("Zorita","Ellis"),("Yen","Hale"),("Madison","Marshall"),("Angela","Perry"),("Michael","Woodard"),("Karyn","Riddle"),("Carol","Lang"),("Malik","Padilla"),("Maxine","Rowland"),("Halee","Larson");
INSERT INTO participants(first_name,last_name) VALUES ("Tatyana","Rosario"),("Latifah","Jenkins"),("Wynne","Rowland"),("Nola","Adkins"),("Nicole","Wilkerson"),("Sybil","Murray"),("Cadman","Evans"),("Xenos","Kramer"),("Illana","Riley"),("Evan","Logan");
INSERT INTO participants(first_name,last_name) VALUES ("Risa","Fuller"),("Jenette","Alvarado"),("Colorado","Moss"),("Bree","Velazquez"),("Madonna","Preston"),("Daria","Pearson"),("Uta","Hensley"),("Paul","Lambert"),("Declan","Ramirez"),("Davis","Mcleod");
INSERT INTO participants(first_name,last_name) VALUES ("Wanda","Sears"),("Melvin","Bowen"),("Lareina","Forbes"),("Dane","Holland"),("Norman","Mcleod"),("Blythe","Cruz"),("Jayme","Gill"),("Adele","Warren"),("Candace","Valenzuela"),("Judith","Blake");

--
--  Insert Data in teams
--

INSERT INTO teams(name,tournament_id) VALUES ('Badboys',1);
INSERT INTO teams(name,tournament_id) VALUES ('Super Nanas',1);
INSERT INTO teams(name,tournament_id) VALUES ('CPVN Crew',1);
INSERT INTO teams(name,tournament_id) VALUES ('Magical Girls',1);
INSERT INTO teams(name,tournament_id) VALUES ('OliverTwist',1);
INSERT INTO teams(name,tournament_id) VALUES ('Scarman',1);
INSERT INTO teams(name,tournament_id) VALUES ('Siomer',1);
INSERT INTO teams(name,tournament_id) VALUES ('Salsadi',1);
INSERT INTO teams(name,tournament_id) VALUES ('Monoster',1);
INSERT INTO teams(name,tournament_id) VALUES ('Picalo',1);
INSERT INTO teams(name,tournament_id) VALUES ('Dellit',1);
INSERT INTO teams(name,tournament_id) VALUES ('SuperStar',1);
INSERT INTO teams(name,tournament_id) VALUES ('Masting',1);
INSERT INTO teams(name,tournament_id) VALUES ('Clafier',1);
INSERT INTO teams(name,tournament_id) VALUES ('Robert2Poche',1);
INSERT INTO teams(name,tournament_id) VALUES ('Alexandri',1);
INSERT INTO teams(name,tournament_id) VALUES ('FanGirls',1);
INSERT INTO teams(name,tournament_id) VALUES ('Les Otakus',1);
INSERT INTO teams(name,tournament_id) VALUES ('Gamers',1);
INSERT INTO teams(name,tournament_id) VALUES ('Over2000',1);
INSERT INTO teams(name,tournament_id) VALUES ('Shinigami',1);
INSERT INTO teams(name,tournament_id) VALUES ('Rocketteurs',1);
INSERT INTO teams(name,tournament_id) VALUES ('Gilles & 2Sot-Vetage',1);
INSERT INTO teams(name,tournament_id) VALUES ('Maya Labeille',1);
INSERT INTO teams(name,tournament_id) VALUES ('Taupes ModL',1);
INSERT INTO teams(name,tournament_id) VALUES ('Les Pausés',1);
INSERT INTO teams(name,tournament_id) VALUES ('Absolute Frost',1);
INSERT INTO teams(name,tournament_id) VALUES ('Dark Side',1);
INSERT INTO teams(name,tournament_id) VALUES ('Btooom',1);
INSERT INTO teams(name,tournament_id) VALUES ('Stalgia',1);
INSERT INTO teams(name,tournament_id) VALUES ('Clattonia',1);
INSERT INTO teams(name,tournament_id) VALUES ('Danrell',1);
INSERT INTO teams(name,tournament_id) VALUES ('RunAGround',1);
INSERT INTO teams(name,tournament_id) VALUES ('Believer',1);

--
--  Insert Data in participant_team
--

INSERT INTO participant_team(participant_id, team_id, isCaptain) select id, ROUND(id/2), (id%2) from participants limit 64;
UPDATE participant_team SET team_id=14 WHERE id=29; -- create a mistake
DELETE from participant_team WHERE id=36; -- and another

--
--  Insert Data in contenders
--

-- ================= stage 1 =====================

-- pools id 1-8
INSERT INTO pools (tournament_id, start_time, end_time, poolName, mode_id, gameType_id, poolSize, stage)
VALUES
  (1, '08:00', '10:00', 'A', 1, 1, 4, 1), (1, '08:00', '10:00', 'B', 1, 1, 4, 1),
  (1, '08:00', '10:00', 'C', 1, 1, 4, 1), (1, '08:00', '10:00', 'D', 1, 1, 4, 1),
  (1, '08:00', '10:00', 'E', 1, 1, 4, 1), (1, '08:00', '10:00', 'F', 1, 1, 4, 1),
  (1, '08:00', '10:00', 'G', 1, 1, 4, 1), (1, '08:00', '10:00', 'H', 1, 1, 4, 1);

-- contenders are automatic: teams 1-4 -> pool 1, teams 5-8 -> pool 2, thus team X -> pool floor((X+3)/4)
INSERT INTO contenders(pool_id,team_id) select floor((id+3)/4),id FROM teams limit 32;

-- ================= stage 2 =====================

-- pools id 9-16
INSERT INTO pools (tournament_id, start_time, end_time, poolName, mode_id, gameType_id, poolSize, stage)
VALUES
  (1, '10:00', '12:00', 'Win1', 1, 1, 4, 2), (1, '10:00', '12:00', 'Win2', 1, 1, 4, 2),
  (1, '10:00', '12:00', 'Win3', 1, 1, 4, 2), (1, '10:00', '12:00', 'Win4', 1, 1, 4, 2),
  (1, '10:00', '12:00', 'Fun1', 1, 1, 4, 2), (1, '10:00', '12:00', 'Fun2', 1, 1, 4, 2),
  (1, '10:00', '12:00', 'Fun3', 1, 1, 4, 2), (1, '10:00', '12:00', 'Fun4', 1, 1, 4, 2);

INSERT INTO contenders (pool_id, rank_in_pool, pool_from_id)
VALUES
  (9, 1, 1),
  (9, 2, 1),
  (9, 1, 2),
  (9, 2, 2),
  (10, 1, 3),
  (10, 2, 3),
  (10, 1, 4),
  (10, 2, 4),
  (11, 1, 5),
  (11, 2, 5),
  (11, 1, 6),
  (11, 2, 6),
  (12, 1, 7),
  (12, 2, 7),
  (12, 1, 8),
  (12, 2, 8),
  (13, 3, 1),
  (13, 4, 1),
  (13, 3, 2),
  (13, 4, 2),
  (14, 3, 3),
  (14, 4, 3),
  (14, 3, 4),
  (14, 4, 4),
  (15, 3, 5),
  (15, 4, 5),
  (15, 3, 6),
  (15, 4, 6),
  (16, 3, 7),
  (16, 4, 7),
  (16, 3, 8),
  (16, 4, 8);

-- ================= stage 3 =====================

-- pools id 17-20
INSERT INTO pools (tournament_id, start_time, end_time, poolName, mode_id, gameType_id, poolSize, stage)
VALUES
  (1, '13:30', '15:30', 'Best 1', 1, 1, 4, 3), (1, '13:30', '15:30', 'Best 2', 1, 1, 4, 3),
  (1, '13:30', '15:30', 'Good 1', 1, 1, 4, 3), (1, '13:30', '15:30', 'Good 2', 1, 1, 4, 3);

INSERT INTO contenders (pool_id, rank_in_pool, pool_from_id)
VALUES
  (17, 1, 9),
  (17, 2, 9),
  (17, 1, 10),
  (17, 2, 10),
  (18, 1, 11),
  (18, 2, 11),
  (18, 1, 12),
  (18, 2, 12),
  (19, 3, 13),
  (19, 4, 13),
  (19, 3, 14),
  (19, 4, 14),
  (20, 3, 15),
  (20, 4, 15),
  (20, 3, 16),
  (20, 4, 16);

-- ================= stage 4 (finals) =====================

-- pools id 21-24
INSERT INTO pools (tournament_id, start_time, end_time, poolName, mode_id, gameType_id, poolSize, stage)
VALUES
  (1, '15:30', '16:30', 'Finale 1-2', 1, 1, 2, 4), (1, '15:30', '16:30', 'Finale 3-4', 1, 1, 2, 4),
  (1, '15:30', '16:30', 'Finale 5-6', 1, 1, 2, 4), (1, '15:30', '16:30', 'Finale 7-8', 1, 1, 2, 4);

INSERT INTO contenders (pool_id, rank_in_pool, pool_from_id)
VALUES
  (21, 1, 17),
  (21, 1, 17),
  (22, 2, 18),
  (22, 2, 18),
  (23, 3, 19),
  (23, 3, 19),
  (24, 4, 20),
  (24, 4, 20);

DELIMITER $$
-- XCL, 4.3.2107
-- A procedure that generates single games within a pool. !! Assumes the contender ids of the pool are contiguous !!
CREATE PROCEDURE generateGames(IN poolid INT)
BEGIN
  DECLARE c1 INT DEFAULT (SELECT id FROM contenders WHERE pool_id=poolid LIMIT 1);
  DECLARE c2 INT;
  DECLARE psize INT DEFAULT (SELECT poolSize FROM pools WHERE id=poolid);
  DECLARE pstart TIME DEFAULT (SELECT pools.start_time FROM pools WHERE id=poolid); -- pool start time
  DECLARE i,j,s1,s2 INT DEFAULT 0;
  DECLARE deltat INT;
  DECLARE gamestart TIME;
  WHILE i < psize-1 DO
    SET j=i+1;
    WHILE j < psize DO
      SET deltat = 15*(i+j-1); -- Assume 15 minutes per game
      SET gamestart = addtime(pstart,maketime(deltat DIV 60, deltat MOD 60, 0));
      IF gamestart < maketime(10,30,0) THEN -- generate a fake result
		IF rand() > 0.5 then -- contender 1 wins
			BEGIN
			  SET s1 = 15;
			  SET s2 = floor(5+8*rand());
			END;
		ELSE -- contender 2 wins
			BEGIN
			  SET s2 = 15;
			  SET s1 = floor(5+8*rand());
			END;
		END IF;
      ELSE
		  BEGIN
			  SET s1 = NULL;
			  SET s2 = NULL;
		  END;
	  END IF;
      INSERT INTO games (contender1_id, contender2_id, date, start_time, court_id, score_contender1, score_contender2) VALUES (c1+i,c1+j,(SELECT start_date FROM pools INNER JOIN tournaments ON tournament_id = tournaments.id WHERE pools.id=poolid),gamestart,1,s1,s2);
      SET j = j + 1;
    END WHILE;
    SET i = i + 1;
  END WHILE;
END;
$$

DELIMITER $$
-- XCL, 4.3.2107
-- A procedure that generates all games !! Assumes the pool ids start at 1 and are contiguous !!
CREATE PROCEDURE generateAllGames()
BEGIN
  DECLARE n INT DEFAULT (SELECT count(id) FROM pools);
  DECLARE i INT DEFAULT 1;
  WHILE i <= n DO
    CALL generateGames(i);
    SET i = i + 1;
  END WHILE;
END;
$$
DELIMITER ;

CALL generateAllGames();

DROP PROCEDURE generateGames; -- cleanup
DROP PROCEDURE generateAllGames; -- cleanup
