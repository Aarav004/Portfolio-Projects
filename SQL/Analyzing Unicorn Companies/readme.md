## Analyzing Unicorn Companies  

Your task is to first identify the three best-performing industries based on the number of new unicorns created in 2019, 2020, and 2021 combined.

From those industries (1), you will need to find the number of unicorns within these industries (2), the year that they became a unicorn (3), and their average valuation, converted to billions of dollars and rounded to two decimal places (4).

With the above information you can then finish your query to return a table containing industry, year, num_unicorns, and average_valuation_billions. For readability, the firm have asked you to sort your results by year and number of unicorns, both in descending order.

Did you know that the average return from investing in stocks is 
10% per year
 (not accounting for inflation)? But who wants to be average?!

You have been asked to support an investment firm by analyzing trends in high-growth companies. They are interested in understanding which industries are producing the highest valuations and the rate at which new high-value companies are emerging. Providing them with this information gives them a competitive insight as to industry trends and how they should structure their portfolio looking forward.

You have been given access to their unicorns database, which contains the following tables:

`dates`  

`Column`	Description   
`company_id`	A unique ID for the company.  
`date_joined`	The date that the company became a unicorn.  
`year_founded`	The year that the company was founded.  

`funding`  
`Column`	Description  
`company_id`	A unique ID for the company.  
`valuation`	Company value in US dollars.  
`funding`	The amount of funding raised in US dollars.  
`select_investors`	A list of key investors in the company.  

`industries`  
`Column`	Description  
`company_id`	A unique ID for the company.  
`industry`	The industry that the company operates in.  

`companies`  
`Column`	Description  
`company_id`	A unique ID for the company.  
`company`	The name of the company.  
`city`	The city where the company is headquartered.  
`country`	The country where the company is headquartered.  
`continent`	The continent where the company is headquartered.  
The output
Your query should return a table in the following format:

|industry |	year |	num_unicorns |	average_valuation_billions |
|--------:|-----:|--------------:|----------------------------:|
|industry1|	2021 |---            |	---                        |
|industry2|	2020 |---            |                        	---|
|industry3|	2019 |---            |	---                        |
|industry1|	2021 |---            |	---                        |
|industry2|	2020 |---            |	---                        |
|industry3|	2019 |---            |	---                        |
|industry1|	2021 |---            | 	---                        |
|industry2|	2020 |---            |	---                        |
|industry3|	2019 |---            |	---                        |


Where industry1, industry2, and industry3 are the three top-performing industries.
