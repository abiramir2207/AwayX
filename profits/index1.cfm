<!--- Get the profile for this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFSET pagetitle = "View rules">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR><BR>


<TABLE BORDER="0" CELLPADDING="20" CELLSPACING="0" ALIGN="center" WIDTH="100%">
<TR>
	<TD NOWRAP VALIGN="top"><IMG SRC="/Images/price_rule_help.gif" WIDTH="250" HEIGHT="238"></TD>
	<TD VALIGN="top" WIDTH="100%">
		<SPAN CLASS="title2">Legend</SPAN>
		<BR><BR>
		
		<FONT COLOR="Red"><B>1</B></FONT> - 
		Clicking on it, will allow you to view the data for commodities
		<BR><BR>
		
		<FONT COLOR="Red"><B>2</B></FONT> - 
		Exploded selection. Lists previously saved pricing rules
		<BR><BR>
		
		<FONT COLOR="Red"><B>3</B></FONT> - 
		Click on  a pricing rule to view its details<BR>
		Depending of your access rights/permissions, you may not have access to some of these options.
		<BR><BR>
		
		<FONT COLOR="Red"><B>4</B></FONT> - 
		Click here to create a new rule<BR>
		Depending of your access rights/permissions, you may not have access to some of these options.
		<BR><BR>


		Please select from the table of contents on the left, the items that you would like to manage
	</TD>
</TR>
</TABLE>

