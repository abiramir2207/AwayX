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
<!--- Get the rule data set for the passed ID														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Rule_Data" datasource="#application.datasource#">
Select	Commodity_Pricing_Rules.*
From	Commodity_Pricing_Rules
Where	Commodity_Pricing_ID	=	#URL.ID#
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the name of the creator																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Creator_Name" datasource="#application.datasource#">
Select	Name_First,
		Name_Last
From	_Users
Where	User_ID	=	'#Get_Rule_Data.Creator_ID#'
</CFQUERY>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Create query to retrieve the product names													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
Select	Description
From	BSA_Foodservice_Items_Master
Where	item  in (#listqualifY(ValueList(Get_Rule_Data.Products), "'")#)
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the name of the exchange used																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Exchange" datasource="#application.datasource#">
Select	Exchange_Detail_Name
From 	Commodities_Exchange_Detail
Where 	Exchange_Detail_ID	=	'#Get_Rule_Data.Exchange#'
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the name of the commodity																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Commodity" datasource="#application.datasource#">
Select	Symbol_Description
From	Commodities_Symbol
Where	Symbol	=	'#Get_Rule_Data.Commodity#'
</CFQUERY>


<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>



<CFOUTPUT QUERY="Get_Rule_Data">
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="10">
<TR>
	<TD ALIGN="right" VALIGN="top"><B>Rule Name:</B></TD>
	<TD BGCOLOR="Orange" ROWSPAN="15"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD>
	<TD><SPAN CLASS="title2">#Rulename#</SPAN></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B>Created by:</B></TD>
	<TD>#Get_Creator_Name.Name_First# #Get_Creator_Name.Name_Last#</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B>Created On:</B></TD>
	<TD>#dateformat(Date_Created, 'm/d/yy')#</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B>Products:</B></TD>
	<TD>
		<CFLOOP QUERY="Get_Products">
			#Get_Products.Description#<BR>
		</CFLOOP>
	</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B>Exchange:</B></TD>
	<TD>#Get_Exchange.Exchange_Detail_Name#</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B>Commodity:</B></TD>
	<TD>#Get_Commodity.Symbol_Description#</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B>Sample Size:</B></TD>
	<TD>#Sample_size# #Time_UOM_sample_size#</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B>Time Lag:</B></TD>
	<TD>#Point_in_time# #Time_UOM_point_in_time#</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B>Calculation Method:</B></TD>
	<TD>#Calc_Process#</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B>Compounded Calculations:</B></TD>
	<TD>
		<TABLE WIDTH="200" CELLSPACING="0" CELLPADDING="2" CLASS="Maintable">
			<TR>
				<TD WIDTH="100%">#CP_desc_calc1#</TD>
				<TD NOWRAP>#CP_amount_calc1#</TD>
			</TR>
			<TR>
				<TD>#CP_desc_calc2#</TD>
				<TD NOWRAP>#CP_amount_calc2#</TD>
			</TR>
			<TR>
				<TD>#CP_desc_calc3#</TD>
				<TD NOWRAP>#CP_amount_calc3#</TD>
			</TR>
			<TR>
				<TD>#CP_desc_calc4#</TD>
				<TD NOWRAP>#CP_amount_calc4#</TD>
			</TR>
		</TABLE>
	</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B>Independent Calculations:</B></TD>
	<TD>
		<TABLE WIDTH="200" CELLSPACING="0" CELLPADDING="2" CLASS="Maintable">
			<TR>
				<TD WIDTH="100%">#IN_desc_calc1#</TD>
				<TD NOWRAP>#IN_amount_calc1#</TD>
			</TR>
			<TR>
				<TD>#IN_desc_calc2#</TD>
				<TD NOWRAP>#IN_amount_calc2#</TD>
			</TR>
			<TR>
				<TD>#IN_desc_calc3#</TD>
				<TD NOWRAP>#IN_amount_calc3#</TD>
			</TR>
			<TR>
				<TD>#IN_desc_calc4#</TD>
				<TD NOWRAP>#IN_amount_calc4#</TD>
			</TR>
		</TABLE>
	</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B>Freight:</B></TD>
	<TD>#Freight#</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B>Floor:</B></TD>
	<TD>#Floor_Amount# #Floor_Type#</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B></B></TD>
	<TD></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B></B></TD>
	<TD></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top"><B></B></TD>
	<TD></TD>
</TR>
</TABLE>
</CFOUTPUT>

<BR><BR>
<!--- 
<FONT COLOR="Red" SIZE="2"><B>[</B></FONT>&nbsp;<A HREF="/profits/index.cfm" TARGET="_parent">create another rule</A>&nbsp;<FONT COLOR="Red" SIZE="2"><B>]</B></FONT>
 ---> 
 </BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFINCLUDE TEMPLATE="/includes/footer.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




</BODY>
</HTML>


 