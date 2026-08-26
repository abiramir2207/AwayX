<!---
Created By: Brenda Flynn
			bflynn@bigredflame.com
Created On:	June 8, 2004

Edited By:
Edited On:
Edited To:

Allows the user to identify program/distributor combinations for which they would like to recieve automated monthly emails
--->

<cfparam name="Action" default="Add">

<cfif isDefined("Auto_Checkbook_ID")>
	<cfset Action="Edit">
</cfif>

<cfif Action IS "Edit">

	<cfquery name="AutoCheckbookValues" datasource="#application.datasource#">
	SELECT Auto_Checkbook.Send_To, Contract_Main.Contract_Number, Contract_Main.Contract_Title, BSA_Foodservice_Customers.Name, BSA_Foodservice_Customers.Ship_To
	FROM Auto_Checkbook
		INNER JOIN Contract_Main ON Contract_Main.Contract_Main_ID = Auto_Checkbook.Program_ID
		INNER JOIN BSA_Foodservice_Customers
			ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Auto_Checkbook.Distributor_ID
	WHERE Auto_Checkbook.Deleted = 0
	AND Auto_Checkbook.Auto_Checkbook_ID = '#Auto_Checkbook_ID#'
	</cfquery>
	
	<cfset ExistingSend_To = AutoCheckbookValues.Send_To>
	<cfset ExistingProgram = AutoCheckbookValues.Contract_Number & " - "  & AutoCheckbookValues.Contract_Title>
	<cfset ExistingDistributor = AutoCheckbookValues.Name>
	
</cfif>


<!---Get creating user's information--->
<cfset useLakebaseForCreatingUserInformation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForCreatingUserInformation>
	<cftry>
		<cfset CreatingUserInformation = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCreatingUserInformation = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCreatingUserInformation>
<cfquery name="CreatingUserInformation" datasource="#application.datasource#">
SELECT User_Email FROM _Users WHERE User_ID = '#request.AccessStructure.User_ID#'
</cfquery>
</cfif>

<!---Param all values entered--->
<cfparam name="Auto_Checkbook_ID"	default="">
<cfparam name="Send_To" 			default="#CreatingUserInformation.User_Email#">
<cfparam name="Contract_Number" 	default="">
<cfparam name="Contract_Title" 		default="">
<cfparam name="Name" 				default="">


<CFPARAM name="FinalDistributorList"				default="">
<CFPARAM name="FinalProgramList"					default="0">
<CFPARAM name="DistributorName" 					default="0">
<CFPARAM name="Program_Submitted"					default="0">
<CFPARAM name="Distributor_Submitted"				default="0">

<cfparam name="ShowLedger"							default=0>

<cfif len(trim(FinalDistributorList)) GT 0 AND len(trim(FinalProgramList)) GT 0>
	<cfset url.DistributorList = FinalDistributorList>
	<cfset url.ProgramList = FinalProgramList>
</cfif>

<cfif IsDefined("Url.Programlist")>
<Cfset Form.Program_List = Url.ProgramList>
<cfset Program_Submitted = 1>
</cfif>

<cfif IsDefined("Url.Distributorlist")>
<Cfset Form.Distributor_List = Url.DistributorList>
<cfset Distributor_Submitted = 1>
</cfif>


<cfoutput>

<!---Form for communicating with Program Selection popup--->
<form name="program_form" action="/billbacks/ledger/auto_checkbook/add_edit.cfm" method="Post">

<input type="hidden" ID="Program_List" Name="Program_List" value="<cfif isDefined("Form.Product_List")>#Form.Program_List#</cfif>">

<INPUT TYPE="hidden" ID="Distributor_List2" NAME="Distributor_List2" VALUE="<cfif isDefined("FORM.Distributor_List")>#Form.Distributor_List#</cfif>">

<INPUT TYPE="hidden" ID="Program_Submitted" Name="Program_Submitted" VALUE="1">

<input type="hidden" name="Action" value="#action#">
<input type="hidden" name="Auto_Checkbook_ID" value="#Auto_Checkbook_ID#">

<input type="hidden" name="runsearchonfirstload" value=0> 
<input type="hidden" name="FilterSearchPrograms" value=0>

</form>

<!---Form for communicating with Distributor Selection Popup--->
<form name="distributor_form" action="/billbacks/ledger/auto_checkbook/add_edit.cfm" method="post">

<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="<cfif isDefined("Form.Distributor_List")>#Form.Distributor_List#</cfif>">

<INPUT TYPE="Hidden" ID="Program_List2" Name="Program_List2" Value="<cfif isDefined("FORM.Program_List")>#Form.Program_List#</cfif>">

<INPUT TYPE="hidden" ID="Distributor_Submitted" Name="Distributor_Submitted" VALUE="1">

<input type="hidden" name="Action" value="#action#">
<input type="hidden" name="Auto_Checkbook_ID" value="#Auto_Checkbook_ID#">

</form>


</cfoutput>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<CFSET PAGE_TITLE="Auto Checkbook">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>

<!--- Header include --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">

<blockquote>
<cfoutput>
<form name="AddAutoCheckbook" action="add_edit_action.cfm" method="post">
<table width="90%" cellpadding="0" cellspacing="2" border="0">
<tr><td colspan="100%"><font color="navy" size="2"><strong>#Action# Auto Checkbook</strong></font></td></tr>
<tr><td colspan="100%"><hr color="orange"></td></tr>

<!---Shows different things here--->
<cfif Program_Submitted IS 0 AND Distributor_Submitted IS 0 AND ShowLedger IS 0>

	<!---Imports list of Programs into distributors to limits distributor list if a program has been selected--->
	<cfif isDefined("Form.Program_List")>

	<cfset Program_Window = #Form.Program_List#>
	<cfelseif isDefined("Form.Program_List2")>
	<cfset Program_Window = #Form.Program_List2#>
	<cfelseif isDefined("FinalProgramList")>
	<cfset Program_Window = #FinalProgramList#>
	<cfelse>
	<cfset Program_Window = "0">
	</cfif>
	
	<!---Imports list of Distributors into program if a distributor has been selected--->
	<cfif isDefined("DistributorName")>
	<cfset Distributor_Window = #DistributorName#>
	<cfelse>
	<cfset Distributor_Window = "0">
	</cfif>
	
	<script>
	function searchData(typeofdata){
		switch (typeofdata) {
			case "di" :
NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=distributor_form", "distributorwindow", 800, 600, "yes", "yes")
			break;
			case "pr" :
NewWindow("/billbacks/search_screens/search_programs.cfm?FormName=program_form&SelectSingleSearchResultOnly=1&Source=Checkbook&Fieldname=Program_List&ProgramType=Trade", "programwindow", 800, 600, "yes", "yes")
			break;
			
		}
	}
	</script>

	
	
<tr>
	<td align="right"><strong><font color="Navy">#application.returned_customer_setting.distributor_label_singular#:</font></strong></td>
	<td rowspan="3" bgcolor="orange"><img src="/images/fill.gif"></td>
	<td><a onclick="searchData('di')" style="cursor: pointer;">Search for a #lcase(application.returned_customer_setting.distributor_label_singular)#</a><cfif isDefined("ExistingDistributor")>
<br>Currently: #ExistingDistributor#
</cfif></td>
</tr>

<tr>
	<td align="right"><strong><font color="Navy">Program:</font></strong></td>
	<td><a onclick="searchData('pr')" style="cursor: pointer;">Search for a program</a><cfif isDefined("ExistingProgram")>
<br>Currently: #ExistingProgram#
</cfif></td>
</tr>

<!---They have picked a distributor and not a program--->
<cfelseif Distributor_Submitted NEQ 0 AND ShowLedger IS 0>
<cfparam name="DistributorName" default="">

<!---Shows the name if they have selected a distributor--->
<cfif isDefined("form.Distributor_list") AND len(trim(form.Distributor_list)) GT 0>
 <cfset useLakebaseForGetDistributorName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForGetDistributorName>
	<cftry>
		<cfset GetDistributorName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#Form.Distributor_List#",
				"select" = "name"
			}), "name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDistributorName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDistributorName>
<cfquery name="GetDistributorName" datasource="#application.datasource#">
	SELECT Name
	FROM BSA_Foodservice_Customers
	WHERE BSA_Foodservice_Customers_ID = '#Form.Distributor_List#'
	</cfquery>
</cfif>
	<cfset FinalDistributorList = form.Distributor_List>
	<cfset DistributorName = GetDistributorName.Name>
</cfif>

<!---Shows the name if they have selected a distributor--->
<cfif isDefined("form.Distributor_list2") AND len(trim(form.Distributor_list2)) GT 0>
	<cfset useLakebaseForGetDistributorName2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForGetDistributorName2>
	<cftry>
		<cfset GetDistributorName2 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#Form.Distributor_List2#",
				"select" = "name"
			}), "name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDistributorName2 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDistributorName2>
<cfquery name="GetDistributorName2" datasource="#application.datasource#">
	SELECT Name
	FROM BSA_Foodservice_Customers
	WHERE BSA_Foodservice_Customers_ID = '#Form.Distributor_List2#'
	</cfquery>
</cfif>
	<cfset FinalDistributorList = form.Distributor_List2>
	<cfset DistributorName = GetDistributorName2.Name>
</cfif>

<tr>
	<td align="right" valign="top"><strong><font color="Navy">#application.returned_customer_setting.distributor_label_singular#:</font></strong></td>
	<td rowspan="3" bgcolor="orange"><img src="/images/fill.gif"></td>
	<td valign="top">#DistributorName#
	</td>
</tr>

<tr>
	<td align="right" valign="top"><strong><font color="Navy">Program:</font></strong></td>
	<td><IFRAME SRC="/billbacks/ledger/program_list.cfm?DistributorList=#Form.Distributor_List#&locationfrom=Auto" NAME="toc" ID="toc" WIDTH="500" HEIGHT="200" MARGINWIDTH="0" MARGINHEIGHT="0" FRAMEBORDER="0"></IFRAME></td>
</tr>

<!---If they have submitted a program but not a distributor--->
<cfelseif Program_Submitted NEQ 0 AND ShowLedger IS 0>

<cfparam name="Contract_Title" default="No contract title">

<!---Shows the name if they have selected a distributor--->
 <cfif isDefined("Form.Program_LIST") AND len(trim(form.Program_list)) GT 0>
	<cfquery name="GetProgramName" datasource="#application.datasource#">
	SELECT left(Contract_Title, 50) AS Contract_Title
	FROM Contract_Main
	WHERE Contract_Main_ID = '#Form.Program_List#'
	</cfquery>
	<cfset Contract_Title = GetProgramName.Contract_Title>
	<cfset FinalProgramList = form.Program_List>
</cfif> 

<!---Shows the name if they have selected a distributor--->
 <cfif isDefined("Form.Program_LIST2") AND len(trim(form.Program_list2)) GT 0>

	<cfquery name="GetProgramName" datasource="#application.datasource#">
	SELECT left(Contract_Title, 50) AS Contract_Title
	FROM Contract_Main
	WHERE Contract_Main_ID = '#Form.Program_List2#'
	</cfquery>
	<cfset Contract_Title = GetProgramName.Contract_Title>
	<cfset FinalProgramList = form.Program_List2>
</cfif> 

<tr>
	<td align="right" valign="top"><strong><font color="Navy">#application.returned_customer_setting.distributor_label_singular#:</font></strong></td>
	<td rowspan="3" bgcolor="orange"><img src="/images/fill.gif"></td>
	<td><IFRAME SRC="/billbacks/ledger/distributor_list.cfm?ProgramList=#Form.Program_List#&locationfrom=Auto" NAME="toc" ID="toc" WIDTH="500" HEIGHT="200" MARGINWIDTH="0" MARGINHEIGHT="0" frameborder="0"></IFRAME></td>
</tr>

<tr>
	<td align="right" valign="top"><strong><font color="Navy">Program:</font></strong></td>
	<td valign="top">#Contract_Title#
	
	</td>
</tr>

<cfelse>

<cfquery name="Program_Name" datasource="#application.datasource#">
	SELECT left(Contract_Title, 50) AS Contract_Title, Contract_Main_ID
	FROM Contract_Main
	WHERE Contract_Main_ID = '#Form.Program_List#'
</cfquery>
<cfset Contract_Title = Program_Name.Contract_Title>

<cfquery name="Distributor_Name" datasource="#application.datasource#">
	SELECT Name, BSA_Foodservice_Customers_ID
	FROM BSA_Foodservice_Customers
	WHERE BSA_Foodservice_Customers_ID = '#Form.Distributor_List#'
	</cfquery>

<cfset DistributorName = Distributor_Name.Name>

<!---If they have selected both distributor and operator--->
<tr>
	<td align="right"><strong><font color="Navy">#application.returned_customer_setting.distributor_label_singular#:</font></strong></td>
	<td rowspan="3" bgcolor="orange"><img src="/images/fill.gif"></td>
	<td>#DistributorName#
		<input type="hidden" name="Distributor_ID" value="#Distributor_Name.BSA_Foodservice_Customers_ID#">
	</td>
</tr>

<tr>
	<td align="right"><strong><font color="Navy">Program:</font></strong></td>
	<td>#Contract_Title#
		<input type="hidden" name="Program_ID" value="#Program_Name.Contract_Main_ID#">
	</td>
</tr>
</cfif>

<tr>
	<td align="right" valign="top"><span ID="error_SendTo"></span><strong><font color="Navy">Email to:</font></strong></td>
	<td><textarea name="Send_To" id="Send_To" rows="3" cols="45"><cfif isDefined("ExistingSend_To")>#ExistingSend_To#<cfelse>#Send_To#</cfif></textarea></td>
</tr>
<input type="hidden" name="Action" value="#action#">
<input type="hidden" name="Auto_Checkbook_ID" value="#Auto_Checkbook_ID#">
<tr><td colspan="2">&nbsp;</td> <td>
<cfif ShowLedger IS 1>
<CF_button
	button_name		=	""
	button_caption	=	"continue"
	button_action	=	"javascript: validateForm();"
	button_type		=	"link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>
</cfif>
</td></tr>
</form>
</table>

</cfoutput>
</blockquote>
<BLOCKQUOTE><BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>

<script>

function validateForm(){
			ErrorCount=0;
			
			//if(document.all.Send_To.value.length == 0)
			if(document.getElementById("Send_To").value.length == 0)
			{
				ErrorCount++;
				queueMessage("You must enter emails to send the report to.", document.all.error_SendTo)
			}
			else{
				clearQueue(document.all.error_SendTo)
			}
			
			if(ErrorCount==0) {
				document.all.AddAutoCheckbook.submit();
			}
			else{
				showMessageWindow()
			}
			
		}
</script>
	
	<CF_MessageWindow>
