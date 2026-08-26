<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/headers/inc_dis_fixed_price_header.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			05/09/2008 - RBL
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]
EDITED:			09/15/2010 - Milan [Add template setting to show/hide info on the letter]


FUNCTIONALITY:
- This header include is used for the the Distributor Fixed Price Deal Letters ONLY...
--->
</cfsilent>
<cfparam name="thisTag.bShowClaimRateFixedPage" default= "0">
<cfparam name="thisTag.bAddcustomerproductnumbers" default= "0">

<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
	<cfset colNum = 3 />
<cfelse>
<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<cfset colNum = 4 />
</cfif>

<cfif attributes.stPDFBodyInfo.bDistributorLine eq 1>
	<cfset colNum = colNum + 1/>
</cfif>

<cfif attributes.stPDFBodyInfo.bDistributorProductNetWeight eq 1>
	<cfset colNum = colNum + 1 />
</cfif>

<cfset ClaimRateColumn = 0>

<!--- If bShowClaimRateFixedPage is On --->
<cfif thisTag.bShowClaimRateFixedPage>
<!--- If the Operator section has "No distributors" not selected --->
	<!--- Seems like below logic is not needed and so it is commented. --->
	<!---<cfif attributes.qGetLetterSettings.opr_Letter_settings eq 3 eq 0>--->
	   <!--- Add one more column --->
	  <cfset colNum = colNum + 1/>
	  <!--- There will be a column for "Claim Rates" --->
	  <cfset ClaimRateColumn = 1>
	<!---</cfif>--->
</cfif>

<!--- If bAddcustomerproductnumbers is ON OR Display Distributor GTIN is ON, add one more column --->
<cfif thisTag.bAddcustomerproductnumbers OR attributes.stPDFBodyInfo.bDistributorGTIN>
	<cfset colNum = colNum + 1/>
</cfif>

<!--- Initialize a table with  columns --->
<cfset table_dis_FixedPrice = PdfPTable.init( javacast("int",colNum) )>
<cfset table_dis_FixedPrice.setWidthPercentage(100)>

<!--- Set the length of the array as big as the number of columns in the table --->
<cfset jArr = arrObj.newInstance(jClass, colNum)>  

<!--- 
Note: When "thisTag.bAddcustomerproductnumbers EQ 0 AND attributes.stPDFBodyInfo.bDistributorGTIN EQ 0" is ON, add a new column before "Item no".
When attributes.stPDFBodyInfo.bDistributorLine is ON, add the "Line #" column.
When attributes.stPDFBodyInfo.bDistributorProductNetWeight is ON, add the "Net Weight" column.
When "ClaimRateColumn" is ON, add the "claim rates" column.
--->
<!--- Customer Number is ON OR Display Distributor GTIN is ON and ClaimRateColumn is ON --->
<cfif (thisTag.bAddcustomerproductnumbers EQ 0 AND attributes.stPDFBodyInfo.bDistributorGTIN EQ 0) AND attributes.stPDFBodyInfo.bDistributorLine EQ 0 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 0 AND ClaimRateColumn EQ 0>
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Item, Item Description, (Price/LB or Price/CS) --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "25,55,20">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Item, Item Description, Price/LB, Price/CS --->
		<cfset percentWidth = "25,51,12,12">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 1 OR attributes.stPDFBodyInfo.bDistributorGTIN EQ 1) AND attributes.stPDFBodyInfo.bDistributorLine EQ 0 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 0 AND ClaimRateColumn EQ 0>
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<!--- Item, (Distributor product Number and/or GTIN), Item Description, (Price/LB or Price/CS) --->
		<cfset percentWidth = "21,23,44,12">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's ---> 
	<!--- Item, (Distributor product Number and/or GTIN), Item Description, Price/LB, Price/CS --->
		<cfset percentWidth = "17,20,39,12,12">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 0 AND attributes.stPDFBodyInfo.bDistributorGTIN EQ 0) AND attributes.stPDFBodyInfo.bDistributorLine EQ 0 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 0 AND ClaimRateColumn EQ 1>		
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Item, Item Description, (Price/LB or Price/CS), Claim Rates --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "21,45,12,22">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->\
	<!--- Item, Item Description, Price/LB, Price/CS, Claim Rates --->
		<cfset percentWidth = "21,39,12,12,16">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 0 AND attributes.stPDFBodyInfo.bDistributorGTIN EQ 0) AND attributes.stPDFBodyInfo.bDistributorLine EQ 0 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 1 AND ClaimRateColumn EQ 0>
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Item, Item Description, Net Weight, (Price/LB or Price/CS) --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "22,50,12,16">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Item, Item Description, Net Weight, Price/LB, Price/CS --->
		<cfset percentWidth = "22,42,10,13,13">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 1 OR attributes.stPDFBodyInfo.bDistributorGTIN EQ 1) AND attributes.stPDFBodyInfo.bDistributorLine EQ 0 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 1 AND ClaimRateColumn EQ 0>
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Item, (Distributor product Number and/or GTIN), Item Description, Net Weight, (Price/LB or Price/CS) --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "16,21,41,10,12">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Item, (Distributor product Number and/or GTIN), Item Description, Net Weight, Price/LB, Price/CS --->
		<cfset percentWidth = "15,17,34,10,12,12">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 0 AND attributes.stPDFBodyInfo.bDistributorGTIN EQ 0) AND attributes.stPDFBodyInfo.bDistributorLine EQ 1 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 1 AND ClaimRateColumn EQ 0>		
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Line number, Item, Item Description, Net Weight, (Price/LB or Price/CS) --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "18,20,40,10,12">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Line number, Item, Item Description, Net Weight, Price/LB, Price/CS --->
		<cfset percentWidth = "16,18,32,10,12,12">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 1 OR attributes.stPDFBodyInfo.bDistributorGTIN EQ 1) AND attributes.stPDFBodyInfo.bDistributorLine EQ 0 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 0 AND ClaimRateColumn EQ 1>
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Item, (Distributor product Number and/or GTIN), Item Description, (Price/LB or Price/CS), Claim Rates --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "15,18,37,12,18">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Item, (Distributor product Number and/or GTIN), Item Description, Price/LB, Price/CS, Claim Rates --->
		<cfset percentWidth = "15,17,29,12,12,15">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 0 AND attributes.stPDFBodyInfo.bDistributorGTIN EQ 0) AND attributes.stPDFBodyInfo.bDistributorLine EQ 1 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 0 AND ClaimRateColumn EQ 1>
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Line number, Item, Item Description, (Price/LB or Price/CS), Claim Rates --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "16,20,36,12,16">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Line number, Item, Item Description, Price/LB, Price/CS, Claim Rates --->
		<cfset percentWidth = "15,17,29,12,12,15">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 0 AND attributes.stPDFBodyInfo.bDistributorGTIN EQ 0) AND attributes.stPDFBodyInfo.bDistributorLine EQ 1 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 0 AND ClaimRateColumn EQ 0>
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Line number, Item, Item Description, (Price/LB or Price/CS) --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "20,25,43,12">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Line number, Item, Item Description, Price/LB, Price/CS --->
		<cfset percentWidth = "18,23,35,12,12">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 1 OR attributes.stPDFBodyInfo.bDistributorGTIN EQ 1) AND attributes.stPDFBodyInfo.bDistributorLine EQ 1 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 0 AND ClaimRateColumn EQ 0>
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Line number, Item, (Distributor product Number and/or GTIN), Item Description, (Price/LB or Price/CS) --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "15,17,20,36,12">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Line number, Item, (Distributor product Number and/or GTIN), Item Description, Price/LB, Price/CS --->
		<cfset percentWidth = "15,16,17,28,12,12">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 1 OR attributes.stPDFBodyInfo.bDistributorGTIN EQ 1) AND attributes.stPDFBodyInfo.bDistributorLine EQ 1 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 0 AND ClaimRateColumn EQ 1>
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Line number, Item, (Distributor product Number and/or GTIN), Item Description, (Price/LB or Price/CS), Claim rates --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "14,15,17,27,12,15">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Line number, Item, (Distributor product Number and/or GTIN), Item Description, Price/LB, Price/CS, Claim rates --->
		<cfset percentWidth = "13,14,15,23,11,11,13">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 1 OR attributes.stPDFBodyInfo.bDistributorGTIN EQ 1) AND attributes.stPDFBodyInfo.bDistributorLine EQ 1 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 1 AND ClaimRateColumn EQ 0>
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Line number, Item, (Distributor product Number and/or GTIN), Item Description, Net Weight, (Price/LB or Price/CS) --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "15,17,19,27,10,12">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Line number, Item, (Distributor product Number and/or GTIN), Item Description, Net Weight, Price/LB, Price/CS --->
		<cfset percentWidth = "14,15,16,24,9,11,11">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 0 AND attributes.stPDFBodyInfo.bDistributorGTIN EQ 0) AND attributes.stPDFBodyInfo.bDistributorLine EQ 0 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 1 AND ClaimRateColumn EQ 1>		
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Item, Item Description, Net Weight, (Price/LB or Price/CS), Claim Rates --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "22,41,10,12,15">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Item, Item Description, Net Weight, Price/LB, Price/CS, Claim Rates --->
		<cfset percentWidth = "20,31,10,12,12,15">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 1 OR attributes.stPDFBodyInfo.bDistributorGTIN EQ 1) AND attributes.stPDFBodyInfo.bDistributorLine EQ 0  AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 1 AND ClaimRateColumn EQ 1>
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Item, (Distributor product Number and/or GTIN), Item Description, Net Weight, (Price/LB or Price/CS), Claim Rates --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "17,19,27,10,12,15">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Item, (Distributor product Number and/or GTIN), Item Description, Net Weight, Price/LB, Price/CS, Claim Rates --->
		<cfset percentWidth = "15,17,23,9,11,11,14">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 0 AND attributes.stPDFBodyInfo.bDistributorGTIN EQ 0) AND attributes.stPDFBodyInfo.bDistributorLine EQ 1  AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 1 AND ClaimRateColumn EQ 1>
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
	<!--- Line number, Item, Item Description, Net Weight, (Price/LB or Price/CS), Claim Rates --->
		<cfset percentWidth = "17,19,27,10,12,15">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Line number, Item, Item Description, Net Weight, Price/LB, Price/CS, Claim Rates --->
		<cfset percentWidth = "15,17,23,9,11,11,14">
	</cfif>

<cfelseif (thisTag.bAddcustomerproductnumbers EQ 1 OR attributes.stPDFBodyInfo.bDistributorGTIN EQ 1) AND attributes.stPDFBodyInfo.bDistributorLine EQ 1 AND attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 1 AND ClaimRateColumn EQ 1>
	<!---If "UOM" template setting for distributors on letters is set to either "LB" or "CS", we need only one column --->
	<!--- Line number, Item, (Distributor product Number and/or GTIN), Item Description, Net Weight, (Price/LB or Price/CS), Claim Rates --->
	<cfif attributes.stPDFBodyInfo.bDistributorUOM neq 3>
		<cfset percentWidth = "14,15,16,22,9,11,13">
	<cfelse>
	<!---If "UOM" template setting for distributors on letters is set to "Both", we need separate columns for both the UOM's --->
	<!--- Line number, Item, (Distributor product Number and/or GTIN), Item Description, Net Weight, Price/LB, Price/CS, Claim Rates --->
		<cfset percentWidth = "13,14,15,17,9,10,10,12">
	</cfif>
</cfif>

<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
will be used as the width of the columns in the table_dis_FixedPrice table.
--->
<cfset elementPosition = -1>
<cfloop list="#percentWidth#" index="i">
	<cfset elementPosition = elementPosition + 1>
	<cfset arrObj.setInt(jArr, #elementPosition#, #i#)>
</cfloop>

<cfset table_dis_FixedPrice.setWidths(jArr)>

<!--- The table is not completely finished --->
<cfset table_dis_FixedPrice.setComplete(0)>	

<!--- Add the headers for the table columns --->
<!--- Column 1 --->
<cfif attributes.stPDFBodyInfo.bDistributorLine EQ 1>
	<cfset Line_Number_Heading = PdfPCell.init(phrase.init("Line ##", GothicBold_Font_Bold_Black_Eight))>
	<cfset Line_Number_Heading.setColspan( javacast("int", 1) )>
	<cfset Line_Number_Heading.setBorder(Rectangle.NO_BORDER)>
	<cfset table_dis_FixedPrice.addCell(Line_Number_Heading)>
</cfif>

<!--- Column 2 --->
<cfset Item_Number_Heading = PdfPCell.init(phrase.init("Item No", GothicBold_Font_Bold_Black_Eight))>
<cfset Item_Number_Heading.setColspan( javacast("int", 1) )>
<cfset Item_Number_Heading.setBorder(Rectangle.NO_BORDER)>
<!---<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
<cfset table_dis_FixedPrice.addCell(Item_Number_Heading)>

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
	<!---<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
	<cfset table_dis_FixedPrice.addCell(Cust_Prod_Number_And_GTIN_Heading)>
</cfif>

<!--- Column 4 --->
<cfset Item_Description_Heading = PdfPCell.init(phrase.init("Item Description", GothicBold_Font_Bold_Black_Eight))>
<cfset Item_Description_Heading.setColspan( javacast("int", 1) )>
<cfset Item_Description_Heading.setBorder(Rectangle.NO_BORDER)>
<!---<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
<cfset table_dis_FixedPrice.addCell(Item_Description_Heading)>

<!--- Column 5 --->
<cfif attributes.stPDFBodyInfo.bDistributorProductNetWeight EQ 1>
	<cfset Net_Weight_Heading = PdfPCell.init(phrase.init("Net Wt", GothicBold_Font_Bold_Black_Eight))>
	<cfset Net_Weight_Heading.setColspan( javacast("int", 1) )>
	<cfset Net_Weight_Heading.setBorder(Rectangle.NO_BORDER)>
	<cfset table_dis_FixedPrice.addCell(Net_Weight_Heading)>
</cfif>

<!--- If "UOM" template setting for distributors on letters is set to "LB" or "Both" or "per hundred weight (CWT)" or "Program UOM" --->
<!--- Column 6 --->
<cfif attributes.stPDFBodyInfo.bDistributorUOM eq 2 OR attributes.stPDFBodyInfo.bDistributorUOM eq 3 OR attributes.stPDFBodyInfo.bDistributorUOM eq 4 OR attributes.stPDFBodyInfo.bDistributorUOM eq 5>
	<cfif attributes.stPDFBodyInfo.bDistributorUOM eq 2 OR attributes.stPDFBodyInfo.bDistributorUOM eq 3>
		<cfset Price_LB_Heading = PdfPCell.init(phrase.init("Price/LB", GothicBold_Font_Bold_Black_Eight))>
	<!--- If "UOM" template setting for distributors on letters is set to "per hundred weight (CWT)" --->
	<cfelseif attributes.stPDFBodyInfo.bDistributorUOM eq 4>
		<cfset Price_LB_Heading = PdfPCell.init(phrase.init("Price/CWT", GothicBold_Font_Bold_Black_Eight))>
	<!--- If "UOM" template setting for distributors on letters is set to "Program UOM" --->
	<cfelseif attributes.stPDFBodyInfo.bDistributorUOM eq 5>
		<cfset Price_LB_Heading = PdfPCell.init(phrase.init("Price", GothicBold_Font_Bold_Black_Eight))>
	</cfif>

	<cfset Price_LB_Heading.setColspan( javacast("int", 1) )>
	<cfset Price_LB_Heading.setBorder(Rectangle.NO_BORDER)>
	<!---<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
	<cfset table_dis_FixedPrice.addCell(Price_LB_Heading)>
</cfif>

<!--- If "UOM" template setting for distributors on letters is set to "CS" or "Both" --->
<!--- Column 7 --->
<cfif attributes.stPDFBodyInfo.bDistributorUOM eq 1 OR attributes.stPDFBodyInfo.bDistributorUOM eq 3>
	<cfset Price_CS_Heading = PdfPCell.init(phrase.init("Price/CS", GothicBold_Font_Bold_Black_Eight))>
	<cfset Price_CS_Heading.setColspan( javacast("int", 1) )>
	<cfset Price_CS_Heading.setBorder(Rectangle.NO_BORDER)>
	<!---<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
	<cfset table_dis_FixedPrice.addCell(Price_CS_Heading)>
</cfif>

<!--- Column 8 --->
<cfif ClaimRateColumn>
	<cfset Claim_Rate_Heading = PdfPCell.init(phrase.init("Claim Rate/CS (#thisTag.claimRateDate#)", GothicBold_Font_Bold_Black_Eight))>
	<cfset Claim_Rate_Heading.setColspan( javacast("int", 1) )>
	<cfset Claim_Rate_Heading.setBorder(Rectangle.NO_BORDER)>
	<!---<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
	<cfset table_dis_FixedPrice.addCell(Claim_Rate_Heading)>
</cfif>