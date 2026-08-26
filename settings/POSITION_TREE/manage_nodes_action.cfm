<cfset debugMode = 0>

<cfparam name="form.Position_Label_Text" 	default="">
<cfparam name="form.SelectedIDList" 		default="0">
<cfparam name="form.ID" 					default="0">
<cfparam name="form.foundBinder"			default="0">
<cfparam name="form.binderType"				default="0">
<cfparam name="form.binderID"				default="0">
<cfparam name="form.z" 						default="0">
<cfparam name="form.r" 						default="0">
<cfparam name="form.m" 						default="0">
<cfparam name="form.b" 						default="0">
<cfparam name="ERR_MESSAGE"					default="">
<cfparam name="ERR_NUMBER"					default="">
<cfparam name="form.save"					default="">


<cfset dataTier=0>
<cfset The_Owner_ID = 0>
<cfset table_param = "">

<cfif len(form.z) EQ 36>
	<cfset dataTier=1>
	<cfset table_param 	= "REGION">
	<cfset this_A_ID	= form.z>
</cfif>

<cfif len(form.r) EQ 36>
	<cfset dataTier=2>
	<cfset table_param = "MARKET">
	<cfset this_A_ID	= form.r>
</cfif>

<cfif isnumeric(form.m) AND form.m NEQ 0>
	<cfset dataTier=3>
	<cfset table_param = "BROKER">
	<cfset this_A_ID	= form.m>
</cfif>

<cfif len(form.b) EQ 36>
	<cfset dataTier=4>
	<cfset table_param = "DISTRIBUTOR">
	<cfset this_A_ID	= form.b>
</cfif>

<cfif form.foundBinder EQ 1>
	<cfset this_A_ID	= form.SelectedIDList>
</cfif>


<CF_List_Compare List1="#FORM.SelectedIDList#" List2="#FORM.ID#">

<cfif debugMode EQ 1 OR debugMode EQ 2 OR debugMode EQ 3>
	<cfoutput>
	<table border="1">
		<tr>
			<TD>ACTION</TD>
			<td><b>MOVE</b></td>
		</tr>
		<tr>
			<TD>TABLE</TD>
			<td><b>#table_param#</b></td>
		</tr>
		<tr>
			<TD>TABLE_ID</TD>
			<td><b><cfif isdefined("x")>#x#<cfelse>NOT DEFINED</cfif></b></td>
		</tr>
		<tr>
			<TD>A_ID</TD>
			<TD><b><cfif isdefined("this_A_ID")>#this_A_ID#<cfelse>NOT DEFINED</cfif></b></TD>
		</tr>
	</table>
	</cfoutput>
	<cfif debugMode EQ 2>
		<cfabort>
	</cfif>
</cfif>

<CFIF form.foundBinder EQ 0>
	<!--- remove these --->
	<cfif listlen(LC_Results1) GT 0 AND LC_Results1 NEQ 0>
		<cfloop index="x" list="#LC_Results1#">
		
			<cfquery name="qTreeBuilder" datasource="#application.datasource#">
				
				DECLARE
				@ERROR_NUM INT,
				@ERROR_MSG NVARCHAR(100),
				@ERROR_COLUMN NVARCHAR(255)
				
				EXEC tree_builder 'FREE', '#trim(table_param)#', '#trim(x)#', NULL, NULL, NULL, @ERROR_NUM, @ERROR_MSG, @ERROR_COLUMN
			
			</cfquery>
			
			<!---
			<cfstoredproc procedure="tree_builder" datasource="#application.datasource#">
				<cfprocparam type="In" 	cfsqltype="CF_SQL_CHAR" 	dbvarname="ACTION" 		value="FREE" 			maxlength="10" 	null="No">
				<cfprocparam type="In" 	cfsqltype="CF_SQL_CHAR" 	dbvarname="TABLE" 		value="#trim(table_param)#" 	maxlength="11" 	null="No">
				<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	dbvarname="TABLE_ID" 	value="#trim(x)#" 			maxlength="50" 	null="No">
				<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	dbvarname="NUMBER"		value="NULL" 			maxlength="50" 	null="Yes">
				<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	dbvarname="A_ID" 		value="NULL"			maxlength="50" 	null="Yes">
				<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	dbvarname="NAME"		value="NULL"			maxlength="255"	null="Yes">
				
				<cfprocparam type="Out" cfsqltype="CF_SQL_INTEGER" 	dbvarname="ERR_NUMBER" 	variable="ERR_NUMBER"  					null="No">
				<cfprocparam type="Out" cfsqltype="CF_SQL_VARCHAR" 	dbvarname="ERR_MESSAGE" variable="ERR_MESSAGE" 	maxlength="100" null="No">
				<cfprocparam type="Out" cfsqltype="CF_SQL_VARCHAR" 	dbvarname="ERR_COLUMN" 	variable="ERR_COLUMN"  	maxlength="255" null="No">
			</cfstoredproc>
			--->
			<!---Update broker data --->
			
			<!---Get affected brokers --->
			
			<!--- we need to update broker's region and zone only when the region or market si getting updated --->
			<cfif table_param EQ "Zone" or table_param EQ "Region" or table_param EQ "Market">
				
				<cfquery name="UpdateServiceRegionZone" datasource="#application.datasource#">
					if object_id('tempdb..##tmp_brokers') is not null
					drop table ##tmp_brokers
				
					SELECT DISTINCT BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
					INTO	##tmp_brokers
					FROM BSA_Foodservice_Brokers
						INNER JOIN Service_Markets
						ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
						INNER JOIN Service_Regions
						ON Service_Regions.Service_Region_ID = Service_Markets.Service_Region_ID
						INNER JOIN Service_Zones
						ON Service_Zones.Service_Zone_ID = Service_Regions.Service_Zone_ID
					WHERE BSA_Foodservice_Brokers.Deleted = 0
					<CFIF table_param EQ "Zone">AND Service_Regions.Service_Zone_ID = '#x#'</CFIF>
					<CFIF table_param EQ "Region">AND Service_Markets.Service_Region_ID = '#x#'</CFIF>			
					<CFIF table_param EQ "Market">AND Service_Markets.Service_Market_ID = '#x#'</CFIF>
					
					-- update region
					UPDATE BSA_Foodservice_Brokers 
					SET SERVICE_REGION_ID = 
					(SELECT SERVICE_REGION_ID FROM SERVICE_MARKETS 
					WHERE SERVICE_MARKET_ID = bsa_foodservice_brokers.SERVICE_MARKET_ID)
					WHERE service_market_id is not null
					AND BSA_Foodservice_Brokers_ID IN (SELECT BSA_Foodservice_Brokers_ID FROM ##tmp_brokers)
					
					-- update zone
					UPDATE BSA_Foodservice_Brokers 
					SET SERVICE_ZONE_ID = 
					(SELECT SERVICE_ZONE_ID FROM SERVICE_REGIONS 
					WHERE SERVICE_REGION_ID = bsa_foodservice_brokers.SERVICE_REGION_ID)
					WHERE service_market_id is not null
					AND BSA_Foodservice_Brokers_ID IN (SELECT BSA_Foodservice_Brokers_ID FROM ##tmp_brokers)			
								
					drop table ##tmp_brokers
				</cfquery>
			
			</cfif>
		</cfloop>
	</cfif>
	
	<!--- add these --->
	<cfif listlen(LC_Results2) GT 0 AND LC_Results2 NEQ 0>
		<cfloop index="x" list="#LC_Results2#">
		
			<cfquery name="qTreeBuilder" datasource="#application.datasource#">
				
				DECLARE
				@ERROR_NUM INT,
				@ERROR_MSG NVARCHAR(100),
				@ERROR_COLUMN NVARCHAR(255)
				
				EXEC tree_builder 'MOVE', '#trim(table_param)#', '#trim(x)#', NULL, '#trim(this_A_ID)#', NULL, @ERROR_NUM, @ERROR_MSG, @ERROR_COLUMN
			
			</cfquery>
			
			<!---
			<cfstoredproc procedure="tree_builder" datasource="#application.datasource#">
				<cfprocparam type="In" 	cfsqltype="CF_SQL_CHAR" 	dbvarname="ACTION" 		value="MOVE" 			maxlength="10" 	null="No">
				<cfprocparam type="In" 	cfsqltype="CF_SQL_CHAR" 	dbvarname="TABLE" 		value="#trim(table_param)#" 	maxlength="11" 	null="No">
				<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	dbvarname="TABLE_ID" 	value="#trim(x)#" 			maxlength="50" 	null="No">
				<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	dbvarname="NUMBER"		value="NULL" 			maxlength="50" 	null="Yes">
				<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	dbvarname="A_ID" 		value="#trim(this_A_ID)#"		maxlength="50" 	null="No">
				<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	dbvarname="NAME"		value="NULL"			maxlength="255"	null="Yes">
				
				<cfprocparam type="Out" cfsqltype="CF_SQL_INTEGER" 	dbvarname="ERR_NUMBER" 	variable="ERR_NUMBER"  					null="No">
				<cfprocparam type="Out" cfsqltype="CF_SQL_VARCHAR" 	dbvarname="ERR_MESSAGE" variable="ERR_MESSAGE" 	maxlength="100" null="No">
				<cfprocparam type="Out" cfsqltype="CF_SQL_VARCHAR" 	dbvarname="ERR_COLUMN" 	variable="ERR_COLUMN"  	maxlength="255" null="No">
			</cfstoredproc>
			--->
			<!---Update broker data --->
			
			<!---Get affected brokers --->
			
			<!--- we need to update broker's region and zone only when the region or market si getting updated --->
			<cfif table_param EQ "Zone" or table_param EQ "Region" or table_param EQ "Market">
			
				<cfquery name="UpdateServiceRegionZone" datasource="#application.datasource#">
					if object_id('tempdb..##tmp_brokers') is not null
					drop table ##tmp_brokers
				
					SELECT DISTINCT BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
					INTO	##tmp_brokers
					FROM BSA_Foodservice_Brokers
						INNER JOIN Service_Markets
						ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
						INNER JOIN Service_Regions
						ON Service_Regions.Service_Region_ID = Service_Markets.Service_Region_ID
						INNER JOIN Service_Zones
						ON Service_Zones.Service_Zone_ID = Service_Regions.Service_Zone_ID
					WHERE BSA_Foodservice_Brokers.Deleted = 0
					<CFIF table_param EQ "Zone">AND Service_Regions.Service_Zone_ID = '#x#'</CFIF>
					<CFIF table_param EQ "Region">AND Service_Markets.Service_Region_ID = '#x#'</CFIF>			
					<CFIF table_param EQ "Market">AND Service_Markets.Service_Market_ID = '#x#'</CFIF>
					
					-- update region
					UPDATE BSA_Foodservice_Brokers 
					SET SERVICE_REGION_ID = 
					(SELECT SERVICE_REGION_ID FROM SERVICE_MARKETS 
					WHERE SERVICE_MARKET_ID = bsa_foodservice_brokers.SERVICE_MARKET_ID)
					WHERE service_market_id is not null
					AND BSA_Foodservice_Brokers_ID IN (SELECT BSA_Foodservice_Brokers_ID FROM ##tmp_brokers)
					
					-- update zone
					UPDATE BSA_Foodservice_Brokers 
					SET SERVICE_ZONE_ID = 
					(SELECT SERVICE_ZONE_ID FROM SERVICE_REGIONS 
					WHERE SERVICE_REGION_ID = bsa_foodservice_brokers.SERVICE_REGION_ID)
					WHERE service_market_id is not null
					AND BSA_Foodservice_Brokers_ID IN (SELECT BSA_Foodservice_Brokers_ID FROM ##tmp_brokers)			
								
					drop table ##tmp_brokers
				</cfquery>
			
			</cfif>
		</cfloop>
	</cfif>
<cfelse>

	<cfquery name="qTreeBuilder" datasource="#application.datasource#">
		
		DECLARE
		@ERROR_NUM INT,
		@ERROR_MSG NVARCHAR(100),
		@ERROR_COLUMN NVARCHAR(255)
		
		EXEC tree_builder 'REPLACE', '#trim(form.binderType)#', '#trim(binderID)#', NULL, '#trim(this_A_ID)#', NULL, @ERROR_NUM, @ERROR_MSG, @ERROR_COLUMN
	
	</cfquery>

	<!---
	<cfstoredproc procedure="tree_builder" datasource="#application.datasource#">
		<cfprocparam type="In" 	cfsqltype="CF_SQL_CHAR" 	dbvarname="ACTION" 		value="REPLACE" 			maxlength="10" 	null="No">
		<cfprocparam type="In" 	cfsqltype="CF_SQL_CHAR" 	dbvarname="TABLE" 		value="#trim(form.binderType)#" 	maxlength="11" 	null="No">
		<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	dbvarname="TABLE_ID" 	value="#trim(binderID)#" 			maxlength="50" 	null="No">
		<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	dbvarname="NUMBER"		value="NULL" 			maxlength="50" 	null="Yes">
		<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	dbvarname="A_ID" 		value="#trim(this_A_ID)#"		maxlength="50" 	null="No">
		<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	dbvarname="NAME"		value="NULL"			maxlength="255"	null="Yes">
		
		<cfprocparam type="Out" cfsqltype="CF_SQL_INTEGER" 	dbvarname="ERR_NUMBER" 	variable="ERR_NUMBER"  					null="No">
		<cfprocparam type="Out" cfsqltype="CF_SQL_VARCHAR" 	dbvarname="ERR_MESSAGE" variable="ERR_MESSAGE" 	maxlength="100" null="No">
		<cfprocparam type="Out" cfsqltype="CF_SQL_VARCHAR" 	dbvarname="ERR_COLUMN" 	variable="ERR_COLUMN"  	maxlength="255" null="No">
	</cfstoredproc>
	--->
<!---Update broker data --->
			
			<!---Get affected brokers --->
			
			<!--- we need to update broker's region and zone only when the region or market si getting updated --->
			<cfif table_param EQ "Zone" or table_param EQ "Region" or table_param EQ "Market">
			
				<cfquery name="UpdateServiceRegionZone" datasource="#application.datasource#">
					if object_id('tempdb..##tmp_brokers') is not null
					drop table ##tmp_brokers
				
					SELECT DISTINCT BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
					INTO	##tmp_brokers
					FROM BSA_Foodservice_Brokers
						INNER JOIN Service_Markets
						ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
						INNER JOIN Service_Regions
						ON Service_Regions.Service_Region_ID = Service_Markets.Service_Region_ID
						INNER JOIN Service_Zones
						ON Service_Zones.Service_Zone_ID = Service_Regions.Service_Zone_ID
					WHERE BSA_Foodservice_Brokers.Deleted = 0
					<CFIF table_param EQ "Zone">AND Service_Regions.Service_Zone_ID = '#x#'</CFIF>
					<CFIF table_param EQ "Region">AND Service_Markets.Service_Region_ID = '#x#'</CFIF>			
					<CFIF table_param EQ "Market">AND Service_Markets.Service_Market_ID = '#x#'</CFIF>
					
					-- update region
					UPDATE BSA_Foodservice_Brokers 
					SET SERVICE_REGION_ID = 
					(SELECT SERVICE_REGION_ID FROM SERVICE_MARKETS 
					WHERE SERVICE_MARKET_ID = bsa_foodservice_brokers.SERVICE_MARKET_ID)
					WHERE service_market_id is not null
					AND BSA_Foodservice_Brokers_ID IN (SELECT BSA_Foodservice_Brokers_ID FROM ##tmp_brokers)
					
					-- update zone
					UPDATE BSA_Foodservice_Brokers 
					SET SERVICE_ZONE_ID = 
					(SELECT SERVICE_ZONE_ID FROM SERVICE_REGIONS 
					WHERE SERVICE_REGION_ID = bsa_foodservice_brokers.SERVICE_REGION_ID)
					WHERE service_market_id is not null
					AND BSA_Foodservice_Brokers_ID IN (SELECT BSA_Foodservice_Brokers_ID FROM ##tmp_brokers)			
								
					drop table ##tmp_brokers
				</cfquery>
				
			</cfif>
</CFIF> 

<cfset spError.message = ERR_MESSAGE>
<cfset spError.number = ERR_NUMBER>
<cfinclude template="/settings/position_tree/sp_error_code.cfm">

<!--- <cfoutput>#ERR_NUMBER# - #ERR_COLUMN# - #ERR_MESSAGE#</cfoutput> --->
<!--- add these --->


<cfif debugMode EQ 3>
	<cfoutput>
	<table border="1">
		<tr>
			<TD>ERR_NUMBER</TD>
			<td><b>#ERR_NUMBER#</b></td>
		</tr>
		<tr>
			<TD>ERR_MESSAGE</TD>
			<td><b>#ERR_MESSAGE#</b></td>
		</tr>
		<tr>
			<TD>ERR_COLUMN</TD>
			<td><b>#ERR_COLUMN#</b></td>
		</tr>
	</table>
	</cfoutput>
	<cfabort>
</cfif>


<cfif dataTier NEQ 4>
	<cfquery name="checkForExistance" datasource="#application.datasource#">
	SELECT 
		Position_label
	FROM 
		User_Positions
	WHERE 1 = 1
	<cfswitch expression="#dataTier#">
		<cfcase value="0"> <!---hq--->
		AND Service_Zone_ID IS NULL
		AND	Service_Region_ID IS NULL
		AND	Service_Market_ID IS NULL
		</cfcase>
		<cfcase value="1"> <!---zone--->
		AND Service_Zone_ID = '#form.z#'
		AND	Service_Region_ID IS NULL
		AND	Service_Market_ID IS NULL
		</cfcase>
		<cfcase value="2"> <!---region--->
		AND	Service_Region_ID = '#form.r#'
		AND	Service_Market_ID IS NULL
		</cfcase>
		<cfcase value="3"> <!---market--->
		AND	Service_Market_ID = '#form.m#'
		</cfcase>
		<cfdefaultcase> <!--- don't update any record if there is no valid where condition --->
		AND	1 = 2
		</cfdefaultcase>
	</cfswitch>
		AND	DELETED = 0
	</cfquery>
	
	
	<cfif checkForExistance.recordcount EQ 0>
		<CFQUERY NAME="insertLabel" datasource="#application.datasource#">
			INSERT INTO User_Positions
			(
			Position_Label,
			Service_Zone_ID,
			Service_Region_ID,
			Service_Market_ID
			)
			VALUES
			(
			'#FORM.POSITION_LABEL_TEXT#',
			<CFIF form.z EQ 0>NULL<CFELSE>'#form.z#'</CFIF>,
			<CFIF form.r EQ 0>NULL<CFELSE>'#form.r#'</CFIF>,
			<CFIF form.m EQ 0>NULL<CFELSE>'#form.m#'</CFIF>
			)			
		</CFQUERY>	
	<cfelse>
		<CFQUERY NAME="updateLabel" datasource="#application.datasource#">
			UPDATE User_Positions
			SET 
				Position_Label	= '#FORM.POSITION_LABEL_TEXT#',
				Service_Zone_ID = <CFIF form.z EQ 0>NULL<CFELSE>'#form.z#'</CFIF>,
				Service_Region_ID = <CFIF form.r EQ 0>NULL<CFELSE>'#form.r#'</CFIF>,
				Service_Market_ID = <CFIF form.m EQ 0>NULL<CFELSE>'#form.m#'</CFIF>
			WHERE 1 = 1
			<cfswitch expression="#dataTier#">
				<cfcase value="0"> <!---hq--->
				AND Service_Zone_ID IS NULL
				AND	Service_Region_ID IS NULL
				AND	Service_Market_ID IS NULL
				</cfcase>
				<cfcase value="1"> <!---zone--->
				AND Service_Zone_ID = '#form.z#'
				AND	Service_Region_ID IS NULL
				AND	Service_Market_ID IS NULL
				</cfcase>
				<cfcase value="2"> <!---region--->
				AND	Service_Region_ID = '#form.r#'
				AND	Service_Market_ID IS NULL
				</cfcase>
				<cfcase value="3"> <!---market--->
				AND	Service_Market_ID = '#form.m#'
				</cfcase>
				<cfdefaultcase> <!--- don't update any record if there is no valid where condition --->
				AND	1 = 2
				</cfdefaultcase>
			</cfswitch>
				AND	DELETED = 0
		</CFQUERY>	
	</cfif>

</cfif>


<CFQUERY NAME="saveLastUpdate" datasource="#application.datasource#">
	INSERT INTO Zone_Region_Market_Last_Edited_By
	(Users_ID)
	VALUES
	('#request.AccessStructure.user_id#')
</CFQUERY>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title></title>
</head>
<BODY BGCOLOR="WhiteSmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
	<div align="center" id="waitLoad" style="font-weight: bold; color: red; font-size: 20px">please be patient while the tree is rebuilt to reflect your changes...</div>
<cfflush>


<!--- Rebuild XML and reload the parent page --->
<cfif form.save eq "regenerate the tree">
<!--- On "regenerate the tree" being clicked from the "manage_nodes.cfm" page, set the "Zone ID" (form.z) to "0",
			as we want the whole tree to be rebuilt.Passing just the "Zone ID" (form.z) to "buildxml.cfm" will result in 
			only that value being updated --->
<cfset form.z = "0">
	<cfinclude template="buildxml.cfm">

		<script language="javascript">
			window.close();
			opener.location.reload(true);
		</script>

<!--- Just close the new window and let the user add/edit more data on the xml tree --->
<cfelseif form.save eq "save">

		<script language="javascript">
			window.close();
		</script>

</cfif>

</body>
</html>