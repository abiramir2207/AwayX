<!---
BJF: This is designed to be a quick way to update information on a
particular deduction, and will be accessed from the scorecard.

Sections:
*Check to see if user can modify deductions
*Lock deduction
*Header information on deduction

Each of these will have user permissions and deduction status verified using existing logic
*Reassign (this parent/child only?)
*Classification
*Action
*Reopen -- removed, only available for approved+ billbacks
*Reject
*Upload document
*Notes

On submit the window should save to /deductions/update_status_action.cfm and close. Should it update parent?

--->

<!--- This page expects Deduction_ID to be passed to it --->

<!--- General page includes --->
<cfsilent>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>

	<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
	<cfinclude template="/deductions/Get_Lock_Status.cfm">
	<cfinclude template="/deductions/sql_Deduction_Info.cfm">

	<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
	<cfif useLakebaseForDeductionsProfilesSettings>
		<cftry>
			<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions_profiles_settings", {
					"profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDeductionsProfilesSettings = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDeductionsProfilesSettings>
	<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
	SELECT *
	FROM Deductions_Profiles_Settings
	WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
	</cfquery>
	</cfif>

	<CFQUERY NAME="Analyst_List" DATASOURCE="#Application.Datasource#">
		SELECT 		*
		FROM 		DD_Analyst
		INNER JOIN	_Users
		ON _Users.User_ID = DD_Analyst.Analyst_User_ID
		AND _Users.Deleted=0
		WHERE 		DD_Analyst.Deleted=0
    ORDER BY	_Users.Name_First,_Users.Name_Last
	</CFQUERY>

	<cfset useLakebaseForGetAllClass = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
	<cfif useLakebaseForGetAllClass>
		<cftry>
			<cfset GetAllClass = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_classification", {
					"deleted" = "eq.0",
					"order" = "dd_classification_desc.asc"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetAllClass = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetAllClass>
	<CFQUERY NAME="GetAllClass" DATASOURCE="#Application.Datasource#">
		SELECT *
		FROM DD_Classification
		WHERE Deleted = 0
		ORDER BY DD_Classification_Desc
	</CFQUERY>
	</cfif>
  <cfset useLakebaseForrsDeductionType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
  <cfif useLakebaseForrsDeductionType>
	<cftry>
		<cfset rsDeductionType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_type", {
				"select" = "deductiontype_desc,deductiontype_id",
				"deleted" = "eq.0",
				"order" = "deductiontype_desc.asc"
			}),
			"deductiontype_desc,deductiontype_id"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForrsDeductionType = false>
		</cfcatch>
	</cftry>
  </cfif>
  <cfif NOT useLakebaseForrsDeductionType>
  <cfquery name="rsDeductionType" datasource="#application.DataSource#">
    SELECT DeductionType_Desc, DeductionType_ID
      FROM Deduction_Type
     WHERE Deleted = 0
     ORDER BY DeductionType_Desc
  </cfquery>
  </cfif>

	<cfset useLakebaseForGetStages = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
	<cfif useLakebaseForGetStages>
		<cftry>
			<cfset GetStages = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_stage", {
					"select" = "dd_stage_description,dd_stage_id",
					"deleted" = "eq.0",
					"order" = "dd_stage_description.asc"
				}),
				"dd_stage_description,dd_stage_id"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetStages = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetStages>
	<cfquery name="GetStages" datasource="#application.datasource#">
	SELECT DISTINCT DD_Stage_Description, DD_Stage_ID
	FROM DD_Stage
	WHERE Deleted = 0
	ORDER BY DD_Stage_Description
	</cfquery>
	</cfif>


</cfsilent>
<cfparam name="CheckForAgreed.RecordCount" default=0>

<!--- Check for profile permissions to modify deduction--->
<cfif DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>

<!--- Handle for locking --->
<CFIF LockStatus EQ 2>
<!--- If the deduction is locked by another user --->
		<img src="/Images/readonly_mode.gif" title="This deduction is currently being viewed by: #ucase(CheckLocked.Name_First)# #ucase(CheckLocked.Name_Last)#"  border="0"><BR />
		<span style="color: RGB(255,0,0);font-size:12px;font-weight:bold;text-decoration:none;">Locked By<br /<cfoutput>>#ucase(CheckLocked.Name_First)# #ucase(CheckLocked.Name_Last)#</cfoutput></span>
<p></p>
You cannot update a locked deduction.

<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">
			Your changes have been made. You will need to refresh the list of records to see the changes displayed there.
			</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function closeWindow()
	{
		window.close()
	}
	window.setTimeout('closeWindow()', 2000);
	</SCRIPT>

<cfabort>
<cfelse>
<!--- Lock the deduction for this user --->
		<cfset useLakebaseForLockDD = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForLockDD>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#Deduction_ID#",
				"deleted" = "eq.0"
			},
			{
				"is_locked" = "1",
				"locked_by" = "#request.AccessStructure.user_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLockDD = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLockDD>
<CFQUERY NAME="LockDD" DATASOURCE="#Application.Datasource#">
		UPDATE 	Deductions
		SET 	Is_Locked = 1,
				Locked_By = '#request.AccessStructure.user_ID#'
		WHERE 	Deduction_ID = '#Deduction_ID#'
		AND Deleted=0
		</CFQUERY>
</cfif>
		<!--- reinclude lock include --->
		<cfinclude template="/deductions/Get_Lock_Status.cfm">
<!--- end locking code --->
</cfif>

<!--- HEADER INFORMATION --->
<!---Begin top display--->

<cfoutput>
	<TABLE border="0" cellpadding="4" id="table2" cellspacing="4">
	<TR>
		<TD nowrap ><B><FONT size="3">#Deduction_Info.DD_DedID_SP_Number#</FONT></B></TD>
		<TD  width="100%" >
		<cfif Deduction_Info.attachment_count gt 0>
			<table border="0">
				<tr>
					<TD width="99%" nowrap><B><FONT size="3"> <CFIF Deduction_Info.ShipToName NEQ "">#Deduction_Info.ShipToName# (#Deduction_Info.Shr_Ship_To#)<CFELSE>#Deduction_Info.Name# (#Deduction_Info.Shr_Bill_To#)</CFIF></FONT></B></TD>
					<TD width="1%"><IMG  align="right"   SRC="/images/doc.gif" width="13" height="16" TITLE="This program has #Deduction_Info.attachment_count# attached document(s)"></TD>
				</tr>
			</table>
		<cfelse>
				<B><FONT size="3"> <CFIF Deduction_Info.ShipToName NEQ "">#Deduction_Info.ShipToName# (#Deduction_Info.Shr_Ship_To#)<CFELSE>#Deduction_Info.Name# (#Deduction_Info.Shr_Bill_To#)</CFIF></FONT></B>
		</cfif>
		</TD>
		<TD nowrap ><B><FONT size="3">
		#Deduction_Info.DD_Stage_Description#
		</FONT></B></TD>

		<TD nowrap ><B><FONT size="3">
				<cfif Deduction_Info.DD_Status IS 3>
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
				<cfelse>
					#Deduction_Info.DDStatus#
				</cfif>
		</FONT></B></TD>
		<TD nowrap ><B><FONT size="3">#Deduction_Info.DD_Age#
			Days</FONT></B></TD>
		<TD nowrap ><B><FONT size="3">#LSCurrencyFormat(Deduction_Info.DD_Amount)#</FONT></B></TD>
		<!---
		<cfif appSettings.get_Setting('Quick_Pay_in_Program_Search') eq '2' AND Deduction_Info.DD_ISParent EQ 1 AND Deduction_Info.DD_Status LT 3>
			<TD nowrap ><a id="QuickPay"><cfoutput>#application.util.string.actionLinkFormat2('Quick Pay')#</cfoutput></a></TD>
		</cfif>
	--->
	</TR>
</TABLE>

<hr width="800" color="navy">
<!--- D29481:Non trade deductions START--->
		<cfif appSettings.getDD_Allow_Non_Trade()>
			<div align="right">
				<!--- This condition check if user can close deduction as non trade --->
				<cfif ReOpenLogic_ShowLinks EQ 1 AND Deduction_Info.Is_Write_Off NEQ 1  AND (
							  (Deduction_Info.Is_Non_trade_Off NEQ 1 AND (Deduction_Info.DD_Status EQ 1 OR Deduction_Info.DD_Status EQ 2)  AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0)
							  OR
							  (Deduction_Info.Is_Non_trade_Off EQ 1 AND Deduction_Info.DD_Status LT 4)
							  )
							  AND LockStatus EQ 1 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
							  AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1)>

					<CF_button
						button_name		=	""
						button_caption	=	"Close As Non Trade"
						button_action	=	"window.location.href='/deductions/closure/DD_Non_trade_all_items.cfm?Deduction_ID=#Deduction_ID#&Profile_ID=#Get_Profile_Settings.Profiles_ID#&from=pop-up'"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Close Deduction As Non Trade"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				<!--- This condition check if user closed deduction as non trade --->
				<cfelseif ReOpenLogic_ShowLinks EQ 1 AND Deduction_Info.Is_Write_Off NEQ 1  AND Deduction_Info.Is_Non_trade_Off EQ 1 AND
							      (Deduction_Info.DD_Status EQ 1 OR Deduction_Info.DD_Status EQ 2)  AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
								  AND LockStatus EQ 1 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1 AND ((CheckForChild.RecordCount EQ 0 AND
								  Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1)>

					<CF_button
						button_name		=	""
						button_caption	=	"Open Non Trade"
						button_action	=	"window.location.href='/deductions/closure/DD_Non_trade_to_open.cfm?Deduction_ID=#Deduction_ID#&Profile_ID=#Get_Profile_Settings.Profiles_ID#&from=pop-up'"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Open Deduction As Non Trade"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>

				<cfelse>
					<div style="color: gray;font-weight:bold;">
					<span class="bracket">[</span>
						Close As Non Trade
					<span class="bracket">]</span>
					<img src="/images/doc.gif" border="0" width="10" height="13" onclick="window.open('/deductions/closure/DD_Non_trade_Items_info.cfm?Deduction_ID=#Deduction_ID#&Profile_ID=#Get_Profile_Settings.Profiles_ID#','Deduction_Info', 'width=800, height=600');">
					</div>
			    </cfif>

			</div>
		</cfif>
<!--- D29481:Non trade deductions END--->
	</cfoutput>
<div align="center"><font color="red">All changes and information are optional</font></div>

<!--- END HEADER INFORMATION --->

<!---Begin body table & form --->
<table  border="0" cellpadding="0" cellspacing="2" align="center">
<form name="MyForm" method="post" action="/deductions/update_status_action.cfm" enctype="multipart/form-data" onsubmit="return validateForm()">
	<!--- REASSIGN --->
	<cfif appSettings.getDD_Show_reassign()>
	<CFIF ReOpenLogic_ShowLinks EQ 1 AND DeductionsProfilesSettings.DD_Reassign_Access EQ 1	AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>

			<TR>
				<TD align="right"><B>Pick analyst:&nbsp;&nbsp;</B>
				</TD>
				<TD>
					<SELECT NAME="To_Analyst" STYLE="WIDTH: 250px">
						<OPTION VALUE="">
						<CFOUTPUT QUERY="Analyst_List">
							<OPTION VALUE="#Analyst_List.Analyst_User_ID#" <cfif Deduction_Info.Analyst_User_ID EQ Analyst_List.Analyst_User_ID>selected</cfif>>#Analyst_List.Name_First# #Analyst_List.Name_Last#</OPTION>
						</CFOUTPUT>
					</SELECT>
				</TD>
			</TR>
	</cfif>
	</cfif>
	<cfoutput><input type="hidden" name="Old_Analyst" value="#Deduction_Info.Analyst_User_ID#"></cfoutput>

	<!--- END REASSIGN --->

	<!--- CLASSIFICATION --->
	<cfif appSettings.getDD_Show_Classification()>
	<CFIF  ReOpenLogic_ShowLinks EQ 1 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
			<TR>
			<TD align="right"><B><cfoutput>Pick #LCase(stDeductionLabels["Classification"])#</cfoutput>:&nbsp;&nbsp;</B>
			</TD>
			<TD>
				<SELECT NAME="DD_Classification_ID" STYLE="WIDTH: 250px">
					<CFOUTPUT QUERY="GetAllClass">
						<OPTION VALUE="#GetAllClass.DD_Classification_ID#" <CFIF GetAllClass.DD_Classification_ID EQ Deduction_Info.DD_Classification_ID>SELECTED</CFIF>>#GetAllClass.DD_Classification_Desc#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
		</TR>
	</CFIF>
	<!---26487 - 2011-mar-9 chrisn: added deduction type--->
	<cfif appSettings.getDD_Show_DeductionType()>
    <cfif  ReOpenLogic_ShowLinks EQ 1 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
      <tr>
        <TD align="right"><b><cfoutput>Pick #LCase(stDeductionLabels["Deduction Type"])#</cfoutput>:&nbsp;&nbsp;</b> </TD>
        <TD><select name="DeductionType_ID" style="WIDTH: 250px">
  				  <!---create a blank value option when field is not populated--->
  				  <cfif Deduction_Info.DeductionType_ID eq "">
  						<option value="" SELECTED>&nbsp;</option>
  				  </cfif>
            <cfoutput query="rsDeductionType">
              <option value="#rsDeductionType.DeductionType_ID#" <CFIF rsDeductionType.DeductionType_ID EQ Deduction_Info.DeductionType_ID>SELECTED</CFIF>>#rsDeductionType.DeductionType_Desc#</option>
            </cfoutput>
          </select>
        </TD>
      </tr>
    </cfif>
    </cfif>
	</cfif>
	<cfoutput>
		<input type="hidden" name="Old_Classification" value="#Deduction_Info.DD_Classification_ID#">
	    <input type="hidden" name="Old_DeductionType"  value="#Deduction_Info.DeductionType_ID#">        <!---26487--->
	</cfoutput>
	<!--- END CLASSIFICATION --->

	<!--- Reference Number--->
	<cfif appSettings.get_Setting('DD_Edit_Reference') eq '1'>
	<TR>
		<TD align="right"><B>Reference Number:&nbsp;&nbsp;</B></TD>
		<TD>
			<cfoutput>
				<input type="text" name="Reference_Number" value="#Deduction_Info.DD_Reference#">
			</cfoutput>
		</TD>
	</TR>
	<cfelse>
		<cfoutput><input type="hidden" name="Reference_Number" value="#Deduction_Info.DD_Reference#"></cfoutput>
	</cfif>
	<input type="hidden" name="Old_Reference_Number" value="#Deduction_Info.DD_Reference#">
	<!---END Reference Number--->

	<!--- ACTION --->

	<CFIF DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
			<TR>
			<TD align="right"><B><cfoutput>Pick an #LCase(stDeductionLabels["Action"])#</cfoutput>:&nbsp;&nbsp;</B>
			</TD>
			<TD>
				<select name="DD_Stage_ID" STYLE="WIDTH: 250px">
					<option value="0">&nbsp;</option>
					<cfoutput query="GetStages">
					<option value="#GetStages.DD_Stage_ID#" <cfif GetStages.DD_Stage_ID EQ Deduction_Info.DD_Stage>selected</cfif> >#GetStages.DD_Stage_Description#</option>
					</cfoutput>
				</select>

			</TD>
		</TR>
	</cfif>
	<cfoutput><input type="hidden" name="Old_Stage" value="#Deduction_Info.DD_Stage#"></cfoutput>
	<!--- END ACTION --->

	<!--- REJECT --->
	<CFIF appSettings.getDD_Show_Reject()>
	<CFIF Deduction_Info.Is_Write_Off EQ 0 AND ReOpenLogic_ShowLinks EQ 1 AND Deduction_Info.DD_Rejected NEQ 1 AND LockStatus EQ 1 AND
	(Deduction_Info.DD_IsChild NEQ 1 OR CheckForChild.RecordCount EQ 0) AND DeductionsProfilesSettings.DD_Reject EQ 1 AND
	Deduction_Info.DD_Status LT 3 AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0 AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1  AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1)>

		<TR>
			<TD align="right" valign="top"><B>Reject:&nbsp;&nbsp;</B>
			</TD>
			<TD>
				<input type="checkbox" name="Reject" value="1"><br>
				<TEXTAREA NAME="DD_Rejected_Reason" COLS="47" ROWS="6" onPaste="javaScript: return textareaChecklength('250', this);"  onkeyPress="javaScript: return textareaChecklength('250', this);">Enter rejection reason here</TEXTAREA>
			</TD>
		</TR>

	</CFIF>
	</CFIF>

	<!--- END REJECT --->

	<!--- NOTES --->
	<cfif ReOpenLogic_ShowLinks EQ 1>
	<tr>
		<TD align="right" valign="top">
			<strong>Notes:&nbsp;&nbsp;</strong>
		</TD>
		<TD>
	<textarea name="DD_Note" COLS="47" ROWS="6" maxlength="255"></textarea>
		</TD>
	</tr>
	</cfif>
	<!--- END NOTES --->
<!--- D42846 :: Deduction tool upgrades START--->
<cfoutput>
		<tr>
			<TD align="right" valign="top">
				<strong>#stDeductionLabels["User Ref 1"]#:&nbsp;&nbsp;</strong>
			</TD>
			<TD>
				<input type="text" name="DD_User_Reference1" value="#Deduction_Info.DD_User_Reference1#" style="width: 250px">
				<input type="hidden" name="Old_DD_User_Reference1" value="#Deduction_Info.DD_User_Reference1#">
			</TD>
		</tr>
		<tr>
			<TD align="right" valign="top">
				<strong>#stDeductionLabels["User Ref 2"]#:&nbsp;&nbsp;</strong>
			</TD>
			<TD>
				<input type="text" name="DD_User_Reference2" value="#Deduction_Info.DD_User_Reference2#" style="width: 250px">
				<input type="hidden" name="Old_DD_User_Reference2" value="#Deduction_Info.DD_User_Reference2#">
			</TD>
		</tr>
</cfoutput>
<!--- D42846 :: Deduction tool upgrades END--->
	<tr><Td colspan="100%"><hr width="100%" color="navy"></Td></tr>
	<!--- UPLOAD DOCUMENT --->
	<cfoutput>
	<TR>
		<TD VALIGN="top" ALIGN="right" NOWRAP>
			<SPAN ID="ERR_FILE"></SPAN>&nbsp;<B>Select Upload File </B></TD>
		<TD VALIGN="top"><INPUT SIZE="45" TYPE="file" NAME="File_Path" onchange="javascript: autofill()"></TD>
	</TR>
	<TR>
		<TD VALIGN="top" ALIGN="right"><B>File Name</B></TD>
		<TD VALIGN="top"><INPUT SIZE="45" NAME="Doc_File" VALUE="" MAXLENGTH="50" READONLY DISABLED>
						<INPUT TYPE="hidden" NAME="Doc_File_Name" VALUE="">
		</TD>
	</TR>
	<TR>
		<TD VALIGN="top" ALIGN="right"><SPAN ID="ERR_TITLE"></SPAN>&nbsp;<B>Title</B></TD>
		<TD VALIGN="top"><INPUT SIZE="45" NAME="Doc_Title" VALUE="" MAXLENGTH="45"></TD>
	</TR>

	<cfset PrivacyOff = appSettings.getUploadDocumentPrivacyOff()>

	<cfif PrivacyOff EQ 0>
		<CFSET PublicChecked = "Checked">
	<cfelse>
		<CFSET PublicChecked = "">
	</cfif>

	<TR>
		<TD VALIGN="Top" ALIGN="Right"><SPAN ID="ERR_PUBLIC"></SPAN>&nbsp;<B>Private</B></TD>
		<TD VALIGN="Top">
			<INPUT TYPE="CheckBox" NAME="Doc_Public" VALUE="1" #PublicChecked#>
		</TD>

	</TR>
	<TR>
		<TD VALIGN="top" ALIGN="right"><SPAN ID="ERR_DESC"></SPAN>&nbsp;<B>Description</B></TD>

		<TD VALIGN="top">
			<TEXTAREA COLS="47" ROWS="6" NAME="Doc_Description" ONBLUR="Javascript: CheckLength()" ></TEXTAREA>
</TD>

	</TR>
	</cfoutput>
	<!--- END UPLOAD DOCUMENT --->
	<cfoutput><input type="hidden" name="Deduction_ID" value="#Deduction_ID#"></cfoutput>
	<!--- Submit button --->
	<tr>
		<TD colspan="100%" align="right">
			<input type="Submit" value="Save Changes">
		</TD>
	</tr>
	<!--- END Submit button --->

</form>
</table>
<!---Begin body table & form --->

<!--- User has view only rights --->
<cfelse>

You do not have permission to update this deduction.

<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">
			Your changes have been made. You will need to refresh the list of records to see the changes displayed there.
			</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function closeWindow()
	{
		window.close()
	}
	window.setTimeout('closeWindow()', 2000);
	</SCRIPT>

<!--- END Check for profile permissions to modify deduction--->
</cfif>


<cfinclude template="\common_files\jQuery.cfm">

<!--- Javascript functions --->
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
<script>
function autofill()
{
	var x = document.MyForm.File_Path.value;
	var len = x.length;
	var position = x.lastIndexOf("\\");
	var filename=x.substr(position+1,len);
	document.all.Doc_File.value = filename;
	document.all.Doc_File_Name.value = filename;
}

function CheckLength()
{
	var x=document.MyForm.Doc_Description.value;

	//////Trim extra white space
	var re = /\s+/ig;
	document.MyForm.Doc_Description.value = x.replace(re," ");
	//////Trim extra white space

	x=document.MyForm.Doc_Description.value;

	var len = x.length;
	if (len > 350)
	{
		var trunc_length = confirm("The size of Description is more than 350 characters. Press OK to truncate and save OR press cancel to modify it")
		if (trunc_length == true)
		{
			y=x.substr(0,350);
			document.MyForm.Doc_Description.value=y;
		}
		else
		{
			document.MyForm.Doc_Description.focus();
		}

	}

}

function validateForm() {
	if ( $('select[name=DD_Stage_ID]').val() == "0" ) {
		<cfoutput>alert('Please pick an #LCase(stDeductionLabels["Action"])#');</cfoutput>
		return false;
	}
	return true;
}
/*
$("#QuickPay").click(function(){
	var QuickPayHeight =  window.screen.height;
	var QuickPayWidth =  window.screen.width;

	window.open('/Scorecard/adv_quick_pay_DD.cfm?<cfoutput>Overspend=#Get_Profile_Settings.AQP_Max_Overspend#&Deduction_ID=#Deduction_ID#</cfoutput>','AdvanceQuickPay','width=QuickPayWidth,height=QuickPayHeight,scrollbars=1');
})*/
</script>