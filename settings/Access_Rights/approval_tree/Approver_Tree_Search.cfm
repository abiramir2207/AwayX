<!--- 
	INPUT:
		Zone_ID_Search = 1 zone id
		Region_ID_Search = 1 region_id
		Market_ID_Search = 1 market ID

	OUTPUT:

	Default_Approver_List	= User id list>
	Zone_Approver_List 		= User id list>
	Region_Approver_List	= User id list>
	Market_Approver_List	= User id list>	
 --->
	<!--- get install path --->	
	<!--- END get install path --->
	<!--- create usable directory information --->
	<CFSET The_File_Location = APPLICATIONPATH & "\settings\Access_Rights\approval_tree\Serialized_Approver_Tree.cfm">
	<!--- end create usable directory information --->	
<CFIF FileExists(The_File_Location) EQ FALSE>
	<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\Approver_Tree_Build.cfm">
</CFIF>

<CFFILE ACTION="READ" FILE="#The_File_Location#" VARIABLE="Approval_Tree_WDDX">
<CFWDDX ACTION="WDDX2CFML" INPUT="#Approval_Tree_WDDX#" OUTPUT="Approval_Tree">



<!--- search it --->

<CFSET Current_Tree_Node = structnew()>

<CFQUERY NAME="getAllTopLevelApprovers" datasource="#application.datasource#">
	SELECT     dbo.User_Position_Holders.User_ID, dbo.User_Position_Holders.User_Positions_ID
	FROM         dbo.User_Positions INNER JOIN
	                      dbo.User_Position_Holders ON dbo.User_Positions.User_Positions_ID = dbo.User_Position_Holders.User_Positions_ID
	WHERE     (dbo.User_Positions.Deleted = 0) AND (dbo.User_Position_Holders.deleted = 0) AND (dbo.User_Positions.Service_Market_ID IS NULL) AND 
	                      (dbo.User_Positions.Service_Region_ID IS NULL) AND (dbo.User_Positions.Service_Zone_ID IS NULL)
</CFQUERY>

<CFSET Default_Approver_List = Valuelist(getAllTopLevelApprovers.User_ID)>
<CFSET Zone_Approver_List = "">
<CFSET Region_Approver_List = "">
<CFSET Market_Approver_List = "">



<CFSET Default_Approver_Position_List = Valuelist(getAllTopLevelApprovers.User_Positions_ID)>
<CFSET Zone_Approver_Position_List = "">
<CFSET Region_Approver_Position_List = "">
<CFSET Market_Approver_Position_List = "">


<CFSET Zone_ID_Search = "Z_#trim(replace(Zone_ID_Search, '-', '_', 'ALL'))#">
<CFSET Region_ID_Search = "R_#trim(replace(Region_ID_Search, '-', '_', 'ALL'))#">
<CFSET Market_ID_Search = "M_#trim(replace(Market_ID_Search, '-', '_', 'ALL'))#">

<!--- IN SEARCH
<CFOUTPUT>
<HR>
	#Zone_ID_Search#
<HR>
<HR>
	#Region_ID_Search#
<HR>
<HR>
	#Market_ID_Search#
<HR>
</CFOUTPUT> --->

<!--- BEGIN SEARCH --->
<CFIF len(trim(Zone_ID_Search)) GT 2>
<CFLOOP INDEX="temp_Zone_ID" LIST="#structkeylist(Approval_Tree)#">
	<CFIF trim(temp_Zone_ID) EQ trim(Zone_ID_Search)>
		<CFSET Current_Tree_Node = evaluate("Approval_Tree.#temp_Zone_ID#")>
	</CFIF>
</CFLOOP>


<!--- Get Approvers --->
<CFIF Isdefined("Current_Tree_Node.AA_APPROVERS_POSITION")>
	<CFLOOP INDEX="Approver_Position" LIST="#structkeylist(Current_Tree_Node.AA_APPROVERS_POSITION)#">
		<CFLOOP INDEX="User_ID" LIST="#structkeylist(evaluate("Current_Tree_Node.AA_APPROVERS_POSITION.#Approver_Position#"))#">
			<CFSET Zone_Approver_List = listappend(Zone_Approver_LIST,User_ID)>
			<CFSET Zone_Approver_Position_List = listappend(Zone_Approver_Position_List,mid(Approver_Position, 3, len(Approver_Position)))>
		</CFLOOP>
	</CFLOOP>
</CFIF>
</CFIF>

<CFIF len(trim(Region_ID_Search)) GT 2>
 <CFLOOP INDEX="temp_Region_ID" LIST="#structkeylist(Current_Tree_Node)#">
	<CFIF trim(temp_Region_ID) EQ trim(Region_ID_Search)>
		<CFSET Current_Tree_Node = evaluate("Approval_Tree.#Zone_ID_Search#.#temp_Region_ID#")>
	</CFIF>
</CFLOOP>

<!--- Get Approvers --->
<CFIF Isdefined("Current_Tree_Node.AA_APPROVERS_POSITION")>
	<CFLOOP INDEX="Approver_Position" LIST="#structkeylist(Current_Tree_Node.AA_APPROVERS_POSITION)#">
		<CFLOOP INDEX="User_ID" LIST="#structkeylist(evaluate("Current_Tree_Node.AA_APPROVERS_POSITION.#Approver_Position#"))#">
			<CFSET Region_Approver_List = listappend(Region_Approver_List,User_ID)>
			<CFSET Region_Approver_Position_List = listappend(Region_Approver_Position_List,mid(Approver_Position, 3, len(Approver_Position)))>
		</CFLOOP>
	</CFLOOP>
</CFIF>
</CFIF>


<CFIF len(trim(Market_ID_Search)) GT 2>
<CFLOOP INDEX="temp_Market_ID" LIST="#structkeylist(Current_Tree_Node)#">
	<CFIF trim(temp_Market_ID) EQ trim(Market_ID_Search)>
		<CFSET Current_Tree_Node = evaluate("Approval_Tree.#Zone_ID_Search#.#Region_ID_Search#.#temp_Market_ID#")>
	</CFIF>
</CFLOOP>

<!--- Get Approvers --->
<CFIF Isdefined("Current_Tree_Node.AA_APPROVERS_POSITION")>
	<CFLOOP INDEX="Approver_Position" LIST="#structkeylist(Current_Tree_Node.AA_APPROVERS_POSITION)#">
		<CFLOOP INDEX="User_ID" LIST="#structkeylist(evaluate("Current_Tree_Node.AA_APPROVERS_POSITION.#Approver_Position#"))#">
			<CFSET Market_Approver_List = listappend(Market_Approver_List,User_ID)>
			<CFSET Market_Approver_Position_List = listappend(Market_Approver_Position_List,mid(Approver_Position, 3, len(Approver_Position)))>
		</CFLOOP>
	</CFLOOP>
</CFIF>
</CFIF>


<CFSET Zone_Approver_List = replace(Zone_Approver_List, "ID_", "", "ALL")>
<CFSET Region_Approver_List = replace(Region_Approver_List, "ID_", "", "ALL")>
<CFSET Market_Approver_List = replace(Market_Approver_List, "ID_", "", "ALL")>

<!--- GET THE DISTINCT LIST OF USER POSITIONS --->
<CFSET Position_List = QueryNew("Geographic_Position,Position_ID")>

<CFSET totalrows = listlen(Default_Approver_Position_List)+listlen(Zone_Approver_Position_List)+listlen(Region_Approver_Position_List)+listlen(Market_Approver_Position_List)>
<CFSET temp = QueryAddRow(Position_List,totalrows)>

<CFSET RunningRowNumber = 1>
<CFLOOP INDEX="this_Position_ID" LIST="#Default_Approver_Position_List#">
	<CFSET temp = QuerySetCell(Position_List,"Geographic_Position","GOD",RunningRowNumber)>
	<CFSET temp = QuerySetCell(Position_List,"Position_ID",this_Position_ID,RunningRowNumber)>
	<CFSET RunningRowNumber = RunningRowNumber + 1>
</CFLOOP>

<CFLOOP INDEX="this_Position_ID" LIST="#Zone_Approver_Position_List#">
	<CFSET temp = QuerySetCell(Position_List,"Geographic_Position","ZONE",RunningRowNumber)>
	<CFSET temp = QuerySetCell(Position_List,"Position_ID",this_Position_ID,RunningRowNumber)>
	<CFSET RunningRowNumber = RunningRowNumber + 1>
</CFLOOP>

<CFLOOP INDEX="this_Position_ID" LIST="#Region_Approver_Position_List#">
	<CFSET temp = QuerySetCell(Position_List,"Geographic_Position","REGION",RunningRowNumber)>
	<CFSET temp = QuerySetCell(Position_List,"Position_ID",this_Position_ID,RunningRowNumber)>
	<CFSET RunningRowNumber = RunningRowNumber + 1>
</CFLOOP>

<CFLOOP INDEX="this_Position_ID" LIST="#Market_Approver_Position_List#">
	<CFSET temp = QuerySetCell(Position_List,"Geographic_Position","MARKET",RunningRowNumber)>
	<CFSET temp = QuerySetCell(Position_List,"Position_ID",this_Position_ID,RunningRowNumber)>
	<CFSET RunningRowNumber = RunningRowNumber + 1>
</CFLOOP>

<CFQUERY NAME="GOD_UserPositions" DBTYPE="query">
	SELECT DISTINCT Position_ID, Geographic_Position
	FROM Position_List
	WHERE Geographic_Position = 'GOD'
</CFQUERY>
<CFSET GOD_User_Position_ID_List = ValueList(GOD_UserPositions.Position_ID)>

<CFQUERY NAME="ZONE_UserPositions" DBTYPE="query">
	SELECT DISTINCT Position_ID, Geographic_Position
	FROM Position_List
	WHERE Geographic_Position = 'ZONE'
</CFQUERY>
<CFSET ZONE_User_Position_ID_List = ValueList(ZONE_UserPositions.Position_ID)>

<CFQUERY NAME="REGION_UserPositions" DBTYPE="query">
	SELECT DISTINCT Position_ID, Geographic_Position
	FROM Position_List
	WHERE Geographic_Position = 'REGION'
</CFQUERY>
<CFSET REGION_User_Position_ID_List = ValueList(REGION_UserPositions.Position_ID)>

<CFQUERY NAME="MARKET_UserPositions" DBTYPE="query">
	SELECT DISTINCT Position_ID, Geographic_Position
	FROM Position_List
	WHERE Geographic_Position = 'MARKET'
</CFQUERY>
<CFSET MARKET_User_Position_ID_List = ValueList(MARKET_UserPositions.Position_ID)>


<CFSET Total_User_Positions_ID_List = "">
<!--- GOD --->
<CFIF listlen(GOD_User_Position_ID_List) GT 0>
	<CFSET Total_User_Positions_ID_List = Total_User_Positions_ID_List & GOD_User_Position_ID_List>
</CFIF>
<!--- ZONE --->
<CFIF listlen(ZONE_User_Position_ID_List) GT 0>
	<CFSET Total_User_Positions_ID_List = Total_User_Positions_ID_List & "," & ZONE_User_Position_ID_List>
</CFIF>
<!--- REGION --->
<CFIF listlen(REGION_User_Position_ID_List) GT 0>
	<CFSET Total_User_Positions_ID_List = Total_User_Positions_ID_List & "," & REGION_User_Position_ID_List>
</CFIF>
<!--- MARKET --->
<CFIF listlen(MARKET_User_Position_ID_List) GT 0>
	<CFSET Total_User_Positions_ID_List = Total_User_Positions_ID_List & "," & MARKET_User_Position_ID_List>
</CFIF>
