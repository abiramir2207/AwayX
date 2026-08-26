<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- 
<FIELDSET STYLE="padding:0px; width: 450; border: 1px solid Silver;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Commodity Pricing  - Step 1 of 2</LEGEND>
 --->

<CFFORM ACTION="rules_wizard2.cfm" METHOD="post" onSubmit="return require_Selected();" Name="MyForm">
<TABLE border="0" cellspacing="5" cellpadding="0" WIDTH="550">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TR>
		<TD WIDTH="100%" VALIGN="bottom"><DIV CLASS="title2">Rule Name</DIV></TD>
		<TD><A HREF="commodity_help.cfm#Rule_Name" onclick="NewWindow(this.href,'name','625','450','Yes', 'No');return false;"><IMG SRC="/images/question.gif" BORDER="0"></A></TD>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="2"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
	</TR>
	<TR>
		<TD COLSPAN="2">
			Please create the rule name:<BR>
			<CFINPUT TYPE="Text" NAME="rulename" MESSAGE="You must enter the name of the rule." REQUIRED="Yes" STYLE="width:400px;">
		</TD>
	</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of products																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Products" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(24, 0, 0, 0)#">
	Select		item,
				UPC,
				Type_Code_Desc,
				Description
	From		BSA_Foodservice_Items_Master
	Where		Deleted = 0
	Order by	Type_Code_Desc
</CFQUERY>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TR>
		<TD VALIGN="bottom"><DIV CLASS="title2">Products/SKUs</DIV></TD>
		<TD><A HREF="commodity_help.cfm#Products/SKUs" onclick="NewWindow(this.href,'name','625','450','Yes', 'No');return false;"><IMG SRC="/images/question.gif" BORDER="0"></A></TD>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="2"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
	</TR>
	<TR>
		<TD COLSPAN="2">
			Please Select Products:<BR>
			<CFSELECT NAME="Products" SIZE="5" MESSAGE="You must select at least one product." REQUIRED="Yes" MULTIPLE STYLE="width:400px;">
				<CFOUTPUT QUERY="Get_Products">
				<OPTION VALUE="#Item#">#UPC# - #Type_Code_Desc# - #Description#</OPTION>
				</CFOUTPUT>
			</CFSELECT>
		</TD>
	</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TR>
		<TD VALIGN="bottom"><DIV CLASS="title2">Exchange & Commodities</DIV></TD>
		<TD><A HREF="commodity_help.cfm#Exchange" onclick="NewWindow(this.href,'name','625','450','Yes', 'No');return false;"><IMG SRC="/images/question.gif" BORDER="0"></A></TD>
	</TR>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="2"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
	<TR>
		<TD COLSPAN="2">
			Please Select the Commodity Exchange:<BR>

			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<!--- Get the exchange & commodity data																 --->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<CFQUERY NAME="get_data" datasource="#application.datasource#">
			Select		Commodities_Symbol.*,
						Commodities_Exchange_Detail.*
			From		Commodities_Symbol,
						Commodities_Exchange_Detail
			Where		Commodities_Symbol.Exchange_Detail_Abrev	=	Commodities_Exchange_Detail.Exchange_Detail_Abrev
			Order by	Commodities_Symbol.Exchange_Detail_Abrev, Commodities_Symbol.Symbol
			</CFQUERY>

			<CF_TwoSelectsRelated
				QUERY="get_data"
				NAME1="Exchange"
				NAME2="Commodity"
				DISPLAY1="Exchange_Detail_Name"
				DISPLAY2="Symbol_Description"
				VALUE1="Exchange_Detail_ID"
				VALUE2="Symbol"
				SIZE1="1"
				SIZE2="1"
				HTMLBETWEEN="<BR><BR>"
				AUTOSELECTFIRST="Yes"
				FORMNAME="MyForm">

		</TD>
	</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TR>
		<TD VALIGN="bottom"><DIV CLASS="title2">Sample Size</DIV></TD>
		<TD><A HREF="commodity_help.cfm#Sample_Size" onclick="NewWindow(this.href,'name','625','450','Yes', 'No');return false;"><IMG SRC="/images/question.gif" BORDER="0"></A></TD>
	</TR>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="2"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
	<TR>
		<TD COLSPAN="2">
			Please enter the number of days that you would like to select data for:<BR>
			<CFINPUT TYPE="Text" NAME="sample_size" MESSAGE="You must enter the size of the commodity sample" VALIDATE="integer" REQUIRED="Yes" SIZE="11">
			&nbsp;&nbsp;&nbsp;&nbsp;
			<INPUT TYPE="radio" NAME="Time_UOM_sample_size" VALUE="days" CHECKED>Days
			&nbsp;&nbsp;&nbsp;&nbsp;
			<INPUT TYPE="radio" NAME="Time_UOM_sample_size" VALUE="weeks">Weeks
		</TD>
	</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TR> 
		<TD VALIGN="bottom"><DIV CLASS="title2">Sample Time Lag</DIV></TD>
		<TD><A HREF="commodity_help.cfm#Sample_Time_Lag" onclick="NewWindow(this.href,'name','625','450','Yes', 'No');return false;"><IMG SRC="/images/question.gif" BORDER="0"></A></TD>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="2"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
	</TR>
	<TR>
		<TD COLSPAN="2">
			Please select how far back in time the sample window&nbsp; should be:<BR>
			<CFINPUT TYPE="Text" NAME="point_in_time" MESSAGE="You must enter where in time  to select the sample." VALIDATE="integer" REQUIRED="Yes" SIZE="11">
			&nbsp;&nbsp;&nbsp;&nbsp;
			<INPUT TYPE="radio" NAME="Time_UOM_point_in_time" VALUE="days" CHECKED>Days
			&nbsp;&nbsp;&nbsp;&nbsp;
			<INPUT TYPE="radio" NAME="Time_UOM_point_in_time" VALUE="weeks">Weeks
		</TD>
	</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TR>
		<TD VALIGN="bottom"><DIV CLASS="title2">Pricing Manipulation Method</DIV></TD>
		<TD><A HREF="commodity_help.cfm#Pricing_Manipulation_Method" onclick="NewWindow(this.href,'name','625','450','Yes', 'No');return false;"><IMG SRC="/images/question.gif" BORDER="0"></A></TD>
	</TR>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="2"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
	<TR>
		<TD COLSPAN="2">
			<INPUT type="radio" value="Average" name="Calc_Process" checked>Average all of the sample data points (Mean)<BR>
			<INPUT type="radio" value="Trend" name="Calc_Process" DISABLED>Calculate the Linear Trend of the data (Regression Analysis)
		</TD>
	</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</TABLE>

<IMG SRC="/images/fill.gif" WIDTH="300" HEIGHT="1" BORDER="0" ALT="">
<INPUT TYPE="submit" VALUE="go to step 2 >>">
<BR><BR>

</CFFORM>
<!--- 
</FIELDSET>
 --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>
