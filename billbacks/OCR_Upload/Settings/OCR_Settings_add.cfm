<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Settings/OCR_Settings_add.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  28-Feb-17
Created By   :  Anand Rao
Description  :  Add a new OCR Setting
---------------------------------------------------------------------------------->

<cfif isDefined("stError")>
	<cfset showSettingTemplateName = "Setting Template name" />
	<!--- <cfif form.rebate_type EQ 2>
		<cfset showCompTypeName = "PP Increase Rebate Component" />
	</cfif> --->
	<script>
	<cfoutput>		
	<cfif stError.bNameExists EQ 1>
		alert("#showSettingTemplateName# already exists!!");		
	</cfif>
	</cfoutput>
	</script>
</cfif>
<style>
.Orangline
{
	border-right: 2px solid orange;
	width:400px;
}
</style>
 
<FIELDSET STYLE="padding:10px; width:800px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">OCR Template Setting</LEGEND>
	<table width="100%" border="0"   cellpadding="3" cellspacing="0">
		<cfoutput>
		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>OCR Template Setting Name:</B></td>
			<td width="50%"><input name="OCR_Template_Name" type="text" maxlength="500" value="#form.OCR_Template_Name#" style="width:300px"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>OCR File Landing Path:</B></td>
			<td width="50%"><input name="OCR_File_Landing_Path" type="text" maxlength="2000" value="#form.OCR_File_Landing_Path#" style="width:450px"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>OCR File Landing Path Processed:</B></td>
			<td width="50%"><input name="OCR_File_Landing_Path_Processed" type="text" maxlength="2000" value="#form.OCR_File_Landing_Path_Processed#" style="width:450px"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>OCR File PreProcess Path:</B></td>
			<td width="50%"><input name="OCR_File_PreProcess_Path" type="text" maxlength="2000" value="#form.OCR_File_PreProcess_Path#" style="width:450px"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>OCR File PostProcess Path:</B></td>
			<td width="50%"><input name="OCR_File_PostProcess_Path" type="text" maxlength="2000" value="#form.OCR_File_PostProcess_Path#" style="width:450px"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>OCR File PostProcess Txt Path:</B></td>
			<td width="50%"><input name="OCR_File_PostProcess_Txt_Path" type="text" maxlength="2000" value="#form.OCR_File_PostProcess_Txt_Path#" style="width:450px"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>DB File Preprocess Path:</B>
			<CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>If 'DOCPARSER' is picked as the type in 'OCR Reader' this field will be automatically reset to blank</center>
				</CF_SmallHelp> 
				</td>
			<td width="50%"><input name="DB_File_Preprocess_Path" type="text" maxlength="2000" value="#form.DB_File_Preprocess_Path#" style="width:450px"></td>
		</tr>	
		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>DB OCR Root Path:</B></td>
			<td width="50%"><input name="DB_OCR_Root_Path" type="text" maxlength="2000" value="#form.DB_OCR_Root_Path#" style="width:450px"></td>
		</tr>			
		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>Image Path:</B></td>
			<td width="50%"><input name="OCR_Image_Path" type="text" maxlength="2000" value="#form.OCR_Image_Path#" style="width:450px"></td>
		</tr>	
		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>Image Hover Help:</B></td>
			<td width="50%"><textarea name="OCR_Image_Helptext" cols="75" rows="5" >#form.OCR_Template_Description#</textarea>
		</tr>			
		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>OCR Reader:</B></td>
			<td width="50%">
				<select NAME="OCR_Reader_Name">
					<option value="">Select OCR Reader</option> 
					<option value="ABBYY">ABBYY</option>
					<option value="DOCPARSER">DOCPARSER</option>
					<option value="EXCELCSV">EXCEL/CSV</option>
					<option value="EXCELCFPARSE">EXCELCFPARSE</option>
					<option value="ABBYY&DOCPARSER">ABBYY &amp; DOCPARSER</option>
					<option value="DOCPARSER_ABBYY_DOCPARSER">DOCPARSER-ABBYY-DOCPARSER</option>
				</select>
			</td>
		</tr>			
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is OCR Required:</B></td>
			<td width="50%"><input name="IS_OCR_Required" type="checkbox"   value="#form.IS_OCR_Required#"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is Double Processing On?</B></td>
			<td width="50%"><input name="Is_Double_Processing_On" type="checkbox"   value="1"></td>
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
			<td width="50%"><input name="Special_Processing_Flag" type="checkbox"   value="1"></td>
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
				</CF_SmallHelp> </td>
			<td width="50%"><input name="Account_ID" type="text" maxlength="2000" value="#form.Account_ID#" style="width:300px"></td>
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
				</CF_SmallHelp> </td>
			<td width="50%"><input name="Parser_ID" type="text" maxlength="2000" value="#form.Parser_ID#" style="width:200px"></td>
		</tr>	
		
		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>Source(Payee):</B></td>
			<td width="50%">
				<select NAME="BB_Claim_Source_XREF_ID">
					<option value="">Select a Source </option> 
					<cfloop query="qGetValidSources">
						<option value="#BB_Claim_Source_XREF_ID#">#Source_Code#</option>
	  				</cfloop>
				</select>
			</td>
		</tr>	
 		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>OCR Code:</B></td>
			<td width="50%"><input name="OCR_Code" type="text" maxlength="2000" value="#form.OCR_Code#" style="width:150px"></td>
		</tr>			
 		<tr>
			<td align="right" class="Orangline" width="50%"><B><font color="red" size="2">*</font>DB OCR Source Code:</B></td>
			<td width="50%"><input name="DB_OCR_Source_Code" type="text" maxlength="2000" value="#form.DB_OCR_Source_Code#" style="width:150px"></td>
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
			<td width="50%"><input name="Allowable_File_Ext" type="text" maxlength="2000" value="#form.Allowable_File_Ext#" style="width:100px"></td>
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
			<td width="50%"><textarea name="Search_String" cols="75" rows="5" >#form.Search_String#</textarea>
			
			<!--- <input name="Search_String" type="text" maxlength="3000" value="#form.Search_String#" style="width:220px"> ---></td>
		</tr>	
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Template Search Order:</B></td>
			<td width="50%"><input name="Search_Order" type="text" maxlength="2000" value="#form.Search_Order#" style="width:50px"></td>
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
			<td width="50%"><input name="Rank_Order" type="text" maxlength="2000" value="#form.Rank_Order#" style="width:50px"></td>
		</tr>			
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Customer Reference Prefix:</B></td>
			<td width="50%"><input name="Customer_Reference_Prefix" type="text" maxlength="500" value="#form.Customer_Reference_Prefix#" style="width:50px"></td>
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
				</CF_SmallHelp> 
			</td>
			<td width="50%"><input name="OCR_User_Input_Required" type="checkbox"   value="1"></td>
		</tr>	
		
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is Invoice Number & Amount Required:</B></td>
			<td width="50%"><input name="Invoice_Number_Amount_Required" type="checkbox"   value="1"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is Invoice Date Required:</B></td>
			<td width="50%"><input name="Invoice_Date_Required" type="checkbox"   value="1"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is Invoice Start Required:</B></td>
			<td width="50%"><input name="Invoice_Start_Date_Required" type="checkbox"   value="1"></td>
		</tr>
		<tr>
			<td align="right" class="Orangline" width="50%"><B>Is Invoice End Required:</B></td>
			<td width="50%"><input name="Invoice_End_Date_Required" type="checkbox"   value="1"></td>
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
			<td width="50%"><textarea name="OCR_Template_Description" cols="75" rows="5" >#form.OCR_Template_Description#</textarea>
		</tr>
		
		<input type="hidden" name="Component_ID" value="">
		<input name="GLList" type="hidden" value="">
		<input name="ExistingGLList" type="hidden" value="">
 		 
		</cfoutput>
 
		<tr>
			<td colspan="100%" align="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Add"
					button_action	=	"return addOCRSetting();"
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
	
	function addOCRSetting()
	{
	
		var actionFrm = document.DataForm;
		var strErrorMsg  = "";
		
		if (trim(actionFrm.OCR_Template_Name.value) == "")
		{
			strErrorMsg = "- Please provide a Template Setting name";
			// return false;
		}
		 
		if (trim(actionFrm.DB_OCR_Root_Path.value) == "")
		{
			strErrorMsg = strErrorMsg + (strErrorMsg ? "\n" : "") + "- Please provide a DB OCR Root Path";
			// return;
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
 
		//set hidden form fields and submit
		actionFrm.command.value = 'addOCRSetting';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		$("#msgSave").append("<p>Saving changes, please wait...</p>");
		return false;	
	
	}
	
 
	</script>
</FIELDSET>