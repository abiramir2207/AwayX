<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/headers/inc_opr_fixed_price_header.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			05/09/2008 - RBL
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]
EDITED:			09/15/2010 - Milan [Add template setting to show/hide info on the letter]

FUNCTIONALITY:
- This header include is used for the the Operator Fixed Price Deal Letters ONLY...
--->

<!--- These parameters are required for this template to process correctly --->
<!--- na --->
</cfsilent>


<!---If "UOM" template setting for operators on letters is set to either "LB" or "CS", we need only one column --->
<cfif attributes.stPDFBodyInfo.bOperatorGTIN eq 0>
  <cfif attributes.stPDFBodyInfo.bOperatorUOM neq 3>
	<cfset colNum = 3 />
  <cfelse>
  <!---If "UOM" template setting for operators on letters is set to "Both", we need separate columns for both the UOM's --->
	<cfset colNum = 4 />
  </cfif>

<cfelse>

  <cfif attributes.stPDFBodyInfo.bOperatorUOM neq 3>
	<cfset colNum = 4 />
  <cfelse>
  <!---If "UOM" template setting for operators on letters is set to "Both", we need separate columns for both the UOM's --->
	<cfset colNum = 5 />
  </cfif>
</cfif>

<cfif attributes.stPDFBodyInfo.bOperatorLine eq 1>
	<cfset colNum = colNum + 1 />
</cfif>

<cfif attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
	<cfset colNum = colNum + 1 />
</cfif>

<!--- Initialize a table with (colNum) number of columns --->
<cfset table_opr_FixedPrice = PdfPTable.init( javacast("int",#colNum#) )>
<cfset table_opr_FixedPrice.setWidthPercentage(100)>

<!--- Set the length of the array as big as the number of columns in the table (colNum) --->
<cfset jArr = arrObj.newInstance(jClass, #colNum#)>  

<!--- 
Note: When "attributes.stPDFBodyInfo.bOperatorGTIN" is ON, add a new column before "Item no".
When attributes.stPDFBodyInfo.bOperatorLine is ON, add the "Line #" column.
When attributes.stPDFBodyInfo.bOperatorProductNetWeight is ON, add the "Net Weight" column.
--->
<!---If "UOM" template setting for operators on letters is set to either "LB" or "CS", we need only one column --->
<cfif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>  
  <cfif attributes.stPDFBodyInfo.bOperatorUOM neq 3>
	<!--- Item, Item Description, (Price/LB or Price/CS) --->
	 <cfset percentWidth = "25,60,15">
  <cfelse>
	<!---If "UOM" template setting for operators on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Item, Item Description, Price/LB, Price/CS --->
	<cfset percentWidth = "25,42,21,12">
  </cfif>

<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
  <cfif attributes.stPDFBodyInfo.bOperatorUOM neq 3>
	<!--- Item, GTIN, Item Description, (Price/LB or Price/S) --->
	<cfset percentWidth = "21,23,44,12">
  <cfelse>
	<!---If "UOM" template setting for operators on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Item, GTIN, Item Description, Price/LB, Price/CS --->
	<cfset percentWidth = "20,21,35,12,12">
  </cfif>

<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
  <cfif attributes.stPDFBodyInfo.bOperatorUOM neq 3>
	<!--- Item, Item Description, Net weight, (Price/LB or Price/CS) --->
	<cfset percentWidth = "25,48,12,15">
  <cfelse>
	<!---If "UOM" template setting for operators on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Item, Item Description, Net weight, Price/LB, Price/CS --->
	<cfset percentWidth = "22,42,10,13,13">
  </cfif>

<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 0 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
  <cfif attributes.stPDFBodyInfo.bOperatorUOM neq 3>
	<!--- Item, GTIN, Item Description, Net weight, (Price/LB or Price/CS) --->
	<cfset percentWidth = "20,22,31,12,15">
  <cfelse>
	<!---If "UOM" template setting for operators on letters is set to "Both", we need separate columns for both the UOM's --->
	<!---  Item, GTIN, Item Description, Net weight, Price/LB, Price/CS --->
	<cfset percentWidth = "17,20,28,9,13,13">
  </cfif>

<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
  <cfif attributes.stPDFBodyInfo.bOperatorUOM neq 3>
	<!--- Line number, Item, Item Description, Net weight, (Price/LB or Price/CS) --->
	<cfset percentWidth = "19,21,36,10,14">
  <cfelse>
	<!---If "UOM" template setting for operators on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Line number, Item, Item Description, Net weight, Price/LB, Price/CS --->
	<cfset percentWidth = "16,20,30,10,12,12">
  </cfif>

<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 0 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
  <cfif attributes.stPDFBodyInfo.bOperatorUOM neq 3>
	<!--- Line number, Item, Item Description, (Price/LB or Price/CS) --->
	<cfset percentWidth = "21,25,42,12">
  <cfelse>
	<!---If "UOM" template setting for operators on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Line number, Item, Item Description, Price/LB, Price/CS --->
	<cfset percentWidth = "20,20,36,12,12">
  </cfif>

<cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 0>
  <cfif attributes.stPDFBodyInfo.bOperatorUOM neq 3>
	<!--- Line number, Item, GTIN, Item Description, (Price/LB or Price/CS) --->
	<cfset percentWidth = "17,20,20,31,12">
  <cfelse>
	<!---If "UOM" template setting for operators on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Line number, Item, GTIN, Item Description, Price/LB, Price/CS --->
	<cfset percentWidth = "15,15,17,29,12,12">
  </cfif>

  <cfelseif attributes.stPDFBodyInfo.bOperatorGTIN eq 1 AND attributes.stPDFBodyInfo.bOperatorLine eq 1 AND attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
  <cfif attributes.stPDFBodyInfo.bOperatorUOM neq 3>
	<!--- Line number, Item, GTIN, Item Description, Net Weight, (Price/LB or Price/CS) --->
	<cfset percentWidth = "16,16,18,28,10,12">
  <cfelse>
	<!---If "UOM" template setting for operators on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Line number, Item, GTIN, Item Description, Net Weight, Price/LB, Price/CS --->
	<cfset percentWidth = "13,13,15,25,10,12,12">
  </cfif>
</cfif>

<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
will be used as the width of the columns in the table_opr_FixedPrice table.
--->
<cfset elementPosition = -1>
<cfloop list="#percentWidth#" index="i">
	<cfset elementPosition = elementPosition + 1>
	<cfset arrObj.setInt(jArr, #elementPosition#, #i#)>
</cfloop>

<cfset table_opr_FixedPrice.setWidths(jArr)>

<!--- The table is not completely finished --->
<cfset table_opr_FixedPrice.setComplete(0)>	

<!--- Add the headers for the table columns --->
<!--- Column 1 --->
<cfif attributes.stPDFBodyInfo.bOperatorLine eq 1>
	<cfset Line_Number_Heading = PdfPCell.init(phrase.init("Line ##", GothicBold_Font_Bold_Black_Eight))>
	<cfset Line_Number_Heading.setColspan( javacast("int", 1) )>
	<cfset Line_Number_Heading.setBorder(Rectangle.NO_BORDER)>
	<cfset table_opr_FixedPrice.addCell(Line_Number_Heading)>
</cfif>

<!--- Column 2 --->
<cfset Item_Number_Heading = PdfPCell.init(phrase.init("Item No", GothicBold_Font_Bold_Black_Eight))>
<cfset Item_Number_Heading.setColspan( javacast("int", 1) )>
<cfset Item_Number_Heading.setBorder(Rectangle.NO_BORDER)>
<!---<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
<cfset table_opr_FixedPrice.addCell(Item_Number_Heading)>

<!--- Column 3 --->
<cfif attributes.stPDFBodyInfo.bOperatorGTIN>
  <cfset GTIN_Number_Heading = PdfPCell.init(phrase.init("GTIN", GothicBold_Font_Bold_Black_Eight))>
  <cfset GTIN_Number_Heading.setColspan( javacast("int", 1) )>
  <cfset GTIN_Number_Heading.setBorder(Rectangle.NO_BORDER)>
  <!---<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
  <cfset table_opr_FixedPrice.addCell(GTIN_Number_Heading)>
</cfif>

<!--- Column 4 --->
<cfset Item_Description_Heading = PdfPCell.init(phrase.init("Item Description", GothicBold_Font_Bold_Black_Eight))>
<cfset Item_Description_Heading.setColspan( javacast("int", 1) )>
<cfset Item_Description_Heading.setBorder(Rectangle.NO_BORDER)>
<!---<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
<cfset table_opr_FixedPrice.addCell(Item_Description_Heading)>

<!--- Column 5 --->
<cfif attributes.stPDFBodyInfo.bOperatorProductNetWeight>
	<cfset Net_Weight_Heading = PdfPCell.init(phrase.init("Net Wt", GothicBold_Font_Bold_Black_Eight))>
	<cfset Net_Weight_Heading.setColspan( javacast("int", 1) )>
	<cfset Net_Weight_Heading.setBorder(Rectangle.NO_BORDER)>
	<cfset table_opr_FixedPrice.addCell(Net_Weight_Heading)>
</cfif>

<!--- If "UOM" template setting for operators on letters is set to "LB" or "Both" or "per hundred weight (CWT)" or "Program UOM" --->
<!--- Column 6 --->
<cfif attributes.stPDFBodyInfo.bOperatorUOM eq 2 OR attributes.stPDFBodyInfo.bOperatorUOM eq 3 OR attributes.stPDFBodyInfo.bOperatorUOM eq 4 OR attributes.stPDFBodyInfo.bOperatorUOM eq 5>	
	<cfif attributes.stPDFBodyInfo.bOperatorUOM eq 2 OR attributes.stPDFBodyInfo.bOperatorUOM eq 3>
		<cfset Price_LB_Heading = PdfPCell.init(phrase.init("Price/LB", GothicBold_Font_Bold_Black_Eight))>
	<!--- If "UOM" template setting for operators on letters is set to "per hundred weight (CWT)" --->
	<cfelseif attributes.stPDFBodyInfo.bOperatorUOM eq 4>
		<cfset Price_LB_Heading = PdfPCell.init(phrase.init("Price/CWT", GothicBold_Font_Bold_Black_Eight))>
	<!--- If "UOM" template setting for operators on letters is set to "Program UOM" --->
	<cfelseif attributes.stPDFBodyInfo.bOperatorUOM eq 5>
		<cfset Price_LB_Heading = PdfPCell.init(phrase.init("Price", GothicBold_Font_Bold_Black_Eight))>
	</cfif>

	<cfset Price_LB_Heading.setColspan( javacast("int", 1) )>
	<cfset Price_LB_Heading.setBorder(Rectangle.NO_BORDER)>
	<!---<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
	<cfset table_opr_FixedPrice.addCell(Price_LB_Heading)>
</cfif>

<!--- If "UOM" template setting for operators on letters is set to "CS" or "Both" --->
<!--- Column 7 --->
<cfif attributes.stPDFBodyInfo.bOperatorUOM eq 1 OR attributes.stPDFBodyInfo.bOperatorUOM eq 3>	
	<cfset Price_CS_Heading = PdfPCell.init(phrase.init("Price/CS", GothicBold_Font_Bold_Black_Eight))>
	<cfset Price_CS_Heading.setColspan( javacast("int", 1) )>
	<cfset Price_CS_Heading.setBorder(Rectangle.NO_BORDER)>
	<!---<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
	<cfset table_opr_FixedPrice.addCell(Price_CS_Heading)>
</cfif>