<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxProduct Summaryxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="q_getActiveStatus" DBTYPE="Query">
Select	DISTINCT Contract_Status_Type_ID,Contract_Status_Type_Desc
From 	q_getStatus
Where	
	Contract_Status_Type_ID >= 5
	AND
	Contract_Status_Type_ID <= 6
Order By Contract_Status_Type_ID
</CFQUERY>

<CFINCLUDE TEMPLATE="#reportProductMarginLookup#">
<cfoutput>
<CFSET formItemStartLetter="mpdt">
<cfif isDefined("rID")>
<!-----------------------------------------------------------------------
	Get Prev record from DB
	--------------------------------------------------------------------------->
	<CFQUERY NAME="q_getPrevReport" datasource="#application.datasource#">
	Select 	top 1 Report_Type_ID, Report_Type
	From	Report_Type
	Where	Report_Type_ID < #rID#
	Order By Report_Type_ID DESC
	</CFQUERY>
	<!-----------------------------------------------------------------------
	End - Get Prev record from DB
	--------------------------------------------------------------------------->
	
	<!-----------------------------------------------------------------------
	Get Prev record from DB
	--------------------------------------------------------------------------->
	<CFQUERY NAME="q_getNextReport" datasource="#application.datasource#">
	Select 	top 1 Report_Type_ID, Report_Type
	From	Report_Type
	Where	Report_Type_ID > #rID#
	Order By Report_Type_ID ASC
	</CFQUERY>
	<!-----------------------------------------------------------------------
	End - Get Prev record from DB
	--------------------------------------------------------------------------->
	
	<CFIF q_getPrevReport.recordCount GT 0>
		<B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
		<FONT SIZE="2" COLOR="Blue">
				<A HREF="
				<cfswitch expression="#q_getPrevReport.Report_Type#">
					<cfcase value="programSummary,productSummary" delimiters=",">
						#reportDetailsPage#
					</cfcase>
					<cfcase value="Product_Based_Margin_Analysis,Program_Based_Margin_Analysis" delimiters=",">
						#ReportDetailsPage#
					</cfcase>
				</cfswitch>				
				?rID=#q_getPrevReport.Report_Type_ID#">
					< Prev
				</A>
		</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B>
	</CFIF>
	
	<CFIF q_getNextReport.recordCount GT 0>
		<B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
		<FONT SIZE="2" COLOR="Blue">
				<A HREF="
				<cfswitch expression="#q_getNextReport.Report_Type#">
					<cfcase value="programSummary,productSummary" delimiters=",">
						#reportDetailsPage#
					</cfcase>
					<cfcase value="Product_Based_Margin_Analysis,Program_Based_Margin_Analysis" delimiters=",">
						#ReportDetailsPage#
					</cfcase>
				</cfswitch>
				?rID=#q_getNextReport.Report_Type_ID#">
					Next > 
				</A>
		</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B>
	</CFIF>
<cfelse>
	<SPAN CLASS="title2">Create Product-based Margin Analysis Report
</cfif>
</SPAN>
</cfoutput>

<HR COLOR="Orange" SIZE="1">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxx show Form xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
<CFSET rStatus="-1">
<!------<CFSET rProgramTypes="-1">----->
<CFSET rGenericTypes="-1">

<CFSET rSortBy="status,programtype,margin">
<CFSET rMarginOption="ALL">
<CFSET rMarginValue1="">
<CFSET rMarginValue2="">

<CFSET rFilterItem="">
<CFSET rFilterCust="">

<CFSET rTypeGroups="-1">
<CFSET rQBrands="-1">
<CFSET rTypeCodes="-1">
<CFSET rBrands="-1">


<CFSET rFamilys="">
<CFSET rBuyingGroups="">
<CFSET rDistributors="">

<CFSET reportFormatType=1>


<CFSET rReportOutputType="h">


<!----------- Get a new report name --------------------->
<CFQUERY NAME="q_reportName" datasource="#application.datasource#">
	SELECT Max(Report_Type_ID) as maxReport_Type_ID
	FROM Report_Type
</CFQUERY>
<CFIF q_reportName.recordCount GT 0>
	<CFIF q_reportName.maxReport_Type_ID EQ "">
		<CFSET rName="Product Margin Report 1">
	<CFELSE>
		<CFSET rName="Product Margin Report #Evaluate(q_reportName.maxReport_Type_ID+1)#">
	</CFIF>
</CFIF>

<!----------- Get a new report name --------------------->


<CFSET rStartDate=dateformat(Now(), 'm/d/yyy')>
<CFSET rEndDate=dateformat(Now(), 'm/d/yyy')>
<CFSET rStartTime=thisTime>
<CFSET rInterval="daily">
<CFSET rEmailAddress="">

<cfset showDetails=false>
<cfif isDefined("fromReportSaveAction")>
	<CFSET rStatus			=	Form.rStatus>
	<!------<CFSET rProgramTypes	=	Form.rProgramTypes>----->
	<CFSET rGenericTypes	=	Form.rGenericTypes>
	
	<CFSET rTypeGroups		=	Form.rTypeGroups>
	<CFSET rQBrands			=	Form.rQBrands>
	<CFSET rTypeCodes		=	Form.rTypeCodes>
	<CFSET rBrands			=	Form.rBrands>
	
	<CFSET rSortBy			=	Form.rSortBy>
	<CFSET reportFormatType	=	Form.reportFormatType>
	
	<cfparam name="Form.rMarginValue1" 	default="">
	<cfparam name="Form.rMarginValue2" 	default="">
	
	<CFSET rMarginValue1	=	Form.rMarginValue1>
	<CFSET rMarginValue2	=	Form.rMarginValue2>
	
	<CFSET rFilterItem		=	Form.rFilterItem>
	<CFSET rFilterCust		=	Form.rFilterCust>

	
	<CFSET rFamilys			=	Form.rFamilys>
	<CFSET rBuyingGroups	=	Form.rBuyingGroups>
	<CFSET rDistributors	=	Form.rDistributors>
	<CFSET rBrands			=	Form.rBrands>
	
	<CFSET rReportOutputType=	Form.rReportOutputType>

	<CFSET reportFormatType	=	Form.reportFormatType>
	
	<CFSET rName			=	Form.rName>
	<CFSET rStartDate		=	Form.rStartDate>
	<CFSET rEndDate			=	Form.rEndDate>
	<CFSET rStartTime		=	getMilitaryTime(Form.rStartTime)>
	<CFSET rInterval		=	Form.rInterval>
	<CFSET rEmailAddress	=	Form.rEmailAddress>	
<cfelseif isDefined("rID")>
	<CFIF IsDefined("q_getReportStructure")>
		<CFLOOP QUERY="q_getReportStructure">
			<CFSET Evaluate("#Report_Structure#=""#Report_Structure_Value#""")>
		</CFLOOP>
		
		<CFIF isDefined("rFilterItemValue") AND isDefined("rFilterItem")>
			<CFSET Evaluate("r#rFilterItem#=""#rFilterItemValue#""")>
		</CFIF>
		
		<!------<CFIF isDefined("rFilterItemValue") AND isDefined("rFilterItem")>
			<CFSET Evaluate("r#rFilterItem#=""#rFilterItemValue#""")>
		</CFIF>----->
		
		<CFIF isDefined("rFilterCustValue") AND isDefined("rFilterCust")>
			<CFSET Evaluate("r#rFilterCust#=""#rFilterCustValue#""")>
		</CFIF>
		
		<!------<CFIF isDefined("rFilterItemValue") AND isDefined("rFilterItem")>
			<CFSET Evaluate("r#rFilterItemCust#=""#rFilterItemValue#""")>
		</CFIF>----->
		
		<CFSET rName=q_getReportDetails.Report_Name>
		<CFSET rStartDate=q_getReportDetails.Report_StartDate>
		<CFSET rEndDate=q_getReportDetails.Report_EndDate>
		<!----<CFSET rStartTime=getMilitaryTime(q_getReportDetails.rStartTime)>--->
		<CFSET rStartTime=q_getReportDetails.Report_StartTime>
		<CFSET rInterval=q_getReportDetails.Report_Interval>
		<CFSET rEmailAddress=q_getReportDetails.Report_EmailAddress>		
		<cfset showDetails=true>
	<CFELSE>
		<CFSET rID=0>
	</CFIF>	
</cfif>
	
	<cfif showDetails>
		<SPAN CLASS="title2"><CFOUTPUT>#rName#</CFOUTPUT></SPAN><BR>
	</cfif>
	
	
	<cfif isDefined("sErr")>
		<TABLE BGCOLOR="Red" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<CFOUTPUT><FONT SIZE="2"><B>
		Update failed. Some of the fields are either missing or invalid.
		</B></FONT></CFOUTPUT>
		</TD>
		</TD>
		</TR>
		</TABLE>
	<cfelseif isDefined("URL.action")>
		<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<CFOUTPUT><FONT SIZE="2"><B>
		The report was <cfif URL.action EQ "edit">edited<cfelse>added</cfif> successfully.
		</B></FONT></CFOUTPUT>
		</TD>
		</TD>
		</TR>
		</TABLE>
	<cfelseif showDetails>
		
		<CFIF Len(rUserName) GT 0><BR><BR>
		<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
			<TR BGCOLOR="White">
			<TD>		
			<CFOUTPUT><FONT SIZE="2"><B>		
			This Report was last updated on #rEditDate# by #rUserName#		
			</B></FONT></CFOUTPUT>
			</TD>
			</TD>
			</TR>
		</TABLE>
		</CFIF>
	</cfif>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<SCRIPT LANGUAGE="JavaScript" SRC="../script/javascript/string_functions.js">
<!--- <CFINCLUDE TEMPLATE="../script/javascript/string_functions.js"> --->
</SCRIPT>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	
	<FORM ACTION="<cfoutput>#reportMarginActionPage#</cfoutput>" TARGET="_self" METHOD="post" NAME="ProductMarginForm" ID="ProductMarginForm" style="display:inline;">
	<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="2" WIDTH="700">
	<TR>
		<TD width="45%">
		<INPUT TYPE="RADIO" ID="rReportType" NAME="rReportType" VALUE="Product_Based_Margin_Analysis"<CFIF reportType EQ "Product_Based_Margin_Analysis"> CHECKED</CFIF>> Product-Based
		</TD>
		<TD width="55%">
		<INPUT TYPE="RADIO" ID="rReportType" NAME="rReportType" VALUE="Program_Based_Margin_Analysis"<CFIF reportType EQ "Program_Based_Margin_Analysis"> CHECKED</CFIF>>Program Based		
		</TD>
	</TR>
	<TR>
			<TD COLSPAN="2"><HR COLOR="Orange" SIZE="1"></TD>
	</TR>
			
	<TR>
		<TD VALIGN="TOP">			
			<!------xxxxxxxxxxxxxxxxxxxxxxx Status and program types xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
			<strong>Status</strong><br>
			<SELECT size="5" name="rStatus" multiple>
				<OPTION VALUE="-1"<cfif ListFindNoCase(rStatus,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getActiveStatus" GROUP="Contract_Status_Type_ID"><OPTION<cfif ListFindNoCase(rStatus,q_getActiveStatus.Contract_Status_Type_ID,",")> SELECTED</cfif> VALUE="#q_getActiveStatus.Contract_Status_Type_ID#">#q_getActiveStatus.Contract_Status_Type_Desc#</OPTION></CFOUTPUT>
			</SELECT>
			
			<BR><BR>
			
			<!------<strong>Program Types</strong><br>
			<SELECT size="5" name="rProgramTypes" multiple>
					<OPTION VALUE="-1"<cfif ListFindNoCase(rProgramTypes,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
					<CFOUTPUT QUERY="q_getProgramTypes"><OPTION<cfif ListFindNoCase(rProgramTypes,q_getProgramTypes.ProgramControl_Panel_Options_ID,",")> SELECTED</cfif> VALUE="#q_getProgramTypes.ProgramControl_Panel_Options_ID#">#q_getProgramTypes.Created_Type#</OPTION></CFOUTPUT>
			</SELECT>----->
			<strong>Program Generic Types</strong><br>
			<SELECT size="5" name="rGenericTypes" multiple>
					<OPTION VALUE="-1"<cfif ListFindNoCase(rGenericTypes,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
					<CFOUTPUT QUERY="q_getGenericTypes"><OPTION<cfif ListFindNoCase(rGenericTypes,Generic_Type_ID,",")> SELECTED</cfif> VALUE="#Generic_Type_ID#">#ReReplaceNoCase(Generic_Type, "trade", application.returned_customer_setting.Trade_Label)#</OPTION></CFOUTPUT>
			</SELECT>
			<!------xxxxxxxxxxxxxxxxxxxxxxx End Status and program types xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
		</TD>
		<TD VALIGN="TOP">
			<!------xxxxxxxxxxxxxxxxxxxxxxx Product and Distributor Filters xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="1">
			<TR>
				<TD COLSPAN=2 VALIGN="TOP">
				<span id="error_rFilterItem"></span>&nbsp;<strong>Product Filter</strong>
				</TD>
			</TR>
			
			<TR>
			<TD>
			<INPUT TYPE="radio" ID="rFilterItem" NAME="rFilterItem" VALUE="qbrand"<cfif rFilterItem EQ "qbrand"> CHECKED</cfif> onClick="javascript:setProductMarginItemFilter(this.value);"><CFOUTPUT>#application.returned_customer_setting.q_brand_label_singular#</CFOUTPUT><!--- Q Brand --->
			</TD>
			<TD>
			<cfset selFound=false>
			<DIV ID="<CFOUTPUT>#formItemStartLetter#</CFOUTPUT>FilterItemDIVqbrand">
			<SELECT size="1" name="rQBrands">
			<OPTION VALUE=""></OPTION>
			<OPTION VALUE="-1"<cfif rQBrands EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
			<CFOUTPUT QUERY="q_getQBrands"><OPTION<cfif rQBrands EQ q_getQBrands.Q_Brand_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getQBrands.Q_Brand_ID#">#q_getQBrands.Q_Brand#</OPTION></CFOUTPUT>
			<cfif NOT selFound AND rQBrands NEQ "-1" AND rQBrands NEQ "">
			<CFSET thisFilter="---QBRAND NOT FOUND---">
			<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
			</cfif>
			</SELECT>		
			</DIV>
			</TD>
			</TR>
			
			<TR>
			<TD>
			<INPUT TYPE="radio" ID="rFilterItem" NAME="rFilterItem" VALUE="typegroup"<cfif rFilterItem EQ "typegroup"> CHECKED</cfif> onClick="javascript:setProductMarginItemFilter(this.value);"><CFOUTPUT>#application.returned_customer_setting.type_group_label_singular#</CFOUTPUT><!--- Type Group --->
			</TD>
			<TD>
			<cfset selFound=false>
			<DIV ID="<CFOUTPUT>#formItemStartLetter#</CFOUTPUT>FilterItemDIVtypegroup">
			<SELECT size="1" name="rTypeGroups">
			<OPTION VALUE=""></OPTION>
			<OPTION VALUE="-1"<cfif rTypeGroups EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
			<CFOUTPUT QUERY="q_getTypeGroups"><OPTION<cfif rTypeGroups EQ q_getTypeGroups.Type_Group_Desc_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getTypeGroups.Type_Group_Desc_ID#">#q_getTypeGroups.Type_Group_Desc#</OPTION></CFOUTPUT>
			<cfif NOT selFound AND rTypeGroups NEQ "-1" AND rTypeGroups NEQ "">
			<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
			Select	tg.Type_Group_Desc,tg.Deleted
			From	Type_Group_Desc tg
			Where	tg.Type_Group_Desc_ID='#rTypeGroups#'
			</CFQUERY>
			<CFIF q_getThisFilter.recordCount GT 0>
				<CFSET thisFilter=q_getThisFilter.Type_Group_Desc>
				<CFIF q_getThisFilter.Deleted>
					<CFSET thisFilter="DELETED - #thisFilter#">
				</CFIF>
			<CFELSE>
				<CFSET thisFilter="---TYPEGROUP NOT FOUND---">
			</CFIF>
			<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
			</cfif>
			</SELECT>
			</DIV>
			</TD>
			</TR>
				<TR>
				<TD>
				<INPUT TYPE="radio" ID="rFilterItem" NAME="rFilterItem" VALUE="typecode"<cfif rFilterItem EQ "typecode"> CHECKED</cfif> onClick="javascript:setProductMarginItemFilter(this.value);"><CFOUTPUT>#application.returned_customer_setting.type_code_label_singular#</CFOUTPUT><!--- Type Code --->
				</TD>
				<TD>
				<cfset selFound=false>
				<DIV ID="<CFOUTPUT>#formItemStartLetter#</CFOUTPUT>FilterItemDIVtypecode">
				<SELECT size="1" name="rTypeCodes">
				<OPTION VALUE=""></OPTION>
				<OPTION VALUE="-1"<cfif rTypeCodes EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getTypeCodes"><OPTION<cfif rTypeCodes EQ q_getTypeCodes.Type_Code_Desc_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getTypeCodes.Type_Code_Desc_ID#">#q_getTypeCodes.Type_Code_Desc#</OPTION></CFOUTPUT>
				<cfif NOT selFound AND rTypeCodes NEQ "-1" AND rTypeCodes NEQ "">
				<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
				Select	tc.Type_Code_Desc,tc.Deleted
				From	Type_Code_Desc tc
				Where	tc.Type_Code_Desc_ID='#rTypeCodes#'
				</CFQUERY>
				<CFIF q_getThisFilter.recordCount GT 0>
					<CFSET thisFilter=q_getThisFilter.Type_Code_Desc>
					<CFIF q_getThisFilter.Deleted>
						<CFSET thisFilter="DELETED - #thisFilter#">
					</CFIF>
				<CFELSE>
					<CFSET thisFilter="---TYPECODE NOT FOUND---">
				</CFIF>
				<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
				</cfif>
				</SELECT>
				</DIV>
				</TD>
				</TR>
				<TR>
				<TD>
				<INPUT TYPE="radio" ID="rFilterItem" NAME="rFilterItem" VALUE="brand"<cfif rFilterItem EQ "brand"> CHECKED</cfif> onClick="javascript:setProductMarginItemFilter(this.value);">Brand
				</TD>
				<TD>
				<cfset selFound=false>
				<DIV ID="<CFOUTPUT>#formItemStartLetter#</CFOUTPUT>FilterItemDIVbrand">
				<SELECT size="1" name="rBrands">
				<OPTION VALUE=""></OPTION>
				<OPTION VALUE="-1"<cfif rBrands EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getBrands"><OPTION<cfif rBrands EQ q_getBrands.Brand_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getBrands.Brand_ID#">#q_getBrands.Brand_Name#</OPTION></CFOUTPUT>
				<cfif NOT selFound AND rBrands NEQ "-1" AND rBrands NEQ "">
				<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
				Select	b.Brand_Name,b.Deleted
				From	Brand b
				Where	b.Brand_ID='#rBrands#'
				</CFQUERY>
				<CFIF q_getThisFilter.recordCount GT 0>
					<CFSET thisFilter=q_getThisFilter.Brand_Name>
					<CFIF q_getThisFilter.Deleted>
						<CFSET thisFilter="DELETED - #thisFilter#">
					</CFIF>
				<CFELSE>
					<CFSET thisFilter="---BRAND NOT FOUND---">
				</CFIF>
				<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
				</cfif>
				</SELECT>
				</DIV>
				</TD>
				</TR>
			<TR>
				<TD COLSPAN="2"><HR COLOR="Orange" SIZE="1"></TD>
			</TR>
			
			
			<!----------- Distributer starts here -------------------------->
			
			<TR>
			<TD COLSPAN=2><span id="error_rFilterCust"></span>&nbsp;<strong>Customer Filter</strong></TD>
			</TR>
			<TR>
			<TD><INPUT TYPE="radio" ID="rFilterCust" NAME="rFilterCust" VALUE="family"<cfif rFilterCust EQ "family"> CHECKED</cfif> onClick="javascript:setProductMarginCustomerFilter(this.value);"><CFOUTPUT>#application.returned_customer_setting.family_name_label_singular#</CFOUTPUT><!--- Family ---></TD>
				<TD>
			<cfset selFound=false>
			<DIV ID="<CFOUTPUT>#formItemStartLetter#</CFOUTPUT>FilterCustDIVfamily">
			<SELECT size="1" name="rFamilys">
					<OPTION VALUE=""></OPTION>
					<OPTION VALUE="-1"<cfif rFamilys EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
					<CFOUTPUT QUERY="q_getFamilys"><OPTION<cfif rFamilys EQ q_getFamilys.family_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getFamilys.family_ID#">#q_getFamilys.family_Name#</OPTION></CFOUTPUT>
					<cfif NOT selFound AND rFamilys NEQ "-1" AND rFamilys NEQ "">
					<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
					Select 	f.Family_Name,f.Deleted
					From	Distributor_Family f
					Where	f.family_ID='#rFamilys#'
					</CFQUERY>				
					<CFIF q_getThisFilter.recordCount GT 0>
						<CFSET thisFilter=q_getThisFilter.Family_Name>
						<CFIF q_getThisFilter.Deleted>
							<CFSET thisFilter="DELETED - #thisFilter#">
						</CFIF>
					<CFELSE>
						<CFSET thisFilter="---Family NOT FOUND---">
					</CFIF>
					<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
					</cfif>				
			</SELECT>
			</DIV>
			</TD>
			</TR>
			<TR>
			<TD><INPUT TYPE="radio" ID="rFilterCust" NAME="rFilterCust" VALUE="buyinggroup"<cfif rFilterCust EQ "buyingGroup"> CHECKED</cfif> onClick="javascript:setProductMarginCustomerFilter(this.value);"><CFOUTPUT>#application.returned_customer_setting.buying_group_label_singular#</CFOUTPUT><!--- Buying Group ---></TD>
			<TD>
			<cfset selFound=false>
			<DIV ID="<CFOUTPUT>#formItemStartLetter#</CFOUTPUT>FilterCustDIVbuyinggroup">
			<SELECT size="1" name="rBuyingGroups">
					<OPTION VALUE=""></OPTION>
					<OPTION VALUE="-1"<cfif rBuyingGroups EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
					<CFOUTPUT QUERY="q_getBuyingGroups"><OPTION<cfif rBuyingGroups EQ q_getBuyingGroups.Buying_Group_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getBuyingGroups.Buying_Group_ID#">#q_getBuyingGroups.Buying_Group_Name#</OPTION></CFOUTPUT>
					<cfif NOT selFound AND rBuyingGroups NEQ "-1" AND rBuyingGroups NEQ "">
					<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
					Select 	bg.Buying_Group_Name,bg.Deleted,bg.active_code
					From	Distributor_Buying_Groups bg
					Where	bg.buying_group_ID='#rBuyingGroups#'
					</CFQUERY>				
					<CFIF q_getThisFilter.recordCount GT 0>
						<CFSET thisFilter=q_getThisFilter.Buying_Group_Name>
						<CFIF q_getThisFilter.Deleted>
							<CFSET thisFilter="DELETED - #thisFilter#">
						</CFIF>
						<CFIF q_getThisFilter.Active_Code NEQ 'A'>
							<CFSET thisFilter="NOT ACTIVE - #thisFilter#">
						</CFIF>
					<CFELSE>
						<CFSET thisFilter="---BuyingGroup NOT FOUND---">
					</CFIF>				
					<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
					</cfif>				
			</SELECT>		
			</DIV>
			</TD>
			</TR>
			<TR>
				<TD><INPUT TYPE="radio" ID="rFilterCust" NAME="rFilterCust" VALUE="distributor"<cfif rFilterCust EQ "distributor"> CHECKED</cfif> onClick="javascript:setProductMarginCustomerFilter(this.value);"><CFOUTPUT>#application.returned_customer_setting.distributor_label_singular#</CFOUTPUT><!--- Distributor ---></TD>
				<TD>
				<DIV ID="<CFOUTPUT>#formItemStartLetter#</CFOUTPUT>FilterCustDIVdistributor">
				<CFOUTPUT>
				<INPUT TYPE="HIDDEN" ID="rDistributors" NAME="rDistributors" VALUE="#rDistributors#">
				<IFRAME NAME="Distributor_Frame" STYLE="WIDTH:250px;HEIGHT:20px;" ATOMICSELECTION="false" SRC="ShowDistributors.cfm?rDistributors=#rDistributors#" FRAMEBORDER="0" style="border: 0px none ##000000;" SCROLLING="No"></IFRAME>
				</CFOUTPUT>
				<!-----------
			<cfset selFound=false>			
			<SELECT size="1" name="rDistributors">
					<OPTION VALUE=""></OPTION>
					<OPTION VALUE="-1"<cfif rDistributors EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
					<CFOUTPUT QUERY="q_getDistributors"><OPTION<cfif rDistributors EQ q_getDistributors.BSA_FoodService_Customers_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getDistributors.BSA_FoodService_Customers_ID#">#q_getDistributors.Name#</OPTION></CFOUTPUT>
					<cfif NOT selFound AND rDistributors NEQ "-1" AND rDistributors NEQ "">
					<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
					SELECT  cfc.Name,cfc.Active_Code,cfc.Deleted,lob.Line_Of_Business
					FROM    BSA_Foodservice_Customers cfc,Line_Of_Business lob					
					WHERE   cfc.Line_Of_Business_ID = lob.Line_Of_Business_ID
						and cfc.BSA_Foodservice_Customers_ID='#rDistributors#'
					</CFQUERY>
					<CFIF q_getThisFilter.recordCount GT 0>
						<CFSET thisFilter=q_getThisFilter.Name>
						<CFIF q_getThisFilter.Deleted>
							<CFSET thisFilter="DELETED - #thisFilter#">
						</CFIF>
						<CFIF q_getThisFilter.Active_Code NEQ 'A'>
							<CFSET thisFilter="NOT ACTIVE - #thisFilter#">
						</CFIF>
						<CFIF q_getThisFilter.Line_Of_Business NEQ 'F'>
							<CFSET thisFilter="NOT LOB(F) - #thisFilter#">
						</CFIF>
					<CFELSE>
						<CFSET thisFilter="---Distributor NOT FOUND---">
					</CFIF>
					<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
					</cfif>
			</SELECT>
			-------------->
			</DIV>
			</TD>
			</TR>
			
			</TABLE>
			<!------xxxxxxxxxxxxxxxxxxxxxxx End Product and Distributor Filters xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
		</TD>
	</TR>
	
	<TR>
		<TD COLSPAN="2"><HR COLOR="Orange" SIZE="1"></TD>
	</TR>
	
	<TR>
		<TD VALIGN="TOP">		
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="5">
			<TR>
				<strong>Margin ($/LB)</strong><br>
				<SELECT SIZE="1" NAME="rMarginOption" onChange="javaScript:marginOptionSelected(this);">
				<OPTION VALUE="ALL"<cfif rMarginOption EQ "ALL"> SELECTED</cfif>>All</OPTION>
				<OPTION VALUE="BTW"<cfif rMarginOption EQ "BTW"> SELECTED</cfif>>Between</OPTION>
				<OPTION VALUE="GT"<cfif rMarginOption EQ "GT"> SELECTED</cfif>>Greater Than Or Equal To</OPTION>
				<OPTION VALUE="LT"<cfif rMarginOption EQ "LT"> SELECTED</cfif>>Less Than Or Equal To</OPTION>
				</SELECT><BR>
				<CFOUTPUT>
				<SPAN ID="divMarginValue1">
				<INPUT TYPE="TEXT" SIZE="11" ID="rMarginValue1" NAME="rMarginValue1" VALUE="#rMarginValue1#" onKeyUp="clenseText(this, '0123456789.-');threeDecimalPlaces(this);"  onblur="threeDecimalPlaces(this)">
				<SPAN ID="divMarginValue2">
				AND <INPUT TYPE="TEXT" SIZE="11" ID="rMarginValue2" NAME="rMarginValue2" VALUE="#rMarginValue2#" onKeyUp="clenseText(this, '0123456789.-');threeDecimalPlaces(this);"  onblur="threeDecimalPlaces(this)">
				</SPAN>
				</SPAN>
				</CFOUTPUT>
			</TR>
			</TABLE>
		</TD>
		<TD VALIGN="TOP">
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="5">
			<TR>
				<TD VALIGN="TOP"><strong>Sort By</strong></TD>
				<TD>
				<SELECT SIZE="1" NAME="rSortBy">
				<OPTION VALUE="-1"<cfif ListFindNoCase(rSortBy,"-1",",") EQ 1> SELECTED</cfif>>--Select ----</OPTION>
				<OPTION VALUE="status"<cfif ListFindNoCase(rSortBy,"status",",") EQ 1> SELECTED</cfif>>Status</OPTION>
				<OPTION VALUE="programtype"<cfif ListFindNoCase(rSortBy,"programtype",",") EQ 1> SELECTED</cfif>>Program Types</OPTION>
				<OPTION VALUE="margin"<cfif ListFindNoCase(rSortBy,"margin",",") EQ 1> SELECTED</cfif>>Margin</OPTION>
				</SELECT><BR>				
				<SELECT SIZE="1" NAME="rSortBy">
				<OPTION VALUE="-1"<cfif ListFindNoCase(rSortBy,"-1",",") EQ 2> SELECTED</cfif>>--Select ----</OPTION>
				<OPTION VALUE="status"<cfif ListFindNoCase(rSortBy,"status",",") EQ 2> SELECTED</cfif>>Status</OPTION>
				<OPTION VALUE="programtype"<cfif ListFindNoCase(rSortBy,"programtype",",") EQ 2> SELECTED</cfif>>Program Types</OPTION>
				<OPTION VALUE="margin"<cfif ListFindNoCase(rSortBy,"margin",",") EQ 2> SELECTED</cfif>>Margin</OPTION>
				</SELECT><BR>				
				<SELECT SIZE="1" NAME="rSortBy">
				<OPTION VALUE="-1"<cfif ListFindNoCase(rSortBy,"-1",",") EQ 3> SELECTED</cfif>>--Select ----</OPTION>
				<OPTION VALUE="status"<cfif ListFindNoCase(rSortBy,"status",",") EQ 3> SELECTED</cfif>>Status</OPTION>
				<OPTION VALUE="programtype"<cfif ListFindNoCase(rSortBy,"programtype",",") EQ 3> SELECTED</cfif>>Program Types</OPTION>
				<OPTION VALUE="margin"<cfif ListFindNoCase(rSortBy,"margin",",") EQ 3> SELECTED</cfif>>Margin</OPTION>
				</SELECT>
				</TD>
			</TR>
			</TABLE>
		</TD>
	</TR>
	<TR>
		<TD VALIGN="TOP">		
		<strong>Report output Type</strong>
		<BR><INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="h"<cfif rReportOutputType EQ "h"> CHECKED</cfif> OnClick="JavaScript: reportFormatType[2].disabled=!this.checked;">HTML
		 <INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="e"<cfif rReportOutputType EQ "e"> CHECKED</cfif> OnClick="JavaScript: reportFormatType[2].disabled=!this.checked;">Excel
		 <INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="c"<cfif rReportOutputType EQ "c"> CHECKED</cfif> OnClick="JavaScript: reportFormatType[2].disabled=this.checked;"<CFIF reportFormatType EQ 3> DISABLED</CFIF>>CSV
		</TD>
		<TD>
		</TD>
	</TR>
	<TR>
		<TD ALIGN="TOP" COLSPAN="2">			
			<CFIF Listlen(reportFormatTypes,",") EQ ListLen(reportFormatTypeIDs,",")>
				<strong>Report Output Format</strong><br>
				<CFSET listIndex=1>
				<CFOUTPUT>
				<CFLOOP INDEX="i" LIST="#reportFormatTypes#">
					<INPUT TYPE="RADIO" ID="reportFormatType" NAME="reportFormatType" VALUE="#ListGetAt(reportFormatTypeIDs,listIndex,",")#"<CFIF reportFormatType EQ listIndex> CHECKED</CFIF> OnClick="JavaScript: rReportOutputType[2].disabled=<CFIF listIndex NEQ 3>!</CFIF>this.checked;"<cfif (rReportOutputType EQ "c") AND (listIndex EQ 3)> DISABLED</cfif>> #i#
					<CFSET listIndex=listIndex+1>
				</CFLOOP>
				</CFOUTPUT>
			</CFIF>
		</TD>
	</TR>
	</TABLE>
	<!------ 
	<cfif isDefined("rID")>
			<cfif rID GT 0>
				<cfset bTitle="Edit This Report Schedule">
			<cfelse>
				<cfset bTitle="Save As Report Schedule">
			</cfif>
		<cfelse>
			<cfset bTitle="Save As Report Schedule">
		</cfif>
		<cfif isDefined("sErr")><cfset showClosed="No"><cfelse><cfset showClosed="Yes"></cfif>
		<CF_openLayer
	Border="yes"
	BorderSize="1"  
	BorderColor="orange"  
	Image="/images/plus2.gif"
	ImageOpen="/images/minus2.gif"
	Title="#bTitle#"  
	TitleClosed="#bTitle#"  
	TitleTooltip="#bTitle#"  
	TitleFont="font"  
	TitleColor="Blue"  
	TitleSize="9"  
	IsClosed="#showClosed#"  
	Width="100%">
		<CFSET thisFormName="ProductMarginForm"> 
		<CFSET repType=formItemStartLetter>
		<CFINCLUDE TEMPLATE="#reportTemplatePage#">		
		</CF_openLayer>
	 ----->
	<br>
				<DIV ALIGN="center">
			<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"show report"
			BUTTON_ACTION	=	"javascript: if(confirm(\'This may take some time. Do you want to continue?\'))verifyMarginReportValues(document.ProductMarginForm,\'<CFOUTPUT>#formItemStartLetter#</CFOUTPUT>\');"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">
			</DIV>		
	</FORM>


<!--- xxxxxxxxxxxxxxxxxxxx End show Form xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
