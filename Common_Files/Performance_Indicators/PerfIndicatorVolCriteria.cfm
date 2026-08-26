<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<style>
		.Criteria
		{
			background-color:white;
			color: Blue;
			font-size:12;
			font-weight:bold;
		}
	</style>
</head>

<body>
	<script src="/Common_Files/createList.js"  language="JavaScript"></script>
	<cfparam name="form.perfIndicVolOperator" default=">=">
	<cfparam name="form.perfIndicTimeOperator" default=">=">
	<cfparam name="form.perfIndicIndexOperator" default=">=">
	<cfoutput>
	<CFSET cmpCriteriaHandle = CreateObject("component", "components.programs.performance_indicator.perfIndicatorVolCriteria") />
	<cfset contractTypesQry = cmpCriteriaHandle.ListContractStatusTypes() >
	<CFSET Date_Operators=" ,>=,=,<=">
	<CFSET Date_Operator_Symbols=" ,>=,=,<=">
	<table id="oTable" cellpadding="2" cellspacing="6" width="85%">
		<tr>
			<td class="Criteria" nowrap>
				Program Status
				<select name="programStatus" id="programStatus" onChange="javascript:deleteRows(1,programStatus.options[programStatus.selectedIndex].text,0);">
					<option value="0">Select Status Type</option>
					<cfloop query="contractTypesQry">
						<option value="#Contract_Status_Type_ID#">#Trim(Contract_Status_Type_Desc)#</option>
					</cfloop>
				</select>
			</td>
			<td>&nbsp;</td>
			<td class="Criteria" nowrap>
				Volume 
				 <SELECT  NAME="perfIndicVolOperator" ID="perfIndicVolOperator" STYLE="WIDTH:45px">
					<CFSET cnt=0>
					<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#"<CFIF perfIndicVolOperator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
				</SELECT>
				<!---- deleteRows(1,perfIndicVolOperator.options[perfIndicVolOperator.selectedIndex].text,document.item('volText').value); --->
				<input align="right" name="volText" id="volText" type="text" value="0" size="2" width="2" onKeyUp="javascript:if(event.keyCode==13){deleteRows(2,perfIndicVolOperator.options[perfIndicVolOperator.selectedIndex].text,document.getElementById('volText').value);}" >%
			</td>
			<td>&nbsp;</td>
			<td class="Criteria" nowrap>
				Time 
				<SELECT  NAME="perfIndicTimeOperator" ID="perfIndicTimeOperator" STYLE="WIDTH:45px">
					<CFSET cnt=0>
					<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#"<CFIF perfIndicTimeOperator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
				</SELECT> 
				<input align="right" name="timeText" id="volText" type="text" value="0" size="2" width="2" onKeyUp="if(event.keyCode==13){deleteRows(3,perfIndicTimeOperator.options[perfIndicTimeOperator.selectedIndex].text,document.getElementById('timeText').value);}" >%
			</td>
			<td>&nbsp;</td>
			<td class="Criteria" nowrap>
				Index
				<SELECT  NAME="perfIndicIndexOperator" ID="perfIndicIndexOperator" STYLE="WIDTH:45px">
					<CFSET cnt=0>
					<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#"<CFIF perfIndicIndexOperator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
				</SELECT> 
				<input align="right" name="indexText" id="volText" type="text" value="0" size="2" width="2" onKeyUp="if(event.keyCode==13){deleteRows(0,perfIndicIndexOperator.options[perfIndicIndexOperator.selectedIndex].text,document.getElementById('indexText').value);}" >%
			</td>
		</tr>
	</table>
	</cfoutput>
</body>
</html>
<script>
	function deleteRows(cellIndex, operator, comparedVolume) {
		var deleteObjs = new Array(1);
		
		if (cellIndex == 1) 
		{
			selectedStatusType = operator;
			for (i=1; i < document.all.oVolTable.rows.length; i++) {
				if (getMatchedStatus(trim(selectedStatusType), trim(oVolTable.rows(i).cells(1).innerText)) < 0)
					deleteObjs.push(i);
			}
		}
		else
			for (i=1; i < document.all.oVolTable.rows.length; i++) {
					Vol = getVol(oVolTable.rows(i).cells(cellIndex).innerText);	
					if (trim(operator) == "=" && parseInt(Vol)  != parseInt(comparedVolume))
						deleteObjs.push(i); 	
					else if (trim(operator) == ">=" &&  parseInt(Vol) < parseInt(comparedVolume) )
						deleteObjs.push(i);
					else if (trim(operator) == "<=" && 	parseInt(Vol)  > parseInt(comparedVolume))
						deleteObjs.push(i);
			}
		deleteLength = deleteObjs.length;
		for (i=0; i < deleteLength - 1; i++)
			deleteRow(deleteObjs.pop());
	}

	function deleteRow(rowIndex) {
		document.all.oVolTable.deleteRow(rowIndex);
	}
	
	function getVol(volCellData) {
		var matchPattern = new RegExp("(.*)%", "g");
		matched = matchPattern.exec(volCellData);
		return(RegExp.$1);
	}
	
	function getMatchedStatus(statusType, programCellData) {
		var findStr = statusType + " [";
		return(programCellData.indexOf(findStr));
	
	}
</script>
