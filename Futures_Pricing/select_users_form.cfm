<!------ select_users_form.cfm ----->
<cfoutput>

<cfset groupManager = CreateObject("component", "components.futures_pricing.GroupUserManager").init() />
<cfparam name="form.groupId" 	default="#Evaluate(requestObj.getStatusId()+1)#">
<cfset qGroupUsers = groupManager.getAll(form.groupId) />
<cfset groupName = groupManager.getGroupName(form.groupId) />
<cfset qRequestUsers = reqManager.getGroupsUsers(form.groupId) />
<cfset existingRTequestUsers = ValueList(qRequestUsers.User_ID) />
<SCRIPT>
	
	function submitForm(formName) 
	{
		var formObj = eval("document." + formName);
		if(formObj.requestUsers.selectedIndex == -1)
		{
			alert("Please select a user to whom this request is to be forwarded");
		}
		else
		{
			formObj.submit();
		}
		return false;
	}
	
</SCRIPT>

<form method="post" name="#formName#" target="#target#" style="display:inline;">	
	<table cellpadding="2" cellspacing="0" border="0" align="center" width="60%">
	<caption style="font-size:12px;font-weight:bold;">Select #groupName# users</caption>
	<tr>
	<td align="center">
	<select name="requestUsers" size="15" multiple style="width:200px;">
		<cfloop query="qGroupUsers">
		<option value="#User_ID#"<cfif ListFindNoCase(existingRTequestUsers, User_ID, ",")> SELECTED</cfif>>#User_Full_Name#</option>
		</cfloop>
	</select>
	</td>
	</tr>
	<tr>
		<td align="center">
		<font color="red">Hold ctrl and click to select multiple items</font>
		<br><br>		
		<cfparam name="prevPageURL" 	default="">
		<cfset extraParameters = "">
		<cfif prevPageURL EQ "">
			<cfset extraParameters = "onClick=""JavaScript: window.close();return false;""">			
		</cfif>
		<cf_smallLink
			title="cancel"
			url="#prevPageURL#"		
			parameters = "#extraParameters#"
			>
			&nbsp;&nbsp;&nbsp;
		<cf_smallLink
			title="continue"
			url="##"
			parameters=" onClick=""JavaScript: return submitForm('#formName#');"""
			>
		</td>
	</tr>
	</table>
	<input type="Hidden" name="command" value="#form.command#" />
	<input type="Hidden" name="id" value="#form.id#" />
	<input type="Hidden" name="state" value="1" />
	<input type="Hidden" name="groupId" value="#form.groupId#" />		
</form>
</cfoutput>