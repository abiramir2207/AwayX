<!---- 
budget_program_approve_email.cfm
Send a summary email for programs that are approved beyond budget dollars
---->
<cfset budgetsProgramApproveEmailAddress = Trim(application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsProgramApproveEmailAddress()) />
<cfif Len(budgetsProgramApproveEmailAddress) gt 0>
	<cfinclude template="/get_Contact_Admin_Email_Address.cfm">
	<cfset qProgram = arguments.qProgram />
	<cfset qBudgetBalance = arguments.qBudgetBalance />
	<cfset userManager = CreateObject("component", "components.user.UserManager").init() />
	<cfset qRsp = userManager.getUserInfo(qProgram.Responsible_User_ID) />
	<cfset qApprover = userManager.getUserInfo(qProgram.Approved_By_User_ID) />
	<CF_EMAILWRAPPER 
		TO			=	"#budgetsProgramApproveEmailAddress#"
		FROM		=	"#Contact_Admin_Email_Address#"
		SUBJECT		=	"Program #qProgram.Contract_Number# is approved beyond budget dollars."
		TYPE		=	"html" 
		messagetype="1" 
		generatedby="1"
		appArea="1"
	>
	<cfoutput>
		<TABLE>
		<TR>
		<TD VALIGN="top" colspan="100%">
		Program [#qProgram.Contract_Number#] "#qProgram.Contract_Title#" is approved beyond budget dollars by #qApprover.Name_First# #qApprover.Name_Last# on #DateFormat(qProgram.Approval_Date, "mm/dd/yyyy")# #TimeFormat(qProgram.Approval_Date, "hh:mm:ss tt")#.<br>
		Responsible Salesperson: #qRsp.Name_First# #qRsp.Name_Last#
		</TD>
		</TR>
		</TABLE>
		<TABLE cellpadding="2">
		<tr bgcolor="ffdead">
		<td style="font-weight:bold;">#getBudgetClassAssociationLabel()#</td>
		<td style="font-weight:bold;">Budget</td>
		<td align="right" style="font-weight:bold;">#getBudgetBalanceLabel()#</td>
		</tr>
		<cfloop query="qBudgetBalance">
		<tr valign="top">
		<td>#Simple_Budget_Class_Association_Number#</td>
		<td>
		#Simple_Budget_Class_Desc# (#Simple_Budget_Class_Number#) /	#Simple_Budget_Desc# (#Simple_Budget_Number#)
		</td>
		<td align="right" <cfif Position_Budget_Balance lt 0> style="color:red"</cfif>>#DollarFormat(Position_Budget_Balance)#</td>
		</tr>
		</cfloop>
		</TABLE>		
	</cfoutput>
	</CF_EMAILWRAPPER>
</cfif>