/****************************************************************\

PROGRAM:       C:\MEPS\PROG\EXAMPLE_E4.SAS

DESCRIPTION:  	THIS EXAMPLE SHOWS HOW TO COMPUTE FAMILY-LEVEL 
               ESTIMATES, USING THE MEPS DEFINITION OF FAMILY
               RATHER THAN THE CPS DEFINITION.
               
               SEE SECTION 3.3 OF THE DOCUMENTATION FOR HC-060
               (THE 2001 MEPS FILL-YEAR FILE).
               
               THIS PROGRAM GENERATES THE FOLLOWING FAMILY-LEVEL
               ESTIMATES:
               (1) MEAN NUMBER OF PERSONS PER FAMILY.
               (2) 2001 MEAN TOTAL HEALTHCARE EXPENSES PER
                   FAMILY.
               (3) 2001 MEAN TOTAL HEALTHCARE EXPENSES PER
                   FAMILY SIZE.

INPUT FILE:  	(1) C:\MEPS\DATA\H60.SAS7BDAT
                        -- 2001 MEPS FULL-YEAR FILE

\****************************************************************/

LIBNAME CMEPS  V8 'C:\MEPS\DATA' ;

FOOTNOTE 'PROGRAM: C:\MEPS\PROG\EXAMPLE_E4.SAS';

TITLE1 'AHRQ MEPS DATA USERS WORKSHOP (ESTIMATION) -- NOV/DEC 2004';
TITLE2 'COMPUTING FAMILY-LEVEL ESTIMATES';
TITLE3 ' ';

/***** THIS DATA STEP READS IN THE REQUIRED VARIABLES FROM THE *****/
/***** FULL-YEAR FILE.                                         *****/

DATA H60;
   LENGTH DUIDFAMY $6 ;
   SET CMEPS.H60 (KEEP=  DUID FAMIDYR DUPERSID FAMWT01F 
                           VARSTR01 VARPSU01 FAMRFPYR FAMSZEYR 
                           TOTEXP01);
   DUIDFAMY=PUT(DUID,Z5.)||TRIM(FAMIDYR);
RUN;

/***** CREATE A FAMILY-LEVEL FILE (ONE RECORD PER FAMILY)      *****/
/***** AFTER SUMMING TOTAL AND OUT-OF-POCKET EXPENSES TO       *****/
/***** THE FAMILY LEVEL.                                       *****/

/***** THE FAMILY-LEVEL OUTPUT FILE *FAM_H60* IS SUBSET        *****/
/***** TO FAMILIES WITH A POSITIVE WEIGHT (FAMWT01F).          *****/

PROC SORT DATA= H60;
   BY DUIDFAMY;
RUN;

DATA FAM_H60 (DROP= TOTEXP01) H60_CHK;
   SET H60;
   BY DUIDFAMY;
   IF FIRST.DUIDFAMY
      THEN FAMTOT01 = 0;
   FAMTOT01+TOTEXP01;
   LABEL FAMTOT01 = 'TOTAL EXPENSES (FAMILY)';
   IF (LAST.DUIDFAMY) AND (FAMWT01F > 0)
      THEN OUTPUT FAM_H60;
   OUTPUT H60_CHK;
RUN;

TITLE4 'FREQUENCY COUNT OF FAMILY SIZE VARIABLE *FAMSZEYR*';
TITLE5 'UNWEIGHTED';

PROC FREQ DATA= FAM_H60;
   TABLES FAMSZEYR / LIST MISSING;
RUN;

TITLE4 'SAMPLE PRINT OF 5 MEPS FAMILIES';
TITLE5 'SHOWING HOW TOTEXP01 IS SUMMED TO FAMILY-LEVEL';
TITLE6 '(LAST ROW OF *FAMTOT01* COLUMN SHOWS FAMILY TOTALS)';
TITLE7 'PERSON-LEVEL OUTPUT (PRE-SELECTED FAMILIES)';

PROC PRINT DATA= H60_CHK NOOBS;
   BY DUIDFAMY;
   VAR DUPERSID TOTEXP01 FAMTOT01 ;
   WHERE DUIDFAMY IN ('40001A', '40006A', '40007A',
                        '40010A', '40011A');
RUN;

TITLE5 'SHOWING VARIABLES AFTER SUMMING TO FAMILY-LEVEL';
TITLE6 'FAMILY-LEVEL OUTPUT (PRE-SELECTED FAMILIES)';

PROC PRINT DATA= FAM_H60 NOOBS;
   VAR DUIDFAMY FAMTOT01 ;
   WHERE DUIDFAMY IN ('40001A', '40006A', '40007A',
                        '40010A', '40011A');
RUN;

TITLE4 ' ';

PROC SURVEYMEANS DATA= FAM_H60 NOBS SUMWGT MEAN STDERR CLM;
   VAR FAMSZEYR FAMTOT01 ;
   STRATA VARSTR01;
   CLUSTER VARPSU01;
   WEIGHT FAMWT01F;
RUN;

PROC FORMAT;
   VALUE FAMF
   1 = '1'
   2 = '2'
   3 = '3'
   4 = '4'
   5-HIGH = '5+';
RUN;

TITLE5 'TOTAL HEALTHCARE EXPENSES PER FAMILY SIZE';

PROC SURVEYMEANS DATA= FAM_H60 NOBS SUMWGT MEAN STDERR CLM;
   VAR FAMTOT01 ;
   STRATA VARSTR01;
   CLUSTER VARPSU01;
   WEIGHT FAMWT01F;
   DOMAIN FAMSZEYR;
   FORMAT FAMSZEYR FAMF. ;
RUN;



