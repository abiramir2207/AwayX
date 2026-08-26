<CFSET rStatus=-1>
<CFSET rBusinessSegment=-1>
<CFSET rDiscountIdentifier="-1">
<CFSET rGenericTypes="-1">
<CFSET rFilter="none">
<CFSET rZones="-1">
<CFSET rRegions="-1">
<CFSET rBrokers="-1">
<CFSET rSortBy="status,programtype">

<CFSET rFilterItems="none">

<CFSET rTypeGroups="-1">
<CFSET rQBrands="-1">
<CFSET rTypeCodes="-1">
<CFSET rBrands="-1">
<CFSET rProductGroups="-1">
<CFSET rProducts="">

<CFSET rReportOutputType="h">
<CFSET rColumnHeaderID=fProductColumnHeaderID>

<cfset rOutputStartDate = "">
<cfset rOutputStartDateOperator = "">
<cfset rOutputEndDate = "">
<cfset rOutputEndDateOperator = "">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<!----------- Get a new report name --------------------->
<CFQUERY NAME="q_reportName" datasource="#application.datasource#">
	SELECT Max(Report_Type_ID) as maxReport_Type_ID
	FROM Report_Type
</CFQUERY>
<CFIF q_reportName.recordCount GT 0>
	<CFIF q_reportName.maxReport_Type_ID EQ "">
		<CFSET rName="Product Report 1">
	<CFELSE>
		<CFSET rName="Product Report #Evaluate(q_reportName.maxReport_Type_ID+1)#">
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
	<CFSET rStatus=Form.rStatus>
	<CFSET rBusinessSegment=Form.rBusinessSegment>
	<CFSET rDiscountIdentifier=Form.rDiscountIdentifier>
	<CFSET rGenericTypes=Form.rGenericTypes>	
	<CFSET rFilter=Form.rFilter>
	<CFSET rZones=Form.rZones>
	<CFSET rRegions=Form.rRegions>
	<CFSET rBrokers=Form.rBrokers>	
	<CFSET rSortBy=Form.rSortBy>
	
	<CFSET rFilterItems=Form.rFilterItems>
	
	<CFSET rTypeGroups=Form.rTypeGroups>
	<CFSET rQBrands=Form.rQBrands>
	<CFSET rTypeCodes=Form.rTypeCodes>
	<CFSET rBrands=Form.rBrands>
	<CFSET rProductGroups=Form.rProductGroups>	
	<CFSET rProducts=Form.rProducts>
	
	<CFSET rReportOutputType=Form.rReportOutputType>
	<CFSET rColumnHeaderID=Form.rColumnHeaderID>
	
	<CFSET rName=Form.rName>
	<CFSET rStartDate=Form.rStartDate>
	<CFSET rEndDate=Form.rEndDate>
	<CFSET rStartTime=getMilitaryTime(Form.rStartTime)>
	<CFSET rInterval=Form.rInterval>
	<CFSET rEmailAddress=Form.rEmailAddress>	
<cfelseif isDefined("rID")>
	<CFIF IsDefined("q_getReportStructure")>
		<CFLOOP QUERY="q_getReportStructure">
			<CFSET Evaluate("#Report_Structure#=""#Report_Structure_Value#""")>
		</CFLOOP>
		
		<CFIF isDefined("rFilterValue") AND isDefined("rFilter")>
			<CFSET Evaluate("r#rFilter#s=""#rFilterValue#""")>
		</CFIF>
		
		<CFIF isDefined("rFilterItemValue") AND isDefined("rFilterItems")>
			<CFSET Evaluate("r#rFilterItems#s=""#rFilterItemValue#""")>
		</CFIF>
		
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
		<TABLE BGCOLOR="Red" BORDER="0" CELLPADDING="0" CELLSPACING="1" ALIGN="CENTER">
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
	<cfset discountIdentifierManager = CreateObject("component","components.programs.discount_identifier.discountidentifier")>
	
	<CFSET thisFormName="pProductSummaryForm"> 
	<cfoutput>
	<FORM ACTION="#reportActionPage#" TARGET="_self" METHOD="post" NAME="#thisFormName#" ID="pProductSummaryForm" style="display:inline;">
	</cfoutput>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="1" WIDTH="750">
	<TR>
		<TD VALIGN="TOP" COLSPAN="2" ROWSPAN="2">
		<TABLE cellpadding="2" cellspacing="2">
		<TR valign="top">
		<TD><strong>Status</strong><br>
		<SELECT size="5" name="rStatus" multiple>
          <OPTION VALUE="-1"<cfif ListFindNoCase(rStatus,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
          <CFOUTPUT QUERY="q_getStatus"> 
            <OPTION<cfif ListFindNoCase(rStatus,q_getStatus.Contract_Status_Type_ID,",")> SELECTED</cfif> VALUE="#q_getStatus.Contract_Status_Type_ID#">#q_getStatus.Contract_Status_Type_Desc#</OPTION>
          </CFOUTPUT> 
		</SELECT> 
		</TD>
		
		<cfif businessSegEnabled>
		<td>
			<cfset qGetBusSegments = businessSegManager.getActive() />
			<strong><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></strong><br>
			<SELECT size="5" name="rBusinessSegment" multiple>
			<OPTION VALUE="-1"<cfif ListFindNoCase(rBusinessSegment,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
			<cfoutput query="qGetBusSegments">
			<option value="#Business_Segment_ID#">#Business_Unit_Desc#</option>
			</cfoutput>
			</SELECT>
		</td>
		</cfif>
		</TR>
		<TR valign="top">
        <TD><strong>Program Generic Types</strong><br>
		<SELECT size="5" name="rGenericTypes" multiple>
          <OPTION VALUE="-1"<cfif ListFindNoCase(rGenericTypes,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
          <CFOUTPUT QUERY="q_getGenericTypes"> 
            <OPTION<cfif ListFindNoCase(rGenericTypes,Generic_Type_ID,",")> SELECTED</cfif> VALUE="#Generic_Type_ID#">#ReReplaceNoCase(Generic_Type, 
            "trade", application.returned_customer_setting.Trade_Label)#</OPTION>
          </CFOUTPUT> 
		</SELECT> 
		</TD>
		 <cfif discountIdentifierManager.discountIdentifierOn()>	  
	      <td><strong>Discount Identifier</strong><br>
		  <cfset qGetDiscountIdentifiers = discountIdentifierManager.getActive() />
		 <select size="5" name="rDiscountIdentifier" multiple>
	           <option value="-1"<cfif ListFindNoCase(rDiscountIdentifier,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</option>
	          <cfoutput query="qGetDiscountIdentifiers"> 
			  	<option<cfif ListFindNoCase(rDiscountIdentifier,Discount_Identifier_ID,",")> SELECTED</cfif> value="#Discount_Identifier_ID#">#Discount_Identifier_Desc#</option>
	          </cfoutput>
			</select>
		  &nbsp;</td>
		  </cfif>
		  
		</TR>
		</TABLE>
	</TR>
	
	
	
	<TR>
		<TD COLSPAN=2 VALIGN="TOP">
		<span id="error_rFilterItems"></span>&nbsp;<strong>Product Filter (This field will be used for primary grouping)</strong>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="1" WIDTH="100%">			
			<TR>
				<TD>
				<INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="qbrand"<cfif rFilterItems EQ "qbrand"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);"><CFOUTPUT>#application.returned_customer_setting.q_brand_label_singular#</CFOUTPUT><!--- Q Brand --->
				</TD>
				<TD>
				<cfset selFound=false>
		<DIV ID="pFilterItemDIVqbrand">
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
				<INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="typegroup"<cfif rFilterItems EQ "typegroup"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);"><CFOUTPUT>#application.returned_customer_setting.type_group_label_singular#</CFOUTPUT><!--- Type Group --->
				</TD>
				<TD>
				<cfset selFound=false>
		<DIV ID="pFilterItemDIVtypegroup">
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
					<INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="typecode"<cfif rFilterItems EQ "typecode"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);"><CFOUTPUT>#application.returned_customer_setting.type_code_label_singular#</CFOUTPUT><!--- Type Code --->
					</TD>
					<TD>
					<cfset selFound=false>
					<DIV ID="pFilterItemDIVtypecode">
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
					<INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="brand"<cfif rFilterItems EQ "brand"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);">Brand
					</TD>
					<TD>
					<cfset selFound=false>
						<DIV ID="pFilterItemDIVbrand">
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
					<TD nowrap>
					<INPUT <cfif not productGroupIsOn>disabled</cfif> TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="productGroup"<cfif rFilterItems EQ "productGroup"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);">Product Group
					</TD>
					<TD>
					<cfset selFound=false>
						<DIV ID="pFilterItemDIVproductGroup">
						<cfif productGroupIsOn>
					<SELECT size="1" name="rProductGroups">
							<OPTION VALUE=""></OPTION>
							<OPTION VALUE="-1"<cfif rProductGroups EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
							<CFOUTPUT QUERY="q_getProductGroups"><OPTION<cfif rProductGroups EQ q_getProductGroups.BSA_Product_Group_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getProductGroups.BSA_Product_Group_ID#">#q_getProductGroups.Product_Group_Desc#</OPTION></CFOUTPUT>							
					</SELECT>
						<cfelse>
						
						</cfif>
						</DIV>
					</TD>
				</TR>
				<TR>
					<TD>
					<INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="product"<cfif rFilterItems EQ "product"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);">Product
					</TD>
					<TD>						
						<DIV ID="pFilterItemDIVproduct">
						<CFOUTPUT>
						<INPUT TYPE="HIDDEN" ID="rProducts" NAME="rProducts" VALUE="#rProducts#">
						<IFRAME NAME="Product_Frame" STYLE="WIDTH:250px;HEIGHT:20px;" ATOMICSELECTION="false" SRC="ShowProducts.cfm?rProducts=#rProducts#" FRAMEBORDER="0" style="border: 0px none ##000000;" SCROLLING="No"></IFRAME>
						</CFOUTPUT>
						</DIV>
					</TD>
				</TR>
				<TR>
					<TD COLSPAN="2" VALIGN="TOP">
					<INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="none"<cfif rFilterItems EQ "none"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);">None
					</TD>		
				</TR>
		</TABLE>
		</TD>
	</TR>

	<!-----<TR>
		<TD VALIGN="TOP"></TD>
		<TD VALIGN="TOP">
		<strong>Program Types</strong><br>
		<SELECT size="5" name="rProgramTypes" multiple>
				<OPTION VALUE="-1"<cfif ListFindNoCase(rProgramTypes,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getProgramTypes"><OPTION<cfif ListFindNoCase(rProgramTypes,q_getProgramTypes.ProgramControl_Panel_Options_ID,",")> SELECTED</cfif> VALUE="#q_getProgramTypes.ProgramControl_Panel_Options_ID#">#q_getProgramTypes.Created_Type#</OPTION></CFOUTPUT>
		</SELECT>		
		</TD>
	</TR>------->
<!-----	<TR>
			<TD>
			<INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="typegroup"<cfif rFilterItems EQ "typegroup"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);">Type Group
			</TD>
			<TD>
		<cfset selFound=false>
		<DIV ID="pFilterItemDIVtypegroup">
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
------->	
	<!-----<TR>
		<TD>
		<INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="qbrand"<cfif rFilterItems EQ "qbrand"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);">Q Brand
		</TD>
		<TD VALIGN="TOP">		
		<cfset selFound=false>
		<DIV ID="pFilterItemDIVqbrand">
		<SELECT size="1" name="rQBrands">
				<OPTION VALUE=""></OPTION>
				<OPTION VALUE="-1"<cfif rQBrands EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getQBrands"><OPTION<cfif rQBrands EQ q_getQBrands.Q_Brand_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getQBrands.Q_Brand_ID#">#q_getQBrands.Q_Brand#</OPTION></CFOUTPUT>
				<cfif NOT selFound AND rQBrands NEQ "-1" AND rQBrands NEQ "">
				<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
				Select qb.Q_Brand,qb.Deleted, 
				(SELECT Count(pqb.Deleted) From Product_Q_Brand_Desc pqb Where pqb.Q_Brand_ID=qb.Q_Brand_ID AND pqb.LOB='F' AND pqb.Deleted=0) AS ProductQNOTDeleted 
				From Q_Brand_Desc qb 
				Where qb.Q_Brand_ID='#rQBrands#' 
				</CFQUERY>
				<CFIF q_getThisFilter.recordCount GT 0>
					<CFSET thisFilter=q_getThisFilter.Q_Brand>
					<CFIF q_getThisFilter.Deleted>
						<CFSET thisFilter="DELETED - #thisFilter#">
					</CFIF>
					<CFIF q_getThisFilter.ProductQNOTDeleted LTE 0>
						<CFSET thisFilter="NO QBRAND DESC - #thisFilter#">
					</CFIF>
				<CFELSE>
					<CFSET thisFilter="---QBRAND NOT FOUND---">
				</CFIF>
				<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
				</cfif>
		</SELECT>		
		</DIV>
		</TD>
	</TR>	------->
<!-----	<TR>
		<TD>
		<INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="typecode"<cfif rFilterItems EQ "typecode"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);">Type Code
		</TD>
		<TD>
		<cfset selFound=false>
		<DIV ID="pFilterItemDIVtypecode">
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
	</TR>------->
	<!-----<TR>
		<TD>
		<INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="brand"<cfif rFilterItems EQ "brand"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);">Brand
		</TD>
		<TD>
		<cfset selFound=false>
			<DIV ID="pFilterItemDIVbrand">
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
	</TR>------->
	<!-----<TR>
		<TD COLSPAN="2">
		<INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="none"<cfif rFilterItems EQ "none"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);">None
		</TD>		
	</TR>------->
	<!-----<TR>
		<TD VALIGN="TOP" ROWSPAN="3"></TD>
		<TD VALIGN="TOP" ROWSPAN="3">
		<strong>Program Types</strong><br>
		<SELECT size="5" name="rProgramTypes" multiple>
				<OPTION VALUE="-1"<cfif ListFindNoCase(rProgramTypes,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getProgramTypes"><OPTION<cfif ListFindNoCase(rProgramTypes,q_getProgramTypes.ProgramControl_Panel_Options_ID,",")> SELECTED</cfif> VALUE="#q_getProgramTypes.ProgramControl_Panel_Options_ID#">#q_getProgramTypes.Created_Type#</OPTION></CFOUTPUT>
		</SELECT>		
		</TD>
	</TR>------->
	<!-----<TR>
		<TD>
		<INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="brand"<cfif rFilterItems EQ "brand"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);">Brand
		</TD>
		<TD>
		<cfset selFound=false>
			<DIV ID="pFilterItemDIVbrand">
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
		<TD COLSPAN="2" VALIGN="TOP">
		<INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="none"<cfif rFilterItems EQ "none"> CHECKED</cfif> onClick="javascript:setReportFilterItem(this.value);">None
		</TD>		
	</TR>------->
	
	
	</TABLE>
	<HR COLOR="Orange" SIZE="1">
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="1" WIDTH="750">
	<TR>
		<TD COLSPAN="2" VALIGN="TOP">
		<strong>Report output Type</strong>
		<BR><INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="h"<cfif rReportOutputType EQ "h"> CHECKED</cfif>>HTML
		 <INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="e"<cfif rReportOutputType EQ "e"> CHECKED</cfif>>Excel
		 <INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="c"<cfif rReportOutputType EQ "c"> CHECKED</cfif>>CSV
		</TD>
		<TD VALIGN="TOP">
		<cfoutput>
		<table cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td><B>Start Date</B>
			<SELECT NAME="rOutputStartDateOperator" STYLE="WIDTH:45px">
				<CFSET cnt=0>
				<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
					<CFSET cnt=cnt+1>
					<OPTION VALUE="#Trim(thisOperator)#"<CFIF rOutputStartDateOperator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
				</CFLOOP>
			</SELECT>
			<span id="err_Start_Date_End_date"></span>
			</td>
			<td rowspan="2" width="10"></td>
			<td><B>End Date</B>
			<SELECT NAME="rOutputEndDateOperator" STYLE="WIDTH:45px">
				<CFSET cnt=0>
				<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
					<CFSET cnt=cnt+1>
					<OPTION VALUE="#Trim(thisOperator)#"<CFIF rOutputEndDateOperator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
				</CFLOOP>
			</SELECT>
			</td>
		</tr>
		<tr>
			<td>
			<CF_EASYDATE 
				FORMNAME="#thisFormName#" 
				FIELDNAME="rOutputStartDate" 
				FORMAT="mm/dd/yyyy" 
				DEFAULT="#rOutputStartDate#">
			</td>
			<td>
			<CF_EASYDATE 
				FORMNAME="#thisFormName#" 
				FIELDNAME="rOutputEndDate" 
				FORMAT="mm/dd/yyyy" 
				DEFAULT="#rOutputEndDate#">
			</td>
		</tr>
		</table>
		</cfoutput>
		</TD>
		
		<TD VALIGN="TOP"><strong>Group By</strong></TD>
		<TD VALIGN="TOP">
		<SELECT SIZE="1" NAME="rSortBy">
		<OPTION VALUE="-1"<cfif ListFindNoCase(rSortBy,"-1",",") EQ 1> SELECTED</cfif>>--Select ----</OPTION>
		<OPTION VALUE="status"<cfif ListFindNoCase(rSortBy,"status",",") EQ 1> SELECTED</cfif>>Status</OPTION>
		<OPTION VALUE="programtype"<cfif ListFindNoCase(rSortBy,"programtype",",") EQ 1> SELECTED</cfif>>Program Types</OPTION>
		</SELECT>
		<BR>
		<SELECT SIZE="1" NAME="rSortBy">
		<OPTION VALUE="-1"<cfif ListFindNoCase(rSortBy,"-1",",") EQ 2> SELECTED</cfif>>--Select ----</OPTION>
		<OPTION VALUE="status"<cfif ListFindNoCase(rSortBy,"status",",") EQ 2> SELECTED</cfif>>Status</OPTION>
		<OPTION VALUE="programtype"<cfif ListFindNoCase(rSortBy,"programtype",",") EQ 2> SELECTED</cfif>>Program Types</OPTION>
		</SELECT>		
		</TD>		
	</TR>
	<TR>
		<TD COLSPAN="5" ALIGN="LEFT" VALIGN="TOP">
		<cfif ListLen(fProductColumnHeaderID,",") GT 0>
		<HR COLOR="Orange" SIZE="1">
			<cfif ListLen(fProductColumnHeaderID,",") GTE ListLen(fProductColumnHeaders,",")>
				<CFSET colLen=4>								
				<cfoutput>				
				<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0" WIDTH="100%">				
				<COLGROUP>
				<COL SPAN="#colLen#" WIDTH="20%"></COL>
				</COLGROUP>
					<TR>
						<TD COLSPAN="100%">
						<span id="perror_ColumnHeader"></span>&nbsp;<strong>Select Colum Headers</strong>
						</TD>
					<cfset j=Val(1)>
					<!-----<TD STYLE="display:none">
					<cfloop index="i" list="#fProductColumnHeaderID#" delimiters=",">						
						<INPUT onClick="javascript:this.checked=true;" TYPE="checkbox" ID="rColumnHeaderID" NAME="rColumnHeaderID" VALUE="#i#" CHECKED>
					</cfloop>
					</TD>------->
					<cfif ListLen(vProductColumnHeaderID,",") GTE ListLen(vProductColumnHeaders,",")>
						<cfloop index="i" list="#vProductColumnHeaderID#" delimiters=",">						
							<cfif (j MOD colLen) EQ 1>
								</TR>
								<TR>
							</cfif>
							<TD>
							<INPUT TYPE="checkbox" ID="rColumnHeaderID" NAME="rColumnHeaderID" VALUE="#i#"<cfif ListFindNoCase(rColumnHeaderID,i,",")> CHECKED</cfif>> #ListGetAt(vProductColumnHeaders,ListFindNoCase(vProductColumnHeaderID,i,","),",")#
							</TD>
							<cfset j=j+1>
						</cfloop>
					</cfif>
					</TR>
				</TABLE>
				</cfoutput>
			</cfif>
		</cfif>
		<INPUT TYPE="hidden" ID="rReportType" NAME="rReportType" VALUE="<CFOUTPUT>#reportType#</CFOUTPUT>">
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
		<CFSET repType="p">
		<CFINCLUDE TEMPLATE="#reportTemplatePage#">		
		</CF_openLayer>
		 ----->
	<br>
	<DIV ALIGN="center">
			<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"show report"
			BUTTON_ACTION	=	"javascript:verifyData(document.pProductSummaryForm,\'p\');"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">
		</DIV>	
	</FORM>
	
	<SCRIPT LANGUAGE="JavaScript">
	//var fixedColumLen = <CFOUTPUT>#ListLen(fProductColumnHeaderID)#</CFOUTPUT>;
	//var fixedColumLen = 0;
	</SCRIPT>
