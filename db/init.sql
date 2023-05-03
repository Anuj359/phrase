CREATE USER 'appadmin'@'%' IDENTIFIED BY 'appadminpass';
GRANT ALL PRIVILEGES ON *.* TO 'appadmin'@'%' WITH GRANT OPTION;

CREATE USER 'developer'@'%' IDENTIFIED BY 'developerpass';
GRANT SELECT ON *.* TO 'developer'@'%';

USE mydb;

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `users` (`name`, `email`) VALUES
('John Doe', 'john@example.com'),
('Jane Doe', 'jane@example.com');
