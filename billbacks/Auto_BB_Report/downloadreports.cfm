<cfparam name="url.BB_Auto_Report_id" default=0 type="integer">
<cfparam name="variables.CalcBBFile" default=1>
<cfparam name="variables.CalcPBFile" default=1>


<cfset appSettings = application.appSettingsGet>
<cfset oBBReportGet = CreateObject("component","components.Billback.BBAutoReportGet").init() />

<!--- Get pullback information to see if we should show download --->
<cfset qExportPullDetails = application.oBBReportGet.getExportPullDetails(URL.BB_Auto_Report_id) />
<cfset qExportPullLabels = application.oBBReportGet.getExportPullLabels() />
<cfset qExportPullLabelsColumnList = valueList(qExportPullLabels.DB_Col_Name) >
<cfquery name="qExportPullDetails" dbtype="query">
	SELECT #qExportPullLabelsColumnList#
	FROM qExportPullDetails
</cfquery>

<!--- Assume we get passed a legit id --->
<cfif BB_Auto_Report_id>

<!--- Spinner goes here --->
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<CFFLUSH>


<!--- END SPINNER --->

<!---Set file locations --->
<cfset BillbackFileName = "ExportDetails_" & url.BB_Auto_Report_id & ".csv">
<cfset Billbackfilepath = application.Doc_Path & "\Temp_Files\Billback\AutoPayReport\"  & BillbackFileName>
<cfset BillbackDownloadPath = application.HTTPVar & cgi.SERVER_NAME & "/common_documents/Temp_Files/Billback/AutoPayReport/"  & BillbackFileName>
<cfset PullbackFileName = "PullbackDetails_" & url.BB_Auto_Report_id & ".csv">
<cfset Pullbackfilepath = application.Doc_Path & "\Temp_Files\Billback\AutoPayReport\"  & PullbackFileName>
<cfset PullbackDownloadPath = application.HTTPVar & cgi.SERVER_NAME & "/common_documents/Temp_Files/Billback/AutoPayReport/"  & PullbackFileName>

<!--- If we have already calculated these files, don't recalc just show the links --->
<cfif FileExists(Billbackfilepath)>
	<cfset variables.CalcBBFile = 0>
</cfif>

<cfif FileExists(Pullbackfilepath)>
	<cfset variables.CalcPBFile = 0>
</cfif>

<!--- Download records for auto report--->
<Cfif variables.CalcBBFile>
	<cfquery name="qGetExportDetails" datasource="#application.datasource#">
	SELECT 
		BBH.*,
		BBD.*,
		ID.Operator_Id,
		UOM.Unit_Of_Measure_Desc
	FROM BB_Auto_Report_Export_Header H
	INNER JOIN BB_Auto_Program_Pay_Period PP ON
			PP.BB_Auto_Report_id = H.BB_Auto_Report_ID
	INNER JOIN	BB_Auto_Pay_Period_Billback PBB ON
			PP.BB_Auto_Program_Pay_Period_ID = PBB.BB_Auto_Program_Pay_Period_ID
	INNER JOIN BB_Auto_Report_Export_BB_Header BBH
		ON H.Export_Header_Id = BBH.Export_Header_Id AND
		BBH.BillBack_Id = PBB.BillBack_Id
	INNER JOIN BB_Auto_Report_Export_BB_Detail BBD
		ON H.Export_Header_Id = BBD.Export_Header_Id AND
			BBD.BB_Header_Id = BBH.BB_Header_Id
	INNER JOIN Invoice_Detail ID ON
		ID.Invoice_Detail_Id = BBD.Invoice_Detail_id
	LEFT JOIN Units_of_Measure UOM ON
			UOM.Unit_Of_Measure_ID = BBD.Discount_UOM
	WHERE H.BB_Auto_Report_ID = <cfqueryparam value="#url.BB_Auto_Report_id#" cfsqltype="CF_sql_integer">
	ORDER BY BB_code,Shr_Ship_To,Shared_Invoice_Number,BBD.Item
	
	</cfquery>
	
	<!--- Queries for dynamic headers, pulled from autoreport/index.cfm adn BB_Auto_report_Export_Viewr.cfm --->
	<cfset qExportBBLabels = oBBReportGet.getExportBBLabels() />
	<cfset qExportBBLabelsColumnList = valueList(qExportBBLabels.DB_Col_Name) >
	
	<!--- Create list of columns to pull data in the order desired --->
	<cfset BBcolList = qExportBBLabelsColumnList>
	
	<cfquery name="qExportBBDetails" dbtype="query">
		SELECT #qExportBBLabelsColumnList#,Unit_Of_Measure_Desc
		FROM qGetExportDetails
	</cfquery>
	
	
	<!--- Write out the content to save to the file -- will display as written so be careful of white space --->
	<!--- We have dynamically created header names --->
<cfsavecontent variable="ExportDetails"><cfoutput><cfloop list="#BBcolList#" index="i"><cfsilent><cfquery name="BBheaderLabel" dbtype="query">SELECT custom_col_name, default_col_name, db_col_name	FROM qExportBBLabels WHERE db_col_name LIKE '%#ucase(i)#%'</cfquery></cfsilent><cfif BBheaderLabel.custom_col_name NEQ "">#trim(BBheaderLabel.custom_col_name)#<cfelseif BBheaderLabel.default_col_name NEQ "">#trim(BBheaderLabel.default_col_name)#<cfelse>#trim(BBheaderLabel.db_col_name)#</cfif><CFIF ucase(i) NEQ ucase(ListLast(BBcolList))>,<CFELSE>#chr(10)#</CFIF></cfloop></cfoutput>
<cfoutput query="qExportBBDetails"><cfloop list="#BBcolList#" index="i"><cfif i EQ "Discount_Offered">#trim(evaluate("#i#"))# #Unit_Of_Measure_Desc#<cfelseif i EQ "Invoice_date"><cfsilent><cfset invDate = evaluate("#i#")></cfsilent>#trim(dateformat(invDate, 'mm/dd/yyyy'))#<cfelse>#replace(trim(evaluate("#i#")),',','','all' )#</cfif><CFIF ucase(i) NEQ ucase(ListLast(BBcolList))>,<CFELSE>#chr(10)#</CFIF></cfloop>
</cfoutput></cfsavecontent> 
	
	
	<!---Write file to server --->
		<CFFILE action = "write"
		file="#Billbackfilepath#"
		output="#ExportDetails#">
	
<!---  variables.CalcBBFile --->
</Cfif>

<!--- Pullback information --->

<cfif qExportPullDetails.recordcount gt 0>
<!--- download for pullbacks ---> 
<Cfif variables.CalcPBFile>
	<cfquery name="qGetExportPullDetails" datasource="#application.datasource#">
	SELECT
		PH.*,
		PD.*
	FROM BB_Auto_Report_Export_Header H
	INNER JOIN BB_Auto_Report_Export_PullBack_Header PH
		ON PH.Export_Header_Id = H.Export_Header_Id
	INNER JOIN BB_Auto_Report_Export_PullBack_Detail PD
		ON PH.Export_Header_Id = PD.Export_Header_Id AND
		PH.PullBack_Header_Id = PD.PullBack_Header_Id
	INNER JOIN	BB_Auto_Pay_Period_Billback PBB ON
		PH.Dis_Corp_BillBack_Id = PBB.BillBack_Id
	WHERE H.BB_Auto_Report_ID = <cfqueryparam value="#url.BB_Auto_Report_id#" cfsqltype="CF_sql_integer">
	ORDER BY Dis_Corp_BB_Code,Shr_Ship_To,PullBack_BB_Code,Item
	</cfquery>
	
	<cfset qExportPullLabels = oBBReportGet.getExportPullLabels() />
	<cfset qExportPullLabelsColumnList = valueList(qExportPullLabels.DB_Col_Name) >
	
	<!--- Create list of columns to pull data in the order desired --->
	<cfset PullColList = qExportPullLabelsColumnList>
	
	<cfquery name="qExportPullDetails" dbtype="query">
	SELECT #qExportPullLabelsColumnList#
	FROM qGetExportPullDetails
	</cfquery>
	
	<!--- Downloadable pullbacks --->
	<!--- You need to be careful about whitespace in this file --->
<cfsavecontent variable="PullbackDetails"><cfoutput><cfloop list="#PullColList#" index="i"><cfsilent><cfquery name="PullheaderLabel" dbtype="query">SELECT custom_col_name, default_col_name, db_col_name FROM qExportPullLabels WHERE db_col_name LIKE '%#ucase(i)#%'</cfquery></cfsilent><cfif PullheaderLabel.custom_col_name NEQ "">#trim(PullheaderLabel.custom_col_name)#<cfelseif PullheaderLabel.default_col_name NEQ "">#trim(PullheaderLabel.default_col_name)#<cfelse>#trim(PullheaderLabel.db_col_name)#</cfif><CFIF ucase(i) NEQ ucase(ListLast(PullColList))>,<CFELSE>#chr(10)#</CFIF></cfloop></cfoutput>
<cfoutput query="qExportPullDetails"><cfloop list="#PullColList#" index="i">#replace(trim(evaluate("#i#")),',','','all' )#<CFIF ucase(i) NEQ ucase(ListLast(PullColList))>,<CFELSE>#chr(10)#</CFIF></cfloop>
</cfoutput></cfsavecontent> 
	
	
	<!---Write file to server --->
		<CFFILE action = "write"
		file="#Pullbackfilepath#"
		output="#PullbackDetails#">
	
<!---variables.CalcPBFile --->
</Cfif>
<!--- If there are pullbacks --->
</cfif>
<!--- Get rid of spinner --->
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<!--- Show links to records --->

<table width = "380" cellpadding="2" cellspacing="0">
<tr bgcolor="orange"><td><strong>Downloadable Reports</strong></td></tr>
<tr><td><i>Please note that these are .txt files. The files may be too large to be displayed in XL and may take significant time to download.</i></td></tr>
<tr><td><a href="#" onclick="downloadDoc('<cfoutput>#application.HTTPVar##CGI.SERVER_NAME#</cfoutput>/scheduled/getDocument.cfm?filePath=<cfoutput>/common_documents/Temp_Files/Billback/AutoPayReport/#BillbackFileName#</cfoutput>');">Billback Auto Pay report</a></td></tr>
<cfif qExportPullDetails.recordcount gt 0><tr><td><a href="<cfoutput>#PullbackDownloadPath#</cfoutput>">Pullback Auto Pay report</a></td></tr></cfif>
</table>


<!--- No data --->
<cfelse>
	There was not a valid auto report associated with this link. 
</cfif>
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';

function downloadDoc(documentLocation)
{
	setInterval(function(){window.close},1);
	document.location = documentLocation;
	window.close;
}
</SCRIPT>
