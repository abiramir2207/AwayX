
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- 																									
																										
Typical Use:																							
		<CF_TAB_GROUP Width="90%" General_Color="FFFFCC">												
			<CF_TAB_ITEM Title="xxxxxxxxx" ToolTip="111111111111111111111">								
				<CFINCLUDE TEMPLATE="............">														
			</CF_TAB_ITEM>																				
			<CF_TAB_ITEM Title="xxxxxxxxx" ToolTip="222222222222222222222">								
				<CFINCLUDE TEMPLATE="............">														
			</CF_TAB_ITEM>																				
				.																						
				.																						
				.																						
		</CF_TAB_GROUP>																					
																									 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Protect against no sub-tags --->
<CFPARAM NAME="ThisTag.AssocAttribs"		DEFAULT="#ArrayNew(1)#">

<!--- Default width to the control panel --->
<CFPARAM NAME="Attributes.Width"			DEFAULT="800">

<!--- Default height to the control panel --->
<CFPARAM NAME="Attributes.Height"			DEFAULT="300">

<!--- Interface color --->
<CFPARAM NAME="Attributes.General_Color"	DEFAULT="E9E9E9"><!--- eeeeee --->

<!--- URL variable list to pass a data from tab to tab via the URL --->
<CFPARAM NAME="Attributes.Common_URL_Variables"	DEFAULT="">

<CFSWITCH EXPRESSION="#ThisTag.ExecutionMode#">
	<CFCASE VALUE="start">
		<CFSET ThisTag.TabCounter=1>
	</CFCASE>
	<CFCASE VALUE="end">
		<CFPARAM NAME="URL.Tab" DEFAULT="1">
		<CFSET Variables.ColSpan=Evaluate(ThisTag.TabCounter+ThisTag.TabCounter)><!--- <CFSET Variables.ColSpan=Evaluate(ThisTag.TabCounter+1)> --->
		<CFOUTPUT>

		<STYLE TYPE="text/css">
		TD.current
			{
				font-family:sans-serif;
				font-size:10pt;
				color:black;
				font-weight : bold;
			}
		A.noncurrent
			{
				font-family:sans-serif;
				font-size:10pt;
				color:black;
				font-weight : bold;
			}
		A:HOVER.noncurrent
			{
				text-decoration:none;
				color:navy;
			}
		</STYLE>

		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Tabs at the top																				 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<TABLE WIDTH="#Attributes.Width#" BORDER="0" CELLSPACING="0" CELLPADDING="1" ALIGN="center">
			<TR STYLE="border-bottom:solid navy 1px;">
				<CFSET CommonVariableString = "">
				<!--- Loop over the Common variables and create a string with the values--->
				<CFLOOP INDEX="ListVariableName" LIST="#Attributes.Common_URL_Variables#">
					<cfset CommonVariableString = CommonVariableString & "&" & trim(ListVariableName) & "=" & evaluate("URL." & trim(ListVariableName))>
				</CFLOOP>
				<!--- Loop over the attribute sets of all sub tags --->
				<CFLOOP INDEX="MyCounter" FROM="1" TO="#DecrementValue(ThisTag.TabCounter)#">
				<!--- Get the attributes structure --->
				<CFIF MyCounter GTE URL.Tab>
				<CFSET TagAttributes="#ThisTag.AssocAttribs[IncrementValue(MyCounter)]#">
				<CFELSE>
				<CFSET TagAttributes="#ThisTag.AssocAttribs[MyCounter]#">
				</CFIF>
				<CFPARAM NAME="TagAttributes.URLVariableName"			DEFAULT="ID">
				<CFPARAM NAME="TagAttributes.URLVariableValue"			DEFAULT="#RandRange(111111111, 999999999)#">
				<CFPARAM NAME="TagAttributes.Title"						DEFAULT="Tab #MyCounter#">
				<CFPARAM NAME="TagAttributes.ToolTip"					DEFAULT="Click here to see the contents of tab #MyCounter#">
				<CFPARAM NAME="TagAttributes.ContentAlign"				DEFAULT="left">
				<CFPARAM NAME="TagAttributes.ContentVAlign"				DEFAULT="top">
		
				<CFIF URL.Tab EQ MyCounter>
				<!--- Current Tab --->
				<TD BGCOLOR="#Attributes.General_Color#" NOWRAP STYLE="border-top:solid Navy 1px; border-right:solid Navy 1px; border-left:solid Navy 1px;  border-white:solid White 1px;" CLASS="current">
					<B>
					&nbsp;&nbsp;
					#TagAttributes.Title#
					&nbsp;&nbsp;
					</B>
				</TD>
				<CFELSE>
				<!--- Non Current Tab --->
				<TD BGCOLOR="orange" TITLE="#TagAttributes.ToolTip#" NOWRAP VALIGN="middle" STYLE="border-bottom:solid Navy 1px;">
					&nbsp;&nbsp;
					<A HREF="http://#CGI.HTTP_HOST##CGI.SCRIPT_NAME#?Tab=#MyCounter#&#TagAttributes.URLVariableName#=#TagAttributes.URLVariableValue##CommonVariableString#" CLASS="noncurrent">
						#TagAttributes.Title#
					</A>
					&nbsp;&nbsp;
				</TD>
				</CFIF>
				<!--- Spacer between tabs --->
				<TD STYLE="border-bottom:solid Navy 1px;" WIDTH="1"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
				</CFLOOP>
				<TD width="100%" STYLE="border-bottom:solid Navy 1px;">&nbsp;</TD>
			</TR>
		</TABLE>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- End of Tabs at the top																		 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Main content area...																			 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<TABLE HEIGHT="#Attributes.Height#" CELLSPACING="0" CELLPADDING="0" WIDTH="#Attributes.Width#" ALIGN="center" BGCOLOR="#Attributes.General_Color#"  STYLE="border-bottom:solid Navy 1px; border-right:solid Navy 1px; border-left:solid Navy 1px;">
			<TR>
				<TD VALIGN="top"><TABLE CELLPADDING="25" HEIGHT="100%" BORDER="0" WIDTH="100%"><TR><TD VALIGN="top">#ThisTag.GeneratedContent#</TD></TR></TABLE></TD>
			</TR>
		</TABLE>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- End of Main content area...																	 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

		</CFOUTPUT>
		<CFSET ThisTag.GeneratedContent="">
	</CFCASE>
</CFSWITCH>




<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- 																									
																										
Typical Use:																							
		<CF_TAB_GROUP Width="90%" General_Color="FFFFCC">												
			<CF_TAB_ITEM Title="xxxxxxxxx" ToolTip="111111111111111111111">								
				<CFINCLUDE TEMPLATE="............">														
			</CF_TAB_ITEM>																				
			<CF_TAB_ITEM Title="xxxxxxxxx" ToolTip="222222222222222222222">								
				<CFINCLUDE TEMPLATE="............">														
			</CF_TAB_ITEM>																				
				.																						
				.																						
				.																						
		</CF_TAB_GROUP>																					
																									 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Protect against no sub-tags --->
<CFPARAM NAME="ThisTag.AssocAttribs"		DEFAULT="#ArrayNew(1)#">

<!--- Default width to the control panel --->
<CFPARAM NAME="Attributes.Width"			DEFAULT="800">

<!--- Default height to the control panel --->
<CFPARAM NAME="Attributes.Height"			DEFAULT="300">

<!--- Interface color --->
<CFPARAM NAME="Attributes.General_Color"	DEFAULT="E5E5E5"><!--- eeeeee --->

<!--- URL variable list to pass a data from tab to tab via the URL --->
<CFPARAM NAME="Attributes.Common_URL_Variables"	DEFAULT="">

<CFSWITCH EXPRESSION="#ThisTag.ExecutionMode#">
	<CFCASE VALUE="start">
		<CFSET ThisTag.TabCounter=1>
	</CFCASE>
	<CFCASE VALUE="end">
		<CFPARAM NAME="URL.Tab" DEFAULT="1">
		<CFSET Variables.ColSpan=Evaluate(ThisTag.TabCounter+ThisTag.TabCounter)><!--- <CFSET Variables.ColSpan=Evaluate(ThisTag.TabCounter+1)> --->
		<CFOUTPUT>

		<STYLE>
		.current
			{
				font-family:		sans-serif;
				font-size:			10pt;
				color:				black;
			}
		.noncurrent
			{
				font-family:		sans-serif;
				font-size:			10pt;
				color:				white;
			}
		A:HOVER
			{
				text-decoration:	underscore;
				color:				black;
			}
		</STYLE>

		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Tabs at the top																				 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<TABLE WIDTH="#Attributes.Width#" BORDER="0" CELLSPACING="0" CELLPADDING="1" ALIGN="center">
			<TR>
				<!--- <TD width="100%" BORDERCOLORDARK="#Attributes.General_Color#" BORDERCOLORLIGHT="#Attributes.General_Color#"></TD> --->
				<CFSET CommonVariableString = "">
				<!--- Loop over the Common variables and create a string with the values--->
				<CFLOOP INDEX="ListVariableName" LIST="#Attributes.Common_URL_Variables#">
					<cfset CommonVariableString = CommonVariableString & "&" & trim(ListVariableName) & "=" & evaluate("URL." & trim(ListVariableName))>
				</CFLOOP>
				<!--- Loop over the attribute sets of all sub tags --->
				<CFLOOP INDEX="MyCounter" FROM="1" TO="#DecrementValue(ThisTag.TabCounter)#">
				<!--- Get the attributes structure --->
				<CFIF MyCounter GTE URL.Tab>
				<CFSET TagAttributes="#ThisTag.AssocAttribs[IncrementValue(MyCounter)]#">
				<CFELSE>
				<CFSET TagAttributes="#ThisTag.AssocAttribs[MyCounter]#">
				</CFIF>
				<CFPARAM NAME="TagAttributes.URLVariableName"			DEFAULT="ID">
				<CFPARAM NAME="TagAttributes.URLVariableValue"			DEFAULT="#RandRange(111111111, 999999999)#">
				<CFPARAM NAME="TagAttributes.Title"						DEFAULT="Tab #MyCounter#">
				<CFPARAM NAME="TagAttributes.ToolTip"					DEFAULT="Click here to see the contents of tab #MyCounter#">
				<CFPARAM NAME="TagAttributes.ContentAlign"				DEFAULT="left">
				<CFPARAM NAME="TagAttributes.ContentVAlign"				DEFAULT="top">
		
				<CFIF URL.Tab EQ MyCounter>
				<!--- Current Tab --->
				<TD BGCOLOR="#Attributes.General_Color#" NOWRAP>
					<FONT SIZE="2" COLOR="Navy">
						<B>
						&nbsp;&nbsp;
						#TagAttributes.Title#
						&nbsp;&nbsp;
						</B>
					</FONT>
				</TD>
				<CFELSE>
				<!--- Non Current Tab --->
				<TD BGCOLOR="orange" TITLE="#TagAttributes.ToolTip#" NOWRAP VALIGN="middle">
					&nbsp;&nbsp;
					<A HREF="http://#CGI.HTTP_HOST##CGI.SCRIPT_NAME#?Tab=#MyCounter#&#TagAttributes.URLVariableName#=#TagAttributes.URLVariableValue##CommonVariableString#" CLASS="noncurrent" STYLE="color: white; font-weight:bold;">
						#TagAttributes.Title#
					</A>
					&nbsp;&nbsp;
				</TD>
				</CFIF>
				<!--- Spacer between tabs --->
				<TD></TD>
				</CFLOOP>
				<TD width="100%"></TD>
			</TR>
		</TABLE>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- End of Tabs at the top																		 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Main content area...																			 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<TABLE HEIGHT="#Attributes.Height#" CELLPADDING="1" WIDTH="#Attributes.Width#" BORDER="0" ALIGN="center" BGCOLOR="#Attributes.General_Color#">
			<TR>
				<TD VALIGN="top"><TABLE CELLPADDING="25" HEIGHT="100%"><TR><TD VALIGN="top">#ThisTag.GeneratedContent#</TD></TR></TABLE></TD>
			</TR>
		</TABLE>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- End of Main content area...																	 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

		</CFOUTPUT>
		<CFSET ThisTag.GeneratedContent="">
	</CFCASE>
</CFSWITCH>


 --->