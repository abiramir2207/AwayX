<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/queries/inc_opr_rebate_column_query.cfm
CREATED: 		03/11/2007 - RBL
EDITED:			03/14/2008 - RBL
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]
EDITED:			09/15/2010 - Milan [Add template setting to show/hide info on the letter]

FUNCTIONALITY:
- This header include includes the query of queries to identify column count for Operator Rebate Deal Letters ONLY...
--->
</cfsilent>

<!--- we MUST identify HOW MANY child components we have so the PDF does NOT give us a headache [begin]... --->
<!--- A.) --->
	<cfquery name="thisTag.qProgramRebateComponents" datasource="#application.datasource#">
		SELECT 		DISTINCT(Program_Rebates_Component_ID),Program_Rebates_Component_Name,Component_Paid_To,claim_mechanics
		FROM			##TMP_Rebate_Price_Details
		WHERE Component_Paid_to IN (<cfif ThisTag.stPDFBodyInfo.bOprPaysToOperator>2<cfelse> 0</cfif>,<cfif ThisTag.stPDFBodyInfo.bOprPaysToDistributor>1<cfelse>0</cfif>)														
		ORDER BY 	Program_Rebates_Component_ID,Component_Paid_to
	</cfquery>
		
		<!--- We need as many columns as they are components plus 2 for (GTIN and Item no/Description) --->
		<cfif attributes.stPDFBodyInfo.bOperatorGTIN>
		  <cfset colNum = thisTag.qProgramRebateComponents.recordCount+2>
		<cfelse>
		<!--- We need as many columns as they are components plus 1 for (Item no/Description) --->
		  <cfset colNum = thisTag.qProgramRebateComponents.recordCount+1>
		</cfif>

		<cfif attributes.stPDFBodyInfo.bOperatorLine eq 1>
			<cfset colNum = colNum + 1 />
		</cfif>

		<cfif attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<cfset colNum = colNum + 1 />
		</cfif>

		<!--- Initialize the table --->
		<cfset table_opr_Rebate = PdfPTable.init( javacast("int",colNum) )>
		<cfset table_opr_Rebate.setWidthPercentage(100)>

		<!--- Set the length of the array as big as the number of columns in the table --->
		<cfset jArr = arrObj.newInstance(jClass, colNum)> 

	<!--- Assign the table column width based on the number of components, as we need as many columns as the number
	of components.
	--->
  <!--- NOTE: Rebate should always be in [item],Program_Rebates_Component_ID,Component_Paid_to ORDER --->
	<!--- B.) --->
	<cfswitch expression="#thisTag.qProgramRebateComponents.recordCount#">
	<!--- MUST MATCH opr_rebate_header!!! --->
<!--- 
Note: When "attributes.stPDFBodyInfo.bOperatorGTIN" is ON, add a new column before "Item no/Description".
When attributes.stPDFBodyInfo.bOperatorLine is ON, add the "Line #" column.
When attributes.stPDFBodyInfo.bOperatorProductNetWeight is ON, add the "Net Weight" column.
--->
<!---
******************************************************************************************************************
NOTE: IF MAKING A CHANGE TO THIS FILE, A CORRESPONDING CHANGE MAY BE REQUIRED ON inc_dis_rebate_column_query.cfm
******************************************************************************************************************
--->
	<cfcase value="1">
		<cfif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- "Item no/Description", component 1 --->
			<cfset percentWidth = "50,50">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- (Item no/Description), GTIN, component 1 --->
			<cfset percentWidth = "55,25,20">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- (Item no/Description), Net Weight, component 1 --->
			<cfset percentWidth = "60,12,28">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- (Item no/Description), GTIN, Net Weight, component 1 --->
			<cfset percentWidth = "50,25,10,15">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- Line Number, (Item no/Description), Net Weight, component 1 --->
			<cfset percentWidth = "25,45,10,20">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- Line Number, (Item no/Description), component 1 --->
			<cfset percentWidth = "20,60,20">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- Line Number, (Item no/Description), GTIN, component 1 --->
			<cfset percentWidth = "20,22,40,18">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- Line Number, (Item no/Description), GTIN, Net Weight, component 1 --->
			<cfset percentWidth = "19,35,18,10,18">
    	</cfif>
	</cfcase>
	<cfcase value="2">
		<cfif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- "Item no/Description", component 1, component 2 --->
			<cfset percentWidth = "60,20,20">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- (Item no/Description), GTIN, component 1, component 2 --->
			<cfset percentWidth = "44,20,18,18">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- (Item no/Description), Net Weight, component 1, component 2 --->
			<cfset percentWidth = "52,12,18,18">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- (Item no/Description), GTIN, Net Weight, component 1, component 2 --->
			<cfset percentWidth = "40,19,11,15,15">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- Line Number, (Item no/Description), Net Weight, component 1, component 2 --->
			<cfset percentWidth = "18,41,11,15,15">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- Line Number, (Item no/Description), component 1, component 2 --->
			<cfset percentWidth = "20,48,16,16">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- Line Number, (Item no/Description), GTIN, component 1, component 2 --->
			<cfset percentWidth = "17,36,19,14,14">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- Line Number, (Item no/Description), GTIN, Net Weight, component 1, component 2 --->
			<cfset percentWidth = "15,33,17,9,13,13">
    	</cfif>
	</cfcase>
	<cfcase value="3">
		<cfif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- "Item no/Description", component 1, component 2, component 3 --->
			<cfset percentWidth = "52,16,16,16">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- (Item no/Description), GTIN, component 1, component 2, component 3 --->
			<cfset percentWidth = "38,20,14,14,14">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- (Item no/Description), Net Weight, component 1, component 2, component 3 --->
			<cfset percentWidth = "48,10,14,14,14">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- (Item no/Description), GTIN, Net Weight, component 1, component 2, component 3 --->
			<cfset percentWidth = "31,18,9,14,14,14">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- Line Number, (Item no/Description), Net Weight, component 1, component 2, component 3 --->
			<cfset percentWidth = "15,36,10,13,13,13">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- Line Number, (Item no/Description), component 1, component 2, component 3 --->
			<cfset percentWidth = "16,42,14,14,14">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- Line Number, (Item no/Description), GTIN, component 1, component 2, component 3 --->
			<cfset percentWidth = "14,31,16,13,13,13">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- Line Number, (Item no/Description), GTIN, Net Weight, component 1, component 2, component 3 --->
			<cfset percentWidth = "14,30,16,7,11,11,11">
    	</cfif>
	</cfcase>
	<cfcase value="4">
		<cfif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- "Item no/Description", component 1, component 2, component 3, component 4 --->
			<cfset percentWidth = "44,14,14,14,14">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- (Item no/Description), GTIN, component 1, component 2, component 3, component 4 --->
			<cfset percentWidth = "31,17,13,13,13,13">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- (Item no/Description), Net Weight, component 1, component 2, component 3, component 4 --->
			<cfset percentWidth = "38,10,13,13,13,13">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- (Item no/Description), GTIN, Net Weight, component 1, component 2, component 3, component 4 --->
			<cfset percentWidth = "28,15,9,12,12,12,12">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- Line Number, (Item no/Description), Net Weight, component 1, component 2, component 3, component 4 --->
			<cfset percentWidth = "14,29,9,12,12,12,12">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- Line Number, (Item no/Description), component 1, component 2, component 3, component 4 --->
			<cfset percentWidth = "17,35,12,12,12,12">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
			<!--- Line Number, (Item no/Description), GTIN, component 1, component 2, component 3, component 4 --->
			<cfset percentWidth = "14,26,16,11,11,11,11">
    	<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
			<!--- Line Number, (Item no/Description), GTIN, Net Weight, component 1, component 2, component 3, component 4 --->
			<cfset percentWidth = "12,22,13,9,11,11,11,11">
    	</cfif>
	</cfcase>
	<!--- If more columns are needed in the future, then we need to add
	a conditional statement for 5 or more components. We should not use cfdefaultcase,
	as the table might not show up if there are more than 4 components.
	--->
</cfswitch>
<!--- we MUST identify HOW MANY child components we have so the PDF does NOT give us a headache [end]... --->

<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
will be used as the width of the columns in the table_opr_Rebate table.
--->
<cfset elementPosition = -1>
<cfloop list="#percentWidth#" index="i">
	<cfset elementPosition = elementPosition + 1>
	<cfset arrObj.setInt(jArr, #elementPosition#, #i#)>
</cfloop>