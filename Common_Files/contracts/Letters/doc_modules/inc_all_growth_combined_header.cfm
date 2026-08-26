<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_all_growth_combined_header.cfm
CREATED: 		3/12/2015 - Milan Mushran
EDITED:		

FUNCTIONALITY:
- This include template is utilized to display the top most "Header" module and growth header in ONE table in an effort to minimize vertical space...
The cfoutput tags ARE needed for this include.
Note:The code flow in this file has been copied from "inc_all_lumpsum_combined_header.cfm".
--->
<cfparam name="thisTag.bAddcustomerproductnumbers" default= "0">

<cfif findNoCase("HTTPS",cgi.server_protocol,1)>
	<cfset variables.protocol = "https://">
<cfelse>
	<cfset variables.protocol = "http://">
</cfif>
</cfsilent>

<cfset colNum = 3>

<!--- Initialize the table --->
<!--- If an operator letter --->
<cfif thisTag.abbreviation eq "opr">
<!--- If show Operator GTIN is ON --->
  <cfif attributes.stPDFBodyInfo.bOperatorGTIN>
    <cfset colNum = 4>
  </cfif>
<cfelse>
<!--- If a distributor letter --->
<!--- If Addcustomerproductnumbers is ON OR show distributor GTIN is ON --->
  <cfif thisTag.bAddcustomerproductnumbers OR attributes.stPDFBodyInfo.bDistributorGTIN>
    <cfset colNum = 4>
  </cfif>
</cfif>

<cfset table_growth = PdfPTable.init( javacast("int",colNum) )>
<cfset table_growth.setWidthPercentage(100)>

<!--- The table is not yet complete --->
<cfset table_growth.setComplete(0)>	


<!--- Set the length of the array as big as the number of columns in the table --->
<cfset jArr = arrObj.newInstance(jClass, colNum)>  

<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
will be used as the width of the columns in the table_growth table.
--->
<cfif colNum eq 3>
    <cfset arrObj.setInt(jArr, 0, 33)>  
    <cfset arrObj.setInt(jArr, 1, 40)>  
    <cfset arrObj.setInt(jArr, 2, 27)>
<cfelse>
    <cfset arrObj.setInt(jArr, 0, 23)>  
    <cfset arrObj.setInt(jArr, 1, 20)>  
    <cfset arrObj.setInt(jArr, 2, 37)>
    <cfset arrObj.setInt(jArr, 3, 20)>
</cfif>

<cfset table_growth.setWidths(jArr)>

<!--- Table column headers --->
<cfif thisTag.abbreviation eq "opr">

  <!--- If Operator GTIN is ON --->
  <cfif attributes.stPDFBodyInfo.bOperatorGTIN>
      <cfset Cust_Prod_Number_And_GTIN_Heading = PdfPCell.init(phrase.init("GTIN No", GothicBold_Font_Bold_Black_Eight))>
      <cfset Cust_Prod_Number_And_GTIN_Heading.setColspan( javacast("int", 1) )>
      <cfset Cust_Prod_Number_And_GTIN_Heading.setBorder(Rectangle.NO_BORDER)> 
      <cfset table_growth.addCell(Cust_Prod_Number_And_GTIN_Heading)>
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
  <cfset table_growth.addCell(Cust_Prod_Number_And_GTIN_Heading)>
</cfif>

</cfif>

<cfset Item_Header = PdfPCell.init(phrase.init("Item ID", GothicBold_Font_Bold_Black_Eight))>
<cfset Item_Header.setColspan( javacast("int", 1) )>
<cfset Item_Header.setBorder(Rectangle.NO_BORDER)> 
<cfset table_growth.addCell(Item_Header)>

<cfset Item_Description_Header = PdfPCell.init(phrase.init("Item Description", GothicBold_Font_Bold_Black_Eight))>
<cfset Item_Description_Header.setColspan( javacast("int", 1) )>
<cfset Item_Description_Header.setBorder(Rectangle.NO_BORDER)> 
<cfset table_growth.addCell(Item_Description_Header)>

<cfset Amount_Header = PdfPCell.init(phrase.init("Rate", GothicBold_Font_Bold_Black_Eight))>
<cfset Amount_Header.setColspan( javacast("int", 1) )>
<cfset Amount_Header.setBorder(Rectangle.NO_BORDER)> 
<cfset Amount_Header.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT)>
<cfset table_growth.addCell(Amount_Header)>
<cfset document.add(table_growth)>