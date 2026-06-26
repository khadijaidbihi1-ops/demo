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

--- Add constraints to ensure valid date of birth for patients
ALTER TABLE Patients
ADD CONSTRAINT chk_patient_datebirth
CHECK (
    YEAR(DateBirth) > 1920
    AND MONTH(DateBirth) BETWEEN 1 AND 12
    AND (
        (MONTH(DateBirth) IN (1,3,5,7,8,10,12) AND DAY(DateBirth) BETWEEN 1 AND 31)
        OR
        (MONTH(DateBirth) IN (4,6,9,11) AND DAY(DateBirth) BETWEEN 1 AND 30)
        OR
        (MONTH(DateBirth) = 2 AND DAY(DateBirth) BETWEEN 1 AND 29)
    )
);
--- Add constraints to ensure valid date of birth for doctors
ALTER TABLE Doctors
ADD CONSTRAINT chk_doctor_datebirth
CHECK (
    YEAR(DateBirth) > 1920
    AND MONTH(DateBirth) BETWEEN 1 AND 12
    AND (
        (MONTH(DateBirth) IN (1,3,5,7,8,10,12) AND DAY(DateBirth) BETWEEN 1 AND 31)
        OR
        (MONTH(DateBirth) IN (4,6,9,11) AND DAY(DateBirth) BETWEEN 1 AND 30)
        OR
        (MONTH(DateBirth) = 2 AND DAY(DateBirth) BETWEEN 1 AND 29)
    )
);

-- Add constraint to ensure unique doctor slots
ALTER TABLE Appointments
ADD CONSTRAINT uq_doctor_slot
UNIQUE (
    DoctorID,
    AppointmentDate,
    AppointmentTime
);

