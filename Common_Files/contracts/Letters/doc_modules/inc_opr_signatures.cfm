<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_opr_signatures.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			04/03/2008 - RBL
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]

FUNCTIONALITY:
- This include template generates the "Operator Signature" module for all versionS of the Deal Letters v2...
ACTION: Q: why do we have cfoutput here in this include, leave.
--->
</cfsilent>

<cfparam name="ShowHTML" default="0">

<!--- Show Itext --->
<cfif ShowHTML eq 0>

<!--- Here I am creating 4 horizontal lines. The vertical difference between each line is 12.
Arguments - From Left, From Bottom, To Left, writer Object --->
<!--- IT IS USED TO CREATE A HORIZONTAL RULE.
<cfset LetterManager.Create_Horizontal_Line(90,753,240,writer)>
<cfset LetterManager.Create_Horizontal_Line(90,741,240,writer)>
<cfset LetterManager.Create_Horizontal_Line(90,729,240,writer)>
<cfset LetterManager.Create_Horizontal_Line(90,717,240,writer)>
--->

<!--- Here I am creating 4 horizontal lines. The vertical difference between each line is 12.
Arguments - From Left, From Bottom, To Left, writer Object --->
<!--- IT IS USED TO CREATE A HORIZONTAL RULE.
<cfset LetterManager.Create_Horizontal_Line(300,753,540,writer)>
<cfset LetterManager.Create_Horizontal_Line(300,741,540,writer)>
<cfset LetterManager.Create_Horizontal_Line(300,729,540,writer)>
<cfset LetterManager.Create_Horizontal_Line(300,717,540,writer)> 
--->


<cfset table_opr_signature = PdfPTable.init( javacast("int",4) )>
<cfset table_opr_signature.setWidthPercentage(100)>

<!--- Set the length of the array as big as the number of columns in the table (2) --->
<cfset jArr = arrObj.newInstance(jClass, 4)> 

<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
		will be used as the width of the columns in the "table_opr_signature" table.
--->

<cfset arrObj.setInt(jArr, 0, 12)>  
<cfset arrObj.setInt(jArr, 1, 28)> 
<cfset arrObj.setInt(jArr, 2, 12)>  
<cfset arrObj.setInt(jArr, 3, 48)> 	

<!--- Set the width of the table --->
<cfset table_opr_signature.setWidths(jArr)>
		
<!--- Add table headers and content --->

<!--- Accepted By 1 --->
<cfset Accepted_By_Header = PdfPCell.init(phrase.init("Accepted By:", GothicNormal_font_Bold_Black_Eight))>
<cfset Accepted_By_Header.setColspan( javacast("int", 1) )>
<cfset Accepted_By_Header.setBorder(Rectangle.NO_BORDER)>
<cfset table_opr_signature.addCell(Accepted_By_Header)>

<cfset Accepted_By_Details = PdfPCell.init(phrase.init(attributes.qGetTemplateSettings.letters_accepted_by, GothicNormal_font_Bold_Black_Eight))> <!--- D36100 ---> 
<cfset Accepted_By_Details.setColspan( javacast("int", 1) )>
<cfset Accepted_By_Details.setBorder(Rectangle.NO_BORDER)>
<cfset Accepted_By_Details.setBorder(Rectangle.BOTTOM)>
<cfset table_opr_signature.addCell(Accepted_By_Details)>

<!--- Accepted By 2 --->
<cfset Accepted_By_Third_Party_Header = PdfPCell.init(phrase.init("Accepted By:", GothicNormal_font_Bold_Black_Eight))>
<cfset Accepted_By_Third_Party_Header.setColspan( javacast("int", 1) )>
<cfset Accepted_By_Third_Party_Header.setBorder(Rectangle.NO_BORDER)>
<cfset table_opr_signature.addCell(Accepted_By_Third_Party_Header)>

<cfset Accepted_By_Third_Party_Details = PdfPCell.init(phrase.init(listSort(replace(thisTag.lsOperatorNames,"##","","all"),"Text","ASC",","), GothicNormal_font_Bold_Black_Eight))>
<cfset Accepted_By_Third_Party_Details.setColspan( javacast("int", 1) )>
<cfset Accepted_By_Third_Party_Details.setBorder(Rectangle.NO_BORDER)>
<cfset Accepted_By_Third_Party_Details.setBorder(Rectangle.BOTTOM)>
<cfset table_opr_signature.addCell(Accepted_By_Third_Party_Details)>

<!--- Name 1 --->
<cfset Name_Header = PdfPCell.init(phrase.init("Name:", GothicNormal_font_Bold_Black_Eight))>
<cfset Name_Header.setColspan( javacast("int", 1) )>
<cfset Name_Header.setBorder(Rectangle.NO_BORDER)>
<cfset table_opr_signature.addCell(Name_Header)>

<cfset Name_Details = PdfPCell.init(phrase.init(""))>
<cfset Name_Details.setColspan( javacast("int", 1) )>
<cfset Name_Details.setBorder(Rectangle.NO_BORDER)>
<cfset Name_Details.setBorder(Rectangle.BOTTOM)>
<cfset table_opr_signature.addCell(Name_Details)>

<!--- Name 2 --->
<cfset Name_Third_Party_Header = PdfPCell.init(phrase.init("Name:", GothicNormal_font_Bold_Black_Eight))>
<cfset Name_Third_Party_Header.setColspan( javacast("int", 1) )>
<cfset Name_Third_Party_Header.setBorder(Rectangle.NO_BORDER)>
<cfset table_opr_signature.addCell(Name_Third_Party_Header)>

<cfset Name_Third_Party_Details = PdfPCell.init(phrase.init(""))>
<cfset Name_Third_Party_Details.setColspan( javacast("int", 1) )>
<cfset Name_Third_Party_Details.setBorder(Rectangle.NO_BORDER)>
<cfset Name_Third_Party_Details.setBorder(Rectangle.BOTTOM)>
<cfset table_opr_signature.addCell(Name_Third_Party_Details)>

<!--- Signature 1 --->
<cfset Signature_Header = PdfPCell.init(phrase.init("Signature:", GothicNormal_font_Bold_Black_Eight))>
<cfset Signature_Header.setColspan( javacast("int", 1) )>
<cfset Signature_Header.setBorder(Rectangle.NO_BORDER)>
<cfset table_opr_signature.addCell(Signature_Header)>

<cfset Signature_Details = PdfPCell.init(phrase.init(""))>
<cfset Signature_Details.setColspan( javacast("int", 1) )>
<cfset Signature_Details.setBorder(Rectangle.NO_BORDER)>
<cfset Signature_Details.setBorder(Rectangle.BOTTOM)>
<cfset table_opr_signature.addCell(Signature_Details)>

<!--- Signature 2 --->
<cfset Signature_Third_Party_Header = PdfPCell.init(phrase.init("Signature:", GothicNormal_font_Bold_Black_Eight))>
<cfset Signature_Third_Party_Header.setColspan( javacast("int", 1) )>
<cfset Signature_Third_Party_Header.setBorder(Rectangle.NO_BORDER)>
<cfset table_opr_signature.addCell(Signature_Third_Party_Header)>

<cfset Signature_Third_Party_Details = PdfPCell.init(phrase.init(""))>
<cfset Signature_Third_Party_Details.setColspan( javacast("int", 1) )>
<cfset Signature_Third_Party_Details.setBorder(Rectangle.NO_BORDER)>
<cfset Signature_Third_Party_Details.setBorder(Rectangle.BOTTOM)>
<cfset table_opr_signature.addCell(Signature_Third_Party_Details)>

<!--- Date 1 --->
<cfset Date_Header = PdfPCell.init(phrase.init("Date:", GothicNormal_font_Bold_Black_Eight))>
<cfset Date_Header.setColspan( javacast("int", 1) )>
<cfset Date_Header.setBorder(Rectangle.NO_BORDER)>
<cfset table_opr_signature.addCell(Date_Header)>

<cfset Date_Details = PdfPCell.init(phrase.init(dateFormat(now(),'mmmm dd, yyyy'), GothicNormal_font_Bold_Black_Eight))>
<cfset Date_Details.setColspan( javacast("int", 1) )>
<cfset Date_Details.setBorder(Rectangle.NO_BORDER)>
<cfset Date_Details.setBorder(Rectangle.BOTTOM)>
<cfset table_opr_signature.addCell(Date_Details)>

<!--- Date 2--->
<cfset Date_Third_Party_Header = PdfPCell.init(phrase.init("Date:", GothicNormal_font_Bold_Black_Eight))>
<cfset Date_Third_Party_Header.setColspan( javacast("int", 1) )>
<cfset Date_Third_Party_Header.setBorder(Rectangle.NO_BORDER)>
<cfset table_opr_signature.addCell(Date_Third_Party_Header)>

<cfset Date_Third_Party_Details = PdfPCell.init(phrase.init(dateFormat(now(),'mmmm dd, yyyy'), GothicNormal_font_Bold_Black_Eight))>
<cfset Date_Third_Party_Details.setColspan( javacast("int", 1) )>
<cfset Date_Third_Party_Details.setBorder(Rectangle.NO_BORDER)>
<cfset Date_Third_Party_Details.setBorder(Rectangle.BOTTOM)>
<cfset table_opr_signature.addCell(Date_Third_Party_Details)>

<!--- Add table to the pdf document --->
<cfset document.add(table_opr_signature)>

<cfelse>
<!--- Show HTML --->

<!--- This duplicate css file must be here. --->
<cfinclude template="css/inc_all_style.cfm">
<table name="outer_table" width="100%" cellpadding="0" cellspacing="0" class="top noBorderNoPadNoMargin">
  <tr>
      <td align="center" valign="top">
          <table name="inner_table" width="90%" cellpadding="0" cellspacing="0" class="top noBorderNoPadNoMargin">
          <!--- page break [end] --->
              
              <!--- 6.) Signatures [begin] --->
              <cfoutput>
                  <tr name="row_9">
                      <td colspan="6" align="center">
                          <table name="nested_table" border="0" cellpadding="5" cellspacing="0" width="100%" class="top noBorderNoPadNoMargin">
                              <tr>
                                  <td valign="top" width="10%">Accepted By:</td>
                                  <td valign="top" colspan="2" class="thinBottomBorder" width="40%">
                                  	#attributes.qGetTemplateSettings.letters_accepted_by#
                                     <!--- D36100  :: MOVE 'Letters Accepted By text' SETTING TO BE AT THE TEMPLATE LEVEL
                                     #thisTag.oAppSettings.getLettersAcceptedBy()# 
                                     --->
                                  </td>
                                  <td valign="top" width="10%">Accepted By:</td>
                                  <td valign="top" colspan="2" class="thinBottomBorder" width="40%">
                                      #listSort(replace(thisTag.lsOperatorNames,"##","","all"),"Text","ASC",",")#
                                  </td>
                              <tr>
                               <tr>
                                  <td valign="top">Name:</td>
                                  <td valign="top" colspan="2" class="thinBottomBorder">
                                      <!--- #thisTag.qGetProgramDetails.name_first# #thisTag.qGetProgramDetails.name_last# --->&nbsp;
                                  </td>
                                  <td valign="top">Name:</td>
                                  <td valign="top" colspan="2" class="thinBottomBorder">&nbsp;
                                      
                                  </td>
                              <tr>
                              <tr>
                                  <td valign="top">Signature:</td>
                                  <td valign="top" colspan="2" class="thinBottomBorder">&nbsp;
                                      
                                  </td>
                                  <td valign="top">Signature:</td>
                                  <td valign="top" colspan="2" class="thinBottomBorder">&nbsp;
                                      
                                  </td>
                              <tr>
                              <tr>
                                  <td valign="top">Date:</td>
                                  <td valign="top" colspan="2" class="thinBottomBorder">
                                      #dateFormat(now(),"mmmm dd, yyyy")#
                                  </td>
                                  <td valign="top">Date:</td>
                                  <td valign="top" colspan="2" class="thinBottomBorder">
                                      #dateFormat(now(),"mmmm dd, yyyy")#
                                  </td>
                              <tr>
                          </table>
                      </td>
                  </tr>
              </cfoutput>
              <!--- 6.) Signatures [end] --->             
          </table>
      </td>
  </tr>
</table>
</cfif>