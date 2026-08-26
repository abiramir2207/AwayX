 <!---      
			 Name:          sql_jobs.cfm               
			 Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
			 Created Date:  09/14/2007
			 Created By:    Milan Mushran
			 Description:   This page show all the scheduled SQL Jobs
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
function doSort(sFieldName, sSortOrder)
{
	oForm = document.all.MyForm;
	oForm.sort_by.value = sFieldName;
	oForm.sort_order.value = sSortOrder;
	oForm.submit();	
	return false;				
}
</script>

<cfparam name="sort_by"	default="">
<cfparam name="sort_order"	default="">


<!--- Sort the header links (Ascending and Descending) --->
<cffunction name="SortHeader" access="public" output="false" returntype="string">
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
					<a href="javascript: doSort('#arguments.sFieldName#', '#newSortOrder#','MyForm');">
		</cfif>
			#arguments.sTitle#
			<cfif Len(sortImage) GT 0><img border="0" src="/Images/#sortImage#"></cfif>
		<cfif arguments.iSortable></a></cfif>
	</cfsavecontent>
	</cfoutput>
	
	<cfreturn sReturnValue />
</cffunction>

<cfquery name="getDBName" datasource="#application.datasource#">
SELECT TOP 1 TABLE_CATALOG 
FROM INFORMATION_SCHEMA.TABLES
</cfquery>

<cfquery name="getJobsList" datasource="#application.datasource#">
SELECT A.name,A.enabled,A.date_created,A.date_modified
,CAST -- The run_date is in "20050921(yyyymmdd)" format
		( 
				CONVERT(VARCHAR,C.run_date) 
				+ ' ' + STUFF(STUFF(RIGHT('000000' 
				+ CONVERT(VARCHAR,C.run_time),6),5,0,':'),3,0,':')
				As DATETIME 
		) 
As run_time
,C.run_status
/* "run_duration" is not in a fixed format. Its format varies upon the length of the string.
It could be just in (seconds), or (seconds and minutes) or (seconds, minutes and hours).
*/
,CASE    -- get hours
        WHEN LEN( CAST(C.run_duration AS varchar) ) > 5 THEN
                    CAST(LEFT(CAST(C.run_duration as varchar), 2) AS int)				
			  WHEN LEN( CAST(C.run_duration AS varchar) ) = 5 THEN                   
                    CAST(LEFT(CAST(C.run_duration as varchar), 1) AS int)
				END
	As Execution_Hours
,CASE    -- get minutes
        WHEN LEN( CAST(C.run_duration AS varchar) ) > 5 THEN
                    CAST(SUBSTRING(CAST(C.run_duration as varchar), 3, 2) AS int)				
			  WHEN LEN( CAST(C.run_duration AS varchar) ) = 5 THEN                   
                    CAST(SUBSTRING(CAST(C.run_duration as varchar), 2, 2) AS int)
				WHEN LEN( CAST(C.run_duration AS varchar) ) = 4 THEN
										CAST(LEFT(CAST(C.run_duration as varchar), 2) AS int)
				WHEN LEN( CAST(C.run_duration AS varchar) ) = 3 THEN
										CAST(LEFT(CAST(C.run_duration as varchar), 1) AS int)
				END
	As Execution_Minutes
,CASE    -- get seconds
        WHEN LEN( CAST(C.run_duration AS varchar) ) > 5 THEN
                    CAST(RIGHT(CAST(C.run_duration as varchar), 2) AS int)				
			  WHEN LEN( CAST(C.run_duration AS varchar) ) = 5 THEN                   
                    CAST(RIGHT(CAST(C.run_duration as varchar), 2) AS int)
				WHEN LEN( CAST(C.run_duration AS varchar) ) = 4 THEN
										CAST(RIGHT(CAST(C.run_duration as varchar), 2) AS int)
				WHEN LEN( CAST(C.run_duration AS varchar) ) = 3 THEN
										CAST(RIGHT(CAST(C.run_duration as varchar), 2) AS int)
			  ELSE
                   C.run_duration			
				END
	As Execution_Seconds

FROM msdb.dbo.sysjobs A
INNER JOIN msdb.dbo.sysjobhistory C
ON a.job_id=c.job_id
WHERE A.name LIKE '%#getDBName.Table_Catalog#%'
AND C.STEP_ID = 0
<!--- Only for the last 90 days --->
and DateDiff(d,CAST -- The run_date is in "20050921(yyyymmdd)" format
		( 
				CONVERT(VARCHAR,C.run_date) 
				+ ' ' + STUFF(STUFF(RIGHT('000000' 
				+ CONVERT(VARCHAR,C.run_time),6),5,0,':'),3,0,':')
				As DATETIME 
		),getdate())  <= 90
ORDER BY  
<cfif SQLSORT eq "0">
C.run_Date DESC, A.name, C.run_status
<cfelse> 
#SORT_BY# #SORT_ORDER#
</cfif>
</cfquery>

<br />

<cfoutput>
<table id="SQL_JOBS" style="display:none" align="center" width="100%" class="PageContent" border="0" cellspacing="0">
	<tr>
		<td class="heading" valign="top">#SortHeader("A.name", "JOB NAME", sort_by, sort_order, 1)#</td>
		<td class="heading" valign="top">STATUS</td>
		<td class="heading" valign="top">CREATED<BR />DATE</td>
		<td class="heading" valign="top">MODIFIED<BR />DATE</td>
		<td class="heading" valign="top">#SortHeader("run_time", "EXECUTION<BR />DATE", sort_by, sort_order, 1)#</td>	
		<td class="heading" valign="top">#SortHeader("C.run_status", "EXECUTION<BR />STATUS", sort_by, sort_order, 1)#</td>
		<td class="heading" valign="top">#SortHeader("C.run_duration", "EXECUTION<BR />DURATION", sort_by, sort_order, 1)#</td>
	</tr>
</cfoutput>

<cfoutput query="getJobsList">
	<tr onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<td class="underlined">#Name#</td>
		<td class="underlined"><cfif enabled eq "1">Enabled<cfelse>Disabled</cfif></td>
		<td class="underlined">#DateFormat(date_created,'m/d/yy')#<br />#TimeFormat(date_created,'h:mm tt')#</td>
		<td class="underlined">#DateFormat(date_modified,'m/d/yy')#<br />#TimeFormat(date_modified,'h:mm tt')#</td>
		<td class="underlined">#DateFormat(run_time,'m/d/yy')#<br />#TimeFormat(run_time,'h:mm tt')#</td>
		<td class="underlined"><cfif run_status eq 1>Succeeded<cfelse><span style="color:red">Failed</span></cfif></td>
		<td class="underlined">
		#Execution_Hours#<cfif Execution_Hours neq "">&nbsp;hr</cfif>
		#Execution_Minutes#<cfif Execution_Minutes neq "">&nbsp;min</cfif>
		#Execution_Seconds#<cfif Execution_Seconds neq "">&nbsp;sec</cfif>
		</td>
	</tr>
</cfoutput>
</table>

<!--- This form gets used for sorting column headers --->
<CFOUTPUT>
<FORM ACTION="Scheduled_Jobs.cfm?SQLSORT=1" METHOD="post" NAME="MyForm" ID="MyForm">
<input type="hidden" name="sort_by" value="#sort_by#">
<input type="hidden" name="sort_order" value="#sort_order#">
</FORM>
</CFOUTPUT>