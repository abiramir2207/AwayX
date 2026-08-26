<cfoutput>

<!---if we have a note object then set it, otherwise clear the note and create and empty one--->
<cfif ArrayLen(requestObj.getNotes()) and form.noteId>
	<cfset noteObj = requestObj.getNotes() />
<cfelse>
	<cfset tmpNoteObj = CreateObject("component", "components.futures_pricing.Note").init() />
	<cfset ArrayClear(requestObj.notes) />
	<cfset requestObj.setNotes(tmpNoteObj) />
	<cfset noteObj = requestObj.getNotes() />
</cfif>

<br>
<B><FONT SIZE="4" COLOR="##000080">Add Notes</FONT></B>&nbsp;&nbsp;&nbsp;
<hr color="##000080">
<form action="#thisPage#?command=sNotes&id=#requestObj.getId()#" method="post" name="#formName#">
<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td bgcolor="##003366"><FONT SIZE="4" COLOR="##FFFFFF"><b>Note</B></FONT></td>
	</tr>
	<tr>
		<td><textarea name="note" cols="75" rows="5">#noteObj[1].getNote()#</textarea></td>
	</tr>
	<tr>
		<td>Mark private&nbsp;&nbsp;<input name="isPrivate" type="checkbox" value="1" <cfif noteObj[1].getIsPrivate()>checked</cfif> /></td>
	</tr>
</table>
<br>
<CF_smallLink 
	title = "save" 
	url = "##"
	parameters = "onClick=""JavaScript: return submitForm('#formName#','sNotes');"""
>
<CF_smallLink 
	title = "cancel" 
	url = "#thisPage#?command=dNotes&id=#requestObj.getId()#"
>

<INPUT NAME="createdBy" TYPE="Hidden" VALUE="#request.AccessStructure.User_Id#" />
<INPUT NAME="command" TYPE="Hidden" VALUE="#form.command#" />
<INPUT NAME="id" TYPE="Hidden" VALUE="#requestObj.getId()#" />
<INPUT NAME="noteId" TYPE="Hidden" VALUE="#noteObj[1].getNoteId()#" />

</form>
</cfoutput>
