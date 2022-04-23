libname in "F:\Yorghos Class";
/*1. Using PROC SQL, recreate the following table*/
/*	data hosp2;
	set in.admissions;
	if hosp = 2;
	keep pt_id hosp admdate didate;
	run;
*/
libname hw7"/home/u59331108";
data hosp2;
	set hw7.admissions;
	if hosp = 2;
	keep pt_id hosp admdate didate;
	run;
	
PROC SQL;
	SELECT pt_id, hosp,  admdate , disdate 
			/*commas required between elements; establishes order*/
	FROM hw7.admissions
	WHERE hosp=2;
QUIT;

/*2. Using PROC SQL, select only admissions with length of stay 21+ days*/

PROC SQL;
	CREATE TABLE ans2 AS
	SELECT 	pt_id, hosp, admdate, disdate,
			(disdate-admdate) + 1 AS los LABEL='Length of Stay'
	FROM hw7.admissions
	WHERE CALCULATED los GE 21 /*Calculated Statement required to subset on new vars*/
	ORDER BY pt_id, los desc;
QUIT;

proc print data=ans2 label;run;

/*3. Using PROC SQL, how many different subjects are in the ERVISITS
     dataset?  List them.*/

proc sql;
create table ans3 as 
select distinct pt_id
from hw7.admissions;
quit;

PROC SQL;
SELECT count(distinct pt_id) AS num_pt
FROM hw7.admissions;
QUIT;

proc print data=ans3;
run;
/*4a. Using PROC SQL, create a new table that includes all the information from
	 ADMISSIONS, and properly links gender, dob and primary MD ID from
	 PATIENTS.  Be sure to format variables properly.*/

PROC SQL FEEDBACK;
	CREATE TABLE ans4 AS
	SELECT a.pt_id, a.admdate, a.disdate, a.hosp, a.md, b.sex,b.primmd
	FROM hw7.admissions a,
	     hw7.patients b
	WHERE a.pt_id = b.id
	ORDER BY a.pt_id, a.admdate;
QUIT;
proc print data=ans4;var _all_;run;


/*4b.  Same query as above, but include primary MD NAME*/

PROC SQL FEEDBACK;
	CREATE TABLE ans4b AS
	SELECT a.pt_id, a.admdate, a.disdate, a.hosp, a.md, b.sex,b.primmd, b.lastname, b.firstname
	FROM hw7.admissions a,
	     hw7.patients b
	WHERE a.pt_id = b.id
	ORDER BY a.pt_id, a.admdate;
QUIT;
proc print data=ans4b;var _all_;run;

/*5. Using PROC SQL, perform a full outer join of admissions and er visits, keep
     only one variable of pt_id, admission/ER visit date, and hospital*/

PROC SQL;
CREATE TABLE ans5 AS
SELECT
COALESCE(a.pt_id, b.pt_id, a.admdate, b.visitdate,) AS pt_id FORMAT=Z3.,
b.pt_id , b.visitdate, a.hosp
FROM
in.admissions AS a 
FUll JOIN
in.ervisits AS b
ON a.pt_id =  b.pt_id;
QUIT;

proc print data=ans5;
run;

/*6a. Using PROC SQL, find the following information:
	 Number of patients w/ ER visits, Earliest ER visit, Latest ER visit*/
PROC SQL;
SELECT 
MIN(visitdate) AS start_f FORMAT=date9. LABEL='Earliest ER Visit',
  MAX(visitdate) AS start_l FORMAT=date9. LABEL='Latest ER vist',
N(PT_id) AS N_ID LABEL="Number of PATIENTS"   
      FROM in.ervisits;   
QUIT; 

/*6b.  Same as 6a, but get the information by hospital*/
PROC SQL;
SELECT 
MIN(visitdate) AS start_f FORMAT=date9. LABEL='Earliest ER Visit',
  MAX(visitdate) AS start_l FORMAT=date9. LABEL='Latest ER vist',
N(PT_id) AS N_ID LABEL="Number of PATIENTS" 
  
      FROM in.ervisits
GROUP BY er; 
  
QUIT;

/*6c.  Same as 6b Continued, but only keep information for ERs with 4+ patients*/
PROC SQL;
SELECT 
MIN(visitdate) AS start_f FORMAT=date9. LABEL='Earliest ER Visit',
  MAX(visitdate) AS start_l FORMAT=date9. LABEL='Latest ER vist',
N(PT_id) AS N_ID LABEL="Number of PATIENTS" 
  
      FROM in.ervisits
GROUP BY er
Having n_id ge 4 ;  
QUIT;

/*7. Use a subquery, only keep observations from our "FAKE" dataset that
  	 have IDs NOT found in our list of SUBJECTS*/

proc sql;
SELECT Sub_ID FROM hw7.subjects;
run;
PROC SQL;
	CREATE TABLE ans7 AS
		SELECT * FROM hw7.fake
		WHERE id IN
			(SELECT Sub_ID FROM hw7.subjects) /* This is the subquery */
		ORDER BY id, startdt;
QUIT;
	proc print data = hw7.fake;run;
	proc print data =all_sub; run;

/*8a. Create two macro variables:
	  1. Number of Admissions
	  2. Number of Unique Patients w/ an admission*/
PROC SQL;
	SELECT PUT(N(pt_id),5.),
	   	   PUT(N(DISTINCT pt_id),5.)
	INTO :ans8a,
		 :ans8aid
	FROM hw7.admissions;
QUIT;

/*8b. Print these macro variables to the log w/ a descriptive sentence for context*/
%put number of admissions = &ans8a.;
%put Unique patients = &ans8aid.;

/*8c.  Create one unique macro variable per patient ID in the ERVISITS set
	   Print all IDs to the log
	   (Hint: First create a macro variable to score number of unique patients)*/
PROC SQL;
SELECT DISTINCT pt_id
INTO :PT_id_list SEPARATED BY ', '
FROM hw7.ervisits;
QUIT;
%put &PT_id_list.;
