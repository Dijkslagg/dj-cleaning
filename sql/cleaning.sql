CREATE TABLE IF NOT EXISTS `s1450018_QBCORE.cleaning_jobs` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `job_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `payout` int(11) NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `s1450018_QBCORE.cleaning_levels` (
    `citizenid` varchar(50) NOT NULL,
    `level` int(11) NOT NULL DEFAULT 1,
    `experience` int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`citizenid`)
);