<!DOCTYPE html>
<cfsilent>
<!-----------------------------------------------------------------------------
FILE NAME:		dspViewMicroMembers.cfm
DESCRIPTION:
CREATED BY:		02-Dec-2010
MODIFICATION HISTORY:
BY					DATE					DESCRIPTION OF CHANGE
Anand Rao	  10-Aug-2010	Created the file
Dinesh R		  08-June-2015  Modified code to use jQuery & Export Functionality
------------------------------------------------------------------------------>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="/actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->
<cfif NOT (isDefined("URL.Group_ID") AND isDefined("URL.PGType"))><br>
	<br>
	<table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="0"  align="center" width="700">
	      <tr>
	        <td align="center">
	          <cfoutput>
	    	      <font size="2" color="red"><b>Error! Required Parameters Missing!!</b></font>
	          </cfoutput>
	        </td>
	      </tr>
	    </table>
	<cfabort>
</cfif>
</cfsilent>
<html>
<head>
	<title>View Micro Members</title>
	<style>
		th { text-align: left; }
	</style>
	<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
</head>
<body>

<cfparam name="URL.hideExport" default="0">
<cfset GroupID = URL.Group_ID />
<cfset PGType = URL.PGType />

<cfif PGType EQ "1">    <!--- product ( item ) --->
	<cfset isBusinessSegEnabledForProduct = businessSegManager.isEnabledForProduct() />

	<cfquery name="qryMicoMembersIncludeList" datasource="#application.datasource#">
		SELECT 	 	PG_Product_Category.PG_Product_Category_ID,
					PG_Product_Category.PG_Product_Category_Code,
					PG_Product_Category.PG_Product_Category_Name,
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					BSA_Foodservice_Items_Master.Item,
					BSA_Foodservice_Items_Master.Description,
					BSA_Foodservice_Items_Master.Active_Code
					<cfif isBusinessSegEnabledForProduct eq 1>
					,Bus_Seg.Business_Unit_Desc
					</cfif>
					,PG_Product_Category_Definition.PG_Effective_Start_Date
					,PG_Product_Category_Definition.PG_Effective_End_Date
		FROM	PG_Product_Members
		INNER JOIN PG_Product_Category
		ON		PG_Product_Category.PG_Product_Category_ID = PG_Product_Members.PG_Product_Category_ID
		INNER JOIN BSA_Foodservice_Items_Master
		ON		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = PG_Product_Members.BSA_Foodservice_Items_Master_ID
		INNER JOIN PG_Product_Category_Definition
		ON		PG_Product_Category_Definition.PG_Product_Category_ID = PG_Product_Members.PG_Product_Category_ID
				AND PG_Product_Category_Definition.Deleted = 0
		INNER JOIN dbo.Group_Members ON Group_Members.Product_Group_ID = PG_Product_Category_Definition.Product_Group_ID
					AND Group_Members.BSA_Foodservice_Items_Master_ID = PG_Product_Members.BSA_Foodservice_Items_Master_ID
		<cfif isBusinessSegEnabledForProduct eq 1>
		left JOIN Business_Segment Bus_Seg
		ON Bus_Seg.Business_Segment_ID = BSA_Foodservice_Items_Master.Business_Segment_ID
		</cfif>
		WHERE PG_Product_Members.PG_Product_Category_ID IN ('#GroupID#')
		AND PG_Product_Members.Deleted = 0
	UNION
		SELECT PG_Product_Category.PG_Product_Category_ID,
					PG_Product_Category.PG_Product_Category_Code,
					PG_Product_Category.PG_Product_Category_Name,
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					BSA_Foodservice_Items_Master.Item,
					BSA_Foodservice_Items_Master.Description,
					BSA_Foodservice_Items_Master.Active_Code
 					<cfif isBusinessSegEnabledForProduct eq 1>
					,Bus_Seg.Business_Unit_Desc
					</cfif>
					,PG_Product_Category_Definition.PG_Effective_Start_Date
					,PG_Product_Category_Definition.PG_Effective_End_Date
		FROM	PG_Product_Members
		INNER JOIN PG_Product_Category
		ON		PG_Product_Category.PG_Product_Category_ID = PG_Product_Members.PG_Product_Category_ID
		INNER JOIN BSA_Foodservice_Items_Master
		ON		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = PG_Product_Members.BSA_Foodservice_Items_Master_ID
 		INNER JOIN PG_Product_Category_Definition ON
		PG_Product_Category_Definition.Product_Group_ID = PG_Product_Members.BSA_Foodservice_Items_Master_ID
		AND PG_Product_Category_Definition.PG_Product_Category_ID = PG_Product_Members.PG_Product_Category_ID
		AND PG_Product_Category_Definition.Product_Group_Level_ID = 0
		<cfif isBusinessSegEnabledForProduct eq 1>
		left JOIN Business_Segment Bus_Seg
		ON Bus_Seg.Business_Segment_ID = BSA_Foodservice_Items_Master.Business_Segment_ID
		</cfif>
  		WHERE PG_Product_Members.PG_Product_Category_ID IN ('#GroupID#')
		AND PG_Product_Members.Deleted = 0
		AND  PG_Product_Category_Definition.Deleted = 0
		<cfif (appSettings.get_Setting('PG_Eff_Date_Product') eq '1')>
			AND PG_Product_Category_Definition.PG_Effective_Start_Date IS NOT NULL
			AND PG_Product_Category_Definition.PG_Effective_End_Date IS NOT NULL
		</cfif>
	</cfquery>
<cfelseif PGType EQ "2">     <!--- distributor ( customer ) --->
	<cfset isBusinessSegEnabledForDistributor = businessSegManager.isEnabledForDistributor()>

    <cfquery name="qryMicoMembersIncludeList" datasource="#application.datasource#">
      SELECT PG_Customer_Category.PG_Customer_Category_ID,
				PG_Customer_Category.PG_Customer_Category_Code,
				PG_Customer_Category.PG_Customer_Category_Name,
				BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
				BSA_Foodservice_Customers.Shr_Ship_to,
				BSA_Foodservice_Customers.Ship_to,
				BSA_Foodservice_Customers.Name,
				BSA_Foodservice_Customers.Active_Code
				<cfif isBusinessSegEnabledForDistributor eq 1>
				,Bus_Seg.Business_Unit_Desc
				</cfif>
				,PG_Customer_Category_Definition.PG_Effective_Start_Date
				,PG_Customer_Category_Definition.PG_Effective_End_Date
		FROM 	PG_Customer_Members
		INNER JOIN PG_Customer_Category
		ON		PG_Customer_Category.PG_Customer_Category_ID = PG_Customer_Members.PG_Customer_Category_ID
		INNER JOIN BSA_Foodservice_Customers
		ON		BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = PG_Customer_Members.BSA_Foodservice_Customers_ID
		INNER JOIN PG_Customer_Category_Definition
		ON		PG_Customer_Category_Definition.PG_Customer_Category_ID = PG_Customer_Members.PG_Customer_Category_ID
				AND PG_Customer_Category_Definition.Deleted = 0
		LEFT JOIN Customer_Group_Members ON CAST(Customer_Group_Members.Customer_Group_ID AS VARCHAR(50)) = PG_Customer_Category_Definition.Distributor_Group_ID
		AND Customer_Group_Members.BSA_Foodservice_Customers_ID = PG_Customer_Members.BSA_Foodservice_Customers_ID
		AND PG_Customer_Category_Definition.Distributor_Group_Level_ID <> 0
		<cfif isBusinessSegEnabledForDistributor eq 1>
		left JOIN Business_Segment Bus_Seg
		ON Bus_Seg.Business_Segment_ID = BSA_Foodservice_Customers.Business_Segment_ID
		</cfif>
		WHERE PG_Customer_Members.PG_Customer_Category_ID IN ('#GroupID#')
		AND PG_Customer_Members.Deleted = 0
		/* -- Zone, region, market, broker will not have entry in Customer_Group_Members */
		AND (PG_Customer_Category_Definition.Distributor_Group_Level_ID in (23, 24, 25, 26) OR Customer_Group_Members.Customer_Group_Members_ID IS NOT NULL)
	UNION

	SELECT 	 PG_Customer_Category.PG_Customer_Category_ID,
				PG_Customer_Category.PG_Customer_Category_Code,
				PG_Customer_Category.PG_Customer_Category_Name,
				BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
				BSA_Foodservice_Customers.Shr_Ship_to,
				BSA_Foodservice_Customers.Ship_to,
				BSA_Foodservice_Customers.Name,
				BSA_Foodservice_Customers.Active_Code
				<cfif isBusinessSegEnabledForDistributor eq 1>
				,Bus_Seg.Business_Unit_Desc
				</cfif>
				,PG_Customer_Category_Definition.PG_Effective_Start_Date
				,PG_Customer_Category_Definition.PG_Effective_End_Date
		FROM 	PG_Customer_Members
		INNER JOIN PG_Customer_Category
		ON		PG_Customer_Category.PG_Customer_Category_ID = PG_Customer_Members.PG_Customer_Category_ID
		INNER JOIN BSA_Foodservice_Customers
		ON		BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = PG_Customer_Members.BSA_Foodservice_Customers_ID
		INNER JOIN PG_Customer_Category_Definition
		ON		PG_Customer_Category_Definition.Distributor_Group_ID = PG_Customer_Members.BSA_Foodservice_Customers_ID
		AND PG_Customer_Category_Definition.PG_Customer_Category_ID = PG_Customer_Members.PG_Customer_Category_ID
				AND PG_Customer_Category_Definition.Distributor_Group_Level_ID = 0
		<cfif isBusinessSegEnabledForDistributor eq 1>
		left JOIN Business_Segment Bus_Seg
		ON Bus_Seg.Business_Segment_ID = BSA_Foodservice_Customers.Business_Segment_ID
		</cfif>
		WHERE PG_Customer_Members.PG_Customer_Category_ID IN ('#GroupID#')
		AND PG_Customer_Category_Definition.Deleted = 0
		<cfif (appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1')>
			AND PG_Customer_Members.Deleted = 0
			AND PG_Customer_Category_Definition.PG_Effective_Start_Date IS NOT NULL
			AND PG_Customer_Category_Definition.PG_Effective_End_Date IS NOT NULL
		</cfif>
    </cfquery>
<cfelseif PGType EQ "3"> <!--- Operator --->
	<cfset isBusinessSegEnabledForOperator = businessSegManager.isEnabledForOperator()>

	<cfquery name="qryMicoMembersIncludeList" datasource="#application.datasource#">
		SELECT DISTINCT PG_Operator_Category.PG_Operator_Category_ID,
					PG_Operator_Category.PG_Operator_Category_Code,
					PG_Operator_Category.PG_Operator_Category_Name,
					BSA_Operator.BSA_Operator_ID,
					BSA_Operator.Legacy_ID,
					BSA_Operator.Display_Code,
					BSA_Operator.Operator_Name
					<cfif isBusinessSegEnabledForOperator eq 1>
					,Bus_Seg.Business_Unit_Desc
					</cfif>
					,PG_Operator_Category_Definition.PG_Effective_Start_Date
					,PG_Operator_Category_Definition.PG_Effective_End_Date
		FROM 	PG_Operator_Members
		INNER JOIN PG_Operator_Category
		ON		PG_Operator_Category.PG_Operator_Category_ID = PG_Operator_Members.PG_Operator_Category_ID
		INNER JOIN BSA_Operator
		ON		BSA_Operator.BSA_Operator_ID = PG_Operator_Members.BSA_Operator_ID
		INNER JOIN PG_Operator_Category_Definition
		ON
		PG_Operator_Category_Definition.PG_Operator_Category_ID = PG_Operator_Members.PG_Operator_Category_ID AND
		PG_Operator_Category_Definition.Operator_Group_ID = PG_Operator_Members.BSA_Operator_ID
		AND PG_Operator_Category_Definition.Deleted = 0
		<cfif isBusinessSegEnabledForOperator eq 1>
		LEFT JOIN Business_Segment Bus_Seg
		ON Bus_Seg.Business_Segment_ID = BSA_Operator.Business_Segment_ID
		</cfif>
		WHERE PG_Operator_Members.PG_Operator_Category_ID IN ('#GroupID#')
		<cfif (appSettings.get_Setting('PG_Eff_Date_Operator') eq '1')>
		AND PG_Operator_Members.Deleted = 0
		AND PG_Operator_Category_Definition.PG_Effective_Start_Date IS NOT NULL
    	AND PG_Operator_Category_Definition.PG_Effective_End_Date IS NOT NULL
		</cfif>
    </cfquery>
</cfif>

<cfset businessSegmentEnabled = 0>
<cfif ((PGType EQ "1" AND isBusinessSegEnabledForProduct EQ 1) OR (PGType EQ "2" AND isBusinessSegEnabledForDistributor EQ 1) OR (PGType EQ "3" AND isBusinessSegEnabledForOperator EQ 1))>
	<cfset businessSegmentEnabled = 1>
</cfif>

<cfset filename="noData">
<cfoutput>
	<table width="100%">
		<tr>
			<td align="left">
				<cfif PGType EQ 1>
					#qryMicoMembersIncludeList.PG_Product_Category_Name# <cfif (qryMicoMembersIncludeList.PG_Product_Category_Code NEQ "")>(#qryMicoMembersIncludeList.PG_Product_Category_Code#)</cfif>
				<cfset filename=trim(qryMicoMembersIncludeList.PG_Product_Category_Name)>
				<cfelseif PGType EQ 2>
					#qryMicoMembersIncludeList.PG_Customer_Category_Name# <cfif (qryMicoMembersIncludeList.PG_Customer_Category_Code NEQ "")>(#qryMicoMembersIncludeList.PG_Customer_Category_Code#)</cfif>
				<cfset filename=trim(qryMicoMembersIncludeList.PG_Customer_Category_Name)>
				<cfelseif PGType EQ 3>
					#qryMicoMembersIncludeList.PG_Operator_Category_Name# <cfif (qryMicoMembersIncludeList.PG_Operator_Category_Code NEQ "")>(#qryMicoMembersIncludeList.PG_Operator_Category_Code#)</cfif>
				<cfset filename=trim(qryMicoMembersIncludeList.PG_Operator_Category_Name)>
				</cfif> has the following Members included.
			</td>
			<cfif url.hideExport eq 0>
			<td align="right">
				<a href="javascript:getCSVData()" style="margin-left:10px">#LCase(ActionText("export members"))#</a>
			</td>
			</cfif>
		</tr>
	</table>
	<!--- data table grid --->
	<cfif PGType EQ 1 AND appSettings.get_Setting('Display_Item_No') eq ''>
		<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1'>
			<cfset variables.columnSizes = [.75, 4, 1, 1, 1, 1]>
		<cfelse>
			<cfset variables.columnSizes = [1, 5, 2, 1]>
		</cfif>
	<cfelse>
		 <cfif ((appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1' AND PGType EQ 2) OR
					  (appSettings.get_Setting('PG_Eff_Date_Operator') eq '1' AND PGType EQ 3))
			>
			<cfset variables.columnSizes = [.6, 1.5, 3, .6, 1.25, 1.25]>
		<cfelse>
			<cfset variables.columnSizes = [1, 2.5, 5, 1]>
		</cfif>
	</cfif>

	<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes )>
	
	<table class="datagrid" ><!--- Overlapping data issue was fixed by removing this:style='table-layout:fixed;width:100%;' --->
		<cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
			<cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
		</cfloop>
		<thead>
			<tr>
				<th>No</th>
			<cfif PGType EQ 1 AND appSettings.get_Setting('Display_Item_No') eq '1'>
				<th>Item</th>
			<cfelseif PGType EQ 2>
				<th>#application.returned_customer_setting.distributor_label_singular# Number</th>
			<cfelseif PGType EQ 3>
				<th>#application.returned_customer_setting.Operator_label_singular# Number</th>
			</cfif>
				<th><cfif PGType EQ 1>Description<cfelseif PGType EQ 2>#application.returned_customer_setting.distributor_label_singular# Name<cfelseif PGType EQ 3>#application.returned_customer_setting.Operator_label_singular# Name</cfif></th>
			<cfif businessSegmentEnabled>
				<th>#appsettings.Business_Segment_Label#</th>
			</cfif>
				<th>Act</th>
			 <cfif ((appSettings.get_Setting('PG_Eff_Date_Product') eq '1' AND PGType EQ 1) OR
					  (appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1' AND PGType EQ 2) OR
					  (appSettings.get_Setting('PG_Eff_Date_Operator') eq '1' AND PGType EQ 3))
				>
				<th><nobr>Start Date</nobr></th>
				<th><nobr>End Date</nobr></th>
			</cfif>
			</tr>
		</thead>


		<tbody>
			<cfloop query="qryMicoMembersIncludeList" >
				<tr>
					<td class="csvExclude">#currentrow#</td>
				<cfif PGType EQ 1 AND appSettings.get_Setting('Display_Item_No') eq '1'>
					<td>#Item#</td>
				<cfelseif PGType EQ 2>
					<cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>
						<td>#shr_ship_to#</td>
					<cfelse>
						<td>#ship_to#</td>
					</cfif>
				<cfelseif PGType EQ 3>
					<td>#Legacy_ID#</td>
				</cfif>
					<td><cfif PGType EQ 1>#Description#<cfelseif PGType EQ 2>#Name#<cfelseif PGType EQ 3>#Operator_Name#</cfif> </td>
				<cfif businessSegmentEnabled>
					<td>#Business_Unit_Desc#</td>
				</cfif>
					<td><cfif PGType EQ 1 OR PGType EQ 2>#Active_code#<cfelseif PGType EQ 3>#Display_Code#</cfif></td>
				<cfif ((appSettings.get_Setting('PG_Eff_Date_Product') eq '1' AND PGType EQ 1) OR
					  (appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1' AND PGType EQ 2) OR
					  (appSettings.get_Setting('PG_Eff_Date_Operator') eq '1' AND PGType EQ 3))
				>
					<td>#DateFormat(PG_Effective_Start_Date,'mm/dd/yyyy')#</td>
					<td>#DateFormat(PG_Effective_End_Date,'mm/dd/yyyy')#</td>
				</cfif>
				</tr>
			</cfloop>
		</tbody>
	</table>
 </cfoutput>
 <form action="/common_files/csv.cfm" method ="post" id="csv_form">
  <input type="hidden" name="csv_text" id="csv_text">
  <input type="hidden" name="csv_file_name" id="csv_file_name">
</form>

<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/table2csv.js?w=49465"></script>
<script>
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .55) * windowHeight;
oTable = $('.datagrid').dataTable( {
	"bAutoWidth": false
	,"bPaginate": false
	,"bSortClasses": false
	,"bScrollCollapse": true
	,"sDom": 'fti'
	,"sScrollY": "700px"
    , "aoColumns": [
    					<cfif (PGType EQ 1 AND appSettings.get_Setting('Display_Item_No') eq '1') OR (PGType NEQ 1)>
							{"bSearchable": false,  "bSortable":true},
    					</cfif>
	                    	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
						<cfif businessSegmentEnabled>
						,	{"bSearchable": true, 	"bSortable":true}
						</cfif>
	                    ,	{"bSearchable": false, 	"bSortable":true}
						<cfif ((appSettings.get_Setting('PG_Eff_Date_Product') eq '1' AND PGType EQ 1) OR
					  (appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1' AND PGType EQ 2) OR
					  (appSettings.get_Setting('PG_Eff_Date_Operator') eq '1' AND PGType EQ 3))
				>
						,	{"bSearchable": false, 	"bSortable":true}
						,	{"bSearchable": false, 	"bSortable":true}
						</cfif>
	                 ]
} ).fnSetFilteringDelay();
<!--------------------------------------------------------------------------------------------------------------------->
getCSVData = function() {
	 var csv_value = $('table.datagrid').table2CSV();
	 $("#csv_file_name").val("<cfoutput>#filename#</cfoutput>" + '.csv');
	 $("#csv_text").val(csv_value);
	 $("#csv_form").submit();
}
</script>


</body>
</html>
