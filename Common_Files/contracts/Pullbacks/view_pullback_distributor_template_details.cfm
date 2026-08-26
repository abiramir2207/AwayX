<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<CFSET PAGE_TITLE= "#appsettings.getPullbackLabel()# Amounts">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="">


<cfparam name="FORM.sort_order" 	default="DESC">
<cfparam name="FORM.sort_by" 	default="TN">
<cfparam name="form.sql_Sort_By" default="Program_Control_Panel_Options.created_type">

<CFSWITCH expression="#FORM.sort_by#">
	<CFCASE value="TN">
		<CFSET form.sql_Sort_By="Program_Control_Panel_Options.created_type">
	</CFCASE>
	<CFCASE value="TD">
		<CFSET form.sql_Sort_By="program_description">
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
<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />

<cfif url.FromDistributor_Prg EQ 0>
<cfset Gettemplates = PullbackManager.GetDisttemplates(CSL_Contract_Main_ID,form.sql_Sort_By,FORM.sort_order)>
<cfelse>
<cfset Gettemplates = PullbackManager.GetOprtemplates(CSL_Contract_Main_ID,form.sql_Sort_By,FORM.sort_order)>
</cfif>

 <table width="780" class="maintable" CELLPADDING="0" CELLSPACING="0">
 <tr  bgcolor="C6FFC6">
<TD id="header" style="font-size: 12px;"> <strong><A HREF="##" OnClick="javaScript: setSortHref('TN');">Program Type</A></strong>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "TN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
 <td id="header" style="font-size: 12px;"><A HREF="##" OnClick="javaScript: setSortHref('TD');"><strong>Description</strong></A><SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "TD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN></TD>
 </TR>
 <cfif Gettemplates.recordcount GT 0>
 <cfoutput query="Gettemplates">
 <TR height="20">
 <TD><A href="##"><span style="cursor:pointer;  text-decoration: none;" onclick="getdisprograms('#Gettemplates.created_type#');">#created_type#</A></TD>
 <TD><A href="##"><span style="cursor:pointer;  text-decoration: none;" onclick="getdisprograms('#Gettemplates.created_type#');">#program_description#</A></TD>
 </TR>
 </cfoutput>
 <cfelse>
 <TR>
 <TD><strong>No templates found.</strong></TD>
 </TR>
  </cfif>
</TABLE>
<table>
<tr>
<td>
<CF_button

			button_name		=	""
			button_caption	=	"Back"
			button_action	=	"history.back()"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Submit"
			font_color		=	"White"
			font_size		=	"14"
			font_weight		=	"bold"
			></td>
</TR>
</TABLE>
<FORM ACTION="pullback_index.cfm?CID=<CFOUTPUT>#url.CID#</CFOUTPUT>&FromDistributor_Prg=<cfoutput>#url.FromDistributor_Prg#</cfoutput>" METHOD="post" NAME="DistPrograms" STYLE="DISPLAY:INLINE">
<input type="hidden" name="sort_by" value="">
<input type="hidden" name="sort_Order" value="">
<input type="hidden" name="pagetype" value="">
<input type="hidden" name="viewtype" value="templateview">
<input type="hidden" name="command" value="view">
</FORM>
<script>
function getdisprograms(TempId)
{
NewWindow('/common_files/contracts/pullbacks/view_pullback_dis_program_details.cfm?<cfoutput>contract_main_id=#CSL_Contract_Main_ID#</cfoutput>&FromDistributor_Prg=<cfoutput>#url.FromDistributor_Prg#</cfoutput>&TemplateId='+TempId,'pullbackdistributordetails','800','620','Yes', 'No');
}
</script>
