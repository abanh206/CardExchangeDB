-- User Card Synthetic Transaction

Create PROCEDURE uspSYNUserCard
@Run INT
AS
DECLARE
	@Email varchar(75),
	@Condition varchar(255),
	@Price decimal(19,4),
	@BeginDate datetime,
	@EndDate datetime,
	@CardNum varchar(75),
	@Rand numeric(16,16),
	@CardCount INT = (SELECT Count(*) FROM [CARD]),
	@UserCount INT = (SELECT COUNT(*) FROM [USER]),
	@ConditionCount INT = (SELECT COUNT(*) FROM [CONDITION]),
	@CardID INT,
	@UserID INT,
	@ConditionID INT

WHILE @Run > 0
BEGIN
    SET @Rand = (SELECT Rand())
    SET @CardID= (SELECT @Rand * @CardCount + 1)
    SET @UserID = (SELECT @Rand * @UserCount + 1)
    SET @ConditionID = (SELECT @Rand * @ConditionCount + 1)

    SET @Email = (SELECT Email FROM [USER] WHERE UserID = @UserID)
    SET @Condition = (SELECT CardConditionName FROM [CONDITION] WHERE CardConditionID = @ConditionID)
    SET @Price = (CASE
        WHEN (SELECT @Rand * 100) < 10 THEN 10
        WHEN (SELECT @Rand * 100) BETWEEN 10 AND 30 THEN 20
        WHEN (SELECT @Rand * 100) BETWEEN 30 AND 50 THEN 30
        ELSE 40
        END)

    SET @BeginDate = (SELECT GetDate() - (SELECT @Rand * 200))
    SET @EndDate =  NULL
    SET @CardNum = (SELECT CardNum FROM [CARD] WHERE CardID = @CardID)

    EXEC uspPopulateUserCard
        @Email = @Email,
        @Condition = @Condition,
        @BeginDate = @BeginDate,
        @EndDate = @EndDate,
        @CardNum = @CardNum

    SET @Run = @Run -1
END
GO