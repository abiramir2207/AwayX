<!DOCTYPE HTML>
<HTML>
<!--- <cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() /> --->
  <cfset ProdGroupDataManager = CreateObject("component", "components.products.Group.DataManager").init() />

<cfoutput>

<cfset temp = structAppend(FORM, URL) />

<CFSET thisPage = CGI.SCRIPT_NAME>
<CFPARAM NAME="FORM.AlreadySelectedItems" 	DEFAULT="">
<CFPARAM NAME="FORM.Group_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" 	DEFAULT="">
<CFPARAM NAME="FORM.FinisedSearching" 	DEFAULT="0">
<CFPARAM name="FORM.bSubmit" default="0" />
<CFPARAM NAME="FORM.ExcludeItemID" Default="0">
<CFPARAM NAME="FORM.IncludeIOPGFlag" DEFAULT="0">
<CFPARAM NAME="FORM.Business_Segment_Id" DEFAULT="0">
<CFPARAM NAME="URL.ExcludeListFieldname" 	DEFAULT="">
<CFPARAM NAME="URL.groupLevelId" 	DEFAULT="0">
<CFPARAM NAME="URL.ExcludeItemID" Default="0">
<CFPARAM NAME="URL.pageSource" DEFAULT="">
<CFPARAM NAME="URL.TemplateID" DEFAULT="">
<CFPARAM NAME="URL.TemplateFiltersID" DEFAULT="">
<CFPARAM NAME="URL.prodRefresh" DEFAULT="0">
<CFPARAM NAME="URL.IncludeIOPGFlag" DEFAULT="0">
<CFPARAM NAME="URL.Business_Segment_Id" DEFAULT="0">
<CFPARAM NAME="URL.CurrentTemplateID" DEFAULT="#URL.TemplateID#">
<cfparam name="FORM.passed_form" default="">
<cfparam name="FORM.itemList" default="">

<CF_Popup_Search
			FirstFormNameVariable="URL.FormName"
			FirstFieldNameVariable="URL.FieldName"
			ActionPage="#thisPage#"
			AlreadySelectedItems="#FORM.AlreadySelectedItems#"
			id="#FORM.Group_ID#"
			FinalItemList="#FORM.FinalItemList#"
			ReturnFinalItemListVariable="FORM.FinalItemList"
			FinisedSearching="#FORM.FinisedSearching#"
			LastFormNameVariable="FORM.Formname"
			LastFieldNameVariable="FORM.FieldName"
			ExcludeListFieldname="#URL.ExcludeListFieldname#"
			groupLevelId="#URL.groupLevelId#"
			pageSource="#URL.pageSource#"
			TemplateID="#URL.TemplateID#"
			TemplateFiltersID = "#URL.TemplateFiltersID#"
			CurrentTemplateID = "#URL.CurrentTemplateID#"
			prodRefresh = "#URL.prodRefresh#"
			ExcludeItemID = "#URL.ExcludeItemID#"
			IncludeIOPGFlag = "#URL.IncludeIOPGFlag#"
		    BusinessSegmentId = "#URL.Business_Segment_Id#"
			>

<cfif isDefined("FORM.prodRefresh") AND FORM.prodRefresh EQ 1>
	<cfset FORM.FinalItemList = "" />
</cfif>

<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo(form.groupLevelId) />
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<HEAD>
	<TITLE>Search - #approvalGroupType.label#</TITLE>
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
  <style>
    ##actions {
  	}
		##actions a {
  		margin-right: 25px;
  	}
  </style>
</HEAD>

<BODY>
<SCRIPT LANGUAGE="JavaScript" SRC="/settings/Planning_groups/_planning_groups.js"></SCRIPT>
<cfparam name="FORM.ExcludeList" 	DEFAULT="">
<cfparam name="FORM.state" 	default="1">
<cfset formName = "frmApprovalGroups">
<!--- Changed for the Planning Groups - Anand Rao/09-Dec-2010 --->
<cfif isDefined("FORM.pageSource") AND FORM.pageSource EQ "PGFilters">
   <cfset qGetExistingData = ProdGroupDataManager.fnQryExistingProductData(
                                TemplateID = FORM.TemplateID,
                                TemplateFiltersID = FORM.TemplateFiltersID,
                                ProductGroupLevelID = FORM.groupLevelId,
                                bActive = 1
                                ) />
   <cfif ((FORM.FinalItemList EQ "" OR FORM.FinalItemList EQ "undefined") AND qGetExistingData.RecordCount GTE 1)>
   <cfset FORM.FinalItemList = ValueList(qGetExistingData.Product_Group_ID) />
   </cfif>

	<!--- Get list of business segment id from template --->
	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
	<cfif appSettings.getFilterBusinessSegments() AND businessSegManager.isEnabledForProduct() AND isDefined("FORM.CurrentTemplateID") AND FORM.CurrentTemplateID NEQ "">
		<cfset qTemplateSegments = businessSegManager.getBusinessSegmentTemplateSettings(FORM.CurrentTemplateID) />
		<cfset FORM.businessSegmentId = valueList(qTemplateSegments.Business_Segment_ID) />
		<cfif FORM.businessSegmentId eq "">
			<cfset FORM.businessSegmentId = "0" />
		</cfif>
	</cfif>

  <FORM ACTION="ApprovalGroup_Search.cfm" METHOD="post" name="frmApprovalGroups">
    <input type="hidden" name="bSubmit" id="bSubmit" value="0" />
	<input type="hidden" name="CurrentTemplateID" <cfif isDefined("FORM.CurrentTemplateID") AND FORM.CurrentTemplateID NEQ "">Value="#FORM.CurrentTemplateID#"<cfelse>value=""</cfif> />
    <input type="hidden" name="TemplateID" <cfif isDefined("FORM.TemplateID") AND FORM.TemplateID NEQ "">Value="#FORM.TemplateID#"<cfelse>value=""</cfif> />
    <input type="hidden" name="TemplateFiltersID" <cfif isDefined("FORM.TemplateFiltersID") AND FORM.TemplateFiltersID NEQ "">Value="#FORM.TemplateFiltersID#"<cfelse>value=""</cfif> />
<cfelse>
  <FORM ACTION="#thisPage#" METHOD="post" name="#formName#"><!--- REM: in 2 --->
</cfif>

<CFSCRIPT>
	Border="Yes";
	BorderSize=1;
	BorderColor="Blue";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy";
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="Yes";
	WIDTH="500px";
</CFSCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>

<CFPARAM NAME="FORM.startrow" DEFAULT="1">
<CFPARAM NAME="FORM.frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=200>
<CFIF FORM.state EQ 1>

	<STYLE TYPE="text/css">
			body,td
				{
					font: 11px Arial;
				}
			A
				{
					color: blue;
					text-decoration: none;
				}
			A:HOVER
				{
					color: red;
					text-decoration: underline;
				}
		</STYLE>

		<!--- Use the segment based on the setting for product attributes --->
		<cfif FORM.businessSegmentId NEQ "" AND FORM.businessSegmentId NEQ "0">
			<cfset ProductBSFilter = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").get(FORM.businessSegmentId) />
			<cfif ProductBSFilter.RecordCount>
				<cfset FORM.businessSegmentId = ValueList(ProductBSFilter.Product_Group_BS_Filter) />
			</cfif>
		</cfif>

		<!--- Get the records that match the selected criterria --->
		<cfset qGetApprovalGroups = approvalGroupManager.getApprovalGroups(
		                            ExcludeItemID=FORM.ExcludeItemID,
                                    IncludeIOPGFlag=FORM.IncludeIOPGFlag,
                                    businessSegmentId= FORM.businessSegmentId)>

		<cfif FORM.Passed_Form EQ "comCreateListForm" AND FORM.ItemList NEQ "">
			<cfset InputList = ListToArray(FORM.ItemList, ",")/>
			<cfquery name="qGetApprovalGroups" dbtype="query">
					SELECT	*
					FROM	qGetApprovalGroups
					WHERE	Group_Number
					<cfloop index="i" from="1" to="#ArrayLen(InputList)#" step="1">
						<cfset this.DataToBeValidated = #Replace(InputList[i],"'","")# />
						like (
					 		'%#this.DataToBeValidated#%'
							)
						<cfif i LT ArrayLen(InputList)>
							OR Group_Number
						</cfif>
					</cfloop>
				</cfquery>
		</cfif>
 		<FIELDSET STYLE="padding:8px; margin-top:-10px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;padding:5px;">
			 #qGetApprovalGroups.recordcount# #lcase(approvalGroupType.label)# matched the above criteria
 			<CF_SmallHelp
				width="300"
				displayShifyX = "0"
				displayShifyY = "0"
				imgPath="/Images/i.gif"
				imgWidth="12"
				imgHeight="11"
				dropdownCheck="0"
				>
				<font color="black">Placing a check mark indicates that only those products will display in the program search tool.</font>
			</CF_SmallHelp>
		</LEGEND>
		<cfset programID = '' />
		<b>
		<font color="Red">[</font>
		<font color="Blue"><A HREF="javascript:void(0)"  onclick="window.showModalDialog('createList.cfm?passObj=ProductGroup&passForm=frmApprovalGroups&GroupLevelID=#FORM.groupLevelId#&programID=#programId#',window,'dialogHeight:375px;dialogWidth:350px;center:yes;edge:raised;yield:1'); return false;" >create list</A></font> <!--- showModalDialog --->
		<font color="Red">]</font>
		</b>
<!--- Start: Display all the currently checked Items --->
			<cfif isDefined("FORM.pageSource") AND FORM.pageSource EQ "PGFilters">
				<br>
			    <fieldset id="border_1" style="border-width:0; border-color:; border-style:solid; width:650">
			    	<legend>
			      		<span>
			        	<img id="image_1" src="/images/plus2.gif" onclick="switchlayer(1,'Hide Existing Selection','Show Existing Selection',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" border="0" title="" style="cursor:pointer">
			       		<font face="Arial">
			        		<b style="font-size:9pt">
			         			<span id="title_1" onclick="switchlayer(1,'Hide Existing Selection','Show Existing Selection',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy')" style="cursor:pointer;color:00773c;">
				          			<span  title="Click here to toggle the view">
							     		Current Selection
				          			</span>
			         			</span>
			        		</b>
			       		</font>
	     			</legend>
				    <div id="lyrgroup_1" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;">
						<div id="masterContainer">
				      		<table cellpadding="1" cellspacing="0" border="1" bordercolor="979797"  width="70%">
								<tr>
									<td width="40%" align="center"><B>#approvalGroupType.label# ID</B></td>
									<td width="60%" align="center"><B>#approvalGroupType.label#</B></td>
								</tr>
						    	<cfloop query="qGetApprovalGroups">
									<cfloop query="qGetExistingData">
										<cfif (qGetApprovalGroups.Group_ID EQ qGetExistingData.Product_Group_ID)>
											<tr>
												<td align="left" width="100px" nowrap valign="top">&nbsp;
											 		<cfif (Len(qGetApprovalGroups.Group_ID) NEQ 36)>#qGetApprovalGroups.Group_ID#<cfelse>#qGetApprovalGroups.Group_Number#</cfif>
												</td>
												<td>
													&nbsp;#qGetApprovalGroups.Group_Name#
												</td>
											</tr>
										</cfif>
									</cfloop>
								</cfloop>
							</table>
						</div>
				    </div>
				</fieldset>
				<br>
 			</cfif>

<!--- Start: Display all the currently checked Items --->
		<TABLE CELLPADDING="2" CELLSPACING="0" WIDTH="100%" CLASS="MainTable datagrid" id="datagrid"  style='table-layout:fixed;display:none;'>
		  	<col width="5%">
		  	<col width="30%">
		  	<col width="65%">
			<thead>
		    	<tr BGCOLOR="##ffce84">
		      		<th>
		      			<INPUT TYPE="checkbox" NAME="AllItems" VALUE="" onClick="javaScript: CHSelectAll('Group_ID', this.checked);">
		      		</th>
		      		<th ID="Header"><B>#approvalGroupType.label# ID</B></th>
		      		<th ID="Header"><B>#approvalGroupType.label#</B></th>
		    	</tr>
			</thead>
	    	<tfoot>
        		<tr>
        			<th colspan="3">
						<div id="actions">
						<cfif isDefined("FORM.pageSource") AND FORM.pageSource EQ "PGFilters">
						  <a HREF="##" onClick="javascript: return fnPGFiltersSave(document.#formName#)">#application.util.string.actionLinkFormat("import selected record(s)")#</a>
						  <a HREF="##" onClick="javascript: return fnPGFiltersImportAll(document.#formName#)">#application.util.string.actionLinkFormat("import all record(s)")#</a>
						  <a HREF="##" onClick="javascript: return fnPGFiltersRemoveAll(document.#formName#)">#application.util.string.actionLinkFormat("removed selected record(s)")#</a>
						<cfelseif isDefined("FORM.FORMNAME") AND FORM.FORMNAME EQ "PriceProtection">
						  <a HREF="##" onClick="javascript: return importPriceProtectionG(document.#formName#)">#application.util.string.actionLinkFormat("import selected record(s)")#</a>
						  <a HREF="##" onClick="javascript: return importAllPriceProtectionG(document.#formName#)">#application.util.string.actionLinkFormat("import all record(s)")#</a>
						  <a HREF="##" onClick="javascript: return removeAll(document.#formName#)">#application.util.string.actionLinkFormat("removed selected record(s)")#</a>
						<cfelse>
						  <a HREF="##" onClick="javascript: return finishedSearching(document.#formName#)">#application.util.string.actionLinkFormat("import selected record(s)")#</a>
						  <a HREF="##" onClick="javascript: return importAll(document.#formName#)">#application.util.string.actionLinkFormat("import all record(s)")#</a>
					    <a HREF="##" onClick="javascript: return removeAll(document.#formName#)">#application.util.string.actionLinkFormat("removed selected record(s)")#</a>
						</cfif>
						</div>
					</th>
        		</tr>
	    	</tfoot>

		<CFSET AllList = ValueList(qGetApprovalGroups.Group_ID)>
		<CFSET AlreadySelectedItems = "">
    	<tbody>
		    <cfloop query="qGetApprovalGroups">
			    <tr>
                    <!--- ngt --->
			    	<td><INPUT TYPE="checkbox" NAME="Group_ID" VALUE="#Group_ID#" ID2="Group_ID" <CFIF ListFindNoCase(FORM.FinalItemList, Group_ID) NEQ 0 AND ((isDefined("FORM.prodRefresh") AND FORM.prodRefresh EQ 0) OR NOT isDefined("FORM.prodRefresh")) >CHECKED
			        <CFSET AlreadySelectedItems = listappend(AlreadySelectedItems, Group_ID, ",")>
			      </CFIF>></td>
			      	<td><cfif (Len(Group_ID) NEQ 36)>#Group_ID#<cfelse>#Group_Number#</cfif></td>
			      <td>
					  <cfif (URL.groupLevelId GTE 2000 OR FORM.groupLevelId GTE 2000)>
						<a href = "##"
						 onclick = "javascript:fnViewMicroMembers('1','#Group_ID#','');return false;">
							#Group_Name#
						</a>
					<cfelse>
				  		#Group_Name#
					</cfif></td>
			    </tr>
		    </cfloop>
   	 	</tbody>
	</table>
</FIELDSET>

<script language="JavaScript">
	function fnPGFiltersImportAll()
	{
		var AllList = "#AllList#";
      document.frmApprovalGroups.bSubmit.value = "1";
		if(window.confirm("Do you want to import all the records from the search result?"))
		{
			document.frmApprovalGroups.AlreadySelectedItems.value = "";
			document.frmApprovalGroups.FinalItemList.value = AllList;
  			document.frmApprovalGroups.submit();
		}
    	return false;
    }

	function fnPGFiltersRemoveAll(searchForm)
	{
		document.frmApprovalGroups.AlreadySelectedItems.value = "";
		document.frmApprovalGroups.FinalItemList.value = "";
		document.frmApprovalGroups.AllItems.checked = true;
		document.frmApprovalGroups.AllItems.click();
		return false;
	}

	function finishedSearching(searchForm)
	{
		searchForm.FinisedSearching.value = 1;
		searchForm.submit();
		return false;
	}
	function importAll(searchForm)
	{
		var AllList = "#AllList#";
		if(window.confirm("Do you want to import all the records from the search result?"))
		{
			searchForm.AlreadySelectedItems.value = "";
			searchForm.FinalItemList.value = AllList;
			finishedSearching(searchForm);
		}
		return false;
	}
	function removeAll(searchForm)
	{
		searchForm.AlreadySelectedItems.value = "";
		searchForm.FinalItemList.value = "";
		searchForm.AllItems.checked = true;
		searchForm.AllItems.click();
		return false;
	}

	function importPriceProtectionG(searchForm)
	{
		var checkBoxArr = getSelectedCheckboxValue(searchForm.Group_ID);
		var sGroupIDsChecked = checkBoxArr.join(",");
		opener.document.all.<cfoutput>#Form.Formname#</cfoutput>.GroupID.value = sGroupIDsChecked;
		opener.document.all.<cfoutput>#Form.Formname#</cfoutput>.submit();
		searchForm.FinisedSearching.value = 1;
		searchForm.submit();
		window.close();
	}

	function importAllPriceProtectionG(searchForm)
	{
		var AllList = "#AllList#";
		if(window.confirm("Do you want to import all the records from the search result?"))
		{
			searchForm.AlreadySelectedItems.value = "";
			opener.document.all.<cfoutput>#Form.Formname#</cfoutput>.GroupID.value = AllList;
			opener.document.all.<cfoutput>#Form.Formname#</cfoutput>.submit();
			searchForm.submit();
			window.close();
		}
	}

	function getSelectedCheckbox(buttonGroup)
	{
   		var retArr = new Array();
   		var lastElement = 0;
   		if (buttonGroup[0]) { // if the button group is an array (one check box is not an array)
    		for (var i=0; i<buttonGroup.length; i++) {
         			if (buttonGroup[i].checked) {
            			retArr.length = lastElement;
            			retArr[lastElement] = i;
            			lastElement++;
         			}
      		}
   		} else { // There is only one check box (it's not an array)
      		if (buttonGroup.checked) { // if the one check box is checked
        		retArr.length = lastElement;
        		retArr[lastElement] = 0; // return zero as the only array value
      		}
   		}
   		return retArr;
	} // Ends the "getSelectedCheckbox" function

	function getSelectedCheckboxValue(buttonGroup) {
    	var retArr = new Array(); // set up empty array for the return values
   		var selectedItems = getSelectedCheckbox(buttonGroup);
   		if (selectedItems.length != 0) { // if there was something selected
    		retArr.length = selectedItems.length;
    		for (var i=0; i<selectedItems.length; i++) {
        		if (buttonGroup[selectedItems[i]]) { // Make sure it's an array
          			retArr[i] = buttonGroup[selectedItems[i]].value;
        		} else { // It's not an array (there's just one check box and it's selected)
        		retArr[i] = buttonGroup.value;// return that value
        		}
      		}
   		}
   		return retArr;
	} // Ends the "getSelectedCheckBoxValue" function
	</script>
</CFIF>
	<!------ popup search code ----->
	<INPUT NAME="businessSegmentId" TYPE="Hidden" VALUE="#FORM.businessSegmentId#">
	<INPUT NAME="Formname" TYPE="Hidden" VALUE="#FORM.FormName#">
	<INPUT NAME="FieldName" TYPE="Hidden" VALUE="#FORM.FieldName#">
	<INPUT NAME="FinalItemList"   TYPE="Hidden" VALUE="#FORM.FinalItemList#">
	<INPUT NAME="AlreadySelectedItems" ID="AlreadySelectedItems" TYPE="Hidden" VALUE="#AlreadySelectedItems#">
	<INPUT NAME="FinisedSearching" TYPE="HIDDEN" VALUE="0">
	<INPUT NAME="startrow" TYPE="HIDDEN" VALUE="#FORM.startrow#">
	<INPUT NAME="frompage" TYPE="HIDDEN" VALUE="#FORM.frompage#">
	<INPUT NAME="ExcludeList" TYPE="HIDDEN" VALUE="#FORM.ExcludeList#">
	<INPUT NAME="groupLevelId" TYPE="HIDDEN" VALUE="#FORM.groupLevelId#">
	<INPUT NAME="pageSource" TYPE="HIDDEN" VALUE="#FORM.pageSource#">
	<input NAME="passed_form" TYPE="HIDDEN"  VALUE="#FORM.passed_form#">
	<input NAME="itemList" TYPE="HIDDEN" VALUE="#FORM.itemList#">
</FORM>

<!----------------------------------------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/FixedHeader.min.js"></script>

<script language="javascript">
$(document).ready(function() {
//	$(function() {
	  var mydatagrid = $('##datagrid').dataTable({
	       aaSorting: []
	      ,"aoColumnDefs": [ { "aTargets":[0], "bSortable":false, "bSearchable":false } ]
	      ,"bAutoWidth": false
	      ,"bPaginate": false
	      ,"bSortClasses": false
	      ,"bScrollCollapse": true
		  ,"bFilter": true
	      ,"sDom": 'fti'
	    }).fnSetFilteringDelay();
	 $('##datagrid').show();
	 $('tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
	 new FixedHeader( mydatagrid, { "bottom": true } );
	});

	function fnPGFiltersSave()
    {
		var formName = "frmApprovalGroups";
	 	var dataTableName = $("##datagrid").dataTable();
		dataTableName.fnFilter( '' );
		$('.dataTables_filter input').val('');
		$('##bSubmit').val("1");
		$('form[name=' + formName + ']').submit();
    }
</script>

<cfif isDefined("FORM") AND isDefined("FORM.bSubmit") AND FORM.bSubmit EQ "1">
     <cfset bSuccess = 0 />
    <cfset bSuccess = ProdGroupDataManager.fnSaveFilterDataProduct(
                      UserID = REQUEST.AccessStructure.User_ID,
                      stForm = FORM)   />
     <cfif bSuccess EQ "1">
      <script>
        window.close();
      </script>
    <cfelse>
      <script>
        alert("Error encountered!!");
      </script>
    </cfif>
</cfif>

</body>
</html>
</cfoutput>