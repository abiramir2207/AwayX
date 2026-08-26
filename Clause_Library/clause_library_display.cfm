<!------ clause_library_display.cfm ----->
<CFOUTPUT>
<cfparam name="url.id" 	default="0">
<cfparam name="form.id" 	default="#url.id#">

<cfif form.id>
	<br>
	<cfset clauseLibraryManager = CreateObject("component", "components.clause_library.ClauseLibraryManager").init() />
	<cfset clauseLibrary = clauseLibraryManager.getClause(form.id)>
	<FONT FACE="Arial, Helvetica, sans-serif" COLOR="##000099"><B>#ucase(clauseLibrary.getCategory().getTitle())#</B></FONT>
	<HR COLOR="##FF0000" SIZE="2">
	#clauseLibrary.getBody()#
	
	<br><br>
	<table align="center">
	<tr>
	<td>
	<CF_button
		button_name		=	""
		button_caption	=	"Close"
		button_action	=	"window.close();"
		button_type		=	"javascript_link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Close"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
		>
	</td>
	</tr>
	</table>
</cfif>
</CFOUTPUT>
<!--- Dev Note: drachala; D29797: Clause Library  START
Added/Changed: Added Text Area to prevent JS error--->
<div style="display:none;">
<textarea rows="2" cols="20" style="display:none;" id="textarea">
Dont Remove me, if you do so you will get JS error
Message: Object required
Line: 697
Char: 3
Code: 0
URI: http://gm.stage.awayx.com/Script/Editor/scripts/wysiwyg.js
</textarea>
</div>
<!--- End Dev Note: drachala; D29797: Clause Library  --->