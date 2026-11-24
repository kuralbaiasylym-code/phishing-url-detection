-- Фишингтік URL-сілтемелерді анықтау жүйесінің ДҚ толық скрипті (schema.sql)

-- 1. Қолданушылар кестесі
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. ML модельдері кестесі
CREATE TABLE IF NOT EXISTS ml_models (
    model_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    accuracy DECIMAL(5,2) NOT NULL,
    version VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. URL сканерлеу нәтижелері кестесі
CREATE TABLE IF NOT EXISTS url_scans (
    scan_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    model_id INT,
    original_url TEXT NOT NULL,
    is_phishing BOOLEAN NOT NULL,
    confidence_score DECIMAL(5,2) NOT NULL,
    scanned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (model_id) REFERENCES ml_models(model_id) ON DELETE SET NULL
);

-- 4. D4 reports (Тіркелетін есептер) кестесі
CREATE TABLE IF NOT EXISTS reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    scan_id INT,
    report_details TEXT NOT NULL,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (scan_id) REFERENCES url_scans(scan_id) ON DELETE CASCADE
);

-- 5. Шағымдар (Complaints) кестесі (3.0 Шағымдар модулі үшін)
CREATE TABLE IF NOT EXISTS complaints (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    reported_url TEXT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- ==========================================
-- ТЕСТТІК ДЕРЕКТЕР (INSERT 3-5 мәннен)
-- ==========================================

INSERT INTO users (username, email, password_hash) VALUES
('assylym_k', 'assylym@mail.com', 'hash_pass_1'),
('ermek_dev', 'ermek@mail.com', 'hash_pass_2'),
('moldir_b', 'moldir@mail.com', 'hash_pass_3'),
('admin_security', 'admin@mail.com', 'hash_pass_4');

INSERT INTO ml_models (model_name, accuracy, version) VALUES
('Random Forest Classifier', 95.50, 'v1.0'),
('Neural Network PhishDetect', 97.20, 'v2.1'),
('SVM Baseline Model', 91.00, 'v0.9');

INSERT INTO url_scans (user_id, model_id, original_url, is_phishing, confidence_score) VALUES
(1, 1, 'http://secure-login-apple-id.com', TRUE, 98.50),
(1, 2, 'https://google.com', FALSE, 1.20),
(2, 2, 'http://free-crypto-giveaway-bonus.net', TRUE, 99.10),
(3, 1, 'https://edu.kz', FALSE, 0.50),
(2, 3, 'http://update-bank-account-verify.com', TRUE, 94.30);

INSERT INTO reports (scan_id, report_details) VALUES
(1, 'High risk phishing detected via domain age analysis.'),
(3, 'Malicious redirect patterns identified.'),
(5, 'Suspicious login form mimicking financial institution.');

INSERT INTO complaints (user_id, reported_url, reason, status) VALUES
(1, 'http://fake-instagram-verify.com', 'Impersonation of social media', 'Reviewed'),
(2, 'http://free-crypto-giveaway-bonus.net', 'Scam and financial fraud', 'Pending'),
(3, 'http://update-bank-account-verify.com', 'Phishing attack', 'Resolved');

-- ==========================================
-- КҮРДЕЛІ СҰРАНЫСТАР (3 кестелік JOIN және GROUP BY)
-- ==========================================

-- Сұраныс: Қай қолданушының қандай модель арқылы қанша фишингтік сілтеме сканерлегенін көру (users, url_scans, ml_models біріктірілімі)
SELECT
    u.username,
    m.model_name,
    COUNT(s.scan_id) AS total_scans,
    SUM(s.is_phishing) AS phishing_detected_count
FROM users u
JOIN url_scans s ON u.user_id = s.user_id
JOIN ml_models m ON s.model_id = m.model_id
GROUP BY u.username, m.model_name;