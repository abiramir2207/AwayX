<!--- url.Disp = which page to download --->
<!--- url.Del = whether to include deleted records --->
<!--- url.ReportID = the report for details --->
<cfparam name="url.ReportID" default="0">
<cfparam name="url.ReportLevel" type="integer" default="0">
<cfparam name="url.Billback_ID"  default="" type="String">
	
<title>Auto Billback Reports</title>

<!--- Spinner goes here --->
<cfset PW_DoNotCFFLUSH = 1/>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<!---<CFFLUSH>--->

	<cfset Report_ID = url.ReportID>
	<cfset application.oController.getObject(path="components.Billback.BBAutoReportGet",name="BBReportGet",bReload= 1).init() />
	<!--- Call the component that will do execute the query and write it to a file --->
<!---	<Cfif url.Disp EQ "detail">--->
	<!--- If it is display --->
	<!--- Do the processing and writing inside a silent tag --->

	<cfset qGetAutoPayPullbackExport = application.oBBReportGet.getAutoPayPullbackExportDetails(url.ReportID, url.ReportLevel, url.Billback_ID)>
		<cfscript> 
	    //Use an absolute path for the files.
	    FileName = "AutoPayPullbackReport_" & Report_ID & ".csv";
	    Billbackfilepath = application.Doc_Path & "\Temp_Files\Billback\AutoPayReport\" & FileName; 
	    headerRow ="Batch ID,Batch Title,Auto Pay Program,Auto Pay Program Title,Auto Pay Program Template,Auto PayBB,Auto PayBB Title,Auto Pay BB $,Pullback Applied Amount,Auto Pay BB Final $,PullBack Contract Number,PullBack Contract Title,";
	    headerRow = headerRow & "PullBack Contract Template,Operator ID,BSA Operator ID,Operator Name,Customer ID, Customer Name,Recap BB,Recap BB Title,Group Name,Item Number,Item Description,Recap BB Start Date,Recap BB End Date,Date Approved,";
	    headerRow = headerRow & "Recap Rate,Recap Rate/Case,Alt Recap Rate,Alt Recap Rate/Case,Recap Amount,Recap $ Raw,Recap Cases,Calculated Recap Invoice Dollars,Recap Pounds";
	 	s = headerRow & chr(10);
	 	price = 0;
	 	if(qGetAutoPayPullbackExport.Recap_Rate_Percent_num > 0){
	 		price = 100 / qGetAutoPayPullbackExport.Recap_Rate_Percent_num * qGetAutoPayPullbackExport.Recap_Rate_Per_Case;
	 	}
	</cfscript> 
<!--- <cfabort>--->
	<!--- Write the two sheets to a single file ---> 
	<cfsavecontent variable="ResultContent"><cfoutput>#s#</cfoutput>
			<cfoutput query="qGetAutoPayPullbackExport">#qGetAutoPayPullbackExport.BB_Auto_Report_ID#,#qGetAutoPayPullbackExport.Report_Title#,#qGetAutoPayPullbackExport.Auto_Pay_Program#,#qGetAutoPayPullbackExport.Auto_Pay_Program_Title#,#qGetAutoPayPullbackExport.Auto_Pay_Program_Template#,#qGetAutoPayPullbackExport.Auto_PayBB#,#qGetAutoPayPullbackExport.Auto_PayBB_Title#,#qGetAutoPayPullbackExport.Auto_Pay_BB_$#,#qGetAutoPayPullbackExport.Pullback_Applied_Amount#,#qGetAutoPayPullbackExport.Auto_Pay_BB_Final_$#,#qGetAutoPayPullbackExport.PullBack_Contract_Number#,#qGetAutoPayPullbackExport.PullBack_Contract_Title#,#qGetAutoPayPullbackExport.PullBack_Contract_Template#,="#qGetAutoPayPullbackExport.Operator_ID#",="#qGetAutoPayPullbackExport.BSA_Operator_ID#",#qGetAutoPayPullbackExport.Operator_Name#,="#qGetAutoPayPullbackExport.shr_ship_To#",="#qGetAutoPayPullbackExport.SHR_Ship_To_Name#",#qGetAutoPayPullbackExport.Recap_BB#,#qGetAutoPayPullbackExport.Recap_BB_Title#,#qGetAutoPayPullbackExport.Group_Name#,="#qGetAutoPayPullbackExport.Item_Number#",#qGetAutoPayPullbackExport.Item_Description#,#qGetAutoPayPullbackExport.Recap_BB_Start_Date#,#qGetAutoPayPullbackExport.Recap_BB_End_Date#,#qGetAutoPayPullbackExport.Date_Approved#,#qGetAutoPayPullbackExport.Recap_Rate_Percent#,#qGetAutoPayPullbackExport.Recap_Rate_Per_Case#,#qGetAutoPayPullbackExport.Alt_Recap_Rate#,#qGetAutoPayPullbackExport.Alt_Recap_Rate_Per_Case#,#qGetAutoPayPullbackExport.Pullback_Amount#,#qGetAutoPayPullbackExport.Pullback_Amount_Raw#,#qGetAutoPayPullbackExport.Recap_Cases#,#Calculated_Pullback_Invoice_Dollars#,#qGetAutoPayPullbackExport.Recap_Lb##chr(10)#</cfoutput>
	</cfsavecontent>
	<!---,#qGetAutoPayPullbackExport.product_BB_volume_LB#--->
	<CFFILE action = "write" file="#Billbackfilepath#" output="#stripCR(ResultContent)#">
	
<!---	<cfheader name="Content-Disposition" value="attachment; filename=AutoPayReport_#Report_ID#.csv" >
	<cfcontent type="application/vnd.ms-excel" file="#Billbackfilepath#">--->
	
	<cfheader name="Content-Disposition" value="attachment; filename=#FileName#" >
	<cfcontent type="application/vnd.ms-excel" file="#Billbackfilepath#">

	
<!---	</cfif>
	--->
	
<!--- Get rid of spinner --->
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';

function downloadDoc(documentLocation)
{
	setInterval(function(){window.close},1);
	document.location = documentLocation;
	window.close;
}
</SCRIPT>
