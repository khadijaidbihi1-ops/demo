--   Table NHS Database
CREATE DATABASE NHS_Trust_DB;
USE NHS_Trust_DB;
 
-- 1. Create Medications Table
CREATE TABLE Medications (
    MedicationID BIGINT NOT NULL AUTO_INCREMENT,       
    MedicationName VARCHAR(150) NOT NULL,
    Descritption TEXT,
    -- Define primary key
    PRIMARY KEY (MedicationID)
);


-- 2. Create Patients Table
CREATE TABLE Patients (
    PatientID BIGINT NOT NULL AUTO_INCREMENT,
    PatientName VARCHAR(50) NOT NULL,
    PatientSurname VARCHAR(50) NOT NULL,
    PhoneNumber BIGINT NOT NULL,
    Email VARCHAR(100) NOT NULL,
    NHSnumber BIGINT NOT NULL,
    Address VARCHAR(255),
    DateBirth DATE NOT NULL,
    ActiveOrNot BOOLEAN DEFAULT TRUE,
    -- Define primary key
    PRIMARY KEY (PatientID),
    -- Define unique constraint to avoid duplication of patients with the same name, 
    --surname, and date of birth
    UNIQUE KEY `unique_patient` (`PatientName`,`PatientSurname`,`DateBirth`),
    -- constaint on email format
    CONSTRAINT `chk_patient_email` CHECK ((`Email` like '%@%.%'))
);

-- 3. Create Clinics Table 
CREATE TABLE Clinics (
    ClinicID BIGINT NOT NULL AUTO_INCREMENT,
    ClinicName VARCHAR(150) NOT NULL,
    ClinicAddress VARCHAR(255),
    PhoneNumber BIGINT NOT NULL,
    Email VARCHAR(100),
    -- Define primary key
    PRIMARY KEY (ClinicID),
    -- constaint on email format
    CONSTRAINT `chk_clinic_email` CHECK (`Email` like '%@%.%')
);


-- 4. Create Doctors Table 
CREATE TABLE Doctors (
    DoctorID BIGINT NOT NULL AUTO_INCREMENT,
    ClinicID BIGINT NOT NULL,
    DoctorName VARCHAR(50) NOT NULL,
    DoctorSurname VARCHAR(50) NOT NULL,
    Speciality VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    PhoneNumber BIGINT NOT NULL,
    DateBirth DATE NOT NULL,
    ActiveOrNot BOOLEAN DEFAULT TRUE,
    -- Define primary key
    PRIMARY KEY (DoctorID),
    -- define unique key to avoid duplication of doctors with the same name, surname, and date of birth
    UNIQUE KEY `unique_doctor` (`DoctorName`, `DoctorSurname`, `DateBirth`),
    -- define foreign key to reference Clinics table
    KEY `fk_doctor_clinic` (`ClinicID`),
    -- define foreign key constraint to ensure referential integrity with Clinics table
    CONSTRAINT `fk_doctor_clinic` FOREIGN KEY (`ClinicID`) REFERENCES `Clinics` (`ClinicID`),
    -- constaint on email format
    CONSTRAINT `chk_doctor_email` CHECK (`Email` LIKE '%@%.%')
);


-- 5. Create Appointments Table 
CREATE TABLE Appointments (
    AppointmentID BIGINT NOT NULL AUTO_INCREMENT,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Notes TEXT,
    ClinicID BIGINT NOT NULL,
    PatientID BIGINT NOT NULL,
    DoctorID BIGINT NOT NULL,
    Diagnosis VARCHAR(255),
    PhoneOrFace tinyint(1) NOT NULL DEFAULT '0',
    Status VARCHAR(50) DEFAULT 'Scheduled',
    -- Define primary key
    PRIMARY KEY (AppointmentID),
    -- Define foreign keys to reference Clinics, Patients, and Doctors tables
    CONSTRAINT FK_Appointment_Clinic FOREIGN KEY (ClinicID) REFERENCES Clinics(ClinicID),
    CONSTRAINT FK_Appointment_Patient FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    CONSTRAINT FK_Appointment_Doctor FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    -- Constraints to ensure appointments are scheduled on weekdays and within working hours
    CONSTRAINT chk_appointment_day CHECK (DAYOFWEEK(AppointmentDate) BETWEEN 2 AND 6),
    CONSTRAINT chk_appointment_time CHECK (HOUR(AppointmentTime) >= 8 AND HOUR(AppointmentTime) < 20)
);

-- Patients: valid birth date range
ALTER TABLE Patients
ADD CONSTRAINT chk_patient_datebirth
CHECK (
    DateBirth BETWEEN '1920-01-01' AND '2026-12-31'
);
-- Doctors: valid birth date range
ALTER TABLE Doctors
ADD CONSTRAINT chk_doctor_datebirth
CHECK (
    DateBirth BETWEEN '1920-01-01' AND '2001-12-31'
);

-- Add constraint to ensure unique doctor slots
ALTER TABLE Appointments
ADD CONSTRAINT uq_doctor_slot
UNIQUE (
    DoctorID,
    AppointmentDate,
    AppointmentTime
);
-- Add constraint to ensure unique patient slots
ALTER TABLE Appointments
ADD CONSTRAINT uq_patient_slot
UNIQUE (
    PatientID,
    AppointmentDate,
    AppointmentTime
);


--- Add foreign key constraint to ensure referential integrity with Clinics table
--delete the existing foreign key constraint
ALTER TABLE Doctors DROP FOREIGN KEY fk_doctor_clinic;
---add the new foreign key constraint with ON DELETE RESTRICT and ON UPDATE CASCADE
ALTER TABLE Doctors 
ADD CONSTRAINT fk_doctor_clinic 
FOREIGN KEY (ClinicID) REFERENCES Clinics(ClinicID) 
ON DELETE RESTRICT 
ON UPDATE CASCADE;




--- Add unique constraint to ensure unique medication names
ALTER TABLE Medications
ADD CONSTRAINT uq_medication_name UNIQUE (MedicationName);

-- add constraint to ensure appointments are scheduled in 15-minute intervals
ALTER TABLE Appointments
ADD CONSTRAINT chk_appointment_minutes 
CHECK (MINUTE(AppointmentTime) IN (0,15,30,45));

--- add constraint to ensure appointments are not scheduled during lunch break (1 PM)
ALTER TABLE Appointments
ADD CONSTRAINT chk_appointment_lunch 
CHECK (HOUR(AppointmentTime) <> 13);



-- USERS AND ROLES
-- Admin: Full System Control
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'AdminPass2026!';
GRANT ALL PRIVILEGES ON NHS_Trust_DB.* TO 'admin_user'@'localhost';

-- Receptionist: Data Entry & Management
CREATE USER 'receptionist_user'@'localhost' IDENTIFIED BY 'ReceptionistPass2026!';
GRANT SELECT, INSERT, UPDATE ON NHS_Trust_DB.Patients TO 'receptionist_user'@'localhost';
GRANT SELECT, INSERT, UPDATE ON NHS_Trust_DB.Appointments TO 'receptionist_user'@'localhost';

-- Doctor: Clinical Care
CREATE USER 'doctor_user'@'localhost' IDENTIFIED BY 'DoctorPass2026!';
GRANT SELECT ON NHS_Trust_DB.Patients TO 'doctor_user'@'localhost';
GRANT SELECT, INSERT, UPDATE ON NHS_Trust_DB.Medications TO 'doctor_user'@'localhost';
GRANT SELECT, UPDATE (Diagnosis) ON NHS_Trust_DB.Appointments TO 'doctor_user'@'localhost';

-- Patient: Personal Data Access
CREATE USER 'patient_user'@'localhost' IDENTIFIED BY 'PatientPass2026!';
GRANT SELECT ON NHS_Trust_DB.Patients TO 'patient_user'@'localhost';
GRANT SELECT ON NHS_Trust_DB.Appointments TO 'patient_user'@'localhost';

FLUSH PRIVILEGES;



--DATABASE POPULATION
-- 1. CLINICS
INSERT INTO Clinics (ClinicName, ClinicAddress, PhoneNumber, Email) VALUES 
('Harley Street Clinic', '12 Harley St, London', 2071110001, 'info@harleyst.co.uk'),
('Westminster Medical', '50 Victoria St, London', 2072220002, 'info@westminster.co.uk'),
('City Health Hub', '100 Bishopsgate, London', 2073330003, 'info@cityhealth.co.uk');
 
-- 2. MEDICATIONS (10 Records)
INSERT INTO Medications (MedicationName, Descritption) VALUES 
('Paracetamol', 'Analgesic'), ('Amoxicillin', 'Antibiotic'), ('Ibuprofen', 'NSAID'),
('Amlodipine', 'Blood Pressure'), ('Metformin', 'Diabetes'), ('Salbutamol', 'Inhaler'),
('Lisinopril', 'Blood Pressure'), ('Atorvastatin', 'Cholesterol'), ('Omeprazole', 'Acid Reflux'),
('Cetirizine', 'Antihistamine');
 
-- 3. PATIENTS (20 Records)
INSERT INTO Patients (PatientName, PatientSurname, PhoneNumber, Email, NHSnumber, DateBirth) VALUES
('John', 'Doe', 7400100001, 'john@email.com', 1001, '1990-01-10'),
('Jane', 'Smith', 7400100002, 'jane@email.com', 1002, '1990-02-20'),
('Mark', 'Brown', 7400100003, 'mark@email.com', 1003, '1995-03-15'),
('Anna', 'White', 7400100004, 'anna@email.com', 1004, '1995-04-25'),
('Luca', 'Rossi', 7400100005, 'luca@email.com', 1005, '1980-05-30'),
('Sara', 'Verdi', 7400100006, 'sara@email.com', 1006, '1980-06-05'),
('Robert', 'Moore', 7400100007, 'robert@email.com', 1007, '1983-07-12'),
('Laura', 'Taylor', 7400100008, 'laura@email.com', 1008, '1983-08-18'),
('James', 'Anderson', 7400100009, 'james@email.com', 1009, '1975-09-22'),
('Olivia', 'Thomas', 7400100010, 'olivia@email.com', 1010, '1975-10-01'),
('Daniel', 'Jackson', 7400100011, 'daniel@email.com', 1011, '1991-11-14'),
('Sophia', 'White', 7400100012, 'sophia@email.com', 1012, '1991-12-25'),
('Joseph', 'Harris', 7400100013, 'joseph@email.com', 1013, '1993-01-08'),
('Ava', 'Martin', 7400100014, 'ava@email.com', 1014, '1993-02-19'),
('Thomas', 'Thompson', 7400100015, 'thomas@email.com', 1015, '1996-03-27'),
('Mia', 'Garcia', 7400100016, 'mia@email.com', 1016, '1996-04-03'),
('Charles', 'Martinez', 7400100017, 'charles@email.com', 1017, '1994-05-12'),
('Charlotte', 'Robinson', 7400100018, 'charlotte@email.com', 1018, '1994-06-21'),
('Christopher', 'Clark', 7400100019, 'chris@email.com', 1019, '1972-07-07'),
('Amelia', 'Rodriguez', 7400100020, 'amelia@email.com', 1020, '1997-08-30');
 
-- 4. DOCTORS (9 Records)
INSERT INTO Doctors (ClinicID, DoctorName, DoctorSurname, Speciality, Email, PhoneNumber, DateBirth) VALUES
(1, 'John', 'Smith', 'Cardiologist', 'jsmith1@clinic.co.uk', 7700900001, '1975-05-15'),
(1, 'Alice', 'Smith', 'Cardiologist', 'asmith@clinic.co.uk', 7700900002, '1982-08-20'),
(1, 'Sarah', 'Derm', 'Dermatologist', 'sderm@clinic.co.uk', 7700900003, '1970-12-01'),
(2, 'Emily', 'Brown', 'Pediatrician', 'ebrown@clinic.co.uk', 7700900004, '1985-03-10'),
(2, 'Michael', 'Brown', 'Dermatologist', 'mbrown@clinic.co.uk', 7700900005, '1968-07-22'),
(2, 'David', 'Wilson', 'Pediatrician', 'dwilson@clinic.co.uk', 7700900006, '1980-11-30'),
(3, 'Robert', 'Taylor', 'Neurologist', 'rtaylor@clinic.co.uk', 7700900007, '1978-01-14'),
(3, 'Laura', 'Taylor', 'Neurologist', 'ltaylor@clinic.co.uk', 7700900008, '1983-09-05'),
(3, 'James', 'Anderson', 'Orthopedist', 'janderson@clinic.co.uk', 7700900009, '1972-04-18');
 
-- 5. APPOINTMENTS (15 Records)
INSERT INTO Appointments (AppointmentDate, AppointmentTime, ClinicID, PatientID, DoctorID, Diagnosis, Status) VALUES
('2026-06-25', '09:00:00', 1, 1, 1, 'Hypertension', 'Completed'),
('2026-06-26', '10:30:00', 1, 2, 2, 'Dermatitis', 'Completed'),
('2026-06-29', '14:00:00', 2, 3, 4, 'Flu', 'Scheduled'),
('2026-06-30', '16:00:00', 2, 4, 4, 'Check-up', 'Scheduled'),
('2026-07-01', '11:00:00', 3, 5, 7, 'Migraine', 'Completed'),
('2026-07-02', '09:00:00', 3, 6, 7, 'Stress', 'Scheduled'),
('2026-07-03', '15:00:00', 1, 7, 1, 'Follow-up', 'Completed'),
('2026-07-06', '10:00:00', 2, 8, 6, 'Growth check', 'Scheduled'),
('2026-07-07', '14:00:00', 3, 9, 9, 'Knee pain', 'Scheduled'),
('2026-07-08', '09:30:00', 1, 10, 3, 'Rash', 'Scheduled'),
('2026-07-09', '11:00:00', 2, 11, 5, 'Eczema', 'Scheduled'),
('2026-07-10', '13:00:00', 3, 12, 8, 'Vision test', 'Scheduled'),
('2026-07-13', '08:30:00', 1, 13, 1, 'Routine', 'Scheduled'),
('2026-07-14', '15:30:00', 2, 14, 6, 'Flu', 'Scheduled'),
('2026-07-15', '16:00:00', 3, 15, 9, 'Pain', 'Scheduled');
 
-- 6. PRESCRIPTIONS (15 Records)
INSERT INTO Prescriptions (AppointmentID, MedicationID, Dosage, DateIssued, PatientID, DoctorID) VALUES
(1, 1, '500mg daily', '2026-06-25', 1, 1),
(2, 2, 'Twice daily', '2026-06-26', 2, 2),
(5, 5, 'Before bed', '2026-07-01', 5, 7),
(6, 5, 'Before bed', '2026-07-02', 6, 7),
(7, 1, 'As needed', '2026-07-03', 7, 1),
(NULL, 10, 'Once daily', '2026-07-05', 8, NULL),
(NULL, 3, 'Take with food', '2026-07-06', 9, NULL),
(NULL, 4, 'Once daily', '2026-07-07', 10, NULL),
(NULL, 6, 'Use at night', '2026-07-08', 11, NULL),
(NULL, 7, 'Twice daily', '2026-07-09', 12, NULL),
(NULL, 8, 'Once daily', '2026-07-10', 13, NULL),
(NULL, 9, 'Before meals', '2026-07-13', 14, NULL),
(NULL, 2, 'Finish course', '2026-07-14', 15, NULL),
(NULL, 5, 'As needed', '2026-07-15', 16, NULL),
(NULL, 1, '500mg', '2026-07-16', 17, NULL);




---QUERY---
--query to retrieve patients who have not received any prescriptions,
-- along with their appointment details and attending doctor information
SELECT 
    p.PatientName AS 'First Name', 
    p.PatientSurname AS 'Surname',
    TIMESTAMPDIFF(YEAR, p.DateBirth, CURDATE()) AS 'Age',
    a.AppointmentDate AS 'Appointment Date', 
    CONCAT(d.DoctorName, ' ', d.DoctorSurname) AS 'Attending Doctor'
FROM Patients p
LEFT JOIN Appointments a ON p.PatientID = a.PatientID
LEFT JOIN Prescriptions pr ON a.AppointmentID = pr.AppointmentID
JOIN Doctors d ON a.DoctorID = d.DoctorID
WHERE pr.PrescriptionID IS NULL
ORDER BY a.AppointmentDate DESC;