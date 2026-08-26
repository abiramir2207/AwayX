<TABLE width="60%" border="0" cellpadding="1" cellspacing="0">
	<TR>
		<CFIF qGetTempCode.recordCount GT 0>
			<TD ALIGN="left" WIDTH="130" nowrap>
			<CFIF form.display eq "inActive">
			<B><FONT COLOR="FF0000">[</FONT><a HREF="#" onClick="javaScript: return activateSelComps();">
			activate selected</a>
			<CFELSE>
			<B><FONT COLOR="FF0000">[</FONT><a HREF="" onClick="javaScript: return deactivateSelComps();">
			deactivate selected</a>
			</b></b></CFIF><B><B>
			<FONT COLOR="FF0000">]</FONT></B>
			</b></TD>
		</CFIF>
		<TD WIDTH="">&nbsp;</TD>
	</TR>
</TABLE>
<br>
<TABLE width="70%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD width="10">
			<INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this);">
		</TD>
		<!------ external id ----->
		<cfif application.returned_customer_setting.external_id_on EQ 1>
		<TD STYLE="font-size:11px;" nowrap width="20">
			<b>ID</b>
		</TD>
		</cfif>
		<TD STYLE="font-size:11px;" width="70%" nowrap>
			<b>Component Name</b>
		</TD>		
		<TD WIDTH="65" STYLE="font-size:11px;"><B>
		<cfif form.display eq "active">
			DeActivate
		<cfelse>
			Activate
		</cfif>&nbsp;</B></TD>
		<TD WIDTH="50" STYLE="font-size:11px;"><B>Delete</B></TD>
	</TR>
	<CFOUTPUT QUERY="qGetTempCode">
		<!---check to see if we can delete this component--->
		<cfscript>
			bCanDelete = tempCode.canDelete(qGetTempCode.template_code_id);
		</cfscript>
	
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD width="10"><INPUT TYPE="checkbox" NAME="CID" value="#template_code_id#"></TD>
		<!------ external id ----->
		<cfif application.returned_customer_setting.external_id_on EQ 1>
		<TD>
			<a href="" onClick="JavaScript: return submitDataForm('edit','#template_code_id#');">#External_ID#&nbsp;</a>
		</TD>
		</cfif>
		<TD>
			<a href="" onClick="JavaScript: return submitDataForm('edit','#template_code_id#');">#template_code#&nbsp;</a>
		</TD>
		<CFIF form.display EQ "active">
			<TD TITLE="Deactivate #template_code#" ALIGN="center"><a href="" onClick="JavaScript: return deactivateComp('#template_code_id#');"><img src="/images/not_allowed.gif" TITLE="Deactivate #template_code#" BORDER="0"></a></TD>
		<CFELSE>
			<TD TITLE="Activate #template_code#" ALIGN="center"><a href="" onClick="JavaScript: return activateComp('#template_code_id#');"><img src="/images/on_the_program_item.gif" TITLE="Activate #template_code#" BORDER="0"></a></TD>
		</CFIF>
		<CFIF bCanDelete>
			<TD TITLE="Delete #template_code#" ALIGN="center"><a href="" onClick="JavaScript: return deleteComp('#template_code_id#');"><img src="/images/no_small.gif" TITLE="Delete #template_code#" BORDER="0"></a></TD>
		<CFELSE>
			<TD ALIGN="center">&nbsp;<FONT COLOR="Red">N/A</FONT></TD>
		</CFIF>	
	</TR>	
	</CFOUTPUT>
</TABLE>
