<cfset PAGE_TITLE="Reassign Programs">
<!---Gets application settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" align="Center">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfinclude template="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR><BR>

<cfparam name="From_Position" default="">
<cfparam name="TO_Position" default="">
<cfparam name="From_Label" default="">
<cfparam name="From_Zone" default="">
<cfparam name="From_Region" default="">
<cfparam name="From_Market" default="">
<cfparam name="To_Label" default="">
<cfparam name="To_Zone" default="">
<cfparam name="To_Market" default="">
<cfparam name="To_Region" default="">
<cfparam name="Contract_Number" default="">
<cfparam name="Reassign_Type" default="1">
<cfparam name="counter" default= 0>
<cfparam name=" budget_ids " default=""><!---D33624:Mass Reassign - Budget Picker --->
<cfparam name="User_Positions_ID"  default=" "><!---D33624:Mass Reassign - Budget Picker --->
<cfparam name="Include_work_in_progress_below_me" default= 0>
<!---
				Dev Notes: D24498/Anand Rao/01-Sep-10
				Program Reassign

Reassign_Type = 1 ==> Default, user needs to pick the From_Position, Program and To_positions
Reassign_Type = 2 ==> User needs to pick Program and To_Position
Reassign_Type = 3 ==> User needs to pick the To_position and this will come from the Contract Main page and will
                      have the contract_Number in the URL.
--->

<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<cfif From_Position NEQ "" OR Reassign_Type EQ "2" OR Reassign_Type EQ "3">
  <cfif From_Position NEQ "">
  <cfquery name="Postion_Details" datasource="#Application.Datasource#">
  	SELECT		User_Positions.Position_Label,
  				User_Positions.User_Positions_ID,
  				Service_Zones.Zone_Name,
  				Service_Regions.Region_Name,
  				Service_Markets.Market_Name,
  				User_Positions.Service_Zone_ID,
  				User_Positions.Service_Region_ID,
  				User_Positions.Service_Market_ID,
				Position_Level = CASE
                                         WHEN User_Positions.Service_Market_Id IS NOT NULL THEN 3
                                         WHEN User_Positions.Service_Region_Id IS NOT NULL
                                              AND User_Positions.Service_Market_Id IS NULL THEN 2
                                         WHEN User_Positions.Service_Zone_Id IS NOT NULL
                                              AND User_Positions.Service_Region_Id IS NULL
                                              AND User_Positions.Service_Market_Id IS NULL THEN 1
                                         ELSE 0
                                       END
  	FROM		User_Positions
  				LEFT JOIN	Service_Zones
  				ON
  				Service_Zones.Service_Zone_ID = User_Positions.Service_Zone_ID
  				LEFT JOIN	Service_Regions
  				ON
  				Service_Regions.Service_Region_ID = User_Positions.Service_Region_ID
  				LEFT JOIN	Service_Markets
  				ON
  				Service_Markets.Service_Market_ID = User_Positions.Service_Market_ID
  	WHERE		<!--- User_Positions.Deleted=0
  				AND--->
  				(len(User_Positions.Position_Label) <> 0)
  			<!--- 	AND
  				(
  					User_Positions.Service_Zone_ID IS NULL
  					OR
  					(Service_Zones.Deleted = 0)
  				)
  				AND
  				(
  					User_Positions.Service_Region_ID IS NULL
  					OR
  					(Service_Regions.Deleted = 0)
  				)
  				AND
  				(
  					User_Positions.Service_Market_ID IS NULL
  					OR
  					(Service_Markets.Deleted = 0)
  				)				 --->
  				AND User_Positions.User_Positions_ID = #From_Position#
  </cfquery>
  <cfoutput query="Postion_Details">
	  <cfset From_Label = #Position_Label#>
  	<cfset From_Zone = #Zone_Name#>
	  <cfset From_Region = #Region_Name#>
  	<cfset From_Market = #Market_Name#>
  </cfoutput>
</cfif>
	<cfif TO_Position NEQ"">
	<cfquery name="To_Position_details" datasource="#Application.Datasource#">
		SELECT		User_Positions.Position_Label,
					User_Positions.User_Positions_ID,
					Service_Zones.Zone_Name,
					Service_Regions.Region_Name,
					Service_Markets.Market_Name,
					User_Positions.Service_Zone_ID,
					User_Positions.Service_Region_ID,
					User_Positions.Service_Market_ID
		FROM		User_Positions
					LEFT JOIN	Service_Zones
					ON
					Service_Zones.Service_Zone_ID = User_Positions.Service_Zone_ID
					LEFT JOIN	Service_Regions
					ON
					Service_Regions.Service_Region_ID = User_Positions.Service_Region_ID
					LEFT JOIN	Service_Markets
					ON
					Service_Markets.Service_Market_ID = User_Positions.Service_Market_ID
		WHERE		User_Positions.Deleted=0
					AND
					(len(User_Positions.Position_Label) <> 0)
					AND
					(
						User_Positions.Service_Zone_ID IS NULL
						OR
						(Service_Zones.Deleted = 0)
					)
					AND
					(
						User_Positions.Service_Region_ID IS NULL
						OR
						(Service_Regions.Deleted = 0)
					)
					AND
					(
						User_Positions.Service_Market_ID IS NULL
						OR
						(Service_Markets.Deleted = 0)
					)
					AND User_Positions.User_Positions_ID = #TO_Position#
					<!--- <CFELSEIF URL.User_Position NEQ "">#URL.User_Position# --->
	</cfquery>
	</cfif>

  <cfif TO_Position NEQ"">
    <cfoutput query="To_Position_details">
  	  <cfset To_Label = #Position_Label#>
    	<cfset To_Zone = #Zone_Name#>
    	<cfset To_Region = #Region_Name#>
  	  <cfset To_Market = #Market_Name#>
	  <cfset User_Positions_ID = #User_Positions_ID#><!---D33624:Mass Reassign - Budget Picker --->
    </cfoutput>
  </cfif>
</cfif>

<script src="/Script/javascript/dom_common.js"></script>
<script language="JavaScript">
function anyCheckBoxChecked(chObj)
{
	var bChecked = false;
	if(chObj.length)
	{
		var i, chLen;
		chLen = chObj.length;
		for(i=0;i<chLen;i++)
		{
			if(chObj[i].checked)
			{
				bChecked = true;
				break;
			}
		}
	}
	else
	{
		if(chObj.checked)
		{
			bChecked = true;
		}
	}
	return bChecked;
}

function toaction(ListOfPrograms)
{

	x= document.reassign_program
	submit_ok = 1;
	//if (x.SelectedITEMS.value == "")
	if(!anyCheckBoxChecked(x.SelectedITEMS))
	{
		queueMessage("There must be at least one program selected. Please, select some programs", document.all.ERR_PROG);
		submit_ok = 0;
	}
	else
	{
		clearQueue(document.all.ERR_PROG);
	}

	if (x.To_Position.value == "")
	{
		queueMessage("Please select a position to reassign the selected programs", document.all.ERR_POSITION);
		submit_ok = 0;
	}
	else
	{
		clearQueue(document.all.ERR_POSITION);
	}

	<cfif application.returned_customer_setting.Responsible_Person EQ 1>
	if(submit_ok)
	{
		var arItems = document.all.SelectedITEMS;
		var arItem;
		var selObj, spObj, arLen = arItems.length;
		if(arItems.length)
		{
			for(var j=0;j<arLen;j++)
			{
				arItem = arItems[j];
				spObj = eval("document.all.err_responsibleUser_" + arItem.value);
				if(arItem.checked)
				{
					selObj = eval("document.all.responsibleUser_" + arItem.value);

					if (selObj.disabled == false && selObj.value == "0")
					{
						queueMessage("Please select a responsible sales person to reassign the selected program", spObj);
						submit_ok = 0;
					}
					else
					{
						clearQueue(spObj);
					}
				}
				else
				{
					clearQueue(spObj);
				}
			}
		}
		else
		{
				arItem = arItems;
				spObj = eval("document.all.err_responsibleUser_" + arItem.value);
				if(arItem.checked)
				{
					selObj = eval("document.all.responsibleUser_" + arItem.value);

					if (selObj.disabled == false && selObj.value == "0")
					{
						queueMessage("Please select a responsible sales person to reassign the selected program", spObj);
						submit_ok = 0;
					}
					else
					{
						clearQueue(spObj);
					}
				}
				else
				{
					clearQueue(spObj);
				}
		}
	}
	</cfif>
<!--- D33624:Mass Reassign - Budget Picker --->
<cfif appSettings.getBudgetsFunctionalityOn() AND appSettings.getBudgetSelectionRequired()>

		var arItems = document.all.SelectedITEMS;
		if (arItems.length) {
			for (i = 0; i < arItems.length; i++) {//Program loop
				if (arItems[i].checked) {//if Program selected
					if(!validateBudgetSelection(arItems[i].value)){
						submit_ok = 0;
					}
				}
			}
		}
		else{
			if(!validateBudgetSelection(arItems.value)){
				submit_ok = 0;
			}
		}

</cfif>
<!--- D33624:Mass Reassign - Budget Picker--->
	if (submit_ok == 1)
	{
		var errorMessage=''
		var errorMessageString = "these"
			if(ListOfPrograms !='')
			{
				errorMessage = "The following programs cannot be reassigned beacause there is no RSP with access to all the class codes from the program(s)-\n" + ListOfPrograms + "\n";
				var errorMessageString = "the remaining"
			}
		var confirm_reassign = confirm(errorMessage+ "Are you sure you want to reassign "+errorMessageString+" programs ?");
		if (confirm_reassign == true)
		{
			document.reassign_program.action="Reassign_Programs_Action.cfm";
			document.reassign_program.submit();
			return false;
			}
	}
	else
	{
		showMessageWindow();
	}
}

function validateBudgetSelection(programId){
	var budgetslistObj;
	var classtype = eval("document.all.class_type_" + programId);

	// program may allow many budget class, but user should only chose from either calendar or fiscal or partial year
	if(classtype){
		if(classtype.length) {
			for(var i=0; i< classtype.length;i++){
				if(classtype[i].checked){
					budgetslistObj = eval("document.all.budget_class_list_" + classtype[i].getAttribute('classtype') + "_" + programId);
				}
			}
		}
		else {// if only one class type, both lists should be same
			budgetslistObj = eval("document.all.budgets_" + programId);
		}
	}


	var budgetslist = "";
	if(budgetslistObj)
		budgetslist = budgetslistObj.value;
	var budgetclass = new Array();
	var budgetclass = budgetslist.split(",");
	var submit_ok = 1;
	var anyBudget = 0;
	var partialBudgetSelected = 0;
	var budgetClassOK = 0;
	for (j = 0; j < budgetclass.length; j++) { // Loop over budget class
		var budgets = document.getElementsByName("budget_" + budgetclass[j] + "_" + programId);
		for (k = 0; k < budgets.length; k++) {// Loop over budget
			anyBudget = 1;
			budgetClassOK = 1;
			var spObj = eval("document.all.err_budget_" + budgetclass[j] + "_" + programId);
			if (budgets[k].value == "0") {//Whether user selected a budget
				queueMessage("Please select a budget to reassign the selected program", spObj);
				submit_ok = 0;
				budgetClassOK = 0;
			}
			else if(budgetslist == "0") { // partial budget and user has made a selection
				partialBudgetSelected = budgets[k].value;
				var budgetStartObj = eval("document.all.Start_Date_" + budgetclass[j] + "_" + programId + "_" + partialBudgetSelected);
				var budgetEndObj = eval("document.all.End_Date_" + budgetclass[j] + "_" + programId + "_" + partialBudgetSelected);
				var programStartObj = eval("document.all.Program_Start_" + programId);
				var programEndObj = eval("document.all.Program_End_" + programId);

				if(budgetStartObj && budgetEndObj && programStartObj && programEndObj) {
					var partial_budget_start = new Date(budgetStartObj.value);
					var partial_budget_end = new Date(budgetEndObj.value);
					var program_start = new Date(programStartObj.value);
					var program_end = new Date(programEndObj.value);
					if(partial_budget_start > program_start || partial_budget_end < program_end){
						queueMessage("Budget selection is required for entire program period", spObj);
						submit_ok = 0;
						budgetClassOK = 0;
					}
				}
			}

			if(budgetClassOK) {
				clearQueue(spObj);
			}

		}
	}
	//if no budget available
	if(anyBudget == 0){
		var spObj = eval("document.all.err_budget_" + programId);
		queueMessage("Please select a budget to reassign the selected program", spObj);
		submit_ok = 0;
	}

	return submit_ok;
}

function propogateSelection(thisObj)
{
	var selValue = thisObj.value;
	var arItems = document.all.SelectedITEMS;
	var selObj, optObj, arLen = arItems.length;
	for(var j=0;j<arLen;j++)
	{
		//if(arItems[j].checked)
		{
			selObj = eval("document.all.responsibleUser_" + arItems[j].value);
			if(selObj.disabled == false){
			optObj = Get_Object_Property_Match_Collection(selObj.options, "value", selValue);
			optObj.selected = true;
			}
		}
	}
}

function selectAll(thisobj)
{
	var bCheck = thisobj.checked;
	var chObjs = document.all.SelectedITEMS;
	if(chObjs.length)
	{
		var chObjLen = chObjs.length;
		var i;
		for(i=0;i<chObjLen;i++)
		{
			chObjs[i].checked = bCheck;
		}
	}
	else
	{
		chObjs.checked = bCheck;
	}
}
function dis_program()
{

	window.location.href = "Reassign_Programs.cfm?searchprograms=1&Position_1=<CFOUTPUT>#From_Position#</CFOUTPUT>&From_Label=<CFOUTPUT>#From_Label#</CFOUTPUT>";
}

function sort_by_this_order(fieldName, sOrder)
	{
		var oForm = document.Save_reassign;
		oForm.SORT_BY.value = fieldName;
		oForm.SORT_ORDER.value = sOrder;
		oForm.submit();
		return false;
	}

</SCRIPT>

<cfset program = CreateObject("component", "components.programs.Program") />

<!--- Dinesh Rachala LABEL 26667 & D26891  START--->
<!--- This JavaScript function is used to collect the Contact_Number
     from the pop-up child window and assaign those values to form variables and submit form --->
    <script language="javascript" type="text/javascript">
     function ParentWindowFunction(s)
     {
        document.reassign_program.Contract_Number.value = s;
        document.reassign_program.submit();
        return false;
     }
     </script>
<!--- Dinesh Rachala LABEL 26667 & D26891  END--->

	<FORM name="reassign_program" ACTION="Reassign_Programs.cfm" METHOD="POST">
	<cfoutput>
	<input type="Hidden" ID="SelectSingleSearchResultOnly_Position" name="SelectSingleSearchResultOnly_Position" VALUE="1">
	<input type="Hidden" name="From_Position" VALUE="#From_Position#">
	<!--- <input type="hidden" name="To_Position" VALUE="#To_Position#"> --->
	<input type="Hidden" name="EnableListOfPositionsAboveMine" VALUE="0">
	<input type="Hidden" name="To_Position" VALUE="#To_Position#">
	<cfif application.returned_customer_setting.Responsible_Person NEQ 1>
	<input type="Hidden" ID="Disable_Position_List" name="Disable_Position_List" VALUE="#From_Position#">
	</cfif>
	<input type="Hidden" name="From_Label" VALUE="#From_Label#">
	<input type="Hidden" name="To_Label" VALUE="#To_Label#">
    <input type="Hidden" name="Reassign_Type" VALUE = "#reassign_type#" />


		<cfparam name="startrow"  default="1">
	   	<cfparam name="frompage"   default="1">
	   	<cfparam name="pageLength"  default=10>
	   	<cfset startrow=startrow>
	   	<cfset frompage=frompage>
	   	<cf_Number_of_Rows maxrows="#pageLength#">
	   	<input type="hidden" VALUE = "#frompage#" name="frompage">
		<input type="hidden" VALUE = "#StartRow#" name="startrow">


	<cfset col1Len1 = "7%" />
<cfif Reassign_Type EQ "1">
	<cfset col1Len2 = "30%" />
<cfelse>
  	<cfset col1Len2 = "5%" />
</cfif>
 <!---<cfoutput>
  --->
	<TABLE align="center" border="0" width="98%" CELLSPACING="0">
		<TR>
			<TD COLSPAN="100%"><B>Reassign Program</B>
			<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
			<hr color="orange">
      <cfif (Reassign_Type NEQ "3")>
        <table border="0" cellspacing="2" cellpadding="2">
          <tr>
            <td>

              <CF_button
							button_name		=	""
							button_caption	=	"Reassign by Position"
  							button_action	=	"fnByPosition()"
  							button_type		=	"javascript_link"
  							button_width	=	"100"
  							button_color	=	"Navy"
  							button_tip		=	""
  							font_color		=	"White"
  							font_size		=	"12"
  							font_weight		=	"bold"
 							>
  				 </td>

           <td>
<!--- Dinesh Rachala for LABEL  D26667   START--->
<cfif appSettings.getFlexProgramSearch() eq 2 OR appSettings.getFlexProgramSearch() eq 3 OR appSettings.getFlexProgramSearch() eq 4 OR appSettings.getFlexProgramSearch() eq 5>
	         <CF_button
							button_name		=	""
							button_caption	=	"Reassign by Program"
  							button_action	=	"dis_program2()"
  							button_type		=	"javascript_link"
  							button_width	=	"100"
  							button_color	=	"Navy"
  							button_tip		=	""
  							font_color		=	"White"
  							font_size		=	"12"
  							font_weight		=	"bold"
 							>

<cfelse>

 <CF_button
				button_name		=	""
				button_caption	=	"Reassign by Program"
  							button_action	=	"dis_program1()"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				>
</cfif>
<!--- Dinesh Rachala for LABEL  D26667   END --->

          </td></tr></table>
        </cfif>
 			</td>
		</tr>
	 <cfif Contract_Number EQ "">
		<!--- <TR>
			<TD COLSPAN="100%">
      <!--- <div id="div10" name="div10" STYLE="color:red;font-weight:bold;font-style:italic;position:absolute"> --->
			<SPAN STYLE="color:red;font-weight:bold;font-style:italic"> Choose the position from which you want to move the programs:</SPAN>
      <!--- </div> --->
      <!--- <div id="div20" name="div20" style="visibility:hidden;position:absolute" STYLE="color:red;font-weight:bold;font-style:italic"> --->
			<SPAN STYLE="color:red;font-weight:bold;font-style:italic">Choose the Program you want to reassign:</SPAN>
      <!--- </div> --->
			</TD>
		</TR> --->
		<cfelse>
		<tr>
			<td colspan="100%" align="right">
			  <!--- <SPAN STYLE="color:red;font-weight:bold;font-style:italic">Choose the new position to move the selected programs to and click "Reassign"</SPAN>   --->
			</td>
		</tr>
		</cfif>
		 <tr>
     <cfif Reassign_Type EQ "1">
      <td width="50%">&nbsp;</td>
     </cfif>

			<cfif Contract_Number NEQ "">
				<cfquery name="List_program" datasource="#Application.Datasource#">
					SELECT 		CM.Contract_Main_ID,
								CM.Contract_Reference_Number,
								CM.Contract_Number,
								CST.Contract_Status_Type_Desc,
								CM.Contract_Title,
								CM.Contract_Start_Date,
								CM.Contract_End_Date,
								_Users.Name_First + ' ' + _Users.Name_Last Responsible_User_Name,
								CM.Responsible_User_ID,
								CM.Business_Segment_ID,
								CM.Creating_User_Position_ID,
								Position_Level = CASE
                                         WHEN User_Positions.Service_Market_Id IS NOT NULL THEN 3
                                         WHEN User_Positions.Service_Region_Id IS NOT NULL
                                              AND User_Positions.Service_Market_Id IS NULL THEN 2
                                         WHEN User_Positions.Service_Zone_Id IS NOT NULL
                                              AND User_Positions.Service_Region_Id IS NULL
                                              AND User_Positions.Service_Market_Id IS NULL THEN 1
                                         ELSE 0
                                       END
					FROM 		Contract_Main CM
					INNER JOIN 	Contract_Status_Types CST
					ON 			CM.Contract_Status_Type_IDX = CST.Contract_Status_Type_ID
					LEFT JOIN 	_Users
					ON 			_Users.User_ID = CM.Responsible_user_ID
					LEFT JOIN	User_Positions
					ON			CM.Creating_User_Position_ID = User_Positions.User_Positions_ID
					WHERE 		Contract_Main_ID IN (<cfqueryparam value="#Contract_Number#" cfsqltype="CF_SQL_INTEGER" list="yes" />)
					ORDER BY 	CM.Contract_Number
				</cfquery>


				<td align="left" STYLE="border-bottom:none;"><SPAN ID="ERR_POSITION" STYLE="border-bottom:none; font-size: 12px; font-weight: bold;">&nbsp;</SPAN>
				<SPAN STYLE="border-bottom:none; font-size: 12px; font-weight: bold;">To:</SPAN>
				<B>
					<FONT SIZE="2" COLOR="Red">[</FONT>
						<FONT COLOR="Blue">
							<A HREF="##"
							onClick='document.all.EnableListOfPositionsAboveMine.value=1;NewWindow("/Search_Screens/Position_Search.cfm?Formname=reassign_program&Fieldname=To_Position&Contract_number=#contract_number#", "qbrandwindow", 800, 600, "yes", "yes")'>
							select position
							</A>
						</FONT>
					<FONT SIZE="2" COLOR="Red">]</FONT>
				</B>	<br>
        <span STYLE="color:red;font-weight:bold;font-style:italic">Choose the new position to move the selected program(s) to and click "Reassign"</SPAN>  <!---30027--->
			</td>
			</cfif>
		</tr>
		<tr>
			<td colspan="100%">
				<table border="0" width="100%" ALIGN="center" CELLSPACING="0">
					<cfif From_Position NEQ "" AND Reassign_Type EQ "1">
						<cfquery name="Check_Program" datasource="#Application.Datasource#">
							SELECT 	Contract_Main_ID
							FROM 	Contract_Main
							WHERE 	Creating_User_Position_ID = #From_Position#
						</cfquery>
						<cfif Check_Program.recordcount EQ 0>
							<script language="JavaScript">
								alert("There are no program(s) under this position. Please select some other position.");
							</script>
							<cfset 	From_Position = "">
						</cfif>
					</cfif>
					<TR>
						<cfif From_Position NEQ "" <!--- AND  Contract_Number EQ "" --->>
            <SPAN STYLE="font-size: 12px; font-weight: bold;">From:</SPAN>
						<TD WIDTH="#col1Len1#" ALIGN="right" STYLE="font-size: 11px; font-weight: bold;"><B>Label:</B></TD>
						<TD ALIGN="left">#From_Label#&nbsp;</TD>
						</cfif>
						<cfif Contract_Number NEQ "" AND To_Position NEQ "">
						<TD WIDTH="#col1Len2#" ALIGN="right" STYLE="border-bottom:none; font-size: 11px; font-weight: bold;">
            <B>Label:</B>&nbsp;&nbsp;</TD>
						<TD STYLE="border-bottom:none;"><cfif To_Position NEQ "">#To_Label#&nbsp;<CFELSE><!--- None Selected ---></cfif></TD>
						</cfif>
					</TR>
					<TR>
					<cfif From_Position NEQ "" <!--- AND  Contract_Number EQ "" --->>
						<TD WIDTH="#col1Len1#" ALIGN="right" STYLE="font-size: 11px; font-weight: bold;"><B>Zone:</B></TD>
						<TD>#From_Zone#&nbsp;</TD>
					</cfif>
					<cfif Contract_Number NEQ "" AND To_Position NEQ "">
						<TD WIDTH="#col1Len2#" ALIGN="right"  STYLE="border-bottom:none; font-size: 11px; font-weight: bold;"><B>Zone:</B>&nbsp;&nbsp;</TD>
						<TD  STYLE="border-bottom:none;"><cfif To_Position NEQ "">#To_Zone#&nbsp;<CFELSE>None Selected</cfif></TD>
					</cfif>
					</TR>
					<TR>
					<cfif From_Position NEQ "" <!--- AND  Contract_Number EQ "" --->>
						<TD WIDTH="#col1Len1#" ALIGN="right" STYLE="font-size: 11px; font-weight: bold;"><B>Region:</B></TD>
						<TD>#From_Region#&nbsp;</TD>
					</cfif>
					<cfif Contract_Number NEQ "" AND To_Position NEQ "">
						<TD WIDTH="#col1Len2#" ALIGN="right"  STYLE="border-bottom:none; font-size: 11px; font-weight: bold;"><B>Region:</B>&nbsp;&nbsp;</TD>
					  <TD STYLE="border-bottom:none;"><cfif To_Position NEQ "">#To_Region#&nbsp;<CFELSE>None Selected</cfif></TD>
					</cfif>
					</TR>
					<TR>
					<cfif From_Position NEQ "" <!--- AND  Contract_Number EQ "" --->>
						<TD WIDTH="#col1Len1#" ALIGN="right"  STYLE="font-size: 11px; font-weight: bold;"><B>Market:</B></TD>
						<TD>#From_Market#&nbsp;</TD>
					</cfif>
					<cfif Contract_Number NEQ "" AND To_Position NEQ "">
						<TD WIDTH="#col1Len2#" ALIGN="right"  STYLE="border-bottom:none; font-size: 11px; font-weight: bold;"><B>Market:</B>&nbsp;&nbsp;</TD>
						<TD STYLE="border-bottom:none;"><cfif To_Position NEQ "">#To_Market#&nbsp;<CFELSE>None Selected</cfif></TD>
					</cfif>
					</TR>
					<!--- <cfif From_Position EQ "" AND Reassign_Type EQ "1">
					<TR>
						<TD>None Selected</TD>
					</TR>
					</cfif> --->
				</TABLE>
				<hr color="orange">
			</TD>
		</TR>
    <script language="javascript">
      function fnByPosition()
      {
        document.reassign_program.Reassign_Type.value = "1";
        document.all.EnableListOfPositionsAboveMine.value=0;
        NewWindow("/Search_Screens/Position_Search.cfm?Formname=reassign_program&Fieldname=From_Position&reassign_type=1", 'PositionSearch', '800', '600', 'yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
      }

      function dis_program2()
      {
        document.reassign_program.Reassign_Type.value = "2";
        document.all.EnableListOfPositionsAboveMine.value=0;
		<cfif appSettings.getFlexProgramSearch() eq 2 OR appSettings.getFlexProgramSearch() eq 3>
        NewWindow("/flex/search/ProgramSearchFx.cfm?Include_work_in_progress_below_me=1&importlist_type=1&userid=#cookie.user_id#&Formname=reassign_program&Fieldname=Contract_Number&ReturnFieldname=Contract_Main_ID&AllowImportAll=1&Disable_Locked=1&Display_Deleted_Programs=1&reassign_type=2", 'pro_search', '800', '600', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
		<cfelseif appSettings.getFlexProgramSearch() eq 4 OR appSettings.getFlexProgramSearch() eq 5>
		NewWindow("/programs/program_search.cfm?Include_work_in_progress_below_me=1&importlist_type=1&userid=#cookie.user_id#&Formname=reassign_program&Fieldname=Contract_Number&ReturnFieldname=Contract_Main_ID&AllowImportAll=1&Disable_Locked=1&Display_Deleted_Programs=1&reassign_type=2", 'pro_search', '800', '600', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
		</cfif>	
	  }
      function dis_program1()
      {
        document.reassign_program.Reassign_Type.value = "2";
        document.all.EnableListOfPositionsAboveMine.value=0;
        NewWindow("/Scorecard/program_Search.cfm?type=htm&Formname=reassign_program&Fieldname=Contract_Number&ReturnFieldname=Contract_Main_ID&AllowImportAll=1&Disable_Locked=1&Display_Deleted_Programs=1&reassign_type=2", 'pro_search', '1100', '600', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
      }
    </script>
    <input type = "hidden" name="Contract_Number" VALUE="#Contract_Number#">
</cfoutput>
 	  <!---Modified by dinesh for Label D26891 passing FROM POSITION --->
	 	<cfif From_Position NEQ "" OR Reassign_Type EQ "2" OR Reassign_Type EQ "3">
   	 	<cfif From_Position NEQ "">
		<!--- Include_work_in_progress_below_me --->
<!--- LABEL D26891 --->
<cfoutput>
	  		<SCRIPT language="JavaScript">
	  		function dis_program()
	  		{
	   NewWindow("/Scorecard/Program_Search.cfm?type=htm&Include_work_in_progress_below_me=1&Formname=reassign_program&Fieldname=Contract_Number&ReturnFieldname=Contract_Main_ID&AllowImportAll=1&Disable_Locked=1&Creating_User_Position=#From_Position#&Display_Deleted_Programs=1", 'pro_search', '1000', '600', 'yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
		    }
	  		</SCRIPT>


	  		<SCRIPT language="JavaScript">
	  		function dis_program3()
	  		{
	 //NewWindow("/flexdev/ProgramSearch/bin-debug/ProgramSearchFx.cfm?reload=1&Include_work_in_progress_below_me=1&Creating_User_Position=#From_Position#&importlist_type=1&userid=#cookie.user_id#&Formname=reassign_program&Fieldname=Contract_Number&ReturnFieldname=Contract_Main_ID&AllowImportAll=1&Disable_Locked=1&Display_Deleted_Programs=1&reassign_type=2", 'pro_search', '800', '600', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
	<cfif appSettings.getFlexProgramSearch() eq 2 OR appSettings.getFlexProgramSearch() eq 3>
	NewWindow("/flex/search/ProgramSearchFx.cfm?reload=1&Include_work_in_progress_below_me=1&Creating_User_Position=#From_Position#&importlist_type=1&userid=#cookie.user_id#&Formname=reassign_program&Fieldname=Contract_Number&ReturnFieldname=Contract_Main_ID&AllowImportAll=1&Disable_Locked=1&Display_Deleted_Programs=1&reassign_type=2", 'pro_search', '800', '600', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
	<cfelseif appSettings.getFlexProgramSearch() eq 4 OR appSettings.getFlexProgramSearch() eq 5>
	NewWindow("/programs/program_search.cfm?reload=1&Include_work_in_progress_below_me=1&Creating_User_Position=#From_Position#&importlist_type=1&userid=#cookie.user_id#&Formname=reassign_program&Fieldname=Contract_Number&ReturnFieldname=Contract_Main_ID&AllowImportAll=1&Disable_Locked=1&Display_Deleted_Programs=1&reassign_type=2", 'pro_search', '800', '600', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
	</cfif>
			 }
	  		</SCRIPT>
</cfoutput>
<!--- LABEL D26891 --->
      </cfif>
	<!--- LABEL D26891 --->

			<cfif Contract_Number EQ "">
<cfoutput>
					<cfif appSettings.getFlexProgramSearch() eq 2 OR appSettings.getFlexProgramSearch() eq 3 OR appSettings.getFlexProgramSearch() eq 4 OR appSettings.getFlexProgramSearch() eq 5>
					<!--- Flex Version --->
				<TR>
				<TD colspan="100%" align="center"><BR><BR><BR>
						<CF_button
							button_name		=	""
							button_caption	=	"search program"<!--- AG grid or Flex--->
							button_action	=	"dis_program3()"
							button_type		=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
							>
					<BR>

					<FONT COLOR="Red"><B><I>Choose the specific program(s) you want to move from "#From_Label#"</I></B></FONT>
				</TD>
			</TR>
	                <cfelse>
	                 <!--- HTML VERSION --->
			<TR>
				<TD colspan="100%" align="center"><BR><BR><BR>
						<CF_button
							button_name		=	""
							button_caption	=	"search program"<!--- html--->
							button_action	=	"dis_program()"
							button_type		=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
							>
					<BR>
					<FONT COLOR="Red"><B><I>Choose the specific program(s) you want to move from "#From_Label#"</I></B></FONT>
				</TD>
			</TR>

	               </cfif>
</cfoutput>
			<!--- LABEL D26891 --->
			<CFELSE>

				<TR>
					<TD COLSPAN="100%">
					<cfoutput>
						<cfif From_Position NEQ ""><br>
									<SPAN ID="ERR_PROG">&nbsp;</SPAN><b>Reassign Programs from " #From_Label# " :</b>&nbsp;&nbsp;&nbsp;&nbsp;
									<B>
									<FONT COLOR="Red">[</FONT>
									<A HREF="##" onclick="Javascript:dis_program();" >Search Programs</A>
									<FONT COLOR="Red">]</FONT>
						</cfif>

						<cfif To_Position NEQ "">
									#RepeatString("&nbsp;", 25)#
									<SPAN STYLE="color:red;font-weight:bold;font-style:italic">Choose the new Responsible Sales Person for each program</SPAN><BR><BR>
						</cfif>
						</cfoutput>
						</B>
						<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%" CLASS="MainTable">
							<!--- D40274 :: EVEN ERRORS:  Variable LISTOFPROGRAMS is undefined. MOVED THIS VARIABLE OUTSIDE THE LOOP SO THAT IT WONT THROW AN EVENT ERROR IF THER "LIST_PROGRAM" QUERY HAS ZERO RECORDS--->
							<cfset ListOfPrograms = "">
							<cfif List_Program.recordcount GT 0>
			  							<cfif To_Position NEQ "">
					  								<!------ Get the users in this position ----->
					    							<cfset UserManager = CreateObject("component", "components.user.UserManager").init() />
					    							<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
					    							<cfif businessSegManager.getClassCodesOn() eq 0>
					      							<cfset stStruct = StructNew() />
					      							<cfset stStruct.userPosition = To_Position />
					      							<cfset stStruct.userPositionType = "P,S" />
					      							<cfset stStruct.Eligible_RSP = 1> <!--- Dev Note: : D12943: CAG - non eligible sales person available for reassign programs --->
													<cfif appsettings.getDisplayEligibleRSP() EQ 1>
														<cfset stStruct.Is_On_Behalf_Of = 0>
													</cfif>
					      							<cfset qUsers = UserManager.search(stStruct) />
			    						</cfif>
  							</cfif>

							<TR BGCOLOR= "ffce84" VALIGN="top">
								<TD><input type="checkbox" name="allbox" onclick="javaScript: selectAll(this);" CHECKED></TD>
								<TD STYLE="font-size: 11px; font-weight: bold;">Status</TD>
								<TD STYLE="font-size: 11px; font-weight: bold;">Program</TD>
								<TD STYLE="font-size: 11px; font-weight: bold;">Title[Reference]</TD>
								<TD STYLE="font-size: 11px; font-weight: bold;">Start Date<BR>End Date</TD>
								<cfif To_Position NEQ "" AND application.returned_customer_setting.Responsible_Person EQ 1>
								<TD nowrap="nowrap" STYLE="font-size: 11px; font-weight: bold;">Responsible Sales Person<BR><input name="keepResponsibleUserSame" type="Checkbox" checked> All same	</TD>
								</cfif>
								<!---D33624:Mass Reassign - Budget Picker --->
								<cfif To_Position NEQ "" AND appSettings.getBudgetsFunctionalityOn() >
								<TD STYLE="font-size: 11px; font-weight: bold;">Budgets</TD>
								</cfif>
								<!---D33624:Mass Reassign - Budget Picker --->
							</TR>


							<cfloop QUERY="List_program"><!---  startrow="#StartRow#" maxrows="#MaxRows#" --->
<cfoutput>
							<cfset qGetProgramCompleteSpan = program.getProgramCompleteSpan(List_program.Contract_Main_ID, List_program.Contract_Number) />
							<cfif To_Position NEQ "">
								<cfset businessSegmentsOn = 0 />
									<cfif businessSegManager.isEnabled()>
										<cfset businessSegmentsOn = 1 />
									</cfif>
							<cfif businessSegmentsOn>
							<cfif businessSegManager.getClassCodesOn()>
							<cfset stStruct = StructNew() />
							<cfset stStruct.userPosition = To_Position />
							<cfset stStruct.userPositionType = "P,S" />
								<cfquery name="List_ClassCodes" datasource="#Application.Datasource#">
									SELECT 	DISTINCT a.Class_Code_ID
									FROM		Class_Code a INNER JOIN BSA_Foodservice_Items_Master b
									ON a.Class_Code_ID = b.Class_Code_ID
									INNER JOIN Contract_Products c
									ON b.BSA_Foodservice_Items_Master_ID = c.BSA_Foodservice_Items_Master_ID
									WHERE c.Contract_Main_ID = '#List_Program.Contract_Main_ID#'
									AND c.deleted = 0
									ORDER BY a.Class_Code_ID
								</cfquery>
									<cfset CheckUserClassCodeList = ValueList(List_ClassCodes.class_code_id)>
									<cfset stStruct.CheckUserClassCodeList = CheckUserClassCodeList />
									<cfset qUsers = UserManager.search(stStruct) />
							</cfif>
								<cfquery name="isActive_Business_Segment_ID" datasource="#Application.Datasource#">
									select Business_Segment_ID
									from Business_Segment
									where Business_Segment_ID = '#List_Program.Business_Segment_ID#'
									and active = 1
								</cfquery>

								<cfif  isActive_Business_Segment_ID.recordcount GT 0>
									<cfset stStruct.Contract_Business_Segment_ID  = '#isActive_Business_Segment_ID.Business_Segment_ID#'>
									<cfset qUsers = UserManager.search(stStruct) />
								</cfif>
							</cfif>
									<cfif qUsers.recordcount GT 0>
											<cfset counter = counter + 1>
										<cfelse>
											<!--- As of now, only Conagra has business segments and class codes setting "ON". If no user is found for
														the position, show the appropriate message. The first message is for Conagra. --->
											<cfif IsDefined("stStruct.CheckUserClassCodeList")>
												<cfset ErrorMessage = "Cannot reassign, no RSP with all class codes">
											<cfelseif IsDefined("stStruct.Contract_Business_Segment_ID")>
												<cfset ErrorMessage = "Cannot reassign, no RSP with #appsettings.getbusiness_segment_label()#">
											<cfelse>
												<cfset ErrorMessage = "Cannot reassign, no RSP found for this position">
											</cfif>
											<cfset ListOfPrograms = ListOfPrograms & List_program.Contract_Number & "\n">
									</cfif>
							</cfif>
							<TR VALIGN="top" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
								<TD><input type="Checkbox" name="SelectedITEMS" VALUE="#Contract_Main_ID#" CHECKED <cfif To_Position NEQ ""><cfif qUsers.recordcount eq 0>DISABLED</cfif></cfif>>&nbsp;
								<input type="hidden" id="Program_Start_#Contract_Main_ID#" value="#Dateformat(qGetProgramCompleteSpan.Program_Start, 'mm/dd/yyyy')#">
								<input type="hidden" id="Program_End_#Contract_Main_ID#" value="#Dateformat(qGetProgramCompleteSpan.Program_End, 'mm/dd/yyyy')#">
								</TD>
								<TD NOWRAP>#Contract_Status_Type_Desc#&nbsp;&nbsp;</TD>
								<TD NOWRAP>#Contract_Number#&nbsp;&nbsp;</TD>
								<TD>#Contract_Title# <cfif Len(Contract_Reference_Number)>[#Contract_Reference_Number#]</cfif>
								<cfif application.returned_customer_setting.Responsible_Person EQ 1>
								<br>SP:#Responsible_User_Name#</cfif>
								</TD>
								<TD>#DateFormat(Contract_Start_Date,"mm/dd/yyyy")#&nbsp;<BR>
								#DateFormat(Contract_End_Date,"mm/dd/yyyy")#
								</TD>

</cfoutput>
								<cfif To_Position NEQ "" AND application.returned_customer_setting.Responsible_Person EQ 1>
<cfoutput>
								<TD NOWRAP>
								<select name="responsibleUser_#Contract_Main_ID#" <cfif To_Position NEQ ""><cfif qUsers.recordcount eq 0>DISABLED</cfif></cfif> onchange="javaScript: if(this.form.keepResponsibleUserSame.checked) {propogateSelection(this);}">
									<cfif To_Position NEQ "">
									<cfif qUsers.recordcount eq 0>
									<option value="0">#ErrorMessage#</option>
									<cfelse>
									<option value="0">Select Responsible Sales Person</option>
									</cfif>
									</cfif>
									<cfloop query="qUsers">
									<option value="#User_ID#">#User_Full_Name#</option>
									</cfloop>
								</select>
								<span id="err_responsibleUser_#Contract_Main_ID#"></span>
								&nbsp;
								</TD>
</cfoutput>
							<!--- D33624:Mass Reassign - Budget Picker --->
							<cfif appSettings.getBudgetsFunctionalityOn() >
								<cfstoredproc procedure="ADV_BUDGET_GET_PGM_BUDGET_LIST"
																	dataSource="#application.datasource#"
																	returnCode="Yes"
																	debug="Yes">
									<cfprocresult name=qBudgets>
									<cfprocparam type="in" cfsqltype = cf_sql_integer value="#Contract_Main_ID#" dbVarName = @program_id>
									<cfprocparam type="in" cfsqltype = cf_sql_integer value="#User_Positions_ID#" dbVarName = @user_position_id>
									<cfprocparam type="in" cfsqltype = cf_sql_integer value="0" dbVarName = @new_template_id>
   									<cfprocparam type="in" cfsqltype = cf_sql_integer value="0" dbVarName = @new_business_segment_id>
									<cfprocparam type="in" cfsqltype = cf_sql_integer value="#appSettings.getBudgetSelectionRequired()#" dbVarName = @budget_required_complete_span>
								</cfstoredproc>

								<!--- Get distinct class types available for this program --->
								<cfquery name="qGetBudgetClassType" dbtype="query">
									SELECT 	DISTINCT Is_Fiscal, Partial_Year
									FROM	qBudgets
									ORDER BY Is_Fiscal DESC, Partial_Year
								</cfquery>
								<!--- Get the class type already selected in the program --->
								<cfquery name="qGetCurrentProgramBudgetClassType" datasource="#Application.Datasource#">
									SELECT 	DISTINCT Budget_Class.Is_Fiscal, Budget_Class.Partial_Year
									FROM	Budget_Program_Selection
									INNER JOIN Budget_Class
									ON		Budget_Class.Budget_Class_ID = Budget_Program_Selection.Budget_Class_ID
									WHERE	Budget_Program_Selection.Program_ID = <cfqueryparam value="#Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER" />
								</cfquery>

								<!--- If program has budget selection, set that class type as the default --->
								<cfif qGetCurrentProgramBudgetClassType.RecordCount>
									<cfset var_CurrentBudgetClassIsFiscal = qGetCurrentProgramBudgetClassType.Is_Fiscal />
									<cfset var_CurrentBudgetClassPartialYear = qGetCurrentProgramBudgetClassType.Partial_Year />
								<cfelse><!--- If program record not found use the first record from the budget class types available --->
									<cfset var_CurrentBudgetClassIsFiscal = qGetBudgetClassType.Is_Fiscal />
									<cfset var_CurrentBudgetClassPartialYear = qGetBudgetClassType.Partial_Year />
								</cfif>

								<cfset CurrentBudgetClassType = "#var_CurrentBudgetClassIsFiscal#_#var_CurrentBudgetClassPartialYear#" />

								<TD width="300">
									<!--- Display the radio selection for class types --->
									<cfoutput query="qGetBudgetClassType">
										<cfset var_Class_Type_ID =  "0" />
										<cfset var_Class_Type_Desc = "" />
										<!--- class type description is now hard coded --->
										<cfif Is_Fiscal EQ 0>
											<cfset var_Class_Type_Desc = "Calendar" />
										<cfelseif Is_Fiscal EQ 1 AND Partial_Year EQ 0>
											<cfset var_Class_Type_Desc = "Fiscal" />
										<cfelseif Is_Fiscal EQ 1 AND Partial_Year EQ 1>
											<cfset var_Class_Type_Desc = "Fiscal (Partial Year)" />
										</cfif>
										<cfset var_Class_Type_ID =  "#Is_Fiscal#_#Partial_Year#" />

										<cfif var_Class_Type_Desc neq "">
										<input type="radio"
												objtype="classtypeobj"
												classtype="#var_Class_Type_ID#"
												programid="#List_program.Contract_Main_ID#"
												id="class_type_#List_program.Contract_Main_ID#"
												name="class_type_#List_program.Contract_Main_ID#" value="#var_Class_Type_ID#"
												<cfif CurrentBudgetClassType eq var_Class_Type_ID OR CurrentRow EQ 1>checked</cfif>
												>#var_Class_Type_Desc#&nbsp;
										</cfif>
									</cfoutput>
									<cfoutput>
									<span id="err_budget_#List_program.Contract_Main_ID#"></span>
									</cfoutput>
									<!--- Display the class and the budget list per class --->
									<table>
									<cfset budget_class_list_0_0 = "" />
									<cfset budget_class_list_1_0 = "" />
									<cfset budget_class_list_1_1 = "0" /><!--- always ID = 0, we will only allow one budget selected, thus only one drop down --->

									<cfoutput query="qBudgets" group="Budget_Class_Desc_New">
										<cfset var_Class_Type_ID = "#Is_Fiscal#_#Partial_Year#" />
										<cfset var_Budget_Class_ID_To_Use = Budget_Class_ID />
										<cfif Partial_Year EQ 1><!--- For partial year we will only allow one budget to select even if there are many classes --->
											<cfset var_Budget_Class_ID_To_Use = 0 />
										</cfif>
										<cfset tmp_Budget_Class_Desc_New = qBudgets.Budget_Class_Desc_New>
                          				<!---  count number of budgets within its group  --->
                          				<cfquery dbtype="query" name="qoqGroup">
                            				SELECT 	1
                              				FROM 	qBudgets
                             				WHERE 	Budget_Class_Desc_New = '#tmp_Budget_Class_Desc_New#'
                          				</cfquery>
										<tr trclasstype="#var_Class_Type_ID#" name="tr_class_type_#var_Class_Type_ID#_#List_program.Contract_Main_ID#">
											<td style="border:none;">
												<span style="font-weight:bold;font-size:11px;">#qBudgets.Budget_Class_Desc_New#</span><br>
												<select name="budget_#var_Budget_Class_ID_To_Use#_#List_program.Contract_Main_ID#" style="width:250px">
													<option value="0">Select a Budget</option>
                          						<cfoutput><cfif qBudgets.Budget_ID neq "">
													<option value="#qBudgets.Budget_ID#" <cfif qoqGroup.recordCount eq 1>selected=selected</cfif>><span class="descr">#qBudgets.Budget_Desc#</span> (#qBudgets.Contribution_Factor_Type#)</option>
													</cfif></cfoutput>
												</select>
												<span id="err_budget_#var_Budget_Class_ID_To_Use#_#List_program.Contract_Main_ID#"></span>
												<cfset budget_ids = listappend(budget_ids, var_Budget_Class_ID_To_Use)>
												<cfif Is_Fiscal EQ 0>
													<cfset budget_class_list_0_0 = listappend(budget_class_list_0_0, var_Budget_Class_ID_To_Use)>
												<cfelseif Is_Fiscal EQ 1 AND Partial_Year EQ 0>
													<cfset budget_class_list_1_0 = listappend(budget_class_list_1_0, var_Budget_Class_ID_To_Use)>
												</cfif>
												<cfoutput>
												<input type="hidden" id="Start_Date_#var_Budget_Class_ID_To_Use#_#List_program.Contract_Main_ID#_#qBudgets.Budget_ID#" value="#DateFormat(qBudgets.Start_Date, 'mm/dd/yyyy')#">
				  								<input type="hidden" id="End_Date_#var_Budget_Class_ID_To_Use#_#List_program.Contract_Main_ID#_#qBudgets.Budget_ID#" value="#DateFormat(qBudgets.End_Date, 'mm/dd/yyyy')#">
				  								</cfoutput>
											</td>
										</tr>
									</cfoutput>
									</table>
									<cfoutput>
										<input type="hidden" name="budgets_#List_program.Contract_Main_ID#" value="#budget_ids#">
										<input type="hidden" name="budget_class_list_0_0_#List_program.Contract_Main_ID#" value="#budget_class_list_0_0#">
										<input type="hidden" name="budget_class_list_1_0_#List_program.Contract_Main_ID#" value="#budget_class_list_1_0#">
										<input type="hidden" name="budget_class_list_1_1_#List_program.Contract_Main_ID#" value="#budget_class_list_1_1#">
									</cfoutput>
									<cfset budget_ids = "">
								</TD>
							</cfif>
							<!--- D33624:Mass Reassign - Budget Picker --->
							</TR>
</cfif>

							</cfloop>
							</cfif>
						</TABLE>
						<hr color="orange">
					</TD>
				</TR>
					</cfif>

		<cfset Enabled = 1>
		<cfif Contract_Number NEQ "">
			<cfif Counter eq 0>
				<cfset Enabled = 0>
			</cfif>
			<!--- D38387 Programs not routing for approval START --->
			<cfif Enabled>
					<TR>
						<TD colspan="100%" align="left">
					<span STYLE="color:red;font-weight:bold;font-style:italic;text-align:left;">
					If you are reassigning programs that are Ready for Approval and the application has already recorded an Agreement from a user, those Agree actions will be removed.
					<br>
					Programs that are reassigned will need to re-route for approval beginning with the new RSP.
					</span>
						</TD>
					</TR>
			</cfif>
			<!--- D38387 Programs not routing for approval END --->
		<TR>
			<TD colspan="100%" align="center">
			<BR><cfoutput>
						<CF_button
							button_name		=	""
							button_caption	=	"Reassign"
							button_action	=	"toaction('#ListOfPrograms#')"
							button_type		=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
							enabled				= "#Enabled#"
						>
					</cfoutput>
			</TD>
		</TR>
		</cfif>
		</cfif>
	</TABLE>
	<!---</cfoutput>--->
	</FORM>
<CF_MessageWindow>
</BLOCKQUOTE></BLOCKQUOTE>
<BLOCKQUOTE><BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript">

$(document).ready(function()
{
	var arClassTypeObj;
	arClassTypeObj = $('[objtype=classtypeobj]');

	//loop through each radio for class type (calendar, fiscal, partial) and add event
	$(arClassTypeObj).each(function()
    {
    	//add onclick event for each class type radio
    	$(this).click(function(e) {
    		//radio has clastype=0_0, 1_0, 1_1
    		var v_classtype = $(this).attr("classtype");
    		var v_programid = $(this).attr("programid");

			//show-hide tr based on which radio was clicked
			//when calendar is clicked, show tr for calendar and hide others
			var objTr;
			objTr = $('[name=tr_class_type_0_0_' + v_programid + ']');
			showHide(objTr, v_classtype);
			objTr = $('[name=tr_class_type_1_0_' + v_programid + ']');
			showHide(objTr, v_classtype);
			objTr = $('[name=tr_class_type_1_1_' + v_programid + ']');
			showHide(objTr, v_classtype);
		 });

		//when the checkbox isn't checked there isn't a attribute called checked.
		//when it is checked there will be a checked="checked" attribute.
		var attrChecked;
		attrChecked = $(this).attr("checked");
		if(attrChecked != "undefined" && attrChecked == "checked"){
			$(this).click();
		}
    })
});

function showHide(obj, classtype){
	$(obj).each(function()
    {
    	//if classtype matches show, otherwise hide
    	if($(this).attr("trclasstype") == classtype){
    		$(this).show();
    	}
    	else{
    		$(this).hide();
    	}

    })
}


</script>

</body>
</html>