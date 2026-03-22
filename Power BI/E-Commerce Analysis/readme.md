
## Ecommerce Analysis  

We will be working on a fictitious data from online pet supply store. We will be analyzing the dataset and leverage Power BI to create an engaging dashboard-style pages.  

Goals of this analysis:
- Serve as many customers as possible and increase sales
- Reduce the operating costs
- Provide actionable insights on how to increase sales and reduce expenses

##### Importing data  
Let's connect data sources and ensure the correct relationships exist betweeen the tables in our data model.  
While loading csv files we ran into an issue.  
<img width="636" height="302" alt="image" src="https://github.com/user-attachments/assets/ece7572a-03c7-4497-a4a2-d5e3aeeed18c" />  
More than half of the rows are errors. We should find the cause and fix it. If not we could loss valuable data.  
issue is with `Transaction Data` column. Let's try fixing it.  
-  Most of the values in the column are invalid, even though they look fine.  
  <img width="806" height="538" alt="image" src="https://github.com/user-attachments/assets/26f884f7-7418-419e-b5c7-2a043a40545b" />

- lets try to change the datatype using locale.
  because, there could be chance that the powerBI is unable to recognize the format.i.e., USA mm-dd-yyyy and UK dd-mm-yyyy
  Even after doing the above step, Still getting invalid rows.
- Well in such case we will split the column into different columns `Year`, `Month`, `Day`, and `Time`.  
  
  <img width="1148" height="662" alt="image" src="https://github.com/user-attachments/assets/78d55a08-42d6-4e00-b4be-61c909b53f1a" />
  *even after splitting individual columns are still have invalid data*.
Let's proceed further
  
- So, we made sure that the data type is text in between the steps to make sure that we achieve the desired output.  

<img width="1140" height="496" alt="image" src="https://github.com/user-attachments/assets/43cd76ae-c5e7-41c2-8e3f-98dee61c017a" />

We found that different versions of the same US states in the Order State variable exist. So, to make our analysis accurate, we need to join state_mapping table to customer table. Now we have unique version for each state. Classify the `State` column as a "State or Province".

Our datamodel  
<img width="1010" height="738" alt="image" src="https://github.com/user-attachments/assets/4cc43575-9997-41ed-82d7-0c83e88bebf1" />  

- We found that the `Invoice No` have blanks. But a valid transaction should have a Invoice No. So, remove the blank invoice values.

## Customer Metrics  

We want to understand how many customers the company has and their total business.  
we will use two of such metrics.
  - Number of Customers
      - ```Number of Customers = DISTINCTCOUNTNOBLANK(Sales[Customer ID])```
      - we are using `DISTINCTCOUNTNOBLANK` to count the customers who ordered/did business with the company. that is, customers who are in sales table.
        
  - Customer Lifetime value (CLTV) or Liftime value(LTV)
       - The total value of all sales by a customer.
       - ```Customer LTV (avg) = SUM(Sales[Sales])/[Number of Customers]```
       - The higher the customer lifetime value, the more important the customer is to the company.
         
Create a Map visualization using  `Number of Customers` measure and `State` variable.
Also, Visualize Customer Lifetime value by state. Show the top 20 states by customer lifetime value.

<img width="985" height="565" alt="image" src="https://github.com/user-attachments/assets/ba333858-bc7f-4f95-96db-7301895eaf23" />   

### Products and shipping  
It is important to know what products sell well and what type of costs mights be associated with selling those products. So, we will look at the products which are selling in higher quantities and how much total sales they are generating. We will also look into the products that have the highest shipping costs associated.  

Display the average `Quantity` by the product `Descriptin`.  
Create a treemap that visualizes total `Sales` amount by product `Description` and product `Category`.  

The Shipping Cost 1000 mile field is the average cost to ship a single quantity of a product by itself (without combining it with other products).
Create a barchart that displays `Shipping_Cost_1000_mile` by `Description`. Use average as summerization. 
We can observe that there are two descriptions of the same product. So, replace all "Indoor Pet Camera (Wi-Fi)" descriptions in the Sales table with "Indoor Pet Camera".

<img width="862" height="482" alt="image" src="https://github.com/user-attachments/assets/a87c2fd2-23cd-40cf-9514-2c5b72acbe12" />
 

Let us view the total sales by average quantity. Many customers buy a single quantity of a product but combine that with other product types. The average quantity differs when calculated at the invoice level vs. across the entire business.

create a visualization that displays the sales by quantity of a product across all sales. Filter out quantities less than zero (returned orders). Display only quantities associated with sales by making the x-variable category.

Let's see what the total sales by total invoice quantity would look like for the company.
Duplicate the `Sales` table and name the new table `Invoice Totals`.
Group the data in the `Invoice Totals` table to create a table aggregating the total quantity and total sales amount by The Invoice No.  
Create a visualization that displays the total sales by invoice total quantity of a product across all sales.  
like before filter out returned orders, and display x-axis as categorical.  

<img width="967" height="288" alt="image" src="https://github.com/user-attachments/assets/c84afe78-b5f0-41d6-963a-b4df998dc82f" />  

Most often, the company ships multiple products in a single shipment. They do a good job selling multiple product types in a single invoice.

### Simple version of Market basket analysis
Market basket analysis allows a retailer to understand customer purchasing patterns better. If they buy one specific product, what else do they buy?
Market basket analysis is a data mining technique retailers use to increase sales by better understanding customer purchasing patterns. It helps to find products frequently bought together.  
Let's implement simplified version of market basket visualization.  

- Copy the Sales table. `Market Basket = Sales`
- Use the 'Invoice No' to create a relationship between the `Market Basket` table and the `Sales` table.
- Create a Table or Slicer containing the product descriptions from the `Sales` table.
- Create a chart visual using the Description from the Market Basket table, counting the number of occurrences of the variable.
- Alter the interactions between the two visuals, ensuring that the list filters down the information in the chart.

<img width="962" height="317" alt="image" src="https://github.com/user-attachments/assets/f0809f9f-2d08-4343-9cb2-2ab2e7d3bbb5" />  
> Earth Rated Dog Poop Bags is most often purchased along with the Pet Hair Remover.

### What-if Analysis  
The company hasn't automated integration with shipping providers and does not capture shipping costs at the transaction level. Shipping more than one quantity of an item costs on average, 70% of the cost of a single-unit shipment. There are variances based on the product.  
We usually know that shipping a single quantity costs more.
- Per-unit costs go down with higher shipped quantity.
- Savings for customers and good for the environment too.

Let's build the required metrics to make an interactive what-if analysis for with effective shipping rates as the quantity changes.  
- add Shipping Cost column using shipping_cost_1000_mile to the sales table.
  ```
  Shipping Cost = RELATED(Products[Shipping_Cost_1000_mile])
  ```
- Create a new measure in the Sales table called "Shipping (Baseline)", that will sum the costs of shipping items iteratively across the Sales table.
  ```
  Shipping (Baseline) = SUMX(Sales,
        IF(Sales[Quantity] = 1, Sales[Shipping Cost],
        Sales[Shipping Cost] + (Sales[Quantity] - 1) * (Sales[Shipping Cost] * 0.7)))
  ```
- Create a new parameter called "What-if quantity" of integer type. Allow values from 1 to 20 in steps of one, with the current value set to five.

- Create a new measure in the What-if quantity table called "Blended Shipping Cost Factor", which calculates the discounted shipping cost based on different costs for differnt quantities.
```
Blended Shipping Cost Factor = IF('What-if quantity'[What-if quantity Value] <=1, 1,
IF('What-if quantity'[What-if quantity Value] <=2, 0.8,
IF('What-if quantity'[What-if quantity Value] <=4, 0.6, 
IF('What-if quantity'[What-if quantity Value]<= 7, 0.5,
IF('What-if quantity'[What-if quantity Value] <=9, 0.4,
    0.3)))))
```
- Create a new measure in the Sales table called "Shipping (What-if)" using `Blended Shipping Cost Factor`

```
Shipping (What-if) = SUMX(Sales,
        IF(Sales[Quantity] = 1, Sales[Shipping Cost],
        Sales[Shipping Cost] + ((Sales[Quantity] - 1) * (Sales[Shipping Cost] * [Blended Shipping Cost Factor]))))
```
- calculate the difference between the shipping (baseline) and shipping (What-if)
  ```Shipping (Difference) = [Shipping (Baseline)] - [Shipping (What-if)]```
<img width="362" height="72" alt="image" src="https://github.com/user-attachments/assets/6e3a83a4-688c-4b61-8c49-5d729a15ba4a" />
> For the default value 5 of shipped quantity, total shipping costs decreased by $59095.20

<img width="970" height="305" alt="image" src="https://github.com/user-attachments/assets/089de5a3-d0a9-4ec3-9e96-0d2a7a5fc387" />  

- let us compare shipping costs (baseline) with a hypothetical what-if scenario. Change parameter values and see how it impacts the shipping costs.
<img width="965" height="388" alt="image" src="https://github.com/user-attachments/assets/8b8a0155-e3b3-4625-bfa3-e1e5be3a53c2" />
>the shipping cost savings (the difference between baseline and what-if shipping amount) for Dog and Puppy Pads when the What-if Quantity is set to 10 is $10,904

- Let's create a measure to calculate cumulative shipping costs(baseline, what-if, difference).
-  we have to sum the Shipping (Baseline) measure across the whole table, ensuring that all values are selected, and each new total is summed for a date before the max
```
Baseline running total = SUMX(FILTER(ALLSELECTED(sales), Sales[Transaction Date] <=MAX('Market Basket'[Transaction Date])), [Shipping (Baseline)])

What-if running total = SUMX(FILTER(ALLSELECTED(sales), Sales[Transaction Date] <=MAX('Market Basket'[Transaction Date])), [Shipping (What-if)])

Difference running total = SUMX(FILTER(ALLSELECTED(sales), Sales[Transaction Date] <=MAX('Market Basket'[Transaction Date])), [Shipping (Difference)])
```
- Let's add three cards that display the Shipping (Baseline), Shipping (What-if), and Shipping (Difference).
- Also, let's display the running total of the three main shipping metrics over month and year in an area chart.

<img width="970" height="556" alt="image" src="https://github.com/user-attachments/assets/4ea135d3-002f-42ab-9037-ef2a97cd7ac9" />  
>the amount of savings if Pet Odor Eliminator ships seven items together is $4184.

### Designing Dashboard pages  
Lets create 3 pages
- Executive Summary: KPIs
- Shipping Costs: will suggest strategies to reduce costs
- Growth Opportunities: Will provide Specific recommendations

Let's calculate few KPIs
  ```
  COGS = Sales[Quantity] * RELATED(Products[Landed Cost])
  Profit (Baseline) = Sales[Sales] - Sales[COGS] - [Shipping (Baseline)]
  Profit % = SUM(Sales[Profit (Baseline)])/SUM(Sales[Sales])
  ```

An executive summary provides a quick pulse of the business operations and displays metrics such as sales, profit, and expenses. In addition, it provides an ability to drill down or filter on dimensions like product and customer location.

- Add a map visual which displays total sales by state
- Display total sales by each product
- Add KPI as card visuals (profit %, Total sales, profit (Baseline), Shipping (Baseline)
- Add a product slicer
- let's also add a breakdown of profit margin by product.
<img width="1917" height="883" alt="image" src="https://github.com/user-attachments/assets/67115a06-f33c-4135-8840-e08559cac244" />


In the Market Basket Analysis page, create a stacked column & line chart using description, sales and profit %.

<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/752611e2-a03d-42bd-ae43-1ce8ebdb19e1" />  

Let's visualize shipping costs breakdown by geography and also provide recommendations on quantity upsell strategies.

<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/bdab4d23-7bab-4158-b1c1-20eb9ad0d400" />

### Recommendations
- To increase sales and to recommend on which products should be recommended to customers on the checkout page for cross-sell promotions, use Market Basket analysis and check for each product by slicing the list of product descriptions.
- To reduce shipping cost, refer shipping metrics page, and use slicer to decide on the shipping quantity to reduce the shipping cost for each product.
  
  






