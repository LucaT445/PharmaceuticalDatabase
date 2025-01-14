DROP DATABASE IF EXISTS PharmaDB;
CREATE DATABASE PharmaDB;
USE PharmaDB;

DROP TABLE IF EXISTS User;

CREATE TABLE IF NOT EXISTS User (
  user_id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NOT NULL,
  role ENUM('patient', 'prescriber', 'pharmacist') NOT NULL,
  PRIMARY KEY (user_id)
);

DROP TABLE IF EXISTS Account;

CREATE TABLE IF NOT EXISTS Account (
  account_id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_of_birth TIMESTAMP NOT NULL,
  PRIMARY KEY (account_id),
  INDEX user_id_idx (user_id ASC),
  CONSTRAINT user_id
    FOREIGN KEY (user_id)
    REFERENCES User (user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Address;

CREATE TABLE IF NOT EXISTS Address (
  address_id INT NOT NULL AUTO_INCREMENT,
  street_name VARCHAR(45) NOT NULL,
  city VARCHAR(45) NOT NULL,
  state CHAR(2) NOT NULL,
  country VARCHAR(45) NOT NULL,
  PRIMARY KEY (address_id)
);

DROP TABLE IF EXISTS UserAddress;

CREATE TABLE IF NOT EXISTS UserAddress (
  address_id INT NOT NULL,
  user_id INT NOT NULL,
  INDEX address_id_idx (address_id ASC) VISIBLE,
  INDEX user_id_idx (user_id ASC) VISIBLE,
  CONSTRAINT address_id
    FOREIGN KEY (address_id)
    REFERENCES Address (address_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT useraddress_user_id
    FOREIGN KEY (user_id)
    REFERENCES User (user_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS Notification;

CREATE TABLE IF NOT EXISTS Notification (
  notification_id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  message MEDIUMTEXT NOT NULL,
  PRIMARY KEY (notification_id),
  INDEX user_id_idx (user_id ASC) VISIBLE,
  CONSTRAINT notification_user_id
    FOREIGN KEY (user_id)
    REFERENCES User (user_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS DrugClass;

CREATE TABLE IF NOT EXISTS DrugClass (
  class_id INT NOT NULL,
  class_name VARCHAR(45) NOT NULL,
  conditions MEDIUMTEXT NOT NULL,
  PRIMARY KEY (class_id),
  UNIQUE INDEX name_UNIQUE (class_name ASC) VISIBLE
);

DROP TABLE IF EXISTS Medication;

CREATE TABLE IF NOT EXISTS Medication (
  medication_id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NOT NULL,
  class_id INT NOT NULL,
  SKU VARCHAR(45) NOT NULL,
  expiration_date DATE NOT NULL,
  PRIMARY KEY (medication_id),
  UNIQUE INDEX SKU_UNIQUE (SKU ASC) VISIBLE,
  INDEX class_id_idx (class_id ASC) VISIBLE,
  CONSTRAINT class_id
    FOREIGN KEY (class_id)
    REFERENCES DrugClass (class_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS Supplier;

CREATE TABLE IF NOT EXISTS Supplier (
  supplier_id INT NOT NULL,
  name VARCHAR(45) NOT NULL,
  contact_info VARCHAR(45) NOT NULL,
  PRIMARY KEY (supplier_id)
);

DROP TABLE IF EXISTS Patient;

CREATE TABLE IF NOT EXISTS Patient (
  patient_id INT NOT NULL,
  user_id INT NOT NULL,
  name VARCHAR(45) NOT NULL,
  med_history VARCHAR(255) NOT NULL,
  PRIMARY KEY (patient_id),
  UNIQUE INDEX user_id_UNIQUE (user_id ASC) VISIBLE,
  CONSTRAINT patient_user_id
    FOREIGN KEY (user_id)
    REFERENCES User (user_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS Pharmacy;

CREATE TABLE IF NOT EXISTS Pharmacy (
  pharmacy_id INT NOT NULL AUTO_INCREMENT,
  address_id INT NOT NULL,
  PRIMARY KEY (pharmacy_id),
  INDEX address_id_idx (address_id ASC) VISIBLE,
  CONSTRAINT pharmacy_address_id
    FOREIGN KEY (address_id)
    REFERENCES Address (address_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS Pharmacist;

CREATE TABLE IF NOT EXISTS Pharmacist (
  pharmacist_id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  PRIMARY KEY (pharmacist_id),
  INDEX user_id_idx (user_id ASC) VISIBLE,
  CONSTRAINT pharmacist_user_id
    FOREIGN KEY (user_id)
    REFERENCES User (user_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Prescriber;

CREATE TABLE IF NOT EXISTS Prescriber (
  prescriber_id INT NOT NULL,
  user_id INT NOT NULL,
  med_license VARCHAR(45) NOT NULL,
  num_of_patients INT NULL,
  PRIMARY KEY (prescriber_id),
  UNIQUE INDEX med_license_UNIQUE (med_license ASC) VISIBLE,
  INDEX user_id_idx (user_id ASC) VISIBLE,
  CONSTRAINT prescriber_user_id
    FOREIGN KEY (user_id)
    REFERENCES User (user_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS Prescription;

CREATE TABLE IF NOT EXISTS Prescription (
  prescription_id INT NOT NULL AUTO_INCREMENT,
  patient_id INT NOT NULL,
  medication_id INT NOT NULL,
  dosage VARCHAR(45) NOT NULL,
  refills INT NOT NULL,
  PRIMARY KEY (prescription_id),
  INDEX patient_id_idx (patient_id ASC) VISIBLE,
  INDEX medication_id_idx (medication_id ASC) VISIBLE,
  CONSTRAINT patient_id
    FOREIGN KEY (patient_id)
    REFERENCES Patient (patient_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT medication_id
    FOREIGN KEY (medication_id)
    REFERENCES Medication (medication_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);


DROP TABLE IF EXISTS Drug_Interaction;

CREATE TABLE IF NOT EXISTS Drug_Interaction (
  interaction_id INT NOT NULL AUTO_INCREMENT,
  amount_of_substances INT NOT NULL,
  description MEDIUMTEXT NOT NULL,
  severity ENUM('low', 'moderate', 'high') NOT NULL,
  PRIMARY KEY (interaction_id)
);

DROP TABLE IF EXISTS Inventory;

CREATE TABLE IF NOT EXISTS Inventory (
  inventory_id INT NOT NULL AUTO_INCREMENT,
  pharmacy_id INT NOT NULL,
  medication_id INT NOT NULL,
  inventory_level INT NOT NULL,
  stock_alert INT NOT NULL,
  PRIMARY KEY (inventory_id),
  INDEX pharmacy_id_idx (pharmacy_id ASC) VISIBLE,
  CONSTRAINT pharmacy_id
    FOREIGN KEY (pharmacy_id)
    REFERENCES Pharmacy (pharmacy_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

ALTER TABLE Inventory
ADD COLUMN supplier_id INT NOT NULL,
ADD CONSTRAINT inventory_supplier_fk FOREIGN KEY (supplier_id)
    REFERENCES Supplier (supplier_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;


DROP TABLE IF EXISTS OrderTable;

CREATE TABLE IF NOT EXISTS OrderTable (
  order_id INT NOT NULL AUTO_INCREMENT,
  pharmacy_id INT NOT NULL,
  supplier_id INT NOT NULL,
  order_details MEDIUMTEXT NOT NULL,
  status ENUM('Pending', 'Completed', 'Cancelled') NOT NULL,
  PRIMARY KEY (order_id),
  INDEX pharmacy_id_idx (pharmacy_id ASC) VISIBLE,
  INDEX supplier_id_idx (supplier_id ASC) VISIBLE,
  CONSTRAINT order_pharmacy_id
    FOREIGN KEY (pharmacy_id)
    REFERENCES Pharmacy (pharmacy_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT supplier_id
    FOREIGN KEY (supplier_id)
    REFERENCES Supplier (supplier_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

-- To ensure business requirement #4 goes through smoothly
ALTER TABLE Supplier
ADD COLUMN cost DECIMAL(10, 2) NOT NULL,
ADD COLUMN delivery_speed INT NOT NULL;

DROP TABLE IF EXISTS Insurance;

CREATE TABLE IF NOT EXISTS Insurance (
  insurance_id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NOT NULL,
  coverage_info MEDIUMTEXT NOT NULL,
  claims INT NOT NULL,
  PRIMARY KEY (insurance_id),
  UNIQUE INDEX name_UNIQUE (name ASC) VISIBLE
);

DROP TABLE IF EXISTS Payment;

CREATE TABLE IF NOT EXISTS Payment (
  payment_id INT NOT NULL AUTO_INCREMENT,
  prescription_id INT NOT NULL,
  method ENUM('Cash', 'Credit', 'Insurance') NOT NULL,
  status ENUM('Pending', 'Completed', 'Refunded') NOT NULL,
  PRIMARY KEY (payment_id),
  INDEX prescription_id_idx (prescription_id ASC) VISIBLE,
  CONSTRAINT prescription_id
    FOREIGN KEY (prescription_id)
    REFERENCES Prescription (prescription_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Renewal;

CREATE TABLE IF NOT EXISTS Renewal (
  renewal_id INT NOT NULL AUTO_INCREMENT,
  prescription_id INT NOT NULL,
  renewal_date DATE NOT NULL,
  times_renewed INT NOT NULL,
  PRIMARY KEY (renewal_id),
  INDEX prescription_id_idx (prescription_id ASC) VISIBLE,
  CONSTRAINT renewal_prescription_id
    FOREIGN KEY (prescription_id)
    REFERENCES Prescription (prescription_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS Inventory_Audit;

CREATE TABLE IF NOT EXISTS Inventory_Audit (
  audit_id INT NOT NULL AUTO_INCREMENT,
  inventory_id INT NOT NULL,
  audit_date DATE NOT NULL,
  audit_conductor INT NOT NULL,
  PRIMARY KEY (audit_id),
  INDEX inventory_id_idx (inventory_id ASC) VISIBLE,
  CONSTRAINT inventory_id
    FOREIGN KEY (inventory_id)
    REFERENCES Inventory (inventory_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS Feedback;

CREATE TABLE IF NOT EXISTS Feedback (
  feedback_id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  rating INT NOT NULL,
  comments MEDIUMTEXT NULL,
  PRIMARY KEY (feedback_id),
  INDEX user_id_idx (user_id ASC) VISIBLE,
  CONSTRAINT feedback_user_id
    FOREIGN KEY (user_id)
    REFERENCES User (user_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS MedicationInteraction;

CREATE TABLE IF NOT EXISTS MedicationInteraction (
  interaction_id INT NOT NULL,
  medication_id INT NOT NULL,
  INDEX interaction_id_idx (interaction_id ASC) VISIBLE,
  INDEX medication_id_idx (medication_id ASC) VISIBLE,
  CONSTRAINT interaction_id
    FOREIGN KEY (interaction_id)
    REFERENCES Drug_Interaction (interaction_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT med_interaction_medication_id
    FOREIGN KEY (medication_id)
    REFERENCES Medication (medication_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS PatientInsurance;

CREATE TABLE IF NOT EXISTS PatientInsurance (
  patient_id INT NOT NULL,
  insurance_id INT NOT NULL,
  INDEX patient_id_idx (patient_id ASC) VISIBLE,
  CONSTRAINT insurance_id
    FOREIGN KEY (insurance_id)
    REFERENCES Insurance (insurance_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT patient_insurance_patient_id
    FOREIGN KEY (patient_id)
    REFERENCES Patient (patient_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

