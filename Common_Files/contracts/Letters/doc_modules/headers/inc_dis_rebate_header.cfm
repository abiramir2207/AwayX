<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/headers/inc_dis_rebate_header.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			05/09/2008 - RBL
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]
EDITED:			09/15/2010 - Milan [Add template setting to show/hide info on the letter]

FUNCTIONALITY:
- This header include is used for the the Distributor Rebate Deal Letters ONLY...
--->
</cfsilent>

<!--- Table details --->
<cfinclude template="../queries/inc_dis_rebate_column_query.cfm">

<cfset table_dis_Rebate.setWidths(jArr)>

<!--- The table is not complete as yet --->
<cfset table_dis_Rebate.setComplete(0)>	

<!--- Add the table column headers --->
<!--- Column 1 --->
<cfif attributes.stPDFBodyInfo.bDistributorLine eq 1>
	<cfset Line_Number_Heading = PdfPCell.init(phrase.init("Line ##", GothicBold_Font_Bold_Black_Eight))>
	<cfset Line_Number_Heading.setColspan( javacast("int", 1) )>
	<cfset Line_Number_Heading.setBorder(Rectangle.NO_BORDER)>
	<cfset table_dis_Rebate.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
	<cfset table_dis_Rebate.addCell(Line_Number_Heading)>
</cfif>

<!--- Column 2 --->
<cfset Item_Description_Heading = PdfPCell.init(phrase.init("Item No / Description", GothicBold_Font_Bold_Black_Eight))>
<cfset Item_Description_Heading.setColspan( javacast("int", 1) )>
<cfset Item_Description_Heading.setBorder(Rectangle.NO_BORDER)>
<cfset table_dis_Rebate.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
<cfset table_dis_Rebate.addCell(Item_Description_Heading)>

<!--- Column 3 --->
<cfif thisTag.bAddcustomerproductnumbers AND attributes.stPDFBodyInfo.bDistributorGTIN>
		<cfset Cust_Prod_Number_And_GTIN_Heading = PdfPCell.init(phrase.init("Cust Prod No" & chr(13) & chr(10) & "GTIN No", GothicBold_Font_Bold_Black_Eight))>
<cfelseif thisTag.bAddcustomerproductnumbers>
		<cfset Cust_Prod_Number_And_GTIN_Heading = PdfPCell.init(phrase.init("Cust Prod No", GothicBold_Font_Bold_Black_Eight))>
<cfelseif attributes.stPDFBodyInfo.bDistributorGTIN>
		<cfset Cust_Prod_Number_And_GTIN_Heading = PdfPCell.init(phrase.init("GTIN No", GothicBold_Font_Bold_Black_Eight))>
</cfif>

<cfif thisTag.bAddcustomerproductnumbers OR attributes.stPDFBodyInfo.bDistributorGTIN>
		<cfset Cust_Prod_Number_And_GTIN_Heading.setColspan( javacast("int", 1) )>
		<cfset Cust_Prod_Number_And_GTIN_Heading.setBorder(Rectangle.NO_BORDER)>
		<cfset table_dis_Rebate.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
		<cfset table_dis_Rebate.addCell(Cust_Prod_Number_And_GTIN_Heading)>
</cfif>

<!--- Column 4 --->
<cfif attributes.stPDFBodyInfo.bDistributorProductNetWeight eq 1>
	<cfset Net_Weight_Heading = PdfPCell.init(phrase.init("Net Wt", GothicBold_Font_Bold_Black_Eight))>
	<cfset Net_Weight_Heading.setColspan( javacast("int", 1) )>
	<cfset Net_Weight_Heading.setBorder(Rectangle.NO_BORDER)>
	<cfset table_dis_Rebate.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
	<cfset table_dis_Rebate.addCell(Net_Weight_Heading)>
</cfif>

<!--- Additional columns (Components) --->
<cfoutput query="thisTag.qProgramRebateComponents">
<!--- If "Component Name" template setting for distributors on letters is set to "Display" --->
<cfif attributes.stPDFBodyInfo.bDistributorComponentName>
		<cfset Rebates_Component_Name_Heading = PdfPCell.init(phrase.init("#thisTag.qProgramRebateComponents.Program_Rebates_Component_Name#", GothicBold_Font_Bold_Black_Eight))>
<cfelse>
		<cfset Rebates_Component_Name_Heading = PdfPCell.init(phrase.init(""))>
</cfif>		
		<cfset Rebates_Component_Name_Heading.setColspan( javacast("int", 1) )>
		<cfset Rebates_Component_Name_Heading.setBorder(Rectangle.NO_BORDER)>
		<cfset Rebates_Component_Name_Heading.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT)>
		<cfset table_dis_Rebate.addCell(Rebates_Component_Name_Heading)>

</cfoutput>
