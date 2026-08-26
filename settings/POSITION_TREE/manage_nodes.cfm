<!------ Get application settings ----->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>

<!--- Tim Ford - Label 19281: Add Business Unit ID to Brokers --->
<cfparam name="variables.businessSegmentsEnabled" default="0" />
<cfset variables.businessSegmentsEnabled = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").isEnabled() />

<cfparam name="url.z" 			default="0">
<cfparam name="url.r" 			default="0">
<cfparam name="url.m" 			default="0">
<cfparam name="url.b" 			default="0">

<cfparam name="url.zone_isbinder"	default="NULL">
<cfparam name="url.region_isbinder" default="NULL">
<cfparam name="url.market_isbinder" default="NULL">
<cfparam name="url.binderType" default="NULL">
<cfparam name="url.binderID" default="NULL">


<cfparam name="SelectedIDList" 	default="">
<cfset inputType = "checkbox">

<cfset name.a_zone 			= "">
<cfset name.b_region 		= "">
<cfset name.c_market 		= "">
<!--- <cfset name.d_broker 		= "">
<cfset name.e_distributor 	= ""> --->

<!--- zone --->
<cfquery name="zone_binders" datasource="#application.datasource#">
	SELECT * 
	FROM user_binder
	WHERE 
	Deleted = 0
	AND
	binder_type = 1
</cfquery>
<cfset zone_binder_list = lcase(valuelist(zone_binders.SERVICE_ID))>

<cfquery name="zone_free" datasource="#application.datasource#">
	SELECT * 
	FROM user_binder
	WHERE 
	Deleted = 0
	AND
	binder_type = 4
</cfquery>
<cfset zone_free_list = lcase(valuelist(zone_free.SERVICE_ID))>


<cfquery name="region_binders" datasource="#application.datasource#">
	SELECT * 
	FROM user_binder
	WHERE 
	Deleted = 0
	AND
	binder_type = 2
</cfquery>
<cfset region_binder_list = lcase(valuelist(region_binders.SERVICE_ID))>

<cfquery name="region_free" datasource="#application.datasource#">
	SELECT * 
	FROM user_binder
	WHERE 
	Deleted = 0
	AND
	binder_type = 5
</cfquery>
<cfset region_free_list = lcase(valuelist(region_free.SERVICE_ID))>

<cfquery name="market_binders" datasource="#application.datasource#">
	SELECT * 
	FROM user_binder
	WHERE
	Deleted = 0
	AND
	binder_type = 3
</cfquery>
<cfset market_binder_list = lcase(valuelist(market_binders.SERVICE_ID))>

<cfquery name="market_free" datasource="#application.datasource#">
	SELECT * 
	FROM user_binder
	WHERE 
	Deleted = 0
	AND
	binder_type = 6
</cfquery>
<cfset market_free_list = lcase(valuelist(market_free.SERVICE_ID))>


<cfif url.z NEQ 0>
	<cfif listfind(zone_binder_list,lcase(url.z)) EQ 0>
		<cfset url.zone_isbinder = 0>
	<cfelse>
		<cfset url.zone_isbinder = 1>
		<cfset url.binderID = lcase(url.z)>
	</cfif>

	<cfquery name="getName" datasource="#application.datasource#">
		SELECT
			Zone_Name AS Name
		FROM
			Service_Zones
		WHERE 
			Service_Zone_ID = '#url.z#'
	</cfquery>
	<cfif getName.recordcount EQ 0>
		<cfset name.a_zone = "Default Name">
	<cfelse>
		<cfif len(getName.Name) GT 0>
			<cfset name.a_zone = getName.Name>
		<cfelse>
			<cfset name.a_zone = "Default Name">
		</cfif>
	</cfif>
</cfif>

<!--- region --->
<cfif url.r NEQ 0>
	
	<cfif listfind(region_binder_list,lcase(url.r)) EQ 0>
		<cfset url.region_isbinder = 0>
	<cfelse>
		<cfset url.region_isbinder = 1>
		<cfset url.binderID = lcase(url.r)>
	</cfif>

	<cfquery name="getName" datasource="#application.datasource#">
		SELECT
			Region_Name AS Name
		FROM
			Service_Regions
		WHERE 
			Service_Region_ID = '#url.r#'
	</cfquery>

	<cfif getName.recordcount EQ 0>
		<cfset name.b_region = "Default Name">
	<cfelse>
		<cfif len(getName.Name) GT 0>
			<cfset name.b_region = getName.Name>
		<cfelse>
			<cfset name.b_region = "Default Name">
		</cfif>
	</cfif>
</cfif>

<!--- market --->
<cfif url.m NEQ 0>

	<cfif listfind(market_binder_list,lcase(url.m)) EQ 0>
		<cfset url.market_isbinder = 0>
	<cfelse>
		<cfset url.market_isbinder = 1>
		<cfset url.binderID = lcase(url.m)>
	</cfif>
	
	<cfquery name="getName" datasource="#application.datasource#">
		SELECT
			Market_Name AS Name
		FROM
			Service_Markets
		WHERE 
			Service_Market_ID = '#url.m#'
	</cfquery>
	<cfif getName.recordcount EQ 0>
		<cfset name.a_market = "Default Name">
	<cfelse>
		<cfif len(getName.Name) GT 0>
			<cfset name.a_market = getName.Name>
		<cfelse>
			<cfset name.a_market = "Default Name">
		</cfif>
	</cfif>
</cfif>


<CFSET allowAccessToPageTree 	= 0>
<CFSET allowAccessToLabel 		= 0>
<CFSET showSaveButton	 		= 0>
<cfset label_access_setting		= 1>


<!--- zone --->
<cfif url.z NEQ 0 AND url.r EQ 0 AND url.m EQ 0 AND url.b EQ 0>
	<cfif application.returned_customer_setting.tree_access_region EQ 1>
		<CFSET allowAccessToPageTree = 1>
	</cfif>
</cfif>
<!--- region --->
<cfif url.z NEQ 0 AND url.r NEQ 0 AND url.m EQ 0 AND url.b EQ 0>
	<cfif application.returned_customer_setting.tree_access_market EQ 1>
		<CFSET allowAccessToPageTree = 1>
	</cfif>
</cfif>
<!--- market --->
<cfif url.z NEQ 0 AND url.r NEQ 0 AND url.m NEQ 0 AND url.b EQ 0>
	<cfif application.returned_customer_setting.tree_access_broker EQ 1>
		<CFSET allowAccessToPageTree = 1>
	</cfif>
</cfif>
<!--- broker --->
<cfif url.z NEQ 0 AND url.r NEQ 0 AND url.m NEQ 0 AND url.b NEQ 0>
	<cfif application.returned_customer_setting.tree_access_distributor EQ 1>
		<CFSET allowAccessToPageTree = 1>
	</cfif>
</cfif>

<cfset dataTier=0>
<cfset The_Owner_ID = 0>
<cfif len(url.z) EQ 36><CFSET thisPositionZone 	= url.z><cfset dataTier=1><cfset The_Owner_ID = url.z><cfelse><CFSET thisPositionZone 	= 0><cfset The_Owner_ID = 0></cfif>
<cfif len(url.r) EQ 36><CFSET thisPositionRegion 	= url.r><cfset dataTier=2><cfset The_Owner_ID = url.r><cfelse><CFSET thisPositionRegion 	= 0></cfif>
<cfif isnumeric(url.m) AND url.m NEQ 0><CFSET thisPositionMarket 	= url.m><cfset dataTier=3><cfset The_Owner_ID = url.m><cfelse><CFSET thisPositionMarket 	= 0></cfif>
<cfif len(url.b) EQ 36><cfset dataTier=4><cfset The_Owner_ID = url.b><cfelse></cfif>

<cfif allowAccessToPageTree EQ 1 OR (dataTier NEQ 4 AND label_access_setting EQ 1)>
	<cfset showSaveButton = 1>
</cfif>

<cfif dataTier NEQ 4 AND label_access_setting EQ 1>
	<cfset allowAccessToLabel = 1>
</cfif>

<!--- ONE OF THE ITEMS MAY BE A BINDER --->
<cfset foundBinder = 0>
<!--- <cfif url.market_isbinder EQ 1>
	<cfset foundBinder = 1>
	<cfset allowAccessToLabel = 0>
	<cfset showSaveButton = 1>
	<cfset dataTier = 2>
	<cfset inputType = "radio">
	<cfset url.binderType = "MARKET">

<cfelseif url.region_isbinder EQ 1>
	<cfset foundBinder = 1>
	<cfset allowAccessToLabel = 0>
	<cfset showSaveButton = 1>
	<cfset dataTier = 1>
	<cfset inputType = "radio">
	<cfset url.binderType = "REGION">
<cfelseif url.zone_isbinder EQ 1>
	<cfset foundBinder = 1>
	<cfset allowAccessToLabel = 0>
	<cfset showSaveButton = 1>
	<cfset dataTier = 5>
	<cfset inputType = "radio">
	<cfset url.binderType = "ZONE">
<cfelse>
	<!--- nuthin' --->
</cfif> --->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Position > Manage Position</title>
	<style type="text/css">
			.labelInput {
				width: 300px;
				border: 1 solid Silver;
			}

			.button {
				border: 0px;
				width: 50;
				color: White;
				font-weight: bold;
				font-size: 12;
				cursor: pointer;
				background : Navy;
			}
</style>
 <SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<script>
	function selectAll(){
		if(window.checkAllProducts != null){
			for(var x=0; x<checkAllProducts.length;x++){
				box = getFirstChild(checkAllProducts[x])
				box.checked = document.MyForm.checkall.checked
			}
		}
	}	
</script>
</head>

<BODY BGCOLOR="WhiteSmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<CFSET pagetitle = "POSITION: MANAGE POSITION">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<p></p>

<cfif dataTier NEQ 4>
	<CFINCLUDE TEMPLATE="/settings/get_position_label.cfm">
	<CFSET for_Position_Label = thisPositionLabelText>
</cfif>

<form action="manage_nodes_action.cfm" method="post" name="MyForm" id="MyForm">

<cfif showSaveButton EQ 0>
<div align="center" style="font-family: Arial, Helvetica, sans-serif; color: red; font-weight: bold;">You do not have access to this resource. Please contact the system administrator if you feel this is in error.</div>
</cfif>

<div>
	<div style="color: navy; font-weight: bold;">
		<cfloop index="x" list="#structkeylist(name)#">
			<cfif len(evaluate("name.#x#")) GT 0><cfoutput>#evaluate("name.#x#")#</cfoutput> / </cfif>
		</cfloop>

	<cfif allowAccessToLabel EQ 1>
	Position Label:</div>
		<input class="labelInput" type="Text" name="Position_Label_Text" value="<cfoutput>#for_Position_Label#</cfoutput>"><cfelse>Branch Node</cfif>&nbsp;&nbsp;
	<cfif showSaveButton EQ 1>
<!--- Do not change the submit button name here. Let it be "save" for both the buttons.
			This name and their respective values are being used in buildxml.cfm for "saving" OR "regenerating the tree" --->
		<input type="submit" name="save" value="save" class="button"> 
		<input type="submit" name="save" value="regenerate the tree" class="button" style="width:130">	
		<hr align="left" width="400" color="navy" style="height: 1px;">
	</cfif>
</div>

<cfif dataTier NEQ 4 and isdefined("checkForPositionLabel")>
<cfif len(trim(checkForPositionLabel.User_Positions_ID)) GT 0 >
<cfquery name="GetUsersInPosition" datasource="#application.datasource#">
SELECT Name_First, Name_Last, User_Code, User_Position_Type FROM _Users
	INNER JOIN User_Position_Holders
	ON User_Position_Holders.User_ID = _Users.User_ID
	AND User_Position_Holders.Deleted = 0
	INNER JOIN User_Positions
	ON User_Position_Holders.User_Positions_ID = User_Positions.User_Positions_ID
	AND User_Positions.User_Positions_ID = #checkForPositionLabel.User_Positions_ID#
	<!---Don't show BSA users --->
	<cfif appSettings.getHide_BSA_Users() IS 1 AND request.AccessStructure.User_Rights_ID NEQ 9999>
	AND (_Users.User_Rights_ID IS NULL 
	OR _Users.User_Rights_ID != 9999)
	</cfif>
WHERE _Users.Deleted = 0
ORDER BY User_Position_Type, Name_Last, Name_First

</cfquery>


<CFSCRIPT>
	Border="Yes";
	BorderSize=0;  
	BorderColor="";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy"; 
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="Yes";  
	WIDTH="100%";
</CFSCRIPT>

&nbsp;&nbsp;<img src="/images/plus3.gif">
&nbsp;<a href="##" onClick='NewWindow("show_programs_for_position.cfm?Creating_User_position_ID=<cfoutput>#URLEncodedFormat(checkForPositionLabel.User_Positions_ID)#</cfoutput>", "programswindow", 800, 600, "yes", "yes")'><span style='font-weight:bold;font-size:12px;color:navy;text-decoration:none;'>Show Programs in this Position</span></a>
<br/>

<cfif GetUsersInPosition.Recordcount GT 0>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Hide Users in this Position"  
	TitleClosed="Show Users in this Position"  
	TitleTooltip="Click here to toggle the view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#"
	layerid="1234">
	

<table border="0" cellpadding="2" cellspacing="0">
<tr><td><strong>User Name</strong></td><td><strong>User Code</strong></td><td><strong>Primary or secondary</strong></td></tr>
<cfoutput query="GetUsersInPosition">
	<tr>
		<td>#Name_First# #Name_Last#</td>
		<td>#User_Code#</td>
		<td><cfif trim(User_Position_Type) IS "P">Primary<cfelse>Secondary</cfif></td>
	</tr>
</cfoutput>
</table>

</cf_openLayer>
</cfif>
</cfif>
</cfif>

<BR>
<hr align="left" width="400" color="navy" style="height: 1px;">

<cfif allowAccessToPageTree EQ 1>
	<cfif dataTier NEQ 0>
	<cfquery name="theQuery" datasource="#application.datasource#">
	<!--- <cfquery name="theQuery" datasource="#application.datasource#" cachedwithin="#CreateTimeSpan(1, 0, 0, 0)#"> --->
		SELECT
			<cfswitch expression="#dataTier#">
				<cfcase value="5">Zone_Name</cfcase>
				<cfcase value="1">Region_Name</cfcase>
				<cfcase value="2">Market_Name</cfcase>
				<cfcase value="3">Broker_Name</cfcase>
				<cfcase value="4">Name</cfcase>
			</cfswitch>
			AS name,
			<cfswitch expression="#dataTier#">
				<cfcase value="5">Service_Zone_ID</cfcase>
				<cfcase value="1">Service_Region_ID</cfcase>
				<cfcase value="2">Service_Market_ID</cfcase>
				<cfcase value="3">BSA_Foodservice_Brokers_ID</cfcase>
				<cfcase value="4">BSA_Foodservice_Customers_ID</cfcase>
			</cfswitch>
			AS ID,
            <!--- Brad Testing... [begin] D15578 --->
            <cfswitch expression="#dataTier#">
				<cfcase value="5">Zone_Number</cfcase>
				<cfcase value="1">Region_Number</cfcase>
				<cfcase value="2">Market_Number</cfcase>
				<cfcase value="3">CASE WHEN Broker_Shard <> '' THEN Broker_Shard WHEN City <> '' AND State <> '' THEN rTrim(City) + ', ' + State + ' ' + lTrim(Zip) ELSE Broker_CSR END</cfcase>
				<cfcase value="4">CASE WHEN ship_to <> '' or shr_ship_to <> '' THEN ship_to + ' / ' + shr_ship_to WHEN City <> '' AND State <> '' THEN rTrim(City) + ', ' + State + ' ' + lTrim(ZipCode) ELSE CustID_Name END</cfcase>
			</cfswitch>
			AS Display_Identifier,
            <!--- <cfswitch expression="#dataTier#">
				<cfcase value="1,2,3,5" delimiters=",">Source_System_CD</cfcase>
                <cfcase value="4">Customer_ID</cfcase>
			</cfswitch>
			AS Display_ID, --->
            <!--- Brad Testing... [end] D15578 --->
			<cfswitch expression="#dataTier#">
				<cfcase value="5">0</cfcase>
				<cfcase value="1">Service_Zone_ID</cfcase>
				<cfcase value="2">Service_Region_ID</cfcase>
				<cfcase value="3">cast(Service_Market_ID as nvarchar(50))</cfcase>
				<cfcase value="4">BSA_Foodservice_Brokers_ID</cfcase>
			</cfswitch>
			AS Owner_ID
			<!--- Tim Ford - Label 19281: Add Business Unit ID to Brokers --->
			<cfif variables.businessSegmentsEnabled eq 1 and dataTier eq 3>
			, ISNULL(Business_Segment.Business_Unit_ID, 'None') AS Business_Unit_ID
			</cfif>
		FROM
			<cfswitch expression="#dataTier#">
				<cfcase value="5">Service_Zones</cfcase>
				<cfcase value="1">Service_Regions</cfcase>
				<cfcase value="2">Service_Markets</cfcase>
				<cfcase value="3">
					BSA_Foodservice_Brokers
					<!--- Tim Ford - Label 19281: Add Business Unit ID to Brokers --->
					<cfif variables.businessSegmentsEnabled eq 1>
						LEFT JOIN Business_Segment ON
						Business_Segment.Business_Segment_ID = BSA_Foodservice_Brokers.Business_Segment_ID AND
						Business_Segment.Deleted = 0
					</cfif>
				</cfcase>
				<cfcase value="4">BSA_Foodservice_Customers</cfcase>
			</cfswitch>
		WHERE 
			(
			<cfswitch expression="#dataTier#">
				<cfcase value="5">1=1</cfcase>
				<cfcase value="1">Service_Zone_ID = '#The_Owner_ID#' OR Service_Zone_ID IS NULL <cfif listlen(zone_free_list) GT 0>OR Service_Zone_ID IN(#listqualify(zone_free_list, "'")#)</cfif></cfcase>
				<cfcase value="2">Service_Region_ID = '#The_Owner_ID#' OR Service_Region_ID IS NULL <cfif listlen(region_free_list) gt 0>OR Service_Region_ID IN(#listqualify(region_free_list, "'")#)</cfif></cfcase>
				<cfcase value="3">Service_Market_ID = '#The_Owner_ID#' OR Service_Market_ID IS NULL</cfcase>
				<cfcase value="4">
					(BSA_Foodservice_Brokers_ID = '#The_Owner_ID#' OR BSA_Foodservice_Brokers_ID IS NULL)
					<!---Tim Ford - Label 41073: Dist Pitco not in User Position Tree Detail:
					Also check the Market_Distributor table if the getDistributorMultiPosition() application setting is on
					--->
					<cfif appSettings.getDistributorMultiPosition()>
					OR (BSA_Foodservice_Customers_ID IN (SELECT Distributor_ID FROM Market_Distributor WHERE Service_Market_ID = #url.m# and Deleted = 0))
					</cfif>
				</cfcase>
			</cfswitch>
			)
			AND
			<cfswitch expression="#dataTier#">
				<cfcase value="5">
					Deleted = 0 
					<cfif listlen(zone_binder_list) GT 0>
						AND Service_Zone_ID NOT IN(select service_id FROM user_binder WHERE Deleted = 0 AND binder_type = 1)
					</cfif>
				</cfcase>
				
				<cfcase value="1">
					Deleted = 0
					
					<cfif listlen(region_binder_list) GT 0>
						AND Service_Region_ID NOT IN(select service_id FROM user_binder WHERE Deleted = 0 AND binder_type = 2)
					</cfif> 
					
					<cfif listlen(region_free_list) GT 0>
						AND Service_region_ID NOT IN(select service_id FROM user_binder WHERE Deleted = 0 AND binder_type = 5)
					</cfif>

				</cfcase>
				<cfcase value="2">
					Deleted = 0
					
					<cfif listlen(market_binder_list) GT 0>
						AND Service_Market_ID  NOT IN (select service_id FROM user_binder WHERE Deleted = 0 AND binder_type = 3)
					</cfif>
					
					<cfif listlen(market_free_list) GT 0>
						AND Service_Market_ID NOT IN(select service_id FROM user_binder WHERE Deleted = 0 AND binder_type = 6)
					</cfif>
				</cfcase>
				<cfcase value="3">Active_Code = 'A'</cfcase>
				<cfcase value="4">Active_Code = 'A'</cfcase>
			</cfswitch>
		AND
		<cfif lcase(trim(inputType)) EQ "radio">
			<cfswitch expression="#dataTier#">
				<cfcase value="5">Service_Zone_ID NOT IN(SELECT DISTINCT Service_Zone_ID FROM Service_Regions WHERE Deleted = 0 AND Service_Zone_ID IS NOT NULL)</cfcase>
				<cfcase value="1">Service_Region_ID NOT IN(SELECT DISTINCT Service_Region_ID FROM Service_Markets WHERE Deleted = 0 AND Service_Region_ID IS NOT NULL)</cfcase>
				<cfcase value="3">Service_Market_ID IS NULL</cfcase>
				<cfdefaultcase>1=1</cfdefaultcase>
			</cfswitch>
		<cfelse>
		1=1
		</cfif>
		AND
		<!--- Tim Ford - Label 19281: Add Business Unit ID to Brokers --->
		<cfif variables.businessSegmentsEnabled eq 1 and dataTier eq 3>
			BSA_Foodservice_Brokers.Deleted = 0
		<cfelse>
			Deleted = 0
		</cfif>
		ORDER BY Name
	</cfquery>
	
	<cfif foundBinder EQ 0>
		<cfquery name="getSelectedIDS" dbtype="query">
			SELECT ID
			FROM theQuery
			WHERE Owner_ID = '#The_Owner_ID#'
		</cfquery>
		<cfset SelectedIDList = valuelist(getSelectedIDS.ID)>
	<cfelse>
		<cfset SelectedIDList = "">
	</cfif>
	
	</cfif>
	<!--- <cfdump var="#theQuery#">	
	<cfdump var="#getSelectedIDS#">	 --->
	
	<!--- <h1>Tier - <cfoutput>#The_Owner_ID#</cfoutput></h1> --->
	
	<cfif dataTier NEQ 0>
	<cfoutput>
	<TABLE CLASS="Maintable" WIDTH="50%" CELLPADDING="3" CELLSPACING="0">
		<TR BGCOLOR="##FFCE84" VALIGN="bottom">
			<td><cfif foundBinder EQ 0><input TYPE="checkbox" NAME="checkall" ONCLICK="selectAll()"><cfelse>&nbsp;</cfif></td>
			<cfswitch expression="#dataTier#">
				<!--- zone --->
				<cfcase value="5">
					<TD ID="header"><b>#application.returned_customer_setting.zone_label_plural#</b></TD>
				</cfcase>
				<cfcase value="1">
					<TD ID="header"><b>#application.returned_customer_setting.region_label_plural#</b></TD>
				</cfcase>
				<!--- region --->
				<cfcase value="2">
					<TD ID="header"><b>#application.returned_customer_setting.market_label_plural#</b></TD>
				</cfcase>
				<!--- market --->
				<cfcase value="3">
					<TD ID="header"><b>#application.returned_customer_setting.broker_label_plural#</b></TD>
				</cfcase>
				<!--- broker --->
				<cfcase value="4">
					<TD ID="header"><b>#application.returned_customer_setting.distributor_label_plural#</b></TD>
				</cfcase>
			</cfswitch>		
		</tr>
		<cfloop query="theQuery">
		<cfoutput>
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<TD><span ID="checkAllProducts"><input name="ID" type="#inputType#" value="#theQuery.id#" <cfif The_Owner_ID EQ theQuery.owner_id> CHECKED</cfif>></span></TD>
			<TD>
				#theQuery.name# (#theQuery.Display_Identifier#)
				<!--- Tim Ford - Label 19281: Add Business Unit ID to Brokers --->
				<cfif variables.businessSegmentsEnabled eq 1 and dataTier eq 3>
					&nbsp;(#appSettings.getbusiness_segment_label()# - #Business_Unit_ID#)
				</cfif>
			</TD>
		</tr>
		</cfoutput>
		</cfloop>
	</table>
	</cfoutput>
	</cfif>
</cfif><!--- end access switch --->

<cfoutput>
	<input type="Hidden" name="z" value="#url.z#">
	<input type="Hidden" name="r" value="#url.r#">
	<input type="Hidden" name="m" value="#url.m#">
	<input type="Hidden" name="b" value="#url.b#">
	<input type="Hidden" name="foundBinder" value="#foundBinder#">
	<input type="Hidden" name="binderType" value="#url.binderType#">
	<input type="Hidden" name="binderID" value="#url.binderID#">
	
	<input type="Hidden" name="SelectedIDList" value="#SelectedIDList#">
</cfoutput>
</form>

</body>
</html>
