<style>
	.topborder
	{
		border-top: dotted 1px orange;
	}
</style>

<cfif isDefined("Form") AND  isStruct(Form)>
	<CFSET URL = fORM />
</cfif>

<cfset appSettings = application.appSettingsGet />
<cfset compInfo = CreateObject("component","components.programcomponents.programcomponents") />

<cfif isDefined("Component_Name_ID") AND len(trim(Component_Name_ID)) GT 0 AND Component_Name_ID GT 0>
	<cfset CompDetails = compInfo.GetComponentDetails(Component_Name_ID, URL.Discount_Type_ID)>
	<cfparam name="Caller" default="" />
	<cfparam name="URL.GL_Account_ID" default="" />
	<cfparam name="URL.VendorSelection" default="" />
	<cfparam name="URL.Vendor_Master_ID" default="0" />
	<cfparam name="URL.FormName" default="" />
	<cfparam name="URL.bHideFromLSAutoPay" default="0" />
	<cfparam name="URL.Generic_Type" default="" />
	<cfparam name="URL.Payee_Selection" default="" />
	<cfparam name="url.Growth_Auto_Pay" default="0" >
	<cfparam name="url.programId" default="0" >
	<cfparam name="url.Business_Segment_ID" default="0" >
	<cfparam name="ModifyDeletedPrograms" default="0" >
	<cfparam name="Complen" default="0" >
	<cfparam name="URL.Program_Upload" default="0">

	<!--- Set calling page --->
	<cfswitch expression="#Discount_Type_ID#">
		<cfcase value="1">
			<cfset Caller = "Fixed">
		</cfcase>
		<cfcase value="2">
			<cfset Caller = "Rebate">
		</cfcase>
		<cfcase value="3">
			<cfset Caller = "LumpSum">
		</cfcase>
		<cfcase value="4">
			<cfset Caller = "Growth">
		</cfcase>
	</cfswitch>
<table border="0" cellpadding="3" cellspacing="0" width="100%" valign="top">
<tr BGCOLOR="eeeeee" colspan="2" valign="top">
	<td STYLE="border-top:solid 1px blue;" colspan="2">Component Details</td>
</tr>
<tr>
	<td valign="top" colspan="2" class="topborder">
		<input type="hidden" name="Claim_Mech" id="Claim_Mech" value="1">
		<!--- Dev Note: KAL : D13043: Calim Mechanism for Fixed price page --->
		<cfparam name="FORM.ClaimMechanic" 	default="#ClaimMechanics#">
		<cfif appSettings.getClaims_at_Comp_Level() AND EligibleRecordCount GT 0>
			<cf_claim_mechanic_selection
				Default_Claim_Selection = "#ClaimMechanics#"
				Template_ID = "#ProgramType_ID#"
				Component_Name_ID = "#Component_Name_ID#"
				Edit_Selection = "#FORM.ClaimMechanic#"
				Is_Revision = "#Is_a_Revision#"
				Allow_Auto_Payment = "#appSettings.getBBAutoReport()#"
				Discount_Type_ID = "#Discount_Type_ID#"
				Allow_Off_Invoice = "#CompDetails.Off_Invoice_On#"
				Auto_pay = "#url.Growth_Auto_Pay#"><!--- D35731 Growth Auto Pay --->
		<cfelse>
			<cfquery name="GetAutoPayClaimMech" datasource="#application.datasource#">
				SELECT Top 1 Payment_Type_Id
				FROM Payment_Type
				WHERE is_Auto_pay = 1
				AND  Payment_Type_Name NOT LIKE '%Credit%'
			</cfquery>
			<cfoutput><input type="hidden" name="Claim_Mechanics" id="Claim_Mechanics" value="#GetAutoPayClaimMech.Payment_Type_Id#"></cfoutput>
		</cfif>
			<!---D37702 :: Brokerage template type doesn't allow vendor select --->
			<cfif NOT URL.bHideFromLSAutoPay>
				<cfdiv bind="url:/Common_Files/contracts/claim_mech_info.cfm?Claim_Mechanics_ID={Claim_Mechanics}&ProgramType_ID=#ProgramType_ID#&Discount_Type_ID=#URL.Discount_Type_ID#&Vendor_Master_ID=#url.Vendor_Master_ID#&Caller_Split_For_Auto_Pay=1&VendorSelection=#URL.VendorSelection#&Caller=#Caller#&bHideFromLSAutoPay=#URL.bHideFromLSAutoPay#&Generic_Type=#URL.Generic_Type#&Business_Segment_ID=#url.Business_Segment_ID#&Program_Upload=#url.Program_Upload#&Component_Name_ID=#Component_Name_ID#&programId=#url.programId#" ID="ClaimMech"/>
			</cfif>
		</td>
	</tr>
	<!--- 62343 8.0 - Blended Rate, CF START--->
	<cfif appSettings.get_Setting('Blended_Rate') eq '1'>
	<cfquery name="GetCompInfo" datasource="#application.datasource#">
	SELECT 	*
	FROM 	Program_Rebates_Component_Name
	WHERE 	Program_Rebates_Component_Name_ID = #Component_Name_ID#
	</cfquery>
	<cfif GetCompInfo.Rebate_type EQ 7>
		<cfset Blended_Rate_On = 1>	
	<cfelse>
		<cfset Blended_Rate_On = 0>
	</cfif>
	<cfoutput>
	<cfif Complen>
		<script>
			document.dataForm.Prg_Has_Blended_Rate_Comp.value = #Blended_Rate_On#;
		</script>
	</cfif>
	<input name="Blended_Rate_On" type="Hidden"  value="#Blended_Rate_On#" ></cfoutput>
	<cfif GetCompInfo.Rebate_type EQ 7>
	<tr>
		<td colspan="2">
			<hr color="orange" width="100%">
			<strong>Calculation Period</strong>
		</td>
	</tr>
	<tr>
		<td>Start Date</td>
		<td><input name="from_date" id="from_date" type="text" class="date" value="" ></td>
	</tr>
	<tr>
		<td>End Date</td>
		<td><input name="to_date"   type="text" class="date" tabindex="9" value=""></td>
		<cfoutput><input name="todays_date"   type="hidden" value="#DateFormat(Now(),'m/dd/yyyy')# "></cfoutput>
	</tr>
	</cfif>
      <cfelse>
        <input name="Blended_Rate_On" type="Hidden"  value="0" >
	</cfif>
	<!--- 62343 8.0 - Blended Rate, CF END--->
<cfif appSettings.getGL_Account_On() AND appSettings.getGL_Account_Required_for_Comp()>
<!--- GL query --->
	<!--- Dev Note: Kal; D42585: Program dates as fiscal periods --->
	<cfset qGetFiscalDatesforYear = queryNew("") />
	<!--- Dev Note:- (44811)  Removed the join on the fiscal_year as both "template date types" (Free form and Fiscal year)	use contract dates to pick the GL. --->
	<cfquery name="qGetFiscalDatesforYear" datasource="#application.datasource#">
		SELECT 	Contract_Start_Date,	Contract_End_Date,CM.Fiscal_Year
		FROM Contract_Main CM
		WHERE CM.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.programId#" />
		<cfif ! ModifyDeletedPrograms>AND CM.Deleted = 0</cfif><!--- D50074 :: Viewing and Editing prior program versions  --->
	</cfquery>
	<cfquery name="GetGLs" datasource="#application.datasource#">
		SELECT GL_Account.GL_Account_ID, Gl_Account, GL_Account_Desc
		FROM GL_Account
		INNER JOIN GL_Component_Mapping
		ON GL_Component_Mapping.GL_Account_ID = GL_Account.GL_Account_ID
		AND GL_Component_Mapping.Component_Name_ID = '#Component_Name_ID#'
		AND GL_Component_Mapping.Discount_Type_ID = '#Discount_Type_ID#'
		AND <cfqueryparam cfsqltype="CF_SQL_DATE" value="#qGetFiscalDatesforYear.Contract_Start_Date#" /> >= GL_Account.Start_Date
		AND <cfqueryparam cfsqltype="CF_SQL_DATE" value="#qGetFiscalDatesforYear.Contract_Start_Date#" /> <= GL_Account.End_Date
		ORDER BY GL_Account
	</cfquery>
	<!--- GL drowndown --->
	<tr>
		<td colspan="2"  style="topborder">
			<cfif GetGLs.Recordcount GT 1>
				<select name="GL_Account_ID">
					<option value="0">*** PICK A <cfoutput>#Application.GLAccountLabel#</cfoutput> ***</option><!---D42774 --->
				<cfoutput query="GetGLs">
					<option value="#GL_Account_ID#" <cfif GL_Account_ID eq URL.GL_Account_ID>SELECTED</cfif>>#GL_Account# (#GL_Account_Desc#)</option>
				</cfoutput>
				</select>
			<cfelseif GetGLs.Recordcount EQ 1>
				<cfoutput> #Application.GLAccountLabel#: #GetGLs.GL_Account_Desc# (#GetGLs.GL_Account#)</cfoutput>
				<input type="hidden" name="GL_Account_ID" value="<cfoutput>#GetGLs.GL_Account_ID#</cfoutput>">
			<cfelse>
				No  <cfoutput>#Application.GLAccountLabel#</cfoutput> for this component
				<input type="hidden" name="GL_Account_ID" value="0">
			<!--- There are GLs for the comp --->
			</cfif>
		</td>
	</tr>
<!--- The GL App setting is on --->
<cfelse>
	<input type="hidden" name="GL_Account_ID" value="0">
</cfif>
	<tr style="border-top: 1px dotted orange">
		<!--- Accrual --->
		<cfif appSettings.getShow_Component_Accrual()>
			<cfif CompDetails.Accrual_On IS 1>
				<td  class="topborder">Accrual On</td>
			<cfelseif CompDetails.Accrual_On IS 0>
				<td  class="topborder">Accrual Off</td>
			</cfif>
		</cfif>
		<!--- Floor pricing --->
		<cfif appSettings.getShow_Component_Floor_Pricing()>
			<cfif CompDetails.Floor_Pricing_On IS 1>
			<td  class="topborder">Floor Pricing On</td>
			<cfelseif CompDetails.Floor_Pricing_On IS 0>
				<td  class="topborder">Floor Pricing Off</td>
			</cfif>
		</cfif>
	</tr>
	<tr style="border-top: 1px dotted orange">
		<!--- Brokerage --->
		<cfif appSettings.getBrokerage_Functionality_On()>
			<cfif CompDetails.Exclude_Brokerage IS 1>
				<td  class="topborder">Exclude Brokerage</td>
			<cfelseif CompDetails.Exclude_Brokerage IS 0>
				<td  class="topborder">Include Brokerage</td>
			</cfif>
		</cfif>
		<!--- Off invoice --->
		<cfif CompDetails.Off_Invoice_On IS 0>
			<td  class="topborder">Restrict Off Invoice</td>
		<cfelseif CompDetails.Off_Invoice_On IS 1>
			<td class="topborder">Allow Off Invoice</td>
		</cfif>
	</tr>
</table>
<script>
/*D33254:Not able to search for program in billback START */
if (document.getElementById("component_information")) {
		document.getElementById("component_information").style.display = "Block";
}
/*D33254:Not able to search for program in billback END */
/*62343 8.0 - Blended Rate, CF START */
setTimeout(function() {
	jQuery(".date").datepicker({
	    dateFormat: "m/dd/yy",
	    changeMonth: true,
	    changeYear: true,
	    showMonthAfterYear: true,
	    maxDate: 0 ,
	    onSelect: function( selected ) {
	        // change date limit based on selected value
	        if ( jQuery(this).attr("name") === "from_date" )
	            jQuery("input[name=to_date]").datepicker("option", "minDate", selected);
	        else
	            jQuery("input[name=from_date]").datepicker("option", "maxDate", selected);
	    }
	});
},100);
/*62343 8.0 - Blended Rate, CF  END */
</script>

</cfif>