<!--- To find VolumePerDay, ExpensePerDay, MarginAverage, FiscalMarginDollar ---->
<CFSET QProductFiscal = "">
<cfif rTypeGroups NEQ "">
	<CFOUTPUT><cfsavecontent variable="QProductFiscal">
		SELECT 
		VolumePerDay,
		ExpensePerDay,
		MarginAverage,
		FiscalMarginDollar
		FROM 	MainFiscalValues
		WHERE 			
				Contract_Main_ID=#Contract_Main_ID#
		and		Type_Group_Desc_ID='#Type_Group_Desc_ID#'
		</cfsavecontent></CFOUTPUT>	
<cfelseif rQBrands NEQ "">	
		<CFOUTPUT><cfsavecontent variable="QProductFiscal">
		SELECT 
		VolumePerDay,
		ExpensePerDay,
		MarginAverage,
		FiscalMarginDollar
		FROM 	MainFiscalValues
		WHERE 			
				Contract_Main_ID=#Contract_Main_ID#
		and		Q_Brand_ID='#Q_Brand_ID#'
		</cfsavecontent></CFOUTPUT>
<cfelseif rTypeCodes NEQ "">
	<CFOUTPUT><cfsavecontent variable="QProductFiscal">
		SELECT 
		VolumePerDay,
		ExpensePerDay,
		MarginAverage,
		FiscalMarginDollar
		FROM 	MainFiscalValues
		WHERE 			
				Contract_Main_ID=#Contract_Main_ID#
		and		Type_Code_Desc_ID='#Type_Code_Desc_ID#'
		</cfsavecontent></CFOUTPUT>
<cfelseif rBrands NEQ "">
	<CFOUTPUT><cfsavecontent variable="QProductFiscal">
		SELECT 
		VolumePerDay,
		ExpensePerDay,
		MarginAverage,
		FiscalMarginDollar
		FROM 	MainFiscalValues
		WHERE 			
				Contract_Main_ID=#Contract_Main_ID#
		and		Brand_ID='#Brand_ID#'
		</cfsavecontent></CFOUTPUT>
<cfelseif rProductgroups NEQ "">
	<CFOUTPUT><cfsavecontent variable="QProductFiscal">
		SELECT 
		VolumePerDay,
		ExpensePerDay,
		MarginAverage,
		FiscalMarginDollar
		FROM 	MainFiscalValues
		WHERE 			
				Contract_Main_ID=#Contract_Main_ID#
		and		BSA_Product_Group_ID='#BSA_Product_Group_ID#'
		</cfsavecontent></CFOUTPUT>
<cfelseif rProducts NEQ "">
	<CFOUTPUT><cfsavecontent variable="QProductFiscal">
		SELECT 
		VolumePerDay,
		ExpensePerDay,
		MarginAverage,
		FiscalMarginDollar
		FROM 	MainFiscalValues
		WHERE 			
				Contract_Main_ID=#Contract_Main_ID#
		and		BSA_Foodservice_Items_Master_ID='#BSA_Foodservice_Items_Master_ID#'
		</cfsavecontent></CFOUTPUT>
</cfif>
<CFIF Len(QProductFiscal) GT 0>
	<CFQUERY NAME="Get_ProductFiscalValues" DBTYPE="query">
	#PreserveSingleQuotes(QProductFiscal)#
	</CFQUERY>
	<CFIF Get_ProductFiscalValues.RecordCount GT 0>
		<CFSET drk_temp = QuerySetCell(srQuery, "VolumePerDay", Get_ProductFiscalValues.VolumePerDay, currentrow)>
		<CFSET drk_temp = QuerySetCell(srQuery, "ExpensePerDay", Get_ProductFiscalValues.ExpensePerDay, currentrow)>
		<CFSET drk_temp = QuerySetCell(srQuery, "MarginAverage", Get_ProductFiscalValues.MarginAverage, currentrow)>
		<CFSET drk_temp = QuerySetCell(srQuery, "FiscalMarginDollar", Get_ProductFiscalValues.FiscalMarginDollar, currentrow)>
	</CFIF>
	
</CFIF>