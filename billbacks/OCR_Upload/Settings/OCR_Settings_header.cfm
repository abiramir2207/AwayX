<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Settings/OCR_Settings_header.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  28-Feb-17
Created By   :  Anand Rao
Description  :  OCR header file 
---------------------------------------------------------------------------------->

<cfset TR_BORDER_WIDTH = 2>
<cfset TD_FORE_COLOR = "FFE083">
<cfoutput>
<style type="text/css">
	A.tablink_back, A:Hover.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
	A:visited.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
	A.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
	A:visited.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}

	TD.headernotselected
	{
		background-color 	: dddddd;
		border-bottom		: solid #TR_BORDER_WIDTH#px black;
		cursor				: pointer;	
	}
	TD.headerselected
	{
		border-left			: solid #TR_BORDER_WIDTH#px black;
		border-top			: solid #TR_BORDER_WIDTH#px black;
		border-right			: solid #TR_BORDER_WIDTH#px black;
		background-color 	: #TD_FORE_COLOR#;
		cursor				: pointer;	
		TEXT-TRANSFORM		: uppercase;
	}

	TD.headerspacer
	{
		border-bottom		: solid #TR_BORDER_WIDTH#px black;
	}
</style>
</cfoutput>

<cfparam name="SETTING_PAGE_NAME" 	default=1>
<cfset SETTING_PAGE_TITLES = "">
<cfset SETTING_PAGE_ACTIONS = "">

<cfset SETTING_PAGE_TITLES = ListAppend(SETTING_PAGE_TITLES, "Active", ",")>
<cfset SETTING_PAGE_ACTIONS = ListAppend(SETTING_PAGE_ACTIONS, "active", ",")>

<cfset SETTING_PAGE_TITLES = ListAppend(SETTING_PAGE_TITLES, "Inactive", ",")>
<cfset SETTING_PAGE_ACTIONS = ListAppend(SETTING_PAGE_ACTIONS, "inActive", ",")>

<cfset SETTING_PAGE_TITLES = ListAppend(SETTING_PAGE_TITLES, "Add New", ",")>
<cfset SETTING_PAGE_ACTIONS = ListAppend(SETTING_PAGE_ACTIONS, "add", ",")>

 
<!---display edit tab if in edit mode--->
<cfif form.display eq "edit">
	<cfset SETTING_PAGE_TITLES = ListAppend(SETTING_PAGE_TITLES, "Edit OCR Setting", ",")>
	<cfset SETTING_PAGE_ACTIONS = ListAppend(SETTING_PAGE_ACTIONS, "update", ",")>
</cfif>

<!---highlight tabs according to action--->
<cfif form.display eq "inActive">
	<cfset SETTING_PAGE_NAME = 2 />
<cfelseif form.display eq "add">
	<cfset SETTING_PAGE_NAME = 3 />
<cfelseif form.display eq "edit">
	<cfset SETTING_PAGE_NAME = 4 />
</cfif>
<BR>
<table border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
	<tr>
	 	<td class="headerspacer">&nbsp;</TD>
		<cfset C_Counter = 1>
		<cfloop list="#SETTING_PAGE_TITLES#" index="ThisMenuItem">

			<cfif C_Counter EQ SETTING_PAGE_NAME>
				<cfset CLASS_NAME= "headerselected">
			<cfelse>
				<cfset CLASS_NAME= "headernotselected">
			</cfif>
			<!---- Start ------>
			<cfoutput>
			<td width="120" class="#CLASS_NAME#" ALIGN="center" NOWRAP>
			<B>
			<!---remove link if its edit or bus rules--->
			<!--- <cfif SETTING_PAGE_NAME eq 5 and C_Counter EQ SETTING_PAGE_NAME>
				#ThisMenuItem#
			<cfelse>
				<A CLASS="tablink_back" HREF="" onClick="JavaScript: return submitDataForm('#ListGetAt(SETTING_PAGE_ACTIONS,C_Counter)#');">#ThisMenuItem#</A>
			</cfif>	 --->			
			<!--- <A CLASS="tablink_back" HREF="" onClick="JavaScript: return submitDataForm('#ListGetAt(SETTING_PAGE_ACTIONS,C_Counter)#');">#ThisMenuItem#</A> --->
			</B>
			</td>
			</B>
			</td>
			<td class="headerspacer"><img src="/images/fill.gif" width="1" height="1"></td>
			</cfoutput>
			<!---- End ------>
			<cfset C_Counter = C_Counter + 1>
		</cfloop>
		
		<td class="headerspacer" width="100%"><img src="/images/fill.gif" width="1" height="1"></td>
	</tr>
</table>