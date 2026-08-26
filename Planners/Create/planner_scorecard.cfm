<!----------------------------------------------------------------------------------
Name         :  AwayX/Planners/Create/planner_scorecard.cfm
Copyright    :  (c) 2016 Blacksmith Applications, Inc.
Created Date :  08/Jul/2016
Created By   :  Anand Rao
Description  :  Displays the list of programs from the current planner. Includes the planner_summary.cfm page
---------------------------------------------------------------------------------->
<cfparam name="form.action" 	default="">
<cfparam name="form.plannerID" 	default="">
<cfparam name="form.chkProgram" default="">
<cfparam name="url.rfa"         default="">

<cf_layout_planner selectedIndex=0>
        <cfif (form.action eq "rfa")>    <!--- user clicked the rfa option --->
            <cfstoredproc procedure="Planner_Approval_Process" datasource="#application.datasource#">
                <cfprocparam cfsqltype="cf_sql_integer" value="#form.plannerID#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.user_id#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="rfa">
            </cfstoredproc>
        </cfif>

        <cfif (form.action eq "updateCommited")>    <!--- user clicked the update commited option --->
            <!---initialize the BidRequestManager--->
            <cfset bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />

            <cfloop index="indx" list="#form.chkProgram#">
                <!---apply status for bid request--->
                <cfset bidRequestManager.applyStatus(indx, 2) />
            </cfloop>

            <cfset form.action = "" />
        </cfif>

        <cfif (form.action eq "updateLost")>    <!--- user clicked the update lost option --->
            <!---initialize the BidRequestManager--->
            <cfset bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />

            <cfloop index="indx" list="#form.chkProgram#">
                <!---apply status for bid request--->
                <cfset bidRequestManager.applyStatus(indx, 4) />
            </cfloop>

            <cfset form.action = "" />
        </cfif>

        <cfif (form.action eq "updateRFA")>    <!--- user clicked the update rfa option --->
            <!---initialize the PlannerProgramManager--->
            <cfset objPlannerProgramManager = CreateObject("component", "mvc.Models.Planner.PlannerProgramManager") />
            <cfset appSettings = application.appsettingsGet />
            <cfset displayAlert = ArrayNew(1)>

            <cfloop index="indx" list="#form.chkProgram#">
                <!---rfa program--->
                <cfset letUserProceed = 1>
                <cfset messageArray = ArrayNew(1)>
                <cfset struct = structNew()>
                <cfset Discount_Queries_Called = 0 />

                <cfquery name="GetSettings" datasource="#application.datasource#">
                    SELECT  cm.Contract_Number, pcpo.*
                    FROM    Program_Control_Panel_Options pcpo
                            inner join Contract_Main cm on cm.ProgramType_ID = pcpo.ProgramControl_Panel_Options_ID and cm.Contract_Main_ID = '#indx#'
                </cfquery>

                <cfset Contract_Main_ID = indx />

                <cfif val(GetSettings.Discount_Lump_Sums_Document_Attachment_Mandated)>
                    <cfset docCount = objPlannerProgramManager.getDocumentCount(#Contract_Main_ID#)>
                    <cfif ! qDocuments.TotalDocuments>
                        <cfset letUserProceed = 0 />
                        <cfset ArrayAppend(messageArray, "You should have at least one document attached to this program.")>
                    </cfif>
                </cfif>

                <cfinclude template="\Common_Files\contracts\common_program_level_check.cfm">

                <!--- Run program duplicate checker based on program template settings if the template setting is on --->
                <cfif val(GetSettings.Check_Duplicate_Program)>

                    <cfset cryp.value = Contract_Main_ID />
                    <!---duplicate_program_check.cfm needs the GetContractInfo query --->
                    <cfquery NAME="GetContractInfo" datasource="#application.datasource#">
                        SELECT 	Contract_Start_Date,
                                Contract_End_Date,
                                Revision_Of_Contract_Main_ID,
                                Contract_Number,
                                Contract_Title,
                                isnull(Fiscal_Year, '') AS Fiscal_Year,
                                ProgramType_ID
                        FROM    Contract_Main
                        WHERE   Contract_Main_ID = '#cryp.value#'
                    </cfquery>

                    <cfset getProgramTemplateInfo.ProgramType_ID = GetContractInfo.ProgramType_ID />
                    <cfset form.BUSINESS_CONSIDERATIONS = "" />
                    <cfset request.skip_cfflush = "yes" />
                    <cfset url.anyStatus = 1 />
                    <cfset url.plannerId = form.plannerID />

                    <cfinclude template="/Common_Files/contracts/duplicate_program_check.cfm">

                    <cfif val(DuplicateProgramIDList)>
                        <cfset letUserProceed = 0 />
                        <cfset ArrayAppend(messageArray, "Duplicate program(s) already exists")>
                    </cfif>

                </cfif>

                <cfif appSettings.getBudgetsFunctionalityOn() and appSettings.getBudgetSelectionRequired()>

                    <cfquery name="qGetBudget" datasource="#application.datasource#">
                        SELECT  1
                        FROM    Budget_Program_Selection
                        WHERE   Program_ID = '#indx#'
                    </cfquery>

                    <cfif not qGetBudget.recordCount>
                        <cfset letUserProceed = 0 />
                        <cfset ArrayAppend(messageArray, "You must make a budget selection")>
                    </cfif>

                </cfif>

                <cfif letUserProceed eq 1>
                    <cfset objPlannerProgramManager.rfaProgram(indx, request.AccessStructure.user_id) />
                <cfelse>
                    <cfset StructInsert(struct, "programNumber", GetSettings.Contract_Number)>
                    <cfset StructInsert(struct, "messages", messageArray)>
                    <cfset ArrayAppend(displayAlert, struct)>
                </cfif>

            </cfloop>

            <cfset form.action = "" />

            <cfif arrayLen(displayAlert)>

                <cfsavecontent variable="massRFAMessages">
                    <cfloop index="idx2" from="1" to="#arrayLen(displayAlert)#">
                        <cfoutput>#displayAlert[idx2].programNumber#: #ArrayToList(displayAlert[idx2].messages)#<br></cfoutput>
                    </cfloop>
                </cfsavecontent>

            </cfif>

        </cfif>

        <cfif (form.action eq "deletePrograms")>    <!--- user clicked thedelete programs option --->
            <!---initialize the ProgramManager--->
            <cfset objProgramManager = CreateObject("component", "components.programs.program") />

            <cfset displayAlert = ArrayNew(1)>

            <cfloop index="indx" list="#form.chkProgram#">
                <!--- delete program --->
                <cfset struct = structNew()>
                <cfset Contract_Main_ID = indx />

                <!--- Try to lock the program first --->
                <cfset lockReturnValue = objProgramManager.setLockStatus(Contract_Main_ID, 1, request.AccessStructure.User_ID) />

                <cfquery name="GetProgram" datasource="#application.datasource#">
                    SELECT  cm.Contract_Number, cm.Contract_Title
                    FROM    Contract_Main cm
                    WHERE	cm.Contract_Main_ID = '#Contract_Main_ID#'
                </cfquery>

                <cfif lockReturnValue EQ 1> <!--- Successfully locked, can delete --->
                    <cfset objProgramManager.deleteProgram(Contract_Main_ID, request.AccessStructure.User_ID, request.AccessStructure.User_ID, 1) />
                <cfelseif lockReturnValue EQ 2> <!--- Cannot lock, so cannot delete --->
                    <cfset StructInsert(struct, "programNumber", GetProgram.Contract_Number)>
                    <cfset StructInsert(struct, "messages", "#Application.PlannerPrgLabel# not found")>
                    <cfset ArrayAppend(displayAlert, struct)>
                <cfelseif lockReturnValue EQ 3> <!--- Cannot lock, so cannot delete --->
                    <cfset StructInsert(struct, "programNumber", GetProgram.Contract_Number)>
                    <cfset StructInsert(struct, "messages", "#Application.PlannerPrgLabel# is locked by someone else")>
                    <cfset ArrayAppend(displayAlert, struct)>
                </cfif>

            </cfloop>

            <cfif arrayLen(displayAlert)>

                <cfsavecontent variable="massDeleteProgramMessages">
                    <cfloop index="idx2" from="1" to="#arrayLen(displayAlert)#">
                        <cfoutput>#displayAlert[idx2].programNumber#: #displayAlert[idx2].messages#<br></cfoutput>
                    </cfloop>
                </cfsavecontent>

            </cfif>

            <cfset form.action = "" />
        </cfif>

        <cfif (form.action eq "releaseSettlement")>    <!--- user clicked the release settlement option --->
            <!---initialize the release settlement manager --->
            <cfif len(form.chkProgram)>
                <cfset releasemanager = CreateObject("component","components.programs.releasesettlement.releasesettlementmanager") />
                <cfset result = releasemanager.send(form.chkProgram, request.accessstructure.user_id)>
            </cfif>

            <cfset form.action = "" />
        </cfif>


        <cfset jQuery.version   = "1.10.2">
        <cfset jQueryUI.version = "1.11">

        <cfinclude template="/Common_Files/jQuery.cfm">
        <cf_include files="/common_files/dataTables2.cfm, /common_files/datatable2.css, /settings/planners/planners.js, /Script/javascript/jquery.dataTables-api.js, /script/javascript/numeral.min.js, /styles/css-loader.css, /common_files/dhx_message.cfm">

        <style>
            html, body { overflow: hidden; }
            #layoutBody { overflow: auto; width: 100%; }
            #wrapper {display:table; width:98%;  min-height:400px; table-layout:fixed; }
            #leftcolumn {	display:table-cell;
                            background:#D3E5F3;
                            background-image:-webkit-linear-gradient(to right, #D3E5F3, #e7f1f8);
                            background-image:-o-linear-gradient(to right, #D3E5F3, #e7f1f8);
                            background-image:linear-gradient(to right, #D3E5F3, #e7f1f8);
                            padding:5px; border-right:1px solid #CCC; } /* width:220px;float:left */
            #midcolumn {display:table-cell; padding:0px; border-right:1px solid #CCC; vertical-align: middle;}
            #rightcolumn {display:table-cell; padding:2px; vertical-align:top; } /* float:left */
            #datagrid {margin-top:5px;}
            #leftcolumn select {width:180px;}
            .prgSearchHdr{	background:#9BC2E6 !important;
                            background-image: -webkit-linear-gradient(#9BC2E6, #d8e7f5) !important;
                            background-image: -o-linear-gradient(#9BC2E6, #d8e7f5) !important;
                            background-image: linear-gradient(#9BC2E6, #d8e7f5) !important;
                            padding:5px; border-top: 2px solid #444; box-shadow: 0 8px 6px -6px black; }
            th.left { text-align: left; }
            .search{background:#9BC2E6 !important; padding:5px; box-shadow: 0 8px 6px -6px black; }
            hr {border: 1px solid #666;}
            div.refresh_data { display:inline-block; margin-left:25px; position:relative; top:-2px; }
            a.filter { margin:0 5px; }
            table[name=filter] tr { height:24px; }
            table[name=filter] select { line-height:21px; height:21px; }
            #update_committed{display:none;}
            #update_lost{display:none;}
            #update_rfa{display:none;}
            #delete_programs{display:none;}
            #release_settlement{display:none;}
            td.number { text-align: right; }
            td.center { text-align: center; }
            td.nobr { white-space: nowrap; }
            div.refresh_data {
                position:relative;
                top:-4px;
            }
            div.refresh_data a {
                margin-right:20px;
            }
        </style>

        <cfset plannerManager 	= CreateObject("component","mvc.Models.Planner.PlannerManager") />
        <cfset qPlannerPrograms = plannerManager.getPlannerPrograms(plannerID=form.plannerID)/>

        <cfset getPlanner 		= plannerManager.getPlannerSummary(plannerID=form.plannerID, includeIndirectProgramCount=1) />

        <cfset appsettings 		= application.oapplicationappsettingsmanager.getapplicationappsettings()>
        <cfset profileManager   = CreateObject("component","components.user.Profile").init() />
        <cfset profileSettings  = profileManager.getProfileSettings(request.AccessStructure.Profiles_ID)>

        <cfset qLabels                  = createObject("component", "components.settings.Labels.Labels").init() />
        <cfset qGetPlannerBidWonLabels  = qLabels.GetPlannerLabels('Bid Status:Won') />
        <cfset plannerBidWonLabel       = qGetPlannerBidWonLabels.Planner_Labels_Singular />
        <cfset qGetPlannerBidLostLabels = qLabels.GetPlannerLabels('Bid Status:Lost') />
        <cfset plannerBidLostLabel      = qGetPlannerBidLostLabels.Planner_Labels_Singular />

        <cfscript>
            // D73626 - Retail-328 - Release Settlement
            showReleaseSettlement = 0;
            if (appSettings.getReleaseSettlement() AND  profileSettings.release_settlement){
                showReleaseSettlement = 1;
            }
            releaseSettlementAvailability = 0;
            if (appSettings.getReleaseSettlement() AND  appSettings.get_Setting('Release_Settlement_Availability') EQ '1') {
                releaseSettlementAvailability = 1;
            }

            /* Status */
            statusIdList = ValueList(qPlannerPrograms.Contract_Status_Type_IDX) ;
            statusNameList = ValueList(qPlannerPrograms.Contract_Status_Type_Desc);
            statusStruct = {};
            for(i=1;i<=ListLen(statusIdList);i++) {
                statusStruct[ListGetAt(statusIdList,i)] = ListGetAt(statusNameList,i);
            }

            /* Templates */
            tmpltIdList = ValueList(qPlannerPrograms.ProgramType_ID) ;
            tmpltNameList = ValueList(qPlannerPrograms.Created_Type);
            tmpltStruct = {};
            for(i=1;i<=ListLen(tmpltNameList);i++) {
                tmpltStruct[ListGetAt(tmpltNameList,i)] = ListGetAt(tmpltIdList,i);
            }

            /* Perf Types */
            perfIDList = ValueList(qPlannerPrograms.Planner_Perf_Type_ID);
            perfNameList = ValueList(qPlannerPrograms.Description);
            perfStruct = {};
            j = 1;
            for(i=1;i<=ListLen(perfIDList);i++) {
                if (ListGetAt(perfIDList,i) NEQ 0)
                {
                    perfStruct[ListGetAt(perfIDList,i)] = ListGetAt(perfNameList,j);
                    j++;
                }
            }

            /* Components */
            compNameList = 	ListRemoveDuplicates(
                                ListSort(
                                    ValueList(qPlannerPrograms.components),
                                    'textnocase', 'asc'
                                ),
                                ',', true
                            );

            /* Claim Mechanics */
            claimMechList = 	ListRemoveDuplicates(
                                ListSort(
                                    ValueList(qPlannerPrograms.ClaimMechanics),
                                    'textnocase', 'asc'
                                ),
                                ',', true
                            );

            /* Budgets */
            budgetIDList = ValueList(qPlannerPrograms.Planner_Budget_ID);
            budgetNameList = ValueList(qPlannerPrograms.Budget_Desc);
            budgetStruct = {};
            j = 1;
            for(i=1;i<=ListLen(budgetIDList);i++) {
                if (ListGetAt(budgetIDList,i) NEQ 0)
                {
                    budgetStruct[ListGetAt(budgetIDList,i)] = ListGetAt(budgetNameList,j);
                    j++;
                }
            }

            objSearchProgram  = CreateObject("component", "mvc.Models.Program.Search_Program");
            objProgramList    = CreateObject("component", "mvc.Models.Program.ProgramList");
            stProgramSettings = objSearchProgram.getProgramSettingsObject(request.AccessStructure.user_id);
            arrConditions = [
             {conditionId = 1, condition = "Auto renew"}
            ,{conditionId = 2, condition = "Auto renew pairs"}
            ,{conditionId = 4, condition = "Cancelled"}
            ,{conditionId = 5, condition = "Disagreed"}
            ,{conditionId = 6, condition = "Doc attached"}
            ,{conditionId = 7, condition = "Not Cancelled"}
            ,{conditionId = 8, condition = "Revision"}
            ,{conditionId = 9, condition = "Expiring No Revision"}
        ];

        if(stProgramSettings.bestplanon eq 1){
            arrayAppend(arrConditions,{conditionId = 3, condition = "Best Plan Programs"});
        }
        if (application.appSettingsget.getrolloverprograms_on()){
            arrayAppend(arrConditions,{conditionId = 10, condition = "Rollover"});
        }
        if (application.appSettingsget.getReleaseSettlement()) {
            arrayAppend(arrConditions,{conditionId = 11, condition = "Released"});
            arrayAppend(arrConditions,{conditionId = 12, condition = "Not Released"});
        }
        if (application.appsettingsget.getProgramLockTypeID()) {
            arrayAppend(arrConditions,{conditionId = 13, condition = "Acknowledged"});
            arrayAppend(arrConditions,{conditionId = 14, condition = "Not Acknowledged"});
        }
            arrayAppend(arrConditions,{conditionId = 15, condition = "Uploaded"});
            arrayAppend(arrConditions,{conditionId = 16, condition = "Restrict from BB = No"});
            arrayAppend(arrConditions,{conditionId = 17, condition = "Restrict from BB = Yes"});

            arraySort(arrConditions,
            function (e1, e2){
                if (e1.conditionId lt e2.conditionId)
                    return -1;
                else if (e1.conditionId eq e2.conditionId)
                    return 0;
                else
                    return 1;
            });
        </cfscript>

        <div id="wrapper">
            <form method="post" name="plannerScorecardForm" id="plannerScorecardForm">
                <div id="leftcolumn" >
                    <h3 class="search txtCtr"> <span> Filter Options </span> </h3>
                    <cfoutput>
                        <table name="filter">
                            <tr>
                                <td> #Application.PlannerPrgLabel# &nbsp;&nbsp;&nbsp; </td>
                                <td> <input type="text" name="txtProgram" id="txtProgram" class="filter" title="Keyword search on any of:
Program ID, Legacy ID or Reference"> </td>
                            </tr>
                            <tr>
                                <td> Product&nbsp;&nbsp;&nbsp; </td>
                                <td> <input type="text" name="txtProduct" id="txtProduct" class="filter"> </td>
                            </tr>
                            <tr style="height:35px">
                                <td colspan="2">
                                    <a id="btnSearch" class=filter>#application.util.string.linkFormat("search")#</a>
                                    <a id="btnReset"  class="filter opaque-h">#application.util.string.linkFormat("reset")#</a><br>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <select name="selStatus" id="selStatus" class="filter">
                                        <option value="0">Show All Status</option>
                                        <cfloop collection="#statusStruct#" item="statusId">
                                            <cfset selected = StructCount(statusStruct) eq 1 or ( val(url.rfa) eq 999 and statusId eq 2 )
                                                                ? "selected=selected"
                                                                : ''>
                                            <option value="#statusId#" #selected#>
                                                #StructFind(statusStruct, statusId)#
                                            </option>
                                        </cfloop>

                                        <cfif profileSettings.RFA_Agreed neq 0>
                                            <option value="101" <cfif url.rfa eq 101>selected=selected</cfif>>Under Review</option>
                                            <option value="102" <cfif url.rfa eq 102>selected=selected</cfif>>Pending Approval</option>
                                            <option value="103" <cfif url.rfa eq 103>selected=selected</cfif>>Agreed</option>
                                        </cfif>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <select name="selTemplates" id="selTemplates" class="filter">
                                        <option value="0">Show All Templates</option>
                                        <cfloop collection="#tmpltStruct#" item="tmpltId">
                                            <!--- <option value="#tmpltId#" <cfif StructCount(tmpltStruct) eq 1>selected=selected</cfif>>#StructFind(tmpltStruct,tmpltId)#</option> --->
                                            <option value="#StructFind(tmpltStruct,tmpltId)#" <cfif StructCount(tmpltStruct) eq 1>selected=selected</cfif>>#tmpltId#</option>
                                        </cfloop>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <select name="selPerfTypes" id="selPerfTypes" class="filter">
                                        <option value="0">Show All Perf Types</option>
                                        <cfloop collection="#perfStruct#" item="perfId">
                                            <option value="#perfId#" <cfif StructCount(perfStruct) eq 1>selected=selected</cfif>>#StructFind(perfStruct,perfId)#</option>
                                        </cfloop>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <select name="selComponents" id="selComponents" class="filter">
                                        <option value="0">Show All #Application.PlannerCompLabel_Plural#</option>
                                        <cfloop list="#compNameList#" index="compName">
                                            <option value="#compName#" <cfif listLen(compNameList) eq 1>selected=selected</cfif>>#compName#</option>
                                        </cfloop>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <select name="selClaimMech" id="selClaimMech" class="filter">
                                        <option value="0">Show All Claim Mechanics</option>
                                        <cfloop list="#claimMechList#" index="claimMech">
                                            <option value="#claimMech#" <cfif listLen(claimMechList) eq 1>selected=selected</cfif>>#claimMech#</option>
                                        </cfloop>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <select name="selBudgets" id="selBudgets" class="filter">
                                        <option value="0">Show All Budgets</option>
                                        <cfloop collection="#budgetStruct#" item="budgetId">
                                            <option value="#budgetId#" <cfif StructCount(budgetStruct) eq 1>selected=selected</cfif>>#StructFind(budgetStruct,budgetId)#</option>
                                        </cfloop>
                                    </select>
                                </td>
                            </tr>

                            <cfset bsm_cfc = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager")>
                            <cfif not bsm_cfc.isEnabled()>
                                <input type="hidden" name="Business_Segment_ID" value="">
                            <cfelse>
                                <tr>
                                    <cfquery name="qSegments" datasource="#application.datasource#">
                                        SELECT  b.Business_Segment_ID
                                               ,b.Business_Unit_Desc
                                          FROM  Template_Business_Segment t
                                                INNER JOIN Business_Segment b ON t.Business_Segment_ID = b.Business_Segment_ID AND b.Active = 1 AND b.Deleted = 0
                                         WHERE  t.Deleted = 0
                                                AND t.Template_ID IN (
                                                                        SELECT DISTINCT
                                                                                ProgramType_ID
                                                                        FROM Contract_Main
                                                                        WHERE Planner_ID  = '#form.plannerID#'
                                                                                AND DELETED = 0
                                                                    )
                                                ORDER BY b.Business_Unit_Desc
                                    </cfquery>

                                    <td colspan="2">
                                        <select name="business_segment_id" id="business_segment_id" class="filter">
                                            <option value="0">Show All Segments</option>    // ngt
                                            <cfloop query="qSegments">
                                                <option value="#qSegments.Business_Segment_ID#">#qSegments.Business_Unit_Desc#</option>
                                            </cfloop>
                                        </select>
                                    </td>
                                </tr>
                            </cfif>

                            <cfif form.mode eq 'E'>
                            <tr>
                                <td colspan="2">
                                    <select name="selActionFor" id="selActionFor" class="filter2">
                                        <option value="0">Select Action For</option>
                                        <option value="1">Delete</option>
                                        <option value="2">Update #plannerBidWonLabel#</option>
                                        <option value="3">Update #plannerBidLostLabel#</option>
                                        <option value="4">Update RFA</option>
                                        <cfif showReleaseSettlement>
                                        <option value="5">Release Settlement</option>
                                        </cfif>
                                    </select>
                                </td>
                            </tr>
                            </cfif>
                            <tr>
                                <td colspan="2">
                                    <select name="condition_list" id="condition_list" multiple size="30"  style="height:45px" title="Use Ctrl + Click to pick multiple">
                                    <option value="0">Select Conditions</option>
                                        <cfscript>
                                            ArrayEach(arrConditions,function(stCondition){
                                                writeOutput('<option value=#stCondition["conditionId"]#>#stCondition["condition"]#</option>');
                                             });
                                        </cfscript>
                                    </select>
                                </td>
                            </tr>
                            <tr style="height:35px">
                                <td colspan="2">
                                    <a id="btnSearch2" class=filter>#application.util.string.linkFormat("search")#</a>
                                    <a id="btnReset2" class="filter opaque-h">#application.util.string.linkFormat("reset")#</a>
                                </td>
                            </tr>
                            <cfscript>
                                userManager = CreateObject("component", "components.user.UserManager");
                                oProfiles = CreateObject("component","components.settings.profiles.profile");
                                getProfileSettings2 = oProfiles.getAllProfiles(request.AccessStructure.Profiles_ID);
                                createProgramAccess = getProfileSettings2.Cont_Prog_View_Create_Program eq 1 and (application.appsettingsget.userNumberRestrict EQ 0 OR userManager.getUserNumberExists(request.AccessStructure.user_id) EQ 1);
                            </cfscript>
                            <cfif form.mode eq 'E' and createProgramAccess>
                                <tr>
                                    <td colspan="2">
                                        <a name="btnCreateProgram" id="btnCreateProgram" class=filter>#application.util.string.linkFormat("create #lcase(Application.PlannerPrgLabel)#")#</a>
                                    </td>
                                </tr>
                            </cfif>
                            <tr style="height:35px">
                                <td colspan="2">
                                    <a name="btnDownloadData" id="btnDownloadData" class="filter opaque-h" onclick="generate_export('planner_program_download.cfm?fileParam=Download&plannerID=#form.plannerID#')">#application.util.string.linkFormat("download data")#</a>
                                </td>
                            </tr>
                        </table>
                    </cfoutput>
                    <br><br>
                </div> <!--- leftcolumn --->

                <div id="midcolumn">
                    <i class="ui-icon ui-icon-circle-triangle-w" title="click to collapse the filter options"></i>
                </div>

                <div id="rightcolumn">
                    <!--- include the planner_summary.cfm file --->
                    <cfinclude template="planner_summary.cfm"/>

                    <div id="results">
                        <h4 class="prgSearchHdr" >	<cfoutput>#Application.PlannerPrgLabel#	</cfoutput> Search Results: &nbsp; <cfoutput>#qPlannerPrograms.RecordCount#</cfoutput> records </h4>
                        <div id="datagrid0">
                            <table class="dataTable dense row-border order-column hover datagrid" id="datagrid" width="100%">
                                <thead>
                                    <tr>
                                        <!-- 00 --> <th class="left"><input type="checkbox" id="checkAll" name="checkAll"></th>
                                        <!-- 01 --> <th class="left">Status</th>
                                        <!-- 02 --> <th>RFA Days</th>
                                        <!-- 03 --> <th class="left">	<cfoutput>#Application.PlannerPrgLabel#	</cfoutput></th>
                                        <!-- 04 --> <th class="left">Title</th>
                                        <!-- 05 --> <th class="left">	<cfoutput>#Application.PlannerPrgLabel#	</cfoutput> Type</th>
                                        <!-- 06 --> <th class="left">Perf Type</th>
                                        <!--- <th>Budget</th> --->
                                        <!-- 07 --> <th class="left"><cfoutput>#request.planner_labels.delivery_plural# Start</cfoutput></th>
                                        <!-- 08 --> <th class="left"><cfoutput>#request.planner_labels.delivery_plural# End</cfoutput></th>
                                        <!-- 09 --> <th><cfoutput>#Application.PlannerEstTradeLabel#</cfoutput></th>
                                        <!-- 10 --> <th>Actual</th>
                                        <!-- 11 --> <th>Volume</th>
                                        <!-- 12 --> <th>More Info</th>
                                        <!-- 13 --> <th>Release Settlement</th> 	<!--- not displayed, used for filtering --->
                                        <!-- 14 --> <th><cfoutput>#Application.PlannerCompLabel_Plural#</cfoutput></th> 			<!--- not displayed, used for filtering --->
                                        <!-- 15 --> <th>Claim Mechanics</th> 		<!--- not displayed, used for filtering --->
                                        <!-- 16 --> <th>Items</th> 					<!--- not displayed, used for filtering --->

                                        <!-- 17 1 --> <th>Auto Renew</th> 			<!--- not displayed, used for filtering --->
                                        <!-- 18 2 --> <th>Auto Renew Pairs</th> 	<!--- not displayed, used for filtering --->
                                        <!-- 19 3 --> <th>Best Plan Programs</th> 	<!--- not displayed, used for filtering --->
                                        <!-- 20 4 --> <th>Cancelled</th> 			<!--- not displayed, used for filtering --->
                                        <!-- 21 5 --> <th>Disagreed</th> 			<!--- not displayed, used for filtering --->
                                        <!-- 22 6 --> <th>Doc Attached</th> 		<!--- not displayed, used for filtering --->
                                        <!-- 23 7 --> <th>Not Cancelled</th> 		<!--- not displayed, used for filtering --->
                                         <!-- 24 8 --> <th>Revision</th> 			<!--- not displayed, used for filtering --->
                                        <!-- 25 9 --> <th>Expiring No Revision</th> <!--- not displayed, used for filtering --->
                                        <!-- 26 10 --> <th>Rollover</th> 			<!--- not displayed, used for filtering --->
                                        <!-- 27 11 --> <th>Released</th> 			<!--- not displayed, used for filtering --->
                                        <!-- 28 12 --> <th>Not Released</th> 		<!--- not displayed, used for filtering --->
                                        <!-- 29 13 --> <th>Acknowledged</th> 		<!--- not displayed, used for filtering --->
                                        <!-- 30 14 --> <th>Not Acknowledged</th> 	<!--- not displayed, used for filtering --->
                                        <!-- 31 15 --> <th>Uploaded</th> 			<!--- not displayed, used for filtering --->
                                        <!-- 32 16 --> <th>Restrict from BB = No</th>	<!--- not displayed, used for filtering --->
                                        <!-- 33 17 --> <th>Restrict from BB = Yes</th>  <!--- not displayed, used for filtering --->
                                        <!-- 34 18 --> <th>Segment</th>  <!--- not displayed, used for filtering --->
                                        <!-- 35 19 --> <th>Legacy</th>  <!--- not displayed, used for filtering --->
                                        <!-- 36 20 --> <th>Reference</th>  <!--- not displayed, used for filtering --->
                                        <!-- 37 21 --> <th class="c37">Program_Sub_Status_ID</th>  <!--- not displayed, used for filtering --->
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfoutput query="qPlannerPrograms">

                                        <tr id="#qPlannerPrograms.Contract_Main_ID#" class="templateId">
                                            <!-- 00 --> <td><input name="chkProgram" type="checkbox" class="massAll" id="chk_#qPlannerPrograms.Contract_Main_ID#" value="#qPlannerPrograms.Contract_Main_ID#"></td>
                                            <!-- 01 --> <td>#qPlannerPrograms.Contract_Status_Type_Desc#</td>
                                            <!-- 02 --> <td class="number">#qPlannerPrograms.RFA_Days#</td>
                                            <!-- 03 --> <td><cfset url_param = (form.mode eq 'E' ? "bLock=1" : "numb=")> <a href="##" class=edit title="click here to launch the #Application.PlannerPrgLabel#" onclick="popupCenter2022('planner_program_create.cfm?programId=#qPlannerPrograms.Contract_Main_ID#&plannerID=#form.plannerID#&#url_param#&customerID=#getPlanner.BSA_FoodService_Customers_ID#&templateId=#qPlannerPrograms.ProgramType_ID#&Product_List_Type=#form.product_group_level_id#&bInit=1','winEdit','XL','LG');">#qPlannerPrograms.Contract_Number#<cfif qPlannerPrograms.Contract_Status_Type_IDX GT 2>-#qPlannerPrograms.Version#</cfif></a></td>
                                            <!-- 04 --> <td>#qPlannerPrograms.Contract_Title#</td>
                                            <!-- 05 --> <td>#qPlannerPrograms.Created_Type#</td>
                                            <!-- 06 --> <td>#qPlannerPrograms.Description#</td>
                                            <!--- <td>#qPlannerPrograms.Budget_Desc#</td> --->
                                            <!-- 07 --> <td>#dateFormat(qPlannerPrograms.Delivery_Start_Date, "mmm dd, yyyy")#</td>
                                            <!-- 08 --> <td>#dateFormat(qPlannerPrograms.Delivery_End_Date, "mmm dd, yyyy")#</td>
                                            <!-- 09 --> <td class="number">#dollarFormat( qPlannerPrograms.Program_Spend )#</td>
                                            <!-- 10 --> <td class="number">#dollarFormat( qPlannerPrograms.Actual_Dollar )#</td>
                                            <!-- 11 --> <td class="number">#numberFormat(qPlannerPrograms.Contract_Quantity, ",")# #qPlannerPrograms.Volume_UOM#</td>
                                            <!-- 12 -->	<td class="nobr">
                                                            <a title="click to view #Application.PlannerPrgLabel# detail" onclick="popupCenter2022('/common_files/contracts/contract_details.cfm?contractId=#qPlannerPrograms.Contract_Main_ID#', '', 'LG', 'XL');">#application.util.string.linkFormat("detail")#</a>
                                                            <cfif (appSettings.getpaymenthistoryon() AND qPlannerPrograms.Payment_History EQ 1)>
                                                             <a title="click to view payment history" onclick="popupCenter2022('/common_files/contracts/payment_history/payment_history.cfm?ContractId=#qPlannerPrograms.Contract_Main_ID#', '', 'LG', 'XL')" title="Payment History for #qPlannerPrograms.Contract_Number#}">#application.util.string.linkFormat("$")#</a>
                                                            <cfelse>
                                                            &nbsp;
                                                            </cfif>
                                                            <cfif (qPlannerPrograms.Manual_Cancel EQ 1)><img src="/images/no_small.gif" title="Cancelled by #qPlannerPrograms.Cancelled_By# on #qPlannerPrograms.Cancelled_Date#" /> <cfelse> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</cfif>
                                                        </td>
                                            <!-- 13 -->	<td>
                                                            <cfif (	qPlannerPrograms.Release_Settlement EQ 1
                                                                    AND (
                                                                            releaseSettlementAvailability NEQ 1
                                                                            OR (
                                                                                qPlannerPrograms.Sending_To_External_Client EQ 0
                                                                                AND qPlannerPrograms.Sent_To_External_Client EQ 1
                                                                                AND len(qPlannerPrograms.Contract_Reference_Number) GT 0
                                                                                AND len(qPlannerPrograms.External_Client_Ack_Date) GT 0
                                                                            )
                                                                        )
                                                                    AND qPlannerPrograms.Released EQ 0
                                                                    AND (
                                                                            qPlannerPrograms.Contract_Status_Type_IDX EQ 5
                                                                            OR qPlannerPrograms.Contract_Status_Type_IDX EQ 6
                                                                            OR qPlannerPrograms.Contract_Status_Type_IDX EQ 7
                                                                        )
                                                                )>
                                                                1
                                                            <cfelse>
                                                                0
                                                            </cfif>
                                                        </td>
                                            <!-- 14 --> <td>#qPlannerPrograms.Components#</td>
                                            <!-- 15 --> <td>#qPlannerPrograms.ClaimMechanics#</td>
                                            <!-- 16 --> <td>#qPlannerPrograms.Items#</td>

                                            <!-- 17 1 --> <td>#qPlannerPrograms.is_autorenew#</td>
                                            <!-- 18 2 --> <td>#qPlannerPrograms.condRenewed#</td>
                                            <!-- 19 3 --> <td>#qPlannerPrograms.Best_Plan_Program#</td>
                                            <!-- 20 4 --> <td>#qPlannerPrograms.Manual_Cancel#</td>
                                            <!-- 21 5 --> <td>#qPlannerPrograms.DisAgreed_Len#</td>
                                            <!-- 22 6 --> <td><cfif (Len(Trim(qPlannerPrograms.Contract_Attachments_Exists)) GTE 1)>1<cfelse>0</cfif></td>
                                            <!-- 23 7 --> <td>#qPlannerPrograms.Manual_Cancel#</td>
                                            <!--- 24 8 ---> <td>#qPlannerPrograms.condRevision#</td>
                                            <!--- 25 9 ---> <td>#qPlannerPrograms.ExpiringNoRevision#</td>
                                            <!--- 26 10 ---> <td>#qPlannerPrograms.Rollover_Len#</td>
                                            <!--- 27 11 ---> <td>#qPlannerPrograms.condReleased#</td>
                                            <!--- 28 12 ---> <td>#qPlannerPrograms.condNotReleased#</td>
                                            <!--- 29 13 ---> <td>#qPlannerPrograms.Acknowledged#</td>
                                            <!--- 30 14 ---> <td>#qPlannerPrograms.NotAcknowledged#</td>
                                            <!--- 31 15 ---> <td>#qPlannerPrograms.Creation_Method#</td>
                                            <!--- 32 16 ---> <td>#qPlannerPrograms.RestrictedBB#</td>
                                            <!--- 33 17 ---> <td>#qPlannerPrograms.RestrictedBB#</td>
                                            <!--- 34 18 ---> <td>#qPlannerPrograms.Business_Segment_ID#</td>
                                            <!--- 35 19 ---> <td>#qPlannerPrograms.Legacy_Deal_ID#</td>
                                            <!--- 36 20 ---> <td>#qPlannerPrograms.Contract_Reference_Number#</td>
                                            <!--- 37 21 ---> <td class="c37">#qPlannerPrograms.Program_Sub_Status_ID#</td>
                                        </tr>
                                    </cfoutput>
                                </tbody>
                            </table>
                        </div> 	<!--- datagrid --->
                    </div>	<!--- results --->
                </div>	<!--- rightcolumn --->
                <input type="hidden" name="plannerID" value=<cfoutput>"#form.plannerID#"</cfoutput>>
                <input type="hidden" name="action" value="" />
                <input type="hidden" name="mode" value="<cfoutput>#form.mode#</cfoutput>" />
            </form>

            <cfset approval_cfm = "/planners/create/planner_approval.cfm">
            <cfoutput>
            <cfif application.util.query.get_Setting("planner_targets_enabled", 0) eq '1'>
                <cfset approval_cfm = "/planners/create/planner_targets_approval.cfm">
                <form name="approval" method="post" action="#approval_cfm#" onsubmit='popupInCenter("#approval_cfm#?id=#form.plannerID#", "planner_approval", 1300, 750); return false;'>
            <cfelse>
                <form name="approval" method="post" action="#approval_cfm#" onsubmit="popup_form(this, 'approval')">
            </cfif>
                <input type="hidden" name="plannerID" value="#form.plannerID#">
                <input type="hidden" name="include_slotting">
            </form>
            </cfoutput>


            <cfinclude template="topnav_form.cfm">

            <form name="rfa" method="post">
                <cfset application.util.struct.saveToHiddenInput( form, arrayToList(topnav_elements) )>
            </form>
        </div> 	<!--- wrapper --->

        <!--- content for links --->
        <cfset plannerRefreshLink  = application.util.string.linkFormat("refresh data") />
        <cfset plannerBidWonLink   = application.util.string.linkFormat("update #lcase(plannerBidWonLabel)#") />
        <cfset plannerBidLostLink  = application.util.string.linkFormat("update #lcase(plannerBidLostLabel)#") />
        <cfset plannerUpdateRFALink  = application.util.string.linkFormat("update RFA", "", "ui-icon-pencil") />
        <cfset plannerDeleteProgramsLink  = application.util.string.linkFormat("delete programs") />
        <cfset plannerReleaseSettlementLink  = application.util.string.linkFormat("release settlement") />

        <cfsavecontent variable="refresh_data">
            <cfoutput><a id=refresh_data title=\"click to refresh data on this page\" class=hand>#plannerRefreshLink#</a></cfoutput>
            <cfoutput><a id=update_committed title=\"click to update\" class=hand>#plannerBidWonLink#</a></cfoutput>
            <cfoutput><a id=update_lost title=\"click to update\" class=hand>#plannerBidLostLink#</a></cfoutput>
            <cfoutput><a id=update_rfa title=\"click to update\" class=hand>#plannerUpdateRFALink#</a></cfoutput>
            <cfoutput><a id=delete_programs title=\"click to update\" class=hand>#plannerDeleteProgramsLink#</a></cfoutput>
            <cfoutput><a id=release_settlement title=\"click to update\" class=hand>#plannerReleaseSettlementLink#</a></cfoutput>
        </cfsavecontent>

        <cfif val(request.planner_targets_enabled) eq 0>
            <cfset scrollY = [ "50vh", "30vh" ]>
        <cfelse>
            <cfset scrollY = [ "70vh", "50vh" ]>
        </cfif>

        <script>
            const COLUMN = { Segment:34, Legacy:35, Reference:36, Program_Sub_Status_ID:37 };

            var programs_grid = $("#datagrid");
            var oTable = programs_grid.DataTable({
                "autoWidth": false
                ,"paging": false
                ,"processing":true
                ,"orderClasses": true
                ,"ScrollCollapse": true
                ,"sDom": 'f<"refresh_data">ti'
                ,"sorting": [[ 3, "asc" ]]
                ,"scrollY": (window.innerHeight - programs_grid.offset().top - 115) + "px"  /* 115px = top search filter + column headers + showing entries footer */
                ,"columns": [
                      {"bSortable":false, "bSearchable":false}	// 00
                    , {"bSortable":true,  "bSearchable":true}	// 01
                    , {"bSortable":true,  "bSearchable":true}	// 02
                    , {"bSortable":true,  "bSearchable":true}	// 03
                    , {"bSortable":true,  "bSearchable":true}	// 04
                    , {"bSortable":true,  "bSearchable":true}	// 05
                    , {"bSortable":true,  "bSearchable":true}	// 06
                    , {"bSortable":true,  "bSearchable":true}	// 07
                    , {"bSortable":true,  "bSearchable":true}	// 08
                    , {"bSortable":true,  "bSearchable":false}	// 09
                    , {"bSortable":true,  "bSearchable":false}	// 10
                    , {"bSortable":false, "bSearchable":false}	// 11
                    , {"bSortable":false, "bSearchable":false}	// 12
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 13
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 14
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 15
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 16

                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 17
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 18
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 19
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 20
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 21
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 22
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 23
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 24
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 25
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 26
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 27
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 28
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 29
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 30
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 31
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 32
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 33
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 34 - 18 segment
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 35 - 19 legacy
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 36 - 20 reference
                    , {"bSortable":false,  "bSearchable":true, "visible":false}	// 37 - 21 program_sub_status_id
                    ]
            }); // DataTable
            $("div.refresh_data").html( <cfoutput>"#refresh_data#"</cfoutput> );

            $('select.filter').change( function() {
                var  col = -1
                    ,txt = ( $(this).val() == 0 ? "" : $(this).find("option:selected").text().trim() )
                    ,idx = $(this).val();

                switch ( $(this).attr("id") ) {
                    case 'selStatus'     : col = 1; break;
                    case 'selTemplates'  : col = 5; break;
                    case 'selPerfTypes'  : col = 6; break;
                    case 'selBudgets'    : col = 7; break;  // not used
                    case 'selComponents' : col = 14; break;
                    case 'selClaimMech'  : col = 15; break;
                    case 'business_segment_id' :
                        idx = 0;
                        col = COLUMN.Segment;
                        txt = $(this).find("option:selected").val().trim();   // use segment numeric value instead of text
                        txt = txt == '0' ? '' : txt;
                        break;
                }

                // handle status dropdown
                if ( col === 1 ) {
                    regExSearch = '^' + txt +'$';
                    console.log(idx);
                    // search for under review, pending approval & agreed
                    if ( +idx >= 101  ) {
                        oTable.columns( 1 ).search( '' )
                              .columns( COLUMN.Program_Sub_Status_ID ).search( idx )
                              .draw();
                    }
                    // show all status
                    else if ( +idx == 0 ) {
                        oTable.columns( COLUMN.Program_Sub_Status_ID ).search( '' )
                              .columns( 1 ).search( '' )
                              .draw();
                    }
                    // search for selected status
                    else {
                        oTable.columns( COLUMN.Program_Sub_Status_ID ).search( '' )
                              .columns( col ).search( regExSearch, true, false )
                              .draw();
                    }
                }
                else if ( col >= 0 && idx > 0 ){
                    regExSearch = '^' + txt +'$';
                    oTable.columns( col ).search( regExSearch, true, false ).draw();
                }
                else {
                    oTable.columns( col ).search( txt ).draw();
                }

                updateRecordCount();
            });

            $(function() {
                $("#btnCreateProgram").click(function() {
                    popupCenter2022("/common_files/select_new_program_type.cfm?bypassRSPSelect=1&fromRetailPlanner=1&plannerID=<cfoutput>#form.plannerID#</cfoutput>&customerID=<cfoutput>#getPlanner.BSA_FoodService_Customers_ID#</cfoutput>&Product_List_Type=<cfoutput>#form.product_group_level_id#</cfoutput>", "Program_create", "XL", "LG");
                });
            });

            $('#refresh_data').click(function () {
                $("input[name=action]").val("");
                show_loader( "REFRESHING DATA, PLEASE WAIT...");
                $("form[name=topnav]").submit();
            });

            $('#update_committed').click(function () {
                show_loader( "UPDATING PROGRAMS, PLEASE WAIT...");
                $("form[name=plannerScorecardForm]").submit();
            });

            $('#update_lost').click(function () {
                show_loader( "UPDATING PROGRAMS, PLEASE WAIT...");
                $("form[name=plannerScorecardForm]").submit();
            });

            $('#update_rfa').click(function () {
                show_loader( "UPDATING PROGRAMS, PLEASE WAIT...");
                $("form[name=plannerScorecardForm]").submit();
            });

            $('#delete_programs').click(function () {
                show_loader( "DELETING PROGRAMS, PLEASE WAIT...");
                $("form[name=plannerScorecardForm]").submit();
            });

            $('#release_settlement').click(function () {
                show_loader( "UPDATING PROGRAMS, PLEASE WAIT...");
                $("form[name=plannerScorecardForm]").submit();
            });

            var rightcolumn_width = $("#rightcolumn").css("width");
            $("#midcolumn").click(function(){
                if ( $("#leftcolumn").css("display") === "none" ) {
                    $("#fullscreen").hide();
                    $("#halfscreen, #leftcolumn").show();
                    $("#rightcolumn").css("width", rightcolumn_width);
                    $(this).html('<i class="ui-icon ui-icon-circle-triangle-w" title="click to collapse the filter options"></i>');
                }
                else {
                    $("#halfscreen, #leftcolumn").hide();
                    $("#fullscreen").show();
                    $("#rightcolumn").css("width", "100%");
                    $(this).html('<i class="ui-icon ui-icon-circle-triangle-e" title="click to expand the filter options"></i>');
                }
                $("div.dataTables_scrollHeadInner, table.dataTable").css("width", "100%");
            });

            <!--- hide LY in sales & trade when planner template is off --->

            $('div#midcolumn').css("height", Math.floor(jQuery(window).height()) - 92);


            // search button
            $("#btnSearch, #btnSearch2").click(function(){
                var cond = $('#condition_list').val();
                var txt  = $("input[name=txtProgram]").val().trim();
                var prod = $("input[name=txtProduct]").val().trim();

                // filter condition only when at least one condition is selected
                if (cond) {
                    aRenew 			= cond.includes("1"); if (aRenew == true) {oTable.columns( 17 ).search( "1" ).draw(); }
                    aRenewPairs 	= cond.includes("2");  if (aRenewPairs == true) {oTable.columns( 18 ).search( "1" ).draw(); }
                    bestPlanProgram = cond.includes("3");  if (bestPlanProgram == true) {oTable.columns( 19 ).search( "1" ).draw(); }
                    cancelled 		= cond.includes("4");  if (cancelled == true) { oTable.columns( 20 ).search( "1" ).draw(); }
                    disagreed  		= cond.includes("5");  if (disagreed == true) { oTable.columns( 21 ).search( "1" ).draw(); }
                    docAttached 	= cond.includes("6");  if (docAttached == true) { oTable.columns( 22 ).search( "1" ).draw(); }
                    notCancelled 	= cond.includes("7");  if (notCancelled == true) { oTable.columns( 23 ).search( "0" ).draw(); }
                     revision 	 	= cond.includes("8");  if (revision == true) { oTable.columns( 24 ).search( "1" ).draw(); }
                    expNoRevision 	= cond.includes("9");  if (expNoRevision == true) { oTable.columns( 25 ).search( "1" ).draw(); }
                    rollover	 	= cond.includes("10");  if (rollover == true) { oTable.columns( 26 ).search( "1" ).draw(); }
                    released	 	= cond.includes("11");  if (released == true) { oTable.columns( 27 ).search( "1" ).draw(); }
                    notReleased	 	= cond.includes("12");  if (notReleased == true) { oTable.columns( 28 ).search( "1" ).draw(); }
                    acknowledged	= cond.includes("13");  if (acknowledged == true) { oTable.columns( 29 ).search( "1" ).draw(); }
                    notAcknowledged = cond.includes("14");  if (notAcknowledged == true) { oTable.columns( 30 ).search( "1" ).draw(); }
                    uploaded	 	= cond.includes("15");  if (uploaded == true) { oTable.columns( 31 ).search( "1" ).draw(); }
                    restrictedBBNo  = cond.includes("16");  if (restrictedBBNo == true) { oTable.columns( 32 ).search( '0' ).draw(); }
                    restrictedBBYes = cond.includes("17");  if (restrictedBBYes == true) { oTable.columns( 33 ).search( "1" ).draw(); }
                }

                oTable.search( txt ).draw();
                oTable.columns( 16 ).search( prod ).draw();
                updateRecordCount();
            });

            // reset button
            $("#btnReset, #btnReset2").click(function(){
                resetActions();
                $("input.filter").val('');
                $("select.filter").val(0);
                $("#condition_list option:selected").prop("selected", false);
                oTable.search( '' ).draw();
                // reset segment filter
                oTable.columns( COLUMN.Segment ).search( '' )
                      .columns( COLUMN.Program_Sub_Status_ID ).search( '' )
                      .draw();
                updateRecordCount();
            });

            // reset actions
            resetActions = function(){
                for (var i = 1; i <= 33; i++) {
                    oTable.columns( i ).search( "" ).draw();
                }
                $("#update_lost").css("display", "none");
                $("#update_committed").css("display", "none");
                $("#update_rfa").css("display", "none");
                $("#delete_programs").css("display", "none");
                $("#release_settlement").css("display", "none");
            }

            updateRecordCount = function(){
                if ($(".templateId td").length == 0){
                    recCount = 0;
                }
                else{
                    recCount = eval($('#datagrid tr').length - 1);
                }
                $( ".prgSearchHdr" ).html("<cfoutput>#Application.PlannerPrgLabel#</cfoutput> Search Results: &nbsp; " + recCount + " records ");
            }

            $("#selActionFor").change(function(){
                var action = $(this).val();
                var recCount = 0;
                $("#update_lost").css("display", "none");
                $("#update_committed").css("display", "none");
                $("#update_rfa").css("display", "none");
                $("#delete_programs").css("display", "none");
                $("#release_settlement").css("display", "none");
                $("input[name=action]").val("");

                if (action == 1){
                    oTable.columns( 1 ).search( "Work|Ready", true).draw();
                    $("#delete_programs").css("display", "inline");
                    $("input[name=action]").val("deletePrograms");
                }
                else if (action == 2){
                    oTable.columns( 1 ).search( "Pending Accept" ).draw();
                    $("#update_committed").css("display", "inline");
                    $("input[name=action]").val("updateCommited");
                }
                else if (action == 3){
                    oTable.columns( 1 ).search( "Pending Accept" ).draw();
                    $("#update_lost").css("display", "inline");
                    $("input[name=action]").val("updateLost");
                }
                else if (action == 4){
                    oTable.columns( 1 ).search( "Work In Progress" ).draw();
                    $("#update_rfa").css("display", "inline");
                    $("input[name=action]").val("updateRFA");
                }
                else if (action == 5){
                    oTable.columns( 13 ).search( "1" ).draw();
                    $("#release_settlement").css("display", "inline");
                    $("input[name=action]").val("releaseSettlement");
                }
                else if (action == 0){
                    resetActions();
                }
                // show records count
                updateRecordCount();
            });

            $("#checkAll").change(function(){
                if($(this).prop("checked")){
                    $(".massAll").prop("checked", true);
                }
                else{
                    $(".massAll").prop("checked", false);
                }
            });

            <cfif isDefined("massRFAMessages")>
                dhtmlx.alert({
                    title:"RFA Programs",
                    type:"alert-error",
                    text: "<cfoutput>#massRFAMessages#</cfoutput>",
                    width: "600px"
                });
            </cfif>

            <cfif isDefined("massDeleteProgramMessages")>
                dhtmlx.alert({
                    title:"Delete Programs",
                    type:"alert-error",
                    text: "<cfoutput>#massDeleteProgramMessages#</cfoutput>",
                    width: "600px"
                });
            </cfif>

            function popupInCenter2( url, title, w, h ) {
                return popup2022( url, title, "XL", "XL", "center" );
            }

            <cfoutput>
            // clicking from rfa column on planner programs search result
            <cfif val(url.rfa) eq 999>
                // filter to show only rfa programs
                oTable.columns( 1 ).search( "Ready For Approval" ).draw();
                // show records count
                updateRecordCount();
            <cfelseif val(url.rfa) gte 101>
                // filter to show only
                oTable.columns( COLUMN.Program_Sub_Status_ID ).search( "#url.rfa#" ).draw();
                // show records count
                updateRecordCount();
            </cfif>
            </cfoutput>

        </script>

        <cfinclude template="\common_files\popup2022.cfm">

</cf_layout_planner>
