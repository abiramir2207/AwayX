<!----------------------------------------------------------------------------------
Name         :  AwayX/Planners/Search/Planners_Search_Result.cfm
Copyright    :  (c) 2016 Blacksmith Applications, Inc.
Created Date :  23-May-2016
Created By   :  Anand Rao
Description  :  Search Planner - select planner then redirect to edit planner
---------------------------------------------------------------------------------->
<!DOCTYPE html>
<cfparam name="form.Planner"      default="">
<cfparam name="form.Planner_Template"    default="">
<cfparam name="form.Customer"         default="">
<cfparam name="form.Planner_Template_ID" default="">
<cfparam name="form.Responsible_User_Id" default="">
<cfparam name="form.Indirect_Customer"         default="">
<cfparam name="url.Planner_Status_ID"   default="">
<cfparam name="form.Planner_Status_ID"   default="#url.Planner_Status_ID#">
<cfparam name="form.BusinessSegment"     default="0">
<cfparam name="form.Business_Segment_Id" default="">
<cfparam name="form.businessSegmentsOn"  default="0">
<cfparam name="showPlanningGroups"       default="0">
<cfparam name="url.Display_Scorecard_Result"       default="0">
<cfparam name="url.Include_Indirect"   default="1">
<cfparam name="form.Include_Indirect"  default="#url.Include_Indirect#">
<cfparam name="form.include_direct"  default="1">
<cfparam name="form.Catalog_View"  default="0">
<cfparam name="form.product"  default="">

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfset userManager = CreateObject("component", "components.user.UserManager") />
<cfset oProfiles = CreateObject("component","components.settings.profiles.profile") />
<cfset plannerTemplateManager = CreateObject("component","mvc.Models.Planner.PlannerTemplateManager") />
<cfset qLabels = createObject("component", "components.settings.Labels.Labels").init() />
<cfset plannerSearchManager = CreateObject("component","mvc.Models.Planner.PlannerSearchManager") />

<cfset planner_labels   = qLabels.plannerLabels() />
<cfset plannerCustomerLabel         = planner_labels.Customer_Singular />
<cfset plannerCustomerLabelPlural   = planner_labels.Customer_Plural />
<cfset plannerIndirectLabel   		= planner_labels.Indirect_Singular />
<cfset qGetStatus					= plannerSearchManager.getPlannerStatus() />

<cfset This_User_Positions_ID = userManager.getPositionId(request.AccessStructure.User_ID, 1) />
<cfset Get_Profile_Settings = oProfiles.getAllProfiles(request.AccessStructure.Profiles_ID)>
<cfset stStruct = StructNew() />

<cfset stStruct.userPositionType = "P,S">
<cfset stStruct.sortBy = "Position_Level,User_Positions.Position_Label,_Users.Name_First" />
<cfset rspList = userManager.search(stStruct) />
<cfset templateList = plannerTemplateManager.getPlannerTemplates(status='1') />
<cfset this_user_id = request.AccessStructure.User_ID />

<cfset DistSearchSettingsManager = CreateObject("component", "components.settings.Labels.Labels") />
<cfset DistSearchSettings        = DistSearchSettingsManager.getDistributorStaticSearchFieldsActive() />
<cfset vars.qSearchField = DistSearchSettingsManager.getDistributorSearchFields()>
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
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabledForDistributor()>
	<cfif form.Business_Segment_ID eq "">
		<cfset form.businessSegmentsOn = 1 />
		<cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.User_ID) />
		<cfset form.Business_Segment_Id = ValueList(qGetBusSegments.Business_Segment_Id) />
	<cfelse>
		<cfset form.businessSegmentsOn = 1 />
	</cfif>
</cfif>
<!--- End if not pactiv --->
<cfif form.BusinessSegment neq "" and form.BusinessSegment neq "0">
	<cfset form.Business_Segment_Id = form.BusinessSegment />
</cfif>

<cfset maxColsPerRow = 4 />
<cfset currentColCount = 0/>

<html lang="en">
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta charset="utf-8">
        <title>Search Planner</title>
        <cfset jQuery.version = "1.12.4">
		<cfinclude template="/Common_Files/jQuery.cfm">
		<cfsavecontent variable="head_content">
			<cfset include_files = [    "/common_files/dataTables2.cfm"
										,"/script/javascript/dhtmlx/scheduler/codebase/dhtmlxscheduler.js"
										,"/common_files/datatable2.css"
										,"/Script/javascript/jquery.dataTables-api.js"
										,"/script/javascript/dhtmlx/skins/terrace/dhtmlx.css"
                                        ,"/styles/css-loader.css"
                                        ,"/script/javascript/table2csv.js"
									]>
			<cf_include files=#arrayToList( include_files )#>
			<cfset jQueryUI.widgets = "accordion, tooltip">
			<!--- <cfinclude template="/common_files/jQueryUI.cfm"> --->

			<style type="text/css">
				.sectionHead
				{
					font-weight:bold;
					font-size:15px;
					color:red;
					letter-spacing: 1px;
					text-shadow: 4px 4px 4px #AAA;
					padding-top2: 20px;
					border-bottom:1px solid #0000CD;
					border-bottom:1px solid #EEE;
				}

				table#t413 { table-layout:fixed; }
				table#t413 tr { line-height: 22px; }
				table#t413 td.first, table#t413 td:nth-child(1) { padding-left:2%; }
				table#t413 input, table#t413 select { width:90%; }
				.full { width: 90%; }
				.half { width:110px; }
				a#createlist13 { margin-left: 15px; }
				td.right, .right { text-align: right !important; }
				.left { text-align: left !important; }

/*				#datagrid { margin-top:15px; }
				.datagrid thead tr th {background-color:#9BC2E6;}
				.datagrid tbody tr.even { background-color:#EEE; }
*/
				#generictypefilter { width:225px; }
				.ui-accordion-header { text-align:left; font-weight:bold; font-size:11px;
										background-color:#9BC2E6;
			                            background-image: -webkit-linear-gradient(#9BC2E6, #d8e7f5) !important;
			                            background-image: -o-linear-gradient(#9BC2E6, #d8e7f5) !important;
			                            background-image: linear-gradient(#9BC2E6, #d8e7f5) !important;
										border:1px solid #A5A5A5; color:#333;
				}
				.ui-state-default2 { background:#9BC2E6;
		                            background-image: -webkit-linear-gradient(#9BC2E6, #d8e7f5) !important;
		                            background-image: -o-linear-gradient(#9BC2E6, #d8e7f5) !important;
		                            background-image: linear-gradient(#9BC2E6, #d8e7f5) !important;
				}

				#feedback { font-size: 1.4em; }
				#selectable .ui-selecting { background: #FECA40; }
				#selectable .ui-selected { background: #F39814; color: white; }
				#selectable { list-style-type: none; margin: 0; padding: 0; width: 450px; }
				#selectable li { margin: 3px; padding: 1px; float: left; width: 100px; height: 80px; font-size: 4em; text-align: center; }
				fieldset { text-align:center; font-weight:bold; font-size:12px; border:2px solid black; height:75px; width:90%; padding:10px; }
				h3 { letter-spacing: 0.75px; }
				div.delplnrs { display:inline-block; margin-left:25px; position:relative; top:-2px; font-size:12px; }
				th:nth-child(8) { text-align: left !important; }
				label { cursor: pointer; }
                /* label.dropdown { display: inline-block; width: 115px; } */
                h3.search, h3.result {
                    font-weight: bold;
                    font-size: 1.35em !important;
                }
                table#t413 {
                    width: 700px;
                    border: 0;
                }
                td.direct {
                    font-weight: bold !important;
                }
                tr.direct {
                    background-color: blue !important;
                }
                td.center {
                    text-align: center;
                }
                img.info {
                    position: relative;
                    top: 1px;
                }
                td.cursor, span.cursor {
                    cursor: pointer;
					color: blue;
                }
                a#export {
                    margin-left: 15px;
                }
                i.ui-icon {
                    top: 0;
                }
			</style>
		</cfsavecontent>
		<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
		<cfhtmlhead text="#application.util.string.compress( head_content )#">
	</head>

	<body>
		<!--------------------------------------------------------------------------------------------------------------------->
		<cfset pagetitle = "Search #Application.PlannerLabel#">

        <!--- export to csv form --->
        <form action="/common_files/csv.cfm" method ="post" id="csv_form" name="csv">
            <input type="hidden" name="csv_text" id="csv_text">
            <input type="hidden" name="csv_file_name">
        </form>

        <form method="post" name="plannerSearchForm" id="plannerSearchForm" action="">
            <input type="hidden" name="method" value="searchPlanners">

			<!--- // accordian --->
			<div id="accordion">
				<!--- **************************************************** search tab **************************************************** --->
				<h3 class="search">Search Criteria</h3>
				<div id="search" style="padding:0 25px;">
					<cfoutput>
						<cfsavecontent variable="variables.uncompressed">
							<table cellspacing="2"  cellpadding="2" id="t413">
								<col width="20%">
								<col width="50%">
								<col width="30%">
								<tr>
									<td></td>
									<td>Name or ID</td>
								</tr>
								<tr>
									<td>#Application.PlannerLabel#:</td>
									<td><input type="text" name="Planner" id="Planner" value="#form.Planner#" class="full">
								</tr>
								<tr>
									<td>#Application.PlannerPrgLabel#:</td>
									<td><input type="text" name="Program" id="Program" value="" class="full">
								</tr>
								<tr>
									<td>#plannerCustomerLabel#:</td>
									<td><input type="text" name="Customer" id="Customer" value="#form.Customer#" class="half"></td>
								</tr>
								<tr>
									<td>Product:</td>
									<td><input type="text" name="Product" value="#form.product#" class="half"></td>
								</tr>

								<tr>
									<td>#plannerIndirectLabel#:</td>
									<td><input type="text" name="Indirect_Customer" id="Indirect_Customer" value="" class="half"></td>
									<td>
                                        <b>
                                        <input type="checkbox" name="Include_Indirect" id="Include_Indirect" value="1" <cfif form.Include_Indirect>checked</cfif> style="width:15px;vertical-align:top;">
                                        <label for="Include_Indirect">#plannerIndirectLabel#</label>
                                        <label><input type="checkbox" name="include_direct" value="1" <cfif form.include_direct>checked</cfif> style="width:15px;vertical-align:top;"> Direct</label>
                                        </b>
									</td>
								</tr>

								<tr>
									<td>&nbsp;</td>
								</tr>

                                <tr>
                                    <td>
                                        Templates
                                    </td>
									<td colspan="2">
                                        <select name="Planner_Template"  id="Planner_Template" class="full multi" multiple="multiple" place_holder="Show All Templates">
											<!--- <option value="">Show All Templates</option> --->
											<cfloop query="templateList">
												<option value="#templateList.Planner_Template_ID#" <cfif form.Planner_Template_ID eq templateList.Planner_Template_ID> selected </cfif>>
													#templateList.Planner_Type#
												</option>
											</cfloop>
										</select>
									</td>
								</tr>


                                <tr>
                                    <td>
                                        Status
                                    </td>
									<td colspan="2">
										<select name="Planner_Status"  id="Planner_Status" class="full multi" multiple="multiple" place_holder="Show All Statuses">
											<!--- <option value="">Show All Status</option> --->
											<cfloop query="qGetStatus">
												<option value="#qGetStatus.Use_Status_ID#" <cfif form.Planner_Status_ID eq qGetStatus.Use_Status_ID> selected </cfif>>
													#qGetStatus.Status_Description#
												</option>
											</cfloop>
										</select>
									</td>
								</tr>


								<cfloop query="vars.qSearchField">
										<!-------------------------------------------------------- Family ------------------------------------------------------------>
									<cfif vars.qSearchField.Field_Name eq "Family">
                                        <tr>
                                            <td>
                                                #application.returned_customer_setting.family_name_label_plural#
                                            </td>
                                            <td colspan="2">
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
													AND		EXISTS (
														SELECT	1
														FROM	BSA_Foodservice_Customers c
														WHERE	c.Family_ID = Distributor_Family.Family_ID
														AND		c.Retail_Customer = 1
													)
                                                    ORDER BY Family_Name
                                                </cfquery>
                                                <cfparam name="form.Family" default="0">
                                                <select name="Family" id="Family" class="multi" multiple="multiple" place_holder="Show All #application.returned_customer_setting.family_name_label_plural#">
                                                    <!--- <option value="0">Show All #application.returned_customer_setting.family_name_label_plural# </option> --->
                                                    <cfloop query="GetFamilyNames">
                                                        <option value="#trim(GetFamilyNames.Family_ID)#" <cfif trim(form.Family) eq trim(GetFamilyNames.Family_ID)> selected </cfif>>
                                                            #trim(GetFamilyNames.Family_Name)#
                                                        </option>
                                                    </cfloop>
                                                </select>
                                            </td>
										</tr>

										<!-------------------------------------------------------- Buying Group ------------------------------------------------------>
									<cfelseif vars.qSearchField.Field_Name eq "Buying Group">
                                        <tr>
                                            <td>
                                                #application.returned_customer_setting.buying_group_label_plural#
                                            </td>
                                            <td colspan="3">
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
                                                <select name="Buying_Group" id="Buying_Group" class="multi" multiple="multiple" place_holder="Show All #application.returned_customer_setting.buying_group_label_plural#">
                                                    <!--- <option value="0">Show All #application.returned_customer_setting.buying_group_label_plural# </option> --->
                                                    <cfloop query="GetBuyingGroups">
                                                        <option value="#trim(GetBuyingGroups.Buying_Group_ID)#" <cfif trim(form.Buying_Group) eq trim(GetBuyingGroups.Buying_Group_ID)> selected </cfif> >
                                                            #trim(GetBuyingGroups.Buying_Group_Name)#
                                                        </option>
                                                    </cfloop>
                                                </select>
                                            </td>
										</tr>

										<!-------------------------------------------------------- Customer ID ------------------------------------------------------->
									<cfelseif vars.qSearchField.Field_Name eq "Customer ID">
										<cfparam name="form.Cust_Id" default="0">
										<cfif appSettings.getcustid_on() eq 1>
                                        <tr>
                                            <td>
                                                #application.returned_customer_setting.Customer_Id_Label#
                                            </td>
                                            <td colspan="2">
                                                    <cfset useLakebaseForGetCustIds = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_customer_id")>
<cfif useLakebaseForGetCustIds>
	<cftry>
		<cfset GetCustIds = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_customer_id", {
				"deleted" = "eq.0",
				"custid_name" = "not.is.null",
				"order" = "custid_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCustIds = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCustIds>
<cfquery name="GetCustIds" datasource="#application.datasource#">
                                                        SELECT *
                                                        FROM Distributor_Customer_ID
                                                        WHERE Deleted = 0
                                                        AND Custid_Name IS NOT NULL
                                                        ORDER BY Custid_Name
                                                    </cfquery>
</cfif>

                                                    <select name="Cust_Id" id="Cust_Id" class="multi" multiple="multiple" place_holder="Show All #application.returned_customer_setting.Customer_Id_Label#">
                                                        <!--- <option value="0">Show All #application.returned_customer_setting.Customer_Id_Label# </option> --->
                                                        <cfloop query="GetCustIds">
                                                            <option value="#trim(GetCustIds.Customer_ID)#" <cfif trim(form.Cust_Id) eq trim(GetCustIds.Customer_ID)> selected </cfif> >
                                                                #trim(GetCustIds.Custid_Name)#
                                                            </option>
                                                        </cfloop>
                                                    </select>
                                                </td>
                                            </tr>
										</cfif>

										<!-------------------------------------------------------- Line Of Biz ------------------------------------------------------->
									<cfelseif vars.qSearchField.Field_Name eq "Line Of Business">
										<cfset First_Time = NOT Isdefined("form.Line_Of_Biz")>
										<cfparam name="form.Line_Of_Biz" default="0">
										<cfif application.returned_customer_setting.lob_search_switch eq 1>
                                            <tr>
                                                <td>
                                                    Line of Biz
                                                </td>
                                                <td colspan="2">
                                                    <select name="Line_Of_Biz" id="Line_Of_Biz" class="multi" multiple="multiple" place_holder="Show All Line of Biz">
                                                        <cfif GetLinesOfBiz.Recordcount eq 1>
                                                            <option value="#trim(GetLinesOfBiz.Line_Of_Business_ID)#" <cfif trim(form.Line_Of_Biz) eq trim(GetLinesOfBiz.Line_Of_Business_ID)> selected </cfif>>
                                                                #trim(GetLinesOfBiz.Line_Of_Business_Name)#
                                                            </option>
                                                        <cfelse>
                                                            <option value="0">Show All #application.returned_customer_setting.lob_label_plural# </option>
                                                            <cfloop query="GetLinesOfBiz">
                                                                <cfif Line_Of_Business eq "#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#" and First_Time>
                                                                    <cfset form.Line_Of_Biz = GetLinesOfBiz.Line_Of_Business_ID>
                                                                </cfif>
                                                                <option value="#trim(GetLinesOfBiz.Line_Of_Business_ID)#" <cfif trim(form.Line_Of_Biz) eq trim(GetLinesOfBiz.Line_Of_Business_ID)> selected </cfif>>
                                                                    #trim(GetLinesOfBiz.Line_Of_Business_Name)#
                                                                </option>
                                                            </cfloop>
                                                        </cfif>
                                                    </select>
                                                </td>
										</tr>
										</cfif>

										<!-------------------------------------------------------- Zone -------------------------------------------------------------->
									<cfelseif vars.qSearchField.Field_Name eq "Zone" and application.datasource neq "butterball">
                                        <tr>
                                            <td>
                                                #application.returned_customer_setting.zone_label_plural#
                                            </td>
											<td colspan="2">
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
											<select name="Zone_ID" id="Zone_ID" class="multi" multiple="multiple" place_holder="Show All #application.returned_customer_setting.zone_label_plural#">
												<!--- <option value="0">Show All #application.returned_customer_setting.zone_label_plural# </option> --->
												<cfloop query="GetZones">
													<option value="#trim(GetZones.Service_Zone_ID)#" <cfif trim(form.Zone_ID) eq GetZones.Service_Zone_ID> selected </cfif>>
														#trim(GetZones.Zone_Name)#
													</option>
												</cfloop>
											</select>
										</td>
										</tr>

										<!-------------------------------------------------------- Region ------------------------------------------------------------>
									<cfelseif vars.qSearchField.Field_Name eq "Region">
                                        <tr>
                                            <td>
                                                #application.returned_customer_setting.region_label_plural#
                                            </td>
											<td colspan="2">
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
											<select name="Region_ID" id="Region_ID" class="multi" multiple="multiple" place_holder="Show All #application.returned_customer_setting.region_label_plural#">
												<!--- <option value="0">Show All #application.returned_customer_setting.region_label_plural# </option> --->
												<cfloop query="GetRegions">
													<option value="#trim(GetRegions.Service_Region_ID)#" <cfif trim(form.Region_ID) eq getRegions.Service_Region_ID> selected </cfif>>
														#trim(GetRegions.Region_Name)#
													</option>
												</cfloop>
											</select>
										</td>
										</tr>

										<!-------------------------------------------------------- Market ------------------------------------------------------------>
									<cfelseif vars.qSearchField.Field_Name eq "Market">
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
                                        <tr>
                                            <td>
                                                #application.returned_customer_setting.broker_label_plural#
                                            </td>
											<td colspan="2">
											<!--- Brokers --->
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
											<select name="Broker" id="Broker" class="multi" multiple="multiple" place_holder="Show All #application.returned_customer_setting.broker_label_plural#">
												<!--- <option value="0">Show All #application.returned_customer_setting.broker_label_plural# </option> --->
												<cfloop query="GetAllBrokers">
													<option value="#trim(GetAllBrokers.BSA_Foodservice_Brokers_ID)#" <cfif trim(form.Broker) eq trim(GetAllBrokers.BSA_Foodservice_Brokers_ID)> selected </cfif>>#trim(GetAllBrokers.Broker_Name)#</option>
												</cfloop>
											</select>
										</td>
										</tr>

										<!-------------------------------------------------------- Planning Group ---------------------------------------------------->
									<cfelseif vars.qSearchField.Is_PG>
										<cfif showPlanningGroups>
											<cfif isDefined("GetTemplateInfo.First_Parent_ID")>
												<cfset FirstParentID = GetTemplateInfo.First_Parent_ID />
											<cfelse>
												<cfset FirstParentID = 0 />
											</cfif>
											<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />
											<cfset qGetTopLevelGroups = DistGroupDataManager.getDistributorLevels(
																										bActive = 1,
																										allowList = vars.qSearchField.Distributor_Group_Level_Id,
																										Template_ID = "#FirstParentID#",
																										allowInSearch = 1
																										) />

											<cfloop query="qGetTopLevelGroups">
												<cfif qGetTopLevelGroups.Distributor_Group_Level_Id eq vars.qSearchField.Distributor_Group_Level_Id>
													<cfset DistributorGroupAttributeManager = CreateObject("component", "components.customer.group.DistributorGroupAttributeManager").init() />
													<cfset stGetGroupAttributeInfo = DistributorGroupAttributeManager.getGroupAttributeInfo(groupLevelTypeId = Distributor_Group_Level_Type_ID) />
													<cfset groupDropDownBusinessSegmentFilter = 0 />
													<cfif Is_PG and form.businessSegmentsOn>
														<cfset groupDropDownBusinessSegmentFilter = form.Business_Segment_Id />
													</cfif>

													<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
													<cfparam name="form.#DistributorAttributeDropDownName#" default="0">
													<cfset selectedValue = evaluate("form.#DistributorAttributeDropDownName#") />
													<cfset GetGroupValues = DistributorGroupAttributeManager.getDistributorGroupValues(
																			DistributorGroupAttributeInfo 	= stGetGroupAttributeInfo,
																			businessSegmentId				= groupDropDownBusinessSegmentFilter,
																			cachedwithin					= application.masterDataCacheSpan,
																			TemplateID            			= FirstParentID)
															/>
                                                    <tr>
                                                        <td>
                                                            #stGetGroupAttributeInfo.Label#
                                                        </td>
                                                        <td colspan="2">
                                                            <select name="#DistributorAttributeDropDownName#" id="#DistributorAttributeDropDownName#" class="multi" multiple="multiple" place_holder="Show All #stGetGroupAttributeInfo.Label#">
                                                                <!--- <option value="0">Show All #stGetGroupAttributeInfo.Label#</option> --->
                                                                <cfloop query="GetGroupValues"><OPTION VALUE="#Group_ID#"<cfif selectedValue EQ Group_ID> SELECTED</cfif>>#Group_Name#</OPTION></cfloop>
                                                            </select>
                                                        </td>
													</tr>
												</cfif>
											</cfloop>
										</cfif> <!--- Planning group display ends --->
									</cfif>
								</cfloop> <!--- vars.qSearchField --->

                                <tr>
                                    <td>
                                        RSP
                                    </td>
									<td colspan="2">
										<cfquery name="qRsp" datasource="#application.datasource#">
											SELECT User_ID
												,Name_First
												,Name_Last
											FROM dbo._Users
											WHERE Deleted = 0
												AND Name_Last <> 'unknown'
											ORDER BY
												Name_First
											,Name_Last
                                        </cfquery>
										<select name="responsible_user_id" id="responsible_user_id" class="multi" multiple="multiple" place_holder="Show All RSPs">
											<!--- <option value="">Show All Responsible Sales Person</option> --->
											<cfloop query="qRsp">
												<option value="#qRsp.user_id#" <cfif listFindNoCase(form.responsible_user_id, qRsp.user_id)>selected</cfif>>
													#qRsp.name_first# #qRsp.name_last#
												</option>
											</cfloop>
										</select>
									</td>
								</tr>
                                <tr>
                                    <td>
                                        User Position
                                    </td>
									<td colspan="2">
										<cfset userPositionManager = CreateObject("component", "components.general.UserPositionManager").init()>
                                        <cfset qUserPosition = userPositionManager.getUserPositions()>
										<select name="user_position" id="user_position" class="multi" multiple="multiple" place_holder="Show All User Positions">
											<!--- <option value="">Show All User Positions</option> --->
											<cfparam name="form.user_position" default="">
											<cfloop query="qUserPosition">
                								<option value="#trim(qUserPosition.User_Positions_ID)#" <cfif form.user_position eq trim(qUserPosition.User_Positions_ID)>selected</cfif>>#trim(qUserPosition.Position_Label)#</option>
											</cfloop>
										</select>
									</td>
								</tr>

								<tr>
									<td></td>
								</tr>

								<tr>
									<td>Data view:</td>
									<td>
										<input type="radio" name="Catalog_View" id="Catalog_View_0" value="0" <cfif form.Catalog_View eq 0>checked</cfif> style="width:15px;vertical-align:top;">
										<label for="Catalog_View_0">#Application.PlannerLabel#</label>
										<input type="radio" name="Catalog_View" id="Catalog_View_1" value="1" <cfif form.Catalog_View eq 1>checked</cfif> style="width:15px;vertical-align:top;">
										<label for="Catalog_View_1">Catalog</label>
									</td>
								</tr>

								<tr>
									<td colspan="3">
										<br>
										<a href="##" id="plannerSearch" class="primary" style="margin-right:40px"> #application.util.string.linkformat("search")#</a>
										<a href="##" id="reset" class="secondary"> #application.util.string.linkformat("reset")# </a>
									</td>
								</tr>


							</table>
						</cfsavecontent>
						#application.util.string.compress( variables.uncompressed )#
					</cfoutput>
				</div> <!--- search tab --->

				<!--- **************************************************** results **************************************************** --->
				<h3 class="result"> Results </h3>
				<div id="result">
					<!--- <table class="datagrid" id="datagrid"  style='table-layout:float'> --->
					<table class="dataTable row-border order-column hover datagrid" id="datagrid" width="100%">
						<!--- data inserted here by data grid below --->
						<tbody> </tbody>
					</table>
				</div>  <!--- results tab --->
            </div>  <!--- // accordian --->

            <input type="hidden" name="RSP_ID">
            <input type="hidden" name="currentTime" value="<cfoutput>#timeFormat(now(), 'hhmmssl')#</cfoutput>">
		</form>

		<form name="load_planner" method="post">
			<input type="hidden" name="plannerID">
			<input type="hidden" name="mode">
			<input type="hidden" name="page_creating" value="1">
		</form>

		<cfsavecontent variable="delplnrs"><cfoutput><a id=delplnrs title=\"click to delete #Application.PlannerLabel_Plural#\" class=hand>#application.util.string.linkFormat("delete #Application.PlannerLabel_Plural#")#</a><a id=export class=hand title=\"click to export to csv format\">#application.util.string.linkFormat("export to csv")#</a></cfoutput></cfsavecontent>

		<script>
			$(function(){
				var oTable2 = 0;
				$( "#accordion" ).accordion({ heightStyle: "content" }); // accordian

                    Load_Planner_Search_Results = function() {

                    $("input[name=method]").val( "searchPlanners" );
                    $("input[name=RSP_ID]").val( $("select[name=responsible_user_id]" ).val() );

                    String.prototype.trunc = function( n, useWordBoundary ){
                                                if (this.length <= n) {
                                                    return this;
                                                }
                                                let subString = this.substr(0, n-1);
                                                return (useWordBoundary
                                                            ? subString.substr(0, subString.lastIndexOf(' '))
                                                            : subString)
                                                        + "&hellip;";
                                            };

                    function shorten_text(data, size) {
                        let result = data.trunc(size, true);
                        return result.length == data.length
                                  ? result
                                  : '<span title="' + data + '">' + result + '</span>';
                    }

                    $("form[name=plannerSearchForm] input").each(function(){
                        $(this).val( $(this).val().trim() );
                    });

					// JSON.DATA array of array - column mapping
					const JSON = { rfa:58, under_review:59, pending_approval:60, agreed:61 };
					$.ajax({
                        url: '/mvc/Models/Planner/PlannerSearchManager.cfc',
                        dataType: "json",
                        type: "POST",
                        data: $("form[name=plannerSearchForm] select,form[name=plannerSearchForm] input").serialize(),
						success: function(mydata){
							$(".result").removeClass( "ui-state-disabled" );
							$("#accordion").accordion({ active: $('#accordion h3').index($('.result')) });
							if ( $.fn.dataTable.isDataTable( '#datagrid' ) ) {
								oTable2.destroy();
							}
							$("div.loader").remove();
							oTable2 =  $('#datagrid').removeAttr('width').DataTable({
                                "aaSorting": [],
                                "autoWidth": false,
								"data": mydata.DATA,
								"paging": false,
								"processing":true,
								"orderClasses": true,
								"ScrollCollapse": true,
								scrollY: (window.innerHeight > 768 ? "77vh" : "67vh"),
								"sDom": 'f<"delplnrs">ti',
								columnDefs: [
									{targets:0, visible:true, title:" ", sortable:false, className:"left nocsv", render: cb_format },
									{targets:1, sortable:true, title:"<cfoutput>#Application.PlannerLabel#</cfoutput> ID", visible:true, className:"left cursor planner", render: PlannerId_format, width:100},
									{targets:2, sortable:true, title:"<cfoutput>#Application.PlannerLabel#</cfoutput> Title", visible:true, className:"left", width: 200,
                                        render: function ( data, type, row ) { return row[2] } },
                                    {targets:3, sortable:true, title:"D/I", visible:true, className:"center",
                                        render: function ( data, type, row ) {  return row[46] > 0 ? 'I' : 'D' } },
									{targets:4, sortable:true, title:"<cfoutput>#Application.PlannerLabel#</cfoutput> Type", visible:true, className:"left", width: 150,
                                        render: function ( data, type, row ) { return row[3] } },
									{targets:5, sortable:true, title:"Start Date", visible:true, className:"center",
                                        render: function ( data, type, row ) { return row[4] } },
									{targets:6, sortable:true, title:"End Date", visible:true, className:"center",
                                        render: function ( data, type, row ) { return row[5] } },
									{targets:7, sortable:true, title:"Grp?", visible:true, className:"center",
										render: function ( data, type, row ) { return row[36] } },
									{targets:8, sortable:true, title:"<cfoutput>#Application.PlannerPrgLabel#</cfoutput>", visible:true, className:"center", width: 50,
                                        render: function ( data, type, row ) {
                                                                                return (row[46] > 0 || row[55] == 0)
                                                                                        ? row[37]
                                                                                        : row[37] + ' | ' + ( row[54] + row[37] ) + ' <img class="info" src="/images/info.png" height="12" width="12" title="When a template has been flagged as Wholesaler, then the Direct Planners will display the count for just the Direct #Application.PlannerLabel# followed by the total #Application.PlannerPrgLabel# count for the Direct and Indirect combined.">'} },

// ngt
									<cfset display_all_rfa = ( get_profile_settings.RFA_Agreed eq 0 )>
									<cfoutput>
									{ targets:9, sortable:<cfoutput>#( display_all_rfa ? true : false )#</cfoutput>, title:"RFA", visible:true, className:"center cursor planner", width:90,
                                        render: function ( data, type, row ) {
																				<cfif display_all_rfa>
																					return rfa_format( row[ JSON.rfa ], "RFA", row );
																				<cfelse>
																					return rfa_format( row[ JSON.rfa ], "RFA", row );
																				</cfif>
																				} },
									</cfoutput>

									{targets:10, sortable:true, title:"Status", visible:true, className:"center",
                                        render: function ( data, type, row ) { return row[8] } },
									{targets:11, sortable:true, title:"RSP", visible:true, className:"center",
										render: function ( data, type, row ) { return row[41] } },
									{targets:12, sortable:true, title:"RSP Position", visible:true, className:"left",
										render: function ( data, type, row ) {
                                                    return row[42];
                                                } },
									{targets:13, sortable:true, title:"Wholesaler", visible:false, className:"left",
										render: function ( data, type, row ) { return row[45] } },
									{targets:'_all', visible:false, sortable:false}
                                ],
                                rowCallback: function(row, data, index) {
                                                                            if (data[53].indexOf('-9999999999') > -1 && data[45]) {
                                                                                $("td", row).addClass("direct");
                                                                            }
                                                                            if (data[46]) {
                                                                                $("td:eq(1)", row).addClass("right");
                                                                            }
                                                                        }
							}); // DataTable
                            $("div.delplnrs").html( <cfoutput>"#delplnrs#"</cfoutput> );

							function rfa_format( count, css, row ) {
								let css_class = count ? " class='cursor " + css + "'" : '';
								let is_direct = row[46] > 0 ? false : true;
								let message   = is_direct
													? "\nThe count of Indirect RFA&apos;s are not included in the Direct Plan level.\nThe count is shown at the Indirect Plan level."
													: '';
								return "<span title='RFA Programs: " + message + "'" + css_class + ">" + count + "</span>";
							}

                            $("#export").click(function() {
                                $('input[name=csv_file_name]').val( "planner-result-"
                                                                    + <cfoutput>"#dateFormat(now(), "mm-dd-yyyy")#-"</cfoutput>
                                                                    + random367()    // append an arbitrary unique substring
                                                                    + ".csv");
                                var csv_value=$("#datagrid").table2CSV({ delivery:"value", sScrollY:999, csvExclude:'nocsv' });
                                $("#csv_text").val(csv_value);
                                $("#csv_form").submit();
                            });


							//delete planners
							$('#delplnrs').on( 'click', function () {
								var msg = "";
								var selected = [];
								var selected_wholesale = [];

								$('input[id^="plannerId"]:checkbox:checked').each(function() {
									selected.push($(this).val());
									if($(this).attr('whsplnr') == "true"){
										selected_wholesale.push($(this).val());
									}
								});
								if ( selected.length == 0 ) {
									dhtmlx.alert( "Please select at least one <cfoutput>#Application.PlannerLabel#</cfoutput> to delete." );
									return false;
								}
								else {
									msg = "You have selected (" + selected.length + ") <cfoutput>#Application.PlannerLabel#</cfoutput>" + (selected.length > 1 ? "s" : "");
									if ( selected_wholesale.length > 0 ) {
										msg = msg + " including <br> (" + selected_wholesale.length + ") Wholesaler <cfoutput>#Application.PlannerLabel#</cfoutput>" + (selected_wholesale.length > 1 ? "s" : "");
										msg = msg + "<br><br>" + "Deleting a Wholesaler <cfoutput>#Application.PlannerLabel#</cfoutput> will also delete all of the associated Indirect planners";
									};
									msg = msg + "<br><br>" + "Continue and delete?";
									// confirm delete
									dhtmlx.confirm({
										title:"Delete <cfoutput>#Application.PlannerLabel_Plural#</cfoutput>",
										type:"confirm-error",
										text: msg,
										callback:function(response){
											if(response){
												show_loader();
												$.getJSON(
													'/mvc/Models/Planner/PlannerSearchManager.cfc',
													{
														method       : "deletePlanners",
														plannerList  : selected.join(","),
														returnformat : "json"
													},
													// success
													function(mydata){
														// $("#accordion").accordion({ active: $('#accordion h3').index($('.search')) });
													} // success
												); // $.getJSON
												location.reload();
											} // if(response)
										} // callback function
									}); // dhtmlx.confirm
								}; // else
							});
						} // success
                    }); // $.getJSON
                }// Load_Planner_Search_Results

				$('#plannerSearch').on( 'click', function () {
					show_loader( "SEARCHING FOR <cfoutput>#UCase( Application.PlannerLabel_Plural )#</cfoutput>..." );
					Load_Planner_Search_Results();
				}); // plannerSearch

				// click planner ID cells or RFA cells
				$('#datagrid tbody')
					.on( 'click', 'td.planner, span.rfa, span.under_review, span.pending_approval, span.agreed', function() {
							let parent_tr     = $( this ).closest( "tr" )[ 0 ];
							let planner_id    = oTable2.cell( parent_tr, 0 ).data();
							let planner_title = oTable2.cell( parent_tr, 1 ).data();

							$("input[name=plannerID]").val( planner_id );
							$("input[name=mode]").val( 'E' );

							let url = "planner_scorecard.cfm?";

							// user clicked on rfa cell
							if ( $( this ).hasClass( "rfa" ) ) {
								url = url + "rfa=999&";
							}
							else if ( $( this ).hasClass( "under_review" ) ) {
								url = url + "rfa=101&";
							}
							else if ( $( this ).hasClass( "pending_approval" ) ) {
								url = url + "rfa=102&";
							}
							else if ( $( this ).hasClass( "agreed" ) ) {
								url = url + "rfa=103&";
							}
							// user clicked on wip planner
							else if ( oTable2.cell( parent_tr, 8 ).data() == "WIP" ) {
								url = "planner_calendar.cfm?"
							}

							url = "/planners/create/" + url + "clearCache=1";
							parent.load_planner( planner_title, planner_id, url );
						})
					.on( 'hover', 'tr', function() { $(this).toggleClass("over2").toggleClass("hand"); }); // hover


				//click reset
				$('#reset').on( 'click', function () {
					$("#plannerSearchForm").trigger("reset");
                    $("#plannerSearchForm").find("input[type=hidden]").val("");
                    $(".ui-multiselect-filter-label input").val("");
                    $("a.ui-multiselect-none").click();
				});


				cb_format = function(data, type, row) {
					return (row[12] ? '' : "<input type='checkbox' id='plannerId_" + row[0] + "' whsplnr='" + row[45] + "'  class='hand'" + " value='" + row[0] + "'>");
				}

                PlannerId_format = function(data, type, row) {
    				if ( !row[38] && !row[43] ) {
						return row[1]; // Not User Locked & Not System locked
					}
					else {
						var imgSrc = "/Images/iconmonstr-lock-1-24.png";
					    <cfoutput>
						if (row[40] == "#this_user_id#") {
					    	imgSrc = "/Images/iconmonstr-pencil-10-24.png";
						}
					    </cfoutput>
						return "<span title='Locked by " + ( row[43] ? 'System' : row[39] ) + "'>"
									+ row[1]
									+ "&nbsp; <img style='width:10px;height:10px;' src='" + imgSrc + "' style='vertical-align:bottom;'> &nbsp;"
									+ "</span>";
					}
				}

                <cfif url.Display_Scorecard_Result eq "1">
                Load_Planner_Search_Results();
                </cfif>

                $("input[type=text]").keypress(function (e) {
  					if (e.which == 13) {
    					show_loader();
    					Load_Planner_Search_Results();
  					}
				});
			}); // function
		</script>

        <cfinclude template="/common_files/multiselect.cfm">

        <script>
            let multi_select_min_rows_filter = <cfoutput>#val(application.util.query.get_setting("multi_select_min_rows_filter", 0))#</cfoutput>;
            if (multi_select_min_rows_filter == 0) {
                multi_select_min_rows_filter = 10;
            }
            config.multiselect.buttonWidth = 420;
            config.multiselect.selectedList = 3;
            $("select.multi").each(function() {
                config.multiselect.noneSelectedText = $(this).attr("place_holder");
                if (config.multiselect.noneSelectedText) {
                }
                else {
                    config.multiselect.noneSelectedText = "Show All";
                }
                $(this).multiselect( config.multiselect );
                <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!--- ~ enable search feature when number of options in dropdown is large (customizable) ~ --->
                <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                if ($("option", this).length > multi_select_min_rows_filter) {
                    $(this).multiselectfilter( { label: "Find", placeholder: "", width: "300px", autoReset: true } );
                }
            });
        </script>
		<cfset request.focusHiLightOff = 1>
	</body>
</html>
