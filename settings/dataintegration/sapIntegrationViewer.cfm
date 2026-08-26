<CFSET URL.PageTitle="Settlements">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<cfset fore_Color="CC3300">
<CFPARAM NAME="URL.StartRow" DEFAULT="1">
<CFPARAM NAME="URL.frompage" DEFAULT="1">

 <CFPARAM NAME="FORM.StartRow" DEFAULT="#URL.StartRow#">
<CFPARAM NAME="FORM.frompage" DEFAULT="#URL.frompage#">

<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="approved_date">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="desc">
<cfparam name="next_program_id" default="">

<CFIF FORM.SORT_ORDER NEQ "DESC">
	<CFSET FORM.SORT_ORDER = "ASC">
</CFIF>
<CFSET SQL_Sort_by = "approved_date desc, program_id,Program_Webservices_Detail.bsa_program_id,pactiv_program_id,message_text,message_type">

<CFSWITCH EXPRESSION="#LCase(FORM.SORT_BY)#">
	<CFCASE VALUE="bsa_program_id">
		<CFSET SQL_Sort_by = "REQ.Rebate_ID">
	</CFCASE>
	<CFCASE VALUE="pactiv_program_id">
		<CFSET SQL_Sort_by = "REQ.Rebate_Ref_ID">
	</CFCASE>
	<CFCASE VALUE="message_type">
		<CFSET SQL_Sort_by = "message_type">
	</CFCASE>
	<CFCASE VALUE="approved_date">
		<CFSET SQL_Sort_by = "approved_date">
	</CFCASE>
</CFSWITCH>

<CFSET SQL_Sort_by = " #SQL_Sort_by# #FORM.SORT_ORDER#">

<cfset WebservicesManager = CreateObject("component","components.programs.Approval.Webservices_Manager") />
<cfif isdefined("form.bsa_program_id") and form.bsa_program_id NEQ "">
	<cfset getSettlementHistory = WebservicesManager.getSettlementHistory(form.bsa_program_id)>
<cfelseif isdefined("form.pactiv_program_id") and form.pactiv_program_id NEQ "">
	<cfset getSettlementHistory = WebservicesManager.getSettlementHistory('',form.pactiv_program_id)>
<cfelse>
	<cfset getSettlementHistory = WebservicesManager.getSettlementHistory('','',SQL_Sort_by)>
</cfif>

<CFSET StartRow = FORM.StartRow>
<CFSET frompage = FORM.frompage>
<cf_Number_of_Rows maxrows=20>

<HTML>
<HEAD>
<STYLE>
TABLE.UnderLine TD
{
	border-bottom: 1px #93BEE2 solid; 
}
</STYLE>
</HEAD>
<BODY>
 <TABLE width="430">
<FORM ACTION="sapIntegrationViewer.cfm" METHOD="post" NAME="saprebatechildren" ID="saprebatechildren">
<TR>
  <TD><font size="2"><b>Blacksmith Rebate Id:</b></font></TD>
<TD>
<font size="2">
<input name="bsa_program_id" type="text" size="20"/>
</font>
</TD>
<TD><CF_button
	button_name		=	""
	button_caption	=	"search"
	button_action	=	"saprebatechildren.submit();"
	button_type		=	"javascript_link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>	</TD>
</TR>
<tr>
  <TD><font size="2"><b>SAP Rebate Id:</b></font></TD>
<td><input name="pactiv_program_id" type="text" size="20"/></td>
</tr>
<cfoutput><INPUT TYPE="Hidden" NAME="SORT_BY" VALUE="#FORM.SORT_BY#">
	<INPUT TYPE="Hidden" NAME="SORT_ORDER" VALUE="#FORM.SORT_ORDER#">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#form.startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#form.frompage#"></cfoutput>
	</form>
</TABLE> 
<br>
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" width="100%" CLASS="UnderLine" align="center"><TR bgcolor="CC3300">
<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		<CFOUTPUT>
		<CFSET Sort_By_Display_List = "BSA Rebate Id, Pactiv Rebate Id,Message Type,Message Details,Sent Date">
		<CFSET Sort_By_Value_List = "bsa_program_id,pactiv_program_id,Message_Type,Message_Details,approved_date">
		<CFSET Counter = 1>
		<CFLOOP LIST="#Sort_By_Value_List#" INDEX="This_Header_Item">
			<CFSET This_Sort_Order = "ASC">
			<CFSET This_Img = "">
			<CFIF LCase(This_Header_Item) EQ LCase(FORM.SORT_BY)>
				<CFIF FORM.SORT_ORDER EQ "ASC">
					<CFSET This_Sort_Order = "DESC">
					<CFSET This_Img = "down_1.gif">
				<CFELSE>
					<CFSET This_Img = "up_1.gif">
				</CFIF>
			</CFIF>
			<CFSET Display_Name = ListGetAt(Sort_By_Display_List, Counter, ",")>
			<cfif Display_Name NEQ "Message Details">
				<TD ID="header"><A HREF="##" onClick="javaScript:return sortBy('#This_Header_Item#','#This_Sort_Order#');"><B>#Display_Name#</B></A>
			<CFIF Len(This_Img) GT 0><IMG SRC="/Images/#This_Img#" BORDER="0"></CFIF>
				</TD>
			<cfelse>
				<TD ID="header"><B>Message Details</B></TD>
			</cfif>
			<CFSET Counter = Counter + 1>
		</CFLOOP>
		</CFOUTPUT>
		
		<!--- <TD ID="header"><B>Send To SAP</B></TD> --->
	</TR>
	<cfif getSettlementHistory.recordcount GT 0>
<cfset i = 1>
	<CFOUTPUT QUERY="getSettlementHistory" startrow="#StartRow#" maxrows="#MaxRows#">
		<cfset current_program_id = getSettlementHistory.bsa_program_id>
		<!--- <cfif trim(current_program_id) NEQ trim(next_program_id)> --->
		<TR BGCOLOR="#IIf(i Mod 2, DE('ffffff'), DE('C6FFC6'))#">
		<TD STYLE="font-size:10px">#bsa_program_id#&nbsp;</TD>
		
		<cfset useLakebaseForitemcount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getsettlementhistory")>
<cfif useLakebaseForitemcount>
	<cftry>
		<cfset itemcount = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getsettlementhistory", {
				"bsa_program_id" = "eq.#bsa_program_id#",
				"message_type" = "eq.S"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForitemcount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForitemcount>
<CFQUERY NAME="itemcount" DBTYPE="query">
			select * from getSettlementHistory
			where bsa_program_id = '#bsa_program_id#'
			and message_type = 'S'
		</CFQUERY>
</cfif>
		<cfif itemcount.recordcount GT 0>
			<TD STYLE="font-size:10px" align="center">#itemcount.pactiv_program_id#&nbsp;</TD>
			<TD STYLE="font-size:10px" align="center">Success</TD>
			<TD STYLE="font-size:10px">#itemcount.message_text#</TD>
		<cfelse>
			<cfif pactiv_program_id neq 0>
				<TD STYLE="font-size:10px" align="center">#pactiv_program_id#&nbsp;</TD>
			<cfelse>
				<TD STYLE="font-size:10px" align="center">&nbsp;</TD>
			</cfif>
			 <TD STYLE="font-size:10px" align="center">Failed</TD>
		<TD STYLE="font-size:10px"><A STYLE="cursor:pointer;"ONCLICK="showSAPerrorDetails('#bsa_program_id#')">Click here for Error Details</A></TD>
		</cfif>
		<TD STYLE="font-size:10px">#Dateformat(approved_date, "mm/dd/yyyy")#</TD>
		<cfif itemcount.recordcount GT 0>
			<TD STYLE="font-size:10px">&nbsp;</TD>
		<cfelse>
			<!--- <TD STYLE="font-size:10px"><A STYLE="cursor:pointer;"ONCLICK="sendRebatetoSAP('#bsa_program_id#')">Click here</A></TD> --->
		</cfif>
</TR>
<cfset i=i+1>
<!--- </cfif> --->
<cfset next_program_id = getSettlementHistory.bsa_program_id>
	</CFOUTPUT>
</cfif>
</TABLE>
<TABLE>
<TR>
<TD>
<CFIF getSettlementHistory.recordcount GT 0>
<CF_Next_Previous_For_Forms
	formname="MyForm"
	query="getSettlementHistory"
	maxpages="30"
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	firstseries		=	"<IMG SRC=""/images/first_series.gif"" ALIGN=""middle"" BORDER=""0"">"	
	lastseries		=	"<IMG SRC=""/images/last_series.gif"" ALIGN=""middle"" BORDER=""0"">"		
	addparams="">
	</CFIF>
</TD>
<TD><B><FONT SIZE="2" COLOR="Navy">There<CFIF getSettlementHistory.recordcount EQ 0> Are No Rebates <CFELSEIF getSettlementHistory.recordcount EQ 1> Is A Rebate.<CFELSE> Are <CFOUTPUT>#getSettlementHistory.recordcount#</CFOUTPUT> Rebates.</CFIF> </FONT></B></TD>
<TD>&nbsp;&nbsp;<cfif isdefined("form.bsa_program_id") OR isdefined("form.pactiv_program_id")><A STYLE="cursor:pointer;" href="saprebatechildren.cfm" target="mainwindow"><b>Display ALL</b></A></cfif></TD>
</TR>
</TABLE>
<cfoutput><FORM ACTION="#CGI.SCRIPT_NAME#" METHOD="post" NAME="MyForm" ID="MyForm">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
<INPUT TYPE="Hidden" NAME="SORT_BY" VALUE="#FORM.SORT_BY#">
	<INPUT TYPE="Hidden" NAME="SORT_ORDER" VALUE="#FORM.SORT_ORDER#">
<!--- <INPUT TYPE="Hidden" NAME="title" VALUE="#title#"> --->
<!--- <INPUT TYPE="Hidden" NAME="currentProgramList" VALUE="#form.currentProgramList#"> --->
</FORM></cfoutput>
<SCRIPT LANGUAGE="javaScript">
	function getthisPage(thisObj)
	{
		thisObj.submit();
		return false;
	}
	
	function showSAPerrorDetails(CID){
			//window.open()
	NewWindow('show_sap_error_details.cfm?CID='+ CID+'&type=S','ErrorDetails','450','450','Yes', 'Yes')		
		}
	function sendRebatetoSAP(CID){
			//window.open()
	NewWindow('send_rebate_to_sap.cfm?BSA_Program_Id='+ CID,'ErrorDetails','450','450','Yes', 'Yes')		
		}
	function sortBy(sVal, sOrder)
	{
		var searchFrm = document.saprebatechildren;
		searchFrm.SORT_BY.value = sVal;
		searchFrm.SORT_ORDER.value = sOrder;
		searchFrm.submit();
		return false;
	}
</SCRIPT>
</BODY>
</HTML>
