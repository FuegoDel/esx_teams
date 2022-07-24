  CREATE TABLE IF NOT EXISTS `teams` (
            `jobname` VARCHAR(32) NOT NULL,
            `owneridentifier` varchar(32) NOT NULL,
            `experience` INT(11) DEFAULT 0,
            `level` INT(11) DEFAULT 1,
            `privilages` VARCHAR(124) NOT NULL,
            PRIMARY KEY (`jobname`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
