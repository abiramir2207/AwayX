<!------ groupLevelAccessValuesAction.cfm ----->
<CFPARAM NAME="Form.Profile_ID" DEFAULT="0">
<CFPARAM NAME="Total_LS_Approval_Amount"	DEFAULT="0">	
<CFPARAM NAME="Inactive_LS_Approval_Amount"	DEFAULT="0">
<CFPARAM NAME="Lump_Sum_Approval_Amount"	DEFAULT="0">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = application.appSettingsGet>

<!--- Only do this for spending cap values OR if "ApproveLSComponentByProfile" is ON --->
<cfif appSettings.getApprovalSpendingCapOn() or appSettings.getApproveLSComponentByProfile()>

	<!---Deletes all values for active, non-deleted Lump sum approval amounts--->
	<cfquery name="DeleteAllPriorLSValues" datasource="#application.datasource#">
	DELETE FROM Profile_LS_Approval
	WHERE 	Profiles_ID IN (#Form.Profile_ID#) AND
			Program_Lump_Sum_Name_ID IN 
				(	Select Program_Lump_Sum_Name_ID 
					FROM Program_Lump_Sum_Name 
					WHERE Deleted = 0 AND 
						  Active = 1)
	</cfquery>

<!--- Do this for different profiles --->
<CFLOOP LIST="#Form.Profile_Id#" INDEX="ProfileId">
<!--- Loops through all the form variables and  saves the settings --->
<CFLOOP INDEX="Item" LIST="#Form.FieldNames#" DELIMITERS=",">		
	<!---Lump sum approval amounts--->
	<cfif Left(Item,22) IS "PROGRAM_LUMP_SUM_NAME_">
		<cfset VarLen = len(Item)>
		<cfset IDs_Only = right(item,(VarLen - 22))>
		<cfset IDs_Only_len = len(IDs_Only)>
		<cfset Underscorelocation  = find("_",IDs_Only)>
		<cfset Program_Lump_Sum_Name_ID = right(IDs_Only, (IDs_Only_len - Underscorelocation))>	

		<cfquery name="EnterLSApprovalAmount" datasource="#application.datasource#">
		INSERT INTO Profile_LS_Approval
		(
			Program_Lump_Sum_Name_ID,
			Profiles_ID,
			Approval_Amount
		)
		VALUES
		(
			#Program_Lump_Sum_Name_ID#,
			#ProfileId#,
			'#evaluate(item)#'
		)
		</cfquery>

	</cfif>
</CFLOOP>
</CFLOOP>

<!--- Update the Amt. for Total LS,Inactive LS and LS Approval --->
	<cfquery name="updLSApprovalAmount" datasource="#application.datasource#">
		UPDATE Profiles_Settings
		SET Total_LS_Approval_Amount = '#Total_LS_Approval_Amount#',
				Inactive_LS_Approval_Amount = '#Inactive_LS_Approval_Amount#',
				Lump_Sum_Approval_Amount = '#Lump_Sum_Approval_Amount#'
		WHERE Profiles_ID IN (#Form.Profile_ID#)
	</cfquery>
</cfif>

<script language="JavaScript">
window.close();
</script>

