<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />


<CFOUTPUT>
<!DOCTYPE HTML>
<HTML>
<cfset thisPage = CGI.SCRIPT_NAME & "?" & CGI.QUERY_STRING>

<CFPARAM NAME="FORM.AlreadySelectedDists" 	DEFAULT="">
<CFPARAM NAME="FORM.Group_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.FinalDistList" 	DEFAULT="">
<CFPARAM NAME="FORM.FinisedSearching" 	DEFAULT="0">
<CfPARAM NAME="FORM.TemplateFiltersID" 	DEFAULT="0">
<CfPARAM NAME="FORM.TemplateID" 	DEFAULT="0">
<CFPARAM NAME="FORM.pageSource" default="" />
<CFPARAM NAME="FORM.bSubmit" default="0" />
<CfPARAM NAME="FORM.PlannerTemplateFiltersID" 	DEFAULT="0">

<CFPARAM NAME="URL.ExcludeListFieldname" 	DEFAULT="">
<CFPARAM NAME="URL.groupLevelId" 	DEFAULT="0">
<CFPARAM NAME="URL.pageSource" DEFAULT="">
<CFPARAM NAME="URL.TemplateID" DEFAULT="">
<CFPARAM NAME="URL.TemplateFiltersID" DEFAULT="">
<CFPARAM NAME="URL.ExcludeDistID" DEFAULT="0"> 
<CFPARAM NAME="URL.IncludeIOPGFlag" DEFAULT="0"> 
<CFPARAM NAME="URL.Business_Segment_Id" DEFAULT="0">
<CFPARAM NAME="URL.CurrentTemplateID" DEFAULT="#URL.TemplateID#">
<CfPARAM NAME="URL.PlannerTemplateFiltersID" 	DEFAULT="0">
<CFPARAM NAME="URL.FieldName" DEFAULT="">
<CFPARAM NAME="URL.GroupLevelFieldName" DEFAULT="">
<CFPARAM NAME="URL.submitParentForm" DEFAULT="">

<cfif isDefined("URL.groupLevelId") AND URL.groupLevelId NEQ 0>
  <cfset FORM.groupLevelId = URL.groupLevelId />
</cfif>
<cfif isDefined("URL.TemplateID") AND URL.TemplateID NEQ "">
  <cfset FORM.TemplateID = URL.TemplateID />
</cfif>
<cfif isDefined("URL.TemplateFiltersID") AND URL.TemplateFiltersID NEQ "">
  <cfset FORM.TemplateFiltersID = URL.TemplateFiltersID />
</cfif>
<cfif isDefined("URL.CurrentTemplateID") AND URL.CurrentTemplateID NEQ "">
  <cfset FORM.CurrentTemplateID = URL.CurrentTemplateID />
</cfif>
<cfif isDefined("URL.ExcludeDistID") AND URL.ExcludeDistID NEQ "">
  <cfset FORM.ExcludeDistID = URL.ExcludeDistID />
</cfif>
<cfif isDefined("URL.PageSource") AND URL.PageSource NEQ "">
  <cfset FORM.PageSource = URL.PageSource />
</cfif>
<cfif isDefined("URL.FormName") AND URL.FormName NEQ "">
  <cfset FORM.FormName = URL.FormName />
</cfif>
<cfif isDefined("URL.PlannerTemplateFiltersID") AND URL.PlannerTemplateFiltersID NEQ 0>
  <cfset FORM.PlannerTemplateFiltersID = URL.PlannerTemplateFiltersID />
</cfif>
<cfif isDefined("URL.FieldName")>
  <cfset FORM.FieldName = URL.FieldName />
</cfif>
<cfif isDefined("URL.submitParentForm")>
  <cfset FORM.submitParentForm = URL.submitParentForm />
</cfif>
<cfif isDefined("URL.GroupLevelFieldName")>
  <cfset FORM.GroupLevelFieldName = URL.GroupLevelFieldName />
</cfif>

<cfparam name="attributes.groupLevelType" 	default="0">
<cfparam name="attributes.businessSegmentId" 	default="0">
<cfparam name="attributes.cachedwithin" 	default="#CreateTimeSpan(0, 0, 0, 0)#">
<CFPARAM NAME="attributes.usepopup" DEFAULT="0">
<CFPARAM NAME="attributes.formname" DEFAULT="DataForm">
<CFPARAM Name="attributes.dropDownName" default="">


 
<!--- 
  Distributor_Group_Level Table values:
  Business Segment - 1, Family - 2, Buying Group - 3, Line of Business - 4, Market - 23, Region -	24, Zone - 25
  The below function takes (Active, Include list, exclude List)
  So, we pick only the above values for the dropdown 
---> 
<cfset qGetTopLevelGroups = DistGroupDataManager.getDistributorLevels(1, "#URL.groupLevelId#", "") />

<cfif qGetTopLevelGroups.RecordCount EQ 0>
	<cfquery name="qGetTopLevelGroups" datasource="#application.datasource#">
		SELECT	DISTINCT 
          		Active, 
          		Distributor_Group_Level_ID, 
          		Distributor_Group_Level_Type_ID, 
          		Group_Level_Desc, 
          		Search_Sequence_Name, 
          		Distributor_Group_Attribute_Master_ID_Field, 
          		Level_ID, 
          		Search_Filter_On,
          		Is_PG 
		FROM	Distributor_Group_Level 
		WHERE	Deleted = 0
 		AND		Active = 1
		AND		Distributor_Group_Level_Type_ID IN (#URL.groupLevelId#)
	</cfquery>
</cfif>

<cfset DistGroupManager = CreateObject("component", "components.programs.distributors.DistributorGroupManager").init() />
<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />

<cfset DistributorGroupAttributeManager = CreateObject("component", "components.customer.group.DistributorGroupAttributeManager").init() />
<cfset is_pg_info = DistributorGroupAttributeManager.getDistributorGroupAttributes(groupLevelTypeId = URL.groupLevelId) />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<cfset Business_Segment_Id = 0>
<cfif businessSegManager.isEnabledForDistributor()>
	<cfif is_pg_info.IS_PG>
		<cfset Business_Segment_Id = URL.Business_Segment_Id>
	<cfelse>
		<cfif URL.Business_Segment_Id neq 0>
			<cfset oBSFilter = businessSegManager.get(URL.Business_Segment_Id) />
			<cfset Business_Segment_Id = Val(oBSFilter.Customer_Group_BS_Filter)>
		</cfif>
		
		<cfif appSettings.getFilterBusinessSegments()>

		<cfif isDefined("FORM.pageSource") AND FORM.pageSource EQ "PGFilters" AND isDefined("FORM.CurrentTemplateID") AND FORM.CurrentTemplateID NEQ "">		
			<cfset qTemplateSegments = businessSegManager.getBusinessSegmentTemplateSettings(FORM.CurrentTemplateID) />
			<cfset Business_Segment_Id = valueList(qTemplateSegments.Business_Segment_ID) />
			<cfif Business_Segment_Id eq "">
				<cfset Business_Segment_Id = "0" />
			</cfif>
		</cfif>
		</cfif>
	</cfif>
</cfif>
		
<cfset stGetGroupAttributeInfo = DistributorGroupAttributeManager.getGroupAttributeInfo(groupLevelTypeId = URL.groupLevelId) />
<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START Added Business Segment ID --->
<cfset GetGroupValues = DistributorGroupAttributeManager.getDistributorGroupValues(
						DistributorGroupAttributeInfo 	= stGetGroupAttributeInfo,
						cachedwithin					= attributes.cachedwithin,
						ExcludeDistID 				= FORM.ExcludeDistID,
						businessSegmentId           = Business_Segment_Id,
						TemplateFiltersID			= FORM.TemplateFiltersID
						) />
<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->

<cfif FORM.PlannerTemplateFiltersID NEQ "0">
	
	<cfquery name="qGetExistingGroups" datasource="#application.datasource#">
		SELECT	* 
		FROM 	Planner_Template_Filters_Customers
		WHERE	Planner_Template_ID = '#FORM.PlannerTemplateFiltersID#'
	</cfquery>

	<cfset FORM.FinalDistList = '#ValueList( qGetExistingGroups.Distributor_Group_ID)#' />
	
</cfif>

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

<BODY>

<SCRIPT LANGUAGE="JavaScript" SRC="/settings/Planning_groups/_planning_groups.js"></SCRIPT>
<CFPARAM NAME="FORM.ExcludeList" 	DEFAULT="">
<cfparam name="FORM.state" 	default="1">
<cfset formName = "frmDistGroups">

<FORM ACTION="#thisPage#" METHOD="post" name="#formName#"> 


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
		
		<!--- Get the records that match the selected criterria --->
	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">		
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF GetGroupValues.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#GetGroupValues.recordcount#</CFOUTPUT> #qGetTopLevelGroups.Group_Level_Desc# That 			<CFIF GetGroupValues.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Selection Criteria</LEGEND>
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
		       		</span>
		     	</legend>
		    	<div id="lyrgroup_1" style="display:none; visibility:inherit; z-index:5; margin:10px 10px 8px 20px;">
		      		<div id="masterContainer">
		      		<table cellpadding="3" cellspacing="0" border="1" width="70%" class="datagrid">
							<thead>
							<tr>
									<th width="40%">#qGetTopLevelGroups.Group_Level_Desc# ID</td>
									<th width="60%">#qGetTopLevelGroups.Group_Level_Desc#</td>
							</tr>	
							</thead>
							<cfsavecontent variable="variables.tBody">
					        <cfloop query="GetGroupValues">
								<cfloop query="qGetExistingData">
									<cfif (GetGroupValues.Group_ID EQ qGetExistingData.Distributor_Group_ID)>
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
							</cfsavecontent>
							<tbody>
				 				<!--- remove extra blank lines, line feeds to minimize the response size --->
 								#application.util.string.compress(variables.tBody)#
 							</tbody>
						</table>
		  			</div>
		    	</div>
			</fieldset>
			<br>
 		</cfif>	

		<TABLE CELLPADDING="2" CELLSPACING="0" WIDTH="100%" CLASS="MainTable datagrid" id="datagrid"  style='table-layout:fixed;display:none;'>
		  <col width="5%">
		  <col width="30%">
		  <col width="65%">
		<thead>	
		<TR>
			<th>
			<INPUT TYPE="checkbox" NAME="AllDists" VALUE="" onClick="javaScript: CHSelectAll('Group_ID', this.checked);">			
			</th>
				<th ID22="Header">#qGetTopLevelGroups.Group_Level_Desc# ID</th>
			<th ID22="Header">#qGetTopLevelGroups.Group_Level_Desc#</th>
		</TR>
		</thead>
	    <tfoot>
			<tr>
				<th colspan="3">
					<div id="actions">
						  	<a HREF="##" onClick="javascript: return finishedSearching(document.#formName#)">#application.util.string.actionLinkFormat("import selected record(s)")#</a>
							<a HREF="##" onClick="javascript: return importAll(document.#formName#)">#application.util.string.actionLinkFormat("import all record(s)")#</a>
							<a HREF="##" onClick="javascript: return removeAll(document.#formName#)">#application.util.string.actionLinkFormat("removed selected record(s)")#</a>  
					</div>
				</th>
        	</tr>	      
	    </tfoot>
		
		<cfset AllList = ValueList(GetGroupValues.Group_ID)>
		<cfset AlreadySelectedDists = "">

		<!--- gather all rows and place them in a string variable --->
		<cfsavecontent variable="variables.tBody">
			<CFLOOP QUERY="GetGroupValues" <!--- startrow="#StartRow#" endrow="#Evaluate(StartRow + MaxRows - 1)#" --->>
				<TR><!---  BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#" --->
					<TD> 
					<INPUT TYPE="checkbox" NAME="Group_ID" VALUE="#Group_ID#" ID="Group_ID"
					<CFIF ListFindNoCase(FORM.FinalDistList, Group_ID) NEQ 0>CHECKED
						<cfset AlreadySelectedDists = listappend(AlreadySelectedDists, Group_ID, ",")>
					</CFIF>
					></TD>
					<td><cfif (Len(Group_ID) NEQ 36)>#Group_ID#<cfelse>#Group_Number#</cfif>&nbsp;</td>			
					<TD>
					<cfif (URL.groupLevelId GTE 2000)> 
						<a href = "##" 
						 onclick = "javascript:fnViewMicroMembers('2','#Group_ID#','');return false;">
							#Group_Name#
						</a>
					<cfelse>
						#Group_Name#&nbsp;
					</cfif>
					</TD>
				</TR>
			</CFLOOP>
		</cfsavecontent>
 		<tbody>
 			<!--- remove extra blank lines, line feeds to minimize the response size --->
 			#application.util.string.compress(variables.tBody)#
		</tbody>
	</TABLE>
</FIELDSET>
 
<script language="JavaScript">
	function fnPGFiltersImportAll()
    {
		var AllList = "#AllList#";
      	document.frmDistGroups.bSubmit.value = "1";
		if(window.confirm("Do you want to import all the records from the search result?"))
		{
			document.frmDistGroups.AlreadySelectedDists.value = "";
			document.frmDistGroups.FinalDistList.value = AllList;
  			document.frmDistGroups.submit();
		}			
    	return false;
    }

	function fnPGFiltersRemoveAll(searchForm)
	{
		document.frmDistGroups.AlreadySelectedDists.value = "";
		document.frmDistGroups.FinalDistList.value = "";
		document.frmDistGroups.AllDists.checked = true;
		document.frmDistGroups.AllDists.click();
		return false;
	}	
				
		
	function finishedSearching(searchForm)
	{
		searchForm.FinisedSearching.value = 1;
		searchForm.bSubmit.value = 1;
		searchForm.submit();
		return false;
	}

	function importAll(searchForm)
	{
		var AllList = "#AllList#";
		if(window.confirm("Do you want to import all the records from the search result?"))
		{
			searchForm.AlreadySelectedDists.value = "";
			searchForm.FinalDistList.value = AllList;
			finishedSearching(searchForm);
		}
		return false;
	}

	function removeAll(searchForm)
	{
		searchForm.AlreadySelectedDists.value = "";
		searchForm.FinalDistList.value = "";
		searchForm.AllDists.checked = true;
		searchForm.AllDists.click();
		return false;
	}
</script>
	<!------ popup search code ----->
	<INPUT NAME="Formname" TYPE="HIDDEN" VALUE="#FORM.Formname#">
	<INPUT NAME="FieldName" TYPE="HIDDEN" VALUE="#FORM.FieldName#">
	<INPUT NAME="GroupLevelFieldName" TYPE="HIDDEN" VALUE="#FORM.GroupLevelFieldName#">
	<INPUT NAME="submitParentForm" TYPE="HIDDEN" VALUE="#FORM.submitParentForm#">
	<INPUT NAME="FinalDistList" TYPE="HIDDEN" VALUE="#FORM.FinalDistList#">
	<INPUT NAME="AlreadySelectedDists" ID="AlreadySelectedDists" TYPE="Hidden" VALUE="#AlreadySelectedDists#">	
	<INPUT NAME="FinisedSearching" TYPE="HIDDEN" VALUE="0">
	<INPUT NAME="startrow" TYPE="HIDDEN" VALUE="#FORM.startrow#">
	<INPUT NAME="frompage" TYPE="HIDDEN" VALUE="#FORM.frompage#">
	<INPUT NAME="ExcludeList" TYPE="HIDDEN" VALUE="#FORM.ExcludeList#">	
	<INPUT NAME="groupLevelId" TYPE="HIDDEN" VALUE="#FORM.groupLevelId#">	
  	<INPUT NAME="pageSource" TYPE="HIDDEN" <Cfif isDefined("FORM.pageSource")>VALUE="#FORM.pageSource#"</CFIF>>	
	<INPUT NAME="bSubmit" TYPE="HIDDEN" value="#form.bSubmit#">
	  
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
        ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
	      ,"aoColumnDefs": [ { "aTargets":[0], "bSortable":false, "bSearchable":false } ] 
	      ,"bAutoWidth": false
	      ,"bPaginate": false
	      ,"iDisplayLength": 200
	      ,"bSortClasses": false
	      ,"bScrollCollapse": true
		  ,"bFilter": true
	      ,"sDom": 'fptip'
	    }).fnSetFilteringDelay();
	 $('##datagrid').show();
	 $('tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
	 new FixedHeader( mydatagrid, { "bottom": true } );
	});
	
	function fnPGFiltersSave()
    { 
		var formName = "frmDistGroups";
	 	var dataTableName = $("##datagrid").dataTable();	
		dataTableName.fnFilter( '' );
		$('.dataTables_filter input').val('');
		$('##bSubmit').val("1");
		$('form[name=' + formName + ']').submit();
     // document.frmDistGroups.bSubmit.value = "1";
     // document.frmDistGroups.submit();
    }
</script>


<cfif isDefined("FORM") AND isDefined("FORM.bSubmit") AND FORM.bSubmit EQ "1">
	<script>
		<cfif FORM.Formname NEQ "" AND FORM.FieldName NEQ "" AND FORM.submitParentForm EQ "1">
			window.opener.#FORM.Formname#.elements["#FORM.FieldName#"].value = '#form.Group_ID#';
			
			<cfif FORM.Formname NEQ "" AND FORM.GroupLevelFieldName NEQ "">
			window.opener.#FORM.Formname#.elements["#FORM.GroupLevelFieldName#"].value = '#form.groupLevelId#';
			</cfif>
			
			window.opener.#FORM.Formname#.submit();			
		<cfelse>
			window.opener.DataForm.Customers_Filters_#FORM.groupLevelId#.value = '#form.Group_ID#';
		</cfif>
		window.close();
	</script>
</cfif> 

</body>
</html>
</cfoutput>