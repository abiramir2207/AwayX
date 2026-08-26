<cfoutput>
<br>

<B><FONT SIZE="4" COLOR="##000080">Reminders</FONT></B>&nbsp;&nbsp;&nbsp;
<CF_smallLink 
	title = "add reminder" 
	url = "#thisPage#?command=ceReminder&id=#requestObj.getId()#&reminderDisplay=#form.reminderDisplay#"
>
<hr color="##000080">
<form action="#thisPage#?command=dReminder&id=#requestObj.getId()#" method="post" name="#formName#">
Show: <select name="reminderDisplay" onChange="#formName#.submit();">
	<option value="1" <cfif form.reminderDisplay eq "1">selected</cfif>>Todays</option>
	<option value="2" <cfif form.reminderDisplay eq "2">selected</cfif>>All</option>
</select>
</form>
<TABLE BORDER="0" cellpadding="0" cellspacing="0" width="100%" class="MainTable">
	<TR bgcolor="##FFCE84">
		<td id="header"><b>Reminder</b></td>
		<td id="header"><b>Reminder Date</b></td>
		<td id="header"><b>Email Notification</b></td>
		<td id="header"><b>Private</b></td>
		<td id="header">&nbsp;</td>
<cfif ArrayLen(requestObj.reminder)>

	<cfloop index="remIndx" from="1" to="#ArrayLen(requestObj.reminder)#">
	
		<!---set boolean vars needed--->
		<cfset bIsOwner = 0 />
		<cfset bDisplayReminder = 1 />
		
		<!---set if this is the owner--->
		<cfif requestObj.reminder[remIndx].getCreatedBy() eq request.AccessStructure.User_Id>
			<cfset bIsOwner = 1 />
		</cfif>
			
		<!---if the reminder is set to private and the user accessing this reminder isn't the owner then don't display--->
		<cfif requestObj.reminder[remIndx].getIsPrivate() and not bIsOwner>
			<cfset bDisplayReminder = 0 />
		</cfif>
	
		<cfif bDisplayReminder>
			<TR>
				<TD>#requestObj.reminder[remIndx].getDesc()#</td>
				<td>#DateFormat(requestObj.reminder[remIndx].getReminderDate(), "mm/dd/yyyy")#</td>
				<td><cfif requestObj.reminder[remIndx].getEmailReminder()>yes<cfelse>no</cfif></td>
				<td><cfif requestObj.reminder[remIndx].getIsPrivate()>yes<cfelse>no</cfif></td>
				<td>
					<cfif bIsOwner>
						<CF_smallLink 
							title = "edit" 
							url = "#thisPage#?command=ceReminder&id=#requestObj.getId()#&reminderId=#requestObj.reminder[remIndx].getId()#&reminderDisplay=#form.reminderDisplay#"
						>
					</cfif>&nbsp;
				</td>
			</tr>
		
		</cfif>

	</cfloop>
	
<cfelse>
	<TR>
		<TD colspan="100%">&nbsp;(NO REMINDERS)</td>
	</tr>
</cfif>
</table>
<br><br>
<CF_smallLink 
	title = "close reminders" 
	url = "##"
	parameters = "onClick=""JavaScript: return submitForm('#formName#','close');"""
>

</cfoutput>
