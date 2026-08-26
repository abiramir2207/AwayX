<!-------------------------Program Summary Report--------------------------------------------------->
<!--------Set defaults------------->
<CFPARAM NAME="Form.rStatus" DEFAULT="-1">
<CFPARAM NAME="Form.rBusinessSegment" DEFAULT="-1">
<CFPARAM NAME="Form.rDiscountIdentifier" DEFAULT="-1">
<CFPARAM NAME="Form.rGenericTypes" DEFAULT="-1">
<CFPARAM NAME="Form.rFilter" DEFAULT="">
<CFPARAM NAME="Form.rZones" DEFAULT="">
<CFPARAM NAME="Form.rRegions" DEFAULT="">
<CFPARAM NAME="Form.rBrokers" DEFAULT="">
<CFPARAM NAME="Form.rSortBy" DEFAULT="">

<CFPARAM NAME="Form.rFilterItems" DEFAULT="">

<CFPARAM NAME="Form.rFamilys" DEFAULT="">
<CFPARAM NAME="Form.rBuyingGroups" DEFAULT="">
<CFPARAM NAME="Form.rDistributors" DEFAULT="">
<cfparam name="Form.rColumnHeaderID" default="">

<CFPARAM NAME="Form.rOutputStartDate" DEFAULT="">
<CFPARAM NAME="Form.rOutputStartDateOperator" DEFAULT="">
<CFPARAM NAME="Form.rOutputEndDate" DEFAULT="">
<CFPARAM NAME="Form.rOutputEndDateOperator" DEFAULT="">

	<cfif Len(Trim(Form.rStatus)) EQ "">
		<CFSET Form.rStatus = "-1">
	</cfif>
	
	<cfif Len(Trim(Form.rBusinessSegment)) EQ "">
		<CFSET Form.rBusinessSegment = "-1">
	</cfif>
	
	<cfif Len(Trim(Form.rDiscountIdentifier)) EQ "">
		<CFSET Form.rDiscountIdentifier = "-1">
	</cfif>
	
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
				<cfset sErr="#sErr#Distributor is to be selected<br>">
			</cfif>
		</cfcase>
	</cfswitch>
	
	<cfif bErr>
		<cfset allClear=false>
		<!-----<cfset writeToErrorMessage(sErr,"error_rFilterItems")>------->
	</cfif>
	
	<cfset bErr=false>
	<!-----<cfset sErr="">------->
	<cfswitch expression="#Form.rFilter#">
		<cfcase value="zone">
			<cfif Form.rZones EQ "">
				<cfset bErr=true>
				<cfset sErr="#sErr#Zone is to be selected<br>">
			</cfif>
		</cfcase>
		<cfcase value="region">
			<cfif Form.rRegions EQ "">
				<cfset bErr=true>
				<cfset sErr="#sErr#Region is to be selected<br>">
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
		<!-----<cfset writeToErrorMessage(sErr,"error_rFilter")>------->
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
	
	<CFSET rStatus=Form.rStatus>
	<CFSET rBusinessSegment=Form.rBusinessSegment>
	<CFSET rDiscountIdentifier=Form.rDiscountIdentifier>
	<CFSET rGenericTypes=Form.rGenericTypes>
	
	<CFSET rFilter=Form.rFilter>
	<CFSET rZones=Form.rZones>
	<CFSET rRegions=Form.rRegions>
	<CFSET rBrokers=Form.rBrokers>
	
	<CFIF rFilter NEQ "none">
		<CFSET rFilterValue=Evaluate("r#rFilter#s")>
	<CFELSE>
		<CFSET rFilterValue="">
	</CFIF>
	
	<CFSET rFilterItems=Form.rFilterItems>
	<CFSET rFamilys=Form.rFamilys>
	<CFSET rBuyingGroups=Form.rBuyingGroups>
	<CFSET rDistributors=Form.rDistributors>
	
	<CFIF rFilterItems NEQ "none">
		<CFSET rFilterItemValue=Evaluate("r#rFilterItems#s")>
	<CFELSE>
		<CFSET rFilterItemValue="">
	</CFIF>
	
	
	<CFSET rReportOutputType=Form.rReportOutputType>
	<CFSET rSortBy=Form.rSortBy>
	
	<CFSET rOutputStartDate=Form.rOutputStartDate>
	<CFSET rOutputStartDateOperator=Trim(Form.rOutputStartDateOperator)>
	<CFSET rOutputEndDate=Form.rOutputEndDate>
	<CFSET rOutputEndDateOperator=Trim(Form.rOutputEndDateOperator)>
	<CFSET rOutputStartDateOperatorSymbol="">
	<cfif Len(rOutputStartDateOperator) GT 0>
		<CFSET rOutputStartDateOperatorSymbol=Trim(ListGetAt(Date_Operator_Symbols,ListFindNoCase(Date_Operators, rOutputStartDateOperator, ",")))>
	</cfif>
	<CFSET rOutputEndDateOperatorSymbol="">
	<cfif Len(rOutputEndDateOperator) GT 0>
		<CFSET rOutputEndDateOperatorSymbol=Trim(ListGetAt(Date_Operator_Symbols,ListFindNoCase(Date_Operators, rOutputEndDateOperator, ",")))>
	</cfif>
	
	
	<CFSET rColumnHeaderID=ListAppend(fProgramColumnHeaderID,Form.rColumnHeaderID,",")>
	
	
	
	
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
	
	
	<CFINCLUDE TEMPLATE="#schGenerateProgram#">
	
	<cfif IsDefined("srqueryname")>		
		<CFINCLUDE TEMPLATE="#showProgramPage#">
	</cfif>
	
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!----------------------- Building query ends here -------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->