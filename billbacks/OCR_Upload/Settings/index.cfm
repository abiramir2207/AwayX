<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Settings/index.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  28-Feb-17
Created By   :  Anand Rao
Description  :  Redirects to the Upload Payables page from the status page.
---------------------------------------------------------------------------------->

<cfsilent>
<cfparam NAME="url.display" 	DEFAULT="active">
<cfparam NAME="form.display" 	DEFAULT="#url.display#">
<cfparam NAME="form.command" 	DEFAULT="">
<cfparam NAME="form.returnTo" 	DEFAULT="">
<cfparam NAME="form.editMode" 	DEFAULT="0">

<cfparam name="form.OCR_Template_Name" 				default="">
<cfparam name="form.OCR_File_Landing_Path" 			default="">
<cfparam name="form.OCR_File_Landing_Path_Processed" default="">
<cfparam name="form.OCR_File_PreProcess_Path" 		default="">
<cfparam name="form.OCR_File_PostProcess_Path" 		default="">
<cfparam name="form.OCR_File_PostProcess_Txt_Path" 	default="">
<cfparam name="form.DB_File_Preprocess_Path" 		default="">
<cfparam name="form.Search_String" 					default="">
<cfparam name="form.Allowable_File_Ext" 			default=".pdf">
<cfparam name="form.BB_Claim_Source_XREF_ID"		default="">
<cfparam name="form.Search_Order"					default="">
<cfparam name="form.DB_OCR_Root_Path"				default="">
<cfparam name="form.DB_OCR_Source_Code"				default="">
<cfparam name="form.IS_OCR_Required"				default="0">
<cfparam name="form.Customer_Reference_Prefix"		default="">
<cfparam name="form.OCR_Reader_Name"				default="">
<cfparam name="form.Parser_ID"						default="">
<cfparam name="form.Account_ID"						default="da6152df5175257d3a7d8ff428d1a10aebc6213f">
<cfparam name="form.OCR_Code"						default="">

<cfparam name="form.OCR_Image_Path"					default="">
<cfparam name="form.OCR_User_Input_Required"		default="">
<cfparam name="form.Invoice_Number_Amount_Required"	default="">
<cfparam name="form.Invoice_Date_Required"			default="">
<cfparam name="form.Invoice_Start_Date_Required"	default="">
<cfparam name="form.Invoice_End_Date_Required"		default="">
<cfparam name="form.OCR_Template_Description"		default="">
<cfparam name="form.Allowed_Invoice_Rows_Count"		default="">
<cfparam name="form.OCR_Image_Helptext"				default="">
<cfparam name="form.Rank_Order"						default="">
<cfparam name="form.Is_Double_Processing_On"		default="">
<cfparam name="form.Special_Processing_Flag"		default="">

<cfset selectedIndex = 99>
<cfswitch expression="#form.display#">
	<cfcase value="active">    <cfset selectedIndex = 0> 	</cfcase>
	<cfcase value="inActive">  <cfset selectedIndex = 1> 	</cfcase>
	<cfcase value="add">       <cfset selectedIndex = 2> 	</cfcase>
	<cfcase value="edit">      <cfset selectedIndex = 3> 	</cfcase>
</cfswitch>
</cfsilent>
  
<cfmodule template="/customTags/layout.cfm"
							layoutID = "OCR_Upload"
							selectedIndex = "#selectedIndex#" >
 

<cfmodule template="/customTags/include.cfm" file_to_include="/Common_Files/Delete_Functions.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/string_functions.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dom_common.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="OCR_Settings.js"/>

<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template ="/actionformat.cfm">
<script>
	function toggle(type, id) 
	{
		if(type=='show')
		{
			$('.' + id).show();
		}
		if(type=='hide')
		{
				$('.' + id).hide();
		}
	}
</script>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfscript>
	OCRSettingsManager  = CreateObject("component","components.Billback.OCRUploadSettingsManager");
	qGetValidSources		= OCRSettingsManager.getValidSources();
</cfscript>

<cfif form.command eq "addOCRSetting">

	<cfscript>
		stError = StructNew();
		stError.bNameExists = 0;
		stError.bNameExists = OCRSettingsManager.insUpdOCRSettings(
				OCR_Action							= form.command
				,OCRTemplateSettingsID 				= ""
				,OCR_Template_Name					= form.OCR_Template_Name
				,OCR_File_Landing_Path 				= form.OCR_File_Landing_Path
				,OCR_File_Landing_Path_Processed	= form.OCR_File_Landing_Path_Processed
				,OCR_File_PreProcess_Path			= form.OCR_File_PreProcess_Path
				,OCR_File_PostProcess_Path			= form.OCR_File_PostProcess_Path
				,OCR_File_PostProcess_Txt_Path		= form.OCR_File_PostProcess_Txt_Path
				,DB_File_Preprocess_Path			= form.DB_File_Preprocess_Path
				,Search_String						= form.Search_String
				,Allowable_File_Ext					= form.Allowable_File_Ext
				,BB_Claim_Source_XREF_ID			= form.BB_Claim_Source_XREF_ID
				,Search_Order						= form.Search_Order
				,DB_OCR_Root_Path					= form.DB_OCR_Root_Path
				,DB_OCR_Source_Code					= form.DB_OCR_Source_Code
				,IS_OCR_Required					= form.IS_OCR_Required
				,Customer_Reference_Prefix			= form.Customer_Reference_Prefix
				,OCR_Reader_Name					= form.OCR_Reader_Name
				,Parser_ID							= form.Parser_ID
				
	 			,Account_ID							= form.Account_ID
	            ,OCR_Code							= form.OCR_Code
	            ,OCR_Image_Path						= form.OCR_Image_Path
			    ,OCR_User_Input_Required			= form.OCR_User_Input_Required
	            ,Invoice_Number_Amount_Required		= form.Invoice_Number_Amount_Required
	            ,Invoice_Date_Required				= form.Invoice_Date_Required
	            ,Invoice_Start_Date_Required		= form.Invoice_Start_Date_Required
	            ,Invoice_End_Date_Required			= form.Invoice_End_Date_Required
	            ,OCR_Template_Description			= form.OCR_Template_Description
	            ,Allowed_Invoice_Rows_Count			= form.Allowed_Invoice_Rows_Count
				,OCR_Image_Helptext					= form.OCR_Image_Helptext
				,Rank_Order							= form.Rank_Order
				,Is_Double_Processing_On			= form.Is_Double_Processing_On
				,Special_Processing_Flag			= form.Special_Processing_Flag
				);
		if(stError.bNameExists EQ 1)
		{
			form.display = "add";
		}
		else
		{
			form.display = "active";
		}
	</cfscript>
	<cfif stError.bNameExists EQ 0>
		<cfoutput><p align="center" style="color:##ff0000;font-weight:bold;">New template setting "#form.OCR_Template_Name#" was added!</p></cfoutput>
	</cfif>
<cfelseif form.command eq "update">
	<cfscript>
		stError = StructNew();
		stError.bNameExists = 0;
		stError.bNameExists = OCRSettingsManager.insUpdOCRSettings(
				OCR_Action							= form.Command
				,OCRTemplateSettingsID 				= form.OCRTemplateSettingsID
				,OCR_Template_Name					= form.OCR_Template_Name
				,OCR_File_Landing_Path 				= form.OCR_File_Landing_Path
				,OCR_File_Landing_Path_Processed	= form.OCR_File_Landing_Path_Processed
				,OCR_File_PreProcess_Path			= form.OCR_File_PreProcess_Path
				,OCR_File_PostProcess_Path			= form.OCR_File_PostProcess_Path
				,OCR_File_PostProcess_Txt_Path		= form.OCR_File_PostProcess_Txt_Path
				,DB_File_Preprocess_Path			= form.DB_File_Preprocess_Path
				,Search_String						= form.Search_String
				,Allowable_File_Ext					= form.Allowable_File_Ext
				,BB_Claim_Source_XREF_ID			= form.BB_Claim_Source_XREF_ID
				,Search_Order						= form.Search_Order
				,DB_OCR_Root_Path					= form.DB_OCR_Root_Path
				,DB_OCR_Source_Code					= form.DB_OCR_Source_Code
				,IS_OCR_Required					= form.IS_OCR_Required
				,Customer_Reference_Prefix			= form.Customer_Reference_Prefix
				,OCR_Reader_Name					= form.OCR_Reader_Name
				,Parser_ID							= form.Parser_ID
				,Account_ID							= form.Account_ID
	            ,OCR_Code							= form.OCR_Code
	            ,OCR_Image_Path						= form.OCR_Image_Path
			    ,OCR_User_Input_Required			= form.OCR_User_Input_Required
	            ,Invoice_Number_Amount_Required		= form.Invoice_Number_Amount_Required
	            ,Invoice_Date_Required				= form.Invoice_Date_Required
	            ,Invoice_Start_Date_Required		= form.Invoice_Start_Date_Required
	            ,Invoice_End_Date_Required			= form.Invoice_End_Date_Required
	            ,OCR_Template_Description			= form.OCR_Template_Description
	            ,Allowed_Invoice_Rows_Count			= form.Allowed_Invoice_Rows_Count
				,OCR_Image_Helptext					= form.OCR_Image_Helptext
				,Rank_Order							= form.Rank_Order
				,Is_Double_Processing_On			= form.Is_Double_Processing_On
				,Special_Processing_Flag			= form.Special_Processing_Flag
				);
		if (stError.bNameExists)
		{
			form.display = "edit";
		}
		else
		{
			form.display = "active";
		}
	</cfscript>
	<cfif stError.bNameExists EQ 0>
		<cfoutput><p align="center" style="font-weight:bold;color:##ff0000;">Template setting "#form.OCR_Template_Name#" was updated!</p></cfoutput>
	</cfif>
<!---/////////////DEACTIVATE SELECTED ///////////--->
<cfelseif form.command eq "deactSel">

	<cfscript>
		OCRSettingsManager.deactivateOCRSettings(form.CID);
	</cfscript>

<!---/////////////DEACTIVATE SINGLE SELECTED ///////////--->
<cfelseif form.command eq "deact">
	<cfscript>
		OCRSettingsManager.deactivateOCRSettings(form.OCRTemplateSettingsID);
	</cfscript>

<!---/////////////ACTIVATE SELECTED ///////////--->
<cfelseif form.command eq "actSel">
	<cfscript>
		OCRSettingsManager.activateOCRSettings(form.CID);
	</cfscript>
<!---/////////////ACTIVATE SINGLE ///////////--->
<cfelseif form.command eq "act">
	<cfscript>
		OCRSettingsManager.activateOCRSettings(form.OCRTemplateSettingsID);
	</cfscript>
<!---/////////////DELETE SELECTED  ///////////--->
<cfelseif form.command eq "delete">
	<cfscript>
		OCRSettingsManager.deleteOCRSettings(form.OCRTemplateSettingsID);
	</cfscript>
<!---/////////////UPDATE SETTING ///////////--->
</cfif>

<cfset form.command = "" />

<!---****************************** END COMMANDS ***********************************--->


<!---****************************** START DISPLAY ***********************************--->

<cfif form.display eq "active">
	<cfscript>
		qGetOCRSettings = OCRSettingsManager.getOCRSettings(bactive = 1);
	</cfscript>
<cfelseif form.display eq "inActive">
	<cfscript>
		qGetOCRSettings = OCRSettingsManager.getOCRSettings(bactive = 0);
	</cfscript>
<cfelseif form.display eq "edit">
	<cfscript>
		qGetOCRSettings = OCRSettingsManager.getOCRSettings(bActive = 1, OCRTemplateSettingsID = form.settingId);
	</cfscript>
</cfif>

<!---****************************** END DISPLAY ***********************************--->

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!--switch for each action--->
<cfswitch expression="#form.display#">


	<cfcase value="active,inActive">
		<cfinclude template="OCR_Settings_display.cfm" />
	</cfcase>
	<cfcase value="add">
		<cfinclude template="OCR_Settings_add.cfm" />
	</cfcase>

	<cfcase value="edit">
		<cfinclude template="OCR_Settings_edit.cfm" />
	</cfcase>
 
</cfswitch>

<cfoutput>
	<!---hidden form fields--->
	<input name="display" type="hidden" value="#form.display#" />
	<input name="command" type="hidden" value="#form.command#" />
	<input name="settingId" type="hidden" value="" />
	<input name="returnTo" type="hidden" value="#form.returnTo#"/>
	<input name="editMode" type="hidden" value=""/>
</cfoutput>
</form>
 
<cfmodule template="/customTags/include.cfm" file_to_include="/program_wizard/component_select_templates_grid_js.js"/>
<div align="center" style="font-size:15px;color:red;font-weight:bold;width:75%" id="msgSave"></div>
<!--- reserve this div for displaying message in long process (e.g. saving changes) --->
</cfmodule>