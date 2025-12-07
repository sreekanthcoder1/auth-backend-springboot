-- Database creation script for Auth Demo Application
-- Run this script in MySQL to create the required database

-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS auth_demo;

-- Use the database
USE auth_demo;

-- Create users table (Spring Boot will handle this with JPA, but included for reference)
-- Note: Spring Boot with JPA will auto-create tables based on entity classes
-- This is just for manual database setup if needed

-- Optional: Create a user for the application (adjust privileges as needed)
-- CREATE USER IF NOT EXISTS 'auth_user'@'localhost' IDENTIFIED BY 'auth_password';
-- GRANT ALL PRIVILEGES ON auth_demo.* TO 'auth_user'@'localhost';
-- FLUSH PRIVILEGES;

-- Verify database creation
SHOW DATABASES LIKE 'auth_demo';

-- Show tables (will be empty initially, Spring Boot will create them)
SHOW TABLES;

PRINT 'Database auth_demo created successfully!';
