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


-- 4. Create Doctors Table (Can now safely reference Clinics)
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

