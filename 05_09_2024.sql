-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.28-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for 09_09_2024
CREATE DATABASE IF NOT EXISTS `09_09_2024` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `09_09_2024`;

-- Dumping structure for function 09_09_2024.fun_check_person
DELIMITER //
CREATE FUNCTION `fun_check_person`(`name` VARCHAR(50),
	`fname` VARCHAR(50)
) RETURNS varchar(11) CHARSET utf8 COLLATE utf8_unicode_ci
BEGIN
	RETURN (SELECT if (EXISTS (SELECT * FROM fun_person o WHERE o.name = NAME  AND o.fname = fname), '1', '0'));
END//
DELIMITER ;

-- Dumping structure for function 09_09_2024.fun_check_user
DELIMITER //
CREATE FUNCTION `fun_check_user`(`nik` VARCHAR(50)
) RETURNS int(11)
    COMMENT 'Funkcija, kas pārbauda vai tāds lietotājs eksistē. Ja eksistē, tad atgriež id!'
BEGIN
	RETURN (SELECT if (EXISTS (SELECT name FROM fun_users o WHERE o.name = nik), '1', '0'));
END//
DELIMITER ;

-- Dumping structure for procedure 09_09_2024.fun_create_person
DELIMITER //
CREATE PROCEDURE `fun_create_person`(
	IN `name` TEXT,
	IN `fname` TEXT
)
BEGIN
DECLARE personexists INT; 
SET personexists = (SELECT `fun_check_person`(name, fname));
if personexists = 0 then
 INSERT INTO fun_person (name, fname) VALUES (name, fname);
 END if;
ENd//
DELIMITER ;

-- Dumping structure for procedure 09_09_2024.fun_create_user
DELIMITER //
CREATE PROCEDURE `fun_create_user`(
	IN `nik` VARCHAR(50),
	IN `pasw` VARCHAR(50),
	IN `name` VARCHAR(50),
	IN `fname` VARCHAR(50)
)
BEGIN
DECLARE userexists INT; 
DECLARE person INT;
SET person = (SELECT o.id FROM fun_person o WHERE o.name = NAME AND o.fname = fname); #dod person id uz user id

SET userexists = (SELECT `fun_check_user`(nik)); #paskatas vai user jau eksiste

if userexists = 0 then
INSERT INTO fun_users (person_id, NAME, password) VALUES (person, nik, pasw);#atlauj vai aizlied izveidod user
END if;
END//
DELIMITER ;

-- Dumping structure for function 09_09_2024.fun_data
DELIMITER //
CREATE FUNCTION `fun_data`(`id` INT
) RETURNS datetime
    COMMENT 'skata vai lietotājam ir vēl ļauts darboties. Ja ir, tad dod laiku, kas ir patreizējais+5 min'
BEGIN
	#DECLARE usertime DATETIME;
 	#SET usertime = (ADDTIME(NOW(), "0:5"));
 	#INSERT INTO fun_login (user_id, time) values (id, usertime);
 	RETURN (ADDTIME(NOW(), "0:5"));
END//
DELIMITER ;

-- Dumping structure for table 09_09_2024.fun_login
CREATE TABLE IF NOT EXISTS `fun_login` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Login ID',
  `user_id` int(10) unsigned NOT NULL COMMENT 'User id',
  `time` datetime NOT NULL COMMENT 'Time to work',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `FK_fun_login_fun_users` FOREIGN KEY (`user_id`) REFERENCES `fun_users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Pieteikšanās tabula\r\ntime- laiks līdz kuram konts aktīvs';

-- Dumping data for table 09_09_2024.fun_login: ~2 rows (approximately)
INSERT INTO `fun_login` (`id`, `user_id`, `time`) VALUES
	(1, 1, '2024-09-18 14:44:42'),
	(2, 2, '2024-09-18 14:44:31');

-- Dumping structure for table 09_09_2024.fun_person
CREATE TABLE IF NOT EXISTS `fun_person` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Person ID',
  `name` varchar(50) NOT NULL COMMENT 'Personas name',
  `fname` varchar(50) NOT NULL COMMENT 'Person fname',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Personu DB';

-- Dumping data for table 09_09_2024.fun_person: ~2 rows (approximately)
INSERT INTO `fun_person` (`id`, `name`, `fname`) VALUES
	(1, 'ralfs', 'cvikl'),
	(2, 'karl', 'grin');

-- Dumping structure for table 09_09_2024.fun_users
CREATE TABLE IF NOT EXISTS `fun_users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'User ID',
  `person_id` int(10) unsigned NOT NULL COMMENT 'Person ID',
  `name` varchar(20) NOT NULL COMMENT 'User name',
  `password` varchar(20) NOT NULL COMMENT 'User password',
  PRIMARY KEY (`id`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `FK_fun_users_fun_person` FOREIGN KEY (`person_id`) REFERENCES `fun_person` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Lietotāju tabula';

-- Dumping data for table 09_09_2024.fun_users: ~2 rows (approximately)
INSERT INTO `fun_users` (`id`, `person_id`, `name`, `password`) VALUES
	(1, 1, 'rally', '123'),
	(2, 2, 'karlito', '1234');

-- Dumping structure for function 09_09_2024.login
DELIMITER //
CREATE FUNCTION `login`(`nik` VARCHAR(50),
	`pasword` VARCHAR(50)
) RETURNS varchar(11) CHARSET utf8 COLLATE utf8_unicode_ci
    DETERMINISTIC
    COMMENT 'Piesakās sistēmā!'
BEGIN
	#izmanto fun_data()
	DECLARE user_id INT;
	DECLARE userexists INT; 
	DECLARE pasword_correct varchar(20);
	DECLARE usertime DATETIME;
	DECLARE is_loged INT;
	
	SET userexists = (SELECT `fun_check_user`(nik));
	set user_id = (SELECT o.person_id FROM fun_users o WHERE o.name = nik);
	SET pasword_correct = (SELECT o.password from fun_users o where o.name = nik);
	SET usertime = (SELECT `fun_data`(1));
	SET is_loged = (SELECT if (EXISTS (SELECT o.user_id FROM fun_login o WHERE o.user_id = user_id), '1', '0'));
	
	if userexists = 1 AND pasword_correct = pasword AND is_loged = 0 then 
	INSERT INTO fun_login (user_id, time) values (user_id, usertime); 
	RETURN "loged in";
	ELSE 
	UPDATE fun_login o SET TIME = usertime WHERE o.user_id = user_id;
	RETURN "loged again";
	END if;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
