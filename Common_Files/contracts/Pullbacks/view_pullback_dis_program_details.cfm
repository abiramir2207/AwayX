<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<CFSET PAGE_TITLE="#appsettings.getPullbackLabel()# Program - #application.returned_customer_setting.distributor_label_singular# Details">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<script src="/script/javascript/sorttable.js"></script>
		<script>
		function toggleRateDisplay(ID,sts) {
			tempVar = eval("document.all.RS_"+ID);
			if(tempVar != null){
				if(sts == 0) {
					if(tempVar[0].style.display == "none") {
						toggleStatus = ""
					}
					else {
						toggleStatus = "none"
					}
				}
				else{
					toggleStatus = sts
				}
					tempVar.style.display = toggleStatus;
			}
		}	
	</script>
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

<cfparam name="FORM.sort_by" 	default="CN">
<cfparam name="form.sql_Sort_By" default="contract_number">

<CFSWITCH expression="#FORM.sort_by#">
	<CFCASE value="CN">
		<CFSET form.sql_Sort_By="contract_number">
	</CFCASE>
	<CFCASE value="CT">
		<CFSET form.sql_Sort_By="contract_title">
	</CFCASE>	
	<CFCASE value="CS">
		<CFSET form.sql_Sort_By="contract_start_date">
	</CFCASE>
	<CFCASE value="CE">
		<CFSET form.sql_Sort_By="contract_end_date">
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



<cfif url.contract_main_id NEQ "" and  url.templateid NEQ "" >
<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
<!--- <cfset GetProducts = PullbackManager.viewProductlist(url.contract_main_id,url.distributor_id)>
<cfset GetDistDetails = PullbackManager.GetDistDetails(url.distributor_id)> --->
<cfset GetcontractDetails = PullbackManager.GetcontractDetails(url.Contract_Main_ID)>
<cfset GettemplateDetails = PullbackManager.GettemplateDetails(url.templateid)>

<cfif url.FromDistributor_Prg EQ 0>
<cfset GettemplateProgramDetails = PullbackManager.GettemplateDisProgramDetails(program_id=url.Contract_Main_ID,
template_id=url.templateid,sql_Sort_By=form.sql_Sort_By,
Sort_order=FORM.sort_order,
opr_templateid=GetcontractDetails.ProgramControl_Panel_Options_ID)>
<cfelse>
<cfset GettemplateProgramDetails = PullbackManager.GettemplateOprProgramDetails(url.Contract_Main_ID,url.templateid,form.sql_Sort_By,FORM.sort_order)>
</cfif>


<CFOUTPUT>
<TABLE WIDTH="95%" border="0" CELLPADDING="0" CELLSPACING="0" class="maintable" align="center">
	<tr>
	<td colspan="100%"><SPAN CLASS="TITLE2"><center><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Amount Information</center></SPAN></td>
	</tr>
	<TR bgcolor="C6FFC6">
		<TD STYLE="font-size: 12px; color: NAVY;" colspan="50%" align="left">
		<B>Program:</B>&nbsp;[#GetcontractDetails.Contract_Number#]<br>
		<B>Title:</B>&nbsp;#GetcontractDetails.contract_title#<br>
		<B>Start Date:</B>&nbsp;#DateFormat(GetcontractDetails.Contract_Start_Date,"mm/dd/yyyy")# - <B>End Date:</B>&nbsp;#DateFormat(GetcontractDetails.Contract_End_Date,"mm/dd/yyyy")#&nbsp;&nbsp;</TD>
		<TD STYLE="font-size: 12px; color: NAVY;" colspan="50%" align="left" valign="top">
		<B>Created Type:</B> #GettemplateDetails.created_type#<br>
		</TD>
	</TR>
</TABLE>
<br>
</CFOUTPUT>
<cfif GettemplateProgramDetails.recordcount GT 0>

<TABLE BORDER="0" width="95%"  CELLPADDING="0" CELLSPACING="0" align="center" class="maintable">
<cfif form.PRINTONLY eq 0>
<TR>
<TD id="header" style="font-size: 12px;"> <strong><A HREF="##" OnClick="javaScript: setSortHref('CN');">Contract Number</A></strong>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "CN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
<TD id="header" style="font-size: 12px;"> <strong><A HREF="##" OnClick="javaScript: setSortHref('CT');">Contract Title</A></strong>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "CT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
<TD id="header" style="font-size: 12px;"> <strong><A HREF="##" OnClick="javaScript: setSortHref('CS');">Start Date</A></strong>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "CS"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
<TD id="header" style="font-size: 12px;"> <strong><A HREF="##" OnClick="javaScript: setSortHref('CE');">End Date</A></strong>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "CE"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
<cfif url.FromDistributor_Prg EQ 0>
<TD id="header" style="font-size: 12px;"> <strong><A HREF="##" OnClick="javaScript: setSortHref('CE');">Default <cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Rate</A></strong>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "CE"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
</cfif>
</TR>
<cfelse>
<TR>
<TD id="header" style="font-size: 12px;"> <strong>Contract Number</strong></td>
<TD id="header" style="font-size: 12px;"> <strong>Contract Title</strong></td>
<TD id="header" style="font-size: 12px;"> <strong>Start Date</strong></td>
<TD id="header" style="font-size: 12px;"> <strong>End Date</strong></td>
</TR>
</cfif>
<cfoutput query="GettemplateProgramDetails">
<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="center" height="20">
		<TD STYLE="border-bottom: 0px; color: NAVY;">
		#Replace(Contract_Number,"000-","")#-<cfif len(revision_version) eq 4>#right("#revision_version#", 4)#<cfelseif len(revision_version) eq 5>#right("#revision_version#", 5)#<cfelse>#right("000#revision_version#", 3)#</cfif>
		<cfif form.PRINTONLY eq 0><span style="color: black; font-weight:bold;"><a onclick="toggleAllToSameStatus('#program_id#','inline')" style="cursor:hand; color:red;"><font color="blue">[</font>show<font color="blue">]</font></a> or <a onclick="toggleAllToSameStatus('#program_id#','none')" style="cursor:hand; color:red;"><font color="blue">[</font>hide<font color="blue">]</font></a></span></cfif></TD>
</TD>
<TD STYLE="border-bottom: 0px;color: NAVY">#Contract_Title#</TD>
<TD STYLE="border-bottom: 0px;color: NAVY">#dateformat(contract_start_date,"mm/dd/yyyy")#</TD>
<TD STYLE="border-bottom: 0px;color: NAVY">#dateformat(contract_end_date,"mm/dd/yyyy")#</TD>
<cfif url.FromDistributor_Prg EQ 0>
<TD STYLE="border-bottom: 0px;color: NAVY">#Pullback_Default_Rate#%</TD>
</cfif>
</TR>
<TR>
<TD colspan="100%" id="RS_#program_id#" <cfif form.PRINTONLY eq 0>style="display:none"</cfif>>
<TABLE <cfif form.PRINTONLY eq 0>class="sortable"</cfif> WIDTH="95%" align="center" CELLPADDING="3" CELLSPACING="0" border="0" id="TB_#program_id#">
<TR BGCOLOR="##FFCE84" VALIGN="bottom">
			<TD ID="header" NOWRAP><B>#application.returned_customer_setting.distributor_label_singular#</B></TD>
			<TD ID="header"><B>#application.returned_customer_setting.shard_ship_to_label#</B></TD>
			<TD ID="header"><B>Max #appsettings.getPullbackLabel()# Rate</B></TD>
</TR>
<cfif url.FromDistributor_Prg EQ 0>
<cfset GetProgramDistDetails = PullbackManager.GetProgramDistDetails(program_id,url.contract_main_id)>
<cfelse>
<cfset GetProgramDistDetails = PullbackManager.GetProgramDistDetails(url.contract_main_id,program_id)>
</cfif>
<cfset dist_prg_id = GettemplateProgramDetails.program_id>
<Cfloop query="GetProgramDistDetails">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<TD valign="top"><cfif form.PRINTONLY eq 0><A href="##"><span style="cursor:hand;  text-decoration: none;" onclick="getdisitemdetails('#dist_prg_id#','#GetProgramDistDetails.BSA_Foodservice_Customers_id#');">#name#</A><cfelse>#name#</cfif></TD>
			<TD valign="top">#shr_ship_to#</TD>
			<TD valign="top">#max_pullback_value#% &nbsp;<cfif max_pullback_value neq GettemplateDetails.default_pullback_rate or min_pullback_value neq GettemplateDetails.default_pullback_rate><CFMODULE template="/CustomTags/SmallHelp.cfm"
					width = "100"
					height = "100"
					imgPath="/Images/Asterix.gif"
					imgWidth="10"
					imgHeight="10"
					dropdownCheck=0
					>The maximum <cfoutput>#appsettings.getPullbackLabel()#</cfoutput> rate is not same as the default template <cfoutput>#appsettings.getPullbackLabel()#</cfoutput> rate.
			</cfmodule></cfif></TD>
		</TR>
</cfloop>
</table>
</TD></TR>
</cfoutput>
</TABLE>

<cfelse>
<span STYLE="font: bold 14px sans-serif; color: red;">No programs found.</span><br><br>

</cfif>
<cfelse>
<span STYLE="font: bold 14px sans-serif; color: red;">Invalid Template Name. Please try again.</span><br><br>
</cfif>

<script>
function getdisitemdetails(Dist_PrgId,DistId)
{
NewWindow('/common_files/contracts/pullbacks/view_pullback_dis_item_details.cfm?<cfoutput>contract_main_id=#url.Contract_Main_ID#</cfoutput>&FromDistributor_Prg=<cfoutput>#url.FromDistributor_Prg#</cfoutput>&DistId='+DistId+'&Dist_PrgId='+Dist_PrgId,'pullbackdistributoritemdetails','800','620','Yes', 'No');
}
</script>
<cfoutput><FORM ACTION="view_pullback_dis_program_details.cfm?contract_main_id=#url.contract_main_id#&TemplateId=#url.TemplateId#&FromDistributor_Prg=#url.FromDistributor_Prg#" METHOD="post" NAME="Templates" STYLE="DISPLAY:INLINE">
<input type="hidden" name="sort_by" value="">
<input type="hidden" name="sort_Order" value="">
<input type="hidden" name="printonly" value="0">
<input type="hidden" name="Include_File_path" value="/common_files/contracts/pullbacks/view_pullback_dis_program_details.cfm">
</FORM></cfoutput>
<script>
	function toggleAllToSameStatus(id,status)
	 {
			toggleRateDisplay(id,status);
	}
</script>
<cfinclude template="pullbacks_js.cfm">
<script>
function printform()
{
NewWindow('','PrintEmailWin','760','600','Yes', 'Yes');
document.all.Templates.printonly.value=1;
document.Templates.target = "PrintEmailWin";
<cfoutput>document.Templates.action = "/common_files/contracts/print_payment_history.cfm?contract_main_id=#url.contract_main_id#&TemplateId=#url.TemplateId#&FromDistributor_Prg=#url.FromDistributor_Prg#";</cfoutput>
document.all.Templates.submit();	
}
</script>
</Body>
</html>