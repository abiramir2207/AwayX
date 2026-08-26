<!-----------------------------------------------------------------------------

FILE NAME:		save_Closing_Methods.cfm
DESCRIPTION:	This file displays the settings for BB closing Methods
              [Done for D18281]
CREATED BY:		Anand Rao/27-May-09
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

------------------------------------------------------------------------------>


<CFPARAM NAME="FORM.BBClosingMethod_ID" DEFAULT = "0" />
<CFPARAM NAME="FORM.chkEnabled" DEFAULT = "0" />
<CFPARAM NAME="FORM.selBBStatus"  DEFAULT ="4" />
<CFPARAM NAME="FORM.rdoDeleted" DEFAULT = "0" />
<CFPARAM NAME="FORM.Payee_Selection" DEFAULT = "" />
<CFPARAM NAME="URL.BCID" 		DEFAULT = "0" />
<CFPARAM NAME="URL.setDefault" 	DEFAULT = "0" />
<CFPARAM NAME="FORM.Exclude_From_Payment_History" 	DEFAULT = "0" />
<CFPARAM NAME="FORM.Vendor_Required" 						 	DEFAULT = "0" />
<CFPARAM NAME="FORM.require_bank_info" DEFAULT = "0" />
<CFPARAM NAME="FORM.Allow_operator_payee" DEFAULT = "0" />
<CFPARAM NAME="FORM.Display_In_Advance_QP" DEFAULT = "0" /><!---97929--->
<!---97929 QUICK PAY START--->
	<!--- set the default closing method--->
	<CFIF URL.setDefault>
		<!---first turn off all defaults--->
		<CFQUERY NAME="qSetAllDefaultsOff" datasource="#application.datasource#">
	  		UPDATE 	Billback_Closing_Methods
		SET	 		<CFIF URL.setDefault eq 1>	bDefault = 0 <cfelse> qpDefault = 0 </cfif>
							,Updated_By = '#request.AccessStructure.User_ID#'
							,Updated_On = getdate()
		</CFQUERY>
		<!--- Update Default Closing Method --->
		<CFQUERY NAME="qSetDefaultClosingMethod" datasource="#application.datasource#">
	  		UPDATE 	 Billback_Closing_Methods
			SET	 	<CFIF URL.setDefault eq 1>	bDefault = 1 <cfelse> qpDefault = 1 </cfif>
							,Updated_By = '#request.AccessStructure.User_ID#'
							,Updated_On = getdate()
			WHERE  	 iBillback_Closing_Method_ID = #URL.BCID#
		</CFQUERY>
		<CFLOCATION URL="BB_Closing_Methods.cfm" ADDTOKEN="No">
	</CFIF>
<!---97929 QUICK PAY END--->
	<CFIF FORM.BBClosingMethod_ID NEQ 0>		
		<!--- Update the record --->
		<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
	  		UPDATE 	Billback_Closing_Methods
			SET	 		bEnabled = <cfqueryparam cfsqltype="cf_sql_bit" value='#FORM.chkEnabled#'>
							,tiAutoPay_BB_Status = <cfqueryparam cfsqltype="cf_sql_integer" value='#FORM.selBBStatus#'>
							,Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value='#FORM.rdoDeleted#'>
							,Payee_Type = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Payee_Selection#">
							,Exclude_From_Payment_History = <cfqueryparam cfsqltype="cf_sql_bit" value="#Form.Exclude_From_Payment_History#">
							,Require_Bank_Info = <cfqueryparam cfsqltype="cf_sql_bit" value="#Form.Require_Bank_Info#">    <!--- 55346 --->
							,Updated_By = '#request.AccessStructure.User_ID#'
							,Updated_On = getdate()
							,Vendor_Required = <cfqueryparam cfsqltype="cf_sql_bit" value="#Form.Vendor_Required#">
							,Allow_operator_payee = <cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.allow_operator_payee#">
							,Display_In_Advance_QP  = <cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.Display_In_Advance_QP#"><!---97929--->
			WHERE  	iBillback_Closing_Method_ID = #FORM.BBClosingMethod_ID#
		</CFQUERY>
		<CFLOCATION URL="BB_Closing_Methods.cfm" ADDTOKEN="No">
	<CFELSE>
		<CFLOCATION URL="BB_Closing_Methods.cfm" ADDTOKEN="No">
	</CFIF>