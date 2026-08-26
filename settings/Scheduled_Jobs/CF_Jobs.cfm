 <!---      
			 Name:          cf_jobs.cfm               
			 Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
			 Created Date:  09/13/2007
			 Created By:    Milan Mushran
			 Description:   This page show all the scheduled CF Jobs
			 Parameters:    None
			 Modified By:
			 Modified Date:
			 Modification:
--->
 <style type="text/css">
	.heading{ 	
		font-family: verdana,arial,helvetica; font-size: 11px;font-weight: bold;background: #FFB062;
		}
	.PageContent{ 		
		font-family:Verdana, Arial, Helvetica, sans-serif;font-size:9px;
		}
	TD.UNDERLINED{		
		border-bottom: 1px solid #7575FF;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;
		}
	TR.highlight TD.UNDERLINED{		
		background-color: #EAFFEA;
		}
	TR.nothighlight TD.UNDERLINED{  
		border-bottom: 1px solid #7575FF;
		}
	</style>

<script language="javascript">
function doSort1(sFieldName, sSortOrder)
{
	oForm = document.all.MyForm1;
	oForm.sort_by.value = sFieldName;
	oForm.sort_order.value = sSortOrder;
	oForm.submit();	
	return false;				
}
</script>


<cfparam name="SORT_BY" default="">
<cfparam name="SORT_ORDER" 	default="">

<!--- Sort the header links (Ascending and Descending) --->
<cffunction name="SortHeader1" access="public" output="false" returntype="string">
	<cfargument name="sFieldName" type="string" required="true" />
	<cfargument name="sTitle" type="string" required="true" />
	<cfargument name="sCurrentSortBy" type="string" required="true" />
	<cfargument name="sCurrentSortOrder" type="string" required="true" />
	<cfargument name="iSortable" type="boolean" required="true" />
	
	<cfset var sReturnValue = "" />
	<cfset var sortImage = "" />
	<cfset var newSortOrder = "" />
	<cfif arguments.iSortable>
		<cfif arguments.sFieldName EQ arguments.sCurrentSortBy>
			<cfif arguments.sCurrentSortOrder EQ "desc">
				<cfset newSortOrder = "asc" />
				<cfset sortImage = "up_1.gif" />
			<cfelse>
				<cfset newSortOrder = "desc" />
				<cfset sortImage = "down_1.gif" />
			</cfif>
		<cfelse>
			<CFSET newSortOrder = "asc" />
		</cfif>
	</cfif>	
	<cfoutput>
	<cfsavecontent variable="sReturnValue">
		<cfif arguments.iSortable>
					<a href="javascript: doSort1('#arguments.sFieldName#', '#newSortOrder#','MyForm1');">
		</cfif>
			#arguments.sTitle#
			<cfif Len(sortImage) GT 0><img border="0" src="/Images/#sortImage#"></cfif>
		<cfif arguments.iSortable></a></cfif>
	</cfsavecontent>
	</cfoutput>
	
	<cfreturn sReturnValue />
</cffunction>

<!--- Initialize the Java Service Factory --->
<cfobject type="JAVA" action="Create" name="factory" class="coldfusion.server.ServiceFactory">

<!--- Get all the jobs from the JAVA service factory --->
<cfset allTasks = factory.CronService.listAll()>   


<!--- Get the details of "Scheduled_Tasks.cfm" file --->
 <cfquery name="CF_Jobs" datasource="#application.datasource#">
	SELECT Created_Date,Message,Execution_Time,Status
	FROM Scheduled_CF_JOBS
	ORDER BY 
	<cfif CFSORT eq "0">CAST(Created_Date As datetime) DESC,Message
	<cfelse> 
	#SORT_BY# #SORT_ORDER#
	</cfif>
 </cfquery>

<!--- Show the CF Jobs --->
<table id="CF_JOBS_1" style="display:none" align="center" width="100%" class="PageContent" border="0" cellspacing="0">
	<tr>
		<td class="heading" width="28%" valign="top">JOB NAME</td>
		<td class="heading" width="38%" valign="top">FILE</td>
		<td class="heading" width="5%" valign="top">STATUS</td>
		<td class="heading" width="12%" valign="top">START DATE</td>
		<td class="heading" width="5%" valign="top">FREQUENCY</td>
		<td class="heading" width="12%" valign="top">START TIME</td>
	</tr>
	<cfoutput>
		<cfloop from="1" to="#Arraylen(allTasks)#" index="i">
		<!--- In most cases, it will be 'http://xyz.awayx.com/whatever'--->
			<cfset Find_Character = Find("/",allTasks[i].url,8)>
			<cfif Find_Character eq 0>
			<!--- In some cases, it could be 'http://xyz.awayx.com?param=value'--->
				<cfset Find_Character = Find("?",allTasks[i].url,8)>
			</cfif>

		<!--- We need to see the jobs for a particular instance only. For Eg: If one is logged onto xyz.awayx.com, we only want to
					see any job added for xyz.awayx.com on the coldfusion server and not any other web site. We need to extract the
					Domain Address (xyz.awayx.com in this case) for this purpose. --->
			<cfset Domain_Address = Replace(Left(allTasks[i].url,Find_Character-1),'http://',"")>
			<cfif Server_Name eq Domain_Address>
				<tr onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
					<td class="underlined">#allTasks[i].task#</td>
					<td class="underlined">#Replace(Replace(allTasks[i].url,'http://',""),server_name,"")#</td>
					<td class="underlined">
							<cfif (StructKeyExists(allTasks[i],"paused") AND allTasks[i].paused eq "no")  
								OR	(StructKeyExists(allTasks[i],"status") AND allTasks[i].status eq "running") >
								Enabled
							<cfelse>
								Disabled
							</cfif>
					</td>
					<td class="underlined">#DateFormat(allTasks[i].start_date,'m/d/yy')#</td>
					<td class="underlined"><cfif IsNumeric(allTasks[i].Interval)>Every #NumberFormat(Evaluate(allTasks[i].Interval/3600),',.99')# hour/s<cfelse>#allTasks[i].Interval#</cfif></td>
					<td class="underlined">#TimeFormat(allTasks[i].start_time,'h:mm tt')#</td>
				</tr>
			</cfif>
		</cfloop>
	</cfoutput>
</table>

<p>

<!--- Show the steps of the "NIGHTLY SCHEDULED TASK" --->
<table id="CF_JOBS_2" style="display:none" align="center" width="100%" class="PageContent" border="0" cellspacing="0">
	<tr>
		<td colspan="100%" align="center"><span style="font-weight:bold">"NIGHTLY SCHEDULED TASK" STEPS</span></td>
	</tr>
	<CFOUTPUT>
	<tr>
		<td class="heading" valign="top">#SortHeader1("Created_Date", "EXECUTION<BR />DATE", sort_by, sort_order, 1)#</td>
		<td class="heading" valign="top">#SortHeader1("Message", "TASK NAME", sort_by, sort_order, 1)#</td>
		<td class="heading" valign="top">#SortHeader1("CAST(Execution_Time As bigint)", "EXECUTION<BR />DURATION", sort_by, sort_order, 1)#</td>
		<td class="heading" valign="top">#SortHeader1("status", "EXECUTION<BR />STATUS", sort_by, sort_order, 1)#</td>
	</tr>	
	</CFOUTPUT>

	<cfset Calculated_Execution_hours = 0>
	<cfset Calculated_Execution_minutes = 0>
	<cfset Calculated_Execution_seconds = 0>
	<cfset Positive_or_Negative_hours = 0>
	<cfset Positive_or_Negative_minutes = 0>
	<cfset Positive_or_Negative_seconds = 0>

<!--- ****Execution_Time is in milliseconds**** --->
<cfoutput query="CF_Jobs">

<!--- Get the execution time in hours (if any) --->
	<cfset Calculated_Execution_hours = Evaluate(Execution_Time/3600000)>

<!--- For some division of numbers, the calculated value is in exponential format, so CF is unable to determine
		  the true value of that number, so I am using the log function. Now I know the true value of the number. --->
<cfif Calculated_Execution_hours GT 0>
	<cfset Positive_or_Negative_hours = Log(Calculated_Execution_hours)>
</cfif>

<!--- Get the remainder in minutes (if any) --->
<cfset Calculated_Execution_Remainder = Execution_Time MOD 3600000>

<!--- Get the hours in whole number format (the decimal value should be in minutes and seconds) --->
<cfif Positive_or_Negative_hours GT 0 AND Calculated_Execution_Remainder neq 0>
	<cfset Calculated_Execution_hours = Left(Calculated_Execution_hours,Find(".",Calculated_Execution_hours)-1)>
</cfif>

<!--- Get the execution time in minutes (if any) --->
	<cfset Calculated_Execution_minutes = Evaluate(Calculated_Execution_Remainder/60000)>
	
<!--- Get the remainder in seconds (if any) --->
<cfset Calculated_Execution_Remainder = Calculated_Execution_Remainder MOD 60000>

<!--- For some division of numbers, the calculated value is in exponential format, so CF is unable to determine
		  the true value of that number, so I am using the log function. Now I know the true value of the number. --->
<cfif Calculated_Execution_minutes GT 0>
	<cfset Positive_or_Negative_minutes = Log(Calculated_Execution_minutes)>
</cfif>

<!--- Get the minutes in whole number format (the decimal value should be in seconds) --->
<cfif Positive_or_Negative_minutes GT 0 AND Calculated_Execution_Remainder neq 0>
	<cfset Calculated_Execution_minutes = Left(Calculated_Execution_minutes,Find(".",Calculated_Execution_minutes)-1)>
</cfif>

<!--- Get the execution time in seconds (It could be less than a second too) --->
<cfset Calculated_Execution_seconds = Evaluate(Calculated_Execution_Remainder/1000)>

<!--- For some division of numbers, the calculated value is in exponential format, so CF is unable to determine
		  the true value of that number, so I am using the log function. Now I know the true value of the number. --->
<cfif Calculated_Execution_seconds GT 0>
	<cfset Positive_or_Negative_seconds = Log(Calculated_Execution_seconds)>
</cfif>

<!--- Get the remainder in milliseconds (if any), though we dont specifically show milliseconds  --->
<cfset Calculated_Execution_Remainder = Calculated_Execution_Remainder MOD 1000>

<!--- Get the seconds in whole number format (the decimal value should be in milliseconds)--->
<cfif Positive_or_Negative_seconds GT 0  AND Calculated_Execution_Remainder neq 0>
	<cfset Calculated_Execution_seconds = Left(Calculated_Execution_seconds,Find(".",Calculated_Execution_seconds)-1)>
</cfif>

	<tr onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<td class="underlined">#DateFormat(Created_Date,'m/d/yy')# #TimeFormat(Created_Date,'h:m tt')#</td>
		<td class="underlined">#Message#</td>
		<td class="underlined">			
			<cfif Positive_or_Negative_hours GTE 0>
				#Calculated_Execution_hours# hr
			</cfif>
			<cfif Positive_or_Negative_minutes GTE 0>
				#Calculated_Execution_minutes# min
			</cfif>
				#Calculated_Execution_seconds# sec
		</td>
		<td class="underlined"><cfif status eq 0><span style="color:red">Failed</span><cfelse>Succeeded</cfif></td>
	</tr>
</cfoutput>
</table>

<!--- This form gets used for sorting column headers --->
<CFOUTPUT>
<FORM ACTION="Scheduled_Jobs.cfm?CFSORT=1" METHOD="post" NAME="MyForm1" ID="MyForm1">
<input type="hidden" name="sort_by" value="#sort_by#">
<input type="hidden" name="sort_order" value="#sort_order#">
</FORM>
</CFOUTPUT>