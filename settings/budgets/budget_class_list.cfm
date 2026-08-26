<!--- get budget class to display --->
<cfset qGetBudgetClass = BudgetManager.getBudgetClass() />
<cfoutput>
<br>
<cfif Get_Profile_Settings.Create_Budget eq 1>
<CF_smallLink 
		title = "add" 
		url = "##"
		parameters = "onClick=""javascript: return submitForm('ceBudgetClass', 0, 'listBudgetClass');"""
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
			<b>Class ID</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Class</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Span</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Edit</b>
		</TD>
		<TD STYLE="font-size:11px;" align="center">
			<b>Activate/DeActivate</b>
		</TD>
	</TR>
	<cfif not qGetBudgetClass.RecordCount>
		<tr>
			<td colspan="100%">N/A&nbsp;</td>
		</tr>
	</cfif>
	<cfloop QUERY="qGetBudgetClass">
	<cfset bgColor = "FFFFFF">
	<CFIF CURRENTROW MOD 2>	
		<cfset bgColor = "CCFFCC">
	</CFIF>
	<cfif NOT Active>
		<cfset bgColor = "CCCCCC">
	</cfif>
	<TR BGCOLOR="#bgColor#">
		<TD nowrap>#Simple_Budget_Class_Number#</TD>
		<TD nowrap>#Simple_Budget_Class_Desc#</TD>
		<TD nowrap>#DateFormat(Start_Date, "mm/dd/yyyy")# - #DateFormat(End_Date, "mm/dd/yyyy")#</TD>
		<td>
		<cfif Get_Profile_Settings.Create_Budget eq 1>
			<a href="" onClick="JavaScript: return submitForm('ceBudgetClass','#Simple_Budget_Class_ID#', 'listBudgetClass');">(edit)</a>
		<cfelse>&nbsp;
		</cfif>
		</td>
		<td align="center">
		<cfif Get_Profile_Settings.Create_Budget eq 1>
			<cfif Active>
			<a title="Deactivate this class" href="" onClick="JavaScript: return submitForm('deactivateBudgetClass','#Simple_Budget_Class_ID#', 'listBudgetClass');"><img src="/images/not_allowed.gif" border="0"></a>
			<cfelse>
			<a title="Activate this class" href="" onClick="JavaScript: return submitForm('activateBudgetClass','#Simple_Budget_Class_ID#', 'listBudgetClass');"><img src="/images/on_the_program_item.gif" border="0" title="Deactivated by #Deactivated_By_Username# on #Deactivated_Date#"></a>
			</cfif>
		<cfelse>&nbsp;
		</cfif>
		</td>	
	</TR>	
	</cfloop>
</TABLE>
</cfoutput>
