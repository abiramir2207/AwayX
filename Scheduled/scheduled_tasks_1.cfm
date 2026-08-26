<!---
	Name:
		scheduled_tasks.cfm
	Created By:
		Tim Ford 08/27/2003 
	Description:
		File used to call all scheduled tasks
--->

<!---set the Domain for which the url is to run in--->
<cfset url_domain = "http://#CGI.SERVER_NAME#" />

<!---set scripts array--->
<cfset aScript = ArrayNew(1) />
<cfset aScript[ArrayLen(aScript) + 1] = "/scheduled/auto_renew_programs.cfm" />
<cfset aScript[ArrayLen(aScript) + 1] = "/Common_Files/Contracts/Delete_Temp_Files/Delete_Temp_Files.cfm" />
<cfset aScript[ArrayLen(aScript) + 1] = "/anything_automated/onlypublicdirectory/schedule_this_file_only.cfm" />
<cfif application.futuresPricingLinksAvailable>
	<cfset aScript[ArrayLen(aScript) + 1] = "/scheduled/fp_nightly_process.cfm" />
</cfif>
<cfif application.deductionLinksAvailable>
	<cfset aScript[ArrayLen(aScript) + 1] = "/scheduled/deduction_reminder.cfm" />
</cfif>

<cfloop index="indx" from="1" to="#ArrayLen(aScript)#">
	
	<!---set the task name--->

	<cfset taskName = "#ListFirst(ListLast(aScript[indx], "/"), ".")#" />

<cfoutput>

#url_domain##aScript[indx]#<hr>



<cfhttp url="#url_domain##aScript[indx]#" method="get" resolveurl="no">

#isDefined("cfhttp")#<hr>



<cfif CompareNoCase(cfhttp.Responseheader.Status_Code, "200")>
			<cfset logText = "#taskName# failed." />
		<cfelse>
			<cfset logText = "#taskName# was successful." />
		</cfif>
#logText#<hr>


</cfoutput>
<!------		
	<cfhttp url="#url_domain##aScript[indx]#" method="get" resolveurl="no">
		
		
		<cfif CompareNoCase(cfhttp.Responseheader.Status_Code, "200")>
			<cfset logText = "#taskName# failed." />
		<cfelse>
			<cfset logText = "#taskName# was successful." />
		</cfif>
		
		<cflog text="#logText#" log="scheduler" application="yes">
		
		<cfset fileName = "#taskName#.htm" />
		
		<cffile action="write" file="#request.app_general_functions.Get_Application_Path()#\scheduled\#fileName#" output="#cfhttp.FileContent#" addnewline="no">
		
	</cfhttp>
-------->
</cfloop>
