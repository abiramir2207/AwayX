 <html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<script src="/reportWriter/claimReport.js"></script>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<body leftmargin="0" rightmargin="0">
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
	<!--- for BillBack --->
	<form id="claimForm" name="claimForm" method="post" target="_self" action="billbackApprovalTable.cfm">
	<table align="center" width="90%" cellpadding="1" cellspacing="1">
		<tr>
			<td class="header" align="left" colspan="3">
				#Ucase("Billback")#
			</td>
			<td width="10%">&nbsp;</td>
		</tr>
		<tr>
			<td class="label" height="40">
				Billback No<br><input type="text" name="billbackNo" size="20">
             </td>
			<td class="label" height="40">Billback Title<br><input type="text" name="billbackTitle" size="20"></td>
			<td class="label" height="40">Program No<br><input type="text" name="programNumber" size="20"></td>
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
					<SPAN ID="SP_Start_date">
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
			<td class="label" height="20">
				Customer Name<BR>
				<input name="custName" id="custName" type="text" align="left" size="40" maxlength="50" value="">
			</td>
			<td class="label" height="20">
				Customer No<br>
				<input name="custNo" id="custNo" type="text" align="left" size="40" maxlength="50" value="">
			</td>
			<td class="label" height="20">
				Approver<br>
				<input name="approver" id="approver" type="text" align="left" size="40" maxlength="50" value="">	
			</td>
		</tr>
		<tr>
			<td class="label" height="20">
				Deviation Amount<br>
				<table>
					<tr>
						<td>
							<SELECT OnChange="JavaScript: GTE_Operator(5,this);" NAME="deviationAmountOperator" ID="deviationAmountOperator" STYLE="WIDTH:45; height:45">	
									<OPTION VALUE="" SELECTED></OPTION>
									<OPTION VALUE="Greater_Or_Equal">>=</OPTION>
									<OPTION VALUE="Equal">=</OPTION>
									<OPTION VALUE="Less_Or_Equal"><=</OPTION>
							</SELECT>
						</td>
						<td>
							<SPAN ID="SP_Deviation_Amount">
								<input name="deviationAmount" id="deviationAmount" type="text" align="left" size="30" maxlength="50" value="">
							</SPAN>
						</td>
					</tr>
				</table>
			</td>
			<td class="label">
				Total Paid Amount<BR>
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
				</table>
			</td>
			<td class="label" height="20">
				Claim Status<BR>
				<cfset claimStatusQry = cmpHandle.getApprovedClaimProgramStatus() >
				<SELECT NAME="claimStatus" STYLE="WIDTH:200px">
					<OPTION VALUE="0" #IIF(trim(FORM.Program_Status) EQ 0, DE(" SELECTED"), DE(""))#>ALL</OPTION>
					<CFLOOP QUERY="claimStatusQry"><OPTION VALUE="#trim(Billback_Status_ID)#"#IIF(trim(FORM.Program_Status) EQ Billback_Status_ID, DE(" SELECTED"), DE(""))#>#trim(BB_Status_Description)#</OPTION></CFLOOP>
				</SELECT>
			</td>
		</tr>
	</table>
	<!--- group by ---->
	<!--- 	c:	region
			v:	program
			t:	customer
			p:	region and customer
			s:	region and customer
	--->
	<script>
		disable_Comparsion_Operators(1);
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

