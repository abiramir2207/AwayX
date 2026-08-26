<!--- Get the profile for this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- Get the data for the passed rule --->

<CFQUERY NAME="Get_Rule_Data" datasource="#application.datasource#">
	Select		Pricing_Rule.Pricing_Rule_ID,
				Pricing_Rule.Pricing_Rule_Name,
				Pricing_Rule.Pricing_Rule_Date,
				Pricing_Rule.Pricing_Rule_Author,
				Pricing_Rule.Pricing_Rule_Final_Cost,
				Pricing_Rule.Pricing_Rule_Data
	From		Pricing_Rule
	Where		Pricing_Rule.Pricing_Rule_ID			=	'#URL.PRID#'
</CFQUERY>


<!--- Get the products of the rule --->
<CFQUERY name="Get_Rule_Products" datasource="#application.datasource#">
	Select		*
	From		Pricing_Rule_Products
	Where		Pricing_Rule_Products.Pricing_Rule_ID = '#Get_Rule_Data.Pricing_Rule_ID#'
</CFQUERY>


<!--- Convert the XML packet to a structure --->
<CFWDDX ACTION="wddx2cfml" INPUT="#Get_Rule_Data.Pricing_Rule_Data#" OUTPUT="struct_profit_rule_name">

<!------<CFSET pagetitle = "View Pricing Rule: "&Get_Rule_Data.Pricing_Rule_Name>----->
<CFSET pagetitle = "View Pricing Rule: " & ReplaceList(Get_Rule_Data.Pricing_Rule_Name,"<,>","&lt;,&gt;")>

<CFPARAM NAME="PageTitle" DEFAULT="">
<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
<TR>
	<TD ALIGN="left" BGCOLOR="Navy" BACKGROUND="/images/gradient.jpg" WIDTH="100%" HEIGHT="25"><SPAN STYLE="color:white; font-size:14px; font-weight: bold;"><CFOUTPUT>#ucase(PageTitle)#</CFOUTPUT></SPAN></TD>
</TR>
</TABLE>
<BR>



<CFIF Get_Profile_Settings.Commodity_Price_Rule_Create_Edit EQ 1>
		<B>
		<FONT COLOR="#FF0000" size="2">[</FONT>
		<FONT size="2"><a href="index.cfm" TARGET="_top">create new rule</a></FONT>
		<FONT COLOR="#FF0000" size="2">]</FONT>
		</B>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<B>
		<FONT COLOR="#FF0000" size="2">[</FONT>
		<FONT size="2"><a href="index2.cfm?PRID=<CFOUTPUT>#URL.PRID#</CFOUTPUT>">edit this rule</a></FONT>
		<FONT COLOR="#FF0000" size="2">]</FONT>
		</B>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<B>
		<FONT COLOR="#FF0000" size="2">[</FONT>
		<FONT size="2"><a href="delete_pricing_rule.cfm?PRID=<CFOUTPUT>#URL.PRID#</CFOUTPUT>">delete this rule</a></FONT>
		<FONT COLOR="#FF0000" size="2">]</FONT>
		</B>
</CFIF>


<BR><BR>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Default values for the HR lines --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET color="Orange">
<CFSET size=1>


<!--- Get the name of the pricing rule author --->
<CFQUERY NAME="Get_Author_Name" datasource="#application.datasource#">
	Select		Name_First, Name_Last
	From		_Users
	Where		User_ID	=	'#Get_Rule_Data.Pricing_Rule_Author#'
</CFQUERY>


	<TABLE BGCOLOR="White" BORDERCOLOR="Orange" BORDER="1" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This pricing rule was last updated by <CFOUTPUT>#Get_Author_Name.Name_First# #Get_Author_Name.Name_Last#</CFOUTPUT> on <CFOUTPUT>#dateformat(Get_Rule_Data.Pricing_Rule_Date, 'mm/dd/yyyy')# #timeformat(Get_Rule_Data.Pricing_Rule_Date, 'hh:mm:sstt')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>

<!--- <CFOUTPUT>#Get_Rule_Data.Pricing_Rule_Products#</CFOUTPUT> --->

<TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0">
  <TR>
    <TD VALIGN="TOP" ALIGN="right"><B>Rule Name</B></TD>
    <TD ROWSPAN="100%" BGCOLOR="Orange"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
    <TD VALIGN="TOP" ALIGN="LEFT"><CFOUTPUT>#ReplaceList(Get_Rule_Data.Pricing_Rule_Name,"<,>","&lt;,&gt;")#</CFOUTPUT></TD>
  </TR>
  <TR>
    <TD VALIGN="TOP" ALIGN="right"><B>Products</B></TD>
    <TD VALIGN="TOP" ALIGN="LEFT">

	<CFSET Form.AA_PRODUCT_LIST=valuelist(Get_Rule_Products.Pricing_Rule_Products_Item_ID)>
	
		
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Open layer Options																			 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<CFSCRIPT>
		Border="Yes";					BorderSize=1;				BorderColor="orange";			Image="/images/plus3.gif";
		ImageOpen="/images/minus3.gif";	TitleColor="Blue";			TitleFont="Arial";				TitleSize=8;
		IsClosed="Yes";					Width=250;
	</CFSCRIPT>
	
	
	
	<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Hide Products"  
	TitleClosed="ViewProducts"  
	TitleTooltip="Click here to togle view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
	<INPUT TYPE="HIDDEN" ID="AA_PRODUCT_LIST" NAME="AA_PRODUCT_LIST" VALUE="<CFOUTPUT>#FORM.AA_PRODUCT_LIST#</CFOUTPUT>">
	<CFINCLUDE TEMPLATE="product_list.cfm">	
	</CF_openLayer>


	</TD>
  </TR>

<!--- 
  <TR>
    <TD VALIGN="TOP" ALIGN="right"><B>Number of Commodities</B></TD>
    <TD VALIGN="TOP" ALIGN="LEFT"><CFOUTPUT>#struct_profit_rule_name.AA_COMM_NUMBER#</CFOUTPUT></TD>
  </TR>
 --->

	<TR>
		<TD ALIGN="right" VALIGN="top" NOWRAP><B>Cost Lag:</B></TD>
		<TD><CFOUTPUT>#struct_profit_rule_name.Current_Cost_Lag# weeks</CFOUTPUT></TD>
	</TR>


<!--- 
<CFLOOP INDEX="i" FROM="1" TO="#struct_profit_rule_name.AA_COMM_NUMBER#">
	<CFOUTPUT>#evaluate('struct_profit_rule_name.COMMODITY_'&'#i#')#</CFOUTPUT>

</CFLOOP>
 --->






















<CFLOOP INDEX="i" FROM="1" TO="#STRUCT_PROFIT_RULE_NAME.aa_comm_number#">
<CFOUTPUT>
<TR>
	<TD VALIGN="top" ALIGN="right" WIDTH="150"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="5" BORDER="0" ALT=""><BR>

		<!--- Get the name of the commodities --->
		<CFQUERY NAME="get_comm_name" datasource="#application.datasource#">
			select	symbol_description
			from	commodities_symbol
			where	symbol = '#evaluate('STRUCT_PROFIT_RULE_NAME.Commodity_'&'#i#')#'
		</CFQUERY>
		<B>#get_comm_name.symbol_description#</B>
	</TD>

	<TD VALIGN="top" WIDTH="100%">
	
		<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="">
			<TR>
				<TD VALIGN="top">
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
						<TR>
							<TD COLSPAN="100%">Compounded Calculations</TD>
						</TR>
						<TR>
							<TD COLSPAN="100%" BGCOLOR="#color#"><IMG SRC="/images/fill.gif" BORDER="0" ALT=""></TD>
						</TR>
						<TR>
							<TD WIDTH="200">#evaluate('STRUCT_PROFIT_RULE_NAME.compounded_desc_calc1_'&'#i#')#</TD>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.compounded_amount_calc1_'&'#i#')##evaluate('STRUCT_PROFIT_RULE_NAME.compounded_amount_uom1_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.compounded_desc_calc2_'&'#i#')#</TD>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.compounded_amount_calc2_'&'#i#')##evaluate('STRUCT_PROFIT_RULE_NAME.compounded_amount_uom2_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.compounded_desc_calc3_'&'#i#')#</TD>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.compounded_amount_calc3_'&'#i#')##evaluate('STRUCT_PROFIT_RULE_NAME.compounded_amount_uom3_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.compounded_desc_calc4_'&'#i#')#</TD>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.compounded_amount_calc4_'&'#i#')##evaluate('STRUCT_PROFIT_RULE_NAME.compounded_amount_uom4_'&'#i#')#</TD>
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
							<TD WIDTH="200">#evaluate('STRUCT_PROFIT_RULE_NAME.independent_desc_calc1_'&'#i#')#</TD>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.independent_amount_calc1_'&'#i#')##evaluate('STRUCT_PROFIT_RULE_NAME.independent_amount_uom1_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.independent_desc_calc2_'&'#i#')#</TD>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.independent_amount_calc2_'&'#i#')##evaluate('STRUCT_PROFIT_RULE_NAME.independent_amount_uom2_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.independent_desc_calc3_'&'#i#')#</TD>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.independent_amount_calc3_'&'#i#')##evaluate('STRUCT_PROFIT_RULE_NAME.independent_amount_uom3_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.independent_desc_calc4_'&'#i#')#</TD>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.independent_amount_calc4_'&'#i#')##evaluate('STRUCT_PROFIT_RULE_NAME.independent_amount_uom4_'&'#i#')#</TD>
						</TR>
					</TABLE>
				</TD>
			</TR>
			<TR>
				<TD VALIGN="top">
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
						<TR>
							<TD COLSPAN="100%">Sample data</TD>
						</TR>
						<TR>
							<TD COLSPAN="100%" BGCOLOR="#color#"><IMG SRC="/images/fill.gif" BORDER="0" ALT=""></TD>
						</TR>
						<TR>
							<TD>Size:</TD>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.sample_size_'&'#i#')# #evaluate('STRUCT_PROFIT_RULE_NAME.Time_UOM_sample_size_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>Lag</TD>
							<TD>#evaluate('STRUCT_PROFIT_RULE_NAME.point_in_time_'&'#i#')# #evaluate('STRUCT_PROFIT_RULE_NAME.Time_UOM_point_in_time_'&'#i#')#</TD>
						</TR>
					</TABLE>
				</TD>
				<TD VALIGN="top">
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
						<TR>
							<TD COLSPAN="100%">Pricing Weight</TD>
						</TR>
						<TR>
							<TD COLSPAN="100%" BGCOLOR="#color#"><IMG SRC="/images/fill.gif" BORDER="0" ALT=""></TD>
						</TR>
						<TR>
							<TD WIDTH="140">#evaluate('STRUCT_PROFIT_RULE_NAME.Comm_Weight_'&'#i#')# %</TD>
							<TD></TD>
						</TR>
					</TABLE>
				</TD>
			</TR>
		</TABLE>

	</TD>
</TR>

</CFOUTPUT>
</CFLOOP>










<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF STRUCT_PROFIT_RULE_NAME.aa_comm_number GT 1>

<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP><B>Final<BR>Adjustments:</B></TD>
	<TD>
		
		<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="">
		  <TR>
			<TD>
		
		
				<CFOUTPUT>
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
						<TR>
							<TD COLSPAN="100%">Compounded Calculations</TD>
						</TR>
						<TR>
							<TD COLSPAN="100%" BGCOLOR="#color#"><IMG SRC="/images/fill.gif" BORDER="0" ALT=""></TD>
						</TR>
						<TR>
							<TD WIDTH="200">#struct_profit_rule_name.final_compounded_desc_calc1#</TD>
							<TD>#struct_profit_rule_name.final_compounded_amount_calc1##struct_profit_rule_name.final_compounded_amount_uom1#</TD>
						</TR>
						<TR>
							<TD WIDTH="200">#struct_profit_rule_name.final_compounded_desc_calc2#</TD>
							<TD>#struct_profit_rule_name.final_compounded_amount_calc2##struct_profit_rule_name.final_compounded_amount_uom2#</TD>
						</TR>
						<TR>
							<TD WIDTH="200">#struct_profit_rule_name.final_compounded_desc_calc3#</TD>
							<TD>#struct_profit_rule_name.final_compounded_amount_calc3##struct_profit_rule_name.final_compounded_amount_uom3#</TD>
						</TR>
						<TR>
							<TD WIDTH="200">#struct_profit_rule_name.final_compounded_desc_calc4#</TD>
							<TD>#struct_profit_rule_name.final_compounded_amount_calc4##struct_profit_rule_name.final_compounded_amount_uom4#</TD>
						</TR>
					</TABLE>
				</CFOUTPUT>	
			
			</TD>
			<TD>
		
		
				<CFOUTPUT>
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
						<TR>
							<TD COLSPAN="100%">Independent Calculations</TD>
						</TR>
						<TR>
							<TD COLSPAN="100%" BGCOLOR="#color#"><IMG SRC="/images/fill.gif" BORDER="0" ALT=""></TD>
						</TR>
						<TR>
							<TD WIDTH="200">#struct_profit_rule_name.final_independent_desc_calc1#</TD>
							<TD>#struct_profit_rule_name.final_independent_amount_calc1##struct_profit_rule_name.final_independent_amount_uom1#</TD>
						</TR>
						<TR>
							<TD WIDTH="200">#struct_profit_rule_name.final_independent_desc_calc2#</TD>
							<TD>#struct_profit_rule_name.final_independent_amount_calc2##struct_profit_rule_name.final_independent_amount_uom2#</TD>
						</TR>
						<TR>
							<TD WIDTH="200">#struct_profit_rule_name.final_independent_desc_calc3#</TD>
							<TD>#struct_profit_rule_name.final_independent_amount_calc3##struct_profit_rule_name.final_independent_amount_uom3#</TD>
						</TR>
						<TR>
							<TD WIDTH="200">#struct_profit_rule_name.final_independent_desc_calc4#</TD>
							<TD>#struct_profit_rule_name.final_independent_amount_calc4##struct_profit_rule_name.final_independent_amount_uom4#</TD>
						</TR>
					</TABLE>
				</CFOUTPUT>
			
			</TD>
		  </TR>
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</TABLE>



