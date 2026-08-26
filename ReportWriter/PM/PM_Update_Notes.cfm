<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Update Notes</title>
</head>

<body>

<CFIF not isdefined("FORM.Submitted")>
<FORM NAME="Update_Notes" ACTION="PM_Update_Notes.cfm" METHOD="POST">
<INPUT TYPE="Hidden" NAME="Submitted" VALUE="1">
<INPUT TYPE="Hidden" NAME="PM_Item_Master_ID" VALUE=<CFOUTPUT>"#URL.PM_Item_Master_ID#"</CFOUTPUT>>

<TABLE BORDER="0" WIDTH="100%" CELLPADDING="0">
	<TR>
		<TD COLSPAN="100%"><B><FONT SIZE="3" COLOR="Navy">Update notes</FONT></B><HR COLOR="Orange"></TD>
	</TR>
	<TR>
		<TD VALIGN="Top" ALIGN="Right"><BR><B>Project:</B></TD>
		<TD><BR>&nbsp;<FONT SIZE="2" COLOR="Red"><B><CFOUTPUT>#Descp#</CFOUTPUT></B></FONT></TD>
	</TR>
	<TR>
		<TD ALIGN="Right" VALIGN="Top"><BR><B>Notes:</B></TD>
		<TD><BR>&nbsp;<TEXTAREA COLS="95" NAME="Ud_Notes" ROWS="5"></TEXTAREA></TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" ALIGN="Center"><BR>
		<CFOUTPUT>
			<CF_button
				button_name		=	""
				button_caption	=	"Save"
				button_action	=	"javascript: submit_this();"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				>
		</CFOUTPUT>
		</TD>
	</TR>
</TABLE>
</FORM>
<SCRIPT language="JavaScript">
function focusToNotes()
{
	document.Update_Notes.Ud_Notes.focus()		 
}
document.body.onload = new Function("focusToNotes();");
window.setTimeout("focusToNotes()", 500);

function submit_this()
{	
	if (document.Update_Notes.Ud_Notes.value != "")
	{
		document.Update_Notes.submit();
	}
	else
	{	
		alert("Please enter some notes to update the existing notes.");
	}
}

</SCRIPT>

<CFELSE>
	<CFOUTPUT>
	<cfset useLakebaseForUpdate_Notes_Field = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_notes")>
<cfif useLakebaseForUpdate_Notes_Field>
	<cftry>
		<cfset application.oLakebase.insertRow("pm_notes", {
			"pm_item_master_id" = "#Form.PM_Item_Master_ID#",
			"pm_notes" = "#Form.Ud_Notes#",
			"user_id" = "#request.AccessStructure.User_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Notes_Field = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Notes_Field>
<CFQUERY NAME="Update_Notes_Field" DATASOURCE="#Application.Datasource#">
		INSERT	INTO PM_Notes
				(
					PM_Item_Master_ID,
					PM_Notes,
					User_ID
				)
		VALUES
				(
					'#Form.PM_Item_Master_ID#',
					'#Form.Ud_Notes#',
					'#request.AccessStructure.User_ID#'
				)
	
	</CFQUERY>
</cfif>
	<cfset useLakebaseForChange_Modi_By = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_item_master")>
<cfif useLakebaseForChange_Modi_By>
	<cftry>
		<cfset application.oLakebase.updateRows("pm_item_master",
			{
				"pm_item_master_id" = "eq.#Form.PM_Item_Master_ID#"
			},
			{
				"pm_modified_by_id" = "#request.AccessStructure.User_ID#",
				"pm_date_modified" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForChange_Modi_By = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForChange_Modi_By>
<CFQUERY NAME="Change_Modi_By" DATASOURCE="#Application.Datasource#">
		UPDATE 		PM_Item_Master 
		SET 		PM_Modified_By_ID = '#request.AccessStructure.User_ID#',
					PM_Date_Modified = #now()# 
		WHERE 		PM_Item_Master_ID = '#Form.PM_Item_Master_ID#'
	</CFQUERY>
</cfif>
	
	</CFOUTPUT>
	
	<SCRIPT language="JavaScript">
	function close_this()
	{
		window.close();
	}
	window.setTimeout("close_this()",0);
	</SCRIPT>
</CFIF>







</body>
</html>
