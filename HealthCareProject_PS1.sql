create database if not exists Healthcare;
use healthcare;
-- ------------------------Healthcare project 1 ----------------------
/* 1.shows how the number of treatments each age category of patients has gone through in the year 2022
 
The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years), and Seniors (65 years and over). */

with Age_Of_Patient as (SELECT  patientID, (year(current_timestamp) - year(dob)) as Age,
                            CASE
								WHEN (year(current_timestamp) - year(dob)) <= 14 THEN "Children"
								WHEN (year(current_timestamp) - year(dob)) between 14 and 24 THEN "Youths"
								WHEN (year(current_timestamp) - year(dob)) between 25 and 64 THEN "Adults"
								ELSE "Senior"
							END as Age_Category 
							from patient)
                            
select count(t.treatmentID) as Treatments, Age_Category
from treatment t 
join Age_Of_Patient a on a.patientID = t.patientID
group by a.Age_Category;


/* 2. Jimmy, from the healthcare department, wants to know which disease is infecting people of which gender more often.
Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio. 
Sort the data in a way that is helpful for Jimmy. 
*/

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY','')); 

with Gender_wise_count as (
select d.diseaseID, d.diseaseName, p.gender, count(treatmentID) as Count_of_Gender
from disease d
join treatment t on t.diseaseID = d.diseaseID
join person p on p.personID = t.patientID
group by d.diseaseID, p.gender
)
select m.diseaseName, m.Count_of_Gender as Male_Count, f.Count_of_Gender as Female_Count, 
round(((m.Count_of_Gender) / (f.Count_of_Gender)),2) as Male_to_Female_Ratio 
from (select *
			from Gender_wise_count
            where gender = 'male') m 
join (select *
			from Gender_wise_count
            where gender = 'female') f on f.diseaseID = m.diseaseID
order by m.diseaseName;


/*3. Jacob, from insurance management, has noticed that insurance claims are not made for all the treatments. 
He also wants to figure out if the gender of the patient has any impact on the insurance claim. 
Assist Jacob in this situation by generating a report that finds for each gender the number of 
treatments, number of claims, and treatment-to-claim ratio. And notice if there is a significant 
difference between the treatment-to-claim ratio of male and female patients.
*/

with Treatment_Insurance_Claim as (
select count(t.treatmentID) as Number_of_Treatment, count(t.claimID) as Number_of_Claim, p.gender, count(t.patientID) as Count_of_Gender
from treatment t
join person p on p.personID = t.patientID
group by p.gender
)
select Number_of_Treatment,Number_of_Claim, round((Number_of_Treatment / Number_of_Claim),2) as Treatment_to_Claim_Ratio, gender, Count_of_Gender
from Treatment_Insurance_Claim;

/*
4.The Healthcare department wants a report about the inventory of pharmacies. 
Generate a report on their behalf that shows how many units of medicine each pharmacy has in their inventory, 
the total maximum retail price of those medicines, and the total price of all the medicines after discount.
 
Note: discount field in keep signifies the percentage of discount on the maximum price.
*/
select p.pharmacyName, 
sum(k.quantity) as Unit_of_Medicine, 
sum(m.maxPrice) as total_MRP, 
round(sum((m.maxPrice-(m.maxprice*(k.discount/100)))),2) as Total_Price_After_Discount
from pharmacy p
join keep k on k.pharmacyID = p.pharmacyID
join medicine m on m.medicineID = k.medicineID
group by pharmacyName;

/* 5. The healthcare department suspects that some pharmacies prescribe more medicines than others in a 
single prescription, for them, generate a report that finds for each pharmacy the maximum, 
minimum and average number of medicines prescribed in their prescriptions. */ 
with Report_of_Pharmacy as(
select p.pharmacyName, count(c.medicineID) as Count_of_Medicince
from pharmacy p
join prescription pre on pre.pharmacyID = p.pharmacyID
join contain c on c.prescriptionID = pre.prescriptionID
group by pre.prescriptionID
)
select pharmacyName, max(Count_of_Medicince) as Max_No_of_Medicine_Prescribed, 
min(Count_of_Medicince) as Min_No_of_Medicine_Prescribed, round(avg(Count_of_Medicince)) as Avg_No_of_Medicine_Prescribed
from Report_of_Pharmacy
group by pharmacyName;



select distinct(pharmacyName) from pharmacy;



 