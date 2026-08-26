<script language="JavaScript">
	function confirmDelete(doAction, id, label)
	{
		if(window.confirm("Are you sure you want to delete the '" + label + "' priority ?"))
		{
			submitForm(doAction, id);
		}
		return false;
	}
</script>
Click on the priority name to edit the priority. Click (View) to see what operators are assigned to that priority.<br> 
The (Default) priority or priorities that have operators assigned to them can't be deleted. 
<p>
<TABLE width="60%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD STYLE="font-size:11px;">
			<b>Priority Name</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Operators</b>
		</TD>
<!--- 		<td>&nbsp;</td> --->
		<TD WIDTH="50" STYLE="font-size:11px;"><B>Delete</B></TD>
	</TR>
	<CFOUTPUT QUERY="qGetPriority">
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD>
			<!--- <a HREF="index.cfm?mode=4&doAction=editPriority&id=#Operator_Priority_ID#">#Priority_Label#</a> --->
			<a HREF="javascript: void(0);" onclick="javaScript: return submitForm('editPriority', #Operator_Priority_ID#);">#Priority_Label#</a>
			&nbsp;&nbsp;<cfif isDefault>(Default)<cfelse>&nbsp;</cfif>
		</TD>
		<TD>
			<a href="javascript: void(0);"  OnClick="NewWindow('priority/priority_operators.cfm?id=#Operator_Priority_ID#', 'Position_Operators', '800', '600', 'Yes', 'No', true);">View</a>
		</TD>		
<!--- 		<TD>
			<a HREF="index.cfm?mode=4&doAction=assignPriority&id=#Operator_Priority_ID#">Assign</a>
		</TD> --->
		<CFIF trim(operatorExists) eq "" and not isDefault>
			<TD TITLE="Delete #Priority_Label#" ALIGN="center"><a href="" onClick="JavaScript: return confirmDelete('deletePriority', #Operator_Priority_ID#, '#Priority_Label#');"><img src="/images/no_small.gif" TITLE="Delete #Priority_Label#" BORDER="0"></a></TD>
		<CFELSE>
			<TD ALIGN="center">&nbsp;<FONT COLOR="Red">N/A</FONT></TD>
		</CFIF>	
	</TR>	
	</CFOUTPUT>
</TABLE>