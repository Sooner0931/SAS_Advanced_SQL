* ALL ADVANCED PROGRAM:;

/***************************************************** BASIC SQL *************************************************/
/***************************************************** BASIC SQL *************************************************/
/***************************************************** BASIC SQL *************************************************/
/***************************************************** BASIC SQL *************************************************/
/***************************************************** BASIC SQL *************************************************/
/***************************************************** BASIC SQL *************************************************/

* 1. BASIC SQL;
 proc sql;
        select empid,jobcode,salary,
               salary*.06 as bonus
           from sasuser.payrollmaster
           where salary<32000
           order by jobcode;
quit;

proc sql;                                        * QUALIFYING THE COLUMN NAME: Prefixing a table name to a column name;
        select salcomps.empid,lastname,           
               newsals.salary,newsalary
           from sasuser.salcomps,sasuser.newsals
           where salcomps.empid=newsals.empid     /* INNER JOIN */
           order by lastname;
quit; 

proc sql;                                        * SUMMARY STATS BY GROUP;
        select membertype,
               sum(milestraveled) as TotalMiles
           from sasuser.frequentflyers
           group by membertype;
quit;
/* 
AVG, MEAN	 	    mean or average of values
COUNT, FREQ, N	 	number of nonmissing values
CSS	 	            corrected sum of squares
CV	 	            coefficient of variation (percent)
MAX	 	            largest value
MIN	 	            smallest value
NMISS	 	        number of missing values
PRT	 	            probability of a greater absolute value of Student's t
RANGE	 	        range of values
STD	 	            standard deviation
STDERR	 	        standard error of the mean
SUM	 	            sum of values
T	 	            student's t value for testing the hypothesis that the population mean is zero
USS	 	            uncorrected sum of squares
VAR	 	            variance
*/

proc sql;                                          * HAVING CLAUSE TO UTILIZE CALCULATED FIELD;
        select jobcode,avg(salary) as Avg
           from sasuser.payrollmaster
           group by jobcode
           having avg(salary)>40000
           order by jobcode;
quit;


/***************************************************** ADVANCED SQL *************************************************/
/***************************************************** ADVANCED SQL *************************************************/
/***************************************************** ADVANCED SQL *************************************************/
/***************************************************** ADVANCED SQL *************************************************/
/***************************************************** ADVANCED SQL *************************************************/
/***************************************************** ADVANCED SQL *************************************************/

* 2. ADVANCED SQL;
proc sql outobs=20 feedback;                       * ADDING A FEEDBACK OPTION; 
     title 'Job Groups with Average Salary';
     title2 '> Company Average';
        select jobcode, 
               avg(salary) as AvgSalary format=dollar11.2,
               count(*) as Count
           from sasuser.payrollmaster
           group by jobcode
           having avg(salary) >
              (select avg(salary)
                 from sasuser.payrollmaster)
           order by avgsalary desc;
quit;
/* The FEEDBACK option is a debugging tool that lets you see exactly what is being submitted to the SQL processor. 
The resulting message in the SAS log not only expands asterisks (*) into column lists, but it also resolves 
macro variables and places parentheses around expressions to show their order of evaluation.*/


proc sql outobs=10;
        select flightnumber, date
           from sasuser.flightschedule;
quit;
/* to limit the number of rows, use the OUTOBS= option; 
OUTOBS= is similar to the OBS= data set option.*/


/* OUTOBS= option restricts the rows that are displayed,but not the rows that are read. 
To restrict the number of rows that PROC SQL takes as input from any single source, use the INOBS= option */



proc sql;                                                  /* Eliminating Duplicate Rows from Output */
        select distinct flightnumber, destination
           from sasuser.internationalflights
           order by 1;
quit;

/*
Conditional Operator	                        Tests for ...	                          Example

BETWEEN-AND	                values that occur within an inclusive range	      where salary between 70000 and 80000 (<=7000 & >=8000)

CONTAINS or ?               values that contain a specified string            where name contains 'ER'//// where name ? 'ER' 

IN                          values that match one of a list of values         where code in ('PT','NA','FA')

IS MISSING or IS NULL       missing values                                    where dateofbirth is missing//// where dateofbirth is null

LIKE ( %, _)                values that match a specified pattern             where address like '% P%PLACE'

=*                          values that "sound like" a specified value        where lastname=* 'Smith'

ANY                         values that meet a specified condition            where dateofbirth < any
                            with respect to any one of the values                  (select dateofbirth
                            returned by a subquery                                     from sasuser.payrollmaster
                                                                                            where jobcode='FA3')

ALL                         values that meet a specified condition with       where dateofbirth < all       
                            respect to all the values returned by a                (select dateofbirth
                            subquery                                                    from sasuser.payrollmaster
							                                                                where jobcode='FA3')

EXISTS                      the existence of values returned by a subquery    where exists
                                                                                   (select * 
																					   from sasuser.flightschedule
                                                                                            where fa.empid=
                                                                                              flightschedule.empid)
To create a negative condition, you can precede any of these conditional operators, 
except for ANY and ALL, with the NOT operator: 
e.g.: where salary NOT between 70000 and 80000
*/



/***************************************AN EXAMPLE OF "BETWEEN AND" USED FOR DATE *****************************************
   where date between '01mar2000'd and '07mar2000'd
*/



/***************************************AN EXAMPLE OF "CONTAIN (? )" *****************************************/
 proc sql outobs=10;
        select name
           from sasuser.frequentflyers
           where name contains 'ER';                                                              /* (STRING) */
QUIT;                                /* all rows that contain ER anywhere within the Name column are displayed*/


/***************************************AN EXAMPLE OF "IN " *****************************************/
/*
Example                                                        Returns rows in which ...
where jobcategory in ('PT','NA','FA')                   the value of JobCategory is PT, NA, or FA         (STRING)
where dayofweek in (2,4,6)                              the value of DayOfWeek is 2, 4, or 6              (NUMERIC)
*/


/***************************************AN EXAMPLE OF "IS MISSING (IS NULL)" *****************************************/
proc sql;
        select boarded, transferred,
               nonrevenue, deplaned
           from sasuser.marchflights
           where boarded is missing;
QUIT; 

/* Alternatively, you can specify missing values without using the IS MISSING or IS NULL operator, 
as shown in the following examples:
                                   where boarded = .
                                   where flight = ' '
However, the advantage of using the IS MISSING or IS NULL operator is that you don't have to specify 
the data type (character or numeric) of the column. */


/***************************************AN EXAMPLE OF "LIKE " *****************************************/
/* Special Character	        Represents
  underscore ( _ )	        any single character
  percent sign (%)	        any sequence of zero or more characters
The underscore (_) and percent sign (%) are sometimes referred to as WILDCARD characters.
*/

proc sql;
        select ffid, name, address
           from sasuser.frequentflyers
           where address like '% P%PLACE';
QUIT;                                             /* uses the LIKE operator to find all frequent-flyer club members 
                                                   whose street name begins with P and ends with the word PLACE */
/* The pattern '% P%PLACE' specifies the following sequence:

  1. any number of characters (%)
  2. a space
  3. the letter P
  4. any number of characters (%)
  5. the word PLACE.
*/


/***************************************AN EXAMPLE OF "=* " (SOUNDS LIKE) *****************************************
USED to Select a Spelling Variation:
uses the SOUNDEX algorithm
E.G.: 
where lastname  =*  'Smith';
The SOUNDEX algorithm is English-biased and is less useful for languages other than English.*/



/********************* SUBSETTING AND DEFINE NEW FIELD USING CALCULATED FIELDS AS CONDITION***********************/
proc sql outobs=10;
        select flightnumber, date, destination,
               boarded + transferred + nonrevenue
               as Total
           from sasuser.marchflights
           where total < 100;  
QUIT;
*/
ABOVE CODE WON'T WORK CUZ IN SQL, WHERE CLAUSE IS PROCESSED BEFORE SELECT, BUT TOTAL IS NOT EXIST.
FOLLOWING WILL WORK USING CALCULATED FIELDS:;
proc sql outobs=10;
        select flightnumber, date, destination,
               boarded + transferred + nonrevenue
               as Total
           from sasuser.marchflights
           where calculated total < 100;
QUIT;

* DEFINE NEW FIELD USING CALCULATED FIELDS:;
proc sql outobs=10;
        select flightnumber, date, destination,
               boarded + transferred + nonrevenue
               as Total,
               calculated total/2 as Half
           from sasuser.marchflights;

* The CALCULATED keyword is a SAS enhancement and is not specified in the ANSI Standard for SQL;



/****************************************** Enhancing Query Output ********************************************/
proc sql outobs=15;
     title 'Current Bonus Information';
     title2 'Employees with Salaries > $75,000';
        select empid label='Employee ID',
               jobcode label='Job Code',
               salary,
               salary * .10 as Bonus
               format=dollar12.2
           from sasuser.payrollmaster
           where salary>75000
           order by salary desc;
QUIT;
/* Adding a Character Constant to Output */
proc sql outobs=15;
     title 'Current Bonus Information';
     title2 'Employees with Salaries > $75,000';
        select empid label='Employee ID',
               jobcode label='Job Code',
               salary,
               'bonus is:',                                          /* THIS IS THE NEW CONSTANT COLUMN ADDED */
               salary * .10 format=dollar12.2
           from sasuser.payrollmaster
           where salary>75000
           order by salary desc;



/****************************************** Summarizing and Grouping Data ********************************************/
proc sql;
        select membertype, avg(milestraveled)
               as AvgMilesTraveled
           from sasuser.frequentflyers
           group by membertype;
QUIT;

/* The ANSI-standard summary functions, such as AVG and COUNT, can only be used with a single argument. 
  The SAS summary functions, such as MEAN and N, can be used with either single or multiple arguments.

proc sql;    
   select avg(salary)as AvgSalary                            single argument           
               V.S
proc sql outobs=10;         
   select sum(boarded,transferred,nonrevenue)                multiple arguments
          as Total
;
/* Function                                                                    

AVG (ANSI), MEAN (SAS)

COUNT (ANSI), FREQ (SAS), N (SAS)

CSS  /  CV  /  MAX  /  MIN  /  PRT  /  T  /   USS   /

NMISS  /   RANGE

STD   /    STDERR

SUM (SAS)

VAR
;*/

/*************************************** COUNT() FUNCTION *****************************************
Using this form of COUNT ...	              Returns ...	                                Example
COUNT(*)	                  the total number of rows in a group or in a table	      select count(*) as Count

COUNT(column)	              the total number of rows in a group or in a table       select count(jobcode) as Count
                              for which there is a nonmissing value in the 
                              selected column
 
COUNT(DISTINCT column)	      the total number of unique values in a column	          select count(distinct jobcode) as Count

The COUNT summary function counts only the nonmissing values
To count the number of missing values, use the NMISS function*/

* E.G.1;
proc sql;
        select count(*) as Count
           from sasuser.payrollmaster;

proc sql;
        select substr(jobcode,1,2)
               label='Job Category',
               count(*) as Count
           from sasuser.payrollmaster
           group by 1;


* E.G.2;
proc sql;
        select count(JobCode) as Count
           from sasuser.payrollmaster;

* E.G.3;
proc sql;
        select count(distinct jobcode) as Count
           from sasuser.payrollmaster;


/*************************************** HAVING CLAUSE *****************************************/
proc sql;
        select jobcode, 
               avg(salary) as AvgSalary
               format=dollar11.2
           from sasuser.payrollmaster
           group by jobcode
           having avg(salary) > 56000;           having AvgSalary >56000
/* You can use summary functions in a HAVING clause but not in a WHERE clause, because a HAVING clause is 
    used with groups, but a WHERE clause can only be used with individual rows.
   Note that you do not have to specify the keyword CALCULATED in a HAVING clause; you would have to specify 
    it in a WHERE clause.*/


;

*******************************  SEQUENCE IS ORDAINED ************************************
*******************************  SEQUENCE IS ORDAINED ************************************
*******************************  SEQUENCE IS ORDAINED ************************************;
proc sql;                                                     
title1 'XXXXXXXXXXXXXXXXXXXXXX ';
title2 'xxxxxxxxxxxxxxxxxxxxxx';
   select state,
          sum(milestraveled) as TotTravelMiles,
          count(*) as Members
      from sasuser.frequentflyers
      group by state
      having members lt 5
      order by state;
quit;


************************************************** SUB-QURIES ***********************************************
************************************************** SUB-QURIES ***********************************************
************************************************** SUB-QURIES ***********************************************
************************************************** SUB-QURIES ***********************************************
************************************************** SUB-QURIES ***********************************************
************************************************** SUB-QURIES ***********************************************

* The WHERE and HAVING clauses both subset data based on an expression
* PROC SQL also offers another type of expression that can be used for subsetting in WHERE and HAVING clauses: 
  a query-expression or subquery
* A subquery is a query that is nested in, and is part of, another query
* Subqueries are also known as nested queries, inner queries, and sub-selects

E.G.1:;
proc sql;
        select jobcode, 
               avg(salary) as AvgSalary 
               format=dollar11.2
           from sasuser.payrollmaster
           group by jobcode
           having avg(salary) >
              (select avg(salary)
                 from sasuser.payrollmaster);
* 
* A subquery selects one or more rows from a table, then returns single or multiple values to be used by the outer query
* A subquery can return values for multiple rows but only for a single column
* The table that a subquery references can be either the same as or different from the table referenced by the outer query

* TYPES OF SUB-QURIES:

Type of Subquery                  Description
noncorrelated                     a self-contained subquery that executes independently of the outer query

correlated                        a dependent subquery that requires one or more values to be passed to it by 
				                  the outer query before the subquery can return a value to the outer query

************************************************** NON-CORRELATED SUB-QURIES ***********************************************
************************************************** NON-CORRELATED SUB-QURIES ***********************************************
************************************************** NON-CORRELATED SUB-QURIES ***********************************************


**************************************** Single-Value Noncorrelated Subqueries***************************;
proc sql;
        select jobcode, 
               avg(salary) as AvgSalary 
               format=dollar11.2
           from sasuser.payrollmaster
           group by jobcode
           having avg(salary) >
              (select avg(salary)
                 from sasuser.payrollmaster);
* PROC SQL always evaluates a noncorrelated subquery before the outer query
* If a query contains noncorrelated subqueries at more than one level, PROC SQL evaluates the innermost subquery 
  first and works outward, evaluating the outermost query last

**************************************** Multiple-Value Noncorrelated Subqueries***************************;
* If your noncorrelated subquery might return a value for more than one row, be sure to use one of the following 
  operators in the WHERE or HAVING clause that can handle multiple values:
  1. the conditional operator IN
  2. a comparison operator that is modified by ANY or ALL
  3. the conditional operator EXISTS
  4. if you use the equal (=) operator with a noncorrelated subquery that returns multiple values, the query will fail
  5. The operators ANY and ALL can be used with correlated subqueries, but they are usually used only with noncorrelated 
     subqueries.

E.G.1: (IN);
proc sql;
        select empid, lastname, firstname, 
               city, state
           from sasuser.staffmaster
           where empid in
              (select empid
                 from sasuser.payrollmaster
                 where month(dateofbirth)=2);
* E.G.2: (ANY);
proc sql;
   select empid, jobcode, dateofbirth
      from sasuser.payrollmaster
      where jobcode in ('FA1','FA2')
            and dateofbirth < any
               (select dateofbirth
                  from sasuser.payrollmaster
                  where jobcode='FA3');
* Using the ANY operator to solve this problem results in a large number of calculations,
  which increases processing time. For this example, it would be more efficient to use the MAX function in the subquery. 
  The alternative WHERE clause follows:

  where jobcode in ('FA1','FA2') 
           and dateofbirth < 
              (select max(dateofbirth)
                 from sasuser.payrollmaster
                 where jobcode='FA3');

* E.G.3: (ALL);
proc sql;
        select empid, jobcode, dateofbirth
           from sasuser.payrollmaster
           where jobcode in ('FA1','FA2')
                 and dateofbirth < all
                    (select dateofbirth
                       from sasuser.payrollmaster
                       where jobcode='FA3');
* it would be more efficient to solve this problem using the MIN function in the subquery instead of the ALL operator. 
  The alternative WHERE clause follows:

  where jobcode in ('FA1','FA2') 
           and dateofbirth < 
             (select min(dateofbirth) 
                from sasuser.payrollmaster
                 where jobcode='FA3');



************************************************** CORRELATED SUB-QURIES ***********************************************
************************************************** CORRELATED SUB-QURIES ***********************************************
************************************************** CORRELATED SUB-QURIES ***********************************************

* Correlated subqueries cannot be evaluated independently, but depend on the values passed to them by the outer query for 
  their results
* Usually, a PROC SQL join is a more efficient alternative to a correlated subquery;
  proc sql;
   select lastname, firstname
      from sasuser.staffmaster
      where 'NA'=
         (select jobcategory
            from sasuser.supervisors
            where staffmaster.empid = 
                  supervisors.empid);
* The WHERE clause in the subquery lists the column Staffmaster.EmpID, which is the column that the outer query must pass 
  to the correlated subquery

**************************************EXISTS and NOT EXISTS Conditional Operators ***********************************************
Condition	                                 Is true if ...
EXISTS	                          the subquery returns at least one row
NOT EXISTS	                      the subquery returns no data;
proc sql;
        select lastname, firstname
           from sasuser.flightattendants
           where not exists
              (select *
                 from sasuser.flightschedule
		         where flightattendants.empid=
		               flightschedule.empid);


************************************************** Validating Query Syntax ***********************************************
************************************************** Validating Query Syntax ***********************************************
************************************************** Validating Query Syntax ***********************************************
************************************************** Validating Query Syntax ***********************************************
************************************************** Validating Query Syntax ***********************************************
************************************************** Validating Query Syntax ***********************************************

When you are building a PROC SQL query, you might find it more efficient to check your query without actually executing it:

* the NOEXEC option in the PROC SQL statement
* the VALIDATE keyword before a SELECT statement

E.G.1:;
proc sql noexec;
        select empid, jobcode, salary
           from sasuser.payrollmaster
           where jobcode contains 'NA'
           order by salary;

* E.G.2:;
proc sql; 
        validate                                      /* Note that the VALIDATE keyword is not followed by a semicolon */.
        select empid, jobcode, salary
           from sasuser.payrollmaster
           where jobcode contains 'NA'
           order by salary;
* The main difference between the VALIDATE keyword and the NOEXEC option is that the VALIDATE keyword only affects 
  the SELECT statement that immediately follows it, whereas the NOEXEC option applies to all queries in the PROC SQL step. 
  If you are working with a PROC SQL query that contains multiple SELECT statements, the VALIDATE keyword must be specified 
  before each SELECT statement that you want to check.;






/***************************************************** HORIZONTAL COMBINING *******************************************/
/***************************************************** HORIZONTAL COMBINING *******************************************/
/***************************************************** HORIZONTAL COMBINING *******************************************/
/***************************************************** HORIZONTAL COMBINING *******************************************/
/***************************************************** HORIZONTAL COMBINING *******************************************/
/***************************************************** HORIZONTAL COMBINING *******************************************/
/***************************************************** HORIZONTAL COMBINING *******************************************/

* 3. HORIZONTAL COMBINING;
* REMOVE DUPLICATE COLUMN:;
  proc sql;
   select *
      from one, two
      where one.x = two.x;
* ------------------------->>>;
proc sql;
        select one.x, a, b
           from one, two
           where one.x = two.x;
* Renaming a Column by Using a Column Alias:;
proc sql;
        select one.x as ID, two.x, a, b
           from one, two
           where one.x = two.x;


* Specifying Table Alias For Convinience:;
proc sql;
     title 'Employee Names and Job Codes';
        select staffmaster.empid, lastname, firstname, jobcode
           from sasuser.staffmaster, sasuser.payrollmaster
           where staffmaster.empid=payrollmaster.empid;

* Table aliases are usually optional. However, there are two situations that require their use, as shown below:

Table aliases are required when ¡­                                                     Example
 1. a table is joined to itself (called a self-join or reflexive join)       from airline.staffmaster as s1, 
 	                                                                          airline.staffmaster as s2

 2. you need to reference columns from same-named                            from airline.flightdelays as af,
    tables in different libraries                                                 work.flightdelays as wf
                                                                                  where af.delay > wf.delay



**************************************************  Complex PROC SQL Inner Join ***********************************************
**************************************************  Complex PROC SQL Inner Join ***********************************************
**************************************************  Complex PROC SQL Inner Join ***********************************************

* functions and expressions in the SELECT clause;
proc sql outobs=15;
     title 'New York Employees';
        select substr(firstname,1,1) || '. ' || lastname 
               as Name,
               jobcode,
               int((today() - dateofbirth)/365.25)
               as Age
           from sasuser.payrollmaster as p,
                sasuser.staffmaster as s
           where p.empid =
                 s.empid
                 and state='NY'
           order by 2, 3;

* PROC SQL Inner Join with Summary Functions;
proc sql outobs=15;
     title 'Avg Age of New York Employees';
        select jobcode,
               count(p.empid) as Employees,
               avg(int((today() - dateofbirth)/365.25))
               format=4.1 as AvgAge
           from sasuser.payrollmaster as p,
                sasuser.staffmaster as s
           where p.empid =
                 s.empid
                 and state='NY'
           group by jobcode
           order by jobcode;



**************************************************   Outer Joins ***********************************************
**************************************************   Outer Joins ***********************************************
**************************************************   Outer Joins ***********************************************
;
* Creating an Inner Join with Outer Join-Style Syntax:;
PROC SQL;
   SELECT *
      FROM one
      INNER JOIN TWO
      ON ONE.X = TWO.X;
QUIT;
* An inner join that uses this syntax can be performed on only two tables or views at a time. 
  When an inner join uses the syntax presented earlier, up to 32 tables or views can be combined at once


**********************************   Comparing SQL Joins and DATA Step Match-Merges  ************************
**********************************   Comparing SQL Joins and DATA Step Match-Merges  ************************
**********************************   Comparing SQL Joins and DATA Step Match-Merges  ************************
;
* when all of the values of the selected variable (column) match;
* 1. When all of the values of the BY variable match, you can use a PROC SQL inner join to produce the same results 
     as a DATA step match-merge.
  2. a join does not require that you sort the data first, a DATA step match-merge requires that the data be sorted

* When Only Some of the Values Match:
  1. When only some of the values of the BY variable match, you can use a PROC SQL full outer join to produce the same 
     result as a DATA step match-merge, but need to use COALESCE
  2. a PROC SQL outer join does not overlay the two common columns by default
  3. To overlay common columns, you must use the COALESCE function in the PROC SQL full outer join;
data merged;
   merge three four;
   by x;
run;

* NOW THE SQL IS IDENTICAL AS USING DATA STEP ABOVE:;
proc sql;
title 'Table Merged';
   select coalesce(three.x, four.x)
          as X, a, b
      from three
      full join
      four
      on three.x = four.x;


**************************************************   In-Line Views (A SUB-QUERY)  ***********************************************
**************************************************   In-Line Views (A SUB-QUERY)  ***********************************************
**************************************************   In-Line Views (A SUB-QUERY)  ***********************************************
1. An in-line view is a nested query that is specified in the outer query's FROM clause
2. Unlike a table, an in-line view exists only during query execution. 
3. Because it is temporary, an in-line view can be referenced only in the query in which it is defined
4. Unlike other queries, an in-line view cannot contain an ORDER BY clause
;
from (select flightnumber, date,
                  boarded/passengercapacity*100 
                  as pctfull
                  format=4.1 label=¡¯Percent Full¡¯
             from sasuser.marchflights);

* Referencing Multiple Tables in an In-Line View;
from (select marchflights.flightnumber, 
                  marchflights.date,
                  boarded/passengercapacity*100 
                  as pctfull
                  format=4.1 label=¡¯Percent Full¡¯,
                  delay
              from sasuser.marchflights, 
                   sasuser.flightdelays
              where marchflights.flightnumber=
                    flightdelays.flightnumber
                    and marchflights.date=
                    flightdelays.date)
;
* Assigning an Alias to an In-Line View;
from sasuser.flightschedule as f,
          (select flightnumber, date
                  boarded/passengercapacity*100 
                  as pctfull
                  format=4.1 label=¡¯Percent Full¡¯
              from sasuser.marchflights) as m
     where m.flightnumber=f.flightnumber
           and m.date=f.date;

*                                      ;
proc sql;
title "Flight Destinations and Delays";
   select destination, 
          average format=3.0 label='Average Delay',
          max format=3.0 label='Maximum Delay', 
          late/(late+early) as prob format=5.2
          label='Probability of Delay'
      from (select destination,
                   avg(delay) as average,
                   max(delay) as max,
                   sum(delay > 0) as late,
                   sum(delay <= 0) as early
                   from sasuser.flightdelays
                   group by destination)
      order by average;

* The outer query¡¯s SELECT clause can refer to the calculated columns Late and Early without using the  
  keyword CALCULATED because PROC SQL evaluates the in-line view (the outer query¡¯s FROM clause) first.




/****************************************** VERTICAL COMBINING (TRICKY STUFF INVOLVED) *****************************/
/****************************************** VERTICAL COMBINING (TRICKY STUFF INVOLVED) *****************************/
/****************************************** VERTICAL COMBINING (TRICKY STUFF INVOLVED) *****************************/
/****************************************** VERTICAL COMBINING (TRICKY STUFF INVOLVED) *****************************/
/****************************************** VERTICAL COMBINING (TRICKY STUFF INVOLVED) *****************************/
/****************************************** VERTICAL COMBINING (TRICKY STUFF INVOLVED) *****************************/
/* using four set operators (EXCEPT, INTERSECT, UNION, and OUTER UNION) to combine tables(views) vertically */
/* optional keywords ALL and CORR (CORRESPONDING) */;

proc sql;
        select *
           from sasuser.stress98
        union
        select *
           from sasuser.stress99;
quit;




**************************************************   Using Multiple Set Operators  ***********************************************
;
proc sql; 
        select *
           from sasuser.mechanicslevel1
        outer union
        select *
           from sasuser.mechanicslevel2
        outer union
        select *
           from sasuser.mechanicslevel3;

/* By default, INTERSECT is evaluated first. OUTER UNION, UNION, and EXCEPT all have the same level of precedence. */

/* Three of the four set operators (EXCEPT, INTERSECT, and UNION) combine columns by overlaying them.  
   (The set operator OUTER UNION does not overlay columns.) */;

;
* Keyword                                          Action                                              Used When ...



ALL                              Makes only one pass through the data and                        You do not care if there are duplicates.
                                 does not remove duplicate rows.                                 Duplicates are not possible.
                                                                                                 Caution: ALL cannot be used with OUTER UNION. 
                                                                                                 

                                 






CORR (or-                       Compares and overlays columns by name instead                    Two tables have some or all columns in common, 
CORRESPONDING)                  of by position:                                                  but the columns are not in the same order.
                                ? When used with EXCEPT, INTERSECT, and UNION, 
                                  removes any columns that do not have the same
                                  name in both tables.
								? When used with OUTER UNION, overlays same-named 
                                  columns and displays columns that have nonmatching 
                                  names without overlaying.
                               ;



**************************************************   EXCEPT  ***********************************************
proc sql;
   select *
      from one
   except
   select *
      from two;

* The set operator EXCEPT overlays columns by their position. In this output, the following columns are overlaid:
? the first columns, One.X and Two.X, both of which are numeric
? the second columns, One.A and Two.B, both of which are character. 
? The column names from table One are used, so the second column of output is named A rather than B.;

* EXCEPT using ALL option:;
proc sql;
   select *
      from one
   except all
   select *
      from two;
* UNLIKE EXCEPT WITH NO ALL OPTION, THIS OPTION DO NOT ELEMINATE DUPLICATE OBS AND SHOWS ALL OBS INSTEAD.
----------------------------------------------------------------------------------------------------------------

* EXCEPT usign CORR option:;
proc sql;
   select *
      from one
   except corr
   select *
      from two;
* USING CORR to display both of the following:
? only columns that have the same name
? all unique rows in the first table that do not appear in the second table;


* EXCEPT usign ALL and CORR both:;
* If the keywords ALL and CORR are used together, the EXCEPT operator will display all unique and duplicate rows  
  in the first table that do not appear in the second table, and will overlay and display only columns that have 
  the same name.;
proc sql;
   select *
      from one
   except all corr
   select *
      from two;


**************************************************   INTERSECT  ***********************************************
The GENERAL set operator INTERSECT does both of the following:
? selects unique rows that are common to both tables
? overlays columns.;
proc sql;
   select *
      from one
   intersect
   select *
      from two;

* INTERSECT using ALL option;
proc sql;
   select *
      from one
   intersect ALL
   select *
      from two;

* INTERSECT using CORR option;
proc sql;
   select *
      from one
   intersect corr
   select *
      from two;
* display the unique rows that are common to the two tables based on the column name instead of the column position.
;

* INTERSECT using CORR and ALL option;                *TTTTTRICKYYYYY*;
proc sql;                                            *TTTTTRICKYYYYY*;
   select *
      from one
   intersect ALL CORR
   select *
      from two;
* This is a pretty tricky one that generates the same result as only using CORR, need further investigation.

**************************************************   UNION  ***********************************************
The set operator UNION does both of the following:
? selects unique rows from both tables together
? overlays columns.;
proc sql;
   select *
      from one
   union
   select *
      from two;

* UNION using ALL option;
proc sql;
   select *
      from one
   union ALL
   select *
      from two;

* UNION using CORR option;
proc sql;
   select *
      from one
   union corr
   select *
      from two;

* UNION using CORR and ALL option;                         *TTTTTRICKYYYYY*;
 proc sql;                                                *TTTTTRICKYYYYY*;
   select *
      from one
   union all corr
   select *
      from two;


************************************************** OUTER  UNION  ***********************************************
The set operator OUTER UNION concatenates the results of the queries by
? selecting all rows (both unique and nonunique) from both tables
? not overlaying columns. 
? The ALL keyword is not used with OUTER UNION because this operator's default action is to include all rows in output.

* OUTER UNION using CORR option;
proc sql;
   select *
      from one
   outer union CORR
   select *
      from two;




































/**************************************** VERTICAL COMBINING *************************************************/
/**************************************** VERTICAL COMBINING *************************************************/
/**************************************** VERTICAL COMBINING *************************************************/
/**************************************** VERTICAL COMBINING *************************************************/
/**************************************** VERTICAL COMBINING *************************************************/
/**************************************** VERTICAL COMBINING *************************************************/

* 4. VERTICAL COMBINING;


/************************************ CREATING AND MANAGING TABLES SQL **************************************/
/************************************ CREATING AND MANAGING TABLES SQL **************************************/
/************************************ CREATING AND MANAGING TABLES SQL **************************************/
/************************************ CREATING AND MANAGING TABLES SQL **************************************/
/************************************ CREATING AND MANAGING TABLES SQL **************************************/
/************************************ CREATING AND MANAGING TABLES SQL **************************************/

* 5. CREATING AND MANAGING TABLES SQL;


/************************************ CREATING AND MANAGING INDEX SQL **************************************/
/************************************ CREATING AND MANAGING INDEX SQL **************************************/
/************************************ CREATING AND MANAGING INDEX SQL **************************************/
/************************************ CREATING AND MANAGING INDEX SQL **************************************/
/************************************ CREATING AND MANAGING INDEX SQL **************************************/
/************************************ CREATING AND MANAGING INDEX SQL **************************************/

* 6. CREATING AND MANAGING INDEX SQL;


/************************************ CREATING AND MANAGING VIEWS SQL **************************************/
/************************************ CREATING AND MANAGING VIEWS SQL **************************************/
/************************************ CREATING AND MANAGING VIEWS SQL **************************************/
/************************************ CREATING AND MANAGING VIEWS SQL **************************************/
/************************************ CREATING AND MANAGING VIEWS SQL **************************************/
/************************************ CREATING AND MANAGING VIEWS SQL **************************************/

* 7. CREATING AND MANAGING VIEWS SQL;




/************************************   MANAGING PROCESSING USING SQL **************************************/
/************************************   MANAGING PROCESSING USING SQL **************************************/
/************************************   MANAGING PROCESSING USING SQL **************************************/
/************************************   MANAGING PROCESSING USING SQL **************************************/
/************************************   MANAGING PROCESSING USING SQL **************************************/
/************************************   MANAGING PROCESSING USING SQL **************************************/

* 8. MANAGING PROCESSING USING SQL;
