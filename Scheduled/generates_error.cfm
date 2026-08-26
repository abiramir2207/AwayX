<CFOUTPUT>#GENERATE_ERROR_PLEASE_DO_NOT_WORRY_ABOUT_THIS#</CFOUTPUT>

<cfquery name="CheckPunchList" datasource="PunchList">
select from punch where punch_id = 251
</cfquery>
Middle
<Cfoutput query="CheckPunchList">
#Punch_ID# #Punch_Name# #Punch_FileName#<br>#punch_desc#
</CFOUTPUT>
End