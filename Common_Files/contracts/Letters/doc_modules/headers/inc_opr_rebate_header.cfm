<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/headers/inc_opr_rebate_header.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			05/09/2008 - RBL
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]
EDITED:			09/15/2010 - Milan [Add template setting to show/hide info on the letter]

FUNCTIONALITY:
- This header include is used for the the Operator Rebate Deal Letters ONLY...
--->

<!--- These parameters are required for this template to process correctly --->
<!--- na --->
</cfsilent>

<!--- Table details --->
<cfinclude template="../queries/inc_opr_rebate_column_query.cfm">

<cfset table_opr_Rebate.setWidths(jArr)>

<!--- Add the table column headers --->
<cfset table_opr_Rebate.setComplete(0)>	

<!--- Add the table column headers --->
<!--- Column 1 --->
<cfif attributes.stPDFBodyInfo.bOperatorLine eq 1>
	<cfset Line_Number_Heading = PdfPCell.init(phrase.init("Line ##", GothicBold_Font_Bold_Black_Eight))>
	<cfset Line_Number_Heading.setColspan( javacast("int", 1) )>
	<cfset Line_Number_Heading.setBorder(Rectangle.NO_BORDER)>
	<cfset table_opr_Rebate.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
	<cfset table_opr_Rebate.addCell(Line_Number_Heading)>
</cfif>

<!--- Column 2 --->
<cfset Item_Description_Heading = PdfPCell.init(phrase.init("Item No / Description", GothicBold_Font_Bold_Black_Eight))>
<cfset Item_Description_Heading.setColspan( javacast("int", 1) )>
<cfset Item_Description_Heading.setBorder(Rectangle.NO_BORDER)>
<cfset table_opr_Rebate.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
<cfset table_opr_Rebate.addCell(Item_Description_Heading)>

<!--- Column 3 --->
<cfif attributes.stPDFBodyInfo.bOperatorGTIN>
  <cfset GTIN_Heading = PdfPCell.init(phrase.init("GTIN No", GothicBold_Font_Bold_Black_Eight))>
  <cfset GTIN_Heading.setColspan( javacast("int", 1) )>
  <cfset GTIN_Heading.setBorder(Rectangle.NO_BORDER)>
  <cfset table_opr_Rebate.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
  <cfset table_opr_Rebate.addCell(GTIN_Heading)>
</cfif>

<!--- Column 4 --->
<cfif attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
	<cfset Net_Weight_Heading = PdfPCell.init(phrase.init("Net Wt", GothicBold_Font_Bold_Black_Eight))>
	<cfset Net_Weight_Heading.setColspan( javacast("int", 1) )>
	<cfset Net_Weight_Heading.setBorder(Rectangle.NO_BORDER)>
	<cfset table_opr_Rebate.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
	<cfset table_opr_Rebate.addCell(Net_Weight_Heading)>
</cfif>

<!--- Additional columns (Components) --->
<cfoutput query="thisTag.qProgramRebateComponents">
<!--- If "Component Name" template setting for operators on letters is set to "Display" --->
<cfif attributes.stPDFBodyInfo.bOperatorComponentName>
		<cfset Rebates_Component_Name_Heading = PdfPCell.init(phrase.init("#thisTag.qProgramRebateComponents.Program_Rebates_Component_Name#", GothicBold_Font_Bold_Black_Eight))>
<cfelse>
		<cfset Rebates_Component_Name_Heading = PdfPCell.init(phrase.init(""))>
</cfif>
		<cfset Rebates_Component_Name_Heading.setColspan( javacast("int", 1) )>
		<cfset Rebates_Component_Name_Heading.setBorder(Rectangle.NO_BORDER)>
		<cfset Rebates_Component_Name_Heading.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT)>
		<cfset table_opr_Rebate.addCell(Rebates_Component_Name_Heading)>
</cfoutput>