<!------ Formula_Price_Commodity_Value_Details.cfm ----->
<CFPARAM NAME="URL.Program_Formula_Pricing_Rule_Comm_Data_ID" 	DEFAULT="">
<CFPARAM NAME="URL.Program_ID" 	DEFAULT="">
<CFSET Program_ID = URL.Program_ID>
<HTML>
<HEAD>
	<TITLE>Formula Price - Commodity Details</TITLE>
</HEAD>
<BODY>
	<CFSET getInfoForProgramID 	= Program_ID>
	<CFSET getInfoForPeriod 	= "any">
	<CFINCLUDE TEMPLATE="program_pricing_period_information.cfm"> 
	<CFSET release_Date = periods.Requested_Period_Info.Release_Date>
	<CFQUERY datasource="#application.datasource#" NAME="Commodity_Data">
		SELECT			fc.Program_Formula_Pricing_Rule_Comm_Data_ID, fc.Program_Formula_Pricing_Rule_ID, fc.Symbol, fc.Point_In_Time, fc.Point_In_Time_UOM, fc.Sample_Size, fc.Sample_Size_UOM, fc.Weight
						,cs.Symbol_Description, cex.Exchange_Detail_Name
		FROM
						Program_Formula_Pricing_Rule_Comm_Data fc,
						Commodities_Symbol cs,
						Commodities_Exchange_Detail cex
		WHERE
						Program_Formula_Pricing_Rule_Comm_Data_ID 	= '#URL.Program_Formula_Pricing_Rule_Comm_Data_ID#'
				AND		fc.Deleted	=	0
				AND		fc.Active	=	1
				AND		cs.Symbol = fc.Symbol
				AND		cex.Exchange_Detail_ID = fc.Exchange
	</CFQUERY>
	<CFINCLUDE template="Formula_Price_Display_Commodity_Data.cfm">
</BODY>
</HTML>
