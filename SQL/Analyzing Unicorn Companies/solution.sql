With best_performers AS(
		Select industry,extract('year' from date_joined) as year, count(i.company_id) as num_unicorns
		from industries i
		Inner Join dates d on i.company_id = d.company_id
		where extract('year' from date_joined) in (2019, 2020, 2021) and industry in('Fintech', 'Internet software & services', 'E-commerce & direct-to-consumer')
		group by industry, extract('year' from date_joined)
		order by num_unicorns desc
),
valuations AS(
	select industry,extract('year' from date_joined) as year, avg(valuation) as avg_val
	from industries i
	INNER JOIN funding f on f.company_id = i.company_id
	INNER JOIN dates d on d.company_id = i.company_id
	where extract('year' from date_joined) in (2019, 2020, 2021) and industry in('Fintech', 'Internet software & services', 'E-commerce & direct-to-consumer')
	group by industry, extract('year' from date_joined)
)

select DISTINCT i.industry,extract('year' from date_joined) as year, num_unicorns, round(avg_val/1000000000.0, 2) as average_valuation_billions
from industries i
inner join dates d on d.company_id = i.company_id
inner join best_performers bp on bp.industry = i.industry and bp.year = extract('year' from d.date_joined)
inner join valuations v on v.industry = i.industry and v.year = extract('year' from d.date_joined)
where extract('year' from date_joined) in (2019, 2020, 2021)
ORDER BY year DESC, num_unicorns DESC


