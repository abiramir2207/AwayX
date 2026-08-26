<!--- get budget to display --->
<!--- mcCain enhancement(add sort by) ---->
<cfset qGetBudget = BudgetManager.getBudget() />
<cfoutput>
<br>
<cfif Get_Profile_Settings.Create_Budget eq 1>
<CF_smallLink 
		title = "add" 
		url = "##"
		parameters = "onClick=""javascript: return submitForm('ceBudget', 0, 'listBudget');"""
	>
</cfif>
<br>
<CFPARAM NAME="saveMessage" DEFAULT="">
<cfif saveMessage neq "">
	<br>
	<div style="color:red;font-weight:bold;">**** #saveResponse[1]# ****
	<cfif isQuery(saveResponse[3])>
		<cfset qOnlyBudgetInTemplates = saveResponse[3] />
		<cfloop query="qOnlyBudgetInTemplates">
		<br>#created_type#
		</cfloop>
	</cfif>
	</div>
	<br>
</cfif>
<br>
<TABLE width="60%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="##FFCE84">
		<TD STYLE="font-size:11px;">
			<b>Budget ID</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Budget</b>
		</TD>		
		<TD STYLE="font-size:11px;">
			<b>Edit</b>
		</TD>
		<TD STYLE="font-size:11px;" align="center">
			<b>Activate/DeActivate</b>
		</TD>
		<TD STYLE="font-size:11px;" align="center">
			<b>Delete</b>
		</TD>
	</TR>
	<cfif not qGetBudget.RecordCount>
		<tr>
			<td colspan="100%">N/A&nbsp;</td>
		</tr>
	</cfif>
	<cfloop QUERY="qGetBudget">
	<cfset bgColor = "FFFFFF">
	<CFIF CURRENTROW MOD 2>	
		<cfset bgColor = "CCFFCC">
	</CFIF>
	<cfif NOT Active>
		<cfset bgColor = "CCCCCC">
	</cfif>
	<TR BGCOLOR="#bgColor#">
		<TD nowrap>#Simple_Budget_Number#</TD>
		<TD nowrap>#Simple_Budget_Desc#</TD>		
		<td>
		<cfif Get_Profile_Settings.Create_Budget eq 1>
			<a href="" onClick="JavaScript: return submitForm('ceBudget','#Simple_Budget_ID#', 'listBudget');">(edit)</a>
		<cfelse>&nbsp;
		</cfif>
		</td>
		<td align="center">
		<cfif Get_Profile_Settings.Create_Budget eq 1>
			<cfif Active>
			<a title="Deactivate this budget" href="" onClick="JavaScript: return submitForm('deactivateBudget','#Simple_Budget_ID#', 'listBudget');"><img src="/images/not_allowed.gif" border="0"></a>
			<cfelse>
			<a title="Activate this budget" href="" onClick="JavaScript: return submitForm('activateBudget','#Simple_Budget_ID#', 'listBudget');"><img src="/images/on_the_program_item.gif" border="0" title="Deactivated by #Deactivated_By_Username# on #Deactivated_Date#"></a>
			</cfif>
		<cfelse>&nbsp;
		</cfif>
		</td>
		<td align="center">
		<cfif Get_Profile_Settings.Create_Budget eq 1>
			<a title="Delete this budget" href="" onClick="JavaScript: return submitForm('deleteBudget','#Simple_Budget_ID#', 'listBudget');"><img src="/images/no_small.gif" border="0"></a>
		<cfelse>&nbsp;
		</cfif>
		</td>
	</TR>	
	</cfloop>
</TABLE>
</cfoutput>
