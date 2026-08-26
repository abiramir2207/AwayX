<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Settings/OCR_Settings_edit.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  28-Feb-17
Created By   :  Anand Rao
Description  :  Edit Existing OCR Setting
---------------------------------------------------------------------------------->
 
<style>
.Orangline
{
	border-right: 2px solid orange;
	width:400px;
}
</style>

<cfif isDefined("stError")>
	<cfset showSettingTemplateName = "Setting Template name" />
	<script>
		<cfoutput>		
		<cfif stError.bNameExists EQ 2>
			alert("#showSettingTemplateName# already exists with a different ID.");		
		<cfelseif stError.bNameExists EQ 3>
			alert("Another Template Setting exists with the same code.");
		</cfif>
		</cfoutput>
	</script>
</cfif>

<!--- Last edited info --->
<cfif isdefined("qGetOCRSettings.Updated_By") AND len(trim(qGetOCRSettings.Updated_By)) GT 0 >
	
	<cfquery name="GetUserLastEdited" datasource="#application.datasource#">
		SELECT Name_First + ' ' + Name_Last AS UserLastEdited
		FROM _Users
		WHERE User_ID = '#qGetOCRSettings.Updated_By#'
	</cfquery>
	<cfif GetUserLastEdited.Recordcount IS 1>
		<table id="lastUpdatedBy" bgcolor="White" style="border-color:Orange;border-style:solid;margin-top:10px;" cellpadding="3" cellspacing="0" align="center">
		<tr>
		<td align="center" width="400px" style="font-size:12px;">
			<B>Last updated on <cfoutput>#dateformat(qGetOCRSettings.Updated_Date, 'm/d/yyy')# #timeformat(qGetOCRSettings.Updated_Date, 'h:mm:ss TT')# by #GetUserLastEdited.UserLastEdited#</cfoutput></B></td>
		</td>
		</tr>
		</table>
	</cfif>
	<br>
</cfif>
<FIELDSET STYLE="padding:10px; width:800px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">OCR Template Setting</LEGEND>
	<table width="100%" border="0"   cellpadding="3" cellspacing="0">
		<!--- <colgroup>
		<col width="30%"></col>
		<col width="30%"></col>
		</colgroup> --->
		<cfoutput>
		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>OCR Template Setting Name:</B></td>
			<td width="50%"><input name="OCR_Template_Name" type="text" maxlength="500" value="#qGetOCRSettings.OCR_Template_Name#" style="width:300px"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>OCR File Landing Path:</B></td>
			<td width="50%"><input name="OCR_File_Landing_Path" type="text" maxlength="2000" value="#qGetOCRSettings.OCR_File_Landing_Path#" style="width:450px"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>OCR File Landing Path Processed:</B></td>
			<td width="50%"><input name="OCR_File_Landing_Path_Processed" type="text" maxlength="2000" value="#qGetOCRSettings.OCR_File_Landing_Path_Processed#" style="width:450px"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>OCR File PreProcess Path:</B></td>
			<td width="50%"><input name="OCR_File_PreProcess_Path" type="text" maxlength="2000" value="#qGetOCRSettings.OCR_File_PreProcess_Path#" style="width:450px"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>OCR File PostProcess Path:</B></td>
			<td width="50%"><input name="OCR_File_PostProcess_Path" type="text" maxlength="2000" value="#qGetOCRSettings.OCR_File_PostProcess_Path#" style="width:450px"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>OCR File PostProcess Txt Path:</B></td>
			<td width="50%"><input name="OCR_File_PostProcess_Txt_Path" type="text" maxlength="2000" value="#qGetOCRSettings.OCR_File_PostProcess_Txt_Path#" style="width:450px"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>DB File Preprocess Path:</B></td>
			<td width="50%"><input name="DB_File_Preprocess_Path" type="text" maxlength="2000" value="#qGetOCRSettings.DB_File_Preprocess_Path#" style="width:450px"></td>
		</tr>	
		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>DB OCR Root Path:</B></td>
			<td width="50%"><input name="DB_OCR_Root_Path" type="text" maxlength="2000" value="#qGetOCRSettings.DB_OCR_Root_Path#" style="width:450px"></td>
		</tr>			
		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>Image Path:</B></td>
			<td width="50%"><input name="OCR_Image_Path" type="text" maxlength="2000" value="#qGetOCRSettings.OCR_Image_Path#" style="width:450px"></td>
		</tr>	
		<tr>
			<td align="right" class="Orangline" width="50%" valign="top"><B>Image Hover Text:</B>
			 <CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>Enter a detailed description about the template, that will be displayed on Mouse over of the image</center>
				</CF_SmallHelp> 
			</td>
			<td width="50%"><textarea name="OCR_Image_Helptext" cols="75" rows="5" >#qGetOCRSettings.OCR_Image_Helptext#</textarea>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>OCR Reader:</B></td>
			<td width="50%">
				<select NAME="OCR_Reader_Name">
					<option value="" <cfif qGetOCRSettings.OCR_Reader_Name EQ "">selected</cfif>>Select OCR Reader</option> 
					<option value="ABBYY" <cfif qGetOCRSettings.OCR_Reader_Name EQ "ABBYY">selected</cfif>>ABBYY</option>
					<option value="DOCPARSER" <cfif qGetOCRSettings.OCR_Reader_Name EQ "DOCPARSER">selected</cfif>>DOCPARSER</option>
					<option value="EXCELCSV" <cfif qGetOCRSettings.OCR_Reader_Name EQ "EXCELCSV">selected</cfif>>EXCEL/CSV</option>
					<option value="EXCELCFPARSE" <cfif qGetOCRSettings.OCR_Reader_Name EQ "EXCELCFPARSE">selected</cfif>>EXCELCFPARSE</option>
					<option value="ABBYY&DOCPARSER" <cfif qGetOCRSettings.OCR_Reader_Name EQ "ABBYY&DOCPARSER">selected</cfif>>ABBYY &amp; DOCPARSER</option>
					<option value="DOCPARSER_ABBYY_DOCPARSER" <cfif qGetOCRSettings.OCR_Reader_Name EQ "DOCPARSER_ABBYY_DOCPARSER">selected</cfif>>DOCPARSER-ABBYY-DOCPARSER</option>
				</select>
			</td>
		</tr>			
		
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is OCR Required:</B></td>
			<td width="50%"><input name="IS_OCR_Required" type="checkbox"   value="1" <cfif qGetOCRSettings.IS_OCR_Required EQ "1">checked</cfif>></td>
		</tr>	
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is Double Processing On?</B></td>
			<td width="50%"><input name="Is_Double_Processing_On" type="checkbox"   value="1" <cfif qGetOCRSettings.Is_Double_Processing_On EQ "1">checked</cfif>></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is Triple Processing On?</B>
				<CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>When this is checked, the process goes through Docparser, Abbyy and Docparser again.</center>
				</CF_SmallHelp> 
			</td>
			<td width="50%"><input name="Special_Processing_Flag" type="checkbox"   value="1" <cfif qGetOCRSettings.Special_Processing_Flag EQ "1">checked</cfif>></td>
		</tr>					
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Account ID:</B>
				<CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>Account ID of the docparser. Leave it at default unless the Login credentials have changed for 'DOCPARSER'</center>
				</CF_SmallHelp> 
			</td>
			<td width="50%"><input name="Account_ID" type="text" maxlength="2000" value="#qGetOCRSettings.Account_ID#" style="width:300px"></td>
		</tr>					
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Parser ID:</B>
				<CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>Parser ID from the DocParser site. Only required when the OCR Reader is 'DOCPARSER'</center>
				</CF_SmallHelp> 
			</td>
			<td width="50%"><input name="Parser_ID" type="text" maxlength="2000" value="#qGetOCRSettings.Parser_ID#" style="width:200px"></td>
		</tr>	
		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>Source(Payee):</B></td>
			<td width="50%">
				<select NAME="BB_Claim_Source_XREF_ID">
					<option value="">Select a Source </option> 
					<cfloop query="qGetValidSources">
						<option value="#BB_Claim_Source_XREF_ID#" <cfif (qGetOCRSettings.BB_Claim_Source_XREF_ID EQ BB_Claim_Source_XREF_ID)>selected</cfif>>#Source_Code#</option>
	  				</cfloop>
				</select>
			</td>
		</tr>	
 		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>OCR Code:</B></td>
			<td width="50%"><input name="OCR_Code" type="text" maxlength="2000" value="#qGetOCRSettings.OCR_Code#" style="width:150px"></td>
		</tr>			
 		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>DB OCR Source Code:</B></td>
			<td width="50%"><input name="DB_OCR_Source_Code" type="text" maxlength="2000" value="#qGetOCRSettings.DB_OCR_Source_Code#" style="width:150px"></td>
		</tr>	
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Allowable File Extension:</B>
			<CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>Enter the String that will be accepted eg.: .pdf;.xlsx </center>
				</CF_SmallHelp> 
			</td>
			<td width="50%"><input name="Allowable_File_Ext" type="text" maxlength="2000" value="#qGetOCRSettings.Allowable_File_Ext#" style="width:100px"></td>
		</tr>	
		<tr>
			<td align="right" class="Orangline" width="50%" valign="top"><B>Search String:</B>
			 <CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>Enter the String as |(Pipe) delimited. Please make sure this will definitely be available in the uploaded document, as picking of the template is dependent on this value</center>
				</CF_SmallHelp> 
			</td>
			<td width="50%"><textarea name="Search_String" cols="75" rows="5" >#qGetOCRSettings.Search_String#</textarea>
			
			<!--- <input name="Search_String" type="text" maxlength="3000" value="#form.Search_String#" style="width:220px"> ---></td>
		</tr>	
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Template Search Order:</B></td>
			<td width="50%"><input name="Search_Order" type="text" maxlength="2000" value="#qGetOCRSettings.Search_Order#" style="width:50px"></td>
		</tr>	
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Template Rank Order:</B>
				<CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>The order of this field will determine the position of the template in the list, when shown to the user, in template selection.</center>
				</CF_SmallHelp> 
			</td>
			<td width="50%"><input name="Rank_Order" type="text" maxlength="2000" value="#qGetOCRSettings.Rank_Order#" style="width:50px"></td>
		</tr>			
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Customer Reference Prefix:</B></td>
			<td width="50%"><input name="Customer_Reference_Prefix" type="text" maxlength="500" value="#qGetOCRSettings.Customer_Reference_Prefix#" style="width:50px"></td>
		</tr>	
 		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is User Input Required:</B>
			<CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>The below checkbox fields will be ignored if this field is "OFF"</center>
				</CF_SmallHelp> </td>
			<td width="50%"><input name="OCR_User_Input_Required" type="checkbox"   value="1"<cfif qGetOCRSettings.OCR_User_Input_Required EQ "1">checked</cfif>>
			
			</td>
		</tr>	
		
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is Invoice Number & Amount Required:</B></td>
			<td width="50%"><input name="Invoice_Number_Amount_Required" type="checkbox"   value="1"<cfif qGetOCRSettings.Invoice_Number_Amount_Required EQ "1">checked</cfif>></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is Invoice Date Required:</B></td>
			<td width="50%"><input name="Invoice_Date_Required" type="checkbox"   value="1"<cfif qGetOCRSettings.Invoice_Date_Required EQ "1">checked</cfif>></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is Invoice Start Required:</B></td>
			<td width="50%"><input name="Invoice_Start_Date_Required" type="checkbox"   value="1"<cfif qGetOCRSettings.Invoice_Start_Date_Required EQ "1">checked</cfif>></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is Invoice End Required:</B></td>
			<td width="50%"><input name="Invoice_End_Date_Required" type="checkbox"   value="1"<cfif qGetOCRSettings.Invoice_End_Date_Required EQ "1">checked</cfif>></td>
		</tr>			
 
 		<tr>
			<td align="right" class="Orangline" width="50%" valign="top"><B>Description:</B>
			 <CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>Enter a detailed description about this setting and what format it uses etc.</center>
				</CF_SmallHelp> 
			</td>
			<td width="50%"><textarea name="OCR_Template_Description" cols="75" rows="5" >#qGetOCRSettings.OCR_Template_Description#</textarea>
		</tr>
		<input name="OCRTemplateSettingsID" type="hidden" value="#qGetOCRSettings.OCR_Template_Settings_ID#">
 
		 
		</cfoutput>
 
		<tr>
			<td COLSPAN="100%" align="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Update"
					button_action	=	"return editOCRSetting();"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</td>
		</tr>
	</table>
	
<font color="red">*</font> - Required	
<script>
	///////////////////////////////////   Update Component //////////////////////////////////////////
	function editOCRSetting()
	{
	
		var actionFrm = document.DataForm;
		var strErrorMsg  = "";
		 
		if (trim(actionFrm.OCR_Template_Name.value) == "")
		{
			strErrorMsg = "- Please provide a Template Setting name";
			// return;
		}
 
		if (trim(actionFrm.DB_OCR_Root_Path.value) == "")
		{
			strErrorMsg = strErrorMsg + (strErrorMsg ? "\n" : "") + "- Please provide a DB OCR Root Path";
		}
  
		if ( actionFrm.OCR_Reader_Name.selectedIndex == 0 )
		{
		    strErrorMsg = strErrorMsg + (strErrorMsg ? "\n" : "") + "- Select an OCR Reader";
		}
		
		if ( actionFrm.BB_Claim_Source_XREF_ID.selectedIndex == 0 )
		{
		    strErrorMsg = strErrorMsg + (strErrorMsg ? "\n" : "") + "- Select a Source(Payee)";
		}
		
		if (trim(actionFrm.DB_OCR_Source_Code.value) == "")
		{
			strErrorMsg = strErrorMsg + (strErrorMsg ? "\n" : "") + "- Please provide a DB OCR Source Code";
		}
		
		/* if (trim(actionFrm.Allowable_File_Ext.value) == "" || trim(actionFrm.Allowable_File_Ext.value) == ".pdf")
		{
			strErrorMsg = strErrorMsg + (strErrorMsg ? "\n" : "") + "- Please provide a Allowable File Extension";
		}
		*/
		
		if (strErrorMsg  !=  "")
		{
			alert('Please correct the below errors:\n\n' + strErrorMsg)
			return;
		}
 
		actionFrm.command.value = 'update';
//		actionFrm.display.value = actionFrm.returnTo.value;
		actionFrm.submit();
		// $("#msgSave").append("<p>Saving changes, please wait...</p>");
		return false;
	} 
	
	 
	</script>
	</FIELDSET>