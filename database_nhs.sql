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



