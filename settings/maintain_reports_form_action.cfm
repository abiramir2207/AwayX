<!---<cfdump var="#form#">--->

<cfset RCA = CreateObject("component", "components.user.ReportsCentralAccess").init() />


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Item save data logic --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Check for the presence of data --->
	
<CFIF len(Form.Report_ID) EQ 0>
	<cfset Inserted = RCA.InsertReport('#Form.Report_Name#','#Form.Report_Desc#','#Form.Report_Author#','#Form.Report_URL#','#Form.Report_URL_Jscript#','#Form.Report_URL_Options#',#Form.Report_Group#,#Form.Active#,#Form.Level_Code#,'#request.AccessStructure.User_ID#') />
	
	<CFLOCATION URL="maintain_reports_form.cfm" ADDTOKEN="No"> --->
	<CFABORT>
<CFELSE>
<!--- Update the record	 --->
			
	<cfset Updated = RCA.UpdateReport('#Form.Report_ID#','#Form.Report_Name#','#Form.Report_Desc#','#Form.Report_Author#','#Form.Report_URL#','#Form.Report_URL_Jscript#','#Form.Report_URL_Options#',#Form.Report_Group#,#Form.Active#,#Form.Level_Code#,'#request.AccessStructure.User_ID#') />
	<CFLOCATION URL="maintain_reports_form.cfm" ADDTOKEN="No">
	<CFABORT>	
</CFIF>
