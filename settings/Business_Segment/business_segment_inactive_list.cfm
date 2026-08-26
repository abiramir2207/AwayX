List of InActive <cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>s.
<p>
<TABLE width="60%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD STYLE="font-size:11px;">
			<b>Busines Unit ID</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Company Code</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Edit</b>
		</TD>
		<TD STYLE="font-size:11px;" align="center">
			<b>Activate</b>
		</TD>
	</TR>
	<cfif not qGetBusSegments.RecordCount>
		<tr>
			<td colspan="100%">N/A&nbsp;</td>
		</tr>
	</cfif>
	<CFOUTPUT QUERY="qGetBusSegments">
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF>>
		<TD>#Business_Unit_ID#</TD>
		<TD>#Business_Unit_Desc#</TD>
		<TD><cfif not Len(Trim(Company_Code_ID))>N/A<cfelse>#Company_Code_ID#</cfif>&nbsp;</TD>
		<td><a href="" onClick="JavaScript: return submitForm('eiBusinessSegment','#Business_Segment_ID#', 'dInActiveBusinessSegment');">(edit)</a></td>
		<td align="center"><a href="" onClick="JavaScript: return submitForm('aBusinessSegment','#Business_Segment_ID#');"><img src="/images/on_the_program_item.gif" border="0"></a></td>		
	</TR>	
	</CFOUTPUT>
</TABLE>
<br>