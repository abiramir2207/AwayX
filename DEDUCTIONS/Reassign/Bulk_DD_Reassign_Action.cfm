<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFPARAM NAME="FORM.PerReassign" DEFAULT="">

<CFSET Unavailable = "">
<CFSET UnSuccessful = "">
<CFLOOP LIST="#FORM.Selected_Deduction_ID#" INDEX="Item">	
	<cfset useLakebaseForCheckLock = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForCheckLock>
		<cftry>
			<cfset CheckLock = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"select" = "is_locked",
					"deduction_id" = "eq.#Item#"
				}),
				"is_locked"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForCheckLock = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForCheckLock>
	<CFQUERY NAME="CheckLock" DATASOURCE="#Application.Datasource#">
		SELECT Is_Locked FROM DEductions WHERE Deduction_ID = '#Item#'
	</CFQUERY>
	</cfif>
	
	<CFIF CheckLock.Is_Locked EQ 0>		
		<cfset useLakebaseForLockDeduction = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForLockDeduction>
			<cftry>
				<cfset application.oLakebase.updateRows("deductions",
					{ "deduction_id" = "eq.#Item#" },
					{ "is_locked" = 1, "locked_by" = request.AccessStructure.User_ID }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForLockDeduction = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForLockDeduction>
		<CFQUERY NAME="LockDeduction" DATASOURCE="#Application.Datasource#">
			UPDATE	Deductions
			SET		Is_Locked = 1,
					Locked_By = '#request.AccessStructure.User_ID#'
					
			WHERE 	Deduction_ID = '#Item#'
		</CFQUERY>
		</cfif>
		
		<cfset useLakebaseForIsAvailable = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForIsAvailable>
			<cftry>
				<cfset IsAvailable = application.oLakebase.toQuery(
					application.oLakebase.selectRows("deductions", {
						"deduction_id" = "eq.#Item#"
					})
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForIsAvailable = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForIsAvailable>
		<CFQUERY NAME="IsAvailable" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Deductions WHERE Deduction_ID = '#Item#'
		</CFQUERY>
		</cfif>
		
		<cfset useLakebaseForGetSourceAnalyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
		<cfif useLakebaseForGetSourceAnalyst>
			<cftry>
				<cfset GetSourceAnalyst = application.oLakebase.toQuery(
					application.oLakebase.selectRows("_users", {
						"select" = "name_first,name_last",
						"user_id" = "eq.#IsAvailable.Analyst_User_ID#",
						"deleted" = "eq.0"
					}),
					"name_first,name_last"
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForGetSourceAnalyst = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetSourceAnalyst>
		<CFQUERY NAME="GetSourceAnalyst"  DATASOURCE="#Application.Datasource#">
				SELECT 	Name_First, Name_Last 
				FROM 	_Users 
				WHERE 	User_ID='#IsAvailable.Analyst_User_ID#' 
				AND Deleted=0
		</CFQUERY>
		</cfif>

		<cfset useLakebaseForGetTargetAnalyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
		<cfif useLakebaseForGetTargetAnalyst>
			<cftry>
				<cfset GetTargetAnalyst = application.oLakebase.toQuery(
					application.oLakebase.selectRows("_users", {
						"select" = "name_first,name_last",
						"user_id" = "eq.#FORM.Tar_Analyst#",
						"deleted" = "eq.0"
					}),
					"name_first,name_last"
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForGetTargetAnalyst = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetTargetAnalyst>
		<CFQUERY NAME="GetTargetAnalyst"  DATASOURCE="#Application.Datasource#">
				SELECT 	Name_First, Name_Last 
				FROM 	_Users 
				WHERE 	User_ID='#FORM.Tar_Analyst#' 
				AND Deleted=0
		</CFQUERY>
		</cfif>

		<CFIF IsAvailable.Recordcount GT 0> <!--- </CFIF>0 AND GetSourceAnalyst.Recordcount GT 0> --->
			<CFIF application.returned_customer_setting.DD_Assignment_Based_On_Customer EQ 1>
			<CFSET CheckForPerReassign = 0>
			<CFSET CheckForPerReassign = LISTFIND(FORM.PerReassign,Item,",")>
			</CFIF>
			<CFTRANSACTION ACTION="BEGIN">
				<CFQUERY NAME="Reassign_dd" DATASOURCE="#Application.Datasource#">
					UPDATE 	Deductions
					SET		<CFIF application.returned_customer_setting.DD_Assignment_Based_On_Customer EQ 1>
								<CFIF CheckForPerReassign NEQ 0>
								OverWrite_Auto_Assign = 1,	
								</CFIF>
							</CFIF>
							Analyst_User_ID = '#FORM.Tar_Analyst#'
							<!--- D33578 Ability to reclass when reassigning deduction --->
							<cfif len(FORM.Tar_Classification)>
							,DD_Classification_ID = #FORM.Tar_Classification#
							</cfif>
							<!--- D33578 Ability to reclass when reassigning deduction --->
							<!--- IF the Deduction Status is New or Open and the Analyst is changing, then set the status back to new --->
							<cfif ListFindNoCase("1,2", IsAvailable.DD_Status) and trim(IsAvailable.Analyst_User_ID) neq trim('#FORM.Tar_Analyst#')>
							, DD_Status = 1
							</cfif>
							
					WHERE 	Deduction_ID = '#Item#' AND 
							/* Analyst_User_ID = '#IsAvailable.Analyst_User_ID#' AND */
							Deleted=0	
				</CFQUERY>
				
				<cfset useLakebaseForLog_Reassign = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reassign")>
				<cfif useLakebaseForLog_Reassign>
					<cftry>
						<cfset application.oLakebase.insertRow("dd_reassign", {
							"deduction_id" = Item,
							"from_analyst" = IsAvailable.Analyst_User_ID,
							"to_analyst" = FORM.Tar_Analyst,
							"by_analyst" = request.AccessStructure.User_ID
						})>
						<cfcatch type="any">
							<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
							<cfset useLakebaseForLog_Reassign = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForLog_Reassign>
				<CFQUERY NAME="Log_Reassign" DATASOURCE="#Application.Datasource#">
					INSERT INTO 
					DD_Reassign (	Deduction_ID,
									From_Analyst,
									To_Analyst,
									By_Analyst		)
									
					VALUES 		( 	'#Item#',
									'#IsAvailable.Analyst_User_ID#',
									'#FORM.Tar_Analyst#',
									'#request.AccessStructure.User_ID#'	)
				</CFQUERY>
				</cfif>
			<CFTRANSACTION ACTION = "commit">
			</CFTRANSACTION>
		<CFELSE>			
			<CFSET Unavailable = "#Unavailable##Item#,">
		</CFIF>
		
		<cfset useLakebaseForUnLockDeduction = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForUnLockDeduction>
			<cftry>
				<cfset application.oLakebase.updateRows("deductions",
					{ "deduction_id" = "eq.#Item#" },
					{ "is_locked" = 0, "locked_by" = "" }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUnLockDeduction = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUnLockDeduction>
		<CFQUERY NAME="UnLockDeduction" DATASOURCE="#Application.Datasource#">
			UPDATE	Deductions
			SET		Is_Locked = 0,
					Locked_By = ''
					
			WHERE 	Deduction_ID = '#Item#'
		</CFQUERY>	
		</cfif>
	<CFELSE>
		<CFSET UnSuccessful = "#UnSuccessful##Item#,"> 	
	</CFIF>
</CFLOOP>

<CFIF Unavailable EQ "" AND UnSuccessful EQ "">
	<BR><BR><BR><BR><BR><BR>
	<CFSET ReassignedDed = ListQualify(FORM.Selected_Deduction_ID,"'",",","All")>
	<cfset useLakebaseForDispDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForDispDetails>
		<cftry>
			<cfset DispDetails = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"select" = "dd_dedid,sp_number,dd_dedid_sp_number",
					"deduction_id" = "in.(#FORM.Selected_Deduction_ID#)"
				}),
				"dd_dedid,sp_number,dd_dedid_sp_number"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDispDetails = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDispDetails>
	<CFQUERY NAME="DispDetails" DATASOURCE="#Application.Datasource#">
		SELECT DD_DedID,SP_Number,DD_DedID_SP_Number FROM Deductions WHERE Deduction_ID IN (#PreserveSingleQuotes(ReassignedDed)#)
	</CFQUERY>
	</cfif>
	
	<CFSET Count = 0>
	<CFSET BGCount = 1>
	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="5" ALIGN="Center">
		<TR>
			<TD COLSPAN="5"><B><FONT COLOR="Red" SIZE="3"><CFOUTPUT>Selected deductions are being reassigned to '#GetTargetAnalyst.Name_First# #GetTargetAnalyst.Name_Last#'.</CFOUTPUT></FONT></B></TD><!--- Please wait while selected deductions are being reassigned... --->
		</TR>
		<TR>
			<TD COLSPAN="5"><B><FONT SIZE="3"><BR>List of selected deductions</FONT></B></TD>
		</TR>
		<TR>
		<CFOUTPUT QUERY="DispDetails">
			<CFSET Count = Count + 1>		
			<CFIF Count LT 6>
				<TD BGCOLOR = "C6FFC6" STYLE = "Border: solid C0C0C0 1px">#DD_DedID_SP_Number#<!--- #DD_DedID# - <CFIF SP_Number NEQ "">#SP_Number#<CFELSE>000</CFIF> ---></TD>
			<CFELSE>
				<CFSET Count = 0>
				<CFSET BGCount = BGCount + 1>
				</TR>
				<TR>
				<TD BGCOLOR = "C6FFC6" STYLE = "Border: solid C0C0C0 1px">#DD_DedID_SP_Number#<!--- #DD_DedID# - <CFIF SP_Number NEQ "">#SP_Number#<CFELSE>000</CFIF> ---></td>
			</CFIF>
		</CFOUTPUT>
	</TABLE>
	<!--- <TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">Selected deductions were reassigned from '#SrcName#' to '#TarName#'.</FONT></B></TD><!--- Please wait while selected deductions are being reassigned... --->
		</TR>
	</TABLE> --->
<CFELSEIF Unavailable NEQ "">
	<CFSET Unavailable = ListQualify(Unavailable,"'",",","All")>
	<cfset useLakebaseForUnavailable_Title1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForUnavailable_Title1>
		<cftry>
			<cfset Unavailable_Title = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"select" = "dd_dedid,sp_number",
					"deduction_id" = "in.(#Unavailable#)"
				}),
				"dd_dedid,sp_number"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUnavailable_Title1 = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUnavailable_Title1>
	<CFQUERY NAME="Unavailable_Title" DATASOURCE="#Application.Datasource#">
		SELECT DD_DedID,SP_Number FROM Deductions WHERE Deduction_ID IN (#PreserveSingleQuotes(UnAvailable)#)
	</CFQUERY>
	</cfif>
	<CFSET UnavailableItems = "">
	<CFOUTPUT QUERY="Unavailable_Title">		
		<CFIF SP_Number NEQ "">
			<CFSET Split = #SP_Number#>
		<CFELSE>
			<CFSET Split = "000">
		</CFIF>
		<CFSET UnavailableItems = "#UnavailableItems# [ #TRIM(DD_DedID)# - #Split# ]">
	</CFOUTPUT>
<CFELSEIF UnSuccessful NEQ "">
	<CFSET UnSuccessful = ListQualify(UnSuccessful,"'",",","All")>
	<cfset useLakebaseForUnavailable_Title2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForUnavailable_Title2>
		<cftry>
			<cfset Unavailable_Title = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"select" = "dd_dedid,sp_number",
					"deduction_id" = "in.(#UnSuccessful#)"
				}),
				"dd_dedid,sp_number"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUnavailable_Title2 = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUnavailable_Title2>
	<CFQUERY NAME="Unavailable_Title" DATASOURCE="#Application.Datasource#">
		SELECT DD_DedID,SP_Number FROM Deductions WHERE Deduction_ID IN (#PreserveSingleQuotes(UnSuccessful)#)
	</CFQUERY>
	</cfif>
	<CFSET UnSuccessfulItems = "">
	
	<CFOUTPUT QUERY="Unavailable_Title">
		<CFIF SP_Number NEQ "">
			<CFSET Split = #SP_Number#>
		<CFELSE>
			<CFSET Split = "000">
		</CFIF>
		<CFSET UnSuccessfulItems = "#UnSuccessfulItems# [ #TRIM(DD_DedID)# - #Split# ]">		
	</CFOUTPUT>
</CFIF>


<SCRIPT language="JavaScript">
	function delayLocate()
	{
		window.location.href = "/deductions/Reassign/Bulk_DD_Reassign.cfm";
	}	
	<CFIF UnAvailable NEQ "">
		var unAvai = "<CFOUTPUT>#UnavailableItems#</CFOUTPUT>";
		alert("Deduction(s) " + unAvai + " can't be reassigned (These deductions are not available in the given source).");
		window.setTimeout('delayLocate()', 0);
	</CFIF>
	<CFIF UnSuccessful EQ "" AND UnAvailable EQ "">
		window.setTimeout('delayLocate()', 5000);
	<CFELSEIF UnSuccessful NEQ "">
		var unSucc = "<CFOUTPUT>#UnSuccessfulItems#</CFOUTPUT>";
		alert("Deduction(s) " + unSucc + " can't be reassigned (These deductions are currently locked by someother user).");
		window.setTimeout('delayLocate()', 0);
	</CFIF>
	
	//window.setTimeout('delayLocate()', 3000);
</SCRIPT>

	

</body>
</html>
