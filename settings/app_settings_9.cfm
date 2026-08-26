<cfset currentPage = #GetFileFromPath(GetCurrentTemplatePath())#>
<cfset session.labelMode = URL.labelMode>
<cfset session.appSetCode = URL.appSetCode>
<cfset session.incFile = URL.incFile>

<cfparam name="actionEdit" default="0">
<cfparam name="URL.tblName" default="">
<cfparam name="URL.ShowInactive" default="0">


<script>
function OnSelectMenu(dropdown)
{
    var myindex  = dropdown.selectedIndex;
    var baseURL = dropdown.options[myindex].value;
    location.href = baseURL;

    return true;
}
</script>
<cfset getTables = request.qLabels.getTables()>

<cfif URL.tblName NEQ "">
	<cfset GetColNames = request.qLabels.GetColNames(URL.tblName)>
	<cfset getAllColNames = request.qLabels.GetColLabels(URL.tblName)>

	<cfif getAllColNames.recordcount GT 0>
		<cfset actionEdit = 1>
	</cfif>
</cfif>

<cfoutput>
<form name="selectLabelColumn" method="post">
<cfset tableURL = "#labelURL##SESSION.labelMode#&appSetCode=#SESSION.appSetCode#&incFile=#SESSION.incFile#&tblName=">
	<cfif URL.updated EQ 1>
		<div id="masterContainer"><strong style="color:green; font-size:18px;">Table labels saved successfully.</strong></div>
	</cfif>
	<div id="masterContainer">
		<div id="leftCont">Database Table:
			<select name="tblType" onchange="OnSelectMenu(this.form.tblType);">
				<option value="">Select a table to label...</option>
				<cfloop query="getTables">
				<option value="#tableURL##Table_Name#" <cfif URL.tblName EQ #Table_Name#>selected</cfif>>#Table_Name#</option>
				</cfloop>
			</select>
		</div>
		<cfif actionEdit EQ 1>
			<div id="rightCont" style="width:100%;">
				<cfif URL.ShowInactive EQ 0>
					<a href="#tableURL##URL.tblName#&ShowInactive=1">Show Inactive Columns</a>
				<cfelse>
					<a href="#tableURL##URL.tblName#">Hide Inactive Columns</a>
				</cfif>
			</div>
		</cfif>
	</div>
</cfoutput>
</form>

<cfif URL.tblName EQ "">
	<div id="masterContainer" style="color:red;">
		NOTE<br />
		* You must select a table to create or modify labels for.
	</div>
<cfelse>
	<cfif actionEdit NEQ 1>
		<div id="masterContainer" style="color:red;">
			NOTES<br />
			* The selected table does not have labels stored in the database, please click "save" at
			the bottom of this page to create the labels and have access to label sequencing.
			<br /><br />** ID fields are automatically set to inactive.
			Please be sure to select the checkbox if you desire a label for an ID field.
		</div>
	<cfelse>
		<div id="masterContainer">
			NOTE<br />
			* You can drag and drop the rows to place them in a desired sequence by clicking on and dragging the gray "DRAG" box up or down.
		</div>
	</cfif>
	<form name="customColNames" method="post">
	<cfoutput>
		<input type="hidden" name="tblName" value="#URL.tblName#">
		<input type="hidden" name="modifyLabelsCol" value="1">
		<input type="hidden" name="actionEdit" value="#actionEdit#">
	</cfoutput>
	<div id="masterContainer">
		<div id="headerContainer">
			<div id="innerheaderContainer">Column Name In DB</div>
			<div id="innerheaderContainer">Default Column Name</div>
			<div id="innerheaderContainer">Custom Column Name</div>
			<div id="innerheaderContainerSM">Active</div>
			<div id="innerheaderContainerSM">Order</div>
		</div>
		<div id="sortContainer">
		<cfoutput>
			<cfset rowCounter = 0>
			<cfif actionEdit EQ 1>
				<cfset colLoopList = valueList(getAllColNames.db_col_name)>
			<cfelse>
				<cfset colLoopList = getColNames.ColumnList>
			</cfif>

			<cfloop list="#colLoopList#" index="i">
				<cfif actionEdit EQ 1>
					<cfset useLakebaseForgetCustColNames = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getallcolnames")>
<cfif useLakebaseForgetCustColNames>
	<cftry>
		<cfset getCustColNames = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getallcolnames", {
				"db_col_name" = "eq.#i#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCustColNames = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCustColNames>
<cfquery name="getCustColNames" dbtype="query">
						SELECT *
						FROM getAllColNames
						WHERE DB_Col_Name = '#i#'
					</cfquery>
</cfif>
				</cfif>
			<cfset rowCounter = rowCounter + 1>
			<cfif rowCounter MOD 2>
				<cfif isDefined("getCustColNames.Active")>
					<cfif getCustColNames.Active EQ 1>
						<cfset rowHilite = "rowBg1">
					<cfelse>
						<cfset rowHilite = "inactive">
					</cfif>
				<cfelse>
					<cfset rowHilite = "rowBg1">
				</cfif>
			<cfelse>
				<cfif isDefined("getCustColNames.Active")>
					<cfif getCustColNames.Active EQ 1>
						<cfset rowHilite = "rowBg2">
					<cfelse>
						<cfset rowHilite = "inactive">
					</cfif>
				<cfelse>
					<cfset rowHilite = "rowBg2">
				</cfif>
			</cfif>

			<cfif isDefined("getCustColNames.Active") AND getCustColNames.Active EQ 1>
				<cfset displayThis = 1>
			<cfelse>
				<cfif actionEdit EQ 1>
					<cfif URL.ShowInactive EQ 1>
						<cfset displayThis = 1>
					<cfelse>
						<cfset displayThis = 0>
					</cfif>
				<cfelse>
					<cfset displayThis = 1>
				</cfif>
			</cfif>

			<cfif rowCounter LT 10>
				<cfset activeSequence = '000' & rowCounter>
			<cfelseif rowCounter GTE 10 AND rowCounter LT 100>
				<cfset activeSequence = '00' & rowCounter>
			<cfelseif rowCounter GTE 100 AND rowCounter LT 1000>
				<cfset activeSequence = '0' & rowCounter>
			<cfelseif rowCounter GTE 1000 AND rowCounter LT 10000>
				<cfset activeSequence = rowCounter>
			</cfif>

			<cfif displayThis EQ 1>
				<cfif actionEdit NEQ 0>
					<cfset recordID = getCustColNames.Table_Column_Labels_ID>
				<cfelse>
					<cfset recordID = 0>
				</cfif>
				<div id="bodyContainer_#activeSequence#" class="sortSection #rowHilite#" recordID="#recordID#">
					<span id="innerbodyContainer" style="font-family:courier new; font-size:12px;">
						<cfif len(i) GT 25>
							<cfset name = removechars(i,26,(len(i)-25))&" &hellip;">
						<cfelse>
							<cfset name = i>
						</cfif>
						<cfif len(i) GT 25>
							<cftooltip tooltip="#i#" autodismissdelay="5000">#name#</cftooltip>
						<cfelse>
							#name#
						</cfif>
						<input type="hidden" name="dbColName_#activeSequence#" value="#i#">
					<cfif actionEdit NEQ 0>
						<input type="hidden" name="ID_#activeSequence#" value="#getCustColNames.Table_Column_Labels_ID#">
					</cfif>
					</span>
					<span id="innerbodyContainer">
						<input type="text"
								size="30"
								onKeyUp="modified();"
								name="defaultColName_#activeSequence#"
								<cfif actionEdit NEQ 0>
									value="#getCustColNames.Default_Col_Name#"
								<cfelse>
									value="#replace(i,"_"," ","all")#"
								</cfif>
								>
					</span>
					<span id="innerbodyContainer">
						<input type="text"
								size="30"
								onKeyUp="modified();"
								name="customColName_#activeSequence#"
								<cfif actionEdit NEQ 0>
									value="#getCustColNames.Custom_Col_Name#"
								</cfif>
								>
					</span>
					<span id="innerbodyContainerSm">
						<input type="checkbox"
								name="active_#activeSequence#"
								onClick="modified();"
								value="1"
								<cfif actionEdit NEQ 0>
									<cfif getCustColNames.Active EQ 1>
										checked
									</cfif>
								<cfelse>
									<cfif listgetat(i,listLen(i,"_"),"_") NEQ "ID">
										checked
									</cfif>
								</cfif>
								>
					</span>
					<cfif actionEdit EQ 1>
						<cfif rowHilite NEQ "inactive">
							<span id="innerBodyContainerSM" class="handle sortme">DRAG</span>
						<cfelse>
							<span style="width:0px;height:0px;" class="handle"></span>
						</cfif>
					<cfelse>
						<span id="innerBodyContainerSM">N/A</span>
						<span style="width:0px;height:0px;" class="handle"></span>
					</cfif>
				</div>
			<cfelse>
				<cfset rowCounter = rowCounter - 1>
			</cfif>
			</cfloop>
			<input type="hidden" name="colCount" value="#rowCounter#">
		</cfoutput>
		</div>

		<div id="MainBtnCont" align="center" style="width:700px;margin:10px;">
			<CF_button
					button_name		=	""
					button_caption	=	"Save"
					button_action	=	"customColNames.submit(document.customColNames);"
					button_type		=	"javascript_link"
					button_width	=	"150"
					button_color	=	"Navy"
					button_tip		=	"Save"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
					>
		</div>
	</div>
	</form>
<cfoutput>

<script>
	Sortable.create('sortContainer',{tag:'div', containment: 'sortContainer', only:'sortSection', handle:'handle', scroll:window, onUpdate:updateOrder});
	function updateOrder(){

		var orderList = '';
			orderedNodes = $("sortContainer").getElementsByTagName("div");
			for (var i=0;i < orderedNodes.length;i++) {
				orderList += orderedNodes[i].getAttribute('recordid') + ',';
			}
		var options = {
			method : 'post',
//			onFailure : errFunc,
			parameters : {colList:orderList, tblName:'#tblName#', showInactive:'#URL.ShowInactive#'}
			};
//			alert(options.parameters.colList + "    " + options.parameters.tableCode);
		new Ajax.Request('app_settings_label_sequence.cfm', options);
	}

//	var errFunc = function(t) {
//	alert("Error " + t.status + "  " + t.statusText);
//	}

</script>
</cfoutput>
</cfif>