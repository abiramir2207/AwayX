<!------ notes ----->
<cfoutput>
<!------ set defaults ----->
<cfset formName = "dataForm">
<cfparam name="form.state" default="0" />
<cfparam name="url.noteId" default="0" />
<cfparam name="form.noteId" default="#url.noteId#" />

<!---initialize the components we need--->
<cfset noteManager = CreateObject("component", "components.futures_pricing.NoteManager") />

<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////// Controller Section //////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<!---if the command is sNote then save and relocate--->
<cfif form.command eq "sNotes">
	
	<cfset requestObj =  noteManager.getRequestNotes(form.id,0,form.noteId) />
	<cfset noteObj = noteManager.set(form) />
	<cfset noteManager.save(noteObj) />
	
	<cflocation addtoken="No" url="#thisPage#?command=dNotes&id=#requestObj.getId()#">

<cfelse>
	
	<cfset requestObj =  noteManager.getRequestNotes(form.id,0, form.noteId) />	
	
</cfif>

<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////// End Controller Section //////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<SCRIPT>
	
	function submitForm(formName, command) 
	{
		var formName = eval("document." + formName);

		//close the window if the command is close
		if (command == 'close')
		{
			window.close();
			return false;
		}
		else
		{
			//do validation
			if (trim(formName.note.value) == "")
			{
				alert("Please provide a note.");
				return false;
			}
			formName.command.value = command;
			formName.submit();
			return false;
		}
	}
	
</SCRIPT>

<cfif form.command EQ "ceNotes">
	<cfinclude template="notes_create_edit.cfm">
<cfelse>
	<cfinclude template="notes_display.cfm">
</cfif>

</cfoutput>