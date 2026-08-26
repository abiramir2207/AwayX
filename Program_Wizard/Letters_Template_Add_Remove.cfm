<cfsilent>
<!--- 
FILE: 			
FILENAME:   Letters_Template_Add_Remove.cfm
CREATED: 		? / ? / ? - ???
EDITED:			03/18/2008 - RBL

FUNCTIONALITY:
- 
--->	
</cfsilent>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Program Template - Clause</title>
	<style>
		.retroFieldsIndicator {font-size:22px;color:green;font-weight:bold;vertical-align:middle;}
		.headingTip { margin:10px 20px; }
		.sh31 { font-weight:bold; font-size:12px; }
  	table.MainTable2 tr, table.MainTable4 tr, table.MainTable3 tr { padding-bottom: 9px; }
	#bigTable th, #segmentTable th  {font:bold 14px; text-align: left; color:3300cc; padding:7px 0 15px 0;}
	</style>
</head>

<body>
<cfinclude template="/common_files/jQuery.cfm">

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<CFSET PAGETITLE = "PROGRAM TEMPLATES: LETTERS">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cfset ThisPage = CGI.SCRIPT_NAME>
<cfset formName = "frmTemplateLetters">
<cfset tableBorderColor = "##93BEE2">
<cfparam name="form.command" 	default="">
<cfparam name="form.id" 	default="0">
<cfparam name="url.id" 	default="#form.id#">
<cfparam name="form.Distributor_Letters" default="0">
<cfparam name="form.Operator_Letters" default="0">
<cfparam name="form.Distributor_Fixed_Pricing" default="0">
<cfparam name="form.Operator_Fixed_Pricing" default="0">
<cfparam name="form.Distributor_Rebate" default="0">
<cfparam name="form.Operator_Rebate" default="0">
<cfparam name="form.Distributor_Lumpsum" default="0">
<cfparam name="form.operator_Lumpsum" default="0">
<cfparam name="form.Distributor_Growth" default="0">
<cfparam name="form.operator_Growth" default="0">
<cfparam name="form.Distributor_paysto_opr" default="0">
<cfparam name="form.Distributor_paysto_dis" default="0">
<cfparam name="form.Operator_paysto_opr" default="0">
<cfparam name="form.Operator_paysto_dis" default="0">
<cfparam name="form.Distributor_Bid_Request" default="0">
<cfparam name="form.Operator_Bid_request" default="0">
<cfparam name="form.include_freight_summary" type="boolean" default="0">
<cfparam name="form.freight_uom" type="numeric" default="0">
<cfparam name="form.Pre_Defined_Page_Break" default="1">
<cfparam name="form.Distributor_UOM" default="1">
<cfparam name="form.Operator_UOM" default="1">
<cfparam name="form.Distributor_Discount_Type" default="1">
<cfparam name="form.Operator_Discount_Type" default="1">
<cfparam name="form.Distributor_Component_Name" default="1">
<cfparam name="form.Operator_Component_Name" default="1">
<cfparam name="form.Distributor_Claim_Mechanism" default="1">
<cfparam name="form.Operator_Claim_Mechanism" default="1">
<cfparam name="form.Distributor_Payable_To" default="1">
<cfparam name="form.Operator_Payable_To" default="1">
<cfif appSettings.getShow_Fixed_Freight()>
<cfparam name="form.Distributor_Pricing_Type" default="1">
<cfparam name="form.Operator_Pricing_Type" default="1">
<cfelse>
<cfparam name="form.Distributor_Pricing_Type" default="0">
<cfparam name="form.Operator_Pricing_Type" default="0">
</cfif>
<cfparam name="form.Distributor_Payment_Frequency" default="1">
<cfparam name="form.Operator_Payment_Frequency" default="1">
<cfparam name="form.Distributor_GTIN" default="0">
<cfparam name="form.Operator_GTIN" default="0">
<cfparam name="form.Distributor_Product_Attribute_1" default="0">
<cfparam name="form.Operator_Product_Attribute_1" default="0">
<cfparam name="form.Email_Letters_On_Approval" default="0">    <!---27018--->
<cfparam name="form.Generate_Letters_On_Approval" default="0">
<cfparam name="form.Operator_Fixed_Pricing_Default" default="0">
<cfparam name="form.Operator_Rebate_Default" default="0">
<cfparam name="form.Operator_Lumpsum_Default" default="0">
<cfparam name="form.Operator_Bid_Request_Default" default="0">
<cfparam name="form.Distributor_Fixed_Pricing_Default" default="0">
<cfparam name="form.Distributor_Rebate_Default" default="0">
<cfparam name="form.Distributor_Lumpsum_Default" default="0">
<cfparam name="form.Distributor_Bid_Request_Default" default="0">
<cfparam name="form.Operator_Broker_Number" default="0">

<cfparam name="form.non_blended_delivered_freight_matrix_excel_export" default="0">
<cfparam name="form.blended_delivered_freight_matrix_excel_export" default="0">
<cfparam name="form.escalator_excel_export" default="0">
<cfparam name="form.distributor_broker_number" default="0">
<cfparam name="form.custom_rfp_letter" default="0">

<cfparam name="strBrand" default="Brand">
<cfparam name="strQ_Brand" default="Q Brand">
<cfparam name="strType_Code" default="Type Code">
<cfparam name="strType_Group" default="Type Group"> 
<cfparam name="strCaseCount" default="Case Count"> 
<cfparam name="url.DownloadSettings" default=0>
<cfif url.id>

	<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
	<cfset template = templateManager.get(url.id)>
	<cfif not isDefined("request.qLabels")>
		<cfset request.qLabels = createObject("component", "components.settings.Labels.Labels").init()>
	</cfif>
	<cfset getAllProductAttributes = request.qLabels.getAllProductAttributes()>

	<cfset templatesettings = templateManager.getTemplateSettings(url.id)> <!--- D36100 :: MOVE 'Letters Accepted By text' SETTING TO BE AT THE TEMPLATE LEVEL --->
	<cfset pageName = "letters">	
	<cfif form.command EQ "save">
		<cfset allRevsOfTemplate = templateManager.getThisTemplateAllParentsID(url.id) />
		<cfset templateManager.saveLetters(allRevsOfTemplate, form)>
		<cfset id = url.id>
		
		<!------ Redirect to next page ----->		
		<cfinclude template="Next_Page.cfm" />
		
	<cfelse>

        <cfset templateletters = templatesettings>
        <cfset Created_Type    = template.getCreatedType()>
        <cfset Generic_Type    = template.getGenericType()>
        <cfset Active          = template.getActive()>
        <cfset Action          = "edit">
        
		<cfinclude template="header.cfm">

		<cfloop query="getAllProductAttributes">
			<cfswitch expression="#Trim(Group_Internal_Label)#">
   				<cfcase value="Brand">
      					<cfset strBrand = #Group_Level_Desc#>
   				</cfcase>
   				<cfcase value="Q Brand">
       					<cfset strQ_Brand = #Group_Level_Desc#>
   				</cfcase>
   				<cfcase value="Type Code">
       					<cfset strType_Code = #Group_Level_Desc#>
   				</cfcase>
   				<cfcase value="Type Group">
       					<cfset strType_Group = #Group_Level_Desc#>
   				</cfcase>
		   		<cfcase value="Case Count">
       					<cfset strCaseCount = #Group_Level_Desc#>
   				</cfcase>
			</cfswitch>
		</cfloop>
		
		<!--- The objective here is to show the "Product Attribute 1" labels ordered alphabetically. To accomplish the task, I created an array and sorted it. --->
		<cfset arrProductAttribute = ArrayNew(1)>
		<cfset arrProductAttribute[1] = "#strBrand#">
	<!--- When app setting "Custom 1" is ON for letters --->
	<cfif appSettings.getlettersavailable() eq 2>
		<cfset arrProductAttribute[2] = "#strCaseCount#">
	<cfelse>
	<!--- Standard Letters --->
		<cfset arrProductAttribute[2] = "Pack Size">
	</cfif>
		<cfset arrProductAttribute[3] = "#strQ_brand#">
		<cfset arrProductAttribute[4] = "#strType_Code#">
		<cfset arrProductAttribute[5] = "#strType_Group#">
		<cfset arrProductAttribute[6] = "None">

		<!--- sort the array. default is ascending  --->
		<cfset arraySort(arrProductAttribute,"textnocase")>

		<cfoutput><form name="#formName#" method="post" action="#ThisPage#" style="display:inline;">
		
		<div style="margin:5px 0;">
			<span style="width:60%;"><img src="/images/ico-info.gif"><span class="headingTip">All changes on this page will be saved retroactively for all previous versions.</span></span>
    	<cfif LockedBy_Current_User EQ 1>
    		<span style="width:39%;text-align:right;"><a href="javascript:submitForm(document.#formName#, 'save');">#application.util.string.actionLinkFormat("save and continue")#</a></span>
    	</cfif>
    </div>
    


    <!--- ngt --->
    <style>
        section.xcel {
            width: 100%;
            box-sizing: border-box;
        }
        header.xcel {
            background-color: ##ffce84;
            height: 17px;
            font-weight: bold;
            padding: 5px 0 0 5px;
        }
        label.xcel {
            margin: 10px;
            display: block;
        }
        span.xcel {
            width: 215px;
            display: inline-block;
        }
        input.xcel {
            position: relative;
            top: 2px;
        }
    </style>

    <cfset int_setting = application.util.query.get_settings("non_blended_delivered_freight_matrix_excel_export,blended_delivered_freight_matrix_excel_export,escalator_excel_export,Letters_available", 0)>

    <!--- -------------------------------------------------------------------------------------------------------- --->
    <!--- display excel export section based on the above internal settings (when at least one setting is enabled) --->
    <!--- -------------------------------------------------------------------------------------------------------- --->
    <cfif int_setting.escalator_excel_export
        or int_setting.blended_delivered_freight_matrix_excel_export
        or int_setting.non_blended_delivered_freight_matrix_excel_export>
        <section class="xcel">
            <header class="xcel">Excel Export</header>

            <cfif int_setting.non_blended_delivered_freight_matrix_excel_export>
                <label class="xcel"> <span class="xcel">Non Blended Delivered Freight Matrix</span>
                    <input type="checkbox" value="1" class="xcel" 
                        <cfif templatesettings.non_blended_delivered_freight_matrix_excel_export>checked</cfif>
                        name="non_blended_delivered_freight_matrix_excel_export"> 
                </label>
            </cfif>

            <cfif int_setting.blended_delivered_freight_matrix_excel_export>
                <label class="xcel"> <span class="xcel">Blended Delivered Freight Matrix</span>
                    <input type="checkbox" value="1" class="xcel" 
                        <cfif templatesettings.blended_delivered_freight_matrix_excel_export>checked</cfif>
                        name="blended_delivered_freight_matrix_excel_export"> 
                </label>
            </cfif>

            <cfif int_setting.escalator_excel_export>
                <label class="xcel"> <span class="xcel">Escalator</span>
                    <input type="checkbox" value="1" class="xcel" 
                        <cfif templatesettings.escalator_excel_export>checked</cfif>
                        name="escalator_excel_export"> 
                </label>
            </cfif>
        </section>
    </cfif>

    <cfif int_setting.Letters_available eq '5'>
        <section class="xcel">
            <header class="xcel">Custom RFP Letter</header>
            <label class="xcel"> <span class="xcel">Custom RFP Letter</span>
                <input type="checkbox" value="1" class="xcel" 
                    <cfif templatesettings.custom_rfp_letter>checked</cfif>
                    name="custom_rfp_letter"> 
            </label>
    </section>
    </cfif>


		<table cellpadding="4" cellspacing="0" border="0" class="MainTable2" id="bigTable" width="100%" <cfif url.DownloadSettings>style="display: none"</cfif>>
		<col width="9%">
		<col width="16%">
		<col width="5%">
		<col width="70%">
			
		<tr bgcolor="FFCE84">
		<td colspan="3"><B>Letters</B></td>
		<td ><B>Required</B></td>
		</tr>
		
		<cfif appSettings.getlettersavailable() eq 2>
		<!--- Dev Note:Milan42687. We do not want to email letters on approval as the letter content and the contact email is not verified.
		In fact, by not using this feature, we will not generate the letters on approval at all, as this feature creates and emails the letters.
		Note: We have an different setting called "Generate Letters Upon Approval" below, which just generates letters on approval.
		--->

		<cfelseif appSettings.getlettersavailable() eq 1 OR appSettings.getlettersavailable() eq 4>
			<cfif url.DownloadSettings>
				<cfset SettingsToExcel (Setting_name='Generate Letters Upon Approval', Setting_Field_name='Generate_Letters_On_Approval', Page='4')>
			<cfelse>
			<tr>
				<td  colspan="3" >Generate Letters Upon Approval</td>
				<td><input type="checkbox" name="Generate_Letters_On_Approval" value="1" <cfif templateletters.Generate_Letters_On_Approval EQ 1>checked</cfif>></td>
			</tr>
			</cfif>
		</cfif>

	<cfif url.DownloadSettings>
		<cfset SDValue = 'Continuous Flow'>
		<cfif templateletters.Pre_Defined_Page_Break>
			<cfset SDValue = 'BA Pre-defined Page Breaks'>
		</cfif>
		<cfset SettingsToExcel (Setting_name='Pre Defined Page Break', Setting_Field_name='Pre_Defined_Page_Break', Setting_Value='#SDValue#', Page='4')>
	<cfelse>
		<tr>
		<td  colspan="3">Pre Defined Page Break</td>
		<td>
  			<input type="radio" name="Pre_Defined_Page_Break" value="1" <cfif templateletters.Pre_Defined_Page_Break EQ 1>checked</cfif>> BA Pre-defined Page Breaks <br/>
  			<input type="radio" name="Pre_Defined_Page_Break" value="0" <cfif templateletters.Pre_Defined_Page_Break EQ 0>checked</cfif>> Continuous Flow
	 	</td>
		</tr>
	</cfif>
<!--- D36100 :: MOVE 'Letters Accepted By text' SETTING TO BE AT THE TEMPLATE LEVEL --->
	<cfif templatesettings.Customer_Acceptance>
		<cfif url.DownloadSettings>
			<cfset SettingsToExcel (Setting_name='Acceptance Block - Accepted By Line display', Setting_Field_name='Letters_Accepted_By', Setting_Value='#templateletters.Letters_Accepted_By#', Page='4')>
		<cfelse>
			<tr>
					<td colspan="3" >Acceptance Block - Accepted By Line display</td>
					<td><input type="textbox" size="25" value="#templateletters.Letters_Accepted_By#" name="Letters_Accepted_By"></td>
			</tr>
		</cfif>
	<cfelse>
			<input type="hidden" size="25" value="" name="Letters_Accepted_By">
	</cfif>
	
	<tr><td colspan="4"><hr></td></td></tr>
<!--- D36100 :: MOVE 'Letters Accepted By text' SETTING TO BE AT THE TEMPLATE LEVEL --->	
		<cfif url.DownloadSettings>
			<cfset SDValue = 'No'>
			<cfif templateletters.operator_letters_required EQ 1>
				<cfset SDValue = 'Yes'>
			</cfif>
			<cfset SettingsToExcel (Setting_name='#application.returned_customer_setting.operator_label_plural#', Setting_Field_name='Operator_letters', Setting_Value='#SDValue#', Page='4')>
		<cfelse>
		<tr>
			<th><cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput></th>
			<td><input type="checkbox" name="Operator_letters" value="1" <cfif templateletters.operator_letters_required EQ 1>checked</cfif>></td>
		  <td>Display</td>
		  <td>Default</td>
		</tr>
		</cfif>
		<cfif template.getGenericType() NEQ "Bid Request">
			<cfif url.DownloadSettings>
				<cfset SDValue = 'No'>
				<cfset SDefault = 'No'>

				<cfif templateletters.Operator_Fixed_Pricing EQ 1>
					<cfset SDValue = 'Display'>
				</cfif>

				<cfif templateletters.Operator_Fixed_Pricing_Default EQ 1>
					<cfset SDefault = 'Default'>
				</cfif>

				<cfset SettingsToExcel (Setting_name='#application.returned_customer_setting.operator_label_plural#', Setting_Field_name='Operator_letters', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', Page='4')>
			<cfelse>		
				<tr>
					<td width2="58">&nbsp;</td>
					<td width2="250">Fixed Pricing</td>
					<td><input type="checkbox" name="Operator_Fixed_Pricing" value="1" <cfif templateletters.Operator_Fixed_Pricing EQ 1>checked</cfif>></td>
					<td><input type="checkbox" name="Operator_Fixed_Pricing_Default" value="1" <cfif templateletters.Operator_Fixed_Pricing_Default EQ 1>checked</cfif>></td>
				</tr>
			</cfif>
		</cfif>

<cfif url.DownloadSettings>
	<cfset SDValue = 'No'>
	<cfset SDefault = 'No'>

	<cfif templateletters.Operator_Rebate EQ 1>
		<cfset SDValue = 'Display'>
	</cfif>

	<cfif templateletters.Operator_Rebate_Default EQ 1>
		<cfset SDefault = 'Default'>
	</cfif>

	<cfset SettingsToExcel (Setting_name='#Application.RebateLabel#', Setting_Field_name='Operator_Rebate', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', Page='4')>
<cfelse>			
	<tr>
		<td>&nbsp;</td>
		<td><cfoutput>#Application.RebateLabel#</cfoutput></td>
		<td><input type="checkbox" name="Operator_Rebate" value="1" <cfif templateletters.Operator_Rebate EQ 1>checked</cfif>></td>
		<td><input type="checkbox" name="Operator_Rebate_Default" value="1" <cfif templateletters.Operator_Rebate_Default EQ 1>checked</cfif>></td>
	</tr>
</cfif>

<cfif template.getGenericType() NEQ "Bid Request">
	<cfif url.DownloadSettings>
		<cfset SDValue = 'No'>
		<cfset SDefault = 'No'>

		<cfif templateletters.Operator_Lumpsum EQ 1>
			<cfset SDValue = 'Display'>
		</cfif>

		<cfif templateletters.Operator_Lumpsum_Default EQ 1>
			<cfset SDefault = 'Default'>
		</cfif>

		<cfset SettingsToExcel (Setting_name='#Application.LumpsumLabel#', Setting_Field_name='Operator_Rebate', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', Page='4')>
	<cfelse>		
		<tr>
			<td>&nbsp;</td>
			<td><cfoutput>#Application.LumpsumLabel#</cfoutput></td>
			<td><input type="checkbox" name="Operator_Lumpsum" value="1" <cfif templateletters.Operator_Lumpsum EQ 1>checked</cfif>></td>
			<td><input type="checkbox" name="Operator_Lumpsum_Default" value="1" <cfif templateletters.Operator_Lumpsum_Default EQ 1>checked</cfif>></td>
		</tr>
	</cfif>
</cfif>

<cfif template.getGenericType() EQ "Bid Request">
	<cfif url.DownloadSettings>
		<cfset SDValue = 'No'>
		<cfset SDefault = 'No'>

		<cfif templateletters.Operator_Bid_Request EQ 1>
			<cfset SDValue = 'Display'>
		</cfif>

		<cfif templateletters.Operator_Bid_Request_Default EQ 1>
			<cfset SDefault = 'Default'>
		</cfif>

		<cfset SettingsToExcel (Setting_name='Proposal', Setting_Field_name='Operator_Bid_Request', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', Page='4')>
	<cfelse>		
	<tr>
		<td>&nbsp;</td>
		<td><cfoutput>Proposal</cfoutput></td>
		<td><input type="checkbox" name="Operator_Bid_Request" value="1" <cfif templateletters.Operator_Bid_Request EQ 1>checked</cfif>></td>
		<td><input type="checkbox" name="Operator_Bid_Request_Default" value="1" <cfif templateletters.Operator_Bid_Request_Default EQ 1>checked</cfif>></td>
	</tr>
	</cfif>
</cfif>

	<cfif url.DownloadSettings>
		<cfset SDValue = 'None'>

		<cfif templateletters.Operator_paysto_dis EQ 1>
			<cfset SDValue = 'Distributor'>
		</cfif>

		<cfif templateletters.Operator_paysto_opr EQ 1>
			<cfset SDValue = listAppend(SDValue,'Operator')>
		</cfif>

		<cfset SettingsToExcel (Setting_name='Proposal', Setting_Field_name='Operator_paysto_dis', Setting_Value='#SDValue#', Page='4')>
	<cfelse>		
	<tr>
		<td>&nbsp;</td>
		<td>Pays To</td>
		<td colspan="2">
			<input type="checkbox" name="Operator_paysto_dis" value="1" <cfif templateletters.Operator_paysto_dis EQ 1>checked</cfif>>
			Distributor &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="checkbox" name="Operator_paysto_opr" value="1" <cfif templateletters.Operator_paysto_opr EQ 1>checked</cfif>>
			Operator
		</td>
	</tr>
	</cfif>

<cfif url.DownloadSettings>
	<cfset SDValue = 'None'>

	<cfif templateletters.Operator_UOM EQ 1>
		<cfset SDValue = 'Case'>
	<cfelseif templateletters.Operator_UOM EQ 2>
		<cfset SDValue = 'Pound'>
	<cfelseif templateletters.Operator_UOM EQ 3>
		<cfset SDValue = 'Case & Pound'>
	<cfelseif templateletters.Operator_UOM EQ 4>
		<cfset SDValue = 'Hundred Weight'>
	<cfelseif templateletters.Operator_UOM EQ 5>
		<cfset SDValue = 'Program UOM'>
	</cfif>	

	<cfset SettingsToExcel (Setting_name='UOM', Setting_Field_name='Operator_UOM', Setting_Value='#SDValue#', Page='4')>
<cfelse>		
<tr>
	<td>&nbsp;</td>
	<td>UOM</td>
	<td colspan="2">
		<input type="radio" name="Operator_UOM" value="1" <cfif templateletters.Operator_UOM EQ 1>checked</cfif>> Case&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="radio" name="Operator_UOM" value="2" <cfif templateletters.Operator_UOM EQ 2>checked</cfif> <cfif appSettings.getlettersavailable()  EQ 2>Disabled</cfif>> Pound&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="radio" name="Operator_UOM" value="3" <cfif templateletters.Operator_UOM EQ 3>checked</cfif> <cfif appSettings.getlettersavailable()  EQ 2>Disabled</cfif>> Case & Pound&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<!--- As of now, itis for "Standard letters" only. --->
	<cfif appSettings.getlettersavailable() eq 1>
		<input type="radio" name="Operator_UOM" value="4" <cfif templateletters.Operator_UOM EQ 4>checked</cfif> <cfif appSettings.getlettersavailable()  EQ 2>Disabled</cfif>> Hundred Weight&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="radio" name="Operator_UOM" value="5" <cfif templateletters.Operator_UOM EQ 5>checked</cfif> <cfif appSettings.getlettersavailable()  EQ 2>Disabled</cfif>> Program UOM
	</cfif>
	</td>
</tr>
</cfif>

<cfif appSettings.getlettersavailable() eq 1>
	<cfif url.DownloadSettings>
		<cfset SDValue = 'None'>	
		<cfif templateletters.Operator_show_volume_summary EQ 1>
			<cfset SDValue = 'Program Volume'>
		<cfelseif templateletters.Operator_show_volume_summary EQ 2>
			<cfset SDValue = 'Annual Volume'>
		<cfelseif templateletters.Operator_show_volume_summary EQ 3 OR templateletters.Operator_show_volume_summary EQ 0>
			<cfset SDValue = 'Both'>
		</cfif>		

		<cfset SettingsToExcel (Setting_name='Volume Summary', Setting_Field_name='Operator_show_volume_summary', Setting_Value='#SDValue#', Page='4')>
	<cfelse>
	<tr>
		<td>&nbsp;</td>
		<td>Volume Summary</td>
		<td colspan="2">
		<input type="radio" name="Operator_show_volume_summary" value="1" <cfif templateletters.Operator_show_volume_summary EQ 1>checked</cfif>> Program Volume&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="radio" name="Operator_show_volume_summary" value="2" <cfif templateletters.Operator_show_volume_summary EQ 2>checked</cfif>> Annual Volume&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="radio" name="Operator_show_volume_summary" value="3" <cfif templateletters.Operator_show_volume_summary EQ 3 OR templateletters.Operator_show_volume_summary EQ 0>checked</cfif>> Both
		</td>
	</tr>
	</cfif>
<cfelse>
		<input type="hidden" name="Operator_show_volume_summary" value="0">
</cfif>

<cfif url.DownloadSettings>
	<cfset Setting_Value = 'Discount Type,Component Name,Claim Mechanism,Payment Frequency,Payable To,GTIN,UPC,Approval Date,Price Brackets,Open Date,Date Needed ,Expected Date,Est. Value / Volume,#application.returned_customer_setting.broker_label_singular#,Customer Acceptance Block,Notes,Line No ,Product Net Weight,Rate Change,Pricing Type,#application.returned_customer_setting.item_label# groups,Excel file for product group members'>
	<cfset Setting_Field_name = 'Operator_Discount_Type,Operator_Component_Name,Operator_Claim_Mechanism,Operator_Payment_Frequency,Operator_Payable_To,Operator_GTIN,Operator_UPC,Operator_Approval_Date,Operator_Price_Brackets,Operator_Open_Date,Operator_Date_Needed,Operator_Expected_Date,Operator_Est_Value_Volume,Operator_Broker_Number,Operator_Customer_Acceptance_Block,Operator_Notes,Operator_Line,Operator_Product_Net_Weight,Operator_Rate_Change,Operator_Pricing_Type,Operator_display_product_groups,Operator_Generate_Excel_File_Product_Group_Members'>
	
	<cfloop from="1" to="#listlen(Setting_Value)#" index="OS">
		<cfset SettingValue = 'Do not Display'>

		<cfset OSettingValue = evaluate("templateletters.#listGetAt(Setting_Field_name, OS)#")>
		<cfif OSettingValue EQ 1>
			<cfset SettingValue = 'Display'>
		</cfif>
		<cfset SettingsToExcel (Setting_name='#listGetAt(Setting_Value, OS)#', Setting_Field_name='#listGetAt(Setting_Field_name, OS)#', Setting_Value='#SettingValue#', Page='4')>
	</cfloop>

<cfelse>
		<!------ D26567 Program Letters display price list info ------>
<tr>
		<td>&nbsp;</td>
		<td colspan="4">
			<table cellpadding="4" cellspacing="0" border="0" class="MainTable3" width="50%">
			
				<tr>
					<td>Discount Type</td>
					<td>
						<select name="Operator_Discount_Type">
							<option value="1" <cfif templateletters.Operator_Discount_Type EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Operator_Discount_Type EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>
					<td>Component Name</td>
					<td>
						<select name="Operator_Component_Name">
							<option value="1" <cfif templateletters.Operator_Component_Name EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Operator_Component_Name EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>
				</tr>
	
				<tr <cfif appSettings.getlettersavailable()  EQ 2> style="display:none"</cfif>>
					<td>Claim Mechanism</td>
					<td>
						<select name="Operator_Claim_Mechanism">
							<option value="1" <cfif templateletters.Operator_Claim_Mechanism  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Operator_Claim_Mechanism  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>
					<td>Payment Frequency</td>
					<td>
						<select name="Operator_Payment_Frequency">
							<option value="1" <cfif templateletters.Operator_Payment_Frequency  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Operator_Payment_Frequency  EQ 0>selected</cfif>>Don't Display</option>
						</select>					
					</td>
				</tr>

			<tr>
				<td>Payable To</td>
				<td>
					<select name="Operator_Payable_To">
						<option value="1" <cfif templateletters.Operator_Payable_To  EQ 1>selected</cfif>>Display</option>
						<option value="0" <cfif templateletters.Operator_Payable_To  EQ 0>selected</cfif>>Don't Display</option>
					</select>
				</td>
				<td>GTIN</td>
				<td>
					<select name="Operator_GTIN">
						<option value="1" <cfif templateletters.Operator_GTIN  EQ 1>selected</cfif>>Display</option>
						<option value="0" <cfif templateletters.Operator_GTIN  EQ 0>selected</cfif>>Don't Display</option>
					</select>
				</td>
			</tr>

		<cfif appSettings.getlettersavailable() EQ 4>
			<tr>
				<td>UPC</td>
				<td>
					<select name="Operator_UPC">
						<option value="1" <cfif templateletters.Operator_UPC  EQ 1>selected</cfif>>Display</option>
						<option value="0" <cfif templateletters.Operator_UPC  EQ 0>selected</cfif>>Don't Display</option>
					</select>
				</td>
				<td>Approval Date</td>
				<td>
					<select name="Operator_Approval_Date">
						<option value="1" <cfif templateletters.Operator_Approval_Date  EQ 1>selected</cfif>>Display</option>
						<option value="0" <cfif templateletters.Operator_Approval_Date EQ 0>selected</cfif>>Don't Display</option>
					</select>
				</td>
			</tr>
		<cfelse>
			<input type="hidden" name="Operator_UPC" value="0">
			<input type="hidden" name="Operator_Approval_Date" value="0">
		</cfif>
		<!--- Dev Note: 57337 - Not for standard letters (as of now) --->
		<cfif appSettings.getlettersavailable() neq 1>
		<tr>
			<td>Price Brackets</td>
			<td>
				<select name="Operator_Price_Brackets">
					<option value="1" <cfif templateletters.Operator_Price_Brackets  EQ 1>selected</cfif>>Display</option>
					<option value="0" <cfif templateletters.Operator_Price_Brackets  EQ 0>selected</cfif>>Don't Display</option>
				</select>
			</td>
			<td>Open Date </td>
			<td>
				<select name="Operator_Open_Date">
					<option value="1" <cfif templateletters.Operator_Open_Date  EQ 1>selected</cfif>>Display</option>
					<option value="0" <cfif templateletters.Operator_Open_Date  EQ 0>selected</cfif>>Don't Display</option>
				</select>
			</td>
		</tr>

		<tr>
			<td>Date Needed </td>
			<td>
				<select name="Operator_Date_Needed">
					<option value="1" <cfif templateletters.Operator_Date_Needed  EQ 1>selected</cfif>>Display</option>
					<option value="0" <cfif templateletters.Operator_Date_Needed  EQ 0>selected</cfif>>Don't Display</option>
				</select>
			</td>
			<td>Expected Date</td>
			<td>
				<select name="Operator_Expected_Date">
					<option value="1" <cfif templateletters.Operator_Expected_Date  EQ 1>selected</cfif>>Display</option>
					<option value="0" <cfif templateletters.Operator_Expected_Date  EQ 0>selected</cfif>>Don't Display</option>
				</select>
			</td>
		</tr>

		<tr>
			<td>Est. Value / Volume</td>
			<td>
				<select name="Operator_Est_Value_Volume">
					<option value="1" <cfif templateletters.Operator_Est_Value_Volume  EQ 1>selected</cfif>>Display</option>
					<option value="0" <cfif templateletters.Operator_Est_Value_Volume  EQ 0>selected</cfif>>Don't Display</option>
				</select>
			</td>	
			<cfif appSettings.getlettersavailable() EQ 4>
				<td>#application.returned_customer_setting.broker_label_singular# ##</td>
				<td>
					<select name="Operator_Broker_Number">
						<option value="1" <cfif templateletters.Operator_Broker_Number  EQ 1>selected</cfif>>Display</option>
						<option value="0" <cfif templateletters.Operator_Broker_Number  EQ 0>selected</cfif>>Don't Display</option>
					</select>
				</td>
			<cfelse>
				<input type="hidden" name="Operator_Broker_Number" value="0">
			</cfif>
		</tr>
		<cfelse>
			<!--- default values, when these options are not displayed on the dropdown above --->
			<input type="hidden" name="Operator_Price_Brackets" value="0">
			<input type="hidden" name="Operator_Open_Date" value="0">
			<input type="hidden" name="Operator_Date_Needed" value="0">
			<input type="hidden" name="Operator_Expected_Date" value="0">
			<input type="hidden" name="Operator_Est_Value_Volume" value="0">
		</cfif>
		<tr>
			<td>Customer Acceptance Block </td>
			<td>
				<select name="Operator_Customer_Acceptance_Block">
					<option value="1" <cfif templateletters.Operator_Customer_Acceptance_Block  EQ 1>selected</cfif>>Display</option>
					<option value="0" <cfif templateletters.Operator_Customer_Acceptance_Block  EQ 0>selected</cfif>>Don't Display</option>
				</select>
			</td>					
			<td>Notes</td>
			<td>
				<select name="Operator_Notes">
					<option value="1" <cfif templateletters.Operator_Notes  EQ 1>selected</cfif>>Display</option>
					<option value="0" <cfif templateletters.Operator_Notes  EQ 0>selected</cfif>>Don't Display</option>
				</select>
			</td>					
		</tr>
		<tr>					
		<td>Line ## </td>
		<td>
			<select name="Operator_Line">
				<option value="1" <cfif templateletters.Operator_Line  EQ 1>selected</cfif>>Display</option>
				<option value="0" <cfif templateletters.Operator_Line  EQ 0>selected</cfif>>Don't Display</option>
			</select>
		</td>
		<td>Product Net Weight</td>
		<td>
			<select name="Operator_Product_Net_Weight">
				<option value="1" <cfif templateletters.Operator_Product_Net_Weight  EQ 1>selected</cfif>>Display</option>
				<option value="0" <cfif templateletters.Operator_Product_Net_Weight  EQ 0>selected</cfif>>Don't Display</option>
			</select>		
		</td>	
		</tr>
		<tr>
		<cfif appSettings.getlettersavailable() EQ 4>
			<td>Rate Change</td>
			<td>
				<select name="Operator_Rate_Change">
					<option value="1" <cfif templateletters.Operator_Rate_Change  EQ 1>selected</cfif>>Display</option>
					<option value="0" <cfif templateletters.Operator_Rate_Change  EQ 0>selected</cfif>>Don't Display</option>
				</select>
			</td>
		<cfelse>
			<input type="hidden" name="Operator_Rate_Change" value="0">
		</cfif>
		<cfif appSettings.getShow_Fixed_Freight()>
			<td>Pricing Type</td>
			<td>
				<select name="Operator_Pricing_Type">
					<option value="1" <cfif templateletters.Operator_Pricing_Type  EQ 1>selected</cfif>>Display</option>
					<option value="0" <cfif templateletters.Operator_Pricing_Type  EQ 0>selected</cfif>>Don't Display</option>
				</select>
			</td>
		<cfelse>
		<td colspan="4">&nbsp;</td>
		<input type="hidden" name="Operator_Pricing_Type" value="0">
		</cfif>
		</tr>
		<tr>
			<cfif appSettings.getlettersavailable() EQ 4>
			<td>#application.returned_customer_setting.item_label# groups</td>
			<td>
				<select name="Operator_display_product_groups">
					<option value="1" <cfif templateletters.Operator_display_product_groups  EQ 1>selected</cfif>>Display</option>
					<option value="0" <cfif templateletters.Operator_display_product_groups  EQ 0>selected</cfif>>Don't Display</option>
				</select>
			</td>	
			<cfelse>
				<input type="hidden" name="Operator_display_product_groups" value="0">
			</cfif>
			<cfif appSettings.getlettersavailable() EQ 4>
			<td>Excel file for product group members</td>
			<td>
				<select name="Operator_Generate_Excel_File_Product_Group_Members">
					<option value="1" <cfif templateletters.Operator_Generate_Excel_File_Product_Group_Members  EQ 1>selected</cfif>>Display</option>
					<option value="0" <cfif templateletters.Operator_Generate_Excel_File_Product_Group_Members  EQ 0>selected</cfif>>Don't Display</option>
				</select>
			</td>	
			<cfelse>
				<input type="hidden" name="Operator_Generate_Excel_File_Product_Group_Members" value="0">
			</cfif>
		</tr>
		</table>
		</td>
		</tr>
	</cfif>
		<!------ END D26567 Program Letters display price list info ------>
<cfif appSettings.getlettersavailable() neq 4>
	<cfif url.DownloadSettings>

	<cfloop from="1" to="6" index="i">
		<cfif arrProductAttribute[i] eq strBrand>
			<cfset indexProductAttribute = 1>
		<cfelseif arrProductAttribute[i] eq "Pack Size" OR arrProductAttribute[i] eq strCaseCount>
			<cfset indexProductAttribute = 2>
		<cfelseif arrProductAttribute[i] eq strQ_brand>
			<cfset indexProductAttribute = 3>
		<cfelseif arrProductAttribute[i] eq strType_Code>
			<cfset indexProductAttribute = 4>
		<cfelseif arrProductAttribute[i] eq strType_Group>
			<cfset indexProductAttribute = 5>
		<cfelseif arrProductAttribute[i] eq "None">
			<cfset indexProductAttribute = 0>
		</cfif>

		<cfset SDValue = ''>
		<cfif templateletters.Operator_Product_Attribute_1 EQ indexProductAttribute>
		<cfset SDValue = listAppend(SDValue, '#arrProductAttribute[i]#')>
		</cfif>

	</cfloop>

	<cfset SettingsToExcel (Setting_Name='Product Attribute 1', Setting_Field_Name='Operator_Product_Attribute_1', Setting_Value='#SDValue#', Is_Child_Of='', SetAsDefault='#SDefault#', page='2')>

	<cfelse>
		<tr>
		<td>&nbsp;</td>
		<td>Product Attribute 1</td>
		<td colspan="2">
		<table>
			<!--- Loop through the first 3 product attribute as it needs to be in the top row. Array arrProductAttribute has been sorted alphabetically. 
			The reason why we need to check for all 6 attributes inside the loop for both the rows is because we do not know the order of the array.
			--->
			<tr>
			<cfloop from="1" to="3" index="i">
				<cfif arrProductAttribute[i] eq strBrand>
					<cfset indexProductAttribute = 1>
				<cfelseif arrProductAttribute[i] eq "Pack Size" OR arrProductAttribute[i] eq strCaseCount>
					<cfset indexProductAttribute = 2>
				<cfelseif arrProductAttribute[i] eq strQ_brand>
					<cfset indexProductAttribute = 3>
				<cfelseif arrProductAttribute[i] eq strType_Code>
					<cfset indexProductAttribute = 4>
				<cfelseif arrProductAttribute[i] eq strType_Group>
					<cfset indexProductAttribute = 5>
				<cfelseif arrProductAttribute[i] eq "None">
					<cfset indexProductAttribute = 0>
				</cfif>

			<td STYLE="border-bottom: ">
				<input type="radio" name="Operator_Product_Attribute_1" value="#indexProductAttribute#" <cfif templateletters.Operator_Product_Attribute_1 EQ indexProductAttribute>checked</cfif>>#arrProductAttribute[i]# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</td>
			</cfloop>
			</tr>
			<!--- Loop through the next 3 product attribute as it needs to be in the bottom row. Array arrProductAttribute has been sorted alphabetically.
			The reason why we need to check for all 6 attributes inside the loop for both the rows is because we do not know the order of the array.
			--->
			<tr>
			<cfloop from="4" to="6" index="i">
				<cfif arrProductAttribute[i] eq strBrand>
					<cfset indexProductAttribute = 1>
				<cfelseif arrProductAttribute[i] eq "Pack Size" OR arrProductAttribute[i] eq strCaseCount>
					<cfset indexProductAttribute = 2>
				<cfelseif arrProductAttribute[i] eq strQ_brand>
					<cfset indexProductAttribute = 3>
				<cfelseif arrProductAttribute[i] eq strType_Code>
					<cfset indexProductAttribute = 4>
				<cfelseif arrProductAttribute[i] eq strType_Group>
					<cfset indexProductAttribute = 5>
				<cfelseif arrProductAttribute[i] eq "None">
					<cfset indexProductAttribute = 0>
				</cfif>

			<td STYLE="border-bottom: "><input type="radio" name="Operator_Product_Attribute_1" value="#indexProductAttribute#" <cfif templateletters.Operator_Product_Attribute_1 EQ indexProductAttribute>checked</cfif>>#arrProductAttribute[i]# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
			</cfloop>
			</tr>
		</table>     
		</div></td>
		</tr>
	</cfif>
</cfif>

<tr><td colspan="4"><hr></td></td></tr>

	<cfif url.DownloadSettings>
		<cfset SDValue = 'No'>
		<cfif templateletters.distributor_letters_required EQ 1>
			<cfset SDValue = 'Yes'>
		</cfif>
		<cfset SettingsToExcel (Setting_name='#application.returned_customer_setting.distributor_label_plural#', Setting_Field_name='Distributor_Letters', Setting_Value='#SDValue#', Page='4')>
	<cfelse>
		<tr>
			<th><cfoutput><b>#application.returned_customer_setting.distributor_label_plural#</b></cfoutput></th>
			<td><input type="checkbox" name="Distributor_Letters" value="1" <cfif templateletters.distributor_letters_required EQ 1>checked</cfif>></td>
			<td>Display</td>
			<td>Default</td>
		</tr>
	</cfif>

	<cfif template.getGenericType() NEQ "Bid Request">
			<cfif url.DownloadSettings>
			<cfset SDValue = 'No'>
			<cfset SDefault = 'No'>

			<cfif templateletters.Distributor_Fixed_Pricing EQ 1>
				<cfset SDValue = 'Display'>
			</cfif>

			<cfif templateletters.Distributor_Fixed_Pricing_Default EQ 1>
				<cfset SDefault = 'Default'>
			</cfif>

			<cfset SettingsToExcel (Setting_name='Fixed Pricing', Setting_Field_name='Operator_letters', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', Page='4')>
		<cfelse>		
  	<tr>
      <td>&nbsp;</td>
  		<td><cfoutput>Fixed Pricing</cfoutput></td>
  		<td><input type="checkbox" name="Distributor_Fixed_Pricing" value="1" <cfif templateletters.Distributor_Fixed_Pricing EQ 1>checked</cfif>></td>
		  <td><input type="checkbox" name="Distributor_Fixed_Pricing_Default" value="1" <cfif templateletters.Distributor_Fixed_Pricing_Default EQ 1>checked</cfif>></td>
  	</tr>
 	 </cfif>
	</cfif>

	<cfif url.DownloadSettings>
		<cfset SDValue = 'No'>
		<cfset SDefault = 'No'>

		<cfif templateletters.Distributor_Rebate EQ 1>
			<cfset SDValue = 'Display'>
		</cfif>

		<cfif templateletters.Distributor_Rebate_Default EQ 1>
			<cfset SDefault = 'Default'>
		</cfif>

		<cfset SettingsToExcel (Setting_name='#Application.RebateLabel#', Setting_Field_name='Distributor_Rebate', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', Page='4')>
	<cfelse>
	<tr>
    <td>&nbsp;</td>
		<td><cfoutput>#Application.RebateLabel#</cfoutput></td>
		<td><input type="checkbox" name="Distributor_Rebate" value="1" <cfif templateletters.Distributor_Rebate EQ 1>checked</cfif>></td>
		<td><input type="checkbox" name="Distributor_Rebate_Default" value="1" <cfif templateletters.Distributor_Rebate_Default EQ 1>checked</cfif>></td>
	</tr>
	</cfif>

	<cfif template.getGenericType() NEQ "Bid Request">
		<cfif url.DownloadSettings>
			<cfset SDValue = 'No'>
			<cfset SDefault = 'No'>

			<cfif templateletters.Distributor_Lumpsum EQ 1>
				<cfset SDValue = 'Display'>
			</cfif>

			<cfif templateletters.Distributor_Lumpsum_Default EQ 1>
				<cfset SDefault = 'Default'>
			</cfif>

			<cfset SettingsToExcel (Setting_name='#Application.LumpsumLabel#', Setting_Field_name='Distributor_Lumpsum', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', Page='4')>
		<cfelse>	
			<tr>
	      <td>&nbsp;</td>
	  		<td><cfoutput>#Application.LumpsumLabel#</cfoutput></td>
	  		<td><input type="checkbox" name="Distributor_Lumpsum" value="1" <cfif templateletters.Distributor_Lumpsum EQ 1>checked</cfif>></td>
			  <td><input type="checkbox" name="Distributor_Lumpsum_Default" value="1" <cfif templateletters.Distributor_Lumpsum_Default EQ 1>checked</cfif>></td>
  		</tr>
		</cfif>
	</cfif>

	<cfif template.getGenericType() EQ "Bid Request">
		<cfif url.DownloadSettings>
			<cfset SDValue = 'No'>
			<cfset SDefault = 'No'>

			<cfif templateletters.Distributor_Bid_Request EQ 1>
				<cfset SDValue = 'Display'>
			</cfif>

			<cfif templateletters.Distributor_Bid_Request_Default EQ 1>
				<cfset SDefault = 'Default'>
			</cfif>

			<cfset SettingsToExcel (Setting_name='Proposal', Setting_Field_name='Distributor_Bid_Request', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', Page='4')>
		<cfelse>	
  		<tr>
	      <td>&nbsp;</td>
	  		<td><cfoutput>Proposal</cfoutput></td>
	  		<td><input type="checkbox" name="Distributor_Bid_Request" value="1" <cfif templateletters.Distributor_Bid_Request EQ 1>checked</cfif>></td>
			  <td><input type="checkbox" name="Distributor_Bid_Request_Default" value="1" <cfif templateletters.Distributor_Bid_Request_Default EQ 1>checked</cfif>></td>
  		</tr>
		</cfif>
	</cfif>

	<cfif url.DownloadSettings>
		<cfset SDValue = 'None'>

		<cfif templateletters.Distributor_paysto_dis EQ 1>
		<cfset SDValue = 'Distributor'>
		</cfif>

		<cfif templateletters.Distributor_paysto_opr EQ 1>
			<cfset SDValue = listappend(SDValue,'Operator')>
		</cfif>

		<cfset SettingsToExcel (Setting_name='Proposal', Setting_Field_name='Distributor_Bid_Request', Setting_Value='#SDValue#', SetAsDefault='#SDefault#', Page='4')>
	<cfelse>		
		<tr>
			<td>&nbsp;</td>
			<td>Pays To</td>
			<td colspan="2">
				<input type="checkbox" name="Distributor_paysto_dis" value="1" <cfif templateletters.Distributor_paysto_dis EQ 1>checked</cfif>>Distributor &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="checkbox" name="Distributor_paysto_opr" value="1" <cfif templateletters.Distributor_paysto_opr EQ 1>checked</cfif>>Operator
			</td>
		</tr>
	</cfif>

	<cfif url.DownloadSettings>
		<cfset SDValue = 'None'>

		<cfif templateletters.Distributor_UOM EQ 1>
			<cfset SDValue = 'Case'>
		<cfelseif templateletters.Distributor_UOM EQ 2>
			<cfset SDValue = 'Pound'>
		<cfelseif templateletters.Distributor_UOM EQ 3>
			<cfset SDValue = 'Case & Pound'>
		<cfelseif templateletters.Distributor_UOM EQ 4>
			<cfset SDValue = 'Hundred Weight'>
		<cfelseif templateletters.Distributor_UOM EQ 5>
			<cfset SDValue = 'Program UOM'>
		</cfif>

		<cfset SettingsToExcel (Setting_name='UOM', Setting_Field_name='Distributor_UOM', Setting_Value='#SDValue#', Page='4')>
	<cfelse>		
		<tr>
			<td>&nbsp;</td>
			<td>UOM</td>
			<td colspan="2">
				<input type="radio" name="Distributor_UOM" value="1" <cfif templateletters.Distributor_UOM EQ 1>checked</cfif>> Case&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Distributor_UOM" value="2" <cfif templateletters.Distributor_UOM EQ 2>checked</cfif> <cfif appSettings.getlettersavailable()  EQ 2>Disabled</cfif>> Pound&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Distributor_UOM" value="3" <cfif templateletters.Distributor_UOM EQ 3>checked</cfif> <cfif appSettings.getlettersavailable()  EQ 2>Disabled</cfif>> Case & Pound&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<!--- As of now, itis for "Standard letters" only. --->
				<cfif appSettings.getlettersavailable() eq 1>
				<input type="radio" name="Distributor_UOM" value="4" <cfif templateletters.Distributor_UOM EQ 4>checked</cfif> <cfif appSettings.getlettersavailable()  EQ 2>Disabled</cfif>> Hundred Weight&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Distributor_UOM" value="5" <cfif templateletters.Distributor_UOM EQ 5>checked</cfif> <cfif appSettings.getlettersavailable()  EQ 2>Disabled</cfif>> Program UOM
				</cfif>
			</td>
		</tr>
	</cfif>

	<cfif appSettings.getlettersavailable() eq 1>
		<cfif url.DownloadSettings>
		<cfset SDValue = 'None'>

		<cfif templateletters.Distributor_show_volume_summary EQ 1>
			<cfset SDValue = 'Program Volume'>
		<cfelseif templateletters.Distributor_show_volume_summary EQ 2>
			<cfset SDValue = 'Annual Volume'>
		<cfelseif templateletters.Distributor_show_volume_summary EQ 3>
			<cfset SDValue = 'Both'>
		</cfif>

		<cfset SettingsToExcel (Setting_name='Volume Summary', Setting_Field_name='Distributor_show_volume_summary', Setting_Value='#SDValue#', Page='4')>
		<cfelse>		
			<tr>
				<td>&nbsp;</td>
				<td>Volume Summary</td>
				<td colspan="2">
				<input type="radio" name="Distributor_show_volume_summary" value="1" <cfif templateletters.Distributor_show_volume_summary EQ 1>checked</cfif>> Program Volume&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Distributor_show_volume_summary" value="2" <cfif templateletters.Distributor_show_volume_summary EQ 2>checked</cfif>> Annual Volume&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Distributor_show_volume_summary" value="3" <cfif templateletters.Distributor_show_volume_summary EQ 3 OR templateletters.Distributor_show_volume_summary EQ 0>checked</cfif>> Both
				</td>
			</tr>
		</cfif>
	<cfelse>
		<input type="hidden" name="Distributor_show_volume_summary" value="0">
	</cfif>
		<!------ D26567 Program Letters display price list info ------>
		<cfif url.DownloadSettings>

		<cfset Setting_Value = 'Discount Type,Component Name,Claim Mechanism,Payment Frequency,Payable To,GTIN	,UPC,Approval Date,Price Brackets,Open Date,Date Needed,Expected Date,Est. Value / Volume	,#application.returned_customer_setting.broker_label_singular#
		,Customer Acceptance Block,Notes,Line No,Product Net Weight,Rate Change,Pricing Type,#application.returned_customer_setting.item_label# groups,Excel file for product group members'>

		<cfset Setting_Field_name = 'Distributor_Discount_Type,Distributor_Component_Name,Distributor_Claim_Mechanism,Distributor_Payment_Frequency,Distributor_Payable_To,Distributor_GTIN,Distributor_UPC,Distributor_Approval_Date,Distributor_Price_Brackets,Distributor_Open_Date
		,Distributor_Date_Needed,Distributor_Expected_Date,Distributor_Est_Value_Volume,Distributor_Broker_Number,Distributor_Customer_Acceptance_Block,Distributor_Notes	,Distributor_Line,Distributor_Product_Net_Weight,Distributor_Rate_Change,Distributor_Pricing_Type
		,Distributor_display_product_groups	,Distributor_Generate_Excel_File_Product_Group_Members'>
		
		<cfloop from="1" to="#listlen(Setting_Value)#" index="DS">
			<cfset SettingValue = 'Do Not Display'>
			<cfset DSettingValue = evaluate('templateletters.#listGetAt(Setting_Field_name, DS)#')>
			<cfif DSettingValue EQ 1>
				<cfset SettingValue = 'Display'>
			</cfif>			
			<cfset SettingsToExcel (Setting_name='#listGetAt(Setting_Value, DS)#', Setting_Field_name='#listGetAt(Setting_Field_name, DS)#', Setting_Value='#SettingValue#', Page='4')>
		</cfloop>

		<cfelse>
		<tr>
		<td>&nbsp;</td>
		<td colspan="4">
			<table cellpadding="4" cellspacing="0" border="0" class="MainTable4" width="50%">
				<tr>
					<td>Discount Type</td>
					<td>
						<select name="Distributor_Discount_Type">
							<option value="1" <cfif templateletters.Distributor_Discount_Type EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Discount_Type EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>
					
					<td>Component Name</td>
					<td>
						<select name="Distributor_Component_Name">
							<option value="1" <cfif templateletters.Distributor_Component_Name EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Component_Name EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>					
				</tr>
				<tr  <cfif appSettings.getlettersavailable()  EQ 2> style="display:none"</cfif>>
					<td>Claim Mechanism</td>
					<td>
						<select name="Distributor_Claim_Mechanism">
							<option value="1" <cfif templateletters.Distributor_Claim_Mechanism  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Claim_Mechanism  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>					
					<td>Payment Frequency</td>
					<td>
						<select name="Distributor_Payment_Frequency">
							<option value="1" <cfif templateletters.Distributor_Payment_Frequency  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Payment_Frequency  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>					
				</tr>
				<tr>
					<td>Payable To</td>
					<td>
						<select name="Distributor_Payable_To">
							<option value="1" <cfif templateletters.Distributor_Payable_To  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Payable_To  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>
					
					<td>GTIN</td>
					<td>
						<select name="Distributor_GTIN">
							<option value="1" <cfif templateletters.Distributor_GTIN  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_GTIN  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>					
				</tr>
				<cfif appSettings.getlettersavailable() EQ 4>
				<tr>
					<td>UPC</td>
					<td>
						<select name="Distributor_UPC">
							<option value="1" <cfif templateletters.Distributor_UPC  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_UPC  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>
					<td>Approval Date</td>
					<td>
						<select name="Distributor_Approval_Date">
							<option value="1" <cfif templateletters.Distributor_Approval_Date  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Approval_Date EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>
				</tr>
				<cfelse>
				<input type="hidden" name="Distributor_UPC" value="0">
				<input type="hidden" name="Distributor_Approval_Date" value="0">
				</cfif>
				<!--- Dev Note: 57337 - Not for standard letters (as of now) --->
				<cfif appSettings.getlettersavailable() neq 1>
				<tr>
					<td>Price Brackets</td>
					<td>
						<select name="Distributor_Price_Brackets">
							<option value="1" <cfif templateletters.Distributor_Price_Brackets  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Price_Brackets  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>					
					<td>Open Date </td>
					<td>
						<select name="Distributor_Open_Date">
							<option value="1" <cfif templateletters.Distributor_Open_Date  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Open_Date  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>					
				</tr>
				<tr>
					<td>Date Needed </td>
					<td>
						<select name="Distributor_Date_Needed">
							<option value="1" <cfif templateletters.Distributor_Date_Needed  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Date_Needed  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>					
					<td>Expected Date</td>
					<td>
						<select name="Distributor_Expected_Date">
							<option value="1" <cfif templateletters.Distributor_Expected_Date  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Expected_Date  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>					
				</tr>
				<tr>
					<td>Est. Value / Volume</td>
					<td>
						<select name="Distributor_Est_Value_Volume">
							<option value="1" <cfif templateletters.Distributor_Est_Value_Volume  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Est_Value_Volume  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>					
					<cfif appSettings.getlettersavailable() EQ 4>
					<td>#application.returned_customer_setting.broker_label_singular# ##</td>
					<td>
						<select name="Distributor_Broker_Number">
							<option value="1" <cfif templateletters.Distributor_Broker_Number  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Broker_Number  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>
					<cfelse>
					<input type="hidden" name="Distributor_Broker_Number" value="0">
					</cfif>		
				</tr>
				<cfelse>
				<!--- default values, when these options are not displayed on the dropdown above --->
				<input type="hidden" name="Distributor_Price_Brackets" value="0">
				<input type="hidden" name="Distributor_Open_Date" value="0">
				<input type="hidden" name="Distributor_Date_Needed" value="0">
				<input type="hidden" name="Distributor_Expected_Date" value="0">
				<input type="hidden" name="Distributor_Est_Value_Volume" value="0">
				</cfif>

				<tr>
					<td>Customer Acceptance Block </td>
					<td>
						<select name="Distributor_Customer_Acceptance_Block">
							<option value="1" <cfif templateletters.Distributor_Customer_Acceptance_Block  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Customer_Acceptance_Block  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>					
					<td>Notes </td>
					<td>
						<select name="Distributor_Notes">
							<option value="1" <cfif templateletters.Distributor_Notes  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Notes  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>					
				</tr>
				<tr>				
					<td>Line ## </td>
					<td>
						<select name="Distributor_Line">
							<option value="1" <cfif templateletters.Distributor_Line  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Line  EQ 0>selected</cfif>>Don't Display</option>
						</select>					
					</td>	
					<td>Product Net Weight</td>
					<td>
						<select name="Distributor_Product_Net_Weight">
							<option value="1" <cfif templateletters.Distributor_Product_Net_Weight  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Product_Net_Weight  EQ 0>selected</cfif>>Don't Display</option>
						</select>	
					</td>			
				</tr>				
				<tr>
					<cfif appSettings.getShow_Fixed_Freight()>
						<td>Pricing Type</td>
						<td>
							<select name="Distributor_Pricing_Type">
								<option value="1" <cfif templateletters.Distributor_Pricing_Type  EQ 1>selected</cfif>>Display</option>
								<option value="0" <cfif templateletters.Distributor_Pricing_Type  EQ 0>selected</cfif>>Don't Display</option>
							</select>
						</td>						
					<cfelse>
						<td colspan="2">&nbsp;</td>
					</cfif>

					<!--- Dev Note: 57337 - Not for standard letters (as of now) --->
					<cfif appSettings.getlettersavailable() neq 1>
					<td>Dist Product Codes</td>
					<td>
						<select name="Distributor_Dist_Product_Codes">
							<option value="1" <cfif templateletters.Distributor_Dist_Product_Codes  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Dist_Product_Codes  EQ 0>selected</cfif>>Don't Display</option>
						</select>						
           			</td>
					<cfelse>
					<!--- default values, when these options are not displayed on the dropdown above --->
					<input type="hidden" name="Distributor_Dist_Product_Codes" value="0">
					</cfif>
				</tr>
				<tr>
					<cfif appSettings.getlettersavailable() EQ 4>
					<td>Rate Change</td>
					<td>
						<select name="Distributor_Rate_Change">
							<option value="1" <cfif templateletters.Distributor_Rate_Change  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Rate_Change  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>
					<cfelse>
					<input type="hidden" name="Distributor_Rate_Change" value="0">
					</cfif>
				</tr>
				<tr>
					<cfif appSettings.getlettersavailable() EQ 4>
					<td>#application.returned_customer_setting.item_label# groups</td>
					<td>
						<select name="Distributor_display_product_groups">
							<option value="1" <cfif templateletters.Distributor_display_product_groups  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_display_product_groups  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>	
					<cfelse>
					<input type="hidden" name="Distributor_display_product_groups" value="0">
					</cfif>
					<cfif appSettings.getlettersavailable() EQ 4>
					<td>Excel file for product group members</td>
					<td>
						<select name="Distributor_Generate_Excel_File_Product_Group_Members">
							<option value="1" <cfif templateletters.Distributor_Generate_Excel_File_Product_Group_Members  EQ 1>selected</cfif>>Display</option>
							<option value="0" <cfif templateletters.Distributor_Generate_Excel_File_Product_Group_Members  EQ 0>selected</cfif>>Don't Display</option>
						</select>
					</td>	
					<cfelse>
					<input type="hidden" name="Distributor_Generate_Excel_File_Product_Group_Members" value="0">
					</cfif>
				</tr>
			</table>
		</td>
		</tr>
	</cfif>
		<!------ END D26567 Program Letters display price list info ------>
<cfif appSettings.getlettersavailable() neq 4>
	<cfif url.DownloadSettings>

		<cfloop from="1" to="6" index="i">
			<cfif arrProductAttribute[i] eq strBrand>
				<cfset indexProductAttribute = 1>
			<cfelseif arrProductAttribute[i] eq "Pack Size" OR arrProductAttribute[i] eq strCaseCount>
				<cfset indexProductAttribute = 2>
			<cfelseif arrProductAttribute[i] eq strQ_brand>
				<cfset indexProductAttribute = 3>
			<cfelseif arrProductAttribute[i] eq strType_Code>
				<cfset indexProductAttribute = 4>
			<cfelseif arrProductAttribute[i] eq strType_Group>
				<cfset indexProductAttribute = 5>
			<cfelseif arrProductAttribute[i] eq "None">
				<cfset indexProductAttribute = 0>
			</cfif>

			<cfset SDValue = ''>
			<cfif templateletters.Operator_Product_Attribute_1 EQ indexProductAttribute>
				<cfset SDValue = listAppend(SDValue, '#arrProductAttribute[i]#')>
			</cfif>

		</cfloop>

		<cfset SettingsToExcel (Setting_Name='Product Attribute 1', Setting_Field_Name='Distributor_Product_Attribute_1', Setting_Value='#SDValue#', Is_Child_Of='', page='4')>
	<cfelse>
		<tr>
		<td>&nbsp;</td>
		<td>Product Attribute 1</td>
		<td colspan="2">
		<table>		
			<!--- Loop through the first 3 product attribute as it needs to be in the top row. Array arrProductAttribute has been sorted alphabetically. 
			The reason why we need to check for all 6 attributes inside the loop for both the rows is because we do not know the order of the array.
			--->
	<tr>
		<cfloop from="1" to="3" index="i">
			<cfif arrProductAttribute[i] eq strBrand>
				<cfset indexProductAttribute = 1>
			<cfelseif arrProductAttribute[i] eq "Pack Size" OR arrProductAttribute[i] eq strCaseCount>
				<cfset indexProductAttribute = 2>
			<cfelseif arrProductAttribute[i] eq strQ_brand>
				<cfset indexProductAttribute = 3>
			<cfelseif arrProductAttribute[i] eq strType_Code>
				<cfset indexProductAttribute = 4>
			<cfelseif arrProductAttribute[i] eq strType_Group>
				<cfset indexProductAttribute = 5>
			<cfelseif arrProductAttribute[i] eq "None">
				<cfset indexProductAttribute = 0>
			</cfif>

			<td STYLE="border-bottom: ">
				<input type="radio" name="Distributor_Product_Attribute_1" value="#indexProductAttribute#" <cfif templateletters.Distributor_Product_Attribute_1 EQ indexProductAttribute>checked</cfif>>#arrProductAttribute[i]# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</td>
		</cfloop>
	</tr>		

			<!--- Loop through the next 3 product attribute as it needs to be in the bottom row. Array arrProductAttribute has been sorted alphabetically. 
			The reason why we need to check for all 6 attributes inside the loop for both the rows is because we do not know the order of the array.
			--->
	<tr> 
		<cfloop from="4" to="6" index="i">
			<cfif arrProductAttribute[i] eq strBrand>
				<cfset indexProductAttribute = 1>
			<cfelseif arrProductAttribute[i] eq "Pack Size" OR arrProductAttribute[i] eq strCaseCount>
				<cfset indexProductAttribute = 2>
			<cfelseif arrProductAttribute[i] eq strQ_brand>
				<cfset indexProductAttribute = 3>
			<cfelseif arrProductAttribute[i] eq strType_Code>
				<cfset indexProductAttribute = 4>
			<cfelseif arrProductAttribute[i] eq strType_Group>
				<cfset indexProductAttribute = 5>
			<cfelseif arrProductAttribute[i] eq "None">
				<cfset indexProductAttribute = 0>
			</cfif>

			<td STYLE="border-bottom: ">
				<input type="radio" name="Distributor_Product_Attribute_1" value="#indexProductAttribute#" <cfif templateletters.Distributor_Product_Attribute_1 EQ indexProductAttribute>checked</cfif>>#arrProductAttribute[i]# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</td>
		</cfloop>
	</tr>
	</cfif>
</table>
</div>
</td>
</tr>
</cfif>	

<cfif template.getGenericType() NEQ "Bid Request" and application.oApplicationAppSettingsManager.getApplicationAppSettings().getShow_Fixed_Freight()>
	<cfif url.DownloadSettings>
		<cfset SDValue = 'NO'>
		<cfif templateletters.include_freight_summary>
			<cfset SDValue = 'Yes'>
		</cfif>
		<cfset SettingsToExcel (Setting_Name='Freight', Setting_Field_Name='include_freight_summary', Setting_Value='#SDValue#', Is_Child_Of='', page='4')>

		<cfset SDValue = 'NO'>
		<cfif templateletters.freight_uom EQ 1>
			<cfset SDValue = 'Case'>
		<cfelseif templateletters.freight_uom EQ 2>
			<cfset SDValue = 'Pound'>
		</cfif>
		<cfset SettingsToExcel (Setting_Name='Freight UOM', Setting_Field_Name='freight_uom', Setting_Value='#SDValue#', Is_Child_Of='', page='4')>
	<cfelse>
  <tr>
    <td>&nbsp;</td>
    <td>Freight:</td>
    <td align="center" style="font-size: 10px;">
      <div align="left">
        <input type="checkbox" name="include_freight_summary" value="1" <cfif templateletters.include_freight_summary>checked</cfif>>
      </div>
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>Freight UOM:</td>
    <td>
        <input type="radio" name="freight_uom" value="1" <cfif templateletters.freight_uom EQ 1>checked</cfif>> Case&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="radio" name="freight_uom" value="2" <cfif templateletters.freight_uom EQ 2>checked</cfif>> Pound
        </div>
    </td>
  </tr>
	</cfif>
</cfif>

		<input type="hidden" name="id" value="#url.id#">
		<input type="hidden" name="command" value="#form.command#">
		</form></cfoutput>
		</table>
		
		<table width ="100%" id="oTableButton" border="0" cellpadding="0" cellspacing="0">
		<tr>
		<td align="center">
		<!--- Dev Note: KAL - D7952 : Lock/Unlock Template --->
		<cfif LockedBy_Current_User EQ 1>
		<CF_button
			button_name		=	""
			button_caption	=	"save and continue"
			button_action	=	"submitForm(document.#formName#, 'save');"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"save and continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</cfif>
		</td>
		</tr>
		</table>
			
  </cfif>
</cfif>


<script language="JavaScript">
	function submitForm(thisForm, sCommand){
	var errors = false;
	var bOperatorGrowth = 0;
	var bDistributorGrowth = 0;
	var appSettingLetters  = <cfoutput>#appSettings.getlettersavailable()#</cfoutput>;

	if(appSettingLetters == 1){
		if(thisForm.Operator_Growth){
			if(thisForm.Operator_Growth.checked){
				bOperatorGrowth = 1;
			}
		}

		if(thisForm.Distributor_Growth){
			if(thisForm.Distributor_Growth.checked){
				bDistributorGrowth = 1;
			}
		}
	}


	<cfif template.getGenericType() NEQ "Bid Request">
		if((thisForm.Operator_Fixed_Pricing.checked || thisForm.Operator_Rebate.checked || thisForm.Operator_Lumpsum.checked || bOperatorGrowth) && (!thisForm.Operator_letters.checked)){
	<cfelse>
		if((thisForm.Operator_Rebate.checked || thisForm.Operator_Bid_Request.checked || bOperatorGrowth) && (!thisForm.Operator_letters.checked)){
	</cfif>		
				errors = true;
				alert("Please check operator letters in order to select any of the discount types.");
			}
	<cfif template.getGenericType() NEQ "Bid Request">
		if((thisForm.Distributor_Fixed_Pricing.checked || thisForm.Distributor_Rebate.checked || thisForm.Distributor_Lumpsum.checked || bDistributorGrowth) && (!thisForm.Distributor_Letters.checked)){
	<cfelse>
		if((thisForm.Distributor_Rebate.checked || thisForm.Distributor_Bid_Request.checked || bDistributorGrowth) && (!thisForm.Distributor_Letters.checked)){
	</cfif>
				errors = true;
				alert("Please check distributor letters in order to select any of the discount types.");
			}
	<cfif template.getGenericType() NEQ "Bid Request">
		if((!thisForm.Operator_Fixed_Pricing.checked && !thisForm.Operator_Rebate.checked && !thisForm.Operator_Lumpsum.checked && !bOperatorGrowth) && (thisForm.Operator_letters.checked)){
	<cfelse>
		if((!thisForm.Operator_Rebate.checked && !thisForm.Operator_Bid_Request.checked && !bOperatorGrowth) && (thisForm.Operator_letters.checked)){
	</cfif>
				errors = true;
				alert("Please check at least one discount type for operator letters.");
			}
	<cfif template.getGenericType() NEQ "Bid Request">
		if((!thisForm.Distributor_Fixed_Pricing.checked && !thisForm.Distributor_Rebate.checked && !thisForm.Distributor_Lumpsum.checked && !bDistributorGrowth) && (thisForm.Distributor_Letters.checked)){
	<cfelse>
		if((!thisForm.Distributor_Rebate.checked && !thisForm.Operator_Bid_Request.checked && !bDistributorGrowth) && (thisForm.Distributor_Letters.checked)){
	</cfif>
				errors = true;
				alert("Please check at least one discount type for distributor letters.");
			}
			
		if((thisForm.Operator_letters.checked) && (!thisForm.Operator_paysto_dis.checked && !thisForm.Operator_paysto_opr.checked)){
				errors = true;
				alert("Please select a pay-to for operator letters.");
			}
			
		if((thisForm.Distributor_Letters.checked) && (!thisForm.Distributor_paysto_dis.checked && !thisForm.Distributor_paysto_opr.checked)){
				errors = true;
				alert("Please select a pay-to for distributor letters.");
			}
		
		if (errors == false){
		thisForm.command.value = sCommand;
		thisForm.submit();
		return false;
		}
	}	
</script>

  <cfif LockedBy_Current_User NEQ 1>
    <script>
 	    $("table.MainTable2 input[type!=hidden], table.MainTable2 select, table.MainTable3 input[type!=hidden], table.MainTable3 select, table.MainTable4 input[type!=hidden], table.MainTable4 select, input.xcel").attr("disabled", "disabled");
    </script>
  </cfif>

</body>
</html>