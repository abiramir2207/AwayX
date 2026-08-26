<!---
Document Name:	distributor_list.cfm
Directory:		billbacks/ledger
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	January 10, 2002

Displays only the distributors for already selected programs

--->

<cfparam name="SortBy" default="Name">
<cfparam name="SortOrder" default="asc">

<cfif isDefined("url.SortBy")>
	<cfset SortBy = url.SortBy>
</cfif>
<cfif isDefined("url.SortOrder")>
	<cfset SortOrder = url.SortOrder>
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

<!--- <cfset useLakebaseForgetUserPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
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
	<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm"> --->

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
		dbo.BSA_Foodservice_Brokers.Broker_Name, 
		dbo.Service_Zones.Zone_Name, 
        dbo.Service_Regions.Region_Name, 
		dbo.Distributor_Buying_Groups.Buying_Group_Name,  
		dbo.BSA_Foodservice_Customers.Shr_Ship_To
FROM    dbo.BSA_Foodservice_Customers 
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
WHERE 0 = 0 
AND 	dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN
		(
		SELECT BSA_Foodservice_Customers_ID 
		FROM Contract_Distributors
		WHERE Contract_Main_ID = #ProgramList#
		)
AND dbo.BSA_Foodservice_Customers.DELETED = 0 
ORDER BY #SortBy# #SortOrder#
</cfquery>

<cfset AvailableDistributors = listqualify(valuelist(AllAvailableDistributors.BSA_Foodservice_Customers_ID), chr(39))>
<!--- 
<!---Gets all the distributors I have permission to see--->
	<cfquery name="DistributorsICanSee" datasource="#application.datasource#">
	SELECT     dbo.BSA_Foodservice_Customers.Name, 
			   dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID	
	FROM       dbo.User_Positions 
			INNER JOIN
	        dbo.BSA_Foodservice_Brokers 
			ON dbo.User_Positions.Service_Market_ID = dbo.BSA_Foodservice_Brokers.Service_Market_ID 
				INNER JOIN
	            dbo.BSA_Foodservice_Customers 
				ON dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID =
				dbo.BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID 
	WHERE (dbo.User_Positions.Deleted = 0) 
	AND (dbo.BSA_Foodservice_Customers.Deleted = 0) 
	AND (dbo.User_Positions.User_Positions_ID IN (#GP_Position_List_From_My_Position_Down#))
	<cfif listlen(AvailableDistributors) GT 0>AND dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID 
	IN (#preservesinglequotes(AvailableDistributors)#)</cfif>
	ORDER BY #SortBy# #SortOrder#
	</cfquery>
 --->

<!---Javascript to submit this--->

		<SCRIPT>
			function confirmApproval() 
			{
				document.all.SubmitDistributor.submit();
			}
		</SCRIPT>
		
		
		<!-- </FORM> -->

<!---Display results--->


<!--- <strong>There <CFIF AllAvailableDistributors.recordcount EQ 1>Is <CFELSE>Are </CFIF><CFOUTPUT>  #AllAvailableDistributors.recordcount#</CFOUTPUT>
<CFIF AllAvailableDistributors.recordcount EQ 1>Distributor<CFELSE>Distributors</CFIF> </strong>  --->

<BR>


		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF AllAvailableDistributors.recordcount GT 0>
		<form name="SubmitDistributor" action="index.cfm" method="post" target="_parent">
		<cfoutput>
			<TABLE border="0" cellspacing="0" cellpadding="0" align="center" WIDTH="100%" CLASS="Maintable">
				<TR ID="header" BGCOLOR="ffce84">
					<td HEIGHT="25">&nbsp; </td>
					<TD align="left" ID="header"><B><a href="distributor_list.cfm?ProgramList=#ProgramList#&SortBy=BSA_Foodservice_Customers.Name&SortOrder=<cfif SortBy IS "Name" AND SortOrder IS "asc">desc<cfelse>asc</cfif>">Name 
<cfif SortBy IS "BSA_Foodservice_Customers.Name" AND SortOrder IS "asc"><img src="/images/down_1.gif" border="0"><cfelseif SortBy IS "BSA_Foodservice_Customers.Name" AND SortOrder IS "desc"><img src="/images/up_1.gif" border="0"></cfif></a></B></TD>

					<TD align="left" ID="header"><B><a href="distributor_list.cfm?ProgramList=#ProgramList#&SortBy=BSA_Foodservice_Customers.State&SortOrder=<cfif SortBy IS "BSA_Foodservice_Customers.State" AND SortOrder IS "asc">desc<cfelse>asc</cfif>">Address 
<cfif SortBy IS "BSA_Foodservice_Customers.State" AND SortOrder IS "asc"><img src="/images/down_1.gif" border="0"><cfelseif SortBy IS "BSA_Foodservice_Customers.State" AND SortOrder IS "desc"><img src="/images/up_1.gif" border="0"></cfif></a></B> (State)</TD>

					<TD ID="header"><B><a href="distributor_list.cfm?ProgramList=#ProgramList#&SortBy=BSA_Foodservice_Brokers.Broker_Name&SortOrder=<cfif SortBy IS "BSA_Foodservice_Brokers.Broker_Name" AND SortOrder IS "asc">desc<cfelse>asc</cfif>">Broker 
<cfif SortBy IS "BSA_Foodservice_Brokers.Broker_Name" AND SortOrder IS "asc"><img src="/images/down_1.gif" border="0"><cfelseif SortBy IS "BSA_Foodservice_Brokers.Broker_Name" AND SortOrder IS "desc"><img src="/images/up_1.gif" border="0"></cfif></a></B></TD>
					</TR>
			</cfoutput>
			<CFOUTPUT QUERY="AllAvailableDistributors">
				<TR STYLE="cursor:pointer;" <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					
						<TD align="center"><INPUT type="Radio" NAME="FinalDistributorList" VALUE="#trim(AllAvailableDistributors.BSA_Foodservice_Customers_ID)#" <CFIF listfind(FORM.FinalItemList, trim(AllAvailableDistributors.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(AllAvailableDistributors.BSA_Foodservice_Customers_ID), ",")></CFIF> onClick="confirmApproval()"></TD>
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#AllAvailableDistributors.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" NOWRAP>#AllAvailableDistributors.Name#<BR>#AllAvailableDistributors.Shr_Ship_To#&nbsp;</TD>
					 <TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#AllAvailableDistributors.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;">#AllAvailableDistributors.Address_1#<BR>#AllAvailableDistributors.City#,#AllAvailableDistributors.State# #AllAvailableDistributors.ZipCode#&nbsp;</TD> 
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#AllAvailableDistributors.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" >#AllAvailableDistributors.Broker_Name#&nbsp;</TD>
					<!--- <TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#AllAvailablePrograms.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" NOWRAP>#AllAvailablePrograms.Family_Name#<BR>#AllAvailablePrograms.Buying_Group_Name#&nbsp;</TD> --->
 				</TR>
			</CFOUTPUT>
			</TABLE>
<cfoutput>
<input type="hidden" name="FinalProgramList" value="#ProgramList#">	
<input type="hidden" name="ShowLedger" value="1">
</cfoutput>		

</form>	

<cfelse>
<p></p>
			Please select a different program.  There are no <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> available to this program. 
<form action="index.cfm" method="post" target="_parent">
<input type="submit" value="Start Over" >
</form>
<p></p>
</cfif>

</body></html>