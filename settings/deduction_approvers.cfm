<BODY BGCOLOR="WhiteSmoke">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=32>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR><BR>

<cfquery name="getAuthorizedApprovers" datasource="#application.datasource#">
	SELECT *
	FROM Personnel_Detail
	Order By Personnel_last_name
</cfquery>

<cfquery name="getDeductionRangeAssignments" datasource="#application.datasource#">
	SELECT     dbo.Deduction_Cost_Range_Assignments.Range_Min, dbo.Deduction_Cost_Range_Assignments.Range_Max,dbo.Deduction_Cost_Range_Assignments.Setting_Last_Updated, 
	                      dbo.Deduction_Cost_Range_Assignments.User_ID, dbo.Deduction_Cost_Range_Assignments.Deduction_Cost_Range_Assignment_ID, 
	                      dbo.personnel_detail.personnel_first_name, dbo.personnel_detail.personnel_last_name
	FROM         dbo.Deduction_Cost_Range_Assignments INNER JOIN
	                      dbo.personnel_detail ON dbo.Deduction_Cost_Range_Assignments.User_ID = dbo.personnel_detail.personnel_detail_id
</cfquery>

<script>
function getAttributesWindow(title, debugObject) {
	/* lists all the attributes associated with debugObject in a separate window */
	msgWindow = window.open('','attributeWindow','');
	msgWindow.document.write('<' + 'SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">\n');
	msgWindow.document.write('function stopError() {return true}\n');
	msgWindow.document.write('window.onerror = stopError;\n');
	msgWindow.document.write('<' + '/SCRIPT>\n');
	msgWindow.document.write('&lt;' + title + '&gt;\n<OL>\n');
	for(var i in debugObject) {
		var valueString = debugObject[i];
		if(typeof(valueString) == 'object') {
			var strValueString = '"' + valueString + '"';
			msgWindow.document.write('\t<LI CLASS="OITEM">' + strValueString + ' <b>[' + i + ']</b><OL TYPE="a">\n');
			if(strValueString!='"null"') {
				// for(var j in debugObject) {
					// valueString2 = debugObject[j];
					// if(typeof(valueString2) == 'string') {
						// var ltRE = new RegExp(String.fromCharCode(60), "g");
						// if(valueString2.match(ltRE)) {valueString2 = valueString2.replace(ltRE, "&lt;");}
						// var gtRE = new RegExp(String.fromCharCode(62), "g");
						// if(valueString2.match(gtRE)) {valueString2 = valueString2.replace(gtRE, "&gt;");}
						// }
					// msgWindow.document.write('\t\t<LI CLASS="OITEM">"' + valueString2 + '" <b>' + i + '.' + j + '</b></LI>\n');
					// }
				}
			msgWindow.document.write('</OL></LI>\n');
			}
		else {
			if(typeof(valueString) == 'string') {
				var ltRE = new RegExp(String.fromCharCode(60), "g");
				if(valueString.match(ltRE)) {valueString = valueString.replace(ltRE, "&lt;");}
				var gtRE = new RegExp(String.fromCharCode(62), "g");
				if(valueString.match(gtRE)) {valueString = valueString.replace(gtRE, "&gt;");}
				}
			msgWindow.document.write('\t<LI CLASS="OITEM">"' + valueString + '" <b>' + i + '</b></LI>\n');
			}
		}
	msgWindow.document.write('</OL>\n');
	}

	var currentStartOfRange = "0.00";
	var lastInsertedRowObject = new Object(); //hold row object of last inserted row
	
	function userWantsToAddRange() {
		
		if(document.all.ListApprovers_SELECT.selectedIndex != 0){
			
			if(lastInsertedRowObject.all == null){ //dont error check if no rows exist
				addRangeRowToTable()
			}
			else{
				if(verifyPriorRangeRow()){
					addRangeRowToTable()
				}
			}
		}
		else {
			alert("Please Select A User")
		}
	} 

	function verifyPriorRangeRow(){
		if(lastInsertedRowObject.all.rangeMin.value.length == 0){
			alert("Please Enter Minimum Range Value")
			return false;
		}
		else{
			if(lastInsertedRowObject.all.rangeMax.value.length == 0){
				alert("Please Enter Maximum Range Value")
				return false;
			}
			else{
				if(lastInsertedRowObject.all.rangeMax.value != "*"){
					if(parseFloat(lastInsertedRowObject.all.rangeMin.value) >= parseFloat(lastInsertedRowObject.all.rangeMax.value)){
						alert("Please Enter A Maximum Value Greater Than The Minimum Value")				
					}
					else{
						//verifyConcurentRanges()
						//currentStartOfRange = parseFloat(lastInsertedRowObject.all.rangeMax.value) +1
						return true;
					}
				}
				else{
					return false;
				}				
			}
		}	

	}
	
	function verifyConcurentRanges(){
		oTable = document.all.rangeDisplayTable;
		for(var x=2; x< oTable.rows.length; x++){
			previoustRow = oTable.rows[x-1].all
			currentRow = oTable.rows[x].all
			if(parseFloat(previoustRow.rangeMax.value) > parseFloat(currentRow.rangeMin.value)){
				currentRow.rangeMin.value = parseFloat(previoustRow.rangeMax.value) + 1
			}
			rowdelta = parseFloat(parseFloat(currentRow.rangeMin.value) - parseFloat(previoustRow.rangeMax.value));
			if(rowdelta > 0) {
				currentRow.rangeMin.value = parseFloat(previoustRow.rangeMax.value) + 1
			}
		}
	}
	
	function addRangeRowToTable() {
		clearLastFlaggedRow()
	
		tempVar = document.all.rangeDisplayTable.rows.length/2 + " "
		if(tempVar.indexOf(".") == -1){
			rowColor = "C6FFC6"
		}
		else{
			rowColor = "ffffff"
		}
		tempRow = document.all.rangeDisplayTable.insertRow();
		tempRow.bgColor = rowColor;
		tempRow.userid = document.all.ListApprovers_SELECT.options[document.all.ListApprovers_SELECT.selectedIndex].value
		tempRow.userSelectedIndex = document.all.ListApprovers_SELECT.selectedIndex;
		tempRow.onclick=selectUserFromRow;

		flagCell = tempRow.insertCell()
		flagCell.id = "FlagCell"
		flagCell.align = "center"
		flagCell.vAlign = "middle"
		flagCell.innerHTML = "&nbsp;"
		
		cellOne = tempRow.insertCell();
		cellOne.innerHTML = document.all.ListApprovers_SELECT.options[document.all.ListApprovers_SELECT.selectedIndex].innerText
		cellTwo = tempRow.insertCell();
		cellTwo.innerHTML = "<input type='text' name='rangeMin' id='rangeMin' size='4' value='"+ currentStartOfRange + "'>"

		cellThree = tempRow.insertCell();
		cellThree.innerHTML = "<input type='text' name='rangeMax' id='rangeMax' size='4'>"
		
		lastInsertedRowObject = tempRow;
	}
		
	oRow = new Object();
	function selectUserFromRow(){
		oRow = event.srcElement.parentElement
		document.all.ListApprovers_SELECT.selectedIndex = oRow.userSelectedIndex
		makeActiveRow(oRow)
	}

	var LastFlaggedRow = new Object();
	LastFlaggedRow.id = "proto";
	function makeActiveRow(oRow){
		
		if(oRow.tagName=="TR"){
		clearLastFlaggedRow()
		oRow.cells['FlagCell'].innerHTML = "<font color='red'>*</font>"
		LastFlaggedRow = oRow
		}
		if(oRow.tagName=="TD"){
		clearLastFlaggedRow()
		oRow.parentElement.cells['FlagCell'].innerHTML = "<font color='red'>*</font>"
		LastFlaggedRow = oRow.parentElement
		}
		
	}

	function clearLastFlaggedRow(){
		if(LastFlaggedRow.id != "proto"){
			//getAttributesWindow('',LastFlaggedRow)
			LastFlaggedRow.cells['FlagCell'].innerHTML = "&nbsp;";
		}
	}
	
	function updateRangeUser(){
		if(oRow.userid != null){
			oRow.userid = document.all.ListApprovers_SELECT.options[document.all.ListApprovers_SELECT.selectedIndex].value
			oRow.userSelectedIndex = document.all.ListApprovers_SELECT.selectedIndex
			oRow.cells[1].innerHTML = document.all.ListApprovers_SELECT.options[document.all.ListApprovers_SELECT.selectedIndex].innerText
		}
	}

	function buildFormForSubmital(){
		oTable = document.all.rangeDisplayTable;
		for(var x=1; x< oTable.rows.length; x++){
			currentRow = oTable.rows[x]

			tempHiddenElement = document.createElement("INPUT")
			tempHiddenElement.name = "USER_" + x + "_" + currentRow.userid
			tempHiddenElement.type = "hidden"
			tempHiddenElement.value = currentRow.userid
			document.theForm.insertBefore(tempHiddenElement);

			tempHiddenElement = document.createElement("INPUT")
			tempHiddenElement.name = "USER_" + x + "_" + currentRow.userid+"_rangemin"
			tempHiddenElement.type = "hidden"
			tempHiddenElement.value = currentRow.all.rangeMin.value
			document.theForm.insertBefore(tempHiddenElement);

			tempHiddenElement = document.createElement("INPUT")
			tempHiddenElement.name = "USER_" + x + "_" + currentRow.userid+"_rangemax"
			tempHiddenElement.type = "hidden"
			tempHiddenElement.value = currentRow.all.rangeMax.value
			document.theForm.insertBefore(tempHiddenElement);

			if(currentRow.existingrecordid != null){
				tempHiddenElement = document.createElement("INPUT")
				tempHiddenElement.name = "USER_" + x + "_" + currentRow.userid+"_recordid"
				tempHiddenElement.type = "hidden"
				tempHiddenElement.value = currentRow.existingrecordid
				document.theForm.insertBefore(tempHiddenElement);
			}

			
			document.theForm.submit()
			//currentRow.rangeMin.value
			//currentRow.rangeMax.value
		}
	}
</script>
<script src="/common_files/scripts/formattotwodecimals.js"></script>
<script src="/common_files/scripts/numberValidation.js"></script>


<CFIF getDeductionRangeAssignments.recordcount EQ 0>
<CFELSE>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(getDeductionRangeAssignments.Setting_Last_Updated, 'm/d/yyy')# #timeformat(getDeductionRangeAssignments.Setting_Last_Updated, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
</CFIF>
<style type="text/css">
		body, table, td
		{font-family: Arial; font-size: 12px;}
		.data
		{font-size: 12px; font-weight: bold}
		select, TEXTAREA
		{width:	200px;font-size: 10px;}
		TEXTAREA
		{width:	400px;font-size: 10px;}

		TABLE.Maintable TD
		{border-bottom:solid #93BEE2 1px; font-size : 10px;}

		Maintable
		{cellspacing: 0;}

		header
		{font-size: 12px;}
</style>

<B>
To Add A New Range: 1) Select User 2) Press Add Range<br>
<br>
To Modify Range Assignment: 1) Select Row  2) Make Changes In Select Boxes 3) Press Change User<br>
</B>
<BR><BR>	

<table CLASS="Maintable" border="0" cellspacing="0" cellpadding="1">
	<TR VALIGN="bottom" BGCOLOR="#FFCE84">
		<TD id="header"><b>User</b></TD>
		<TD>&nbsp;</TD>
	</TR>
	<TR VALIGN="bottom">
		<TD>
			<select name="ListApprovers_SELECT" id="ListApprovers_SELECT">
				<option value="0">Select One...</option>
				<cfset ListOfUser = "">
				<cfset ListOfUserSelectIndex = "">
				<cfoutput query="getAuthorizedApprovers">
					<cfset ListOfUser = listappend(ListOfUser, getAuthorizedApprovers.personnel_detail_ID)>
					<cfset ListOfUserSelectIndex = listappend(ListOfUserSelectIndex, currentrow)>
					
					<option value="#getAuthorizedApprovers.personnel_detail_ID#">#getAuthorizedApprovers.personnel_last_name#, #getAuthorizedApprovers.personnel_first_name#</option>
					
				</cfoutput>
			</select>
		</TD>
		<TD>
		<input type="button" value="Add Range" onclick="userWantsToAddRange()">
		<!--- <input type="button" value="Check Ranges" onclick="verifyConcurentRanges()">
		 ---><input type="button" value="Change User" onclick="updateRangeUser()">
		
		</TD>
</TABLE>


<br>



<table border="0" cellspacing="0" cellpadding="0" class="Maintable" id="rangeDisplayTable" width="300">
	<TR VALIGN="bottom" BGCOLOR="#FFCE84">
		<TD width="10">&nbsp;</TD>
		<TD id="header"><b>User</b></TD>
		<TD id="header"><b>Range Low</b></TD>
		<TD id="header"><b>Range High</b></TD>
	</TR>
	<CFOUTPUT query="getDeductionRangeAssignments">
		<cfset selectedIndex = listgetat(ListOfUserSelectIndex, listfind(ListOfUser,getDeductionRangeAssignments.user_id))>
		<TR existingrecordid="#getDeductionRangeAssignments.Deduction_Cost_Range_Assignment_ID#" userid="#getDeductionRangeAssignments.user_id#" userSelectedIndex="#selectedIndex#" onclick="selectUserFromRow()" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD id="FlagCell" align="center" valign="middle">&nbsp;</TD>
			<TD>#getDeductionRangeAssignments.personnel_last_name#, #getDeductionRangeAssignments.personnel_first_name#</TD>
			<TD><input type='text' name='rangeMin' id='rangeMin' value='#trim(numberformat(getDeductionRangeAssignments.range_min,'___________.__'))#' size='4' onkeyup="nextBox(this, 'NONE', 100);" onchange="formattotwodecimals(this)"></TD>
			<TD><input type='text' name='rangeMax' id='rangeMax' value='<cfif getDeductionRangeAssignments.range_max NEQ "*">#trim(numberformat(getDeductionRangeAssignments.range_max,'___________.__'))#<cfelse>*</cfif>' size='4' onkeyup="nextBox(this, 'NONE', 100);" onchange="formattotwodecimals(this)"></TD>
		</TR>
	</CFOUTPUT>
</table>
<br>
<input type="button" value="save" onClick="buildFormForSubmital()">
<form action="deduction_approvers_action.cfm" method="post" name="theForm" id="theForm">

</form>



</BODY>
