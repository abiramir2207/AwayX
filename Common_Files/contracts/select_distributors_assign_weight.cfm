<!------ Common_Files/Contracts/select_distributors_assign_weight.cfm ----->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
    <cf_include files="/common_files/contracts/freight/program_freight.css, /script/javascript/string_functions.js, /Script/javascript/dhtml.js">
</HEAD>
<BODY>
<style>
TABLE.Maintable TD
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header
{
	font-size: 12px;
}
</style>
<cfheader name="Cache-Control" value="no-store">
<cfheader name="expires" value="-100">
<CFSET Cache_Control_Header_Already_Added = 1>

<!------ Spinner ----->
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br>
</SPAN>

<CFFLUSH>

<SCRIPT>
function hide_Spinner()
{
	if(document.all.PleaseWaitMessage)
	{
		if(document.all.PleaseWaitMessage.style)
		{
			document.all.PleaseWaitMessage.style.display='none';
		}
	}
}
hide_Spinner();
</SCRIPT>
<SCRIPT>
function resetform() {
	document.all.FinalItemList.value = 0;
	document.all.finishedselectingitems.value = 1;

	<CFIF TheQuery.Recordcount GT 0>
		document.all.SelectedITEMS.value = 0;
		for(var x=0; x<document.all.MyForm.elements.length;x++) {
			document.all.MyForm.elements[x].checked = false
		}

	</CFIF>
	document.all.MyForm.submit();
}
</SCRIPT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFIF len(FORM.Contract_Main_ID) GT 0><CFSET temp = FORM.Contract_Main_ID></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "di">
<cfif (form.plannerID EQ 0)>
	<cfif application.programLayout EQ 1>
		<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
	 		<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
		</div>
	<cfelse>
			<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
	</cfif>
</cfif>
<cfset distributorManager = CreateObject("component", "components.customer.DistributorManager").init()>
<cfset baseSettings = CreateObject("component","components.Base") />

<cfset qPrgDistExceptions = distributorManager.getProgramDistributorExceptions(FORM.Contract_Main_ID)>

<!--- seperate queries for customer and customer groups--->
<cfif form.Is_Group eq 1>

	<cfset GetDistInfo = DistGroupDataManager.getCustomerGroups(lGroup=FORM.FinalItemList, bAllDistAndGroup=1, searchFilter=StructNew(), checkLGroup=1, Program_ID=FORM.Contract_Main_ID, showDistExceptions=1) />

<cfelse>

	<!--- get the distributor information --->
	<cfset stStruct = StructNew()>
	<cfset stStruct.checkFinalItemList 	= 1>
	<cfset stStruct.FinalItemList 	= Form.FinalItemList>
	<cfset stStruct.Line_Of_Business_ID 	= Form.Line_Of_Business_ID>
	<cfset stStruct.Contract_Main_ID 	= Form.Contract_Main_ID>
	<cfset stStruct.appSettings 	= appSettings>
	<cfset stStruct.GetSettings = GetSettings>

	<cfset GetDistInfo = distributorManager.search(search= stStruct,showDistExceptions=1)>

</cfif>

<CFSET FORM.FinalItemList = ValueList(GetDistInfo.BSA_Foodservice_Customers_ID, ",")>

<cfset temparray = arrayNew(1)>
<CFSET temp = QueryAddColumn(GetDistInfo, "Program_Weight", temparray)>

<!--- get the saved weights --->
<CFQUERY NAME="GetDistPreviousWeight" datasource="#application.datasource#">
	SELECT BSA_Foodservice_Customers_ID, Program_Weight
	FROM Contract_Distributors
	WHERE
		Contract_Main_ID = '#FORM.Contract_Main_ID#'
		AND
		len(Program_Weight) > 0
		AND
		Deleted = 0
</CFQUERY>
<CFSET ListOfIds = ValueList(GetDistPreviousWeight.BSA_Foodservice_Customers_ID)>
<CFSET ListOfWeights = ValueList(GetDistPreviousWeight.Program_Weight)>

<!--- add the common distribs price weights --->
<CFSET CurrentRow = 1>
<!--- does group exist --->
<CFSET groupExists = 0>
<CFLOOP QUERY="GetDistInfo">
	<CFSET thePosition = listfind(ListOfIds,GetDistInfo.BSA_Foodservice_Customers_ID)>
	<CFIF thePosition GT 0>
		<CFSET thisPriceWeight = listgetat(ListOfWeights,thePosition)>
		<CFSET temp = QuerySetCell(GetDistInfo, "Program_Weight", thisPriceWeight, CurrentRow)>
	</CFIF>
	<CFSET CurrentRow = CurrentRow + 1>
	
	<!--- Even if one group exists, "groupExists" is set to 1. --->
	<cfif GetDistInfo.shr_ship_to eq 'GROUP' AND groupExists eq 0>
		<cfset groupExists = 1>
	</cfif>
</CFLOOP>

<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1 and GetSettings.Discount_Fixed_Prices EQ 1>
	<cfset fixedCompObj = CreateObject("component","components.programs.fixed.fixedComponent") />
</cfif>

<cfset distExceptionCount = qPrgDistExceptions.recordcount>

<CFIF GetDistInfo.recordcount EQ 0>
	<CFSET AverageWeight = 0>
<CFELSE>
	<cfset decimalLen = 2 />
	<cfset multiVar = 10 ^ decimalLen />
	<!--- Weight is not applied for "distributor exceptions" and so we need to remove the count of those exceptions. --->
	<CFSET AverageWeight = Fix((100 / (GetDistInfo.recordcount - distExceptionCount)) * multiVar)/multiVar>
</CFIF>

<BLOCKQUOTE>

<cfif application.programLayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:800px; z-index:1; left: 120px; top: 10px;"></cfif>
<CFSET helpfilenumber=5>
<cfinclude template="minimal_contract_info.cfm">
<div id="idWeightSection" style="display:none;">
<cfoutput>
<strong>If you would like to apply the same weight to all #application.returned_customer_setting.distributor_label_plural# (you expect all the #application.returned_customer_setting.distributor_label_plural# to purchase an equal volume of items) you can use this tool.<Br> Otherwise skip this section and add the weights to each #application.returned_customer_setting.distributor_label_singular# individually.</strong>
<TABLE WIDTH="90%" BORDER="0" ALIGN="center">
<TR>
	<TD VALIGN="top">
	<ul><FONT SIZE="2">
		<li>
		Enter weight that you would like to apply to all #application.returned_customer_setting.distributor_label_plural#: <input TYPE="Text" NAME="globalPercentage" SIZE="2" MAXLENGTH="5" ONKEYUP="clenseText(this, '0123456789.'); limitXdecimalplaces(2, this)">% <FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="assignGlobalWeight(2)" STYLE="cursor: pointer;"> click here to apply entered weight</A><FONT COLOR="Red"><B> ]</B></FONT></li>
		<div><b>OR</b></div>
		<LI>To assign an average weight of <div style="display:inline" id="DivAverageWeight"><cfoutput>#AverageWeight#</cfoutput></div>% <FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="assignAverageWeight()" STYLE="cursor: pointer;">click here to apply calculated weight</A><FONT COLOR="Red"><B> ]</B></FONT></LI>
	</FONT
	></ul>
	</TD>
</TR>
</table>
</cfoutput>
<hr color="navy">
</div>

<!--- To show "Select Distributor Groups" link OR "Select Distributors" link OR "both" the links --->
<cfset enableExtraGroupSearch = 0 />
<cfset enableExtraDistSearch = 0 />
<cfset showDistributorLink = 0 />
<cfset showDistributorGroupLink = 0 />
<!--- Look at the "search sequence" setting --->
<cfif appSettings.getSearchSequenceOn() AND len(trim(CSLGETCONTRACTINFO.Search_Sequence_ID)) GT 0>
	<cfset  SearchSequenceManager 	= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
	<cfset 	Program_Search_Sequence 	= SearchSequenceManager.getSearchSequenceInfo(CSLGETCONTRACTINFO.Search_Sequence_ID) />
	<cfset enableExtraGroupSearch = SearchSequenceManager.enableDistributorGroupSelection(Program_Search_Sequence) />
	<cfset enableExtraDistSearch = SearchSequenceManager.enableDistributorSelection(Program_Search_Sequence) />

	<cfif enableExtraDistSearch EQ 1 AND enableExtraGroupSearch EQ 1>
		<cfset showDistributorGroupLink = 1>
		<cfset showDistributorLink = 1>
	<cfelseif enableExtraDistSearch EQ 1>
		<cfset showDistributorLink = 1>
	<cfelseif enableExtraGroupSearch EQ 1>
		<cfset showDistributorGroupLink = 1>
	</cfif>
<!--- Look at the "template setting" --->
<cfelse>			
	<cfif qGetDistGroupData.specify_distributor_groups AND qGetDistGroupData.specify_individual_distributors>
		<cfset showDistributorGroupLink = 1>
		<cfset showDistributorLink = 1>
	<cfelseif qGetDistGroupData.specify_distributor_groups>
		<cfset showDistributorGroupLink = 1>
	<cfelseif qGetDistGroupData.specify_individual_distributors>
		<cfset showDistributorLink = 1>
	<cfelseif qGetDistGroupData.Specify_Distributors>
		<cfset showDistributorLink = 1>
	</cfif>
</cfif>

<cfset DistGroupColumnWidth = "170">
<cfset DistColumnWidth = "135">
<cfset SaveColumnWidth = "50">
<cfset EditWeightColumnWidth = "125">
<cfset FreightColumnWidth = "90">

<cfset tblWidth = DistGroupColumnWidth + DistColumnWidth>

<cfif showDistributorGroupLink eq 0>
	<cfset tblWidth = tblWidth - DistGroupColumnWidth>
<!--- If "select distributors" is OFF --->
<cfelseif showDistributorLink eq 0>
	<cfset tblWidth = tblWidth - DistColumnWidth>
</cfif>

<cfif IsFreightProgram eq 1>
	<cfset tblWidth = tblWidth + FreightColumnWidth>
</cfif>

<cfif FORM.FinalItemList neq "">
	<cfset tblWidth = tblWidth + SaveColumnWidth + EditWeightColumnWidth>
</cfif>

<cfset addDistributorAllowed = 1>
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 and RevisionSettings.Distributors_Added eq 2>
	<cfset addDistributorAllowed = 0>
</cfif>
<cfoutput>
<table style="width:#tblWidth#px" border="0">
	<TR>
		<cfif FORM.FinalItemList neq "">
		<TD style="width:#SaveColumnWidth#px" class="save_table">
			<CF_button
				button_name		=	"save"
				button_caption	=	"save"
				button_action	=	"submitForm();"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>
		</cfif>
		<cfif showDistributorGroupLink eq 1>
		<TD style="width:#DistGroupColumnWidth#px">
				<cfset text = 'select '& #LCase(application.returned_customer_setting.distributor_label_singular)#&' groups'>				
				<a href="##" <cfif addDistributorAllowed eq 1>onclick="submitSelectedEntries(1);return false;"</cfif> <cfif addDistributorAllowed eq 0>disabled</cfif>>
					#application.util.string.actionLinkFormat(text)#
				</a>
		</TD>
		</cfif>
		<cfif showDistributorLink eq 1>
		<TD style="width:#DistColumnWidth#px">
				<cfset text = 'select '& #LCase(application.returned_customer_setting.distributor_label_plural)#>
				<a href="##" <cfif addDistributorAllowed eq 1>onclick="submitSelectedEntries(0);return false;"</cfif> <cfif addDistributorAllowed eq 0>disabled</cfif>>
					#application.util.string.actionLinkFormat(text)#
				</a>
		</TD>
		</cfif>
		<cfif FORM.FinalItemList neq "">
		<TD style="width:#EditWeightColumnWidth#px">
				<cfset textShow = "show edit weight">
				<cfset textHide = "hide edit weight">
				<a href="##" OnClick="showHideWeightSection();" id="txtLinkShow">					
					#application.util.string.actionLinkFormat(textShow)#
				</a>

				<a href="##" OnClick="showHideWeightSection();" id="txtLinkHide" style="display:none;">					
					#application.util.string.actionLinkFormat(textHide)#
				</a>
		</TD>
		</cfif>
		<cfif IsFreightProgram eq 1>
		<TD nowrap style="width:#FreightColumnWidth#px">
			<sup class="overrideDisplay">&nbsp;&nbsp;* - overridden</sup>
		</TD>
		</cfif>
	</TR>
</table>
</cfoutput>

<FORM ACTION="select_distributors.cfm?CID=<cfoutput>#URL.CID#</cfoutput>" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>

<SCRIPT LANGUAGE="JavaSCript">
	var my_queue = new Queue();
</SCRIPT>

<SCRIPT LANGUAGE="JavaScript">

	function deleteThisDistributor(FieldNameRe, distID)
	{
		var trObj = document.getElementById("TR_" + FieldNameRe);
		var trIndex = trObj.rowIndex;		
		var FINALITEMLIST = document.MyForm.FinalItemList.value;
		var resultString = ListDeleteItem(FINALITEMLIST, ",", distID);
		var bDelete = 'true';
	

		if(resultString == FINALITEMLIST)
		{
			resultString = ListAppendItem(FINALITEMLIST, ",", distID);
			bDelete = 'false';
		}

		document.MyForm.FinalItemList.value = resultString;
		resetAverageWeight();
		var emptyString = "<img src=\"/Images/fill.gif\" height=\"1\">";
		/* 6 columns exist if the 2 app settings are on */
		var weightCol = 6;
		<cfif ShowBrokerInResult eq 1 and IsFreightProgram eq 1>
			weightCol = 6;
		<cfelseif ShowBrokerInResult eq 1 or IsFreightProgram eq 1>
			weightCol = 5;
		<cfelse>
			weightCol = 4;
		</cfif>;
		if(trObj)
		{
			var srcObj = event.srcElement;
			if(bDelete == 'true')
			{
				my_queue.addObjValueToQueue(distID + "_weight", "document.all.Weight_DID_" + FieldNameRe);
				//trObj.cells[0].innerHTML = emptyString;
				trObj.cells[trObj.cells.length-1].innerHTML = emptyString;
				trObj.cells[weightCol-1].innerHTML = emptyString;
				trObj.cells[weightCol].innerHTML = "<img src=\"/Images/fill.gif\" height=\"1\" width=\"50\">";
				propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);
				srcObj.title = "undo delete <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>";
                srcObj.src = undodeleteImg.src;	

                $(trObj).find("input").addClass("disabled").hide();  // ngt
				
				/* If distributor "Exclude" checkbox exists */
				if($("#excludeDistributorList").length){
					var arrExcludeDist = document.getElementById('excludeDistributorList').value.split(",");
					arrExcludeDist.splice($.inArray(FieldNameRe, arrExcludeDist),1);
					document.getElementById('excludeDistributorList').value = arrExcludeDist.join(",");
					/* Remove it from the "excludeDistributorList" list. This will make sure that this record will 
					get removed from the "contract_Distributors_Exceptions" table.
					*/
					addRemoveCustomers();
				}
			}
			else
			{		
				//trObj.cells[0].innerHTML = "<span ID=\"chkBoxCol\"><input TYPE=\"Checkbox\" checked name=\"check_Each\"></span>";
				//trObj.cells[trObj.cells.length-1].innerHTML = "<span ID=\"chkBoxCol\"><input TYPE=\"Checkbox\" checked name=\"check_Each\" class=\"check_Each\"></span>";  // 31310
				var weightCell = "<span ID=\"weightCol\"><input NAME=\"Weight_DID_" + FieldNameRe + "\" VALUE=\"\" TYPE=\"text\" CLASS=\"w_perc\" SIZE=\"2\" MAXLENGTH=\"5\" ONKEYUP=\"clenseText(this, '0123456789.'); limitXdecimalplaces(2, this)\"></span>%";
				// trObj.cells[weightCol-1].innerHTML = "<span ID=\"Er_weightCol\"></span>&nbsp;";
				// trObj.cells[weightCol].innerHTML = weightCell;
				var bgCol = "#FFFFFF";
				if(trObj.rowIndex % 2 == 0)
				{
					bgCol = "#C6FFC6";
				}
				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);
				propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);
				my_queue.deleteAndSetObjValueFromQueue(distID + "_weight", "document.all.Weight_DID_" + FieldNameRe);
				srcObj.title = "delete this <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>";
                srcObj.src = deleteImg.src;

                $(trObj).find("input").removeClass("disabled").show();  // ngt
			}
			srcObj.setAttribute('bDelete',(bDelete == 'true'?'false':'true'));			
		}
			//55984 autoApplyWeight
	<cfif appSettings.getAutoWeightDistributorsProgramRevision() EQ 0 AND IsFreightProgram EQ 0>
			var r = confirm("Do you want to apply auto weights for <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> ?");
			if (r == true) {
				assignAverageWeight();
			} 	
	<cfelse>
		assignAverageWeight();		
	</cfif>				
	}

	function resetAverageWeight()
	{
		var FINALITEMLIST = document.MyForm.FinalItemList.value;

		var checkedDistExceptions = [];
		
		/* If distributor "Exclude" checkbox exists */
		if($("#excludeDistributorList").length){	
			$('.check_Exception:checked').each(function(i){
				checkedDistExceptions[i] += $(this).val();
			});
		}

		var Arr = FINALITEMLIST.split(",");
		var Arr1 = checkedDistExceptions;
		/* Weight is not applied for "distributor exceptions" and so we need to remove the count of those exceptions. */
		var ArrLen = Arr.length - Arr1.length;
		
		/* Dev Note(67146) - Using the "JSdecimalFloor" function here. If the weight for a distributor is above .1250, then JS would assign
		".13" as weight. This would create issues because the last distributor(when there are hundreds of distributors) might get a negative weight.
		The solution is to always use floor and so in this case we would use ".12" and not ".13". In fact, when a distributor gets deleted, the last
		distributor gets the balance weight, after all but one of the distributors have been assigned weight. Using ".12" in the example mentioned,
		the balance weight should never be negative.
		*/
		var avgVal = formatToDecimalPlaces(JSdecimalFloor(100/ArrLen,2), 2);

        document.all.DivAverageWeight.innerText = avgVal;
	}
</SCRIPT>

<cfif FORM.FinalItemList neq "">
<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	<cfoutput><LEGEND STYLE="font: bold 14px sans-serif; color: Red;">currently selected #application.returned_customer_setting.distributor_label_plural#</LEGEND></cfoutput>
	<BR>

<!--- ngt --->
<cfset request.custom_rfp_process = appSettings.get_Setting('Custom_RFP_Process',0)>

<TABLE CLASS="Maintable" WIDTH="800" CELLPADDING="3" CELLSPACING="0" BORDER="0">
	<!--- TABLE HEADERS --->

	<TR ID="header" BGCOLOR="#ffce84">
		<cfoutput>
		<TD ID="header" WIDTH="2%" VALIGN="middle">
		<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Distributors_Removed eq 2)>
		<!---<img bDelete="true" sMessage="delete all #application.returned_customer_setting.distributor_label_plural# in this page" src="/images/scissor.gif" title="delete all #application.returned_customer_setting.distributor_label_plural# in this page" border="0" onClick="deleteAll('check_Each')" style="cursor: pointer;">--->
		<img bDelete="true" sMessage="delete all #application.returned_customer_setting.distributor_label_plural# in this page" src="/images/scissor.gif" title="delete all #application.returned_customer_setting.distributor_label_plural# in this page" border="0" onClick="deleteAll()" style="cursor: pointer;">
		<cfelse>
		&nbsp;
		</cfif>
		</TD>
		<TD align="left" ID="header" WIDTH="20%"><B>#application.returned_customer_setting.distributor_label_singular# Name / #application.returned_customer_setting.shard_ship_to_label#</B></TD>
		<TD ID="header" WIDTH="20%"><B>Address</B></TD>
		<cfif ShowBrokerInResult>
		<TD ID="header" WIDTH="20%"><B>#application.returned_customer_setting.broker_label_singular#</B></TD>
		</cfif>
		<cfif IsFreightProgram eq 1 and request.custom_rfp_process EQ 0 >
		<TD ID="header" WIDTH="15%"><B>Warehouse</B></TD>
		</cfif>
	<!--- 	AND GetSettings.Discount_Formula_Pricing EQ 1 --->
		<cfif request.custom_rfp_process EQ 1 AND GetSettings.RFP_Process EQ 1>
			<TD ID="header" WIDTH="15%"><B>Default Facility</B></TD>
		</cfif>
		<TD ID="header" WIDTH="1%">&nbsp;</TD>
		<TD ID="header" WIDTH="15%"><B>Weight</B></TD>
		<cfif groupExists>
		<!--- If distributor group exists on the program., show the "Exclude" column.
		Note: The users need the "exclude" feature for the following reason -
		- User adds a group, but wants to exclude one or more distributors from that group. 
		So as an example, the user will take the below steps -
		1) User adds SYSCO as a distributor group and the then also adds SYSCO Atlanta as an individual distributor.
		The user uses the "Exclude" checkbox to exclude this distributor from the group. This record will not be in the
		contract_distributors table, but will be in the "Contract_Distributors_Exceptions" table.
		--->
		<TD ID="header" WIDTH="5%"><B>Exclude</B></TD>
		</cfif>
		<cfif	request.custom_rfp_process EQ 1 AND GetSettings.RFP_Process EQ 1	>
			<TD ID="header" WIDTH="5%"><B>REDI</B></TD>	
		</cfif>
		</cfoutput>
	</TR>
	<CFOUTPUT>
	<CFLOOP QUERY="GetDistInfo">
	<cfif GetDistInfo.recordcount eq 1>
		<cfset Default_Program_Weight = 100>
	</cfif>
		<CFSET FieldNameRe = replace(GetDistInfo.BSA_Foodservice_Customers_ID,"-","_","ALL")>
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top" ID="TR_#FieldNameRe#">
			<TD STYLE="cursor: pointer;" VALIGN="middle">
			<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Distributors_Removed eq 2)>
			<img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" title="delete this <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>" border="0" onClick="deleteThisDistributor('#FieldNameRe#', '#GetDistInfo.BSA_Foodservice_Customers_ID#')" style="cursor: pointer;">
			<cfelse>
			&nbsp;
			</cfif>
			</TD>
			<TD onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#GetDistInfo.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" NOWRAP>
				#GetDistInfo.Name#<BR>
				<cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>
					#GetDistInfo.Shr_Ship_To#
				<Cfelse>
					#GetDistInfo.Ship_To#
				</cfif>
				&nbsp;</TD>
			<TD onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#GetDistInfo.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;">#GetDistInfo.Address_1#<BR>#GetDistInfo.City#,#GetDistInfo.State# #GetDistInfo.ZipCode#&nbsp;#GetDistInfo.Country_Code#</TD>
			<cfif ShowBrokerInResult>
			<TD onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#GetDistInfo.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" >#GetDistInfo.Broker_Name#&nbsp;</TD>
			</cfif>
			<!--- If its a freight program and if there are no customer groups, then show the warehouse details --->
			<cfif IsFreightProgram eq 1 OR (	request.custom_rfp_process EQ 1 AND GetSettings.RFP_Process EQ 1	)>
			<TD ID="Warehouse_id_#FieldNameRe#" valign="top">
			<span id="Warehouse_details_#FieldNameRe#">    <cfif request.custom_rfp_process EQ 1 >(#GetDistInfo.Warehouse_Code#) </cfif>#GetDistInfo.Warehouse_Name#&nbsp;&nbsp;
			<span <cfif GetDistInfo.Overridden_Warehouse_Master_ID eq 1>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>>*</span>
			<br />#GetDistInfo.Warehouse_Address_1#<cfif GetDistInfo.Warehouse_Address_2 neq ""><br />#GetDistInfo.Warehouse_Address_2#</cfif>
			<br />#GetDistInfo.Warehouse_City#,#GetDistInfo.Warehouse_State#&nbsp;#GetDistInfo.Warehouse_Zip#
			</span>&nbsp;&nbsp;
			
			<!--- <cfif request.custom_rfp_process EQ 0> --->
				<span style="font-weight:bold;color:red;font-size:11px;"> [ </span>
				<a href="##" id="EditWarehouse_#FieldNameRe#" style="font-weight:bold;font-size:11px;" OnClick="OpenWarehousePage_#FieldNameRe#();return false;" style="font-weight:bold;">edit</a>
				<span style="font-weight:bold;color:red;font-size:11px;"> ] </span>
			<!--- </cfif> --->

			<!--- I created this function so that when a warehouse is changed on the popup page (warehouse selection), then
				  this function can do the job of changing the warehouse, for the onclick event --->
			<script language="javascript">
			function OpenWarehousePage_#FieldNameRe#()
			{
				NewWindow('select_warehouse.cfm?BSA_Foodservice_Customers_ID=#FieldNameRe#&WareHouse_Master_ID='+document.all.SelectedWarehouse_#FieldNameRe#.value+'&Default_Warehouse='+document.all.DefaultWarehouse_#FieldNameRe#.value,'warehousewindow', 800, 600, 'yes', 'yes', true);return false;
			}
			</script>
			<input type="hidden" name="SelectedWarehouse_#FieldNameRe#" value="#WareHouse_Master_ID#" ID="SelectedWarehouse_#FieldNameRe#">
			</TD>
			</cfif>
			<td><span ID="Er_weightCol"></span>&nbsp;</td>
			<td NOWRAP><span ID="weightCol"><input class="w_perc" NAME="Weight_DID_#FieldNameRe#" <cfif GetDistInfo.recordcount eq 1> VALUE="#trim(Default_Program_Weight)#"<cfelse>VALUE="#trim(Program_Weight)#"</cfif> TYPE="text" SIZE="2" MAXLENGTH="5" ONKEYUP="clenseText(this, '0123456789.'); limitXdecimalplaces(2, this)" <cfif GetDistInfo.Exclude_Distributor eq 1>disabled</cfif>></span>%</td>
			<!--- <TD><span ID="chkBoxCol"><input TYPE="Checkbox" checked NAME="check_Each" class="check_Each"></span></TD>--->
			<cfif groupExists><TD><cfif GetDistInfo.shr_ship_to neq 'GROUP'><span ID="chkBoxDist"><input TYPE="Checkbox" NAME="excludeDistributor" value="#FieldNameRe#" OnClick="enableDisableWeight()" class="check_Exception" <cfif GetDistInfo.Exclude_Distributor eq 1>checked</cfif>></span>
			<!--- "excludeDistributorList" is the hidden variable which will be passed to the database for inserting/deleting "distributor exceptions". --->
			<input type="hidden" name="excludeDistributorList" id="excludeDistributorList" value="#form.excludeDistributor#">
			<cfelse>N/A</cfif></TD></cfif>
			<cfif	request.custom_rfp_process EQ 1 AND GetSettings.RFP_Process EQ 1	>
				<td>#GetDistInfo.redi#</td>	
			</cfif>
		</TR>
		<!--- If no customer groups - ngt --->
		<cfif IsFreightProgram eq 1 or request.custom_rfp_process>
		<input type="hidden" name="DefaultWarehouse_#FieldNameRe#" value="#GetDistInfo.Default_WareHouse_Master_ID#">
		</cfif>
		<cfparam name="Distributor_Group_Level_ID" default="0" />
		<cfparam name="form.editcurrentweight" default="" />
		<cfparam name="form.finishedselectingitems" default="" />
	</CFLOOP>
	</CFOUTPUT>

</TABLE>
</FIELDSET>

<br/>

<cfset DistGroupColumnWidth = "170">
<cfset DistColumnWidth = "135">
<cfset SaveColumnWidth = "50">

<cfset tblWidth = DistGroupColumnWidth + DistColumnWidth>

<cfif showDistributorGroupLink eq 0>
	<cfset tblWidth = tblWidth - DistGroupColumnWidth>
<cfelseif showDistributorLink eq 0>
	<cfset tblWidth = tblWidth - DistColumnWidth>
</cfif>

<cfif FORM.FinalItemList neq "">
	<cfset tblWidth = tblWidth + SaveColumnWidth>
</cfif>

<cfoutput>
<table style="width:#tblWidth#px" border="0">
	<TR>
		<cfif FORM.FinalItemList neq "">
		<TD style="width:#SaveColumnWidth#px" class="save_table_2">
			<CF_button
				button_name		=	"save"
				button_caption	=	"save"
				button_action	=	"submitForm();"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>
		</cfif>
		<cfif showDistributorGroupLink eq 1>
		<TD style="width:#DistGroupColumnWidth#px">
				<cfset text = 'select '& #LCase(application.returned_customer_setting.distributor_label_singular)#&' groups'>				
				<a href="##" <cfif addDistributorAllowed eq 1>onclick="submitSelectedEntries(1);return false;"</cfif> <cfif addDistributorAllowed eq 0>disabled</cfif>>
					#application.util.string.actionLinkFormat(text)#
				</a>
		</TD>
		</cfif>
		<cfif showDistributorLink eq 1>
		<TD style="width:#DistColumnWidth#px">
				<cfset text = 'select '& #LCase(application.returned_customer_setting.distributor_label_plural)#>
				<a href="##" <cfif addDistributorAllowed eq 1>onclick="submitSelectedEntries(0);return false;"</cfif> <cfif addDistributorAllowed eq 0>disabled</cfif>>
					#application.util.string.actionLinkFormat(text)#
				</a>
		</TD>
		</cfif>
	</TR>
</table>
</cfoutput>
</CFIF>

	<cf_MessageWindow>
    <cf_include files="/Script/javascript/format_functions.js">
	<script>
		function assignGlobalWeight(whereFrom){
			// 31310 - replaced weight percentage handling with jQuery
			let $w_perc;
			let $Last_perc;
			let checked_count = 0;
			// process all tr rows in Maintable table - ngt
			$('table.Maintable tbody tr').each(function() {
                $w_perc = $(this).find('.w_perc');

                /* "Weight" textbox is disabled, when there are "distibutor exceptions". */
                if ( !$($w_perc).hasClass("disabled") ) {
                    // percentage input element exists update it with new value
                    if ($w_perc.length) {
                        $Last_perc = $w_perc;
                        checked_count++;     // keep track on number of checked boxes
                        $w_perc.val( document.all.globalPercentage.value )
                                .trigger('onkeyup')
                                ;
                    }
                }
            });
            
			// if there is more than 1 checked box and check for adjustment parameter is enabled
			if (checked_count > 1 && whereFrom == 1) {
				var all_percentages = checked_count * parseFloat(document.all.globalPercentage.value);
				// if total of all percentages does not equal to 100 adjust the last percentage
				if ( all_percentages !== 100 ) {
					// total up all percentages except the last one
					var all_except_last = (checked_count - 1) * parseFloat(document.all.globalPercentage.value);
					all_except_last = formatToDecimalPlaces(100 - all_except_last, 2);

					// update last percentage
					$Last_perc.val( all_except_last ).trigger('onkeyup');
				}
			}
		}  // end of assignGlobalWeight()

		if ( document.getElementById("weightCol") ) {
			averageWeight = <cfoutput>#AverageWeight#</cfoutput>;
		}
		else{
			averageWeight = 100;
		}

		function assignAverageWeight(){
			averageWeight = formatToDecimalPlaces(parseFloat(document.all.DivAverageWeight.innerText),2);
			document.all.globalPercentage.value = averageWeight;
			callfireEvent(document,document.all.globalPercentage,'keyup');
			
			/* true or false based on browser - IE 10 and above or IE 9 and below. 
			'1' as an argument below means "true". */
			/*document.all.allbox.checked = checkOrUncheckBeforeFireEvent(1);
			callfireEvent(document,document.all.allbox,'Click');
			*/

			assignGlobalWeight(1);
		}

		function verifySummationAsWhole(){
			var bErr;
			totalSum=0;
			if(document.all.weightCol)
			{
				if(document.all.weightCol.length != null){
					for(var x=0; x<document.all.weightCol.length; x++){

						weightBox = getFirstChild(document.all.weightCol[x]);
						/*if(weightBox.value.length > 0){
							totalSum = totalSum + parseFloat(weightBox.value);
                        }*/
                        if ($(weightBox).hasClass("disabled")) {
                        }
						else if(isFloat(weightBox.value,true) && weightBox.value != 0){
						/* "Weight" textbox is disabled, when there are "distibutor exceptions". */
							if(weightBox.disabled == false){
								totalSum = totalSum + parseFloat(weightBox.value);
							}
							clearQueue(document.all.Er_weightCol[x]);
						}
						else
						{	/* "Weight" textbox is disabled, when there are "distibutor exceptions". */
							if(weightBox.disabled == false){
								bErr = true;
								queueMessage("Invalid Weight", document.all.Er_weightCol[x]);
							}
						}
					}
				}
				else {
					weightBox = getFirstChild(document.all.weightCol);
					/*if(weightBox.value.length > 0){
						totalSum = totalSum + parseFloat(weightBox.value);
					}*/
					if(isFloat(weightBox.value,true) && weightBox.value != 0){
						totalSum = totalSum + parseFloat(weightBox.value);
						clearQueue(document.all.Er_weightCol);
					}
					else
					{
						bErr = true;
						queueMessage("Invalid Weight", document.all.Er_weightCol);
					}
				}
			}
			else
			{
				totalSum = 100;
			}

			totalSum = (totalSum * 100);
			totalSum = Math.round(totalSum)
			totalSum = (totalSum / 100);

			if(bErr)
			{
				showMessageWindow();
				return "false";
			}
			else if(totalSum == 100){
				return "true";
			}
			else{
				tempData = (parseFloat(100) - totalSum);
				tempData = (tempData * 100);
				tempData = Math.round(tempData)
				tempData = (tempData / 100);
				return tempData;
			}
		}

		function isFloat(sVal,noMinus)
		{
			var sValTemp = parseFloat(sVal);

			if(!isNaN(sValTemp) && (/^[+-]?\d*(\.(\d)+)?$/.test(sVal)))
			{
				if(noMinus) return /^\d*(\.(\d)+)?$/.test(sVal);
				return true;
			}
			else
			{
				return false;
			}

		}

		function submitForm(){
			tempHolder = verifySummationAsWhole();

			if(tempHolder == "true") {
				document.all.MyForm.WeightAssignmentCompleted.value = 1;
				document.all.MyForm.LoadSavedDistributors.value = 0;
				document.all.finishedselectingitems.value = 1;

				//$(".save_table").attr('disabled','true');
				disableButton("save_table", true, false);
				disableButton("save_table_2", true, false);
				document.all.MyForm.submit();
			}
			else if(tempHolder == "false")
			{

			}
			else
			{
				if(tempHolder > 0) tempHolder = "+ "+tempHolder;
				else {
					tempHolder = tempHolder * -1
					tempHolder = "- " + tempHolder
				}
				alert("The sum of the supplied weights does not equal 100%. Please adjust the weight by: " + tempHolder + "%")
			}
			<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1>
				alert("Please note that you may have to update applicable freight rates for any customers you may have added to this program.");
			</cfif>
		}

		function enableDisableWeight(){
			var $w_perc;
			$("input[name='excludeDistributor']").each(function(){
				var tr = $(this).closest("tr");
				$w_perc = tr.find('.w_perc');

				/* When "distibutor exceptions" exist, i.e. when the "Exclude" checkbox is checked for the distributor, remove the weight from the
				weight textbox and also disable the weight textbox.
				*/
				if(tr.find("input[name=excludeDistributor]").is(":checked")) {
					$($w_perc).val("");
					$($w_perc).attr("disabled", "disabled");
				}
				else{
					$($w_perc).attr("disabled", false);
				}
			});

			<cfif appSettings.getAutoWeightDistributorsProgramRevision() EQ 0 AND IsFreightProgram EQ 0>
				var r = confirm("Do you want to apply auto weights for <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> ?");

				if (r == true) {
					resetAverageWeight();
					assignAverageWeight();
				} 	
			<cfelse>
				resetAverageWeight();
				assignAverageWeight();
			</cfif>	

			addRemoveCustomers();
		}

		function addRemoveCustomers(){
			 /* all checked rows are saved in a hidden input with a name of 'excludeDistributorList' */
			var hiddenCBoxes = $('input[name=excludeDistributorList]').val();

			/* convert the list into an array for easy manipulation */
			if (hiddenCBoxes.length == 0)
				var aDistributorList = [];
			else
				var aDistributorList = hiddenCBoxes.split(",");

			/* scan thru all checkboxes on the page */
			$('input.check_Exception').each( function() {
			/* Kept it lowercase for being used in case-insensitive search using "$.inArray" */
			var distributorID = $(this).val().toLowerCase();

				if ( $(this).prop('checked') ) {
					/* checked box is not in the array, add it */

					if($.inArray(distributorID, aDistributorList) == -1){
						aDistributorList.push( distributorID );
					}
				}
				else {
					/* box is not checked so we need to remove it */
					while($.inArray(distributorID, aDistributorList) != -1) {
						aDistributorList.splice($.inArray(distributorID , aDistributorList),1);
					}
				}
			});

			/* convert array back to a list for usage in form action */
			hiddenCBoxes = aDistributorList.join(",");

			/* refresh the hidden input with ALL selected rows */
			$('input[name=excludeDistributorList]').val( hiddenCBoxes );
		}

		function showHideWeightSection()
		{
			$("#idWeightSection").toggle();

			if($('#txtLinkShow').is(':visible')){ 
				$("#txtLinkHide").show();
				$("#txtLinkShow").hide();
			}
			else{
				$("#txtLinkHide").hide();
				$("#txtLinkShow").show();
			}
		}

		function submitSelectedEntries(type){
			//popupInCenter('about:blank', "formpopup", 1000, 650);
			window.open('about:blank', 'formpopup', 'toolbars=no,scrollbars=yes,resizable=yes,left=0,top=0,width=1250,height=620');
			DistForm.Is_Group.value = type;
			DistForm.target = 'formpopup';
			DistForm.submit();
		}
	</script>
	<CFOUTPUT>

	<input type="hidden" name="WeightAssignmentCompleted" value="0">
	<input type="hidden" name="FinalItemList" id="FinalItemList" value="#Form.FinalItemList#">
	<input type="hidden" name="updateFinalItemListFrompopup" id="updateFinalItemListFrompopup" value="0">
	<input type="hidden" name="editcurrentweight" id="editcurrentweight" value="0">
	<input type="hidden" name="LoadSavedDistributors" value="1">
	<input type="Hidden" name="Distributor_Level_1" 	value="#Form.Distributor_Level_1#">
	<input type="hidden" name="Line_Of_Business_ID" value="#form.Line_Of_Business_ID#">
	<input type="hidden" name="autoApplyWeight" value="0"><!---D41881 :: Auto adjust of DST Weights --->
	<input type="hidden" name="finishedselectingitems" value="0">
	</CFOUTPUT>
</FORM>

<FORM ACTION="select_distributors_programs_popup.cfm?CID=<cfoutput>#URL.CID#</cfoutput>" METHOD="post" NAME="DistForm" ID="DistForm">
	<CFOUTPUT>
	<input type="hidden" name="FinalItemList" value="#form.FinalItemList#">
	<input type="hidden" name="User_Selection_Group_Or_Dist" value="1">
	<input type="hidden" name="Is_Group">
	<input type="Hidden" name="ExcludeDistributor" value="#request.app_general_functions.listRemoveDupes(form.ExcludeDistributor,',')#">
	</CFOUTPUT>
</FORM>
<cfif application.programLayout EQ 1></div></cfif>

</BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfinclude template="/Common_Files/jQuery.cfm">
<script>
/* Assign the average weight automatically when a user imports distributors from the popup. 
The user does not need to click on a link to assign average weight. Calling it here will make sure that
this code gets called after the page is ready.
Seems like JQuery "$( document ).ready(function()" is not reliable.
*/
<cfif form.updateFinalItemListFrompopup eq 1 and request.custom_rfp_process EQ 0>
	assignAverageWeight();
</cfif>
</script>
</BODY>
</HTML>
<CFABORT>