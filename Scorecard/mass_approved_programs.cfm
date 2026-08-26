
<cfparam name="url.programlist" default="">

<CFQUERY NAME="get_Programs" datasource="#application.datasource#">
select * from
contract_main
where
deleted = 0
and contract_main_id IN (#url.programlist#)
</CFQUERY>

<div align="center" style="font-size:15px; font-weight: bold;">The Listed Program<cfif get_Programs.recordcount GT 0>s</cfif> Have Been Approved</div><BR>
		<cfoutput>
		<table cellspacing="0" cellpadding="3" align="center" width="700">
			<tr BGCOLOR="FFE083">
				<td width="100"><span CLASS="tableheaders" valign="top">Program</span></td>
				<td width="300"><span CLASS="tableheaders" valign="top">Title</span></td>
				<td><span CLASS="tableheaders" valign="top">Start</span></td>
				<td><span CLASS="tableheaders" valign="top">-</span></td>
				<td><span CLASS="tableheaders" valign="top">End</span></td>
			</tr>
<cfloop query="get_Programs">
			<tr>
					<td><b>#get_Programs.Contract_Number#</b></td>
					<td><b>#get_Programs.Contract_Title#</b></td>
					<td><b>#dateformat(get_Programs.Contract_Start_Date, 'mm/dd/yyyy')#</b></td>
					<td><b>-</b></td>
					<Td><b>#dateformat(get_Programs.Contract_End_Date, 'mm/dd/yyyy')#</b></TD>
				</tr>
		</cfloop>		
</table>
</cfoutput>
<BR>
		<div align="center">
		<FONT SIZE="2" COLOR="Red">[</FONT>
			<FONT SIZE="2" COLOR="Blue">
				
					<A HREF="/Manufacturers/home.cfm">
						return to home page
					</A>
				
			</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>		
		</div>