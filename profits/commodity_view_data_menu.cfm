<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="100%">
	<TR>
		<TD ALIGN="left" WIDTH="70%">
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Decide Which link to show --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<CFIF request.TemplateName EQ 'view_commodity_chart.cfm'>
			<CFSET headerlink="<FONT COLOR='Red'><B>[</B></FONT>&nbsp;<A HREF='view_commodity_data.cfm?Symbol=#URL.Symbol#&amp;datasize=#URL.datasize#">
			<CFIF startdate NEQ "" AND enddate NEQ "">
				<CFSET headerlink="#headerlink#&amp;start_date=#dateformat(startdate, "mm/dd/yyyy")#&amp;end_date=#dateformat(enddate, "mm/dd/yyyy")#">
			</CFIF>
			<CFSET headerlink="#headerlink#&amp;Comm_Month_Year=#Comm_Month_Year#'>view data</A>&nbsp;<FONT COLOR='Red'><B>]</B></FONT>">
		<CFELSE>
			<CFSET headerlink="<FONT COLOR='Red'><B>[</B></FONT>&nbsp;<A HREF='javascript:history.back();'>view graph</A>&nbsp;<FONT COLOR='Red'><B>]</B></FONT>">
		</CFIF>
		
		<CFOUTPUT>#headerlink#</CFOUTPUT>
		</TD>
		<TD ALIGN="center"><FONT COLOR="Red"><B>[</B></FONT>&nbsp;<A HREF="javascript:history.back();">previous</A>&nbsp;<FONT COLOR="Red"><B>]</B></FONT></TD>
		<TD ALIGN="center"><FONT COLOR="Red"><B>[</B></FONT>&nbsp;<A HREF="javascript:history.forward()">next</A>&nbsp;<FONT COLOR="Red"><B>]</B></FONT></TD>
		<TD ALIGN="center"><FONT COLOR="Red"><B>[</B></FONT>&nbsp;<A HREF="javascript:self.close();">close</A>&nbsp;<FONT COLOR="Red"><B>]</B></FONT></TD>
	</TR>
</TABLE> 