<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_all_lumpsum_combined_header.cfm
CREATED: 		04/03/2008 - RBL
EDITED:			04/25/2008 - RBL
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]
EDITED:			09/15/2010 - Milan [Add template setting to show/hide info on the letter]

FUNCTIONALITY:
- This include template is utilized to display the top most "Header" module and lumpsum header for all versions of the Deal Letters v2 in ONE table in an effort to minimize vertical space...
The cfoutput tags ARE needed for this include.
--->
<cfparam name="thisTag.bAddcustomerproductnumbers" default= "0">

<cfif findNoCase("HTTPS",cgi.server_protocol,1)>
	<cfset variables.protocol = "https://">
<cfelse>
	<cfset variables.protocol = "http://">
</cfif>
</cfsilent>

<cfset colNum = 3>

<cfset OperatorGTINExists = 0>
<cfset DistributorGTINExists = 0>
<cfset OperatorLineNumberExists = 0>
<cfset DistributorLineNumberExists = 0>
<cfset OperatorNetWeightExists = 0>
<cfset DistributorNetWeightExists = 0>

<!--- Initialize the table --->
<!--- If an operator letter --->
<cfif thisTag.abbreviation eq "opr">
<!--- If show Operator GTIN is ON --->
  <cfif attributes.stPDFBodyInfo.bOperatorGTIN>
    <cfset colNum = 4>
	<cfset OperatorGTINExists = 1>
  </cfif>
<cfelse>
<!--- If a distributor letter --->
<!--- If Addcustomerproductnumbers is ON OR show distributor GTIN is ON --->
  <cfif thisTag.bAddcustomerproductnumbers OR attributes.stPDFBodyInfo.bDistributorGTIN>
    <cfset colNum = 4>
	<cfset DistributorGTINExists = 1>
  </cfif>
</cfif>

<cfif thisTag.abbreviation eq "opr">
	<cfif attributes.stPDFBodyInfo.bOperatorLine eq 1>
		<cfset colNum = colNum + 1/>
		<cfset OperatorLineNumberExists = 1>
	</cfif>
<cfelse>
	<cfif attributes.stPDFBodyInfo.bDistributorLine eq 1>
		<cfset colNum = colNum + 1/>
		<cfset DistributorLineNumberExists = 1>
	</cfif>
</cfif>

<cfif thisTag.abbreviation eq "opr">
	<cfif attributes.stPDFBodyInfo.bOperatorProductNetWeight eq 1>
		<cfset colNum = colNum + 1/>
		<cfset OperatorNetWeightExists = 1>
	</cfif>
<cfelse>
	<cfif attributes.stPDFBodyInfo.bDistributorProductNetWeight eq 1>
		<cfset colNum = colNum + 1/>
		<cfset DistributorNetWeightExists = 1>
	</cfif>
</cfif>

<cfset table_lumpsum = PdfPTable.init( javacast("int",colNum) )>
<cfset table_lumpsum.setWidthPercentage(100)>

<!--- The table is not yet complete --->
<cfset table_lumpsum.setComplete(0)>	


<!--- Set the length of the array as big as the number of columns in the table --->
<cfset jArr = arrObj.newInstance(jClass, colNum)> 

<!--- NOTE: THE COLUMN WIDTHS ARE THE SAME FOR OPERATOR AND DISTRIBUTOR LETTERS --->
<!--- 
Note: When "OperatorGTINExists" is ON, Add the "GTIN" column.
When "OperatorLineNumberExists" is ON, Add the "Line #" column.
When "OperatorNetWeightExists" is ON, Add the "Net Weight" column.
--->
<cfif thisTag.abbreviation eq "opr">
	<cfif OperatorGTINExists eq 0 AND OperatorLineNumberExists eq 0 AND OperatorNetWeightExists eq 0>
		<!--- Only Item ID, Item Description and Amount. --->
			<cfset percentWidth = "33,57,10">
	<cfelseif OperatorGTINExists eq 1 AND OperatorLineNumberExists eq 0 AND OperatorNetWeightExists eq 0>
		<!--- Item, GTIN, Item Description, Amount --->
			<cfset percentWidth = "20,25,45,10">
	<cfelseif OperatorGTINExists eq 0 AND OperatorLineNumberExists eq 0 AND OperatorNetWeightExists eq 1>
		<!--- Item, Item Description, Net Weight, Amount --->
			<cfset percentWidth = "25,50,12,13">
	<cfelseif OperatorGTINExists eq 1 AND OperatorLineNumberExists eq 0 AND OperatorNetWeightExists eq 1>
		<!--- Item, GTIN, Item Description, Net Weight, Amount --->
			<cfset percentWidth = "20,20,40,10,10">
	<cfelseif OperatorGTINExists eq 0 AND OperatorLineNumberExists eq 1 AND OperatorNetWeightExists eq 1>
		<!--- Line Number, Item, Item Description, Net Weight, Amount --->
			<cfset percentWidth = "20,20,40,10,10">
	<cfelseif OperatorGTINExists eq 0 AND OperatorLineNumberExists eq 1 AND OperatorNetWeightExists eq 0>
		<!--- Line Number, Item, Item Description, Amount --->
			<cfset percentWidth = "25,25,40,10">
	<cfelseif OperatorGTINExists eq 1 AND OperatorLineNumberExists eq 1 AND OperatorNetWeightExists eq 0>
		<!--- Line Number, Item, GTIN, Item Description, Amount --->
			<cfset percentWidth = "16,19,19,36,10">
	<cfelseif OperatorGTINExists eq 1 AND OperatorLineNumberExists eq 1 AND OperatorNetWeightExists eq 1>
		<!--- Line Number, Item, GTIN, Item Description, Net Weight, Amount --->
			<cfset percentWidth = "14,17,17,34,8,10">
	</cfif>
<cfelse>
	<cfif (thisTag.bAddcustomerproductnumbers eq 0 AND DistributorGTINExists eq 0) AND DistributorLineNumberExists eq 0 AND DistributorNetWeightExists eq 0>
		<!--- Only Item ID, Item Description and Amount. --->
			<cfset percentWidth = "33,57,10">
	<cfelseif (thisTag.bAddcustomerproductnumbers OR DistributorGTINExists) AND DistributorLineNumberExists eq 0 AND DistributorNetWeightExists eq 0>
		<!--- Item, (Distributor product Number and/or GTIN), Item Description, Amount --->
			<cfset percentWidth = "20,25,45,10">
	<cfelseif (thisTag.bAddcustomerproductnumbers eq 0 AND DistributorGTINExists eq 0) AND DistributorLineNumberExists eq 0 AND DistributorNetWeightExists eq 1>
		<!--- Item, Item Description, Net Weight, Amount --->
			<cfset percentWidth = "25,50,12,13">
	<cfelseif (thisTag.bAddcustomerproductnumbers OR DistributorGTINExists) AND DistributorLineNumberExists eq 0 AND DistributorNetWeightExists eq 1>
		<!--- Item, (Distributor product Number and/or GTIN), Item Description, Net Weight, Amount --->
			<cfset percentWidth = "20,20,40,10,10">
	<cfelseif (thisTag.bAddcustomerproductnumbers eq 0 AND DistributorGTINExists eq 0) AND DistributorLineNumberExists eq 1 AND DistributorNetWeightExists eq 1>
		<!--- Line Number, Item, Item Description, Net Weight, Amount --->
			<cfset percentWidth = "20,20,40,10,10">
	<cfelseif (thisTag.bAddcustomerproductnumbers eq 0 AND DistributorGTINExists eq 0) AND DistributorLineNumberExists eq 1 AND DistributorNetWeightExists eq 0>
		<!--- Line Number, Item, Item Description, Amount --->
			<cfset percentWidth = "25,25,40,10">
	<cfelseif (thisTag.bAddcustomerproductnumbers OR DistributorGTINExists) AND DistributorLineNumberExists eq 1 AND DistributorNetWeightExists eq 0>
		<!--- Line Number, Item, (Distributor product Number and/or GTIN), Item Description, Amount --->
			<cfset percentWidth = "16,19,19,36,10">
	<cfelseif (thisTag.bAddcustomerproductnumbers OR DistributorGTINExists) AND DistributorLineNumberExists eq 1 AND DistributorNetWeightExists eq 1>
		<!--- Line Number, Item, (Distributor product Number and/or GTIN), Item Description, Net Weight, Amount --->
			<cfset percentWidth = "14,17,17,34,8,10">
	</cfif>
</cfif>

<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
will be used as the width of the columns in the table_lumpsum table.
--->
<cfset elementPosition = -1>
<cfloop list="#percentWidth#" index="i">
	<cfset elementPosition = elementPosition + 1>
	<cfset arrObj.setInt(jArr, #elementPosition#, #i#)>
</cfloop>

<cfset table_lumpsum.setWidths(jArr)>

<!--- Table column headers --->
<!--- Column 1 --->
<cfif OperatorLineNumberExists eq 1 OR DistributorLineNumberExists eq 1>
	<cfset Line_Number_Header = PdfPCell.init(phrase.init("Line ##", GothicBold_Font_Bold_Black_Eight))>
	<cfset Line_Number_Header.setColspan( javacast("int", 1) )>
	<cfset Line_Number_Header.setBorder(Rectangle.NO_BORDER)> 
	<cfset table_lumpsum.addCell(Line_Number_Header)>
</cfif>

<!--- Column 2 --->
<cfset Item_Header = PdfPCell.init(phrase.init("Item ID", GothicBold_Font_Bold_Black_Eight))>
<cfset Item_Header.setColspan( javacast("int", 1) )>
<cfset Item_Header.setBorder(Rectangle.NO_BORDER)> 
<cfset table_lumpsum.addCell(Item_Header)>


<!--- Column 3 --->
<cfif thisTag.abbreviation eq "opr">

  <!--- If Operator GTIN is ON --->
  <cfif attributes.stPDFBodyInfo.bOperatorGTIN>
      <cfset Cust_Prod_Number_And_GTIN_Heading = PdfPCell.init(phrase.init("GTIN No", GothicBold_Font_Bold_Black_Eight))>
      <cfset Cust_Prod_Number_And_GTIN_Heading.setColspan( javacast("int", 1) )>
      <cfset Cust_Prod_Number_And_GTIN_Heading.setBorder(Rectangle.NO_BORDER)> 
      <cfset table_lumpsum.addCell(Cust_Prod_Number_And_GTIN_Heading)>
  </cfif>

<cfelse>

 <!--- If the user has requested Customer Product Numbers OR Distributor GTIN is ON --->
  <cfif thisTag.bAddcustomerproductnumbers AND attributes.stPDFBodyInfo.bDistributorGTIN>
    <cfset Cust_Prod_Number_And_GTIN_Heading = PdfPCell.init(phrase.init("Cust Prod No" & chr(13) & chr(10) & "GTIN No", GothicBold_Font_Bold_Black_Eight))>

  <cfelseif thisTag.bAddcustomerproductnumbers>
    <cfset Cust_Prod_Number_And_GTIN_Heading = PdfPCell.init(phrase.init("Cust Prod No", GothicBold_Font_Bold_Black_Eight))>

  <cfelseif attributes.stPDFBodyInfo.bDistributorGTIN>
    <cfset Cust_Prod_Number_And_GTIN_Heading = PdfPCell.init(phrase.init("GTIN No", GothicBold_Font_Bold_Black_Eight))>  
  </cfif>


<!--- (If the user has requested Customer Product Numbers OR Distributor GTIN is ON) --->
<cfif thisTag.bAddcustomerproductnumbers OR attributes.stPDFBodyInfo.bDistributorGTIN>
  <cfset Cust_Prod_Number_And_GTIN_Heading.setColspan( javacast("int", 1) )>
  <cfset Cust_Prod_Number_And_GTIN_Heading.setBorder(Rectangle.NO_BORDER)> 
  <cfset table_lumpsum.addCell(Cust_Prod_Number_And_GTIN_Heading)>
</cfif>

</cfif>

<!--- Column 4 --->
<cfset Item_Description_Header = PdfPCell.init(phrase.init("Item Description", GothicBold_Font_Bold_Black_Eight))>
<cfset Item_Description_Header.setColspan( javacast("int", 1) )>
<cfset Item_Description_Header.setBorder(Rectangle.NO_BORDER)> 
<cfset table_lumpsum.addCell(Item_Description_Header)>

<!--- Column 5 --->
<cfif OperatorNetWeightExists eq 1 OR DistributorNetWeightExists eq 1>
	<cfset Net_Weight_Header = PdfPCell.init(phrase.init("Net Wt", GothicBold_Font_Bold_Black_Eight))>
	<cfset Net_Weight_Header.setColspan( javacast("int", 1) )>
	<cfset Net_Weight_Header.setBorder(Rectangle.NO_BORDER)> 
	<cfset table_lumpsum.addCell(Net_Weight_Header)>
</cfif>

<!--- Column 6 --->
<cfset Amount_Header = PdfPCell.init(phrase.init("Amount", GothicBold_Font_Bold_Black_Eight))>
<cfset Amount_Header.setColspan( javacast("int", 1) )>
<cfset Amount_Header.setBorder(Rectangle.NO_BORDER)> 
<cfset Amount_Header.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT)>
<cfset table_lumpsum.addCell(Amount_Header)>
<cfset document.add(table_lumpsum)>