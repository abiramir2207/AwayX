<CFSET PAGE_TITLE="Create Payable">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<cfquery name="getDistinctFilepaths" datasource="#Application.Datasource#">
	SELECT DISTINCT path_info
	FROM cf_file_Access
	WHERE path_info <> '/graph.cfm' AND path_info <> '/xm/checkConnection.cfm'
</cfquery>

<CFSET tempdata = arrayNew(1)>

<cfloop index="x" from="1" to="#getDistinctFilepaths.recordcount#" step="1">
	<CFSET tempdata[x] = 0>
</CFLOOP>

<CFSET temp = QueryAddColumn(getDistinctFilepaths, "number_of_requests", tempdata)>

<!--- <CFDUMP var="#getDistinctFilepaths#"> --->

<CFSet recordcounter = 1>

<cfloop query="getDistinctFilepaths">
	<cfset path_info_string = getDistinctFilepaths.path_info>
	<cfquery name="getCount" datasource="#Application.Datasource#">
		SELECT cf_file_access_id
		FROM cf_file_access
		WHERE path_info = '#path_info_string#'
	</cfquery>
	<CFSET temp = QuerySetCell(getDistinctFilepaths,'number_of_requests',getCount.recordcount,recordcounter)>

	<CFSet recordcounter = recordcounter + 1>
</CFLOOP>


<!--- <CFDUMP var="#getDistinctFilepaths#"> --->

<cfgraph type="HORIZONTALBAR" query="getDistinctFilepaths" valuecolumn="Number_Of_Requests" itemcolumn="Path_info" showvaluelabel="Yes" valuelabelsize="20" valuelocation="OVERBAR"></cfgraph>




</BODY>
</HTML>