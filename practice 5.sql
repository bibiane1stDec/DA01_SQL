ex. 1
select b.continent, floor(avg(a.population))
from city as a
inner join country as b 
on a.countrycode and b.code 
group by b.continent

ex.2
