<cfsilent>
<!---
       Name:          upload_file.cfm
       Copyright:     Copyright (c) 2013 Blacksmith Applications, Inc.       
       Created Date:  05/30/2013
       Created By:    Kal
       Label:		  34605
       Description:   Mass Price Change Utility
--->
</cfsilent>
<SCRIPT type="text/javascript">

	var submitClicked = 0;

	function distributorSearch()
	{
		
		NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?Formname=uploadFile&FieldName=Distributor_List&SelectSingleSearchResultOnly=0&AllowImportAll=1", "distributorwindow", 850, 600, "yes", "yes");
	}
	
	function searchPrograms()
	{
		var thisForm = document.all.uploadFile;

		// distributor is required before adding programs
		if(thisForm.Distributor_List.value.length == 0){
			alert('select at least one bill to before selecting a program');
			return false;
		}
		else
		{
			NewWindow("/billbacks/search_screens/search_programs.cfm?Formname=uploadFile&fieldname=Program_List&SelectSingleSearchResultOnly=0&AllowImportAll=1", "programswindow", 800, 600, "yes", "yes");
		}
	}
	
	function submitForm(submitter)
	{
		var thisForm = document.all.uploadFile;
		var errors = 0;
		var errorMsg = '';

		if($('input[name=Template_Select]:checked').length == 0){
			errors++;
			errorMsg = errorMsg + '\n' + 'select a template';
		}

		// uom - validation
		if(thisForm.uom.value.length == 0){
			errors++;
			errorMsg = errorMsg + '\n' + 'select a uom option';
		}

		// date field not empty
		if(thisForm.effectiveDate.value.length == 0){
			errors++;
			errorMsg = errorMsg + '\n' + 'select an effective date ';
		}

		// no file selected
		if(thisForm.upload_file.value.length == 0){
			errors++;
			errorMsg = errorMsg + '\n' + 'select a file to upload';
		}

		// no bill to selected
		if(thisForm.Distributor_List.value.length == 0){
			errors++;
			errorMsg = errorMsg + '\n' + 'select a bill to';
		}
		
		// no program selected
		if(thisForm.Program_List.value.length == 0){
			errors++;
			errorMsg = errorMsg + '\n' + 'select a program';
		}
		
		if(submitClicked == 0 && errors == 0){			
			submitClicked ++; 
			thisForm.submit();
		}
		else {
			if(!submitClicked){				
				alert(errorMsg);
				return false;
			}
		}
	}
</SCRIPT>

<cfparam name="bValidSpreadSheet" 		default="1" />
<cfparam name="spreadSheetError" 		default="" />
<cfparam name="form.Distributor_List" 	default="" />
<cfparam name="form.Program_List"		default="" />

<cfset  qMassPriceUoms = MPCManager.massPriceUoms() />

<cfquery name="qGetDistributors" datasource="#application.datasource#">
	SELECT 	Ship_To,Name
	FROM	BSA_Foodservice_Customers
	WHERE	<cfif listLen(form.Distributor_List)>BSA_Foodservice_Customers_ID IN (#ListQualify(form.Distributor_List, "'")#)<cfelse>1 = 0</cfif>
</cfquery>

<cfquery name="qGetPrograms" datasource="#application.datasource#">
	SELECT 	Contract_Number, Contract_Title
	FROM	Contract_Main
	WHERE	<cfif listLen(form.Program_List)>Contract_Main_ID IN (#ListQualify(form.Program_List, "'")#)<cfelse>1 = 0</cfif>
</cfquery>


<cfif isdefined("form.upload_file") AND len(form.upload_file)>
	<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
	<cfset uploadFilePath = uploadUtility.getUploadPath() />
	
	<cffile
		action="upload" result="uploadResult"
		filefield="upload_file"
		destination="#Application.Doc_Path#\Data_Files\Uploaded\programs"
		nameconflict="overwrite" />

	<cftry>
		<cfspreadsheet action="read" src="#uploadResult.serverDirectory#\#uploadResult.serverFile#"
					   sheet=1 headerrow="1" excludeheaderrow="true" query="qData">
		<cfcatch type="any">
			<cfscript>
				//make sure all the cols are there
				bValidSpreadSheet = 0;
				spreadSheetError = 'Could not parse file (#uploadResult.serverFile#).  <br>Be sure it is a valid Excel (.xls or .xlsx) file.';
				qData = queryNew('x');
			</cfscript>
		</cfcatch>
	</cftry>

	<!--- if a valid spreadsheet/excel --->
	<cfif bValidSpreadSheet>
		<cfscript>
			//make sure all the cols are there (if it is a valid file)
			keyArray = 	['PRODUCT_ID', 'RATE'];

			//loop the 'keys' and make sure the spreadsheet (qData)	has an entry for each one
			for (i=1;i LTE ArrayLen(keyArray);i=i+1) {
				if(!StructKeyExists(qData,keyArray[i])){
					bValidSpreadSheet = 0;
					if(spreadSheetError == ''){
						spreadSheetError = '  Missing Columns:';
					}
					spreadSheetError = spreadSheetError & '<li>' & keyArray[i];
				}
			}			
		</cfscript>
		<!--- loop over the spread sheet data [stored as a query] and insert into db --->
		<cfif bValidSpreadSheet>
			<!--- Clear existing Data from data holding tables  --->
			<cfset MPCManager.clearData() />

			<!--- insert tempalte data --->
			<cfset MPCManager.insertTemplateData(form.template_select) />
			
			<!--- insert distributor/bill to data --->
			<cfset MPCManager.insertDistributorData(form.Distributor_List) />
			
			<!--- insert program data --->
			<cfset MPCManager.insertProgramData(form.Program_List) />

			<!--- validate and insert product data --->
			<cfoutput query="qData">
				<cfscript>
					//Check for valid PRODUCT_ID
					validProduct = 0;
					validProduct = MPCManager.checkValidProduct(qData.PRODUCT_ID);

					if(!validProduct){
						//set invalid product display message here.
						spreadSheetError = spreadSheetError & '<li>' & qData.PRODUCT_ID & ' is not a valid product and removed from upload';
					}else{
						//insert into db, if rate is a number/decimal
						if(isNumeric(qData.RATE)){
							MPCManager.insertProductData(qData.PRODUCT_ID, qData.RATE, form.uom, form.effectiveDate);
						}
						else{
							spreadSheetError = spreadSheetError & '<li>' & qData.RATE & ' is not a valid number and removed from upload';
						}
					}										
				</cfscript>
			</cfoutput>

			<!--- set the update type and the user  --->
			<cfset MPCManager.setUpdateType(request.accessstructure.user_ID, 'revise')>

		</cfif> <!--- END: bValidSpreadSheet STEP 2  --->
	</cfif> <!--- END: bValidSpreadSheet  --->
</cfif> <!---END: isdefined("form.upload_file")  --->


<!--- when the form is locked by other user, we will replace the html in this div --->
<div id="uploadFileForm" class="buttonText">
	<div id="xlErrors"><cfoutput>#spreadSheetError#</cfoutput></div>
	<form id="uploadFile" name="uploadFile" method="post" action="index.cfm" enctype="multipart/form-data" class="buttonText">
		
		<!--- templates selection  --->
		<cfinclude template="/program_wizard/select_templates.cfm" /><br/>
		
		<!--- distributor selection  --->
		<cfset maxCols = 4 />
		<cfset tdWidth = 100/maxCols />
		<cfscript>
			Border="Yes";
			BorderSize=1;  
			BorderColor="orange";
			Image="/images/plus3.gif";
			ImageOpen="/images/minus3.gif";
			TitleColor="Blue"; 
			TitleFont="Arial";
			TitleSize=9;
			IsClosed="No";
		</cfscript>

		<cf_openlayer
			border="#Border#"							
			bordersize="#BorderSize#"  
			bordercolor="#BorderColor#"					
			image="#Image#"
			imageopen="#ImageOpen#"						
			title="Selected #application.returned_customer_setting.BillTo_Label#"  
			titleclosed="Selected #application.returned_customer_setting.BillTo_Label#"
			titletooltip="Click here to toggle view"  
			titlecolor="#TitleColor#"					
			titlefont="#TitleFont#"
			titlesize="#TitleSize#"						
			isclosed="#IsClosed#">	
		
		<CF_button
			button_name		=	""
			button_caption	=	"select #lcase(application.returned_customer_setting.BillTo_Label)#"
			button_action	=	"distributorSearch()"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			class			=	"NotMaintable"
		>
		<div id="distList" style="overflow-y:scroll;height:100px;">
		<table cellpadding="2" cellspacing="0" width="100%" border="0" align="center">
			<cfif qGetDistributors.recordCount>
				<tr bgcolor="FFCE8" style="height:20px">
					<td width="50%" style="border-bottom:1px solid ##93BEE2;">
						<strong><cfoutput>#application.returned_customer_setting.BillTo_Label# Name</cfoutput></strong>			
					</td>
					
					<td width="50%" style="border-bottom:1px solid ##93BEE2;">
						<strong><cfoutput>#application.returned_customer_setting.BillTo_Label#</cfoutput></strong>			
					</td>
				</tr>
				<cfoutput query="qGetDistributors">
					<tr>
						<td width="#tdWidth#%">
							#Name#
						</td>
						<td width="#tdWidth#%">
							#Ship_To#
						</td>
					</tr>
				</cfoutput>
			</cfif>
		</table>
		</div>
		
		</cf_openlayer>
		
		<input name="Distributor_List" type="hidden" value="<cfoutput>#form.Distributor_List#</cfoutput>" />
		<input name="ShowBillToSearchFields" type="hidden" value="1" />
		
		<br>
		<!--- program selection  --->
		<cfset maxCols = 4 />
		<cfset tdWidth = 100/maxCols />
		<cfscript>
			Border="Yes";
			BorderSize=1;  
			BorderColor="orange";
			Image="/images/plus3.gif";
			ImageOpen="/images/minus3.gif";
			TitleColor="Blue"; 
			TitleFont="Arial";
			TitleSize=9;
			IsClosed="No";
		</cfscript>

		<cf_openlayer
			border="#Border#"							
			bordersize="#BorderSize#"  
			bordercolor="#BorderColor#"					
			image="#Image#"
			imageopen="#ImageOpen#"						
			title="Selected Programs"  
			titleclosed="Selected Programs"
			titletooltip="Click here to toggle view"  
			titlecolor="#TitleColor#"					
			titlefont="#TitleFont#"
			titlesize="#TitleSize#"						
			isclosed="#IsClosed#">	
		
		<CF_button
			button_name		=	""
			button_caption	=	"select program"
			button_action	=	"searchPrograms()"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			class			=	"NotMaintable"
		>
		<div id="prgList" style="overflow-y:scroll;height:100px;">
		<table cellpadding="2" cellspacing="0" width="100%" border="0" align="center">
			<cfif qGetPrograms.recordCount>
				<tr bgcolor="FFCE8" style="height:20px">
					<td width="50%" style="border-bottom:1px solid ##93BEE2;">
						<strong>Number</strong>			
					</td>
					
					<td width="50%" style="border-bottom:1px solid ##93BEE2;">
						<strong>Title</strong>			
					</td>
				</tr>
				<cfoutput query="qGetPrograms">
					<tr>
						<td width="#tdWidth#%">
							#Contract_Number#
						</td>
						<td width="#tdWidth#%">
							#Contract_Title#
						</td>
					</tr>
				</cfoutput>
			</cfif>
		</table>
		</div>
		
		</cf_openlayer>
		
		<input name="Program_List" type="hidden" id="Program_List" value="<cfoutput>#form.Program_List#</cfoutput>" />
		<input name="FilterType" type="hidden" value="1" />
		<input name="FilterSearchPrograms" type="hidden" value="0" />
		<input name="FilterDataList" type="hidden" value="<cfoutput>#form.Distributor_List#</cfoutput>"  />
		
		
		<!--- upload file --->
		<table cellpadding="2" cellspacing="2" border="0">
			<tr>
				<td class="buttonText">UOM:</td>
				<td>
					 <select id="uom" name="uom">  
						<option value="">select</option>
					 	<cfoutput query="qMassPriceUoms">
							<option value="#Unit_Of_Measure_ID#">#Abbreviation_Singular#</option>							
					 	</cfoutput>
					</select>
				</td>
				<td class="buttonText">Effective Date:</td>
				<!--- <td class="buttonText"> <input type="text" id="datepicker"/> </td> --->
				<td class="buttonText"> <cf_easydate FormName="uploadFile" FieldName="effectiveDate" id="effectiveDate" Format="mm/dd/yyyy"> </td>
			</tr>
			<tr>
				<td class="buttonText" colspan="5">
					<br/>
					Upload File: &nbsp; &nbsp; <input type="file" id="upload_file" name="upload_file"  size="80">
					<br>
				</td>
			</tr>
		</table>
		
		<br/>
		<div align="center" width="80" class="buttonText">
			<cfoutput>				
				<span class="redBracket">[</span><a href="##" id="submitLink" onclick="javascript:submitForm(this); return false;">submit</a><span class="redBracket">]</span>
			</cfoutput>
		</div>

	</form>
</div>
