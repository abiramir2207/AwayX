
<CFSET pagetitle = "step 2 of 4">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- Check for the presence of a pricing rule ID (PRID) in the URL --->
<CFPARAM NAME="FORM.PRID" DEFAULT="">

<!-------------------- Added By Deepa ----------------------------------------->
<SCRIPT LANGUAGE="JavaScript">
<CFINCLUDE TEMPLATE="/script/javascript/string_functions.js">
</SCRIPT>
<!-------------------- End Added By Deepa ----------------------------------------->

<!--- Define the defaults --->
<CFLOOP INDEX="i" FROM="1" TO="#form.aa_comm_number#">
	<CFPARAM NAME="sample_size_#i#" DEFAULT="">
	<CFPARAM NAME="point_in_time_#i#" DEFAULT="">

	<CFPARAM NAME="compounded_desc_calc1_#i#" DEFAULT="">
	<CFPARAM NAME="compounded_desc_calc2_#i#" DEFAULT="">
	<CFPARAM NAME="compounded_desc_calc3_#i#" DEFAULT="">
	<CFPARAM NAME="compounded_desc_calc4_#i#" DEFAULT="">

	<CFPARAM NAME="compounded_amount_calc1_#i#" DEFAULT="">
	<CFPARAM NAME="compounded_amount_calc2_#i#" DEFAULT="">
	<CFPARAM NAME="compounded_amount_calc3_#i#" DEFAULT="">
	<CFPARAM NAME="compounded_amount_calc4_#i#" DEFAULT="">

	<CFPARAM NAME="compounded_amount_uom1_#i#" DEFAULT="$">
	<CFPARAM NAME="compounded_amount_uom2_#i#" DEFAULT="$">
	<CFPARAM NAME="compounded_amount_uom3_#i#" DEFAULT="$">
	<CFPARAM NAME="compounded_amount_uom4_#i#" DEFAULT="$">

	<CFPARAM NAME="independent_desc_calc1_#i#" DEFAULT="">
	<CFPARAM NAME="independent_desc_calc2_#i#" DEFAULT="">
	<CFPARAM NAME="independent_desc_calc3_#i#" DEFAULT="">
	<CFPARAM NAME="independent_desc_calc4_#i#" DEFAULT="">

	<CFPARAM NAME="independent_amount_calc1_#i#" DEFAULT="">
	<CFPARAM NAME="independent_amount_calc2_#i#" DEFAULT="">
	<CFPARAM NAME="independent_amount_calc3_#i#" DEFAULT="">
	<CFPARAM NAME="independent_amount_calc4_#i#" DEFAULT="">

	<CFPARAM NAME="independent_amount_uom1_#i#" DEFAULT="$">
	<CFPARAM NAME="independent_amount_uom2_#i#" DEFAULT="$">
	<CFPARAM NAME="independent_amount_uom3_#i#" DEFAULT="$">
	<CFPARAM NAME="independent_amount_uom4_#i#" DEFAULT="$">

</CFLOOP>

<!--- If the pricing rule ID has been passed get the details for it --->
<CFIF FORM.PRID NEQ "">

<CFQUERY NAME="Get_Rule_Data" datasource="#application.datasource#">
	Select		*
	From		Pricing_Rule
	Where		Pricing_Rule_ID	=	'#FORM.PRID#'
</CFQUERY>
<!--- Deserialize the XML packet --->
<CFWDDX ACTION="wddx2cfml" INPUT="#Get_Rule_Data.Pricing_Rule_Data#" OUTPUT="struct_profit_rule_name">

<!--- Output the XML for kicks --->
<!--- <CFOUTPUT>#Get_Rule_Data.Pricing_Rule_Data#</CFOUTPUT> --->
<CFSET FORM.Newly_Selected_Products=Get_Rule_Data.Pricing_Rule_Products>

<!--- Get All variables for the commodities --->
<CFLOOP INDEX="i" FROM="1" TO="#form.aa_comm_number#">
	<CFSET "COMMODITY_#i#"=evaluate('struct_profit_rule_name.COMMODITY_'&'#i#')>
	<!--- Get the name of the commodities --->
	<CFQUERY NAME="get_comm_name" datasource="#application.datasource#">
	select	symbol_description
	from	commodities_symbol
	where	symbol = '#evaluate('Commodity_'&'#i#')#'
	</CFQUERY>
	<CFSET "commodity_name_#i#"=#get_comm_name.symbol_description#>

	<!--- Commodity --->
	<CFSET "COMMODITY_#i#"=evaluate('struct_profit_rule_name.COMMODITY_'&'#i#')>
	<INPUT NAME="<CFOUTPUT>COMMODITY_#i#</CFOUTPUT>" TYPE="hidden" VALUE="<CFOUTPUT>#evaluate('struct_profit_rule_name.COMMODITY_'&'#i#')#</CFOUTPUT>">
	
	<!--- Sample --->
	<CFSET "sample_size_#i#"=evaluate('struct_profit_rule_name.sample_size_'&'#i#')>
	<!--- Lag --->
	<CFSET "point_in_time_#i#"=evaluate('struct_profit_rule_name.point_in_time_'&'#i#')>

	<!--- Compounded reason 1 --->
	<CFSET "compounded_desc_calc1_#i#"=evaluate('struct_profit_rule_name.compounded_desc_calc1_'&'#i#')>
	<!--- Compounded reason 2 --->
	<CFSET "compounded_desc_calc2_#i#"=evaluate('struct_profit_rule_name.compounded_desc_calc2_'&'#i#')>
	<!--- Compounded reason 3 --->
	<CFSET "compounded_desc_calc3_#i#"=evaluate('struct_profit_rule_name.compounded_desc_calc3_'&'#i#')>
	<!--- Compounded reason 4 --->
	<CFSET "compounded_desc_calc4_#i#"=evaluate('struct_profit_rule_name.compounded_desc_calc4_'&'#i#')>

	<!--- Compounded amount 1 --->
	<CFSET "compounded_amount_calc1_#i#"=evaluate('struct_profit_rule_name.compounded_amount_calc1_'&'#i#')>
	<!--- Compounded amount 2 --->
	<CFSET "compounded_amount_calc2_#i#"=evaluate('struct_profit_rule_name.compounded_amount_calc2_'&'#i#')>
	<!--- Compounded amount 3 --->
	<CFSET "compounded_amount_calc3_#i#"=evaluate('struct_profit_rule_name.compounded_amount_calc3_'&'#i#')>
	<!--- Compounded amount 4 --->
	<CFSET "compounded_amount_calc4_#i#"=evaluate('struct_profit_rule_name.compounded_amount_calc4_'&'#i#')>

	<!--- Compounded amount 1 type (dollars or percent) --->
	<CFSET "compounded_amount_uom1_#i#"=evaluate('struct_profit_rule_name.compounded_amount_uom1_'&'#i#')>
	<!--- Compounded amount 2 type (dollars or percent) --->
	<CFSET "compounded_amount_uom2_#i#"=evaluate('struct_profit_rule_name.compounded_amount_uom2_'&'#i#')>
	<!--- Compounded amount 3 type (dollars or percent) --->
	<CFSET "compounded_amount_uom3_#i#"=evaluate('struct_profit_rule_name.compounded_amount_uom3_'&'#i#')>
	<!--- Compounded amount 4 type (dollars or percent) --->
	<CFSET "compounded_amount_uom4_#i#"=evaluate('struct_profit_rule_name.compounded_amount_uom4_'&'#i#')>

	<!--- Independent reason 1 --->
	<CFSET "independent_desc_calc1_#i#"=evaluate('struct_profit_rule_name.independent_desc_calc1_'&'#i#')>
	<!--- Independent reason 2 --->
	<CFSET "independent_desc_calc2_#i#"=evaluate('struct_profit_rule_name.independent_desc_calc2_'&'#i#')>
	<!--- Independent reason 3 --->
	<CFSET "independent_desc_calc3_#i#"=evaluate('struct_profit_rule_name.independent_desc_calc3_'&'#i#')>
	<!--- Independent reason 4 --->
	<CFSET "independent_desc_calc4_#i#"=evaluate('struct_profit_rule_name.independent_desc_calc4_'&'#i#')>

	<!--- Independent amount 1 --->
	<CFSET "independent_amount_calc1_#i#"=evaluate('struct_profit_rule_name.independent_amount_calc1_'&'#i#')>
	<!--- Independent amount 2 --->
	<CFSET "independent_amount_calc2_#i#"=evaluate('struct_profit_rule_name.independent_amount_calc2_'&'#i#')>
	<!--- Independent amount 3 --->
	<CFSET "independent_amount_calc3_#i#"=evaluate('struct_profit_rule_name.independent_amount_calc3_'&'#i#')>
	<!--- Independent amount 4 --->
	<CFSET "independent_amount_calc4_#i#"=evaluate('struct_profit_rule_name.independent_amount_calc4_'&'#i#')>

	<!--- Independent amount 1 type (dollars or percent) --->
	<CFSET "independent_amount_uom1_#i#"=evaluate('struct_profit_rule_name.independent_amount_uom1_'&'#i#')>
	<!--- Independent amount 2 type (dollars or percent) --->
	<CFSET "independent_amount_uom2_#i#"=evaluate('struct_profit_rule_name.independent_amount_uom2_'&'#i#')>
	<!--- Independent amount 3 type (dollars or percent) --->
	<CFSET "independent_amount_uom3_#i#"=evaluate('struct_profit_rule_name.independent_amount_uom3_'&'#i#')>
	<!--- Independent amount 4 type (dollars or percent) --->
	<CFSET "independent_amount_uom4_#i#"=evaluate('struct_profit_rule_name.independent_amount_uom4_'&'#i#')>


</CFLOOP>





</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Default values for the HR lines --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET color="Orange">
<CFSET size=1>



<!--- 
<CFIF ListLen(form.AA_PRODUCT_LIST) GT 50>
	<BR><BR><BR>
	<B>You have selected <CFOUTPUT>#ListLen(form.AA_PRODUCT_LIST)#</CFOUTPUT> products. Please limit you list to 50 or less items.</B>
	<CFABORT>
</CFIF>
 ---><FIELDSET STYLE="padding:5px; width: 100%; border: 1px solid Silver;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Selected options</LEGEND>

<TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="100%">

<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP><B>Rule Name:</B></TD>
	<TD BGCOLOR="Orange" ROWSPAN="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD>
	<TD WIDTH="100%"><CFOUTPUT>#form.aa_rulename#</CFOUTPUT></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP><B>Products:</B></TD>
	<TD>


	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Open layer Options																			 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<CFSCRIPT>
		Border="Yes";					BorderSize=1;  
		BorderColor="orange";			Image="/images/plus3.gif";
		ImageOpen="/images/minus3.gif";	TitleColor="Blue"; 
		TitleFont="Arial";				TitleSize=8;
		IsClosed="Yes";					Width=250;
	</CFSCRIPT>
	
	
	
	<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="View Products"  
	TitleClosed="View/Hide Products"  
	TitleTooltip="Click here to togle view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
	<CFINCLUDE TEMPLATE="product_list.cfm">
	</CF_openLayer>
	

	</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP><B>Number of<BR>Commodities:</B></TD>
	<TD>
		<CFOUTPUT>#form.aa_comm_number#</CFOUTPUT>
	</TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP></TD>
	<TD></TD>
</TR>
</TABLE>



<B><FONT COLOR="Red" SIZE="2"><B>[</B></FONT> <A HREF="javascript:history.back();">revise these values</A> <FONT COLOR="Red" SIZE="2"><B>]</B></FONT></B>

</FIELDSET>



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




<FORM ACTION="index4.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
	
<STYLE>
INPUT {
	font-size : 9px;
}
</STYLE>
	
	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- The master table settings for all objects														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET table_settings="BORDER='0' CELLSPACING='2' CELLPADDING='0' WIDTH='100%'">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
<CFLOOP INDEX="i" FROM="1" TO="#form.aa_comm_number#">

<FIELDSET STYLE="padding:5px; width: 100%; border: 1px solid Silver;">

<!--- If the PRID has been passed don't allow the user to change the commodity selections --->
<CFIF FORM.PRID NEQ "">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;"><CFOUTPUT>#evaluate('commodity_name_'&'#i#')#</CFOUTPUT></LEGEND>
<CFELSE>
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Commodity <CFOUTPUT>#i# of #form.aa_comm_number#</CFOUTPUT></LEGEND>
</CFIF>



<TABLE CELLPADDING="10" WIDTH="100%">
<TR>
	<TD>

	
<CFIF FORM.PRID NEQ "">
<!--- If the PRID has been passed don't allow the user to change the commodity selections --->
<CFELSE>
	<!--- Otherwise let them... --->
	Please Select the Exchange and Commodity:<BR>

	<CF_TwoSelectsRelated
	QUERY="get_data"
	NAME1="Exchange_#i#"
	NAME2="Commodity_#i#"
	ForceWidth1="275"
	ForceWidth2="275"
	DISPLAY1="Exchange_Detail_Name"
	DISPLAY2="Symbol_Description"
	VALUE1="Exchange_Detail_ID"
	VALUE2="Symbol"
	SIZE1="1"
	SIZE2="1"
	HTMLBETWEEN=""
	AUTOSELECTFIRST="Yes"
	FORMNAME="MyForm">

	
	<BR><BR>
</CFIF>



<CFOUTPUT>	
<TABLE CELLPADDING="5" CELLSPACING="0" BORDER="0">
	<TR>
		<TD>
			<span id="error_sample_size#i#"></span>&nbsp;Please enter how many weeks you would like to select data for:<BR>
			<INPUT TYPE="Text" NAME="sample_size_#i#" SIZE="11" VALUE="#evaluate('sample_size_'&'#i#')#" onKeyUp="clenseText(this, '0123456789');">
<!--- 
			&nbsp;&nbsp;&nbsp;&nbsp;
			<INPUT TYPE="radio" NAME="Time_UOM_sample_size_#i#" VALUE="days" CHECKED>Days
 --->
			&nbsp;&nbsp;&nbsp;&nbsp;
			<INPUT TYPE="radio" NAME="Time_UOM_sample_size_#i#" VALUE="weeks" CHECKED>Weeks
		</TD>
		<TD>
			<span id="error_point_in_time_#i#"></span>&nbsp;Please select how far back in time the sample window&nbsp; should be:<BR>
			<INPUT TYPE="Text" NAME="point_in_time_#i#" SIZE="11" VALUE="#evaluate('point_in_time_'&'#i#')#" onKeyUp="clenseText(this, '0123456789');">
<!--- 
			&nbsp;&nbsp;&nbsp;&nbsp;
			<INPUT TYPE="radio" NAME="Time_UOM_point_in_time_#i#" VALUE="days" CHECKED>Days
 --->
			&nbsp;&nbsp;&nbsp;&nbsp;
			<INPUT TYPE="radio" NAME="Time_UOM_point_in_time_#i#" VALUE="weeks" CHECKED>Weeks
		</TD>
	</TR>
</TABLE>
</CFOUTPUT>


<BR>

<CFOUTPUT>

<TABLE CELLPADDING="5" CELLSPACING="0" BORDER="0">
<TR>
	<TD>
		
		<TABLE #table_settings#>
			<TR>
				<TD VALIGN="bottom" WIDTH="100%" COLSPAN="3"><DIV CLASS="title2">Compounded Calculations</DIV><span id="error_compounded_desc_#i#"></span>&nbsp;</TD>
				<TD ALIGN="right"></TD>
			<TR>
				<TD BGCOLOR="Orange" COLSPAN="4"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
			</TR>
			<TR>
				<TD VALIGN="bottom"><B>Component Description</B></TD>
				<TD VALIGN="bottom"><B>Amount</B></TD>
				<TD VALIGN="bottom"><B>UOM</B></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="compounded_desc_calc1_#i#" SIZE="40" MAXLENGTH="45" VALUE="#evaluate('compounded_desc_calc1_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);"></TD>
				<TD><input type="text" name="compounded_amount_calc1_#i#" size="4" VALUE="#evaluate('compounded_amount_calc1_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<TD><SELECT NAME="compounded_amount_uom1_#i#"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="compounded_desc_calc2_#i#" SIZE="40" MAXLENGTH="45" VALUE="#evaluate('compounded_desc_calc2_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);"></TD>
				<TD><input type="text" name="compounded_amount_calc2_#i#" size="4" VALUE="#evaluate('compounded_amount_calc2_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<TD><SELECT NAME="compounded_amount_uom2_#i#"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="compounded_desc_calc3_#i#" SIZE="40" MAXLENGTH="45" VALUE="#evaluate('compounded_desc_calc3_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);"></TD>
				<TD><input type="text" name="compounded_amount_calc3_#i#" size="4" VALUE="#evaluate('compounded_amount_calc3_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<TD><SELECT NAME="compounded_amount_uom3_#i#"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="compounded_desc_calc4_#i#" SIZE="40" MAXLENGTH="45" VALUE="#evaluate('compounded_desc_calc4_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);"></TD>
				<TD><input type="text" name="compounded_amount_calc4_#i#" size="4" VALUE="#evaluate('compounded_amount_calc4_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<TD><SELECT NAME="compounded_amount_uom4_#i#"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>
			</TR>
		</table>
	</TD>
	<TD>
		<TABLE #table_settings#>
			<TR>
				<TD VALIGN="bottom" WIDTH="100%" COLSPAN="3"><DIV CLASS="title2">Independent Calculations</DIV><span id="error_independent_desc_#i#"></span>&nbsp;</TD>
				<TD ALIGN="right"></TD>
			<TR>
				<TD BGCOLOR="Orange" COLSPAN="4"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
			</TR>
			<TR>
				<TD VALIGN="bottom"><B>Component Description</B></TD>
				<TD VALIGN="bottom"><B>Amount</B></TD>
				<TD VALIGN="bottom"><B>UOM</B></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="independent_desc_calc1_#i#" SIZE="40" MAXLENGTH="45" VALUE="#evaluate('independent_desc_calc1_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);"></TD>
				<TD><input type="text" name="independent_amount_calc1_#i#" size="4" VALUE="#evaluate('independent_amount_calc1_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<TD><SELECT NAME="independent_amount_uom1_#i#"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="independent_desc_calc2_#i#" SIZE="40" MAXLENGTH="45" VALUE="#evaluate('independent_desc_calc2_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);"></TD>
				<TD><input type="text" name="independent_amount_calc2_#i#" size="4" VALUE="#evaluate('independent_amount_calc2_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<TD><SELECT NAME="independent_amount_uom2_#i#"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="independent_desc_calc3_#i#"  TABINDEX="13" SIZE="40" MAXLENGTH="45" VALUE="#evaluate('independent_desc_calc3_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);"></TD>
				<TD><input type="text" name="independent_amount_calc3_#i#" size="4" VALUE="#evaluate('independent_amount_calc3_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<TD><SELECT NAME="independent_amount_uom3_#i#"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="independent_desc_calc4_#i#"  TABINDEX="15" SIZE="40" MAXLENGTH="45" VALUE="#evaluate('independent_desc_calc4_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);"></TD>
				<TD><input type="text" name="independent_amount_calc4_#i#" size="4" VALUE="#evaluate('independent_amount_calc4_'&'#i#')#" OnChange="javascript:CalculationsSelectIndex3(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<TD><SELECT NAME="independent_amount_uom4_#i#"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>
			</TR>
		</table>	
	</TD>
</TR>
</TABLE>

</CFOUTPUT>

</TD>
</TR>
</TABLE>

</FIELDSET>
<BR>


<CFIF FORM.PRID NEQ "">
	<INPUT NAME="<CFOUTPUT>COMMODITY_#i#</CFOUTPUT>" TYPE="hidden" VALUE="<CFOUTPUT>#evaluate('struct_profit_rule_name.COMMODITY_'&'#i#')#</CFOUTPUT>">
	<INPUT NAME="<CFOUTPUT>COMM_WEIGHT_#i#</CFOUTPUT>" TYPE="hidden" VALUE="<CFOUTPUT>#evaluate('struct_profit_rule_name.COMM_WEIGHT_'&'#i#')#</CFOUTPUT>">
</CFIF>



</CFLOOP>


<CFIF FORM.PRID NEQ "">
<CFOUTPUT>
	<INPUT NAME="Current_Cost_Lag" TYPE="hidden" VALUE="#struct_profit_rule_name.Current_Cost_Lag#">
	
	<INPUT NAME="final_compounded_desc_calc1" TYPE="hidden" VALUE="#struct_profit_rule_name.final_compounded_desc_calc1#">
	<INPUT NAME="final_compounded_desc_calc2" TYPE="hidden" VALUE="#struct_profit_rule_name.final_compounded_desc_calc2#">
	<INPUT NAME="final_compounded_desc_calc3" TYPE="hidden" VALUE="#struct_profit_rule_name.final_compounded_desc_calc3#">
	<INPUT NAME="final_compounded_desc_calc4" TYPE="hidden" VALUE="#struct_profit_rule_name.final_compounded_desc_calc4#">
	
	<INPUT NAME="final_compounded_amount_calc1" TYPE="hidden" VALUE="#struct_profit_rule_name.final_compounded_amount_calc1#">
	<INPUT NAME="final_compounded_amount_calc2" TYPE="hidden" VALUE="#struct_profit_rule_name.final_compounded_amount_calc2#">
	<INPUT NAME="final_compounded_amount_calc3" TYPE="hidden" VALUE="#struct_profit_rule_name.final_compounded_amount_calc3#">
	<INPUT NAME="final_compounded_amount_calc4" TYPE="hidden" VALUE="#struct_profit_rule_name.final_compounded_amount_calc4#">
	
	<INPUT NAME="final_compounded_amount_uom1" TYPE="hidden" VALUE="#struct_profit_rule_name.final_compounded_amount_uom1#">
	<INPUT NAME="final_compounded_amount_uom2" TYPE="hidden" VALUE="#struct_profit_rule_name.final_compounded_amount_uom2#">
	<INPUT NAME="final_compounded_amount_uom3" TYPE="hidden" VALUE="#struct_profit_rule_name.final_compounded_amount_uom3#">
	<INPUT NAME="final_compounded_amount_uom4" TYPE="hidden" VALUE="#struct_profit_rule_name.final_compounded_amount_uom4#">
	
	<INPUT NAME="final_independent_desc_calc1" TYPE="hidden" VALUE="#struct_profit_rule_name.final_independent_desc_calc1#">
	<INPUT NAME="final_independent_desc_calc2" TYPE="hidden" VALUE="#struct_profit_rule_name.final_independent_desc_calc2#">
	<INPUT NAME="final_independent_desc_calc3" TYPE="hidden" VALUE="#struct_profit_rule_name.final_independent_desc_calc3#">
	<INPUT NAME="final_independent_desc_calc4" TYPE="hidden" VALUE="#struct_profit_rule_name.final_independent_desc_calc4#">
	
	<INPUT NAME="final_independent_amount_calc1" TYPE="hidden" VALUE="#struct_profit_rule_name.final_independent_amount_calc1#">
	<INPUT NAME="final_independent_amount_calc2" TYPE="hidden" VALUE="#struct_profit_rule_name.final_independent_amount_calc2#">
	<INPUT NAME="final_independent_amount_calc3" TYPE="hidden" VALUE="#struct_profit_rule_name.final_independent_amount_calc3#">
	<INPUT NAME="final_independent_amount_calc4" TYPE="hidden" VALUE="#struct_profit_rule_name.final_independent_amount_calc4#">
	
	<INPUT NAME="final_independent_amount_uom1" TYPE="hidden" VALUE="#struct_profit_rule_name.final_independent_amount_uom1#">
	<INPUT NAME="final_independent_amount_uom2" TYPE="hidden" VALUE="#struct_profit_rule_name.final_independent_amount_uom2#">
	<INPUT NAME="final_independent_amount_uom3" TYPE="hidden" VALUE="#struct_profit_rule_name.final_independent_amount_uom3#">
	<INPUT NAME="final_independent_amount_uom4" TYPE="hidden" VALUE="#struct_profit_rule_name.final_independent_amount_uom4#">
</CFOUTPUT>
</CFIF>






<!--- These hidden boxes pass the options selected in the first screen plus the structure --->
<INPUT TYPE="hidden" NAME="aa_rulename" VALUE="<CFOUTPUT>#form.aa_rulename#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="aa_product_list" VALUE="<CFOUTPUT>#form.aa_product_list#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="aa_comm_number" VALUE="<CFOUTPUT>#form.aa_comm_number#</CFOUTPUT>">
<INPUT NAME="PRID" TYPE="hidden" VALUE="<CFOUTPUT>#FORM.PRID#</CFOUTPUT>">	
</FORM>


<CF_BUTTON
	BUTTON_NAME		=	""
	BUTTON_CAPTION	=	"goto step 3"
	BUTTON_ACTION	=	"javascript:validateAndSubmitIndex3(document.all.MyForm);"
	BUTTON_TYPE		=	"link"
	BUTTON_WIDTH	=	"125"
	BUTTON_COLOR	=	"Navy"
	BUTTON_TIP		=	""
	FONT_COLOR		=	"White"
	FONT_SIZE		=	"12"
	FONT_WEIGHT		=	"bold">
	
<!-------------------- Added By Deepa ----------------------------------------->
<SCRIPT LANGUAGE="JavaScript">
	document.body.onload=new Function ("disableElements3(document.all.MyForm,true)")
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="commodityScripts.js"></SCRIPT>
<CF_MessageWindow>
<!-----
Edited
"javascript:document.all.MyForm.submit();"
to
"javascript:validateAndSubmitIndex3(document.all.MyForm);"

Added <span id="error_sample_size#i#"></span>&nbsp;
Added <span id="error_point_in_time_#i#"></span>&nbsp;
Added <span id="error_compounded_desc_#i#"></span>&nbsp;
Added <span id="error_independent_desc_#i#"></span>&nbsp;
Added OnChange="javascript:CalculationsSelectIndex3(this);"
------->
<!-------------------- End Added By Deepa ----------------------------------------->
