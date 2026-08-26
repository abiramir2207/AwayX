<!------Formula_Price_Commodity_Value.cfm----->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Get Rule Name
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<cfset useLakebaseForRuleBasicInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("formula_pricing_rule")>
<cfif useLakebaseForRuleBasicInfo>
	<cftry>
		<cfset Rule_Basic_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("formula_pricing_rule", { "formula_pricing_rule_id" = "eq.#THIS_PRODUCT_FORMULA_PRICING_RULE_ID#", "select" = "rule_name" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForRuleBasicInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForRuleBasicInfo>
	<CFQUERY NAME="Rule_Basic_Info" DATASOURCE="#application.datasource#">
		SELECT	Rule_Name
		FROM	Formula_Pricing_Rule
		WHERE
				Formula_Pricing_Rule_ID = '#THIS_PRODUCT_FORMULA_PRICING_RULE_ID#'
	</CFQUERY>
</cfif>
<CFOUTPUT>
<TABLE BORDER="0">
	<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>RULE NAME:</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B>#Rule_Basic_Info.Rule_Name#</B></TD>
	</TR>
</TABLE>
</CFOUTPUT>
<BR>
<STYLE>
	.NoBorder TD
	{
		border:none;
	}
	.ShowTR
	{
		display:inline;
	}
	.HideTR
	{
		display:none;
	}
</STYLE>

<SCRIPT LANGUAGE="JavaScript">
	function show_Hide_Details(trID)
	{
		event.returnValue = false;
		event.cancelBubble = true;
		var trObjs = document.getElementsByName(trID);
		var trObjLen;
		trObjLen = trObjs.length;
		if(trObjLen)
		{
			var i;			
			for(i=0;i<trObjLen;i++)
			{
				show_Hide_This(trObjs[i]);
			}
		}
		else
		{
			show_Hide_This(trObjs);
		}
	}
	function show_Hide_This(trObj)
	{
		if(trObj.className == "ShowTR")
		{
			trObj.className = "HideTR";
		}
		else
		{
			trObj.className = "ShowTR";
		}
	}
</SCRIPT>
<CFPARAM NAME="Email_Fax_Compatable" 	DEFAULT="false">
<CFIF Email_Fax_Compatable>
	<CFSET Onload_TR_Class = "ShowTR">
<CFELSE>
	<CFSET Onload_TR_Class = "HideTR">
</CFIF>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Get Overage Information for thid Program - TO be used later for each Rule ID
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFQUERY datasource="#application.datasource#" NAME="Overage_Data">
	SELECT			Program_Formula_Pricing_Rule_ID, Overage_Index, Amount, UOM, Description, Calc_Type
	FROM			Program_Formula_Pricing_Rule_Overage
	WHERE	
					Program_Formula_Pricing_Rule_ID = '#THIS_PRODUCT_FORMULA_PRICING_RULE_ID#'
			AND		Active 	= 1
			AND		Deleted = 0
	ORDER BY		Overage_Index
</CFQUERY>


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Get Commodity information for all the rules in this program
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFQUERY datasource="#application.datasource#" NAME="Commodity_Data">
	SELECT			fc.Program_Formula_Pricing_Rule_Comm_Data_ID, fc.Program_Formula_Pricing_Rule_ID, fc.Symbol, fc.Point_In_Time, fc.Point_In_Time_UOM, fc.Sample_Size, fc.Sample_Size_UOM, fc.Weight
					,cs.Symbol_Description, cex.Exchange_Detail_Name
	FROM
					Program_Formula_Pricing_Rule_Comm_Data fc,
					Commodities_Symbol cs,
					Commodities_Exchange_Detail cex
	WHERE
					Program_Formula_Pricing_Rule_ID 	= '#THIS_PRODUCT_FORMULA_PRICING_RULE_ID#'
			AND		fc.Deleted	=	0
			AND		fc.Active	=	1
			AND		cs.Symbol = fc.Symbol
			AND		cex.Exchange_Detail_ID = fc.Exchange
</CFQUERY>

<CFQUERY NAME="Get_All_Commodity_Overage" DATASOURCE="#application.datasource#">
	SELECT	*
	FROM	Formula_Pricing_Commodity_Overage
	WHERE
			Program_Formula_Pricing_Rule_ID = '#THIS_PRODUCT_FORMULA_PRICING_RULE_ID#'
</CFQUERY>


<CFSET SubTotal_Weighted_Cost = 0>
<CFSET adjusted_today = release_Date> 

<!--- find the last friday --->
<CFSET LAST_FRIDAY = #DATEADD("d", -DAYOFWEEK(adjusted_today)+6-7, adjusted_today)#>

<CFSET Grand_Total = 0>
<CFSET Proper_Commodity = 0>
<CFIF Commodity_Data.recordCount GT 0>
<TABLE CLASS="Maintable" WIDTH="98%" CELLPADDING="3" CELLSPACING="0" ALIGN="center" BORDER="0">
		<TR BGCOLOR="#FFCE84" VALIGN="bottom">
			<td>&nbsp;</td>
			<TD ID="header" NOWRAP COLSPAN="2"><B>Exchange</B></TD>
			<TD ID="header"><B>Commodity</B></TD>
			<TD ID="header" ALIGN="CENTER"><B>Lag</B></TD>
			<TD ID="header" ALIGN="CENTER"><B>Sample Size</B></TD>			
			<TD ID="header" ALIGN="CENTER"><B>Commodity Value</B></TD>
			<TD>&nbsp;</TD>
			<TD ID="header" ALIGN="CENTER"><B>Weight</B></TD>
			<TD>&nbsp;</TD>
			<TD ID="header" ALIGN="CENTER"><B>Adjusted Value</B></TD>
			<TD>&nbsp;</TD>
			<TD ID="header" NOWRAP ALIGN="CENTER" COLSPAN="2"><B>Weighted Value</B></TD>
			<TD>&nbsp;</TD>
		</TR>
	<CFSET Proper_Commodity = 1>
	<CFOUTPUT QUERY="Commodity_Data" GROUP="Program_Formula_Pricing_Rule_Comm_Data_ID">
		<CFSET comm_avg = "">
		<CFSET comm_symbol = Commodity_Data.Symbol>
	
				<!--- calculate the size/number of data points of the sample  --->
		<CFIF Commodity_Data.Sample_Size_UOM EQ "weeks">
			<CFSET C_sample_size=Commodity_data.Sample_Size*7>
			
			<!--- set the number of days/data points lag --->
			<CFSET sample_lag=Commodity_Data.Point_In_Time*7>
	
			<!--- start date = last friday minus the lag number of days --->
			<CFSET startdate=createodbcdate(last_friday-sample_lag)>
			
			<!--- the begining of the sample period is the startdate variable --->
			<!--- the end of the sample period is the startdate minus the size of the sample plus 3  --->
			<!--- so that the period really ends on the monday: first day of the last week --->			
			<CFSET enddate=createodbcdate(startdate - C_sample_size + 3)>
			
			<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
			<!------Get Commodity Value from database----->
			<!------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
			<CFIF DateDiff("d", startdate, Now()) GTE 0>
			<CFSTOREDPROC PROCEDURE="AVG_COMM_LAST" datasource="#application.datasource#">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@@C_SYMBOL"		VALUE="#comm_symbol#">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_TIMESTAMP"	DBVARNAME="@@C_MIN_Date"	VALUE="#enddate#">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_TIMESTAMP"	DBVARNAME="@@C_MAX_Date"	VALUE="#startdate#">
				<CFPROCPARAM TYPE="Out" CFSQLTYPE="CF_SQL_FLOAT"	DBVARNAME="@@COMM_AVG"		VARIABLE="comm_avg">
			</CFSTOREDPROC>
			</CFIF>
			<!------<CFSET showStr="#comm_symbol# #startdate# #enddate#">----->
		<CFELSE>
			<CFSET sample_lag=Commodity_Data.Point_In_Time>
			<CFSET C_sample_size=Commodity_data.Sample_Size>
			
			<CFSET startdate=adjusted_today>
			<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
			<!------Get Commodity Value from database----->
			<!------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
			<CFIF DateDiff("d", startdate, Now()) GTE 0>
			<CFSTOREDPROC PROCEDURE="AVG_TRADE_COMM_LAST" datasource="#application.datasource#">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@@C_SYMBOL"		VALUE="#comm_symbol#">			
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_TIMESTAMP"	DBVARNAME="@@C_MAX_Date"	VALUE="#startdate#">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@@C_MIN"			VALUE="#sample_lag#">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@@SAMPLE"		VALUE="#C_sample_size#">
				<CFPROCPARAM TYPE="Out" CFSQLTYPE="CF_SQL_FLOAT"	DBVARNAME="@@COMM_AVG"		VARIABLE="comm_avg">
			</CFSTOREDPROC>
			</CFIF>
			<!------<CFSET showStr="#comm_symbol# #startdate# #sample_lag# #C_sample_size#">----->
		</CFIF>

		<CFIF NOT IsNumeric(comm_avg)>
			<CFSET Fully_loaded=0>
			<CFSET Proper_Commodity = 0>
		<CFELSE>
			<CFSET Fully_loaded=comm_avg>			
		</CFIF>
		
		<CFSET Any_Overage = false>
		<CFSET Formated_Program_Formula_Pricing_Rule_Comm_Data_ID = "TR_#ReplaceNoCase(Program_Formula_Pricing_Rule_Comm_Data_ID, "-", "_", "all")#">
		<CFSAVECONTENT VARIABLE="Commodity_Overage_Details">
			<!------ Commodity level Compunded Calculations Overage calculations----->
			<CFQUERY NAME="This_Overage_Data" DBTYPE="Query">
				SELECT			Overage_Index, Amount, UOM, Description
				FROM			Get_All_Commodity_Overage
				WHERE	
								Program_Formula_Pricing_Rule_Comm_Data_ID = '#Program_Formula_Pricing_Rule_Comm_Data_ID#'
								AND
								Calc_Type = 2
				ORDER BY		Overage_Index
			</CFQUERY>
			<CFSET comm_avg_with_overge = Fully_loaded>
			<CFIF This_Overage_Data.RecordCount GT 0>
			<CFSET Any_Overage = true>
			<TR ID="#Formated_Program_Formula_Pricing_Rule_Comm_Data_ID#" CLASS="#Onload_TR_Class#">
				<TD COLSPAN="2"></TD>
				<TD COLSPAN="8" STYLE="border-bottom:1px solid orange;font-size:11px;"><B>Compounded Calculations</B></TD>				
				<TD ALIGN="right" STYLE="border-bottom:1px solid orange;font-size:11px;" STYLE="color:blue;cursor:hand;" onClick="javaScript: return show_Hide_Details('#Formated_Program_Formula_Pricing_Rule_Comm_Data_ID#');">
				<CFIF Email_Fax_Compatable>
				<B>x</B>
				<CFELSE>
				<A HREF="void(0);" onClick="javaScript: return show_Hide_Details('#Formated_Program_Formula_Pricing_Rule_Comm_Data_ID#');"><IMG SRC="/Images/minus.gif" width="10" heigth="10" ALT="minimise details" BORDER="0"></A>
				</CFIF>
				</TD>
			</TR>
			<TR ID="#Formated_Program_Formula_Pricing_Rule_Comm_Data_ID#" CLASS="#Onload_TR_Class#">
				<TD COLSPAN="2">&nbsp;</TD>
				<TD COLSPAN="9">
					<CFSET Compounded_Calc_Against = Fully_loaded>
					<CFSET Compounded_Calc_Add_To = Fully_loaded>
					<CFSET Independent_Compounded_Calc_Type = 2>
					<CFSET QRY_Overage_Data = This_Overage_Data>
					<CFINCLUDE TEMPLATE="Formula_Componded_Independent_Dispay.cfm">
					<CFSET comm_avg_with_overge = Compounded_Calc_Result>
				</TD>
			</TR>
			</CFIF>
			<!------ Commodity level Independent Calculations Overage calculations----->
			<CFQUERY NAME="This_Overage_Data" DBTYPE="Query">
				SELECT			Overage_Index, Amount, UOM, Description
				FROM			Get_All_Commodity_Overage
				WHERE	
								Program_Formula_Pricing_Rule_Comm_Data_ID = '#Program_Formula_Pricing_Rule_Comm_Data_ID#'
								AND
								Calc_Type = 1
				ORDER BY		Overage_Index
			</CFQUERY>
			<CFIF This_Overage_Data.RecordCount GT 0>
			<CFSET Any_Overage = true>
			<TR ID="#Formated_Program_Formula_Pricing_Rule_Comm_Data_ID#" CLASS="#Onload_TR_Class#">
				<TD COLSPAN="2"></TD>
				<TD COLSPAN="9" STYLE="border-bottom:1px solid orange;font-size:11px;"><B>Independent Calculations</B></TD>
			</TR>
			<TR ID="#Formated_Program_Formula_Pricing_Rule_Comm_Data_ID#" CLASS="#Onload_TR_Class#">
				<TD COLSPAN="2">&nbsp;</TD>
				<TD COLSPAN="9">
					<CFSET Compounded_Calc_Against = Fully_loaded>
					<CFSET Compounded_Calc_Add_To = comm_avg_with_overge>
					<CFSET Independent_Compounded_Calc_Type = 1>
					<CFSET QRY_Overage_Data = This_Overage_Data>
					<CFINCLUDE TEMPLATE="Formula_Componded_Independent_Dispay.cfm">
					<CFSET comm_avg_with_overge = Compounded_Calc_Result>
				</TD>
			</TR>
			</CFIF>
		</CFSAVECONTENT>
		
		<CFSET Weighted_Cost="">
		<CFIF IsNumeric(comm_avg)>
			<CFSET Weighted_Cost=comm_avg_with_overge*(Commodity_Data.Weight/100)>
			<CFSET SubTotal_Weighted_Cost=SubTotal_Weighted_Cost + Weighted_Cost>
		</CFIF>
			
		
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('EEEEEE'), DE('C6FFC6'))#" VALIGN="top">
			<td>&nbsp;</td>
			<TD NOWRAP COLSPAN="2"><B>#Exchange_Detail_Name#</B></TD>
			<TD><B>#Symbol_Description#</B></TD>
			<TD ALIGN="CENTER"><B>#Point_In_Time# #Point_In_Time_UOM#</B></TD>
			<TD ALIGN="CENTER"><B>#Sample_Size# #Sample_Size_UOM#</B></TD>			
			<CFSET AName_Program_Formula_Pricing_Rule_Comm_Data_ID = ReplaceNoCase(Program_Formula_Pricing_Rule_Comm_Data_ID, "-", "_", "all")>
			<TD ALIGN="CENTER" STYLE="color:blue;cursor:hand;">
			<CFIF Email_Fax_Compatable>
			<D_A HREF="###AName_Program_Formula_Pricing_Rule_Comm_Data_ID#">
			<CFELSE>
			<A HREF="Formula_Price_Commodity_Value_Details.cfm?Program_Formula_Pricing_Rule_Comm_Data_ID=#Program_Formula_Pricing_Rule_Comm_Data_ID#&Program_ID=#Program_ID#" OnClick="NewWindow(this.href,'comm_value_details','500','400','Yes', 'Yes');return false;">
			</CFIF>
			<B><cfif IsNumeric(comm_avg)>#numberformat(comm_avg, '_,___.____')#<cfelse>#NO_DATA_STR#</cfif>
			</B>
			<CFIF Email_Fax_Compatable>
			</D_A>
			<CFELSE>
			</A>
			</CFIF>
			<!------<br>(#showStr#)-----></TD>
			<TD ALIGN="CENTER">&nbsp;</TD>			
			<TD ALIGN="CENTER"><B>#Weight#%</B></TD>
			<TD><B>*</B></TD>			
			<TD ALIGN="right"<CFIF Any_Overage> STYLE="color:blue;cursor:hand;" onClick="javaScript: return show_Hide_Details('#Formated_Program_Formula_Pricing_Rule_Comm_Data_ID#');"</CFIF>><B>$#numberformat(comm_avg_with_overge, '_,___.____')#</B></TD>
			<TD><B>=</B></TD>
			<TD NOWRAP ALIGN="RIGHT"><B><cfif IsNumeric(Weighted_Cost)>$#numberformat(Weighted_Cost, '_,___.____')#<CFELSE>#NO_DATA_STR#</CFIF></B></TD>
			<TD>&nbsp;</TD>
			<TD ALIGN="CENTER"><B>+</B></TD>
		</TR>
		#Commodity_Overage_Details#
	</CFOUTPUT>
<CFOUTPUT>	
	<TR>
		<TD STYLE="border-bottom: 2px solid navy;">&nbsp;</TD>
		<TD COLSPAN="10" ALIGN="RIGHT" STYLE="border-bottom: 2px solid navy; font-size: 12px; color: NAVY;"><B>&##931; Weighted Value</B></TD>
		<TD STYLE="border-bottom: 2px solid navy; font-size: 12px; color: NAVY;">&nbsp;</TD>
		<TD ALIGN="RIGHT" STYLE="border-bottom: 2px solid navy; font-size: 12px; color: blue;"><B>
		<CFIF Proper_Commodity EQ 1>$#numberformat(SubTotal_Weighted_Cost, '_,___.____')#<CFELSE>#NO_DATA_STR#</CFIF></B></TD>
		<TD STYLE="border-bottom: 2px solid navy; font-size: 12px; color: blue;" COLSPAN="2">&nbsp;</TD>
	</TR>
	
	<CFSET Rule_ID=Commodity_Data.Program_Formula_Pricing_Rule_ID>

	
	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx----->
	<!------Overage calculations (Compounded Calculations) ----->
	<!------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx----->
	<CFQUERY NAME="This_Overage_Data" DBTYPE="Query">
		SELECT			Overage_Index, Amount, UOM, Description
		FROM			Overage_Data
		WHERE	
						Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
						AND
						Calc_Type = 2
		ORDER BY		Overage_Index
	</CFQUERY>

	<CFSET SubTotal_Weighted_Cost_Compounded = SubTotal_Weighted_Cost>
	<CFSET total_Overage_Compounded = 0>	
	<CFIF This_Overage_Data.RecordCount GT 0>
	<TR>
		<TD COLSPAN="2"></TD>
		<TD COLSPAN="100%" STYLE="border-bottom:1px solid orange;font-size:11px;"><B>Compounded Calculations</B></TD>
	</TD>

	<TR>
	<TD COLSPAN="2"></TD>
	<TD COLSPAN="9">
		<CFSET Compounded_Calc_Against = SubTotal_Weighted_Cost>
		<CFSET Compounded_Calc_Add_To = SubTotal_Weighted_Cost_Compounded>
		<CFSET Independent_Compounded_Calc_Type = 2>
		<CFSET QRY_Overage_Data = This_Overage_Data>
		<CFINCLUDE TEMPLATE="Formula_Componded_Independent_Dispay.cfm">
		<CFSET SubTotal_Weighted_Cost_Compounded = Compounded_Calc_Result>
	</TD>
	<TD VALIGN="bottom" ALIGN="center">=</TD>
	<TD VALIGN="bottom" ALIGN="RIGHT">$#numberformat(SubTotal_Weighted_Cost_Compounded, '_,___.____')#</TD>
	<TD>&nbsp;</TD>
	<!------<TD VALIGN="bottom" ALIGN="CENTER">+</TD>----->
	</TR>
	</CFIF>
	
	
	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx----->
	<!------Independent Calculations Overage calculations----->
	<!------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx----->
	<CFQUERY NAME="This_Overage_Data" DBTYPE="Query">
		SELECT			Overage_Index, Amount, UOM, Description
		FROM			Overage_Data
		WHERE	
						Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
						AND
						Calc_Type = 1
		ORDER BY		Overage_Index
	</CFQUERY>

	<CFSET total_Overage = 0>
	<CFIF This_Overage_Data.RecordCount GT 0>
	<TR>
		<TD COLSPAN="2"></TD>
		<TD COLSPAN="100%" STYLE="border-bottom:1px solid orange;font-size:11px;"><B>Independent Calculations</B></TD>
	</TR>
	<TR>
	<TD COLSPAN="2"></TD>
	<TD COLSPAN="9">
		<CFSET Compounded_Calc_Against = SubTotal_Weighted_Cost>
		<CFSET Compounded_Calc_Add_To = SubTotal_Weighted_Cost_Compounded>
		<CFSET Independent_Compounded_Calc_Type = 1>
		<CFSET QRY_Overage_Data = This_Overage_Data>
		<CFINCLUDE TEMPLATE="Formula_Componded_Independent_Dispay.cfm">
		<CFSET SubTotal_Weighted_Cost_Compounded = Compounded_Calc_Result>
	</TD>
	<TD VALIGN="bottom" ALIGN="center">=</TD>
	<TD VALIGN="bottom" ALIGN="RIGHT">$#numberformat(SubTotal_Weighted_Cost_Compounded, '_,___.____')#</TD>
	<TD>&nbsp;</TD>
	<!------<TD VALIGN="bottom" ALIGN="CENTER">+</TD>----->
	</TR>	
	</CFIF>
	<CFSET Grand_Total = SubTotal_Weighted_Cost_Compounded>

	<TR>
		<TD COLSPAN="2">&nbsp;</TD>
		<TD COLSPAN="9"  STYLE="font-size : 12px; color: NAVY;"><B>Commodity Total</B></TD>
		<TD ALIGN="center" COLSPAN="1"  STYLE="font-size : 12px; color: NAVY;"><B>=</B></TD>
		<TD ALIGN="RIGHT" STYLE="font-size : 12px; color: BLUE;"><B>
		<CFIF Proper_Commodity EQ 1>$#numberformat(Grand_Total, '_,___.____')#<CFELSE>#NO_DATA_STR#</CFIF>
		</B></TD>
		<TD COLSPAN="2" STYLE="font-size : 10px; color: NAVY;">&nbsp;</TD>
	</TR>
</CFOUTPUT>
</CFIF>
