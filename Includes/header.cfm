<cfinclude template="/includes/top_header.cfm">

<CFSET SEND_URL = URLEncodedFormat("#CGI.SCRIPT_NAME##request.app_general_functions.Build_Url_String()#")>
<SCRIPT>
function header_footer_presence()
{
	if(window.top == window)
	{		
		location.href="/Manufacturers/home_new.cfm?pageToOpen=<CFOUTPUT>#SEND_URL#</CFOUTPUT>";		
	}
	else
	{
		return true;
	}
}

if(header_footer_presence())
{
	callRefreshTitle();
}

function addToDoList()
{
	NewWindow('/todo/todo_entry.cfm','name','320','240','Yes', 'Yes')
}

function viewToDoList()
{
	NewWindow('/todo/todo_view.cfm','name','320','240','Yes', 'Yes')
}

function callRefreshTitle()
{
	window.setTimeout("refreshTitle()", 0);
}

function refreshTitle()
{
	if(window.parent.header_new)
	{
		// window.parent.header_new.show_title("<CFOUTPUT>#PAGE_TITLE#</CFOUTPUT>");
	}
}

</SCRIPT>
<!--- 
<TABLE WIDTH="100%" CELLPADDING="1" CELLSPACING="0">
<TR>
	<TD BGCOLOR="Navy"><FONT SIZE="3" COLOR="White"><B><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></B></FONT></TD>
</TR>
</TABLE>

 --->
<!--- <CFINCLUDE template="/XM/Message_Check.cfm"> --->