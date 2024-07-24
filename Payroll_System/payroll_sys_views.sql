-- Views

-- CREATING VIEWS
USE payroll_sys;

-- Dept is created to store department details
CREATE VIEW [Dept] AS
(
	SELECT em.[Empid], ed.[First_Name] + ' ' + ed.[Last_Name] AS [Name], d.[department_name] AS [Department], l.[name] AS [Designation], ed.[Basic_pay]
	FROM [Emp_master] em
	JOIN [Department] d ON d.[department_id] = em.[Departmentid]
	JOIN [Lead] l ON l.[id] = em.[Lead_id]
	JOIN [Employee_details] ed ON ed.[Empid] = em.[Empid]
)

-- Allow is created to store allowance that are mapped to each employee
CREATE VIEW [allow] AS
(
	SELECT ed.[Empid], ed.[First_Name] + ' ' + ed.[Last_Name] AS [Name], string_agg(a.[name], ', ') AS [Allowance], SUM(a.[Amount]) AS [Net_Allowance]
	FROM [Employee_details] ed
	JOIN [Emp_allowance] ea ON ea.[Empid] = ed.[Empid]
	JOIN [Allowance] a ON a.[id] = ea.[Allowance_id]
	GROUP BY ed.[Empid], ed.[First_Name], ed.[Last_Name]
)

-- Deduce is created to store deductions that are mapped to each employee
CREATE VIEW [deduce] AS
(
	SELECT ed.[Empid], e.[First_Name] + ' ' + e.[Last_Name] AS [Name], string_agg(d.[name], ', ') AS [Deduction], SUM(d.[Amount]) AS [Net_deduction]
	FROM [Employee_details] e
	JOIN [emp_deductions] ed ON ed.[Empid] = e.[Empid]
	JOIN [Deductions] d ON d.[id] = ed.[Deduction_id]
	GROUP BY ed.[Empid], e.[First_Name], e.[Last_Name]
)

-- full info is to provide complete details of an employee including allowance, deduction and user details
CREATE VIEW [full_info] AS
(
	SELECT ed.[Empid], ed.[First_Name], ed.[Last_Name], ed.[Gender], ed.[DOB], ed.[Marital_Status], ed.[Nationality], ed.[City], ed.[Postal_Code], ed.[Contact_no], ed.[Email], ed.[Prev_exp], ed.[Hire_date], ed.[PAN_no], ed.[Basic_Pay], d.[department_name], l.[name] AS [designation] 
	FROM [Emp_master] em
	JOIN [Employee_details] ed ON ed.[Empid] = em.[Empid]
	JOIN [Department] d ON d.[department_id] = em.[Departmentid]
	JOIN [lead] l ON l.[id] = em.[Lead_id]
)

CREATE VIEW [attendance_with_permission] AS 
(
SELECT [id],
LEFT(DATENAME(month, CAST([check_in] AS DATE)), 3) + RIGHT(DATENAME(year, CAST([check_in] AS DATE)), 2)  AS [Monthyr],
CASE	WHEN SUM(CASE	WHEN DATEDIFF(second, CAST([check_in] AS time), CAST([check_out] AS time)) < 28800 THEN 1 ELSE 0 END) <= 2 THEN 0
		ELSE SUM(CASE	WHEN DATEDIFF(second, CAST([check_in] AS time), CAST([check_out] AS time)) < 28800 THEN 1 ELSE 0 END) - 2 
END AS [absent]
FROM [attendance]
GROUP BY [id], LEFT(DATENAME(month, CAST([check_in] AS DATE)), 3) + RIGHT(DATENAME(year, CAST([check_in] AS DATE)), 2)

)

CREATE VIEW [leave_without_permission] AS
(
SELECT [id],
LEFT(DATENAME(month, CAST([date] AS DATE)), 3) + RIGHT(DATENAME(year, CAST([date] AS DATE)), 2)  AS [Monthyr],
COUNT([date]) AS [absent]
FROM [leave]
GROUP BY [id], LEFT(DATENAME(month, CAST([date] AS DATE)), 3) + RIGHT(DATENAME(year, CAST([date] AS DATE)), 2)

)

CREATE VIEW [att_leave] AS
(
SELECT awp.[id], awp.[Monthyr], awp.[absent] +
CASE	WHEN NOT EXISTS(SELECT 1 FROM [leave_without_permission] lp WHERE lp.[id]=awp.[id]) THEN 0
		WHEN (SELECT TOP 1 [absent] FROM [leave_without_permission] lp WHERE lp.[id]=awp.[id] AND lp.[Monthyr] LIKE awp.[Monthyr]) IS NULL THEN 0
		WHEN (SELECT TOP 1 [absent] FROM [leave_without_permission] lp WHERE lp.[id]=awp.[id] AND lp.[Monthyr] LIKE awp.[Monthyr]) <= 1 THEN 0
		ELSE (SELECT TOP 1 [absent] FROM [leave_without_permission] lp WHERE lp.[id]=awp.[id] AND lp.[Monthyr] LIKE awp.[Monthyr]) - 1
END AS [leave]
FROM [attendance_with_permission] awp
)






