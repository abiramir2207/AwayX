<!---
	Name: display_program_list.cfm
	Copyright (c) 2006 Blacksmith Applications, Inc.

	Description:
		Displays the list of programs in a table format.
	Usage:
		Called whenever programs listing is required, scorecard, search, etc.
--->


<!---import the custom tag lib--->
<cfimport prefix="layout" taglib="/CustomTags">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<CFPARAM name="form.businessSegmentsOn" default="0">
<CFPARAM name="URL.ShowCheckBoxes" default="0">
<CFPARAM name="URL.SearchIsConductedFromOtherWindow" default="0">
<CFPARAM name="Form.SelectedPrograms" default="">
<cfparam name="form.ILPL_PreSubmit" default="">
<cfparam name="printresults" default="0">
<cfparam name="URL.ShowRFAMassApproveCheckBox" default="0">
<cfparam name="form.currentProgramList" default="">
<cfparam name="form.currentStatusList" default="">
<cfparam name="form.currentReportProgramList" default="">
<cfparam name="application.returned_customer_setting.Accounting_Specialist" default="0" />
<cfparam name="SECTION_TO_OPEN" default="" />
<cfparam name="Cancel_Sent_to_Client" default="0">
<cfparam name="SENDING_TO_EXTERNAL_CLIENT " default="0">
<cfparam name="UseCatalogView" default="0">
<cfparam name="form.readOnlyCatalogSearch" default="0">
<cfparam name="form.Report_Type" default="0">

<cfparam name="variables.dr_type" default="">

<cfif Get_Profile_Settings.Mass_RFA_Program_Approve EQ 1>
	<cfset URL.ShowRFAMassApproveCheckBox = 1>
</cfif>
<cfset objProgramManager = CreateObject("component", "components.programs.ProgramManager").init() />

<!---check to see if the business segment components exist before we run this--->
<!---check whether the directory exists or not--->
<cfset theDir = "#request.app_general_functions.get_Application_Path()#\components\programs\business_segment\" />
<!---create and instance of the BusinessSegmentManager--->
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabled()>
	<cfset form.businessSegmentsOn = 1 />
</cfif>

<CFINCLUDE TEMPLATE="Tables_Measures.cfm">

<cfset deleteProgramMessage = "">
<cfif appSettings.getDeleteIsCancelAutoRenew()>
	<cfset deleteProgramMessage = appSettings.getDeleteProgramMessage()>
	<cfif Len(deleteProgramMessage) GT 0>
		<cfset deleteProgramMessage = "#deleteProgramMessage#\n">
	</cfif>
</cfif>
<script language="JavaScript">


function doScissors(thisObj, Contract_Number, showExtraMsg)
{
	<cfoutput>
	var deleteExtraMsg = "#deleteProgramMessage#";
	</cfoutput>
	var sMsg = "Do you want to delete program [" + Contract_Number + "] ?";
	if(showExtraMsg)
	{
		sMsg = deleteExtraMsg + sMsg;
	}
	if(window.confirm(sMsg))
	{
		NewWindow(thisObj.href , 'delete_program' , 600 , 500 , 'yes' , 'yes');
	}
	return false;
}

function showSAPDetails(program_id)
{
NewWindow('/common_files/contracts/show_sap_references.cfm?CID='+program_id,'ShowSAPReferenceNumbers','500','300','Yes', 'Yes');
}

function chkAllBxs(curState) {
	if(document.all.SelectedPrograms != null) {
		e = document.all.SelectedPrograms
		if(e.length != null) {
			for(var x=0; x<e.length; x++) {
				document.all.SelectedPrograms[x].checked = curState;
			}
		}
		else {
			document.all.SelectedPrograms.checked = curState;
		}
	}
}
	<!--- BSD: D11652 Used in the Pending Accept Tab.
	      Changes the Span to be either "W" or "L" and updates the
	      hidden form field to change the status --->
	function changeWonLost()
	{
		var currentValue = document.getElementById('wonLostStatusTop').innerHTML;
		currentStatusList = "";
		var currentCheckbox;
		for (var i = 0; i < document.all.statusCheckBox.length; i++)
		{
			currentCheckbox = document.all.statusCheckBox[i];
			if(currentCheckbox.getAttribute("bCanChangeBidStatus") == "1")
			{
				if (currentValue == "L")
				{
					document.getElementById('wonlost_'+ currentCheckbox.value).innerHTML = "L";
  				}
  				else
  				{
      				document.getElementById('wonlost_'+ currentCheckbox.value).innerHTML = "W";
  				}

  				// We need to fire an event to uncheck and recheck the checkbox if it is already checked
   				// so the values are refreshed to reflect teh won/lost change from the list
   				if(currentCheckbox.checked)
   				{
   					currentCheckbox.fireEvent("onclick", currentCheckbox.checked=false);
   					currentCheckbox.fireEvent("onclick", currentCheckbox.checked=true);
   				}
			}
		}
		// change the header multi select from won->lost or lost->won
		if (currentValue == "L")
		{
			document.getElementById('wonLostStatusTop').innerHTML = "W";
		}
		else
		{
			document.getElementById('wonLostStatusTop').innerHTML = "L";
		}

	  }


	<!--- BSD: D11652 Changes the Won Lost status based on the record clicked --->
	function changeWonLostById(id)
	{
		var currentStatus = document.getElementById(id).innerHTML;
		var location = new Array();
		currentStatusList = "";

		for (var i=0;i<document.all.statusCheckBox.length;i++)
		{
			if (document.all.statusCheckBox[i].checked)
			{
				location.push(i);
			}
		}

		if (document.all.checkedStatus)
		{
			if (document.all.checkedStatus.checked)
			{
				document.all.checkedStatus.checked = false;
			}
		}

		if (currentStatus == "W")
		{
			document.getElementById(id).innerHTML = "L";
		}
		else
		{
			document.getElementById(id).innerHTML = "W";
		}

		for (var x=0;x<location.length;x++)
		{
			document.all.statusCheckBox[location[x]].fireEvent("onclick", document.all.statusCheckBox[location[x]].checked=false);
			document.all.statusCheckBox[location[x]].fireEvent("onclick",document.all.statusCheckBox[location[x]].checked=true);
		}

	}


	<!--- BSD: D11652 Checks all checkboxes when in the Pending Accept tab.
	      Fires event handler to update selectedProgramListManage() function
	      so that the values are stored --->
	function checkAllStatus()
	{
		currentStatusList = "";
		if(document.all.statusCheckBox)
		{
			if(document.all.statusCheckBox.length)
			{
				for (var i = 0; i < document.all.statusCheckBox.length; i++)
				{
					if (document.all.checkedStatus.checked)
					{
						document.all.statusCheckBox[i].checked = false;
						document.all.statusCheckBox[i].click();
						//document.all.statusCheckBox[i].fireEvent("onclick", selectedProgramStatusManage(document.all.statusCheckBox[i].value));
					}
					else
					{
						document.all.statusCheckBox[i].checked = true;
						document.all.statusCheckBox[i].click();
						//document.all.statusCheckBox[i].fireEvent("onclick", selectedProgramStatusManage(document.all.statusCheckBox[i].value));
					}
				}
			}
			else
			{
				if (document.all.checkedStatus.checked)
				{
					document.all.statusCheckBox.checked = false;
					document.all.statusCheckBox.click();
				}
				else
				{
					document.all.statusCheckBox.checked = true;
					document.all.statusCheckBox.click();
				}
			}
		}
	}

</script>


<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js">
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
document.body.onload=new Function ("popupInit();statusCheck();");

function statusCheck()
{
	if (!document.all.statusCheckBox || document.all.statusCheckBox.length == null)
	{
		if(document.all.TR_Top_Select_All)
		{
			document.all.TR_Top_Select_All.style.display = "none";
		}
	}
}

function initTheTooltip(ToolTipText)
{

	/*if(ToolTipText != '')
	{
	textHolder = ToolTipText;
		messages[0]="";
		messages[0]= "" + textHolder + ""
		popUp(0)
	}
	else
	{*/
	popUp(-1)

}

function showrevisiondetails(contractid,status)
{
	NewWindow('/reportwriter/performance_reports/revisionreport.cfm?Contract_main_id='+contractid+'&Contract_Status='+status,'ProgramRevisionDetails','1200','550','Yes', 'Yes')

}

</SCRIPT>
<!------
<TABLE BORDER="0" WIDTH="<CFOUTPUT>#Table_Width#</CFOUTPUT>" CELLPADDING="2" CELLSPACING="0"CLASS="Maintable" >
----->
<STYLE>
 thead { display: table-header-group }
</STYLE>

<cfif form.readOnlyCatalogSearch eq 1 AND SECTION_TO_OPEN eq "">
	<cfset SECTION_TO_OPEN = 9>
</cfif>


<form name="test">

<cfinclude template="program_status_tool_tip.cfm" />
<cfoutput>#programStatusToolTip#</cfoutput>

<!-----  the header of the table goes here  ----->
<cfif printresults EQ 1>
<TABLE border="0" WIDTH="<CFOUTPUT>#Table_Width#</CFOUTPUT>" cellspacing="0" cellpadding="4" CLASS="Maintable">
<THEAD>

<cfoutput>

<tr bordercolordark="000000" bgcolor="000000">
	<td class="t_292" width="#Status_Width#" STYLE="color:##FFFFFF;font-size:8pt;font-weight:bold">STATUS</td>
      <td class="t_293" nowrap width="#Number_Width#" STYLE="color:##FFFFFF;font-size:8pt;font-weight:bold">PROGRAM</td>
      <td class="t_294" width="#Type_Width#" STYLE="color:##FFFFFF;font-size:8pt;font-weight:bold">TYPE</td>
	  <td class="t_295" width="#Title_Width#" STYLE="color:##FFFFFF;font-size:8pt;font-weight:bold">TITLE</td>
			<!--- Dev Note: Milan; D6320. Show  neither "operator" nor "distributor" on the scorecard --->
	  	<CFIF appSettings.getProgramScoreCard() NEQ 0>
			<td class="t_298" width="#Operator_Width#" CLASS="tableheaders" STYLE="color:##FFFFFF;font-size:8pt;font-weight:bold">#UCASE(application.returned_customer_setting.operator_label_singular)#</TD>
		</CFIF>
	  <td class="t_300" width="#Evaluate(SD_Width+ED_Width)#" STYLE="color:##FFFFFF;font-size:8pt;font-weight:bold">START/END</td>
	  <td class="t_301" width="#Quantity_Width#" STYLE="color:##FFFFFF;font-size:8pt;font-weight:bold">QTY.</td>
</tr>

</cfoutput>

</THEAD>
<CFELSE>
<TABLE border="0" WIDTH="<CFOUTPUT>#Table_Width#</CFOUTPUT>" cellspacing="0" cellpadding="2" CLASS="Maintable">
</cfif>


<cfif printresults EQ 1>
	<cfset StartRow = 1>
	<cfset MaxRows = TheQuery.Recordcount>
</cfif>
<CFIF MaxRows LT 1 or Not IsNumeric(MaxRows)>
	<cfset MaxRows = 1>
</CFIF>

<cfif SECTION_TO_OPEN neq 9>
	<tr bgcolor="#FFE083" id="TR_Top_Select_All">
		<td class="t_322"  STYLE="border:none;padding:0;"><input type="Checkbox" name="checkedStatus" onclick="checkAllStatus()" /></td>
		<td class="t_323"  STYLE="border:none;" colspan="9" align="left">
			<cfif TheQuery.Contract_Status_Type_IDX eq 10>
			<a href="javascript:;" onclick="changeWonLost();"><span id="wonLostStatusTop">L</span></a>
			<cfelse>&nbsp;
			</cfif>
		</td>
		<cfif appSettings.getProgramScoreCard() EQ 2>
			<td class="t_330" STYLE="border:none;" align="left">&nbsp;</td>
		</cfif>
	</tr>
</cfif>

<CFPARAM name="justACatalog" default="0">
<CFPARAM name="CatalogView" default="#justACatalog#">

<cfset status_images = [
                        "/images/wip.gif"
                        ,"/images/rfa.gif"
                        ,""
                        ,"/images/preactive.gif"
                        ,"/images/active.gif"
                        ,"/images/expiring.gif"
                        ,"/images/expired.gif"
                        ,"/images/not_allowed.gif"
                        ,""
                        ,"/images/pending_accept.gif"
                        ]>
<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
		<!---BJF D9992 added this in so if these results are coming from operator search list it uses catalog view --->
		<cfif UseCatalogView IS 1>
			<cfset CatalogView = 1>
		<cfelse>
			<cfset CatalogView = justACatalog>
		</cfif>

	<CFPARAM name="Catalog_Type" default="0">
	<cf_cryp string="#TheQuery.Contract_Main_ID#" type="en" key="#request.key#">

	<CFIF CatalogView>
		<CFSET BG_COLOR = "FFEFD5">
	<CFELSE>
		<CFIF currentrow mod 2>
			<CFSET BG_COLOR = "white">
		<CFELSE>
			<CFSET BG_COLOR = "ccffcc">
		</CFIF>
	</CFIF>
	<TR BGCOLOR="#BG_COLOR#" VALIGN="TOP"<CFIF CatalogView> TITLE="Read Only Catalog"</CFIF>>
		<cfif SECTION_TO_OPEN neq 9>
			<cfif URL.ShowCheckBoxes EQ 1><td><img src="/images/fill.gif" width="1" height="1">
			<input type="Checkbox" name="SelectedPrograms" value="#TheQuery.Contract_Main_ID#" <cfif listfind(form.PL_Final, TheQuery.Contract_Main_ID) NEQ 0> checked <cfset form.ILPL_PreSubmit = listappend(form.ILPL_PreSubmit, TheQuery.Contract_Main_ID)></cfif>></td></cfif>
		</cfif>
		<td class="t_375" NOWRAP ALIGN="left" WIDTH="#Status_Width#">
		<cfif printresults EQ 0>
			<cfset bCanMassApprove = 0 />
			<cfset bCanChangeBidStatus = 0 />
			<cfset bIncludeInReport = 0 />
			<cfset bCurrentProgramChecked = 0 />
			<cfset bShowCheckbox = 0 />
			<cfset sCheckboxActions = "" />
			<cfif Contract_Status_Type_IDX eq 2>
				<cfif url.ShowRFAMassApproveCheckBox EQ 1 AND NOT CatalogView>
					<cfset bShowCheckbox = 1 />
					<cfset sCheckboxActions = ListAppend(sCheckboxActions, "Group Approval") />
					<cfset bCanMassApprove = 1 />
					<cfif listfind(form.currentProgramList,TheQuery.Contract_Main_ID) GT 0>
						<cfset bCurrentProgramChecked = 1 />
					</cfif>
					<!-----<input type="checkbox" value="#TheQuery.Contract_Main_ID#" title="Check this box to include it in the Group Approval Action" onclick="selectedProgramListManage(this)" <cfif listfind(form.currentProgramList,TheQuery.Contract_Main_ID) GT 0>CHECKED</cfif>>---->
				</cfif>
			</cfif>
			<!--- Pending Accept Checkboxes. Used for Mass approval Edit Status --->
			<cfif Contract_Status_Type_IDX eq 10>
				<cfset bShowCheckbox = 1 />
				<cfset sCheckboxActions = ListAppend(sCheckboxActions, "Edit Status") />
				<cfset bCanChangeBidStatus = 1 />
				<cfif listFind(form.currentStatusList2,TheQuery.Contract_Main_ID) GT 0>
					<cfset bCurrentProgramChecked = 1 />
				</cfif>
	              <!-----<input type="checkbox" value="#TheQuery.Contract_Main_ID#" name="statusCheckBox" id="statusCheckBox" title="Check this box to include it in the Edit Status Action" onclick="selectedProgramStatusManage(this)" <cfif listFind(form.currentStatusList2,TheQuery.Contract_Main_ID) GT 0>CHECKED</cfif>>----->
			</cfif>
				<!--- Claim Rates Report --->
				<cfif form.Report_Type eq 1>
					<cfset bShowCheckbox = 1 />
					<cfset sCheckboxActions = ListAppend(sCheckboxActions, "Claim Rates Report") />
					<cfset bIncludeInReport = 1 />

				<!--- Pricing Report --->
				<cfelseif form.Report_Type eq 2>
					<cfset bShowCheckbox = 1 />
					<cfset sCheckboxActions = ListAppend(sCheckboxActions, "Pricing Report") />
					<cfset bIncludeInReport = 1 />

				</cfif>

    			<cfif #variables.dr_type# eq 'htm'>
					<cfset bShowCheckbox = 1 />
			    </cfif>


			<!--- Either Claim Rates Report or Pricing Report --->
			<cfif form.Report_Type eq 1 OR form.Report_Type EQ 2>
				<cfif listFind(form.currentReportProgramList,TheQuery.Contract_Main_ID) GT 0>
					<cfset bCurrentProgramChecked = 1 />
				</cfif>
			</cfif>
			<cfif SECTION_TO_OPEN neq 9>
				<cfif bShowCheckbox>
					<input type="checkbox" value="#TheQuery.Contract_Main_ID#" name="statusCheckBox" id="statusCheckBox"
						bCanMassApprove="#bCanMassApprove#"
						bCanChangeBidStatus="#bCanChangeBidStatus#"
						bIncludeInReport="#bIncludeInReport#"
						title="Check this box to include it in the '#sCheckboxActions#' Action"
						onclick="<cfif bCanMassApprove>selectedProgramListManage(this);</cfif><cfif bCanChangeBidStatus>selectedProgramStatusManage(this);</cfif><cfif bIncludeInReport>selectedProgramListReport(this);</cfif>;void(0);"
						<cfif bCurrentProgramChecked>CHECKED</cfif>
					>
				 <cfelse><input type="checkbox" name="dummycheckbox" style="visibility:hidden">
				</cfif>
			</cfif>
		</cfif>

		<!---- show checkbox if this program is eligible for  ---->
		<!--- #getProgramStatusImageString(TheQuery.Contract_Status_Type_IDX)# --->
        <cfif TheQuery.Contract_Status_Type_IDX gte 0 and TheQuery.Contract_Status_Type_IDX lte 10 and status_images[TheQuery.Contract_Status_Type_IDX] gt "">
            <IMG SRC="#status_images[TheQuery.Contract_Status_Type_IDX]#" onmouseover="initTheTooltip('')" onmouseout="popOut()">
        </cfif>

			<cfif printresults EQ 0>
			<!--- show a lock for locked contracts, or contracts under modify agree --->
			<CFIF TheQuery.Contract_Is_Locked EQ 1 OR (TheQuery.modifying_user_id NEQ request.AccessStructure.User_ID and TheQuery.modifying_program EQ 1)>
				<cfif TheQuery.Contract_Is_Locked EQ 1>
					<cfquery name="LookUpTheLockingUser" datasource="#application.datasource#">
						SELECT Name_First, Name_Last
						FROM _Users
						WHERE User_ID = '#TheQuery.Contract_Locked_By_User_ID#'
					</cfquery>

					<IMG SRC="/images/lock.gif" TITLE="This program is currently being viewed by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#" height="16" width="12">
				<cfelse>
					<cfquery name="LookUpTheLockingUser" datasource="#application.datasource#">
						SELECT Name_First, Name_Last
						FROM _Users
						WHERE User_ID = '#TheQuery.modifying_user_id#'
					</cfquery>

					<IMG SRC="/images/modify_agree_lock.gif" TITLE="This program is currently being edited by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#" height="16" width="12">
				</cfif>

			<CFELSE>
				<IMG SRC="/images/fill.gif" height="16" width="12">
			</CFIF>
			<CFIF TheQuery.Contract_Attachments_Count GT 0>
				<IMG SRC="/images/doc.gif" width="13" height="16" TITLE="This program has #TheQuery.Contract_Attachments_Count# attached document(s)" height="16" width="13">
			<CFELSE>
				<IMG SRC="/images/fill.gif" width="13" height="16">
			</CFIF>
			<cfset Auto_Renew_Info_Available = 0 />
			<CFIF Auto_Renew EQ 1 ><!--- AND Contract_Status_Type_IDX GT 2 --->
				<CFQUERY NAME="Get_Auto_Renew_Info" DATASOURCE="#application.datasource#">
					SELECT	DATEDIFF(d, GetDate(), AR_Notification_Date) AS After_Days, AR_Notification_Date
					FROM	Program_Auto_Renew
					WHERE	Program_Auto_Renew.Renewed = 0
					AND		Program_Auto_Renew.Deleted = 0
					AND		Program_Auto_Renew.Active = 1
					AND		Program_Auto_Renew.Program_ID = #contract_main_id#
				</CFQUERY>
				<CFIF Get_Auto_Renew_Info.RecordCount GT 0><!----- Display will auto renew message ----->
					<cfset Auto_Renew_Info_Available = 1 />
					<cfset AR_Creation_Date = Get_Auto_Renew_Info.AR_Notification_Date />
					<cfset AR_After_Days = Get_Auto_Renew_Info.After_Days />
					<cfif AR_After_Days LTE 0>
						<cfset AR_Creation_Date = Now() + 1 />
						<cfset AR_After_Days = 1 />
					</cfif>
					<IMG SRC="/images/recycle1.gif" width="12" height="12" TITLE="This program will be automatically renewed on #DateFormat(AR_Creation_Date, "mm/dd/yyyy")# (#AR_After_Days# day(s))">
				<CFELSE>
					<CFQUERY NAME="Get_Auto_Renewed_Info" DATASOURCE="#application.datasource#">
						SELECT	Contract_Main.Contract_Number, Contract_Main.Contract_title
						FROM	Program_Auto_Renew
						INNER JOIN Contract_Main
						ON		Contract_Main.Deleted = 0
						AND		Contract_Main.Is_AutoRenew = 1
						AND		Contract_Main.Renewal_Of_Contract_main_ID = Program_Auto_Renew.Program_ID
						WHERE	Program_Auto_Renew.Renewed = 1
						AND		Program_Auto_Renew.Deleted = 0
						AND		Program_Auto_Renew.Active = 1
						AND		Program_Auto_Renew.Program_ID = #contract_main_id#
					</CFQUERY>
					<CFIF Get_Auto_Renewed_Info.RecordCount GT 0><!----- Display already auto renewed message ----->
						<cfset Auto_Renew_Info_Available = 1 />
						<IMG SRC="/images/recycle1.gif" width="12" height="12" TITLE="This program has automatically renewed to create program [#Get_Auto_Renewed_Info.Contract_Number#] #JSStringFormat(Get_Auto_Renewed_Info.Contract_title)#">
					</CFIF>
				</CFIF>
			</CFIF>
			<cfif Auto_Renew_Info_Available eq 0><IMG SRC="/images/fill.gif" width="12" height="12"></cfif>
			</cfif>
		</TD>
		<cfif SECTION_TO_OPEN neq 9>
			<cfif printresults EQ 0>
	        	<td class="t_522" <!---WIDTH="#Status_Width#"--->>
					<cfif Contract_Status_Type_IDX eq 10>
						<a href="javascript:;" onclick="changeWonLostById('wonlost_#TheQuery.Contract_Main_ID#');"><span id="wonlost_#TheQuery.Contract_Main_ID#" style="position:absolute;text-align:left;cursor:pointer;">W</span></a><span>&nbsp;&nbsp;&nbsp;</span>
					<cfelse>
						&nbsp;
					</cfif>
				</td>
			</cfif>
		</cfif>
		<td class="t_531" nowrap WIDTH="#Number_Width#" align="left">
		<CF_CRYP type="en" key="#request.key#" string="#TheQuery.contract_main_id#">
		<CFSET CID = cryp.value>
		<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>
		<cfset windowWidth = 815>
		<cfset windowHeight = 650>
		<cfif CatalogView>
			<cfset targetURL = "/scorecard/program_display.cfm?CID=#CID#&CatalogView=1">
			<cfset targetWindow = "_blank">
			<cfif Catalog_Type EQ 1>
				<cfset windowWidth = 800>
				<cfset windowHeight = 600>
			</cfif>
		<cfelse>
			<cfset targetURL = "/common_files/contracts/contract_edit_menu.cfm?CID=#CID#">
			<cfset targetWindow = "_parent">
		</cfif>
		<!--- Ana's New Code --->
		<CFSET ShowLink_AckedSuccessfully = 1>
		<CFIF left(application.returned_customer_setting.Customer_Keyword,6) EQ "Foster">
			<CFIF Approved EQ 1 AND Sent_To_External_Client NEQ 1>
				<CFIF Generic_Type EQ "Distributor Trade/Shelter" OR Discount_Identifier_Number EQ "ZDis" OR Discount_Identifier_Number EQ "ZNet">
					<CFSET ShowLink_AckedSuccessfully = 0>
				</CFIF>
				<CFIF ShowLink_AckedSuccessfully EQ 1>
					<cfquery name="IsALumpsum" datasource="#application.datasource#">
						SELECT Top 1 Program_ID FROM Program_Lump_Sums	WHERE Program_ID = #contract_main_id# AND Program_Lump_Sums.deleted = 0
					</cfquery>
					<CFIF IsALumpsum.RecordCount GT 0>
						<CFSET ShowLink_AckedSuccessfully = 0>
					</CFIF>
				</CFIF>
				<CFIF ShowLink_AckedSuccessfully EQ 0>
					<cfquery name="AnyDirectCustomers" datasource="#application.datasource#">
						SELECT TOP 1 Customer_Type,BSA_FoodService_Customers.BSA_FoodService_Customers_ID FROM Contract_Distributors
						INNER JOIN BSA_FoodService_Customers ON BSA_FoodService_Customers.BSA_FoodService_Customers_ID = Contract_Distributors.BSA_FoodService_Customers_ID
						WHERE Contract_main_ID = #contract_main_id# AND (Customer_Type IS NULL OR Customer_Type <> 'I')
					</cfquery>
					<!--- Any eligible component to send --->
					<cfquery name="AnyEligibleFixed" datasource="#application.datasource#">
						SELECT		TOP 1 Program_Fixed_Component_Name.External_ID
						FROM		Program_Fixed_Component

						INNER JOIN 	Program_Fixed_Component_Name ON Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID AND
									Program_Fixed_Component_Name.External_ID <> 'XX' AND
									Program_Fixed_Component.deleted = 0 AND
									Program_Fixed_Component.program_id = #contract_main_id#
					</cfquery>
					<cfquery name="AnyEligibleRebate" datasource="#application.datasource#">
						SELECT		TOP 1 Program_Rebates_Component_Name.External_ID
						FROM		Program_Rebates_Component

						INNER JOIN	Program_Rebates_Component_Name ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID AND
									Program_Rebates_Component_Name.External_ID <> 'XX' AND
									Program_Rebates_Component.deleted = 0 AND
									Program_Rebates_Component.program_id = #contract_main_id#
					</cfquery>
					<cfquery name="AnyEligibleLS" datasource="#application.datasource#">
						SELECT		TOP 1 Program_Lump_Sum_Name.External_ID
						FROM		Program_Lump_Sums

						INNER JOIN	Program_Lump_Sum_Name ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID AND
									Program_Lump_Sum_Name.External_ID <> 'XX' AND
									Program_Lump_Sums.deleted = 0 AND
									Program_Lump_Sums.program_id = #contract_main_id#
					</cfquery>
					<cfquery name="AnyEligibleGrowth" datasource="#application.datasource#">
						SELECT		TOP 1 Program_Growth_Components_Name.External_ID
						FROM		Program_Growth_Components

						INNER JOIN	Program_Growth_Components_Name ON Program_Growth_Components_Name.Program_Growth_Components_Name_Id = Program_Growth_Components.Program_Growth_Components_Name_Id AND
									Program_Growth_Components_Name.External_ID <> 'XX' AND
									Program_Growth_Components.deleted = 0 AND
									Program_Growth_Components.program_id  = #contract_main_id#
					</cfquery>
					<!--- End Any eligible component to send --->
					<CFIF (AnyDirectCustomers.RecordCount EQ 0 AND AnyEligibleLS.RecordCount EQ 0) OR (AnyEligibleFixed.RecordCount EQ 0 AND AnyEligibleRebate.RecordCount EQ 0 AND AnyEligibleLS.RecordCount EQ 0 AND AnyEligibleGrowth.RecordCount EQ 0)>
						<CFSET ShowLink_AckedSuccessfully = 1>
					</CFIF>
				</CFIF>
			</CFIF>
		</CFIF>
		<!--- Ana's New Code --->
		<cfif URL.SearchIsConductedFromOtherWindow EQ 0 AND ShowLink_AckedSuccessfully EQ 1>
		<A <cfif CatalogView> onClick="javaScript: NewWindow(this.href , 'Catalog_Program' , #windowWidth# , #windowHeight# , 'yes' , 'yes'); return false;"</cfif> target="#targetWindow#" HREF="#targetURL#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">
		#Replace(Contract_Number,"000-","")#<Cfif TheQuery.Contract_Status_Type_IDX GT 2>-<cfif len(revision_version) eq 4>#right("#revision_version#", 4)#<cfelseif len(revision_version) eq 5>#right("#revision_version#", 5)#<cfelse>#right("000#revision_version#", 3)#</cfif></CFIF>
		</A>
		<cfelse>
		#Replace(Contract_Number,"000-","")#<Cfif TheQuery.Contract_Status_Type_IDX GT 2>-<cfif len(revision_version) eq 4>#right("#revision_version#", 4)#<cfelseif len(revision_version) eq 5>#right("#revision_version#", 5)#<cfelse>#right("000#revision_version#", 3)#</cfif></cfif>
		</cfif>
		<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>
		<cfif rejected eq 1 and Contract_Status_Type_IDX EQ 1>
			<span STYLE="color: red;">[disagreed]</span>
		</cfif>
		<cfif printresults EQ 0>

		<!---BJF D8904: I need to see if there are any revisions of this program and show an icon to indicate their existance if there are--->
		<cfsilent>
			<cfquery name="AreThereRevisions" datasource="#application.datasource#">
			SELECT count(Contract_Main_ID) AS numberofrevisions FROM Contract_Main WHERE Revision_of_Contract_Main_ID = #TheQuery.contract_main_id# AND Deleted = 0
			</cfquery>
<!--- <cfquery name="qryIsRolledOverProgram" datasource="#application.datasource#">
	SELECT Rollover_from_Contract_Main_ID FROM Contract_Main  WHERE Contract_Main_ID = #TheQuery.contract_main_id# AND Deleted = 0
</cfquery>  --->
		</cfsilent>
			<!--- Dev Note: KAL; 9962 : whats the logic behind gray and red triangles  --->
			<cfif AreThereRevisions.numberofrevisions GT 0>
				<cfset imgsrc = "/images/delta_gray.gif">
				<cfset imgclick = "STYLE=""cursor:pointer;"" onclick=""javascript:showrevisiondetails('#TheQuery.contract_main_id#','#TheQuery.Contract_Status_Type_IDX#');""">
				<cfset imgALT = "This program has been Revised..." >
			<cfelseif Revision_of_Contract_Main_ID NEQ "" AND Is_A_Revision EQ 1>
				<cfif appSettings.getPgmScorecardRevisionReport() EQ 1>
					<cfset imgsrc = "/images/delta.gif">
					<cfset imgclick = "STYLE=""cursor:pointer;"" onclick=""javascript:showrevisiondetails('#TheQuery.contract_main_id#','#TheQuery.Contract_Status_Type_IDX#');""">
				<cfelse>
					<cfset imgsrc = "/images/repeat.gif">
					<cfset imgclick = "">
				</cfif>
				<cfset imgALT = "This is a Revision..." >
			<cfelse>
				<cfset imgsrc = "/images/fill.gif">
				<cfset imgclick = "">
				<cfset imgALT = "" >
			</cfif>
		<div style="width:100%;height:15px;">
			<div style="float:left;width:10%;padding-top: 5px;">
			<IMG SRC="#imgsrc#" BORDER="0" TITLE="#imgALT#" #imgclick#>
			<!--- <cfif (IsRollOver EQ 1) OR (qryIsRolledOverProgram.Rollover_from_Contract_Main_ID NEQ "")><IMG SRC="/images/roll_over.gif" width="10" height="10" BORDER="0" ALT="This is a Rollover..."></cfif> --->
			<cfif IsRollOver EQ 1><IMG SRC="/images/roll_over.gif" width="10" height="10" BORDER="0" TITLE="This is a Rollover..."></cfif>
			<!---Displays icon if the program is cancelled--->
			<cfif Contract_Status_Type_IDX IS 7 AND len(trim(Cancelled_Date)) GT 0>
			<img src="/images/delete.gif" title="Cancelled by #Cancelled_Name#">
			</cfif>
		<cfif appsettings.getSend_to_SAP()>
			<cfif Sent_To_External_Client EQ 1 OR error_from_external_client EQ 1>
			<cfif Sent_To_External_Client EQ 1>
				<cfset helpmessage = "This program is being sent to SAP">
			<cfelseif Error_From_External_Client EQ 1>
				<cfset helpmessage = "Errors in sending data to SAP">
			</cfif>
		<A HREF="javascript:showSAPDetails('#TheQuery.Contract_Main_ID#')"> <CF_SmallHelp
				imgWidth = "10"
				imgHeight = "10"
				imgPath="/images/exclamation.gif"
				dropdownCheck="0">#helpmessage#</CF_SmallHelp></A>
			</cfif>
		<cfelseif Cancel_Sent_to_Client EQ 1>
			<IMG SRC="/images/arrow2_red.gif" width="10" height="10" title="This program has been cancelled in ERP #chr(13)##chr(10)#Cancel Date: #Cancelled_Date# #chr(13)##chr(10)#Cancel Acknowledge Date: #External_Client_Cancel_Ack_Date#">
		<cfelseif Sent_To_External_Client EQ 1>
			<IMG SRC="/images/arrow2.gif" width="10" height="10" title="This program has been successfully loaded in ERP #chr(13)##chr(10)#Send Date: #last_extract_date# #chr(13)##chr(10)#Acknowledge Date: #External_Client_Ack_Date#">
		<cfelseif Sending_To_External_Client EQ 1>
			<IMG SRC="/images/arrow1.gif" width="10" height="10" title="This program is being sent to ERP #chr(13)##chr(10)#Send Date: #last_extract_date# #chr(13)##chr(10)#Acknowledge Date: #External_Client_Ack_Date#">
		<cfelseif Unsuccessful_Ack_From_External_Client EQ 1>
			<IMG SRC="/images/process_failed.gif" width="10" height="10" title="#Unsuccessful_Ack_Reason_From_External_Client#">
		<cfelse>
			<IMG SRC="/images/fill.gif" width="10" height="10">
		</cfif>
		</div>
		<!--- Dev Note: Clay 9825: Program_display not found in /common_files/contract/ Made the file reference explicit from root --->
		<div style="width:80%;float:right;text-align: left;">
		<!------ D10082: Preview link should not be available in catalog view, it might conflict with the summary/detail view restrictions ----->
			<cfif NOT CatalogView>
			<A onClick="javaScript: NewWindow(this.href , 'Catalog_Program' , #windowWidth# , #windowHeight# , 'yes' , 'yes'); return false;" target="_blank" HREF="/scorecard/program_display.cfm?display_program=1&CID=#CID#" TITLE="View the details for program #Contract_Number#">#application.util.string.actionLinkFormat2('Preview')#
			</A>
			</cfif>
		</div>
	</div>
		<cfif Claim_Mechanics>
			<div style="width:100%;">
				<div style="float:left;width:10%;">&nbsp;</div>
				<div style="width:80%;float:right;text-align: left;">
					<A onClick="javaScript: NewWindow(this.href , 'Quick_Pay' , 500 , 500 , 'yes' , 'yes'); return false;" target="_blank" HREF="/scorecard/quick_pay.cfm?CID=#CID#" TITLE="Quick Pay for program #Contract_Number#">
						#application.util.string.actionLinkFormat2('Quick Pay')#
					</A>
				</div>
			</div>
		</cfif>
		</CFIF>
		</TD>
		<td class="t_710" WIDTH="#Type_Width#" TITLE="#Created_Type#" align="left">
			<CFSET display_Title=Left(Created_Type,Type_Len)>
			<CFIF LEN(display_Title) LT Len(Created_Type)>
				<CFSET display_Title="#display_Title#...">
			</CFIF>
			<CFIF len(trim(display_Title)) EQ 0>
				<CFSET display_Title="&nbsp;">
			</CFIF>

			#display_Title#
			<cfif application.returned_customer_setting.Accounting_Specialist eq 1>

				<!---create the data struct to pass to the accountinSpecialist section if it's on in customer settings--->
				<cfset tmpStruct = StructNew() />
				<cfset tmpStruct.programId = Contract_Main_ID />
				<cfset tmpStruct.profileId = request.AccessStructure.Profiles_ID />
				<!---if the status is 1 or 2 then allow specialist to be edited--->
				<cfif ListFindNoCase("1,2,3,4,5,6,7", Contract_Status_Type_IDX)>
					<cfset tmpStruct.handler = "edit" />
				<cfelse>
					<cfset tmpStruct.handler = "display" />
				</cfif>
				<!---layout is just a namespace for the custom tag lib--->
				<layout:section name="views.programs.accountingSpecialist" parameters="#tmpStruct#">

			</cfif>
			<cfif application.returned_customer_setting.Responsible_Person>
				<div title="Sales Person Responsible: #SalesPerson_Responsible#">SP: <cfif Len(SalesPerson_Responsible)>#SalesPerson_Responsible#<cfelse>None</cfif></div>
			</cfif>

		</TD>

		<cfif printresults EQ 0>
		<cfset SafeTitle = replace(Contract_Title, """", "'", "all")>
			<!--- <cfif len(Contract_Reference_Number) gt 100> --->
				<td class="t_745"   TITLE="#SafeTitle#">
			<!--- <cfelse>
				<td class="t_747" nowrap width="#Title_Width#" TITLE="#SafeTitle#">
			</cfif> --->
		<cfelse>
		<td class="t_750" nowrap TITLE="#Contract_Title#">
		</cfif>
		<CFIF Contract_Reference_Number NEQ "">
			<CFSET Ref_Num_Len=len(Contract_Reference_Number) + 5>
		<CFELSE>
			<CFSET Ref_Num_Len=0>
		</CFIF>
		<CFIF Ref_Num_Len GTE Title_Len>
			<CFSET Title_Len=Ref_Num_Len+2>
		</CFIF>
		<!--- <CFSET display_Title=Left(Contract_Title,Title_Len-Ref_Num_Len)> --->
		<CFSET display_Title=Left(Contract_Title,Title_Len)>
		<CFIF LEN(display_Title) LT Len(Contract_Title)>
			<CFSET display_Title="#display_Title#...">
		</CFIF>
		#display_Title#<CFIF Contract_Reference_Number NEQ "">&nbsp;( #Contract_Reference_Number# )</CFIF>
		<BR>
		<CFIF TheQuery.Contract_Status_Type_IDX EQ 2>
			<B>Requesting Approval</B>:&nbsp;#Name_First# #Name_Last# - #dateformat(Broker_Approved_Date, 'mm/dd/yyyy')#
			<CFIF appSettings.getProgramAgreeEscalate()>
			<div title="Currently Responsible for Approval: #Position_To_Approve_Label#">
			<a href="##" onclick="javaScript:NewWindow('/scorecard/show_approvable_users.cfm?CID=#contract_main_id#&businessSegmentsOn=#form.businessSegmentsOn#&ResponsibleUser=#Responsible_User_ID#','ShowApprovableUsers','700','300','Yes', 'Yes');return false;">CRA: #Position_To_Approve_Label#</a></div>
			</CFIF>
		<CFELSEIF TheQuery.Contract_Status_Type_IDX GTE 4>
			<B>Approver</B>:&nbsp;#Name_First# #Name_Last# - #dateformat(Approval_date, 'mm/dd/yyyy')#
			<cfif appSettings.get_Requester_Approver_Position()>
			<cfif SECTION_TO_OPEN GTE 4>
			<br /><B>Position</B>: #Position_Approved_Label#
			</cfif>
			</cfif>
		<CFELSE>
			&nbsp;
		</CFIF>
		</TD>
		<!--- Dev Note: Milan; D6320. Show  neither "operator" nor "distributor" on the scorecard --->
		<CFIF appSettings.getProgramScoreCard() NEQ 0>
			<td class="t_785" NOWRAP WIDTH="#Operator_Width#">
			<CFIF Sort_By_Name EQ "1">
				<CFQUERY NAME="CheckMultiDistributor" DATASOURCE="#Application.Datasource#">
					SELECT 		TOP 2 cd.*
					FROM 		Contract_Distributors cd INNER JOIN BSA_Foodservice_Customers bsafc
					ON bsafc.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
					WHERE cd.Contract_Main_ID = '#Contract_Main_ID#'
					AND cd.Deleted = 0
					AND		bsafc.Deleted = 0
				</CFQUERY>
				<CFSET ShowOnlyDistributorLen = 20>
				<CFSET Disp_Distributor = Name>
				<CFIF LEN(Disp_Distributor) GT ShowOnlyDistributorLen>
					<CFSET Disp_Distributor = LEFT(trim(Name),ShowOnlyDistributorLen)>
					<CFSET Disp_Distributor = "#Disp_Distributor#...">
				</CFIF>
				<CFIF Disp_Distributor NEQ "">
					<br/>#Disp_Distributor#<cfif CheckMultiDistributor.RecordCount GT 1>&nbsp;<IMG SRC="\Images\multiple.gif" height="8" width="8" TITLE="Multiple"></cfif>
				</CFIF>
				<CFIF Trim(Disp_Distributor) eq "">
					<CFQUERY NAME="CheckMultiOperator" DATASOURCE="#Application.Datasource#">
						SELECT 		TOP 2 co.*, bsao.legacy_ID
						FROM 		Contract_Operators co INNER JOIN BSA_Operator bsao
						ON bsao.BSA_OPERATOR_ID = co.BSA_OPERATOR_ID
						WHERE co.Contract_Main_ID = '#Contract_Main_ID#'
						AND co.Deleted = 0
						AND		bsao.Deleted = 0
					</CFQUERY>
					<CFSET ShowOnlyOperatorLen = 20>
					<CFSET Disp_Operator = Operator_Name>
					<CFIF LEN(Operator_Name) GT ShowOnlyOperatorLen>
						<CFSET Disp_Operator = LEFT(trim(Operator_Name),ShowOnlyOperatorLen)>
						<CFSET Disp_Operator = "#Disp_Operator#...">
					</CFIF>
					<CFIF Disp_Operator NEQ "">
						#Disp_Operator#&nbsp;
						<!--- Dev Note: Milan; D6320. Show  only "operator" on the scorecard.
									OperatorID is legacy_id when legacy_id has a value, else it is BSA_Operator_ID --->
						<cfif appSettings.getProgramScoreCard() EQ 1>
							(#OperatorID#)
						</cfif>
						<cfif CheckMultiOperator.RecordCount GT 1>&nbsp;<IMG SRC="\Images\multiple.gif" height="8" width="8" TITLE="Multiple"></cfif>
					</CFIF>
				</CFIF>
				<CFIF IsDefined("Disp_Operator")>
					<CFIF Disp_Operator EQ "" AND Disp_Distributor EQ "">None</CFIF>
				<CFELSE>
					<CFIF Disp_Distributor EQ "">None</CFIF>
				</CFIF>
			<CFELSE>
				<CFQUERY NAME="CheckMultiOperator" DATASOURCE="#Application.Datasource#">
					SELECT 		TOP 2 co.*, bsao.legacy_ID
					FROM 		Contract_Operators co INNER JOIN BSA_Operator bsao
					ON bsao.BSA_OPERATOR_ID = co.BSA_OPERATOR_ID
					WHERE co.Contract_Main_ID = '#Contract_Main_ID#'
					AND co.Deleted = 0
					AND		bsao.Deleted = 0
				</CFQUERY>
				<CFSET ShowOnlyOperatorLen = 20>
				<CFSET Disp_Operator = Operator_Name>
				<CFIF LEN(Operator_Name) GT ShowOnlyOperatorLen>
					<CFSET Disp_Operator = LEFT(trim(Operator_Name),ShowOnlyOperatorLen)>
					<CFSET Disp_Operator = "#Disp_Operator#...">
				</CFIF>
				<CFIF Disp_Operator NEQ "">
					#Disp_Operator#&nbsp;
					<!--- Dev Note: Milan; D6320. Show  only "operator" on the scorecard.
									OperatorID is legacy_id when legacy_id has a value, else it is BSA_Operator_ID --->
					<cfif appSettings.getProgramScoreCard() EQ 1>
						(#OperatorID#)
					</cfif>
					<cfif CheckMultiOperator.RecordCount GT 1>&nbsp;<IMG SRC="\Images\multiple.gif" height="8" width="8" TITLE="Multiple"></cfif>
				</CFIF>
				<!--- Dev Note: Milan; D6320. Show "operator" and "distributor" on the scorecard. --->
				<CFIF appSettings.getProgramScoreCard() EQ 2>
					<!--- Only if there is no operator --->
					<CFIF Trim(Disp_Operator) eq "">
					<CFQUERY NAME="CheckMultiDistributor" DATASOURCE="#Application.Datasource#">
						SELECT 		TOP 2 cd.*
						FROM 		Contract_Distributors cd INNER JOIN BSA_Foodservice_Customers bsafc
						ON bsafc.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
						WHERE cd.Contract_Main_ID = '#Contract_Main_ID#'
						AND cd.Deleted = 0
						AND		bsafc.Deleted = 0
					</CFQUERY>
					<CFSET ShowOnlyDistributorLen = 20>
					<CFSET Disp_Distributor = Name>
					<CFIF LEN(Disp_Distributor) GT ShowOnlyDistributorLen>
						<CFSET Disp_Distributor = LEFT(trim(Name),ShowOnlyDistributorLen)>
						<CFSET Disp_Distributor = "#Disp_Distributor#...">
					</CFIF>
					<CFIF Disp_Distributor NEQ "">
						<br/>#Disp_Distributor#<cfif CheckMultiDistributor.RecordCount GT 1>&nbsp;<IMG SRC="\Images\multiple.gif" height="8" width="8" TITLE="Multiple"></cfif>
					</CFIF>
				</CFIF>
			</CFIF>
			<!--- No operators or distributors. This could happen when the program is in WIP --->
			<CFIF IsDefined("Disp_Distributor")>
				<CFIF Disp_Operator EQ "" AND Disp_Distributor EQ "">None</CFIF>
			<CFELSE>
				<CFIF Disp_Operator EQ "">None</CFIF>
			</CFIF>
		</CFIF>
		</TD>
		</CFIF>
 		<td class="t_890"  width="#Evaluate(SD_Width+ED_Width)#">#DateFormat(TheQuery.Contract_Start_Date,"mm/dd/yyyy")#<BR>#DateFormat(TheQuery.Contract_End_Date,"mm/dd/yyyy")#</TD>
		<td class="t_891"  width="#Quantity_Width#">#numberformat(Contract_Quantity, '_,___,___,___,___')# #Abbreviation#&nbsp;<br><cfif (appSettings.getApprovalLayeredOn() OR appSettings.getapprovalStandardOn()) AND Approved>#trim(Dollarformat(program_spend))#</cfif></TD>
		<cfif printresults EQ 0>
			<cfif form.businessSegmentsOn eq 1>
				<td class="t_894" width="#BusSeg_Width#" nowrap align="center" title="#HTMLEditFormat(Business_Unit_Desc)#">#Left(Business_Unit_Desc, 8)#<cfif Len(Business_Unit_Desc) gt 8>...</cfif></TD>
			</cfif>
			<cfif appSettings.getpaymenthistoryon()>
			 <cfset variables.theForm = structNew() />
			 <cfset variables.theForm.START_DATE = "" />
			 <cfset variables.theForm.END_DATE = "" />
			 <cfset variables.theForm.payee_name = "" />
			 <cfset variables.theForm.payee_id = "" />
			 <cfset variables.theForm.payee_type = "" />
			 <cfset variables.theForm.sql_Sort_By = "billback_id," />
			 <cfset variables.theForm.sort_order = "BB_Code" />
			<td class="t_905" width="#SCISSOR_Width#" align="left">
			<cfif NOT CatalogView>
                        <cfif (Is_A_Revision EQ 1 OR Contract_Status_Type_IDX GT 3) and TheQuery.payment_history gt 0><A HREF="##" style="cursor:pointer;" TITLE="Payment History for #Contract_Number#" onclick="NewWindow('/common_files/contracts/payment_history/payment_history.cfm?ContractId=#contract_main_id#','paymenthistorywindow','1150','620','Yes', 'No'); return false;"><img src="/images/time-money.gif" border = "0" widy></A><cfelse>&nbsp;</cfif>
                    </cfif>&nbsp;
                </td>
			</cfif>
			<td class="t_911" width="#SCISSOR_Width#"><cfif CatalogView eq 0 AND Contract_Status_Type_IDX LTE 2 AND URL.SearchIsConductedFromOtherWindow EQ 0 AND (Get_Profile_Settings.Delete_Program_Access EQ 1 OR Is_AutoRenew EQ 0 OR appSettings.getDeleteIsCancelAutoRenew() EQ 0)><a href="delete_program.cfm?CID=#CID#" target="_blank" onclick="return doScissors(this, '#Contract_Number#', #Is_AutoRenew#);"><img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" title="click here to delete this record" border="0" style="cursor: pointer;"></a><cfelse>&nbsp;</cfif></TD>
		</cfif>
		</TR>
</CFOUTPUT>
</TABLE>
</form>

<table align="center">
	<tr>
	<td>

<cfif CatalogView eq 0>
    <cfif variables.dr_type EQ 'htm'>
	<B><FONT COLOR="##FF0000">[</FONT><a style="cursor: pointer;" onClick="importProducts_reassign();">import selected programs</a><FONT COLOR="##FF0000">]</FONT></B>
	&nbsp;&nbsp;
	<!--- <B><FONT COLOR="##FF0000">[</FONT><a style="cursor: pointer;" onClick="importAll_1()">import all returned programs</a><FONT COLOR="##FF0000">]</FONT></B> --->
	</cfif>
</cfif>
    </td>
	</tr>
</table>
