
<cfparam name="PunchID"	default="">
<cfparam name="WR_ID"	default="0">
<cfoutput>
<cfquery name="updateUsersTo9999" datasource="#application.datasource#">
	update _users
	Set User_Rights_ID = 9999 
	where Name_first in ('Ernesto','Arlie', 'Polina','Tammie') 
	and Name_Last in ('Rosado','Ramirez', 'Zasheva',  'Nguyen')
</cfquery>
done
</cfoutput>