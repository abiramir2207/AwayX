<CFSILENT>
<!------
Growth_Common_Amount_Calc.cfm
----->
<cfset bbDeviationManager = CreateObject("component", "components.billback.BillbackDeviationManager").init() />
<cfset bbDeviationManager.setAppSettings(appSettings) />

<cfparam name="FromLumpSum" 	default=0>

<CFSET Total_Program_Growth_Amount  = 0>
<CFSET Total_Program_Growth_Lumpsum = 0>
<CFSET Component_Based_Volume = QueryNew("component_id,component_name,component_type,component_type_desc,component_volume_lb,component_volume_cs,component_sales_dollars,component_uom")>
<!------------------------------------------------------------
Step 1: Find Growth Dates
------------------------------------------------------------->
<CFSET Growth_Start_Date = Program_Start_Date>
<CFIF DATEDIFF("d", Program_End_Date, Billback_End_Date) GTE 0>
	<CFSET Growth_End_Date = Program_End_Date>
<CFELSE>
	<CFSET Growth_End_Date = Billback_End_Date>
</CFIF>

<!-----------------------------------------------------------
Find the Payee
Billback_Payee_Type_ID
Payee_ID
------------------------------------------------------------->
<CFINCLUDE TEMPLATE="BB_Payee.cfm">
</CFSILENT>
<SCRIPT LANGUAGE="JavaScript">
	function show_Invoice_Rate_Details(trName)
	{
		event.returnValue = false;
		var trObj = document.getElementById(trName);
		var bDisplay = "";
		if(trObj.style.display.length == 0)
		{
			bDisplay = "none";
		}
		trObj.style.display = bDisplay;
	}
</SCRIPT>
<CFSILENT>
<!----------------------------------------------------------
STEP 2:
Get Which Program to consider for Growth
------------------------------------------------------------>
<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Which_Growth_Program">
	SELECT	BB_Program_Info.Contract_Main_ID
			, Contract_Main.Contract_Quantity_UOM_IDX
	FROM	BB_Program_Info
			INNER JOIN	Contract_Main
			ON
			(
				(Contract_Main.Contract_Main_ID = BB_Program_Info.Contract_Main_ID)
			)
	WHERE
			BB_Program_Info.Contract_Number = '#Contract_Number#'
			AND
			DATEDIFF(d, Approval_Start_Date, #createodbcdate(Growth_End_Date)#) >= 0
			AND
			DATEDIFF(d, #createodbcdate(Growth_End_Date)#, Approval_End_Date) >= 0
</CFQUERY>	
</CFSILENT>
<CFIF Billback_Which_Growth_Program.recordCount GT 0>
	<CFSILENT>
	<CFSET Growth_Contract_Main_ID	= Billback_Which_Growth_Program.Contract_Main_ID>			
	
	<!------<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Settings">
	SELECT	BB_Tolerance_TET, BB_Tolerance_DPP, BB_Tolerance_DPPO, BB_Tolerance_TET, BB_Tolerance_ERT, BB_Tolerance_DVT
	FROM	Billback_Settings
	</CFQUERY>----->
	
	<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Settings">
	SELECT	BB_TET AS BB_Tolerance_TET, 
			BB_DPPR AS BB_Tolerance_DPP, 
			BB_DPPO AS BB_Tolerance_DPPO, 
			BB_TET AS BB_Tolerance_TET, 
			BB_ERT AS BB_Tolerance_ERT, 
			BB_EVT AS BB_Tolerance_DVT
	FROM	BB_Basic_Setting_Detail
	WHERE
		Billback_ID = '#Billback_ID#' AND
		Contract_Main_Id = #Growth_Contract_Main_ID#
	</CFQUERY>
	
	<cfif isDefined("Billback_Volume_Tolerance.RecordCount") AND Billback_Volume_Tolerance.RecordCount eq 0>
		<!--- 
		D32309 : Event error value "" cannot be converted to a number on bbk deviations grid
		It is possible that deviation ran agianst this billback before label D31930 was in place, handle for it 
		Get any value available at billback level
		--->
		<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Settings">
		SELECT	BB_TET AS BB_Tolerance_TET, 
				BB_DPPR AS BB_Tolerance_DPP, 
				BB_DPPO AS BB_Tolerance_DPPO, 
				BB_TET AS BB_Tolerance_TET, 
				BB_ERT AS BB_Tolerance_ERT, 
				BB_EVT AS BB_Tolerance_DVT
		FROM	BB_Basic_Setting_Detail
		WHERE
			Billback_ID = '#Billback_ID#'
		</CFQUERY>
	</cfif>
	
	<CFIF Billback_Settings.BB_Tolerance_TET EQ 1>
		<CFSET check_Date="Invoice_Header.Invoice_Date">				
	<CFELSE>
		<CFSET check_Date="Invoice_Header.Ship_Date">
	</CFIF>
	
	<!----------------------------------------------------------
	STEP 2: Get all Component Information for this progam
	----------------------------------------------------------->
	<CFQUERY  dataSource="#application.datasource#" NAME="Get_Program_Component_Info">
		SELECT	DISTINCT Program_Growth_Components.Component_Name, 
				Program_Growth_Components.Program_Growth_Component_ID,
				Program_Growth_Components.Program_Growth_Components_Name_Id,
				Program_Growth_Components.Rate_Type,
				Program_Growth_Components.component_uom,
				Program_Growth_Components.Program_Growth_Comparison_Period_UOM_ID,
				ISNULL(Program_Growth_Components.Comparison_Type, 1) Comparison_Type,
				ISNULL(Program_Growth_Components.Sample_Period, #Evaluate(DateDiff("d", Program_Start_Date, Program_End_Date) + 1)#) Sample_Period,
				Program_Growth_Components.Program_Growth_Component_Type_ID,
				Program_Growth_Component_Type.Description Component_Type_Desc,
				Program_Growth_Components.Is_Rate,
				Program_Growth_Components.Is_Volume,
				Program_Growth_Components.Min_Purchase_Requirement,
				Program_Growth_Components.Min_Purchase_Value
		FROM	Program_Growth_Components
				LEFT JOIN Program_Growth_Component_Type
				ON Program_Growth_Component_Type.Program_Growth_Component_Type_ID = Program_Growth_Components.Program_Growth_Component_Type_ID
				INNER JOIN	Program_Growth_Component_Product_Data
				ON
				(
					(Program_Growth_Component_Product_Data.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID)
					AND
					(Program_Growth_Component_Product_Data.Deleted = 0)
				)
				INNER JOIN	Contract_Products
				ON
				(
					(Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID)
					AND
					(Contract_Products.Deleted = 0)					
				)
		WHERE
				Program_Growth_Components.Program_ID = #Growth_Contract_Main_ID#
				AND Program_Growth_Components.Deleted = 0
				AND Program_Growth_Components.IsParent = 1				
	</CFQUERY>
	</CFSILENT>
	<!----------------------------------------------------
	For Each Component
	----------------------------------------------------->
	<CFLOOP QUERY="Get_Program_Component_Info">
		<CFSILENT>
		<CFSET Component_UOM				= Get_Program_Component_Info.component_uom>
		<CFSET This_Component_Name 				= Get_Program_Component_Info.Component_Name>
		<CFSET Program_Growth_Component_ID 	= Get_Program_Component_Info.Program_Growth_Component_ID>
		<CFSET Volume_Program_Growth_Component_ID 	= Get_Program_Component_Info.Program_Growth_Component_ID>
		<CFSET Program_Growth_Comparison_Period_UOM_ID =  Get_Program_Component_Info.Program_Growth_Comparison_Period_UOM_ID>
		<CFSET Component_Rate_Type 			= Get_Program_Component_Info.Rate_Type>
		<CFSET Component_Total_Amount 		= 0>
		<CFSET Component_Total_Volume_LB 	= 0>
		<CFSET Component_Total_Volume_CS 	= 0>
		<CFSET Component_Total_Sales 		= 0>
		<CFSET Prior_Yr_Comparison_Type		= Get_Program_Component_Info.Comparison_Type>
		<CFSET Prior_Yr_Sample_Period		= Get_Program_Component_Info.Sample_Period>
		<CFSET Component_Program_Growth_Component_Type_ID = Get_Program_Component_Info.Program_Growth_Component_Type_ID>
		<cfset Component_Is_Rate			= Get_Program_Component_Info.Is_Rate>
		<cfset Component_Is_Volume			= Get_Program_Component_Info.Is_Volume>
		<cfset Same_Volume_Pool				= 1>
		<cfset productRateCalculated		= 0>
		<cfset tierReached					= "">
		<cfset Min_Purchase_Requirement 	= Get_Program_Component_Info.Min_Purchase_Requirement />
		<cfset Min_Purchase_Value 			= Get_Program_Component_Info.Min_Purchase_Value />
		<cfset Min_Purchase_Req_Failed		= 0 />
		<cfset Program_Growth_Components_Name_Id = Get_Program_Component_Info.Program_Growth_Components_Name_Id />
			
		<cfset Fob_Price_Indicator = bbDeviationManager.getGrowthComponentFobPriceIndicator(
					programGrowthComponentNameID = Program_Growth_Components_Name_Id,
			   		BBPayeeTypeID = Billback_Payee_Type_ID
				   ) />
		
		</CFSILENT>

		<CFIF NOT FromLumpSum>
		<cfoutput>
		<br><br>
		<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" CLASS="Maintable">
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="100%" STYLE="border:none">
			<B>Component #This_Component_Name# (#Get_Program_Component_Info.Component_Type_Desc#)</B>
			<hr color="orange">
			</TD>
		</TR>
		</TABLE>
		</cfoutput>
		</cfif>
		<cfif Component_Program_Growth_Component_Type_ID EQ 1><!------ 1: Normal Growth ----->			

				<cfif Program_Growth_Comparison_Period_UOM_ID eq 2>
							<cfset Program_Growth_Comparison_Period_UOM = "sales amount">
				<cfelse>
							<cfset Program_Growth_Comparison_Period_UOM = "volume">
				</cfif>
			<cfif Component_Is_Volume EQ 0>
				<cfset Same_Volume_Pool				= 0>
						<cfset qVolumeComponent = bbDeviationManager.getVolumeComponent(Program_Growth_Component_ID)>
				<!------ Get Volume Component ID ----->
				<CFSET Volume_Program_Growth_Component_ID 	= qVolumeComponent.Program_Growth_Component_ID>
		</cfif>
			<cfif Volume_Program_Growth_Component_ID EQ "">
				<CFSET Volume_Program_Growth_Component_ID 	= Get_Program_Component_Info.Program_Growth_Component_ID>
			</cfif>
		
			<!--------------------------------------------------								
			STEP 3	: Determine the Program Type												
			--------------------------------------------------->
			<CFIF Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter AND Billback_Payee_Type_ID EQ 1>
			<!-------------- Trade Shelter and distributor ---------------------->
				<!----------------------------------------------------------
				Get all the invoice for each 
				----------------------------------------------------------->
				<cfset Get_Volume_Info = bbDeviationManager.getGrowthComponentVolume(Payee_ID, Volume_Program_Growth_Component_ID, Growth_Start_Date, Growth_End_Date, check_Date, NOT FromLumpSum, Fob_Price_Indicator)>
			<CFELSE>
				<!-------------- Non Trade Shelter ---------------------->				
				<!----------------------------------------------------------
				Get all the volume from billback 
				----------------------------------------------------------->

				<cfif Program_Growth_Comparison_Period_UOM_ID eq 2>
					<cfset Get_Volume_Info = bbDeviationManager.getGrowthComponentBillbackVolume(Billback_ID, Program_Growth_Component_ID, Contract_Main_ID, NOT FromLumpSum, Program_Growth_Comparison_Period_UOM_ID)>
				<cfelse>
					<cfset Get_Volume_Info = bbDeviationManager.getGrowthComponentBillbackVolume(Billback_ID, Program_Growth_Component_ID, Contract_Main_ID, NOT FromLumpSum, Program_Growth_Comparison_Period_UOM_ID)>
				</cfif>
			</CFIF>

			<CFIF FromLumpSum>
				<CFSET drk_temp = QueryAddRow(Component_Based_Volume)>
				<CFSET drk_temp = QuerySetCell(Component_Based_Volume, "component_id", Program_Growth_Component_ID)>
				<CFSET drk_temp = QuerySetCell(Component_Based_Volume, "component_name", Component_Name)>
				<CFSET drk_temp = QuerySetCell(Component_Based_Volume, "component_type", Component_Program_Growth_Component_Type_ID)>				
				<CFSET drk_temp = QuerySetCell(Component_Based_Volume, "component_type_desc", Get_Program_Component_Info.Component_Type_Desc)>
				<CFSET drk_temp = QuerySetCell(Component_Based_Volume, "component_volume_lb", Get_Volume_Info.Sum_Volume_Invoiced)>
				<CFSET drk_temp = QuerySetCell(Component_Based_Volume, "component_volume_cs", Get_Volume_Info.Sum_Volume_Invoiced_CS)>
				<CFSET drk_temp = QuerySetCell(Component_Based_Volume, "component_Sales_dollars", Get_Volume_Info.Sum_Amount)>
				<CFSET drk_temp = QuerySetCell(Component_Based_Volume, "component_uom", Component_UOM)>
				
				<cfif Min_Purchase_Requirement EQ 1>
					<cfif Val(Get_Volume_Info.Sum_Amount) LT Min_Purchase_Value>
						<cfset Min_Purchase_Req_Failed		= 1 />
					</cfif>
				</cfif>					
				
			<CFELSE><!------ only is normal growth and same volume pool ----->				
				<!-------------------------------------------------------------------------------------
				Loop thru all the product volume to get component total volume
				-------------------------------------------------------------------------------------->
				<CFSET Open_Layer_Caption = "#This_Component_Name#">
				<CF_openLayer
					Border="#Border#"
					BorderSize="#BorderSize#"  
					BorderColor="#BorderColor#"  
					Image="#Image#"
					ImageOpen="#ImageOpen#"
					Title="#Open_Layer_Caption#"  
					TitleClosed="#Open_Layer_Caption#"  
					TitleTooltip="#Open_Layer_Caption#"  
					TitleColor="#TitleColor#"  
					TitleFont="#TitleFont#"
					TitleSize="#TitleSize#"
					IsClosed="Yes"
					Width="#width#"
					AddScript="#AddScript#">
					<CFOUTPUT>
					
					<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" CLASS="Maintable">
						<TR CLASS="MaintableTHEAD">
							<TD COLSPAN="100%" STYLE="border:none">#bbDeviationManager.CapFirst(Program_Growth_Comparison_Period_UOM)# of #This_Component_Name# (#DateFormat(Growth_Start_Date, "mm/dd/yyyy")# - #DateFormat(Growth_End_Date, "mm/dd/yyyy")#)</TD>
						</TR>
						<TR BGCOLOR="FFCE84">
							<TD>&nbsp;</TD>
							<TD>#application.returned_customer_setting.item_label#</TD>
							<TD>Description</TD>
							<TD ALIGN="RIGHT">Volume (LB)</TD>
							<TD ALIGN="RIGHT">Volume (CS)</TD>
							<TD ALIGN="RIGHT">Amount</TD>							
							<TD>&nbsp;</TD>
						</TR>

						<CFLOOP QUERY="Get_Volume_Info">
							<CFSET Component_Total_Volume_LB = Component_Total_Volume_LB + Get_Volume_Info.Sum_Volume_Invoiced>
							<CFSET Component_Total_Volume_CS = Component_Total_Volume_CS + Get_Volume_Info.Sum_Volume_Invoiced_CS>
							<CFSET Component_Total_Sales 	 = Component_Total_Sales + Get_Volume_Info.Sum_Amount>
							<cfif (Get_Volume_Info.currentRow mod 2) NEQ 0>
								<CFSET BGCOLOR="ccffcc">
							<CFELSE>
								<CFSET BGCOLOR="FFFFFF">
							</cfif> <!--------- (Get_Volume_Info.currentRow mod 2) NEQ 0 ----------->
							<CFIF isDefined("PRODUCT_ID")>
								<CFIF Get_Volume_Info.BSA_Foodservice_Items_Master_ID EQ Product_ID>
									<CFSET this_Product_Volume = Get_Volume_Info.Sum_Volume_Invoiced>
									<CFSET BGCOLOR="#DEVIATION_VALID_ROW_INDICATOR_COLOR#">
								</CFIF>
							</CFIF>
							<TR BGCOLOR="#BGCOLOR#">
								<TD>&nbsp;</TD>
								<TD>#Get_Volume_Info.Item#</TD>
								<TD>#Get_Volume_Info.Description#</TD>
								<TD ALIGN="RIGHT">#NumberFormat(Get_Volume_Info.Sum_Volume_Invoiced, "(_.___)")#</TD>
								<TD ALIGN="RIGHT">#NumberFormat(Get_Volume_Info.Sum_Volume_Invoiced_CS, "(_.___)")#</TD>
								<TD ALIGN="RIGHT">#DollarFormat(Get_Volume_Info.Sum_Amount)#</TD>								
								<TD>&nbsp;</TD>
							</TR>	
						</CFLOOP>
						<TR CLASS="MaintableTHEAD">
							<TD COLSPAN="100%" ALIGN="RIGHT" STYLE="border:none">
							<B>Total Component Volume &nbsp;&nbsp; (&##931; Volume (LB)) = </B>#NumberFormat(Component_Total_Volume_LB, "(____.___)")#
							</TD>
						</TR>
						<TR CLASS="MaintableTHEAD">
							<TD COLSPAN="100%" ALIGN="RIGHT" STYLE="border:none">
							<B>Total Component Volume (&##931; Volume (CS)) = </B>#NumberFormat(Component_Total_Volume_CS, "(____.___)")#
							</TD>
						</TR>
						<TR CLASS="MaintableTHEAD">
							<TD COLSPAN="100%" ALIGN="RIGHT" STYLE="border:none">
							<B>Total Component Sales (&##931; Amount) = </B>#DollarFormat(Component_Total_Sales)#
							</TD>
						</TR>
						<cfif Min_Purchase_Requirement EQ 1>
						<TR CLASS="MaintableTHEAD">
							<TD COLSPAN="100%" ALIGN="RIGHT" STYLE="border:none">
							<B>Program Minimum $ Purchase Required = </B>#DollarFormat(Min_Purchase_Value)#
							</TD>
						</TR>
						<cfif Component_Total_Sales LT Min_Purchase_Value>
							<cfset Min_Purchase_Req_Failed		= 1 />
							<TR CLASS="MaintableTHEAD">
								<TD COLSPAN="100%" ALIGN="RIGHT" STYLE="border:none;color:red;">
								<B>Program Minimum $ Purchase Requirement Failed</B>
								</TD>
							</TR>
						</cfif>
						</cfif>						
					</TABLE>					
						</CFOUTPUT>
						<CFSILENT>						
						<!-----------------------------------------------------------
						Get Tier Info
						------------------------------------------------------------>
						<CFIF Component_UOM EQ 1>
							<CFSET Total_Invoice_Statistics_In_Pgm_UOM = Component_Total_Volume_CS>
						<CFELSEIF Component_UOM EQ 3 AND Program_Growth_Comparison_Period_UOM_ID eq 2>
							<CFSET Total_Invoice_Statistics_In_Pgm_UOM = Component_Total_Sales>
						<CFELSE>
							<CFSET Total_Invoice_Statistics_In_Pgm_UOM = Component_Total_Volume_LB>
						</CFIF>	
						
						<CFIF Same_Volume_Pool EQ 0><!------ only if normal growth and diff. volume pool ----->
							<CFIF Component_UOM NEQ 3><!------ Find which is the max tier attained ----->
								<cfparam name="Prior_Year_Volume_Percent" 	default="0">
								<cfif Min_Purchase_Req_Failed>
									<cfset tierReached = 0 />
								<cfelse>
									<cfset tierReached = bbDeviationManager.getGrowthTierAttained(Program_Growth_Component_ID, Total_Invoice_Statistics_In_Pgm_UOM, Component_Total_Sales, Component_UOM, Prior_Year_Volume_Percent)>
								</cfif>
							</CFIF>							
						</CFIF>
						</CFSILENT>
						<CFSET This_Program_Growth_Component_ID = Program_Growth_Component_ID>
						<CFINCLUDE TEMPLATE="Growth_Tier_Information.cfm">
						<CFSILENT>
						<cfif GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>
							<cfset Program_Growth_Comparison_Period_UOM = "sales amount">
						<cfelse>
							<cfset Program_Growth_Comparison_Period_UOM = "volume">
						</cfif>
						<CFIF Same_Volume_Pool EQ 0><!------ only if normal growth and diff. volume pool ----->
							<CFIF Component_UOM EQ 3><!------ If % tier reached can be determined only after Growth_Tier_Information.cfm  ----->
								<cfparam name="Prior_Year_Volume_Percent" 	default="0">
								<cfif Min_Purchase_Req_Failed>
									<cfset tierReached = 0 />
								<cfelse>
									<cfif GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>
										<cfset tierReached = bbDeviationManager.getGrowthTierAttained(Program_Growth_Component_ID, Total_Invoice_Statistics_In_Pgm_UOM, Component_Total_Sales, Component_UOM, Prior_Year_Sales_Dollars_Percent, GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID)>
									<cfelse>
										<cfset tierReached = bbDeviationManager.getGrowthTierAttained(Program_Growth_Component_ID, Total_Invoice_Statistics_In_Pgm_UOM, Component_Total_Sales, Component_UOM, Prior_Year_Volume_Percent, GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID)>
									</cfif>
										<cfset Get_Tier_Info = bbDeviationManager.getGrowthTiers(This_Program_Growth_Component_ID, tierReached)>
								</cfif>
							</cfif>
						</CFIF>
						<CFSET Display_Component_UOM = Component_UOM>
						<CFIF Display_Component_UOM EQ 3>
							<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID neq 2>
								<CFSET Display_Component_UOM = 2>
							<CFELSE>
								<CFSET Display_Component_UOM = 4>
							</CFIF>
						</CFIF>
						</CFSILENT>					
						<!------ Single / Multi Component Type 1 - Normal Growth Start ----->
						<CFIF Same_Volume_Pool EQ 1><!------ only if normal growth and same volume pool ----->
							<cfset productRateCalculated		= 1>
							<CFQUERY NAME="Distinct_Product_For_Percent" DBTYPE="query">
								SELECT	DISTINCT BSA_Foodservice_Items_Master_ID, 
										<CFIF Component_UOM EQ 1>Sum_Volume_Invoiced_CS<CFELSE>Sum_Volume_Invoiced</CFIF> As Total_Volume, Sum_Amount As Total_Sales
								FROM	Get_Volume_Info
							</CFQUERY>
							<CFSET PercentNewColumenVals = RepeatString("0,", Distinct_Product_For_Percent.RecordCount)>
							<CFSET PercentNewColumenValsArr = ListToArray(PercentNewColumenVals , ",")>
							<CFSET D_Temp = QueryAddColumn(Distinct_Product_For_Percent, "TOTAL_RATE", PercentNewColumenValsArr)>
							
							<CFIF Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter AND Billback_Payee_Type_ID EQ 1>
							<CFLOOP QUERY="Distinct_Product_For_Percent">
								<!------ Total_Invoice_Volume_In_Pgm_UOM ----->
								<cfset Get_Invoice_For_This_Product = bbDeviationManager.getInvoiceInfo(Payee_ID, BSA_Foodservice_Items_Master_ID, Growth_Start_Date, Growth_End_Date, Component_UOM, check_Date, 1, Fob_Price_Indicator)>
								<CFSAVECONTENT VARIABLE="PERCENT_DERTAILS_#ReplaceNoCase(BSA_Foodservice_Items_Master_ID, "-", "_", "all")#">
								<TABLE CELLPADDING="2" CELLSPACING="0" WIDTH="100%" BORDER="0">
								<CFOUTPUT>
								<CFSET Percent_Amount_Total = 0>
								<CFSET Percent_Volume_Total = Total_Volume>
								<CFSET No_Percent_Total_Rate = 0>
								<TR BGCOLOR="EEEEEE">
									<TD ID="header" ALIGN="right">Price/#ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#</TD>
									<TD ID="header">&nbsp;</TD>
									<TD ID="header" ALIGN="right">Volume#ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#</TD>
									<TD ID="header">&nbsp;</TD>
									<TD ID="header" ALIGN="right">Amount</TD>
								</TR>	
								<CFLOOP QUERY="Get_Invoice_For_This_Product">
									<TR>
										<TD ALIGN="right" STYLE="border-bottom:solid 93BEE2 1px; font-size : 10px;">#NumberFormat(UOM_Unit_Price, DEVIATION_RATE_FORMAT)#</TD>
										<TD ALIGN="center" STYLE="border-bottom:solid 93BEE2 1px; font-size : 10px;">&nbsp;*&nbsp;</TD>
										<TD ALIGN="right" STYLE="border-bottom:solid 93BEE2 1px; font-size : 10px;">#NumberFormat(UOM_Volume_Invoiced, DEVIATION_VOLUME_FORMAT)#</TD>
										<TD ALIGN="center" STYLE="border-bottom:solid 93BEE2 1px; font-size : 10px;">&nbsp;=&nbsp;</TD>
										<CFSET Current_Percent_Amount = (UOM_Unit_Price * UOM_Volume_Invoiced)>
										<CFSET Percent_Amount_Total = Percent_Amount_Total + Current_Percent_Amount>
										<TD ALIGN="right" STYLE="border-bottom:solid 93BEE2 1px; font-size : 10px;">#NumberFormat(Current_Percent_Amount, DEVIATION_RATE_FORMAT)#</TD>
									</TR>
								</CFLOOP>
								<TR>
									<TD COLSPAN="3" ALIGN="right" ID="header"><B>&##931; Amount</B></TD>
									<TD ID="header"><B>&nbsp;=&nbsp;</B></TD>
									<TD ALIGN="right" ID="header"><B>#NumberFormat(Percent_Amount_Total, DEVIATION_RATE_FORMAT)#</B></TD>									
								</TR>
								<TR>
									<TD COLSPAN="3" ALIGN="right" ID="header"><B>&##931; Volume</B></TD>
									<TD ID="header"><B>&nbsp;=&nbsp;</B></TD>
									<TD ALIGN="right" ID="header"><B>#NumberFormat(Percent_Volume_Total, DEVIATION_VOLUME_FORMAT)#</B></TD>									
								</TR>
									<CFIF Percent_Volume_Total GT 0>
											<CFSET No_Percent_Total_Rate = Percent_Amount_Total/Percent_Volume_Total>
									</CFIF>
								<TR>
									<TD COLSPAN="3" ALIGN="right" ID="header"><B>#NumberFormat(Percent_Amount_Total, DEVIATION_RATE_FORMAT)# / #NumberFormat(Percent_Volume_Total, DEVIATION_VOLUME_FORMAT)#</B></TD>
									<TD ID="header"><B>&nbsp;=&nbsp;</B></TD>
									<TD ALIGN="right" ID="header"><B>#NumberFormat(No_Percent_Total_Rate, DEVIATION_RATE_FORMAT)#</B></TD>
								</TR>
								</CFOUTPUT>
								</TABLE>
								</CFSAVECONTENT>
								<CFSET D_Temp = QuerySetCell(Distinct_Product_For_Percent, "TOTAL_RATE", No_Percent_Total_Rate, CurrentRow)>
							</CFLOOP>
							</CFIF>
							
							<!-------- MULTI & SINGLE --------------->
							<CFOUTPUT>
							<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" CLASS="Maintable">
							<COLGROUP>
							</COLGROUP>
							<TR CLASS="MaintableTHEAD">
								<TD COLSPAN="100%" STYLE="border:none">
								Tier Rates of #This_Component_Name#
								<BR>
								Rate Type: <CFIF Component_Rate_Type EQ 1>SINGLE<CFELSE>MULTI</CFIF>
								</TD>
							</TR>
							<TR BGCOLOR="FFCE84">
								<TD WIDTH="30">&nbsp;</TD>
								<TD ALIGN="right">Tier</TD>
								<TD ALIGN="right">Start (#ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#)</TD>
								<TD ALIGN="right">End (#ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#)</TD>
								<TD ALIGN="right">Rate</TD>
								<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>
								<TD ALIGN="right">&nbsp;</TD>
								</CFIF>
								<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID neq 2><TD ALIGN="right">Rate/#ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#</TD></CFIF>
								<TD ALIGN="right">Delta</TD>						
								<TD>&nbsp;</TD>
								<TD ALIGN="right">Allocation</TD>
								<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID neq 2><TD>&nbsp;</TD></CFIF>
								<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID neq 2><TD ALIGN="right">Rate/(#ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#)</TD></CFIF>
								<TD>&nbsp;</TD>
								<TD ALIGN="right">Amount</TD>
								<TD ALIGN="right">&##931; Amount</TD>
								<TD>&nbsp;</TD>
							</TR>
							</CFOUTPUT>
								<CFOUTPUT QUERY="Get_Tier_Info" GROUP="BSA_Foodservice_Items_Master_ID">
									<CFQUERY dbtype="query" NAME="Get_This_Product_Volume">
										SELECT	
												<CFIF Component_UOM EQ 1>
												Sum_Volume_Invoiced_CS
												<CFELSEIF Component_UOM EQ 3 AND GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>
												Sum_Amount
												<CFELSE>
												Sum_Volume_Invoiced  
												</CFIF>				
												AS Product_Statistics
										FROM	Get_Volume_Info
										WHERE
											Get_Volume_Info.BSA_Foodservice_Items_Master_ID = '#BSA_Foodservice_Items_Master_ID#'
									</CFQUERY>

									<CFIF Get_This_Product_Volume.recordCount GT 0>
										<CFSET Product_Statistics = Get_This_Product_Volume.Product_Statistics>
									<CFELSE>
										<CFSET Product_Statistics = 0>
									</CFIF>
									<CFIF Total_Invoice_Statistics_In_Pgm_UOM NEQ 0>
										<CFSET Allocation = Product_Statistics/Total_Invoice_Statistics_In_Pgm_UOM>
									<CFELSE>
										<CFSET Allocation = 0>
									</CFIF>
									<TR CLASS="MaintableTHEAD" BGCOLOR="dddddd">
										<TD COLSPAN="100%" ALIGN="LEFT" STYLE="border:none">
											#Item# #Description#
											<BR>#bbDeviationManager.CapFirst(Program_Growth_Comparison_Period_UOM)# = 
											<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID neq 2>#NumberFormat(Product_Statistics, DEVIATION_VOLUME_FORMAT)# #ListGetAt(DEVIATION_QUANTITY_UOM,Display_Component_UOM)#<cfelse>#NumberFormat(Product_Statistics, DEVIATION_RATE_FORMAT)# </cfif>
											<BR>
											<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID neq 2>
											Allocation = #NumberFormat(Product_Statistics, DEVIATION_VOLUME_FORMAT)# / #NumberFormat(Total_Invoice_Statistics_In_Pgm_UOM, DEVIATION_VOLUME_FORMAT)#  = #NumberFormat(Allocation, DEVIATION_VOLUME_FORMAT)#
											<CFELSE>
											Allocation = #NumberFormat(Product_Statistics, DEVIATION_RATE_FORMAT)# / #NumberFormat(Total_Invoice_Statistics_In_Pgm_UOM, DEVIATION_RATE_FORMAT)#  = #NumberFormat(Allocation, DEVIATION_RATE_FORMAT)#
											</CFIF>
										</TD>
									</TR>
									
									<!-------
									The following code is so that single rate can be done in the way as of multi
									---------->
									<CFIF Component_Rate_Type EQ 1>
										<CFQUERY NAME="Max_Attained_Tier" DBTYPE="Query">
											SELECT	MAX(Tier_Number) AS Max_Tier_Number
											FROM	Get_Tier_Range_Info
											WHERE
												Tier_Attained_Multi = 1
										</CFQUERY>
										<CFSET Max_Attained_Tier_Number = Max_Attained_Tier.Max_Tier_Number>
										<cfset useLakebaseForMax_Attained_Tier_Rate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_tier_info")>
<cfif useLakebaseForMax_Attained_Tier_Rate>
	<cftry>
		<cfset Max_Attained_Tier_Rate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_tier_info", {
				"bsa_foodservice_items_master_id" = "eq.#BSA_Foodservice_Items_Master_ID#",
				"tier_number" = "eq.#Max_Attained_Tier_Number#",
				"select" = "rate_per_cs,rate_per_lb,real_rate"
			}), "rate_per_cs,rate_per_lb,real_rate"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForMax_Attained_Tier_Rate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForMax_Attained_Tier_Rate>
<CFQUERY NAME="Max_Attained_Tier_Rate" DBTYPE="Query">
											SELECT	Rate_Per_CS, Rate_Per_LB, Real_Rate
											FROM	Get_Tier_Info
											WHERE
												BSA_Foodservice_Items_Master_ID = '#BSA_Foodservice_Items_Master_ID#'
												AND
												Tier_Number = '#Max_Attained_Tier_Number#'										
										</CFQUERY>
</cfif>								
									</CFIF>
									<CFOUTPUT GROUP="Tier_Number">
										<!---- Get This Tier Range Info ------>
										<cfset useLakebaseForGet_This_Tier_Range_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_tier_range_info")>
<cfif useLakebaseForGet_This_Tier_Range_Info>
	<cftry>
		<cfset Get_This_Tier_Range_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_tier_range_info", {
				"tier_number" = "eq.#Tier_Number#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_This_Tier_Range_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_This_Tier_Range_Info>
<CFQUERY NAME="Get_This_Tier_Range_Info" DBTYPE="query">
											SELECT	*
											FROM	Get_Tier_Range_Info
											WHERE
													Tier_Number = #Tier_Number#
										</CFQUERY>
</cfif>								
										<CFSET BGCOLOR="FFFFFF">
										<!-------
									The following code is so that single rate can be done in the way as of multi
									---------->
																
										<CFIF Component_UOM EQ 1>	
											<CFSET this_Tier_Rate_Per_Component_UOM_Product = Get_Tier_Info.Rate_Per_CS>
										<CFELSE>
											<CFSET this_Tier_Rate_Per_Component_UOM_Product = Get_Tier_Info.Rate_Per_LB>
										</CFIF>
										
										<CFIF Component_Rate_Type EQ 1>
											<CFIF Component_UOM EQ 1>	
												<CFSET this_Tier_Rate_Per_Component_UOM = Max_Attained_Tier_Rate.Rate_Per_CS>
											<CFELSE>
												<CFSET this_Tier_Rate_Per_Component_UOM = Max_Attained_Tier_Rate.Rate_Per_LB>
											</CFIF>
											<CFSET Product_Percent_Value = Max_Attained_Tier_Rate.Real_Rate>
										<CFELSE>
											<CFSET this_Tier_Rate_Per_Component_UOM = this_Tier_Rate_Per_Component_UOM_Product>
											<CFSET Product_Percent_Value = Real_Rate>
										</CFIF>
										
										<CFSET A_START = "">
										<CFSET A_END = "">
										<CFIF Rate_UOM EQ 3>
											<CFSET this_Tier_Rate_Per_Component_UOM_Product = 0>
											<cfset useLakebaseForTotal_Invoice_Rate_For_This_Product = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distinct_product_for_percent")>
<cfif useLakebaseForTotal_Invoice_Rate_For_This_Product>
	<cftry>
		<cfset Total_Invoice_Rate_For_This_Product = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distinct_product_for_percent", {
				"bsa_foodservice_items_master_id" = "eq.#BSA_Foodservice_Items_Master_ID#",
				"select" = "total_rate"
			}), "total_rate"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForTotal_Invoice_Rate_For_This_Product = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForTotal_Invoice_Rate_For_This_Product>
<CFQUERY NAME="Total_Invoice_Rate_For_This_Product" DBTYPE="query">
												SELECT	TOTAL_RATE
												FROM	Distinct_Product_For_Percent
												WHERE
														BSA_Foodservice_Items_Master_ID = '#BSA_Foodservice_Items_Master_ID#'
											</CFQUERY>
</cfif>
											<CFSET this_Tier_Rate_Per_Component_UOM_Product = (Total_Invoice_Rate_For_This_Product.TOTAL_RATE * val(Real_Rate)) / 100>
											<CFSET this_Tier_Rate_Per_Component_UOM = (Total_Invoice_Rate_For_This_Product.TOTAL_RATE * val(Product_Percent_Value)) / 100>
											
											<CFSET Re_Product_ID = ReplaceNoCase(BSA_Foodservice_Items_Master_ID, "-", "_", "all")>
											<CFSET A_START = "<a href=""void(0);"" onclick=""javaScript: return show_Invoice_Rate_Details('PERCENT_TR_#Re_Product_ID#_#Tier_Number#');"">">
											<CFSET A_END = "</a>">
										</CFIF>

										<CFSET Delta = "">
										<CFSET Product_Amount = "">
										<CFIF Get_This_Tier_Range_Info.Tier_Attained_Multi>
											<CFSET BGCOLOR="#DEVIATION_VALID_ROW_INDICATOR_COLOR#">
											<CFSET Delta = Get_This_Tier_Range_Info.Effective_Range_End - Get_This_Tier_Range_Info.Range_Start + 1>
											<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>
											 <CFSET Product_Amount = (Delta * Allocation * Real_Rate) / 100>
											<CFELSE>
											 <CFSET Product_Amount = Delta * Allocation * Val(this_Tier_Rate_Per_Component_UOM)>
											</CFIF>
											<CFSET Component_Total_Amount = Component_Total_Amount + Product_Amount>
										</CFIF>
										<TR BGCOLOR="#BGCOLOR#">
											<TD>&nbsp;</TD>
											<TD ALIGN="right">#Get_Tier_Info.Tier_Number#</TD>
											<TD ALIGN="right">#Get_This_Tier_Range_Info.Range_Start#</TD>
											<TD ALIGN="right">#Get_This_Tier_Range_Info.Range_End#</TD>
											<TD ALIGN="right">#Real_Rate# #ListGetAt(DEVIATION_QUANTITY_UOM, RATE_UOM, ",")#</TD>
											<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2><TD ALIGN="CENTER">*</TD></CFIF>
											<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID neq 2><TD ALIGN="right">#A_START##DollarFormat(this_Tier_Rate_Per_Component_UOM_Product)##A_END#</TD></CFIF>
											<CFIF Delta NEQ "" AND Product_Amount NEQ "">
												<TD ALIGN="right">#Delta#</TD>
												<TD ALIGN="CENTER">*</TD>
												<TD ALIGN="right">#NumberFormat(Allocation, DEVIATION_PERCENT_FORMAT)#</TD>
												<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID neq 2><TD ALIGN="CENTER">*</TD></CFIF>
												<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID neq 2><TD ALIGN="right">#DollarFormat(this_Tier_Rate_Per_Component_UOM)#</TD></CFIF>
												<TD ALIGN="CENTER">=</TD>
												<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>
												<TD ALIGN="right" TITLE="#Delta# * #NumberFormat(Allocation, DEVIATION_PERCENT_FORMAT)# * #DollarFormat(Real_Rate)#">#DollarFormat(Product_Amount)#</TD>
												<CFELSE>
												<TD ALIGN="right" TITLE="#Delta# * #NumberFormat(Allocation, DEVIATION_PERCENT_FORMAT)# * #DollarFormat(this_Tier_Rate_Per_Component_UOM)#">#DollarFormat(Product_Amount)#</TD>
												</CFIF>
												<TD ALIGN="right">#DollarFormat(Component_Total_Amount)#</TD>
											<CFELSE>
												<TD COLSPAN="8">&nbsp;</TD>
											</CFIF>
											<TD>&nbsp;</TD>
										</TR>
										<CFIF Rate_UOM EQ 3>								
										<TR STYLE="display:none;" ID="PERCENT_TR_#Re_Product_ID#_#Tier_Number#">
											<TD COLSPAN="6" ALIGN="right" ID="header">#Evaluate("PERCENT_DERTAILS_#Re_Product_ID#")#
											<B>Rate = #NumberFormat(Total_Invoice_Rate_For_This_Product.TOTAL_RATE, DEVIATION_RATE_FORMAT)# * #NumberFormat(Real_Rate, DEVIATION_PERCENT_FORMAT)# % = #NumberFormat(this_Tier_Rate_Per_Component_UOM_Product, DEVIATION_RATE_FORMAT)#</B>
											</TD>
										</TR>								
										</CFIF>
									</CFOUTPUT><!----- Each Tier ----->
								</CFOUTPUT><!----- Each product ---------->
								<CFOUTPUT>
								<TR CLASS="MaintableTHEAD">
									<TD COLSPAN="100%" ALIGN="RIGHT" STYLE="border:none">
										Total Component Amount = #DollarFormat(Component_Total_Amount)#
									</TD>
								</TR>	
								</CFOUTPUT>
							</TABLE>				
						<!------ Single Tier / Multi Tier ----->
					</CFIF><!------ only is normal growth and same volume pool ----->					
				</CF_openLayer>
			</CFIF>	
		<cfelseif Component_Program_Growth_Component_Type_ID EQ 2 OR Component_Program_Growth_Component_Type_ID EQ 3><!------ 2:stairway, 3: X of Y ----->
					<cfset arTragetComp = ArrayNew(1)>
			<cfset tierReached = 0>
			<cfset anyTierMissed = 0>
			<cfset qGetGrowthVolumeComponents = bbDeviationManager.getGrowthVolumeComponents(Program_Growth_Component_ID)>			
			<!------ loop over the different targets ----->
			<cfoutput>									
			<cfloop query="qGetGrowthVolumeComponents">				
				<cfif NOT anyTierMissed OR Component_Program_Growth_Component_Type_ID EQ 3>
				<cfset thisTierAttained = 0>
				<CFSET Display_Component_UOM = qGetGrowthVolumeComponents.Component_UOM>
				<cfset Target_Component_Name = qGetGrowthVolumeComponents.Component_Name>
				<cfset targetValue = qGetGrowthVolumeComponents.Range_End>
				<cfset GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID =  qGetGrowthVolumeComponents.Program_Growth_Comparison_Period_UOM_ID>		
				<cfif GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>
				<cfset Program_Growth_Comparison_Period_UOM = "sales dollars">
				<cfelse>
				<cfset Program_Growth_Comparison_Period_UOM = "volume">
				</cfif>
				<CFIF Display_Component_UOM EQ 3>
					<CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID neq 2>
						<CFSET Display_Component_UOM = 2>
					<CFELSE>
						<CFSET Display_Component_UOM = 4>
					</CFIF>
				</CFIF>
				<!------ find whether this tier is achieved ----->
				<!------ first find the sum of volume of all products ----->
				<cfset Get_Volume_Info = bbDeviationManager.getGrowthComponentVolume(Payee_ID, qGetGrowthVolumeComponents.Program_Growth_Component_ID, Growth_Start_Date, Growth_End_Date, check_Date, NOT FromLumpSum, Fob_Price_Indicator)>				
					<CFIF NOT FromLumpSum>
					<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" CLASS="Maintable">
						<TR CLASS="MaintableTHEAD">
							<TD COLSPAN="100%" STYLE="border:none">#bbDeviationManager.CapFirst(Program_Growth_Comparison_Period_UOM)# of #This_Component_Name# - #Target_Component_Name# (#DateFormat(Growth_Start_Date, "mm/dd/yyyy")# - #DateFormat(Growth_End_Date, "mm/dd/yyyy")#)</TD>
						</TR>
						<tr CLASS="MaintableTHEAD">
							<td COLSPAN="100%" STYLE="border:none">
							Target = #targetValue# #ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#
							</td>
						</tr>
						<TR BGCOLOR="FFCE84">
							<TD>&nbsp;</TD>
							<TD>#application.returned_customer_setting.item_label#</TD>
							<TD>Description</TD>
							<cfif GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>
							<TD ALIGN="LEFT">&nbsp;</TD>	
							<TD ALIGN="LEFT">Sales</TD>
							<cfelse>
							<TD ALIGN="RIGHT">Volume (LB)</TD>
							<TD ALIGN="RIGHT">Volume (CS)</TD>	
							</cfif>
							<TD>&nbsp;</TD>
						</TR>
					</cfif>	 
						<CFLOOP QUERY="Get_Volume_Info">
							<CFSET Component_Total_Volume_LB = Component_Total_Volume_LB + Get_Volume_Info.Sum_Volume_Invoiced>
							<CFSET Component_Total_Volume_CS = Component_Total_Volume_CS + Get_Volume_Info.Sum_Volume_Invoiced_CS>
							<CFSET Component_Total_Sales 	 = Component_Total_Sales + Get_Volume_Info.Sum_Amount>
							<cfif (Get_Volume_Info.currentRow mod 2) NEQ 0>
								<CFSET BGCOLOR="ccffcc">
							<CFELSE>
								<CFSET BGCOLOR="FFFFFF">
							</cfif> <!--------- (Get_Volume_Info.currentRow mod 2) NEQ 0 ----------->
							<CFIF isDefined("PRODUCT_ID")>
								<CFIF Get_Volume_Info.BSA_Foodservice_Items_Master_ID EQ Product_ID>
									<CFSET this_Product_Volume = Get_Volume_Info.Sum_Volume_Invoiced>
									<CFSET BGCOLOR="#DEVIATION_VALID_ROW_INDICATOR_COLOR#">
								</CFIF>
							</CFIF>
							<CFIF NOT FromLumpSum>
							<TR BGCOLOR="#BGCOLOR#">
								<TD>&nbsp;</TD>
								<TD>#Get_Volume_Info.Item#</TD>
								<TD>#Get_Volume_Info.Description#</TD>
								<cfif GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>
								<TD ALIGN="LEFT">&nbsp;</TD>
								<TD ALIGN="LEFT">#DollarFormat(val(Get_Volume_Info.Sum_Amount))#</TD>
								<cfelse>
								<TD ALIGN="RIGHT">#NumberFormat(Get_Volume_Info.Sum_Volume_Invoiced, "(_.___)")#</TD>
								<TD ALIGN="RIGHT">#NumberFormat(Get_Volume_Info.Sum_Volume_Invoiced_CS, "(_.___)")#</TD>								
								</cfif>
								<TD>&nbsp;</TD>
							</TR>	
							</cfif>
						</CFLOOP>
						<cfset sColor = "red">
						<CFIF Component_UOM EQ 1>
							<CFSET Total_Invoice_Statistics_In_Pgm_UOM = Component_Total_Volume_CS>
						<CFELSEIF Component_UOM EQ 1 AND GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>
							<CFSET Total_Invoice_Statistics_In_Pgm_UOM = Component_Total_Sales>
						<CFELSE>
							<CFSET Total_Invoice_Statistics_In_Pgm_UOM = Component_Total_Volume_LB>
						</CFIF>
						
						<cfif Total_Invoice_Statistics_In_Pgm_UOM GT targetValue>
							<cfset tierReached = tierReached + 1>
							<cfset thisTierAttained = 1>
							<cfset sColor = "navy">
						<cfelse>
							<cfset anyTierMissed = 1>
						</cfif>	
					<CFIF NOT FromLumpSum>
						<TR CLASS="MaintableTHEAD">
							<TD COLSPAN="100%" ALIGN="RIGHT" STYLE="border:none;color:#sColor#">
							<B>Total Component Volume &nbsp;&nbsp; (&##931; Volume (LB)) = </B>#NumberFormat(Component_Total_Volume_LB, "(____.___)")#
							</TD>
						</TR>
						<TR CLASS="MaintableTHEAD">
							<TD COLSPAN="100%" ALIGN="RIGHT" STYLE="border:none;color:#sColor#">
							<B>Total Component Volume (&##931; Volume (CS)) = </B>#NumberFormat(Component_Total_Volume_CS, "(____.___)")#
							</TD>
						</TR>
						<TR CLASS="MaintableTHEAD">
						<TD COLSPAN="100%" ALIGN="RIGHT" STYLE="border:none;color:#sColor#">
						<B>Total Component Sales  = </B>$#NumberFormat(Component_Total_Sales, "(____.___)")#
						</TD>
						</TR>
					</TABLE>
					</cfif>
				</cfif><!------ If not any missed ----->	
				<cfif FromLumpSum>
					<!------ Insert into struct ----->					
					<cfset stTisTragetComponent = StructNew()>
					<cfset stTisTragetComponent.targetComponentName = This_Component_Name & " " & Target_Component_Name>
					<cfset stTisTragetComponent.targetValue = targetValue>
					<cfset stTisTragetComponent.targetUOM = ListGetAt(Deviation_Quantity_UOM, Display_Component_UOM, ",")>
					<cfset stTisTragetComponent.targetAttained = thisTierAttained>
					<cfset stTisTragetComponent.growthAmount = Growth_Amount>
					
					<!------ insert into array ----->						
					<cfset ArrayAppend(arTragetComp, stTisTragetComponent)>						
				</cfif>
			</cfloop>
			</cfoutput>			
			<cfif FromLumpSum>
				<CFSET drk_temp = QueryAddRow(Component_Based_Volume)>
				<CFSET drk_temp = QuerySetCell(Component_Based_Volume, "component_id", Program_Growth_Component_ID)>
				<CFSET drk_temp = QuerySetCell(Component_Based_Volume, "component_name", Component_Name)>
				<CFSET drk_temp = QuerySetCell(Component_Based_Volume, "component_type", Component_Program_Growth_Component_Type_ID)>				
				<CFSET drk_temp = QuerySetCell(Component_Based_Volume, "component_type_desc", Get_Program_Component_Info.Component_Type_Desc)>				
				<CFSET drk_temp = QuerySetCell(Component_Based_Volume, "component_uom", Component_UOM)>				
			</cfif>
			<cfset Get_Tier_Info = bbDeviationManager.getGrowthTiers(Program_Growth_Component_ID, tierReached)>			
			<cfset componentIDRe = Replace(Program_Growth_Component_ID, "-", "_", "all")>
			<cfset "ArTargetComponents#componentIDRe#" = arTragetComp>		<cfset arTragetComp = ArrayNew(1)>
		</cfif><!------ Component Type. 1:Normal, 2:Stairway, 3:Xo f Y ----->		
	<cfif NOT productRateCalculated><!------ calculate and display product/rate for all other component types ----->
		<cfif FromLumpSum>
			
		<cfelseif isDefined("Get_Tier_Info")>
			<cfoutput>
		
			<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" CLASS="Maintable">
				<colgroup>
				<col span="2"></col>
				<col span="4" align="right"></col>
				</colgroup>
				<tr CLASS="MaintableTHEAD">
					<td style="border:none;">Tier Attained: #tierReached#</td>
				</tr>
				<TR BGCOLOR="FFCE84">
					<td>Item</td>
					<td>Description</td>
					<CFIF Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter AND Billback_Payee_Type_ID EQ 1  AND GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID NEQ 2>
					<td>Avg Invoice Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#</td>
					</CFIF>
					<td>Rate/(#ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#)</td>
					<td width="10">&nbsp;</td>				
					<td <cfif GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID EQ 2>align="left"</cfif>>#bbDeviationManager.CapFirst(Program_Growth_Comparison_Period_UOM)# (#ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#)</td>
					<td width="10">&nbsp;</td>
					<td>Amount</td>
					<TD>&##931; Amount</TD>
				</tr>
				<cfset Component_Total_Amount = 0>
				<cfloop query="Get_Tier_Info">
					<CFIF Component_UOM EQ 1>
						<CFSET this_Tier_Rate_Per_Component_UOM_Product = Rate_Per_CS>
					<CFELSE>
						<CFSET this_Tier_Rate_Per_Component_UOM_Product = Rate_Per_LB>
					</CFIF>
					<cfset invoicePayeeID = "">
					<CFIF Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter AND Billback_Payee_Type_ID EQ 1>
						<cfset invoicePayeeID = Payee_ID>
						<cfset qProductVolume = bbDeviationManager.getInvoiceInfo(invoicePayeeID, BSA_Foodservice_Items_Master_ID, Growth_Start_Date, Growth_End_Date, Component_UOM, check_Date, 2, Fob_Price_Indicator)>
					<cfelse>
						<cfset qProductVolume = bbDeviationManager.getVolumeFromBillback(Billback_ID, Contract_Main_ID, BSA_Foodservice_Items_Master_ID, Component_UOM)>
					</CFIF>
			
					<cfset productVolume = qProductVolume.UOM_Volume_Invoiced>
					<cfset productSales = qProductVolume.Sales_Dollars>
					<CFIF Rate_UOM EQ 3>
						<cfset this_Tier_Rate_Per_Component_UOM_Product = qProductVolume.AvgPrice * Real_Rate / 100>
					</CFIF>
					<cfif productVolume EQ "">
						<cfset productVolume = 0>
					</cfif>
					<cfif GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>
					<cfset productAmount = (val(Real_Rate) * val(productSales)) /100>
					<cfelse>
					<cfset productAmount = this_Tier_Rate_Per_Component_UOM_Product * productVolume>
					</cfif>
					<cfset Component_Total_Amount = Component_Total_Amount + productAmount>					
					<tr>
						<td>#Item#</td>
						<td>#Description#</td>
						<CFIF Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter AND Billback_Payee_Type_ID EQ 1  AND GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID NEQ 2>
						<td>#NumberFormat(qProductVolume.AvgPrice, DEVIATION_RATE_FORMAT)#</td>
						</CFIF>
						<td><CFIF GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID EQ 2>#NumberFormat(Real_Rate, DEVIATION_PERCENT_FORMAT)# %<CFELSE>#NumberFormat(this_Tier_Rate_Per_Component_UOM_Product, DEVIATION_RATE_FORMAT)#</CFIF></td>
						<td align="center">*</td>		
						<cfif GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID eq 2>
						<td align="left">#NumberFormat(productSales, DEVIATION_RATE_FORMAT)#</td>
						<cfelse>
						<td>#NumberFormat(productVolume, DEVIATION_VOLUME_FORMAT)#</td>
						</cfif>
						<td align="center">=</td>
						<td>#DollarFormat(productAmount)#</td>
						<td>#DollarFormat(Component_Total_Amount)#</td>
					</tr>
					
					<CFIF Rate_UOM EQ 3 AND GrowthTierUOM.Program_Growth_Comparison_Period_UOM_ID NEQ 2>
					<tr>
						<td colspan="4" bgcolor="EFF0B9" align="right">
						Rate/(#ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#) = Avg Invoice Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")# * Program Rate<br>				
						#NumberFormat(qProductVolume.AvgPrice, DEVIATION_RATE_FORMAT)# * #NumberFormat(Real_Rate, DEVIATION_PERCENT_FORMAT)# % = #NumberFormat(this_Tier_Rate_Per_Component_UOM_Product, DEVIATION_RATE_FORMAT)# / #ListGetAt(DEVIATION_QUANTITY_UOM, Display_Component_UOM, ",")#
						</td>
					</tr>
					</cfif>
				</cfloop>
			</table>		
			</cfoutput>
		</cfif>
	</cfif>
	<CFSET Total_Program_Growth_Amount = Total_Program_Growth_Amount + Component_Total_Amount>
	</CFLOOP>
</CFIF><!--------- <CFIF Billback_Which_Growth_Program.recordCount GT 0> ------------->