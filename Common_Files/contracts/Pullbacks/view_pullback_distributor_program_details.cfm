
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<CFSET PAGE_TITLE="#appsettings.getPullbackLabel()# Program - Distributor Details">
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

<!----------------- Add Spinner ------------------------>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<CFSET listOfUsedIDS = "">
<cfparam name="url.contract_main_id" default="">
<cfparam name="url.FromDistributor_Prg" default="0">
<cfparam name="form.distributor_id" default="">
<cfparam name="url.distributor_id" default="">
<cfparam name="FORM.sort_order" 	default="DESC">
<cfparam name="url.display" default="0">

<cfparam name="FORM.sort_by" 	default="CN">
<cfparam name="form.sql_Sort_By" default="name">

<CFSWITCH expression="#FORM.sort_by#">
	<CFCASE value="CN">
		<CFSET form.sql_Sort_By="name">
	</CFCASE>
	<CFCASE value="ST">
		<CFSET form.sql_Sort_By="shr_ship_to">
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
<cfif url.distributor_id is not "">
<cfset distributor_id = url.distributor_id>
<cfelse>
<cfset distributor_id = form.distributor_id>
</cfif>


<cfif url.contract_main_id NEQ "" and distributor_id NEQ "" >
<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
<cfset GetcontractDetails = PullbackManager.GetcontractDetails(url.Contract_Main_ID)>

<cfset GetselectedDistributorDetails = PullbackManager.GetDistDetails(distributor_id,form.sql_Sort_By,FORM.sort_order,url.Contract_Main_ID)>
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
	</TR>
</TABLE>
<br>
</CFOUTPUT>
<cfif distributor_id NEQ "">

<TABLE BORDER="0" width="95%"  CELLPADDING="0" CELLSPACING="0" align="center" class="maintable">
<TR>
<TD id="header" style="font-size: 12px;"> <strong><A HREF="##" OnClick="javaScript: setSortHref('CN');"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Name</A></strong>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "CN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
<td colspan="2">&nbsp;</td>
<TD id="header" style="font-size: 12px;"> <strong><A HREF="##" OnClick="javaScript: setSortHref('ST');"><cfoutput>#application.returned_customer_setting.shard_ship_to_label#</cfoutput></A></strong>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "ST"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
</TR>
<cfoutput query="GetselectedDistributorDetails">
<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="center" height="20">
		<TD STYLE="border-bottom: 0px; color: NAVY;" width="150">
		#Name#</TD>
		<TD STYLE="border-bottom: 0px; color: NAVY;" align="left" colspan="2"><span style="color: black; font-weight:bold;"><a onclick="toggleAllToSameStatus('#replace(BSA_Foodservice_Customers_id,'-','_','ALL')#','inline')" style="cursor:pointer; color:red;"><font color="blue">[</font>show<font color="blue">]</font></a> or <a onclick="toggleAllToSameStatus('#replace(BSA_Foodservice_Customers_id,'-','_','ALL')#','none')" style="cursor:pointer; color:red;"><font color="blue">[</font>hide<font color="blue">]</font></a></span></TD>
</TD>
<TD STYLE="border-bottom: 0px;color: NAVY">#shr_ship_to#</TD>
</TR>
<cfif url.FromDistributor_Prg EQ 0>
<cfset GetcurrentDisProgramDetails = PullbackManager.GettemplateDisProgramDetails(program_id = url.Contract_Main_ID,distributors = GetselectedDistributorDetails.BSA_Foodservice_Customers_id,
opr_templateid=GetcontractDetails.ProgramControl_Panel_Options_ID)>
<cfelse>
<cfset GetcurrentDisProgramDetails = PullbackManager.GettemplateOprProgramDetails(program_id = url.Contract_Main_ID,distributors = GetselectedDistributorDetails.BSA_Foodservice_Customers_id)>
</cfif>
<cfset distributor_id = GetselectedDistributorDetails.BSA_Foodservice_Customers_id>
<TR>
<TD colspan="100%" id="RS_#replace(BSA_Foodservice_Customers_id,'-','_','ALL')#" style="display:<cfif url.display EQ 1>visible<cfelse>none</cfif>">
<cfif GetcurrentDisProgramDetails.recordcount GT 0>
<TABLE class="sortable" WIDTH="95%" align="center" CELLPADDING="3" CELLSPACING="0" border="0" id="TB_#replace(BSA_Foodservice_Customers_id,'-','_','ALL')#">
<TR BGCOLOR="##FFCE84" VALIGN="bottom">
			<TD ID="header" NOWRAP><B>Contract##</B></TD>
			<TD ID="header" width="200"><B>Contract Title</B></TD>
			<TD ID="header"><B>Start Date</B></TD>
			<TD ID="header"><B>End Date</B></TD>
			<TD ID="header"><B>Max #appsettings.getPullbackLabel()# Rate</B></TD>
			<TD ID="header"><B>Default #appsettings.getPullbackLabel()# Rate</B></TD>
</TR>
<Cfloop query="GetcurrentDisProgramDetails">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<TD valign="top"  width="100"><A href="##"><span style="cursor:pointer;  text-decoration: none;" onclick="getdisitemdetails('#program_id#','#distributor_id#');">#Replace(Contract_Number,"000-","")#-<cfif len(revision_version) eq 4>#right("#revision_version#", 4)#<cfelseif len(revision_version) eq 5>#right("#revision_version#", 5)#<cfelse>#right("000#revision_version#", 3)#</cfif></A></TD>
			<TD valign="top" width="200">#contract_title#</TD>
			<TD valign="top">#dateformat(contract_start_date,"mm/dd/yyyy")#</TD>
			<TD valign="top">#dateformat(contract_end_date,"mm/dd/yyyy")#</TD>
			<TD valign="top">#max_pullback_value#%&nbsp;
			<cfif max_pullback_value neq default_pullback_rate or min_pullback_value neq default_pullback_rate><CFMODULE template="/CustomTags/SmallHelp.cfm"
					width = "100"
					height = "100"
					imgPath="/Images/Asterix.gif"
					imgWidth="10"
					imgHeight="10"
					dropdownCheck=0
					>The maximum #appsettings.getPullbackLabel()# rate is not same as the default template #appsettings.getPullbackLabel()# rate.
			</cfmodule>
			</cfif></TD>
			<td>#Pullback_Default_Rate#%</td>
		</TR>
</cfloop>
</table>
<cfelse>
<!--- Dev Note: Clay 9983: Remove Duplicate Display of Pullback Label --->
No #appsettings.getPullbackLabel()#.
</cfif>
</TD></TR>
</cfoutput>
</TABLE>

<cfelse>
<span STYLE="font: bold 14px sans-serif; color: red;">No <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> selected found.</span><br><br>

</cfif>
<cfelse>
<span STYLE="font: bold 14px sans-serif; color: red;">Invalid <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> Selected. Please try again.</span><br><br>
</cfif>

<script>
function getdisitemdetails(Dist_PrgId,DistId)
{
NewWindow('/common_files/contracts/pullbacks/view_pullback_dis_item_details.cfm?<cfoutput>contract_main_id=#url.Contract_Main_ID#</cfoutput>&FromDistributor_Prg=<cfoutput>#url.FromDistributor_Prg#</cfoutput>&DistId='+DistId+'&Dist_PrgId='+Dist_PrgId,'pullbackdistributoritemdetails','800','620','Yes', 'No');
}
</script>
<cfoutput><FORM ACTION="view_pullback_distributor_program_details.cfm?contract_main_id=<cfoutput>#url.Contract_Main_ID#</cfoutput>&FromDistributor_Prg=#url.FromDistributor_Prg#" METHOD="post" NAME="Templates" STYLE="DISPLAY:INLINE">
<input type="hidden" name="sort_by" value="">
<input type="hidden" name="sort_Order" value="">
<input type="hidden" name="distributor_id" value="#distributor_id#">
</FORM></cfoutput>
<script>
	function toggleAllToSameStatus(id,status)
	 {
			toggleRateDisplay(id,status);
	}
</script>
<cfinclude template="pullbacks_js.cfm">

</Body>
</html>