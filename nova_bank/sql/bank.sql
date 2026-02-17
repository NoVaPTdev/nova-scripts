CREATE TABLE IF NOT EXISTS `nova_transactions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `type` VARCHAR(20) NOT NULL COMMENT 'deposit, withdraw, transfer_in, transfer_out',
    `amount` INT NOT NULL,
    `target_citizenid` VARCHAR(50) DEFAULT NULL,
    `description` VARCHAR(255) DEFAULT '',
    `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
