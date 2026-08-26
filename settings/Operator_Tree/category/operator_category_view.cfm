<script language="JavaScript">
	function confirmDelete(doAction, id, label)
	{
		if(window.confirm("Are you sure you want to delete the '" + label + "' category ?"))
		{
			submitForm(doAction, id);
		}
		return false;
	}
</script>
Click on the category name to edit the category. Click (View) to see what operators are assigned to that category.<br> 
The (Default) category or categories that have operators assigned to them can't be deleted. 
<p>
<TABLE width="60%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD STYLE="font-size:11px;">
			<b>Category Name</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Operators</b>
		</TD>
<!--- 		<td>&nbsp;</td> --->
		<TD WIDTH="50" STYLE="font-size:11px;"><B>Delete</B></TD>
	</TR>
	<CFOUTPUT QUERY="qGetCategory">
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD>
			<!--- <a HREF="#ThisPage#?mode=3&doAction=editCategory&id=#Operator_Category_ID#">#Category_Label#</a> --->
			<a HREF="javascript: void(0);" onclick="javaScript: return submitForm('editCategory', #Operator_Category_ID#);">#Category_Label#</a>
			&nbsp;&nbsp;<cfif isDefault>(Default)<cfelse>&nbsp;</cfif>
		</TD>
		<TD>
			<a href="javascript: void(0);"  OnClick="NewWindow('category/category_operators.cfm?id=#Operator_Category_ID#', 'Position_Operators', '800', '600', 'Yes', 'No', true);">View</a>
		</TD>		
<!--- 		<TD>
			<a HREF="#ThisPage#?mode=3&doAction=assignCategory&id=#Operator_Category_ID#">Assign</a>
		</TD> --->
		<CFIF trim(operatorExists) eq "" and not isDefault>
			<TD TITLE="Delete #Category_Label#" ALIGN="center"><a href="" onClick="JavaScript: return confirmDelete('deleteCategory', #Operator_Category_ID#, '#Category_Label#');"><img src="/images/no_small.gif" TITLE="Delete #Category_Label#" BORDER="0"></a></TD>
		<CFELSE>
			<TD ALIGN="center">&nbsp;<FONT COLOR="Red">N/A</FONT></TD>
		</CFIF>
	</TR>	
	</CFOUTPUT>
</TABLE>