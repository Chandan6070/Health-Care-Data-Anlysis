use healthcare;
/* 1. Write a SQL query to solve this problem.
ProductType numerical form and ProductType in words are given by
1 - Generic, 
2 - Patent, 
3 - Reference, 
4 - Similar, 
5 - New, 
6 - Specific,
7 - Biological, 
8 – Dinamized
*/
with cte as (
select
	case producttype
		when 1 then "Generic"
        when 2 then "Patent"
        when 3 then "Reference"
        when 4 then "Similar"
        when 5 then "New"
        when 6 then "Specific"
        when 7 then "Biological"
        when 8 then "Dinamized"
	end "ProductType"
from medicine)
select distinct(productType) from cte;

/* 2. Write a query that finds the sum of the quantity of all the medicines in a prescription and 
if the total quantity of medicine is less than 20 tag it as “low quantity”. 
If the quantity of medicine is from 20 to 49 (both numbers including) tag it as “medium quantity“ and 
if the quantity is more than equal to 50 then tag it as “high quantity”.
*/

with quantity_of_medicine as (
select p.prescriptionID, count(c.medicineID) as Quantity
from prescription p 
join contain c on c.prescriptionID = p.prescriptionID
join medicine m on m.medicineID = c.medicineID
group by prescriptionID
)
select *,
	case 
		when Quantity < 20 then "Low Quantity"
        when Quantity between 20 and 49 then "Medium Quantity"
        when Quantity >= 50 then "High Quantity"
    end as "Tag"
from quantity_of_medicine;

/* 3. In the Inventory of a pharmacy 'Spot Rx' the quantity of medicine is considered ‘HIGH QUANTITY’ 
when the quantity exceeds 7500 and ‘LOW QUANTITY’ when the quantity falls short of 1000. 
The discount is considered “HIGH” if the discount rate on a product is 30% or higher, 
and the discount is considered “NONE” when the discount rate on a product is 0%.
 'Spot Rx' needs to find all the Low quantity products with high discounts and all the 
 high-quantity products with no discount so they can adjust the discount rate according to the demand. 
*/

select p.pharmacyName, sum(k.quantity) as Quantity,
	case
		when Quantity > 7500 then "High Quantity"
        when Quantity < 1000 then "Low Quantity"
    end as "Quantity Tag" , k.discount,
    case
		when k.discount >= 30 then "Higher"
        when k.discount = 0 then "None"
    end as "Discount Rate"
from pharmacy p 
join keep k on k.pharmacyID = p.pharmacyID
group by p.pharmacyName;

/* 4. Mack, From HealthDirect Pharmacy, wants to get a list of all the affordable and costly, 
hospital-exclusive medicines in the database. Where affordable medicines are the medicines that 
have a maximum price of less than 50% of the avg maximum price of all the medicines in the database, 
and costly medicines are the medicines that have a maximum price of more than double the avg maximum 
price of all the medicines in the database.  Mack wants clear text next to each medicine name to be 
displayed that identifies the medicine as affordable or costly. The medicines that do not fall under 
either of the two categories need not be displayed.
*/
with categories_wise as (
select productName,
	case 
		when maxPrice < (0.5*(avg(maxPrice))) then "Affordable" 
        when maxPrice >= (2*(avg(maxPrice))) then "Costly" 
    end as "Categories"
from medicine
where hospitalExclusive = "S" 
group by productName)
select * from categories_wise
where Categories is not null;

/* 5. The healthcare department wants to categorize the patients into the following category.

YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.

Write a SQL query to list all the patient name, gender, dob, and their category.
*/

select p.personName as Paitent_Name, p.gender, pt.dob as DOB,
	case
		when pt.dob >= "2005-01-01" and gender = "male" then "Young Male"
        when pt.dob >= "2005-01-01" and gender = "female" then "Young Female"
        when pt.dob >= "1985-01-01" and pt.dob < "2005-01-01" and gender = "male" then "Adult Male"
        when pt.dob >= "1985-01-01" and pt.dob < "2005-01-01" and gender = "female" then "Adult Female"
        when pt.dob >= "1970-01-01" and pt.dob < "1985-01-01" and gender = "male" then "Mid Age Male"
        when pt.dob >= "1970-01-01" and pt.dob < "1985-01-01" and gender = "female" then "Mid Age Female"
        when pt.dob < "1970-01-01" and gender = "male" then "Elder Male"
        when pt.dob < "1970-01-01" and gender = "female" then "Elder Female"
        
    end as "Categories"
from person p
join patient pt on p.personID = pt.patientID;