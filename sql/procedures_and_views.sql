USE pharmadb;

 /*
     Business Requirement #1
     ----------------------------------------------------
     Purpose: Automated Stock Shortage Reordering
     
     Description: The system must monitor inventory levels for medications in real-time and trigger an 
 		  automated reorder when the stock level of a medication falls below a predefined threshold.  

     Challenge:   The system must be able to dynamically calculate projected stock levels based on inventory and usage rates, 
                  accurately assess the need for reorder, and ensure that the logic can handle 
                  multiple pharmacies, suppliers, and medications. 
                  
     Assumptions:
      - Medication stock levels are up to date in the Inventory table.

     Implementation Plan:
        1. Create a stored procedure to handle stock shortages
        2. Check inventory levels against thresholds
        3. Insert reorder details into OrderTable when triggered
        4. Provide an example usage
 */

DELIMITER $$


DROP PROCEDURE IF EXISTS ManageStockShortage $$

-- 1
CREATE PROCEDURE ManageStockShortage(
    IN p_medication_id INT,
    IN p_threshold INT,
    IN p_usage_rate FLOAT,
    IN p_pharmacy_id INT,
    IN p_supplier_id INT,
    IN p_reorder_quantity INT
)
BEGIN
	-- 2
    DECLARE current_stock INT DEFAULT 0;
    DECLARE projected_stock INT;
    DECLARE reorder_triggered BOOLEAN DEFAULT FALSE;

    SELECT COALESCE(SUM(inventory_level), 0) INTO current_stock
    FROM Inventory
    WHERE medication_id = p_medication_id AND pharmacy_id = p_pharmacy_id;

    SET projected_stock = current_stock - (p_usage_rate * p_threshold);

    -- 3
    IF projected_stock < p_threshold THEN
        INSERT INTO OrderTable (pharmacy_id, supplier_id, order_details, status)
        VALUES (p_pharmacy_id, p_supplier_id, CONCAT('Reorder for Medication ID: ', p_medication_id), 'Pending');

        SET reorder_triggered = TRUE;
    END IF;

    IF reorder_triggered THEN
        SELECT CONCAT("Reorder triggered for Medication ID: ", p_medication_id) AS Status;
    ELSE
        SELECT CONCAT("No reorder needed for Medication ID: ", p_medication_id) AS Status;
    END IF;
END $$

DELIMITER ;

-- 4
CALL ManageStockShortage(2322951, 50, 2, 1, 4230, 300);



/*
    Business Requirement #2
    ----------------------------------------------------
    Purpose: Medication Expirement Date Management
    
    Description: The system must notify staff about medications nearing expiration 
    		 within a 6 month time frame. Notifications should include the medication name, 
                 expiration date, and total stock levels.

    Challenge: The system must aggregate inventory levels for each medication and ensure timely 
    	       notifications to avoid medical waste and ensure optimal system performance.
    
    Assumptions:
    - Inventory levels are up to date in the Inventory table.

    Implementation Plan:
	1. Create stored procedure to handle expiration date notifications
        2. Insert a notification for pharmacists that includes the name of the medication, its expiration date, and the total stock level.
        3. Use aggregation to get medication stock levels from the Inventory
        4. Provide an example usage
        
*/

DELIMITER $$

DROP PROCEDURE IF EXISTS NotifyAboutExpiration $$

-- 1
CREATE PROCEDURE NotifyAboutExpiration(
    IN p_days_till_expiration INT
)
BEGIN
    -- This DELETE statement is to ensure the Notifications table doesn't get filled with duplicates (which happened a lot during multiple test runs)
    DELETE FROM Notification;

    -- 2
    INSERT INTO Notification (user_id, message)
    SELECT 
        User.user_id, 
        CONCAT(
            'Medication "', Medication.name, '" (ID: ', Inventory.medication_id, ') is expiring on ', Medication.expiration_date, 
            '. Current stock: ', Inventory.inventory_level, '.'
        ) AS message
    FROM 
        Medication 
    JOIN 
        Inventory ON Medication.medication_id = Inventory.medication_id
    JOIN 
        User ON User.role = 'pharmacist'
    WHERE 
        -- INTERVAL is used here because "Medication.expiration_date <= (CURDATE() + p_days_to_expiry);" was resulting
        -- in an empty Notification table
        -- 3
        Medication.expiration_date <= DATE_ADD(CURDATE(), INTERVAL p_days_till_expiration DAY);

END $$

DELIMITER ;

# The number 180 is being used here to align with the 6 month time frame
-- 4
CALL NotifyAboutExpiration(180);
SELECT * FROM Notification;



/*
    Business Requirement #3
    ----------------------------------------------------
    Purpose: Supplier Diversification
    
    Description: The system must integrate with multiple suppliers and automatically 
    		 select the best supplier based on cost, availability, and delivery speed. This is to ensure 
    		 patients have consistent access to their medications.

    Challenge: The system must determine the best supplier for a given medication and 
    	       ensure accurate and efficient supplier selection.
    
    Assumptions:
    - Supplier table has valid up to date data

    Implementation Plan:
        1. Create procedure to select the best supplier.
        2. Use aggregation to get the minimum possible cost of medication.
        3. Insert the data into the OrderTable.
        4. Automatically select the best supplier, place an order, and notify the staff.
        5. Provide an example usage. 
*/

DELIMITER $$

DROP PROCEDURE IF EXISTS SelectBestSupplier $$

-- 1
CREATE PROCEDURE SelectBestSupplier(
    IN medication_id_param INT,
    IN quantity_needed INT
)
BEGIN
    
    DECLARE best_supplier_id INT;
    DECLARE lowest_cost DECIMAL(10, 2);
    DECLARE delivery_speed INT;

    -- 2
    SELECT Supplier.supplier_id, MIN(Supplier.cost) AS min_cost, Supplier.delivery_speed
    INTO best_supplier_id, lowest_cost, delivery_speed
    FROM Supplier 
    JOIN Inventory ON Supplier.supplier_id = Supplier.supplier_id
    WHERE Inventory.medication_id = medication_id_param
    GROUP BY Supplier.supplier_id
    ORDER BY min_cost, delivery_speed ASC
    LIMIT 1;
    
    -- 3
    INSERT INTO OrderTable (pharmacy_id, supplier_id, order_details, status)
    VALUES (1, best_supplier_id, CONCAT('Order for Medication ID: ', medication_id_param), 'Pending');

    -- 4
    SELECT CONCAT('Order placed with Supplier ID: ', best_supplier_id, '. Cost: ', lowest_cost, '. Delivery speed: ', delivery_speed, ' days.') AS Supplier_Notification;
END $$

DELIMITER ;

-- 5
CALL SelectBestSupplier(2322951, 100);

/*
    Business Requirement #4
    ----------------------------------------------------
    Purpose: Drug Interaction Severity Informer
    
    Description: The system must analyze drug interaction data to identify the 
                 most severe interactions and notify pharmacists about medications 
                 with frequent high severity interactions. This ensures patient 
                 safety and effective medication management.

    Challenge: The system must aggregate interaction data and rank medications based on the 
               frequency of high severity interactions. Ensuring accurate and 
               timely notification to pharmacists to prevent potential risks.

    Assumptions:
     - The Drug_Interaction table contains valid severity levels.
     - Medications with high severity interactions are already mapped out in the MedicationInteraction table.

    Implementation Plan:
	1. Create procedure to get medication interaction severity.
        2. Use aggregation to get total number of drug interactions.
        3. Use aggregation to get top medications with the most interactions.
        4. Insert a notification to the pharmacists about the top medications with the most high risk interactions.
        5. Provide an example usage.
*/

DELIMITER $$

DROP PROCEDURE IF EXISTS GetInteractionSeverity $$

-- 1
CREATE PROCEDURE GetInteractionSeverity()
BEGIN
    -- 2
    SELECT 
        severity,
        COUNT(*) AS total_interactions
    FROM Drug_Interaction
    GROUP BY severity
    ORDER BY FIELD(severity, 'high', 'moderate', 'low') DESC;

    -- 3
    SELECT 
        Medication.name AS medication_name,
        COUNT(MedicationInteraction.interaction_id) AS interaction_count
    FROM Medication 
    JOIN MedicationInteraction ON Medication.medication_id = MedicationInteraction.medication_id
    GROUP BY Medication.medication_id, Medication.name
    ORDER BY interaction_count DESC
    LIMIT 5;

    -- 4
    INSERT INTO Notification (user_id, message)
    SELECT 
        user_id, 
        CONCAT(
            'High-severity drug interactions are common. Top medication: ', 
            (SELECT Medication.name 
             FROM Medication 
             JOIN MedicationInteraction ON Medication.medication_id = MedicationInteraction.medication_id 
             JOIN Drug_Interaction ON MedicationInteraction.interaction_id = Drug_Interaction.interaction_id 
             WHERE Drug_Interaction.severity = 'high' 
             GROUP BY Medication.name 
             ORDER BY COUNT(MedicationInteraction.interaction_id) DESC LIMIT 1), 
            '. Please review interactions for patient safety.'
        )
    FROM User
    WHERE role = 'pharmacist';
END $$

DELIMITER ;

-- 5
CALL GetInteractionSeverity();


/*
    Business Requirement #5
    ----------------------------------------------------
    Purpose: Patient Prescription History View
    
    Description: The system must display a detailed view of a patient's prescription history. 
		 This view that must show the patient's medication information, dosage, refill counts, and 
                 prescription dates.
        

    Challenge: The system must create an up to date view that provides accurate access to historical data.
	       This is to provide up to date information so patients and prescribers can make
               the best decisions going forward. 
	
    Assumptions
     - None
               
	Implementation Plan:
	1. Create a view that integrates information from Prescription, Medication, and Inventory tables
        2. Provide an example usage
*/

DROP VIEW IF EXISTS PatientPrescriptionHistory;

-- 1
CREATE VIEW PatientPrescriptionHistory AS
SELECT 
    Patient.name as patient_name,
    Medication.name as medication_name,
    Prescription.dosage,
    Prescription.refills,
    Prescription.prescription_id,
    Prescription.patient_id,
    Prescription.medication_id
FROM 
    Prescription
JOIN 
    Patient ON Prescription.patient_id = Patient.patient_id
JOIN 
    Medication ON Prescription.medication_id = Medication.medication_id;

-- 2
SELECT * FROM PatientPrescriptionHistory;

