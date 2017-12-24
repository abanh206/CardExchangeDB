-- User Card Synthetic Transaction
-- Grabs sample date from dbo.CustomerBuild

Create Procedure uspInsertUserWrapper
	@Run int
AS
Begin
	IF EXISTS(SELECT Name FROM sys.objects WHERE Name = 'UniqueEmails')
    	BEGIN
    	DROP TABLE UniqueEmails
    	END

	Create Table #UniqueEmails (
			WorkingID int primary key identity(1,1) not null,
			CustomerFName varchar(75) not null,
			CustomerLName varchar(75) not null,
			Email varchar(200) not null,
			DateOfBirth date not null
		)

	--Use unique emails because that determines new users
    Insert Into #UniqueEmails 
        Select top 100000 t1.CustomerFName, t1.CustomerLName, t1.Email, t1.DateofBirth
        from CUSTOMER_BUILD.dbo.tblCustomer t1
        LEFT JOIN (Select top 100000 * from [USER]) t2 ON t1.Email = t2.Email
        Where t2.Email IS NULL
    
	Declare 
		@TID int, 
		@AID int,
		@CID int,
		@FirstName varchar(100),
		@LastName varchar(100),
		@Mail varchar(200),
		@DateOfBirth date,
		@Rand numeric(16,16),
		@TypeCount int = (Select Count(*) from [TYPE]),
		@AddressCount int = (Select Count(*) from [Address]),
		@UserCount int = (Select Count(*) from #UniqueEmails)

	While @Run > 0
		Begin
			Set @Rand = (Select Rand())
			Set @TID = (@Rand * @TypeCount + 1)
            Set @Rand = (Select Rand())
			Set @AID = (@Rand * @AddressCount + 1)
            Set @Rand = (Select Rand())
			Set @CID = (@Rand * @UserCount + 1)

			Set @FirstName = (Select CustomerFName from #UniqueEmails where WorkingID = @CID)
			Set @LastName = (Select CustomerLName from #UniqueEmails where WorkingID = @CID)
			Set @Mail = (Select Email from #UniqueEmails where WorkingID = @CID)
			Set @DateOfBirth = (Select DateOfBirth from #UniqueEmails where WorkingID = @CID)
	
			Exec uspInsertUser
				@UTID = @TID, @FName = @FirstName, @LName = @LastName, @Email = @Mail, @DOB = @DateOfBirth, @AddressID = @AID

			Set @Run = @Run - 1
		End
End
GO
