<CFSET PAGE_TITLE=	"Profitability Analysis Tool">
<CFSET GROUP=		"Profit">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFINCLUDE TEMPLATE="/includes/header.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>

<BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save rules created																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Save_Commodity_Pricing_Rule" datasource="#application.datasource#">

SET NOCOUNT ON
INSERT INTO	Commodity_Pricing_Rules 
	(
		Rulename,
		Products,
		Exchange,
		Commodity,
		Sample_size,
		Time_UOM_sample_size,
		Point_in_time,
		Time_UOM_point_in_time,
		Calc_Process,
		CP_desc_calc1,
		CP_amount_calc1,
		CP_desc_calc2,
		CP_amount_calc2,
		CP_desc_calc3,
		CP_amount_calc3,
		CP_desc_calc4,
		CP_amount_calc4,

		IN_desc_calc1,
		IN_amount_calc1,
		IN_desc_calc2,
		IN_amount_calc2,
		IN_desc_calc3,
		IN_amount_calc3,
		IN_desc_calc4,
		IN_amount_calc4,

		Freight,
		Floor_Type,
		Floor_Amount,
		Notes,
		Creator_ID
	)

VALUES
	(
		'#Rulename#',
		'#Products#',
		'#Exchange#',
		'#Commodity#',
		'#Sample_size#',
		'#Time_UOM_sample_size#',
		'#Point_in_time#',
		'#Time_UOM_point_in_time#',
		'#Calc_Process#',

		'#CP_desc_calc1#',
		'#CP_amount_calc1#',
		'#CP_desc_calc2#',
		'#CP_amount_calc2#',
		'#CP_desc_calc3#',
		'#CP_amount_calc3#',
		'#CP_desc_calc4#',
		'#CP_amount_calc4#',

		'#IN_desc_calc1#',
		'#IN_amount_calc1#',
		'#IN_desc_calc2#',
		'#IN_amount_calc2#',
		'#IN_desc_calc3#',
		'#IN_amount_calc3#',
		'#IN_desc_calc4#',
		'#IN_amount_calc4#',

		'#Freight#',
		'#Floor_Type#',
		'#Floor_Amount#',
		'#Notes#',
		'#request.AccessStructure.USER_ID#'
	)
SELECT Commodity_Pricing_ID = @@IDENTITY
SET NOCOUNT OFF
</CFQUERY>



		<BR><BR><BR><BR><BR>
		<FONT SIZE="+1">
		The <I><CFOUTPUT><A HREF="rules_wizard_view_rule.cfm?id=#Save_Commodity_Pricing_Rule.Commodity_Pricing_ID#" onclick="NewWindow(this.href,'name','625','450','Yes', 'No');return false;">#Rulename#</A></CFOUTPUT></I> rule has been saved...
		
		</FONT>
		<BR><BR><BR><BR><BR>
		<FONT COLOR="Red" SIZE="2"><B>[</B></FONT>&nbsp;<A HREF="/profits/index.cfm" TARGET="_parent">back to commodity pricing</A>&nbsp;<FONT COLOR="Red" SIZE="2"><B>]</B></FONT>
 


 
 
 
 </BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFINCLUDE TEMPLATE="/includes/footer.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<SCRIPT LANGUAGE="JavaScript">
	findselectboxes();
</SCRIPT>


</BODY>
</HTML>

 
 