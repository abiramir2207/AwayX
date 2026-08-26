<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Export Work Requests to Excel</TITLE>
	
<style>
th
{
	background-color: dark red;
	font-color: white;
	font-weight: bold;
	font-size: 12px;
}
</style>
</HEAD>
<body>
	<cfscript>
		compWorkRequest = CreateObject("component","settings.Work_Request.WorkRequest");
		qGetCompRebates = compWorkRequest.search(Request_Desc,Request_Type,App_Area,Client_Priority,Item_Status,Built_To,Created_Since_Date);
	</cfscript>

<cfif qGetCompRebates.recordcount GT 0>
<CFSET nextline=chr(10)>
	
<cfsavecontent variable = "xl">" WR #","WR Description","Application Area","Type","Status","Priority","In Stage ","In Production ","Created By","Created Date","Completed Date","Code Change"
<cfoutput></cfoutput>
<CFOUTPUT QUERY="qGetCompRebates">
<cfsilent>
<cfset CreatedDate =" #DateFormat(Created_Date, 'MM/DD/YYYY')# " />
<cfset CompletedDate =" #DateFormat(Completed_Date, 'MM/DD/YYYY')# " />
<cfif Code_Change EQ 0> 
	<cfset CodeChange = "NO" />
<cfelse>
	<cfset CodeChange = "YES"/>
</cfif>
<cfif len(builtOnProd) EQ 0> 
	<cfset builtOn_Prod = "NO" />
<cfelse>
	<cfset builtOn_Prod = "YES #DateFormat(builtOnProd, 'mm/dd/yyyy')#"/>
</cfif>
<cfif len(builtOnStage) EQ 0> 
	<cfset builtOn_Stage = "NO" />
<cfelse>
	<cfset builtOn_Stage = "YES #DateFormat(builtOnStage, 'mm/dd/yyyy')#"/>
</cfif></cfsilent>
"#BA_Ticket_Number#","#Work_Title#","#App_Area#","#Request_Type#","#Item_Status#","#Client_Priority#","#builtOn_Stage#","#builtOn_Prod#","#Name_First# #Name_Last#","#CreatedDate#","#CompletedDate#","#Code_Change#" </CFOUTPUT></cfsavecontent> 

<CFOUTPUT>
	<cffile action="write" file ="#Application.Doc_Path#\Data_Files\Uploaded\settings\work_request\WorkRequests_#DateFormat(now(), 'mmm-dd-yyyy')#_#timeFormat(now(), 'HHmm')#.csv" output = #xl#>

	<CFLOCATION URL="/common_documents/Data_Files/Uploaded/settings/work_request/WorkRequests_#DateFormat(now(), 'mmm-dd-yyyy')#_#timeFormat(now(), 'HHmm')#.csv" ADDTOKEN="No">
</CFOUTPUT>

		<!---
		<cfset spacer = " ">
	 	<cfcontent type="application/unknown">
		<cfheader name="Content-Disposition" value="attachment;filename=WorkRequests.xls">
		<table border="1">
			<tr>
				<th> Blacksmith number</th>
				<th> Request Title</th>
				<th> Request Type</th>
				<th> Reference Number</th>
				<th> Application Area</th>
				<th> Created Date</th>
				<th> Created By</th>
				<th> Updated By</th>
				<th> Status</th>
				<th> Build</th>
				<th> Time Needed</th>
				<th> Cost</th>
			</tr>
			
			<cfoutput query="qGetCompRebates">
			<tr>
				<td>#BA_Ticket_Number#</td>
				<td>#Work_Title#</td>
				<td>#Request_Type#</td>
				<td>#Client_Reference_Number#</td>
				<td>#App_Area#</td>
				<td>#dateformat(Created_Date)#</td>
				<td>#Created_By#</td>
				<td>#Updated_By#</td>
				<td>#Item_Status#</td>
				<td>#Estimated_Build#</td>
				<td>#Estimated_Time_Required# hours</td>
				<td>#lscurrencyformat(Estimated_Cost)#</td>
			</tr>
			</cfoutput>
		</table>
		--->		
<cfelse>
<!--- No records for XL --->
You do not have any work requests listed for export to Xl
</cfif>

</body>
</html>