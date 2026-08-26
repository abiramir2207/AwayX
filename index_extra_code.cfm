<!------ index_extra_code.cfm ----->
<!--- <table border="1">

<cfloop collection="#CGI#" item="sItem">
<tr>
<cfoutput>
 <td>CGI.#SItem#</td>
 <td nowrap>#CGI[sItem]# &nbsp;</td>
</tr>
</cfoutput>
</cfloop>
</table>
<table border="1">
<cfloop collection="#FORM#" item="sItem">
<tr>
<cfoutput>
 <td>FORM.#SItem#</td>
 <td nowrap>#Form[sItem]# &nbsp;</td>
</tr>
</cfoutput>
</cfloop>
</table>

<cfdump var="#cgi.all_http#">

<table border="1">
<cfloop collection="#URL#" item="sItem">
<tr>
<cfoutput>
 <td>URL.#SItem#</td>
 <td nowrap>#URL[sItem]# &nbsp;</td>
</tr>
</cfoutput>
</cfloop>
</table>

<table border="1">
<cfloop collection="#COOKIE#" item="sItem">
<tr>
<cfoutput>
 <td>COOKIE.#SItem#</td>
 <td nowrap>#COOKIE[sItem]# &nbsp;</td>
</tr>
</cfoutput>
</cfloop>
</table>   

<cfabort> --->