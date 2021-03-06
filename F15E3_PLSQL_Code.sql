drop function role_name;

CREATE OR REPLACE FUNCTION role_name
(
  role_no INTEGER
)
RETURN VARCHAR2
IS
  rol_name VARCHAR2(30);
BEGIN
  SELECT role_type 
  INTO rol_name 
  FROM F15E3_Role_Type
  WHERE role_id = role_no;  
  
  RETURN rol_name;
END;
/

drop function status_name;

CREATE OR REPLACE FUNCTION status_name
(
  status_no INTEGER
)
RETURN VARCHAR2
IS
  stat_name VARCHAR2(30);
BEGIN
  SELECT rfe_status 
  INTO stat_name 
  FROM F15E3_Status
  WHERE status_id = status_no;  
  
  RETURN stat_name;
END;
/

drop function emp_name;

CREATE OR REPLACE FUNCTION emp_name
(
  emp_no INTEGER
)
RETURN VARCHAR2
IS
  emp_name VARCHAR2(30);
BEGIN
  SELECT employee_name 
  INTO emp_name
  FROM F15E3_Employee
  WHERE employee_id = emp_no;   
  
  RETURN emp_name;
END;
/

drop function get_lab_code;

CREATE OR REPLACE FUNCTION get_lab_code
(
  lab_no INTEGER
)
RETURN VARCHAR2
IS
  my_lab_code VARCHAR2(4);
BEGIN
  SELECT lab_code 
  INTO my_lab_code
  FROM F15E3_Lab
  WHERE lab_id = lab_no;    
  
  RETURN my_lab_code;
END;
/

drop function latest_comment;

CREATE OR REPLACE FUNCTION latest_comment
(
  rfe_no INTEGER
)
RETURN INTEGER
IS
  lat_com INTEGER;
BEGIN
  SELECT MAX(comm2.comment_id) 
  INTO lat_com
  FROM F15E3_Comment comm2
  WHERE rfe_no = comm2.F15E3_RFE_rfe_id;
  
  RETURN lat_com;
END;
/