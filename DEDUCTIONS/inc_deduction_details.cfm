<cfparam name="Display" default=""> 
<cfparam name="CheckForAgreed.RecordCount" default=0>
<cfparam name="showScissor" default="0">


<cfif NOT isdefined("Get_Profile_Settings")>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
</cfif>

<html>
<body TOPMARGIN="0">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()> 
<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager").init() /> 
<CFSET ReDirectToMain = 0>
<cfparam name="PrinterFriendly" default="0">
<CFIF IsDefined("URL.AssociatedDeduction") OR IsDefined("URL.AssociatedCredit")>
	<CFIF IsDefined("URL.AssociatedCredit")>
		<!------ From Deduction,
		DEDUCTION_ID = URL.Deduction_ID
		CREDIT_ID = URL.AssociatedCredit
		----->		
		<cfset DeductionManager.RemoveClosureFromCreditForThisDeduction(Deduction_ID) />
		<cfset DeductionManager.RemoveClosureFromDeduction(Deduction_ID) />
	<CFELSE>
		<!------ From Credit,
		CREDIT_ID = URL.Deduction_ID
		DEDUCTION_ID = URL.AssociatedDeduction
		----->
		<cfset DeductionManager.RemoveClosureFromCredit(Deduction_ID) />
		<cfset DeductionManager.RemoveClosureFromDeduction(URL.AssociatedDeduction) />		
	</CFIF>
	<CFSET ReDirectToMain = 1>	
</CFIF>

<CFIF ReDirectToMain EQ 1>
<SCRIPT language="JavaScript">
	function relocateThis()
	{
		window.parent.location.href = "/deductions/deduction.cfm?deduction_ID=<CFOUTPUT>#Deduction_ID#</CFOUTPUT>"
	}
	relocateThis();	
	</SCRIPT>
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif Display neq "Preview">
	<CFIF NOT Isdefined("FORM.Comm_Type")><CFINCLUDE TEMPLATE="/includes/header.cfm"></CFIF>
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Dev Note: KAL - D7433 --->
<cfset Referer_Template = ReplaceList(#cgi.HTTP_REFERER#, "?,-,=", "/,/,/")>
<cfif ListFindNoCase(Referer_Template, "deduction.cfm", "/")> <cfset GetHelpURL =1> </cfif>

<!--- BJF: Don't show help link from print/email --->
<cfif PrinterFriendly EQ 1>
	<cfset GetHelpURL =1>
</cfif>

<DIV ALIGN="RIGHT"><CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"></DIV>
<cfif isDefined("Deduction_ID")>

<cfinclude template="/deductions/sql_Deduction_Info.cfm">

<!---Which search screens to show?--->
<cfset useLakebaseForDeductionSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_settings")>
<cfif useLakebaseForDeductionSettings>
	<cftry>
		<cfset DeductionSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_settings", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeductionSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionSettings>
<cfquery name="DeductionSettings" datasource="#application.datasource#">
SELECT * FROM Deduction_Settings
</cfquery>
</cfif>

<cfparam name="CenterToShow" default="Details">
<cfparam name="Invoices" default="">
<cfparam name="Adj_Excl" default="">
<cfparam name="Billbacks" default="">
<cfparam name="FormType" default="">

<cfparam name="GetPrograms.Recordcount" default = 0>

<cfset useLakebaseForGetDistributor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGetDistributor>
	<cftry>
		<cfset GetDistributor = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"select" = "distributor_id,dd_stage,dd_status",
				"deduction_id" = "eq.#Deduction_ID#"
			}),
			"distributor_id,dd_stage,dd_status"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDistributor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDistributor>
<cfquery name="GetDistributor" datasource="#application.datasource#">
SELECT Distributor_ID, DD_Stage, DD_Status FROM Deductions WHERE Deduction_ID = '#Deduction_ID#'
</cfquery>
</cfif>

<cfif len(trim(Deduction_Info.Program_ID)) GT 0>
	<cfquery name="GetPrograms" datasource="#application.datasource#">
	SELECT Contract_Main.Contract_Number, Contract_Main.Contract_Title, Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date, Contract_Status_Types.Contract_Status_Type_Desc
	FROM Contract_Main
		INNER JOIN Contract_Status_Types 
		ON Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
	WHERE Contract_Main.Contract_Main_ID = #Deduction_Info.Program_ID#
	</cfquery>

</cfif>

<cfif DeductionSettings.ExcandAdj IS 1>
<cfquery name="GetAdjustments" datasource="#application.datasource#">
SELECT * FROM DD_Relationships
	INNER JOIN BB_Adjustment
	ON BB_Adjustment.BB_Adjustment_ID = DD_Relationships.DD_Key_to_Relationship
WHERE DD_Relationship_Type_ID = 1
AND DD_Relationships.Deduction_ID = '#Deduction_ID#'
</cfquery>

<cfquery name="GetExclusions" datasource="#application.datasource#">
SELECT DISTINCT DD_Relationships.DD_Relationship_Type_ID, BB_Program_Exclusion.BB_Program_Exclusion_ID,  BB_Program_Exclusion.Date_Applied, (select sum(BB_Product_Exclusion.Dollar_Amount) from BB_Product_Exclusion WHERE BB_Product_Exclusion.BB_Program_Exclusion_ID = DD_Relationships.DD_Key_to_Relationship) AS Exclusion_Amount 
FROM DD_Relationships
	INNER JOIN BB_Product_Exclusion
	ON BB_Product_Exclusion.BB_Program_Exclusion_ID = DD_Relationships.DD_Key_to_Relationship
	INNER JOIN BB_Program_Exclusion
	ON BB_Program_Exclusion.BB_Program_Exclusion_ID = DD_Relationships.DD_Key_to_Relationship
WHERE DD_Relationship_Type_ID = 2
AND DD_Relationships.Deduction_ID = '#Deduction_ID#'
</cfquery>
</cfif>

<cfset useLakebaseForCheckLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForCheckLocked>
	<cftry>
		<cfset CheckLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"select" = "is_locked,locked_by,rebill_date",
				"deduction_id" = "eq.#Deduction_ID#",
				"deleted" = "eq.0"
			}),
			"is_locked,locked_by,rebill_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckLocked>
<CFQUERY NAME="CheckLocked" DATASOURCE="#Application.Datasource#">
	SELECT 	Is_Locked,Locked_By,rebill_date 
	FROM 	Deductions 
	WHERE 	Deduction_ID = '#Deduction_ID#' AND
			Deleted = 0
</CFQUERY>
</cfif>

<!--- Get Deduction assignment Info --->
<cfquery name="GetassignmentInfo" datasource="#application.datasource#">
 SELECT u.Name_First + ' ' + u.Name_Last As Who
	FROM Deductions d 
		 INNER JOIN _Users u
				ON u.User_ID = d.Analyst_User_ID
 WHERE d.Deduction_ID = '#Deduction_ID#'
</cfquery>

<!--- Get Deduction Reassignment Info --->
<cfquery name="GetReassignInfo" datasource="#application.datasource#">
 SELECT u.Name_First + ' ' + u.Name_Last As FromWho, u1.Name_First + ' ' + u1.Name_Last As ToWho
 ,u2.Name_First + ' ' + u2.Name_Last As ByWho, Created_Date 
	FROM DD_Reassign dr 
		 INNER JOIN _Users u
				ON u.User_ID = dr.From_Analyst
		 INNER JOIN _Users u1
				ON u1.User_ID = dr.To_Analyst
		 INNER JOIN _Users u2
				ON u2.User_ID = dr.By_Analyst
 WHERE dr.Deduction_ID = '#Deduction_ID#'
 AND dr.Deleted = 0
 ORDER BY dr.Created_Date
</cfquery>

<CFQUERY NAME="GetBrokerReassignHis" DATASOURCE="#Application.Datasource#">
	SELECT FB.Broker_Name FBroker,FB.Broker_Shard FbrokerS,TB.Broker_Name TBroker,TB.Broker_Shard TBrokerS,_Users.Name_First,_Users.Name_Last,DD_Broker_Reassign.Created_Date 
	FROM DD_Broker_Reassign
	INNER JOIN BSA_Foodservice_Brokers FB ON FB.BSA_Foodservice_Brokers_ID = DD_Broker_Reassign.From_Broker_ID
	INNER JOIN BSA_Foodservice_Brokers TB ON TB.BSA_Foodservice_Brokers_ID = DD_Broker_Reassign.To_Broker_ID
	INNER JOIN _Users ON _Users.User_ID = DD_Broker_Reassign.Reassigned_By
	WHERE Deduction_ID = '#Deduction_ID#' AND DD_Broker_Reassign.Deleted = 0
</CFQUERY>

<cfoutput>
<cfif Display IS "Preview">

<!---Begin top display--->
<TABLE border="0" cellpadding="4" style="border-collapse: collapse" id="table2" cellspacing="4">
	<TR>
		<TD nowrap STYLE="Border:Solid C0C0C0 1px;  Border-left:Solid C0C0C0 1px;"><B><FONT size="3">#Deduction_Info.DD_DedID_SP_Number#<!--- #Deduction_Info.DD_DedID# <CFIF Deduction_Info.SP_Number NEQ "">- #Deduction_Info.SP_Number#<CFELSE>- 000</CFIF> ---></FONT></B></TD>
		<TD  width="100%"  STYLE="Border:Solid C0C0C0 1px;">
		<cfif Deduction_Info.attachment_count gt 0>
			<table>
				<tr>
					<td width="99%" nowrap><B><FONT size="3"> <CFIF Deduction_Info.ShipToName NEQ "">#Deduction_Info.ShipToName# (#Deduction_Info.Shr_Ship_To#)<CFELSE>#Deduction_Info.Name# (#Deduction_Info.Shr_Bill_To#)</CFIF></FONT></B></td>
					<td width="1%"><IMG  align="right"   SRC="/images/doc.gif" width="13" height="16" TITLE="This program has #Deduction_Info.attachment_count# attached document(s)"></td>
				</tr>
			</table>
		<cfelse>
				<B><FONT size="3"> <CFIF Deduction_Info.ShipToName NEQ "">#Deduction_Info.ShipToName# (#Deduction_Info.Shr_Ship_To#)<CFELSE>#Deduction_Info.Name# (#Deduction_Info.Shr_Bill_To#)</CFIF></FONT></B>
		</cfif>
		</TD>
		<TD nowrap STYLE="Border:Solid C0C0C0 1px;"><B><FONT size="3">
		#Deduction_Info.DD_Stage_Description#
		</FONT></B></TD>
		
		<TD nowrap STYLE="Border:Solid C0C0C0 1px;"><B><FONT size="3"><cfif Deduction_Info.DD_Status IS 1>
			New
			<cfelseif Deduction_Info.DD_Status IS 2>
			Open 
			<CFIF Deduction_Info.Is_Write_Off EQ 1>
				(Write-Off)
			<CFELSEIF Deduction_Info.DD_Rejected EQ 1>
				(Reject)
			</CFIF>
			<cfelseif Deduction_Info.DD_Status IS 3>
			<cfset useLakebaseForCheckForAgreed = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_agreed_info")>
			<cfif useLakebaseForCheckForAgreed>
				<cftry>
					<cfset CheckForAgreed = application.oLakebase.toQuery(
						application.oLakebase.selectRows("dd_agreed_info", {
							"deduction_id" = "eq.#Deduction_ID#",
							"deleted" = "eq.0",
							"limit" = "1"
						})
					)>
					<cfcatch type="any">
						<cfset useLakebaseForCheckForAgreed = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForCheckForAgreed>
			<CFQUERY NAME="CheckForAgreed" DATASOURCE="#Application.Datasource#">
				SELECT TOP 1 * FROM DD_Agreed_Info WHERE Deduction_ID = '#Deduction_ID#' AND Deleted = 0
			</CFQUERY>
			</cfif>
			<CFIF CheckForAgreed.RecordCount GT 0 AND Get_Profile_Settings.DD_RFA_Agreed EQ 1>			
			AGREE
			<CFELSE>
			RFA
			</CFIF>
			<CFIF Deduction_Info.Is_Write_Off EQ 1>
			(Write-Off)
			<CFELSEIF Deduction_Info.Is_Last_Status_Rebill EQ 1>
			(Rebill)
			<CFELSEIF Deduction_Info.DD_Rejected EQ 1>
			(Reject)
			</CFIF>
			<cfelseif Deduction_Info.DD_Status IS 4>
			Closed
				<CFIF Deduction_Info.Is_Write_Off EQ 1>
				(Write-Off)
				<CFELSEIF Deduction_Info.Is_Last_Status_Rebill EQ 1>
				(Rebill)
				<CFELSEIF Deduction_Info.DD_Rejected EQ 1>
				(Reject)
				</CFIF>
			<cfelseif Deduction_Info.DD_Status IS 5>
			Auto Closed
			<cfelseif Deduction_Info.DD_Status IS 6>
			Deleted
			<cfelseif Deduction_Info.DD_Status IS 7>
			Rebill
			<cfelseif Deduction_Info.DD_Status IS 8>
			Credit
			<cfelseif Deduction_Info.DD_Status IS 9>
			Closed Credit
			</cfif></FONT></B></TD>
		<TD nowrap STYLE="Border:Solid C0C0C0 1px;"><B><FONT size="3">#Deduction_Info.DD_Age# 
			Days</FONT></B></TD>
		<TD nowrap STYLE="Border:Solid C0C0C0 1px;"><B><FONT size="3">#LSCurrencyFormat(Deduction_Info.DD_Amount)#</FONT></B></TD>
	</TR>
</TABLE>

</cfif>


<!---Center--->
		<TABLE border="0" cellpadding="3" style="border-collapse: collapse" width="99%" id="table1" valign="top">
			<CFIF Deduction_Info.DD_Rejected EQ 1>
				<CFIF Deduction_Info.DD_Rejected_By NEQ "">
				<cfset useLakebaseForRejectedUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
				<cfif useLakebaseForRejectedUser>
					<cftry>
						<cfset RejectedUser = application.oLakebase.toQuery(
							application.oLakebase.selectRows("_users", {
								"select" = "name_first,name_last",
								"user_id" = "eq.#Deduction_Info.DD_Rejected_By#"
							}),
							"name_first,name_last"
						)>
						<cfcatch type="any">
							<cfset useLakebaseForRejectedUser = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForRejectedUser>
				<CFQUERY NAME="RejectedUser" DATASOURCE="#Application.Datasource#">
					SELECT Name_First, Name_Last FROM _Users WHERE User_ID = '#Deduction_Info.DD_Rejected_By#'
				</CFQUERY>
				</cfif>
				</CFIF>
				<TR>
					<TD COLSPAN="2"><BR><BR><B><FONT COLOR="Red">** This deduction has been rejected by <CFIF RejectedUser.RecordCount GT 0>#RejectedUser.Name_First# #RejectedUser.Name_Last#<CFELSE>Forge System</CFIF> <CFIF Deduction_Info.DD_Rejected_Date NEQ "">on #DateFormat(Deduction_Info.DD_Rejected_Date,"mm/dd/yyyy")#</CFIF> <CFIF Deduction_Info.DD_Rejected_Reason NEQ "">for the reason #Deduction_Info.DD_Rejected_Reason#</CFIF>.</FONT></B><BR><BR></TD>				
				</TR>
			</CFIF>
			<CFIF Isdefined("FORM.Comm_Type")>
			<TR>
				<TD align="right" nowrap valign="top"><B>Deduction ##:</B></TD>
				<TD>#Deduction_Info.DD_DedID# <CFIF Deduction_Info.SP_Number EQ "">000<CFELSE>#Deduction_Info.SP_Number#</CFIF></TD>
			</TR>	
			</CFIF>
			
			<cfif Deduction_Info.DD_Status IS 3>
		<cfquery name="GetRFAInfo" datasource="#application.datasource#">
	SELECT DD_RFA.*, DD_Reason_Code.DD_Reason_Code_Description, DD_Reason_Code.DD_Reason_Code, _users.Name_First, _users.Name_Last
	FROM DD_RFA 
		INNER JOIN DD_Reason_Code
		ON DD_RFA.Reason_Code = DD_Reason_Code.DD_Reason_Code_ID
		INNER JOIN _users
		ON _users.User_ID = DD_RFA.Requested_By
	WHERE DD_RFA.Deduction_ID = '#Deduction_ID#'
	</cfquery>
	
	<CFIF GetRFAInfo.recordCount EQ 0>
		<CFQUERY NAME="GetRFAInfo" DATASOURCE="#Application.Datasource#">
			SELECT RFA_Date Date_Requested,_users.Name_First, _users.Name_Last,
			DD_Reason_Code.DD_Reason_Code_Description,
			DD_Reason_Code.DD_Reason_Code AS DD_Reason_Code,
			DD_Reason_Code.DD_Reason_Code AS Reason_Code,
			DD_Reason_Code.GL_Account_Code,
			NULL AS Closing_Method
			FROM Deductions 
			INNER JOIN DD_Reason_Code
			ON Deductions.DD_Resolution_Code= DD_Reason_Code.DD_Reason_Code_ID			
			INNER JOIN _users ON _users.User_ID = Deductions.RFA_By
			WHERE Deduction_ID = '#Deduction_ID#'
		</CFQUERY>
	</CFIF>
	<tr><td align="center" colspan="2"><strong><font color="Navy">Request for Approval Information</font></strong></td></tr>
	<tr>
		<td valign="top" align="right">#stDeductionLabels["Reason Code"]#:</td>
		<td>#GetRFAInfo.Reason_Code# - #GetRFAInfo.DD_Reason_Code_Description#</td>
	</tr>
	 <cfif appsettings.getGL_Account_On()>
	<tr>
		<td valign="top" align="right">#Application.GLAccountLabel# Code assigned to #stDeductionLabels["Reason Code"]#:</td><!---D42774 --->
		<td>#GetRFAInfo.GL_Account_Code#</td>
	</tr>
	</cfif>
<!---Cleared amount--->
	<cfif DeductionSettings.Use_Cleared_Amount IS 1>
	<TR>
		<TD align="right" nowrap valign="top"><B>Cleared Amount:</B></TD>
		<TD valign="top">#Deduction_Info.Cleared_Amount#</TD>
	</TR>	
	</cfif>
	
	<tr>
		<td valign="top" align="right">Approval Requestor:</td>
		<td>#GetRFAInfo.Name_First# #GetRFAInfo.Name_Last#</td>
	</tr>
	<tr>
		<td valign="top" align="right">Approval Requested On:</td>
		<td>#dateformat(GetRFAInfo.Date_Requested, 'MM/DD/YYYY')# #timeformat(GetRFAInfo.Date_Requested, 'HH:MM tt')#</td>
	</tr>
	
	<tr>
		<td>&nbsp; </td>
		<td><a href="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#&CenterToShow=Closure" target="_parent"><font color="navy"><strong>[ approve this deduction ]</strong></font></a></td>
	</tr>
	<tr><td colspan="2" align="center"><hr width="90%" color="navy"></td></tr>
	</cfif>

	<!--- Label:17716 & 17718 | Display the top header reason if it is a "Closed" status or "Closed Credit" Status only -Anand Rao 12/15/08 --->
	<!--- Removed the AND condition for so it displays the header even if the Closed Credit does not have a write off reason  --->
	<cfif ((Deduction_Info.DD_Status IS 4) OR (Deduction_Info.DD_Status IS 9)) AND Deduction_Info.Is_last_Status_Rebill EQ 0>
	
	<cfquery name="GetClosureInfo" datasource="#application.datasource#">
		SELECT 	DD_Closure_Method.DD_Closure_Method_Description, 
				DD_Reason_Code.DD_Reason_Code_Description, 
				DD_Reason_Code.DD_Reason_Code,
				Deductions.DD_Operator_ID,
				Deductions.Is_Trade,
				Deductions.Business_Segment_ID,
				Deductions.Cleared_Amount,
				Deductions.ReOpened,
				Deductions.DD_DedID_SP_Number,
				Deductions.is_write_off,
				Deductions.DD_IsParent,
				Deductions.Is_Credit,
				Deductions.DD_Closure_ID,
				Deductions.DD_Closure_Type,
				ISNULL(Deductions.write_off_reason,'') AS write_off_reason,
				Business_Segment.Business_Unit_ID,
				Business_Segment.Business_Unit_Desc,
				Deductions.Q_Brand_ID,
				Q_Brand_Desc.Q_Brand,
				Operating_Unit.Code,
				Operating_Unit.Operating_unit_Description,
				GL_Account.GL_Account,
				GL_Account.GL_Account_Desc
		FROM Deductions
			LEFT JOIN Business_Segment ON Business_Segment.Business_Segment_ID = Deductions.Business_Segment_ID
			LEFT JOIN Operating_Unit ON Operating_Unit.Operating_Unit_ID = Deductions.Operating_Unit_ID
			LEFT JOIN Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = Deductions.Q_Brand_ID
			LEFT JOIN DD_Closure_Method
			ON DD_Closure_Method.DD_Closure_Method_ID = Deductions.DD_Closure_Method
			LEFT JOIN DD_Reason_Code
			ON DD_Reason_Code.DD_Reason_Code_ID = Deductions.DD_Resolution_Code
			LEFT JOIN GL_Account
			ON GL_Account.GL_Account = DD_Reason_Code.GL_Account_Code
		WHERE Deduction_ID = '#Deduction_ID#'
		</cfquery>	
		
 		<cfset useLakebaseForChk_IsParent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
 		<cfif useLakebaseForChk_IsParent>
 			<cftry>
 				<cfset Chk_IsParent = application.oLakebase.toQuery(
 					application.oLakebase.selectRows("deductions", {
 						"select" = "dd_dedid_sp_number",
 						"dd_parent_id" = "eq.#Deduction_ID#",
 						"deleted" = "eq.0",
 						"limit" = "1"
 					}),
 					"dd_dedid_sp_number"
 				)>
 				<cfcatch type="any">
 					<cfset useLakebaseForChk_IsParent = false>
 				</cfcatch>
 			</cftry>
 		</cfif>
 		<cfif NOT useLakebaseForChk_IsParent>
 		<cfquery name="Chk_IsParent" datasource="#application.datasource#">
 			SELECT 	TOP 1 DD_DedID_SP_Number 
			FROM 	Deductions 
			WHERE 	DD_Parent_ID = '#Deduction_ID#' AND Deleted = 0
 		</cfquery>	
 		</cfif>
		
		<cfif ((Chk_IsParent.RecordCount EQ 0) AND (Deduction_Info.DD_Status EQ 9) AND GetClosureInfo.is_write_off EQ 0 AND GetClosureInfo.DD_Closure_Type EQ 6)>
			<cfquery name="GetCrdDedClosureInfo" datasource="#application.datasource#">
				SELECT 	DD_Closure_Method.DD_Closure_Method_Description, 
					DD_Reason_Code.DD_Reason_Code_Description, 
					DD_Reason_Code.DD_Reason_Code
				FROM Deductions
				LEFT JOIN DD_Closure_Method
			ON DD_Closure_Method.DD_Closure_Method_ID = Deductions.DD_Closure_Method
			LEFT JOIN DD_Reason_Code
			ON DD_Reason_Code.DD_Reason_Code_ID = Deductions.DD_Resolution_Code
		WHERE Deduction_ID = '#GetClosureInfo.DD_Closure_ID#'	
			</cfquery>
		</cfif>
				
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<CFIF application.returned_customer_setting.DD_Allow_Trade_Non_Trade_Type EQ 1>
		<TR>
			<TD align="right" nowrap valign="top"><B>Deduction Type:</B></TD>	
			<TD valign="top"><CFIF GetClosureInfo.Is_Trade EQ 1><B>TRADE</B><CFELSE><B>NON - TRADE</B></CFIF> <CFIF GetClosureInfo.ReOpened EQ 1><B>( <FONT COLOR="Red">Reopened</FONT> )</B></CFIF></TD>		
		</TR>	
		</CFIF>
		<CFIF businessSegManager.isEnabled()>
			<CFIF GetClosureInfo.Business_Segment_ID NEQ "">								
			<TR>
				<TD align="right" nowrap valign="top"><B>Business Segment:</B></TD>
				<TD valign="top">#GetClosureInfo.Business_Unit_ID# - #GetClosureInfo.Business_Unit_Desc#</TD>
			</TR>	
			</CFIF>
			<TR>
				<TD align="right" nowrap valign="top"><B>Operating Unit:</B></TD>
				<TD valign="top">#GetClosureInfo.Code# - #GetClosureInfo.Operating_unit_Description#</TD>
			</TR>
		</CFIF>	
		<CFIF GetClosureInfo.Q_Brand NEQ "">
			<TR>
				<TD align="right" nowrap valign="top"><B>Q Brand:</B></TD>
				<TD valign="top">#GetClosureInfo.Q_Brand#</TD>
			</TR>
		</CFIF>
		<cfif (Chk_IsParent.RecordCount EQ 0)>
		<TR>
			<TD align="right" nowrap valign="top"><B>#stDeductionLabels["Reason Code"]#:</B></TD>
			<TD valign="top"><cfif (GetClosureInfo.Is_Credit EQ 1 AND GetClosureInfo.is_write_off EQ 0 AND GetClosureInfo.DD_Closure_Type EQ 6)>#GetCrdDedClosureInfo.DD_Reason_Code_Description#<cfelse>#GetClosureInfo.DD_Reason_Code_Description#</cfif>
					<br>#GetClosureInfo.GL_Account# #GetClosureInfo.GL_Account_Desc#
			</TD>
		</TR>	
		</cfif>
		<CFIF GetClosureInfo.DD_Operator_ID NEQ "" AND GetClosureInfo.DD_Operator_ID NEQ 0>			
		<TR>
			<TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.operator_label_singular#:</B></TD>
			<cfset useLakebaseForGetOperator = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_operator")>
			<cfif useLakebaseForGetOperator>
				<cftry>
					<cfset GetOperator = application.oLakebase.toQuery(
						application.oLakebase.selectRows("dd_operator", { "dd_operator_id" = "eq.#GetClosureInfo.DD_Operator_ID#" })
					)>
					<cfcatch type="any">
						<cfset useLakebaseForGetOperator = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForGetOperator>
			<CFQUERY NAME="GetOperator" DATASOURCE="#Application.Datasource#">
				SELECT * FROM DD_Operator WHERE DD_Operator_ID = '#GetClosureInfo.DD_Operator_ID#'
			</CFQUERY>
			</cfif>
			<TD valign="top">
				#GetOperator.DD_Operator_Name#<BR>
				#GetOperator.DD_Operator_Address#,
				#GetOperator.DD_Operator_Address2#<BR>
				#GetOperator.DD_City#,
				#GetOperator.DD_State#,
				#GetOperator.DD_ZipCode#.
			</TD>
		</TR>		
	
		</CFIF>	
		

    
    
		<!---Cleared amount--->
		<cfif DeductionSettings.Use_Cleared_Amount IS 1>
		<TR>
			<TD align="right" nowrap valign="top"><B>Cleared Amount:</B></TD>
			<TD valign="top">#lscurrencyformat(GetClosureInfo.Cleared_Amount)#</TD>
		</TR>	
		</cfif>
	<!--- <TR>	
		<TD align="right" nowrap valign="top">
			<B>Deduction Type:</B><BR>
			<cfif businessSegManager.isEnabled()>
				<CFIF GetClosureInfo.Business_Segment_ID NEQ "">
				<B>Business Segment:</B><BR>
				</CFIF>
			</CFIF>
			<!--- <CFIF GetClosureInfo.Is_Trade EQ 1> --->
			<B>Q Brand:</B><BR>
			<!--- </CFIF> --->
			<strong>Reason Code:</strong><br>
		
			<CFIF GetClosureInfo.DD_Operator_ID NEQ "" AND GetClosureInfo.DD_Operator_ID NEQ 0>			
				<strong>Operator:</strong><br>
			</CFIF>
			
			</TD>
			<TD valign="top">
			<CFIF GetClosureInfo.Is_Trade EQ 1><B>TRADE</B><CFELSE><B>NON - TRADE</B></CFIF><BR>
			
			<cfif businessSegManager.isEnabled()>
				<CFIF GetClosureInfo.Business_Segment_ID NEQ "">
				#GetClosureInfo.Business_Unit_ID# - #GetClosureInfo.Business_Unit_Desc#<BR>
				</CFIF>
			</CFIF>
			<!--- <CFIF GetClosureInfo.Is_Trade EQ 1> --->
			#GetClosureInfo.Q_Brand#<BR>
			<!--- </CFIF> --->
			#GetClosureInfo.DD_Reason_Code_Description#<br>#GetClosureInfo.GL_Account# (#GetClosureInfo.GL_Account_Desc#)<br>
			<CFIF GetClosureInfo.DD_Operator_ID NEQ "" AND GetClosureInfo.DD_Operator_ID NEQ 0>
				<cfset useLakebaseForGetOperator2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_operator")>
				<cfif useLakebaseForGetOperator2>
					<cftry>
						<cfset GetOperator = application.oLakebase.toQuery(
							application.oLakebase.selectRows("dd_operator", { "dd_operator_id" = "eq.#GetClosureInfo.DD_Operator_ID#" })
						)>
						<cfcatch type="any">
							<cfset useLakebaseForGetOperator2 = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForGetOperator2>
				<CFQUERY NAME="GetOperator" DATASOURCE="#Application.Datasource#">
					SELECT * FROM DD_Operator WHERE DD_Operator_ID = '#GetClosureInfo.DD_Operator_ID#'
				</CFQUERY>
				</cfif>
				#GetOperator.DD_Operator_Name#<BR>
				#GetOperator.DD_Operator_Address#,
				#GetOperator.DD_Operator_Address2#<BR>
				#GetOperator.DD_City#,
				#GetOperator.DD_State#,
				#GetOperator.DD_ZipCode#.
			</CFIF>				
			</TD>
		</TR> --->
    
    
    
		<cfif (Chk_IsParent.RecordCount EQ 0)>
		
		<TR>
			<TD align="right" nowrap valign="top"><strong>Closing Method:</strong><br></TD>
			<TD valign="top"><cfif (GetClosureInfo.Is_Credit EQ 1 AND GetClosureInfo.is_write_off EQ 0 AND GetClosureInfo.DD_Closure_Type EQ 6)>#GetCrdDedClosureInfo.DD_Closure_Method_Description#<cfelse>#GetClosureInfo.DD_Closure_Method_Description#</cfif></TD>
		</TR>
				
		</cfif>
		<!--- Label:17716 & 17718 | Display the write off reason only if it is a write off -Anand Rao 12/15/08 --->
		<CFIF (GetClosureInfo.is_write_off EQ 1)>
		<TR>
			<TD align="right" nowrap valign="top"><strong>Write Off Reason:</strong><br></TD>
			<TD valign="top"><cfif (TRIM(GetClosureInfo.write_off_reason) EQ "")>[None] <cfelse>#TRIM(GetClosureInfo.write_off_reason)#</cfif></TD>
		</TR>	
		</CFIF>

		<!--- 
		<CFIF GetClosureInfo.ReOpened EQ 1>
		<TR>
			<TD COLSPAN="2"><BR><B><FONT COLOR="Red">** </FONT>Information about this reopened deduction will be send to your legacy system tonight with deduction ## <FONT COLOR="Red">#GetClosureInfo.DD_DedID_SP_Number#</FONT></B></TD>
		</TR>
		</CFIF>
		 --->
		<TR>
			<TD COLSPAN="2"><HR COLOR="ORANGE"></TD>
		</TR>
	</cfif>
  

	<CFIF ReOpenLogic_ShowLinks EQ 0>
		<TR>
			<TD></TD>
			<TD><BR><B><FONT COLOR="Red">** This deduction has been reopened but not yet acknowledged</FONT></B></TD>
		</TR>
	</CFIF>

      <!--- 
	    Dev Notes: 19384/Anand Rao/16-Apr-10
    	Rebill Interface and changes 
    --->
  	<!--- Ana - 19384 - Added Rebill Num, Reason Code, Classification and date in the Rebill Status. --->
    <cfif (appSettings.getIntegrated_Rebill() EQ 1 AND (Deduction_Info.DD_Status IS 7 OR Deduction_Info.Is_Last_Status_Rebill EQ 1))>
		<cfquery name="GetReasonClass" datasource="#application.datasource#">
		SELECT DD_Classification_Desc,DD_Reason_Code
		FROM DD_Rebill_Integration
			INNER JOIN DD_Reason_Code ON DD_Reason_Code.DD_Reason_Code_ID = DD_Rebill_Integration.DD_Reason_Code_ID
			LEFT JOIN DD_Classification ON DD_Classification.DD_Classification_ID = DD_Rebill_Integration.DD_Classification_ID
		WHERE Deduction_ID = '#Deduction_ID#'
		</cfquery>	
      <TR>
			  <TD align="right" nowrap valign="top"><B>Rebill Amount:</B></TD>
			  <TD valign="top">#lscurrencyformat(Deduction_Info.DD_Amount)#</TD>			  
		  </TR>	
		  <CFIF Deduction_Info.Rebill_Number NEQ "">
		  <TR>
			  <TD align="right" nowrap valign="top"><B>Rebill Number:</B></TD>
			  <TD valign="top">#Deduction_Info.Rebill_Number#</TD>			  
		  </TR>	
		  </CFIF>
    		<TR>
			  <TD align="right" nowrap valign="top"><B>#stDeductionLabels["Rebill Reason Code"]#:</B></TD>
			  <TD valign="top">#GetReasonClass.DD_Reason_Code#</TD>			  
		  	</TR>	

      <cfif (appSettings.getDD_Show_Classification() EQ 1)>  
			<TR>
			  <TD align="right" nowrap valign="top"><B>#stDeductionLabels["Rebill Classification"]#:</B></TD>
			  <TD valign="top">#GetReasonClass.DD_Classification_Desc#</TD>			  
		 	</TR>	
      </cfif>
      <TR>
			  <TD align="right" nowrap valign="top"><B>Rebill Status:</B></TD>
			  <TD valign="top">
          <cfif (Deduction_Info.Rebill_Ack_Status EQ 1)>
            Set by #Deduction_Info.Rebilled_By#
          <cfelseif (Deduction_Info.Rebill_Ack_Status EQ 2)>
            Sent to ERP (#Deduction_Info.Rebill_Sent_On#)
          <cfelseif (Deduction_Info.Rebill_Ack_Status EQ 3)>
            Invoice confirmed (#Deduction_Info.Rebill_Ack_On#)
          <cfelseif (Deduction_Info.Rebill_Ack_Status EQ 4)>                
            Collected (#Deduction_Info.Rebill_Ack_On#)
          </cfif>
        </TD>
		  </TR>	
      <TR>
			  <TD COLSPAN="2"><HR COLOR="ORANGE"></TD>
		  </TR>      
   </cfif>
	
			<CFIF application.returned_customer_setting.DD_Assignment_Based_On_Customer EQ 0>	
			<TR>
				<TD align="right" nowrap valign="top"><B> #application.returned_customer_setting.billto_label#:</B></TD>
				<TD valign="top">
				#Deduction_Info.Name# (#Deduction_Info.Shr_Bill_To#)<Br>
				#Deduction_Info.Address1#<br>
				<cfif len(trim(Deduction_Info.Address2)) GT 0>#Deduction_Info.Address2#<br></cfif>
				#Deduction_Info.City#, #Deduction_Info.State# #Deduction_Info.Zip#<br>
				(#left(Deduction_Info.Phone, 3)#) #left(right(Deduction_Info.Phone, 7), 3)#-#right(Deduction_Info.Phone, 4)#			
				</TD>
			</TR>
			</CFIF>
			
			<cfif len(trim(Deduction_Info.Distributor_ID)) GT 0>
		
			<cfquery name="GetDistributor" datasource="#application.datasource#">
			SELECT Name, Address_1, Address_2, City, State, ZipCode, Phone,Shr_ship_to, Active_Code, Deleted
			FROM BSA_Foodservice_Customers
			WHERE BSA_Foodservice_Customers_ID = '#Deduction_Info.Distributor_ID#'
			</cfquery>
			
			<!--- 
				Tim Ford - Label 41048: Event error 'Variable SHOWSCISSOR is undefined' when previewing deduction 
				Paramed the showScissor variable above and addding display neq Preview below
			--->
			<cfif NOT isDefined("showScissor") and Display neq "Preview">
				<cfset useLakebaseForIsLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
				<cfif useLakebaseForIsLocked>
					<cftry>
						<cfset IsLocked = application.oLakebase.toQuery(
							application.oLakebase.selectRows("deductions", {
								"select" = "is_locked,locked_by",
								"deduction_id" = "eq.#URL.Deduction_ID#"
							}),
							"is_locked,locked_by"
						)>
						<cfcatch type="any">
							<cfset useLakebaseForIsLocked = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForIsLocked>
				<CFQUERY NAME="IsLocked" DATASOURCE="#Application.Datasource#">
					SELECT Is_Locked,Locked_By FROM Deductions WHERE Deduction_ID = '#URL.Deduction_ID#'
				</CFQUERY>
				</cfif>
				
				<CFIF IsLocked.Is_Locked EQ 1 AND IsLocked.Locked_By EQ "#request.AccessStructure.User_ID#">
					<CFSET DeductionLockStatus = 1>
				<CFELSE>
					<CFSET DeductionLockStatus = 0>
				</CFIF>
				<cfset showScissor = DeductionLockStatus />
			</cfif>
			<!---Query for ship to data from BSA_Foodservice_Customers table--->
			<TR>
				<TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.shard_ship_to_label#:</B></TD>
				<TD valign="top">
				#GetDistributor.Name# (#GetDistributor.Shr_ship_to#)<Br>
				#GetDistributor.Address_1#<br>
				<cfif len(trim(GetDistributor.Address_2)) GT 0>#GetDistributor.Address_2#<br></cfif>
				#GetDistributor.City#, #GetDistributor.State# #GetDistributor.ZipCode#<br>
				(#left(GetDistributor.Phone, 3)#) #left(right(GetDistributor.Phone, 7), 3)#-#right(GetDistributor.Phone, 4)#
				<cfif GetDistributor.Active_Code NEQ "A" OR GetDistributor.Deleted NEQ 0>
				<br><span style="color:red;font-weight:bold">** This #LCase(application.returned_customer_setting.shard_ship_to_label)# is inactive</span>
				</cfif>			
				</TD>
			</TR>


<form name="RemoveThisShipTo" method="post" action="/deductions/deduction.cfm" target="_parent">
<input name="Deduction_ID" value="#Deduction_Info.Deduction_ID#" type="hidden">
<input type="hidden" name="FormType" value="RemoveShipTo">
</form>
				</cfif>
		
			<cfif GetPrograms.Recordcount GT 0>	

			<TR>
				<TD align="right" nowrap valign="top"><B>Program:</B></TD>
				<TD valign="top">
				#GetPrograms.Contract_Title# (#GetPrograms.Contract_Number#)<br>
				#dateformat(GetPrograms.Contract_Start_Date, 'MM/DD/YYYY')# - #dateformat(GetPrograms.Contract_End_Date, 'MM/DD/YYYY')#
				</TD>
			</TR>
			</cfif> 		


			<TR>
				<TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.broker_label_singular#:</B></TD>
				<TD valign="top">
				#Deduction_Info.Broker_Name#<Br>
				#Deduction_Info.Account_Exec#<br>
				#Deduction_Info.Address#<br>
				<cfif len(trim(Deduction_Info.Address_2)) GT 0>#Deduction_Info.Address_2#<br></cfif>
				#Deduction_Info.Broker_City#, #Deduction_Info.Broker_State# #Deduction_Info.Broker_Zip#<br>
				(#Deduction_Info.Phone_1#) #Deduction_Info.Phone_2#-#Deduction_Info.Phone_3#
				<cfif len(trim(Deduction_Info.Phone_Ext)) GT 0>x#Deduction_Info.Phone_Ext#</cfif>
				<cfif Deduction_Info.Broker_Active_Code NEQ "A" OR Deduction_Info.Broker_Deleted NEQ 0>
				<br><span style="color:red;font-weight:bold">** This #LCase(application.returned_customer_setting.broker_label_singular)# is inactive</span>
				</cfif>
				</TD>
			</TR>
			<TR><!--- Dev Note: KAL; D7819 --->
				<TD align="right" nowrap valign="top"><B>#stDeductionLabels["Customer Reference"]#:</B></TD>
				<TD valign="top">#Deduction_Info.DD_Customer_RefNo#</TD>
			</TR><!--- End Note: KAL; D7819 --->
			<TR>
				<TD align="right" nowrap valign="top"><B>Deduction Age:</B></TD>
				<TD valign="top">#Deduction_Info.DD_Age# days</TD>
			</TR>
			<TR>
				<TD align="right" nowrap valign="top"><B>Deduction Date:</B></TD>
				<TD valign="top">#dateformat(Deduction_Info.DD_Date, 'MMMM D, YYYY')#</TD>
			</TR>
			<TR>
				<TD align="right" nowrap valign="top"><B>Deduction Amount:</B></TD>
				<TD valign="top">#LSCurrencyFormat(Deduction_Info.DD_Amount)#</TD>
			</TR>
			<cfif DeductionSettings.Images IS 1>
			<TR>
				<TD align="right" nowrap valign="top" height="40"><B>Images:</B></TD>
				<TD valign="top" height="40">Information on images is not available at this time</TD>
			</TR>
			</cfif>
			<TR>
				<TD align="right" nowrap valign="top"><B>#stDeductionLabels["Reference"]#:</B></TD>
				<TD valign="top">
				#Deduction_Info.DD_Reference#<br>
				 </TD>
			</TR>
			<!---115378 - Deduction Detail View: Adding Reason Code and Reason Code Description --->
			<TR>
				<TD align="right" nowrap valign="top"><B>#stDeductionLabels["Reason Code"]#:</B></TD>
				<TD valign="top">
					#Deduction_Info.DD_Resolution_Code#-#Deduction_Info.DD_Reason_Code_Description#<br>
				 </TD>
			</TR>
			<cfset useLakebaseForGetDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
			<cfif useLakebaseForGetDefault>
				<cftry>
					<cfset GetDefault = application.oLakebase.toQuery(
						application.oLakebase.selectRows("dd_classification", { "is_default" = "eq.1", "deleted" = "eq.0" })
					)>
					<cfcatch type="any">
						<cfset useLakebaseForGetDefault = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForGetDefault>
			<CFQUERY NAME="GetDefault" DATASOURCE="#Application.Datasource#">
				SELECT * FROM DD_Classification WHERE Is_Default = 1 AND Deleted = 0
			</CFQUERY>
			</cfif>
			<CFIF Deduction_Info.DD_Classification_Desc EQ "">				
				<CFSET Deduction_Info.DD_Classification_Desc = GetDefault.DD_Classification_Desc>
			</CFIF>
			<TR>
				<TD align="right" nowrap valign="top"><B>#stDeductionLabels["Classification"]#:</B></TD>
				<TD valign="top">
				#Deduction_Info.DD_Classification_Desc# <CFIF appSettings.getDDChangeClassificationBeforeRFA() AND (Deduction_Info.DD_Classification_ID EQ GetDefault.DD_Classification_ID OR Deduction_Info.DD_Classification_ID EQ "")><B>(<FONT COLOR="Red">** Change the default #stDeductionLabels["Classification"]# To Enable RFA</FONT>)</B></CFIF><br>
				 </TD>
			</TR>
			<!---26487 - 2011-mar-9 chrisn: added deduction type--->
			<TR>
				<TD align="right" nowrap valign="top"><B>#stDeductionLabels["Deduction Type"]#:</B></TD>
				<TD valign="top">#Deduction_Info.DeductionType_Desc#<br></TD>
			</TR>
			<!---115378 - Deduction Detail View: Adding Check Number --->
			<TR>
				<TD align="right" nowrap valign="top"><B>Check Number:</B></TD>
				<TD valign="top">
				#Deduction_Info.DD_Check_Number#<br>
				 </TD>
			</TR>
			<!---115378 - Deduction Detail View: Adding Check Date --->
			<TR>
				<TD align="right" nowrap valign="top"><B>Check Date:</B></TD>
				<TD valign="top">
					#dateformat(Deduction_Info.DD_Accounting_Date, 'MMMM D, YYYY')#<br>
				 </TD>
			</TR>
			<TR>
				<TD align="right" nowrap valign="top"><B>Check Amount:</B></TD>
				<TD valign="top">
					#LSCurrencyFormat(Deduction_Info.DD_Check_Amount)#<br>
				 </TD>
			</TR>
			<CFIF Deduction_Info.Is_Credit EQ 1 AND len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND Deduction_Info.DD_Closure_Type IS 6>
				<cfset useLakebaseForAssociatedDD = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
				<cfif useLakebaseForAssociatedDD>
					<cftry>
						<cfset AssociatedDD = application.oLakebase.toQuery(
							application.oLakebase.selectRows("deductions", { "deduction_id" = "eq.#Deduction_Info.DD_Closure_ID#" })
						)>
						<cfcatch type="any">
							<cfset useLakebaseForAssociatedDD = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForAssociatedDD>
				<CFQUERY NAME="AssociatedDD" DATASOURCE="#Application.Datasource#">
					SELECT * FROM Deductions WHERE Deduction_ID = '#Deduction_Info.DD_Closure_ID#'
				</CFQUERY>
				</cfif>
				<CFIF AssociatedDD.RecordCount GT 0>
				<!------ D10188 (DRK): NTS records should be read-only when interfaced and then re-opened  ----->
				<!------ If deduction re-open not acknowledged then prevent users from removing a ded from a credit.  ----->
				<CFIF AssociatedDD.ReOpened EQ 1 AND AssociatedDD.Ack_received_Reopen EQ 0>
					<CFSET ReOpenLogic_ShowLinks = 0>
				</CFIF>
				<TR>
					<TD align="right" nowrap valign="top"><CFIF NOT Isdefined("FORM.Comm_Type") AND NOT PrinterFriendly><cfif ReOpenLogic_ShowLinks EQ 1 AND AssociatedDD.DD_Status LT 3><CFIF showScissor EQ 1><a href="##" onClick="fnRemoveDDORCredit(2); return false;"><img src="/images/scissor.gif" border="0"></a></CFIF></CFIF></cfif>&nbsp;&nbsp;&nbsp;<B>Associated Deduction:</B></TD>
					<TD valign="top">
					<cfif NOT PrinterFriendly><A Href="/deductions/deduction.cfm?deduction_ID=#AssociatedDD.Deduction_ID#"  target="_parent"></cfif><B>#AssociatedDD.DD_DedID_SP_Number#</B><cfif NOT PrinterFriendly></A></cfif><br>
					 </TD>					 
				</TR>
				</CFIF>			
			</CFIF>			
			<TR>
				<TD align="right" nowrap valign="top"><B>Invoice Number:</B></TD>
				<TD valign="top">
				#Deduction_Info.DD_Invoice_Number#<br>
				 </TD>
			</TR>
			<cfif DeductionSettings.Invoices IS 1>
			<cfquery name="AreThereInvoices" datasource="#application.datasource#">
			SELECT Invoice_Header.Invoice_Header_ID, Invoice_Header.Shared_Invoice_Number, (SELECT SUM(cast(Invoice_Detail.Sales_Dollars as money)) FROM Invoice_Detail WHERE Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID) AS Invoice_Dollar_Total, Invoice_Header.Order_Number, Invoice_Header.Invoice_Version, Invoice_Header.Invoice_Date, BSA_Foodservice_Customers.Name AS Distributor_Name
			FROM DD_Relationships
				INNER JOIN Invoice_Header
				ON DD_Relationships.DD_Key_To_Relationship = Invoice_Header.Invoice_Header_ID
				INNER JOIN BSA_Foodservice_Customers
				ON Invoice_Header.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
			WHERE DD_Relationship_Type_ID = 3
			AND Deduction_ID = '#Deduction_ID#'
			</cfquery>
				<cfif AreThereInvoices.Recordcount GT 0>
				<TR>
					<TD align="right" nowrap valign="top"><B>Associated Invoice:</B></TD>
					<TD valign="top">
					<strong><CFIF NOT Isdefined("FORM.Comm_Type")><a href="javascript: void(0);" onClick="NewWindow('/search_Screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#AreThereInvoices.Invoice_Header_ID#','#trim(AreThereInvoices.Shared_Invoice_Number)#','850','600','Yes', 'Yes');"  >#AreThereInvoices.Invoice_Version#-#AreThereInvoices.Order_Number#</a><CFELSE>#AreThereInvoices.Invoice_Version#-#AreThereInvoices.Order_Number#</CFIF></strong>
					<Br>
					#lscurrencyformat(AreThereInvoices.Invoice_Dollar_Total)#
					<br>
					#AreThereInvoices.Distributor_Name#
					 </TD>
				</TR>
				</cfif>
			</cfif>
			
				<cfif DeductionSettings.Billback IS 1 AND len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND Deduction_Info.DD_Closure_Type IS 1>
			
			<cfquery name="GetBillbackInfo" datasource="#application.datasource#">
		SELECT 	Billback.Billback_ID, Billback.BB_Title, Billback.BB_Date, Billback.BB_Start_Date, Billback.BB_End_Date, Billback.BB_Amount, Billback.BB_Reference, Billback.BB_Code, Billback.Billback_Status_ID, Billback_Status.BB_Status_Description, ISNull(BB_Approved.Paid_Amount, 0) AS BB_Approved_Amount,
				BB_Approved.Vendor_Master_ID
		FROM Billback
		INNER JOIN Billback_Status ON Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
		INNER JOIN DD_Closure_Detail ON DD_Closure_Detail.DD_Closure_ID = Billback.Billback_ID AND DD_Closure_Detail.Deleted = 0
		LEFT JOIN BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
		WHERE Deduction_ID = '#Deduction_ID#'
		</cfquery>
			
				<cfif GetBillbackInfo.Recordcount GT 0>
				<TR>
					<TD align="right" nowrap valign="top">					
					<CFIF NOT Isdefined("FORM.Comm_Type")>
						<cfif ReOpenLogic_ShowLinks EQ 1 AND Deduction_Info.DD_Status LT 3>
							<CFIF showScissor EQ 1>
							<a href="##" onClick="removeAssoBB(); return false;"><img src="/images/scissor.gif" border="0"></a></CFIF>
						</CFIF>
					</cfif>&nbsp;&nbsp;&nbsp;
					<B>Associated Billback:</B>
					</TD>
					
					<TD valign="top">
					<table border="0" cellpadding="0" cellspacing="0">
					<CFLOOP QUERY="GetBillbackInfo">
					<tr><td><strong><strong><CFIF NOT Isdefined("FORM.Comm_Type")><a href="javascript: void(0);" onClick="NewWindow('/deductions/billback_details.cfm?Billback_ID=#Billback_ID#','BBDetail','850','600','Yes', 'Yes');"  >#BB_Code#</a><CFELSE>#BB_Code#</CFIF></strong></td><td><strong>&nbsp; &nbsp; #BB_Title#</strong></td></tr>
					<tr><td>#lscurrencyformat(BB_Approved_Amount)#</td><td>#dateformat(BB_Date, 'MM/DD/YYYY')#</td></tr>
					<cfif application.returned_customer_setting.Upload_GL_Code EQ 1 and Billback_Status_ID eq 3 and Vendor_Master_ID EQ "">
						<!---- for a specific client who user uplaod gl code,
						only if billback is in approved status
						and only if no vendor selected yet ---->
						<tr><td colspan="2">
							<CF_smallLink 
								title = "select vendor" 
								url = "billback_select_vendor.cfm?Billback_ID=#Billback_ID#&Deduction_ID=#Deduction_ID#"								
							>
						</td></tr>
					</cfif>
					<tr><td colspan="2">This billback is <i>#BB_Status_Description#</i></td></tr>					
					</CFLOOP>
					</table>
					 </TD>
				</TR>
				</cfif>
				<CFELSEIF len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND Deduction_Info.DD_Closure_Type IS 5>
				
				<cfset AssociatedCredit = DeductionManager.getAssociatedCredits(Deduction_ID) />
				<CFIF AssociatedCredit.RecordCount GT 0>
				<TR> 
					<TD align="right" nowrap valign="top">
					<CFSET CHANGE_CREDIT_ASSOC = 0 />
					<CFIF NOT Isdefined("FORM.Comm_Type")>
						<cfif ReOpenLogic_ShowLinks EQ 1 AND Deduction_Info.DD_Status LT 3>
							<CFIF showScissor EQ 1>
							<CFSET CHANGE_CREDIT_ASSOC = 1 />
							<a href="##" onClick="fnRemoveDDORCredit(1); return false;"><img src="/images/scissor.gif" border="0"></a></CFIF>
						</CFIF>
					</cfif>&nbsp;&nbsp;&nbsp;<B>Associated Credit:</B></TD>
					<TD valign="top">
					<CFIF AssociatedCredit.RecordCount EQ 1>
					<A Href="/deductions/deduction.cfm?deduction_ID=#AssociatedCredit.Deduction_ID#"  target="_parent"><B>#AssociatedCredit.DD_DedID_SP_Number#</B></A>
					<CFELSE>
					<A Href="##" OnClick="javascript: return viewMultipleAssociatedCredits();" ><B>Multiple...</B></A>
					&nbsp;&nbsp;
					<CF_smallLink 
						title = "view" 
						url = "##"
						parameters = "onClick=""javascript: return viewMultipleAssociatedCredits();"""
					>					
					</CFIF>
					<CFIF CHANGE_CREDIT_ASSOC EQ 1>
					&nbsp;&nbsp;
					<CF_smallLink 
						title = "edit" 
						url = "##"
						parameters = "onClick=""javascript: return editMultipleAssociatedCredits();"""
					>
					</CFIF>
					<br>
					 </TD>					 
				</TR>				
				</CFIF>
				
			</cfif>
			
<script>
function removeAssoBB()
{
	if (confirm("Are you sure you want to remove this associated billback(s)."))
	{
		window.parent.location.href = "/deductions/deduction.cfm?Deduction_ID=<CFOUTPUT>#Deduction_Info.Deduction_ID#</CFOUTPUT>&RemoveBB=1"		
	}
}
function viewMultipleAssociatedCredits()
{
	NewWindow('/deductions/credits/closure_detail.cfm?Deduction_ID=#Deduction_ID#', 'Deduction_Credit_Details','650','400','Yes', 'Yes');
	return false;
}
function editMultipleAssociatedCredits()
{
	window.location.href = "/deductions/Credits/LinkDeduction.cfm?Deduction_ID=#Deduction_ID#&FromDeduction=1";
	return false;
}
function fnRemoveDDORCredit(type)
{
	var displayText = "credit"
	if (type == 2)
	{
		displayText = "deduction"
	}
	if (confirm("Are you sure you want to remove this associated "+displayText+"."))
	{
		if (type == 1)
		{
			window.location.href="/deductions/inc_deduction_details.cfm?Deduction_ID=<CFOUTPUT>#Deduction_Info.Deduction_ID#</CFOUTPUT>&showScissor=1&AssociatedCredit=<CFOUTPUT>#Deduction_Info.DD_Closure_ID#</CFOUTPUT>"
		}
		else if (type == 2)
		{
			window.location.href="/deductions/inc_deduction_details.cfm?Deduction_ID=<CFOUTPUT>#Deduction_Info.Deduction_ID#</CFOUTPUT>&showScissor=1&AssociatedDeduction=<CFOUTPUT>#Deduction_Info.DD_Closure_ID#</CFOUTPUT>"
		}
		
	}
}
</script>

			<cfif DeductionSettings.ExcandAdj IS 1>
			<TR>
				<TD align="right" nowrap valign="top"><B>Adjustments &amp;<BR>
				Exclusions:</B>
				</TD>
				<TD valign="top">
				<li>
				<cfloop query="GetAdjustments">
				#LSCurrencyFormat(GetAdjustments.Adjustment_Amount)# applied on #DateFormat(GetAdjustments.Date_Applied, 'MM/DD/YYYY')#  <CFIF NOT Isdefined("FORM.Comm_Type")><A href="javascript: void(0);" onClick="NewWindow('/deductions/search_screens/adjustment_exclusions_detail.cfm?ID=#BB_Adjustment_ID#&Type= #DD_Relationship_Type_ID#', 'adjustmentsandexclusions', 500, 400, 'yes', 'yes')">(Details)</a></CFIF></li>
				</cfloop>
				<cfloop query="GetExclusions">
				<li>#LSCurrencyFormat(GetExclusions.Exclusion_Amount)# applied on #DateFormat(GetExclusions.Date_Applied, 'MM/DD/YYYY')#  
				<CFIF NOT Isdefined("FORM.Comm_Type")><A href="javascript: void(0);" onClick="NewWindow('/deductions/search_screens/adjustment_exclusions_detail.cfm?ID=#BB_Program_Exclusion_ID#&Type=#DD_Relationship_Type_ID#', 'adjustmentsandexclusions', 500, 400, 'yes', 'yes')">(Details)</a></CFIF>
				</li></cfloop>
				
				<cfif GetExclusions.Recordcount IS 0 AND GetAdjustments.Recordcount IS 0>
				No adjustments or exclusions associated with this deduction
				</cfif>
				</TD>
			</TR>
			</cfif>
			<!--- Last Rebill Date --->
			<TR>
				<TD align="right" nowrap valign="top"><B>Last Rebill Date:</B>
				</TD>
				<TD valign="top">
					<cfif CheckLocked.rebill_date eq "">None<cfelse>#dateformat(CheckLocked.rebill_date,"mm/dd/yyyy")#</cfif>
				</TD>
			</TR>
			
			<!--- User_References of deduction --->
			<TR>
				<TD valign="top" align="right"><B>#stDeductionLabels["User Ref 1"]#:</B></TD>
				<TD>#Deduction_Info.DD_User_Reference1#</TD>
			</TR>
			<TR>
				<TD valign="top" align="right"><B>#stDeductionLabels["User Ref 2"]#:</B></TD>
				<TD>#Deduction_Info.DD_User_Reference2#</TD>
			</TR>
			
				<!--- Current Owner of deduction --->
			<TR>
				<TD align="right" nowrap valign="top"><B>Current Owner:</B>
				</TD>
				<TD valign="top">
					#GetassignmentInfo.Who#
				</TD>
			</TR>
			
			<!--- List of all of deduction reassignments --->
		<!--- <cfif GetReassignInfo.Recordcount neq 0>
			<TR>
				<TD align="right" nowrap valign="top"><B>Analyst Reassignment:</B></TD>
				<TD valign="top">
					<ul style="margin-left:0px;">
					<cfloop query ="GetReassignInfo">
						<cfif GetReassignInfo.currentrow neq 1>
							<hr noshade width="150px;" align="left">
						</cfif>
						<li>From:&nbsp;#FromWho#</li>
						<li>To:&nbsp;#ToWho#</li>
						<li>By:&nbsp;#ByWho#</li>
						<li>Date:&nbsp;#Dateformat(Created_Date, "m/d/yyyy")# #Timeformat(Created_Date, "h:mm tt")#</li>
					</cfloop>
					</ul>
				</TD>
			</TR>
			</cfif> --->
					
			<cfif GetBrokerReassignHis.Recordcount neq 0>
			<TR>
				<TD align="right" nowrap valign="top"><B>Broker Reassignment:</B></TD>
				<TD valign="top">
					<ul style="margin-left:0px;">
					<cfloop query ="GetBrokerReassignHis">
						<cfif GetBrokerReassignHis.currentrow neq 1>
							<hr noshade width="150px;" align="left">
						</cfif>
						<li>From:&nbsp;#FBroker# (#FbrokerS#)</li>
						<li>To:&nbsp;#TBroker# (#TBrokerS#)</li>
						<li>By:&nbsp;#Name_First# #Name_Last#</li>
						<li>Date:&nbsp;#Dateformat(Created_Date, "m/d/yyyy")# #Timeformat(Created_Date, "h:mm tt")#</li>
					</cfloop>
					</ul>
				</TD>
			</TR>
			</cfif>
			<!--- <!---Show list of billbacks unpaid for this ship to--->
			<cfquery name="GetUnpaidBillbacks" datasource="#application.datasource#">
			SELECT Billback.Billback_ID, Billback.BB_Code, Billback.BB_Date, Billback.BB_Reference, Billback.BB_Title, BB_Approved.Authorized_Amount, Billback_Status.BB_Status_Description 
			FROM Billback
				INNER JOIN BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
				INNER JOIN Billback_Status ON Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
				AND Billback_Status.Status_Order_Number > 2 AND Billback_Status.Status_Order_Number < 7
			WHERE Billback.Deleted = 0
			ORDER BY BB_Code ASC
			</cfquery>

			<Cfif GetUnpaidBillbacks.Recordcount GT 0 AND showScissor EQ 1>
			<form action="deduction.cfm" target="_parent" method="post" name="AddThisBillback">
			<Tr><td align="right"><strong>Unpaid Billbacks for this <br>#application.returned_customer_setting.distributor_label_singular#:</strong></td><Td></TD></TR>
			<cfloop query="GetUnpaidBillbacks">
				
				<TR>
					<TD align="right" nowrap valign="top"><input type="radio" name="Billbacks" value="#Billback_ID#"></TD>
					<TD valign="top">
					<table border="0" cellpadding="0" cellspacing="0">
					<tr><td><strong><strong><CFIF NOT Isdefined("FORM.Comm_Type")><a href="javascript: void(0);" onClick="NewWindow('/deductions/billback_details.cfm?Billback_ID=#GetUnpaidBillbacks.Billback_ID#','BBDetail','850','600','Yes', 'Yes');"  >#GetUnpaidBillbacks.BB_Code#</a><CFELSE>#GetUnpaidBillbacks.BB_Code#</CFIF></strong></td><td><strong>&nbsp; &nbsp; #GetUnpaidBillbacks.BB_Title#</strong></td></tr>
					<tr><td>#lscurrencyformat(GetUnpaidBillbacks.Authorized_Amount)#</td><td>#dateformat(GetUnpaidBillbacks.BB_Date, 'MM/DD/YYYY')#</td></tr>
<tr><td colspan="2">This billback is <i>#GetUnpaidBillbacks.BB_Status_Description#</i></td></tr>
				</table>
					 </TD>
				</TR>
				
				</cfloop>
				<tr><td>&nbsp; </td><td>
				<CF_smallLink 
	title = "add this billback" 
	url = "##"
	parameters = "onClick=""javascript: AddThisBillback.submit();"""
></td></tr>
	<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
			</form>
			</CFIF> --->
			</TABLE>
</cfoutput>
<cfelse>

No deduction listed
</cfif>


</body></html>
