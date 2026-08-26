<!----
	Filename:	C:\Work\Code\base\AwayX\DEDUCTIONS\Closure\DD_Non_Trade_To_Open.cfm
	Created:	12/28/2011
 	Developer:	drachala        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		This file is used to open DEDUCTION for NON TRADE 
	Usage:
		DD NON TRADE SECTION
---->
<cfparam name="url.from" default="">
<cfparam name="url.deduction_id" default="">

	<cfset NonTrade = CreateObject("component", "components.deduction.nontrade") />
	<cfscript>
		NonTrade.NonTradeOpen(
								DeductionID			=	#url.deduction_ID#
								);
	</cfscript>

<cfif url.from EQ "pop-up">
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="green" SIZE="3">
			Your changes have been made. This window will close automatically.
			</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function closeWindow()
	{
		window.close()
	}
	window.setTimeout('closeWindow()', 2000);	
	</SCRIPT>

<cfelse>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="green" SIZE="3">
			Your changes have been made. This window will redirect to summary page.
			</FONT></B></TD>
		</TR>
	</TABLE>
	<!--- D38841 : Update non-trade feature to open in a new window--->
<SCRIPT language="JavaScript">
	function relocateThis()
	{
		window.parent.location.href = "/deductions/deduction.cfm?deduction_ID=<CFOUTPUT>#URL.Deduction_ID#</CFOUTPUT>"
	}
	window.setTimeout('relocateThis()', 2000);	
</SCRIPT>

</cfif>


