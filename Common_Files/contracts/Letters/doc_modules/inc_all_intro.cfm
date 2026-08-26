<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_all_intro.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			04/15/2008 - RBL
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]
EDITED:			09/15/2010 - Milan [Add template setting to show/hide info on the letter]

FUNCTIONALITY:
- This include template is utilized to display the "Intro" module for all versions of the Letters
--->
</cfsilent>

	<!--- Initialize the "Operator" table with 3 columns --->
	<cfset tableHeaderOperator = PdfPTable.init( javacast("int",3) )>
	<cfset tableHeaderOperator.setWidthPercentage(100)>

	<!--- Initialize the "Distributor" table with 3 columns --->
	<cfset tableHeaderDistributor = PdfPTable.init( javacast("int",3) )>
	<cfset tableHeaderDistributor.setWidthPercentage(100)>

	<!--- Add Program category --->
	<cfset document.add(phrase.init(chr(13) & chr(10) & chr(13) & chr(10) &chr(13) & chr(10) & chr(13) & chr(10) & "Program Category: ", GothicBold_Font_Normal_Black_Eight))>
	<cfset document.add(phrase.init(thisTag.stPDFIntroInfo.template_name & chr(13) & chr(10), GothicBold_Font_Bold_Black_Eight))>

	<!--- Add Eligible Dates --->
	<cfset document.add(phrase.init("Eligible Dates: ", GothicBold_Font_Normal_Black_Eight))>
	<cfset document.add(phrase.init(dateFormat(thisTag.stPDFIntroInfo.contract_start_date, 'mmmm dd, yyyy') & " to " &  dateFormat(thisTag.stPDFIntroInfo.contract_end_date, 'mmmm dd, yyyy') & chr(13) & chr(10), GothicBold_Font_Bold_Black_Eight))>

	<!--- Add Program Volume --->
	<cfset document.add(phrase.init("Program Volume: ", GothicBold_Font_Normal_Black_Eight))>
	<cfset document.add(phrase.init(thisTag.stPDFIntroInfo.total_program_value & chr(13) & chr(10) & chr(13) & chr(10) & chr(13) & chr(10), GothicBold_Font_Bold_Black_Eight))>

	<!--- Dev Note: Milan (27514). Comment out RSP info. It is not longer needed. --->
	<!--- Add Responsible Sales Person --->
	<!---
	<cfset document.add(phrase.init("Responsible Sales Person: ", GothicBold_Font_Normal_Black_Eight))>
	<cfset document.add(phrase.init(thisTag.stPDFIntroInfo.responsible_sales_person_first_name & ' ' & thisTag.stPDFIntroInfo.responsible_sales_person_last_name, GothicBold_Font_Bold_Black_Eight))>
	 --->
	
	<!--- Add Responsible Sales Person Title --->
	<!---
	<cfset document.add(phrase.init("(" & thisTag.stPDFIntroInfo.responsible_sales_person_title & ")" & chr(13) & chr(10), GothicBold_Font_Italic_Black_Eight))>
	--->

	<!--- Add Responsible Sales Person Phone --->
	<!---
	<cfset document.add(phrase.init(thisTag.stPDFIntroInfo.responsible_sales_person_phone & ' ', GothicBold_Font_Normal_Black_Eight))>
	--->

	<!--- Add Responsible Sales Person Email --->
	<!---
	<cfset RSP_EMail = chunk.init(lCase(thisTag.stPDFIntroInfo.responsible_sales_person_email) & chr(13) & chr(10) & chr(13) & chr(10),GothicBold_Font_Normal_Blue_Eight)>  
	<cfset RSP_EMail.setAnchor("mailto:#trim(thisTag.stPDFIntroInfo.responsible_sales_person_email)#")>
	<cfset document.add(phrase.init(RSP_EMail))>
	--->


	<!--- Set the length of the array as big as the number of columns in the table (3) --->
	<cfset jArr = arrObj.newInstance(jClass, 3)> 

	<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
				will be used as the width of the columns in the tableHeaderOperator table.
	--->
	
	<cfset arrObj.setInt(jArr, 0, 33)>  
	<cfset arrObj.setInt(jArr, 1, 33)> 
	<cfset arrObj.setInt(jArr, 2, 33)> 
	

	<!--- Set the width of the Operator table --->
	<cfset tableHeaderOperator.setWidths(jArr)>

    <!--- operator [begin] --->
    
    <!--- IF we a operator list OR are perhaps working with a letter BY operator... [begin] --->
		<!--- set gross to incoming... --->
    <cfset thisTag.qProgramOperatorGross = thisTag.qProgramOperator>
    <!--- Let's compare our incoming XML Operator List to our Operator Query --->
    <cfset thisTag.lsOperatorIDs = trim(thisTag.lsOperatorIDs)>
    <!--- If THIS letter is per operator... --->
    <cfif listLen(thisTag.lsOperatorIDs,",") EQ 1>
      <cfquery name="thisTag.qProgramOperator" datasource="#application.datasource#">
        SELECT 	*
        FROM 		##TMP_qProgramOperatorInfo
        WHERE		operator_id IN (#thisTag.lsOperatorIDs#)
      </cfquery>
    <!--- otherwise the length of the list should equal the length of the query per our business rules, but we won't ask on purpose... --->  
    <cfelse>
      <cfset thisTag.qProgramOperator = thisTag.qProgramOperatorGross>
    </cfif>
    <!--- IF we a operator list OR are perhaps working with a letter BY operator... [end] --->

	
	<!--- Get Operator Heading --->
	<cfif thisTag.qProgramOperator.recordCount>
		<cfset Operator_Header = PdfPCell.init(phrase.init("Eligible Operators", GothicBold_Font_Bold_Brown_Nine))>
		<cfset Operator_Header.setColspan( javacast("int", 3) )>
		<cfset Operator_Header.setBorder(Rectangle.NO_BORDER)>
		<!---<cfset tableHeaderOperator.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
		<cfset tableHeaderOperator.addCell(Operator_Header)>
	</cfif>

	<!--- Get Operator Data --->
 <cfloop query="thisTag.qProgramOperator">
		<cfset operator_Desc = thisTag.qProgramOperator.operator_name>

		<cfif len(trim(thisTag.qProgramOperator.Legacy_ID))>
			<cfset operator_Desc = operator_Desc & ' ' & "[" & thisTag.qProgramOperator.legacy_id & "]">
		<cfelse>
			<cfset operator_Desc = operator_Desc & ' ' & "[" & thisTag.qProgramOperator.operator_id & "]">
		</cfif>

		<cfif len(trim(thisTag.qProgramOperator.operator_address))>
			<cfset operator_Desc = operator_Desc & chr(13) & chr(10) & thisTag.qProgramOperator.operator_address>
		</cfif>

		<cfset operator_Desc = operator_Desc & chr(13) & chr(10) & thisTag.qProgramOperator.operator_city & ", " & thisTag.qProgramOperator.operator_state>

		<cfif len(trim(thisTag.qProgramOperator.operator_zip))>
			<cfset operator_Desc = operator_Desc  & " - " & thisTag.qProgramOperator.operator_zip>
		</cfif>
 
		<cfset Operator_Description = PdfPCell.init(phrase.init(operator_Desc, GothicNormal_font_Bold_Black_Eight))>

		<cfset Operator_Description.setColspan( javacast("int", 1) )>

		<!--- If its the last query record --->
		<cfif thisTag.qProgramOperator.currentrow eq thisTag.qProgramOperator.recordcount>
		<!--- In Itext, when we use Colspan, we need to specify use all the columns in the table (In this case 3), else
		there will be no output.
		--->
		<!--- If the last row of display has only one record, then the colspan will be 3 --->
			<cfif thisTag.qProgramOperator.currentrow MOD 3 EQ 1>
					<cfset Operator_Description.setColspan( javacast("int", 3) )>

		<!--- If the last row of display has 2 records, then the colspan will be 2 --->
			<cfelseif thisTag.qProgramOperator.currentrow MOD 3 EQ 2>
					<cfset Operator_Description.setColspan( javacast("int", 2) )>
			</cfif>	
		</cfif>

					<cfset Operator_Description.setBorder(Rectangle.NO_BORDER)> 
					<cfset tableHeaderOperator.addCell(Operator_Description)>

 </cfloop>

	<!--- Add the Operator table to the pdf file --->
	<cfset document.add(tableHeaderOperator)>

    <!--- operator [end] --->



 <!--- distributor [begin] --->
 <!--- If it is a "operator" letter and the Operator section has "No distributors" selected, then do not include the "Distributor section" --->
 <cfif (thisTag.abbreviation eq "opr" AND attributes.qGetLetterSettings.opr_Letter_settings eq 3) eq 0>

	<!--- Set the length of the array as big as the number of columns in the table (3) --->
	<cfset jArr = arrObj.newInstance(jClass, 3)> 
	
	<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
	will be used as the width of the columns in the tableHeaderDistributor table.
	--->
	<cfset arrObj.setInt(jArr, 0, 33)>  
	<cfset arrObj.setInt(jArr, 1, 33)> 
	<cfset arrObj.setInt(jArr, 2, 33)> 
			
	<!--- Set the width of the Distributor table to be he same as the width of the Operator table --->
	<cfset tableHeaderDistributor.setWidths(jArr)>
  
  	<!--- Do we wish to display the Warehouses? [begin] IF Freight_Component_Type[1] NEQ 0 display whs IF Freight_Component_Type[1] EQ 1 display Frt Bkt --->
  	<cfset useLakebaseForthisTag_qGetFreightComponentType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForthisTag_qGetFreightComponentType>
	<cftry>
		<cfset thisTag.qGetFreightComponentType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main_aux_data", {
				"contract_main_id" = "eq.#thisTag.CMID#",
				"select" = "freight_component_type"
			}), "freight_component_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForthisTag_qGetFreightComponentType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForthisTag_qGetFreightComponentType>
<cfquery name="thisTag.qGetFreightComponentType" datasource="#application.datasource#">
      SELECT	Contract_main_Aux_Data.Freight_Component_Type
      FROM		Contract_main_Aux_Data
      WHERE		Contract_main_Aux_Data.Contract_Main_ID = #thisTag.CMID#
		</cfquery>
</cfif>
    <!--- Do we wish to display the Frt Bkts? [end] IF Freight_Component_Type[1] NEQ 0 display whs IF Freight_Component_Type[1] EQ 1 display Frt Bkt --->
  
  	<!--- IF we a distributor list OR are perhaps working with a letter BY distributor... [begin] --->
		<!--- set gross to incoming... --->
    <cfset thisTag.qProgramDistributorGross = thisTag.qProgramDistributor>

    <!--- Let's compare our incoming XML Distributor List to our Distributor Query --->
    <cfset thisTag.lsDistributorIDs = trim(thisTag.lsDistributorIDs)>
    <!--- If THIS letter is per distributor... --->
    <cfif listLen(thisTag.lsDistributorIDs,",") EQ 1>
      <cfquery name="thisTag.qProgramDistributor"  datasource="#application.datasource#">
        SELECT 	*
        FROM 		##TMP_qProgramAllDistributorInfo
        WHERE		contract_distributors_id IN (#thisTag.lsDistributorIDs#)
        ORDER BY Name
      </cfquery>
    <!--- otherwise the length of the list should equal the length of the query per our business rules, but we won't ask on purpose... --->  
    <cfelse>
      <cfset thisTag.qProgramDistributor = thisTag.qProgramDistributorGross>
    </cfif>
    <!--- IF we a distributor list OR are perhaps workign with a letter BY distributor... [end] --->

		<!--- Add Distributor --->
    <cfif thisTag.qProgramDistributor.recordCount>
				<cfset document.add(chunk.init(chr(13) & chr(10)))>
				<cfset Distributor_Header = PdfPCell.init(phrase.init("Eligible Distributors", GothicBold_Font_Bold_Brown_Nine))>
				<cfset Distributor_Header.setColspan( javacast("int", 3) )>
				<cfset Distributor_Header.setBorder(Rectangle.NO_BORDER)>
				<!---<cfset tableHeaderDistributor.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
				<cfset tableHeaderDistributor.addCell(Distributor_Header)>
    </cfif>
<cfloop query="thisTag.qProgramDistributor">
	<cfset Distributor_Details = thisTag.qProgramDistributor.name & ' ' & "[" & thisTag.qProgramDistributor.shr_ship_to & "]">

	<cfif len(trim(thisTag.qProgramDistributor.address_1))>
		<cfset Distributor_Details = Distributor_Details & chr(13) & chr(10) & thisTag.qProgramDistributor.address_1>
	</cfif>

	<cfset Distributor_Details = Distributor_Details & chr(13) & chr(10) & thisTag.qProgramDistributor.city & ", " & thisTag.qProgramDistributor.state>

	<cfif len(trim(thisTag.qProgramDistributor.zipcode))>
		<cfset Distributor_Details = Distributor_Details & " - " & thisTag.qProgramDistributor.zipcode>
	</cfif>

	<cfif thisTag.qGetFreightComponentType.Freight_Component_Type[1]>
		<cfset Distributor_Details = Distributor_Details & chr(13) & chr(10)  & "Whse: " & thisTag.qProgramDistributor.warehouse_name & chr(13) & chr(10)  & thisTag.qProgramDistributor.warehouse_city>
	</cfif>

	<cfif thisTag.qGetFreightComponentType.Freight_Component_Type[1] EQ 1>
		<cfset Distributor_Details = Distributor_Details & chr(13) & chr(10)  & "Frt Brkt: " & thisTag.qProgramDistributor.freight_bracket_label>
	</cfif>

	<cfset Distributor_Description = PdfPCell.init(phrase.init(Distributor_Details, GothicNormal_font_Bold_Black_Eight))>

	<cfset Distributor_Description.setColspan( javacast("int", 1) )> 

		<!--- If its the last query record --->
		<cfif thisTag.qProgramDistributor.currentrow eq thisTag.qProgramDistributor.recordcount>
		<!--- In Itext, when we use Colspan, we need to specify use all the columns in the table (In this case 3), else
		there will be no output.
		--->
		<!--- If the last row of display has only one record, then the colspan will be 3 --->
			<cfif thisTag.qProgramDistributor.currentrow MOD 3 EQ 1>
					<cfset Distributor_Description.setColspan( javacast("int", 3) )>

		<!--- If the last row of display has 2 records, then the colspan will be 2 --->
			<cfelseif thisTag.qProgramDistributor.currentrow MOD 3 EQ 2>
					<cfset Distributor_Description.setColspan( javacast("int", 2) )>
			</cfif>	
		</cfif>

			<cfset Distributor_Description.setBorder(Rectangle.NO_BORDER)>
			<cfset tableHeaderDistributor.addCell(Distributor_Description)>
 </cfloop>

	<!--- Add the Distributor table to the pdf file --->
 	<cfset document.add(tableHeaderDistributor)>
</cfif>
	<!--- distributor [end] --->

<!--- notes [start] --->
<cfset IncludeNotes = 0>
<!--- If it is an "distributor" letter, check whether "Notes" is ON at the letter tab of the template --->
<cfif thisTag.abbreviation eq "dis" and attributes.stPDFBodyInfo.bDistributorNotes
OR
<!--- If it is an "operator" letter, check whether "Notes" is ON at the letter tab of the template --->
	  thisTag.abbreviation eq "opr" and attributes.stPDFBodyInfo.bOperatorNotes>
	<cfset IncludeNotes = 1>
</cfif>

<cfif IncludeNotes eq 1>
	<cfset document.add(chunk.init(chr(13) & chr(10)))>
	<cfset document.add(phrase.init("Notes", GothicBold_Font_Bold_Brown_Nine))>
	<cfset document.add(chunk.init(chr(13) & chr(10)))>
	<cfset document.add(phrase.init(thisTag.stPDFIntroInfo.program_notes, GothicNormal_font_Bold_Black_Eight))>
</cfif>
<!--- notes [end] --->

<!--- Freight Notes... [begin] --->
<cfif thisTag.stPDFBodyInfo.bTemplateAllowFreightLetters AND thisTag.bLetterDisplayFreight>
	<cfset document.add(chunk.init(chr(13) & chr(10)))>
	<cfset document.add(phrase.init("Freight Notes", GothicBold_Font_Bold_Brown_Nine))>
	<cfset document.add(chunk.init(chr(13) & chr(10)))>
	<cfif thisTag.stPDFIntroInfo.freight_notes NEQ "NULL">
		<cfset document.add(phrase.init(thisTag.stPDFIntroInfo.freight_notes, GothicNormal_font_Bold_Black_Eight))>
	</cfif>
</cfif>
<!--- Freight Notes... [end] --->