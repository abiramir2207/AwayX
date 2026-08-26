<br>
<TABLE width="70%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<td>
			<INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this, 'lAccounting_Specialist_ID');">
		</td>
		<TD STYLE="font-size:11px;" width="100%" nowrap colspan="2">
			<b>Accounting Specialist</b>
		</TD>
	</TR>
	
	<cfif qGetSpecialists.RecordCount>
	
		<CFOUTPUT QUERY="qGetSpecialists">

			<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
				<td>
					<input name="lAccounting_Specialist_ID" type="checkbox" value="#Accounting_Specialist_ID#" />
				</td>
				<TD>
					#Accounting_Specialist_Name#
				</TD>
				<td>
					<a href="" onClick="JavaScript: return submitDataForm('edit','#Accounting_Specialist_ID#');">(edit)</a>
				</td>	
			</TR>
			
		</CFOUTPUT>
		
	<cfelse>
		
		<TR HEIGHT="21">
		
			<TD colspan="100%">
				N/A
			</TD>	
			
		</TR>
			
	</cfif>
	
</TABLE>
<br>
<CF_smallLink 
	title = "delete" 
	url = ""
	parameters = "onClick=""javascript: return deleteSpecialist();"""
>