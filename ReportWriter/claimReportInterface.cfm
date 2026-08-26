 <html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<script src="/reportWriter/claimReport.js"></script>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<body>
<style>
	.header
	{
		background-color:gray;
		color: white;
		font-size:14;
		font-weight:bold;
	}
	.label
	{
		color: black;
		font-size:12;
		font-weight:bold;
	}
	.labelWithNoBold
	{
		color: black;
		font-size:12;
	}
</style>
<CFPARAM NAME="FORM.Program_Status" DEFAULT="0">
<CFPARAM NAME="FORM.ProgramType" DEFAULT="0">
<CFPARAM NAME="FORM.Generic_Type" DEFAULT="0">
<CFPARAM NAME="FORM.Date_Operator" DEFAULT="">
<CFPARAM NAME="FORM.Start_date_Operator" DEFAULT="">
<CFPARAM NAME="FORM.Amount_Operator" DEFAULT="">
<CFPARAM NAME="GTE_Operators" DEFAULT=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
<CFPARAM NAME="GTE_Operator_Symbols" DEFAULT=" ,>=,=,<=">
<CFPARAM NAME="cnt" DEFAULT="0">
<cfoutput>
	<CFSET cmpHandle = CreateObject("component", "components.reports.claimReport") />
	<cfset crManagerObj = createObject('component','components.reports.ClaimReportManager').init() />
	<cfset thisObj = createObject('component','components.reports.#diThisPage#').init() /> 
	<cfset isExcelGeneratorEnabled = crManagerObj.isExcelGeneratorEnabled(thisObj) /> 
	<!--- for BillBack --->
	<form id="claimForm" name="claimForm" method="post" target="_self">
	<table align="center" width="90%" cellpadding="1" cellspacing="0">
		<tr>
			<td class="header" align="left" colspan="3">
				#Ucase("Billback")#
			</td>
			<td width="10%">&nbsp;</td>
		</tr>
		<tr>
			<td class="label">
				Customer Invoice ##<BR>
				<input name="custInvoice" id="custInvoice" type="text" align="left" size="40" maxlength="50" value="">
			</td>
			<td class="label">
				Vendor ID<BR>
				<input name="vendorID" id="vendorID" type="text" align="left" size="40" maxlength="50" value="">
			</td> 
			<td class="label">
				Check ##<BR>
				<input name="checkNo" id="checkNo" type="text" align="left" size="40" maxlength="50" value="">
			</td>
		</tr>
		<!--- date --->
		<tr>
			<td class="label">
				Billback Date<BR>
				<table>
				<tr>
				<td>
					<!--- OnChange="JavaScript: start_End_Date(1,this);" --->
					<SELECT OnChange="JavaScript: GTE_Operator(1,this);" NAME="BB_Operator" ID="BB_Operator" STYLE="WIDTH:45px">
						<CFLOOP LIST="#GTE_Operators#" INDEX="thisOperator">
							<CFSET cnt=cnt+1>
							<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.Date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(GTE_Operator_Symbols,cnt))#</OPTION>
						</CFLOOP>
					</SELECT>
				</td>
				<td>
					<CFPARAM NAME="FORM.BB_Date" DEFAULT="#Now()#">
					<SPAN ID="SP_Start_Date">
						<CF_EASYDATE FORMNAME="claimForm" FIELDNAME="BB_Date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.BB_Date#">
					</SPAN>
				</td>
				</tr>
				</table>
			</td>
			<td class="label">
				Billback Delivery Start Date<BR>
				<table>
					<tr>
						<td>
							<cfset cnt = 0>
							<!--- OnChange="JavaScript: start_End_Date(1,this);" --->
							<SELECT  OnChange="JavaScript: GTE_Operator(2,this);" NAME="BB_DeliverStart_Operator" ID="BB_DeliverStart_Operator" STYLE="WIDTH:45px">
								<CFLOOP LIST="#GTE_Operators#" INDEX="thisOperator">
									<CFSET cnt=cnt+1>
									<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.Date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(GTE_Operator_Symbols,cnt))#</OPTION>
								</CFLOOP>
							</SELECT>
						</td>
						<td>
							<CFPARAM NAME="FORM.BB_DeliverStart" DEFAULT="#Now()#">
							<SPAN ID="SP_BB_DeliverStart">
								<CF_EASYDATE FORMNAME="claimForm" FIELDNAME="BB_DeliverStart" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.BB_DeliverStart#">
							</SPAN>
						</td>
					</tr>
				</table>
			</td>
			<td class="label">
				Billback Delivery End Date<BR>
				<table>
					<tr>
						<td>
							<cfset cnt = 0>
							<!---- OnChange="JavaScript: start_End_Date(1,this);" --->
							<SELECT OnChange="JavaScript: GTE_Operator(3,this);" NAME="BB_DeliverEnd_Operator" ID="BB_DeliverEnd_Operator" STYLE="WIDTH:45px">
								<CFLOOP LIST="#GTE_Operators#" INDEX="thisOperator">
									<CFSET cnt=cnt+1>
									<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.Date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(GTE_Operator_Symbols,cnt))#</OPTION>
								</CFLOOP>
							</SELECT>
						</td>
						<td>
							<CFPARAM NAME="FORM.BB_DeliverEnd" DEFAULT="#Now()#">
							<SPAN ID="SP_BB_DeliverEnd">
								<CF_EASYDATE FORMNAME="claimForm" FIELDNAME="BB_DeliverEnd" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.BB_DeliverEnd#">
							</SPAN>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<!--- distributor or operator---->
		<tr>
			<td class="label">
				<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Name<BR>
				<input name="custName" id="custName" type="text" align="left" size="40" maxlength="50" value="">
			</td>
			<td class="label">
				<cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name<BR>
				<input name="operatorName" id="operatorName" type="text" align="left" size="40" maxlength="50" value="">
			</td>
			<td class="label">
				Total Claim Amount<BR>
				<table>
					<tr>
						<td>
							<cfset cnt = 0>
							<!---- OnChange="JavaScript: start_End_Date(1,this);" --->
							<SELECT OnChange="JavaScript: GTE_Operator(4,this);" NAME="Amount_Operator" ID="Amount_Operator" STYLE="WIDTH:45px">
								<CFSET cnt=0>
								<CFLOOP LIST="#GTE_Operators#" INDEX="thisOperator">
									<CFSET cnt=cnt+1>
									<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.Amount_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(GTE_Operator_Symbols,cnt))#</OPTION>
								</CFLOOP>
							</SELECT>
						</td>
						<td>
							<SPAN ID="SP_Amount">
								<input name="claimAmount" id="claimAmount" type="text" align="left" size="30" maxlength="50" value="">
							</SPAN>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<!--- claim status --->
		<tr>
			<td class="label">
				Claim Status<BR>
				<cfset claimStatusQry = cmpHandle.getClaimReportProgramStatus() >
				<SELECT NAME="claimStatus" STYLE="WIDTH:200px" multiple size="4">
					<CFLOOP QUERY="claimStatusQry"><OPTION VALUE="#trim(Billback_Status_ID)#"#IIF(trim(FORM.Program_Status) EQ Billback_Status_ID, DE(" SELECTED"), DE(""))#>#trim(BB_Status_Description)#</OPTION></CFLOOP>
				</SELECT>
			</td>
			<td class="label">
				Template Type<BR>
				<cfset claimTypesQry = cmpHandle.getClaimReportProgramTypes() >
				<SELECT NAME="templateTypes" STYLE="WIDTH:200px" multiple size="4">
					<CFLOOP QUERY="claimTypesQry"><OPTION VALUE="#trim(Generic_Type)#"#IIF(trim(FORM.Generic_Type) EQ Generic_Type, DE(" SELECTED"), DE(""))#>#trim(ReReplaceNoCase(Generic_Type, "trade", application.returned_customer_setting.Trade_Label))#</OPTION></CFLOOP>
				</SELECT>
			</td>
			<td class="label">
				Sold To ##<BR>
				<input name="soldToNo" id="soldToNo" type="text" align="left" size="40" maxlength="50" value="">
				<BR>Operator ##<BR>
				<input name="operatorNo" id="operatorNo" type="text" align="left" size="40" maxlength="50" value="">

			</td>
		</tr>
		<cfset discountIdentifierManager = CreateObject("component","components.programs.discount_identifier.discountidentifier")>
		<tr>
			<TD class="label">
				<cfif discountIdentifierManager.discountIdentifierOn()>
					<B>Discount Identifier</B><BR>
					<CFPARAM NAME="FORM.Discount_Identifier" DEFAULT="0">
					<cfset qDiscountIdentifiers = discountIdentifierManager.getActive()>
					<SELECT NAME="Discount_Identifier">
						<OPTION VALUE="0">**ALL** Discount Identifier</OPTION>
						<CFLOOP QUERY="qDiscountIdentifiers">
							<OPTION VALUE="#trim(Discount_Identifier_ID)#"#IIF(trim(FORM.Discount_Identifier) EQ Discount_Identifier_ID, DE(" SELECTED"), DE(""))#>
								#trim(Discount_Identifier_Desc)#
							</OPTION>
						</CFLOOP>
					</SELECT>
				</cfif>
			</TD>
		</TR>
	</table>
	
	<!--- for Geography --->
	<table align="center" width="90%" cellpadding="1" cellspacing="0">
		<tr>
			<td class="header" align="left" colspan="3">
				#Ucase("Geography")#
			</td>
			<td width="10%">&nbsp;</td>
		</tr>
		<TR>			
			<TD class="label">
				#application.returned_customer_setting.zone_label_singular#<BR>
				<cfset divisionQry = cmpHandle.getClaimReportDivisions() >
				<CFPARAM NAME="FORM.Service_Zone_ID" DEFAULT="0">
				<SELECT NAME="Service_Zone_ID">
					<OPTION VALUE="0">**ALL** #application.returned_customer_setting.zone_label_plural#</OPTION>
					<cfloop query="divisionQry"><OPTION VALUE="#trim(Service_Zone_ID)#"#IIF(trim(FORM.Service_Zone_ID) EQ Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(Zone_Name)#</OPTION></cfloop>
				</SELECT>
			</TD>	
			<TD class="label">
				#application.returned_customer_setting.region_label_singular#<BR>
				<cfset regionQry = cmpHandle.getClaimReportRegions() >
				<CFPARAM NAME="FORM.Service_Region_ID" DEFAULT="0">
				<SELECT NAME="Service_Region_ID">
					<OPTION VALUE="0">**ALL** #application.returned_customer_setting.region_label_plural#</OPTION>
					<CFLOOP QUERY="regionQry"><OPTION VALUE="#trim(Service_Region_ID)#"#IIF(trim(FORM.Service_Region_ID) EQ Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(Region_Name)#</OPTION></CFLOOP>
				</SELECT>
			</TD>
			<TD class="label">
				#application.returned_customer_setting.market_label_singular#<BR>
				<cfset territoriesQry = cmpHandle.getClaimReportTerritories() >
				<CFPARAM NAME="FORM.Service_Market_ID" DEFAULT="0">
				<SELECT NAME="Service_Market_ID">
					<OPTION VALUE="0">**ALL** #application.returned_customer_setting.market_label_plural#</OPTION>
					<CFLOOP QUERY="territoriesQry"><OPTION VALUE="#trim(Service_Market_ID)#"#IIF(trim(FORM.Service_Market_ID) EQ Service_Market_ID, DE(" SELECTED"), DE(""))#>#trim(Market_Name)#</OPTION></CFLOOP>
				</SELECT>
			</TD>
		</TR>
		<tr>
			<td class="header" align="left" colspan="3">
				#Ucase("Ownership")#
			</td>
		</tr>
		<!--- ownership --->
		<!---Gets application settings--->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
		<cfset userPositionManager = CreateObject("component", "components.general.UserPositionManager").init() />
		<TR>
			<cfif NOT appSettings.getDistributorMultiPosition()>
			<TD>
			<!------ user position -------->
				<CFSET User_Position_Operator_List = "Created By, Requesting Approval By,Approved By" />
				<span ID="searchItemLabel"><B>Billback</B></span><BR>				
				<SELECT ID="User_Position_Operator" NAME="User_Position_Operator" style="width:200px">
					<CFLOOP LIST="#User_Position_Operator_List#" INDEX="This_Op">
						<CFOUTPUT><OPTION VALUE="#Trim(This_Op)#">#This_Op#</OPTION></CFOUTPUT>
					</CFLOOP>
				</SELECT>
			</TD>	
			<TD>
				<cfset usersAndPositions = userPositionManager.getUsersAndPositions() />
				<span ID="searchItemLabel"><B><CFOUTPUT>User Name</CFOUTPUT><!--- User Position ---></B></span><BR>				
				<SELECT NAME="User_Position_Of" onChange="javaScript:disableSelect(this,this.form.User_Position,true);" style="width:200px">
					<OPTION VALUE="" SELECTED>**ALL** Users</OPTION>
					<cfloop QUERY="usersAndPositions">
						<OPTION VALUE="#trim(User_Positions_ID)#">#trim(User_Name)#</OPTION>
					</cfloop>
				</SELECT>
			</TD>
			<TD>
				<cfset userPositions = userPositionManager.getUserPositions() />
				<span ID="searchItemLabel"><B><CFOUTPUT>User Position</CFOUTPUT><!--- User Position ---></B></span><BR>				
				<SELECT NAME="User_Position" onChange="javaScript: disableSelect(this,this.form.User_Position_Of,false);" style="width:200px">
					<OPTION VALUE="" SELECTED>**ALL** User Positions</OPTION>
 					<CFLOOP QUERY="userPositions">
						<OPTION VALUE="#trim(User_Positions_ID)#">#trim(Position_Label)#</OPTION>
					</CFLOOP>
				</SELECT>
			</TD>
			</cfif>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</TR>
		<br>
		<tr>
			<td colspan="3">
				<HR align="center" COLOR="Orange" SIZE="1">
			</td>
			<td width="10%">&nbsp;</td>
		</tr>
	</table>

	<!--- group by ---->
	<!--- 	c:	region
			v:	program
			t:	customer
			p:	region and customer
			s:	region and customer
	--->
	<table width="90%" align="center">
		<tr>
			<td class="label" nowrap>
				Group By:	
			</td>
			<td class="labelWithNoBold">
				<input type="checkbox" name="reportGrp" id="reportGrp"   value="1" <cfif ListFind(cmpHandle.getClaimReportGroupByList(trim(reportType)), 1) GT 0>checked</cfif> disabled>Program
			</td>
			<td class="labelWithNoBold">
				<input type="checkbox" name="reportGrp" id="reportGrp"   value="2" <cfif ListFind(cmpHandle.getClaimReportGroupByList(trim(reportType)), 2) GT 0>checked</cfif> disabled>Region
			</td>
			<td class="labelWithNoBold">
				<input type="checkbox" name="reportGrp" id="reportGrp"   value="3" <cfif ListFind(cmpHandle.getClaimReportGroupByList(trim(reportType)), 3) GT 0>checked</cfif> disabled><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>
			</td>
			<td width="10%" class="labelWithNoBold" nowrap><span style="color:gray">( view only )</span></td>			
			<td align="left" width="<cfif isExcelGeneratorEnabled >10%<cfelse>55%</cfif>">
					<CF_BUTTON
					BUTTON_NAME		=	""
					BUTTON_CAPTION	=	"show report"
					BUTTON_ACTION	=	"confirmData(document.claimForm, '#reportType#', 'html');"
					BUTTON_TYPE		=	"javascript_link"
					BUTTON_WIDTH	=	"150"
					BUTTON_COLOR	=	"Navy"
					BUTTON_TIP		=	""
					FONT_COLOR		=	"White"
					FONT_SIZE		=	"12"
					FONT_WEIGHT		=	"bold">
					<input type="hidden" name="selectedUser" value=""> 
				</td>
				<cfif isExcelGeneratorEnabled >
					<td align="left" width="65%">
						<CF_BUTTON
						BUTTON_NAME		=	""
						BUTTON_CAPTION	=	"generate excel"
						BUTTON_ACTION	=	"confirmData(document.claimForm, '#reportType#', 'csv');"
						BUTTON_TYPE		=	"javascript_link"
						BUTTON_WIDTH	=	"150"
						BUTTON_COLOR	=	"Navy"
						BUTTON_TIP		=	""
						FONT_COLOR		=	"White"
						FONT_SIZE		=	"12"
						FONT_WEIGHT		=	"bold">
					</td>
				</cfif>
		</tr>
	</table>
	<script>
		disable_Comparsion_Operators();
	</script>
	<input type="hidden" id="reportType" name="reportType" value="">
	</form>
	</CFOUTPUT>
</body>
</html>

<script>
	function confirmData(thisForm, report_type, output_type)
	{
		//set action
		thisForm.reportType.value = output_type;
		var allClear = true;
		var oldTarget = thisForm.target;
		if (output_type == 'html' ) thisForm.target = "claimForm";
		else {
				var  answer = confirm('This may take some time. Do you want to continue?');
				if (answer == false)	return false;
		}
		if (output_type == 'html' )  NewWindow('', 'claimForm', '800','550','Yes', 'Yes');
		thisForm.action = "/reportWriter/claimSummary.cfm?reportType=" + report_type;
		thisForm.submit();
		thisForm.target = oldTarget;		
		return allClear;
	}
	
	function disableSelect(sel1, sel2, findProperVal)
	{
		var selInd = 0;
		if(findProperVal)
		{
			selInd = Get_Select_Index(sel2, sel1.value);
			sel2.selectedIndex = selInd;
		}
		else
		{
			if(sel1.selectedIndex > 0)
			{
				sel2.selectedIndex = selInd;
			}
		}
		document.all.item("selectedUser").value = sel1.options[sel1.selectedIndex].label;
	}
</script>

