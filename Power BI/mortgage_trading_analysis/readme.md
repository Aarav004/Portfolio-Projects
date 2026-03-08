# Mortgage Trading Analysis

### Dataset
 We have real simplified mortgage data of over 5000 rows from US market.
 We are part of a non-bank mortgage lender
 Model View of the dataset looks like this.
 
<img width="557" height="412" alt="image" src="https://github.com/user-attachments/assets/6cbca42a-ffda-4172-b88f-260a94ba408c" />

 ### Objective
 Execute a trade of mortgages in the capital markets by analyzing mortgage data, market price and company's target profit on the trade.

#### Task1: Data Cleaning
Load the loan_data.xlxs into the power query and check the data quality and column distribution.
- Replace all errors with number 0.
- We don't need unnecessary columns or redundant columns. So remove columns derived_loan_product_type, derived_dwelling_category, credit_score_type.
- Format interest_rate as percentage.(required to divide by 100)
- format target_price as fixed decimal

#### Risky Ratios
The two most fundamental ratios that describe the riskiness of the loan are loan to value and debt to income.

**The loan to value (LTV)** ratio gives the loan amount over the value of the property. This is important in determining how much the investor would expect to get back if the borrower were to default and stop paying. In that case, the investor could take the property and sell it to try and recoup the loan amount.

$LTV$ = $\frac{\text{[Loan Amount]}}{\text{[property Value]}}$; *lower LTV is better*.

The **debt to income (DTI)** ratio gives the monthly debt payments over the monthly income, and it tells the investor how well the borrower can pay back the loan. Usually, investors don't like to see this over 50% as that would imply that 50% of the borrowers gross income is spent just on debt payments! This doesn't leave a lot of room to pay other things like utility bills, groceries or taxes.

$DTI$ = $\frac{\text{Montly Debt Payments}}{\text{Monthly Income}}$, *generally, needs to be under 50%*

using dax find the LTV and DTI
- Loan to Value Ratio = DIVIDE(SUM(loan_data[loan_amount]), SUM(loan_data[property_value]), 0)
- Monthly Income = DIVIDE(SUM(loan_data[income_thousands]), 12, 0) * 100 ( income is in thousands and annually)
- debt to income ratio = DIVIDE(SUM(loan_data[recurring_monthly_debt]), [Monthly Income], 0)
- Format both LTV and DTI as percentage.

we got DTI = 31.70% and LTV = 60.44%

The LTV and DTI can be much higher, so the loan population seems to have a low default risk. This should definitely help us get some good prices on the trade.

### Task 3 : 
As a trader, have to manage a pipeline of closed loans, and it's our goal to sell them to investors as soon as possible so the business can take the cash to keep lending.

Before a loan can be traded, the loan file must be audited for any errors or missing documentation. Once the audit is finished, it is sent to a document custodian for safe keeping until the loan's ownership can be transfered to the buyer.

- Load loan_status.xlsx into Power Query
- Change the data type for the date fields to dates.
- Add all the fields from loan_status to a Table visualization in the following order: loan_ID, closing_date, file_in_audit, file_audit_complete, file_sent_to_custodian, and file_at_custodian.
- Change each column to short date format.
- We can observe that the dates are in order of process: closing date, file in audit, file audit complete, file sent to custodian, then file at custodian.
  
<img width="665" height="305" alt="image" src="https://github.com/user-attachments/assets/09849e50-093f-47e0-bdcf-c44062d7799b" />

These are process time stamps, and the dates seem to be following a process order. However, some loans are missing some time stamps, which means some loans aren't quite ready to trade yet.

### Are Loans Ready?
We need to find the loan's readiness to trade. To do that we can create a conditional column.
```
Trade Status = 
    IF(ISBLANK(loan_status[file_in_audit]),
        "Closed - Needs Audit",
    IF(ISBLANK(loan_status[file_audit_complete]),
        "Closed - In Audit",
    IF(ISBLANK(loan_status[file_sent_to_custodian]),
        "Closed - Audit Complete",
    IF(ISBLANK(loan_status[file_at_custodian]),
        "Closed - File Sent to Custodian",
    "Closed - Ready to Trade")
        )))
```
Add Trade Status column to the table and check the correctness of the calculated column.  
Create a pie chart using Trade Status and loan_id.  
<img width="612" height="323" alt="image" src="https://github.com/user-attachments/assets/bbf7f94f-82d0-4b6b-99af-a3f404f26638" />  
**60.35% of the loans are in ready to trade status.**

### Scheduled Balances  
  For the context, we are doing our analysis on September 21, 2021. Generally, trades take time as buyers review the loan data, perform financial analysis and contracts are signed. Therefore, we'll target October 13, 2021 as the settlement date. The settlement date is the day the transaction happens: everything is finalized and the lender sells their loans to the financial institutions.

Since the trade settles in the next month, some borrowers will have to make payments on their mortgages for October. We'll need to do some math to figure out what the scheduled principal balance will be for each loan next month.

- Create a calculated column called "Payment Period" in loan_balances which counts the number of payments made so far. ( we have column payment_periods_made)
- Create a new calculated column called "Amortization Amount" in loan_balances using PPMT()
  ```
  Amortization Amount = PPMT(loan_balance[interest_rate]/12, loan_balance[Payment Period], loan_balance[loan_term], loan_balance[current_balance], 0, 0)
  ```
  *interest rate is annual rate, and [fv] and [type] are 0*
- Now create a new calculated column called "Scheduled Principal Balance". (Amortization amount is already negative)
  ```
  Scheduled Principal Balance = loan_balance[current_balance] + loan_balance[Amortization Amount]
  ```
- Add a table with loan_id, current_balance, first_payment_date, next_payment_date, and Scheduled Principal Balance.
  <img width="685" height="292" alt="image" src="https://github.com/user-attachments/assets/e6798e21-83e8-40ad-ac1d-003807f767c3" />  
  *You can see tha some loans have a next payment due date after 10/1/2021, so they have already made their October payment.*

Since we are trying to find october's balance, if the loan has already made october payment, then we are subtracting too much and our amount is incorrect.

#### Correct Scheduled balances
We realized that some loans had already made their october payment. So we don't need to apply payments to these loans. i.e., loans that have next_payment_due_date of 11/1/2021 and beyond do not need to make any additional payment

```
Scheduled_next_payment = DATE(2021, 11, 1) 
```
Modify the Scheduled principal Balance as 
```
Scheduled Principal Balance = loan_balance[current_balance] + 
    IF(loan_balance[next_payment_due_date] < loan_balance[Scheduled Next Payment Date],  loan_balance[Amortization Amount], 0)
```
Now  add the Trade status to the table and Using a Slicer filter for only Ready to Trade.  

**914.41M  scheduled principal balance is ready to trade**





