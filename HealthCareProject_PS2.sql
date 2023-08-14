use healthcare;
-- ------------------------Healthcare project 2 ----------------------

/*1. A company needs to set up 3 new pharmacies, they have come up with an idea that the pharmacy 
can be set up in cities where the pharmacy-to-prescription ratio is the lowest and the number of 
prescriptions should exceed 100. 
Assist the company to identify those cities where the pharmacy can be set up.
*/
select a.city, count(p.pharmacyID) as Number_of_Pharmacy,
	count(pre.prescriptionID) as Number_of_Prescription, 
    round((count(p.pharmacyID) / count(pre.prescriptionID)),2) as Pharmacy_to_Pescription_Ratio
from pharmacy p 
join prescription pre on pre.pharmacyID = p.pharmacyID
join address a on a.addressID = p.addressID
group by a.city
having count(pre.prescriptionID) > 100
order by Pharmacy_to_Pescription_Ratio desc, a.city;

/*2. The State of Alabama (AL) is trying to manage its healthcare resources more efficiently. 
For each city in their state, they need to identify the disease for which the maximum number of 
patients have gone for treatment. Assist the state for this purpose.

Note: The state of Alabama is represented as AL in Address Table.
*/
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

select distinct(a.city) as City , 
		d.diseaseName, count(t.patientID) as Patient
	from address a 
    join person p on p.addressID = a.addressID
    join treatment t on t.patientID = p.personID
    join disease d on d.diseaseID = t.diseaseID
where a.state = 'AL'
group by d.diseaseName
order by Patient desc limit 1;

/*3. The healthcare department needs a report about insurance plans. 
The report is required to include the insurance plan, 
which was claimed the most and least for each disease.  Assist to create such a report.
*/
with Report_of_Insurance_Plans as (
select d.diseaseName, ip.planName, count(c.claimID) as Count_of_Insurance_Claim, t.diseaseID
	from insuranceplan ip
    join claim c on c.uin = ip.uin
    join treatment t on t.claimID = c.claimID
    join disease d on d.diseaseID = t.diseaseID
group by d.diseaseName, ip.planName
order by d.diseaseName asc, Count_of_Insurance_Claim desc
)
select diseaseName, planName, 
max(Count_of_Insurance_Claim) as Maximum_Claimed_insurance, 
min(Count_of_Insurance_Claim) as Minimum_Claimed_insurance
from Report_of_Insurance_Plans
-- (select *
-- 		from Report_of_Insurance_Plans) mx 
--         
--         join (select *
-- 		from Report_of_Insurance_Plans) mn on mx.diseaseID = mn.diseaseID 
group by diseasename
order by Maximum_Claimed_insurance desc, Minimum_Claimed_insurance asc;

/* 4. The Healthcare department wants to know which disease is most likely to infect multiple people in the same household. 
For each disease find the number of households that has more than one patient with the same disease. 
*/

-- to check the how many person are residing at one addressID (Means count the personID having same adddressID)

select a.addressID, count(p.personID) as count_of_person
from address a
join person p on p.addressID = a.addressID
group by a.addressID
order by count_of_person desc;

-- --- actual Solution--- 

select distinct(d.diseaseName), count(a.addressID) as Count_of_Households
from address a 
join person p on p.addressID = a.addressID
join treatment t on t.patientID = p.personID
join disease d on d.diseaseID = t.diseaseID
group by d.diseaseName
having count(t.patientID) > 1;


/* 5. An Insurance company wants a state wise report of the treatments to 
claim ratio between 1st April 2021 and 31st March 2022 (days both included). Assist them to create such a report.
*/
select distinct(state) from address;

select a.state, (count(t.treatmentID) / count(t.claimID)) as Treatment_to_Claim_Ratio
from address a
join person p on p.addressID = a.addressID
join treatment t on t.patientID = p.personID
where t.date >= '2021-04-01'  and t.date <= '2022-03-31'
group by a.state;


