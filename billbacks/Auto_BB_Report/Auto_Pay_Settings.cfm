<cfmodule template="/customTags/layout.cfm"
							layoutID = "autoPay"
							selectedIndex = #nav_index#>
<!--- 48219 --->
<style>
table.autopay { border-spacing:3px; border-collapse:separate; margin:0; padding:0; }
table.autopay td { padding:3px 4px; }
table.status { border:3px solid orange; }
td.status { font-weight:bold; font-size:1.1em; }
</style>
<CFOUTPUT>
<CFPARAM NAME="FORM.Submitted" DEFAULT="0">

<CFIF FORM.Submitted EQ 0>
	<CFQUERY NAME="GetData" DATASOURCE="#Application.Datasource#">
		SELECT 		Adjustment_From_Program_WithOut_PullBack,
					Adjustment_From_Program_With_PullBack,
					_Users.Name_First + ' ' + _Users.Name_Last UpdatedBy,
					Pullback_Adjustment_Updated_On
		FROM		Billback_Settings
		LEFT JOIN 	_Users ON _Users.User_ID = Billback_Settings.Pullback_Adjustment_Updated_By
	</CFQUERY>
	<BR>
	<TABLE class="autopay status">
		<TR>
			<TD class="status">This setting was last updated By &nbsp;<CFOUTPUT>#GetData.UpdatedBy#</CFOUTPUT> on <CFOUTPUT>#dateformat(GetData.Pullback_Adjustment_Updated_On, 'm/d/yyy')#
				#timeformat(GetData.Pullback_Adjustment_Updated_On, 'h:mm:ss TT')#</CFOUTPUT>
			</TD>
		</TR>
	</TABLE>

	<FORM ACTION="Auto_Pay_Settings.cfm" METHOD="post" NAME="MyForm">
		<INPUT TYPE="hidden" NAME="Submitted" VALUE="1">
		<TABLE class="autopay">
			<TR>
				<TD><B>When a billback is from a program that does not have recapture and the billback has deviations then auto pay will:</B></TD>
				<TD>
					<SELECT NAME="Program_No_PullBack"  >
						<OPTION VALUE="1" <CFIF GetData.Adjustment_From_Program_WithOut_PullBack EQ 1>SELECTED</CFIF>>Apply</OPTION>
						<OPTION VALUE="2" <CFIF GetData.Adjustment_From_Program_WithOut_PullBack EQ 2 OR GetData.Adjustment_From_Program_WithOut_PullBack EQ 0>SELECTED</CFIF>>Remove</OPTION>
						<!--- <OPTION VALUE="3" <CFIF GetData.Adjustment_From_Program_WithOut_PullBack EQ 3 OR GetData.Adjustment_From_Program_WithOut_PullBack EQ 0>SELECTED</CFIF>>Ignore</OPTION>
						<OPTION VALUE="4" <CFIF GetData.Adjustment_From_Program_WithOut_PullBack EQ 4>SELECTED</CFIF>>Recalc</OPTION> --->
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD><B>When a billback is from a program that has recapture and the billback has deviations then auto pay will:</B></TD>
				<TD>
					<SELECT NAME="Program_With_PullBack"  >
						<OPTION VALUE="1" <CFIF GetData.Adjustment_From_Program_With_PullBack EQ 1>SELECTED</CFIF>>Apply</OPTION>
						<OPTION VALUE="2" <CFIF GetData.Adjustment_From_Program_With_PullBack EQ 2 OR GetData.Adjustment_From_Program_With_PullBack EQ 0>SELECTED</CFIF>>Remove</OPTION>
						<!--- <OPTION VALUE="3" <CFIF GetData.Adjustment_From_Program_With_PullBack EQ 3 OR GetData.Adjustment_From_Program_With_PullBack EQ 0>SELECTED</CFIF>>Ignore</OPTION>
						<OPTION VALUE="4" <CFIF GetData.Adjustment_From_Program_With_PullBack EQ 4>SELECTED</CFIF>>Recalc</OPTION> --->
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD>&nbsp;</TD>
				<TD  Align="Center">
					<FONT COLOR="##ff0000" SIZE="2"><B>[</B></FONT>
							<A HREF="javascript: document.MyForm.submit()"><B>save</B></A>
					<FONT COLOR="##ff0000" SIZE="2"><B>]</B></FONT>
				</TD>
			</TR>
		</TABLE>
			<input type="hidden" name="nav_index" value="#nav_index#">
	</FORM>
<CFELSE>

	<CFQUERY NAME="UpdDate" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Settings
		SET 	Adjustment_From_Program_WithOut_PullBack = #FORM.Program_No_PullBack#,
				Adjustment_From_Program_With_PullBack = #FORM.Program_With_PullBack#,
				Pullback_Adjustment_Updated_By =  '#request.AccessStructure.user_id#',
				Pullback_Adjustment_Updated_On = GetDate()
	</CFQUERY>
	<CFLOCATION URL="auto_pay_settings.cfm?nav_index=#nav_index#">
</CFIF>
</CFOUTPUT>
</cfmodule>