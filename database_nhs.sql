--   Table NHS Databaase
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

    -- Define primary key and unique constraint

    PRIMARY KEY (PatientID),

    UNIQUE KEY `unique_patient` (`PatientName`,`PatientSurname`,`DateBirth`),

    CONSTRAINT `chk_patient_email` CHECK ((`Email` like '%@%.%'))

);
