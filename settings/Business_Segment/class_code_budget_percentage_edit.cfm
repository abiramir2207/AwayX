<!------ class_code_budget_percentage_edit.cfm ----->

<cfif form.command EQ "sBudgetPercentage">
	<!---save business segment--->
	<cfset businessSegManager.saveClassCodeBudgetPercentage(form) />
	<cflocation url="index.cfm?command=#form.returnCommand#" />
	<cfabort>
</cfif>

<!---get class code budget percentage to edit--->
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
		<TD STYLE="font-size:11px;" align="right">
			<b>Budget Percentage</b>
		</TD>
	</TR>
	<cfif not qGetClassCodes.RecordCount>
		<tr>
			<td colspan="100%">N/A&nbsp;</td>
		</tr>
	</cfif>
	<cfset totalPercent = 0 />
	<CFOUTPUT QUERY="qGetClassCodes">
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF>>
		<TD>#Class_Code#</TD>
		<TD>#Class_Code_Desc#</TD>
		<TD>#Business_Unit_Desc#</TD>
		<TD align="right">
		<input size="4" maxlength="6" type="Text" name="Breakout_Percentage_#Class_Code_ID#" value="#NumberFormat(Breakout_Percentage, ".___")#" ONKEYUP="clenseText(this, '.0123456789');" onblur="formatTextboxDecimalPlaces(this, 3);" onchange="javaScript:recalcTotal();" />%
		</TD>
	</TR>
	<cfset totalPercent = totalPercent + Breakout_Percentage />
	</CFOUTPUT>
	<cfoutput>
	<TR>
		<TD colspan="100%" align="right">
		<span style="width:40px;" id="totalPercent">#NumberFormat(totalPercent, ".___")#</span>%
		</TD>
	</TR>
	</cfoutput>
</TABLE>
<br>
<center>
<CF_smallLink 
	title = "save" 
	url = "##"
	parameters = "onClick=""javascript: return submitForm('sBudgetPercentage', 0, 'dClassCodes');"""
>
<span id="err_percentage"></span>
</center>

<cf_MessageWindow />