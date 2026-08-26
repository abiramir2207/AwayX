<!------ Get application settings ----->
<cfif NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>

<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />

<cfset GP_Position_List_From_My_Position_Down = "0" />
<cfset GP_Position_List_From_My_Position_Down_SC = "0" />

<cfif NOT isDefined("Get_Profile_Settings")>
	<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
</cfif>

<CFSET GP_Supplied_Position = UserPositionList>

<!------ <CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm"> ----->

<cfset HQPosition = CreateObject("component", "components.geography.position").getHQPosition() />
<cfset HQUser = 0>
<cfif listfind(GP_Supplied_Position, HQPosition.User_Positions_ID)>
	<cfset HQUser = 1>
</cfif>

<cfif NOT Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>

<cfset GP_Position_List_From_My_Position_Down = "SELECT Below_User_Positions_ID FROM @Positions_Below_Me" />
<cfset GP_Position_List_From_My_Position_Down_SC = "SELECT Below_User_Positions_ID FROM ##Positions_Below_Me" />

<!--- D12833 BJF and DRK: If the user is HQ, they should be able to see all positions, so don't do the joins on user position 

NOTE: It would further increase performance if all calling pages were modified NOT to include the list of programs if the users 
--->

<cfoutput>

<!--- D12833 If the user is not HQ we need to figure out which distributors they can see to include in program search 
 --->
<cfif HQUser IS NOT 1>
<CFSAVECONTENT variable="ProgramsWithDistUnderMe">
SELECT	DISTINCT Contract_Distributors.Contract_Main_ID
FROM	User_Positions
		INNER JOIN	BSA_Foodservice_Brokers 
		ON 
		User_Positions.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID
		INNER JOIN BSA_Foodservice_Customers
		ON
		BSA_Foodservice_Customers.Deleted = 0
		AND 
		(BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID	
		)
		INNER JOIN Contract_Distributors
		ON
		Contract_Distributors.Deleted = 0
		AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
WHERE	User_Positions.Deleted = 0
		AND User_Positions.User_Positions_ID IN(#GP_Position_List_From_My_Position_Down#)
</CFSAVECONTENT>
<CFSAVECONTENT variable="ProgramsWithDistUnderMe_SC">
SELECT	DISTINCT Contract_Distributors.Contract_Main_ID
FROM	User_Positions
		INNER JOIN ##Positions_Below_Me PBM ON 
			PBM.Below_User_Positions_ID = User_Positions.User_Positions_ID 
		INNER JOIN	BSA_Foodservice_Brokers 
		ON 
		User_Positions.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID
		INNER JOIN BSA_Foodservice_Customers
		ON
		BSA_Foodservice_Customers.Deleted = 0
		AND 
		(BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID	
		)
		INNER JOIN Contract_Distributors
		ON
		Contract_Distributors.Deleted = 0
		AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
WHERE	User_Positions.Deleted = 0
</CFSAVECONTENT>
<!--- If user is HQ they can see all programs based on position --->
<cfelse>
<CFSAVECONTENT variable="ProgramsWithDistUnderMe">
/*	if user is HQ	*/
SELECT	Distinct Contract_Main_ID 
FROM Contract_Main
WHERE Deleted = 0
</CFSAVECONTENT>
<!--- Is user HQ or not --->
<cfset ProgramsWithDistUnderMe_SC = ProgramsWithDistUnderMe />
</cfif>

<!--- D12833 If the user is not HQ we need to figure out which brokers they can see to include in program search --->
<cfif HQUser IS NOT 1>
<CFSAVECONTENT variable="ProgramsWithBrokerUnderMe">
SELECT	DISTINCT Contract_Brokers.Contract_Main_ID
FROM	User_Positions
		INNER JOIN	BSA_Foodservice_Brokers 
		ON 
		User_Positions.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID		
		INNER JOIN Contract_Brokers
		ON
		Contract_Brokers.Deleted = 0
		AND BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Contract_Brokers.BSA_Foodservice_Brokers_ID
WHERE	User_Positions.Deleted = 0
		AND User_Positions.User_Positions_ID IN(#GP_Position_List_From_My_Position_Down#)
</CFSAVECONTENT>
<CFSAVECONTENT variable="ProgramsWithBrokerUnderMe_SC">
SELECT	DISTINCT Contract_Brokers.Contract_Main_ID
FROM	User_Positions
		INNER JOIN ##Positions_Below_Me PBM ON 
			PBM.Below_User_Positions_ID = User_Positions.User_Positions_ID 
		INNER JOIN	BSA_Foodservice_Brokers 
		ON 
		User_Positions.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID		
		INNER JOIN Contract_Brokers
		ON
		Contract_Brokers.Deleted = 0
		AND BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Contract_Brokers.BSA_Foodservice_Brokers_ID
WHERE	User_Positions.Deleted = 0
</CFSAVECONTENT>
<cfelse>
	<!--- If user is HQ they can see all programs based on position --->
	<CFSAVECONTENT variable="ProgramsWithBrokerUnderMe">
	--if user is HQ
	SELECT	Distinct Contract_Main_ID 
	FROM Contract_Main
	WHERE Deleted = 0
	</CFSAVECONTENT>
	<cfset ProgramsWithBrokerUnderMe_SC = ProgramsWithBrokerUnderMe />
	<!--- Is user HQ or not --->
</cfif>


</cfoutput>

</cfif>