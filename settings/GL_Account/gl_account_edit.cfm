<cfif isDefined("stError") and stError.bNameExists>
	<script>
		alert("<cfoutput>#Application.GLAccountLabel#</cfoutput> already exists.");
	</script>
</cfif>
<cfif not isDefined("glUsedInProgram")>
	<cfset glUsedInProgram = 0 />
</cfif>

<CFIF qGetCompRebates.Last_Updated_By NEQ "">
	<cfset useLakebaseForgetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserName>
	<cftry>
		<cfset getUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#qGetCompRebates.Last_Updated_By#",
				"select" = "name_last as user_fullname"
			}), "name_last as user_fullname"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserName>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
		SELECT 	_Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
		FROM 	_Users
		WHERE 	User_ID = '#qGetCompRebates.Last_Updated_By#'
	</CFQUERY>
</cfif>
</CFIF>
<CFIF qGetCompRebates.Last_Updated_By NEQ "">
	<div  width="800">
		<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;align:center;" CELLPADDING="3" CELLSPACING="0">
		<tr><td align="center">
		<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(qGetCompRebates.Last_Updated_Date, 'm/d/yyy')# #timeformat(qGetCompRebates.Last_Updated_Date, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#getUserName.User_FullName#</CFOUTPUT></B></FONT>
		</td></tr></table>
	</div>
</CFIF>

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#Application.GLAccountLabel#</cfoutput>s</LEGEND><!---D42774 --->
	<cfoutput> 
		<table width="90%" border="0" cellpadding="3" cellspacing="0">
			<TR <cfif glUsedInProgram>TITLE="This #Application.GLAccountLabel# is already used in a program"</cfif>><!---D42774 --->
				<TD ALIGN="right" class="Orangline"><B>#Application.GLAccountLabel#:</B></TD><!---D42774 --->
				<TD>
					<cfif glUsedInProgram>
					<INPUT NAME="GL_Account" TYPE="text" SIZE="25" MAXLENGTH="50" value="#qGetCompRebates.GL_Account#" DISABLED>
					<INPUT NAME="GL_Account" TYPE="hidden" value="#qGetCompRebates.GL_Account#">
					<cfelse>
					<INPUT NAME="GL_Account" TYPE="text" SIZE="25" MAXLENGTH="50" value="#qGetCompRebates.GL_Account#">
					</cfif>
				</TD>
			</TR>		
			<TR>
				<TD ALIGN="right" class="Orangline"><B>Description:</B></TD>
				<TD><INPUT NAME="GL_Account_Desc" TYPE="text" SIZE="25" MAXLENGTH="50" value="#qGetCompRebates.GL_Account_Desc#"></TD>
			</TR>	
			<TR>
				<TD ALIGN="right" class="Orangline"><B>Start Date:</B></TD>
				<TD>
					<CF_EASYDATE FORMNAME="DataForm" FIELDNAME="Start_Date" FORMAT="mm/dd/yyyy" default="#qGetCompRebates.Start_Date#">
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right" class="Orangline"><B>End Date:</B></TD>
				<TD>
					<CF_EASYDATE FORMNAME="DataForm" FIELDNAME="End_Date" FORMAT="mm/dd/yyyy" default="#qGetCompRebates.End_Date#">
				</TD>
			</TR>

			<!--- Dev Note: Kal; Component selection on GL Page --->					
			<!--- component selection  --->
			<TR>
				<TD COLSPAN="100%">
					<cfinclude template="/settings/GL_Account/select_components.cfm" /><br/>
				</TD>
			</TR>

			<TR>
				<TD COLSPAN="100%" ALIGN="center">
					<BR>
					<CF_button
						button_name		=	""
						button_caption	=	"Update"
						button_action	=	"return updateComp(#form.compId#);"
						button_type		=	"javascript_link"
						button_width	=	"75"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</TD>
			</TR>
		</table>
	</cfoutput>
</FIELDSET>