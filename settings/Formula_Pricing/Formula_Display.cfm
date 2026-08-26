<!------Formula_Display.cfm----->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<CFPARAM NAME="URL.Formula_ID" 	DEFAULT="">

<CFPARAM NAME="EDIT_RULE" 	DEFAULT=false>
<CFPARAM NAME="SHOW_ACTIVATE_BUTTON" 	DEFAULT=false>
<CFPARAM NAME="SHOW_RULE_TITLE" 	DEFAULT=true>

<CFSET URL.Formula_ID = Trim(URL.Formula_ID)>

<CFIF Len(URL.Formula_ID) LTE 0>
	<CFABORT>
</CFIF>

<cfset useLakebaseForFormula_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("formula_pricing_rule")>
<cfif useLakebaseForFormula_Details>
	<cftry>
		<cfset Formula_Details = application.oLakebase.toQuery(
			application.oLakebase.selectRows("formula_pricing_rule", {
				"formula_pricing_rule_id" = "eq.#URL.Formula_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForFormula_Details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForFormula_Details>
<CFQUERY NAME="Formula_Details" DATASOURCE="#application.datasource#">
	SELECT	*
	FROM	Formula_Pricing_Rule
	WHERE
			Formula_Pricing_Rule.Formula_Pricing_Rule_ID = '#URL.Formula_ID#'
			AND
			Formula_Pricing_Rule.Deleted = 0
</CFQUERY>
</cfif>

<CFIF Formula_Details.Active_Code EQ 0>
	<CFSET EDIT_RULE = false>
</CFIF>


<CFQUERY NAME="Formula_Details_Commodities" DATASOURCE="#application.datasource#">
	SELECT	*
	FROM	Program_Formula_Pricing_Rule_Comm_Data
			INNER JOIN Commodities_Symbol 
			ON 
			Program_Formula_Pricing_Rule_Comm_Data.Symbol = Commodities_Symbol.Symbol 
			INNER JOIN Commodities_Exchange_Detail 
			ON 
			Program_Formula_Pricing_Rule_Comm_Data.Exchange = Commodities_Exchange_Detail.Exchange_Detail_ID
	WHERE
			Program_Formula_Pricing_Rule_Comm_Data.Program_Formula_Pricing_Rule_ID = '#URL.Formula_ID#'
			AND
			Program_Formula_Pricing_Rule_Comm_Data.Deleted = 0
</CFQUERY>

<CFQUERY NAME="Formula_Details_Overage" DATASOURCE="#application.datasource#">
	SELECT	*
	FROM	Program_Formula_Pricing_Rule_Overage
	WHERE
			Program_Formula_Pricing_Rule_Overage.Program_Formula_Pricing_Rule_ID = '#URL.Formula_ID#'
			AND
			Program_Formula_Pricing_Rule_Overage.Deleted = 0
	ORDER BY Calc_Type DESC, Overage_Index
</CFQUERY>

<cfset useLakebaseForGet_All_Commodity_Overage = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("formula_pricing_commodity_overage")>
<cfif useLakebaseForGet_All_Commodity_Overage>
	<cftry>
		<cfset Get_All_Commodity_Overage = application.oLakebase.toQuery(
			application.oLakebase.selectRows("formula_pricing_commodity_overage", {
				"program_formula_pricing_rule_id" = "eq.#URL.Formula_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_All_Commodity_Overage = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_All_Commodity_Overage>
<CFQUERY NAME="Get_All_Commodity_Overage" DATASOURCE="#application.datasource#">
	SELECT	*
	FROM	Formula_Pricing_Commodity_Overage
	WHERE
			Program_Formula_Pricing_Rule_ID = '#URL.Formula_ID#'
</CFQUERY>
</cfif>

<html>
<head>
	<title>Formula - <CFOUTPUT>#Formula_Details.Rule_Name#</CFOUTPUT></title>
</head>
<body>
<CFOUTPUT>
<CFIF SHOW_RULE_TITLE>	
	<SPAN CLASS="Title2">
	Rule: #Formula_Details.Rule_Name#
	</SPAN>
	<CFIF EDIT_RULE>
	&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="Formula_Price_Step1.cfm?RID=#Formula_Details.Formula_Pricing_Rule_ID#">edit rule name</a><FONT COLOR="FF0000">]</FONT></B>
	</CFIF>
	<CFIF SHOW_ACTIVATE_BUTTON AND Formula_Details.Active_Code EQ 0>
	&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a href="Formula_Price_Activate.cfm?RID=#Formula_Details.Formula_Pricing_Rule_ID#&active=false" onClick="javascript:return confirm('Do you want to activate the rule \'' + '#ReplaceNOCase(Formula_Details.RULE_NAME,"'","\'","All")#' + '\'?');">activate rule</a><FONT COLOR="FF0000">]</FONT></B>
	</CFIF>
	<HR COLOR="Orange">
<CFELSE>
	<BR>
</CFIF>
<SPAN CLASS="Title2">Number of commodities: #Formula_Details.Number_Of_Comms#
</SPAN>
</CFOUTPUT>
<BR><BR>

<!------------------ Display Start ------------------------->
<!------
<CFOUTPUT>
<SPAN CLASS="Title2">Commodities:</SPAN>
<CFIF EDIT_RULE>
&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="Formula_Price_Step1.cfm?RID=#Formula_Details.Formula_Pricing_Rule_ID#">edit commodities</a><FONT COLOR="FF0000">]</FONT></B>
&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="Formula_Price_Step2.cfm?RID=#Formula_Details.Formula_Pricing_Rule_ID#">edit commodity values</a><FONT COLOR="FF0000">]</FONT></B>
</CFIF>
<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0">
	<TR BGCOLOR="FFCE84" VALIGN="bottom">
		<TD ID="header"><B>Exchange</B></TD>		
		<TD ID="header"><B>Commodity</B></TD>
		<CFIF Formula_Details_Commodities.recordcount GT 1>
			<TD ID="header"><B>Weight</B></TD>
		</CFIF>
		<TD ID="header"><B>Sample Size</B></TD>
		<TD ID="header"><B>Lag</B></TD>
	</TR>
	</CFOUTPUT>
	<CFLOOP QUERY="Formula_Details_Commodities">
		<CFOUTPUT>
		<TR BGCOLOR="C6FFC6">
			<TD>#Exchange_Detail_Name#</TD>			
			<TD>#Symbol_Description#</TD>
			<CFIF Formula_Details_Commodities.recordcount GT 1>
				<TD>#Weight#%</TD>
			</CFIF>
			<TD>#Sample_Size#&nbsp;#Sample_Size_UOM#</TD>
			<TD>#Point_In_Time#&nbsp;#Sample_Size_UOM#</TD>
		</TR>
	</CFOUTPUT>
		<CFQUERY NAME="Commodities_Overage" DBTYPE="query">
			SELECT	*
			FROM	Get_All_Commodity_Overage
			WHERE
					Get_All_Commodity_Overage.Program_Formula_Pricing_Rule_Comm_Data_ID = '#Program_Formula_Pricing_Rule_Comm_Data_ID#'
			ORDER BY Calc_Type, Overage_Index
		</CFQUERY>
		<CFIF Commodities_Overage.RecordCount GT 0>
		<TR>
			<TD>&nbsp;</TD>
			<TD COLSPAN="100%">
				<TABLE CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
				<TR VALIGN="top">
				<CFOUTPUT GROUP="Calc_Type" QUERY="Commodities_Overage">
				<TD STYLE="border:none;">&nbsp;</TD>
				<TD WIDTH="50%" STYLE="border:none;">
				<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="2" CELLSPACING="0">
					<TR BGCOLOR="FFCE84" VALIGN="bottom">		
						<TD ID="header" COLSPAN="2"><b>
						<CFIF Calc_Type EQ 1>
						Independent 
						<CFELSE>
						Compounded 
						</CFIF>		
						Calculations</b></TD>
					</TR>								
					<CFOUTPUT>
						<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ffffff'))#">
						<TD>#Description#</TD>
						<CFIF UOM EQ "%">				
							<TD>#trim(numberformat(trim(Amount), '_________________.___)'))##UOM#</TD>
						<CFELSE>				
							<TD>#UOM##trim(numberformat(trim(Amount), '___,___,___,___,___,___.__)'))#</TD>
						</CFIF>
						</TR>
					</CFOUTPUT>
				</TABLE>
				</TD>
				</CFOUTPUT>
				</TR>			
				</TABLE>				
			</TD>
		</TR>
		</CFIF>
	</CFLOOP>
	<CFOUTPUT>
</TABLE>
<BR>

<SPAN CLASS="Title2">Overage:</SPAN>
<CFIF EDIT_RULE>
&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="Formula_Price_Step2.cfm?RID=#Formula_Details.Formula_Pricing_Rule_ID#">edit overage</a><FONT COLOR="FF0000">]</FONT></B>
</CFIF>
</CFOUTPUT>

<CFIF Formula_Details_Overage.RecordCount GT 0>
<TABLE CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
<TR VALIGN="top">
<CFOUTPUT GROUP="Calc_Type" QUERY="Formula_Details_Overage">
<TD WIDTH="50%">
<TABLE CLASS="Maintable" WIDTH="98%" CELLPADDING="3" CELLSPACING="0">
	<TR BGCOLOR="FFCE84" VALIGN="bottom">		
		<TD ID="header" COLSPAN="2"><b>
		<CFIF Calc_Type EQ 1>
		Independent 
		<CFELSE>
		Compounded 
		</CFIF>		
		Calculations</b></TD>
	</TR>								
	<CFOUTPUT>
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ffffff'))#">
		<TD>#Description#</TD>
		<CFIF UOM EQ "%">				
			<TD>#trim(numberformat(trim(Amount), '_________________.___)'))##UOM#</TD>
		<CFELSE>				
			<TD>#UOM##trim(numberformat(trim(Amount), '___,___,___,___,___,___.__)'))#</TD>
		</CFIF>
		</TR>
	</CFOUTPUT>
</TABLE>
</TD>
</CFOUTPUT>
</TR>
</TABLE>
<CFELSE>
<BR><BR>
<FONT SIZE="1" COLOR="Red">
<B>None Found</B>
</FONT>
</CFIF>----->

<!------------------ Display End ------------------------->


<CFLOOP QUERY="Formula_Details_Commodities">
	<CFOUTPUT>
	<BR>
	<SPAN CLASS="Title2">#Exchange_Detail_Name# : #Symbol_Description#</SPAN>
	<BR>
	<CFIF EDIT_RULE>
	<B><FONT COLOR="FF0000">[</FONT><a HREF="Formula_Price_Step1.cfm?RID=#Formula_Details.Formula_Pricing_Rule_ID#">edit commodities</a><FONT COLOR="FF0000">]</FONT></B>
	&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="Formula_Price_Step2.cfm?RID=#Formula_Details.Formula_Pricing_Rule_ID#">edit commodity values</a><FONT COLOR="FF0000">]</FONT></B>
	</CFIF>
	<HR COLOR="Navy">
	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="100%">
		<TR>
			<TD WIDTH="30%" STYLE="font-size:12px;font-weight:bold;">Sample Size: #Sample_Size#&nbsp;#Sample_Size_UOM#</TD>
			<TD WIDTH="30%" STYLE="font-size:12px;font-weight:bold;">Lag: #Point_In_Time#&nbsp;#Sample_Size_UOM#</TD>
			<CFIF Formula_Details_Commodities.recordcount GT 1>
			<TD WIDTH="30%" STYLE="font-size:12px;font-weight:bold;">Weight: #Weight#%</TD>
			</CFIF>			
		</TR>
	</CFOUTPUT>
		<cfset useLakebaseForCommodities_Overage_1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all_commodity_overage")>
<cfif useLakebaseForCommodities_Overage_1>
	<cftry>
		<cfset Commodities_Overage_1 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all_commodity_overage", {
				"program_formula_pricing_rule_comm_data_id" = "eq.#Program_Formula_Pricing_Rule_Comm_Data_ID#",
				"calc_type" = "eq.1",
				"order" = "overage_index.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCommodities_Overage_1 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCommodities_Overage_1>
<CFQUERY NAME="Commodities_Overage_1" DBTYPE="query">
			SELECT	*
			FROM	Get_All_Commodity_Overage
			WHERE
					Get_All_Commodity_Overage.Program_Formula_Pricing_Rule_Comm_Data_ID = '#Program_Formula_Pricing_Rule_Comm_Data_ID#'
					AND
					Calc_Type = 1
			ORDER BY Overage_Index
		</CFQUERY>
</cfif>
		<cfset useLakebaseForCommodities_Overage_2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all_commodity_overage")>
<cfif useLakebaseForCommodities_Overage_2>
	<cftry>
		<cfset Commodities_Overage_2 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all_commodity_overage", {
				"program_formula_pricing_rule_comm_data_id" = "eq.#Program_Formula_Pricing_Rule_Comm_Data_ID#",
				"calc_type" = "eq.2",
				"order" = "overage_index.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCommodities_Overage_2 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCommodities_Overage_2>
<CFQUERY NAME="Commodities_Overage_2" DBTYPE="query">
			SELECT	*
			FROM	Get_All_Commodity_Overage
			WHERE
					Get_All_Commodity_Overage.Program_Formula_Pricing_Rule_Comm_Data_ID = '#Program_Formula_Pricing_Rule_Comm_Data_ID#'
					AND
					Calc_Type = 2
			ORDER BY Overage_Index
		</CFQUERY>
</cfif>
		
		<CFIF Commodities_Overage_1.RecordCount GT 0 OR Commodities_Overage_2.RecordCount GT 0>
		<TR>
			<TD COLSPAN="100%">
				<TABLE CELLPADDING="0" CELLSPACING="2" WIDTH="100%" BORDER="0">
					<TR BGCOLOR="FFCE84" VALIGN="bottom">		
						<TD ID="header"><b>Compounded Calculations</b></TD>
						<TD ID="header" COLSPAN="2"><b>Independent Calculations</b></TD>
					</TR>
					<TR VALIGN="top">
						<TD WIDTH="50%">
						<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="2" CELLSPACING="0">
							<CFLOOP QUERY="Commodities_Overage_2">
							<CFOUTPUT>
								<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ffffff'))#">
								<TD>#Description#</TD>
								<CFIF UOM EQ "%">				
									<TD>#trim(numberformat(trim(Amount), '_________________.___)'))##UOM#</TD>
								<CFELSE>				
									<TD>#UOM##trim(numberformat(trim(Amount), '___,___,___,___,___,___.__)'))#</TD>
								</CFIF>
								</TR>
							</CFOUTPUT>
							</CFLOOP>
						</TABLE>
						</TD>
						<TD WIDTH="50%">
						<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="2" CELLSPACING="0">
							<CFLOOP QUERY="Commodities_Overage_1">
							<CFOUTPUT>
								<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ffffff'))#">
								<TD>#Description#</TD>
								<CFIF UOM EQ "%">				
									<TD>#trim(numberformat(trim(Amount), '_________________.___)'))##UOM#</TD>
								<CFELSE>				
									<TD>#UOM##trim(numberformat(trim(Amount), '___,___,___,___,___,___.__)'))#</TD>
								</CFIF>
								</TR>
							</CFOUTPUT>
							</CFLOOP>
						</TABLE>
						</TD>
					</TR>
				</TABLE>			
			</TD>
		</TR>
		</CFIF>
	</TABLE>	
</CFLOOP>
<SPAN CLASS="Title2">Overage:</SPAN>
	<CFIF EDIT_RULE>
	<CFOUTPUT>
	&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="Formula_Price_Step2.cfm?RID=#Formula_Details.Formula_Pricing_Rule_ID#">edit overage</a><FONT COLOR="FF0000">]</FONT></B>
	</CFOUTPUT>
	</CFIF>
	<HR COLOR="Orange">
	<cfset useLakebaseForFormula_Details_Overage_1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("formula_details_overage")>
<cfif useLakebaseForFormula_Details_Overage_1>
	<cftry>
		<cfset Formula_Details_Overage_1 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("formula_details_overage", {
				"calc_type" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForFormula_Details_Overage_1 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForFormula_Details_Overage_1>
<CFQUERY NAME="Formula_Details_Overage_1" DBTYPE="query">
		SELECT	*
		FROM	Formula_Details_Overage
		WHERE
				Calc_Type = 1
	</CFQUERY>
</cfif>
	<cfset useLakebaseForFormula_Details_Overage_2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("formula_details_overage")>
<cfif useLakebaseForFormula_Details_Overage_2>
	<cftry>
		<cfset Formula_Details_Overage_2 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("formula_details_overage", {
				"calc_type" = "eq.2"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForFormula_Details_Overage_2 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForFormula_Details_Overage_2>
<CFQUERY NAME="Formula_Details_Overage_2" DBTYPE="query">
		SELECT	*
		FROM	Formula_Details_Overage
		WHERE
				Calc_Type = 2
	</CFQUERY>
</cfif>
	<CFIF Formula_Details_Overage.RecordCount GT 0>
		<TABLE CELLPADDING="0" CELLSPACING="2" WIDTH="100%" BORDER="0">
			<TR BGCOLOR="FFCE84" VALIGN="bottom">		
				<TD ID="header"><b>Compounded Calculations</b></TD>
				<TD ID="header" COLSPAN="2"><b>Independent Calculations</b></TD>
			</TR>
			<TR VALIGN="top">
				<TD WIDTH="50%">
				<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="2" CELLSPACING="0">
					<CFLOOP QUERY="Formula_Details_Overage_2">
					<CFOUTPUT>
						<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ffffff'))#">
						<TD>#Description#</TD>
						<CFIF UOM EQ "%">				
							<TD>#trim(numberformat(trim(Amount), '_________________.___)'))##UOM#</TD>
						<CFELSE>				
							<TD>#UOM##trim(numberformat(trim(Amount), '___,___,___,___,___,___.__)'))#</TD>
						</CFIF>
						</TR>
					</CFOUTPUT>
					</CFLOOP>
				</TABLE>
				</TD>
				<TD WIDTH="50%">
				<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="2" CELLSPACING="0">
					<CFLOOP QUERY="Formula_Details_Overage_1">
					<CFOUTPUT>
						<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ffffff'))#">
						<TD>#Description#</TD>
						<CFIF UOM EQ "%">				
							<TD>#trim(numberformat(trim(Amount), '_________________.___)'))##UOM#</TD>
						<CFELSE>				
							<TD>#UOM##trim(numberformat(trim(Amount), '___,___,___,___,___,___.__)'))#</TD>
						</CFIF>
						</TR>
					</CFOUTPUT>
					</CFLOOP>
				</TABLE>
				</TD>
			</TR>
		</TABLE>
	</CFIF>
	<!------<CFIF Formula_Details_Overage.RecordCount GT 0>
		<TABLE CELLPADDING="0" CELLSPACING="2" WIDTH="100%" BORDER="0">
		<TR BGCOLOR="FFCE84" VALIGN="bottom">		
			<TD ID="header"><b>
			Compounded 
			Calculations</b></TD>
			<TD ID="header" COLSPAN="2"><b>
			Independent 
			Calculations</b></TD>
		</TR>
		<TR VALIGN="top">
		<CFSET Calc_Type_1 = false>
		<CFOUTPUT GROUP="Calc_Type" QUERY="Formula_Details_Overage">		
		<CFIF Calc_Type EQ 1>
			<CFSET Calc_Type_1 = true>
		<CFELSEIF  Calc_Type EQ 2>
			<CFIF NOT Calc_Type_1>
				<TD WIDTH="50%"></TD>
			</CFIF>
		</CFIF>
		<TD WIDTH="50%">
		<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="2" CELLSPACING="0">						
			<CFOUTPUT>
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ffffff'))#">
				<TD>#Description#</TD>
				<CFIF UOM EQ "%">				
					<TD>#trim(numberformat(trim(Amount), '_________________.___)'))##UOM#</TD>
				<CFELSE>				
					<TD>#UOM##trim(numberformat(trim(Amount), '___,___,___,___,___,___.__)'))#</TD>
				</CFIF>
				</TR>
			</CFOUTPUT>
		</TABLE>
		</TD>
		</CFOUTPUT>
		</TR>
		</TABLE>
		<CFELSE>
		<BR><BR>
		<FONT SIZE="1" COLOR="Red">
		<B>None Found</B>
		</FONT>
		</CFIF>----->
</body>
</html>
