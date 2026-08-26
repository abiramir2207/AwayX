<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<CFSET PAGE_TITLE="#appsettings.getPullbackLabel()# Amount Details">
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
<cfset GettemplateProgramDetails = PullbackManager.GettemplateProgramDetails(url.Contract_Main_ID,url.templateid,form.sql_Sort_By,FORM.sort_order)>
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
		<B>Default Rate:</B>&nbsp;#GettemplateDetails.default_pullback_rate#%<br>
		</TD>
	</TR>
</TABLE>
<br>
</CFOUTPUT>
<cfif GettemplateProgramDetails.recordcount GT 0>

<TABLE BORDER="0" width="95%"  CELLPADDING="0" CELLSPACING="0" align="center" class="maintable">
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
</TR>
<cfoutput query="GettemplateProgramDetails">
<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="center" height="20">
		<TD STYLE="border-bottom: 0px; color: NAVY;">
		#Contract_number#
		<span style="color: black; font-weight:bold;"><a onclick="toggleAllToSameStatus('#opr_contract_main_id#','inline')" style="cursor:pointer; color:red;"><font color="blue">[</font>show<font color="blue">]</font></a> or <a onclick="toggleAllToSameStatus('#opr_contract_main_id#','none')" style="cursor:pointer; color:red;"><font color="blue">[</font>hide<font color="blue">]</font></a></span></TD>
</TD>
<TD STYLE="border-bottom: 0px;color: NAVY">#Contract_Title#</TD>
<TD STYLE="border-bottom: 0px;color: NAVY">#dateformat(contract_start_date,"mm/dd/yyyy")#</TD>
<TD STYLE="border-bottom: 0px;color: NAVY">#dateformat(contract_end_date,"mm/dd/yyyy")#</TD>
</TR>
<TR>
<TD colspan="100%" id="RS_#opr_contract_main_id#" style="display:none">
<TABLE class="sortable" WIDTH="95%" align="center" CELLPADDING="3" CELLSPACING="0" border="0" id="TB_#opr_contract_main_id#">
<TR BGCOLOR="##FFCE84" VALIGN="bottom">
			<TD ID="header" NOWRAP><B>#application.returned_customer_setting.distributor_label_singular#</B></TD>
			<TD ID="header"><B>#application.returned_customer_setting.shard_ship_to_label#</B></TD>
			<TD ID="header"><B>#application.returned_customer_setting.ITEM_Label#</B></TD>
			<TD ID="header"><B>Product Description</B></TD>
			<TD ID="header"><B>#appsettings.getPullbackLabel()# Rate</B></TD>
</TR>
<cfset GetProgramDistDetails = PullbackManager.GetProgramDistDetails(url.contract_main_id,opr_contract_main_id)>
<Cfloop query="GetProgramDistDetails">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<TD valign="top">#name#</TD>
			<TD valign="top">#shr_ship_to#</TD>
			<TD valign="top">#item#</TD>
			<TD valign="top">#description#</TD>
			<TD valign="top">#pullback_value#%</TD>
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

<cfoutput><FORM ACTION="view_pullback_opr_program_details.cfm?contract_main_id=#url.contract_main_id#&TemplateId=#url.TemplateId#" METHOD="post" NAME="Templates" STYLE="DISPLAY:INLINE">
<input type="hidden" name="sort_by" value="">
<input type="hidden" name="sort_Order" value="">
</FORM></cfoutput>
<script>
	function toggleAllToSameStatus(id,status)
	 {
			toggleRateDisplay(id,status);
	}
</script>
<SCRIPT LANGUAGE="javaScript">
	function getParentObject(thisObj, tagName)
	{
		if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
		{
			return thisObj;
		}
		else if(thisObj.tagName.toLowerCase() == "body")
		{
			return null;
		}
		else
		{
			return getParentObject(thisObj.parentElement, tagName);
		}
	}
	var sortBy;
	var sort_order;
	var orderFileName;
	
	initialise();
	function initialise()
	{		
		sortBy = "<cfoutput>#checksortby#</cfoutput>";
		<CFIF FORM.sort_order EQ "ASC">
			sort_order = 1;
		<CFELSE>
			sort_order = 0;		
		</CFIF>
		orderFileName = "<cfoutput>#Current_Image#</cfoutput>";
	}
	function setSortHref(sortVal)
	{
		if(sortBy == sortVal)
		{
			sort_order *= -1;
		}
		else
		{
			sort_order = 1;
			sortBy = sortVal;
		}
		var SORTORDER;
		
		if(sort_order < 0)
		{
			SORTORDER = "DESC";
			orderFileName = "<cfoutput>#DESC_IMG#</cfoutput>";
		}
		else
		{
			SORTORDER = "ASC";
			orderFileName = "<cfoutput>#ASC_IMG#</cfoutput>";
		}
		document.Templates.sort_by.value = sortVal;
		document.Templates.sort_Order.value = SORTORDER;
		
		var thisCell = getParentObject(event.srcElement,"TD");		
		//setSortImage(thisCell);
		document.Templates.submit();
	}
	/*
	function setSortImage(thisCell)
	{
		
		var thisSPObj = thisCell.all.SP_SP;
		var spObjs = document.all.SP_SP;
		var i;
		alert(orderFileName);
		for(i=0;i<spObjs.length;i++)
		{
			if(spObjs[i] == thisSPObj)
			{
				spObjs[i].all.S_IMG.src = "/Images/" + orderFileName;
				alert(spObjs[i].all.S_IMG.src);
				spObjs[i].style.visibility = "visible";
			}
			else
			{
				spObjs[i].style.visibility = "hidden";
			}
		}	
	}*/
</SCRIPT>

</Body>
</html>