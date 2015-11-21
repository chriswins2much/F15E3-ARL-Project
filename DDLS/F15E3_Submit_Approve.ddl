-- View for pushing an RFE along in the review process
drop view F15E3_RFE_approve_view;

create view F15E3_RFE_approve_view as
SELECT rfe_id
FROM F15E3_RFE;

-- Approve RFE Trigger - Update Status/Time
CREATE OR REPLACE TRIGGER F15E3_RFE_approve_trigger
   INSTEAD OF UPDATE ON F15E3_RFE_approve_view
   DECLARE
     rfe_no NUMBER;
     status_no NUMBER;
   BEGIN
     rfe_no := :NEW.rfe_id;

     SELECT F15E3_Status_status_id 
     INTO status_no
     FROM F15E3_RFE
     WHERE rfe_id = rfe_no;

     IF status_no = 1 THEN
      status_no := 2;-- Entered -> Submitted
     ELSIF status_no = 2 THEN
      status_no := 6; -- Submitted -> SA Approved
     ELSIF status_no = 6 THEN 
      status_no := 7; -- SA Approved -> LD Approval
     ELSIF status_no = 7 THEN 
      status_no := 8; -- LD Approval -> CH Approval
     ELSIF status_no = 8 THEN 
      status_no := 9; -- CH Approval -> Final Approved
     END IF;

     UPDATE F15E3_RFE 
     SET F15E3_Status_status_id = status_no -- 2 Is the 'submitted' status
     WHERE rfe_id = rfe_no;

     INSERT INTO F15E3_Status_History(
      status_history_id, 
      F15E3_RFE_rfe_id,
      F15E3_Status_status_id,
      effective_date,
      entered_by_emp_id) 
     VALUES (
      F15E3_Status_History_seq.nextval, 
      rfe_no,
      status_no,
      localtimestamp,
      v('P100_LOGIN_EMP_ID'));

   -- TODO: Auto email

    END F15E3_RFE_approve_trigger;
/

-- View for Updating the status of an RFE arbitrarily
drop view F15E3_RFE_status_update_view;

create view F15E3_RFE_status_update_view as
SELECT rfe_id, F15E3_STATUS_STATUS_ID
FROM F15E3_RFE;

-- Reject/Recall/Return RFE Trigger - Update Status/Time
CREATE OR REPLACE TRIGGER F15E3_RFE_stat_update_trigger
   INSTEAD OF UPDATE ON F15E3_RFE_status_update_view
   DECLARE
     rfe_no NUMBER;
     status_no NUMBER;
     comment_text VARCHAR2(4000);
   BEGIN
     rfe_no := :NEW.rfe_id;
     status_no := :NEW.F15E3_Status_status_id;

     UPDATE F15E3_RFE 
     SET F15E3_Status_status_id = status_no
     WHERE rfe_id = rfe_no;

     INSERT INTO F15E3_Status_History(
      status_history_id, 
      F15E3_RFE_rfe_id,
      F15E3_Status_status_id,
      effective_date,
      entered_by_emp_id) 
     VALUES (
      F15E3_Status_History_seq.nextval, 
      rfe_no,
      status_no,
      localtimestamp,
      v('P100_LOGIN_EMP_ID'));

    -- TODO: Auto email

    -- Auto comment
    SELECT ((SELECT description FROM F15E3_Status 
               WHERE status_id = status_no) 
            || ' Automatic comment by ' 
            || (SELECT employee_name FROM F15E3_Employee 
                  WHERE employee_id = v('P100_LOGIN_EMP_ID'))
            || ' at ' || localtimestamp || '.')
    INTO comment_text
    FROM Dual;

    INSERT INTO F15E3_Comment (
      comment_id,
      F15E3_RFE_rfe_id,
      entered_by_emp_id,
      comment_entry_date,
      comment_body)
    VALUES (
      F15E3_Comment_seq.nextval,
      rfe_no,
      v('P100_LOGIN_EMP_ID'),
      localtimestamp,
      comment_text);

    END F15E3_RFE_stat_update_trigger;
/

-- View for Duplicating RFEs
drop view F15E3_RFE_dup_view;

create view F15E3_RFE_dup_view as
SELECT rfe_id
FROM F15E3_RFE;

-- Duplicate RFE Trigger - Select RFE and use info to create new RFE
CREATE OR REPLACE TRIGGER F15E3_RFE_dup_trigger
   INSTEAD OF INSERT ON F15E3_RFE_dup_view
   DECLARE
     rfe_no NUMBER;
   BEGIN
     rfe_no := :NEW.rfe_id;

     INSERT INTO F15E3_RFE_create_view(
        explanation,
        alt_protections)
     VALUES (
        (SELECT explanation FROM F15E3_RFE WHERE rfe_id = rfe_no),
        (SELECT alt_protections FROM F15E3_RFE WHERE rfe_id = rfe_no));

    END F15E3_RFE_dup_trigger;
/