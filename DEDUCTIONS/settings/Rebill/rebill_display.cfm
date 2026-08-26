
<TABLE width="60%" border="0" cellpadding="1" cellspacing="0">
	<TR>
		<CFIF qGetCompRebates.recordCount GT 0>
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
	<cfoutput>
	<TR ID="HEADER" BGCOLOR="##FFCE84">
		<TD width="10">
			<INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this);">
		</TD>
		
		<TD STYLE="font-size:11px;" width="70%" nowrap>
			<b>Rebill clause</b>
		</TD>
		<td><strong>Classification</strong></td>
		<td><strong>Mandatory</strong></td>
		<td><strong>Editable</strong></td>
		<td><strong>Order</strong></td>
		
		<TD WIDTH="65" STYLE="font-size:11px;"><B>
		<cfif form.display eq "active">
			DeActivate
		<cfelse>
			Activate
		</cfif></B></TD>
	
	</TR>
	</cfoutput>
	<CFOUTPUT QUERY="qGetCompRebates">

	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD width="10"><INPUT TYPE="checkbox" NAME="CID" value="#DD_Rebill_ID#"></TD>
		
		<TD>
			<a href="" onClick="JavaScript: return submitDataForm('edit','#DD_Rebill_ID#');">#left(trim(DD_Rebill_Text), 50)#<Cfif len(DD_Rebill_Text) GT 50>... </CFIF>&nbsp;</a>
		</TD>
	
		<td>
		<cfif DD_Classification_ID LT 2>NA
		<cfelse>
			#DD_Classification_Desc#
		</cfif>
		</td>
		
		<TD>
			<Cfif Is_Mandatory Is 1>Yes<cfelse>No</CFIF>
		</TD>
		
		<TD>
			<Cfif Is_Editable Is 1>Yes<cfelse>No</CFIF>
		</TD>
		
		<td>#Clause_Order#</td>
		
		<CFIF form.display EQ "active">
			<TD TITLE="Deactivate" ALIGN="center"><a href="" onClick="JavaScript: return deactivateComp('#DD_Rebill_ID#');"><img src="/images/not_allowed.gif" TITLE="Deactivate" BORDER="0"></a></TD>
		<CFELSE>
			<TD TITLE="Activate" ALIGN="center"><a href="" onClick="JavaScript: return activateComp('#DD_Rebill_ID#');"><img src="/images/on_the_program_item.gif" TITLE="Activate" BORDER="0"></a></TD>
		</CFIF>
		
	</TR>	
	
	
	</CFOUTPUT>
	
</TABLE>

<table width="70%">
<tr><Td colspan="100%">NOTE: If you have more than one item with the same order, they will appear in the rebill letter in the order they were added.</TD></tr>
</table>
