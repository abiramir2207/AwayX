<CFSET pagetitle = "step 3 of 4">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Create the structure that will hold all of the profit rule settings							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!-------------------- Added By Deepa ----------------------------------------->

<SCRIPT LANGUAGE="JavaScript" SRC="../script/javascript/string_functions.js">
<!--- <CFINCLUDE TEMPLATE="../script/javascript/string_functions.js"> --->
</SCRIPT>


<CFLOOP INDEX="i" FROM="1" TO="#form.aa_comm_number#">
	
	<CFLOOP INDEX="j" FROM="1" TO="4">
		<CFIF evaluate("Form.compounded_amount_calc#j#_#i#") EQ "">
			<CFSET evaluate("Form.compounded_amount_calc#j#_#i#=0")>
		</CFIF>
		
		<CFIF evaluate("Form.independent_amount_calc#j#_#i#") EQ "">
			<CFSET evaluate("Form.independent_amount_calc#j#_#i#=0")>
		</CFIF>
		
		<CFPARAM NAME="Form.compounded_amount_uom#j#_#i#" DEFAULT="$">
		<CFPARAM NAME="Form.independent_amount_uom#j#_#i#" DEFAULT="$">
	</CFLOOP>

</CFLOOP>

<!-------------------- End Added By Deepa ----------------------------------------->

<CFSET Struct_Profit_Rule_Name=StructNew()>

<!--- Append to the created structure the data from the previous form								 --->
<CFLOOP INDEX="Item" LIST="#Form.FieldNames#" DELIMITERS=",">										 
	<CFSET Variables.Temp = StructInsert(Struct_Profit_Rule_Name, '#item#', #evaluate(item)#, True)>
</CFLOOP>																							 


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Default values for the HR lines --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET color="Orange">


<CFIF FORM.PRID EQ "">

	<CFPARAM NAME="Current_Cost_Lag" DEFAULT="0">	

	<CFPARAM NAME="final_compounded_desc_calc1" DEFAULT="">
	<CFPARAM NAME="final_compounded_amount_calc1" DEFAULT="">
	<CFPARAM NAME="final_compounded_amount_uom1" DEFAULT="$">

	<CFPARAM NAME="final_compounded_desc_calc2" DEFAULT="">
	<CFPARAM NAME="final_compounded_amount_calc2" DEFAULT="">
	<CFPARAM NAME="final_compounded_amount_uom2" DEFAULT="$">

	<CFPARAM NAME="final_compounded_desc_calc3" DEFAULT="">
	<CFPARAM NAME="final_compounded_amount_calc3" DEFAULT="">
	<CFPARAM NAME="final_compounded_amount_uom3" DEFAULT="$">

	<CFPARAM NAME="final_compounded_desc_calc4" DEFAULT="">
	<CFPARAM NAME="final_compounded_amount_calc4" DEFAULT="">
	<CFPARAM NAME="final_compounded_amount_uom4" DEFAULT="$">

	<CFPARAM NAME="final_independent_desc_calc1" DEFAULT="">
	<CFPARAM NAME="final_independent_amount_calc1" DEFAULT="">
	<CFPARAM NAME="final_independent_amount_uom1" DEFAULT="$">

	<CFPARAM NAME="final_independent_desc_calc2" DEFAULT="">
	<CFPARAM NAME="final_independent_amount_calc2" DEFAULT="">
	<CFPARAM NAME="final_independent_amount_uom2" DEFAULT="$">

	<CFPARAM NAME="final_independent_desc_calc3" DEFAULT="">
	<CFPARAM NAME="final_independent_amount_calc3" DEFAULT="">
	<CFPARAM NAME="final_independent_amount_uom3" DEFAULT="$">

	<CFPARAM NAME="final_independent_desc_calc4" DEFAULT="">
	<CFPARAM NAME="final_independent_amount_calc4" DEFAULT="">
	<CFPARAM NAME="final_independent_amount_uom4" DEFAULT="$">

<CFELSE>
</CFIF>




<!--- <CFABORT> --->

<CFSET size=1><FIELDSET STYLE="padding:5px; width: 100%; border: 1px solid Silver;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Selected options</LEGEND>

<TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="100%">

<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP><B>Rule Name:</B></TD>
	<TD BGCOLOR="Orange" ROWSPAN="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD>
	<TD WIDTH="100%"><CFOUTPUT>#ReplaceList(form.aa_rulename,"<,>","&lt;,&gt;")#</CFOUTPUT></TD>
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

<CFLOOP INDEX="i" FROM="1" TO="#form.aa_comm_number#">
<CFOUTPUT>
<TR>
	<TD VALIGN="top" ALIGN="right"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="5" BORDER="0" ALT=""><BR>

		<!--- Get the name of the commodities --->
		<CFQUERY NAME="get_comm_name" datasource="#application.datasource#">
			select	symbol_description
			from	commodities_symbol
			where	symbol = '#evaluate('Commodity_'&'#i#')#'
		</CFQUERY>
		<B>#get_comm_name.symbol_description#</B>
	</TD>

	<TD>
	
		<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="">
			<TR>
				<TD VALIGN="top">
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
						<TR>
							<TD COLSPAN="100%">Sample data</TD>
						</TR>
						<TR>
							<TD COLSPAN="100%" BGCOLOR="#color#"><IMG SRC="/images/fill.gif" BORDER="0" ALT=""></TD>
						</TR>
						<TR>
							<TD>Size:</TD>
							<TD>#evaluate('sample_size_'&'#i#')# #evaluate('Time_UOM_sample_size_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>Lag</TD>
							<TD>#evaluate('point_in_time_'&'#i#')# #evaluate('Time_UOM_point_in_time_'&'#i#')#</TD>
						</TR>
					</TABLE>
				</TD>
				<TD VALIGN="top">
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
						<TR>
							<TD COLSPAN="100%">Compounded Calculations</TD>
						</TR>
						<TR>
							<TD COLSPAN="100%" BGCOLOR="#color#"><IMG SRC="/images/fill.gif" BORDER="0" ALT=""></TD>
						</TR>
						<TR>
							<TD WIDTH="140">#evaluate('compounded_desc_calc1_'&'#i#')#</TD>
							<TD>#evaluate('compounded_amount_calc1_'&'#i#')##evaluate('compounded_amount_uom1_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('compounded_desc_calc2_'&'#i#')#</TD>
							<TD>#evaluate('compounded_amount_calc2_'&'#i#')##evaluate('compounded_amount_uom2_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('compounded_desc_calc3_'&'#i#')#</TD>
							<TD>#evaluate('compounded_amount_calc3_'&'#i#')##evaluate('compounded_amount_uom3_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('compounded_desc_calc4_'&'#i#')#</TD>
							<TD>#evaluate('compounded_amount_calc4_'&'#i#')##evaluate('compounded_amount_uom4_'&'#i#')#</TD>
						</TR>
					</TABLE>
				</TD>
				<TD VALIGN="top">
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
						<TR>
							<TD COLSPAN="100%">Independent Calculations</TD>
						</TR>
						<TR>
							<TD COLSPAN="100%" BGCOLOR="#color#"><IMG SRC="/images/fill.gif" BORDER="0" ALT=""></TD>
						</TR>
						<TR>
							<TD WIDTH="140">#evaluate('independent_desc_calc1_'&'#i#')#</TD>
							<TD>#evaluate('independent_amount_calc1_'&'#i#')##evaluate('independent_amount_uom1_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('independent_desc_calc2_'&'#i#')#</TD>
							<TD>#evaluate('independent_amount_calc2_'&'#i#')##evaluate('independent_amount_uom2_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('independent_desc_calc3_'&'#i#')#</TD>
							<TD>#evaluate('independent_amount_calc3_'&'#i#')##evaluate('independent_amount_uom3_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('independent_desc_calc4_'&'#i#')#</TD>
							<TD>#evaluate('independent_amount_calc4_'&'#i#')##evaluate('independent_amount_uom4_'&'#i#')#</TD>
						</TR>
					</TABLE>
				</TD>
			</TR>
		</TABLE>

	</TD>
</TR>
</CFOUTPUT>
</CFLOOP>


</TABLE>




<B><FONT COLOR="Red" SIZE="2"><B>[</B></FONT> <A HREF="javascript:history.back();">revise these values</A> <FONT COLOR="Red" SIZE="2"><B>]</B></FONT></B>

</FIELDSET>





<FORM ACTION="index5.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
	
<STYLE>
INPUT {
	font-size : 9px;
}
</STYLE>




<FIELDSET STYLE="padding:5px; width: 100%; border: 1px solid Silver;">
<span id="error_Comm_Weight"></span>&nbsp;<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Commodity Pricing Weight</LEGEND>
<BR>
	<!--- Number of commodities:<CFOUTPUT>#form.aa_comm_number#</CFOUTPUT> --->
	
	<CFLOOP INDEX="i" FROM="1" TO="#form.aa_comm_number#">
	
		<!--- Get the name of the commodities --->
		<CFQUERY NAME="get_comm_name" datasource="#application.datasource#">
			select	symbol_description
			from	commodities_symbol
			where	symbol = '#evaluate('Commodity_'&'#i#')#'
		</CFQUERY>
		
			<CFOUTPUT>
				<TABLE>
				<TR>
					<TD WIDTH="150" ALIGN="right"><B>#get_comm_name.symbol_description#</B></TD>
					<TD>
						<CFIF FORM.PRID NEQ "">
							<INPUT TYPE="text" NAME="Comm_Weight_#i#" SIZE="3" VALUE="#evaluate('Form.Comm_Weight_'&'#i#')#" MAXLENGTH="6" STYLE="text-align: center;"><B>%</B>
						<CFELSE>
							<!--- Propose a calulated weight for each commodity --->
							<CFSET weight=decimalformat(evaluate(100/form.aa_comm_number))>
							<INPUT TYPE="text" NAME="Comm_Weight_#i#" SIZE="3" VALUE="#weight#" MAXLENGTH="6" STYLE="text-align: center;"><B>%</B>
						</CFIF>
					</TD>
				</TR>
				</TABLE>
			</CFOUTPUT>
	
	</CFLOOP>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<I><FONT COLOR="Red">The total weight of all commodities, must add up to 100%</FONT></I>
<BR><BR>
</FIELDSET>


<BR>
	

<FIELDSET STYLE="padding:5px; width: 100%; border: 1px solid Silver;">
<span id="error_Current_Cost_Lag"></span>&nbsp;<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Current Cost Lag</LEGEND>
<BR>

What is the current cost lag in weeks:
<CFOUTPUT><INPUT TYPE="text" NAME="Current_Cost_Lag" STYLE="text-align:center;" SIZE="3" MAXLENGTH="6" value="#Current_Cost_Lag#" onKeyUp="clenseText(this, '0123456789');"></CFOUTPUT>


</FIELDSET>


<BR>



	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- The master table settings for all objects														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET table_settings="BORDER='0' CELLSPACING='2' CELLPADDING='0' WIDTH='100%'">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<CFIF form.aa_comm_number NEQ 1>


<FIELDSET STYLE="padding:5px; width: 100%; border: 1px solid Silver;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Final Adjustments</LEGEND>

<BR>

<CFOUTPUT>

<TABLE CELLPADDING="5" CELLSPACING="0" BORDER="0" ALIGN="center">
<TR>
	<TD>
		
		<TABLE #table_settings#>
			<TR>
				<TD VALIGN="bottom" WIDTH="100%" COLSPAN="3"><DIV CLASS="title2">Compounded Calculations</DIV><span id="error_final_compounded_desc"></span>&nbsp;</TD>
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
				<TD><INPUT TYPE="text" NAME="final_compounded_desc_calc1" SIZE="40" MAXLENGTH="45" value="#final_compounded_desc_calc1#" OnChange="javascript:CalculationsSelectIndex4(this);"></TD>
				<TD><input type="text" name="final_compounded_amount_calc1" size="4" value="#final_compounded_amount_calc1#" OnChange="javascript:CalculationsSelectIndex4(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<!-----<TD><SELECT NAME="final_compounded_amount_uom1"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>------->
				<TD><SELECT NAME="final_compounded_amount_uom1"><OPTION VALUE="$"<cfif final_compounded_amount_uom1 EQ "$"> SELECTED</cfif>>$</OPTION><OPTION VALUE="%"<cfif final_compounded_amount_uom1 EQ "%"> SELECTED</cfif>>%</OPTION></SELECT></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="final_compounded_desc_calc2" SIZE="40" MAXLENGTH="45" value="#final_compounded_desc_calc2#" OnChange="javascript:CalculationsSelectIndex4(this);"></TD>
				<TD><input type="text" name="final_compounded_amount_calc2" size="4" value="#final_compounded_amount_calc2#" OnChange="javascript:CalculationsSelectIndex4(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<!-----<TD><SELECT NAME="final_compounded_amount_uom2"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>------->
				<TD><SELECT NAME="final_compounded_amount_uom2"><OPTION VALUE="$"<cfif final_compounded_amount_uom2 EQ "$"> SELECTED</cfif>>$</OPTION><OPTION VALUE="%"<cfif final_compounded_amount_uom2 EQ "%"> SELECTED</cfif>>%</OPTION></SELECT></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="final_compounded_desc_calc3" SIZE="40" MAXLENGTH="45" value="#final_compounded_desc_calc3#" OnChange="javascript:CalculationsSelectIndex4(this);"></TD>
				<TD><input type="text" name="final_compounded_amount_calc3" size="4" value="#final_compounded_amount_calc3#" OnChange="javascript:CalculationsSelectIndex4(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<!-----<TD><SELECT NAME="final_compounded_amount_uom3"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>------->
				<TD><SELECT NAME="final_compounded_amount_uom3"><OPTION VALUE="$"<cfif final_compounded_amount_uom3 EQ "$"> SELECTED</cfif>>$</OPTION><OPTION VALUE="%"<cfif final_compounded_amount_uom3 EQ "%"> SELECTED</cfif>>%</OPTION></SELECT></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="final_compounded_desc_calc4" SIZE="40" MAXLENGTH="45" value="#final_compounded_desc_calc4#"></TD>
				<TD><input type="text" name="final_compounded_amount_calc4" size="4" value="#final_compounded_amount_calc4#" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<!-----<TD><SELECT NAME="final_compounded_amount_uom4"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>------->
				<TD><SELECT NAME="final_compounded_amount_uom4"><OPTION VALUE="$"<cfif final_compounded_amount_uom4 EQ "$"> SELECTED</cfif>>$</OPTION><OPTION VALUE="%"<cfif final_compounded_amount_uom4 EQ "%"> SELECTED</cfif>>%</OPTION></SELECT></TD>
			</TR>
		</table>
	</TD>
	<TD>
		<TABLE #table_settings#>
			<TR>
				<TD VALIGN="bottom" WIDTH="100%" COLSPAN="3"><DIV CLASS="title2">Independent Calculations</DIV><span id="error_final_independent_desc"></span>&nbsp;</TD>
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
				<TD><INPUT TYPE="text" NAME="final_independent_desc_calc1" SIZE="40" MAXLENGTH="45" value="#final_independent_desc_calc1#" OnChange="javascript:CalculationsSelectIndex4(this);"></TD>
				<TD><input type="text" name="final_independent_amount_calc1" size="4" value="#final_independent_amount_calc1#" OnChange="javascript:CalculationsSelectIndex4(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<!-----<TD><SELECT NAME="final_independent_amount_uom1"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>------->
				<TD><SELECT NAME="final_independent_amount_uom1"><OPTION VALUE="$"<cfif final_independent_amount_uom1 EQ "$"> SELECTED</cfif>>$</OPTION><OPTION VALUE="%"<cfif final_independent_amount_uom1 EQ "%"> SELECTED</cfif>>%</OPTION></SELECT></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="final_independent_desc_calc2" SIZE="40" MAXLENGTH="45" value="#final_independent_desc_calc2#" OnChange="javascript:CalculationsSelectIndex4(this);"></TD>
				<TD><input type="text" name="final_independent_amount_calc2" size="4" value="#final_independent_amount_calc2#" OnChange="javascript:CalculationsSelectIndex4(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<!-----<TD><SELECT NAME="final_independent_amount_uom2"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>------->
				<TD><SELECT NAME="final_independent_amount_uom2"><OPTION VALUE="$"<cfif final_independent_amount_uom2 EQ "$"> SELECTED</cfif>>$</OPTION><OPTION VALUE="%"<cfif final_independent_amount_uom2 EQ "%"> SELECTED</cfif>>%</OPTION></SELECT></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="final_independent_desc_calc3" SIZE="40" MAXLENGTH="45" value="#final_independent_desc_calc3#" OnChange="javascript:CalculationsSelectIndex4(this);"></TD>
				<TD><input type="text" name="final_independent_amount_calc3" size="4" value="#final_independent_amount_calc3#" OnChange="javascript:CalculationsSelectIndex4(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<!-----<TD><SELECT NAME="final_independent_amount_uom3"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>------->
				<TD><SELECT NAME="final_independent_amount_uom3"><OPTION VALUE="$"<cfif final_independent_amount_uom3 EQ "$"> SELECTED</cfif>>$</OPTION><OPTION VALUE="%"<cfif final_independent_amount_uom3 EQ "%"> SELECTED</cfif>>%</OPTION></SELECT></TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="text" NAME="final_independent_desc_calc4" SIZE="40" MAXLENGTH="45" value="#final_independent_desc_calc4#" OnChange="javascript:CalculationsSelectIndex4(this);"></TD>
				<TD><input type="text" name="final_independent_amount_calc4" size="4" value="#final_independent_amount_calc4#" OnChange="javascript:CalculationsSelectIndex4(this);" onKeyUp="clenseText(this, '0123456789.+-');"></TD>
				<!-----<TD><SELECT NAME="final_independent_amount_uom4"><OPTION VALUE="$" SELECTED>$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>------->
				<TD><SELECT NAME="final_independent_amount_uom4"><OPTION VALUE="$"<cfif final_independent_amount_uom4 EQ "$"> SELECTED</cfif>>$</OPTION><OPTION VALUE="%"<cfif final_independent_amount_uom4 EQ "%"> SELECTED</cfif>>%</OPTION></SELECT></TD>
			</TR>
		</table>	
	</TD>
</TR>
</TABLE>

<BR>

</CFOUTPUT>

</FIELDSET>


<CFELSE>

<INPUT TYPE="hidden" NAME="final_compounded_desc_calc1"	VALUE="0">
<INPUT TYPE="hidden" NAME="final_compounded_desc_calc2"	VALUE="0">
<INPUT TYPE="hidden" NAME="final_compounded_desc_calc3"	VALUE="0">
<INPUT TYPE="hidden" NAME="final_compounded_desc_calc4"	VALUE="0">

<INPUT TYPE="hidden" NAME="final_compounded_amount_calc1"	VALUE="0">
<INPUT TYPE="hidden" NAME="final_compounded_amount_calc2"	VALUE="0">
<INPUT TYPE="hidden" NAME="final_compounded_amount_calc3"	VALUE="0">
<INPUT TYPE="hidden" NAME="final_compounded_amount_calc4"	VALUE="0">

<INPUT TYPE="hidden" NAME="final_compounded_amount_uom1"	VALUE="$">
<INPUT TYPE="hidden" NAME="final_compounded_amount_uom2"	VALUE="$">
<INPUT TYPE="hidden" NAME="final_compounded_amount_uom3"	VALUE="$">
<INPUT TYPE="hidden" NAME="final_compounded_amount_uom4"	VALUE="$">

<INPUT TYPE="hidden" NAME="final_independent_desc_calc1"	VALUE="0">
<INPUT TYPE="hidden" NAME="final_independent_desc_calc2"	VALUE="0">
<INPUT TYPE="hidden" NAME="final_independent_desc_calc3"	VALUE="0">
<INPUT TYPE="hidden" NAME="final_independent_desc_calc4"	VALUE="0">

<INPUT TYPE="hidden" NAME="final_independent_amount_calc1"	VALUE="0">
<INPUT TYPE="hidden" NAME="final_independent_amount_calc2"	VALUE="0">
<INPUT TYPE="hidden" NAME="final_independent_amount_calc3"	VALUE="0">
<INPUT TYPE="hidden" NAME="final_independent_amount_calc4"	VALUE="0">

<INPUT TYPE="hidden" NAME="final_independent_amount_uom1"	VALUE="$">
<INPUT TYPE="hidden" NAME="final_independent_amount_uom2"	VALUE="$">
<INPUT TYPE="hidden" NAME="final_independent_amount_uom3"	VALUE="$">
<INPUT TYPE="hidden" NAME="final_independent_amount_uom4"	VALUE="$">


</CFIF>

<!--- Serialize the packet so that it can be passed from page to page								 --->
<CFSET Struct_Profit_Rule_Name.aa_rulename="<![CDATA[#Struct_Profit_Rule_Name.aa_rulename#]]>">
<CFWDDX ACTION="CFML2WDDX" INPUT="#Struct_Profit_Rule_Name#" OUTPUT="XML_Profit_Rule_Name">

<!--- These hidden boxes pass the options selected in this screen  --->
<INPUT TYPE="hidden" NAME="XML_Profit_Rule_Name"	VALUE="<CFOUTPUT>#XML_Profit_Rule_Name#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="aa_product_list" 		VALUE="<CFOUTPUT>#Struct_Profit_Rule_Name.aa_product_list#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="PRID"					VALUE="<CFOUTPUT>#FORM.PRID#</CFOUTPUT>">
</FORM>



<CF_BUTTON
BUTTON_NAME		=	""
BUTTON_CAPTION	=	"goto step 4"
BUTTON_ACTION	=	"javascript:validateAndSubmitIndex4(document.all.MyForm);"
BUTTON_TYPE		=	"link"
BUTTON_WIDTH	=	"125"
BUTTON_COLOR	=	"Navy"
BUTTON_TIP		=	""
FONT_COLOR		=	"White"
FONT_SIZE		=	"12"
FONT_WEIGHT		=	"bold">				

<!-------------------- Added By Deepa ----------------------------------------->
<SCRIPT LANGUAGE="JavaScript">
	document.body.onload=new Function ("disableElements4(document.all.MyForm,true)")
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
var aa_comm_number= <CFOUTPUT>#form.aa_comm_number#</CFOUTPUT>;
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="commodityScripts.js"></SCRIPT>
<CF_MessageWindow>
<!-----
edited from
"javascript:document.all.MyForm.submit();"
to
"javascript:validateAndSubmitIndex4(document.all.MyForm);"

Added <span id="error_sample_size#i#"></span>&nbsp;
Added <span id="error_final_compounded_desc"></span>&nbsp;
Added <span id="error_final_independent_desc"></span>&nbsp;
Added <span id="error_Current_Cost_Lag"></span>&nbsp;
Added OnChange="javascript:CalculationsSelectIndex4(this);"
------->
<!-------------------- End Added By Deepa ----------------------------------------->

