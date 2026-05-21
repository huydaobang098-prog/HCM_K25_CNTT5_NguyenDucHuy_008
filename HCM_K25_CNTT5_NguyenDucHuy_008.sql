-- TẠO DATABASE
CREATE  DATABASE final_db;
USE final_db;
-- XÓA BẢNG ĐỂ RESET LẠI DỮ LIỆU
DROP TABLE IF EXISTS player_statistics;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS coaches;
DROP TABLE IF EXISTS teams;

-- TẠO BẢNG 
CREATE TABLE teams (
	team_id INT PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    founded_year YEAR NOT NULL,
    stadium VARCHAR(100) NOT NULL,
    ranking_position INT DEFAULT 0
);

CREATE TABLE coaches (
	coach_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    experience_years INT DEFAULT 0,
    team_id INT,
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE players (
	player_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    jersey_number INT NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(12,2) NOT NULL,
    team_id INT,
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE matches (
	match_id INT PRIMARY KEY AUTO_INCREMENT,
    home_team_id INT,
    away_team_id INT,
    match_date DATETIME NOT NULL,
    stadium VARCHAR(100) NOT NULL,
    match_status VARCHAR(30) DEFAULT 'Scheduled',
    FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
    FOREIGN KEY (away_team_id) REFERENCES teams(team_id),
    win_team_id INT REFERENCES matches(home_team_id)
);

CREATE TABLE player_statistics (
	stat_id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT,
    match_id INT,
    goals INT DEFAULT 0,
    assists INT DEFAULT 0,
    yellow_cards INT DEFAULT 0,
    rating_score DECIMAL(3,1) DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (match_id) REFERENCES matches(match_id)
);

-- THÊM DỮ LIỆU VÀO BẢNG
INSERT INTO teams(team_id, team_name, founded_year, stadium, ranking_position)
VALUES 
(1, 'Manchester City', '1901', 'Etihad Stadium', 1),
(2, 'Real Madrid', '1902', 'Santiago Bernabeu', 2),
(3, 'Hanoi FC', '2006', 'Hang Day Stadium', 3),
(4, 'Saigon United', '2015', 'Thong Nhat Stadium', 5),
(5, 'Thép Xanh Nam Định', '1979', 'Thien Duong Stadium', 10);

INSERT INTO coaches(coach_id, full_name, nationality, experience_years, team_id)
VALUES 
(1, 'Pep Guardiola', 'Spanish', 15, 1),
(2, 'Carlo Ancelotti', 'Italian', 25, 2),
(3, 'Chu Đình Nghiêm', 'Vietnamese', 12, 3),
(4, 'Alexandre Polking', 'German-Brazilian', 10, 5),
(5,'Park Han-seo', 'Korean', 30, 5);

INSERT INTO players(player_id, full_name, jersey_number, position, salary, team_id)
VALUES
(1, 'Erling Haaland', 9, 'Forward', 450000000, 1),
(2, 'Kevin De bruyne', 17, 'Midfielder', 400000000, 1),
(3, 'Nguyễn Quang Hải', 19, 'Midfielder', 60000000, 3),
(4, 'Kylian Mbappe', 7, 'Forward', 500000000, 2),
(5, 'Nguyễn Văn Quyết', 10, 'Forward', 55000000, 3);
 
INSERT INTO matches(match_id, home_team_id, away_team_id, match_date, stadium, match_status, win_team_id)
VALUES 
(1 , 1, 2, '2026-05-10 19:00', 'Etihad Stadium', 'Finished', 0),
(2 , 3, 4, '2026-05-12 18:30', 'Hang Day Stadium', 'Finished', 1),
(3 , 5, 1, '2026-05-15 20:00', 'Thien Duong Stadium', 'Scheduled', 1),
(4 , 2, 3, '2026-05-20 21:00', 'Santiago Bernabeu', 'Scheduled', 0),
(5 , 4, 5, '2026-05-25 17:00', 'Thong Nhat Stadium', 'Scheduled', 1);

INSERT INTO player_statistics(stat_id, player_id, match_id, goals, assists, yellow_cards, rating_score)
VALUES 
(1, 1, 1, 2, 1, 0, 9.5),
(2, 4, 1, 1, 0, 1, 8.2),
(3, 3, 2, 0, 2, 0, 8.5),
(4, 5, 2, 3, 0, 0, 9.0),
(5, 1, 4, 0, 0, 3, 5.0);

-- PHẦN 2 CÂU 1
SET SQL_SAFE_UPDATES = 0;

UPDATE players p
JOIN player_statistics ps
ON p.player_id = ps.player_id
SET salary = salary * 1.15
WHERE position = 'Forward' AND rating_score > 8.0;

-- PHẦN 2 CÂU 2
DELETE FROM player_statistics
WHERE yellow_cards > 2;

-- PHẦN 3 CÂU 1
SELECT full_name, jersey_number, position
FROM players
WHERE salary > 50000000 OR position = 'Midfielder';

-- PHẦN 3 CÂU 2
SELECT team_name, stadium
FROM teams
WHERE (ranking_position BETWEEN 1 AND 5) AND stadium LIKE 'S%';

-- PHẦN 3 CÂU 3
SELECT match_id, stadium, match_date
FROM matches
ORDER BY match_date DESC LIMIT 3 OFFSET 3;

-- PHẦN 4 CÂU 1
SELECT p.full_name, t.team_name, ps.goals, ps.assists
FROM players p
JOIN player_statistics ps
ON p.player_id = ps.player_id
JOIN teams t
ON t.team_id = p.team_id;

-- PHẦN 4 CÂU 2
SELECT t.team_name, SUM(ps.goals) AS total_goals
FROM teams t
JOIN players p
ON p.team_id = t.team_id
JOIN player_statistics ps
ON p.player_id = ps.player_id
GROUP BY t.team_name
HAVING SUM(ps.goals) > 10;

-- PHẦN 5 CÂU 1
DROP INDEX index_players ON players;

CREATE INDEX index_players
ON players(position, salary);

DROP VIEW view_text;

-- PHẦN 5 CÂU 2
CREATE VIEW view_text AS
SELECT t.team_name, count(p.player_id) AS total_players, SUM(p.salary) AS total_salary
FROM teams t
JOIN players p
ON t.team_id = p.team_id
WHERE p.salary <> 0
GROUP BY t.team_name;

-- PHẦN 6 CÂU 1
DROP TRIGGER trigger_ps;

DELIMITER //

CREATE TRIGGER trigger_ps
AFTER UPDATE 
ON player_statistics FOR EACH ROW
BEGIN
	
	IF NEW.goals > 10 THEN 
    UPDATE players
    SET salary = salary * 1.05
    WHERE player_id = NEW.player_id;
    END IF ;
END //

DELIMITER ;

-- PHẦN 6 CÂU 2

DROP TRIGGER trigger_update;

DELIMITER //

CREATE TRIGGER trigger_update
AFTER INSERT ON matches
FOR EACH ROW
BEGIN

IF NEW.win_team_id IS NOT NULL AND NEW.win_team_id <> 0 THEN	
    UPDATE teams
    SET ranking_position = ranking_position + 1
    WHERE team_id = NEW.win_team_id;
	ELSE 
    UPDATE teams
    SET ranking_position = ranking_position - 1
    WHERE team_id = NEW.win_team_id;
END IF;

END //

DELIMITER ;

-- PHẦN 7 CÂU 1
DROP PROCEDURE mess_status;

DELIMITER //

CREATE PROCEDURE mess_status(
    IN p_player_id INT,
    OUT msg VARCHAR(50)
)
BEGIN
    DECLARE v_goals INT;
    SELECT SUM(goals)
    INTO v_goals
    FROM player_statistics
    WHERE player_id = p_player_id;
    IF v_goals > 20 THEN SET msg = 'Excellent';
    ELSEIF v_goals > 10 THEN SET msg = 'Good';
    ELSE SET msg = 'Average';
    END IF;
END //
DELIMITER ;

CALL mess_status(2, @result);
SELECT @result;



