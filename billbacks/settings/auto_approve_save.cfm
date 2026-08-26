<!---
***********************************************************************
Created By: Tim Ford
File Path: /billbacks/settings/auto_approve_save.cfm
Created Date: 02/01/2010
Description: This file is responsible for saving billback auto approve settings
***********************************************************************
--->

<cfquery name="UpdateBillbackAutoApproveSettings" datasource="#application.datasource#">
	UPDATE 	Billback_Settings
	SET 	Auto_Approve_On = <CFIF FORM.AutoApprove_not_allowed EQ 1>0<cfelse>1</cfif>, 
			Auto_Approve_Amount = <cfif FORM.AutoApprove_not_allowed EQ 1>null<cfelse>'#form.Auto_Approve_Amount#'</cfif>,
			Auto_Approve_BB_Types = <cfif FORM.AutoApprove_not_allowed EQ 1>null<cfelse>'#FORM.rdo_Auto_Approve_BB_Types#'</cfif>,
			Auto_Approved_BB_Status = <cfif FORM.AutoApprove_not_allowed EQ 1>null<cfelse>'#FORM.sel_Auto_Approved_BB_Status#'</cfif>,
			Auto_Appr_Reference_Exclusive = #form.Auto_Appr_Reference_Exclusive#,
			Auto_Appr_Consider_Created_Date = #form.Auto_Appr_Consider_Created_Date#,
			Auto_Appr_Age = <cfif not len(trim(form.Auto_Appr_Age))>0<cfelse>#form.Auto_Appr_Age#</cfif>,
			Auto_Appr_Divested_Items = #form.Auto_Appr_Divested_Items#,
			Auto_Appr_Unknown_Items = #form.Auto_Appr_Unknown_Items#,
			Auto_Appr_Payee_Operator = #form.Auto_Appr_Payee_Operator#,
			Auto_Appr_Payee_Distributor = #form.Auto_Appr_Payee_Distributor#,
			Auto_Approve_Dummy_Prog = #FORM.Auto_Approve_Dummy_Prog#,
			Auto_Approve_Updated_By = '#request.AccessStructure.User_ID#',					
			Auto_Approve_Updated_Date				=	getdate(),
			Auto_Approve_CM_OFF = <CFIF FORM.AutoApproveCMOFF EQ 1>1<cfelse>0</cfif> 
</cfquery>

<cfquery name="qLogBillbackAutoApproveSettings" datasource="#application.datasource#">
	INSERT INTO Billback_Settings_Auto_Approve_Log
		(
			Auto_Approve_On, 
			Auto_Approve_Amount, 
			Auto_Approve_BB_Types, 
			Auto_Approved_BB_Status,
			Auto_Appr_Reference_Exclusive,
			Auto_Appr_Consider_Created_Date,
			Auto_Appr_Age,
			Auto_Appr_Divested_Items,
			Auto_Appr_Unknown_Items,
			Auto_Appr_Payee_Operator,
			Auto_Appr_Payee_Distributor,
			Auto_Approve_Dummy_Prog,
			Auto_Approve_Updated_By,
			Auto_Approve_Updated_Date,
			Auto_Approve_CM_OFF
		)
	SELECT 	Auto_Approve_On, 
			Auto_Approve_Amount,
			Auto_Approve_BB_Types,
			Auto_Approved_BB_Status,
			Auto_Appr_Reference_Exclusive,
			Auto_Appr_Consider_Created_Date,
			Auto_Appr_Age,
			Auto_Appr_Divested_Items,
			Auto_Appr_Unknown_Items,
			Auto_Appr_Payee_Operator,
			Auto_Appr_Payee_Distributor,
			Auto_Approve_Dummy_Prog,
			Auto_Approve_Updated_By,
			Auto_Approve_Updated_Date,
			Auto_Approve_CM_OFF
	FROM	Billback_Settings
</cfquery>

<!--- Payee_Type: 1 = Distributor, 2 = Operator --->

<!---///////////////////////////////////////////////////////////////////
remove entries from exceptions if auto approve operator was not selected
or auto approve operator was selected and operator exceptions were added
////////////////////////////////////////////////////////////////////--->
<cfif (form.Auto_Appr_Payee_Operator eq "0") or form.Auto_Appr_Payee_Operator eq "1">

	<!---before we delete we have to log the exceptions--->
	<cfquery name="qLogOperatorExceptions" datasource="#application.datasource#">
		INSERT INTO Auto_Appr_Payee_Exception_Log
			(Payee_Type, Operator_ID, Deleted_By)
		SELECT	2, Operator_ID, '#request.AccessStructure.User_ID#'
		FROM	Auto_Appr_Payee_Exception
		WHERE	Payee_Type = 2
		<cfif form.Auto_Appr_Payee_Operator eq "1" and len(trim(form.Operator_List))>
		AND		Operator_ID NOT IN (#form.Operator_List#)
		</cfif>		
	</cfquery>
	
	<cfset useLakebaseForqDeleteOperatorExceptions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("auto_appr_payee_exception")>
<cfif useLakebaseForqDeleteOperatorExceptions>
	<cftry>
		<cfset application.oLakebase.deleteRows("auto_appr_payee_exception", {
			"payee_type" = "eq.2"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteOperatorExceptions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteOperatorExceptions>
<cfquery name="qDeleteOperatorExceptions" datasource="#application.datasource#">
		DELETE 	FROM Auto_Appr_Payee_Exception
		WHERE	Payee_Type = 2
	</cfquery>
</cfif>
	
</cfif>

<!---now add them if they exist--->
<cfif form.Auto_Appr_Payee_Operator eq "1" and len(trim(form.Operator_List))>

	<cfloop index="indx" list="#form.Operator_List#">
		
		<cfset useLakebaseForqAddOperator = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("auto_appr_payee_exception")>
<cfif useLakebaseForqAddOperator>
	<cftry>
		<cfset application.oLakebase.insertRow("auto_appr_payee_exception", {
			"payee_type" = "2",
			"operator_id" = "#indx#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqAddOperator = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAddOperator>
<cfquery name="qAddOperator" datasource="#application.datasource#">
			INSERT INTO Auto_Appr_Payee_Exception
				(Payee_Type, Operator_ID)
			VALUES
				(2, #indx#)
		</cfquery>
</cfif>
	
	</cfloop>
		
</cfif>

<!---//////////////////////////////////////////////////////////////////////
remove entries from exceptions if auto approve distributor was not selected
or auto approve distributor was selected and operator exceptions were added
///////////////////////////////////////////////////////////////////////--->
<cfif (form.Auto_Appr_Payee_Distributor eq "0") or form.Auto_Appr_Payee_Distributor eq "1">

	<!---before we delete we have to log the exceptions--->
	<cfquery name="qLogDistributorExceptions" datasource="#application.datasource#">
		INSERT INTO Auto_Appr_Payee_Exception_Log
			(Payee_Type, Distributor_ID, Deleted_By)
		SELECT	1, Distributor_ID, '#request.AccessStructure.User_ID#'
		FROM	Auto_Appr_Payee_Exception
		WHERE	Payee_Type = 1
		<cfif form.Auto_Appr_Payee_Distributor eq "1" and len(trim(form.Distributor_List))>
		AND		Distributor_ID NOT IN (#listQualify(form.Distributor_List, "'")#)
		</cfif>		
	</cfquery>
	
	<cfset useLakebaseForqDeleteDistributorExceptions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("auto_appr_payee_exception")>
<cfif useLakebaseForqDeleteDistributorExceptions>
	<cftry>
		<cfset application.oLakebase.deleteRows("auto_appr_payee_exception", {
			"payee_type" = "eq.1"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteDistributorExceptions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteDistributorExceptions>
<cfquery name="qDeleteDistributorExceptions" datasource="#application.datasource#">
		DELETE 	FROM Auto_Appr_Payee_Exception
		WHERE	Payee_Type = 1
	</cfquery>
</cfif>
</cfif>

<!---now add them if they exist--->
<cfif form.Auto_Appr_Payee_Distributor eq "1" and len(trim(form.Distributor_List))>

	<cfloop index="indx" list="#form.Distributor_List#">
	
		<cfset useLakebaseForqAddDistributor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("auto_appr_payee_exception")>
<cfif useLakebaseForqAddDistributor>
	<cftry>
		<cfset application.oLakebase.insertRow("auto_appr_payee_exception", {
			"payee_type" = "1",
			"distributor_id" = "#indx#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqAddDistributor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAddDistributor>
<cfquery name="qAddDistributor" datasource="#application.datasource#">
			INSERT INTO Auto_Appr_Payee_Exception
				(Payee_Type, Distributor_ID)
			VALUES
				(1, '#indx#')
		</cfquery>
</cfif>
		
	</cfloop>
	
</cfif>

<CFLOCATION URL="auto_approve.cfm" ADDTOKEN="No">
