<CFSET PAGE_TITLE= "<cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Amounts">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="">

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "pullbacks"> 
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>
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

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif application.programlayout EQ 1>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm">
</cfif>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 160px; top: 0px;"> </cfif>
<cfinclude template="/common_files/contracts/minimal_contract_info.cfm">
<span STYLE="font: bold 14px sans-serif; color: Navy;width:800"><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Amounts Information</span><br><br>


<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />

<cfset Gettemplates = PullbackManager.Gettemplates(CSL_Contract_Main_ID,form.sql_Sort_By,FORM.sort_order)>

 <table width="780" class="maintable" CELLPADDING="0" CELLSPACING="0">
 <tr  bgcolor="C6FFC6">
<TD id="header" style="font-size: 12px;"> <strong><A HREF="##" OnClick="javaScript: setSortHref('TN');">Program Type</A></strong>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "TN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
 <td id="header" style="font-size: 12px;"><A HREF="##" OnClick="javaScript: setSortHref('TD');"><strong>Description</strong></A><SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "TD"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN></TD>
 <TD id="header" style="font-size: 12px;"><strong>Default <cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Rate</strong></TD>
 </TR>
 <cfif Gettemplates.recordcount GT 0>
 <cfoutput query="Gettemplates">
 <TR height="20">
 <TD><A href="##"><span style="cursor:pointer;  text-decoration: none;" onclick="getoprprograms('#Gettemplates.ProgramControl_Panel_Options_id#');">#created_type#</A></TD>
 <TD><A href="##"><span style="cursor:pointer;  text-decoration: none;" onclick="getoprprograms('#Gettemplates.ProgramControl_Panel_Options_id#');">#program_description#</A></TD>
<td>#default_pullback_rate#%</td>
 </TR>
 </cfoutput>
 <cfelse>
 <TR>
 <TD><strong>No templates found.</strong></TD>
 </TR>
  </cfif>
</TABLE>
<FORM ACTION="pullback_corp_index.cfm?CID=<CFOUTPUT>#url.CID#</CFOUTPUT>" METHOD="post" NAME="Templates" STYLE="DISPLAY:INLINE">
<input type="hidden" name="sort_by" value="">
<input type="hidden" name="sort_Order" value="">
</FORM>
<script>
function getoprprograms(TempId)
{
NewWindow('/common_files/contracts/pullbacks/view_pullback_opr_program_details.cfm?<cfoutput>contract_main_id=#CSL_Contract_Main_ID#</cfoutput>&TemplateId='+TempId,'pullbackamountdetails','800','620','Yes', 'No');
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
