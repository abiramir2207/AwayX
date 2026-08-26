<cfparam name="ExistingGLList" default="">
<cfparam name="blnSubmit" default="0">
<cfparam name="Action" default="Edit">
<cfparam name="SortBy" default="GL_Account">

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<!--- select/unselect toggle switch --->
<script language="JavaScript">
	function selectAll(bCheck)
	{
		var ObjCB = document.all.GL_Account_ID;
		var ObjCBAll = document.all.cbAll;
		var i, cbLen;
		if(ObjCB)
		{
			cbLen = ObjCB.length;
			if(cbLen)
			{
				for(i=0;i<cbLen;i++)
				{
					ObjCB[i].checked = bCheck; // set the value to cbAll.checked
				}
			}
			else
			{
					ObjCB.checked = bCheck; // set the value to cbAll.checked
			}
		}
	}
</script>

<!--- Return to main page --->
<cfif blnSubmit IS 2>

<cfif Action IS "Add">	
	<script>
		window.opener.document.all.DataForm.GLList.value = <cfoutput>"#form.GL_Account_ID#"</cfoutput>
		callfireEvent(opener.document,opener.document.all.DataForm.GLList,'Change');					
		window.opener.ShowGLInfo.style.display = "";
		window.opener.ShowGLSearch.style.display = "none";
		window.close();
	</script>
<cfelse>	
	<script>
		window.opener.document.all.DataForm.ExistingGLList.value = <cfoutput>"#form.GL_Account_ID#"</cfoutput>
		window.opener.document.all.DataForm.command.value = 'update';
		window.opener.document.all.DataForm.display.value = 'edit';
		window.opener.document.all.DataForm.compId.value = window.opener.document.all.DataForm.Component_ID.value
		window.opener.document.all.DataForm.submit(); 
		window.close();
	</script>
</cfif>
<cfabort>
</cfif>

<cfoutput><CFSET PAGE_TITLE="Select #Application.GLAccountLabel#s"></cfoutput><!---D42774 --->
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="20" TOPMARGIN="0">

<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
SELECT
{
 width: 190px;
}
</style>
<form name="GL_Account_Search" method="post" action="GL_Account_Search.cfm">
	<FIELDSET STYLE="padding:8px; border: 1px solid Blue; width: 425px;">
		<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#Application.GLAccountLabel#</cfoutput> search</LEGEND>
		<TABLE BORDER="0" CELLSPACING="2" CELLPADDING="0" BGCOLOR="WhiteSmoke" width="400">
			<TR VALIGN="TOP">
			<TD><strong><cfoutput>#Application.GLAccountLabel#</cfoutput></strong></TD>
			<TD><input type="text" size="30" maxlength="50" name="GL_Account"></TD>
			<TD><CF_button
						button_name		=	""
						button_caption	=	"Search"
						button_action	=	"GL_Account_Search.submit();"
						button_type		=	"javascript_link"
						button_width	=	"75"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					></TD>
			</TR>
		</TABLE>
	</FIELDSET>
	<input type="hidden" value="1" name="blnSubmit">
	<input type="hidden" value="<cfoutput>#ExistingGLList#</cfoutput>" name="ExistingGLList">
	<input type="hidden" name="Action" value="<cfoutput>#Action#</cfoutput>">
	<input type="hidden" name="SortBy" value="<cfoutput>#SortBy#</cfoutput>">
</form>

<cfif blnSubmit IS 1>
	<cfquery name="TheQuery" datasource="#application.datasource#">
		SELECT *
		FROM GL_Account
		WHERE Deleted = 0
			AND Is_Active = 1
			AND (GL_Account LIKE '%#GL_Account#%'
					OR GL_Account_Desc LIKE '%#GL_Account#%')
		ORDER BY #SortBy#
	</cfquery>
	<p></p>
	<FIELDSET STYLE="padding:8px; border: 1px solid Blue; width: 425px;">
		<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">
			<CFOUTPUT>
				There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> #TheQuery.recordcount# #Application.GLAccountLabel#<CFIF NOT TheQuery.recordcount EQ 1>s</CFIF>
		</CFOUTPUT>
		</LEGEND><!---D42774 --->
		
		<!--- select all logic: if all the id's in query are in existing then set check all --->
		<cfset ExistingGLList = listSort(ExistingGLList,"numeric") />
		<cfset queryGLList = listSort("#valueList(TheQuery.GL_Account_ID)#","numeric") />
		<cfset bCheckAll = 0 />
		<cfloop list="#queryGLList#" 	index="queryGLListId">
			<cfset bCheckAll = listFind(ExistingGLList,queryGLListId) />
			<cfif NOT bCheckAll> <cfbreak> </cfif>
		</cfloop>

		<form name="SelectedGLs" action="" method="post">
			<table width="400" cellpadding="2" cellspacing="0" class="maintable">
				<tr bgcolor="orange">
					<td><input type="checkbox" name="cbAll" <cfif bCheckAll>checked</cfif> onClick="javaScript:selectAll(this.checked);" > </td>
					<td><strong><a href="##" onclick="sortResults('GL_Account')"><cfoutput>#Application.GLAccountLabel#</cfoutput></a></strong></td>
					<td><strong><a href="##" onclick="sortResults('GL_Account_Desc')">GL Description</a></strong></td>
					<td><strong><a href="##" onclick="sortResults('Start_Date')">Start Date</a></strong></td>
					<td><strong><a href="##" onclick="sortResults('End_Date')">End Date</a></strong></td>
				</tr>
				<cfoutput query="TheQuery">
					<tr  BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
						<td><input type="checkbox" name="GL_Account_ID" value="#GL_Account_ID#" <cfif listfind(ExistingGLList, GL_Account_ID)>checked</cfif>></td>
						<td>#GL_Account#</td>
						<td>#GL_Account_Desc#</td>
						<td>#dateformat(Start_Date, 'mm/dd/yyyy')#</td>
						<td>#dateformat(End_Date, 'mm/dd/yyyy')#</td>
					</tr>
				</cfoutput>
			</table>
			<br/>
			<div align="center">
				<CF_button
									button_name		=	""
									button_caption	=	"import to component"
									button_action	=	"SelectedGLs.submit();"
									button_type		=	"javascript_link"
									button_width	=	"75"
									button_color	=	"Navy"
									button_tip		=	""
									enabled				= "#TheQuery.recordcount#"
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold"
								>
			</div>
			<input type="hidden" name="blnSubmit" value="2">
			<input type="hidden" name="Action" value="<cfoutput>#Action#</cfoutput>">
		</form>
	</FIELDSET>

	<script>
	function sortResults(fieldname)
	{
		// enable sort only if there are results.
		<cfif TheQuery.recordcount>
			document.GL_Account_Search.SortBy.value = fieldname;
			document.GL_Account_Search.submit();
		</cfif>
		return false;
	}
	</script>

</cfif>
