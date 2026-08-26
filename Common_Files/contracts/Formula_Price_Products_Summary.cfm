<!------ Formula_Price_Products_Summary.cfm ----->
<CFPARAM NAME="URL.Program_ID" 	DEFAULT="">
<CFPARAM NAME="Program_ID" 	DEFAULT="#URL.Program_ID#">
<CFSET SHOW_FORMULA_PRICING_DETAIL_INFO = 0>

<CFSET NO_DATA_STR = "<font color=""red"">No Data</font>">

<cfquery name="COMM_GetSettings" datasource="#application.datasource#">
	SELECT 	Discount_Formula_Pricing		
	FROM	Contract_Main			
			INNER JOIN Program_Control_Panel_Options
			ON
			Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	WHERE 
		Contract_Main.Contract_Main_ID = '#Program_ID#'
</cfquery>

<cfset useLakebaseForGet_Program_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGet_Program_Info>
	<cftry>
		<cfset Get_Program_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Program_ID#",
				"select" = "contract_number,contract_title"
			}), "contract_number,contract_title"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Program_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Program_Info>
<CFQUERY NAME="Get_Program_Info" DATASOURCE="#application.datasource#">
	SELECT	Contract_Number, Contract_Title
	FROM	Contract_Main
	WHERE
			Contract_Main.Contract_Main_ID = #Program_ID#
</CFQUERY>
</cfif>
<CFIF COMM_GetSettings.Discount_Formula_Pricing EQ 1>
	
	<CFQUERY NAME="getRules" datasource="#application.datasource#">
		SELECT     	dbo.Contract_Products.Contract_Main_ID, 
					Formula_Pricing_Rule.Rule_Name, dbo.BSA_Foodservice_Items_Master.Item, dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
		           	dbo.BSA_Foodservice_Items_Master.UPC, dbo.BSA_Foodservice_Items_Master.Description, 
		           	Formula_Pricing_Rule.Formula_Pricing_Rule_ID, 
				   	Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID,
				   	dbo.Program_Formula_Pricing_Rule_Products.Weekly_Volume,dbo.Program_Formula_Pricing_Rule_Products.Price,dbo.Program_Formula_Pricing_Rule_Products.Weekly_Volume,
					Program_Formula_Pricing_Rule_Products.Unit_Of_Measure_ID, Program_Formula_Pricing_Rule_Products.Product_Overage,
					Formula_Pricing_Rule.Show_Details
		FROM        dbo.BSA_Foodservice_Items_Master 
					INNER JOIN	dbo.Contract_Products 
					ON dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = dbo.Contract_Products.BSA_Foodservice_Items_Master_ID 
					INNER JOIN dbo.Program_Formula_Pricing_Rule_Products 
					ON dbo.Contract_Products.Contract_Products_ID = dbo.Program_Formula_Pricing_Rule_Products.Contract_Product_ID
					INNER JOIN Program_Formula_Pricing_Rule_Mapped
					ON
					Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID = dbo.Program_Formula_Pricing_Rule_Products.Program_Formula_Pricing_Rule_ID
					AND
					Program_Formula_Pricing_Rule_Mapped.Deleted = 0
					LEFT JOIN Formula_Pricing_Rule
					ON
					Formula_Pricing_Rule.Formula_Pricing_Rule_ID = Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID
					AND
					Formula_Pricing_Rule.Deleted = 0
		WHERE     
					(dbo.Contract_Products.Deleted = 0) 
					AND (dbo.Contract_Products.Contract_Main_ID = #Program_ID#) 
					AND (dbo.Program_Formula_Pricing_Rule_Products.Deleted = 0)
 		ORDER BY Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID
	</CFQUERY>
<HTML>
<HEAD>
	<TITLE>Formula Pricing Details</TITLE>
	<style type="text/css">
		<CFINCLUDE template="/Common_Files/main_style.css">
	</style>
</HEAD>
<BODY>
<CFSET Email_Fax_Compatable = true>
<CFPARAM NAME="Fax_Version" 	DEFAULT="0">
	<cfif getRules.recordcount GT 0>		
		<CFSET getInfoForProgramID 	= Program_ID>
		<CFSET getInfoForPeriod 	= "any">
		<CFINCLUDE TEMPLATE="program_pricing_period_information.cfm"> 
	<TABLE CELLSPACING="0" CELLPADDING="2" BORDER="0" WIDTH="90%">
		<TR>
		<CFPARAM NAME="HOW_MANY_COMMS" 	DEFAULT="0">		
		<TD COLSPAN="100%" VALIGN="TOP">			
			<CFIF getRules.recordcount GT 0>				
				<CFOUTPUT QUERY="getRules" GROUP="Program_Formula_Pricing_Rule_Mapped_ID">					
					<CFIF Show_Details>
						<CFSET SHOW_FORMULA_PRICING_DETAIL_INFO = 1>
						<CFSET HOW_MANY_COMMS = HOW_MANY_COMMS + 1>
						<TABLE WIDTH="100%" BORDER="0" <CFIF HOW_MANY_COMMS GT 1 AND NOT Fax_Version>CLASS="pageBreakBefore"</CFIF>>
						<TR>
							<TD>
							<SPAN STYLE="font-weight:bold; font-size: 12px;">[#Get_Program_Info.Contract_Number#]&nbsp;&nbsp;&nbsp;&nbsp;#Get_Program_Info.Contract_Title#</SPAN>
							</TD>
						</TR>						
						<TR>
							<TD>
							<B><FONT SIZE="2" COLOR="Navy">Formula Pricing</FONT></B>&nbsp;&nbsp;&nbsp;&nbsp;
								<CFIF periods.Requested_Period_Info.ValidData EQ 1>
									<SPAN STYLE="font-weight:bold; font-size: 12px;">Prices For Period:</SPAN>
									<SPAN STYLE="font-weight:bold; font-size: 12px; color: red;">#DateFormat(periods.Requested_Period_Info.Start_Date,'m/d/yyyy')# - #DateFormat(periods.Requested_Period_Info.End_Date,'m/d/yyyy')#</SPAN>
									&nbsp;&nbsp;&nbsp;&nbsp;
									<SPAN STYLE="font-weight:bold; font-size: 12px;">Release Date:</SPAN>
									<SPAN STYLE="font-weight:bold; font-size: 12px; color: red;">#DateFormat(periods.Requested_Period_Info.Release_Date,'m/d/yyyy')#</SPAN>
									<CFSET PPID=periods.Requested_Period_Info.Program_Formula_Pricing_Period_ID>
								<CFELSE>
									<SPAN STYLE="font-weight:bold; font-size: 12px; color: red;">NO DATE SUPPLIED</SPAN>
									<CFSET PPID="">
								</CFIF>	
									
							<HR COLOR="Navy">		
							</TD>
						</TR>
						</TABLE>
						<CFSET release_Date = periods.Requested_Period_Info.Release_Date>
						<CFSET THIS_PRODUCT_FORMULA_PRICING_RULE_ID = Formula_Pricing_Rule_ID>						
						<CFINCLUDE template="Formula_Price_Commodity_Value.cfm">
						<TR>
							<TD COLSPAN="100%" STYLE="border:none;font-size : 12px; color: NAVY;">
							<BR>
							<B>Product Prices for this rule</B>
							<HR COLOR="Orange">
							</TD>
						</TR>
						<CFOUTPUT>
							<CFSET CurrentRowColor = IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))>
							<TR VALIGN="top" BGCOLOR="#CurrentRowColor#">
								<TD COLSPAN="5" STYLE="border-bottom: 0px;font-size : 11px;">
								<B>								
								<cfif application.returned_customer_setting.upc_switch>
								#application.returned_customer_setting.upc_label#:#UPC#
								<cfelse>
								#application.returned_customer_setting.item_label#:#ITEM#
								</cfif>
								<BR>#DESCRIPTION#</B>
								</TD>
								<TD  COLSPAN="2" STYLE="border-bottom: 0px;font-size : 10px;">Product Overage: 							
								<CFIF Unit_Of_Measure_ID EQ 3>
									%</TD>
									<CFSET thisAvearage = (getRules.Product_Overage * Grand_Total)/100>
									<TD COLSPAN="2" ALIGN="RIGHT" STYLE="border-bottom: 0px;">#numberformat(getRules.Product_Overage, '_,___.____')#%</TD>
									<TD ALIGN="CENTER" STYLE="border-bottom: 0px;">*</TD>
									<TD ALIGN="RIGHT" STYLE="border-bottom: 0px;">#numberformat(Grand_Total, '_,___.____')#</TD>
								<CFELSE>
									[$/lb]</TD>
									<CFSET thisAvearage = getRules.Product_Overage>
									<TD COLSPAN="4" ALIGN="RIGHT" STYLE="border-bottom: 0px;">$#numberformat(thisAvearage, '_,___.____')#</TD>
								</CFIF>	
								<CFSET Product_Grand_Total = Grand_Total + thisAvearage>
								<TD STYLE="border-bottom: 0px;" ALIGN="center">=</TD>
								<TD ALIGN="RIGHT" STYLE="border-bottom: 0px;">
								$#numberformat(thisAvearage, '_,___.____')#
								<BR>#numberformat(Grand_Total, '_,___.____')#
								</TD>
								<TD STYLE="border-bottom: 0px;">&nbsp;</TD>
								<TD ALIGN="CENTER" STYLE="border-bottom: 0px;">+</TD>
							</TR>	
							<TR BGCOLOR="#CurrentRowColor#">
								<TD STYLE="border-top:solid navy 1px; border-bottom: 0px; font-size : 10px; color: NAVY;">&nbsp;</TD>
								<TD COLSPAN="10" ALIGN="RIGHT" STYLE="border-top:solid navy 1px; border-bottom: 0px; font-size : 12px; color: NAVY;"><B>Product Formula Price</B></TD>
								<TD ALIGN="center" STYLE="border-top:solid navy 1px; border-bottom: 0px; font-size : 12px; color: NAVY;">=</TD>
								<TD ALIGN="RIGHT" STYLE="border-top:solid navy 1px; border-bottom: 0px; font-size : 12px; color: BLUE;"><B>
								<CFIF Proper_Commodity EQ 1>$#numberformat(Product_Grand_Total, '_,___.____')#<CFELSE>#NO_DATA_STR#</CFIF>
								</B></TD>
								<TD COLSPAN="3" STYLE="border-top:solid navy 1px; border-bottom: 0px; font-size : 10px; color: NAVY;">&nbsp;</TD>
							</TR>
						</CFOUTPUT>	
						</TABLE>									
					</CFIF>
				</CFOUTPUT>
				
			</CFIF>
			
		</TD>
	</TR>
	</TABLE>
	<CFSET User_Existing_Query = true>
	<CFINCLUDE template="Formula_Price_Commodity_Summary.cfm">
	</CFIF>
</BODY>
</HTML>
</CFIF>