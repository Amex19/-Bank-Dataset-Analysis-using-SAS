libname Bank "C:\Toronto\SAS Final Project\Project Data";

/* 1. BANK CUSTOMER DATA PROFILING */

PROC CONTENTS DATA = Bankcustomer;
run;
 
/* OR */
PROC CONTENTS DATA = Bankcustomer OUT= Bankcustomer_VARIABLES;
RUN;
  
PROC CONTENTS DATA = Bankcustomer VARNUM SHORT;
RUN;

PROC PRINT DATA = Bankcustomer (OBS=100);
RUN;

/*CHECK and DROP DUPLICATE OBSERVATION IF EXIST IN THE DATA SET */
TITLE " DUPLICATE VALUES IN THE DATASET"; 

PROC SORT DATA=Bankcustomer  OUT=Bankcustomer NODUPKEY;
 BY _ALL_;
RUN;

/* 2. VARIABLE SELECTION * /

/* AcctAge DDA DDABal CashBk Checks DirDep NSF NSFAmt Phone Teller Sav SavBal ATM ATMAmt POS POSAmt CD CDBal IRA IRABal 
LOC LOCBal ILS ILSBal MM MMBal MMCred MTG MTGBal CC CCBal CCPurc SDB Income HMOwn LORes HMVal Age CRScore Moved InArea 
Ins Branch Res Dep DepAmt Inv InvBal */ 

/*EDA */

/*VARIABLE SELECTION*/
/*  
y = DDA(Active/Inactive)

Xs varaibles
X1- demogrpahics: AcctAge, Age, Income	CRScore
X2 - products: NSF,LOC, MTG, CC, CCPurc, 	 
X3 - Customer Banking Habit: Teller, checks 
 

 y=X1+X2+X3+X3 

/*univarite analysis*/

/*1. Distribution: summary and visualization
  2. Missing values
  3. Outliers
  4. How data/varaibles are gathered and generated: features leakage or data leakage
  5. Data Transformation */

PROC SQL;
CREATE TABLE  Bankcustomer_variables As
SELECT DDA,
       AcctAge, Age,Income, CRScore,	
	   NSF, LOC, MTG, CC, CCPurc,   
	   Teller, checks,Branch
	   FROM Bankcustomer
	   ;
	   QUIT;
	   PROC PRINT; RUN;

	   /*BANK CUSTOMER DATA TYPES FOR THE ANALYSIS : NUMERIC(20 FEATURES) AND CATEGORY(1 FEATURES)*/

	   /*NUMERIC DATA FIVE NUMBER SUMMARY: - MIN MAX RANGE MEDIAN STD
        VISUALIZASION:        : HISTORGRAM, DENSITY CURVE, BOX PLOT*/

	   /*CATEGORY: ABSOLUTE FREQ, RELATIVE FREQ AND CUMULATIVE FREQ
        VISUALISATION       : BAR CHART, PIE CHART, */
 
/* 3. DATA DISTRIBUTION OF CONTINOUS VARIABLES */
 
 
PROC MEANS DATA =Bankcustomer_variables MAXDEC=2;* proc means do summarization ( univariate) for all numeric variables;
RUN;

/* OR*/
PROC MEANS DATA=Bankcustomer_variables ;
output out=data_summary; 
Run;
proc print data=data_summary;run;

/* 3.1. FIVE NUMBER SUMMARY OF THE CONTINOUS VARIABLES */
 PROC MEANS DATA = Bankcustomer_variables MAXDEC=2 N NMISS MIN MEDIAN MAX STD CV CLM;
 var AcctAge Age Income CRScore;
RUN;

/* 4. UNIVARIATE ANALYSIS OF CATEGORICAL VARIABLES 
PROC FREQ, PROC SGPLOT, PROC GCHART */
 
/*============================================================ 
                      DDA        */
TITLE "DISTRIBUTION OF CATEGORICAL VARIABLE : DDA";
PROC FREQ DATA = Bankcustomer_variables;
 TABLE DDA;
RUN;
 TITLE "DISTRIBUTION OF CATEGORICAL VARIABLE : DDA";

PROC GCHART DATA =  Bankcustomer_variables ;
PIE DDA/STAT=PCT;
RUN; QUIT;

TITLE "DISTRIBUTION OF  DDA";
PROC GCHART DATA = Bankcustomer_variables;
 PIE DDA;
RUN; QUIT;

/*============================================================ 
                      NSF     */
 TITLE "DISTRIBUTION OF NSF";
PROC FREQ DATA = Bankcustomer_variables;
 TABLE NSF;
RUN; QUIT;

TITLE "DISTRIBUTION CUSTOMERS NSF";
FOOTNOTE "CUSTOMERS NSF PROFILE";
PROC GCHART DATA = Bankcustomer_variables;
 PIE NSF;
RUN; QUIT;

 /* OR */
TITLE " CUSTOMERS FUND INFORMATION ";
PROC GCHART DATA=Bankcustomer_variables;
PIE NSF/type=percent discrete;
legend;
RUN;
 
/* =====================CHECKING MISSING VALUES====================  */

PROC FREQ DATA = Bankcustomer_variables;
 TABLE DDA;
RUN;
Proc FREQ data=Bankcustomer_variables;
Table DDA/Missing;
Run;

/*===================================================================================
                Customer AcctAge    */

TITLE"DISTRIBUTION OF CUSTOMER ACCOUNT AGE";
PROC MEANS DATA = Bankcustomer_var_replaced MAXDEC=2 N NMISS MIN MEAN MEDIAN MAX STD CV CLM;
  VAR AcctAge;
RUN;

PROC UNIVARIATE DATA =Bankcustomer_variables;
 VAR AcctAge;
RUN;

/* CHECKING MISSING VALUES */
PROC FREQ DATA = Bankcustomer_variables;
 TABLE AcctAge;
RUN;

Proc FREQ data=Bankcustomer_variables;
Table AcctAge/Missing;
Run;

/* VISUALIZATION */
TITLE "CUSTOMER ACCOUNT AGE DATA DISTRIBUTION ";
PROC SGPLOT DATA = Bankcustomer_variables ;
 HISTOGRAM AcctAge;
 DENSITY AcctAge;
RUN;
QUIT;

TITLE "VISUALIZATION OF CUSTOMER ACCOUNT";
PROC SGPLOT DATA = Bankcustomer_variables ;
 VBOX AcctAge;
RUN;
QUIT;

 TITLE "DISTRIBUTION AND OUTLIER OF AcctAge";
 FOOTNOTE "DISTRIBUTION AND OUTLIER OF AcctAge";
proc univariate data = Bankcustomer_variables plot normal; 
var AcctAge; 
run;

/* ACCTAGE VARIABLE VALUES ARE NOT NORMALLY DISTRIBUTED AND RIGHT SKEWED, MOST OF THE VALUES ARE IN THE LEFT( MEAN=5.9,MEDAIN=3.9
AND MODE=4.3).HENCE, MISSING VALUES HAS TO BE REPLACED BY "MEDIAN" 
IT HAS 6.42% MISSING VALUES */

TITLE "REPLACING MISSING VALUES OF CUSTOMER ACCOUNT AGE DATA ";
PROC STDIZE DATA = Bankcustomer_variables OUT= Bankcustomer_var_replaced METHOD= MEDIAN REPONLY;
 VAR AcctAge;
RUN;

/* CHECK IF MISSING VALUES WERE REPLACED OR NOT*/

PROC FREQ DATA =  Bankcustomer_var_replaced;
 TABLE AcctAge/MISSING;
RUN;

/*===========AcctAge outlier detection and removal============== */
 
PROC MEANS DATA = Bankcustomer_var_replaced MAXDEC = 2 N NMISS P25 P75 QRANGE ;
 VAR AcctAge;
 OUTPUT OUT=  AcctAge_1 P25 = Q1 P75=Q3 QRANGE=IQR;
RUN;


PROC FORMAT;
 VALUE AcctAg LOW -7.9 ='< 7.9'
            9- 13.9 ='9-13.9 '
			14-19='14-19'
			 ;
RUN;

TITLE" DISTRIBTION OF CUSTOMERS BY ACCOUNT AGE ";
PROC FREQ DATA = AcctAge_01;
 TABLE AcctAge/MISSING;
 FORMAT AcctAge AcctAg.;
RUN;

TITLE" DISTRIBUTION OF CUSTOMERS BANKING EXPERIANCE PROFILE";
FOOTNOTE" CUTOMERS BANKING EXPERINCE FROM ZERO TO 19 MONTHS";
PROC SGPLOT DATA = AcctAge_01 ;
 VBAR AcctAge/datalabel ;
 FORMAT AcctAge AcctAg.  ;
RUN; QUIT;


/*=======================================================*/
/* Customer Age    */
PROC MEANS DATA = Bankcustomer_variables ;
 VAR Age;
RUN;

TITLE" STATESTICAL SUMMARY OF CUSTOMERS AGE";
PROC MEANS DATA = Bankcustomer_var_replaced MAXDEC=2 N NMISS MIN MEAN MEDIAN MAX STD CV CLM;
  VAR Age;
RUN;

PROC UNIVARIATE DATA =Bankcustomer_variables;
 VAR Age;
RUN;

/* CHECKING MISSING VALUES */
PROC FREQ DATA = Bankcustomer_variables;
 TABLE Age;
RUN;
Proc FREQ data=Bankcustomer_variables;
Table Age/Missing;
Run;

/* VISUALIZATION */
TITLE "DISTRIBUTION OF NUMERIC VARIABLE : Customer Age";
FOOTNOTE "DISTRIBUTION OF NUMERIC VARIABLE : Customer Age";
PROC SGPLOT DATA = Bankcustomer_variables ;
 HISTOGRAM Age;
 DENSITY Age;
RUN;
QUIT;

TITLE "DISTRIBUTION OF CUSTOMERS Age";
PROC SGPLOT DATA = Bankcustomer_var_replaced ;
 VBOX Age;
RUN;
QUIT;

/* CUSTOMER AGE VARIABLE VALUES ARE NORMALLY DISTRIBUTE.HENCE, MISSING VALUES HAS TO BE REPLACED BY "MEAN" 
  Age VARIABLE HAS 19.7% MISSING VALUES*/

PROC STDIZE DATA = Bankcustomer_variables OUT= Bankcustomer_var_replaced METHOD= MEAN REPONLY;
 VAR Age;
RUN;
*CHECK IF MISSING VALUES WERE REPLACED OR NOT;
PROC FREQ DATA =  Bankcustomer_var_replaced;
 TABLE Age/MISSING;
RUN;

/* ==========================================================*/

/* Customer Income    */

PROC MEANS DATA = Bankcustomer_variables ;
 VAR Income; RUN;

 PROC MEANS DATA = Bankcustomer_var_replaced MAXDEC=2 N NMISS MIN MEAN MEDIAN MAX STD CV CLM;
  VAR Income;
RUN;

PROC UNIVARIATE DATA =Bankcustomer_variables;
 VAR Income;
RUN;

/* CHECKING MISSING VALUES */
PROC FREQ DATA = Bankcustomer_variables;
 TABLE Income;
RUN;
Proc FREQ data=Bankcustomer_variables;
Table Income/Missing;
Run;

/* CUSTOMER Income VARIABLE VALUES ARE NOT NORMALLY DISTRIBUTE.HENCE, MISSING VALUES HAS TO BE REPLACED BY "MEDIAN" 
       Income variable has 17.92% */

PROC STDIZE DATA = Bankcustomer_variables OUT= Bankcustomer_var_replaced METHOD= MEDIAN REPONLY;
 VAR Income; 
RUN;

*CHECK IF MISSING VALUES WERE REPLACED OR NOT;
PROC FREQ DATA =  Bankcustomer_var_replaced;
 TABLE Income/MISSING;
RUN;

/* VISUALIZATION */
TITLE "CUSTOMERS INCOME DATA DISTRIBUTION";
FOOTNOTE "CUSTOMERS INCOME DATA DISTRIBUTION";
PROC SGPLOT DATA = Bankcustomer_variables plot normal;
 HISTOGRAM Income;
 DENSITY Income;
RUN; QUIT;

PROC univariate data  = Bankcustomer_variables plot normal;
 var Income;
RUN; QUIT;

TITLE "CUSTOMERS INCOME DATA DISTRIBUTION";
PROC SGPLOT DATA = Bankcustomer_variables ;
 VBOX Income;
RUN; QUIT;

/*=================================================================*/ 
/* Customer Non sufficient Fund(NSF)   */

PROC MEANS DATA = Bankcustomer_variables ;
 VAR NSF;
RUN;
PROC MEANS DATA = Bankcustomer_variables MAXDEC=2 N NMISS MIN MEAN MEDIAN MAX STD CV CLM;
  VAR NSF;
RUN;

/* CHECKING MISSING VALUES  */
PROC FREQ DATA = Bankcustomer_variables;
 TABLE NSF;
RUN;
Proc FREQ data=Bankcustomer_variables;
Table NSF/Missing;
Run;

/*============================================================================*/
/* Customer Line of Credit(LOC)   */

PROC MEANS DATA = Bankcustomer_variables ;
 VAR LOC;
RUN;

/* CHECKING MISSING VALUES  */
PROC FREQ DATA = Bankcustomer_variables;
 TABLE LOC;
RUN;
Proc FREQ data=Bankcustomer_variables;
Table LOC/Missing;
Run;

/* VISUALIZATION   */
TITLE "DISTRIBUTION OF CUSTOMERS Line of Credit(LOC) ";
FOOTNOTE "DISTRIBUTION OF CUSTOMERS Line of Credit(LOC)";
PROC GCHART DATA = Bankcustomer_variables ;
 PIE LOC;
RUN; QUIT;

/*================================================================*/
/* Customer Mortgage(MTG)   */
PROC MEANS DATA = Bankcustomer_variables MAXDEC=2 N NMISS MIN MEAN MEDIAN MAX STD CV CLM;
  VAR MTG;
RUN;

/* CHECKING MISSING VALUES  */
PROC FREQ DATA = Bankcustomer_variables;
 TABLE MTG;
RUN;
Proc FREQ data=Bankcustomer_variables;
Table MTG/Missing;
Run;

/* VISUALIZATION  */
TITLE "DISTRIBUTION OF MORTGAGE ";
FOOTNOTE"CUSTOMERS MORTGAGE PROFILE";
PROC GCHART DATA = Bankcustomer_variables ;
 PIE MTG;
RUN;
QUIT;
 

/*================================================================*/
/* Customer Cash Credit(CC)   */

/* CHECKING MISSING VALUES   */
PROC FREQ DATA = Bankcustomer_variables;
 TABLE CC;
RUN;
PROC FREQ data=Bankcustomer_variables;
Table CC/Missing;
Run;

/* VISUALIZATION  */
TITLE "DISTRIBUTION OF CUSTOMERS CASH CREDIT ";
FOOTNOTE "DISTRIBUTION OF CUSTOMERS CASH CREDIT ";
PROC GCHART DATA = Bankcustomer_variables ;
 PIE CC;
RUN;
QUIT;

/* REPLACE WITH 0 - USING COALESCE     CC, REPLACING THE MISSING VALUE OF THE CATEGORICAL VARIABLE BY MODE  */  
DATA Bankcustomer_variables;
	SET Bankcustomer_var_replaced;
	CC = coalesce(CC,0);
RUN;

PROC FREQ data=Bankcustomer_variables;
TABLE CC/Missing;
Run;

/*============================================================ */

/* Customer Cash Credit Purchase(CCPurc)   */
PROC MEANS DATA = Bankcustomer_variables ;
 VAR CCPurc; 
RUN;
  
PROC UNIVARIATE DATA =Bankcustomer_variables;
 VAR CCPurc; 
RUN;

 /* CUSTOMER CCPurc VARIABLE VALUES ARE NOT NORMALLY DISTRIBUTE.HENCE, MISSING VALUES HAS TO BE REPLACED BY "MODE" 
  CCPurc HAS 12.81 MISSING VALUES */
/* REPLACE WITH 0 - USING COALESCE     CCPurc  */  

data Bankcustomer_variables;
	set Bankcustomer_var_replaced;
	CCPurc = coalesce(CCPurc,0);
run;

/* CHECKING  MISSING VALUES */
PROC FREQ DATA = Bankcustomer_variables;
 TABLE CCPurc;
RUN;
Proc FREQ data=Bankcustomer_variables;
Table CCPurc/Missing;
Run;

TITLE "DISTRIBUTION OF NUMERIC VARIABLE:Cash Credit Purchase(CCPurc)";
PROC SGPLOT DATA = Bankcustomer_variables ;
 VBOX CCPurc;
RUN; 
QUIT;

/*=====================================================
  Customer Credit score(CRScore)   */
PROC MEANS DATA = Bankcustomer_variables ;
 VAR CRScore; 
RUN;
 
 PROC MEANS DATA = Bankcustomer_var_replaced MAXDEC=2 N NMISS MIN MEAN MEDIAN MAX STD CV CLM;
  VAR CRScore;
RUN;

PROC UNIVARIATE DATA =Bankcustomer_variables;
 VAR CRScore; 
RUN;

 /* CRScore VARIABLE VALUES ARE NORMALLY DISTRIBUTE.HENCE, MISSING VALUES HAS TO BE REPLACED BY "MEAN" 
  Age VARIABLE HAS 2.19% MISSING VALUES*/

PROC STDIZE DATA = Bankcustomer_variables OUT= Bankcustomer_var_replaced METHOD= MEAN REPONLY;
 VAR CRScore;
RUN;

/* CHECKING MISSING VALUES  */
PROC FREQ DATA = Bankcustomer_variables;
 TABLE CRScore; RUN;
Proc FREQ data=Bankcustomer_variables;
Table CRScore/Missing; 
Run;

/* VISUALIZATION */
TITLE "CUSTOMERS CREDIT SCORE DATA DISTRIBUTION  ";
FOOTNOTE "CUSTOMERS CREDIT SCORE DATA DISTRIBUTION  ";
PROC SGPLOT DATA = Bankcustomer_variables ;
 HISTOGRAM CRScore;
 DENSITY CRScore;RUN; 
QUIT;

TITLE "CUSTOMERS CREDIT SCORE DATA DISTRIBUTION  ";
FOOTNOTE "CUSTOMERS CREDIT SCORE DATA DISTRIBUTION  ";
PROC SGPLOT DATA = Bankcustomer_variables ;
 VBOX CRScore; RUN; 
QUIT;

 /* Banking Habit of Customers (Teller)   */
PROC MEANS DATA = Bankcustomer_variables ;
 VAR Teller; 
RUN;

PROC MEANS DATA = Bankcustomer_variables MAXDEC=2 N NMISS MIN MEAN MEDIAN MAX STD CV CLM;
  VAR Teller;
RUN;

PROC UNIVARIATE DATA =Bankcustomer_variables;
 VAR Teller; 
RUN;

/* CHECKING MISSING VALUES */
PROC FREQ DATA = Bankcustomer_variables;
 TABLE Teller; 
RUN;
Proc FREQ data=Bankcustomer_variables;
Table Teller/Missing; 
Run;

/* VISUALIZATION */
TITLE "DISTRIBUTION OF NUMERIC VARIABLE :Banking Habit of Customers (Teller)";
PROC SGPLOT DATA = Bankcustomer_variables ;
 HISTOGRAM Teller;
 DENSITY Teller;
RUN; 
QUIT;

TITLE "DISTRIBUTION OF NUMERIC VARIABLE:Banking Habit of Customers (Teller)";
PROC SGPLOT DATA = Bankcustomer_variables ;
 VBOX Teller; 
RUN; 
QUIT;

/*=====================================================================*/
/* Banking Habit of Customers (checks)  */
PROC MEANS DATA = Bankcustomer_variables ;
 VAR checks; 
RUN;

PROC UNIVARIATE DATA =Bankcustomer_variables;
 VAR checks; 
RUN;

/* CHECKING MISSING VALUES */
PROC FREQ DATA = Bankcustomer_variables;
 TABLE checks; 
RUN;
Proc FREQ data=Bankcustomer_variables;
Table checks/Missing; 
Run;

/* VISUALIZATION  */
TITLE "DISTRIBUTION OF NUMERIC VARIABLE :Banking Habit of Customers (checks)";
PROC SGPLOT DATA = Bankcustomer_variables ;
 HISTOGRAM checks;
 DENSITY checks;
RUN; 
QUIT;

TITLE "DISTRIBUTION OF NUMERIC VARIABLE:Banking Habit of Customers (checks)";
PROC SGPLOT DATA = Bankcustomer_variables ;
 VBOX checks; 
RUN; 
QUIT;

/*=================================================================*/
/* Categorical Variable:  Branch  */
PROC FREQ DATA = Bankcustomer_variables;
 TABLE Branch;
RUN;

TITLE "THE DISTRIBUTION OF BANK'S CUSTOMERS BY BRANCH";
PROC SGPLOT DATA =  Bankcustomer_variables ;
 HBAR Branch;
RUN;
QUIT;

/* BAR CHART VISUALIZATION FOR CATEGORICAL VARIABLE */
TITLE"BAR CHART CUSTOMERS BY BRANCHS";
PROC SGPLOT DATA =Bankcustomer_variables;
 VBAR Branch;
RUN;

 
 
/* OUTLIER VALUES OF THE DATA: A colser look for each varibale  
======OUTLIER DETECTION=====
OUTLIERS= OBSERVATIONS > Q3 + 1.5*IQR  or < Q1 – 1.5*IQR */

TITLE "OUTLIER DETECTION(Age)";
PROC SGPLOT DATA = Bankcustomer_var_replaced;
 VBOX Age;
RUN;
QUIT;

PROC PRINT DATA = Bankcustomer_var_replaced;
VAR Age;
RUN;
QUIT;

PROC MEANS DATA = Bankcustomer_var_replaced MAXDEC = 2 N NMISS P25 P75 QRANGE ;
 VAR Age;
 OUTPUT OUT= TEMP P25 = Q1 P75=Q3 QRANGE=IQR;
RUN;

/* Outliers = Observations > Q3 + 3*IQR  or < Q1 – 3*IQR  
The interquartile range is: Q3 – Q1  
The upper limit for outliers would be: Q3 + 3*IQR =   */

/* OUTLIER REMOVAL 
 
     CARTESIAN JOIN OR PRODUCT
  =======================================================*/

PROC MEANS DATA = Bankcustomer_var_replaced;
 VAR Age CRScore;
RUN;


PROC FORMAT;
 VALUE AgeG  LOW - 15 ='BELOW RANGE'
 			 16- 94 = 'WITHIN RAGNE'
			 95- HIGH = 'ABOVE RANGE';
 VALUE CRS  LOW - 508 = 'BELOW SCORE RATE'
 	         509-820 = 'WITHIN RAGE'
			 821- HIGH = 'ABOVE RANGE';
RUN;

PROC FREQ DATA = Bankcustomer_var_replaced;
 TABLE Age  CRScore/MISSING;
 FORMAT Age AgeG. CRScore CRS.;
RUN;

PROC SQL;
 CREATE TABLE Bankcustomer_Age_CRScore AS
 SELECT *
 FROM Bankcustomer_var_replaced
 WHERE Age  BETWEEN 16 AND 94
 AND CRScore BETWEEN 509 AND 820
 ;
 QUIT;

 *UNKNOWN RANGE- IQR OR STD;
 * IQR - INTERQUARTILE RANGE;
 * Q1 -(3*IQR) --- OUTLIERS;
 * Q3+ (3*IQR) --- OUTLIERS;

 * Q1 -(2.5*IQR) --- OUTLIERS;
 * Q3+ (2.5*IQR) --- OUTLIERS;

PROC MEANS DATA = Bankcustomer_var_replaced MAXDEC = 2 N NMISS P25 P75 QRANGE ;
 VAR Age CRScore;
 OUTPUT OUT= TEMP P25 = Q1 P75=Q3 QRANGE=IQR;
RUN;
DATA TEMP01;
 SET TEMP;
 LOWER_LIMIT = Q1 -(3*IQR);
 UPPER_LIMIT = Q3+ (3*IQR);
 DROP _TYPE_ _FREQ_;
RUN;

*CARTESIAN JOIN OR PRODUCT;
PROC SQL;
CREATE TABLE Bankcustomer_var_replaced_01 AS
SELECT A.*,
	   B.LOWER_LIMIT,B.UPPER_LIMIT
FROM Bankcustomer_var_replaced AS A, TEMP01 AS  B
;
QUIT;
* LE= LESS THAN OR EQUAL TO;
* LT= LESS THAN ;
* GE = GRATER THAN OR EQUAL TO;
* GT = GRATER THAN ;
* EQ = EQUAL TO;

DATA Bankcustomer_var_replaced_02;
 SET Bankcustomer_var_replaced_01;
 IF Bankcustomer_Age_CRScore LE LOWER_LIMIT THEN RECURR_RANGE ='BELOW LOWER LIMIT';
 ELSE IF Bankcustomer_Age_CRScore GE UPPER_LIMIT THEN RECURR_RANGE ='ABOVE UPPER LIMIT';
 ELSE RECURR_RANGE ='WITHIN RANGE';
RUN;


PROC FREQ DATA = Bankcustomer_var_replaced_02;
 TABLE RECURR_RANGE;

 /*create new dataset with outliers Age*/

PROC MEANS DATA = Bankcustomer_var_replaced MAXDEC = 2 N NMISS P25 P75 QRANGE ;
 VAR Age;
 OUTPUT OUT= Age_1 P25 = Q1 P75=Q3 QRANGE=IQR;
RUN;

DATA Age_2;
 SET Age_1;
 LOWER_LIMIT = Q1 -(3*IQR);
 UPPER_LIMIT = Q3+ (3*IQR);
 DROP _TYPE_ _FREQ_;
RUN;
proc print data = Age_2;
run;
/* ======================================================
     CARTESIAN JOIN OR PRODUCT
  =======================================================*/
PROC SQL;
CREATE TABLE Bankcustomer_var_replaced_01 AS
SELECT A.*,
	   B.LOWER_LIMIT,B.UPPER_LIMIT
FROM Bankcustomer_var_replaced AS A, Age_2 AS  B
;
QUIT;

PROC FORMAT;
 VALUE AGRP  LOW - 15 ='BELOW RANGE'
 			 16- 94 = 'WITHIN RAGNE'
			 95- HIGH = 'ABOVE RANGE';

DATA Bankcustomer_var_replaced_02;
 SET Bankcustomer_var_replaced_01;
 IF Age LE LOWER_LIMIT THEN RECURR_RANGE ='BELOW LOWER LIMIT';
 ELSE IF Age GE UPPER_LIMIT THEN RECURR_RANGE ='ABOVE UPPER LIMIT';
 ELSE RECURR_RANGE ='WITHIN RANGE';
RUN;

PROC FREQ DATA = Bankcustomer_var_replaced_02;
 TABLE RECURR_RANGE;
RUN;

PROC SQL;
 CREATE TABLE Bankcustomer_var_replaced_03 AS
 SELECT *
 FROM Bankcustomer_var_replaced_02
 WHERE RECURR_RANGE ='WITHIN RANGE'
 ;
 QUIT;

PROC SGPLOT DATA = Bankcustomer_var_replaced_03 ;
 VBOX Age; 
RUN; 
QUIT;

/*==============================================================================*/
/*DISCRETIZATION OR BINNING : Age */

PROC HPBIN DATA =Bankcustomer_var_replaced_03 OUT=variable;
 INPUT Age /NUMBIN=4;  
RUN;

PROC FORMAT;
 VALUE Agc  Low- 34="< 34"
           35-55 = "35-45"
		   56-74 = '56-74'
		   74-94 = '74-94'
           	 ;
RUN;
 
TITLE " CUSTOMERS INFORMATION BY AGE GROUP CATEGORY";
FOOTNOTE"    ";
PROC FREQ DATA = Bankcustomer_var_replaced;
 TABLE Age/MISSING;
 FORMAT Age Agc.;
 FORMAT DDA DD.;
RUN;
 
/*====================================================*/
PROC SGPLOT DATA = Bankcustomer_var_replaced;
VBAR Age/datalabel ;
FORMAT Age Agc.;
TITLE 'CUSTOMERS by  AGE GROUP';
RUN;

TITLE"";
FOOTNOTE"ACTIVE AND INACTIVE CUSTOMERS BY AGE GROUP";
PROC SGPLOT DATA=Bankcustomer_var_replaced;
VBAR Age/stat=percent GROUP=DDA groupdisplay =cluster;
FORMAT Age Agc.;
FORMAT DDA DD.;
RUN;
QUIT;
 
/*==========================================================================================================
/* BUSINESS QUESTION-1. WHAT PERCENTAGE OF THE BANK CUSTOMERS ARE ACTIVE AND INACTIVE? */

TITLE " CUSTOMERS BASE INFORMATION ";
FOOTNOTE" 81.56% of Customers are Active and 18.44% of them are Inactive Customers";
PROC GCHART DATA=Bankcustomer_variables;
PIE DDA/type=pct;
FORMAT DDA DD.;
legend;
RUN;
/* 
BUSINESS QUESTION-2. WHICH AGE GROUP THE BANK HAS MORE CUSTOMERS? 
BUSINESS QUESTION-3. WHAT PERCENTAGE OF THE BANKS  CUSTOMERS HAVING NSF? 
BUSINESS QUESTION-4. WHAT IS THE DISTRIBUTION OF CUSTOMERS BASED ON THEIR CREDIT SCORE RATE ?  

BUSINESS QUESTION-5 IS THERE ANY  ASSOCIATION BETWEEN CUSTOMER AGE  WITH THE TARGET VARIABLE DDA? 
CHI SQUARE TEST OF ASSOCIATION AFTER CONVERTING TO CATEGORICAL

HO: THERE IS NO ASOCIATION BETWEEN DDA AND CUSTOMER AGE
HA: THERE IS ASOCIATION BETWEEN DDA AND CUSTOMER AGE */

/* BINNING OF DATA IN TO DFIFFERENT GROUPS OR GATEGORIES */


PROC HPBIN DATA =Bankcustomer_variables OUT=variable;
 INPUT DDA /NUMBIN=2;  
RUN;
PROC FORMAT;
 VALUE DD  
            1= 'Active Customers'
            0='Inactive Customers '
			 ;
RUN;
PROC HPBIN DATA =Bankcustomer_var_replaced_03 OUT=variable;
 INPUT Age /NUMBIN=4;  
RUN;

PROC FREQ DATA = Bankcustomer_var_replaced;
 TABLE DDA * Age/CHISQ NOROW NOCOL;
 FORMAT Age Agc. ;
 FORMAT DDA DD. ;
RUN;

TITLE" DDA AND NSF STACKED BAR CHART"; 
PROC SGPLOT DATA=Bankcustomer_var_replaced;
VBAR DDA/stat=percent GROUP=Age groupdisplay=claster datalabel;
FORMAT Age Agc. ;
 FORMAT DDA DD. ;
 RUN;


/* Visualization   */

TITLE" DDA AND AGE STACKED BAR CHART"; 
PROC SGPLOT DATA=Bankcustomer_var_replaced  ;
VBAR DDA/GROUP=Age groupdisplay= stack stat=pct seglabel seglabelattrs=(size=6 color=white) ;
FORMAT Age Agc. ;
 FORMAT DDA DD. ;
 RUN;

 /*create clustered bar chart*/
TITLE "Clustered Bar Chart of Age & DDA";
PROC SGPLOT DATA = Bankcustomer_var_replaced;
    vbar Age / group = DDA groupdisplay = cluster datalabel;
	FORMAT Age Agc. ;
    FORMAT DDA DD. ;
RUN;

TITLE" DISTRIBUTION OF AGE VRSUS DDA";
PROC FREQ DATA= Bankcustomer_var_replaced;
TABLE Age*DDA /NOCOL NOROW;
FORMAT Age Agc.;
FORMAT DDA DD.;
RUN;


TITLE  "CUSTOMER AGE VS DDA BAR GRAPH ";
FOOTNOTE " CUSTOMER AGE VS DDA BAR GRAPH";
PROC SGPLOT = Bankcustomer_var_replaced;
    VBAR Age /stat=percent group = DDA  groupdisplay = cluster;
	FORMAT Age Agc.;
    FORMAT DDA DD.;
RUN;
QUIT;

 /*===============================================================================

 BUSINESS QUESTION 6. IS THERE SIGNIFICANT DIFFERENCE BETWEEN DDA AND BRANCH?  

 HO: THERE IS NO SIGNIFICANT DIFFERENCE BETWEEN DDA AND BRANCH
 HA: THERE  IS SIGNIFICANT DIFERENCE BETWEEN DDA AND BRANCH  */

TITLE" DISTRIBUTION OF CUSTOMERS DEMAND DEPOSIT ACCCOUNT VS BRANCH ";
FOOTNOTE" CUSTOMERS DEMAND DEPOSIT ACCCOUNT VS BRANCH";
PROC FREQ DATA = Bankcustomer_var_replaced;
 TABLE DDA * Branch/CHISQ NOROW NOCOL;
 FORMAT DDA DD. ;
RUN;

TITLE" DISTRIBUTION OF CUSTOMERS DEMAND DEPOSIT ACCCOUNT VS BRANCH ";
PROC FREQ DATA=Bankcustomer_var_replaced;
TABLE DDA*BRANCH/NOCOL NOROW;
FORMAT DDA DD.;
RUN;
QUIT;

TITLE" DISTRIBUTION OF CUSTOMERS DEMAND DEPOSIT ACCCOUNT VS BRANCH ";
 FOOTNOTE" DEMAND DEPOSIT ACCCOUNT VS BRANCH";
PROC SGPLOT DATA=Bankcustomer_var_replaced;
VBAR DDA/STAT=PERCENT GROUP=Branch Groupdisplay=cluster datalabel;
FORMAT DDA DD.;
RUN;
QUIT;

/*====================DISCRETIZATION OR BINNING : CRScore =======================*/

PROC CONTENTS DATA = Bankcustomer_variables VARNUM SHORT;
RUN;
/* AcctAge DDA DDABal CashBk Checks DirDep NSF NSFAmt Phone Teller Sav SavBal ATM ATMAmt POS POSAmt CD CDBal IRA IRABal 
LOC LOCBal ILS ILSBal MM MMBal MMCred MTG MTGBal CC CCBal CCPurc SDB Income HMOwn LORes HMVal Age CRScore Moved InArea 
Ins Branch Res Dep DepAmt Inv InvBal */ 

/*create boxplot to visualize distribution of CRScore*/

ods output sgplot=boxplot_data;
proc sgplot data=Bankcustomer_var_replaced;
    vbox CRScore;
run;

/*view summary of boxplot descriptive statistics*/
TITLE"CUSTOMERS CREDIT SCORE OUTLIERS DESCRIPTIVE STATESTICS ";
proc print data=boxplot_data;
var CRScore;
Run;

PROC HPBIN DATA =Bankcustomer_var_replaced OUT=variable;
 INPUT CRScore /NUMBIN=4;  
RUN;

PROC FORMAT;
 VALUE CRSc Low-659 ='< 659'
            660-712= '660-712'
			713-740= '713 -740'
			741-820='741-820'
			 ;
RUN;

TITLE" DISTRIBUTION OF CUSTOMERS CREDIT SCORE BY AGE GRUOP";
PROC FREQ DATA = Bankcustomer_var_replaced;
 TABLE CRScore/MISSING;
 FORMAT CRScore CRSc.;
RUN;
QUIT;

TITLE" CUSTOMERS CREDIT SCORE PROFILE";
FOOTNOTE" CUSTOMERS CREDIT SCORE PROFILE";
PROC SGPLOT DATA = Bankcustomer_var_replaced ;
 VBAR CRScore/datalabel colormodel=( white red); 
 FORMAT CRScore CRSc.  ;
 LEGEND;
RUN; QUIT;
 
 
 
 /* All category observations are above 5 and hince we can test chi square test of asociation */ 

/*======================================================================================

/* DDA has two class values and has no outliers*/

/* BIVARIATE ANALYSIS: HYPOTHESIS TESTING
/*DISCRETIZATION OR BINNING : DDA */

PROC HPBIN DATA =Bankcustomer_variables OUT=variable;
 INPUT DDA /NUMBIN=2;  
RUN;
PROC FORMAT;
 VALUE DD  0 ='Inactive Customers '
           1 = 'Active Customers '
			 ;
RUN;
PROC FREQ DATA = Bankcustomer_variables;
 TABLE DDA/MISSING;
 FORMAT DDA DD.;
RUN;

PROC FREQ DATA = Bankcustomer_variables;
 TABLE DDA * NSF/CHISQ NOROW NOCOL;
 FORMAT DDA DD.  ;
RUN;

TITLE" ACTIVE AND INACTIVE CUSTOMERS OF THE BANK";
PROC GCHART DATA = Bankcustomer_variables ;
 PIE DDA  ;
 FORMAT DDA DD.  ;
RUN; QUIT;
TITLE" ACTIVE AND INACTIVE CUSTOMERS OF THE BANK";
PROC SGPLOT DATA = Bankcustomer_variables ;
VBAR DDA  ;
 FORMAT DDA DD.  ;
RUN; QUIT;
 
/*========================================================================================*/

/* THE VARIABLE NSF HAS A BINARY VALUE OR TWO LEVELS WITH VALUES ONE AND TWO ONLY AND DOES NOT HAVE OUTLIER VALUES. */

/*DISCRETIZATION OR BINNING : SNF */
/* THE BINNING PROCEDURE DIVIDE THE INTERVAL 0 TO 1 IN TO <0.5 AND >0.5. BUT TO KEEP THE CLASSES VALUES, NO NEED TO FORMAT IN TO 
NSF < 0.5 AND 0.5 <= NSF*. I HAVE TO KEEP THE VALUES IN TO TWO CLASSES AS 0 AND 1*/
 
 /*BUSINESS QUESTION-7 IS THERE ANY  ASSOCIATION BETWEEN NSF  WITH   DDA? 

HO: THERE IS NO ASSOCIATION BETWEEN DDA AND NSF
HA: THERE IS ASSOCIATION BETWEEN DDA AND NSF  */


/* VARIABLE SNF BINNING TO CONVERT IN TO CATEGORICAL VARIABLE TO TEST CHI SQUARE */

PROC HPBIN DATA =Bankcustomer_variables OUT=variable;
 INPUT NSF /NUMBIN=2;  
RUN;
PROC FORMAT;
 VALUE NS 0 ='Customers with Sufficient Fund '
          1 = 'Customers with no Sufficient Fund'
			 ; RUN;
PROC FREQ DATA = Bankcustomer_variables;
 TABLE NSF/MISSING;
 FORMAT NSF NS.; 
RUN;

TITLE "ASSOCIATION BETWEEN DDA AND NSF";

PROC FREQ DATA = Bankcustomer_variables;
 TABLE DDA *NSF/CHISQ NOROW NOCOL;
 FORMAT NSF NS.  ;
 FORMAT DDA DD.;
RUN;

TITLE" DDA AND NSF STACKED BAR CHART"; 
PROC SGPLOT DATA=Bankcustomer_var_replaced;
VBAR DDA/stat=percent GROUP=NSF groupdisplay=claster datalabel;
FORMAT NSF NS. ;
 FORMAT DDA DD. ;
 RUN;

TITLE" CUSTOMERS ACCOUNT FUND INFORMATION";
FOOTNOTE "91.29% of Customers have sufficient Fund whereas 8.71% of them have non sufficient Fund";
PROC SGPLOT DATA = Bankcustomer_variables ;
VBAR NSF/datalabel colormodel=( white red);
 FORMAT NSF NS.;
 legend;
RUN; QUIT;


/*BUSINESS QUESTION-8 IS THERE ANY  ASSOCIATION BETWEEN CRScore  WITH  DDA? 

HO: THERE IS NO ASSOCIATION BETWEEN DDA AND CRScore
HA: THERE IS ASSOCIATION BETWEEN DDA AND CRScore */


TITLE "ASSOCIATION BETWEEN DDA AND CRScore";
PROC FREQ DATA = Bankcustomer_variables;
 TABLE DDA *CRScore/CHISQ NOROW NOCOL;
 FORMAT CRScore CRSc.  ;
 FORMAT DDA DD.;
RUN;

TITLE" DDA AND CRScore Vs BAR CHART"; 
PROC SGPLOT DATA=Bankcustomer_var_replaced;
VBAR DDA/stat=percent GROUP=CRScore groupdisplay=claster datalabel;
FORMAT CRScore CRSc. ;
 FORMAT DDA DD. ;
 RUN;


/*BUSINESS QUESTION-9 IS THERE ANY  ASSOCIATION BETWEEN AGE WITH  DDA? */

TITLE "ASSOCIATION BETWEEN DDA AND Age";
PROC FREQ DATA = Bankcustomer_variables;
 TABLE DDA *Age/CHISQ NOROW NOCOL;
 FORMAT Age Agc.  ;
 FORMAT DDA DD.;
RUN;

TITLE" DDA Vs AcctAge"; 
PROC SGPLOT DATA=Bankcustomer_var_replaced;
VBAR DDA/stat=percent GROUP=Age groupdisplay=claster datalabel;
FORMAT AcctAge Agc. ;
 FORMAT DDA DD. ;
 RUN;

/*BUSINESS QUESTION-10 IS THERE ANY  ASSOCIATION BETWEEN AcctAge WITH  DDA? */

TITLE "ASSOCIATION BETWEEN DDA AND AcctAge";
PROC FREQ DATA = Bankcustomer_variables;
 TABLE DDA *Income/CHISQ NOROW NOCOL;
 FORMAT Income Inc.  ;
 FORMAT DDA DD.;
RUN;

TITLE" DDA Vs AcctAge"; 
PROC SGPLOT DATA=Bankcustomer_var_replaced;
VBAR DDA/stat=percent GROUP=Income groupdisplay=claster datalabel;
FORMAT Income Inc. ;
 FORMAT DDA DD. ;
 RUN;


/*BUSINESS QUESTION-11 IS THERE ANY  ASSOCIATION BETWEEN MTG WITH  DDA? */

PROC FORMAT;
 VALUE MG    0='No Mortgage'
             1 = 'Mortgage'
			 ;
RUN;


TITLE "ASSOCIATION BETWEEN DDA AND MTG";
PROC FREQ DATA = Bankcustomer_variables;
 TABLE DDA * MTG/CHISQ NOROW NOCOL;
 FORMAT MTG MG.  ;
 FORMAT DDA DD.;
RUN;

TITLE" DDA Vs MTG"; 
PROC SGPLOT DATA=Bankcustomer_var_replaced;
VBAR DDA/stat=percent GROUP=MTG groupdisplay=claster datalabel;
 FORMAT MTC Inc. ;
 FORMAT DDA DD. ;
 RUN;

/*BUSINESS QUESTION-12 IS THERE ANY  ASSOCIATION BETWEEN CC WITH  DDA? */

PROC FORMAT;
 VALUE Cc    0='No Credit Crad'
             1 = 'Credit Card'
			 ;
RUN;

TITLE "ASSOCIATION BETWEEN DDA AND CC";
PROC FREQ DATA = Bankcustomer_variables;
 TABLE DDA * CC/CHISQ NOROW NOCOL;
 FORMAT CC Cc.  ;
 FORMAT DDA DD.;
RUN;

TITLE" DDA Vs CC"; 
PROC SGPLOT DATA=Bankcustomer_var_replaced;
VBAR DDA/stat=percent GROUP=CC groupdisplay=claster datalabel;
 FORMAT CC Cc. ;
 FORMAT DDA DD. ;
 RUN;

/* Income outlier detection and removal */

PROC SGPLOT DATA = Bankcustomer_var_replaced ;
 VBOX Income; 
RUN; 
QUIT;

TITLE"CUSTOMERS INCOME OUTLIERS STATESTICS ";
ods output sgplot=boxplot_data;
proc sgplot data=Bankcustomer_var_replaced;
    vbox Income;
run;
/*view summary of boxplot descriptive statistics*/
TITLE"CUSTOMERS INCOME OUTLIERS STATESTICS ";
PROC PRINT DATA=boxplot_data;
 
 /*create new dataset with outliers removed*/
data new_data;
    set Bankcustomer_var_replaced;
    if Income >= 127 then delete;
run;

/*view new dataset*/
proc print data=new_data;

TITLE"CUSTOMERS INCOME OUTLIERS Removal ";
proc sgplot data=new_data;
    vbox Income;
run;

/*============================================*/
TITLE"CUSTOMERS Age OUTLIERS DESCRIPTIVE STATESTICS ";
ods output sgplot=boxplot_data1;
proc sgplot data=Bankcustomer_var_replaced;
    vbox Age;
run;
/*view summary of boxplot descriptive statistics*/
TITLE"CUSTOMERS Age OUTLIERS DESCRIPTIVE STATESTICS ";
PROC PRINT DATA=boxplot_data1;
 
 /*create new dataset with outliers removed*/
data new_data1;
    set Bankcustomer_var_replaced;
    where 16>=Age <= 94;
run;
PROC STDIZE DATA = new_data1 OUT= Bankcustomer_var_replaced METHOD= MEAN REPONLY;
 VAR Age; 
RUN;

/*view new dataset*/
proc print data=new_data1;

TITLE"CUSTOMERS INCOME OUTLIERS Removal ";
proc sgplot data=new_data;
    vbox Income;
run;
PROC HPBIN DATA =new_data OUT=variable;
 INPUT Income /NUMBIN=4;  
RUN;

PROC FORMAT;
 VALUE Inc LOW - 31 ='Lower 31 '
            32- 63 = '32- 63'
			64 - 94= '64 - 94'
			95 - 126 ='95 - 126'
			 ;
RUN;
/*REPLACING MISSING VALUES IN THE NEW DATA =================================================================*/
PROC STDIZE DATA = new_data OUT= new_data_var_replaced METHOD= MEDIAN REPONLY;
 VAR Income; 
RUN;

TITLE" CUSTOMERS BY INCOME CATEGORY";
FOOTNOTE"    ";
PROC FREQ DATA = new_data_var_replaced;
 TABLE Income/MISSING;
 FORMAT Income Inc.;
RUN;

TITLE" CUSTOMERS INCOME DISTRIBUTION ";
FOOTNOTE"CUSTOMERS INCOME IN FOUR SCALES";
PROC SGPLOT DATA = new_data_var_replaced ;
 VBAR Income/ datalabel ;
 FORMAT Income Inc.  ;
 LEGEND;
RUN; QUIT;
 

TITLE"STACK BAR CHART SHOWING CUSTOMERS BY BRANCH "; 
PROC GCHART DATA= Bankcustomer_var_replaced;
VBAR DDA/discrete type=percent subgroup=Branch;
FORMAT DDA DD.;
FORMAT NSF NS. ;
RUN;
QUIT;

/* ========================================================================
   FORMATING AT ONE GLANCE FOR ALL VARIABLES FOR LOGESTIC REGRESSION MODELING */

 PROC FORMAT ;
 value DD
       1= 'Active Customers'
       0='Inactive Customers '
      ;
 value NS
        0 ='Customers with Sufficient Fund '
        1 = 'Customers with no Sufficient Fund' 
       ;
 value Agc 
         Low- 34='16 34 Years '
           35-55 ='35-45 Years'
		   56-74 ='56-74 Years'
		   74-94 ='74-94 Years'
       ;
 value AcctAg 
          LOW -7.9 ='0.3-7.9'
            9- 13.9 ='9-13.9 '
			14-19='14-19'
         ;
		 
  value   CRSc
         Low-659 ='<509-659'
          660-712= '660-712'
		  713-740= '713 -740'
		  741-820='741-820'
         ;
  value   Inc
        Low- 31 ='0- 31 '
          32- 63 = '32-63'
		  64 - 94= '64-94'
		  95 - 126 ='95-126'
		  127-233 ="127-233"
        ;
  value  Cc  
           0='No Credit Crad'
           1 = 'Credit Card'
	    ;
  value MG    
           0='No Mortgage'
           1 = 'Mortgage'
	      ;
  value  LC 
           0=  'No Line of Credit'
           1 = 'Line of Credit '
	 ;
 value  CCP  
           0 = 'No Credit Carad Purchse'
           1 = '1 Credit Carad Purchse'
           2 = '2 Credit Carad Purchse'
		   3 = '3 Credit Carad Purchse'
           4 = '4 Credit Carad Purchse'
		   5 = '4 Credit Carad Purchse'  
		   ;
value Chec
       0 -10 ='0-10 Transactions'
       11-20 = '11-20 Transactions'
       21-30 = '21-30 Transactions'
       31-40 = '31-40 Transactions'
       41-49 = '41-49 Transactions'
;
value Telv
      0 -5 = '0-5 Teller Visit'
       6-10 = '6-10 Teller Visit'
       11-15 = '11-15 Teller Visit'
       16-21= '11-21 Teller Visit'
       21-27 = '11-21 Teller Visit'
	   ;
RUN;

DATA Bankcustomer_var_replaced;
SET Bankcustomer_var_replaced;
FORMAT  AcctAge AcctAg. Age Agc. Income Inc. CRScore CRSc. Teller Telv. Checks chec. DDA DD. NSF NS. LOC LC.
       MTG MG. CCPurc CCP. CC Cc.;
RUN ;

PROC FREQ DATA =  Bankcustomer_var_replaced;
TABLES AcctAge Age Income CRScore Teller Checks DDA NSF LOC MTG Branch CCPurc CC  ;
RUN;

PROC LOGISTIC DATA = Bankcustomer_var_replaced;
CLASS  DDA / param=glm;
MODEL DDA = Age NSF AcctAge MTG Income CC CRScore LOC CCPurc Teller Checks ;
RUN;

/* LOGISTIC REGRESSION AND ODDS RATION */

TITLE"FITTING THE LOGISTIC REGRESSION and ODDS RATIO ";
proc logistic data = Bankcustomer_var_replaced descending;
class DDA  Income  NSF Age  CRScore  CC  LOC  CCPurc  MTG  Checks  Teller  / param=glm;
model DDA = DDA  Income  NSF Age  CRScore  CC  LOC  CCPurc  MTG  Checks  Teller ;
format DDA DD.;
format Income Inc.;
format NSF NS.;
format Age Agc.;
format CRScore CRSc.;
format CC Cc. ;
format LOC LC. ;
format CCPurc CCP.;
format MTG MG.;
format Checks Chec.;
format Teller Telv.;
run;

TITLE "ASSOCIATION OF VARIABLES";
PROC FREQ DATA = Bankcustomer_var_replaced;
 TABLE DDA * MTG /CHISQ NOROW NOCOL;
 FORMAT MTG MG.; 
 FORMAT DDA DD.;
RUN;
TITLE "ASSOCIATION OF VARIABLES";
PROC FREQ DATA = Bankcustomer_var_replaced;
 TABLE DDA * AcctAge* Age* Income *CRScore* Teller*Checks* NSF* LOC* MTG* Branch * CCPurc / NOROW NOCOL;
 FORMAT AcctAge AcctAg.;
 FORMAT  Age Agc. ;
 FORMAT Income Inc.;
 FORMAT CRScore CRSc.;
 FORMAT Teller Telv. ;
 FORMAT Checks chec.; 
 FORMAT NSF NS.;
 FORMAT LOC LC.;
 FORMAT MTG MG.; 
 FORMAT CCPurc CCP.; 
 FORMAT CC Cc.;
 FORMAT DDA DD.;
RUN;




 

