<!---------------------------------------------------------------------------------------------------------------------
      Template:  \Scheduled\deleteAuditReports.cfm
      Date:      Feb 3 2012
      Author:    Chris Nguyen
      Purpose:   Delete Old Audit Reports - D30227
----------------------------------------------------------------------------------------------------------------------->

<cfparam name="URL.deleteAfterDays"  default="90">
<cfparam name="URL.filesFilter"      default="Audit_Report_*.*">
<cfparam name="URL.Relative_Path"    default="\Temp_Files\Billback\0000000000"> <!---\Scheduled\Billback_III_PU_Audit_Reprot.cfm--->

<cfscript>
   my = structnew();
</cfscript>

<!---read files in specified folder to gather files to delete--->
<cfdirectory action="list" directory="#ExpandPath( URL.Relative_Path )#" name="my.filesToDelete" filter="#URL.filesFilter#" type="file">

<cfloop query="my.filesToDelete">

  <!---if file is older than the specified number of days blow it away--->
  <cfif datediff('d', my.filesToDelete.dateLastModified, now()) gte url.deleteAfterDays>
    <cffile action="delete" file="#my.filesToDelete.Directory#\#my.filesToDelete.Name#">
  </cfif>

</cfloop>

