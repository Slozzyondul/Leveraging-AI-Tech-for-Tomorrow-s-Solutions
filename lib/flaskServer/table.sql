-- Create the database
CREATE DATABASE IF NOT EXISTS disaster_alerts;

-- Use the database
USE disaster_alerts;

-- Create the disasters table
CREATE TABLE disasters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(255),
    location VARCHAR(255),
    severity VARCHAR(50),
    date DATE
);
