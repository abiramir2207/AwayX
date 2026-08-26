<!---
       Name:          Billback_Type_Label_Settings.cfm
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.
       Created Date:  19-Aug-2010
       Created By:    Anand Rao
       Label:
       Description:
--->

<cfparam name="FORM.Manual_BB_Label"			  default="" />
<cfparam name="FORM.Uploaded_Via_App_Label" 	  default="" />
<cfparam name="FORM.Batch_Interface_Label"		  default="" />
<cfparam name="FORM.Auto_Pay_Label"	         	  default="" />
<cfparam name="FORM.Auto_Approved_Label"	      default="" />
<cfparam name="FORM.BBLabelsSubmitted"			  default="" />
<cfparam name="FORM.III_party_Xref_Enabled"		  default="0" />
<cfparam name="FORM.Operator_Xref_Enabled"		  default="0" />
<cfparam name="FORM.Allow_Multiple_Operator_Xref" default="0" />
<cfparam name="FORM.IS_ReferenceNum" 			  default="0" />
<!---32530--->
<cfparam name="FORM.one_pgm_per_bb" 			  default="0" />
<cfparam name="FORM.load_claim_price" 			default="0" />
<cfparam name="FORM.alias_uses_eshark" 			default="0" />
<cfparam name="FORM.Operator_Auto_Add" 			default="0" />
<cfparam name="FORM.SyscoUseProgramXref" 		default="0" />
<cfparam name="FORM.USFSUseProgramXref" 		default="0" />
<cfparam name="FORM.OverrideUseProgramXref" 		default="0" />
<cfparam name="FORM.SyscoUseMfgProductID" 		default="0" />
<cfparam name="FORM.VendorOverrideForSyscoEDI" default="0" />
<cfparam name="FORM.VendorID" default="" />
<cfparam name="FORM.VendorDefaultClosingMethodID" default="0" />
<cfparam name="URL.uVendorID" default="" />
<cfparam name="FORM.EnableBBDupCheck" 		default="0" />
<cfparam name="FORM.SameDollarAmount" 		default="0" />
<cfparam name="FORM.SameReferenceNumber" 	default="0" />
<cfparam name="FORM.SamePayee" 				default="0" />
<cfparam name="FORM.SameStartEndDates" 		default="0" />
<cfparam name="FORM.SyscoEDIFilterNegativeInvoices" 		default="0" />
<cfparam name="FORM.USFoodsEDIFilterNegativeInvoices" 		default="0" />
<cfparam name="FORM.III_Party_Load_Negative_Invoices_ADJ_and_PAID" 		default="0" /><!---74703--->
<!---D43360 --->
<cfparam name="FORM.USFSConcatProgramAliasDesc" 		default="0" />
<cfparam name="FORM.EDICreateBBPerAssociatedShipto" 		default="0" />
<cfparam name="FORM.SyscoConcatProgramAliasID" 		default="0" />
<cfparam name="FORM.III_P_Upload_Business_Segment" 	default="0" />
<cfparam name="form.Third_Party_Upload_Ship_To_Column" default="ship_to">
<cfparam name="form.III_P_Upload_Use_Closing_Method" default="0"> <!--- D65807 --->
<cfparam name="form.III_P_Upload_Use_Holding_Pen" default="0"> <!--- 85870 --->

<cfinclude template="/actionFormat.cfm">
<!---D43360 --->
<cfset appSettings = application.appSettingsGet>

<cfset oBillbackTypeLabelSettings = createObject("component", "components.billback.BillbackSettingsManager") />

<cfset labelSettings = Createobject("component", "mvc.Models.SettingsService") />
<cfset stBBLabels = labelSettings.getBBLabels() />

<cfif FORM.BBLabelsSubmitted eq 1>
	<cfif (appSettings.getThirdPartyBBUpload() NEQ 1 OR FORM.III_party_Xref_Enabled EQ "1")>
		<cfset varOperator_Xref_Enabled = FORM.Operator_Xref_Enabled />
		<cfset varAllow_Multiple_Operator_Xref = FORM.Allow_Multiple_Operator_Xref />
	<cfelse>
		<cfset varOperator_Xref_Enabled = FORM.Operator_Xref_EnabledDum />
		<cfset varAllow_Multiple_Operator_Xref = FORM.Allow_Multiple_Operator_XrefDum />
	</cfif>
	<cfif (isDefined("FORM.hVendorID") and FORM.hVendorID NEQ "")>
		<cfset FORM.vendorID = FORM.hVendorID />
	</cfif>
	<cfif (isDefined("FORM.hVendorDefaultClosingMethodID"))>
		<cfset FORM.hVendorDefaultClosingMethodID = FORM.hVendorDefaultClosingMethodID />
	</cfif>
	<cfif FORM.VendorOverrideForSyscoEDI EQ 0>
		<cfset FORM.VendorDefaultClosingMethodID = 0 />
		<cfset FORM.VendorID = "" />
	</cfif>
	<cfset oBillbackTypeLabelSettings.saveBBUploadedTypeLabels(FORM.Manual_BB_Label,
															   FORM.Uploaded_Via_App_Label,
															   FORM.Batch_Interface_Label,
															   FORM.Auto_Pay_Label,
															   FORM.Auto_Approved_Label,
															   FORM.III_party_Xref_Enabled,
															   varOperator_Xref_Enabled,
															   varAllow_Multiple_Operator_Xref,
															   FORM.IS_ReferenceNum,
															   request.AccessStructure.User_ID,
															   FORM.one_pgm_per_bb,
															   FORM.load_claim_price,
															   FORM.alias_uses_eshark,
															   FORM.Operator_Auto_Add,
															   FORM.SyscoUseProgramXref,
															   FORM.USFSUseProgramXref,
															   FORM.OverrideUseProgramXref,
															   FORM.SyscoUseMfgProductID,
															   FORM.VendorOverrideForSyscoEDI,
															   FORM.VendorID,
															   FORM.VendorDefaultClosingMethodID,
															   FORM.EnableBBDupCheck,
															   FORM.SameDollarAmount,
															   FORM.SameReferenceNumber,
															   FORM.SamePayee,
															   FORM.SameStartEndDates,
															   FORM.SyscoEDIFilterNegativeInvoices,
															   FORM.USFoodsEDIFilterNegativeInvoices
															   ,FORM.USFSConcatProgramAliasDesc
															   ,FORM.EDICreateBBPerAssociatedShipto
															   ,FORM.SyscoConcatProgramAliasID
															   ,FORM.III_P_Upload_Business_Segment
															   ,FORM.Third_Party_Upload_Ship_To_Column
															   ,FORM.III_P_Upload_Use_Closing_Method
															   ,FORM.III_Party_Load_Negative_Invoices_ADJ_and_PAID
															   ,FORM.III_P_Upload_Use_Holding_Pen) />
	<cflocation url = "/DEDUCTIONS/settings/deduction_external_settings.cfm?PageTitle=Payables: Settings">
</cfif>

  <cfscript>
	  qGetBBUploadedTypeLabels 	    	= oBillbackTypeLabelSettings.getBBUploadedTypeLabels() ;
	  varManual_BB_Label             	= qGetBBUploadedTypeLabels.Manual_BB_Label ;
	  varUploaded_Via_App_Label      	= qGetBBUploadedTypeLabels.Uploaded_Via_App_Label ;
	  varBatch_Interface_Label       	= qGetBBUploadedTypeLabels.Batch_Interface_Label ;
	  varAuto_Pay_Label              	= qGetBBUploadedTypeLabels.Auto_Pay_Label ;
	  varAuto_Approved_Label         	= qGetBBUploadedTypeLabels.Auto_Approved_Label ;
	  varBB_Type_Labels_Updated_By   	= qGetBBUploadedTypeLabels.BB_Type_Labels_Updated_By ;
	  varBB_Type_Labels_Updated_Date 	= qGetBBUploadedTypeLabels.BB_Type_Labels_Updated_Date ;
	  FORM.III_party_Xref_Enabled		  = qGetBBUploadedTypeLabels.III_party_Xref_Enabled ;
	  FORM.Operator_Xref_Enabled 		  = qGetBBUploadedTypeLabels.Operator_Xref_Enabled ;
	  FORM.Allow_Multiple_Operator_Xref	= qGetBBUploadedTypeLabels.Allow_Multiple_Operator_Xref ;
	  FORM.IS_ReferenceNum 				    = qGetBBUploadedTypeLabels.IS_ReferenceNum ;
	  // 32530
	  FORM.one_pgm_per_bb             = qGetBBUploadedTypeLabels.III_P_Upload_One_Pgm_Per_BB ;
	  FORM.load_claim_price           = qGetBBUploadedTypeLabels.III_P_Upload_Load_Claim_Price ;
	  FORM.alias_uses_eshark          = qGetBBUploadedTypeLabels.III_P_Upload_Alias_Uses_Eshark ;
	  FORM.Operator_Auto_Add          = qGetBBUploadedTypeLabels.III_P_Upload_Operator_Auto_Add;
	  FORM.SyscoUseProgramXref		= qGetBBUploadedTypeLabels.Sysco_EDI_Use_Program_Xref;
	  FORM.USFSUseProgramXref			= qGetBBUploadedTypeLabels.USFS_EDI_Use_Program_Xref;
	  FORM.OverrideUseProgramXref		= qGetBBUploadedTypeLabels.Override_Use_Program_Xref;
	  FORM.SyscoUseMfgProductID 		= qGetBBUploadedTypeLabels.Sysco_Use_Mfg_Product_ID;
	  FORM.VendorOverrideForSyscoEDI 	= qGetBBUploadedTypeLabels.Vendor_Override_For_Sysco_EDI;
	  FORM.VendorID					= qGetBBUploadedTypeLabels.Vendor_ID;
	  FORM.VendorDefaultClosingMethodID = qGetBBUploadedTypeLabels.Vendor_Default_Closing_Method_ID;
	  FORM.EnableBBDupCheck			= qGetBBUploadedTypeLabels.Enable_BB_Dup_Check;
	  FORM.SameDollarAmount			= qGetBBUploadedTypeLabels.Same_Dollar_Amount;
	  FORM.SameReferenceNumber		= qGetBBUploadedTypeLabels.Same_Reference_Number;
	  FORM.SamePayee					= qGetBBUploadedTypeLabels.Same_Payee;
	  FORM.SameStartEndDates			= qGetBBUploadedTypeLabels.Same_Start_End_Dates;
	  FORM.SyscoEDIFilterNegativeInvoices 	= qGetBBUploadedTypeLabels.Sysco_Load_Negative_Invoices_ADJ_and_PAID;
	  FORM.USFoodsEDIFilterNegativeInvoices	= qGetBBUploadedTypeLabels.USF_Load_Negative_Invoices_ADJ_and_PAID;
	  FORM.USFSConcatProgramAliasDesc = qGetBBUploadedTypeLabels.USFS_Concat_Program_Alias_Desc;//D43360
	  FORM.EDICreateBBPerAssociatedShipto = qGetBBUploadedTypeLabels.EDI_create_BB_per_Associated_Shipto;//D44290
	  FORM.SyscoConcatProgramAliasID = qGetBBUploadedTypeLabels.Sysco_Concat_Program_Alias_ID;//D48482
	  FORM.III_P_Upload_Business_Segment = qGetBBUploadedTypeLabels.III_P_Upload_Business_Segment; //49208
	  FORM.Third_Party_Upload_Ship_To_Column = qGetBBUploadedTypeLabels.Third_Party_Upload_Ship_To_Column; // 65603
	  FORM.III_P_Upload_Use_Closing_Method = qGetBBUploadedTypeLabels.III_P_Upload_Use_Closing_Method; // 65807
	  FORM.III_Party_Load_Negative_Invoices_ADJ_and_PAID = qGetBBUploadedTypeLabels.III_Party_Load_Negative_Invoices_ADJ_and_PAID;//74703
	  FORM.III_P_Upload_Use_Holding_Pen = qGetBBUploadedTypeLabels.III_P_Upload_Use_Holding_Pen; // 85870
  </cfscript>
  <cfif (URL.uVendorID NEQ "")>
	<cfset pgVendorID = URL.uVendorID />
  <cfelseif (FORM.VendorID NEQ "")>
	<cfset pgVendorID = FORM.VendorID />
  <cfelse>
	<cfset pgVendorID = "" />
  </cfif>

<script>

	searchVendor =  function()
		{
			NewWindow('/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=labelSettings&ReloadForm=0&FieldName=VendorID', 'VendorSearch', '800', '600', 'yes', 'yes')
		}

	</script>
  <cfset useLakebaseForqBillbackClosingMethods = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_closing_methods")>
  <cfif useLakebaseForqBillbackClosingMethods>
	<cftry>
		<cfset qBillbackClosingMethods = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_closing_methods", {
				"select" = "ibillback_closing_method_id,vchbillback_closing_method_desc,benabled,tiautopay_bb_status,deleted,abbreviation,bdefault",
				"deleted" = "eq.0",
				"benabled" = "eq.1",
				"order" = "vchbillback_closing_method_desc.asc"
			}),
			"ibillback_closing_method_id,vchbillback_closing_method_desc,benabled,tiautopay_bb_status,deleted,abbreviation,bdefault"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForqBillbackClosingMethods = false>
		</cfcatch>
	</cftry>
  </cfif>
  <cfif NOT useLakebaseForqBillbackClosingMethods>
  <cfquery NAME="qBillbackClosingMethods" datasource="#application.datasource#">
	SELECT 	Ibillback_closing_method_id,
			Vchbillback_closing_method_desc,
			Benabled,
			Tiautopay_bb_status,
			Deleted,
			Abbreviation,
			Bdefault
	FROM 	Billback_closing_methods
	WHERE 	Deleted = 0
	AND 	Benabled = 1
	ORDER BY Vchbillback_closing_method_desc
  </cfquery>
  </cfif>

<script language="JavaScript">
	function BBLabelsSubmitForm()
	{
		//var sChkObj = document.getElementById("VendorOverrideForSyscoEDI");
		var sChkObj = document.getElementById("VendorOverrideForSyscoEDI").checked;
		var sChkVendorID = document.getElementById("VendorID");
		if (sChkObj == true && sChkVendorID.value == "")
		{
			alert("Please select a Vendor");
			return false;
		}


		document.all.labelSettings.BBLabelsSubmitted.value = 1;
		document.all.labelSettings.submit();
		return false;
	}

	function toggleFieldDisplay(srcElement,dispElement1,dispElement2)
  	{
   	  var field1 = document.getElementById(dispElement1);
  	  var field2 = document.getElementById(dispElement2);
  	  var srcVal = document.getElementById(srcElement);

  	if (srcVal.checked)
  	  {
 	     field1.style.display = 'none';
 	     field2.style.display = '';
  	  }
   	 else
    {
      field1.style.display = '';
      field2.style.display = 'none';
    }
  }

</script>

<form action="Billback_Type_Label_Settings.cfm" method="post" name="labelSettings" id="labelSettings">

<cfoutput>
  <cfif Len(trim(qGetBBUploadedTypeLabels.BB_Type_Labels_Updated_By)) GT 0>
    <br />
    <table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="2">
    	<tr>
    		<td>
    			<FONT SIZE="2">
    				<B>
    					The settings were last updated on #dateformat(qGetBBUploadedTypeLabels.BB_Type_Labels_Updated_Date, 'mm/dd/yyyy')# #timeformat(qGetBBUploadedTypeLabels.BB_Type_Labels_Updated_Date, 'hh:mm:ss TT')# by #qGetBBUploadedTypeLabels.Updated_By#
    				</B>
				</FONT>
    		</td>
    	</tr>
    </table>
  </cfif>
 <br>
 <font color="navy" size=2>
 	<b>
 		<span class="subheading">
 			Billback Search Tool Labels:
		</span>
	</b>
 </font>
 <br><br>


 <table border="0" cellspacing="1">
	<tr>
		<td style="font-weight:bold;width:68%;">
			Manual:&nbsp;
		</td>
		<td>
			<input type="text" name="Manual_BB_Label" value="#varManual_BB_Label#">
		</td>
	</tr>
	<tr>
		<td style="font-weight:bold">
			Upload Via App:&nbsp;
		</td>
		<td>
			<input type="text" name="Uploaded_Via_App_Label" value="#varUploaded_Via_App_Label#"><br>
		</td>
	</tr>
	<tr>
		<td style="font-weight:bold">
			Batch/Interface:&nbsp;
		</td>
		<td>
			<input type="text" name="Batch_Interface_Label" value="#varBatch_Interface_Label#"><br>
		</td>
	</tr>
	<tr>
		<td style="font-weight:bold">
			Auto Pay:&nbsp;
		</td>
		<td>
			<input type="text" name="Auto_Pay_Label" value="#varAuto_Pay_Label#">
		</td>
	</tr>
	<tr>
		<td style="font-weight:bold">
			Auto Approved:&nbsp;
		</td>
		<td>
			<input type="text" name="Auto_Approved_Label" value="#varAuto_Approved_Label#">
		</td>
	</tr>
<cfif appSettings.getThirdPartyBBUpload() eq 1 OR appSettings.getThirdPartyBBUpload() eq 2>
	<tr>
		<td colspan="3">
			<br>
			<font color="navy" size=2>
				<b>
					<span class="subheading">
						3rd Party BB Upload Validation Rules:
					</span>
				</b>
			</font>
			<br><br>
		</td>
	</tr>
	<tr>
		<td>
			<strong>III party Xref Enabled:</strong>
		</td>
		<td>
			<input name="III_party_Xref_Enabled"  id = "III_party_Xref_Enabled" type="checkbox" value="1" <cfif FORM.III_party_Xref_Enabled eq 1>checked</cfif>  onclick="toggleFieldDisplay('III_party_Xref_Enabled','hideFields','showFields');"/>
		</td>
	</tr>
	<tr>
		<td colspan="3">
			<div id="showFields" <cfif (isDefined("FORM.III_party_Xref_Enabled") AND FORM.III_party_Xref_Enabled EQ "0")>style="display:none;"</cfif>>
				<table>
					<tr id="showFields">
						<td>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Operator Xref Enabled:</strong>
						</td>
						<td>
							<input name="Operator_Xref_Enabled" type="checkbox" value="1" <cfif FORM.Operator_Xref_Enabled eq 1>checked</cfif> />
						</td>
					</tr>
					<tr id="showFields">
						<td>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Allow Multiple Operator Xref:</strong>
						</td>
						<td>
							<input name="Allow_Multiple_Operator_Xref" type="checkbox" value="1" <cfif FORM.Allow_Multiple_Operator_Xref eq 1>checked</cfif> />
						</td>
					</tr>
				</table>
				</div>
				<div id="hideFields" <cfif (isDefined("FORM.III_party_Xref_Enabled") AND FORM.III_party_Xref_Enabled EQ "0") OR (NOT isDefined("FORM.III_party_Xref_Enabled"))>style="display:none;"</cfif>>
					<input type="hidden" name = "Operator_Xref_EnabledDum" value= "#FORM.Operator_Xref_Enabled#" />
					<input type="hidden" name = "Allow_Multiple_Operator_XrefDum" value= "#FORM.Allow_Multiple_Operator_Xref#" /><br>
				</div>
		</td>
	</tr>
	<tr>
		<td>
			<strong>Store Billback Reference Number:</strong>
		</td>
		<td>
			<input name="IS_ReferenceNum"  id = "IS_ReferenceNum" type="checkbox" value="1" <cfif FORM.IS_ReferenceNum eq 1>checked</cfif> />
		</td>
	</tr>
<!---32530--->
	<tr>
		<td>
			<strong>
				Single program per billback:
			</strong>
		</td>
		<td>
			<input name="one_pgm_per_bb" type="checkbox" value="1" <cfif FORM.one_pgm_per_bb eq 1>checked=checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<strong>
				3rd party includes program price:
			</strong>
		</td>
		<td>
			<input name="load_claim_price" type="checkbox" value="1" <cfif FORM.load_claim_price eq 1>checked=checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<strong>
				Operator alias considers E-Shark ID:
			</strong>
		</td>
		<td>
			<input name="alias_uses_eshark" type="checkbox" value="1" <cfif FORM.alias_uses_eshark eq 1>checked=checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<strong>
				Claim Upload - Operator Auto Add:
			</strong>
		</td>
		<td>
			<input name="Operator_Auto_Add" type="checkbox" value="1" <cfif FORM.Operator_Auto_Add eq 1>checked=checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<strong>
				Require 3rd Party Upload to have business segment:
			</strong>
		</td>
		<td>
			<input name="III_P_Upload_Business_Segment" type="checkbox" value="1" <cfif FORM.III_P_Upload_Business_Segment eq 1>checked=checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<strong>3rd Party uploads use:&nbsp;
		</td>
		<td>
			<input name="Third_Party_Upload_Ship_To_Column" type="radio" value="shr_ship_to" <cfif form.Third_Party_Upload_Ship_To_Column eq "shr_ship_to">checked</cfif> />&nbsp;Shared Ship To
			<input name="Third_Party_Upload_Ship_To_Column" type="radio" value="ship_to" <cfif form.Third_Party_Upload_Ship_To_Column eq "ship_to">checked</cfif> />&nbsp;Ship To
		</td>
	</tr>
	<!--- D65807 --->
	<tr>
		<td>
			<strong>
				3rd Party Upload - Use closing method:
			</strong>
		</td>
		<td>
			<input name="III_P_Upload_Use_Closing_Method" type="checkbox" value="1" <cfif FORM.III_P_Upload_Use_Closing_Method eq 1>checked=checked</cfif> />
		</td>
	</tr>
	<!---- 85870 ---->
	<tr>
		<td>
			<strong>
				3rd Party Upload - Use holding pen:
			</strong>
		</td>
		<td>
			<input name="III_P_Upload_Use_Holding_Pen" type="checkbox" value="1" <cfif FORM.III_P_Upload_Use_Holding_Pen eq 1>checked=checked</cfif> />
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<br>
			<font color="navy" size=2>
				<b>
					<span class="subheading">
						EDI Validation Rules:
					</span>
				</b>
			</font>
			<br>
		</td>
	</tr>
	<tr>
		<td>
			<strong>
				Sysco Use Program Xref:
			</strong>
		</td>
		<td>
			<input name="SyscoUseProgramXref" type="checkbox" value="1" <cfif FORM.SyscoUseProgramXref eq 1>checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<strong>USFS Use Program Xref:</strong>
		</td>
		<td>
			<input name="USFSUseProgramXref" type="checkbox" value="1" <cfif FORM.USFSUseProgramXref eq 1>checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<strong>Override Use Program Xref:</strong>
		</td>
		<td>
			<input name="OverrideUseProgramXref" type="checkbox" value="1" <cfif FORM.OverrideUseProgramXref eq 1>checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<strong>
				Sysco Use Mfg Product ID:
			</strong>
		</td>
		<td>
			<input name="SyscoUseMfgProductID" type="checkbox" value="1" <cfif FORM.SyscoUseMfgProductID eq 1>checked</cfif> />
		</td>
	</tr>
<!--- START :: D39300 : AFP EDI -- Corporate Payee selection -- CF side --->
	<tr>
		<td>
			<strong>
				Vendor Override for Sysco EDI when invoice length is 12:
			</strong>
		</td>
		<td>
			<input name="VendorOverrideForSyscoEDI"  id = "VendorOverrideForSyscoEDI" type="checkbox" value="1" <cfif FORM.VendorOverrideForSyscoEDI eq 1 OR URL.uVendorID NEQ "">checked</cfif>  onclick="toggleFieldDisplay('VendorOverrideForSyscoEDI','hideFieldsVendor','showFieldsVendor');"/>
		</td>
	</tr>
	<tr>
		<td colspan="3">
				<div id="showFieldsVendor" <cfif ((isDefined("FORM.VendorOverrideForSyscoEDI") AND FORM.VendorOverrideForSyscoEDI EQ "0") AND URL.uVendorID EQ "")>style="display:none;"</cfif>>
					<table>
						<tr id="showFieldsVendor">
							<td>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Select a Vendor :</strong>
							</td>
							<td>
								<cfif (pgVendorID NEQ "")>
									<cfset useLakebaseForqGetVendorID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_master")>
									<cfif useLakebaseForqGetVendorID>
										<cftry>
											<cfset qGetVendorID = application.oLakebase.toQuery(
												application.oLakebase.selectRows("vendor_master", {
													"select" = "vendor_id,vendor_name",
													"vendor_id" = "eq.#pgVendorID#"
												}),
												"vendor_id,vendor_name"
											)>
											<cfcatch type="any">
												<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
												<cfset useLakebaseForqGetVendorID = false>
											</cfcatch>
										</cftry>
									</cfif>
									<cfif NOT useLakebaseForqGetVendorID>
									<cfquery name="qGetVendorID" datasource="#application.datasource#">
										SELECT Vendor_ID, Vendor_Name
										FROM Vendor_Master
										WHERE Vendor_ID = '#pgVendorID#'
									</cfquery>
									</cfif>
									<cfif (qGetVendorID.RecordCount NEQ 0)>
										#qGetVendorID.Vendor_Name#(#qGetVendorID.Vendor_ID#)<br>
									</cfif>
								</cfif>
								<a href="##" onClick="searchVendor();">#actiontext("Select Vendor")#</a>
								<input type="hidden" name = "VendorID" value= "#pgVendorID#" />
							</td>
					</tr>
					<tr id="showFieldsVendor">
						<td>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Vendor Default Billback Closing Method:</strong>
						</td>
						<td>
							<select name="VendorDefaultClosingMethodID" STYLE="WIDTH:120px" class="bb_closing_meth">
								<cfloop query="qBillbackClosingMethods">
								<option value="#iBillback_Closing_Method_ID#" <cfif qBillbackClosingMethods.iBillback_Closing_Method_ID eq FORM.VendorDefaultClosingMethodID>selected</cfif>>
									#vchBillback_Closing_Method_DESC#
								</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
			</div>

			<div id="hideFieldsVendor" <cfif (isDefined("FORM.VendorOverrideForSyscoEDI") AND FORM.VendorOverrideForSyscoEDI EQ "1")>style="display:none;"</cfif>>
				<input type="hidden" name = "hVendorID" value= "" />
				<input type="hidden" name = "hVendorDefaultClosingMethodID" value= "0" /><br>
			</div>
		</td>
<!--- END :: D39300 : AFP EDI -- Corporate Payee selection -- CF side--->
<!--- START :: D41281: Sysco EDI - negative invoices --->
	<tr>
		<td>
		<strong>Sysco EDI - load negative invoices as ADJ and PAID:</strong>
		</td>
		<td>
			<input name="SyscoEDIFilterNegativeInvoices" type="checkbox" value="1" <cfif FORM.SyscoEDIFilterNegativeInvoices eq 1>checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<strong>
				US Foods EDI - load negative invoices as ADJ and PAID:
			</strong>
		</td>
		<td>
			<input name="USFoodsEDIFilterNegativeInvoices" type="checkbox" value="1" <cfif FORM.USFoodsEDIFilterNegativeInvoices eq 1>checked</cfif> />
		</td>
	</tr>
<!--- END :: D41281: Sysco EDI - negative invoices --->
<!---74703 :: Create setting 3rd Party Upload  - load negative invoices as ADJ and PAID START--->
	<tr>
		<td>
			<strong>
				3rd Party Upload  - load negative invoices as ADJ and PAID:
			</strong>
		</td>
		<td>
			<input name="III_Party_Load_Negative_Invoices_ADJ_and_PAID" type="checkbox" value="1" <cfif FORM.III_Party_Load_Negative_Invoices_ADJ_and_PAID eq 1>checked</cfif> />
		</td>
	</tr>
<!---74703 :: Create setting 3rd Party Upload  - load negative invoices as ADJ and PAID END--->
<!--- D43360 ::  Create setting to Concatenate fields for USF EDI load START--->
	<tr>
		<td>
			<strong>USFS Concat Program Alias Description:</strong>
		</td>
		<td>
			<input name="USFSConcatProgramAliasDesc" type="checkbox" value="1" <cfif FORM.USFSConcatProgramAliasDesc  eq 1>checked</cfif> />
		</td>
	</tr>
<!--- D43360 ::  Create setting to Concatenate fields for USF EDI load END --->
<!--- D44290  ::  CF display setting to create BB per Associated shipto and program - EDI & User upload START--->
	<tr>
		<td>
			<strong>EDI create BB per Associated Shipto:</strong>
		</td>
		<td>
			<input name="EDICreateBBPerAssociatedShipto" type="checkbox" value="1" <cfif FORM.EDICreateBBPerAssociatedShipto  eq 1>checked</cfif> />
		</td>
	</tr>
<!--- D44290 ::  CF display setting to create BB per Associated shipto and program - EDI & User upload END --->
<!--- START: 48482 - Duplicate Sysco EDI External ID's/Anand Rao/03-Mar-2014 --->
	<tr>
		<td>
			<strong>Sysco concatenate Xref and Description for Operator Alias:</strong>
		</td>
		<td>
			<input name="SyscoConcatProgramAliasID" type="checkbox" value="1" <cfif FORM.SyscoConcatProgramAliasID  eq 1>checked</cfif> />
		</td>
	</tr>
<!--- END: 48482 - Duplicate Sysco EDI External ID's/Anand Rao/03-Mar-2014 --->


<!--- START: 39812	Validate EDI files for potential billback duplicate/Anand Rao/16-Jan-2014 --->
<cfif appSettings.getThirdPartyBBUpload() NEQ 0>
	<tr>
		<td colspan="2">
			<br>
			<font color="navy" size=2>
				<b>
					<span class="subheading" title="When 'Enable EDI billback duplicate check' is ON, we will check for duplicates.  When checking for duplicates consider billbacks from any status (WIP, RFA, Approved, Payment Request, Paid) and that was created within the last year.  Checking for duplicates should be based on the below settings that are check marked.  If a duplicate is found, the billback will have a flag indicating it is a duplicate.  The user will have a field within the BB Search tool to find the duplicates." style="cursor:pointer;">
						EDI Duplicate Rules:
					</span>
				</b>
			</font>
			<br>
		</td>
	</tr>
	<tr>
		<td>
			<strong>
				Enable EDI #stBBLabels.Billback# duplicate check:
			</strong>
		</td>
		<td>
			<input name="EnableBBDupCheck" type="checkbox" value="1" <cfif FORM.EnableBBDupCheck eq 1>checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<strong>
				Same Dollar Amount:
			</strong>
		</td>
		<td>
			<input name="SameDollarAmount" type="checkbox" value="1" <cfif FORM.SameDollarAmount eq 1>checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<strong>
				Same #stBBLabels.Reference_Number#:
			</strong>
		</td>
		<td>
			<input name="SameReferenceNumber" type="checkbox" value="1" <cfif FORM.SameReferenceNumber eq 1>checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<strong>
				Same #stBBLabels.Payee# :
			</strong>
		</td>
		<td>
			<input name="SamePayee" type="checkbox" value="1" <cfif FORM.SamePayee eq 1>checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<strong>Same Start & End Dates:</strong>
		</td>
		<td>
			<input name="SameStartEndDates" type="checkbox" value="1" <cfif FORM.SameStartEndDates eq 1>checked</cfif> />
		</td>
	</tr>
</cfif>
<!--- END: 39812	Validate EDI files for potential billback duplicate/Anand Rao/16-Jan-2014 --->
<cfelse>
	<input type="hidden" name = "III_party_Xref_Enabled" value= "#FORM.III_party_Xref_Enabled#" />
	<input type="hidden" name = "Operator_Xref_Enabled" value= "#FORM.Operator_Xref_Enabled#" />
	<input type="hidden" name = "Allow_Multiple_Operator_Xref" value= "#FORM.Allow_Multiple_Operator_Xref#" />
	<input type="hidden" name = "IS_ReferenceNum" value= "#FORM.IS_ReferenceNum#" />
	<!---32530--->
	<input type="hidden" name = "one_pgm_per_bb" value= "#FORM.one_pgm_per_bb#" />
	<input type="hidden" name = "load_claim_price" value= "#FORM.load_claim_price#" />
	<input type="hidden" name = "alias_uses_eshark" value= "#FORM.alias_uses_eshark#" />
	<input type="hidden" name = "Operator_Auto_Add" value= "#FORM.Operator_Auto_Add#" />
	<input type="hidden" name = "SyscoUseProgramXref" value= "#FORM.SyscoUseProgramXref#" />
	<input type="hidden" name = "USFSUseProgramXref" value= "#FORM.USFSUseProgramXref#" />
	<input type="hidden" name = "OverrideUseProgramXref" value= "#FORM.OverrideUseProgramXref#" />
	<input type="hidden" name = "SyscoUseMfgProductID" value= "#FORM.SyscoUseMfgProductID#" />
	<input type="hidden" name = "VendorOverrideForSyscoEDI" value= "#FORM.VendorOverrideForSyscoEDI#" />
	<input type="hidden" name = "VendorID" value= "#FORM.VendorID#" />
	<input type="hidden" name = "VendorDefaultClosingMethodID" value= "#FORM.VendorDefaultClosingMethodID#" />
	<input type="hidden" name = "EnableBBDupCheck" value= "#FORM.EnableBBDupCheck#" />
	<input type="hidden" name = "SameDollarAmount" value= "#FORM.SameDollarAmount#" />
	<input type="hidden" name = "SameReferenceNumber" value= "#FORM.SameReferenceNumber#" />
	<input type="hidden" name = "SamePayee" value= "#FORM.SamePayee#" />
	<input type="hidden" name = "SameStartEndDates" value= "#FORM.SameStartEndDates#" />
	<input type="hidden" name = "SyscoEDIFilterNegativeInvoices" value= "#FORM.SyscoEDIFilterNegativeInvoices#" />
	<input type="hidden" name = "USFoodsEDIFilterNegativeInvoices" value= "#FORM.USFoodsEDIFilterNegativeInvoices#" /><!---D43360 --->
	<input type="hidden" name = "III_Party_Load_Negative_Invoices_ADJ_and_PAID" value= "#FORM.III_Party_Load_Negative_Invoices_ADJ_and_PAID#" /><!---74703--->
	<input type="hidden" name = "III_P_Upload_Business_Segment" value= "#FORM.III_P_Upload_Business_Segment#" />
	<input type="hidden" name = "Third_Party_Upload_Ship_To_Column" value= "#FORM.Third_Party_Upload_Ship_To_Column#" />
	<input type="hidden" name = "III_P_Upload_Use_Closing_Method" value= "#FORM.III_P_Upload_Use_Closing_Method#" />
	<input type="hidden" name = "III_P_Upload_Use_Holding_Pen" value= "#FORM.III_P_Upload_Use_Holding_Pen#" />

</cfif>
	<tr>
		<td></td>
		<td></td>
		<td  align="center">
			<br>
			<CF_smallLink title = "save" url = "##" parameters = "onClick=""javascript: return BBLabelsSubmitForm();""">
		</td>
	</tr>
</table>
</cfoutput>
<input name="BBLabelsSubmitted" type="hidden" value="0" />
</form>