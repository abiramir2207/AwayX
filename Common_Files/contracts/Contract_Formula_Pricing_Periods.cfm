<cf_cryp type="de" key="#request.key#" string="#URL.CID#">

<!--- check for existing Periods --->
<CFQUERY NAME="checkForPeriods" datasource="#application.datasource#">
	SELECT *
	FROM Program_Formula_Pricing_Periods
	WHERE Program_ID = #cryp.value#
	AND 
		ACTIVE = 1
	AND 
		Deleted = 0
</CFQUERY>


<CFSET PAGE_TITLE="">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "formula"> 
<BLOCKQUOTE><BLOCKQUOTE>
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>

<CFINCLUDE TEMPLATE="contract_status_legend.cfm">



<cfinclude template="minimal_contract_info.cfm">

<BR>

<CFIF checkForPeriods.recordcount EQ 0>
	There are no exising periods defined.
	<BR>
	<A HREF="Contract_Formula_Pricing_Periods_step_1.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" STYLE="font-size: 20px;">click here to defiend the periods</A>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>
