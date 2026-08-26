<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfset qHQPositions = HQPositionManager.getAll()>
<cfset getRevisionHQAssigned = HQPositionManager.getRevisionHQAssigned()>
<SPAN CLASS="title2">Assign Revision Types to HQ Positions</SPAN>
	<HR COLOR="Blue" SIZE="1">
	<table cellpadding="2" cellspacing="0" align="center" class="Maintable" width="100%">
		<tr>
			<td id="header"><B>Revision Type</B></td>
			<td id="header"><B>Assign Position to Start Approval From</B></td>
			<td id="header">&nbsp;</td>
			<td id="header">&nbsp;</td>
			<td id="header">&nbsp;</td>
		</tr>
		<tr>
			<td><a onClick="javaScript: NewWindow(this.href , 'Revision_Settings' , 600 , 500 , 'yes' , 'yes'); return false;" target="_blank"  href="/settings/edit_revise_program.cfm?display=1" STYLE="FONT-SIZE:10PX;" TITLE="View the details for this revision type">Revision Type A</a></td>
			<td>
			<select size="1" name="HQPosition_A" style="width:120px">
					<option value="0">None</option>
					<cfoutput>
					<cfloop query="qHQPositions">
						<option value="#qHQPositions.HQ_Position_Id#" <cfif getRevisionHQAssigned.Revision_TypeA EQ qHQPositions.HQ_Position_Id>selected</cfif>>#qHQPositions.HQ_Position_Name#</option>
					</cfloop>
					</cfoutput>
				</select></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td><a onClick="javaScript: NewWindow(this.href , 'Revision_Settings' , 600 , 500 , 'yes' , 'yes'); return false;" target="_blank"  href="/settings/edit_revise_program.cfm?display=1" STYLE="FONT-SIZE:10PX;" TITLE="View the details for this revision type">Revision Type B</A></td>
			<td>
			<select size="1" name="HQPosition_B" style="width:120px">
					<option value="0">None</option>
					<cfoutput>
					<cfloop query="qHQPositions">
						<option value="#qHQPositions.HQ_Position_Id#" <cfif getRevisionHQAssigned.Revision_TypeB EQ qHQPositions.HQ_Position_Id>selected</cfif>>#qHQPositions.HQ_Position_Name#</option>
					</cfloop>
					</cfoutput>
				</select></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td><a onClick="javaScript: NewWindow(this.href , 'Revision_Settings' , 600 , 500 , 'yes' , 'yes'); return false;" target="_blank"  href="/settings/edit_revise_program.cfm?display=1" STYLE="FONT-SIZE:10PX;" TITLE="View the details for this revision type">Revision Type C</A></td>
			<td>
			<select size="1" name="HQPosition_C" style="width:120px">
					<option value="0">None</option>
					<cfoutput>
					<cfloop query="qHQPositions">
						<option value="#qHQPositions.HQ_Position_Id#" <cfif getRevisionHQAssigned.Revision_TypeC EQ qHQPositions.HQ_Position_Id>selected</cfif>>#qHQPositions.HQ_Position_Name#</option>
					</cfloop>
					</cfoutput>
				</select></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
	<tr>
			<td colspan="100%" align="left" id="header" style="border-bottom:none">
			<br>
			<CF_smallLink 
				title = "save" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#formName#', 'RTSave');"""
			>
	</td>
	</tr>
	</table>

</body>
</html>
