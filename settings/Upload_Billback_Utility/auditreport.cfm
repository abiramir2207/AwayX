<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<!---------------------------------------------------------------------------------------------------------------------
      Template:   \settings\Upload_Billback_Utility\auditreport.cfm
      Date:       Feb 2 2012
      Author:     Chris Nguyen
      Purpose:    Display audit report

      Parameters:

      URL.FilePrefix (required)
----------------------------------------------------------------------------------------------------------------------->

<cfoutput>
<html lang="en">
<head>
 <meta http-equiv="content-type" content="text/html; charset=utf-8">
 <title>Upload Audit Report</title>
</head>

<body>

  <!---find the audit report files--->
  	<cfif URL.FileName NEQ  "">
	  <cfdirectory action="list" directory="#ExpandPath('\Temp_Files\Billback\0000000000\')#" name="auditReport" filter="#url.FileName#">
	</cfif>	
	
	<cfif ((URL.FileName EQ "") OR (isDefined("auditReport.RecordCount") AND auditReport.RecordCount eq 0))>
	<!---   <cfif auditReport.RecordCount eq 0> --->
    <script>
      alert( 'Sorry the audit report is not available for the selected upload.' );
      window.close();
    </script>
  <cfelse>
    <cfloop query="auditReport">
      <cffile action="read" file="#auditReport.Directory#\#auditReport.Name#" variable="reportContent" >
      #reportContent#
    </cfloop>
  </cfif>

</body>
</html>
</cfoutput>

