<cfsilent>
</cfsilent>
<cfdump var="#url#" abort="true">
<!--- Download spreadsheet in memory --->
<cfheader name="Content-Disposition" value="attachment;filename=foo.xlsx">
<cfoutput><cfcontent type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" file="#url.f#" deletefile="no"></cfoutput>
