<CFSET VOL_OUTPUT_PAGE_TITLE = "Volume Summary Report" >
<cfif rReportType EQ "c">
	<cfsetting enablecfoutputonly="yes" showdebugoutput="no">
</cfif>
<!--- retrieve the BB_Tolerance_TET setting to determine which date we should run aganist for the volume --->
<!--- default - invoicedate --->
<CFSET GF_objHandle = CreateObject("component", "components.general.General_Functions")>
<!---Trade Eligibility Toggle--->
<cfset TET = GF_objHandle.getBBToTET() >
<!--- file type --->
<cfset srNotCSV=true>
<cfif rReportType EQ "c">
	<cfset srNotCSV=false>
</cfif>
<cfif rReportOutputType EQ "direct" >
	<cfif rReportType EQ "e">
		<cfcontent type="application/unknown">
		<cfheader name="Content-Disposition" value="attachment;filename=invoiceVolumeReport.xls">
	<cfelseif rReportType EQ "c">
		<cfcontent type="application/unknown">
		<cfheader name="Content-Disposition" value="attachment;filename=invoiceVolumeReport.csv"> 
	</cfif>
</cfif>
<!---- initialization --->
<CFPARAM NAME="currentRecordValue" DEFAULT="">
<cfif srNotCSV is false>
<cfoutput>#VOL_OUTPUT_PAGE_TITLE#</cfoutput>
<cfelse>
	<html>
	<head>
		<title><cfoutput>#VOL_OUTPUT_PAGE_TITLE#</cfoutput></title>
	</head>
</cfif>
<cfif srNotCSV>
	<body>
</cfif>
<cfif Not isDefined("mail_flag") and rReportType EQ "h">
	<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
		 <br><br><br>
		 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
		 <br><br><br>
	</SPAN>
	<CFFLUSH>
</cfif>
	<!----- determine the title of output based on the UOM, 1 - cases, 2 - pound---->
	<cfif isDefined("Form.Global_UOM") and Form.Global_UOM EQ 1 >
		<cfset invoice_report_title = "Total_Cases_Invoiced" >
	</cfif>
	<cfif isDefined("Form.Global_UOM") and Form.Global_UOM EQ 2 >
		<cfset invoice_report_title = "Total_Pounds_Invoiced" >
	</cfif>
	<cfif isDefined("Form.Global_UOM") and Form.Global_UOM EQ 3 >
		<cfset invoice_report_title = "Total_Sales" >
	</cfif>
	<cfinclude TEMPLATE="getFiscalDate.cfm">
	<cfset customer_ship_to_struct =  StructNew() >
	<cfset timespanArray = ArrayNew(1)>
	<cfset count = 1 >
	<!--- add year ago for each item --->
	<CFLOOP From = "1" To = "#ListLen(form.history_period)#" INDEX = "Counter">
		<cfset timespanArray[count] = trim(ListGetAt(form.history_period, Counter)) >
		<cfset timespanArray[count+1] = trim(ListGetAt(form.history_period, Counter)) & "_year_ago" >
		<cfset count = count + 2 >
 	</cfloop>
	<cfset timespanArray[count] = "Two_Fiscal_Year" >
	<cfset timespanList = ArrayToList(timespanArray, ',')> 
	<!---store output data for each time span into structure array variable--->
	<!--- hold btoh pound and case both in the structure --->
	<cfscript>
		QueryOutputStuct = StructNew();
	</cfscript>
	<!--- <cfloop INDEX="i" FROM="1" TO="1" STEP="1">  --->
	<cfloop INDEX="i" FROM="1" TO="#ArrayLen(timespanArray)#" STEP="1"> 
		<cfset QueryOutputHistory = StructNew() > 
		<!---<cfset QueryOutputArray = ArrayNew(1)> --->
		<cfset time_span = timespanArray[i]>
		<cfinclude TEMPLATE="reportInvoiceQuery.cfm">
		<cfloop QUERY="TheQuery"> 
			<CFSCRIPT>
			// compose customer's ship to structure
				if (Not StructKeyExists( customer_ship_to_struct, trim(Name))) 
				{
					 customer_ship_to_struct[trim(Name)] = trim(Customer_Ship_To);
				}
				if (Not StructKeyExists( QueryOutputHistory, trim(Zone_Name))) 
				{   
					QueryOutputHistory[trim(Zone_Name)] = StructNew();
					QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)] = StructNew();
					QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)] = StructNew();
					QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)]["Total_Pounds_Invoiced"] = total_pounds_invoiced;
					QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)]["Total_Cases_Invoiced"] = total_cases_invoiced;
					QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)]["Total_Sales"] = total_sales;
				}
				
				else 
				{ //if current zone is existing, check for the region
					if (Not StructKeyExists( QueryOutputHistory[trim(Zone_Name)], trim(Region_Name))) 
					{
						QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)] = StructNew();
						QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)] = StructNew();
						QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)]["Total_Pounds_Invoiced"] = total_pounds_invoiced;
						QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)]["Total_Cases_Invoiced"] = total_cases_invoiced;
						QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)]["Total_Sales"] = total_sales;
					}
					else
					{
						//zone and region are both existing, check for customer 
						if (Not StructKeyExists( QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)], trim(Name))) 
						{ 
							QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)] = StructNew();
							QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)]["Total_Pounds_Invoiced"] = total_pounds_invoiced;
							QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)]["Total_Cases_Invoiced"] = total_cases_invoiced;
							QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)]["Total_Sales"] = total_sales;
						}
						else
						{
							QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)]["Total_Pounds_Invoiced"] = total_pounds_invoiced;
							QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)]["Total_Cases_Invoiced"] = total_cases_invoiced;
							QueryOutputHistory[trim(Zone_Name)][trim(Region_Name)][trim(Name)]["Total_Sales"] = total_sales;
						}
					}
				} 
			</CFSCRIPT> 
		</cfloop>
		<cfscript>
			StructInsert(QueryOutputStuct, timespanArray[i], QueryOutputHistory);
		</cfscript> 
	</cfloop>
	<!--- <H1>query is over!</H1> --->
<!---<cfdump var = #Fiscal_Period_Output#>--->
	<cfif Not isDefined("mail_flag") and rReportType EQ "h">
		<SCRIPT LANGUAGE="JavaScript">
			document.all.PleaseWaitMessage.style.display='none';
		</SCRIPT>
	</cfif>
	<!---- invoice --->
	<cfif Not isDefined("mail_flag")>
		<cfflush>
	</cfif> 
	<cfinclude TEMPLATE="invoice_output.cfm" >
	<cfif Not isDefined("mail_flag")>
		<cfflush>
	</cfif>
	<cfif isDefined("mail_flag")>
		<CFSAVECONTENT VARIABLE="reportOutput">
			<cfinclude TEMPLATE="invoice_output.cfm">
		</CFSAVECONTENT>
	<cfelse>
	</cfif>
<cfif srNotCSV>
	</body>
	</html>
</cfif>
<cfif isDefined("mail_flag")  >
	<!---<cfoutput>#reportOutput#</cfoutput>--->
	<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">					
	<!--- Build file name --->
	<CFSET filename_email	=	"#datetimestamp#_#gettickcount()#">
	<cfswitch expression="#rReportType#">
		<cfcase value="h">
			<cfset file_extension = "html">
		</cfcase>
		<cfcase value="e">
			<cfset file_extension = "xls">
		</cfcase>
		<cfcase value="c">
			<cfset file_extension = "csv">
		</cfcase>
		<cfdefaultcase>
			<cfset file_extension = "html">
		</cfdefaultcase>
	</cfswitch>
	<CFSET HTML_File_Path = "\Temp_Files\search_screens\invoice\utilities\htmlfiles\#filename_email#." & #trim(file_extension)#>
	<cfset TMP_HTML_File_Path = HTML_File_Path>
	<CFIF NOT FileExists("#Application.Doc_Path##HTML_File_Path#")>
		<CFSET HTML_File_Path = Application.Doc_Path & HTML_File_Path>
		<cffile action="write" file="#HTML_File_Path#" output="#reportOutput#">
	</cfif>
	<!--- send email out --->
	<cfset completePath = application.HTTPVar & CGI.HTTP_HOST &  #Application.Doc_Mapping# & TMP_HTML_File_Path>
	<cfoutput>
		<cfif mail_flag EQ 1 >
			<CF_EMAILWRAPPER 
				TO			=	"#FORM.Broker_Address#"
		        FROM		=	"#request.AccessStructure.User_Email#"
		        SUBJECT		=	"Invoice Volume Summary Report - Output email notification"
				TYPE		=	"html" 
				messagetype="1" 
				generatedby="3" 
				apparea="8" 
				userid="#request.AccessStructure.user_id#">
			<!--- use crypted url --->
			<CFSET Encrypt_Document_Type 	= "Invoice_Report">
			<!--- <CFSET Encrypt_Document_ID 		= #completePath# >  --->
			<CFSET Encrypt_Document_ID 		= "/Manufacturers/home_new.cfm?pageToOpen=#URLEncodedFormat(completePath)#">
			<CFINCLUDE TEMPLATE="/Common_Files/Encrypted_url.cfm">
			<CFPARAM NAME="Encrypted_Url" 	DEFAULT="">
			<TABLE WIDTH="100%">
				<TR><TD>Your <B>Invoice Volume Reports</B> is ready!</TD></TR>
				<TR><TD>To access it, please click the link below. You will be prompted for your login and password and then the report will be displayed.</TD></TR>
				<TR><TD>Click here to view your report:</TD></TR>
				<TR><TD><A HREF="#Encrypted_Url#"> #completePath# </A></TD></TR>
				<TR><TD><BR></TD></TR>
				<!--- <TR><TD>#reportOutput#</TD></TR> --->
			</TABLE>
				<!--- <cfmailparam file = "#Invoice_FN#"> --->
				<!---<cf_EmailWrapperParam file = "#Invoice_FN#" store="yes"> --->
		<!--- </CFMAIL> --->
			</CF_EMAILWRAPPER>
		</cfif>
	</cfoutput>
<cfelse>
	<cfoutput></cfoutput>
</cfif>

