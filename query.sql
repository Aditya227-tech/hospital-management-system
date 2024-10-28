-- Create the database
CREATE DATABASE IF NOT EXISTS HospitalManagementSystem;
USE HospitalManagementSystem;

-- Create SuperAdmin table
CREATE TABLE superAdmin (
    super_admin_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Create Admin table
CREATE TABLE admin (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    department VARCHAR(50),
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES superAdmin(super_admin_id)
);

-- Create Doctors table
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    qualification VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    joining_date DATE NOT NULL,
    consultation_fee DECIMAL(10,2),
    status ENUM('Active', 'On Leave', 'Inactive') DEFAULT 'Active',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES admin(admin_id)
);

-- Create Patients table
CREATE TABLE patient (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    blood_group VARCHAR(5),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    medical_history TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Appointments table
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status ENUM('Scheduled', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    reason TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- Sample SELECT queries
-- Query super admins
SELECT * FROM superAdmin;

-- Query admins with their creator's information
SELECT a.*, sa.username as created_by_username 
FROM admin a 
LEFT JOIN superAdmin sa ON a.created_by = sa.super_admin_id;

-- Query patients with their appointment history
SELECT p.*, 
       COUNT(a.appointment_id) as total_appointments,
       MAX(a.appointment_date) as last_appointment
FROM patient p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id;

-- Query doctors with their appointment counts
SELECT d.*,
       COUNT(a.appointment_id) as total_appointments,
       COUNT(CASE WHEN a.status = 'Completed' THEN 1 END) as completed_appointments
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id;

-- Create indexes for better performance
CREATE INDEX idx_patient_name ON patient(first_name, last_name);
CREATE INDEX idx_doctor_specialization ON doctors(specialization);
CREATE INDEX idx_appointment_date ON appointments(appointment_date);