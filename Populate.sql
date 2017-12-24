-- Populate USER_TYPE
INSERT INTO USER_TYPE (UserTypeName)
    VALUES ('Admin'), ('Premium'), ('Normal')
GO

-- Populate States from CUSTOMER_BUILD
INSERT INTO [STATE](StateName)
    SELECT DISTINCT(StateName) FROM CUSTOMER_BUILD.dbo.tblCITY_STATE_ZIP
GO

-- Populate Condition
INSERT INTO CONDITION (CardConditionName, CardConditionDesc)
    Values ('Near Mint', 'Minimal to no wear from shuffling, play or handling')
    , ('Lightly Played', 'Minor border or corner wear or even just slight scuffs or scratches')
    , ('Moderately Played', 'Border wear, corner wear, scratching or scuffing, creases or whitening, minor dirt buildup')
    , ('Heavily Played', 'Major creasing, major whitening, major border wear'), ('Damaged', 'Extreme border wear, extreme corner wear, heavy scratching or scuffing, folds, creases or tears')

-- Populate City
CREATE PROCEDURE uspPopulateCity
AS
BEGIN
    IF EXISTS(SELECT Name FROM sys.objects WHERE Name = 'WORKING')
    BEGIN
        DROP TABLE WORKING
    END

    CREATE TABLE WORKING (
        PK int PRIMARY KEY IDENTITY(1,1) not null,
        StateName varchar(75) not null,
        CityName varchar(75) not null
    )

    INSERT INTO WORKING
        SELECT DISTINCT StateName, CityName
        FROM CUSTOMER_BUILD.dbo.tblCITY_STATE_ZIP
    
    CREATE NONCLUSTERED INDEX working_idx
    ON WORKING (PK)

    DECLARE @_ID int
    DECLARE @_CityName varchar(75)
    DECLARE @_StateName varchar(75)
    DECLARE @_StateID int

    DECLARE @RUN int
    SET @RUN = (SELECT COUNT(*) FROM WORKING)
    WHILE(@RUN > 0)
   	    BEGIN
            SET @_ID = (SELECT MIN(PK) FROM WORKING)
            SET @_CityName = (SELECT CityName FROM WORKING WHERE PK = @_ID)
            SET @_StateName = (SELECT StateName FROM WORKING WHERE PK = @_ID)

            EXEC uspGetStateID
                @StateName = @_StateName,
                @StateID = @_StateID OUTPUT

            BEGIN TRAN T1
                INSERT INTO CITY(CityName, StateID)
                VALUES (@_CityName, @_StateID)
            IF @@ERROR <> 0
                ROLLBACK TRAN T1
            ELSE
                COMMIT TRAN T1

            DELETE FROM WORKING WHERE PK = @_ID
            SET @RUN = @RUN - 1
   	    END
END
GO

-- Populate Rarity
INSERT INTO RARITY(RarityName) 
    SELECT DISTINCT(Rarity) FROM RAW_YUGIOHCARD_PK

-- Populate Type
INSERT INTO TYPE(TypeName) 
    SELECT DISTINCT(TYPE) FROM RAW_YUGIOHCARD_PK

-- Populate SubType
INSERT INTO SUBTYPE(SubTypeName) 
    SELECT DISTINCT(SubType) FROM RAW_YUGIOHCARD_PK

-- Populate Attribute
INSERT INTO Attribute(AttributeName) 
    SELECT DISTINCT(Attribute) FROM RAW_YUGIOHCARD_PK WHERE Attribute is Not null

--Populate Address
CREATE PROCEDURE uspPopulateAddress
AS
BEGIN
    IF EXISTS(SELECT Name FROM sys.objects WHERE Name = 'WORKING')
   	    BEGIN
   	    DROP TABLE WORKING
   	    END

    CREATE TABLE Working(
   	 PK int primary key identity(1,1) not null,
   	 CustomerState varchar(75) not null,
   	 CustomerCity varchar(75) not null,
   	 CustomerAddress varchar(75) not null,
   	 CustomerZip varchar(75) not null,
   	 AreaCode varchar(75) not null
    )

    INSERT INTO WORKING
    SELECT DISTINCT TOP 10000 CustomerState, CustomerCity, CustomerAddress, CustomerZip, AreaCode
    FROM CUSTOMER_BUILD.dbo.tblCustomer

    CREATE NONCLUSTERED INDEX working_idx
    ON WORKING (PK)

    DECLARE @_ID int
    DECLARE @_StateName varchar(75)
    DECLARE @_StateID int
    DECLARE @_CityName varchar(75)
    DECLARE @_CityID int
    DECLARE @_StreetAddress varchar(255)
    DECLARE @_PostCode char(3)

    DECLARE @RUN int
    SET @RUN = (SELECT COUNT(*) FROM WORKING)
    WHILE(@RUN > 0)
   	 BEGIN
   		 SET @_ID = (SELECT MIN(PK) FROM WORKING)
   		 SET @_CityName = (SELECT CustomerCity FROM WORKING WHERE PK = @_ID)
   		 SET @_StreetAddress = (SELECT CustomerAddress FROM WORKING WHERE PK = @_ID)
   		 SET @_PostCode = (SELECT AreaCode FROM WORKING WHERE PK = @_ID)
   		 SET @_StateName = (SELECT CustomerState FROM WORKING WHERE PK = @_ID)

   		 EXEC uspGetCityID
   			 @CityName = @_CityName,
   			 @CityStateName = @_StateName,
   			 @CityID = @_CityID OUTPUT

   		 IF @_CityID IS NULL
   			 BEGIN
   				 DELETE FROM WORKING WHERE PK = @_ID
   				 SET @RUN = @RUN - 1
   				 CONTINUE
   			 END

   		 BEGIN TRAN T1
   			 INSERT INTO [ADDRESS](StreetAddress, PostCode, CityID)
   			 VALUES (@_StreetAddress, @_PostCode, @_CityID)

   		 IF @@ERROR <> 0
   			 ROLLBACK TRAN T1
   		 ELSE
   			 COMMIT TRAN T1

   		 DELETE FROM WORKING WHERE PK = @_ID
   		 SET @RUN = @RUN - 1

   	 END
END
GO

--Populate Users
Create PROCEDURE uspPopulateUsers
AS
BEGIN
	IF EXISTS(SELECT Name FROM sys.objects WHERE Name = 'WORKING')
    BEGIN
    	DROP TABLE WORKING
    END

	SELECT TOP 2500 * INTO WORKING FROM CUSTOMER_BUILD.dbo.tblCustomer

	DECLARE @_ID int
	DECLARE @_StateName varchar(75)
	DECLARE @_CityName varchar(75)
	DECLARE @_StreetAddress varchar(255)
	DECLARE @_PostCode char(3)
	DECLARE @_FirstName varchar(75)
	DECLARE @_LastName varchar(75)
	DECLARE @_Email varchar(255)
	DECLARE @_DOB datetime
    DECLARE @_RAND numeric(16,16)
    DECLARE @_UserTypeCount int = (SELECT COUNT(*) FROM USER_TYPE)
    DECLARE @_UserTypeID INT

	DECLARE @RUN int
	SET @RUN = (SELECT COUNT(*) FROM WORKING)
	WHILE(@RUN > 0)
    	BEGIN
        	DECLARE @_AddressID int
            SET @_RAND = (SELECT RAND())
        	SET @_ID = (SELECT MIN(CustomerID) FROM WORKING)
        	SET @_StateName = (SELECT CustomerState FROM WORKING WHERE CustomerID = @_ID)
        	SET @_CityName = (SELECT CustomerCity FROM WORKING WHERE CustomerID = @_ID)
        	SET @_StreetAddress = (SELECT CustomerAddress FROM WORKING WHERE CustomerID = @_ID)
        	SET @_PostCode = (SELECT AreaCode FROM WORKING WHERE CustomerID = @_ID)
        	SET @_FirstName = (SELECT CustomerFname FROM WORKING WHERE CustomerID = @_ID)
        	SET @_LastName = (SELECT CustomerLname FROM WORKING WHERE CustomerID = @_ID)
        	SET @_Email = (SELECT Email FROM WORKING WHERE CustomerID = @_ID)
   		    SET @_UserTypeID = (@_RAND * @_UserTypeCount + 1)
        	SET @_DOB = (Select DateOfBirth FROM WORKING WHERE CustomerID = @_ID)

        	EXEC uspGetAddressID
            	@_StreetAddress
   			 , @_PostCode
   			 , @_CityName
            	, @_StateName
            	, @_AddressID OUTPUT

   		    -- go to next row if address not found
        	IF @_AddressID IS NULL
            	BEGIN
                	DELETE FROM WORKING WHERE CustomerID = @_ID
                	SET @RUN = @RUN - 1
                	CONTINUE
            	END

       	 
        	BEGIN TRAN T1
            	INSERT INTO [USER](UserTypeId, FirstName, LastName, Email, DOB, AddressID)
            	VALUES
            	(
                 	@_UserTypeID, @_FirstName , @_LastName , @_Email , @_DOB , @_AddressID
            	)
        	IF @@ERROR <> 0
            	ROLLBACK TRAN T1
        	ELSE
            	COMMIT TRAN T1
        	DELETE FROM WORKING WHERE CustomerID = @_ID
        	SET @RUN = @RUN - 1s
    	END
END
GO

-- Populate Event
Create Procedure uspEventTRX
    @BuyerEmail varchar(225),
    @SellerEmail varchar(225),
    @CardNum varchar(75),
    @CardCondition varchar(75),
    @EventType varchar(75),
    @Date datetime,
    @Price Decimal(17,2)
As 
Begin
	Declare @BuyerID int,
        @SellerID int,
        @UserCardID int,
        @EventTypeID int,
	    @CardID int, 
        @Condition int

	Exec uspGetUserCardID
        @Email = @SellerEmail,
        @CardNum = @CardNum,
        @Condition = @CardCondition,
        @UserCardID = @UserCardID Output
	
	Exec uspGetUserID
        @UserEmail = @BuyerEmail,
        @UserID = @BuyerID Output

	Exec uspGetEventTypeID
        @EventTypeName = @EventType,
        @EventTypeID = @EventTypeID Output

	Exec uspGetCardID
        @CardNum = @CardNum,
        @CardID = @CardID Output

	Exec uspGetConditionID
        @CardConditionName = @CardCondition,
        @CardConditionID = @Condition Output

	If @BuyerID Is Null Or @UserCardID Is Null

	Begin
		Print 'Buyer, Seller or Card not found';
		Throw 50001, 'Null ID', 1
	End

	If @Date is Null Or @Price is Null Or @EventTypeID Is Null
	Begin
		Print 'Fields are Null';
		Throw 50001, 'Null Parameters', 1
	End

	Begin Tran
		Insert Into [Event] (UserCardID, EventTypeID, [Date], Price)
		    Values (@UserCardID, @EventTypeID, @Date, @Price)

		Update USER_CARD
			Set EndDate = @Date
			Where UserCardID = @UserCardID

		Insert Into [USER_CARD] (UserID, CardID, CardConditionID, BeginDate, EndDate)
		    Values(@BuyerID, @CardID, @Condition, @Date, Null)
		
		Insert Into [Event] (UserCardID, EventTypeID, [Date], Price)
		    Values ((Select SCOPE_IDENTITY()), 1, @Date, @Price)

		If @@Error <> 0
			Rollback Tran
		ELse
			Commit Tran
End
GO

-- Populate Card
Create PROCEDURE uspPopulateCard
As
IF Exists(Select Name From sys.objects Where Name = 'working')
	Begin
    	Drop Table working
	End

Select * Into working From Raw_YugiohCard_PK

DECLARE @_WorkingID INT
DECLARE @_TypeName varchar(75)
DECLARE @_TypeID INT
DECLARE @_CardName VARCHAR(75)
DECLARE @_CardNum VARCHAR(75)
DECLARE @_CardText VARCHAR(75)
DECLARE @_RarityName varchar(75)
DECLARE @_RarityID INT
DECLARE @_AttributeName varchar(75)
DECLARE @_AttributeID INT
DECLARE @_SubTypeName varchar(75)
DECLARE @_SubTypeID INT
DECLARE @_Level INT
DECLARE @_ATK INT
DECLARE @_DEF INT
Declare @Run int = (SELECT COUNT(*) FROM WORKING)

While (@Run > 0)
Begin
	Set @_WorkingID = (Select min(CardID) From Working)
	Set @_CardName = (Select CardName From Working Where CardID = @_WorkingID)
	Set @_CardNum = (Select CardNum From Working Where CardID = @_WorkingID)
	Set @_CardText = (Select CardText From Working Where CardID = @_WorkingID)
    SET @_RarityName = (SELECT Rarity FROM WORKING WHERE CardID = @_WorkingID)
    SET @_AttributeName = (SELECT Attribute FROM WORKING WHERE CardID = @_WorkingID)
    SET @_SubTypeName = (SELECT SubType FROM WORKING WHERE CardID = @_WorkingID)
    SET @_TypeName = (SELECT Type FROM WORKING WHERE CardID = @_WorkingID)
    SET @_Level = (SELECT Level FROM WORKING WHERE CardID = @_WorkingID)
    SET @_ATK = (SELECT ATK FROM WORKING WHERE CardID = @_WorkingID)
    SET @_DEF = (SELECT DEF FROM WORKING WHERE CardID = @_WorkingID)

    EXEC uspGetRarityID
        @_RarityName, @_RarityID OUTPUT

    IF @_RarityID is NULL
        THROW 50001, 'Rarity not found', 1

    -- both attribute and subtype can be null so we dont need to error check
    EXEC uspGetAttributeID
        @_AttributeName, @_AttributeID OUTPUT

    EXEC uspGetSubTypeID
        @_SubTypeName, @_SubTypeID OUTPUT

    EXEC uspGetTypeID
        @_TypeName, @_TypeID OUTPUT

    IF @_TypeID is NULL
        THROW 50001, 'Type not found', 1

	Begin TRAN T1
        Insert into CARD (CardName, CardNum, CardText, Level, ATK, DEF, TypeID, RarityID, AttributeID, SubTypeID)
            Values(@_CardName, @_CardNum, @_CardText, @_Level, @_ATK, @_DeF, @_TypeID, @_RarityID, @_AttributeID, @_SubTypeID)
	IF @@ERROR <> 0
    	Rollback TRAN T1
	Else
    	Commit TRAN T1

	Delete From working Where CardID = @_WorkingID
	Set @Run = @Run -1
End
GO

-- Populate User Card
Create PROCEDURE uspPopulateUserCard
    @Email varchar(75),
    @Condition varchar(75),
    @BeginDate datetime,
    @EndDate datetime,
    @CardNum varchar(75)
AS
DECLARE @UserID int
DECLARE @CardID int
DECLARE @ConditionID int

BEGIN
    EXEC uspGetUserID
        @Email, @UserID OUTPUT

    IF @UserID IS NULL
        THROW 50001, 'User Not Found', 1

    EXEC uspGetCardID
        @CardNum, @CardID OUTPUT

    IF @CardID IS NULL
        THROW 50001, 'Card Not Found', 1

    EXEC uspGetConditionID
        @Condition, @ConditionID OUTPUT

    IF @ConditionID IS NULL
        THROW 50001, 'Condition Not Found', 1

    BEGIN TRAN T1
        INSERT INTO USER_CARD (UserID, CardID, CardConditionID, BeginDate, EndDate)
        VALUES(@UserID, @CardID, @ConditionID, @BeginDate, @EndDate)
    IF @@ERROR <> 0
        ROLLBACK TRAN T1
    ELSE
        COMMIT TRAN T1
END
GO
