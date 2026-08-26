<!---
       Name:          upload_settings.cfm
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.
       Created Date:  1/27/2010
       Created By:    Tim Ford
       Label:		  21918
       Description:
--->

<!---
	form.Vendor_Field_Type		-- 1 = Vendor,	2 = Operator/Dsitributor
	form.Operator_Type			-- 1 = Legacy,	2 = BA_Operator
	form.Distributor_Required	-- 0 = No,		1 = Yes
--->
<cfparam name="form.Vendor_Field_Type"			default="1" />
<cfparam name="form.Operator_Type" 			default="1" />
<cfparam name="form.distributorRequired"		default="0" />
<cfparam name="form.Reject_Invalid_Programs"		default="0" />
<cfparam name="form.Auto_BB_Title"			default="0" />
<cfparam name="form.incl_BB_UOM"			default="0" />
<cfparam name="form.submitted"				default="0" />
<cfparam name="form.User_Upload_create_BB_per_Associated_Shipto"				default="0" />
<cfparam name="form.Vendor_Closing_Method_Required" default="0" />
<cfparam name="form.Payee_As_Associated_Shipto" default="0" />
<cfparam name="form.Operator_Location_Is_Required" default="0" />
<cfparam name="form.Program_Picker_For_Trade" default="0" />
<cfparam name="form.src" default="upload_payables" />

<cfset oBillbackUpload = createObject("component", "components.billback.BillbackUploadUtility") />

<cfif form.submitted eq 1>
	<cfset oBillbackUpload.saveBillbackUploadSettings(form.Vendor_Field_Type, form.Operator_Type, form.distributorRequired, form.Reject_Invalid_Programs, request.AccessStructure.User_ID,
						form.Auto_BB_Title,
						form.incl_BB_UOM,
						form.Manual_Upload_Ship_To_Column,
						form.User_Upload_create_BB_per_Associated_Shipto,
						Vendor_Closing_Method_Required,
						form.Payee_As_Associated_Shipto,
						form.Operator_Location_Is_Required,
		   				form.Program_Picker_For_Trade
						) />
						<!--- D29378 Added form incl bb uom --->
	
	<cfif form.src EQ "payable_settings">
		<cflocation url = "/DEDUCTIONS/settings/deduction_external_settings.cfm?PageTitle=Payables: Settings">
	<cfelse>
		<cflocation url="index.cfm?show_tab=5">		
	</cfif>
</cfif>

<cfset qGetBillbackUploadSettings 	= 	oBillbackUpload.getBillbackUploadSettings() />
<cfset form.Vendor_Field_Type		= 	qGetBillbackUploadSettings.Vendor_Field_Type />
<cfset form.Operator_Type		= 	qGetBillbackUploadSettings.Operator_Type />
<cfset form.distributorRequired 	= 	qGetBillbackUploadSettings.Distributor_Required />
<cfset form.Reject_Invalid_Programs	=	qGetBillbackUploadSettings.Reject_Invalid_Programs />
<cfset form.Auto_BB_Title		=	qGetBillbackUploadSettings.Auto_BB_Title />
<cfset form.Manual_Upload_Ship_To_Column		=	qGetBillbackUploadSettings.Manual_Upload_Ship_To_Column />
<cfset form.User_Upload_create_BB_per_Associated_Shipto = qGetBillbackUploadSettings.User_Upload_create_BB_per_Associated_Shipto />
<cfset form.Vendor_Closing_Method_Required = qGetBillbackUploadSettings.Vendor_Closing_Method_Required />
<cfset form.Payee_As_Associated_Shipto = qGetBillbackUploadSettings.Payee_As_Associated_Shipto />
<cfset form.Operator_Location_Is_Required = qGetBillbackUploadSettings.Operator_Location_Is_Required />
<cfset form.Program_Picker_For_Trade = qGetBillbackUploadSettings.Program_Picker_For_Trade />

 <!--- 44290/Anand Rao/08-Aug-2014 --->

<!--- Dev Note: drachala; D29378: Display Billback settings Use_UOM on the upload payables settings page  START--->
<cfquery name="BBUOM" datasource="#application.datasource#">
      SELECT USE_UOM
	  FROM Billback_Settings
</cfquery>
<cfset form.incl_BB_UOM		=   BBUOM.USE_UOM />
<!--- End Dev Note: drachala; D29378: Display Billback settings Use_UOM on the upload payables settings page  --->

<script language="JavaScript">
	function submitFormUploadBBUtility()
	{
		document.all.uploadSettings.submitted.value = 1;
		document.all.uploadSettings.submit();
		return false;
	}
</script>

<form action="/Settings/upload_billback_utility/upload_settings.cfm" method="post" name="uploadSettings" id="uploadSettings">
<cfif Len(trim(qGetBillbackUploadSettings.Updated_By)) GT 0>
<br />
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="2">
	<TR>
		<TD>
			<cfoutput>
			<FONT SIZE="2"><B>The settings were last updated on #dateformat(qGetBillbackUploadSettings.Updated_Date, 'mm/dd/yyyy')# #timeformat(qGetBillbackUploadSettings.Updated_Date, 'hh:mm:ss TT')# by #qGetBillbackUploadSettings.UpdatedByFullName#</B></FONT>
			</cfoutput>
		</TD>
	</TR>
</TABLE>
</cfif>

<br><font color="navy" size=2><b><span class="subheading">Upload Payables - Settings</span></b></font><br><br>

<table border="0" cellspacing="1">
	<tr>
		<td style="font-weight:bold">
			ID In Vendor Field Will Be:&nbsp;
		</td>
		<td>
			<input name="Vendor_Field_Type" type="radio" value="1" <cfif form.Vendor_Field_Type eq 1>checked</cfif> />&nbsp;Vendor
			<input name="Vendor_Field_Type" type="radio" value="2" <cfif form.Vendor_Field_Type eq 2>checked</cfif> />&nbsp;Operator/Distributor
		</td>
	</tr>
	<tr>
		<td style="font-weight:bold">
			Operator Type:&nbsp;
		</td>
		<td>
			<input name="Operator_Type" type="radio" value="1" <cfif form.Operator_Type eq 1>checked</cfif> />&nbsp;Legacy
			<input name="Operator_Type" type="radio" value="2" <cfif form.Operator_Type eq 2>checked</cfif> />&nbsp;BA Operator
		</td>
	</tr>
	<tr>
		<td style="font-weight:bold">
			When BB Payee = Operator, Then Distributor ID Is Required:&nbsp;
		</td>
		<td>
			<input name="distributorRequired" type="checkbox" value="1" <cfif form.distributorRequired eq 1>checked</cfif> />
		</td>
	</tr>
	<tr>
		<td style="font-weight:bold">
			Reject BB Upload File if Program Field is Blank or Invalid:&nbsp;
		</td>
		<td>
			<input name="Reject_Invalid_Programs" type="checkbox" value="1" <cfif form.Reject_Invalid_Programs eq 1>checked</cfif> />
		</td>
	</tr>

	<tr>
		<td style="font-weight:bold"><br />
			Set auto title for 3rd party and user uploaded billbacks:&nbsp;
		</td>
		<td><br />
			<input name="Auto_BB_Title" type="checkbox" value="1" <cfif form.Auto_BB_Title eq 1>checked</cfif> />
		</td>
	</tr>
<!--- Dev Note: drachala; D29378: Display Billback settings Use_UOM on the upload payables settings page  START--->
	<tr>
		<td style="font-weight:bold">
			Use product UOM for billback upload:&nbsp;
		</td>
		<td>
			<input name="incl_BB_UOM" type="checkbox" value="1" <cfif form.incl_BB_UOM eq 1>checked</cfif> />
		</td>
	</tr>
<!--- End Dev Note: drachala; D29378: Display Billback settings Use_UOM on the upload payables settings page	  --->
	<!---  35663  --->
	<tr>
		<td style="font-weight:bold">
			Manual uploads use:&nbsp;
		</td>
		<cfparam name="form.Manual_Upload_Ship_To_Column" default="ship_to">
		<td>
			<input name="Manual_Upload_Ship_To_Column" type="radio" value="shr_ship_to" <cfif form.Manual_Upload_Ship_To_Column eq "shr_ship_to">checked</cfif> />&nbsp;Shared Ship To
			<input name="Manual_Upload_Ship_To_Column" type="radio" value="ship_to" <cfif form.Manual_Upload_Ship_To_Column eq "ship_to">checked</cfif> />&nbsp;Ship To
		</td>
	</tr>
	<tr>
		<td style="font-weight:bold">
			User Upload-Create BB per Associated Shipto:&nbsp;
		</td>
		<td>
			<input name="User_Upload_create_BB_per_Associated_Shipto" type="checkbox" value="1" <cfif form.User_Upload_create_BB_per_Associated_Shipto eq 1>checked</cfif> />
		</td>
	</tr>
	<!--- Start: Dev Notes: D49989 User BB Upload Setting - Vendor and Closing Method Requirements / Anand Rao / 05-May-2015  --->
	<tr>
		<td style="font-weight:bold">
			Vendor and Closing Method Required:&nbsp;
		</td>
		<td>
			<input name="Vendor_Closing_Method_Required" type="checkbox" value="1" <cfif form.Vendor_Closing_Method_Required eq 1>checked</cfif> />
		</td>
	</tr>
	<!--- END: D49989 --->
	<!--- 51890 BB upload, single file - Payee = Distributor with multiple associated distributors  --->
	<tr>
		<td style="font-weight:bold">
			Set associated ship to = payee for distributor billbacks:&nbsp;
		</td>
		<td>
			<input name="Payee_As_Associated_Shipto" type="checkbox" value="1" <cfif form.Payee_As_Associated_Shipto eq 1>checked</cfif> />
		</td>
	</tr>
	<!--- START: 63222 - Update CBS/User billback upload to include operator location level information --->
	<tr>
		<td style="font-weight:bold">
			Operator Location is required:<img src="/images/help_small.gif"
			Title="When this setting is checked, the Payable upload file should have the three columns: 'Cust Desc, Address, State' as the last 3 columns respectively."/>&nbsp;
		</td>
		<td>
			<input name="Operator_Location_Is_Required" type="checkbox" value="1" <cfif form.Operator_Location_Is_Required eq 1>checked</cfif> />
		</td>
	</tr>
	<!--- START: 63222 - Update CBS/User billback upload to include operator location level information --->
	<tr>
		<td style="font-weight:bold">
			Program Picker For Trade:&nbsp;
		</td>
		<td>
			<input name="Program_Picker_For_Trade" type="checkbox" value="1" <cfif form.Program_Picker_For_Trade eq 1>checked</cfif> />
		</td>
	</tr>
	<!--- END: 63222 - Update CBS/User billback upload to include operator location level information --->
	<tr>
		<td></td>
		<td align="center">
			<br />
			<CF_smallLink
				title = "save"
				url = "##"
				parameters = "onClick=""javascript: return submitFormUploadBBUtility();"""
			>
		</td>
	</tr>
</table>
<cfoutput>
<input type="hidden" name="src" value="#variables.src#">
</cfoutput>
<input name="submitted" type="hidden" value="0" />
</form>