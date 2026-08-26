<CFSET PAGETITLE = "step 4 of 4">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CF_TEMPLATENAME><CFOUTPUT>#templatename#</CFOUTPUT> --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Default values for the HR lines --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET color="Orange">
<CFSET size=1>


<!--- de-serialize the packet so that it can be passed from page to page								 --->
<CFWDDX ACTION="wddx2cfml" INPUT="#form.xml_profit_rule_name#" OUTPUT="struct_profit_rule_name">

<!--- append to the created structure the data from the previous form								 --->
<CFLOOP INDEX="item" LIST="#form.fieldnames#" DELIMITERS=",">										 
	<CFIF ITEM NEQ 'XML_PROFIT_RULE_NAME'>
		<CFSET VARIABLES.TEMP = STRUCTINSERT(STRUCT_PROFIT_RULE_NAME, '#ITEM#', #EVALUATE(ITEM)#, TRUE)>
	</CFIF>
</CFLOOP>																							 

<!--- serialize the packet so that it can be passed from page to page								 --->
<CFWDDX ACTION="cfml2wddx" INPUT="#struct_profit_rule_name#" OUTPUT="xml_profit_rule_name"><FIELDSET STYLE="padding:5px; width: 100%; border: 1px solid Silver;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Selected options</LEGEND>

<TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="100%">
<CFOUTPUT>
<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP><B>Rule Name:</B></TD>
	<TD BGCOLOR="Orange" ROWSPAN="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD>
	<TD WIDTH="100%">#struct_profit_rule_name.aa_rulename#</TD>
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
		IsClosed="Yes";					Width=245;
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
</CFOUTPUT>

<TR>
	<TD ALIGN="right" VALIGN="top" NOWRAP><B>Current Cost Lag:</B></TD>
	<TD>
		<CFOUTPUT>#struct_profit_rule_name.Current_Cost_Lag#</CFOUTPUT> weeks<BR>
	</TD>
</TR>

<CFLOOP INDEX="i" FROM="1" TO="#struct_profit_rule_name.aa_comm_number#">
<CFOUTPUT>
<TR>
	<TD VALIGN="top" NOWRAP ALIGN="right"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="5" BORDER="0" ALT=""><BR>

		<!--- Get the name of the commodities --->
		<CFQUERY NAME="get_comm_name" datasource="#application.datasource#">
			select	symbol_description
			from	commodities_symbol
			where	symbol = '#evaluate('struct_profit_rule_name.Commodity_'&'#i#')#'
		</CFQUERY>
		<B>#get_comm_name.symbol_description#</B>
	</TD>

	<TD VALIGN="top">
	
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
							<TD WIDTH="175">#evaluate('struct_profit_rule_name.compounded_desc_calc1_'&'#i#')#</TD>
							<TD>#evaluate('struct_profit_rule_name.compounded_amount_calc1_'&'#i#')##evaluate('struct_profit_rule_name.compounded_amount_uom1_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('struct_profit_rule_name.compounded_desc_calc2_'&'#i#')#</TD>
							<TD>#evaluate('struct_profit_rule_name.compounded_amount_calc2_'&'#i#')##evaluate('struct_profit_rule_name.compounded_amount_uom2_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('struct_profit_rule_name.compounded_desc_calc3_'&'#i#')#</TD>
							<TD>#evaluate('struct_profit_rule_name.compounded_amount_calc3_'&'#i#')##evaluate('struct_profit_rule_name.compounded_amount_uom3_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('struct_profit_rule_name.compounded_desc_calc4_'&'#i#')#</TD>
							<TD>#evaluate('struct_profit_rule_name.compounded_amount_calc4_'&'#i#')##evaluate('struct_profit_rule_name.compounded_amount_uom4_'&'#i#')#</TD>
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
							<TD WIDTH="175">#evaluate('struct_profit_rule_name.independent_desc_calc1_'&'#i#')#</TD>
							<TD>#evaluate('struct_profit_rule_name.independent_amount_calc1_'&'#i#')##evaluate('struct_profit_rule_name.independent_amount_uom1_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('struct_profit_rule_name.independent_desc_calc2_'&'#i#')#</TD>
							<TD>#evaluate('struct_profit_rule_name.independent_amount_calc2_'&'#i#')##evaluate('struct_profit_rule_name.independent_amount_uom2_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('struct_profit_rule_name.independent_desc_calc3_'&'#i#')#</TD>
							<TD>#evaluate('struct_profit_rule_name.independent_amount_calc3_'&'#i#')##evaluate('struct_profit_rule_name.independent_amount_uom3_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>#evaluate('struct_profit_rule_name.independent_desc_calc4_'&'#i#')#</TD>
							<TD>#evaluate('struct_profit_rule_name.independent_amount_calc4_'&'#i#')##evaluate('struct_profit_rule_name.independent_amount_uom4_'&'#i#')#</TD>
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
							<TD>#evaluate('struct_profit_rule_name.sample_size_'&'#i#')# #evaluate('struct_profit_rule_name.Time_UOM_sample_size_'&'#i#')#</TD>
						</TR>
						<TR>
							<TD>Lag</TD>
							<TD>#evaluate('struct_profit_rule_name.point_in_time_'&'#i#')# #evaluate('struct_profit_rule_name.Time_UOM_point_in_time_'&'#i#')#</TD>
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
							<TD WIDTH="140">#evaluate('struct_profit_rule_name.Comm_Weight_'&'#i#')# %</TD>
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
	<TD ALIGN="right" VALIGN="top" NOWRAP>
	<B>Final<BR>Adjustments</B>
	</TD>
	<TD VALIGN="top">

		<CFOUTPUT>
			<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0">
			<TR>
			<TD>
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD COLSPAN="100%">Compounded Calculations</TD>
					</TR>
					<TR>
						<TD COLSPAN="100%" BGCOLOR="#color#"><IMG SRC="/images/fill.gif" BORDER="0" ALT=""></TD>
					</TR>
					<TR>
						<TD WIDTH="175">#struct_profit_rule_name.final_compounded_desc_calc1#</TD>
						<TD>#struct_profit_rule_name.final_compounded_amount_calc1##struct_profit_rule_name.final_compounded_amount_uom1#</TD>
					</TR>
					<TR>
						<TD WIDTH="175">#struct_profit_rule_name.final_compounded_desc_calc2#</TD>
						<TD>#struct_profit_rule_name.final_compounded_amount_calc2##struct_profit_rule_name.final_compounded_amount_uom2#</TD>
					</TR>
					<TR>
						<TD WIDTH="175">#struct_profit_rule_name.final_compounded_desc_calc3#</TD>
						<TD>#struct_profit_rule_name.final_compounded_amount_calc3##struct_profit_rule_name.final_compounded_amount_uom3#</TD>
					</TR>
					<TR>
						<TD WIDTH="175">#struct_profit_rule_name.final_compounded_desc_calc4#</TD>
						<TD>#struct_profit_rule_name.final_compounded_amount_calc4##struct_profit_rule_name.final_compounded_amount_uom4#</TD>
					</TR>
				</TABLE>
			</TD>
			<TD>
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD COLSPAN="100%">Independent Calculations</TD>
					</TR>
					<TR>
						<TD COLSPAN="100%" BGCOLOR="#color#"><IMG SRC="/images/fill.gif" BORDER="0" ALT=""></TD>
					</TR>
					<TR>
						<TD WIDTH="175">#struct_profit_rule_name.final_independent_desc_calc1#</TD>
						<TD>#struct_profit_rule_name.final_independent_amount_calc1##struct_profit_rule_name.final_independent_amount_uom1#</TD>
					</TR>
					<TR>
						<TD WIDTH="175">#struct_profit_rule_name.final_independent_desc_calc2#</TD>
						<TD>#struct_profit_rule_name.final_independent_amount_calc2##struct_profit_rule_name.final_independent_amount_uom2#</TD>
					</TR>
					<TR>
						<TD WIDTH="175">#struct_profit_rule_name.final_independent_desc_calc3#</TD>
						<TD>#struct_profit_rule_name.final_independent_amount_calc3##struct_profit_rule_name.final_independent_amount_uom3#</TD>
					</TR>
					<TR>
						<TD WIDTH="175">#struct_profit_rule_name.final_independent_desc_calc4#</TD>
						<TD>#struct_profit_rule_name.final_independent_amount_calc4##struct_profit_rule_name.final_independent_amount_uom4#</TD>
					</TR>
				</TABLE>
			</TD>
			</TR>
			</TABLE>
		</CFOUTPUT>

	</TD>
</TR>
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</TABLE>


<B><FONT COLOR="Red" SIZE="2"><B>[</B></FONT> <A HREF="javascript:history.back();">revise these values</A> <FONT COLOR="Red" SIZE="2"><B>]</B></FONT></B>

</FIELDSET>

<!--- <cfoutput>#xml_profit_rule_name#</cfoutput><hr> --->

 

<!--- Since there could be a current cost lag (ask Paul to explain...) --->
<!--- the "stake in the ground" date may or not be today ie now() --->
<!--- before anything else gets done move "today" back X number of weeks --->
<CFSET adjusted_today=evaluate(NOW()-(Current_Cost_Lag*7))> 
  
 
 <!--- find the last friday --->
<CFSET LAST_FRIDAY = #DATEADD("d", -DAYOFWEEK(adjusted_today)+6-7, adjusted_today)#>

<!--- last friday: <CFOUTPUT>#dateformat(last_friday, 'mm/dd/yy')#</CFOUTPUT> --->
 
 
 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- get the commodity dates/data to analyze														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<CFPARAM NAME="SubTotal_Weighted_Cost" DEFAULT="0">

<CFLOOP INDEX="i" FROM="1" TO="#struct_profit_rule_name.aa_comm_number#">

<CFPARAM NAME="comm_symbol_#i#" DEFAULT="#evaluate('struct_profit_rule_name.commodity_'&'#i#')#">

<!--- get the name of the commodity --->
<CFQUERY NAME="get_comm_name" datasource="#application.datasource#">
	select	symbol_description
	from	commodities_symbol
	where	symbol = '#evaluate("comm_symbol_"&"#i#")#'
</CFQUERY>

<!--- <CFOUTPUT><B>#get_comm_name.symbol_description#</B></CFOUTPUT><BR> --->


<!--- set the number of days/data points lag --->
<CFPARAM NAME="sample_lag_#i#" DEFAULT="#evaluate(evaluate('struct_profit_rule_name.point_in_time_'&'#i#')*7)#">

<!--- start date = last friday minus the lag number of days --->
<CFPARAM NAME="startdate_#i#" DEFAULT="#createodbcdate(evaluate(last_friday-evaluate('sample_lag_'&'#i#')))#">
<!--- <CFOUTPUT>start: #dateformat(evaluate('startdate_#i#'), 'mm/dd/yy')#</CFOUTPUT><BR> --->


<!--- calculate the size/number of data points of the sample  --->
<CFPARAM NAME="sample_size_#i#" DEFAULT="#evaluate(evaluate('struct_profit_rule_name.sample_size_'&'#i#')*7)#">
<!--- <cfoutput>#evaluate('sample_size_#i#')#</cfoutput><br> --->


<!--- the begining of the sample period is the startdate variable --->
<!--- the end of the sample period is the startdate minus the size of the sample plus 3  --->
<!--- so that the period really ends on the monday: first day of the last week --->
<CFPARAM NAME="enddate_#i#" DEFAULT="#createodbcdate(evaluate(evaluate('startdate_'&'#i#') - evaluate('sample_size_'&'#i#')+3))#">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Temporarily disable this... --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- get the commodity data... --->

<CFSTOREDPROC PROCEDURE="AVERAGE_COMM_LAST" datasource="#application.datasource#">
	<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@@C_SYMBOL"		VALUE="#evaluate('comm_symbol_'&'#i#')#">
	<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_TIMESTAMP"	DBVARNAME="@@C_MIN_Date"	VALUE="#evaluate('enddate_'&'#i#')#">
	<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_TIMESTAMP"	DBVARNAME="@@C_MAX_Date"	VALUE="#evaluate('startdate_'&'#i#')#">
	<CFPROCPARAM TYPE="Out" CFSQLTYPE="CF_SQL_FLOAT"	DBVARNAME="@@COMM_AVG"		VARIABLE="comm_avg_#i#">
</CFSTOREDPROC>
<CFOUTPUT><B> comm_avg_#i#: #evaluate('comm_avg_'&'#i#')# </B></CFOUTPUT>


<CFABORT>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Compounded calculations																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---> 
<CFSET base_value=50>

<!--- Decide if the values are to be seen as percentages or dollars --->
<!--- Compounded --->
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_UOM1_'&'#i#') EQ "%">
	<CFSET "C_Value1_#i#"=#evaluate((evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_CALC1_'&'#i#')+100)/100)#>
<CFELSE>
	<CFSET "C_Value1_#i#"="#evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_CALC1_'&'#i#')#">
</CFIF>
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_UOM2_'&'#i#') EQ "%">
	<CFSET "C_Value2_#i#"=#evaluate((evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_CALC2_'&'#i#')+100)/100)#>
<CFELSE>
	<CFSET "C_Value2_#i#"="#evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_CALC2_'&'#i#')#">
</CFIF>
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_UOM3_'&'#i#') EQ "%">
	<CFSET "C_Value3_#i#"=#evaluate((evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_CALC3_'&'#i#')+100)/100)#>
<CFELSE>
	<CFSET "C_Value3_#i#"="#evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_CALC3_'&'#i#')#">
</CFIF>
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_UOM4_'&'#i#') EQ "%">
	<CFSET "C_Value4_#i#"=#evaluate((evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_CALC4_'&'#i#')+100)/100)#>
<CFELSE>
	<CFSET "C_Value4_#i#"="#evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_CALC4_'&'#i#')#">
</CFIF>

<!--- Independent --->
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_UOM1_'&'#i#') EQ "%">
	<CFSET "I_Value1_#i#"=#evaluate((evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_CALC1_'&'#i#')+100)/100)#>
<CFELSE>
	<CFSET "I_Value1_#i#"="#evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_CALC1_'&'#i#')#">
</CFIF>
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_UOM2_'&'#i#') EQ "%">
	<CFSET "I_Value2_#i#"=#evaluate((evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_CALC2_'&'#i#')+100)/100)#>
<CFELSE>
	<CFSET "I_Value2_#i#"="#evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_CALC2_'&'#i#')#">
</CFIF>
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_UOM3_'&'#i#') EQ "%">
	<CFSET "I_Value3_#i#"=#evaluate((evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_CALC3_'&'#i#')+100)/100)#>
<CFELSE>
	<CFSET "I_Value3_#i#"="#evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_CALC3_'&'#i#')#">
</CFIF>
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_UOM4_'&'#i#') EQ "%">
	<CFSET "I_Value4_#i#"=#evaluate((evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_CALC4_'&'#i#')+100)/100)#>
<CFELSE>
	<CFSET "I_Value4_#i#"="#evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_CALC4_'&'#i#')#">
</CFIF>

<!--- Calculate Compounded --->
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_UOM1_'&'#i#') EQ "%">
	<CFSET "C_Calc1_#i#"=base_value*evaluate('C_Value1_'&'#i#')>
<CFELSE>
	<CFSET "C_Calc1_#i#"=base_value+evaluate('C_Value1_'&'#i#')>
</CFIF>
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_UOM2_'&'#i#') EQ "%">
	<CFSET "C_Calc2_#i#"=EVALUATE('C_Calc1_'&'#i#')*evaluate('C_Value2_'&'#i#')>
<CFELSE>
	<CFSET "C_Calc2_#i#"=EVALUATE('C_Calc1_'&'#i#')+evaluate('C_Value2_'&'#i#')>
</CFIF>
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_UOM3_'&'#i#') EQ "%">
	<CFSET "C_Calc3_#i#"=EVALUATE('C_Calc2_'&'#i#')*evaluate('C_Value3_'&'#i#')>
<CFELSE>
	<CFSET "C_Calc3_#i#"=EVALUATE('C_Calc2_'&'#i#')+evaluate('C_Value3_'&'#i#')>
</CFIF>
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.COMPOUNDED_AMOUNT_UOM4_'&'#i#') EQ "%">
	<CFSET "C_Calc4_#i#"=EVALUATE('C_Calc3_'&'#i#')*evaluate('C_Value4_'&'#i#')>
<CFELSE>
	<CFSET "C_Calc4_#i#"=EVALUATE('C_Calc3_'&'#i#')+evaluate('C_Value4_'&'#i#')>
</CFIF>

<!--- Total overhead of the compounded calculations --->
<CFSET "total_compounded_#i#"=evaluate(evaluate('C_Calc4_'&'#i#')-base_value)>

<!--- Calculate Independent --->
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_UOM1_'&'#i#') EQ "%">
	<CFSET "I_Calc1_#i#"=(base_value*evaluate('I_Value1_'&'#i#'))-base_value>
<CFELSE>
	<CFSET "I_Calc1_#i#"=evaluate('I_Value1_'&'#i#')>
</CFIF>
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_UOM2_'&'#i#') EQ "%">
	<CFSET "I_Calc2_#i#"=(base_value*evaluate('I_Value2_'&'#i#'))-base_value>
<CFELSE>
	<CFSET "I_Calc2_#i#"=evaluate('I_Value2_'&'#i#')>
</CFIF>
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_UOM3_'&'#i#') EQ "%">
	<CFSET "I_Calc3_#i#"=(base_value*evaluate('I_Value3_'&'#i#'))-base_value>
<CFELSE>
	<CFSET "I_Calc3_#i#"=evaluate('I_Value3_'&'#i#')>
</CFIF>
<CFIF evaluate('STRUCT_PROFIT_RULE_NAME.INDEPENDENT_AMOUNT_UOM4_'&'#i#') EQ "%">
	<CFSET "I_Calc4_#i#"=(base_value*evaluate('I_Value4_'&'#i#'))-base_value>
<CFELSE>
	<CFSET "I_Calc4_#i#"=evaluate('I_Value4_'&'#i#')>
</CFIF>

<!--- Total overhead of the independent calculations --->
<CFSET "total_independent_#i#"=evaluate('I_Calc1_'&'#i#')+evaluate('I_Calc2_'&'#i#')+evaluate('I_Calc3_'&'#i#')+evaluate('I_Calc4_'&'#i#')>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Fully loaded cost for this commodity with 100% weight											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET "Fully_loaded_#i#"=base_value+evaluate('total_compounded_'&'#i#')+evaluate('total_independent_'&'#i#')>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Fully loaded weighted cost associated with this commodity --->
<CFSET "Weighted_Cost_#i#"=evaluate('Fully_loaded_'&'#i#')*(evaluate('COMM_WEIGHT_'&'#i#')/100)>


<CFSET SubTotal_Weighted_Cost=SubTotal_Weighted_Cost+evaluate('Weighted_Cost_'&'#i#')>

</CFLOOP>

<!--- 
<CFIF struct_profit_rule_name.aa_comm_number EQ 1>
	<CFELSE>
		
</CFIF>
 --->







<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Final adjustments																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---> 
<!--- Decide if the values are to be seen as percentages or dollars --->
<!--- Compounded --->
<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_UOM1 EQ "%">
	<CFSET FC_Value1=(STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_CALC1+100)/100>
<CFELSE>
	<CFSET FC_Value1=STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_CALC1>
</CFIF>
<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_UOM2 EQ "%">
	<CFSET FC_Value2=(STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_CALC2+100)/100>
<CFELSE>
	<CFSET FC_Value2=STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_CALC2>
</CFIF>
<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_UOM3 EQ "%">
	<CFSET FC_Value3=(STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_CALC3+100)/100>
<CFELSE>
	<CFSET FC_Value3=STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_CALC3>
</CFIF>
<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_UOM4 EQ "%">
	<CFSET FC_Value4=(STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_CALC4+100)/100>
<CFELSE>
	<CFSET FC_Value4=STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_CALC4>
</CFIF>

<!--- Independent --->
<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_UOM1 EQ "%">
	<CFSET FI_Value1=(STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_CALC1+100)/100>
<CFELSE>
	<CFSET FI_Value1=STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_CALC1>
</CFIF>
<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_UOM2 EQ "%">
	<CFSET FI_Value2=(STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_CALC2+100)/100>
<CFELSE>
	<CFSET FI_Value2=STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_CALC2>
</CFIF>
<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_UOM3 EQ "%">
	<CFSET FI_Value3=(STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_CALC3+100)/100>
<CFELSE>
	<CFSET FI_Value3=STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_CALC3>
</CFIF>
<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_UOM4 EQ "%">
	<CFSET FI_Value4=(STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_CALC4+100)/100>
<CFELSE>
	<CFSET FI_Value4=STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_CALC4>
</CFIF>


<!--- The base value for the final calculations is the result of all Com/Ind calculations --->
<!--- #SubTotal_Weighted_Cost# --->

<!--- Calculate Final Compounded --->
<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_UOM1 EQ "%">
	<CFSET FC_Calc1=SubTotal_Weighted_Cost*FC_Value1>
<CFELSE>
	<CFSET FC_Calc1=SubTotal_Weighted_Cost+FC_Value1>
</CFIF>

<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_UOM2 EQ "%">
	<CFSET FC_Calc2=FC_Calc1*FC_Value2>
<CFELSE>
	<CFSET FC_Calc2=FC_Calc1+FC_Value2>
</CFIF>

<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_UOM3 EQ "%">
	<CFSET FC_Calc3=FC_Calc2*FC_Value3>
<CFELSE>
	<CFSET FC_Calc3=FC_Calc2+FC_Value3>
</CFIF>

<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_COMPOUNDED_AMOUNT_UOM4 EQ "%">
	<CFSET FC_Calc4=FC_Calc3*FC_Value4>
<CFELSE>
	<CFSET FC_Calc4=FC_Calc3+FC_Value4>
</CFIF>

<!--- Total overhead of the final compounded calculations --->
<CFSET total_final_compounded=FC_Calc4-SubTotal_Weighted_Cost>

<!--- Calculate Independent --->
<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_UOM1 EQ "%">
	<CFSET FI_Calc1=(SubTotal_Weighted_Cost*FI_Value1)-SubTotal_Weighted_Cost>
<CFELSE>
	<CFSET FI_Calc1=FI_Value1>
</CFIF>

<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_UOM2 EQ "%">
	<CFSET FI_Calc2=(SubTotal_Weighted_Cost*FI_Value2)-SubTotal_Weighted_Cost>
<CFELSE>
	<CFSET FI_Calc2=FI_Value2>
</CFIF>

<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_UOM3 EQ "%">
	<CFSET FI_Calc3=(SubTotal_Weighted_Cost*FI_Value3)-SubTotal_Weighted_Cost>
<CFELSE>
	<CFSET FI_Calc3=FI_Value3>
</CFIF>

<CFIF STRUCT_PROFIT_RULE_NAME.FINAL_INDEPENDENT_AMOUNT_UOM4 EQ "%">
	<CFSET FI_Calc4=(SubTotal_Weighted_Cost*FI_Value4)-SubTotal_Weighted_Cost>
<CFELSE>
	<CFSET FI_Calc4=FI_Value4>
</CFIF>

<!--- Total overhead of the final independent calculations --->
<CFSET total_final_independent=FI_Calc1+FI_Calc2+FI_Calc3+FI_Calc4>

<CFSET Grand_Total=SubTotal_Weighted_Cost+total_final_compounded+total_final_independent>

<!--- 
<HR>
<CFOUTPUT>#Grand_Total#</CFOUTPUT>
<HR>
 --->

<FIELDSET STYLE="padding:5px; width: 100%; border: 1px solid Silver;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Commodity Formula Cost</LEGEND>
	<BLOCKQUOTE>
		<FONT SIZE="3">The commodity formula cost is <CFOUTPUT><B><U>$#numberformat(Grand_Total, '_,___.___')#</U></B></CFOUTPUT> </FONT>
	</BLOCKQUOTE>
</FIELDSET>




<FORM ACTION="index6.cfm" METHOD="post" NAME="MyForm" ID="MyForm">

<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="aa_rulename"				VALUE="#STRUCT_PROFIT_RULE_NAME.aa_rulename#">
	<INPUT TYPE="hidden" NAME="AA_PRODUCT_LIST"			VALUE="#STRUCT_PROFIT_RULE_NAME.AA_PRODUCT_LIST#">
	<INPUT TYPE="hidden" NAME="xml_profit_rule_name"	VALUE="#xml_profit_rule_name#">
	<INPUT TYPE="hidden" NAME="Total_Calculated_Cost"	VALUE="#Grand_Total#">

	<INPUT TYPE="hidden" NAME="User_ID" 				VALUE="#request.AccessStructure.User_ID#">
</CFOUTPUT>

<CFIF FORM.PRID NEQ "">
	<CFOUTPUT><INPUT TYPE="hidden" NAME="PRID"	VALUE="#FORM.PRID#"></CFOUTPUT>
</CFIF>	

</FORM>


<!--- <CFOUTPUT>#FORM.PRID#</CFOUTPUT> --->


<CF_BUTTON
BUTTON_NAME		=	""
BUTTON_CAPTION	=	"save the data"
BUTTON_ACTION	=	"javascript:document.all.MyForm.submit();"
BUTTON_TYPE		=	"link"
BUTTON_WIDTH	=	"125"
BUTTON_COLOR	=	"Navy"
BUTTON_TIP		=	""
FONT_COLOR		=	"White"
FONT_SIZE		=	"12"
FONT_WEIGHT		=	"bold">				















