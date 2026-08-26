<!---
Script: Release_Programs.cfm
Date:	1/18/2007
Author:	Clarence Morse
Label:	11286
Description: The page will systemically release programs which have reached their auto-release
			 date (as defined in the template (send release settlement (n) days after expiration).
			 Logic-wise: This query will compare today's date to (contract_main.contract_end_date
			 + template setting int) and then set the released flag to 2.

			 Should be scheduled prior to the morning transmit to customer.
--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfquery name="tempClear" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##TmpPrgList') IS NOT NULL
		DROP TABLE ##TmpPrgList
</cfquery>


<cfquery name="tempPrograms" datasource="#application.datasource#">
		SELECT DISTINCT Contract_Number
		INTO 	##TmpPrgList
		FROM		CONTRACT_MAIN
		INNER JOIN	Program_Control_Panel_Options PCPO
		ON			PCPO.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
		WHERE		Released = 0
		AND Contract_Main.Deleted = 0
		AND Contract_Status_Type_IDX >= 5
		AND PCPO.Release_Settlement = 1
		<cfif appSettings.get_Setting('Release_Settlement_Availability') eq '1'><!--- 1 = Only after ack, 2 = Always ---->
		AND (Sending_to_External_Client = 0 AND Sent_To_External_Client = 1 AND len(Contract_Reference_Number) <> 0 AND External_Client_Ack_Date IS NOT NULL )
		</cfif>
		<!--- It should be at least pcpo.rs_daystoclaim days since the program ended --->
		AND DATEDIFF(day,DATEADD(day, pcpo.rs_daystoclaim,contract_end_date),getdate()) >= 0
		<!--- Dev Note() - Add setting #1 (pcpo.rs_daystoclaim) and then subtract setting #2 (pcpo.RS_CreatedDaysGreater) from contract_end_date. Program should be created before that date --->
		AND (pcpo.RS_CreatedDaysFilter = 0 OR Contract_Created_Date <= DATEADD(day, pcpo.rs_daystoclaim - pcpo.RS_CreatedDaysGreater, contract_end_date))

		AND (Cancel_Sent_To_Client = 0 AND Manual_Cancel = 0)
		AND DATEDIFF(d, '9/7/2007', Contract_Created_Date) > 0
</cfquery>

<cfquery name="releasePrograms" datasource="#application.datasource#">
	UPDATE		CONTRACT_MAIN
	SET		Released = 2,
				Released_Date = GetDate(),
				Released_Sent_to_Client = 0,
				Released_Ack_From_Client = 0,
				Released_Sending_To_Client = 1
	FROM	CONTRACT_MAIN
	WHERE Contract_Number IN (SELECT Contract_Number FROM ##TmpPrgList)
</cfquery>