<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\ajax\Customer_PG_Query.cfm
	Created:	3/7/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USED TO MAKE AJAX CALLS TO DB FOR PRODUCT PLANNING GROUPS
	Usage:
		SETTING>>ADMINISTRATOR>>PLANNING GROUPS. TAB PRODCUT
---->
<cfparam name="Edit"												default="0">
<cfparam name="Activate" 										default="0">
<cfparam name="Deactivate" 								default="0">
<cfparam name="Copy" 											default="0">
<cfparam name="Delete" 											default="0">
<cfparam name="Info" 												default="0">
<cfparam name="MultiDeActivate"						default="0">
<cfparam name="ID"													default="">
<cfparam name="MultiActivate"   							default="0">
<cfparam name="NodeletePG"   							default="0">
<cfparam name="NoDeleteReasonListForPG"   	default="">
<cfparam name="fileExistStatus"   							default="0">
<cfparam name="System" 											default="0">

<cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() /> 
<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset isBusinessSegEnabledForDistributor = businessSegManager.isEnabledForDistributor()>
<cfset isBusinessSegEnabledForProduct = businessSegManager.isEnabledForProduct() /> 
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

	<!--- This query name is the "cfprocresult name" below. It is being used in "pg_all_write_data_to_file.cfm" --->
	<cfset QryPGCategoryDefinitionByID = "qryGetPGProductCategoryByID">

	<cfstoredproc procedure="Get_Product_Group_Info_For_PG" datasource="#application.datasource#">
	  	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@PG_Product_Category_ID" value = "#ID#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Keyword" value = "" null="no">		
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderByField" value="Group_Name" null="no">			  
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@OrderBy" value="ASC" null="no">		
	    <cfprocresult name="#QryPGCategoryDefinitionByID#">
	</cfstoredproc>

	<cfset ProductInfo = PGManager.fnGetPGProductCategoryByID('#id#')>
	
	<cfset entityType ="products">

	<!--- 1 is for product --->
	<cfset planningGroupType = 1>
	
	<!--- Write to an excel file --->
	<cfinclude template="pg_all_write_data_to_file.cfm">
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
	
	<cfoutput>
			<!--- <cfif qryGetPGProductCategoryByID.RecordCount EQ 0> --->
				<table border="0" style="height:168px;width:586px;background-color:##D0D0D0;">
					<tr>
						<td align="center" style="font-size:14px;">
							<span style="font-weight:bold;">PG Code:</span> #ProductInfo.PG_Product_Category_Code# 
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<span style=";font-weight:bold;">PG Name:</span> #ProductInfo.PG_Product_Category_Name#
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
							<span style="font-weight:bold;">PG Code:</span> #ProductInfo.PG_Product_Category_Code# 
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<span style=";font-weight:bold;">PG Name:</span> #ProductInfo.PG_Product_Category_Name#<br>
							
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
							<span style="font-weight:bold;">PG Code:</span> #ProductInfo.PG_Product_Category_Code# 
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<span style=";font-weight:bold;">PG Name:</span> #ProductInfo.PG_Product_Category_Name#
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
<!---  D37056 No Members Found - TEST JEN & FSD All Distributors START --->	
		<cfoutput>
					<cfif System>
								<table border="0" style="height:168px;width:586px;background-color:##D0D0D0;">
									<tr>
										<td colspan="2" align="center" style="font-size:14px;font-weight:bold;">System planning groups cannot be copied.</td>
									</tr>
								</table>
					<cfelse>	
								<cfif type>
										<cfset type = 'ACTIVE'>
								<cfelse>
										<cfset type = 'INACTIVE'>
								</cfif>
								<table border="0" style="height:168px;width:586px;background-color:##D0D0D0;">
									<tr>
										<td align="center" style="font-size:14px;">
										<span style="font-weight:bold;">PG Code:</span> #ProductInfo.PG_Product_Category_Code# 
										&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
										<span style="font-weight:bold;">PG Name:</span> #ProductInfo.PG_Product_Category_Name#
										</td>
									</tr>
									<tr>
										<td style="font-size:14px;text-align:center">Do you really want to <span style="font-weight:bold;">COPY</span> this planning group?</td>
									</tr>
									<tr>
										<td style="font-size:14px;color:white;" align="center">
										<a href="##" onclick="CopySelProdRecs('#ProductInfo.PG_Product_Category_ID#', 'Product', '#type#');ColdFusion.Window.hide('EditPlanningGroup');">#application.util.string.actionLinkFormat("ok")#</a>
										&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
										<a href="##" onclick="ColdFusion.Window.hide('EditPlanningGroup')">#application.util.string.actionLinkFormat("cancel")#</a>
										</td>
									</tr>
								</table>				
					</cfif>
		</cfoutput>	
<!---  D37056 No Members Found - TEST JEN & FSD All Distributors END --->
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
			<cfif qryGetPGProductCategoryByID.RecordCount EQ 0 AND NodeletePG EQ 0>
				<table border="0" style="height:168px;width:586px;background-color:##D0D0D0;">
					<tr>
						<td align="center" style="font-size:14px;">
							<span style="font-weight:bold;">PG Code:</span> #ProductInfo.PG_Product_Category_Code# 
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<span style=";font-weight:bold;">PG Name:</span> #ProductInfo.PG_Product_Category_Name#
						</td>
					</tr>
					<tr>
						<td style="font-size:14px;text-align:center">Do you really want to <span style="font-weight:bold;">DELETE</span> this planning group?</td>
					</tr>
					<tr>
						<td style="font-size:14px;color:white;" align="center">
							<a href="##" onclick="deleted('#id#');ColdFusion.Window.hide('EditPlanningGroup');">#application.util.string.actionLinkFormat("ok")#</a>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<a href="##" onclick="ColdFusion.Window.hide('EditPlanningGroup');">#application.util.string.actionLinkFormat("cancel")#</a>
						</td>
					</tr>
				</table>
			<cfelse>
				
				<table border="0" style="background-color:##D0D0D0;height:168px;width:586px;">
					<tr>
						<td style="margin-top:50px;" rowspan="2"><img src="/images/event.png"></td>
						<td style="margin-top:50px;font-size:14px;color:black;" valign="bottom">
							<span style="font-weight:bold;">PG Code:</span> #ProductInfo.PG_Product_Category_Code# 
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<span style=";font-weight:bold;">PG Name:</span> #ProductInfo.PG_Product_Category_Name#<br>
							
						</td>
					</tr>
					<tr>
						<td style="margin-top:50px;font-size:14px;color:black;" valign="top">
							You can't <b>DELETE</b>  this Planning Group due to the following reason(s): <br /> #NoDeleteReasonListForPG#.
						</td>
					</tr>
					<!--- If the excel file exists, then show the "download" link --->
					<cfif fileExistStatus eq 1>
					<tr>
						<td valign="top" colspan="100%">
						For details, please click on the "download" link:
							<A href="#application.HTTPVar##CGI.server_name#/GetDocument.cfm?FilePath=Temp_Files/Documents/Temp_Uploaded_Doc/#file_name#" onclick="NewWindow(this.href,'PGName','800','600','Yes', 'No');return false;" TITLE="Click on this link to view this file">#application.util.string.actionLinkFormat("download")#</A>
						</td>
					</tr>
					</cfif>
				</table> 
				
			</cfif>
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

<cfset bind = "cfc:components.settings.PlanningGroups.PlanningGroupsManager.ProductGroupInfo({cfgridpage},{cfgridpagesize},{cfgridsortcolumn},{cfgridsortdirection},getSearchString(),'#id#')">
<cfoutput>
	<div style="width:100%; margin:5px;font-size:14px;">
		<div style="width:48%;float:left;">&nbsp;&nbsp;&nbsp;<b>PG Code:</b> #ProductInfo.PG_Product_Category_Code#</div> 
		<div style="width:48%;float:right;text-align:right;"><b>PG Name:</b> #ProductInfo.PG_Product_Category_Name#</div>
	</div>
	   	<cfset args 						= structNew()>
	    <cfset args.name 					= "Product_Group_Info">
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
<input type="submit" id="search" name="search" value="Search" onclick="ColdFusion.Grid.refresh('Product_Group_Info', false);"/>

<div align="center">
<cfform method="post" name="ProductInfo"> 
	<cfgrid attributeCollection="#args#">  
 	 	<cfgridcolumn name = "Group_Desc" 				header = "Group/#application.returned_customer_setting.Item_Label# Description" 	Select="No" 	width="100"		headerBold="yes">
 	 	<cfgridcolumn name = "Group_Number" 			header = "Group/#application.returned_customer_setting.Item_Label# Number" 			Select="No" 	width="150"		headerBold="yes">
 	 	<cfgridcolumn name = "Group_Name" 				header = "Group/#application.returned_customer_setting.Item_Label# Name" 			Select="No" 	width="300"		headerBold="yes">
 	 	<cfgridcolumn name = "Inclusion_Exclusion" 		header = "Include/Exclude" 															Select="No" 	width="100"		headerBold="yes">
	 	<cfif isBusinessSegEnabledForProduct>
 	 	<cfgridcolumn name = "Business_Unit_Desc" 		header = "#appsettings.Business_Segment_Label#" 									Select="No" 	width="100"		headerBold="yes">
	 	</cfif>
 	</cfgrid>  
</cfform> 
</div>
</cfif>
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
<!--- **********************************************INFO PLANNING GROUP END********************************************************** --->
<!--- ******************************************************************************************************************************* --->
<!--- ******************************************************************************************************************************* --->
