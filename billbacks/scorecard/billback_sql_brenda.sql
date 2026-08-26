/****
*	Name:		sel_LookUpLockingUser
*
*	Function:	Looks to see who has locked a billback
*
*	Parameter:	BB_User_Who_Locked thingy
*
*	Return:		None
*
****/
if exists (select name 
	   from   sysobjects 
	   where  name = 'sel_LookUpLockingUser' 
	   and 	  type = 'p')
    drop procedure sel_LookUpLockingUser
go
create procedure sel_LookUpLockingUser
	@BB_Locked_By_User_ID nvarchar(50),
	@Name_First nvarchar(50) OUTPUT,
	@Name_Last nvarchar(50) OUTPUT
as
	set nocount on

	SELECT Name_First, Name_Last
	FROM _Users
	WHERE User_ID = '@BB_Locked_By_User_ID'

	set nocount off
go


/****
*	Name:		sel_getUserPosition
*
*	Function:	Gets the position of the user viewing the page
*
*	Parameter:	Viewing users' ID
*
*	Return:		None
*
****/
if exists (select name 
	   from   sysobjects 
	   where  name = 'sel_getUserPosition' 
	   and 	  type = 'p')
    drop procedure sel_getUserPosition
go
create procedure sel_getUserPosition
	@User_ID nvarchar(50)
as
	set nocount on

	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '@User_ID' AND Deleted = 0

	set nocount off
go


/****
*	Name:		up_UnlockBillbacks
*
*	Function:	Releases locks on billbacks set by users who have not locked out
*
*	Parameter:	Viewing users' ID
*
*	Return:		None
*
****/
if exists (select name 
	   from   sysobjects 
	   where  name = 'up_UnlockBillbacks' 
	   and 	  type = 'p')
    drop procedure up_UnlockBillbacks
go
create procedure up_UnlockBillbacks
	@User_ID nvarchar(50)
as
	set nocount on
	UPDATE Billback
	Set BB_Is_Locked = 0 
	WHERE BB_Locked_By_User_ID = '@User_ID'
	set nocount off
go


/****
*	Name:		sel_getBillbacksWithBrokersInMyPositionBranch
*
*	Function:	Returns all billbacks with brokers in position branch of viewing user
*
*	Parameter:	Viewing users' position
*
*	Return:		None
*
****/
if exists (select name 
	   from   sysobjects 
	   where  name = 'sel_getBillbacksWithBrokersInMyPositionBranch' 
	   and 	  type = 'p')
    drop procedure sel_getBillbacksWithBrokersInMyPositionBranch
go
create procedure sel_getBillbacksWithBrokersInMyPositionBranch
	@Position_List_From_My_Position_Down varchar(500)
as
	set nocount on
	
	SELECT     dbo.User_Positions.User_Positions_ID, dbo.Contract_Main.Contract_Status_Type_IDX, dbo.Contract_Brokers.Contract_Main_ID
	FROM         dbo.User_Positions INNER JOIN
                      dbo.Service_Markets ON dbo.User_Positions.Service_Market_ID = dbo.Service_Markets.Service_Market_ID INNER JOIN
                      dbo.ConAgra_Foodservice_Brokers ON 
                      dbo.Service_Markets.ConAgra_Foodservice_Brokers_ID = dbo.ConAgra_Foodservice_Brokers.ConAgra_Foodservice_Brokers_ID INNER JOIN
                      dbo.Contract_Brokers ON 
                      dbo.ConAgra_Foodservice_Brokers.ConAgra_Foodservice_Brokers_ID = dbo.Contract_Brokers.ConAgra_Foodservice_Brokers_ID INNER JOIN
                      dbo.Contract_Main ON dbo.Contract_Brokers.Contract_Main_ID = dbo.Contract_Main.Contract_Main_ID
	WHERE     (dbo.Service_Markets.Deleted = 0) AND (dbo.User_Positions.Deleted = 0) AND (dbo.Contract_Main.Contract_Status_Type_IDX = 4) AND 
                      (dbo.Contract_Main.Deleted = 0) AND (dbo.User_Positions.User_Positions_ID IN (@Position_List_From_My_Position_Down))
					  AND dbo.Contract_Main.Flagged_As_Purged = 0 AND dbo.Contract_Main.Force_Expiration_Flag = 0			
	
	set nocount off
go


/****
*	Name:		sel_getBillbacksWithDistributorsInMyPositionBranch
*
*	Function:	Returns all billbacks with distributors in position branch of viewing user
*
*	Parameter:	Viewing users' position
*
*	Return:		None
*
****/
if exists (select name 
	   from   sysobjects 
	   where  name = 'sel_getBillbacksWithDistributorsInMyPositionBranch' 
	   and 	  type = 'p')
    drop procedure sel_getBillbacksWithDistributorsInMyPositionBranch
go
create procedure sel_getBillbacksWithDistributorsInMyPositionBranch
	@Position_List_From_My_Position_Down varchar(500)
as
	set nocount on
	
	SELECT     
	dbo.User_Positions.User_Positions_ID, dbo.Contract_Distributors.Contract_Main_ID, dbo.Contract_Main.Contract_Status_Type_IDX
	FROM         dbo.User_Positions INNER JOIN
                      dbo.Service_Markets ON dbo.User_Positions.Service_Market_ID = dbo.Service_Markets.Service_Market_ID INNER JOIN
                      dbo.ConAgra_Foodservice_Brokers ON 
                      dbo.Service_Markets.ConAgra_Foodservice_Brokers_ID = dbo.ConAgra_Foodservice_Brokers.ConAgra_Foodservice_Brokers_ID INNER JOIN
                      dbo.ConAgra_Foodservice_Customers ON 
                      dbo.ConAgra_Foodservice_Brokers.ConAgra_Foodservice_Brokers_ID = dbo.ConAgra_Foodservice_Customers.ConAgra_Foodservice_Brokers_ID INNER
                       JOIN
                      dbo.Contract_Distributors ON 
                      dbo.ConAgra_Foodservice_Customers.ConAgra_Foodservice_Customers_ID = dbo.Contract_Distributors.ConAgra_Foodservice_Customers_ID INNER JOIN
                      dbo.Contract_Main ON dbo.Contract_Distributors.Contract_Main_ID = dbo.Contract_Main.Contract_Main_ID
	WHERE     (dbo.Service_Markets.Deleted = 0) AND (dbo.User_Positions.Deleted = 0) AND (dbo.Contract_Distributors.Deleted = 0) AND 
                      (dbo.ConAgra_Foodservice_Customers.Deleted = 0) AND (dbo.Contract_Main.Contract_Status_Type_IDX = 4) AND (dbo.Contract_Main.Deleted = 0)
			AND dbo.User_Positions.User_Positions_ID IN(@Position_List_From_My_Position_Down)
			AND dbo.Contract_Main.Flagged_As_Purged = 0 AND dbo.Contract_Main.Force_Expiration_Flag = 0
	
	set nocount off
go

/****
*	Name:			sp_ProcName
*
*	Function:	None
*
*	Parameter:	None
*
*	Return:		None
*
****/
if exists (select name 
	   from   sysobjects 
	   where  name = 'sp_ProcName' 
	   and 	  type = 'p')
    drop procedure sp_ProcName
go
create procedure sp_ProcName
as
	set nocount on
	
	
	
	set nocount off
go