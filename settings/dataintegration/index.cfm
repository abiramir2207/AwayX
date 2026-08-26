<!------index.cfm----->

<CFPARAM NAME="URL.PageTitle" 	DEFAULT="SYSTEM ADMINISTRATION: Data Integration">
<CFINCLUDE TEMPLATE="diAccessible_Pages.cfm">

<CFSET firstPage = ListFirst(DI_Page_List, ",")>
<CFIF Len(Trim(firstPage)) GT 0>
	<CFLOCATION ADDTOKEN="No" URL="#firstPage#?PageTitle=#URL.PageTitle#">
</CFIF>

<FONT COLOR="Red" SIZE="+2"><B>Data Integration is not setup. Please contact the system administrator</B></FONT>
