<cfoutput>
<cfparam name="form.state" 	default="0">
<cfset formName = "frmRefreshExpired" />
<cfif url.id>
	<cfset fpRequestManager = CreateObject("component", "components.futures_pricing.RequestManager").init() />
	<cfset fpRequest = fpRequestManager.get(url.id)>
	<cfset statusId = fpRequest.getStatusId()>
	
	<cfif form.state>
		<cfparam name="form.newStatus" 	default="#statusId#">
		<cfset fpRequestManager.changeStatus(form.newStatus, accessStructure, 0) />
		<cflocation url="#thisPageUrl#" addtoken="No" />
		<cfabort>
	</cfif>
	<!------ Get Status ----->
	<cfset qGetStatus = CreateObject("component", "components.futures_pricing.StatusManager").getAll() />
	<SCRIPT>
	
		function submitForm(formName) 
		{
			var formObj = eval("document." + formName);
			formObj.submit();
			return false;
		}
		
	</SCRIPT>

	<form method="post" name="#formName#" action="#thisPageUrl#">
	<br><br>
	<table cellpadding="2" cellspacing="0" align="center">
	<tr>
	<td>
		<B>Which status do you want the futures pricing request be refreshed to</B>
	</td>
	</tr>
	<tr>
	<td>
		<select name="newStatus" style="width:200px;">
		<cfloop query="qGetStatus" endrow="#statusId#">
			<option value="#FP_Status_ID#"<cfif FP_Status_ID EQ statusId> SELECTED</cfif>>#FP_Status_Desc#</option>		 
		</cfloop>
		</select>
		&nbsp;&nbsp;&nbsp;
		<cf_smallLink
			title="refresh from expired"
			url="##"
			parameters=" onClick=""JavaScript: return submitForm('#formName#');"""
			>
	</td>
	</tr>
	</table>
	<input type="hidden" name="state" value="1">
	</form>
</cfif>
</cfoutput>