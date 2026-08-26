<cfset thisTemplate="#GetFileFromPath(GetCurrentTemplatePath())#">

<CFPARAM name="ListOfPositionsUnderSearchPosition"  default="">
<CFPARAM name="ListOfPositionsUnderMine"      default="">

<!--- -If the browser version is IE 10 or more --->
<cfif len(request.app_general_functions.getBrowserVersion()) GT 4>
	<cfset alignStyle = "inline-block">
<cfelse>
	<cfset alignStyle = "inline">
</cfif>

<CFIF isdefined("URL.FormName")>
  <CFPARAM NAME="URL.AllowImportAll"          Default="0">
  <CFPARAM NAME="URL.FieldName"           Default="User_Positions_ID">
  <CFPARAM NAME="url.EnableListOfPositionsAboveMine"  default="0">
  <CFPARAM NAME="url.RestrictPositionLevel"  default="-1">
  <cfparam name="url.SelectSingleSearchResultOnly" default="0">
  <cfparam name="url.Business_Segment_Id" default="0">
  <FORM ACTION="<CFOUTPUT>#thisTemplate#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm">
    <INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
    <INPUT NAME="FieldName" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FieldName#</CFOUTPUT>">
    <INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
    <INPUT NAME="AllowImportAll" TYPE="HIDDEN" VALUE="<CFOUTPUT>#URL.AllowImportAll#</CFOUTPUT>">
    <INPUT NAME="SelectSingleSearchResultOnly" TYPE="HIDDEN" VALUE="<cfoutput>#url.SelectSingleSearchResultOnly#</cfoutput>">
    <INPUT NAME="EnableListOfPositionsAboveMine" TYPE="HIDDEN" VALUE="<CFOUTPUT>#url.EnableListOfPositionsAboveMine#</CFOUTPUT>">
    <INPUT NAME="RestrictPositionLevel" TYPE="HIDDEN" VALUE="<CFOUTPUT>#url.RestrictPositionLevel#</CFOUTPUT>">
    <INPUT NAME="Disable_Position_List" TYPE="HIDDEN" VALUE="">
    <INPUT TYPE="hidden" name="BusinessSegment" value="<cfoutput>#url.Business_Segment_Id#</cfoutput>"><!--- D28618: Position Drop Down Fields filtered based on Program Business Segment   Added FORM variable Business Segment ID--->
    <INPUT NAME="init"  TYPE="HIDDEN" VALUE="1">
  </FORM>

  <script>

    if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null)
    {
      this.document.all.FinalItemList.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.<CFOUTPUT>#URL.FieldName#</CFOUTPUT>.value;
      var Search_Info_Form = window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>;
      if(Search_Info_Form.SelectSingleSearchResultOnly_Position)
      {
        this.document.all.SelectSingleSearchResultOnly.value = Search_Info_Form.SelectSingleSearchResultOnly_Position.value;
      }
      if(Search_Info_Form.EnableListOfPositionsAboveMine)
      {
        this.document.all.EnableListOfPositionsAboveMine.value = Search_Info_Form.EnableListOfPositionsAboveMine.value;
      }
      if(Search_Info_Form.Disable_Position_List)
      {
        this.document.all.Disable_Position_List.value = Search_Info_Form.Disable_Position_List.value;
      }
      document.all.MyForm.submit();
    }
    else
    {
      alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!");
      window.close();
    }

  </script>
  <cfabort>

</CFIF>

<cfset PAGE_TITLE="Select User Positions">
<cfset GROUP="Common">

<CFPARAM NAME="FORM.SelectedITEMS"          DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList"          DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems"       DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems"     DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedResults"       Default="1">
<CFPARAM NAME="FORM.SelectSingleSearchResultOnly" Default="0">
<CFPARAM NAME="FORM.AllowImportAll"         Default="0">
<CFPARAM NAME="FORM.EnableListOfPositionsAboveMine" DEFAULT="0">
<CFPARAM NAME="FORM.RestrictPositionLevel" DEFAULT="-1">
<CFPARAM NAME="FORM.Search_Level"           DEFAULT="">
<CFPARAM NAME="FORM.Disable_Position_List"      DEFAULT="">
<CFPARAM NAME="FORM.Segments"           DEFAULT="disabled">
<cfparam name="form.BusinessSegment" default="">
<CFPARAM NAME="FORM.FieldName"           DEFAULT="">
<CFPARAM NAME="FORM.ParentFormname"      DEFAULT="">


<CFIF FORM.SelectSingleSearchResultOnly EQ 1>
  <cfset FORM.AllowImportAll = 0>
</CFIF>


<cfset FORM.LoadSavedResults=0>

<CFIF FORM.finishedselectingitems EQ 1>
  <script>
    opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.<CFOUTPUT>#Form.FieldName#</CFOUTPUT>.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>';
    opener.document.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.submit();
    window.close();
  </script>
  <CFABORT>
</CFIF>
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
<cfsavecontent variable="head_content">
	<cf_include files="/styles/jQueryUI_18/jquery.multiselect.css, /styles/jQueryUI_18/jquery-ui-1.8.14.custom.css">

	<cfinclude template="/common_files/jQuery.cfm">
	<cf_include files="/Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js, /Script/javascript/jQueryUI_18/jquery.multiselect.min.js">

	<script>
		$(document).ready(function() {
			var started = +(new Date);
			$('.dropdown').multiselect({
			     checkAllText:"Select All"
			    ,uncheckAllText:"Unselect All"
			    ,selectedText: function(numChecked, numTotal, checkedItems){
			          if (numChecked == numTotal) {
			            return 'Selected All';
			          }
			          else {
			            return numChecked + ' of ' + numTotal + ' selected';
			          }
			       }
			});
			var ended = +(new Date);
		});
	</script>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</HEAD>
<body>
<style>
	TABLE.Maintable TD
	{
	  border-bottom:solid #93BEE2 1px; font-size:10px;
	}
	#header
	{
	  font-size:12px;
	}
	SELECT
	{
	 width:190px;
	}
	.dropdown { width:200px; display:none; }
	#actions { text-align:center; }
	table.tfilter > tbody > tr { line-height:18px; }
	body { margin:5px; }
	#border_9010 { margin:0; padding:0; }
</style>
<cfset Input_Select_Width = 160>

<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
  SELECT  User_Positions_ID
  FROM  User_Position_Holders
  WHERE   User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>

<CFQUERY NAME="getUserPrimaryPosition" datasource="#application.datasource#">
  SELECT  User_Positions_ID
  FROM  User_Position_Holders
  WHERE Deleted = 0
  AND   User_ID = '#request.AccessStructure.user_id#'
  AND   User_Position_Type ='P'
</CFQUERY>

<CFPARAM NAME="Form.sort_by"    DEFAULT="Position_Label">
<CFPARAM NAME="Form.sort_Order"   DEFAULT="ASC">

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="/settings/Advanced_Budget/actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->

<FORM ACTION="<CFOUTPUT>#thisTemplate#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE">
<CFOUTPUT>
  <INPUT TYPE="HIDDEN" NAME="sort_Order" VALUE="#FORM.sort_Order#">
  <INPUT TYPE="HIDDEN" NAME="sort_by" VALUE="#FORM.sort_by#">
</CFOUTPUT>
<CFPARAM NAME="Form.Label"    DEFAULT="">
<CFPARAM NAME="Form.Positions"  DEFAULT="<cfoutput>#getUserPrimaryPosition.User_Positions_ID#</cfoutput>">
<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">user position search</LEGEND>
<TABLE BORDER="0" CELLSPACING="2" CELLPADDING="0" width="100%" BGCOLOR="WhiteSmoke" class="tfilter">
  <TR>
    <TD COLSPAN="2">
      <B>Position Name / Number</B><BR>
      <cfoutput><INPUT TYPE="TEXT" NAME="Label" VALUE="#Form.Label#" STYLE="WIDTH:400px"></cfoutput>
    </TD>
    <TD>
    <B>Sales Hierarchy Level</B><BR>
    <cfsetting enablecfoutputonly="true">
    <cfif isDefined("form.init")>
		<cfif FORM.RestrictPositionLevel EQ "-1">
      		<cfset FORM.Search_Level = "0,1,2,3">
		<cfelse>
			<cfset FORM.Search_Level = FORM.RestrictPositionLevel>
		</cfif>
    </cfif>

    <cfoutput><SELECT NAME="Search_Level" class="dropdown" multiple="multiple"></cfoutput>
      <cfif FORM.RestrictPositionLevel EQ "-1" OR FORM.RestrictPositionLevel EQ "0"><cfoutput><option value="0" <cfif form.Search_Level contains "0">selected</cfif>>Headquarters</option></cfoutput></cfif>
      <cfif FORM.RestrictPositionLevel EQ "-1" OR FORM.RestrictPositionLevel EQ "1"><cfoutput><option value="1" <cfif form.Search_Level contains "1">selected</cfif>>#application.returned_customer_setting.zone_label_plural#</option></cfoutput></cfif>
      <cfif FORM.RestrictPositionLevel EQ "-1" OR FORM.RestrictPositionLevel EQ "2"><cfoutput><option value="2" <cfif form.Search_Level contains "2">selected</cfif>>#application.returned_customer_setting.region_label_plural#</option></cfoutput></cfif>
      <cfif FORM.RestrictPositionLevel EQ "-1" OR FORM.RestrictPositionLevel EQ "3"><cfoutput><option value="3" <cfif form.Search_Level contains "3">selected</cfif>>#application.returned_customer_setting.market_label_plural#</option></cfoutput></cfif>
    <cfoutput></SELECT></cfoutput>
    <cfsetting enablecfoutputonly="false">

    </TD>
    <TD VALIGN="bottom">
      <cfoutput><a href="javascript:reset_Form_Fields();">#Lcase(ActionText("reset"))#</a></cfoutput>
    </TD>
    <TD COLSPAN="2" VALIGN="bottom">
      <cfoutput><a href="javascript:document.all.MyForm.submit();">#Lcase(ActionText("search"))#</a></cfoutput>
    </TD>
  </TR>
  <!---business segments drop-down--->
  <cfset busSegMgr.obj = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
  <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
  <cfset busSegMgr.isEnabled = busSegMgr.obj.isEnabled() && appSettings.getPositionFieldsFilterOnProgramSegment()>
  <cfset busSegMgr.label = appSettings.getbusiness_segment_label()>
  <cfif busSegMgr.isEnabled>
    <cfset qSegments = busSegMgr.obj.getActive( userId = request.AccessStructure.User_ID )>
    <tr>
    <td colspan="2">&nbsp;</td>
    <td><b><cfoutput>#busSegMgr.label#</cfoutput></b><br/>
      <cfif isDefined("form.init")>
        <cfset FORM.segments = ValueList(qSegments.business_segment_id)>
      </cfif>
      <cfquery dbtype="query" name="qSortedSegments">
        SELECT * FROM qSegments ORDER BY Business_Unit_Desc
      </cfquery>
      <cfsetting enablecfoutputonly="true">
      <cfoutput><select name="segments" class="dropdown" multiple="multiple"></cfoutput>
      <cfloop query="qSortedSegments">
        <cfoutput><option value="#qSortedSegments.business_segment_id#" <cfif form.segments contains qSortedSegments.business_segment_id>selected=selected</cfif>>#qSortedSegments.Business_Unit_Desc#</option></cfoutput>
      </cfloop>
      <cfoutput></select></cfoutput>
      <cfsetting enablecfoutputonly="false">
    </td>
    </tr>
  <cfelse>
    <!---send disabled value to skip the filtering by segment--->
    <input name="segments" type="hidden" value="disabled">
  </cfif>
</TABLE>

</FIELDSET>

<cfset sql_Sort_By="User_Positions.Position_Label">
<!------Position, Position Number, Sales Hierarcy Level----->
<CFSWITCH expression="#LCase(trim(Form.sort_by))#">
  <CFCASE value="Position">
    <cfset sql_Sort_By="Position_Label">
  </CFCASE>
  <CFCASE value="Position Number">
    <cfset sql_Sort_By="Position_Number">
  </CFCASE>
  <CFCASE value="Sales Hierarcy Level">
    <cfset sql_Sort_By="Position_Level">
  </CFCASE>
  <cfdefaultcase>
    <cfset sql_Sort_By="Position_Label">
  </cfdefaultcase>
</CFSWITCH>
<cfif busSegMgr.label eq LCase(trim(Form.sort_by))>
  <cfset sql_Sort_By = "Business_Segment.Business_Unit_Desc">
</cfif>
<cfset sql_Sort_By_Order=" ASC">
<CFIF Form.sort_Order EQ "DESC">
  <cfset sql_Sort_By_Order=" DESC">
</CFIF>
<cfset sql_Sort_By="#sql_Sort_By# #sql_Sort_By_Order#">
<!--- Dev Note: drachala; 28618:Position Drop Down Fields filtered based on Program Business Segment   Added URL variable Business Segment ID  START
Added/Changed:  Added if condition to pass form variable as argument--->
<cfif (busSegMgr.isEnabled) AND (appsettings.getPositionFieldsFilterOnProgramSegment()) AND (len(form.BusinessSegment) AND form.BusinessSegment NEQ 0)>
	<cfset form.segments = #form.BusinessSegment#>
</cfif>
<!--- End Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  --->
<cfset positionManager = CreateObject("component", "components.geography.position").init() />
<cfset TheQuery = positionManager.getPositions(level = form.Search_Level, sortBy = sql_Sort_By, ignoreDeletedFlag = 0, keyword = trim(form.Label), segments = form.segments) />

<cfif Len(trim(form.FinalItemList))>
  <cfset Selected_List = positionManager.getPositions(form.FinalItemList) />
<cfelse>
  <cfset Selected_List.RecordCount = 0 />
</cfif>

<cfset FORM.All_User_Positions_ID = valuelist(TheQuery.User_Positions_ID) />

<CFSCRIPT>
  Border="Yes";
  BorderSize=1;
  BorderColor="Silver";
  Image="/images/plus3.gif";
  ImageOpen="/images/minus3.gif";
  TitleColor="Navy";
  TitleFont="Arial";
  TitleSize=8;
  IsClosed="Yes";
  WIDTH="100%";
</CFSCRIPT>

<cfset Open_Layer_Caption = "currently selected positions">
<CF_openLayer
  Border="#Border#"
  BorderSize="#BorderSize#"
  BorderColor="#BorderColor#"
  Image="#Image#"
  ImageOpen="#ImageOpen#"
  Title="#Open_Layer_Caption#"
  TitleClosed="#Open_Layer_Caption#"
  TitleTooltip="#Open_Layer_Caption#"
  TitleColor="#TitleColor#"
  TitleFont="#TitleFont#"
  TitleSize="#TitleSize#"
  IsClosed="#IsClosed#"
  Width="#width#">
<CFIF Selected_List.recordcount GT 0>
 <TABLE border="0" cellspacing="1" cellpadding="2" align="left" WIDTH="100%" BGCOLOR="white">
   <TR>
   <cfsetting enablecfoutputonly="true" >
   <cfloop query="Selected_List">
     <cfoutput><TD NOWRAP BGCOLOR="##eeeeee">#Position_Label#</TD></cfoutput>
     <CFIF Selected_List.currentrow mod 3>
     <CFELSE>
       <!---ends current row & starts a new row--->
       <cfoutput></tr></cfoutput><cfif Selected_List.currentrow lt Selected_List.RecordCount><cfoutput><tr></cfoutput></cfif>
     </CFIF>
   </cfloop>
   <cfsetting enablecfoutputonly="false" >
   <cfif Selected_List.recordcount mod 3>
     <!---ends the last row--->
     </tr>
   </cfif>
 </TABLE>
<CFELSE>
  NONE
</CFIF>
  <BR>
</CF_openLayer>


<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">
  There <cfif TheQuery.recordcount EQ 1>Is<cfelse>Are</cfif> <cfoutput>&nbsp;#TheQuery.recordcount#</cfoutput> <cfif TheQuery.recordcount EQ 1>Position<cfelse>Positions</cfif>
</LEGEND>
<cfset FORM.AlreadySelectedItems = "">
<CFIF TheQuery.recordcount GT 0>
<br>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<table id="Positions" class="datagrid" border="0">
	<thead>
	<tr>
		<th>
		  <cfif form.SelectSingleSearchResultOnly neq "1">
	       	<INPUT Name="allbox" TYPE="Checkbox" TITLE="Click here to select all Programs">
	      </cfif>
		</th>
		<cfset HeaderNameList="Position, Position Number, Sales Hierarcy Level">
		<cfif busSegMgr.isEnabled>
		      <cfset HeaderNameList = HeaderNameList & "," & appSettings.getbusiness_segment_label()>
		</cfif>
		<CFLOOP LIST="#HeaderNameList#" INDEX="this_Header" DELIMITERS=",">
		   <th>
				<cfoutput>#this_Header#</cfoutput>
		   </th>
		</CFLOOP>
	</tr>
	</thead>

	<tbody>
		<cfoutput query="TheQuery">
		 	<tr>
			<cfset Disable_This = ListFindNoCase(Disable_Position_List, User_Positions_ID, ",") gt 0>
		   	<td>
		   		<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
		          <CFIF Disable_This>
		            <INPUT type="Checkbox" DISABLED>
		          <CFELSE>
		            <INPUT type="Checkbox" NAME="SelectedITEMS" class="cb" VALUE="#trim(TheQuery.User_Positions_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.User_Positions_ID)) NEQ 0>CHECKED
					<cfset FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.User_Positions_ID), ",")></CFIF>
					ONCLICK="if(!this.checked) document.all.allbox.checked = false;addRemoveEntries();">				
		          </CFIF>
		        <CFELSE>
		          <CFIF Disable_This>
		            <INPUT type="Radio" DISABLED>
		          <CFELSE>
		            <INPUT type="Radio" NAME="SelectedITEMS" class="cb" VALUE="#trim(TheQuery.User_Positions_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.User_Positions_ID)) NEQ 0>CHECKED
					<cfset FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.User_Positions_ID), ",")></CFIF>
					ONCLICK="if(!this.checked) document.all.allbox.checked = false;addRemoveEntries();">
		          </CFIF>
		        </CFIF>
		    </td>
			<td>&nbsp;#Trim(TheQuery.Position_Label)#</td>
		   	<td>&nbsp;&nbsp;#Trim(TheQuery.Position_Number)#</td>
		   	<td>
			   	  <cfif TheQuery.Position_Level eq 3>
			        &nbsp;&nbsp;&nbsp;&nbsp;#application.returned_customer_setting.market_label_singular#&nbsp;
			      <cfelseif TheQuery.Position_Level eq 2>
			        &nbsp;&nbsp;&nbsp;&nbsp;#application.returned_customer_setting.region_label_singular#&nbsp;
			      <cfelseif TheQuery.Position_Level eq 1>
			        &nbsp;&nbsp;&nbsp;&nbsp;#application.returned_customer_setting.zone_label_singular#&nbsp;
			      <cfelse>
			        &nbsp;&nbsp;&nbsp;&nbsp;Headquarters&nbsp;
			      </cfif>
			</td>
			<cfif busSegMgr.isEnabled>
			   <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#Trim(TheQuery.Business_Unit_Desc)#</td>
			</cfif>
			</tr>
		</cfoutput>
	</tbody>
</table>
</CFIF>
</FIELDSET>


  <cfoutput>
    <INPUT TYPE="hidden" NAME="FieldName"             VALUE="#FORM.FieldName#">
    <INPUT TYPE="hidden" NAME="ParentFormname"          VALUE="#FORM.ParentFormname#">
    <INPUT TYPE="hidden" NAME="FinalItemList"           VALUE="#Form.FinalItemList#" />
    <INPUT TYPE="hidden" NAME="AlreadySelectedItems"      VALUE="#Form.AlreadySelectedItems#" />
    <INPUT TYPE="hidden" NAME="finishedselectingitems"      VALUE="0">
    <INPUT TYPE="HIDDEN" NAME="AllowImportAll"          VALUE="#FORM.AllowImportAll#">
    <INPUT TYPE="HIDDEN" NAME="SelectSingleSearchResultOnly"  VALUE="#FORM.SelectSingleSearchResultOnly#">
    <INPUT TYPE="HIDDEN" NAME="EnableListOfPositionsAboveMine"  VALUE="#FORM.EnableListOfPositionsAboveMine#">
	<INPUT TYPE="HIDDEN" NAME="RestrictPositionLevel"  VALUE="#FORM.RestrictPositionLevel#">
    <INPUT TYPE="HIDDEN" NAME="Disable_Position_List"       VALUE="#FORM.Disable_Position_List#">
    <!---<INPUT TYPE="HIDDEN" NAME="All_User_Positions_ID"       VALUE="#FORM.All_User_Positions_ID#">--->
  </cfoutput>
</FORM>

<cfif TheQuery.recordcount GT 0>
  <DIV id="actions">
    <cfoutput>
    <a href="javascript:finishedSearching();">#Lcase(ActionText("import selected positions"))#</a>
    <a href="javascript:importAllProducts(#TheQuery.recordcount#);" style="margin:0 20px">#Lcase(ActionText("import all returned positions"))#</a>
    <a href="javascript:removeAllProducts();">#Lcase(ActionText("remove all selected positions"))#</a>
    </cfoutput>
  </DIV>
</cfif>

<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<SCRIPT>
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .61 : .45) * windowHeight;
var grid = $('#Positions').dataTable({
						"bPaginate": true
						,"iDisplayLength": 100
						,"bSortClasses": false
						,"bScrollCollapse": true
						,"sDom": 'fptipr'
						,"sScrollY": sScrollY
						,"aaSorting": [[ 0, "asc" ]]
						,"aoColumns": [ 	 {"bSortable":false}
													,{"bSortable":true}
													,{"bSortable":true}
													,{"bSortable":true}
													<cfif busSegMgr.isEnabled>
													,{"bSortable":true}
													</cfif>
												]
						,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
			})

			$('table#Positions tr').hover (
				function() { $(this).addClass("over"); },
				function() { $(this).removeClass("over"); }
			);

$('input[name=allbox]').change(function() {
	$("input.cb").attr("checked", (this.checked ? true : false));
	 addRemoveEntries();
});


function sortByThisItem(thisObj, thisSortItem, thisSortOrder) {
	var formObj;
	formObj = document.all.MyForm;
	formObj.sort_by.value = thisSortItem;
	formObj.sort_Order.value = thisSortOrder;
	formObj.submit();
	return false;
}

function reset_Form_Fields(){
	document.MyForm.reset();
	document.MyForm.Label.value='';
	$('.dropdown').multiselect("checkAll");  <!---check ALL selections in dropdowns--->
	document.MyForm.submit();
}

function importAllProducts(recordcount) {
	if(parseInt(recordcount) == 1)
		pString = "Position";
	else
		pString = "Positions";

	$("input[name=allbox]").attr("checked", true);
	$("input[name=allbox]").trigger("change");

	document.MyForm.finishedselectingitems.value = 1;
	if (document.MyForm.FinalItemList.value.length > 0) {
		document.MyForm.FinalItemList.value = document.MyForm.FinalItemList.value + ",";
	}
	else {
		document.MyForm.FinalItemList.value = "";
	}
	document.MyForm.FinalItemList.value = document.MyForm.FinalItemList.value + "<CFOUTPUT>#FORM.All_User_Positions_ID#</CFOUTPUT>";
	document.MyForm.submit();
}

function removeAllProducts() {
	if (confirm("By pressing OK all selected records will be unselected")) {
		document.MyForm.finishedselectingitems.value = 0;
		document.MyForm.FinalItemList.value          = "";
		document.MyForm.AlreadySelectedItems.value   = "";
		$("input[name=allbox]").attr("checked", false);
		$("input[name=allbox]").trigger("change");
	}
}

function finishedSearching() {
	document.all.finishedselectingitems.value = 1;
	document.all.MyForm.submit();
}

function addRemoveEntries(){

	/* all checked rows are saved in a hidden input with a name of 'FinalItemList' */

	/* checkbox */
	<CFIF FORM.SelectSingleSearchResultOnly eq 0>
	var hiddenCBoxes = $('input[name=FinalItemList]').val().toLowerCase();
	<CFELSE>
	/* radio */
	var hiddenCBoxes = '';
	</CFIF>

	/* convert the list into an array for easy manipulation */
	if (hiddenCBoxes.length == 0)
		var aPositionsList = [];
	else
		var aPositionsList = hiddenCBoxes.split(",");

	/* scan thru all checkboxes (or radio buttons for single selection) on the page */
	$('input.cb').each( function() {
	/* Kept it lowercase for being used in case-insensitive search using "$.inArray" */
	var positionID = $(this).val().toLowerCase();

		if ( $(this).prop('checked') ) {
			 /* checked box is not in the array, add it */
			if($.inArray(positionID, aPositionsList) == -1){
			
				aPositionsList.push( positionID );
			}
		}
		else {
			 /* box is not checked so we need to remove it */
			while($.inArray(positionID, aPositionsList) != -1) {
				aPositionsList.splice($.inArray(positionID , aPositionsList),1);
			}
		}
	});

	/* convert array back to a list for usage in form action */
	hiddenCBoxes = aPositionsList.join(",");

	/* refresh the hidden input with ALL selected rows */
	$('input[name=FinalItemList]').val( hiddenCBoxes );
}
	$("input[type=text]").keypress(function (e) {
		if (e.which == 13) {
			document.all.MyForm.submit();
		}
	});
	
	</script>
</body>
</html>