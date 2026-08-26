<cfset columns				=	5>
<cfset table_width			=	800>
<cfset column_width			=	125>
<cfset column_width_first	=	table_width - ((columns-1) * column_width)>

<!--- since the iPad doesn't  use scroll bars, it needs this fix for the header --------------- --->
<CFIF FindNoCase('iPad','#CGI.HTTP_USER_AGENT#') GT 0>
<cfset table_width_header	=	table_width - 0>
<cfelse>
<cfset table_width_header	=	table_width - 17>
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->

<style>
div.scroll_header
{
	overflow-x: 		hidden; 
	overflow-y: 		hidden; 
	width:				<cfoutput>#table_width_header#</cfoutput>px; 
	border:				1px silver solid;
}

div.scroll_data
{
	overflow-x: 		hidden; 
	overflow-y: 		scroll;
	-webkit-overflow-scrolling: touch;	
	height:				200px; 
	width:				<cfoutput>#table_width#</cfoutput>px; 
	border:				1px silver solid;
}

table.scroll_data, table.scroll_header
{
	border-collapse:	collapse;
	border-spacing:		0;
}
</style>



<div class="scroll_header">
<table class="scroll_header">
	<cfoutput>
    <col width="#column_width_first#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    </cfoutput>
    <tr>
        <td><br />xxxxx</td><td><br />xxxxx</td><td><br />xxxxx</td><td><br />xxxxx</td><td><br />xxxxx</td>
    </tr>
</table>
</div>

<div class="scroll_data">
<table class="scroll_data">
	<cfoutput>
    <col width="#column_width_first#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    </cfoutput>
    <cfloop index="i" from="1" to="100" step="1">
    <tr><td>row <cfoutput>#i#</cfoutput></td><td>xxxxx</td><td>xxxxx</td><td>xxxxx</td><td>xxxxx</td></tr>
    </cfloop>
</table>
</div>
