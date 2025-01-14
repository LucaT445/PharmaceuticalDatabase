-- This file includes sample data for me to test the Pharmaceutical Database System
USE pharmadb;

-- Disables safety update mode, which was causing a constant error during testing
SET SQL_SAFE_UPDATES = 0; 

DELETE FROM Feedback;
DELETE FROM Notification;
DELETE FROM Renewal;
DELETE FROM Payment;
DELETE FROM Inventory_Audit;
DELETE FROM UserAddress;
DELETE FROM PatientInsurance;
DELETE FROM MedicationInteraction;
DELETE FROM Drug_Interaction;
DELETE FROM Account;
DELETE FROM Prescription;
DELETE FROM OrderTable; 
DELETE FROM Inventory; 
DELETE FROM Patient;
DELETE FROM Pharmacist;
DELETE FROM Prescriber;
DELETE FROM Pharmacy;  
DELETE FROM User;
DELETE FROM Address;
DELETE FROM Medication;
DELETE FROM DrugClass;
DELETE FROM Supplier;
DELETE FROM Insurance;

-- Strong Entities
INSERT INTO User (user_id, name, role) VALUES
(1, 'John Doe', 'patient'),
(2, 'Jane Smith', 'pharmacist'),
(3, 'Alice Johnson', 'prescriber'),
(4, 'Jake Hall', 'patient'),
(5, 'Vivian Stevenson', 'pharmacist'),
(6, 'Robert Kraft', 'prescriber'),
(7, 'Kurt Cobain', 'patient'),
(8, 'Jeff Bridges', 'pharmacist'),
(9, 'Dane Bryant', 'prescriber');

INSERT INTO Address (address_id, street_name, city, state, country) VALUES
(1, 'Blackwood Street', 'Omaha', 'NE', 'USA'),
(2, 'Portola Drive', 'San Mateo', 'CA', 'USA'),
(3, 'Kolyat Avenue', 'Bristol', 'CT', 'USA');

INSERT INTO DrugClass (class_id, class_name, conditions) VALUES
(1, 'Stimulant', 'Used to treat ADHD and narcolepsy'),
(2, 'Benzodiazepine', 'Used for anxiety, panic disorder, and seizures'),
(3, 'SSRI', 'Used to treat depression and anxiety disorders');

INSERT INTO Medication (medication_id, name, class_id, SKU, expiration_date) VALUES
(02322951, 'Lisdexamfetamine', 1, 'LXDF30', '2025-02-07'),
(02490226, 'Clonazepam', 2, 'CLZ05', '2025-09-24'),
(03127459, 'Escitalopram', 3, 'ESC20', '2026-07-18');

INSERT INTO Supplier (supplier_id, name, contact_info, cost, delivery_speed) VALUES
(4230, 'Sun Pharmaceuticals Industries', '800-818-4555', 50.00, 2),
(6421, 'Watson Labs', '760-271-3989', 45.00, 3),
(8473, 'Marley Drug', '800-810-7790', 55.00, 1),
(9123, 'GreenLeaf Pharma', '888-888-8888', 48.00, 4);

INSERT INTO Patient (patient_id, user_id, name, med_history) VALUES
(001, 1, 'John Doe', 'Attention Deficit Hyperactivity Disorder (ADHD)'),
(002, 4, 'Jake Hall', 'Panic Disorder'),
(003, 7, 'Kurt Cobain', 'Major Depressive Disorder');

INSERT INTO Prescription (prescription_id, patient_id, medication_id, dosage, refills) VALUES
(101, 001, 02322951, '30mg', 0),
(102, 002, 02490226, '0.5mg', 1),
(103, 003, 03127459, '20mg', 3);

INSERT INTO Pharmacy (pharmacy_id, address_id) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO Pharmacist (pharmacist_id, user_id) VALUES
(1, 1),
(4, 4),
(7, 7);

INSERT INTO Prescriber (prescriber_id, user_id, med_license, num_of_patients) VALUES
(1, 3, 'LIC12345', 35),
(2, 6, 'LIC67890', 40),
(3, 9, 'LIC11223', 45);

INSERT INTO OrderTable (order_id, pharmacy_id, supplier_id, order_details, status) VALUES
(1025, 1, 4230, 'Order for Lisdexamfetamine', 'Pending'),
(1026, 2, 6421, 'Order for Clonazepam', 'Completed'),
(1027, 3, 8473, 'Order for Escitalopram', 'Cancelled');

INSERT INTO Inventory (inventory_id, pharmacy_id, medication_id, inventory_level, stock_alert, supplier_id) VALUES
(501, 1, 02322951, 100, 10, 4230),  
(502, 2, 02490226, 50, 5, 6421),    
(503, 3, 03127459, 75, 8, 8473); 

INSERT INTO Insurance (insurance_id, name, coverage_info, claims) VALUES
(1, 'Blue Cross Blue Shield', 'Covers prescription drugs and medical services', 15),
(2, 'UnitedHealthcare', 'Provides comprehensive medical and prescription coverage', 20),
(3, 'Aetna', 'Covers generic medications and medical visits', 10);

INSERT INTO Drug_Interaction (interaction_id, amount_of_substances, description, severity) VALUES
(1, 2, 'Interaction between Lisdexamfetamine and Clonazepam can cause increased sedation and drowsiness.', 'moderate'),
(2, 2, 'Interaction between Clonazepam and Escitalopram may increase the risk of serotonin syndrome.', 'high'),
(3, 2, 'Interaction between Lisdexamfetamine and Escitalopram can increase the risk of side effects like jitteriness and anxiety.', 'low');

INSERT INTO Feedback (feedback_id, user_id, rating, comments) VALUES
(1, 1, 5, 'Great service and quick prescription fulfillment.'),
(2, 4, 4, 'Helpful pharmacist but long wait times.'),
(3, 7, 3, 'Average experience; some medications were out of stock.');

-- Weak Entities

INSERT INTO Account (account_id, user_id, creation_date, date_of_birth) VALUES
(1, 1, '2024-01-15 09:00:00', '1990-05-20'),  
(2, 2, '2024-02-20 10:30:00', '1985-08-12'),  
(3, 3, '2024-03-05 14:15:00', '1978-11-03'),  
(4, 4, '2024-03-18 16:45:00', '1995-09-24'),  
(5, 5, '2024-04-10 11:00:00', '1992-04-15'),
(6, 6, '2024-05-10 15:00:00', '1986-02-25'),
(7, 7, '2024-05-10 17:25:00', '1990-09-20'),
(8, 8, '2024-05-10 19:05:00', '1999-04-17'),
(9, 9, '2024-01-10 20:10:00', '2000-01-12');

INSERT INTO Notification (notification_id, user_id, message) VALUES
(1, 1, 'Your prescription for Lisdexamfetamine is ready for pickup.'),  
(2, 2, 'Stock alert: Clonazepam levels are low. Please reorder.'),      
(3, 3, 'New patient assigned: Review the medical profile for Kurt Cobain.'),  
(4, 4, 'Your next refill for Clonazepam is available starting next week.'),  
(5, 7, 'Your upcoming appointment has been scheduled for the 20th of this month.');  

INSERT INTO Renewal (renewal_id, prescription_id, renewal_date, times_renewed) VALUES
(1, 101, '2024-03-01', 1),  
(2, 102, '2024-04-15', 2),  
(3, 103, '2024-05-10', 0),  
(4, 101, '2024-06-15', 2),  
(5, 102, '2024-07-20', 3);  

INSERT INTO Payment (payment_id, prescription_id, method, status) VALUES
(1, 101, 'Credit', 'Completed'),
(2, 102, 'Insurance', 'Pending'),
(3, 103, 'Cash', 'Pending'),
(4, 101, 'Insurance', 'Refunded'),
(5, 102, 'Credit', 'Completed');

INSERT INTO Inventory_Audit (audit_id, inventory_id, audit_date, audit_conductor) VALUES
(1, 501, '2024-04-01', 1), 
(2, 502, '2024-05-15', 4), 
(3, 503, '2024-06-20', 7), 
(4, 501, '2024-07-05', 1), 
(5, 502, '2024-08-10', 4); 

-- Associative Entities

INSERT INTO UserAddress (address_id, user_id) VALUES
(1, 1),  
(2, 2),  
(3, 3),  
(1, 4),  
(2, 5);  

INSERT INTO MedicationInteraction (interaction_id, medication_id) VALUES
(1, 02322951),  
(1, 02490226),  
(2, 02490226),  
(2, 03127459),  
(3, 02322951);  

INSERT INTO PatientInsurance (patient_id, insurance_id) VALUES
(1, 1),  
(2, 2),  
(3, 3),  
(1, 2),  
(2, 3);  


