<!------
bb_reset2.cfm
----->

<cfparam name="URL.fromResubmit" default="0">
<cfparam name="IsBillbackApproved" default="1">
<cfparam name="Disagree" default="0">
<cfparam name="FromFlex" default="0">
<cfparam name="URL.parentName" default="" />
<cfparam name="URL.paramSource" default="" />

<!--- Dev Note: Kal: 30645 - Disagree in deviation screen should reset BB to WIP : Call from the Flex App --->
<!---
	<cfparam name="FORM.FlexAppName" default="BillbackMain"> 
	<script type="text/javascript">alert(<cfoutput>#url.FlexAppName#</cfoutput>)</script> 
--->
<cfif isDefined("URL.FlexAppName")>
	<cfset temp = structInsert(FORM,"FlexAppName",#URL.FlexAppName#,true) />		
</cfif>	

<CFSET reset_This_Billback = 1>
<CFIF NOT isDefined("resetBillback")>
	<CFSET reset_This_Billback = 0>
</CFIF>


<CFIF NOT isDefined("Billback_ID")>
	<CFSET reset_This_Billback = 0>
</CFIF>

<cfset BBMgr = CreateObject("component", "mvc.models.billback.billbackManager") />

<cfquery name="getBBStatus" datasource="#application.datasource#">
SELECT billback_status_id
FROM billback
WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<!--- DevNote:45924 - The logic for "IsBillbackApproved" seems to be incorrect in many places. Instead of adding code in many places,
change logic here -  If the bb is approved, set "IsBillbackApproved" to 1.
--->
<cfif getBBStatus.billback_status_id GT 2>
	<cfset IsBillbackApproved = 1>
</cfif>

<CFIF reset_This_Billback>

	<cfif Disagree eq 1>
		<cfquery name="setReason" datasource="#application.datasource#">
			UPDATE 	Billback
			SET 	BB_Disagree = 1,
					BB_Disagree_Date = GetDate(),
					BB_Disagree_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	</cfif>	

  
	<cfquery name="ResetAgree" datasource="#application.datasource#">
		UPDATE 	BB_Agreed_Info
		SET		Deleted = 1
		WHERE  	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	<!------ If the billback status got changed to WIPs end mail to creator and approver ----->
	<cfquery name="getBillbacks" datasource="#application.datasource#">
		SELECT	Billback.Billback_ID_Int,Billback.Billback_ID, BB_Title, BB_Creator_User_Position_ID, BB_Code, 
				Billback.BB_Amount,BB_Reference, BB_Code, BB_Date, BB_Start_Date, BB_End_Date,
				BB_Creator_ID, User_Approved, isNull(Uploaded_Billback,0) AS Uploaded_Billback,
				Billback.BB_Deviations_Override_Price as BB_Level_Deviations_Override_Price_Flag
		FROM	Billback
				LEFT JOIN BB_Approved
				ON
				BB_Approved.Billback_ID = Billback.Billback_ID
		WHERE	Billback.Deleted = 0
				AND Billback.Billback_ID = '#Billback_ID#'
	</cfquery>
	
	<!--- 21923/Anand Rao/22-Feb-2010 --->
	<!---
	Rules for deleting entries from BB_Item_Invoice_Level
	For client who do not allow editing of claimed amount and claimed quantity, only delete for WIP/RFA billbacks which are not third party upload 
	For client who allow editing of claimed amount and claimed quantity, delete for any WIP/RFA billbacks		
	--->
	<cfif 
		NOT(
			(getBillbacks.Uploaded_Billback EQ 3 
		 	AND (application.oApplicationAppSettingsManager.getApplicationAppSettings().getBB_Upload_III_P_Qty_Amt_Editable() EQ 0 OR getBillbacks.BB_Level_Deviations_Override_Price_Flag EQ 1))
			OR
			getBillbacks.Uploaded_Billback EQ 2 
		 	AND (application.oApplicationAppSettingsManager.getApplicationAppSettings().getEditableClaimedDollarsQuantity() EQ 0 OR getBillbacks.BB_Level_Deviations_Override_Price_Flag EQ 1)
		 	)>
		<cfquery name="DeleteFromGridTable" datasource="#application.datasource#">
		UPDATE 	BB_Item_Invoice_Level
		SET 	Deleted = 1
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
  </cfif>
  
	<cfset userManager = CreateObject("component", "components.user.UserManager").init() />
	<cfset finalEmailAddress = "" />
	<cfset finalEmailAddress = ListAppend(finalEmailAddress, userManager.getUserEmail(getBillbacks.BB_Creator_ID), ";") />
	<cfset finalEmailAddress = ListAppend(finalEmailAddress, userManager.getUserEmail(getBillbacks.User_Approved), ";") />
	
	<!--- It seems that this code fires for "Reset" only --->
	<cfif IsBillbackApproved eq 1>
		<cfset CreateObject("component", "components.Billback.BillbackManager").resetBillback(billbackId=Billback_ID, userId=request.AccessStructure.User_ID,DisagreeFlag=Disagree) />
		<!---	If the request is from flex, call code to remove splits from the parent billback.
				Note: This code should execute for billback reset.
		--->
		<cfif FromFlex eq 1>
			<cfset BBMgr.removeDDAndSplits(Billback_ID)>
		</cfif>
	<!--- It seems that this code fires for "Disagree" only --->
	<cfelse>
		<cfset CreateObject("component", "components.Billback.BillbackManager").resetBillback(Billback_ID, request.AccessStructure.User_ID,0,Disagree) />
	</cfif>

	<cfif getBillbacks.recordcount>
		<cfset Message_Title = "Billback - Reset to Work in Progress" />
		<cfset Message_Description = "Please be advised this billback has been reset to work in progress status" />
		<cfoutput>
			<cfloop query="getBillbacks">		
				<cfsavecontent variable="bb_email_content">
					<cfinclude template="bb_email_info.cfm" />
				</cfsavecontent>		
			</cfloop>
		</cfoutput>
		<cfif finalEmailAddress is not "">
			<cf_EmailWrapper 
				to="#finalEmailAddress#" 
				from="BlacksmithApplicationsNotificationService@#application.CompanyEmailSuffix#" 
				subject="Billback #getBillbacks.BB_Code# - Reset to Work in Progress" 
				type="HTML" 
				messagetype="1" 
				generatedby="1" 
				apparea="3">
				<cfoutput>#bb_email_content#</cfoutput>
			</cf_EmailWrapper>
		</cfif>
	</cfif>
	
	<!--- 
    The page should reload anytime when the user reset the billback from a status of approved
    to WIP so that they can delete if they want to without going from page to page.
    Hopefully there is no harm in reloading the entire frame.  Will have to revisit if there is
    any implications because of this change and reloading the entire frame.
    The cfelse condition is also commented out below.
    -Anand Rao 02/18/09 -D18159 
  	--->

		<cfoutput>
			<cfif FromFlex eq 0>
				<!--- here javascript is required to refresh the whole frame because the bb code has changed in the resubmit action --->
				<script language="JavaScript">
					function refeshThis()
					{			
						window.parent.location.href = '/billbacks/capture/index.cfm?bbid=#Billback_ID#'
					}
					refeshThis()		
				</script>
			<cfelse>
				<script type="text/javascript">
					// This function returns the appropriate reference, depending on the browser.
					<cfif IsDefined("FlexAppName") neq 0>
						<cfif FlexAppName EQ 'cfbbedit'> 
							window.open("javascript:saveReset()", "#url.parentName#");
							window.close();
						</cfif>
					</cfif>
					function getFlexApp(appName)
					{
						if (navigator.appName.indexOf ("Microsoft") !=-1)
						{
							return opener.window[appName];
						} 
					else 
						{
							return opener.document[appName];
						}
					}
					
					<cfif IsDefined("FlexAppName") neq 0 and URL.paramSource eq "">
					// implement call to externalinterface.				    
					function bbDisagreed()
					{
						getFlexApp('#FlexAppName#').bbDisagreed('#getBillbacks.Billback_ID_Int#');
					}
					</cfif>

					// call back handler
					<cfif URL.paramSource eq "AgGridBB" or URL.paramSource eq "BBSettlement">
						window.opener.parent.reloadBBEdit();
					<cfelse>
						bbDisagreed();
					</cfif>
					window.close();
			     </script>
			</cfif>
		</cfoutput>
</CFIF>

<CFIF NOT reset_This_Billback>
	<cfif FromFlex eq 0>
		<script language="JavaScript">
			history.back();
		</script>
	<cfelse>
		<script language="JavaScript">
			window.close();
		</script>
	</cfif>
</CFIF>