<cfparam name="url.contract_number" default="0">

<cfset qGetCompetitiveDataHistory = CreateObject("component","components.programs.bid_request.CompetitiveDataManager").getProgramCompetitiveDownloadData(url.contract_number) />

<cfset pathFileName = "#Application.Doc_Path#\Temp_Files\contracts\" & url.contract_number & ".csv" />

<cfset fileOutput= CreateObject("java","java.lang.StringBuffer").init() >

<!--- header row --->
<cfset fileOutput.append("Program_Number" & ",")>
<cfset fileOutput.append("Version" & ",")>
<cfset fileOutput.append("Item" & ",")>
<cfset fileOutput.append("Description" & ",")>
<cfset fileOutput.append("Discount" & ",")>
<cfset fileOutput.append("Component" & ",")>
<cfset fileOutput.append("Rate" & ",")>
<cfset fileOutput.append("Rate_UOM" & ",")>
<cfset fileOutput.append("Won" & ",")>
<cfset fileOutput.append("Won_By" & ",")>
<cfset fileOutput.append("Won_Rate" & ",")>
<cfset fileOutput.append("Won_Uom" & ",")>
<cfset fileOutput.append("Delivery_Type" & ",")>
<cfset fileOutput.append("Category" & ",")>
<cfset fileOutput.append("Package" & ",")>
<cfset fileOutput.append("Shared" & ",")>
<cfset fileOutput.append("Incremental" & ",")>
<cfset fileOutput.append("Source" & ",")>
<cfset fileOutput.append("Source_Type" & ",")>
<cfset fileOutput.append("Date_Source_Received" & ",")>
<cfset fileOutput.append("Opportunity_Volume_CS" & ",")>
<cfset fileOutput.append("Opportunity_Volume_LB" & ",")>
<cfset fileOutput.append("Approval_Date")>
<cfset fileOutput.append(Chr(13) & Chr(10))>


<cfoutput query="qGetCompetitiveDataHistory">
	<cfset fileOutput.append(trim(Program_Number) & ",")>
	<cfset fileOutput.append(trim(Version) & ",")>
	<cfset fileOutput.append(trim(Item) & ",")>
	<cfset fileOutput.append(trim(Description) & ",")>
	<cfset fileOutput.append(trim(Discount) & ",")>
	<cfset fileOutput.append(trim(Component) & ",")>
	<cfset fileOutput.append(trim(Rate) & ",")>
	<cfset fileOutput.append(trim(Rate_UOM) & ",")>
	<cfset fileOutput.append(trim(Won) & ",")>
	<cfset fileOutput.append(trim(Won_By) & ",")>
	<cfset fileOutput.append(trim(Won_Rate) & ",")>
	<cfset fileOutput.append(trim(Won_Uom) & ",")>
	<cfset fileOutput.append(trim(Delivery_Type) & ",")>
	<cfset fileOutput.append(trim(Category) & ",")>
	<cfset fileOutput.append(trim(Package) & ",")>
	<cfset fileOutput.append(trim(Shared) & ",")>
	<cfset fileOutput.append(trim(Incremental) & ",")>
	<cfset fileOutput.append(trim(Source) & ",")>
	<cfset fileOutput.append(trim(Source_Type) & ",")>
	<cfset fileOutput.append(trim(Date_Source_Received) & ",")>
	<cfset fileOutput.append(trim(Opportunity_Volume_CS) & ",")>
	<cfset fileOutput.append(trim(Opportunity_Volume_LB) & ",")>
	<cfset fileOutput.append(trim(Approval_Date))>
	<cfset fileOutput.append(Chr(13) & Chr(10))>
</cfoutput>

<cffile action="write" file="#pathFileName#" output="#fileOutput.ToString()#" nameconflict="overwrite" />

<cfheader name="Content-Disposition" value="attachment;filename=#url.contract_number#.csv"  />
<cfcontent type="application/csv" file="#pathFileName#"  />

