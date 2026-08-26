<cfoutput>
<cfparam name="fromFPEmailFaxPage" 	default="0">
<cfif NOT fromFPEmailFaxPage>
<br>
<cfelse>
<cfinclude template="fp_header.cfm">
</cfif>
<B><FONT SIZE="4" COLOR="##000080">Notes</FONT></B>
<cfif NOT fromFPEmailFaxPage>
&nbsp;&nbsp;&nbsp;
<CF_smallLink 
	title = "add note" 
	url = "#thisPage#?command=ceNotes&id=#requestObj.getId()#"
>
</cfif>
<hr color="##000080">

<!---if we have notes then display them--->
<cfif ArrayLen(requestObj.notes)>

	<cfloop index="noteIndx" from="1" to="#ArrayLen(requestObj.notes)#">
	
		<!---set boolean vars needed--->
		<cfset bIsOwner = 0 />
		<cfset bDisplayNote = 1 />
	
		<!---set if this is the owner--->
		<cfif requestObj.notes[noteIndx].getCreatedBy() eq request.AccessStructure.User_Id>
			<cfset bIsOwner = 1 />
		</cfif>
			
		<!---if the note is set to private and the user accessing this note isn't the owner then don't display--->
		<cfif requestObj.notes[noteIndx].getIsPrivate() and not bIsOwner>
			<cfset bDisplayNote = 0 />
		</cfif>
		
		<cfif bDisplayNote>
		<TABLE BORDER="1" cellpadding="1" cellspacing="0" width="100%" style="border: 1px">
			<TR bgcolor="##FFCE84">
				<TD NOWRAP style="border:none">Posted By <b>#requestObj.notes[noteIndx].getCreatedByName()#</b> on <b>#DateFormat(requestObj.notes[noteIndx].getCreatedDate(), "mm/dd/yyyy")#</b></TD>
				<td align="right" style="border:none">
					<cfif NOT fromFPEmailFaxPage>
						<cfif bIsOwner>
							<CF_smallLink 
								title = "edit" 
								url = "#thisPage#?command=ceNotes&id=#requestObj.getId()#&noteId=#requestObj.notes[noteIndx].getNoteId()#"
							>
						</cfif>
					</cfif>
					&nbsp;
				</td>
			</TR>
			<TR>
				<TD colspan="100%" style="border-top:none">#requestObj.notes[noteIndx].getNote()#</td>
			</tr>
		</table>
		</cfif>
		
		<br>
	</cfloop>

<cfelse>
	&nbsp;(NO NOTES)
</cfif>
<cfif NOT fromFPEmailFaxPage>
<br>
<CF_smallLink 
	title = "close notes" 
	url = "##"
	parameters = "onClick=""JavaScript: return submitForm('#formName#','close');"""
>
</cfif>
</cfoutput>
