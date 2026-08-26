<html>
<head>
<title>Reopen Deduction</title>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
</head>
<body>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!--- Dev Note: Clay 9131: Allow Credit Write-Off (labels to match deduction type) --->
<CFPARAM NAME="Deduction_Label" Default="Deduction" />
<!---Gets data about deduction--->
<CFSET DateTimeHolder = now()>

<cfset useLakebaseForDeductionIsCredit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForDeductionIsCredit>
	<cftry>
		<cfset Deduction_IsCredit = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", { "deduction_id" = "eq.#Deduction_ID#", "select" = "is_credit,dd_closure_sent" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionIsCredit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionIsCredit>
	<cfset useLakebaseForDeduction_IsCredit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForDeduction_IsCredit>
	<cftry>
		<cfset Deduction_IsCredit = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"deduction_id" = "eq.#Deduction_ID#",
				"select" = "is_credit,dd_closure_sent"
			}), "is_credit,dd_closure_sent"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeduction_IsCredit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeduction_IsCredit>
<cfquery name="Deduction_IsCredit" datasource="#application.datasource#" >
	select is_credit, DD_Closure_Sent from deductions where deduction_id = '#Deduction_ID#'
	</cfquery>
</cfif>
</cfif>
<cfset Original_Deduction_ID = Deduction_ID />

<CFIF Deduction_IsCredit.Is_Credit EQ 1>
	<cfset Deduction_Label = "Credit" />
</CFIF>

<!--- DEV NOTE: DAA; D16341 --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfinclude template="/deductions/sql_Deduction_Info.cfm">
<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", { "profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
	<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
	SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
	</cfquery>
</cfif>

<CFQUERY NAME="CheckLocked" DATASOURCE="#Application.Datasource#">
	SELECT 	dd.Is_Locked,dd.Locked_By,u.Name_First,u.Name_Last 
	FROM 	Deductions dd RIGHT OUTER JOIN _Users u
	ON dd.Locked_By = u.User_ID
	WHERE 	dd.Deduction_ID = '#Deduction_ID#' AND
			dd.Deleted = 0
</CFQUERY>
<CFSET LockStatus = 0>
<CFIF CheckLocked.Is_Locked EQ 1 AND CheckLocked.Locked_BY NEQ request.AccessStructure.User_ID>				
	<CFSET LockStatus = 2>
<CFELSE>	
	<CFIF CheckLocked.Is_Locked EQ 1 AND CheckLocked.Locked_BY EQ request.AccessStructure.User_ID>
		<CFSET LockStatus = 1>
	<CFELSE>
		<CFSET LockStatus = 0>
	</CFIF>
</CFIF>

<cfset useLakebaseForDeductionInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForDeductionInfo>
	<cftry>
		<cfset DeductionInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", { "deduction_id" = "eq.#Deduction_ID#" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionInfo>
	<CFQUERY NAME="DeductionInfo" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Deductions WHERE Deduction_ID = '#Deduction_ID#'
	</CFQUERY>
</cfif>
<!--- END DEV NOTE: DAA; D16341 --->



<cfoutput>


<!--- DEV NOTE: DAA; D16341 --->
<!--- 
	CHECK DEDUCTION CONDITIONS TO ONLY ALLOW REOPEN IF CERTAIN CIRCUMSTANCES HAVE OCCURED, 
	IF CONDITIONS ARE NOT MET, NOTIFY THE USER AND REDIRECT THEM BACK TO THE DEDUCTIONS MAIN PAGE.
 --->
<cfset ReopenLinkEnabled = 0>
<CFIF 
	(Deduction_Info.DD_Status IS 4 OR Deduction_Info.DD_Status IS 9) AND
	(
		(Deduction_Info.DD_Closure_Sent EQ 0 AND Deduction_Info.Ack_received_Closure EQ 0 AND Deduction_Info.ReOpened EQ 0 AND Deduction_Info.DD_Reopened_Sent EQ 0 AND Deduction_Info.Ack_received_Reopen EQ 0) OR
		(Deduction_Info.DD_Closure_Sent EQ 1 AND Deduction_Info.Ack_received_Closure EQ 1 AND Deduction_Info.ReOpened EQ 0 AND Deduction_Info.DD_Reopened_Sent EQ 0 AND Deduction_Info.Ack_received_Reopen EQ 0)
	)
>
	<CFSET ReopenLinkEnabled = 1>
</CFIF>
<cfif appSettings.getDD_Show_ReOpen()>
 
<cfif
	ReopenLinkEnabled AND LockStatus EQ 1 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1 AND
	(
		Deduction_Info.DD_Status EQ 4 OR (Deduction_Info.DD_Status EQ 9 AND Deduction_Info.Is_Write_Off EQ 1) OR (Deduction_Info.DD_Status EQ 9 AND Deduction_Info.DD_Closure_Type EQ 1)
	)
	AND ( (appSettings.getDDReopenParent() EQ 0 AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1))
		OR (appSettings.getDDReopenParent() EQ 1 AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_ISParent EQ 1))
		)
>
<!--- END DEV NOTE: DAA; D16341 --->

<cfif isDefined("form.blnSubmit")>

	<cfset useLakebaseForDeductionInfo2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForDeductionInfo2>
		<cftry>
			<cfset DeductionInfo = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", { "deduction_id" = "eq.#Deduction_ID#" })
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDeductionInfo2 = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDeductionInfo2>
		<CFQUERY NAME="DeductionInfo" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Deductions WHERE Deduction_ID = '#Deduction_ID#'
		</CFQUERY>
	</cfif>
	<!-----
	11/18/2013: D40312: We no longer need Heinz special logic
	11/21/2006: Deepa, Label # D11017 - Heinz: Changes for deductions that are re-opened the same day as closed
	For (all clients other than Heinz) and (for Heinz if DD_Closure_Sent = 0),
		- Reset the deduction back to open status 
		- Reset sent flags for 1510 and 1700, ack received, reopen sent etc.
		- Reset the billback to approved status if closed by billback
		- add notes entry
	For Heinz If DD_Closure_Sent = 0, additional to the steps done above,
		- delete log entry for 1510, 900, 910 and 1700 for this deduction alone
	For Heinz If DD_Closure_Sent = 1, do old logic
		- Add J to the front of the deduction # 
		- Reset sent flags for 1510 and 1700
		For this deduction and all it's siblings and it's parent
			- add log entry for 1510, 900, 910 and 1700
			- update billback status to approved, and reset sent flags, and BB_Reopened_Multiplier t0 -1
			- add notes entry
	----->
	
	
	<cfset Deduction_ID = Original_Deduction_ID />
	
	<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager") />
	
	<CFIF ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1)><!--- Single DD or child only --->
	
		<cfset DeductionManager.ReopenDeduction(deductionId = Original_Deduction_ID) />
	
		<!------ 
		D16950 H. Re-open should update the parent balance amount on parent credits
		Following update of ParentBalanceAmount should happen 
		after the Deduction/Credit status is updated
		and outside the if condition for GetDeductionInfo.DD_IsChild IS 1
		------->
		<cfif DeductionInfo.DD_IsChild IS 1>
		
			<cfset DeductionManager.updateParentBalanceAmount(parentDeductionId = DeductionInfo.dd_parent_Id) />
			
		</cfif>	
		
	<CFELSEIF ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_ISParent EQ 1)> <!--- Parent Deduction --->
	
		<!--- Loop over the children and close the children --->
		<CFLOOP Query="CheckForChild">
			<cfset DeductionManager.ReopenDeduction(deductionId = CheckForChild.Deduction_ID) />
		</CFLOOP>
		
		<cfset DeductionManager.updateParentBalanceAmount(parentDeductionId = Original_Deduction_ID) />
			
	</CFIF>
	
	
 <script>
window.parent.location.href = '/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#'
</script> 

</cfif>
<div align="Center">
Are you sure you want to reopen this <cfoutput>#lcase(deduction_label)#</cfoutput>? <cfif application.returned_customer_setting.customer_keyword IS "Heinz" AND Deduction_IsCredit.DD_Closure_Sent EQ 1>This will send a record to your legacy system.</cfif>

<p></p>
<div id="reopenLink">
<a href="##" onclick="Reopen_Deduction();return false;"><strong><font color="navy">[ reopen this <cfoutput>#lcase(deduction_label)#</cfoutput> ]</strong></font></a>
</div>
</div>

<form name="Reopen" action="/deductions/closure/reopen.cfm" method="post">
	<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
	<input type="hidden" name="blnSubmit" value="1">
</form>

<script>
function Reopen_Deduction()
	{
		disableButton("reopenLink", true, false);
		document.Reopen.submit();
	}
</script>

<!--- DEV NOTE: DAA; D16341 --->

	<CFELSE>

		<div style="padding:10px; position:absolute; width:600px; left:125px; top:60px; text-align:center;">
		
		An acknowledgement from the client's ERP system must be received prior to allowing this #lcase(deduction_label)# to be reopened.<br />
		Please check back at a later time to see if acknowledgement has been received.<br /><br />
		
		<a href="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#" target="_parent"><strong><font color="navy">[ return ]</font></strong></a> to the #lcase(deduction_label)#.
		
		</div>

	</cfif>
</cfif>
<!--- END DEV NOTE: DAA; D16341 --->

</cfoutput>

</body>
</html>