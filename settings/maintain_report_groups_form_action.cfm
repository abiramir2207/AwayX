<CFPARAM name="Form.DeleteRecord" default="0">

<cfset RCA = CreateObject("component", "components.user.ReportsCentralAccess").init() />

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Item save data logic --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Check for the presence of data --->
<CFIF Form.DeleteRecord EQ 1>
	<cfset Deleted = RCA.DeleteReportGroup('#Form.Group_ID#') />
	<CFLOCATION URL="maintain_report_groups_form.cfm" ADDTOKEN="No">
<CFABORT>
</CFIF>

<CFIF Form.Group_ID EQ "">
	<cfset Inserted = RCA.InsertReportGroup('#Form.Group_Label#','#Form.Icon_Used#','#Form.Group_Icon#','#request.AccessStructure.User_ID#') />
	<CFLOCATION URL="maintain_report_groups_form.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Update the record	 --->
	<cfset Updated = RCA.UpdateReportGroup('#Form.Group_ID#','#Form.Group_Label#','#Form.Icon_Used#','#Form.Group_Icon#','#request.AccessStructure.User_ID#') />
	<CFLOCATION URL="maintain_report_groups_form.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>
