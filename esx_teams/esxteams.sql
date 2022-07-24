  CREATE TABLE IF NOT EXISTS `teams` (
            `owneridentifier` varchar(32) NOT NULL,
            `jobname` VARCHAR(32) NOT NULL,
            `experience` INT(11) DEFAULT 0,
            `level` INT(11) DEFAULT 1,
            PRIMARY KEY (`jobname`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  CREATE TABLE IF NOT EXISTS `teamsprivilages` (
            `jobname` varchar(32) NOT NULL,
            `privilages` VARCHAR(124) NOT NULL,
            PRIMARY KEY (`jobname`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;