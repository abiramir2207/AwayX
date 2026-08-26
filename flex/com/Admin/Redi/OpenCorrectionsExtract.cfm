<cfsilent>
<cfparam name="url.Display" default="1">

	<cfscript>
		dao = CreateObject("component","mvc.Models.Admin.Redi.RediDAO");
		q = dao.getReportData();
		id = datepart("yyyy",now()) & datepart("m",now()) & datepart("d",now()) & '_' & datePart("h",now()) & datePart("n",now()) & datePart("s",now());
	    //Use an absolute path for the files.
	    fileName = "OpenRediCorrections_" & id & ".csv";
	    Winfilepath = application.Doc_Path & "\Temp_Files\Redi\" & fileName;
		DownloadFilePath =  "common_documents/Temp_Files/Redi/" & fileName;
	    sCols = '';
	    s ="Control Id,Upload Id,Source ##,Source,Invoice ##,Inv Date,PO ##,PO Date,Error Message,Partner Data,Manufacturer Data";
	    s = s & chr(10);
	</cfscript> 

<cfsavecontent variable="ResultContent"><cfoutput>#s#</cfoutput>
<cfoutput query="q">#q.rediCorrectionHeaderId#,#q.uploadId#,#q.sourceTypeDesc#,#q.sourceType#,#q.invoiceNumber#,#q.invoiceDate#,#q.poNum#,#q.PO_Date#,#q.errorMessage#,#Replace('#q.errAliasId# #q.errAliasDesc# #q.errAliasDesc1# #q.errAliasDesc2# #q.errAliasDesc3# #q.errAliasDesc4#',',','','ALL')#,#Replace('#q.errId# #q.errDesc# #q.errDesc1# #q.errDesc2# #q.errDesc3# #q.errDesc4#',',','','ALL')##chr(10)#</cfoutput>
</cfsavecontent>

	<CFFILE action = "write"
			file="#Winfilepath#"
			output="#ResultContent#">
</cfsilent>
<cfif url.Display eq 1>
	<html>
	<head>
	<title>Open Redistribution Corrections Report</title>
	</head>
	<!--- Spinner goes here --->
	<cfset PW_DoNotCFFLUSH = 1/>
	<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
	 <br><br><br>
	 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
	 <br><br><br>
	</SPAN>
	
		<cfheader name="Content-Disposition" value="attachment; filename=#fileName#" >
		<cfcontent type="application/vnd.ms-excel" file="#Winfilepath#">
	
	<!--- Get rid of spinner --->
	<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
	</SCRIPT>
</body>
</html>
</cfif>
