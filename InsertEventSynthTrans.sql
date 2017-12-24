-- Insert Event

Create Procedure uspEventWrapper
@Run Int
As
Begin
	Declare
	@Rand numeric(16,16),
	@ID int,
	@UserCardID int,
	@UserRow int = (Select Count(*) From [User]),
	@SellerEmail varchar(225),
	@BuyerEmail varchar(225),
	@CardNum varchar(75),
	@Condition varchar(75),
	@EventType varchar(75),
	@Date datetime,
	@Price decimal(17,2)

	While @Run > 0
	Begin
		Set @Rand = (Select Rand())
		Set @ID = (Select @Rand * (Select Count(*) From USER_CARD Where EndDate Is Null)) + 1
		Set @UserCardID = (Select s.UserCardID From 
			(Select ROW_NUMBER() Over(Order By UserCardID) As RowNumber, UserCardID From USER_CARD Where EndDate is Null) s 
			Where RowNumber = @ID)
		Set @SellerEmail = (Select Email From [User] Join User_Card On [User].UserID = User_Card.UserID Where UserCardID = @UserCardID)
		Set @ID = (Select @Rand * @UserRow)
		Set @BuyerEmail = (Select s.Email From 
			(Select ROW_NUMBER() Over(Order By UserID) As RowNumber, Email From [User] Where Email != @SellerEmail) s
			Where RowNumber = @ID)
		Set @CardNum = (Select CardNum From Card C 
			Join USER_CARD UC On C.CardID = UC.CardID 
			Where UserCardID = @UserCardID)
		Set @Condition = (Select CardConditionName From Condition C 
			Join USER_CARD UC On C.CardConditionID = UC.CardConditionID 
			Where UserCardID = @UserCardID)
		Set @EventType = 'Seller'
		Set @Date = GetDate()
		Set @Price = (Select @Rand * 100)

		Begin Try
			Exec uspEventTRX
				@BuyerEmail = @BuyerEmail,
				@SellerEmail = @SellerEmail,
				@CardNum = @CardNum,
				@CardCondition = @Condition,
				@EventType = @EventType,
				@Date = @Date,
				@Price = @Price
		End Try
		Begin Catch
			Print 'UserCard Not Found'
		End Catch
		
		Set @Run = @Run - 1
	End
End