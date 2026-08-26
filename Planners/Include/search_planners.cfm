<!-----------------------------------------------------------------------------------------------------------------------------------------
Name         :  /planners/include/search_planners.cfm
Created Date :  2017 July
Created By   :  Chris Nguyen
Description  :  Display search planners criteria

Remarks      :
----------------------------------------------------------------------------------------------------------------------------------------->
<style>
	.sectionHead {
		border-bottom:1px solid #0000CD;
		border-bottom:1px solid #EEE;
		color:red;
		font-size:15px;
		font-weight:bold;
		letter-spacing: 1px;
		text-shadow: 4px 4px 4px #AAA;
	}
	table#t413 { width:100%; table-layout:fixed; }
	table#t413 tr { line-height: 22px; }
	table#t413 td.first, table#t413 td:nth-child(1) { padding-left:2%; }
	table#t413 input, table#t413 select { width:90%; }
</style>
<cfsilent>
<cfscript>
	param name="form.Planner_Number"      default="";
	param name="form.Planner_Template"    default="";
	param name="form.Customer_Name"       default="";
	param name="form.Customer_ID"         default="";
	param name="form.Planner_Template_ID" default="";
	param name="form.Responsible_User_Id" default="";
	param name="form.Indirect_Customer"   default="";
	param name="form.Indirect_ID"         default="";
	param name="form.Planner_Status_ID"   default="";
	param name="form.user_position"       default="";
	param name="form.BusinessSegment"     default="0";
	param name="form.Business_Segment_Id" default="";
	param name="form.businessSegmentsOn"  default="0";
	param name="showPlanningGroups"       default="0";
	param name="form.Pending_My_approval" default="0";

	businessSegManager        = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager");
	DistSearchSettingsManager = CreateObject("component", "components.settings.Labels.Labels");
	plannerTemplateManager    = CreateObject("component","mvc.Models.Planner.PlannerTemplateManager");
	qLabels                   = createObject("component", "components.settings.Labels.Labels").init();
	userManager               = CreateObject("component", "components.user.UserManager");

	appSettings        = application.oApplicationAppSettingsManager.getApplicationAppSettings();
	DistSearchSettings = DistSearchSettingsManager.getDistributorStaticSearchFieldsActive();
	qSearchFields      = DistSearchSettingsManager.getDistributorSearchFields();
	templateList       = plannerTemplateManager.getPlannerTemplates();

	stStruct                  = StructNew();
	stStruct.userPositionType = "P,S";
	stStruct.sortBy           = "Position_Level,User_Positions.Position_Label,_Users.Name_First";
	rspList                   = userManager.search(stStruct);

	qGetPlannerCustomerLabels    = qLabels.GetPlannerLabels('Customer');
	qGetPlannerDistributorLabels = qLabels.GetPlannerLabels('Distributor');
	plannerCustomerLabel         = qGetPlannerCustomerLabels.Planner_Labels_Singular;
	plannerCustomerLabelPlural   = qGetPlannerCustomerLabels.Planner_Labels_Plural;
	plannerDistLabel             = qGetPlannerDistributorLabels.Planner_Labels_Singular;
	plannerDistLabelPlural       = qGetPlannerDistributorLabels.Planner_Labels_Plural;

    // gather the same statuses as in \planners\search\planner_search_result.cfm
    plannerSearchManager = CreateObject("component","mvc.Models.Planner.PlannerSearchManager");
    qGetStatus		     = plannerSearchManager.getPlannerStatus();

	if ( businessSegManager.isEnabledForDistributor() )
		if ( form.Business_Segment_ID eq "" ) {
			form.businessSegmentsOn  = 1;
			qGetBusSegments          = businessSegManager.getActive(request.AccessStructure.User_ID);
			form.Business_Segment_Id = ValueList(qGetBusSegments.Business_Segment_Id);
		}
		else
			form.businessSegmentsOn = 1;

	//<!--- End if not pactiv --->
	if ( form.BusinessSegment neq "" and form.BusinessSegment neq "0" )
		form.Business_Segment_Id = form.BusinessSegment;

	maxColsPerRow   = 4;
	currentColCount = 0;
</cfscript>

<cfquery name="GetLinesOfBiz" datasource="#application.datasource#">
	SELECT *
	FROM Line_Of_Business
	WHERE Deleted = 0
	<cfif form.businessSegmentsOn and Lookup_BS_General_Dropdowns eq 1>
		<cfif Len(form.Business_Segment_ID) gt 0>
		and Business_Segment_ID IN (#form.Business_Segment_ID#)
		<cfelse>
			<cfif application.returned_customer_setting.Business_Segments_On eq 1>
				and 1 = 1
			<cfelse>
				and 1=2
			</cfif>
		</cfif>
	</cfif>
	ORDER BY Line_Of_Business_Name
</cfquery>
</cfsilent>

<cfoutput>
<form id="search_planners" method="post">
	<cfset saveHiddenValues()>

	<cfsavecontent variable="variables.uncompressed">
		<table border="0" cellspacing="2"  cellpadding="2" id="t413">
			<col width="27%">
			<col width="25%">
			<col width="25%">
			<col width="23%">
			<tr>
				<td colspan="4" class="sectionHead">#Application.PlannerLabel#</td>
			</tr>
			<tr>
				<td class="first">
					<b>#Application.PlannerLabel# Template</b> <br>
					<select name="Planner_Template"  id="Planner_Template" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();" >
						<option value="">**All** Templates</option>
						<cfloop query="templateList">
							<option value="#templateList.Planner_Template_ID#"
								<cfif form.Planner_Template_ID eq templateList.Planner_Template_ID> selected </cfif>>
								#templateList.Planner_Type#
							</option>
						</cfloop>
					</select>
				</td>
				<td>
					<b>#Application.PlannerLabel# Number</b> <br>
					<input type="text" name="Planner_Number" id="Planner_Number" value="#form.Planner_Number#"
						class="full" onkeydown="if (event.keyCode == 13) enterKeySearch();">
				</td>
				<td>

					<b>#Application.PlannerLabel# Status</b> <br>
					<select name="Planner_Status" id="Planner_Status" class="full" onkeydown="if (event.keyCode == 13) enterKeySearch();">
						<option value="">**All** Status</option>
						<cfloop query="qGetStatus">
							<option value="#qGetStatus.Use_Status_ID#" <cfif form.Planner_Status_ID eq qGetStatus.Use_Status_ID> selected </cfif>>
								#qGetStatus.Status_Description# [#qGetStatus.Status_Abbreviation#]
							</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="4" class="sectionHead" style="padding-top: 20px">#plannerCustomerLabel#</td>
			</tr>
			<tr>
				<td class="first">
					<b>#plannerCustomerLabel# Name</b> <br>
					<input type="text" name="Customer_Name" id="Customer_Name" value="#form.Customer_Name#"
						class="full" onkeydown="if (event.keyCode == 13) enterKeySearch();">
				</td>
				<td>
					<b>Type</b> <br>
					<select name="Planner_Type"  id="Planner_Type" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();" >
						<option value="">**All** Types</option>
						<option value="D">Direct</option>
						<option value="I">Indirect</option>
					</select>
				</td>
			</tr>

			<tr>
			<cfloop query="qSearchFields">
				<!---------------->
				<!---  Family  --->
				<!--------------------------------------------------------------------------------------------------------------------------------------------->
				<cfif qSearchFields.Field_Name eq "Family">
					<td>
						<span class="searchItemLabel"> <strong>#application.returned_customer_setting.family_name_label_plural#</strong> </span> <br>
						<cfquery name="GetFamilyNames" datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Family
							WHERE Deleted = 0
							<cfif form.businessSegmentsOn>
								<cfif Len(form.Business_Segment_ID) gt 0>
								and Business_Segment_ID IN (#form.Business_Segment_ID#)
								<cfelse>
									<cfif application.returned_customer_setting.Business_Segments_On eq 1>
										and 1 = 1
									<cfelse>
										and 1=2
									</cfif>
								</cfif>
							</cfif>
							ORDER BY Family_Name
						</cfquery>
						<cfparam name="form.Family_Name" default="0">
						<select name="Family_Name" id="Family_Name" onkeydown="if (event.keyCode == 13) doSearchNow();">
							<option value="0">**ALL** #application.returned_customer_setting.family_name_label_plural# </option>
							<cfloop query="GetFamilyNames">
								<option value="#trim(GetFamilyNames.Family_ID)#"
									<cfif trim(form.Family_Name) eq trim(GetFamilyNames.Family_ID)> selected </cfif>>
									#trim(GetFamilyNames.Family_Name)#
								</option>
							</cfloop>
						</select>
					</td>
					<cfinclude template="/billbacks/Search_screens/_incTrSeparator.cfm" />

				<!--------------------->
				<!---  Buying Group --->
				<!--------------------------------------------------------------------------------------------------------------------------------------------->
				<cfelseif qSearchFields.Field_Name eq "Buying Group">
					<td>
						<span class="searchItemLabel"> <strong>#application.returned_customer_setting.buying_group_label_plural#</strong> </span> <br>
						<cfquery name="GetBuyingGroups" datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Buying_Groups
							WHERE Deleted = 0
							<cfif form.businessSegmentsOn>
								<cfif Len(form.Business_Segment_ID) gt 0>
								and Business_Segment_ID IN (#form.Business_Segment_ID#)
								<cfelse>
									<cfif application.returned_customer_setting.Business_Segments_On eq 1>
										and 1 = 1
									<cfelse>
										and 1=2
									</cfif>
								</cfif>
							</cfif>
							ORDER BY Buying_Group_Name
						</cfquery>
						<cfparam name="form.Buying_Group" default="0">
						<select name="Buying_Group" id="Buying_Group" onkeydown="if (event.keyCode == 13) doSearchNow();">
							<option value="0">**ALL** #application.returned_customer_setting.buying_group_label_plural# </option>
							<cfloop query="GetBuyingGroups">
								<option value="#trim(GetBuyingGroups.Buying_Group_ID)#"
									<cfif trim(form.Buying_Group) eq trim(GetBuyingGroups.Buying_Group_ID)> selected </cfif> >
									#trim(GetBuyingGroups.Buying_Group_Name)#
								</option>
							</cfloop>
						</select>
					</td>
					<cfinclude template="/billbacks/Search_screens/_incTrSeparator.cfm" />

				<!-------------------->
				<!---  Customer ID --->
				<!--------------------------------------------------------------------------------------------------------------------------------------------->
				<cfelseif qSearchFields.Field_Name eq "Customer ID">
					<cfparam name="form.Cust_Id" default="0">
					<cfif appSettings.getcustid_on() eq 1>
						<td>
							<span class="searchItemLabel"> <strong>#application.returned_customer_setting.Customer_Id_Label#</strong> </span> <br>
							<cfquery name="GetCustIds" datasource="#application.datasource#">
								SELECT *
								FROM Distributor_Customer_ID
								WHERE Deleted = 0
								AND Custid_Name IS NOT NULL
								ORDER BY Custid_Name
							</cfquery>

							<select name="Cust_Id" id="Cust_Id" onkeydown="if (event.keyCode == 13) doSearchNow();">
								<option value="0"> **ALL** #application.returned_customer_setting.Customer_Id_Label# </option>
								<cfloop query="GetCustIds">
									<option value="#trim(GetCustIds.Customer_ID)#" <cfif trim(form.Cust_Id) eq trim(GetCustIds.Customer_ID)> selected </cfif> >
										#trim(GetCustIds.Custid_Name)#
									</option>
								</cfloop>
							</select>
						</td>
						<cfinclude template="/billbacks/Search_screens/_incTrSeparator.cfm" />
					</cfif>

				<!--------------------->
				<!---  Line of Biz --->
				<!--------------------------------------------------------------------------------------------------------------------------------------------->
				<cfelseif qSearchFields.Field_Name eq "Line Of Business">
					<cfset First_Time = NOT Isdefined("form.Line_Of_Biz")>
					<cfparam name="form.Line_Of_Biz" default="0">
					<cfif application.returned_customer_setting.lob_search_switch eq 1>
						<td>
							<span class="searchItemLabel"> <strong>#application.returned_customer_setting.lob_label_singular#</strong> </span> <br>
							<select name="Line_Of_Biz" id="Line_Of_Biz" onkeydown="if (event.keyCode == 13) doSearchNow();">
								<cfif GetLinesOfBiz.Recordcount eq 1>
									<option value="#trim(GetLinesOfBiz.Line_Of_Business_ID)#"
										<cfif trim(form.Line_Of_Biz) eq trim(GetLinesOfBiz.Line_Of_Business_ID)> selected </cfif>>
										#trim(GetLinesOfBiz.Line_Of_Business_Name)#
									</option>
								<cfelse>
									<option value="0"> **ALL** #application.returned_customer_setting.lob_label_plural# </option>
									<cfloop query="GetLinesOfBiz">
										<cfif Line_Of_Business eq "#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#" and First_Time>
											<cfset form.Line_Of_Biz = GetLinesOfBiz.Line_Of_Business_ID>
										</cfif>
										<option value="#trim(GetLinesOfBiz.Line_Of_Business_ID)#"
											<cfif trim(form.Line_Of_Biz) eq trim(GetLinesOfBiz.Line_Of_Business_ID)> selected </cfif>>
											#trim(GetLinesOfBiz.Line_Of_Business_Name)#
										</option>
									</cfloop>
								</cfif>
							</select>
						</td>
						<cfinclude template="/billbacks/Search_screens/_incTrSeparator.cfm" />
					</cfif>

				<!------------->
				<!---  Zone --->
				<!--------------------------------------------------------------------------------------------------------------------------------------------->
				<cfelseif qSearchFields.Field_Name eq "Zone">
					<td>
						<span class="searchItemLabel"> <strong>#application.returned_customer_setting.zone_label_singular#</strong> </span> <br>
						<cfquery name="GetZones" datasource="#application.datasource#">
							SELECT *
							FROM Service_Zones
							WHERE len(Zone_Name) != 0 AND Deleted = 0
							<cfif (businessSegManager.isEnabled()) and (appsettings.getPositionFieldsFilterOnProgramSegment()) and (form.Business_Segment_ID neq 0)>
								<cfif Len(form.Business_Segment_ID) gt 0>
									and Business_Segment_ID IN (#form.Business_Segment_ID#)
								</cfif>
							</cfif>
							ORDER BY Zone_Name
						</cfquery>
						<cfparam name="form.Zone_ID" default="0">
						<select name="Zone_ID" id="Zone_ID" onkeydown="if (event.keyCode == 13) doSearchNow();">
							<option value="0">**ALL** #application.returned_customer_setting.zone_label_plural# </option>
							<cfloop query="GetZones">
								<option value="#trim(GetZones.Service_Zone_ID)#" <cfif trim(form.Zone_ID) eq GetZones.Service_Zone_ID> selected </cfif>>
									#trim(GetZones.Zone_Name)#
								</option>
							</cfloop>
						</select>
					</td>
					<cfinclude template="/billbacks/Search_screens/_incTrSeparator.cfm" />

				<!--------------->
				<!---  Region --->
				<!--------------------------------------------------------------------------------------------------------------------------------------------->
				<cfelseif qSearchFields.Field_Name eq "Region">
					<td>
						<span class="searchItemLabel"> <strong>#application.returned_customer_setting.region_label_singular#</strong> </span> <br>
						<cfquery name="GetRegions" datasource="#application.datasource#">
							SELECT *
							FROM Service_Regions
							WHERE len(Region_Name) != 0 AND Deleted = 0
							<cfif (businessSegManager.isEnabled()) and (appsettings.getPositionFieldsFilterOnProgramSegment()) and (form.Business_Segment_ID neq 0)>
								<cfif Len(form.Business_Segment_ID) gt 0>
									and Business_Segment_ID IN (#form.Business_Segment_ID#)
								<cfelse>
									<cfif application.returned_customer_setting.Business_Segments_On eq 1>
										and 1 = 1
									<cfelse>
										and 1=2
									</cfif>
								</cfif>
							</cfif>
							ORDER BY Region_Name
						</cfquery>
						<cfparam name="form.Region_ID" default="0">
						<select name="Region_ID" id="Region_ID" onkeydown="if (event.keyCode == 13) doSearchNow();">
							<option value="0">**ALL** #application.returned_customer_setting.region_label_plural# </option>
							<cfloop query="GetRegions">
								<option value="#trim(GetRegions.Service_Region_ID)#" <cfif trim(form.Region_ID) eq getRegions.Service_Region_ID> selected </cfif>>
									#trim(GetRegions.Region_Name)#
								</option>
							</cfloop>
						</select>
					</td>
					<cfinclude template="/billbacks/Search_screens/_incTrSeparator.cfm" />

				<!--------------->
				<!---  Market --->
				<!--------------------------------------------------------------------------------------------------------------------------------------------->
				<cfelseif qSearchFields.Field_Name eq "Market">
					<!--- Get Foodservice Line Of Business ID --->
					<cfquery name="GetFirstDefaultBiz" dbtype="query">
						SELECT Line_Of_Business_ID
						FROM GetLinesOfBiz
						WHERE Line_Of_Business = '#trim(listfirst(application.returned_customer_setting.Line_Business_Default,","))#'
						UNION
						SELECT Line_Of_Business_ID
						FROM GetLinesOfBiz
						WHERE Line_Of_Business = '#ljustify(listfirst(application.returned_customer_setting.Line_Business_Default,","),10)#'
					</cfquery>
					<td>
						<!--- Brokers --->
						<span class="searchItemLabel"> <strong>#application.returned_customer_setting.broker_label_singular#</strong> </span> <br>
						<cfquery name="GetAllBrokers" datasource="#application.datasource#">
							SELECT DISTINCT Broker_Name
									<!--- find the brokers with the same name and collect the IDs --->
							       ,STUFF(( SELECT ',' + Cast(b.BSA_Foodservice_Brokers_ID AS VARCHAR(50))
							                  FROM BSA_Foodservice_Brokers b
							                 WHERE b.Broker_Name = BSA_Foodservice_Brokers.Broker_Name
							              FOR
							                XML PATH('') ), 1, 1, '') AS BSA_Foodservice_Brokers_ID
							FROM BSA_Foodservice_Brokers
							WHERE   Active_Code = 'A'
								AND Line_Of_Business_ID = '#GetFirstDefaultBiz.Line_Of_Business_ID#'
								AND deleted = 0
								<cfif (businessSegManager.isEnabled()) and (appsettings.getPositionFieldsFilterOnProgramSegment()) and (form.Business_Segment_ID neq 0)>
									<cfif Len(form.Business_Segment_ID) gt 0>
										and Business_Segment_ID IN (#form.Business_Segment_ID#)
									<cfelse>
										<cfif application.returned_customer_setting.Business_Segments_On eq 1>
											and 1 = 1
										<cfelse>
											and 1=2
										</cfif>
									</cfif>
								</cfif>
							ORDER BY Broker_Name
						</cfquery>

						<cfparam name="form.Broker" default="0">
						<select name="Broker" id="Broker" onkeydown="if (event.keyCode == 13) doSearchNow();">
							<option value="0">**ALL** #application.returned_customer_setting.broker_label_plural# </option>
							<cfloop query="GetAllBrokers">
								<option value="#trim(GetAllBrokers.BSA_Foodservice_Brokers_ID)#"
									<cfif trim(form.Broker) eq trim(GetAllBrokers.BSA_Foodservice_Brokers_ID)> selected </cfif>>
									#trim(GetAllBrokers.Broker_Name)#</option>
							</cfloop>
						</select>
					</td>
					<cfinclude template="/billbacks/Search_screens/_incTrSeparator.cfm" />

				<!----------------------->
				<!---  Planning Group --->
				<!--------------------------------------------------------------------------------------------------------------------------------------------->
				<cfelseif qSearchFields.Is_PG>
					<cfif showPlanningGroups>
						<cfif isDefined("GetTemplateInfo.First_Parent_ID")>
							<cfset FirstParentID = GetTemplateInfo.First_Parent_ID />
						<cfelse>
							<cfset FirstParentID = 0 />
						</cfif>
						<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />
						<cfset qGetTopLevelGroups = DistGroupDataManager.getDistributorLevels(
																					bActive = 1,
																					allowList = "",
																					disAllowList = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25",
																					Template_ID = "#FirstParentID#",
																					allowInSearch = 1
																					) />

						<cfloop query="qGetTopLevelGroups">
							<cfif qGetTopLevelGroups.Distributor_Group_Level_Id eq qSearchFields.Level_ID>
								<td>
									<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
									<cfset groupDropDownBusinessSegmentFilter = 0 />
									<cfif Is_PG and form.businessSegmentsOn>
										<cfset groupDropDownBusinessSegmentFilter = form.Business_Segment_Id />
									</cfif>

									<cfparam name="form.#DistributorAttributeDropDownName#" default="0">
									<cfmodule	template="/Customtags/DistributorGroupDropDown.cfm"
														groupLevelType = "#Distributor_Group_Level_Type_ID#"
														dropDownName = "#DistributorAttributeDropDownName#"
														selectedValue = "#evaluate("form.#DistributorAttributeDropDownName#")#"
														cachedwithin="#application.masterDataCacheSpan#"
														businessSegmentId="#groupDropDownBusinessSegmentFilter#"
														FirstParentID = "#FirstParentID#" />
								</td>
								<cfinclude template="/billbacks/Search_screens/_incTrSeparator.cfm" />
							</cfif>
						</cfloop>
					</cfif> <!--- Planning group display ends --->
					<cfinclude template="/billbacks/Search_screens/_incTrSeparator.cfm" />
				</cfif>
			</cfloop> <!--- qSearchFields --->
			</tr>

			<tr>
				<td colspan="4" class="sectionHead" style="padding-top: 20px">Owner</td>
			</tr>
			<tr>
				<!--------------------------------->
				<!--- Responsible Sales Person  --->
				<!--------------------------------------------------------------------------------------------------------------------------------------------->
				<td colspan="1" class="first">
					<cfquery name="qRsp" datasource="#application.datasource#">
						SELECT User_ID
								,Name_First
								,Name_Last
						  FROM _Users
						 WHERE Deleted = 0
								AND Name_Last <> 'unknown'
						ORDER BY Name_First, Name_Last
					</cfquery>
					<strong>Responsible Sales Person</strong> <br>
					<select name="responsible_user_id" id="responsible_user_id" style="width:96%">
						<option value=""></option>
						<cfloop query="qRsp">
							<option value="#qRsp.user_id#"
								<cfif qRsp.user_id eq form.responsible_user_id>selected</cfif>>
									#qRsp.name_first# #qRsp.name_last#
							</option>
						</cfloop>
					</select>
				</td>
				<td>
					<br>&nbsp;
					<b>
					<input type="checkbox" name="Pending_My_approval" id="Pending_My_approval" value="1"
						<cfif form.Pending_My_approval>checked</cfif> style="width:15px;vertical-align:top;">
					<label for="Pending_My_approval">Pending my approval</label>
					</b>
				</td>
				<td>
					<b>User Position</b><br>
					<!----------------------->
					<!--- User positions  --->
					<!----------------------->
					<cfset userPositionManager = CreateObject("component", "components.general.UserPositionManager").init()>
				    <cfset qUserPosition = userPositionManager.getUserPositions()>
					<select name="user_position" id="user_position">
						<option value="">All User Positions</option>
						<cfparam name="form.user_position" default="">
						<cfloop query="qUserPosition">
							<option value="#trim(qUserPosition.User_Positions_ID)#" <cfif form.user_position eq trim(qUserPosition.User_Positions_ID)>selected</cfif>>#trim(qUserPosition.Position_Label)#</option>
						</cfloop>
					</select>
				</td>
			</tr>

			<tr>
				<td colspan="4">
					<br>
					<a href="##" id="plannerSearch" class="primary" style="margin-right:40px"> #application.util.string.linkformat("search")#</a>
					<a href="##" id="reset" class="secondary"> #application.util.string.linkformat("reset")# </a>
				</td>
			</tr>
		</table>
	</cfsavecontent>
	#application.util.string.compress( variables.uncompressed )#
</form>
</cfoutput>



<script>
	$("#plannerSearch").click( function() {
		show_loader();
		$("#search_planners").submit();
	});

	$("#reset").click(function() {
		$("#search_planners").trigger("reset");
	});
</script>