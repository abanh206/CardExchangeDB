--No Blue Eyes And Cali

CREATE FUNCTION fnNoCaliBlueEyes()
RETURNS INT
AS
BEGIN
DECLARE @RET int = 0
IF EXISTS(SELECT * FROM USER_CARD uc
   		 JOIN [USER] u ON u.UserID = uc.UserID
   		 JOIN [ADDRESS] a ON u.AddressID = a.AddressID
   		 JOIN [CITY] c ON c.CityID = a.CityID
   		 JOIN [STATE] s ON s.StateID = c.StateID
   		 JOIN [CARD] ca ON ca.CardID = uc.CardID
   		 WHERE s.StateName = 'California, CA' AND ca.cardName = 'Blue-Eyes White Dragon')
SET @RET = 1
RETURN @RET
END
GO

ALTER TABLE USER_CARD
ADD CONSTRAINT CK_NoCaliBlueEyes
CHECK (dbo.fnNoCaliBlueEyes() = 0)

--No Damaged pot of greeds
-- Cannot put pot of greed for sale if damaged
CREATE FUNCTION fnNoDamageGreed()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF EXISTS(SELECT * FROM USER_CARD uc
JOIN [CARD] c ON c.CardID = uc.CardID
JOIN [CONDITION] con ON con.CardConditionID = uc.CardConditionID
WHERE c.CardName = 'Pot of Greed' AND con.CardConditionName = 'Damaged')
SET @RET = 1
RETURN @RET
END
GO

ALTER TABLE USER_CARD
ADD CONSTRAINT CK_NoDamageGreed
CHECK (dbo.fnNoDamageGreed() = 0)
GO

--No Florida Transactions

CREATE FUNCTION fnNoFloridaTrans()
RETURNS INT
AS
BEGIN
DECLARE @RET int = 0
IF EXISTS(SELECT * FROM USER_CARD uc
   		 JOIN [USER] u ON u.UserID = uc.UserID
   		 JOIN [ADDRESS] a ON u.AddressID = a.AddressID
   		 JOIN [CITY] c ON c.CityID = a.CityID
   		 JOIN [STATE] s ON s.StateID = c.StateID
   		 JOIN [EVENT] e on uc.UserCardID = e.UserCardID
		 JOIN [EVENT_TYPE] et on e.EventTypeID = et.EventTypeID
   		 WHERE s.StateName = 'Florida, FL'
			AND (et.EventTypeName = 'Buyer' OR et.EventTypeName = 'Seller'))
SET @RET = 1
RETURN @RET
END
GO

ALTER TABLE [EVENT] WITH NOCHECK
ADD CONSTRAINT CK_NoFloridaTrans
CHECK (dbo.fnNoFloridaTrans() = 0)

-- No Greg Hay

CREATE FUNCTION fnNoGregHay()
RETURNS INT
AS
BEGIN
DECLARE @RET int = 0
IF EXISTS(SELECT * FROM [USER]
			Where (FirstName = 'Greg' OR FirstName = 'Gregory' Or FirstName = 'Greggy')
			AND LastName = 'Hay')
SET @RET = 1
RETURN @RET
END
GO

ALTER TABLE [USER]
ADD CONSTRAINT CK_NoGregHay
CHECK (dbo.fnNoGregHay() = 0)

-- Age Limit For Trading

Create Function fnTradeAgeLimit()
Returns Int
AS
Begin
Declare @Ret int = 0
IF Exists (Select * From [User] U
			Join USER_CARD UC On U.UserID = UC.UserID
			Join Event E ON UC.UserCardID = E.UserCardID
			Where Age < 18)
	Set @Ret = 1
Return @Ret
End
Go

Alter Table Event
Add Constraint CK_TradeAgeLimit
Check (dbo.fnTradeAgeLimit() = 0)

-- Trade Limit of 100 Transaction of the Same Card Within 24H

Create Function fnTradeLimit()
Returns Int
As
Begin
Declare @Ret int = 0
If Exists (Select U.UserID, Count(*) As [Count] From [User] U
			Join User_Card UC On U.UserID = UC.UserID
			Join Event E On UC.UserCardID = E.UserCardID
			Where E.Date > GetDate() - 1
			Group By U.UserID, UC.CardID, UC.CardConditionID
			Having Count(*) > 100)
	Set @Ret = 1
Return @Ret
End
Go

Alter Table Event
Add Constraint CK_TradeLimit
Check (dbo.fnTradeLimit() = 0)
