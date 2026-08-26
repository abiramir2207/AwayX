<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<CFSET PAGE_TITLE="#appsettings.getPullbackLabel()# Item Details">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<style>
		TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
		#header {font-size: 12px;}
		
		table.sortable a.sortheader {
    	font-weight: bold;
    	text-decoration: none;
    	display: block;
			}
		table.sortable span.sortarrow {
	    color: black;
 		text-decoration: none;
		}

	</style>

</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<cfparam name="form.PRINTONLY" default="0">

<cfif form.PRINTONLY eq 0>
<!----------------- Add Spinner ------------------------>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
</cfif>

<CFSET listOfUsedIDS = "">
<cfparam name="url.contract_main_id" default="">
<cfparam name="url.FromDistributor_Prg" default="">
<cfparam name="FORM.sort_order" 	default="DESC">
<cfparam name="FORM.sort_by" 	default="IT">
<cfparam name="form.sql_Sort_By" default="item">

<CFSWITCH expression="#FORM.sort_by#">
	<CFCASE value="IT">
		<CFSET form.sql_Sort_By="item">
	</CFCASE>
	<CFCASE value="DS">
		<CFSET form.sql_Sort_By="description">
	</CFCASE>	
</CFSWITCH>

<CFSET ASC_IMG="down_1.gif">
<CFSET DESC_IMG="up_1.gif">

<cfset checksortby = FORM.sort_by>
<CFIF FORM.sort_order EQ "ASC">
	<CFSET Current_Image = ASC_IMG>
<CFELSE>
	<CFSET Current_Image = DESC_IMG>			
</CFIF>


<cfif url.contract_main_id NEQ "">
<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
<!--- <cfset GetProducts = PullbackManager.viewProductlist(url.contract_main_id,url.distributor_id)>
<cfset GetDistDetails = PullbackManager.GetDistDetails(url.distributor_id)> --->
<cfset GetcontractDetails = PullbackManager.GetcontractDetails(url.Dist_PrgId)>
<cfset getoprcontractdetails = PullbackManager.GetcontractDetails(url.contract_main_id)>
<cfset getDefaultPullbackRate = PullbackManager.getDefaultPullbackRate(url.Dist_PrgId,getoprcontractdetails.ProgramControl_Panel_Options_ID)>
<cfif getDefaultPullbackRate.recordcount GT 0>
<cfset default_pullback_rate = getDefaultPullbackRate.Pullback_Default_Rate>
<cfelse>
<cfset default_pullback_rate = 0>
</cfif>
<cfset GetDistDetails = PullbackManager.GetDistDetails(url.DistId)>
<cfif url.FromDistributor_Prg EQ 0>
<cfset GetDistItemDetails = PullbackManager.GetDistItemDetails(url.Dist_PrgId,url.Contract_Main_ID,url.DistId,form.sql_Sort_By,FORM.sort_order)>
<cfelse>
<cfset GetDistItemDetails = PullbackManager.GetDistItemDetails(url.Contract_Main_ID,url.Dist_PrgId,url.DistId,form.sql_Sort_By,FORM.sort_order)>
</cfif>

<CFOUTPUT>
<TABLE WIDTH="95%" border="0" CELLPADDING="0" CELLSPACING="0" class="maintable" align="center">
	<tr>
	<td colspan="100%"><SPAN CLASS="TITLE2"><center><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Information</center></SPAN></td>
	</tr>
	<TR bgcolor="C6FFC6">
		<TD STYLE="font-size: 12px; color: NAVY;" colspan="50%" align="left">
		<B>Program:</B>&nbsp;[#GetcontractDetails.Contract_Number#]<br>
		<B>Title:</B>&nbsp;#GetcontractDetails.contract_title#<br>
		<B>Start Date:</B>&nbsp;#DateFormat(GetcontractDetails.Contract_Start_Date,"mm/dd/yyyy")# - <B>End Date:</B>&nbsp;#DateFormat(GetcontractDetails.Contract_End_Date,"mm/dd/yyyy")#&nbsp;&nbsp;</TD>
		<TD STYLE="font-size: 12px; color: NAVY;" colspan="50%" align="left" valign="top">
		<B><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Name:</B> #GetDistDetails.name#<br>
		<B><cfoutput>#application.returned_customer_setting.shard_ship_to_label#</cfoutput>:</B>&nbsp;#GetDistDetails.shr_ship_to#<br>
		<strong>Default Template <cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Rate:</strong> &nbsp;#default_pullback_rate#%
		</TD>
	</TR>
</TABLE>
<cfif GetDistItemDetails.recordcount gt 0>
<TABLE class="sortable" WIDTH="95%" align="center" CELLPADDING="3" CELLSPACING="0" border="0">
<TR BGCOLOR="##FFCE84" VALIGN="bottom">
			<TD ID="header" NOWRAP><cfif form.PRINTONLY eq 0> <strong><A HREF="##" OnClick="javaScript: setSortHref('IT');"><B>#application.returned_customer_setting.item_label#</B></A><SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "IT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN><cfelse><B>#application.returned_customer_setting.item_label#</B></cfif></TD>
			<TD ID="header"><cfif form.PRINTONLY eq 0><A HREF="##" OnClick="javaScript: setSortHref('DS');"><B>Description</B></A><SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "DS"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN><cfelse><B>Description</B></cfif></TD>
			<TD ID="header"><B><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Rate</B></TD>
</TR>
<Cfloop query="GetDistItemDetails">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<TD valign="top">#item#</TD>
			<TD valign="top">#description#</TD>
			<TD valign="top">#pullback_value#%</TD>
		</TR>
</cfloop>
</table>
<cfelse>
<span STYLE="font: bold 14px sans-serif; color: red;">No Items found.</span><br><br>
</cfif></CFOUTPUT>
<cfelse>
<span STYLE="font: bold 14px sans-serif; color: red;">Invalid <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Name. Please try again.</span><br><br>
</cfif>

<cfoutput><FORM ACTION="view_pullback_dis_item_details.cfm?contract_main_id=#url.contract_main_id#&DistId=#url.DistId#&Dist_PrgId=#url.Dist_PrgId#&FromDistributor_Prg=#url.FromDistributor_Prg#" METHOD="post" NAME="Templates" STYLE="DISPLAY:INLINE">
<input type="hidden" name="sort_by" value="">
<input type="hidden" name="sort_Order" value="">
<input type="hidden" name="printonly" value="0">
<input type="hidden" name="Include_File_path" value="/common_files/contracts/pullbacks/view_pullback_dis_item_details.cfm">
</FORM></cfoutput>
<cfinclude template="pullbacks_js.cfm">

<script>
function printform()
{
NewWindow('','PrintEmailWin','760','600','Yes', 'Yes');
document.all.Templates.printonly.value=1;
document.Templates.target = "PrintEmailWin";
<cfoutput>document.Templates.action = "/common_files/contracts/print_payment_history.cfm?contract_main_id=#url.contract_main_id#&DistId=#url.DistId#&Dist_PrgId=#url.Dist_PrgId#&FromDistributor_Prg=#url.FromDistributor_Prg#";</cfoutput>
document.all.Templates.submit();	
}
</script>
</Body>
</html>