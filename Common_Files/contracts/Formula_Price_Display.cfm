<CFSET PAGE_TITLE="Formula Price Details">
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

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="0">


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

<CFIF NOT IsNumeric(URL.CID) OR URL.CPID EQ "" OR URL.PPID EQ "">
	<CFOUTPUT><BR><BR><SPAN CLASS="TITLE2">Invalid Information</SPAN></CFOUTPUT>
	<CFABORT>
</CFIF>
<CFSET Program_ID=URL.CID>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Get Program - Product - Rule Information
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<!--- 
	<CFSET release_Date=Now()>
	<CFSET Program_ID = 1015> 
--->

<CFSET NO_DATA_STR = "<font color=""red"">No Data</font>">

<CFQUERY datasource="#application.datasource#" NAME="Get_Product_Rule">
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
<CFSET Product_Overage=Get_Product_Rule.Product_Overage>



<BR>
<CFOUTPUT>
<SPAN CLASS="TITLE2">&nbsp;&nbsp;&nbsp;&nbsp;Rate Calculation (Release Date - #DateFormat(release_Date, "mm/dd/yyyy")#)</SPAN>
</CFOUTPUT>
<HR COLOR="Orange">
<CFOUTPUT>
<TABLE BORDER="0">
	<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>PRODUCT:</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#Get_Product_Rule.UPC# - </cfif></cfif>#Get_Product_Rule.Description#</B></TD>
	</TR>
</TABLE>
</CFOUTPUT>

<CFSET THIS_PRODUCT_FORMULA_PRICING_RULE_ID = Get_Product_Rule.Formula_Pricing_Rule_ID>

<!------ Formula value calculate ----->
<CFSET Email_Fax_Compatable = false>
<CFINCLUDE template="Formula_Price_Commodity_Value.cfm">

<!------ Formula value calculate ----->
<CFOUTPUT>
	<TR>
		<TD COLSPAN="2" STYLE="border-bottom: 0px;"></TD>
		<TD  COLSPAN="5" STYLE="border-bottom: 0px;">Product Overage: 
		<CFIF Get_Product_Rule.Unit_Of_Measure_ID EQ 3>
			%</TD>
			<CFSET thisAvearage = (Product_Overage * Grand_Total)/100>
			<TD COLSPAN="2" ALIGN="RIGHT" STYLE="border-bottom: 0px;">#numberformat(Product_Overage, '_,___.____')#%</TD>
			<TD ALIGN="CENTER" STYLE="border-bottom: 0px;">*</TD>
			<TD ALIGN="RIGHT" STYLE="border-bottom: 0px;">#numberformat(Grand_Total, '_,___.____')#</TD>
		<CFELSE>
			[$/lb]</TD>
			<CFSET thisAvearage = Product_Overage>
			<TD COLSPAN="4" ALIGN="RIGHT" STYLE="border-bottom: 0px;">$#numberformat(thisAvearage, '_,___.____')#</TD>
		</CFIF>	
		<CFSET Grand_Total = Grand_Total + thisAvearage>
		<TD STYLE="border-bottom: 0px;" ALIGN="center">=</TD>
		<TD ALIGN="RIGHT" STYLE="border-bottom: 0px;">$#numberformat(thisAvearage, '_,___.____')#</TD>
		<TD STYLE="border-bottom: 0px;">&nbsp;</TD>
		<TD ALIGN="CENTER" STYLE="border-bottom: 0px;">+</TD>
	</TR>	
	<TR>
		<TD STYLE="border-top:solid navy 1px; border-bottom: 0px; font-size : 10px; color: NAVY;">&nbsp;</TD>
		<TD COLSPAN="10" ALIGN="RIGHT" STYLE="border-top:solid navy 1px; border-bottom: 0px; font-size : 12px; color: NAVY;"><B>Total Formula Price</B></TD>
		<TD ALIGN="center" STYLE="border-top:solid navy 1px; border-bottom: 0px; font-size : 12px; color: NAVY;">=</TD>
		<TD ALIGN="RIGHT" STYLE="border-top:solid navy 1px; border-bottom: 0px; font-size : 12px; color: BLUE;"><B>
		<CFIF Proper_Commodity EQ 1>$#numberformat(Grand_Total, '_,___.____')#<CFELSE>#NO_DATA_STR#</CFIF>
		</B></TD>
		<TD COLSPAN="3" STYLE="border-top:solid navy 1px; border-bottom: 0px; font-size : 10px; color: NAVY;">&nbsp;</TD>
	</TR>
</CFOUTPUT>
	<!------ Update new calculated value to the database----->
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


