use healthcare;

/* 1.Some complaints have been lodged by patients that they have been prescribed hospital-exclusive 
medicine that they can’t find elsewhere and facing problems due to that. Joshua, from the pharmacy management, 
wants to get a report of which pharmacies have prescribed hospital-exclusive medicines the most in the years 2021 and 2022. 
Assist Joshua to generate the report so that the pharmacies who prescribe hospital-exclusive medicine more often are 
advised to avoid such practice if possible.    
*/
-- IN hospital exclusive S represent yes and N represent no means  

select distinct(hospitalExclusive) from medicine;


select p.pharmacyName, count(m.medicineID) as count_of_hospital_exclusive_Med
from contain c
	join prescription pre on pre.prescriptionID = c.prescriptionID 
    join pharmacy p on p.pharmacyID = pre.pharmacyID
	join treatment t on t.treatmentID = pre.treatmentID
	join medicine m on m.medicineID = c.medicineID
where (year(t.date) between 2021 and 2022) and m.hospitalExclusive = "S"
group by p.pharmacyName
order by count_of_hospital_exclusive_Med desc;

/* 2. Insurance companies want to assess the performance of their insurance plans. 
Generate a report that shows each insurance plan, the company that issues the plan, and the number of 
treatments the plan was claimed for.
*/

select count(claimID) from treatment;
select planname from insurancePlan;
select distinct(companyname) from insuranceCompany;

select ic.companyName, ip.planName , count(t.treatmentID) as No_of_Treament_Plan_Claimed
from insuranceCompany ic
join insurancePlan ip on ip.companyID = ic.companyID
join claim c on c.uin = ip.uin
join treatment t on t.claimID = c.claimID
group by ic.CompanyName;

/* 3. Insurance companies want to assess the performance of their insurance plans. 
Generate a report that shows each insurance company's name with their most and least claimed insurance plans.
*/

create view company_plan_claimed as 
select ic.companyName, ip.planName , count(c.claimID) as No_of_Plan_Claimed
from insuranceCompany ic
join insurancePlan ip on ip.companyID = ic.companyID
join claim c on c.uin = ip.uin
join treatment t on t.claimID = c.claimID
group by ic.companyName,ip.planName
order by ic.companyName;

 

select companyName,planName, max(No_of_Plan_Claimed) as Most_Claimed
from company_plan_claimed
group by companyName;


Select t.companyName, t.planName, t.No_of_Plan_Claimed as Least_Claimed
from (
	select *,
    min(No_of_Plan_Claimed) over(partition by companyName ORDER BY No_of_plan_claimed) as Least_Claimed
	from company_plan_claimed) t
WHERE t.No_of_Plan_Claimed = Least_Claimed;

/* 4. The healthcare department wants a state-wise health report to assess which state requires more 
attention in the healthcare sector. Generate a report for them that shows the state name, 
number of registered people in the state, number of registered patients in the state, and the people-to-patient ratio. 
sort the data by people-to-patient ratio.  
*/


select a.state, count(p.personID) as No_of_Registered_Person, count(pt.patientID) as No_of_Registered_Patients,
round((count(p.personID)/count(pt.patientID)),2) as People_to_Patient_Ratio
from address a 
join person p on p.addressID = a.addressID
left join patient pt on pt.patientID = p.personID
group by a.state;


/* 5. Jhonny, from the finance department of Arizona(AZ), has requested a report that lists the total quantity of medicine each 
pharmacy in his state has prescribed that falls under Tax criteria I for treatments that took place in 2021. 
Assist Jhonny in generating the report.
*/
select distinct(taxCriteria) from medicine;

select p.pharmacyName, count(c.medicineID) as Quantity_of_Medicine
from pharmacy p 
join address a on a.addressID = p.addressID
join prescription pre on pre.pharmacyID = p.pharmacyID
join contain c on c.prescriptionID = pre.prescriptionID
join treatment t on t.treatmentID = pre.treatmentID
join medicine m on m.medicineID = c.medicineID
where a.state = "AZ" and year(t.date) = 2021 and m.taxCriteria = "I"
group by p.pharmacyName; 

