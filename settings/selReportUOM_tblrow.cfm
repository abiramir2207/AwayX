<cfset useLakebaseForgetCurrentSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetCurrentSettings>
	<cftry>
		<cfset getCurrentSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "usdanoi_i_agree_enabled"
			}), "usdanoi_i_agree_enabled"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCurrentSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCurrentSettings>
<cfquery name="getCurrentSettings" datasource="#application.datasource#">
	SELECT USDANOI_I_Agree_Enabled
	FROM general_Settings
</cfquery>
</cfif>

<cfoutput>
<tr id="dropdown_row">
<td colspan="100%" align="center" bgcolor="##FFFFFF">
<table width="100%">
	<tr >
		<cfif getCurrentSettings.USDANOI_I_Agree_Enabled EQ 1>
		<td valign="top" align="left" style="cursor: help;" title="I&nbsp;<cfif getLatestAgreement.user_agrees EQ 1>AGREE<cfelse>DO NOT AGREE</cfif>:&nbsp;&nbsp;#HTMLEditFormat(getLatestAgreement.notes)#">
			<input type="checkbox" name="I_Agree_ChkBx" value="1" style="cursor: default;" onClick="showAgreementForm()"> <span style="font-size: 12px; font-weight: bold;">Click here to respond to this report<cfif getLatestAgreement.recordcount NEQ 0><br>Last Respond to on #DateFormat(getLatestAgreement.DateTimeStamp, 'm/d/yyyy')# <!--- - #TimeFormat(getLatestAgreement.DateTimeStamp, 'hh:mm:ss')# --->by #getLatestAgreement.Name_First# #getLatestAgreement.Name_Last#</cfif></span>
		</td>
		</cfif>
		<td align="right">
			<table cellspacing="3" cellpadding="3">
				<tr>
					<td align="right" nowrap>
						<span style="font-size: 11px; font-weight: bold;">Report Type:</span><br>
						<select name="selReportType" onchange="changeReportUOM()">
						<option value="operator" <cfif lcase(url.ReportType) EQ "operator"> SELECTED</cfif>>#application.returned_customer_setting.operator_label_singular#</option>
						<option value="item" <cfif lcase(url.ReportType) EQ "item"> SELECTED</cfif>>Item</option>
						<option value="operator-item" <cfif lcase(url.ReportType) EQ "operator-item"> SELECTED</cfif>>#application.returned_customer_setting.operator_label_singular#-Item</option>
						<option value="operator-month-item" <cfif lcase(url.ReportType) EQ "operator-month-item"> SELECTED</cfif>>#application.returned_customer_setting.operator_label_singular#-Month-Item</option>
						</select>							
					</td>
					
					<td align="right" nowrap>
						<span style="font-size: 11px; font-weight: bold;">Report Unit Of Measure:</span><br>
						<select name="selReportUOM" onchange="changeReportUOM()">
						<option value="1" <cfif url.ReportUOM EQ "1"> SELECTED</cfif>>Cases</option>
						<option value="2" <cfif url.ReportUOM EQ "2"> SELECTED</cfif>>Pounds</option>
						<option value="rm" <cfif url.ReportUOM EQ "rm"> SELECTED</cfif>>Raw Materials</option>
						</select>
					</td>
					
					<td align="right" nowrap>
						<span style="font-size: 11px; font-weight: bold;">Show #application.returned_customer_setting.distributor_label_singular# Delivery Detail:</span><br>
						<select name="selReportBBDetail" onchange="changeReportUOM()">
						<option value="0" <cfif url.ReportBBDetail EQ "0"> SELECTED</cfif>>No</option>
						<option value="1" <cfif url.ReportBBDetail EQ "1"> SELECTED</cfif>>Yes</option>
						</select>
						<input type="Button" onclick="document.all.frmChangeReportUOM.submit()" value="run report">
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</td>
</tr>
</cfoutput>