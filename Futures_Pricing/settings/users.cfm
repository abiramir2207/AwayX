<!------ users.cfm ----->
<cfoutput>

<cfset groupUserManager = CreateObject("component", "components.futures_pricing.GroupUserManager").init() />
<cfset groupUserGroup = groupUserManager.getGroup(userGroup) />
<cfif form.state>
	<!------ Save group users ----->
	<cfparam name="form.Group_User_ID" 	default="">
	<cfset groupUserManager.save(form.Group_User_ID, userGroup, request.AccessStructure.User_ID) />	
	<cflocation addtoken="No" url="#thisPage#?command=#form.command#">	
	<cfabort>
<cfelse>
	<cfset qGroupUsers = groupUserManager.getAll(userGroup, 1) />
	
	<cfset stSearch = StructNew()>
	<cfset stSearch.excludeList = ValueList(qGroupUsers.User_ID, ",")>
	<cfset qUsers = CreateObject("component", "components.user.UserManager").search(stSearch) />
	
	<br>
	<cfif Len(groupUserGroup.getUpdatedBy()) GT 0>
	<TABLE align="center" BGCOLOR="White" BORDERCOLOR="Orange" BORDER="1" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
		<FONT SIZE="2"><B>The settings were last updated on #dateformat(groupUserGroup.getUpdatedOn(), 'mm/dd/yyyy')# #timeformat(groupUserGroup.getUpdatedOn(), 'hh:mm:ss TT')# by #groupUserGroup.getUpdatedByUserName()#</B></FONT>	</TD>
	</TD>
	</TR>
	</TABLE>
	
	</cfif>

	<table cellpadding="2" cellspacing="0" align="center">
	<tr>
		<td align="center"><B>#groupUserGroup.getDesc()# users</B></td>
		<td></td>
		<td align="center"><B>Users</B></td>
	</tr>
	<tr>
		<td>
		<select name="Group_User_ID" size="15" style="width:250px" multiple>
			<cfloop query="qGroupUsers">
			<option value="#User_ID#" RequestExist="#Len(RequestExist)#">#User_Full_Name#</option>
			</cfloop>
		</select>		
		</td>
		<td>
		<!------ buttons ----->
		<input type="Button" value="<" style="width:25px;" onClick="javaScript: addSelect(document.all.User_ID, document.all.Group_User_ID);">
		<br><br>
		<input type="Button" value="<<" style="width:25px;" onClick="javaSCript: addAll(document.all.User_ID, document.all.Group_User_ID)">
		<br><br>
		<input type="Button" value=">>" style="width:25px;" onClick="javaSCript: addAll(document.all.Group_User_ID, document.all.User_ID)">
		<br><br>
		<input type="Button" value=">" style="width:25px;" onClick="javaScript: addSelect(document.all.Group_User_ID, document.all.User_ID);">
		</td>
		<td>
		<select name="User_ID" size="15" style="width:250px" multiple>
			<cfloop query="qUsers">
			<option value="#User_ID#" RequestExist="0">#User_Full_Name#</option>
			</cfloop>
		</select>
		</td>
	</tr>
	<tr>
		<td colspan="100%" align="center">
		<font color="red">Hold ctrl and click to select multiple items</font>
		<br><br>
		<CF_button
			button_name		=	""
			button_caption	=	"Save"
			button_action	=	"selectAll(document.all.Group_User_ID);submitForm(document.#formName#, '#form.command#');"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Save"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
	</tr>
	</table>
</cfif>
</cfoutput>