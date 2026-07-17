---
--- Harris Fungwi
--- 17th July 2026
--- compute compound interest
---

--create object type
CREATE OR REPLACE TYPE compound_interest_tab_ot IS OBJECT
  (
   period            NUMBER
  ,initial_principal NUMBER
  ,interest_rate     NUMBER
  ,new_principal     NUMBER
  )
/

--create nested table
CREATE OR REPLACE TYPE compound_interest_tab_nt IS TABLE OF compound_interest_tab_ot
/

--create pipelined table function
CREATE OR REPLACE FUNCTION compute_compound_interest
  ( 
   initial_principal_in IN NUMBER
  ,preiodic_rate_in     IN NUMBER
  ,periods_in           IN NUMBER
  )
RETURN compound_interest_tab_nt 
AUTHID DEFINER
IS
  v_initial_principal NUMBER := initial_principal_in;
  v_periodic_rate     NUMBER := preiodic_rate_in;
  v_profit            NUMBER;
  v_new_principal     NUMBER;
  v_period            NUMBER := periods_in;
  v_repitition        NUMBER := 1;
  v_ci_tab            compound_interest_tab_nt := compound_interest_tab_nt();
BEGIN
  v_new_principal := v_initial_principal;

  WHILE v_repitition <= v_period
  LOOP
      v_initial_principal := v_new_principal; 
      v_profit            := v_new_principal * v_periodic_rate; 
      v_new_principal     := v_profit + v_initial_principal;

      v_ci_tab.EXTEND(1); 
      
      v_ci_tab(v_ci_tab.COUNT) := compound_interest_tab_ot(
                                    			   v_repitition,
                                    			   ROUND(v_initial_principal, 2),
                                    			   ROUND(v_profit, 2),
                                    			   ROUND(v_new_principal, 2)
                                  			  );
      v_repitition := v_repitition + 1;

  END LOOP;
  
  RETURN v_ci_tab;
END compute_compound_interest;
/

--example usecase   
--compute compound interest for a starting principal of 1000, interest rate of 10%, and period of 12(months, days, whatever)
SELECT * 
FROM compute_compound_interest( 1000, 0.1, 12);

-- to insert into a table
CREATE TABLE interest_on_loan (
   loan_id                      NUMBER
  ,period                       NUMBER
  ,loan_type                    VARCHAR2(32 CHAR) --e.g car payyment, mortgage,
  ,period_type                  VARCHAR2(32 CHAR) --e.g year(s), day(s), month(s), week(s)
  ,starting_principal           NUMBER
  ,interest_accrued             NUMBER
  ,new_loan_amount              NUMBER
  ,CONSTRAINT interest_on_loan_pk PRIMARY KEY (loan_id, period) 
  );

-- 
-- compute compound interest for a credit card balance of 1000, interest rate of 22%, over a period of 12 months
--
INSERT INTO interest_on_loan
SELECT 1, period, 'Credit card payment', 'Month' initial_principal, interest_rate, new_principal 
FROM compute_compound_interest( 1000, 0.22, 12);

--select * from table
SELECT * FROM interest_on_loan;

--
-- the below code is the equivalent of all the above processes in SQL
--

SELECT 
  LEVEL AS period,
  ROUND(&&initial_principal  * POWER(1 + &&periodic_rate, LEVEL - 1), 2)                    AS initial_principal,
  ROUND((&&initial_principal * POWER(1 + &&periodic_rate, LEVEL - 1)) * &&periodic_rate, 2) AS interest_rate,
  ROUND(&&initial_principal  * POWER(1 + &&periodic_rate, LEVEL), 2)                        AS new_principal
FROM dual
CONNECT BY LEVEL <= &periods;

-- Clean up session variables
UNDEFINE initial_principal;
UNDEFINE periodic_rate;
UNDEFINE periods; 
