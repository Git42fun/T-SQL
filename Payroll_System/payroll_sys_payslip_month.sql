USE payroll_sys;

CREATE PROCEDURE [pr_payroll_sys](@empname VARCHAR(60), @Month_yr VARCHAR(10)) AS
BEGIN

	BEGIN TRY

		IF NOT EXISTS (SELECT 1 FROM [Employee_details] WHERE [First_Name] + ' ' + [Last_Name] LIKE @empname OR @empname IS NULL) 	
			RAISERROR('Please check empName!!', 16, 1)


		-- Summation of attendance and leave
		CREATE TABLE #at_leav
		(
		[id] INT,
		[days_absent] INT
		)


		DECLARE @s DATE
		DECLARE @days_incl INT
		DECLARE @lop_days_absent DECIMAL(8, 2)


		-- To catch invalid monthyear input
		BEGIN TRY
			SET @s = CAST('01-' + LEFT(@Month_yr, 3) + '-' + RIGHT(@Month_yr, 2) AS DATE)
		END TRY

		BEGIN CATCH
			RAISERROR('Error while casting date. Invalid date passed as a parameter. Try passing date as "MON-YY" without underscore!!!', 11, 1)
		END CATCH


		IF DATEPART(MONTH, @s) > 3 AND DATEPART(year, @s) NOT LIKE 2024
			RAISERROR('Cannot find data for specified month and year!!!', 11, 1)		
		ELSE IF DATEPART(MONTH, @s) > 3
			RAISERROR('Cannot find data for the specified month!!!', 11, 1)
		ELSE IF DATEPART(year, @s) NOT LIKE 2024
			RAISERROR('Cannot find data for specified year!!!', 11, 1)

		SET @days_incl = DAY(EOMONTH(@s))


		-- attendance + Leave
		BEGIN TRY
			BEGIN TRAN
				INSERT INTO #at_leav
				SELECT [id], [leave] AS [days_absent]
				FROM [att_leave]
				WHERE [Monthyr] LIKE @Month_yr
				ORDER BY [id] 
			COMMIT
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			RAISERROR('Insertion #att_leav failed...Rolling back Transaction', 11, 1)
		END CATCH



		IF @empname IS NOT NULL
		BEGIN
			SELECT ed.[empid],  ed.[First_Name] + ' ' + ed.[Last_Name] AS [Name], @s AS [Date_From], EOMONTH(@s) AS [Date_to], GETUTCDATE() AS [Date_created], #at_leav.[days_absent] AS [days_absent],
				ed.[Basic_Pay] AS [Basic_pay], CAST((ed.[Basic_pay]/@days_incl) * #at_leav.[days_absent] AS DECIMAL(8, 2)) AS [Loss_of_Pay], a.[Allowance],
				a.[Net_Allowance], ed.[Basic_pay] + a.[Net_Allowance] AS [Gross_salary], d.[deduction], d.[Net_deduction],
				(ed.[Basic_Pay]+a.[Net_Allowance]-d.[Net_deduction]) - CAST((ed.[Basic_pay]/@days_incl) * #at_leav.[days_absent] AS DECIMAL(8, 2)) AS [Net_Salary]
			FROM [Employee_details] ed 
			JOIN #at_leav ON #at_leav.[id] = ed.[Empid]
			JOIN [allow] a ON a.[Empid] = ed.[Empid]
			JOIN [deduce] d ON d.[Empid] = ed.[Empid]
			WHERE ed.[First_Name] + ' ' + ed.[Last_Name] LIKE @empname
		END
		ELSE
		BEGIN
			SELECT ed.[empid],  ed.[First_Name] + ' ' + ed.[Last_Name] AS [Name], @s AS [Date_From], EOMONTH(@s) AS [Date_to], GETUTCDATE() AS [Date_created], #at_leav.[days_absent] AS [days_absent],
				ed.[Basic_Pay] AS [Basic_pay], CAST((ed.[Basic_pay]/@days_incl) * #at_leav.[days_absent] AS DECIMAL(8, 2)) AS [Loss_of_Pay], a.[Allowance],
				a.[Net_Allowance], ed.[Basic_pay] + a.[Net_Allowance] AS [Gross_salary], d.[deduction], d.[Net_deduction],
				(ed.[Basic_Pay]+a.[Net_Allowance]-d.[Net_deduction]) - CAST((ed.[Basic_pay]/@days_incl) * #at_leav.[days_absent] AS DECIMAL(8, 2)) AS [Net_Salary]
			FROM [Employee_details] ed 
			JOIN #at_leav ON #at_leav.[id] = ed.[Empid]
			JOIN [allow] a ON a.[Empid] = ed.[Empid]
			JOIN [deduce] d ON d.[Empid] = ed.[Empid]
			
		END	

	END TRY


	BEGIN CATCH

		SELECT  ERROR_NUMBER() AS [ErrorNumber], ERROR_SEVERITY() AS [ErrorSeverity], ERROR_STATE() AS [ErrorState], ERROR_PROCEDURE() AS [ErrorProcedure], ERROR_LINE() AS [ErrorLine],
		ERROR_MESSAGE() AS [ErrorMessage];  

	END CATCH



END


EXEC pr_payroll_sys 'Witty Aspall', 'JAN24';


