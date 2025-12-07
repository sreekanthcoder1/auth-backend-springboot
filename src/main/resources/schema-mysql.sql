-- ================================================================
-- MySQL Database Schema for Authentication Backend
-- ================================================================
-- This script creates the necessary tables for the authentication system
-- Optimized for MySQL 8.0+ with proper indexes and constraints

-- Create database (will be created automatically if createDatabaseIfNotExist=true)
-- CREATE DATABASE IF NOT EXISTS authdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE authdb;

-- ================================================================
-- USERS TABLE
-- ================================================================
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    account_non_expired BOOLEAN DEFAULT TRUE,
    account_non_locked BOOLEAN DEFAULT TRUE,
    credentials_non_expired BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255),
    password_reset_token VARCHAR(255),
    password_reset_expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL,
    login_attempts INT DEFAULT 0,
    locked_until TIMESTAMP NULL,

    -- Indexes for performance
    INDEX idx_email (email),
    INDEX idx_email_verification_token (email_verification_token),
    INDEX idx_password_reset_token (password_reset_token),
    INDEX idx_enabled (enabled),
    INDEX idx_created_at (created_at),
    INDEX idx_last_login (last_login_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- USER ROLES TABLE
-- ================================================================
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- USER ROLES MAPPING TABLE
-- ================================================================
CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by BIGINT NULL,

    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL,

    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- JWT TOKEN BLACKLIST TABLE
-- ================================================================
CREATE TABLE IF NOT EXISTS jwt_blacklist (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    token_hash VARCHAR(64) NOT NULL UNIQUE,
    user_id BIGINT,
    expires_at TIMESTAMP NOT NULL,
    blacklisted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason VARCHAR(100),

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- USER SESSIONS TABLE (Optional - for session management)
-- ================================================================
CREATE TABLE IF NOT EXISTS user_sessions (
    id VARCHAR(128) PRIMARY KEY,
    user_id BIGINT NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    active BOOLEAN DEFAULT TRUE,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_expires_at (expires_at),
    INDEX idx_active (active),
    INDEX idx_last_accessed (last_accessed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- AUDIT LOG TABLE (Optional - for security auditing)
-- ================================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id BIGINT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_created_at (created_at),
    INDEX idx_success (success)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- APPLICATION SETTINGS TABLE (Optional - for dynamic configuration)
-- ================================================================
CREATE TABLE IF NOT EXISTS app_settings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_type VARCHAR(20) DEFAULT 'STRING',
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by BIGINT,

    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_setting_key (setting_key),
    INDEX idx_setting_type (setting_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- INITIAL DATA SETUP
-- ================================================================

-- Insert default roles
INSERT IGNORE INTO roles (name, description) VALUES
('USER', 'Standard user role with basic permissions'),
('ADMIN', 'Administrator role with full system access'),
('MODERATOR', 'Moderator role with limited administrative permissions');

-- Insert default application settings
INSERT IGNORE INTO app_settings (setting_key, setting_value, setting_type, description) VALUES
('jwt.expiration.hours', '24', 'INTEGER', 'JWT token expiration time in hours'),
('password.min.length', '8', 'INTEGER', 'Minimum password length requirement'),
('login.max.attempts', '5', 'INTEGER', 'Maximum login attempts before account lockout'),
('account.lockout.minutes', '30', 'INTEGER', 'Account lockout duration in minutes'),
('email.verification.required', 'false', 'BOOLEAN', 'Whether email verification is required for new accounts'),
('registration.enabled', 'true', 'BOOLEAN', 'Whether new user registration is enabled');

-- ================================================================
-- CLEANUP PROCEDURES (Optional)
-- ================================================================

-- Create event to clean up expired tokens
DELIMITER //
CREATE EVENT IF NOT EXISTS cleanup_expired_tokens
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    DELETE FROM jwt_blacklist WHERE expires_at < NOW();
    DELETE FROM user_sessions WHERE expires_at < NOW();
END//

CREATE EVENT IF NOT EXISTS cleanup_old_audit_logs
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    DELETE FROM audit_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY);
END//
DELIMITER ;

-- Enable event scheduler (may require SUPER privilege)
-- SET GLOBAL event_scheduler = ON;

-- ================================================================
-- PERFORMANCE OPTIMIZATIONS
-- ================================================================

-- Additional composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_users_email_enabled ON users(email, enabled);
CREATE INDEX IF NOT EXISTS idx_users_created_enabled ON users(created_at, enabled);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_active ON user_sessions(user_id, active);

-- ================================================================
-- SECURITY CONSTRAINTS
-- ================================================================

-- Ensure email format is valid (basic check)
ALTER TABLE users ADD CONSTRAINT chk_email_format
CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Ensure password is not empty
ALTER TABLE users ADD CONSTRAINT chk_password_not_empty
CHECK (CHAR_LENGTH(password) > 0);

-- Ensure login attempts is non-negative
ALTER TABLE users ADD CONSTRAINT chk_login_attempts_positive
CHECK (login_attempts >= 0);

-- ================================================================
-- VIEWS FOR COMMON QUERIES (Optional)
-- ================================================================

-- Active users with roles
CREATE OR REPLACE VIEW active_users_with_roles AS
SELECT
    u.id,
    u.name,
    u.email,
    u.enabled,
    u.email_verified,
    u.created_at,
    u.last_login_at,
    GROUP_CONCAT(r.name ORDER BY r.name SEPARATOR ',') as roles
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
WHERE u.enabled = TRUE
GROUP BY u.id, u.name, u.email, u.enabled, u.email_verified, u.created_at, u.last_login_at;

-- User statistics view
CREATE OR REPLACE VIEW user_statistics AS
SELECT
    COUNT(*) as total_users,
    COUNT(CASE WHEN enabled = TRUE THEN 1 END) as active_users,
    COUNT(CASE WHEN enabled = FALSE THEN 1 END) as disabled_users,
    COUNT(CASE WHEN email_verified = TRUE THEN 1 END) as verified_users,
    COUNT(CASE WHEN last_login_at > DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as active_last_30_days,
    COUNT(CASE WHEN created_at > DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 END) as new_last_7_days
FROM users;

-- ================================================================
-- COMPLETION MESSAGE
-- ================================================================
-- Schema creation completed successfully!
-- Tables created: users, roles, user_roles, jwt_blacklist, user_sessions, audit_logs, app_settings
-- Views created: active_users_with_roles, user_statistics
-- Events created: cleanup_expired_tokens, cleanup_old_audit_logs
-- Ready for production use with MySQL 8.0+
