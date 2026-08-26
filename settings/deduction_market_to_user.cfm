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

<!--- <CFQUERY NAME="Get_Market_Area" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Market_Area
	FROM BSA_Foodservice_Brokers
	WHERE deleted = 0
</CFQUERY> --->

<CFQUERY NAME="Get_Market_Area" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT *
	FROM Market_Areas
</CFQUERY>

<cfquery name="getPersonnel" datasource="#application.datasource#">
	SELECT PERSONNEL_FIRST_NAME, PERSONNEL_LAST_NAME, PERSONNEL_DETAIL_ID
	FROM personnel_detail
	WHERE personnel_function_id >= 8000 and personnel_function_id < 9000 
	ORDER BY getPersonnel.PERSONNEL_LAST_NAME
</cfquery>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>

<SCRIPT>
	
	function saveForm(){
		if(!validateMARKET_AREA_SELECTBOX()) return false
		if(!validatePERSONNEL_DETAIL_ID_SELECTBOX()) return false
		return true
	}
	
	function validateMARKET_AREA_SELECTBOX() {
		if(document.all.MARKET_AREA_SELECTBOX.value == 0){
			alert("ENTER ALERT TEXT FOR MARKET_AREA_SELECTBOX")
			return false
		}
		else {
			return true
		}
	}

	function validatePERSONNEL_DETAIL_ID_SELECTBOX() {
		if(document.all.PERSONNEL_DETAIL_ID_SELECTBOX.value == 0){
			alert("ENTER ALERT TEXT FOR PERSONNEL_DETAIL_ID_SELECTBOX")
			return false
		}
		else {
			return true
		}
	}
	
	
	var marketAreaText="";
	var marketArea_ID=""	
	var userName="";
	var currentSelectedMarketArea = new Object();
	var currentSelectedUser = new Object();
	var marketAreaTextSelectIndex=""
	var userNameSelectIndex=""
	var currentRow = new Object();
	
	
	function storeMarketArea(){
		currentSelectedMarketArea = event.srcElement.options[event.srcElement.selectedIndex];
		marketAreaText = event.srcElement.options[event.srcElement.selectedIndex].innerText;
		marketArea_ID = event.srcElement.options[event.srcElement.selectedIndex].value;
		marketAreaTextSelectIndex = event.srcElement.selectedIndex
	}

	function storeUserInfo(){
		currentSelectedUser = event.srcElement.options[event.srcElement.selectedIndex];
		userName = event.srcElement.options[event.srcElement.selectedIndex].innerText;
		userNameID = event.srcElement.options[event.srcElement.selectedIndex].value
		userNameSelectIndex = event.srcElement.selectedIndex
	}

	
	function initPage(){
		document.all.MARKET_AREA_SELECTBOX.onchange=storeMarketArea
		document.all.PERSONNEL_DETAIL_ID_SELECTBOX.onchange=storeUserInfo
	}
	
	function addUserToList(){
		tempVar = document.all.assignmentList.rows.length/2 + " "
		if(tempVar.indexOf(".") == -1){
			rowColor = "C6FFC6"
		}
		else{
			rowColor = "ffffff"
		}
		if(document.all.MARKET_AREA_SELECTBOX.value != 0 && document.all.PERSONNEL_DETAIL_ID_SELECTBOX.value != 0)	{
			clearLastFlaggedRow()
			/*
			if(currentSelectedUser.hasBeenUsed == 1){
				alert("This User Already Has A Market Assignment")
				return false
			} 
			*/

			if(currentSelectedMarketArea.hasbeenused == 1){
				alert("This Market Area Is Assigned")
				return false
			} 
			
			currentSelectedMarketArea.hasbeenused = 1
			currentSelectedUser.hasbeenused = 1
			
			var tempRow = new Object();
			
			tempRow = document.all.assignmentList.insertRow()
			tempRow.onclick=editMarketRow
			tempRow.bgColor = rowColor;
			tempRow.deleteassignment=0
			tempRow.marketarea = marketArea_ID
			tempRow.marketareaselectindex = marketAreaTextSelectIndex
			tempRow.username = userName
			tempRow.usernameid = userNameID
			tempRow.usernameidselectindex = userNameSelectIndex
			tempRow.recid=0
			

			flagCell = tempRow.insertCell()
			flagCell.id = "FlagCell"
			flagCell.align = "center"
			flagCell.vAlign = "middle"
			flagCell.innerHTML = "&nbsp;"

			cellOne = tempRow.insertCell()
			cellOne.innerText = marketAreaText
			cellTwo = tempRow.insertCell()
			cellTwo.innerText = tempRow.username
			cellThree = tempRow.insertCell()
			cellThree.innerHTML = "<input NAME='marketsToDelete' type='checkbox' onclick='deleteMarketAssignment(this)'>"
		}
	}
	
	
	function updateCurrentRow(){

		if(currentSelectedMarketArea.hasbeenused == 1 && currentSelectedMarketArea.index != currentRow.marketareaselectindex){
			alert("This Market Area Is Assigned")
			return false
		}

		if(document.all.MARKET_AREA_SELECTBOX.value != 0 && document.all.PERSONNEL_DETAIL_ID_SELECTBOX.value != 0)	{		
			
			document.all.MARKET_AREA_SELECTBOX.options[currentRow.marketareaselectindex].hasbeenused=0
			currentSelectedMarketArea.hasbeenused=1
			currentRow.marketarea = marketArea_ID
			currentRow.marketareaselectindex = marketAreaTextSelectIndex
			currentRow.username = userName
			currentRow.usernameid = userNameID
			currentRow.usernameidselectindex = userNameSelectIndex
			currentRow.cells[1].innerText = currentSelectedMarketArea.innerText
			currentRow.cells[2].innerText = currentSelectedUser.innerText
		}
	}

	function editMarketRow(){
		currentRow = event.srcElement.parentElement
		document.all.PERSONNEL_DETAIL_ID_SELECTBOX.selectedIndex = currentRow.usernameidselectindex
		document.all.MARKET_AREA_SELECTBOX.selectedIndex = currentRow.marketareaselectindex

		document.all.MARKET_AREA_SELECTBOX.fireEvent("onchange")
		document.all.PERSONNEL_DETAIL_ID_SELECTBOX.fireEvent("onchange")
		makeActiveRow(event.srcElement)
	}
	
	function buildForm(){
		for(var x=0; x<document.all.assignmentList.rows.length; x++){
			theRow = document.all.assignmentList.rows[x]
			if(theRow.username != null){
				if(theRow.deleteassignment != 1){
					tempHiddenElement = document.createElement("INPUT")
					tempHiddenElement.name = "data" + x + "_user"
					tempHiddenElement.type = "hidden"
					tempHiddenElement.value = theRow.usernameid
					document.theForm.insertBefore(tempHiddenElement);
	
					tempHiddenElement = document.createElement("INPUT")
					tempHiddenElement.name = "data" + x + "_market"
					tempHiddenElement.type = "hidden"
					tempHiddenElement.value = theRow.marketarea				
					document.theForm.insertBefore(tempHiddenElement);
					
					tempHiddenElement = document.createElement("INPUT")
					tempHiddenElement.name = "data" + x + "_recid"
					tempHiddenElement.type = "hidden"
					tempHiddenElement.value = theRow.recid				
					document.theForm.insertBefore(tempHiddenElement);
				}
				else{
					tempHiddenElement = document.createElement("INPUT")
					tempHiddenElement.name = "delete_recid"
					tempHiddenElement.type = "hidden"
					tempHiddenElement.value = theRow.recid				
					document.theForm.insertBefore(tempHiddenElement);
				}
			}
		}
		document.all.theForm.submit()
	}
	
	function deleteMarketAssignment(oCheckbox){
	if(oCheckbox.checked){
		if(oCheckbox.parentElement.parentElement.recid == 0){
			document.all.MARKET_AREA_SELECTBOX.options[oCheckbox.parentElement.parentElement.marketareaselectindex].hasbeenused=0
			document.all.assignmentList.deleteRow(oCheckbox.parentElement.parentElement.rowIndex)
		}
		else {
			oCheckbox.parentElement.parentElement.deleteassignment=1;
			alert("Market Assignment Will Be Deleted After You Save");
		}
	}
	else {
		if(oCheckbox.parentElement.parentElement.deleteassignment == 1){
			oCheckbox.parentElement.parentElement.deleteassignment == 0
		}
	}
	}

	var LastFlaggedRow = new Object();
	LastFlaggedRow.id = "proto";
	function makeActiveRow(oRow){
		if(oRow.tagName=="TD"){
		//alert(oRow.className)
		//oRow.parentElement.className = "active_row";
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
</SCRIPT>


<head>
	<title>Untitled</title>
</head>

<body ONLOAD="initPage()" BGCOLOR="Whitesmoke">

	<cfquery name="getMarketAssignments" datasource="#application.datasource#">
SELECT     dbo.deduction_market_to_user.Market_Area_ID, dbo.personnel_detail.personnel_first_name, dbo.personnel_detail.personnel_last_name, 
                      dbo.personnel_detail.personnel_detail_id, dbo.deduction_market_to_user.Company_Main_ID, 
                      dbo.deduction_market_to_user.deduction_market_to_user_ID, dbo.Market_Areas.Market_Area_Description,dbo.deduction_market_to_user.Setting_Last_Updated
FROM         dbo.deduction_market_to_user INNER JOIN
                      dbo.personnel_detail ON dbo.deduction_market_to_user.User_ID = dbo.personnel_detail.personnel_detail_id INNER JOIN
                      dbo.Market_Areas ON dbo.deduction_market_to_user.Market_Area_ID = dbo.Market_Areas.Market_Area_ID
	</cfquery>

<CFIF getMarketAssignments.recordcount EQ 0>
<CFELSE>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(getMarketAssignments.Setting_Last_Updated, 'm/d/yyy')# #timeformat(getMarketAssignments.Setting_Last_Updated, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
</CFIF>

<B>
To Assign A User To A Market Area: 1) Select Market Area 2) Select User 3) Press Add User<br>
<br>
To Modify A Market Area Assignment: 1) Select Row  2) Make Changes In Select Boxes3) Press Update User<br>
<br>
To Delete A Market Area Assignment: 1) Select Check Box On Far Right Next To The Assignment You Want TO Delete<br>
</B>
<BR><BR>	

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

<table CLASS="Maintable" border="0" cellspacing="0" cellpadding="1">
	<TR VALIGN="bottom" BGCOLOR="#FFCE84">
		<TD id="header"><b>Market Area</b></TD>
		<TD id="header"><b>User</b></TD>
		<TD id="header">&nbsp;</TD>
		<TD id="header">&nbsp;</TD>
	</TR>
	<TR>
		<TD>
			<cfset arrayOfSelectedMarkets = ArrayNew(1)>
			<cfloop query="getMarketAssignments">
				<cfset arrayOfSelectedMarkets[currentrow] = getMarketAssignments.Market_Area_ID>
			</cfloop>
			
			<SELECT NAME="MARKET_AREA_SELECTBOX">
				<OPTION VALUE="0">Select One...</OPTION>
				<cfset MarketAreaSelectboxIndexTracker = ArrayNew(2)>
				<cfloop query="Get_Market_Area">
					<cfset MarketAreaInUse = 0>
					<cfloop index="LoopCount" from="1" to="#ArrayLen(arrayOfSelectedMarkets)#" step="1">
						<cfif arrayOfSelectedMarkets[LoopCount] EQ Get_Market_Area.MARKET_AREA_ID>
							<cfset MarketAreaInUse = 1>
						</cfif>
					</cfloop>
		
				
					<CFSET MarketAreaSelectboxIndexTracker[currentrow][1] = currentrow>
					<CFSET MarketAreaSelectboxIndexTracker[currentrow][2] = Get_Market_Area.MARKET_AREA_ID>
		
					<cfoutput><OPTION VALUE="#Get_Market_Area.MARKET_AREA_ID#" hasbeenused="#MarketAreaInUse#">#Get_Market_Area.MARKET_AREA_Description#</OPTION></cfoutput>
				</cfloop>
			</SELECT>
		</TD>
		<TD>
			<SELECT NAME="PERSONNEL_DETAIL_ID_SELECTBOX">
				<OPTION VALUE="0">Select One...</OPTION>
				<cfset userNameSelectboxIndexTracker = ArrayNew(2)>
				<cfloop query="getPersonnel">
		
					<CFSET userNameSelectboxIndexTracker[currentrow][1] = currentrow>
					<CFSET userNameSelectboxIndexTracker[currentrow][2] = getPersonnel.PERSONNEL_FIRST_NAME & " " & getPersonnel.PERSONNEL_LAST_NAME>
							
					<cfoutput><OPTION VALUE="#getPersonnel.PERSONNEL_DETAIL_ID#">#getPersonnel.PERSONNEL_FIRST_NAME# #getPersonnel.PERSONNEL_LAST_NAME#</OPTION></cfoutput>
				</cfloop>
			</SELECT>
		</TD>
		<TD>
			<input ID="actionButton" VALUE="ADD USER" type="button" ONCLICK="addUserToList()">	
		</TD>
		<TD>
			<input  VALUE="UPDATE USER" type="button" ONCLICK="updateCurrentRow()">
		</TD>	
	</TR>
</TABLE>	
	
	
	


<BR>




<TABLE ID="assignmentList" CELLPADDING="3" CELLSPACING="0" CLASS="maintable" WIDTH="500">
	<TR VALIGN="bottom" BGCOLOR="#FFCE84">
		<TD id="header" width="10">&nbsp;</TD>
		<TD id="header"><b>Market Area</b></TD>
		<TD id="header"><b>Name</b></TD>
		<TD id="header">&nbsp;</TD>
	</TR>
	
	<cfoutput>
		<cfloop query="getMarketAssignments">

			<CFSET userNameSelectIndex=0>
			<cfloop index="LoopCount" from="1" to="#ArrayLen(userNameSelectboxIndexTracker)#" step="1">

				<cfset usernamestring = getMarketAssignments.PERSONNEL_FIRST_NAME & " " &  getMarketAssignments.PERSONNEL_LAST_NAME>
				<cfif userNameSelectboxIndexTracker[LoopCount][2] EQ usernamestring>
					<CFSET userNameSelectIndex = userNameSelectboxIndexTracker[LoopCount][1]>
				</cfif>

			</cfloop>
			
			<CFSET marketAreaSelectIndex=0>
			<cfloop index="LoopCount" from="1" to="#ArrayLen(MarketAreaSelectboxIndexTracker)#" step="1">
				
				<cfif MarketAreaSelectboxIndexTracker[LoopCount][2] EQ getMarketAssignments.Market_Area_ID>
					<CFSET marketAreaSelectIndex = MarketAreaSelectboxIndexTracker[LoopCount][1]>
				</cfif>
			</cfloop>			
			<TR marketarea="#getMarketAssignments.Market_Area_ID#" marketareaselectindex="#marketAreaSelectIndex#" username="#getMarketAssignments.personnel_first_name# #getMarketAssignments.personnel_last_name#" usernameid="#getMarketAssignments.personnel_detail_id#" usernameidselectindex="#userNameSelectIndex#"  ONCLICK="editMarketRow()" recid="#getMarketAssignments.deduction_market_to_user_id#" deleteassignment="0" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
				<TD id="FlagCell" align="center" valign="middle">&nbsp;</TD>
				<TD>#getMarketAssignments.Market_Area_Description#</TD>
				<TD>#getMarketAssignments.personnel_first_name# #getMarketAssignments.personnel_last_name#</TD>
				<TD><input id="marketsToDelete" value="#getMarketAssignments.deduction_market_to_user_id#" type="checkbox" onclick="deleteMarketAssignment(this)"></TD>
			</TR>	
		</cfloop>
	</cfoutput>
</table>
<FORM ACTION="deduction_market_to_user_action.cfm" METHOD="post" NAME="theForm" ID="theForm">

</form>
<input type="button" VALUE="save list" ONCLICK="buildForm()">
</body>
</html>
