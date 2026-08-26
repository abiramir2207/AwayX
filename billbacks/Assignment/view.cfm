<!------ view.cfm ----->

<cfif NOT isDefined("qGetAnalysts")><!------ might be already called in nextPage.cfm ----->
<cfset qGetAnalysts = billbackAssignmentManager.getAnalysts() />
</cfif>
<STYLE>
TABLE.underline TD 
{
	border-bottom:solid #C0C0C0 1px; 
}
</STYLE>
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="750" CLASS="underline" style="margin-top:10px;">	
	<TR BGCOLOR="FFE083">
		<TD WIDTH="250"><B>Analyst</B></TD>
		<TD WIDTH="250"><B>Assigned Markets</B></TD>
		<cfoutput><TD WIDTH="250"><B>Assigned #application.returned_customer_setting.distributor_label_plural#</B></TD>
		<TD WIDTH="250"><B>Assigned #application.returned_customer_setting.operator_label_plural#</B></TD></cfoutput>
		<TD WIDTH="250"><B>Assigned Analysts</B></TD>
	</TR>
	<cfloop query="qGetAnalysts">
	<cfset qGetAnalystMarkets = billbackAssignmentManager.getAnalystMarkets(Analyst_User_ID) />
	<cfset qGetAnalystDistributors = billbackAssignmentManager.getAnalystDistributors(Analyst_User_ID) />
	<cfset qGetAnalystOperators = billbackAssignmentManager.getAnalystOperators(Analyst_User_ID) />
	<cfif Is_Supervisor EQ 1>
		<cfset qGetSupervisorAnalysts = billbackAssignmentManager.getSupervisorAnalysts(Analyst_User_ID) />
	</cfif>
	<cfoutput><TR valign="top" BGCOLOR="#IIf(currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#"></cfoutput>
		<cfoutput><TD VALIGN="Top"><B>#Name_First# #Name_last#</B><B><FONT COLOR="red"><CFIF Default_Analyst EQ 1><BR>( Default Analyst )</CFIF><CFIF Is_Default_Supervisor EQ 1><BR>( Default Supervisor )<CFELSEIF Is_Supervisor EQ 1><BR>( Supervisor )</CFIF></FONT></B></TD></cfoutput>
		<TD>
		<CFIF qGetAnalystMarkets.Recordcount GT 0>
		<CF_openLayer
			Border="Yes"
			BorderSize="1"
			BorderColor="orange"  
			Image="/images/plus2.gif"
			ImageOpen="/images/minus2.gif"
			Title="Hide Markets:"
			TitleClosed="Show Markets:"
			TitleTooltip="Click to Show/Hide Criteria Used"
			TitleFont="font"
			TitleColor="Blue"
			TitleSize="9"
			IsClosed="Yes"
			Width="95%">
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
				<CFOUTPUT Query="qGetAnalystMarkets">
				<TR>
					<TD VALIGN="Top">#Market_Name#</TD>
				</TR>
				</CFOUTPUT>
			</TABLE>
		</CF_openLayer>
		<CFELSE>
		&nbsp;
		</CFIF>
		</TD>
		<TD>
		<CFIF qGetAnalystDistributors.RecordCount GT 0>
		<CF_openLayer
			Border="Yes"
			BorderSize="1"  
			BorderColor="orange"  
			Image="/images/plus2.gif"
			ImageOpen="/images/minus2.gif"
			Title="Hide #application.returned_customer_setting.distributor_label_plural#:"  
			TitleClosed="Show #application.returned_customer_setting.distributor_label_plural#:"  
			TitleTooltip="Click to Show/Hide Criteria Used"  
			TitleFont="font"  
			TitleColor="Blue"  
			TitleSize="9"  
			IsClosed="Yes"  
			Width="95%">		
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
				<CFOUTPUT Query="qGetAnalystDistributors">
				<TR>
					<TD VALIGN="Top">#Name#</TD>
				</TR>
				</CFOUTPUT>
			</TABLE>
		</CF_openLayer>
		<CFELSE>
		&nbsp;
		</CFIF>
		</TD>
		<TD>
		<CFIF qGetAnalystOperators.RecordCount GT 0>
		<CF_openLayer
			Border="Yes"
			BorderSize="1"  
			BorderColor="orange"  
			Image="/images/plus2.gif"
			ImageOpen="/images/minus2.gif"
			Title="Hide #application.returned_customer_setting.operator_label_plural#:"  
			TitleClosed="Show #application.returned_customer_setting.operator_label_plural#:"  
			TitleTooltip="Click to Show/Hide Criteria Used"  
			TitleFont="font"  
			TitleColor="Blue"  
			TitleSize="9"  
			IsClosed="Yes"  
			Width="95%">		
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
				<CFOUTPUT Query="qGetAnalystOperators">
				<TR>
					<TD VALIGN="Top">#Operator_Name#</TD>
				</TR>
				</CFOUTPUT>
			</TABLE>
		</CF_openLayer>
		<CFELSE>
		&nbsp;
		</CFIF>
		</TD>
		<TD>
		<cfif Is_Supervisor EQ 1 AND qGetSupervisorAnalysts.RecordCount GT 0>
		<CF_openLayer
			Border="Yes"
			BorderSize="1"  
			BorderColor="orange"  
			Image="/images/plus2.gif"
			ImageOpen="/images/minus2.gif"
			Title="Hide Analysts:"  
			TitleClosed="Show Analysts:"  
			TitleTooltip="Click to Show/Hide Criteria Used"  
			TitleFont="font"  
			TitleColor="Blue"  
			TitleSize="9"  
			IsClosed="Yes"  
			Width="95%">		
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
				<CFOUTPUT Query="qGetSupervisorAnalysts">
				<TR>
					<TD VALIGN="Top">#Name_First# #Name_last#</TD>
				</TR>
				</CFOUTPUT>
			</TABLE>
		</CF_openLayer>
		<cfelse>&nbsp;
		</cfif>
		</TD>
	</TR>
	</cfloop>
</TABLE>