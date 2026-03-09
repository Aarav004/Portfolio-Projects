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

## Theory
There are two types of common transactions in mortgage trades
1. Whole loan trade
2. Securitization

**Whole loan trade** is a trade in which an investory individually bids on each mortgage.
- This is pretty straightforward, as the investory knows exactly which mortgages they purchase.
- However, this type of transaction is inefficient as the investor needs to analyze each loan, which can be time-consuming.

**Mortgage-backed Securities (Securitization)** is the most common type of transaction seen in the mortgage capital markets.
- With securitization, mortgage pools are bundled into a new financial asset called a mortgage backed security and the investor buys the security instead of the individual mortgage.
- Securitizations are usually formed from mortgage pools with similar characteristics.
  -e.g. rate, term, loan-to-value, location, or even the lender who originated the loan.

Once an investory has identified which mortgage or MBS bond they want, they will place a bid on it with a price.  
**Trade Price** is expressed as the percentage of the bond's principal balance.  
**Trade amount** is the total dollar amount paid for the loan.  
$\text{Trade Price} * \text{Principal Balance}  
**Trade Premium** is the difference between the principal balance and the trade amount.  
$\text{Trade Amount} - \text{Principal Balance}  
*shows the extra amount the investor paid to own the mortgage*  

### Bids Recieved  
After sending our mortgage data out, counterparties are sending their best bids.  
- load loan_bids.xlsx into power Query and reshaper it so that the bids to all be in the same column.
- Group by loan_id with "All rows" operation.
- Add a custom column that finds the highest price from all bids.
  ```
  max_price = Table.Max([All Bids], "Price")
  ```
- Filter out passed bids

We got the highest price for each mortgage but, how do we know if this is the best price? Let's compare it against a benchmark.
we have another option to sell these loans into Uniform Mortgage-Backed Securities (UMBS).  

Merge loan_data, umbs_prices and loan_bids and include only necessary columsn which expanding. 

Selling our loans to a securitizer is a much more efficient process. So we would only want to trade to whole loan counterparties if they can beat price we can get from UMBS bonds.  

create a calculated column.
```
Benchmark Test = IF(loan_data[Price] > loan_data[umbs_price], "True", "False")
```

<img width="407" height="240" alt="image" src="https://github.com/user-attachments/assets/4598981e-b486-4690-a9c4-1ea5963b22d7" />  
*Turns out that majority of prices we got weren't as great as we could get by selling these loans into UMBS bonds. However, we are getting a good price on over 1400 loans.*  

We will calculate the trade amount and trade premium amounts to understand how much money we'll make on these trades.  
```
Trade Amount = RELATED(loan_balance[Scheduled Principal Balance]) * loan_data[Price]/100
```
```
Trade Premium = [Trade Amount] - RELATED(loan_balance[Scheduled Principal Balance])
```
filter for Benchmark Test = True and add these fields to a table.
>we can sell these loans for a premium of $15.14M. This amount is just the amount earned from the market.

A **weighted-average** would give more representation to larger loans which would produce more dollar price amount, than smaller loans.
```
WA Price = DIVIDE(SUMX(loan_data, loan_data[Price] * RELATED(loan_balance[Scheduled Principal Balance])),
    SUM(loan_balance[Scheduled Principal Balance]), 0)
```
<img width="307" height="108" alt="image" src="https://github.com/user-attachments/assets/4dc74cc0-a78f-46ef-87cb-7b27a91ddef5" />  
>while the differences may seem small, the weighted average of price gives a truer average because of the way it considers balances. This becomes important especially on a large scale.

- Create a table with counter_party, count of loan_id, sum of scheduled principal balance, WA price, sum of trade amount, and Sum of Trade Premium.
- create a clusterd column chart with counterparty and sum of trade amount
- create a 100% stacked bar chart with counterparty as legend and sum of trade premium on x-axix.
  <img width="790" height="447" alt="image" src="https://github.com/user-attachments/assets/8de03fb8-a3a8-4a5b-8a15-cb11b37df404" />
>Snells largo is contributing to less than 1% of trade premium on this transaction. With all the work and expenses it takes to draw up the contracts and execute a trade on 14 loans,it's not worth only making $65K in premium.

Need to analyze how much money the company made on these loans.    
```
Total Loan Revenue = SUMX(loan_data, loan_data[Trade Premium] + loan_data[origition_charges])
```
```
Loan Gross Profit = SUMX(loan_data, [Total Loan Revenue] - loan_data[lender_credits])
```
```
Loan Profit Margin = DIVIDE([Loan Gross Profit],SUMX(loan_balance,loan_balance[Scheduled Principal Balance]),0)
```
>After accounting for lending fees and credits, company made 5.69% on each dollar it lent.
 ```
Target Profit Margin = DIVIDE(SUMX(loan_data, loan_data[target_profit]), SUMX(loan_data, loan_data[loan_amount]), 0)
```
>company was pricing their origination fee to make a margin of 5% per loan.

Now we know that our actual Loan Profit Margin is greater than our Target Profit, we should explore why this happened. While it is great to make more money than we expected from the trade, lending is a competitive business where even a small price difference can mean the difference between winning or losing borrowers. Many borrowers will shop around at different mortgage lenders to get quotes; even a difference as small as .25% is enough to lose a potential borrower.  

Create a key Influencers visual. add analyze Price and explain by loan_amount, loan to value, debt to income, median_fico_score.  
<img width="871" height="376" alt="image" src="https://github.com/user-attachments/assets/aeea2298-26a8-4968-828a-1acfdb6457f2" />  

It seems like one of the biggest influencers on price is the FICO score. This makes sense, as a higher credit score means the borrower is less likely to default, and 760 is a very good score!  

## Recommendation  
Based on our finding that median FICO scores between ove 760 had a higher margin by 72 basis points(bps) and prices are lower by 85 bps when FICO is 711 or less.  

>We should create pricing groups for different ranges of Credit Scores as Scores increase the fee decreases.

<img width="1141" height="642" alt="image" src="https://github.com/user-attachments/assets/7b14a112-b9e2-4329-b7bf-a3f6ca447b8d" />










