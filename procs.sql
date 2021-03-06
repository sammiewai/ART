/*Ordering Sites*/
DELIMITER //
CREATE OR REPLACE PROCEDURE proc_save_ordering_sites(
    IN facility_code VARCHAR(30), 
    IN facility_name VARCHAR(150),
    IN county_name VARCHAR(30)
    )
BEGIN
    DECLARE county,master,subcounty,facility INT DEFAULT NULL;
    SET facility_name = REPLACE(facility_name, "'", "");
    SET county_name = REPLACE(county_name, "'", "");
    SELECT id INTO county FROM tbl_county WHERE name LIKE CONCAT('%', county_name , '%');
    SELECT id INTO master FROM tbl_facility_master WHERE code LIKE CONCAT('%', facility_code , '%') AND name LIKE CONCAT('%', facility_name , '%');
    SELECT id INTO facility FROM tbl_facility WHERE name LIKE CONCAT('%', facility_name , '%');
    IF (county IS NULL) THEN 
        INSERT INTO tbl_county(name)VALUES(LOWER(county_name));
        SET county = LAST_INSERT_ID();
    END IF;
    IF (master IS NULL) THEN 
        SELECT sb.id INTO subcounty FROM tbl_county_sub sb INNER JOIN tbl_county c ON c.id = sb.county_id WHERE c.id = county LIMIT 1;
        IF (subcounty IS NULL) THEN 
            INSERT INTO tbl_county_sub(name)VALUES('N/A');
            SET subcounty = LAST_INSERT_ID();
        END IF;
        INSERT INTO tbl_facility_master(code, name, county_sub_id)VALUES(facility_code, LOWER(facility_name), subcounty);
        SET master = LAST_INSERT_ID();
    END IF;
    IF (facility IS NULL) THEN
        INSERT INTO tbl_facility(name, master_id) VALUES(facility_name, master);
    ELSE
        UPDATE tbl_facility SET name = facility_name, master_id = master  WHERE id = facility;
    END IF;
END//
DELIMITER ;

/*Current ART Patients*/
DELIMITER //
CREATE OR REPLACE PROCEDURE proc_save_current_art_patients(
	IN facility_name VARCHAR(150), 
	IN regimen_code VARCHAR(6),
	IN patient_total INT(11),
	IN p_month VARCHAR(3),
	IN p_year INT(4)
	)
BEGIN
	DECLARE facility,regimen INT DEFAULT NULL;
    SET facility_name = REPLACE(facility_name, "'", "");
    SELECT id INTO facility FROM tbl_facility WHERE name LIKE CONCAT('%', facility_name , '%');
    SELECT id INTO regimen FROM tbl_regimen WHERE code LIKE CONCAT('%', regimen_code , '%');
    IF (facility IS NULL) THEN 
    	INSERT INTO tbl_facility(name)VALUES(facility_name);
    	SET facility = LAST_INSERT_ID();
    END IF;
    IF (regimen IS NULL) THEN 
    	INSERT INTO tbl_regimen(code)VALUES(regimen_code);
    	SET regimen = LAST_INSERT_ID();
    END IF;
    IF NOT EXISTS(SELECT * FROM tbl_regimen_patient WHERE period_year = p_year AND period_month = p_month AND regimen_id = regimen AND facility_id = facility) THEN
        INSERT INTO tbl_regimen_patient(total, period_year, period_month, regimen_id, facility_id) VALUES(patient_total, p_year, p_month, regimen, facility);
    ELSE
        UPDATE tbl_regimen_patient SET total = patient_total WHERE period_year = p_year AND period_month = p_month AND regimen_id = regimen AND facility_id = facility;
    END IF;
END//
DELIMITER ;


/*Pipeline Consumption*/
DELIMITER //
CREATE OR REPLACE PROCEDURE proc_save_pipeline_consumption(
	IN drug_name VARCHAR(150), 
	IN packsize VARCHAR(10),
	IN period_year INT(4),
	IN period_month VARCHAR(3),
	IN consumption_total INT(10)
	)
BEGIN
	DECLARE drug INT DEFAULT NULL;
    SET drug_name = REPLACE(drug_name, "'", "");
    SELECT id INTO drug FROM tbl_drug WHERE name LIKE CONCAT('%', drug_name , '%') AND pack_size LIKE CONCAT('%', packsize , '%');
    IF (drug IS NULL) THEN 
    	INSERT INTO tbl_drug(name, pack_size)VALUES(drug_name, packsize);
    	SET drug = LAST_INSERT_ID();
    END IF;
    IF NOT EXISTS(SELECT * FROM tbl_consumption_pipeline WHERE period_year = period_year AND period_month = period_month AND drug_id = drug) THEN
        INSERT INTO tbl_consumption_pipeline(total, period_year, period_month, drug_id) VALUES(consumption_total, period_year, period_month, drug);
    ELSE
        UPDATE tbl_consumption_pipeline SET total = consumption_total WHERE period_year = period_year AND period_month = period_month AND drug_id = drug; 
    END IF;
END//
DELIMITER ;

/*Facility Consumption*/
DELIMITER //
CREATE OR REPLACE PROCEDURE proc_save_facility_consumption(
    IN facility_name VARCHAR(150),
    IN drug_name VARCHAR(150), 
    IN packsize VARCHAR(10),
    IN period_year INT(4),
    IN period_month VARCHAR(3),
    IN consumption_total INT(10)
    )
BEGIN
    DECLARE facility,drug INT DEFAULT NULL;
    SET facility_name = REPLACE(facility_name, "'", "");
    SET drug_name = REPLACE(drug_name, "'", "");
    SELECT id INTO facility FROM tbl_facility WHERE name LIKE CONCAT('%', facility_name , '%');
    SELECT id INTO drug FROM tbl_drug WHERE name LIKE CONCAT('%', drug_name , '%') AND pack_size LIKE CONCAT('%', packsize , '%');
    IF (facility IS NULL) THEN 
        INSERT INTO tbl_facility(name)VALUES(facility_name);
        SET facility = LAST_INSERT_ID();
    END IF;
    IF (drug IS NULL) THEN 
        INSERT INTO tbl_drug(name, pack_size)VALUES(drug_name, packsize);
        SET drug = LAST_INSERT_ID();
    END IF;
    IF NOT EXISTS(SELECT * FROM tbl_consumption_facility WHERE period_year = period_year AND period_month = period_month AND facility_id = facility AND drug_id = drug) THEN
        INSERT INTO tbl_consumption_facility(total, period_year, period_month, facility_id, drug_id) VALUES(consumption_total, period_year, period_month, facility, drug);
    ELSE
        UPDATE tbl_consumption_facility SET total = consumption_total WHERE period_year = period_year AND period_month = period_month AND facility_id = facility AND drug_id = drug; 
    END IF;
END//
DELIMITER ;

/*Facility SOH*/
DELIMITER //
CREATE OR REPLACE PROCEDURE proc_save_facility_soh(
    IN facility_name VARCHAR(150),
    IN drug_name VARCHAR(150), 
    IN packsize VARCHAR(10),
    IN period_year INT(4),
    IN period_month VARCHAR(3),
    IN soh_total INT(10)
    )
BEGIN
    DECLARE facility,drug INT DEFAULT NULL;
    SET facility_name = REPLACE(facility_name, "'", "");
    SET drug_name = REPLACE(drug_name, "'", "");
    SELECT id INTO facility FROM tbl_facility WHERE name LIKE CONCAT('%', facility_name , '%');
    SELECT id INTO drug FROM tbl_drug WHERE name LIKE CONCAT('%', drug_name , '%') AND pack_size LIKE CONCAT('%', packsize , '%');
    IF (facility IS NULL) THEN 
        INSERT INTO tbl_facility(name)VALUES(facility_name);
        SET facility = LAST_INSERT_ID();
    END IF;
    IF (drug IS NULL) THEN 
        INSERT INTO tbl_drug(name, pack_size)VALUES(drug_name, packsize);
        SET drug = LAST_INSERT_ID();
    END IF;
    IF NOT EXISTS(SELECT * FROM tbl_soh_facility WHERE period_year = period_year AND period_month = period_month AND facility_id = facility AND drug_id = drug) THEN
        INSERT INTO tbl_soh_facility(total, period_year, period_month, facility_id, drug_id) VALUES(soh_total, period_year, period_month, facility, drug);
    ELSE
        UPDATE tbl_soh_facility SET total = soh_total WHERE period_year = period_year AND period_month = period_month AND facility_id = facility AND drug_id = drug; 
    END IF;
END//
DELIMITER ;