create schema capstone1;

/* 

2. Get information about individuals who are diabetic and have heart ailments. Get average age, average no. of children dependent, average BMI, and average hospitalization costs for such individuals.
3. What are the average charges of hospitalization across different hospital levels and cities?
4. How many individuals who have had any major surgeries have cancer history?
5. Find out how many Tier-1 hospitals in each state.
*/


/* 1. To get a complete understanding of the driving factors behind hospitalisation costs, 
      it is important to merge the given tables. 
      Identify the columns present in the data tables which can allow that to happen. 
      Add ‘Primary Key’ constraint for these columns in both the tables.
      Hint: remove duplicates and null values in the column and then use alter table to add primary key constraint.
*/

create schema capstone1;
use capstone1;

# get table dat from csv


select `Customer ID` , count(*) as ct from hosp
group by `Customer ID`
order by ct desc;

# remove rwos where customer id = ?

SET SQL_SAFE_UPDATES = 0;

delete from hosp
where `Customer ID` ="?";

# making cust id not null
alter table hosp
modify  `Customer ID` varchar(10) not null;

# making it a primary key
alter table hosp
add primary key ( `Customer ID`);

# repeating with medic table
alter table medic
modify  `Customer ID` varchar(10) not null;

alter table medic
add primary key ( `Customer ID`);

SET SQL_SAFE_UPDATES = 1;

select `Customer ID` , count(*) as ct from hosp
group by `Customer ID`
order by ct desc;


/* 2. Get information about individuals who are diabetic and have heart ailments. 
      Get average age, average no. of children dependent, average BMI, and 
      average hospitalization costs for such individuals. */
 
 SELECT 
    m.diabetes,
    m.`Heart Issues`,
    round(AVG(h.age),0) AS avg_age,
    round(AVG(h.children),0) AS avg_child_dep,
    round(AVG(m.BMI),2) AS avg_bmi,
    round(AVG(h.charges),2) AS avg_charges
FROM
    (select * , 2022 - year AS age
    from hosp) h,
    (SELECT 
        *,
            CASE
                WHEN HBA1C > 6.5 THEN 'Yes'
                ELSE 'No'
            END AS diabetes
    FROM
        medic) m
	where h.`Customer ID` = m.`Customer ID`
GROUP BY m.diabetes ,m.`Heart Issues`;


/* What are the average charges of hospitalization across different hospital levels and cities?*/
/* replace "?" in City tier and hospital tier with mode value */

select `Hospital tier`,count(*) as ct
from hosp
group by `Hospital tier`
order by ct ;

select `City tier`,count(*) as ct
from hosp
group by `City tier`
order by ct ;

# replace "?" with mode values
SET SQL_SAFE_UPDATES = 0;
update hosp
set `Hospital tier` = "tier - 2"
where `Hospital tier` = "?";

update hosp
set `City tier` = "tier - 2"
where `City tier` = "?";
SET SQL_SAFE_UPDATES = 1;

select `Hospital tier`, `City tier` , avg(charges) as avg_charges
from  hosp
group by `Hospital tier`,`City tier`;


/* How many individuals who have had any major surgeries have cancer history? */
select `Cancer history`, surgery, count(*) as count_pat
from (
select *, 
case 
when NumberOfMajorSurgeries>= 1 then "Yes"
else "No"
end as surgery
from  medic) m
group by `Cancer history`, surgery
having `Cancer history` = "yes"
;

/* Find out how many Tier-1 hospitals in each state.*/

# replace "?" in state id with mode value
select * from hosp ;
select `State ID` , count(*) as ct
from hosp
group by `State ID`
order by ct desc;
SET SQL_SAFE_UPDATES = 0;
update hosp
set `Hospital tier` = "tier - 2"
where `Hospital tier` = "?";

select `State ID`, `Hospital tier` , count(*) as hosp_count
from hosp
group by `State ID`, `Hospital tier`
having `Hospital tier` = "tier - 1";
