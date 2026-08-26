<!------ kickback.cfm ----->
<cfoutput>
<cfparam name="url.id" 	default="0">
<cfparam name="form.id" 	default="#url.id#">
<cfparam name="form.state" 	default="0">
<cfset formName = "frmKickback" />
<cfset thisPageUrl = "#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#">

<cfif form.id>
	<cfset fpRequestManager = CreateObject("component", "components.futures_pricing.RequestManager").init() />
	<cfset requestObj = fpRequestManager.get(form.id)  />
	
	<cfif form.state>
		<cfparam name="form.newStatus" 	default="#requestObj.getStatusId()#">
		<cfset fpRequestManager.changeStatus(form.newStatus, accessStructure) />
		
		<!------ <cflocation url="handler.cfm?id=#form.id#&command=ceInitialRequest" addtoken="No" /> ----->
		<cflocation url="view.cfm?id=#form.id#&command=ceInitialRequest" addtoken="No" />
		<cfabort>
	</cfif>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Futures Pricing</title>
</head>

<body>

<SCRIPT>
	
	function submitForm(formName) 
	{
		var formObj = eval("document." + formName);
		formObj.submit();
		return false;
	}
	
</SCRIPT>
	<cfset newStatus = requestObj.getStatusId() - 1 />
	
	<cfset pagePhase = 0>	
	<cfinclude template="fp_header.cfm">
	<cfset statusManager = CreateObject("component", "components.futures_pricing.StatusManager").init() />	
	<form method="post" name="#formName#" action="#thisPageUrl#" target="_parent">
	&nbsp;&nbsp;&nbsp;<span class="Title2">Kick back</span><hr color="Navy">
	<table cellpadding="2" cellspacing="0" align="center">
	<tr>
		<td style="font-size:13px;color:red;">
		<br><br>
		Once you kick back, you will lose all the work you have done in this phase.<br>
		Do you want to change the status of this request to <B>'#statusManager.getStatusDesc(newStatus)#'</B>?
		<br><br>
		</td>
	</tr>
	<tr>
	<td align="center">
		<cf_smallLink
			title="cancel"
			url="##"
			parameters=" onClick=""JavaScript: history.back();return false;"""
			>
			&nbsp;&nbsp;&nbsp;
		<cf_smallLink
			title="change status"
			url="##"
			parameters=" onClick=""JavaScript: return submitForm('#formName#');"""
			>
	</td>
	</tr>
	</table>
	<input type="hidden" name="state" value="1">
	<input type="hidden" name="id" value="#form.id#">
	<input type="Hidden" name="newStatus" value="#newStatus#" />
	</form>
</body>
</html>
</cfif>
</cfoutput>