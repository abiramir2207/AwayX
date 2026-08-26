<cfoutput>
<HTML>
<HEAD>
<TITLE>Futures Pricing</TITLE>
</HEAD>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<body>
<!------ set defaults ----->
<cfparam name="url.id" 	default="0">
<cfparam name="url.command" 	default="ceInitialRequest">
<cfset thisPageUrl = "#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#">

<cfset fpRequestManager = CreateObject("component", "components.futures_pricing.RequestManager").init() />
<cfset fpRequest = fpRequestManager.get(id=url.id,userId=request.AccessStructure.User_ID)>
<cfset statusId = fpRequest.getStatusId()>
<cfset url.id = fpRequest.getId() />
<cfif fpRequest.getIsExpired()>

	<cfinclude template="expired.cfm" />

<cfelse>

	<cfset fpRequestManager.getGroupsUserAccess() />
	<cfset initialUrl = "handler.cfm?command=#url.command#&id=#url.id#">
	
	<table cellpadding="0" cellspacing="0" border="0" height="100%" width="100%">
	 <tr valign="top">
	 	<td width="140"><cfinclude template="index_toc.cfm"></td>
		<td width=""><iframe frameborder="1" name="right" src="#initialUrl#" width="100%" height="100%"></iframe></td>
	 </tr>
	</table>
	
</cfif>
 </body>
</HTML>
</cfoutput>