<CFOUTPUT>
<CFSET PAGE_TITLE="Component #Application.RebateLabel# Details">
</CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
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
<!----------------- Add Spinner ------------------------>

<cfparam name="URL.CID" 	default="">
<cfparam name="URL.CPID" 	default="">
<cfparam name="URL.PPID" 	default="">

<!--- <CFIF NOT IsNumeric(URL.CID) OR URL.CPID EQ "">
	<CFOUTPUT><BR><BR><SPAN CLASS="TITLE2">Invalid Information</SPAN></CFOUTPUT>
	<CFABORT>
</CFIF> --->
<CFSET Program_ID=URL.CID>
<CFSET itemMasterID=URL.itemMasterId>
<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<CFSET Contract_Main_ID = cryp.value>

<cfscript>
	rebate = CreateObject("component","components.programs.rebates.Rebate");
	uom = CreateObject("component","components.programs.rebates.uom");
	thisRebate = rebate.loadFromDB(Contract_Main_ID,0, itemMasterID);
</cfscript>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Get Program - Product - Rule Information
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<!--- 
	<CFSET release_Date=Now()>
	<CFSET Program_ID = 1015> 
--->

<CFSET NO_DATA_STR = "<font color=""red"">No Data</font>">

<!--- <CFQUERY datasource="#application.datasource#" NAME="Get_Product_Rule">
	SELECT	fpp.Program_Formula_Pricing_Rule_ID, fpp.Product_Overage, cfi.UPC, cfi.Description,
			Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID,
			fpp.Unit_Of_Measure_ID
	FROM	Program_Formula_Pricing_Rule_Products fpp,
			Contract_Products cp,
			BSA_Foodservice_Items_Master cfi,
			Program_Formula_Pricing_Rule_Mapped
	WHERE			
					cp.Contract_Products_ID = fpp.Contract_Product_ID
			AND		cfi.BSA_Foodservice_Items_Master_ID = '#URL.CPID#'
			AND		fpp.Deleted	=	0
			AND 	fpp.Active	=	1
			AND		cp.BSA_Foodservice_Items_Master_ID = '#URL.CPID#'
			AND		fpp.Program_ID = #Program_ID#
			AND		Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID = fpp.Program_Formula_Pricing_Rule_ID
</CFQUERY>

<CFQUERY datasource="#application.datasource#" NAME="Get_Release_Date">
	SELECT		Release_Date
	FROM		Program_Formula_Pricing_Periods
	WHERE		Program_Formula_Pricing_Period_ID = '#URL.PPID#'
</CFQUERY>
<CFIF Get_Release_Date.recordCount EQ 0 OR Get_Product_Rule.recordCount EQ 0>
	<CFOUTPUT><BR><BR><SPAN CLASS="TITLE2">Invalid Information</SPAN></CFOUTPUT>
	<CFABORT>
</CFIF>
<CFSET release_Date=Get_Release_Date.Release_Date>
<CFSET Product_Overage=Get_Product_Rule.Product_Overage> --->


<BLOCKQUOTE>
<BR><BR>
<CFOUTPUT>
<SPAN CLASS="TITLE2">Component #Application.RebateLabel# Calculation</SPAN>

<HR COLOR="Orange">

<TABLE BORDER="0">
	<TR>
	<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>PRODUCT:</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#thisRebate.aProd[1].UPC# - </cfif></cfif>#thisRebate.aProd[1].Description#</B></TD>
	</TR>
</TABLE>


<TABLE CLASS="Maintable" WIDTH="90%" CELLPADDING="3" CELLSPACING="0" ALIGN="center" border="0">

		<TR BGCOLOR="##FFCE84" VALIGN="bottom">
			<TD ID="header"><B>Component Name</B></TD>
			<TD ID="header"><B>Rate</B></TD>
			<TD ID="header">&nbsp;</TD>
			<TD ID="header"><B>Net Weight</B></TD>
			<TD ID="header"><B>List Price</B></TD>
			<TD ID="header">&nbsp;</TD>
			<TD ID="header"><B>Component Rate</B></TD>
		</TR>
		<cfloop index="i" from="1" to="#ArrayLen(thisRebate.aComp)#">
		<cfscript>
			uomAbb = uom.getUomAbbr(thisRebate.aCompVal[1][i].uomId);
			rebateCalc = rebate.calculate(thisRebate.aProd,thisRebate.aComp,thisRebate.aCompVal);
		</cfscript>
		
		<!---calc component rebate value--->
		<cfif thisRebate.aCompVal[1][i].uomId eq 1>
			<cfset compRebVal = thisRebate.aCompVal[1][i].rate / thisRebate.aProd[1].netWeight />
		<cfelseif thisRebate.aCompVal[1][i].uomId eq 3>
			<cfset compRebVal = (thisRebate.aCompVal[1][i].rate * thisRebate.aProd[1].fobPrice) / 100 />
		<cfelse>
			<cfset compRebVal = thisRebate.aCompVal[1][i].rate />
		</cfif>
		<TR>
			<td>#thisRebate.aComp[i].compName#</td>
			<td><cfif thisRebate.aCompVal[1][i].uomId eq 3>#thisRebate.aCompVal[1][i].rate##uomAbb#<cfelse>#numberFormat(thisRebate.aCompVal[1][i].rate, "$_.___")# / #uomAbb#</cfif></td>
			<td style="font-size:12px;font-weight:bold"><cfif thisRebate.aCompVal[1][i].uomId eq 1>/<cfelseif thisRebate.aCompVal[1][i].uomId eq 3>*<cfelse>&nbsp;</cfif></td>
			<td><cfif thisRebate.aCompVal[1][i].uomId eq 1>#thisRebate.aProd[1].netWeight#<cfelse>&nbsp;</cfif></td>
			<td><cfif thisRebate.aCompVal[1][i].uomId eq 3>#thisRebate.aProd[1].fobPrice#<cfelse>&nbsp;</cfif></td>
			<td>=</td>
			<td>#numberFormat(compRebVal, "$_.___")#</td>
		</TR>
		</cfloop>
		<tr>
			<TD COLSPAN="6" ALIGN="RIGHT" STYLE="border-top:none; border-bottom: 0px; font-size : 12px; color: NAVY;"><B>&##931; Total #Application.RebateLabel# =</B></TD>
			<td STYLE="border-top:none; border-bottom: 0px; font-size : 12px; color: NAVY;"><font color="0000FF"><b>#numberFormat(rebateCalc[1].rebateVal, "$_.___")#</b></font></td>
		</tr>	
</CFOUTPUT>
</TABLE>
	<BR><BR>
<DIV ALIGN="center">
		<CF_button
			button_name		=	""
			button_caption	=	"close this window"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"close this window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
		</DIV>	
		<BR><BR>
</BLOCKQUOTE>