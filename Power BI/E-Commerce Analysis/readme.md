
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
  *even after splitting, individual columns are still have invalid data. Let's proceed further*
  
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
> Neveda has one of the highest Customer LTV.

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








