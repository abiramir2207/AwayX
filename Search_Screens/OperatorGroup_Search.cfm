
<cfset OprGroupDataManager = CreateObject("component", "components.operator.Group.DataManager").init() />

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<cfset thisPage = CGI.SCRIPT_NAME & "?" & CGI.QUERY_STRING>

<CFPARAM NAME="FORM.AlreadySelectedOprs" 	DEFAULT="">
<CFPARAM NAME="FORM.Group_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.FinalOprList" 	DEFAULT="">
<CFPARAM NAME="FORM.FinisedSearching" 	DEFAULT="0">
<CfPARAM NAME="FORM.TemplateFiltersID" 	DEFAULT="0">
<CfPARAM NAME="FORM.TemplateID" 	DEFAULT="0">
<CFPARAM NAME="FORM.pageSource" default="" />
<CFPARAM NAME="FORM.bSubmit" default="0" />
<CFPARAM NAME="URL.ExcludeListFieldname" 	DEFAULT="">
<CFPARAM NAME="URL.groupLevelId" 	DEFAULT="0">
<CFPARAM NAME="URL.pageSource" DEFAULT="">
<CFPARAM NAME="URL.TemplateID" DEFAULT="">
<CFPARAM NAME="URL.TemplateFiltersID" DEFAULT="">
<CFPARAM NAME="URL.ExcludeOprID" 	DEFAULT="0">
<CFPARAM NAME="URL.IncludeIOPGFlag" DEFAULT="0">

<cfif isDefined("URL.groupLevelId") AND URL.groupLevelId NEQ 0>
  <cfset FORM.groupLevelId = URL.groupLevelId />
</cfif>
<cfif isDefined("URL.TemplateID") AND URL.TemplateID NEQ "">
  <cfset FORM.TemplateID = URL.TemplateID />
</cfif>
<cfif isDefined("URL.TemplateFiltersID") AND URL.TemplateFiltersID NEQ "">
  <cfset FORM.TemplateFiltersID = URL.TemplateFiltersID />
</cfif>
<cfif isDefined("URL.ExcludeOprID") AND URL.ExcludeOprID NEQ "">
  <cfset FORM.ExcludeOprID = URL.ExcludeOprID />
</cfif>
<cfif isDefined("URL.IncludeIOPGFlag") AND URL.IncludeIOPGFlag NEQ "">
  <cfset FORM.IncludeIOPGFlag = URL.IncludeIOPGFlag />
</cfif>
<cfif isDefined("URL.PageSource") AND URL.PageSource NEQ "">
  <cfset FORM.PageSource = URL.PageSource />
</cfif>
<cfif isDefined("URL.FormName") AND URL.FormName NEQ "">
  <cfset FORM.FormName = URL.FormName />
</cfif>
 
<cfparam name="attributes.groupLevelType" 	default="0">
<cfparam name="attributes.businessSegmentId" 	default="0">
<cfparam name="attributes.cachedwithin" 	default="#CreateTimeSpan(0, 0, 0, 0)#">
<CFPARAM NAME="attributes.usepopup" DEFAULT="0">
<CFPARAM NAME="attributes.formname" DEFAULT="DataForm">
<CFPARAM Name="attributes.dropDownName" default="">
 
<CF_Popup_Opr_Search
		FirstFormNameVariable="#URL.FormName#"
		FirstFieldNameVariable="#URL.FieldName#"
		ActionPage="#thisPage#"
		AlreadySelectedOprs="#FORM.AlreadySelectedOprs#"
		id="#FORM.Group_ID#"
		FinalOprList="#FORM.FinalOprList#"
		ReturnFinalOprListVariable="FORM.FinalOprList"
		FinisedSearching="#FORM.FinisedSearching#"
		LastFormNameVariable="FORM.Formname"
		LastFieldNameVariable="FORM.FieldName"
		ExcludeListFieldname="#URL.ExcludeListFieldname#"
		groupLevelId="#URL.groupLevelId#"
		pageSource="#URL.pageSource#"
      	TemplateID="#URL.TemplateID#"
      	TemplateFiltersID = "#URL.TemplateFiltersID#"  
		ExcludeOprID = "#URL.ExcludeOprID#"   
		IncludeIOPGFlag = "#URL.IncludeIOPGFlag#" 
		>   <!--- done --->

<!--- 
  Oprributor_Group_Level Table values:
  Business Segment - 1, Family - 2, Buying Group - 3, Line of Business - 4, Market - 23, Region -	24, Zone - 25
  The below function takes (Active, Include list, exclude List)
  So, we pick only the above values for the dropdown 
---> 
<cfset qGetTopLevelGroups = OprGroupDataManager.getOperatorLevels(1, "#URL.groupLevelId#", "") /> <!--- done --->

<cfif qGetTopLevelGroups.RecordCount EQ 0>
	<cfquery name="qGetTopLevelGroups" datasource="#application.datasource#">
		SELECT OGL.Active, 
          OGL.Operator_Group_Level_ID, 
          OGL.Operator_Group_Level_Type_ID, 
          OGL.Group_Level_Desc, 
          OGL.Search_Sequence_Name, 
          OGL.Operator_Group_Attribute_Master_ID_Field, 
          OGL.Level_ID, 
          OGL.Search_Filter_On,
          OGL.Is_PG 
			FROM	Operator_Group_Level OGL
			WHERE		OGL.Deleted = 0
			AND		OGL.Active = 1
			AND		OGL.Operator_Group_Level_Type_ID IN (#URL.groupLevelId#)
	</cfquery>
</cfif>

<cfset OprGroupManager = CreateObject("component", "components.programs.operators.OperatorManager").init() /> <!--- done --->
<cfset OprGroupDataManager = CreateObject("component", "components.operator.Group.DataManager").init() /> <!--- done --->

<cfset OperatorGroupAttributeManager = CreateObject("component", "components.operator.group.OperatorGroupAttributeManager").init() />
<cfset stGetGroupAttributeInfo = OperatorGroupAttributeManager.getGroupAttributeInfo(groupLevelTypeId = URL.groupLevelId) />
<cfset GetGroupValues = OperatorGroupAttributeManager.getOperatorGroupValues(
							OperatorGroupAttributeInfo 	= stGetGroupAttributeInfo,
							businessSegmentId						= attributes.businessSegmentId,
							cachedwithin								= attributes.cachedwithin,
							ExcludeOprID 								= FORM.ExcludeOprID,
							IncludeIOPGFlag 						= FORM.IncludeIOPGFlag
							) />
<HEAD>
	<TITLE>Search - #qGetTopLevelGroups.Group_Level_Desc#</TITLE>
  	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
 <style>
    ##actions {
  	}
		##actions a {
  		margin-right: 25px;
  	}
  </style>
</HEAD>

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<SCRIPT LANGUAGE="JavaScript" SRC="/settings/Planning_groups/_planning_groups.js"></SCRIPT>
<CFPARAM NAME="FORM.ExcludeList" 	DEFAULT="">
<cfparam name="FORM.state" 	default="1">
<cfset formName = "frmOprGroups">

<!--- Changed for the Planning Groups - Anand Rao/15-Dec-2010 --->
<cfif (isDefined("FORM.pageSource") AND FORM.pageSource EQ "PGFilters") OR (isDefined("URL.pageSource") AND URL.pageSource EQ "PGFilters") >
   <cfset qGetExistingData = OprGroupDataManager.fnQryExistingOperatorData( 
                                TemplateID = FORM.TemplateID, 
                                TemplateFiltersID = FORM.TemplateFiltersID, 
                                OperatorGroupLevelID = FORM.groupLevelId, 
                                bActive = 1
                                ) />

	<cfif (FORM.FinalOprList EQ "" AND qGetExistingData.RecordCount GTE 1)>
    	<cfset FORM.FinalOprList = ValueList(qGetExistingData.Operator_Group_ID) />
   	</cfif>       
  	<cfset sURL =  "?PageSource=PGFilters&groupLevelId=" & URL.groupLevelId & "&TemplateID=" & URL.TemplateID & "&FormName=DataForm&FieldName=SelectedFilterGroups&TemplateFiltersID=" & URL.TemplateFiltersID />  
  	<FORM ACTION="OperatorGroup_Search.cfm#sURL#" METHOD="post" name="#formName#"><!--- frmApprovalGroups --->
    	<input type="hidden" name="bSubmit" id="bSubmit" value="0" />
    	<input type="hidden" name="TemplateID" <cfif isDefined("FORM.TemplateID") AND FORM.TemplateID NEQ "">Value="#FORM.TemplateID#"<cfelse>value=""</cfif> />
    	<input type="hidden" name="TemplateFiltersID" <cfif isDefined("FORM.TemplateFiltersID") AND FORM.TemplateFiltersID NEQ "">Value="#FORM.TemplateFiltersID#"<cfelse>value=""</cfif> />
<cfelse>
  <FORM ACTION="#thisPage#" METHOD="post" name="#formName#"> 
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
		
	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">		
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF GetGroupValues.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#GetGroupValues.recordcount#</CFOUTPUT> #qGetTopLevelGroups.Group_Level_Desc# That <CFIF GetGroupValues.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Selection Criteria</LEGEND>
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
	      					<table cellpadding="1" cellspacing="0" border="1" bordercolor="979797"  width="70%" >
								<tr>
									<td width="40%" align="center"><B>#qGetTopLevelGroups.Group_Level_Desc# ID</B></td>
									<td width="60%" align="center"><B>#qGetTopLevelGroups.Group_Level_Desc#</B></td>
								</tr>
							    <cfloop query="GetGroupValues">
									<cfloop query="qGetExistingData">
										<cfif (GetGroupValues.Group_ID EQ qGetExistingData.Operator_Group_ID)>
										<tr>
											<td align="left" width="100px" nowrap valign="top">&nbsp;
												 <cfif (Len(GetGroupValues.Group_ID) NEQ 36)>#GetGroupValues.Group_ID#<cfelse>#GetGroupValues.Group_Number#</cfif> 
											</td>	
											<td>&nbsp;#GetGroupValues.Group_Name#
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

			<TABLE CELLPADDING="2" CELLSPACING="0" WIDTH="100%" CLASS="MainTable datagrid" id="datagrid" style='table-layout:fixed;display:none;'>
		  		<col width="5%">
		  		<col width="30%">
		  		<col width="65%">
				<thead>	
					<tr bgcolor="##ffce84">
						<th>
							<INPUT TYPE="checkbox" NAME="AllOprs" VALUE="" onClick="javaScript: CHSelectAll('Group_ID', this.checked);">			
						</th>
						<th ID="Header"><B> #qGetTopLevelGroups.Group_Level_Desc# ID</B></th>
						<th ID="Header"><B> #qGetTopLevelGroups.Group_Level_Desc#</B></th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th colspan="3">
							<div id="actions">
								<cfif (isDefined("FORM.pageSource") AND FORM.pageSource EQ "PGFilters") OR (isDefined("URL.pageSource") AND URL.pageSource EQ "PGFilters") >
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								  	<a HREF="##" onClick="javascript: return fnPGFiltersSave(document.#formName#)">#application.util.string.actionLinkFormat("import selected record(s)")#</a> 
									<a HREF="##" onClick="javascript: return fnPGFiltersImportAll(document.#formName#)">#application.util.string.actionLinkFormat("import all record(s)")#</a>
									<a HREF="##" onClick="javascript: return fnPGFiltersRemoveAll(document.#formName#)">#application.util.string.actionLinkFormat("removed selected record(s)")#</a>
								<cfelse>
									<a HREF="##" onClick="javascript: return finishedSearching(document.#formName#)">#application.util.string.actionLinkFormat("import selected record(s)")#</a>
									<a HREF="##" onClick="javascript: return importAll(document.#formName#)">#application.util.string.actionLinkFormat("import all record(s)")#</a>
									<a HREF="##" onClick="javascript: return removeAll(document.#formName#)">#application.util.string.actionLinkFormat("removed selected record(s)")#</a>
								</cfif>  
							</div>
						</th>
        			</tr>	      
	    		</tfoot>
				<cfset AllList = ValueList(GetGroupValues.Group_ID)>
				<cfset AlreadySelectedOprs = "">
				<tbody>
					<CFLOOP QUERY="GetGroupValues" startrow="#StartRow#" endrow="#Evaluate(StartRow + MaxRows - 1)#">
						<tr> 
							<td> 
								<INPUT TYPE="checkbox" NAME="Group_ID" VALUE="#Group_ID#"
								<cfif ListFindNoCase(FORM.FinalOprList, Group_ID) NEQ 0>CHECKED
									<cfset AlreadySelectedOprs = listappend(AlreadySelectedOprs, Group_ID, ",")>
								</cfif>>
							</td>
							<td><cfif (Len(Group_ID) NEQ 36)>#Group_ID#<cfelse>#Group_Number#</cfif>&nbsp;</td>			
							<td>
								<cfif (URL.groupLevelId GTE 2000)> 
									<a href = "##" 
									 onclick = "javascript:fnViewMicroMembers('3','#Group_ID#','');return false;">
										#Group_Name#
									</a>
								<cfelse>
									#Group_Name#&nbsp;
								</cfif>
							</td>
						</tr>
					</cfloop>
				</tbody>
			</TABLE>
		</FIELDSET>
 
	<script language="JavaScript">
	function fnPGFiltersImportAll()
    {
		var AllList = "#AllList#";
      	document.frmOprGroups.bSubmit.value = "1";
		if(window.confirm("Do you want to import all the records from the search result?"))
		{
			document.frmOprGroups.AlreadySelectedOprs.value = "";
			document.frmOprGroups.FinalOprList.value = AllList;
  			document.frmOprGroups.submit();
		}			
    	return false;
    }

	function fnPGFiltersRemoveAll(searchForm)
	{
		document.frmOprGroups.AlreadySelectedOprs.value = "";
		document.frmOprGroups.FinalOprList.value = "";
		document.frmOprGroups.AllOprs.checked = true;
		document.frmOprGroups.AllOprs.click();
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
			searchForm.AlreadySelectedOprs.value = "";
			searchForm.FinalOprList.value = AllList;
			finishedSearching(searchForm);
		}
		return false;
	}
	
	function removeAll(searchForm)
	{
		searchForm.AlreadySelectedOprs.value = "";
		searchForm.FinalOprList.value = "";
		searchForm.AllOprs.checked = true;
		searchForm.AllOprs.click();
		return false;
	}
	</script>

	<!------ popup search code ----->
	<INPUT NAME="Formname" TYPE="Hidden" VALUE="DataForm">
	<INPUT NAME="FieldName" TYPE="Hidden" VALUE="Allow_Operator_Group">
	<INPUT NAME="FinalOprList" TYPE="Hidden" VALUE="#FORM.FinalOprList#">
	<INPUT NAME="AlreadySelectedOprs" ID="AlreadySelectedOprs" TYPE="Hidden" VALUE="#AlreadySelectedOprs#">	
	<INPUT NAME="FinisedSearching" TYPE="HIDDEN" VALUE="0">
	<INPUT NAME="startrow" TYPE="HIDDEN" VALUE="#FORM.startrow#">
	<INPUT NAME="frompage" TYPE="HIDDEN" VALUE="#FORM.frompage#">
	<INPUT NAME="ExcludeList" TYPE="HIDDEN" VALUE="#FORM.ExcludeList#">	
	<INPUT NAME="groupLevelId" TYPE="HIDDEN" VALUE="#FORM.groupLevelId#">	
  <INPUT NAME="pageSource" TYPE="HIDDEN" <Cfif isDefined("FORM.pageSource")>VALUE="#FORM.pageSource#"</CFIF> value="">	  
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
		var formName = "frmOprGroups";
	 	var dataTableName = $("##datagrid").dataTable();	
		dataTableName.fnFilter( '' );
		$('.dataTables_filter input').val('');
		$('##bSubmit').val("1");
		$('form[name=' + formName + ']').submit();
     // document.frmOprGroups.bSubmit.value = "1";
     // document.frmOprGroups.submit();
    }
</script>

<cfif isDefined("FORM") AND isDefined("FORM.bSubmit") AND FORM.bSubmit EQ "1">
    <cfset bSuccess = 0 />
    <cfset bSuccess = OprGroupDataManager.fnSaveFilterDataOperator( 
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