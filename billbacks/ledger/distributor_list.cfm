<!---
Document Name:	distributor_list.cfm
Directory:		billbacks/ledger
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	January 10, 2002

Displays only the distributors for already selected programs

--->

<cfset appSettings = application.appSettingsGet>

<cfparam name="FORM.SortBy" 	default="Name">
<cfparam name="FORM.SortOrder" 	default="asc">

<cfset SortBy = form.SortBy>
<cfset SortOrder = form.SortOrder>

<cfparam name="FORM.StartRow" 	default="1">
<cfparam name="FORM.frompage" 	default="1">
<CFSET StartRow = FORM.StartRow>
<CFSET frompage = FORM.frompage>
<cf_Number_of_Rows maxrows=12>

<cfparam name="locationfrom" default="/billbacks/ledger/index.cfm">
<cfif locationfrom IS "auto">
	<cfset locationfrom = "/billbacks/ledger/auto_checkbook/add_edit.cfm">
</cfif>

<html><head><Title><cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput></TITLE></head><body STYLE="margin:0; border: 0px orange solid; background-color:transparent" allowTransparency="true">

<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<CFFLUSH>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<!---All Parameters--->
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="">
<CFPARAM NAME="ProgramList" DEFAULT="">
<cfset ProgramList = url.ProgramList>

<!---Get list of distributors this user can see--->

<cfset useLakebaseForgetUserPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForgetUserPosition>
	<cftry>
		<cfset getUserPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserPosition>
<CFQUERY NAME="getUserPosition" DATASOURCE="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>
</cfif>
<CFSET GP_Supplied_Position = getUserPosition.User_Positions_ID>
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">
<cfset bAllDistributorProgram = CreateObject("component", "components.programs.distributors.DistributorGroupManager").isAllDistributorProgram(ProgramList)>

<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegEnabled = businessSegManager.isEnabled()>

<!------ Get application settings ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>


<cfquery name="AllAvailableDistributors" datasource="#application.datasource#">
SELECT	dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, 	
		dbo.BSA_Foodservice_Customers.Name, 
        dbo.BSA_Foodservice_Customers.Address_1, 
		dbo.BSA_Foodservice_Customers.City, 
		dbo.BSA_Foodservice_Customers.State, 
        dbo.BSA_Foodservice_Customers.ZipCode, 
		dbo.Distributor_Family.Family_Name, 
		dbo.BSA_Foodservice_Customers.Ship_To, 
        dbo.BSA_Foodservice_Customers.Active_Code,
		<cfif NOT appSettings.getDistributorMultiPosition()>
		dbo.BSA_Foodservice_Brokers.Broker_Name, 		
		dbo.Service_Zones.Zone_Name, 
        dbo.Service_Regions.Region_Name, 
		</cfif>
		dbo.Distributor_Buying_Groups.Buying_Group_Name,  
		dbo.BSA_Foodservice_Customers.Shr_Ship_To
FROM    dbo.BSA_Foodservice_Customers 
	INNER JOIN Contract_Main
		ON
		Contract_Main.Deleted = 0
		AND
		Contract_Main.Contract_Main_ID = #ProgramList#
		<cfif businessSegEnabled>
		AND
		<cfif application.returned_customer_setting.customer_keyword IS "conagra">
		(
			Contract_Main.Business_Segment_ID = BSA_Foodservice_Customers.Business_Segment_ID
			OR
			(Contract_Main.Business_Segment_ID = 5 AND BSA_Foodservice_Customers.Business_Segment_ID = 1)
		)
		<cfelse>				
		Contract_Main.Business_Segment_ID = BSA_Foodservice_Customers.Business_Segment_ID		
		</cfif>
		</cfif>
	INNER JOIN
        dbo.Distributor_Family 
		ON dbo.BSA_Foodservice_Customers.Family_ID = dbo.Distributor_Family.Family_ID 
	INNER JOIN
        dbo.Distributor_Buying_Groups 
		ON dbo.BSA_Foodservice_Customers.Buying_Group_ID =
		   dbo.Distributor_Buying_Groups.Buying_Group_ID 
	INNER JOIN
        dbo.Line_Of_Business 
		ON dbo.BSA_Foodservice_Customers.Line_Of_Business_ID =
		   dbo.Line_Of_Business.Line_Of_Business_ID 
	<cfif NOT appSettings.getDistributorMultiPosition()>
	INNER JOIN
        dbo.BSA_Foodservice_Brokers 
		ON dbo.BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID =
		   dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID 	
	INNER JOIN
        dbo.Service_Regions 
		ON dbo.BSA_Foodservice_Brokers.Service_Region_ID =
		   dbo.Service_Regions.Service_Region_ID 
	INNER JOIN
        dbo.Service_Zones 
		ON dbo.BSA_Foodservice_Brokers.Service_Zone_ID = 
		   dbo.Service_Zones.Service_Zone_ID
	</cfif>
WHERE 0 = 0 
<cfif NOT bAllDistributorProgram>
AND 	dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN
		(
		SELECT BSA_Foodservice_Customers_ID 
		FROM Contract_Distributors
		WHERE Contract_Main_ID = #ProgramList#
		AND Deleted = 0
		)
</cfif>
AND dbo.BSA_Foodservice_Customers.DELETED = 0
AND dbo.BSA_Foodservice_Customers.Active_Code = 'A'
ORDER BY #SortBy# #SortOrder#
</cfquery>

<cfset AvailableDistributors = listqualify(valuelist(AllAvailableDistributors.BSA_Foodservice_Customers_ID), chr(39))>



<!---Javascript to submit this--->

	<cfoutput>
		<SCRIPT>
			function confirmApproval() 
			{
				
				var oForm = document.all.SubmitDistributor;
				oForm.action = "#LocationFrom#";
				oForm.target = "_parent";
				oForm.submit();
				return false;
			}
			function setSort(sSortBy, sSortOrder)
			{
				var oForm = document.all.SubmitDistributor;
				oForm.SortBy.value = sSortBy;
				oForm.SortOrder.value = sSortOrder;
				oForm.submit();
				return false;
			}
		</SCRIPT>
		</cfoutput>
		
		<!-- </FORM> -->

<!---Display results--->


<!--- <strong>There <CFIF AllAvailableDistributors.recordcount EQ 1>Is <CFELSE>Are </CFIF><CFOUTPUT>  #AllAvailableDistributors.recordcount#</CFOUTPUT>
<CFIF AllAvailableDistributors.recordcount EQ 1>Distributor<CFELSE>Distributors</CFIF> </strong>  --->

<BR>


<CFSET FORM.AlreadySelectedItems = "">
<CFIF AllAvailableDistributors.recordcount GT 0>
	<cfoutput>
	<form name="SubmitDistributor" action="/billbacks/ledger/distributor_list.cfm?ProgramList=#ProgramList#" method="post">
	<TABLE border="0" cellspacing="0" cellpadding="0" align="center" WIDTH="100%" CLASS="Maintable">
		<TR ID="header" BGCOLOR="ffce84">
			<td HEIGHT="25">&nbsp; </td>
			<TD align="left" ID="header">
			<B><a onclick="javaScript: return setSort('BSA_Foodservice_Customers.Name', '<cfif SortBy IS "Name" AND SortOrder IS "asc">desc<cfelse>asc</cfif>');" href="##">Name 
			<cfif SortBy IS "BSA_Foodservice_Customers.Name" AND SortOrder IS "asc"><img src="/images/down_1.gif" border="0"><cfelseif SortBy IS "BSA_Foodservice_Customers.Name" AND SortOrder IS "desc"><img src="/images/up_1.gif" border="0"></cfif></a></B>
			</TD>
			<TD align="left" ID="header"><B>
			<a onclick="javaScript: return setSort('BSA_Foodservice_Customers.State', '<cfif SortBy IS "BSA_Foodservice_Customers.State" AND SortOrder IS "asc">desc<cfelse>asc</cfif>');" href="##">Address 
			<cfif SortBy IS "BSA_Foodservice_Customers.State" AND SortOrder IS "asc"><img src="/images/down_1.gif" border="0"><cfelseif SortBy IS "BSA_Foodservice_Customers.State" AND SortOrder IS "desc"><img src="/images/up_1.gif" border="0"></cfif></a></B> (State)
			</TD>
			<cfif NOT appSettings.getDistributorMultiPosition()>
			<TD ID="header"><B>
			<a  onclick="javaScript: return setSort('BSA_Foodservice_Brokers.Broker_Name', '<cfif SortBy IS "BSA_Foodservice_Brokers.Broker_Name" AND SortOrder IS "asc">desc<cfelse>asc</cfif>');" href="##">Broker 
			<cfif SortBy IS "BSA_Foodservice_Brokers.Broker_Name" AND SortOrder IS "asc"><img src="/images/down_1.gif" border="0"><cfelseif SortBy IS "BSA_Foodservice_Brokers.Broker_Name" AND SortOrder IS "desc"><img src="/images/up_1.gif" border="0"></cfif></a></B>
			</TD>
			</cfif>
		</TR>
	</cfoutput>
	<CFOUTPUT QUERY="AllAvailableDistributors" startrow="#StartRow#" maxrows="#MaxRows#">
		<TR STYLE="cursor:pointer;" <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
			<TD align="center">
			<Cfif appSettings.getUse_AccrualLog_For_TC() IS 1>
			<!--- You can only make a multi selection by using the accrual log--->
			<INPUT type="checkbox" NAME="FinalDistributorList" VALUE="#trim(AllAvailableDistributors.BSA_Foodservice_Customers_ID)#" <CFIF listfind(FORM.FinalItemList, trim(AllAvailableDistributors.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(AllAvailableDistributors.BSA_Foodservice_Customers_ID), ",")></CFIF> >
		<cfelse>
		<INPUT type="Radio" NAME="FinalDistributorList" VALUE="#trim(AllAvailableDistributors.BSA_Foodservice_Customers_ID)#" <CFIF listfind(FORM.FinalItemList, trim(AllAvailableDistributors.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(AllAvailableDistributors.BSA_Foodservice_Customers_ID), ",")></CFIF> onClick="confirmApproval()">
</cfif>
			</TD>
			<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#AllAvailableDistributors.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" NOWRAP>
			#AllAvailableDistributors.Name#<BR>#AllAvailableDistributors.Shr_Ship_To#&nbsp;
			</TD>
			<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#AllAvailableDistributors.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;">
			#AllAvailableDistributors.Address_1#<BR>#AllAvailableDistributors.City#,#AllAvailableDistributors.State# #AllAvailableDistributors.ZipCode#&nbsp;
			</TD> 
			<cfif NOT appSettings.getDistributorMultiPosition()>
			<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#AllAvailableDistributors.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" >
			#AllAvailableDistributors.Broker_Name#&nbsp;
			</cfif>
			</TD>
		</TR>
	</CFOUTPUT>
	
	
	</TABLE>
	<table align="center">
	<tr><td><A href="##" onClick="confirmApproval()"><strong><font color="red">[</font> <font color="navy">view checkbook</font> <font color="red">]</font></strong></A></td></tr>
	</table>
	<cfoutput>
	<input type="hidden" name="FinalProgramList" value="#ProgramList#">	
	<input type="hidden" name="ShowLedger" value="1">
	<input type="hidden" name="startrow" value="#FORM.StartRow#">
	<input type="hidden" name="frompage" value="#FORM.frompage#">
	<input type="hidden" name="SortBy" value="#FORM.SortBy#">
	<input type="hidden" name="SortOrder" value="#FORM.SortOrder#">
	<input type="hidden" name="LocationFrom" value="#locationfrom#">

	</cfoutput>		
	
	</form>	
	<div>
	<CF_Next_Previous_For_Forms
		formname="SubmitDistributor"
		query="AllAvailableDistributors"
		maxpages="30"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		firstseries		=	"<IMG SRC=""/images/first_series.gif"" ALIGN=""middle"" BORDER=""0"">"	
		lastseries		=	"<IMG SRC=""/images/last_series.gif"" ALIGN=""middle"" BORDER=""0"">"		
		addparams="">
	</div>
<cfelse>
<p></p>
			Please select a different program.  There are no <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> available to this program. 
<cfoutput><form action="#locationfrom#" method="post" target="_parent">
<input type="submit" value="Start Over" >
</form></cfoutput>
<p></p>
</cfif>

</body></html>
