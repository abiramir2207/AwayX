<!---import the custom tag lib--->
<cfimport prefix="layout" taglib="/CustomTags"> 

<TABLE width="60%" border="0" cellpadding="1" cellspacing="0">
	<TR>
		<CFIF qGetCurrency.recordCount GT 0>
			<TD ALIGN="left" WIDTH="130" nowrap>
			<CFIF form.display eq "inActive">
			<B><FONT COLOR="FF0000">[</FONT><a HREF="#" onClick="javaScript: return activateSelCurrencies();">
			activate selected</a>
			<CFELSE>
			<B><FONT COLOR="FF0000">[</FONT><a HREF="" onClick="javaScript: return deactivateSelCurrencies();">
			deactivate selected</a>
			</b></b></CFIF><B><B>
			<FONT COLOR="FF0000">]</FONT></B>
			</b></TD>
		</CFIF>
		<TD WIDTH="">&nbsp;</TD>
	</TR>
</TABLE>
<br>
<TABLE width="60%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD width="10">
			<INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this);">
		</TD>
		<TD STYLE="font-size:11px;" nowrap>
			<b>Currency</b>
		</TD>
		<TD WIDTH="85" STYLE="font-size:11px;" nowrap><B>
		<cfif form.display eq "active">
			DeActivate
		<cfelse>
			Activate
		</cfif></B></TD>
		<TD WIDTH="50" STYLE="font-size:11px;" nowrap><B>Delete</B></TD>
	</TR>
	
	<CFOUTPUT QUERY="qGetCurrency">
		<!---check to see if we can delete this currencyonent--->
		<cfscript>
			bCanDelete = currency.canDelete(qGetCurrency.Currency_ID);
		</cfscript>
	
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD width="10"><INPUT TYPE="checkbox" NAME="CID" value="#Currency_ID#"></TD>
		<TD>
			<a href="" onClick="JavaScript: return submitDataForm('edit','#Currency_ID#');">#Currency_Name# (#Currency_Code#)</a>
		</TD>		
		<CFIF form.display EQ "active">
			<TD TITLE="Deactivate #Currency_Name#" ALIGN="center"><a href="" onClick="JavaScript: return deactivateCurrency('#Currency_ID#');"><img src="/images/not_allowed.gif" TITLE="Deactivate #Currency_Name#" BORDER="0"></a></TD>
		<CFELSE>
			<TD TITLE="Activate #Currency_Name#" ALIGN="center"><a href="" onClick="JavaScript: return activateCurrency('#Currency_ID#');"><img src="/images/on_the_program_item.gif" TITLE="Activate #Currency_Name#" BORDER="0"></a></TD>
		</CFIF>
		
		
		<CFIF bCanDelete >
			<TD TITLE="Delete #Currency_Name#" ALIGN="center"><a href="" onClick="JavaScript: return deleteCurrency('#Currency_ID#');"><img src="/images/no_small.gif" TITLE="Delete #Currency_Name#" BORDER="0"></a></TD>
		<CFELSE>
			<TD ALIGN="center">&nbsp;<FONT COLOR="Red">N/A</FONT></TD>
		</CFIF>	
	</TR>	
	</CFOUTPUT>
</TABLE>

