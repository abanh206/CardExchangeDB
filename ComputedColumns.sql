-- Age

CREATE FUNCTION fnCalculateAge(@UserID int)
RETURNS INT
AS
BEGIN
DECLARE @DOB date = (SELECT DOB FROM [USER] WHERE UserID = @UserID)
DECLARE @RET int = (SELECT FLOOR( DATEDIFF(DAY, @DOB, GetDate()) / 365.25 ))
RETURN @Ret
END

ALTER TABLE [USER]
ADD AGE AS (dbo.fnCalculateAge(UserID))

--Duration for USER_CARD

CREATE FUNCTION fnCalculateDuration(@UserCardID int)
RETURNS int
AS
BEGIN
DECLARE @BeginDate date = (SELECT BeginDate FROM USER_CARD WHERE UserCardID = @UserCardID)
DECLARE @EndDate date = (SELECT EndDate FROM USER_CARD WHERE UserCardID = @UserCardID)

IF @EndDate IS NULL
RETURN NULL

RETURN (DATEDIFF(DAY, @BeginDate, @EndDate))
END
GO

ALTER TABLE USER_CARD
ADD Duration AS (dbo.fnCalculateDuration(UserCardID))

--Quantity of each card on market

Create Function fnNumberOnMarket(@CardID int)
Returns INT
AS
Begin
	Declare @RET int = (Select Count(UserCardID) from USER_CARD Where CardID = @CardID)
	Return @RET
END
GO

Alter Table [Card]
Add NumberOnMarket AS (dbo.fnNumberOnMarket(CardID))

--Active Users Per State

Create Function fnActiveUsersPerState(@StateID int)
Returns INT
AS
Begin
	Declare @RET int = (Select Count(Distinct(UC.UserID)) from [Event] E 
		JOIN USER_CARD UC ON E.UserCardID = UC.UserCardID
		JOIN [USER] U On U.UserID = UC.UserID
		JOIN [ADDRESS] A ON U.AddressID = A.AddressID
		JOIN [CITY] C ON A.CityID = C.CityID
		JOIN [STATE] S ON C.StateID = S.StateID 
	 Where E.Date >= (Select GetDate() - 180)
		AND S.StateID = @StateID)
	Return @RET
END
GO

Alter Table [State]
Add ActiveUsers AS (dbo.fnActiveUsersPerState(StateID))

--Total Cards per User

Create Function fnTotalCards(@UserID Int)
Returns Int
As
Begin
	Declare @Ret numeric
	Set @Ret = (Select Count(*) From [User] U
		Join User_Card UC On U.UserID = UC.UserID
		Where U.UserID = @UserID
		And UC.EndDate Is Null)
Return @Ret
End
Go

Alter Table [User]
Add Inventory As dbo.fnTotalCards(UserID)

-- Market Price

Create Function fnMarketPrice(@CardID int)
Returns Numeric(19,4)
As
Begin
Declare @Ret numeric(19,4)
	Set @Ret = (Select avg(Price) as MarketPrice From EVENT E
		Join User_Card UC On E.UserCardID = UC.UserCardID
		Where EventTypeID = 1
		And CardID = @CardID
		Group By CardID)
	If @Ret is Null
		Set @Ret = 0
Return @Ret
End

Alter Table Card
Add MarketPrice As dbo.fnMarketPrice(CardID)


