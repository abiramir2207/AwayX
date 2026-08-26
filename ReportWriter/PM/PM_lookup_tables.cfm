<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Queries used by the lookup tables																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- Get all of the statuses --->
<CFQUERY NAME="Get_Status" datasource="#application.datasource#">
	Select		PM_Status_ID,
				PM_Status_Description
	From		PM_Status
	Where		PM_Status_Deleted	=	0
	Order by	LTRIM(PM_Status_Description)
</CFQUERY>

<!--- Get all of the Priorities --->
<CFQUERY NAME="Get_Priority" datasource="#application.datasource#">
	Select		PM_Priority_ID,
				PM_Priority_Description
	From		PM_Priority
	Where		PM_Priority_Deleted	=	0
	Order by	PM_Weight,LTRIM(PM_Priority_Description)
</CFQUERY>

<!--- Get all of the Phases --->
<CFQUERY NAME="Get_Phase" datasource="#application.datasource#">
	Select		PM_Phase_ID,
				PM_Phase_Description
	From		PM_Phase
	Where		PM_Phase_Deleted	=	0
	Order by	LTRIM(PM_Phase_Description)
</CFQUERY>

<!--- Get all of the QBrands --->
<!------<CFQUERY NAME="Get_QBrands" datasource="#application.datasource#">
	Select		PM_QBrands_ID,
				PM_QBrands_Description
	From		PM_QBrands
	Where		PM_QBrands_Deleted	=	0
	Order by	PM_QBrands_Code
</CFQUERY>----->

<!--- Get all of the Functioanl Areas of Responsibility --->
<CFQUERY NAME="Get_FAR" datasource="#application.datasource#">
	Select		PM_FAR_ID,
				PM_FAR_Description
	From		PM_FAR
	Where		PM_FAR_Deleted	=	0
	Order by	LTRIM(PM_FAR_Description)
</CFQUERY>

<!--- Get all of the Sponsors --->
<CFQUERY NAME="Get_Sponsor" datasource="#application.datasource#">
	Select		PM_Sponsor_ID,
				PM_Sponsor_Name_First, 
				PM_Sponsor_Name_Last
	From		PM_Sponsor
	Where		PM_Sponsor_Deleted	=	0
	Order by	LTRIM(PM_Sponsor_Name_First)
</CFQUERY>

<!--- Get the fiscal calendar --->
<!------<CFQUERY NAME="Get_Fiscal_Calendar" datasource="#application.datasource#">
	Select		Start_Date,
				End_date
	From		Fiscal_Year
	Where		Company_Main_ID	= '#request.AccessStructure.Company_Main_ID#'
				AND
				Deleted			= 0
	Order by	Start_Date 
</CFQUERY>----->

<!--- Get the list of Owners --->
<!------<CFQUERY NAME="Get_Owners" datasource="#application.datasource#">
	Select		Name_First,
				Name_Last,
				User_ID
	From		_Users
	Where		Company_Main_ID		=		'#request.AccessStructure.Company_Main_ID#'
				AND
				Deleted			= 0
	Order by	Name_Last
</CFQUERY>----->

<!------<CFQUERY NAME="Get_Positions" datasource="#application.datasource#">
	Select		u.Name_First,
				u.Name_Last,
				up.Position_Label,
				up.User_Positions_ID
	From		_Users u
				INNER JOIN 	User_Position_Holders ph
				ON ((ph.User_ID = u.User_ID) AND (ph.Deleted=0))
				INNER JOIN	User_Positions up
				ON ((up.User_Positions_ID 	= ph.User_Positions_ID) AND (up.Deleted=0))
	Where		u.Company_Main_ID			=		'#request.AccessStructure.Company_Main_ID#'
				AND
				u.Deleted			= 0
	Order by	u.Name_Last
</CFQUERY>---->

<!------
<!---  initial user position--->
<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>
<!--- locate those positions underneath the supplied position --->
<CFSET GP_Supplied_Position = getUserPosition.User_Positions_ID>
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">
<!--- list of positions underneath supplied --->
<CFSET ListOfPositionsUnderMine = GP_Position_List_From_My_Position_Down>

<CFQUERY NAME="Get_Positions" datasource="#application.datasource#">
	Select		User_Positions.Position_Label,
				User_Positions.User_Positions_ID
				<CFIF IsDefined("URL.RID")>
				,CASE 
				WHEN PM_Owner_Position.PM_Item_Master_ID IS NULL THEN
					0
				ELSE
					1
				END AS Owner_Position_Selected
				</CFIF>
	From		User_Positions
				<CFIF IsDefined("URL.RID")>
				LEFT JOIN PM_Owner_Position
				ON
				(
					PM_Owner_Position.User_Positions_ID = User_Positions.User_Positions_ID
					<CFIF Len(Trim(URL.RID)) GT 0>
					AND
					PM_Owner_Position.PM_Item_Master_ID = '#URL.RID#'
					<CFELSE>
					AND
					1=2
					</CFIF>
				)
				</CFIF>
	Where		User_Positions.Deleted=0
				AND
				(len(User_Positions.Position_Label) <> 0)
				AND EXISTS
				(
					SELECT Service_Zones.Service_Zone_ID
					FROM Service_Zones
					WHERE
					User_Positions.Service_Zone_ID IS NULL
					OR
					(Service_Zones.Deleted = 0 AND User_Positions.Service_Zone_ID = Service_Zones.Service_Zone_ID)
				)
				AND EXISTS
				(
					SELECT Service_Regions.Service_Region_ID
					FROM Service_Regions
					WHERE
					User_Positions.Service_Region_ID IS NULL
					OR
					(Service_Regions.Deleted = 0 AND User_Positions.Service_Region_ID = Service_Regions.Service_Region_ID)
				)
				AND EXISTS
				(
					SELECT Service_Markets.Service_Market_ID
					FROM Service_Markets
					WHERE
					User_Positions.Service_Market_ID IS NULL
					OR
					(Service_Markets.Deleted = 0 AND User_Positions.Service_Market_ID = Service_Markets.Service_Market_ID)
				)
				AND
				User_Positions.User_Positions_ID IN (#ListOfPositionsUnderMine#)				
	Order by	User_Positions.Position_Label
</CFQUERY>
----->

<!---  initial user position--->
<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>
<!--- locate those positions underneath the supplied position --->
<CFSET GP_Supplied_Position = getUserPosition.User_Positions_ID>
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">
<!--- list of positions underneath supplied --->
<CFSET ListOfPositionsUnderMine = GP_Position_List_From_My_Position_Down>

<CFQUERY NAME="Get_Positions" datasource="#application.datasource#">
	Select		User_Positions.Position_Label,
				User_Positions.User_Positions_ID
	From		User_Positions
	Where		User_Positions.Deleted=0
				AND
				(len(User_Positions.Position_Label) <> 0)
				AND EXISTS
				(
					SELECT Service_Zones.Service_Zone_ID
					FROM Service_Zones
					WHERE
					User_Positions.Service_Zone_ID IS NULL
					OR
					(Service_Zones.Deleted = 0 AND User_Positions.Service_Zone_ID = Service_Zones.Service_Zone_ID)
				)
				AND EXISTS
				(
					SELECT Service_Regions.Service_Region_ID
					FROM Service_Regions
					WHERE
					User_Positions.Service_Region_ID IS NULL
					OR
					(Service_Regions.Deleted = 0 AND User_Positions.Service_Region_ID = Service_Regions.Service_Region_ID)
				)
				AND EXISTS
				(
					SELECT Service_Markets.Service_Market_ID
					FROM Service_Markets
					WHERE
					User_Positions.Service_Market_ID IS NULL
					OR
					(Service_Markets.Deleted = 0 AND User_Positions.Service_Market_ID = Service_Markets.Service_Market_ID)
				)
				AND
				User_Positions.User_Positions_ID IN (#ListOfPositionsUnderMine#)				
	Order by	User_Positions.Position_Label
</CFQUERY>

<!------<CFQUERY NAME="Get_QBrands2" datasource="#application.datasource#">
Select 	distinct qb.Q_Brand_ID,qb.Q_Brand,pqb.LOB
From	Product_Q_Brand_Desc pqb,Q_Brand_Desc qb, product_category_lob_active pcla
Where	pqb.BSA_Foodservice_Items_Master_ID=pcla.BSA_Foodservice_Items_Master_ID
	and	pqb.Q_Brand_ID=qb.Q_Brand_ID
	and	pqb.LOB='F'
	and pqb.Deleted=0
	and qb.Deleted=0
	Order By qb.Q_Brand
</CFQUERY>
----->


<!--- 
<CFOUTPUT QUERY="Get_Fiscal_Calendar">#dateformat(Start_Date, 'm/d/yy')# - #dateformat(End_date, 'm/d/yy')#<BR></CFOUTPUT>
 --->