-- Get State ID
CREATE PROCEDURE uspGetStateID
@StateName VARCHAR(75),
@StateID INT OUTPUT
AS
BEGIN
    SET @StateID = (SELECT StateID FROM [STATE] WHERE StateName = @StateName)
END
GO

-- Get City ID
CREATE PROCEDURE uspGetCityID
@CityName VARCHAR(75),
@CityStateName VARCHAR(75),
@CityID INT OUTPUT
AS
BEGIN
    DECLARE @CityStateID INT

    EXEC uspGetStateID
        @StateName = @CityStateName,
        @StateID = @CityStateID OUTPUT

    SET @CityID = (SELECT CityID FROM CITY 
        WHERE CityName = @CityName AND StateID = @CityStateID)
END
GO

-- Get Attribute ID
CREATE PROCEDURE uspGetAttributeID
@AttributeName VARCHAR(75),
@AttributeID INT OUTPUT
AS
BEGIN
	SET @AttributeID = (SELECT AttributeID FROM [Attribute] 
        WHERE AttributeName = @AttributeName)
END
GO

-- Get SubType ID
CREATE PROCEDURE uspGetSubTypeID 
@SubTypeName VARCHAR(75),
@SubTypeID INT OUTPUT
AS
BEGIN
	SET @SubTypeID = (SELECT SubTypeID FROM [SubType] 
		WHERE SubTypeName = @SubTypeName)
END
GO

-- Get Card ID
CREATE PROCEDURE uspGetCardID
@CardNum VARCHAR(75),
@CardID INT OUTPUT
AS
BEGIN
    SET @CardID = (SELECT CardID FROM [CARD] 
        WHERE CardNum = @CardNum)
END
GO

-- Get User ID
CREATE PROCEDURE uspGetUserID 
@UserEmail VARCHAR(225),
@UserID INT OUTPUT
AS 
BEGIN
	SET @UserID = (SELECT U.UserID FROM [USER] U 
        WHERE U.Email = @UserEmail) 
END
GO

-- Get User Card ID
CREATE Procedure uspGetUserCardID
@Email VARCHAR(225),
@CardNum VARCHAR(75),
@Condition VARCHAR(75),
@UserCardID INT OUTPUT
AS 
BEGIN
	DECLARE @UserID INT, @CardID INT, @ConditionID INT

	EXEC uspGetUserID 
        @UserEmail = @Email,
        @UserID = @UserID OUTPUT

	EXEC uspGetCardID
        @CardNum = @CardNum,
        @CardID = @CardID OUTPUT

	EXEC uspGetConditionID
        @CardConditionName = @Condition,
        @CardConditionID = @ConditionID OUTPUT

	SET @UserCardID = (SELECT Top 1 UserCardID FROM USER_CARD 
		WHERE UserID = @UserID
		And CardID = @CardID
		And CardConditionID = @ConditionID
		And ENDDate is Null)	
END
GO

-- Get Condition ID
CREATE Procedure uspGetConditionID
@CardConditionName VARCHAR(75),
@CardConditionID INT OUTPUT
AS
BEGIN
	SET @CardConditionID = (SELECT CardConditionID FROM CONDITION
		WHERE CardConditionName = @CardConditionName)
END
GO

-- Get EventType ID
CREATE Procedure uspGetEventTypeID
@EventTypeName VARCHAR(75),
@EventTypeID INT OUTPUT
AS
BEGIN
	SET @EventTypeID = (SELECT EventTypeID FROM Event_Type 
		WHERE EventTypeName = @EventTYpeName)
END
GO