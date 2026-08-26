<!---
Document Name:	index.cfm
Directory:		billbacks/ledger
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	December 26, 2002

This is the ledger.  When the user first enters it, they are requested to provide information. From that information a ledger is generated

Updated By:		Brenda Flynn
Updated Date:	June 15, 2004
Update Description:	Added following elements to trade checkbook
*Growth seperate volume
*Growth targets
*Growth $ Targets
*Item/distributor groups 
*Fixed Price changes
*Deductions

Updated By: Brenda Flynn
Updated Date: September 14, 2005
Update Description: Made major structural changes to trade checkbook. Instead of having 1 to 1 relationship of programs and distributors, you may now have either multiple programs for one distributor or multiple distributors for one program. Also, all calculations are now being done on a nightly basis and are available in the table Accrual_Log. This has gone from performing the calculations to merely showing most of them.
--->

<cfset appSettings = application.appSettingsGet>

<CFPARAM name="ShowLedger"							default="0">
<CFPARAM name="CalledFrom"							default="Checkbook">

<!---Gets the current user's position--->
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

<!---Includes approval rights stuff--->
<CFSET GP_Supplied_Position = getUserPosition.User_Positions_ID>
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm"> --->

<CFSET PAGE_TITLE="#application.returned_customer_setting.Trade_Label# Checkbook">
<CFSET group="reports">

<!---Begin viewable page--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
	<style>
	.tableheader
		{
			border-bottom: solid blue 1px;
			font-weight: bold;
		}
	.tdbody	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	.tdbodyright	{border-bottom:solid #93BEE2 1px; border-right:solid #93BEE2 1px; font-size : 10px;}
	.tableborder
		{
			border-bottom: solid blue 1px;
			border-top: solid blue 1px;
			border-right: solid blue 1px;
			border-left: solid blue 1px;
		}

		.inactiveMenuItem {
			width : 100px;
			height : 30px;
			cursor : pointer;
			background-color: WhiteSmoke;
			PADDING-BOTTOM: 1px;
			PADDING-LEFT: 10px;
			PADDING-RIGHT: 10px;
			PADDING-TOP: 1px;
			border-right:solid red 1px;
			border-top:solid WhiteSmoke 1px;
			border-bottom:solid WhiteSmoke 1px;
			border-left:solid WhiteSmoke 1px;
			border-white:solid White 1px;			
		}
		.activeMenuItem {
			width : 100px;
			height : 30px;
			cursor : pointer;
			background-color: silver;
			PADDING-BOTTOM: 1px;
			PADDING-LEFT: 10px;
			PADDING-RIGHT: 10px;
			PADDING-TOP: 1px;
			border-right:solid silver 1px;
			border-top:solid red 1px;
			border-bottom:solid red 1px;
			border-left:solid red 1px;
		}

		.cellaroundIframe {
			border-right:solid red 1px;
			border-top:solid red 1px;
			border-bottom:solid red 1px;
		} 

		.menuItem_idle {
			font-weight: bold;
			background-color: WhiteSmoke;
			PADDING-BOTTOM: 1px;
			PADDING-LEFT: 10px;
			PADDING-RIGHT: 10px;
			PADDING-TOP: 1px;
			border-right:solid red 1px;
			border-top:solid WhiteSmoke 1px;
			border-bottom:solid WhiteSmoke 1px;
			border-left:solid WhiteSmoke 1px;
			border-white:solid White 1px;
		}

					
</style>

</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<cfif CalledFrom IS NOT "Scheduled">
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<CFFLUSH>
<SCRIPT LANGUAGE="JavaScript">
function hide_PleaseWaitMessage()
{
 document.all.PleaseWaitMessage.style.display='none';
}
hide_PleaseWaitMessage();
</SCRIPT>



<!---Include header--->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<BR>
<p></p>
</cfif>

<div align="center">

<cfif IsDefined("Url.Programlist")>
<Cfset Form.Program_List = Url.ProgramList>
<cfset Program_Submitted = 1>
</cfif>

<cfif IsDefined("Url.Distributorlist")>
<Cfset Form.Distributor_List = Url.DistributorList>
<cfset Distributor_Submitted = 1>
</cfif>



<cfif ShowLedger IS 0>

<!--- Setting default parameters --->

<CFPARAM name="FORM.start_date" 					default="">
<CFPARAM name="FORM.end_date" 						default="">
<CFPARAM name="FinalDistributorList"				default="">
<CFPARAM name="FinalProgramList"					default="0">
<CFPARAM name="DistributorName" 					default="0">
<CFPARAM name="Program_Submitted"					default="0">
<CFPARAM name="Distributor_Submitted"				default="0">

<cfoutput>

<!---Form for communicating with Program Selection popup--->
<form name="program_form" action="/billbacks/ledger/index.cfm" method="Post">

<input type="hidden" ID="Program_List" Name="Program_List" value="<cfif isDefined("Form.Product_List")>#Form.Program_List#</cfif>">

<INPUT TYPE="hidden" ID="Distributor_List2" NAME="Distributor_List2" VALUE="<cfif isDefined("FORM.Distributor_List")>#Form.Distributor_List#</cfif>">

<INPUT TYPE="hidden" ID="Program_Submitted" Name="Program_Submitted" VALUE="1">

<input type="hidden" name="runsearchonfirstload" value=0> 
<input type="hidden" name="FilterSearchPrograms" value=0>

</form>

<!---Form for communicating with Distributor Selection Popup--->
<form name="distributor_form" action="/billbacks/ledger/index.cfm" method="post">

<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="<cfif isDefined("Form.Distributor_List")>#Form.Distributor_List#</cfif>">

<INPUT TYPE="Hidden" ID="Program_List2" Name="Program_List2" Value="<cfif isDefined("FORM.Program_List")>#Form.Program_List#</cfif>">

<INPUT TYPE="hidden" ID="Distributor_Submitted" Name="Distributor_Submitted" VALUE="1">

</form>
</cfoutput>
<!--- 
<TABLE WIDTH="92%" CELLSPACING="0" CELLPADDING="2">
<TR>
	<TD CLASS="tableheader" COLSPAN="100%"><SPAN CLASS="Title2">Ledger Criteria:</SPAN></TD>
</TR>
</TABLE>
 --->


<!---Allows the user to select the information used to generate the ledger--->
<table width="92%" cellspacing="0" cellpadding="0" border="0">
<tr>
<td align="Center">
<!---Only shown if the program hasn't been selected--->


<cfif Program_Submitted IS 0 AND Distributor_Submitted IS 0>
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


	<table cellpadding="0" cellspacing="0">
	
	<tr>
	<td colspan="5">
	<cfoutput>
	<table width="400"><Tr><Td>
	View how much a #lcase(application.returned_customer_setting.distributor_label_singular)# has earned compared to how much they have billed back.  Select either a #lcase(application.returned_customer_setting.distributor_label_singular)# or a program to begin viewing the checkbook.</cfoutput></TD></TR></table>
	</td>
	</tr>
	<Tr><Td colspan="5">&nbsp; </TD></TR>
	
	<tr><cfoutput>
	<Td align="center" valign="center" ><a onclick="searchData('di')" style="cursor: pointer;"><img src="../../images/dist_icon1.jpg" border="1" title="Search for a #lcase(application.returned_customer_setting.distributor_label_singular)#"></a></TD>
<Td align="center" valign="center">
<a onclick="searchData('di')" style="cursor: pointer;"><strong>Search for a<br> #lcase(application.returned_customer_setting.distributor_label_singular)#</strong></a></cfoutput>
</td>
<Td align="center" valign="center">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
OR&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
</td>
<Td align="center" valign="center" > 
	<a onclick="searchData('pr')" style="cursor: pointer;"><img src="../../images/cont_icon1.jpg" border="1" title="Search for a Program"></a>
</td>
<Td align="center" valign="center" >
<a onclick="searchData('pr')" style="cursor: pointer;"><strong>Search for a<br> program</strong></a>
</td>
</tr>
</table>

<!---They have picked a distributor and not a program--->
<cfelseif Distributor_Submitted NEQ 0>

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



<TABLE WIDTH="92%" CELLSPACING="0" CELLPADDING="2">
<TR>
	<TD CLASS="tableheader" COLSPAN="100%"><FONT SIZE="3"><CFOUTPUT><B>#DistributorName#</B></CFOUTPUT></FONT></TD>
</TR>
</TABLE>




<BR>

<!--- 
You have selected <b><cfoutput>#DistributorName#</cfoutput></b> as your distributor.
<p>
Please select a Program:
</p>
 --->
 <cfoutput>
<!--- <IFRAME SRC="program_list.cfm?DistributorList=#Form.Distributor_List#" NAME="toc" ID="toc" WIDTH="90%" HEIGHT="400" MARGINWIDTH="0" MARGINHEIGHT="0" class="iframeStyle" frameborder="1"></IFRAME> --->

<IFRAME SRC="program_list.cfm?DistributorList=#Form.Distributor_List#" NAME="toc" ID="toc" WIDTH="90%" HEIGHT="425" MARGINWIDTH="0" MARGINHEIGHT="0" FRAMEBORDER="0"></IFRAME>
<br>
</cfoutput>
<!---If they have submitted a program but not a distributor--->
<cfelseif Program_Submitted NEQ 0>

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




<TABLE WIDTH="92%" CELLSPACING="0" CELLPADDING="2">
<TR>
	<TD CLASS="tableheader" COLSPAN="100%"><FONT SIZE="3"><CFOUTPUT><B>#Contract_Title#</B></CFOUTPUT></FONT></TD>
</TR>
</TABLE>


<!--- 
You have selected <strong><cfoutput>#Contract_Title#</cfoutput></strong> as your program.
<p>
Please select a Distributor:
</p>
 --->

<cfoutput>
<IFRAME SRC="distributor_list.cfm?ProgramList=#Form.Program_List#" NAME="toc" ID="toc" WIDTH="90%" HEIGHT="424" MARGINWIDTH="0" MARGINHEIGHT="0" frameborder="0"></IFRAME>
</cfoutput>
<br>
</cfif>


</td>
</tr>
</table>
</div>
<!---Show Ledger is 0--->
<cfelse>

<!---If they have selected both distributor and program--->


<cfif CalledFrom IS NOT "Scheduled">
<TABLE ALIGN="center" WIDTH="90%" CELLPADDING="5" BORDER="0">
<TR>

<TD NOWRAP><strong><font color="red">[</font> <font color="blue"><a href="index.cfm">Choose Another <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>/Program</a></font> <font color="red">]</font></strong></TD>

<cfinclude template="details/shared_settings.cfm">
<cfif CalledFrom IS NOT "Scheduled" AND ShowDetails IS 0>
<TD NOWRAP><strong><font color="red">[ </font> <font color="blue">
<B>
<a href="#" onclick="return AllOpenLayers(1, this, 1)" name="a_show_all_details"> Show All Details </a></font><font color="red">]</font></b></td>

<TD NOWRAP ALIGN="center">
<b><font color="red">[</font> <font color="blue">
<a href="#" onclick="return startFind();">Find</a></font> <font color="red">]</font>
</B>
</cfif>

<!--- Can't do now with multiple selections --->
	 
	<!---<TD NOWRAP ALIGN="center"><strong><font color="red">[</font> <font color="blue"><a href="index.cfm?ProgramList=<cfoutput>#FinalProgramList#</cfoutput>&ShowLedger=0">Choose Another <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></a></font> <font color="red">]</font></strong></TD> 
	<TD NOWRAP ALIGN="right"><strong><font color="red">[</font> <font color="blue"><a href="index.cfm?DistributorList=<cfoutput>#FinalDistributorList#</cfoutput>&ShowLedger=0">Choose Another Program</a></font> <font color="red">]</font></strong></TD>--->

</TR>
</TABLE>
</cfif>





<!---The guts of the display--->
<Cfif appSettings.getUse_AccrualLog_For_TC() IS 1>
	<!---Uses accrual log --->
	<cfinclude template="index_inc.cfm">
<cfelse>
	<!---Do it the old way, calculating on the fly, instead of from accrual log--->
	<cfinclude template="index_inc_old.cfm">
</CFIF>


<!---ShowLedger IS 0--->


<script>
/*
function AllOpenLayers(bExpand)
{	
	var allFieldsets = document.getElementsByTagName("fieldset");
	var i, FieldsetLen, thisFieldsetID, nameLast;
	var divObj, imgObj;
	FieldsetLen = allFieldsets.length;
	var checkToken = "border_";
	for(i=0;i<FieldsetLen;i++)
	{
		if(allFieldsets[i].id)
		{
			thisFieldsetID = allFieldsets[i].id;
			if(thisFieldsetID.substr(0,checkToken.length) == checkToken)
			{
				nameLast = thisFieldsetID.substr(checkToken.length,thisFieldsetID.length-checkToken.length);
				eval("divObj = allFieldsets[i].all.lyrGroup_" + nameLast);
				eval("imgObj = allFieldsets[i].all.title_" + nameLast);					
				divObj.style.display = "none";
				imgObj.click();
			}
		}
	}	
	return false;
}
function HideAllOpenLayers(bExpand)
{	
	var allFieldsets = document.getElementsByTagName("fieldset");
	var i, FieldsetLen, thisFieldsetID, nameLast;
	var divObj, imgObj;
	FieldsetLen = allFieldsets.length;
	var checkToken = "border_";
	for(i=0;i<FieldsetLen;i++)
	{
		if(allFieldsets[i].id)
		{
			thisFieldsetID = allFieldsets[i].id;
			if(thisFieldsetID.substr(0,checkToken.length) == checkToken)
			{
				nameLast = thisFieldsetID.substr(checkToken.length,thisFieldsetID.length-checkToken.length);
				eval("divObj = allFieldsets[i].all.lyrGroup_" + nameLast);
				eval("imgObj = allFieldsets[i].all.title_" + nameLast);					
				divObj.style.display = "block";
				imgObj.click();
			}
		}
	}	
	return false;
}
	function sync() {
		
	}*/
</script>
<cfif CalledFrom IS NOT "Scheduled">
<div align="left">
<table border="0" >
<tr>
	<!--- <TD>
		<CF_button
			button_name		=	""
			button_caption	=	"Show all Details"
			button_action	=	"AllOpenLayers(1, null)"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Show all Details"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
		<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"Hide all Details"
			button_action	=	"HideAllOpenLayers(1, null)"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Show all Details"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD> --->
	<Td width="60">&nbsp; </TD>
	<TD align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"NewWindow('/billbacks/ledger/utilities/printer_friendly.cfm?FinalDistributorList=#FinalDistributorList#&FinalProgramList=#FinalProgramList#&ShowDetails=1&PageName=index_inc.cfm','name','800','600','Yes', 'Yes')"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Print this information"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>

	<TD align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"email"
			button_action	=	"window.location.href='/billbacks/ledger/utilities/email_create.cfm?PageName=index_inc.cfm&FinalDistributorList=#FinalDistributorList#&FinalProgramList=#FinalProgramList#'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Email this information"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
	<TD align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"fax"
			button_action	=	"window.location.href='/billbacks/ledger/utilities/fax_create.cfm?PageName=index_inc.cfm&FinalDistributorList=#FinalDistributorList#&FinalProgramList=#FinalProgramList#'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare the contents of a fax to be sent"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
 --->
</td></tr>
</cfif>
</table>
</div>
<!---end display--->


<!---Footer--->

<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</cfif>

</BODY>
</HTML>
