<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\ajax\Customer_PG_Query.cfm
	Created:	3/7/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USED TO MAKE AJAX CALLS TO DB FOR PRODUCT PLANNING GROUPS
	Usage:
		SETTING>>ADMINISTRATOR>>PLANNING GROUPS. TAB TYPE
---->
<cfparam name="Edit"				default="0">
<cfparam name="Activate" 			default="0">
<cfparam name="Deactivate" 			default="0">
<cfparam name="Copy" 				default="0">
<cfparam name="Delete" 				default="0">
<cfparam name="Info" 				default="0">
<cfparam name="MultiDeActivate"		default="0">
<cfparam name="ID"					default="">
<cfparam name="MultiActivate"   	default="0">
<cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() /> 
<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />

<style>
	.tr{ 
	 	background-color:#7FCDFE;
		color:white;
	}
	.td{ 
		font-size:11px;
		font-family:Arial;
		font-weight: bold;
		}
	.td_nobold{ 
		font-size:11px;
		font-family:Arial;
		}
	.header{ 
	 	font-size:12px;
		background-color:#736F6E;
		width:750px;
		color:white;
		padding-top:5px;
		padding-bottom:5px;
		padding-left:5px;
		font-weight:bold;
	}
</style>
<cfif len(ID)>
	<cfquery name="qryGetPGTypeByID" datasource="#application.datasource#" >
		    SELECT	DISTINCT
			PGT.PG_Type_ID,
			PGT.PG_Type_Code,
	        PGT.PG_Type_Name,
	        PGT.PG_Group_Type, 
			PGT.Is_System  
	        FROM	PG_Type PGT
	        LEFT JOIN PG_Product_Category PGPC 
	        ON		PGPC.Pg_Type_ID = PGT.PG_Type_ID 
	        AND		PGPC.Active = 1 
	        AND		PGPC.Deleted = 0
	        LEFT JOIN PG_Customer_Category PGCC 
	        ON		PGCC.Pg_Type_ID = PGT.PG_Type_ID 
	        AND		PGCC.Active = 1 
	        AND		PGCC.Deleted = 0
	        LEFT JOIN PG_Operator_Category PGOC 
	        ON		PGOC.PG_Type_ID = PGT.PG_Type_ID 
	        AND		PGOC.Active = 1 
	        AND		PGOC.Deleted = 0
	        WHERE	PGT.Active = #url.active# 
	        AND		PGT.Deleted = 0
			AND     PGT.PG_Type_ID = #trim(url.id)#
	</cfquery>
</cfif>

<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- *******************************************MULTI DEACTIVATE PLANNING GROUP START*********************************************** --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<cfif MultiDeActivate>
<cfoutput>
	
	<cfif len(selectedvalue)>
	<table border="0" style="height:168px;width:586px;background-color:##D0D0D0;">
		<tr>
			<td style="font-size:14px;text-align:center">Do you really want to <span style="font-weight:bold;">DEACTIVATE</span> selected planning group(s)?</td>
		</tr>
		<tr>
			<td style="font-size:14px;color:black;" align="center">
				<a href="##" onclick="deactivated('#selectedvalue#');ColdFusion.Window.hide('EditPlanningGroup');">#application.util.string.actionLinkFormat("ok")#</a>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<a href="##" onclick="ColdFusion.Window.hide('EditPlanningGroup')">#application.util.string.actionLinkFormat("cancel")#</a>
			</td>
		</tr>
	</table>
	<cfelse>
	<table border="0" style="height:168px;width:586px;background-color:##D0D0D0;">
		<tr>
			<td width="150" style="margin-top:50px;" align="right"><img src="/images/event.png"></td>
			<td style="font-size:14px;color:black;" align="left">
			You haven't selected <b>any</b> type of planning groups.
			</td> 
		</tr>
	</table>
	</cfif>
	
</cfoutput>	
</cfif>
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- *******************************************MULTI DEACTIVATE PLANNING GROUP START*********************************************** --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->

<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- *******************************************MULTI ACTIVATE PLANNING GROUP START************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<cfif MultiActivate>
<cfoutput>
	<cfif len(selectedvalue)>
	<table border="0" style="height:168px;width:586px;background-color:##D0D0D0;">
		<tr>
			<td style="font-size:14px;text-align:center">Do you really want to <span style="font-weight:bold;">ACTIVATE</span> selected planning group(s)?</td>
		</tr>
		<tr>
			<td style="font-size:14px;color:black;" align="center">
				<a href="##" onclick="activated('#selectedvalue#');ColdFusion.Window.hide('EditPlanningGroup');">#application.util.string.actionLinkFormat("ok")#</a>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<a href="##" onclick="ColdFusion.Window.hide('EditPlanningGroup')">#application.util.string.actionLinkFormat("cancel")#</a>
			</td>
		</tr>
	</table>
	<cfelse>
	<table border="0" style="height:168px;width:586px;background-color:##D0D0D0;">
		<tr>
			<td width="150" style="margin-top:50px;" align="right"><img src="/images/event.png"></td>
			<td style="font-size:14px;color:black;" align="left">
			You haven't selected <b>any</b> type of planning groups.
			</td> 
		</tr>
	</table>
	</cfif>
</cfoutput>		
</cfif>
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- *******************************************MULTI ACTIVATE PLANNING GROUP START************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->


<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- *******************************************DEACTIVATE PLANNING GROUP START***************************************************** --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<cfif Deactivate>
<!--- <cfset memberscheck = PGManager.TypeMembers(PGTypeID =#url.id# , PGGroup =#url.group#)> --->
	<cfoutput>
			<!--- <cfif memberscheck.RecordCount EQ 0> --->
				<table border="0" style="height:168px;width:586px;background-color:##D0D0D0;">
					<tr>
						<td align="center" style="font-size:14px;">
							<span style="font-weight:bold;">PG Code:</span> #qryGetPGTypeByID.PG_Type_Code# 
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<span style=";font-weight:bold;">PG Name:</span> #qryGetPGTypeByID.PG_Type_Name#
						</td>
					</tr>
					<tr>
						<td style="font-size:14px;text-align:center">Do you really want to <span style="font-weight:bold;">DEACTIVATE</span> this planning group?</td>
					</tr>
					<tr>
						<td style="font-size:14px;color:white;" align="center">
							<a href="##" onclick="deactivated('#id#');ColdFusion.Window.hide('EditPlanningGroup');">#application.util.string.actionLinkFormat("ok")#</a>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<a href="##" onclick="ColdFusion.Window.hide('EditPlanningGroup')">#application.util.string.actionLinkFormat("cancel")#</a>
						</td>
					</tr>
				</table>
			<!--- <cfelse>
				
				<table border="0" style="background-color:##D0D0D0;height:168px;width:586px;">
					<tr>
						<td style="margin-top:50px;" rowspan="2"><img src="/images/event.png"></td>
						<td style="margin-top:50px;font-size:14px;color:black;" valign="bottom">
							<span style="font-weight:bold;">PG Code:</span> #qryGetPGTypeByID.PG_Type_Code# 
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<span style=";font-weight:bold;">PG Name:</span> #qryGetPGTypeByID.PG_Type_Name#<br>
							
						</td>
					</tr>
					<tr>
						<td style="margin-top:50px;font-size:14px;color:black;" valign="top">You can't <b>DEACTIVATE</b> this Planning Group as members are associated with it.</td>
					</tr>
				</table> 
				
			</cfif> --->
	</cfoutput>

</cfif>
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- ********************************************DEACTIVATE PLANNING GROUP END****************************************************** --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->

<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- *******************************************ACTIVATE PLANNING GROUP START***************************************************** --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<cfif Activate>
	<cfoutput>

				<table border="0" style="height:168px;width:586px;background-color:##D0D0D0;">
					<tr>
						<td align="center" style="font-size:14px;">
							<span style="font-weight:bold;">PG Code:</span> #qryGetPGTypeByID.PG_Type_Code# 
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<span style=";font-weight:bold;">PG Name:</span> #qryGetPGTypeByID.PG_Type_Name#
						</td>
					</tr>
					<tr>
						<td style="font-size:14px;text-align:center">Do you want to <span style="font-weight:bold;">ACTIVATE</span> this planning group?</td>
					</tr>
					<tr>
						<td style="font-size:14px;color:white;" align="center">
							<a href="##" onclick="activated('#id#');ColdFusion.Window.hide('EditPlanningGroup');">#application.util.string.actionLinkFormat("ok")#</a>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<a href="##" onclick="ColdFusion.Window.hide('EditPlanningGroup')">#application.util.string.actionLinkFormat("cancel")#</a>
						</td>
					</tr>
				</table>

  </cfoutput>
</cfif>
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- ********************************************ACTIVATE PLANNING GROUP END****************************************************** --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->

<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- ********************************************COPY PLANNING GROUP START********************************************************** --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<cfif Copy>
<cfoutput>

				<table border="0" style="height:168px;width:586px;background-color:##D0D0D0;">
					<tr>
						<td align="center" style="font-size:14px;">
							<span style="font-weight:bold;">PG Code:</span> #qryGetPGTypeByID.PG_Type_Code# 
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<span style=";font-weight:bold;">PG Name:</span> #qryGetPGTypeByID.PG_Type_Name#
						</td>
					</tr>
					<tr>
						<td style="font-size:14px;text-align:center">Do you really want to <span style="font-weight:bold;">COPY</span> this planning group?</td>
					</tr>
					<tr>
						<td style="font-size:14px;color:white;" align="center">
							<a href="##" onclick="CopySelProdRecs('#qryGetPGTypeByID.PG_Product_Category_ID#', 'Product', 'ACTIVE');ColdFusion.Window.hide('EditPlanningGroup');">#application.util.string.actionLinkFormat("ok")#</a>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<a href="##" onclick="ColdFusion.Window.hide('EditPlanningGroup')">#application.util.string.actionLinkFormat("cancel")#</a>
						</td>
					</tr>
				</table>

  </cfoutput>
</cfif>
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- ********************************************COPY PLANNING GROUP END************************************************************ --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->

<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- ********************************************DELETE PLANNING GROUP START******************************************************** --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<cfif Delete>
	<cfoutput>

				<table border="0" style="height:168px;width:586px;background-color:##D0D0D0;">
					<tr>
						<td align="center" style="font-size:14px;">
							<span style="font-weight:bold;">PG Code:</span> #qryGetPGTypeByID.PG_Type_Code# 
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<span style=";font-weight:bold;">PG Name:</span> #qryGetPGTypeByID.PG_Type_Name#
						</td>
					</tr>
					<tr>
						<td style="font-size:14px;text-align:center">Do you really want to <span style="font-weight:bold;">DELETE</span> this planning group?</td>
					</tr>
					<tr>
						<td style="font-size:14px;color:white;" align="center">
							<a href="##" onclick="deleted('#id#');ColdFusion.Window.hide('EditPlanningGroup');">#application.util.string.actionLinkFormat("ok")#</a>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<a href="##" onclick="ColdFusion.Window.hide('EditPlanningGroup')">#application.util.string.actionLinkFormat("cancel")#</a>
						</td>
					</tr>
				</table>

  </cfoutput>
</cfif>	
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- ********************************************DELETE PLANNING GROUP END********************************************************** --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->


<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- **********************************************INFO PLANNING GROUP END********************************************************** --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<cfif Info>


<cfset bind = "cfc:components.settings.PlanningGroups.PlanningGroupsManager.TypeGroupInfo({cfgridpage},{cfgridpagesize},{cfgridsortcolumn},{cfgridsortdirection},getSearchString(),'#id#', '#Group#')">
<cfoutput>
	<div style="width:100%; margin:5px;font-size:14px;">
		<div style="width:48%;float:left;">&nbsp;&nbsp;&nbsp;<b>PG Code:</b> #qryGetPGTypeByID.PG_Type_Code#</div> 
		<div style="width:48%;float:right;text-align:right;"><b>PG Name:</b> #qryGetPGTypeByID.PG_Type_Name#</div>
	</div>
	   	<cfset args 						= structNew()>
	    <cfset args.name 					= "Type_Group_Info">
	    <cfset args.format 					= "html">
	    <cfset args.bind 					= "#bind#">
	    <cfset args.pagesize 				= "21">
	    <cfset args.selectmode 				= "row">
	    <cfset args.appendKey 				= "no">
		<cfset args.stripeRows				= "yes"> 
		<cfset args.colHeaderBold  			= "yes"> 
	    <cfset args.colHeaderFontSize 		= "12">
	    <cfset args.width			 		= "775">
		<cfset args.height					= "538">
		<cfset args.selectOnLoad			= "no"> 
		<cfset args.fontsize				= "12">
</cfoutput>

&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" id="filter" name="filter" value=""> 
<input type="submit" id="search" name="search" value="Search" onclick="ColdFusion.Grid.refresh('Type_Group_Info', false);"/>

<div align="center">
<cfform method="post" name="TypeInfo"> 
	<cfgrid attributeCollection="#args#">  
 	 	<cfgridcolumn name = "PG_Type_ID" 						header = "PG Code" 			Select="No" 	width="100"		headerBold="yes">
 	 	<cfgridcolumn name = "PG_Name" 							header = "PG Name" 			Select="No" 	width="250"		headerBold="yes">
 	 	<cfgridcolumn name = "Include_In_Other_PG" 				header = "Include/Exclude" 	Select="No" 	width="100"		headerBold="yes">
 	</cfgrid>  
</cfform> 
</div>

</cfif>
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- **********************************************INFO PLANNING GROUP END********************************************************** --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
