USE payroll_sys;

-- Employee-details table
IF NOT EXISTS (
    select * from sysobjects where name='Employee_details' and xtype='U'
) CREATE TABLE [Employee_details] (
    [Empid] INT,
    [First_Name] VARCHAR(30),
    [Last_Name] VARCHAR(30),
    [Gender] VARCHAR(6),
    [DOB] DATE,
    [Marital_Status] VARCHAR(9),
    [Nationality] VARCHAR(30),
    [City] VARCHAR(30),
    [Postal_Code] VARCHAR(8),
    [Contact_no] VARCHAR(12),
    [Email] VARCHAR(40),
    [Prev_exp] INT,
    [Hire_date] DATE,
    [PAN_no] VARCHAR(10),
    [Basic_Pay] DECIMAL(8, 2),
	CONSTRAINT [PK_empid] PRIMARY KEY([Empid]),
	CONSTRAINT [ck_phno] CHECK(LEN([Contact_no])=12),
	CONSTRAINT [U_panno] UNIQUE([PAN_no])
);


-- department table
IF NOT EXISTS (
    select * from sysobjects where name='department' and xtype='U'
) CREATE TABLE [department] (
    [department_id] INT,
    [department_name] VARCHAR(14),
	CONSTRAINT [PK_did] PRIMARY KEY([department_id])
);


-- Lead Table
IF NOT EXISTS (
    select * from sysobjects where name='lead' and xtype='U'
) CREATE TABLE [lead] (
    [id] INT,
    [name] VARCHAR(17),
	CONSTRAINT [PK_lid] PRIMARY KEY([id])
);


-- Emp_master table
IF NOT EXISTS (
    select * from sysobjects where name='Emp_master' and xtype='U'
) CREATE TABLE [Emp_master] (
    [Empid] INT,
    [Departmentid] INT,
    [Lead_id] INT,
	CONSTRAINT [PK_master_id] PRIMARY KEY([Empid]),
	CONSTRAINT [FK_dept_id] FOREIGN KEY([Departmentid]) REFERENCES Department([department_id]),
	CONSTRAINT [FK_id] FOREIGN KEY([Lead_id]) REFERENCES Lead([id])
);


-- Attendance table
IF NOT EXISTS (
    select * from sysobjects where name='attendance' and xtype='U'
)
create table attendance (
	[id] INT,
	[check_in] DATETIME,
	[check_out] DATETIME,
	CONSTRAINT [FK_att_empid] FOREIGN KEY([id]) REFERENCES Emp_master([Empid])
);


-- leave table
IF NOT EXISTS (
    select * from sysobjects where name='leave' and xtype='U'
)
create table leave (
	[id] INT,
	[date] DATE,
	CONSTRAINT [FK_leave_empid] FOREIGN KEY([id]) REFERENCES Emp_master([Empid])
);

-- Allowance Table
IF NOT EXISTS (
    select * from sysobjects where name='allowance' and xtype='U'
) CREATE TABLE [allowance] (
    [id] INT,
    [Name] VARCHAR(30),
    [Description] VARCHAR(200),
    [Amount] DECIMAL(8,2),
	CONSTRAINT [PK_id] PRIMARY KEY([id])
);



-- Deduction Table
IF NOT EXISTS (
    select * from sysobjects where name='deductions' and xtype='U'
) CREATE TABLE [deductions] (
    [id] INT,
    [Name] VARCHAR(24),
    [Description] VARCHAR(135),
    [Amount] DECIMAL(8, 2),
	CONSTRAINT [PK_deduction_id] PRIMARY KEY([id])
);


-- Employee_allowance Table
IF NOT EXISTS (
    select * from sysobjects where name='emp_allowance' and xtype='U'
) CREATE TABLE [emp_allowance] (
    [Empid] INT,
    [Allowance_id] INT,
	CONSTRAINT [FK_ea_empid] FOREIGN KEY([Empid]) REFERENCES Emp_master([Empid]),
	CONSTRAINT [FK_ea_aid] FOREIGN KEY([Allowance_id]) REFERENCES Allowance([id])
);


-- Employee_deduction Table
IF NOT EXISTS (
    select * from sysobjects where name='emp_deductions' and xtype='U'
) CREATE TABLE [emp_deductions] (
    [Empid] INT,
    [Deduction_id] INT,
	CONSTRAINT [FK_ed_empid] FOREIGN KEY([Empid]) REFERENCES Emp_master([Empid]),
	CONSTRAINT [FK_ed_did] FOREIGN KEY([Deduction_id]) REFERENCES Deductions([id])
);


