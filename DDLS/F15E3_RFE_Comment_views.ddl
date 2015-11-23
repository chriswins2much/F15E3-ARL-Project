CREATE OR REPLACE PROCEDURE status_name
(
  status_no INTEGER
)
RETURN VARCHAR2
AS
  stat_name VARCHAR2
BEGIN
  SELECT rfe_status 
  INTO stat_name 
  FROM F15E3_Status
  WHERE status_id = status_no; 	
  
  RETURN stat_name;
END;
/

CREATE OR REPLACE PROCEDURE emp_name
(
  emp_no INTEGER
)
RETURN VARCHAR2
AS
  emp_name VARCHAR2
BEGIN
  SELECT employee_name 
  INTO emp_name
  FROM F15E3_Employee
  WHERE employee_id = emp_no; 	
  
  RETURN emp_name;
END;
/

CREATE OR REPLACE PROCEDURE get_lab_code
(
  lab_no INTEGER
)
RETURN VARCHAR2
AS
  my_lab_code VARCHAR2
BEGIN
  SELECT lab_code 
  INTO my_lab_code
  FROM F15E3_Lab
  WHERE lab_id = lab_no; 	
  
  RETURN my_lab_code;
END;
/

drop view F15E3_RFE_Search_view;

create view F15E3_RFE_Search_view as
	SELECT rfe.RFE_ID AS 'RFE ID', 
		emp.employee_name AS Requestor, 
		get_lab_code(emp.F15E3_Lab_lab_id) AS Lab
		status_name(rfe.F15E3_Status_status_id) AS Status, 
		stat_his.effective_date AS 'Status Eff Date',
		comm.comment_body AS 'Last Comments'
	FROM F15E3_RFE rfe
		INNER JOIN F15E3_Contacts con ON con.F15E3_RFE_rfe_id = rfe.ID AND con.role_id = '1' -- requestor
		INNER JOIN F15E3_Employee emp ON con.F15E3_Employee_employee_id = emp.emp_id
		INNER JOIN F15E3_Status_History stat_his ON stat_his.F15E3_Status_status_id = rfe.F15E3_Status_status_id
		INNER JOIN F15E3_Comment comm ON rfe.RFE_ID = comm.F15E3_RFE_rfe_id
	WHERE comm.comment_entry_date = (SELECT MAX(comm2.comment_entry_date) FROM F15E3_Comment comm2 WHERE rfe.RFE_ID = comm2.F15E3_Status_status_id);