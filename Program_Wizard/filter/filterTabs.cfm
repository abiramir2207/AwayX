
<cfset variables.settings = application.returned_customer_setting />

<cfinclude template="/program_wizard/filter/filter_page_List.cfm"/>

	<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="90%" class="MAINTABLE">
		<TR>
		 	<TD CLASS="headerspacer">&nbsp;</TD>
			<CFSET F_Counter = 1>
			<CFLOOP LIST="#PAGE_TITLES#" INDEX="ThisMenuItem">
				<CFSET ThisURL = "Template_Filters.cfm"/>
				<CFSET ThisPageName = ListGetAt(PAGE_NAMES, F_Counter, ",")>
				<CFSET CLASS_NAME= "filterheadernotselected">
				<CFSET TAB_CLASS_NAME= "tablink_back">
				<CFIF ThisPageName EQ URL.filterPageName>
					<CFSET CLASS_NAME= "filterheaderselected">
					<CFSET TAB_CLASS_NAME= "filtertablink">
				</CFIF>
				<!---- Start ------>
				<CFOUTPUT>
				<A CLASS="#TAB_CLASS_NAME#" HREF="#ThisURL#?id=#ID#&tfId=#form.rdoFilter#&filterPageName=#ThisPageName#">
				<TD CLASS="#CLASS_NAME#" ALIGN="center" NOWRAP  bgcolor="##FFCE84" >&nbsp;&nbsp;
				<B>			
				<A CLASS="#TAB_CLASS_NAME#" HREF="#ThisURL#?id=#ID#&tfId=#form.rdoFilter#&filterPageName=#ThisPageName#">#ThisMenuItem#</A></B>&nbsp;&nbsp;</TD></A></B>
				</TD>
				</A>
				<TD CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
				</CFOUTPUT>
				<!---- End ------>
				<CFSET F_Counter = F_Counter + 1>
			</CFLOOP>
			
			<TD CLASS="headerspacer" WIDTH=100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
		</TR>
	</TABLE>