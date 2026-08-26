<cfset currentPage = #GetFileFromPath(GetCurrentTemplatePath())#>
<cfset session.labelMode = URL.labelMode>
<cfset session.appSetCode = URL.appSetCode>
<cfset session.incFile = URL.incFile>
<cfparam name="actionEdit" default="0">
<cfparam name="URL.ShowInactive" default="0">

<cfif URL.LabelMode EQ "BBAutoPayLabels">
	<cfset URL.tblType = "Billback">
	<cfset tableCode = "BB">
	<cfset tableGrab = "BB_Auto_Report_Export_BB_Detail,BB_Auto_Report_Export_BB_Header">
<cfelseif URL.LabelMode EQ "PBAutoPayLabels">
	<cfset URL.tblType = "Pullback">
	<cfset tableCode = "PB">
	<cfset tableGrab = "BB_Auto_Report_Export_Pullback_Detail,BB_Auto_Report_Export_Pullback_Header">
</cfif>

<cfset GetColNames = request.qLabels.GetAutoPayColNames(tableGrab)>
<cfset getAllColNames = request.qLabels.GetAutoPayLabels(tableCode)>

<cfif getAllColNames.recordcount GT 0>
	<cfset actionEdit = 1>
</cfif>

<cfoutput>
<cfset labelTypeURL = "#labelURL##SESSION.labelMode#&appSetCode=#SESSION.appSetCode#&incFile=#SESSION.incFile#">

	<cfif URL.updated EQ 1>
		<div id="masterContainer"><strong style="color:green; font-size:18px;">#URL.tblType# Report Labels saved successfully.</strong></div>
	</cfif>
	<CFIF request.AccessStructure.USER_RIGHTS_ID EQ 9999>
		<div id="masterContainer" style="text-align:right;">
			<cfif URL.ShowInactive EQ 0>
				<a href="#labelTypeURL#&ShowInactive=1">Show Inactive Columns</a>
			<cfelse>
				<a href="#labelTypeURL#">Hide Inactive Columns</a>
			</cfif>
		</div>
	</CFIF>
	<div id="masterContainer">
		NOTE<br />
		* You can drag and drop the rows to place them in a desired sequence by clicking on and dragging the gray "DRAG" box up or down.
		This will control the display sequence of the columns within the Auto-Pay Report.
	</div>
	<form name="customColNames" method="post">
		<input type="hidden" name="tableCode" value="#tableCode#">
		<input type="hidden" name="modifyLabelsAutoPay" value="1">
		<input type="hidden" name="tableName" value="#URL.tblType#">
		<input type="hidden" name="actionEdit" value="#actionEdit#">
		<div id="headerContainer">
			<div id="innerheaderContainer">Default Label</div>
			<div id="innerheaderContainer">Client Label</div>
			<div id="innerheaderContainer"></div>
			<div id="innerheaderContainerSM"><CFIF request.AccessStructure.USER_RIGHTS_ID EQ 9999>Active</cfif></div>
			<div id="innerheaderContainerSM">Order</div>
		</div>
		<div id="sortContainer">
			<cfset rowCounter = 0>
			<cfif actionEdit EQ 1>
				<cfset colLoopList = valueList(getAllColNames.db_col_name)>
			<cfelse>
				<cfset colLoopList = getColNames.ColumnList>
			</cfif>

			<cfloop list="#colLoopList#" index="i">
				<cfif actionEdit EQ 1>
					<cfquery name="getCustColNames" dbtype="query">
						SELECT *
						FROM getAllColNames
						WHERE DB_Col_Name = '#i#'
					</cfquery>
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
					<cfset recordID = getCustColNames.BB_Auto_Report_Export_Labels_ID>
				<cfelse>
					<cfset recordID = 0>
				</cfif>
				<div id="bodyContainer_#activeSequence#" class="sortSection #rowHilite#" recordID="#recordID#">
					<span id="innerbodyContainer">
						<CFIF request.AccessStructure.USER_RIGHTS_ID EQ 9999>
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
						<cfelse>
							<input type="hidden"
									size="30"
									onKeyUp="modified();"
									name="defaultColName_#activeSequence#"
									<cfif actionEdit NEQ 0>
										value="#getCustColNames.Default_Col_Name#"
									<cfelse>
										value="#replace(i,"_"," ","all")#"
									</cfif>
									>

							<cfif actionEdit NEQ 0>
								#getCustColNames.Default_Col_Name#
							<cfelse>
								#replace(i,"_"," ","all")#
							</cfif>
						</cfif>
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
					<span id="innerbodyContainer">
						<input type="hidden" name="dbColName_#activeSequence#" value="#i#">
						<cfif actionEdit NEQ 0>
							<input type="hidden" name="ID_#activeSequence#" value="#getCustColNames.BB_Auto_Report_Export_Labels_ID#">
						</cfif>
					</span>
					<span id="innerBodyContainerSM">
						<CFIF request.AccessStructure.USER_RIGHTS_ID EQ 9999>
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
						<cfelse>
							<cfif listgetat(i,listLen(i,"_"),"_") NEQ "ID">
								<input type="hidden" name="active_#activeSequence#" value="1">
							</cfif>
						</cfif>
					</span>
					<cfif actionEdit EQ 1>
						<span id="innerBodyContainerSM" class="handle sortme">
							DRAG
						</span>
					<cfelse>
						N/A
					</cfif>
				</div>
			<cfelse>
				<cfset rowCounter = rowCounter - 1>
			</cfif>
			</cfloop>
			<input type="hidden" name="colCount" value="#rowCounter#">
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
	</form>
	</div>

	<script type="text/javascript">
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
				parameters : {colList:orderList, tableCode:'#tableCode#', showInactive:'#URL.ShowInactive#'}
				};
	//			alert(options.parameters.colList + "    " + options.parameters.tableCode);
			new Ajax.Request('app_settings_update_label_order.cfm', options);
		}

	//	var errFunc = function(t) {
	//	alert("Error " + t.status + " — " + t.statusText);
	//	}

	</script>
</cfoutput>