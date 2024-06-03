SELECT npi,
	SUM(total_claim_count) AS total_claims
FROM prescriber
	LEFT JOIN prescription USING (npi)
WHERE total_claim_count IS NOT NULL
GROUP BY npi
ORDER BY total_claims DESC;
--1(a) npi: 1881634483, total claims: 99,707

SELECT nppes_provider_first_name,
	nppes_provider_last_org_name,
	specialty_description,
	SUM(total_claim_count) AS total_claims
FROM prescriber
	LEFT JOIN prescription USING (npi)
WHERE total_claim_count IS NOT NULL
GROUP BY nppes_provider_first_name,
	nppes_provider_last_org_name,
	specialty_description
ORDER BY total_claims DESC;
--1(b) bruce pendley, family practice: 99,707

SELECT specialty_description,
	SUM(total_claim_count) AS total_claims
FROM prescriber
	LEFT JOIN prescription USING (npi)
WHERE total_claim_count IS NOT NULL
GROUP BY specialty_description
ORDER BY total_claims DESC;
--2(a) family practice: 9,752,357

SELECT specialty_description, 
	SUM(total_claim_count) AS total_claims
FROM prescriber
	LEFT JOIN prescription USING (npi)
	LEFT JOIN drug USING (drug_name) 
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_claims DESC;
--2(b) nurse practitioner: 900,845

SELECT specialty_description, COUNT (total_claim_count)AS claim_count
FROM prescriber LEFT JOIN prescription USING(npi)
GROUP BY specialty_description
HAVING COUNT(total_claim_count)='0';
--2(c) 15 specialties 

SELECT generic_name, SUM(total_drug_cost) AS total_drug_cost
FROM prescription
	LEFT JOIN drug USING (drug_name)
GROUP BY generic_name 
ORDER BY total_drug_cost DESC;
--3(a) INSULIN GLARGINE,HUM.REC.ANLOG

SELECT generic_name,(total_drug_cost/total_day_supply) AS cost_per_day
FROM prescription
	LEFT JOIN drug USING (drug_name)
ORDER BY cost_per_day DESC;
--3(b) IMMUN GLOB G(IGG)/GLY/IGA OV50

SELECT DISTINCT drug_name,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag ='Y' THEN 'antibiotic'
		ELSE 'neither' END AS drug_type
FROM drug;
--4(a)

WITH drug_type_cost AS (SELECT drug_name,
						CASE
							WHEN opioid_drug_flag = 'Y' THEN 'opioid'
							WHEN antibiotic_drug_flag ='Y' THEN 'antibiotic'
							ELSE 'neither' END AS drug_type
						FROM drug)
SELECT drug_type, SUM(total_drug_cost) AS total_cost
FROM drug_type_cost
	LEFT JOIN prescription USING (drug_name)
WHERE drug_type = 'opioid' OR drug_type = 'antibiotic'
GROUP BY drug_type;
--4(b) opioids, $105,080,626.37

SELECT COUNT(DISTINCT cbsa) AS tn_cbsa
FROM cbsa
WHERE cbsaname LIKE '%TN%';
--5(a) 10

SELECT cbsaname, SUM(population) AS total_pop
FROM cbsa
	LEFT JOIN population USING (fipscounty)
WHERE population IS NOT NULL
GROUP BY cbsaname
ORDER BY total_pop DESC;
--5(b) largest: Nashville-Davidson--Murfreesboro--Franklin, TN 1,830,410
-------smallest: Morristown, TN 116,352

SELECT county, population
FROM cbsa
	FULL JOIN population USING (fipscounty)
	LEFT JOIN fips_county USING (fipscounty)
WHERE cbsa IS NULL
ORDER BY population DESC;
--5(c) sevier county 95,523

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;
--6(a)

SELECT drug_name, total_claim_count,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'yes'
		ELSE 'no' END AS opioid
FROM prescription
	LEFT JOIN drug USING (drug_name)
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;
--6(b)

SELECT drug_name, 
	total_claim_count, 
	nppes_provider_first_name,
	nppes_provider_last_org_name,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'yes'
		ELSE 'no' END AS opioid
FROM prescription
	LEFT JOIN drug USING (drug_name)
	LEFT JOIN prescriber ON prescription.npi=prescriber.npi
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;
--6(c)

SELECT npi, drug_name
FROM prescriber
	CROSS JOIN drug
WHERE nppes_provider_city = 'NASHVILLE'
	AND specialty_description = 'Pain Management'
	AND opioid_drug_flag = 'Y';
--7(a)

WITH tn_pm_list AS (
					SELECT npi, drug_name
					FROM prescriber CROSS JOIN drug
					WHERE specialty_description = 'Pain Management'
						AND nppes_provider_city = 'NASHVILLE'
						AND opioid_drug_flag = 'Y')
SELECT npi, drug_name, COALESCE(total_claim_count,0) AS total_claims
FROM tn_pm_list 
	LEFT JOIN prescription USING(npi, drug_name)
ORDER BY total_claims DESC;
--7(b)