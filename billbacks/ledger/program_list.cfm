<!---
Document Name:	program_list.cfm
Directory:		billbacks/ledger
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	January 10, 2002

Displays only the program for already selected distributors

--->
<!---The waiting code--->

<cfset appSettings = application.appSettingsGet>

<cfparam name="SortBy" default="Contract_Number">
<cfparam name="SortOrder" default="asc">
<cfparam name="ShowExpired" default=0>
<cfparam name="ShowExpired" default=0>
<cfparam name="locationfrom" default="/billbacks/ledger/index.cfm">
<cfif locationfrom IS "auto">
	<cfset locationfrom = "/billbacks/ledger/auto_checkbook/add_edit.cfm">
</cfif>

<cfif isDefined("url.ShowExpired")>
	<cfset ShowExpired = url.ShowExpired>
</cfif>
<cfif isDefined("url.SortBy")>
	<cfset SortBy = url.SortBy>
</cfif>
<cfif isDefined("url.SortOrder")>
	<cfset SortOrder = url.SortOrder>
</cfif>


<html><head><Title>Programs</TITLE></head><body STYLE="margin:0; border: 0px orange solid; background-color:transparent" allowTransparency="true">

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
<CFPARAM NAME="DistributorList" DEFAULT="">

<cfset DistributorList = url.DistributorList>

<cfparam name="ShowExpired" default=0>
<cfif IsDefined("url.ShowExpired")>
	<cfset ShowExpired = url.ShowExpired>
</cfif>

<cfquery name="AllAvailableDistributors" datasource="#application.datasource#">
	SELECT	DISTINCT Contract_Main.Contract_Main_ID, Contract_Number, Contract_Title, Contract_Start_Date, Contract_End_Date, Contract_Status_Type_ID, Contract_Status_Type_Desc
	FROM	Contract_Main			
			INNER JOIN Contract_Status_Types 
			ON
			Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
			INNER JOIN Contract_Distributors 
			ON 
			Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
			AND 
			Contract_Distributors.Deleted = 0			
			---INNER JOIN START
			INNER JOIN	BSA_FoodService_Customers
			ON
			BSA_FoodService_Customers.Deleted = 0
			AND
			BSA_FoodService_Customers.BSA_Foodservice_Customers_ID = '#DistributorList#'
			AND
			(
				BSA_FoodService_Customers.BSA_FoodService_Customers_ID = Contract_Distributors.BSA_FoodService_Customers_ID
				OR
				(
				Contract_Distributors.Distributor_Group_Level_ID = 1
				AND Contract_Distributors.Distributor_Group_ID IS NOT NULL
				AND Len(Contract_Distributors.Distributor_Group_ID) > 0				
				AND
				(
					<cfif application.returned_customer_setting.customer_keyword IS "conagra">
					(
						Contract_Distributors.Distributor_Group_ID = BSA_Foodservice_Customers.Business_Segment_ID
						OR
						(Contract_Distributors.Distributor_Group_ID = 5 AND BSA_Foodservice_Customers.Business_Segment_ID = 1)
					)
					<cfelse>
					Contract_Distributors.Distributor_Group_ID = cast(BSA_Foodservice_Customers.Business_Segment_ID as nvarchar(50))
					</cfif>
					AND
					Contract_Distributors.BSA_FoodService_Customers_ID IN
					(
						SELECT 	DISTINCT Distributor_Group_Distributor.Distributor_ID
						FROM	Distributor_Group_Distributor
						WHERE
								Distributor_Group_Distributor.Deleted = 0
								AND
								Distributor_Group_Distributor.Distributor_Group_Level_ID = 1
								AND
								Distributor_Group_Distributor.Distributor_Group_ID = Contract_Distributors.Distributor_Group_ID
					)
				)
				)
			)
			---INNER JOIN END
	WHERE	
			Contract_Main.ProgramType_ID IN 
				(	
					SELECT 	ProgramControl_Panel_Options_ID 
					FROM 	Program_Control_Panel_Options 
					WHERE 
							Program_Control_Panel_Options.Generic_Type = 'Distributor Trade/Shelter'
				)
			AND
			Contract_Main.Deleted = 0
			AND
			Contract_Status_Types.Contract_Status_Type_ID >= 5
			<cfif ShowExpired IS 0>
			AND 
			Contract_Status_Types.Contract_Status_Type_ID < 7
			</cfif>
			AND
			(
			((Contract_Main.Parent_Revised_Contract_Main_ID IS NULL) AND (Contract_Main.Revision_of_Contract_Main_ID IS NULL))
			OR
			(NOT(Contract_Main.Parent_Revised_Contract_Main_ID IS NULL) AND NOT(Contract_Main.Revision_of_Contract_Main_ID IS NULL) AND Contract_Status_Types.Contract_Status_Type_ID > 4)
			)
	ORDER BY #SortBy# #SortOrder#

</cfquery>

<!---Javascript to submit this--->

		<SCRIPT>
			function confirmApproval() 
			{
				document.all.SubmitPrograms.submit();
			}
		</SCRIPT>
		
		
		<!-- </FORM> -->

<!---Display results--->

<!--- 
<strong>There <CFIF AllAvailableDistributors.recordcount EQ 1>Is <CFELSE>Are </CFIF> <CFOUTPUT> #AllAvailableDistributors.recordcount#</CFOUTPUT> <CFIF AllAvailableDistributors.recordcount EQ 1>Program<CFELSE>Programs</CFIF> </strong>
 --->
<CFIF AllAvailableDistributors.recordcount GT 0><cfoutput>
<form name="SubmitPrograms" action="#locationfrom#" method="post" target="_parent">
		<CFSET FORM.AlreadySelectedItems = "">
		
			<TABLE border="0" cellspacing="0" cellpadding="3" align="center" WIDTH="100%" CLASS="Maintable">
				<TR ID="header" BGCOLOR="ffce84">
					<td>&nbsp; </td>
					<TD align="left" NOWRAP ID="header"><B><a href="program_list.cfm?DistributorList=#url.DistributorList#&ShowExpired=#ShowExpired#&SortBy=Contract_Number&SortOrder=<cfif SortBy IS "Contract_Number" AND SortOrder IS "asc">desc<cfelse>asc</cfif>">Number
<cfif SortBy IS "Contract_Number" AND SortOrder IS "asc"><img src="/images/down_1.gif" border="0"><cfelseif SortBy IS "Contract_Number" AND SortOrder IS "desc"><img src="/images/up_1.gif" border="0"></cfif>
</a></B></TD>
					<td align="left" id="header"><strong><a href="program_list.cfm?DistributorList=#url.DistributorList#&SortBy=Contract_Start_Date&SortOrder=<cfif SortBy IS "Contract_Start_Date" AND SortOrder IS "asc">desc<cfelse>asc</cfif>&ShowExpired=#ShowExpired#">Dates
<cfif SortBy IS "Contract_Start_Date" AND SortOrder IS "asc"><img src="/images/down_1.gif" border="0"><cfelseif SortBy IS "Contract_Start_Date" AND SortOrder IS "desc"><img src="/images/up_1.gif" border="0"></cfif>
</a></strong></td>
					<td align="left" id="header"><strong><a href="program_list.cfm?DistributorList=#url.DistributorList#&SortBy=Contract_Status_Type_ID&SortOrder=<cfif SortBy IS "Contract_Status_Type_ID" AND SortOrder IS "asc">desc<cfelse>asc</cfif>&ShowExpired=#ShowExpired#">Status
<cfif SortBy IS "Contract_Status_Type_ID" AND SortOrder IS "asc"><img src="/images/down_1.gif" border="0"><cfelseif SortBy IS "Contract_Status_Type_ID" AND SortOrder IS "desc"><img src="/images/up_1.gif" border="0"></cfif>
</a></strong></td>
					<TD align="left" ID="header"><B><a href="program_list.cfm?DistributorList=#url.DistributorList#&SortBy=Contract_Title&SortOrder=<cfif SortBy IS "Contract_Title" AND SortOrder IS "asc">desc<cfelse>asc</cfif>&ShowExpired=#ShowExpired#">Title 
<cfif SortBy IS "Contract_Title" AND SortOrder IS "asc"><img src="/images/down_1.gif" border="0"><cfelseif SortBy IS "Contract_Title" AND SortOrder IS "desc"><img src="/images/up_1.gif" border="0"></cfif>
</a></B></TD>
				
				</TR>
				</cfoutput>

			<CFOUTPUT QUERY="AllAvailableDistributors">
				<cf_cryp string="#AllAvailableDistributors.Contract_Main_ID#" type="en" key="#request.key#">

				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<TD align="center">
						<Cfif appSettings.getUse_AccrualLog_For_TC() IS 1>
			<!--- You can only make a multi selection by using the accrual log--->
							<INPUT type="checkbox" NAME="FinalProgramList" VALUE="#trim(AllAvailableDistributors.Contract_Main_ID)#" <CFIF listfind(FORM.FinalItemList, trim(AllAvailableDistributors.Contract_Main_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(AllAvailableDistributors.Contract_Number), ",")></CFIF> >
					<cfelse>
							<INPUT type="Radio" NAME="FinalProgramList" VALUE="#trim(AllAvailableDistributors.Contract_Main_ID)#" <CFIF listfind(FORM.FinalItemList, trim(AllAvailableDistributors.Contract_Main_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(AllAvailableDistributors.Contract_Number), ",")></CFIF> onClick="confirmApproval()">
					</cfif>
						
					</TD>
					<TD NOWRAP>#AllAvailableDistributors.Contract_Number#&nbsp;</TD>
					<TD NOWRAP>#DateFormat(AllAvailableDistributors.Contract_Start_Date, 'MM/DD/YY')# - #DateFormat(AllAvailableDistributors.Contract_End_Date, 'MM/DD/YY')#&nbsp;</TD>
				<Td nowrap>#AllAvailableDistributors.Contract_Status_Type_Desc#</TD>	<TD>#AllAvailableDistributors.Contract_Title#</TD>
					
 				</TR>
			</CFOUTPUT>
			
			</TABLE>
			<table align="center">
	<tr><td><A href="##" onClick="confirmApproval()"><strong><font color="red">[</font> <font color="navy">view checkbook</font> <font color="red">]</font></strong></A></td></tr>
	</table>
			<p></p>
			<div align="center">
			<strong><font color="red">[</font>
			<cfif ShowExpired IS 0>
				<font color="blue"><cfoutput><a href="program_list.cfm?DistributorList=#url.DistributorList#&ShowExpired=1">Show Expired</a></cfoutput></font>
			<cfelse>
				<font color="blue"><cfoutput><a href="program_list.cfm?DistributorList=#url.DistributorList#&ShowExpired=0">Hide Expired</a></cfoutput></font>
			</cfif>
			<font color="red">]</font></strong></div>
<cfoutput>
<input type="hidden" name="FinalDistributorList" value="#distributorlist#">
<input type="hidden" name="ShowLedger" value="1">
<input type="hidden" name="LocationFrom" value="#locationfrom#">
</cfoutput>
</form>	
<!---There are no programs that match the selected distributor--->
		<cfelse>
		<p></p>
			Please select a different <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput>.  There are no programs available to this <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput>.  

<cfoutput><form action="#locationfrom#" method="post" target="_parent">
<input type="submit" value="Start Over" >
</form></cfoutput>
<p></p>
		</CFIF>

</body></html>
