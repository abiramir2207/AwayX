
<!--- Settings panel to determine which fields are included in
		the Margin calculation for Brokerage --->
<cfparam name="form.brkMrg" 	default="0">
<cfset callingPage = "/settings/app_settings.cfm?command=settings6">
<cfset brkMarginCalc = CreateObject("component", "Components.Programs.Approval.BrokerageMarginCalc").init() />
<cfset qGetMarginCalc = brkMarginCalc.getMarginCalcSetting() />
<cfif form.brkMrg>

	<CFOUTPUT QUERY="qGetMarginCalc">
		<cfset thisStatus = evaluate("Form.#qGetMarginCalc.Column_Name#")/>
		<cfset setbrkMarginSetting = brkMarginCalc.updBrkMrgCalcSetting(qGetMarginCalc.Column_Name,thisStatus,request.accessstructure.user_id)/>
	</CFOUTPUT>
	<cflocation addtoken="No" url="#callingPage#">
	<cfabort>
</cfif>

<hr class="four">
<div align="left" width="700">
<br>
<table cellpadding="2" cellspacing="3" border="0" width="700">
	<tr>
		<td>
			<cfif qGetMarginCalc.UpD_User_ID neq '00000000-0000-0000-0000000000000000'>
				<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0" width="500">
				<TR>
					<TD>
						<FONT SIZE="2">
							<B><CFOUTPUT>The settings were last updated on #dateformat(qGetMarginCalc.Upd_Date, 'mm/dd/yyyy')#
							#timeformat(qGetMarginCalc.Upd_Date, 'hh:mm:ss TT')# by
							#qGetMarginCalc.UpdatedByFullName#</CFOUTPUT>
							</B>
						</FONT>
					</TD>
				</TR>
				</TABLE>
			</cfif>
		</td>
	</tr>
	<tr>
		<td>
			<table>
					<tr>
						<th><font color="navy">Margins - Brokerage Margin Calculation Settings</font></th>
					</tr>
			</table>
		</td>
	</tr>
	<CFIF application.appSettingsGet.getBrokerage_Margin_Calculation()>
	<tr>
		<td>
			<FORM NAME="Brk_Mrgn_Calc" ACTION="/settings/Brokerage_Margin_Calc_Settings.cfm" method="post" style="display:inline;">
			<table cellpadding="2" cellspacing="2" border="0">
				<CFOUTPUT QUERY="qGetMarginCalc">
				<tr valign="top">
					<td nowrap>#replace(qGetMarginCalc.Column_Name,"_"," ")#:</td>
					<td>&nbsp; </td>
					<td align="left">
						<select name="#qGetMarginCalc.Column_Name#">
							<option value="0" <cfif qGetMarginCalc.status EQ 0>selected</cfif>>Net out of Base Sales</option>
							<option value="1" <cfif qGetMarginCalc.status EQ 1>selected</cfif>>Add To NET to get Broker Base</option>
						</select>
					</td>
				</tr>
				</CFOUTPUT>
			</table>
			<input type="Hidden" name="brkMrg" value="1">
			</FORM>
		</td>
	</tr>
	<tr>
		<td>
			<div align="center">
				<CF_button
						button_name		=	""
						button_caption	=	"Save"
						button_action	=	"document.Brk_Mrgn_Calc.submit();"
						button_type		=	"javascript_link"
						button_width	=	"150"
						button_color	=	"Navy"
						button_tip		=	"Save"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
						>
			</div>
		</td>
	</tr>
	<CFELSE>
	<tr>
		<td>
			The "Brokerage Margin Calculation" Application Setting Must Be Turned on To Manage This
		</td>
	</tr>
	</CFIF>
</table>
</div>
