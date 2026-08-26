<!---get business segments to edit--->
<cfset qGetClassCodes = businessSegManager.getActiveClasscodes() />
	
List of Class Codes.
<p>
<TABLE width="60%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD STYLE="font-size:11px;">
			<b>Class Code ID</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Class Code</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Business Segment</b>
		</TD>
		<cfif appSettings.getProgramBudgetOn()>
		<TD STYLE="font-size:11px;">
			<b>Budget Percentage</b>
		</TD>
		</cfif>
		<td style="font-size:11px;">
			<b>Materials For Settlement</b>
		</td>
		<TD STYLE="font-size:11px;">
			<b>Edit</b>
		</TD>		
	</TR>
	<cfif not qGetClassCodes.RecordCount>
		<tr>
			<td colspan="100%">N/A&nbsp;</td>
		</tr>
	</cfif>
	<CFOUTPUT QUERY="qGetClassCodes">
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF>>
		<TD>#Class_Code#</TD>
		<TD>#Class_Code_Desc#</TD>
		<TD>#Business_Unit_Desc#</TD>
		<cfif appSettings.getProgramBudgetOn()>
		<TD>#Breakout_Percentage#</TD>
		</cfif>
		<td>
		<cfif External_Id is "">
			&nbsp;
		<cfelse>
		    #External_Id#
		</cfif>
		</td>
		<td><a href="" onClick="JavaScript: return submitForm('eClassCodes','#Class_Code_ID#', 'dClassCodes');">(edit)</a></td>
	</TR>	
	</CFOUTPUT>
</TABLE>
<br>
<CF_smallLink 
	title = "add" 
	url = "##"
	parameters = "onClick=""javascript: return submitForm('eClassCodes', 0, 'dClassCodes');"""
>
<cfif appSettings.getProgramBudgetOn()>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<CF_smallLink 
	title = "Budget Percentage" 
	url = "##"
	parameters = "onClick=""javascript: return submitForm('eBudgetPercentage', 0, 'dClassCodes');"""
>
</cfif>