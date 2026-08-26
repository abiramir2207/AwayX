<!--- Get the profile for this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!------<FIELDSET STYLE="padding:5px; width: 80%; border: 1px solid Silver;">----->
<CFPARAM NAME="TARGET_PAGE" 	DEFAULT="">
<CFSET TARGET_STRING = "">
<CFIF TARGET_PAGE NEQ "">
	<CFSET PRICING_RULE_PAGE = "index2.cfm">
	<CFSET TARGET_STRING = " TARGET=""#TARGET_PAGE#""">
<CFELSE>
	<CFSET PRICING_RULE_PAGE = "index_rules.cfm">
	<CFSET TARGET_STRING = " TARGET=""_parent""">
</CFIF>

<CFIF TARGET_PAGE EQ "">
<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="3" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="border: 1px solid #D3D3D3;">
<BR>&nbsp;&nbsp;
</CFIF>

<CFIF Get_Profile_Settings.Commodity_Price_Rule_Create_Edit EQ 1>
	<CFOUTPUT>	
	<B><FONT COLOR="##FF0000">[</FONT><a #TARGET_STRING# href="#PRICING_RULE_PAGE#">create pricing rule</a><FONT COLOR="##FF0000">]</FONT></B>
	</CFOUTPUT>
</CFIF>

<BR><BR>

<!------<SPAN STYLE="<CFIF TARGET_PAGE EQ "">width:350px;<CFELSE>width:255px;</CFIF>border-bottom:2px orange solid;font: bold 14px sans-serif; color: Navy;">&nbsp;Saved Pricing Rules</SPAN>----->
<CFIF TARGET_PAGE NEQ "">
<SPAN STYLE="width:255px;border-bottom:2px orange solid;font: bold 14px sans-serif; color: Navy;">&nbsp;Saved Pricing Rules</SPAN>
<BR><BR>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the rules that have been saved in the db													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Rules" datasource="#application.datasource#">
	Select	Pricing_Rule.Pricing_Rule_ID,
			Pricing_Rule.Pricing_Rule_Name,
			Pricing_Rule.Pricing_Rule_Date,
			_Users.Name_First + ' ' + _Users.Name_Last AS Pricing_Rule_Author
	From	Pricing_Rule
			LEFT JOIN _Users
			ON
			Pricing_Rule.Pricing_Rule_Author = _Users.User_ID
	Where	Pricing_Rule.Deleted = 0
	Order by Pricing_Rule.Pricing_Rule_Date Desc
</CFQUERY>	



<CFIF TARGET_PAGE NEQ "">	
	<CFSET PRICING_RULE_PAGE = "pricing_rule_display.cfm">
<CFELSE>
	<CFSET PRICING_RULE_PAGE = "index_rules.cfm">
</CFIF>

	<TABLE WIDTH="95%" BORDER="0" CELLPADDING="0" CELLSPACING="6">
		<TR>
			<TD WIDTH="90%"><B>Rule Name</B></TD>
			<TD NOWRAP><B>Updated on</B></TD>
			<CFIF TARGET_PAGE EQ "">
			<TD NOWRAP><B>By</B></TD>
			</CFIF>			
		</TR>
		<TR>
			<TD COLSPAN="<CFIF TARGET_PAGE EQ "">3<CFELSE>2</CFIF>" BGCOLOR="Orange"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD>
		</TR>
		<CFOUTPUT QUERY="Get_Rules">
		<TR>
			<TD VALIGN="top">
			<A #TARGET_STRING# HREF="#PRICING_RULE_PAGE#?PRID=#Pricing_Rule_ID#">#ReplaceList(Pricing_Rule_Name,"<,>","&lt;,&gt;")#</A></TD>
			<TD VALIGN="top" NOWRAP>&nbsp;#dateformat(Pricing_Rule_Date, 'mm/dd/yy')# #timeformat(Pricing_Rule_Date, 'hh:mmtt')#</TD>
			<CFIF TARGET_PAGE EQ "">
			<TD VALIGN="top" NOWRAP>&nbsp;#Pricing_Rule_Author#</TD>
			</CFIF>
		</TR>
		</CFOUTPUT>
	</TABLE>
<CFIF TARGET_PAGE EQ "">
</BODY>
</CFIF>