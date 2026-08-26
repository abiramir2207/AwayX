<!-------------------------Program Summary Report--------------------------------------------------->
<!--------Set defaults------------->
<CFPARAM NAME="Form.rStatus" 		DEFAULT="-1">
<!------<CFPARAM NAME="Form.rProgramTypes" 	DEFAULT="-1">----->
<CFPARAM NAME="Form.rGenericTypes" 	DEFAULT="-1">


<CFPARAM NAME="Form.rTypeGroups" 	DEFAULT="">
<CFPARAM NAME="Form.rQBrands" 		DEFAULT="">
<CFPARAM NAME="Form.rTypeCodes" 	DEFAULT="">
<CFPARAM NAME="Form.rBrands" 		DEFAULT="">

<CFPARAM NAME="Form.rFilterItem" 	DEFAULT="">
<CFPARAM NAME="Form.rFilterCust" 	DEFAULT="">

<CFPARAM NAME="Form.rFamilys" 		DEFAULT="">
<CFPARAM NAME="Form.rBuyingGroups" 	DEFAULT="">
<CFPARAM NAME="Form.rDistributors" 	DEFAULT="">

<cfparam name="Form.reportFormatType" DEFAULT="">
<CFPARAM NAME="Form.rSortBy" 		DEFAULT="">
<cfparam name="Form.rMarginOption" 	DEFAULT="">
<cfparam name="Form.rMarginValue1" 	default="">
<cfparam name="Form.rMarginValue2" 	default="">


	<cfif Len(Trim(Form.rStatus)) EQ "">
		<CFSET Form.rStatus = "-1">
	</cfif>
	
	<!------<cfif Len(Trim(Form.rProgramTypes)) EQ "">
		<CFSET Form.rProgramTypes = "-1">
	</cfif>----->
	<cfif Len(Trim(Form.rGenericTypes)) EQ "">
		<CFSET Form.rGenericTypes = "-1">
	</cfif>

	<!-------------------------------Validation-------------------->
	<cfset allClear=true>
	
	<cfset bErr=false>
	<cfset sErr="">	
	<cfswitch expression="#Form.rFamilys#">
		<cfcase value="family">
			<cfif Form.rFamilys EQ "">
				<cfset bErr=true>
				<cfset sErr="#sErr#Family is to be selected<br>">
			</cfif>
		</cfcase>
		<cfcase value="buyinggroup">
			<cfif Form.rBuyingGroups EQ "">
				<cfset bErr=true>
				<cfset sErr="#sErr#Buying Group is to be selected<br>">
			</cfif>
		</cfcase>
		<cfcase value="distributor">
			<cfif Form.rDistributors EQ "">
				<cfset bErr=true>
				<cfset sErr="#sErr##application.returned_customer_setting.distributor_label_singular# is to be selected<br>">
			</cfif>
		</cfcase>
	</cfswitch>
	
	<cfif bErr>
		<cfset allClear=false>
		<!-----<cfset writeToErrorMessage(sErr,"error_rFilterItems")>------->
	</cfif>
	
	<cfset bErr=false>
	<!-----<cfset sErr="">------->
	<cfswitch expression="#Form.rFilterItem#">
		<cfcase value="typegroup">
			<cfif Form.rTypeGroups EQ "">
				<cfset bErr=true>
				<cfset sErr="#sErr#Type Code is to be selected<br>">
			</cfif>
		</cfcase>
		<cfcase value="qbrand">
			<cfif Form.rQBrands EQ "">
				<cfset bErr=true>
				<cfset sErr="#sErr#Q Brand is to be selected<br>">
			</cfif>
		</cfcase>						
		<cfcase value="typecode">
			<cfif Form.rTypeCodes EQ "">
				<cfset bErr=true>
				<cfset sErr="#sErr#Type Code is to be selected<br>">
			</cfif>
		</cfcase>
		<cfcase value="brand">
			<cfif Form.rBrands EQ "">
				<cfset bErr=true>
				<cfset sErr="#sErr#Brand is to be selected<br>">
			</cfif>
		</cfcase>
	</cfswitch>
	
	<cfif bErr>
		<cfset allClear=false>
		<!-----<cfset writeToErrorMessage(sErr,"error_rFilterItems")>------->
	</cfif>
	<!-------------------------------End Validation-------------------->
	
	<cfif NOT allClear>
		<cfoutput>#sErr#</cfoutput>
		<cfabort>
	</cfif>
	
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!----------------------- Building query starts here ------------------------------------------------------>
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	
	<CFSET rStatus			=	Form.rStatus>
	<!------<CFSET rProgramTypes	=	Form.rProgramTypes>----->
	<CFSET rGenericTypes	=	Form.rGenericTypes>	
	
	<CFSET rFilterItem		=	Form.rFilterItem>

	<CFSET rTypeGroups		=	Form.rTypeGroups>
	<CFSET rQBrands			=	Form.rQBrands>
	<CFSET rTypeCodes		=	Form.rTypeCodes>
	<CFSET rBrands			=	Form.rBrands>
	
	<CFSET rFilterItemValue	=Evaluate("r#rFilterItem#s")>
	
	<CFSET rFilterCust		=	Form.rFilterCust>
	
	<CFSET rFamilys			=	Form.rFamilys>
	<CFSET rBuyingGroups	=	Form.rBuyingGroups>
	<CFSET rDistributors	=	Form.rDistributors>
	
	<CFSET rFilterCustValue	=	Evaluate("r#rFilterCust#s")>
	
	<CFSET rReportOutputType=	Form.rReportOutputType>
	<CFSET rSortBy			=	Form.rSortBy>
	<CFSET reportFormatType	=	ListFindNoCase(reportFormatTypeIDs,Form.reportFormatType,",")>
	
	<CFSET rMarginOption	=	Form.rMarginOption>
	<CFSET rMarginValue1	=	Form.rMarginValue1>
	<CFSET rMarginValue2	=	Form.rMarginValue2>
	
	
	
	
	
	<cfif (rReportOutputType EQ "h")>
		<CFOUTPUT><SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
		<br><br><br>
		<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
		<br><br><br>
		</SPAN>
		<SCRIPT LANGUAGE="JavaScript">
			document.body.onload=new Function ("hideWaitMessage();");
			function hideWaitMessage()
			{
				document.all.PleaseWaitMessage.style.display="none";
			}
		</SCRIPT></CFOUTPUT>
		<cfflush>		
	</cfif>
	
	
	<CFSET reportType=Form.rReportType>


	<CFINCLUDE TEMPLATE="#schGenerateMarginProduct#">
	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Show the Report
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	<cfif IsDefined("srqueryname")>		
		<cfset srNotCSV=true>
		<cfif rReportOutputType EQ "e">
			<cfcontent type="application/unknown">
			<cfheader name="Content-Disposition" value="attachment;filename=productMarginAnalysisReport.xls">
		<cfelseif rReportOutputType EQ "c">
			<cfcontent type="application/unknown">
			<cfheader name="Content-Disposition" value="attachment;filename=productMarginAnalysisReport.csv">
			<cfset srNotCSV=false>
		</cfif>
		
		
		<CFINCLUDE TEMPLATE="#displayProductMarginPage#">
		
		<cfif srQuery.recordCount GT 0>
			<cfif rReportOutputType EQ "h">	
				<CFOUTPUT><TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0" WIDTH="176" HEIGHT="35" BACKGROUND="/images/print_button.gif">
				<TR>
				<TD><A HREF="javascript:void(0);" onClick="javascript:window.print();"><IMG SRC="/images/fill.gif" ALT="" WIDTH="176" HEIGHT="35" BORDER="0"></A></TD>
				</TR>
				</TABLE></CFOUTPUT>	
			</cfif>
		</cfif>
		
		<cfif (rReportOutputType EQ "e") OR (rReportOutputType EQ "c")>
			<cfabort>
		</cfif>
	</cfif>
	
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!----------------------- Building query ends here -------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->