<script language="javascript">
function ClickToDisplay(UniqueID)
{
var DisplayObject;

/* Get the row's ID */
DisplayObject = document.getElementById(UniqueID)

/* Show/Hide based on its visible status */
		if(DisplayObject.style.display == 'none')
		{
		DisplayObject.style.display = '';
		}
		else
		{
		DisplayObject.style.display = 'none';
		}
}
</script>

<cfparam name="SQLSORT" default="0">
<cfparam name="CFSORT" default="0">

<!--- Show the links for scheduled CF and SQL jobs --->
<div align="center" style='font-weight:bold'>
<a HREF="##" onClick="ClickToDisplay('CF_JOBS_1');ClickToDisplay('CF_JOBS_2');return false;">SCHEDULED CF JOBS</a>
<CFINCLUDE TEMPLATE="cf_jobs.cfm">
<br />
<a HREF="##" onClick="ClickToDisplay('SQL_JOBS');return false;">SCHEDULED SQL JOBS</a>
<CFINCLUDE TEMPLATE="sql_jobs.cfm">
</div>

<script language="javascript">

<!--- "CFSORT" and  "SQLSORT" are passed in the URL from cf_jobs.cfm and sql_jobs.cfm respectively, while sorting 
			the column headers. We need to pass this to make sure that the data is visible and not hidden.
--->
<cfif SQLSORT eq 1>
	ClickToDisplay('SQL_JOBS');

<cfelseif CFSORT eq 1>
	ClickToDisplay('CF_JOBS_1');
	ClickToDisplay('CF_JOBS_2');
</cfif>

 </script>