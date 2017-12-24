--Number of cards each person has

CREATE VIEW v_CardsByPerson
AS
SELECT u.FirstName, u.LastName, COUNT(*) AS 'Number of Cards' FROM USER_CARD uc
JOIN [USER] u ON u.UserID = uc.UserID
GROUP BY u.FirstName, u.LastName, u.UserID

--States by number of users

CREATE VIEW v_TopStatesByUser
AS
SELECT s.StateName, COUNT(*) AS NumUsers FROM [USER] u
JOIN [ADDRESS] a ON a.AddressID = u.AddressID
JOIN CITY c ON c.cityID = a.CityID
JOIN [STATE] s ON s.StateID = c.StateID
GROUP BY s.StateID, s.StateName

--Moderately Used Or Better Tri-Horned Dragon Being Sold

Create View v_ModeratelyPlayedUltraRareTriHornedDragonForSale AS
Select C.CardName as 'Card', C.CardNum as 'Edition', Co.CardConditionName AS 'Condition', R.RarityName As 'Rarity', (U.FirstName + ' ' + U.LastName) AS 'Seller' 
	From [CONDITION] Co JOIN [USER_CARD] UC ON Co.CardConditionID = UC.CardConditionID
	JOIN [USER] U ON UC.UserID = U.UserID
	JOIN [CARD] C ON UC.CardID = C.CardID
	JOIN [Rarity] R On C.RarityID = R.RarityID
	Where (Co.CardConditionName = 'Near Mint' 
		OR Co.CardConditionName = 'Lightly Played'
		OR Co.CardConditionName = 'Moderately Played')
		AND C.CardName = 'Tri-Horned Dragon'
		AND R.RarityName = 'Secret Rare'
		AND UC.EndDate is null

--Buyer Transaction Log for the Last 30 Days

Create View v_BuyerTransLogOver30Days AS
Select (U.FirstName + ' ' + U.LastName) 'Buyer', C.CardName 'Card', 
	E.Price 'Price Sold', Co.CardConditionName 'Condition', E.Date
	From EVENT_TYPE ET JOIN EVENT E ON ET.EventTypeID = E.EventTypeID
		JOIN USER_CARD UC ON E.UserCardID = UC.UserCardID
		JOIN Card C ON UC.CardID = C.CardID
		JOIN Condition Co ON UC.CardConditionID = Co.CardConditionID
		JOIN [User] U ON UC.UserID = U.UserID
	Where ET.EventTypeName = 'Buyer' 
		AND E.Date >= (Select GetDate() - 30)

--Current Market Stock

Create View vStore
As
Select CardName, CardConditionName, Count(*) As Stock From USER_CARD UC
	Join Card C On UC.CardID = C.CardID
	Join Condition CO On UC.CardConditionID = CO.CardConditionID
Where EndDate Is Null 
Group By CardName, CardConditionName
Go

--View Users Older Than 18

Create View vUsers
As
Select Concat(FirstName, ' ', LastName) As Name, CityName, StateName From [User] U 
	Join ADDRESS A On U.AddressID = A.AddressID
	Join CITY C On A.CityID = C.CityID
	Join STATE S On C.StateID = S.StateID
	Where U.DOB < (Getdate() - 365.25 * 18)
