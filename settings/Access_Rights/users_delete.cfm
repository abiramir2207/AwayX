<!DOCTYPE HTML>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>

<body>   
    <cfparam name="form.blnSubmit" default="0">
    <cfset UsersIP = CGI.Remote_Addr>
    <style>
        th {
            background-color: lightsteelblue;
        }
        div.page_title {
            /* height: 30px; */
            padding: 10px;
            background-image: linear-gradient(to right, #010281 ,#a7caf2);
            color: #fff;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: .5px;
            width: 99.5%;
        }

        /* Card style */
        .details-card {
            width: 450px;
            margin: 10px 5px 20px 5px;
            background-color: #fff;
            border: 1px solid #d8d9dd;
            border-radius: 5px;
            box-shadow: 1px 1px 1px rgba(0,0,0, 0.3), -1px 0 1px rgba(0,0,0, 0.2);
        }
        .card-header {
            background-color: #ffedd2;
            /* border-radius: 5px 5px 0px 0px; */
            border-bottom: 1px solid #d8d9dd;
            color: #343540;
            font-size: 14px;
            font-weight: 600;
        }
            .card-header img {
                margin: 3px 10px 0 10px;
            }
            .card-header span {
                position: relative;
                top: -5px;
            }
        .card-main {
            font-size: 11px;
            min-height: 25px;
            padding-top:5px;
            padding-left:6px;
            padding-right:4px;
            padding-bottom:8px;
            width: 100%;
        }
        .card-main p {
            margin: 6px 6px 8px 0px;
        }
    </style>

    <!---- Reassign Programs --->
    <cfparam name="form.Responsible_User_Id_Position_Id" default="">
    <cfparam name="form.Reassign_User_Id__Primary_Position" default = "">
    <cfparam name="user_primaty_position" default = "0">
    <cfparam name="form.planner_rsp_id" default = "">

	<cfset useLakebaseForFindProgramstoReassign = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForFindProgramstoReassign>
	<cftry>
		<cfset FindProgramstoReassign = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"responsible_user_id" = "eq.#FORM.User_ID#",
				"deleted" = "eq.0",
				"planner_id" = "eq.0",
				"select" = "contract_main_id,contract_number"
			}), "contract_main_id,contract_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForFindProgramstoReassign = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForFindProgramstoReassign>
<cfquery name="FindProgramstoReassign" datasource="#application.datasource#">
        SELECT	Contract_Main_ID, Contract_Number
        FROM 	Contract_Main
        WHERE 	Responsible_User_ID = '#FORM.User_ID#' AND deleted = 0   <!---D28655: Deactivating users prog issue --->
                AND planner_id = 0
	</cfquery>
</cfif>

	<cfquery NAME="checkifanyprimaryPOSITIONS" datasource="#application.datasource#">
		SELECT DISTINCT user_positions_id
		  FROM user_position_holders
		 WHERE user_id = '#FORM.User_ID#'
		       AND deleted = 0
		       AND user_position_type = 'P'
		       AND user_positions_id NOT IN (SELECT user_positions_id
		                                       FROM user_position_holders
		                                      WHERE deleted = 0
		                                            AND user_id != '#FORM.User_ID#') 
	</cfquery>
	
	<cfquery name="BillbackAnalystCheck" datasource="#application.datasource#">
		SELECT DISTINCT Default_Analyst
		  FROM BB_Analyst
		       INNER JOIN Billback
		               ON Billback.Analyst_User_ID = BB_Analyst.Analyst_User_ID
		                  AND Billback.Deleted = 0
		 WHERE BB_Analyst.Analyst_User_ID = '#FORM.User_ID#'
		       AND BB_Analyst.Deleted = 0 
	</cfquery>
	
	<cfquery name="DeductionAnalystCheck" datasource="#application.datasource#">
		SELECT DISTINCT Default_Analyst
		  FROM DD_Analyst
		       INNER JOIN Deductions
		               ON Deductions.Analyst_User_ID = DD_Analyst.Analyst_User_ID
		                  AND Deductions.Deleted = 0
		 WHERE DD_Analyst.Analyst_User_ID = '#FORM.User_ID#'
		       AND DD_Analyst.Deleted = 0 
	</cfquery>

	<cfset useLakebaseForqPlanners = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planners")>
<cfif useLakebaseForqPlanners>
	<cftry>
		<cfset qPlanners = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planners", {
				"rsp_id" = "eq.#FORM.User_ID#",
				"deleted" = "eq.0",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqPlanners = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqPlanners>
<cfquery name="qPlanners" datasource="#application.datasource#">
		SELECT TOP 1 *
		  FROM Planners
		 WHERE Rsp_ID = '#FORM.User_ID#'
		       AND Deleted = 0 
	</cfquery>
</cfif>

	<cfset useLakebaseForqUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForqUser>
	<cftry>
		<cfset qUser = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#FORM.User_ID#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUser = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUser>
<cfquery name="qUser" datasource="#application.datasource#">
		SELECT Name_First, Name_Last
		  FROM _Users
		 WHERE User_ID = '#FORM.User_ID#'
	</cfquery>
</cfif>

	<cfif checkifanyprimaryPOSITIONS.recordcount GT 0>
		<cfset user_primaty_position = checkifanyprimaryPOSITIONS.user_positions_id>
	</cfif>
	
	<cfif form.blnSubmit IS NOT 1>
        <cfif FindProgramstoReassign.recordcount 
            or checkifanyprimaryPOSITIONS.recordcount
            or BillbackAnalystCheck.RecordCount
            or DeductionAnalystCheck.RecordCount
            or qPlanners.recordCount>

            
            <cfset userManager = CreateObject("component", "components.user.UserManager") />
            <cfset stStruct = StructNew() />
            <cfset stStruct.excludeUserIdList = FORM.User_ID />
            <cfset stStruct.userPositionType = "P,S" />
            <cfset stStruct.sortBy = "User_Positions.Position_Label,_Users.Name_First" />
            <cfset Users = userManager.search(stStruct) />
            
		    <cfoutput>
            <div class="page_title">Reassign #uCase(qUser.Name_First)# #uCase(qUser.Name_Last)#'s responsibilities to another user</div>
			
		    <form name="ReassignPrograms" action="users_delete.cfm" method="post">
		        <input type="hidden" name="blnSubmit" value="1">
			    <input type="hidden" name="User_ID" value="#Form.User_ID#">			

                <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!--- ~~~~~ Programs Reassignment ~~~~~~ --->
                <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <cfif FindProgramstoReassign.recordcount OR checkifanyprimaryPOSITIONS.recordcount>
                    <div class="details-card">
                        <div class="card-header">
                            <img src="/images/icon_programs.png"><span>Programs</span>
                        </div>
                    
                        <div class="card-main">
                            <cfif FindProgramstoReassign.recordcount>
                                <p>Select a person to reassign this user's programs to:</p>
                                <select name="Responsible_User_Id_Position_Id" id="Responsible_User_Id_Position_Id" class="multi">
                                    <option></option>
                                    <cfloop query="Users">
                                        <option value="#User_Positions_ID#_#USER_ID#">[#Position_Label#] #USER_FULL_NAME#</option>
                                    </cfloop>
                                </select>
                            </cfif>
                    
                            <cfif checkifanyprimaryPOSITIONS.recordcount>
                                <cfset useLakebaseForgetdistinctusers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("users")>
<cfif useLakebaseForgetdistinctusers>
	<cftry>
		<cfset getdistinctusers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("users", {
				"select" = "user_full_name,user_id"
			}), "user_full_name,user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetdistinctusers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetdistinctusers>
<cfquery NAME="getdistinctusers" dbtype="query">
                                    select distinct USER_FULL_NAME, user_id from Users
                                </cfquery>
</cfif>
                                <p>Select a person to reassign this user's primary position as secondary position:</p>
                                <select name="Reassign_User_Id__Primary_Position" id="Reassign_User_Id_Position" class="multi">
                                    <option></option>
                                    <cfloop query="getdistinctusers">
                                        <option value="#USER_ID#"> #USER_FULL_NAME#</option>
                                    </cfloop>
                                </select>
                            </cfif>
                        </div>
                    </div>
                </cfif>

		        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!--- ~~~~~~~ Billbacks Reassignment ~~~~~~~ --->
		        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        		<cfif BillbackAnalystCheck.recordcount gt 0>
                    <div class="details-card">
                        <div class="card-header">
                            <img src="/images/icon_billbacks.png"><span>Billbacks</span>
                        </div>
                    
                        <div class="card-main">
                            <cfquery name="OtherBillbackAnalysts" datasource="#application.datasource#">
                                SELECT Name_First + ' ' + Name_Last AS User_Full_Name,
                                       User_ID
                                  FROM _Users
                                       INNER JOIN BB_Analyst
                                               ON BB_Analyst.Analyst_User_ID = _Users.User_ID
                                                  AND BB_Analyst.Deleted = 0
                                 WHERE _Users.Deleted = 0
                                       AND _Users.User_ID != '#FORM.User_ID#'
                                 ORDER BY Name_Last,
                                          Name_First 
                            </cfquery>
        
                            <p>Select a person to reassign this user's billbacks to:</p>   
                            <select name="Reassign_Analyst_Billbacks" id="Reassign_User_Billbacks" class="multi">
                                <option></option>
                                <cfloop query="OtherBillbackAnalysts">
                                    <option value="#USER_ID#"> #USER_FULL_NAME#</option>
                                </cfloop>
                            </select>

                            <!--- Reassign default analyst --->
                            <cfif BillbackAnalystCheck.Default_Analyst eq 1>
                                <p>This user is the default billback analyst. Please select a new default analyst.</p>
                                <select name="NewBillbackAnalystDefault" id="Reassign_User_Billbacks" class="multi">
                                    <option></option>
                                    <cfloop query="OtherBillbackAnalysts">
                                        <option value="#USER_ID#"> #USER_FULL_NAME#</option>
                                    </cfloop>
                                </select>
                            </cfif>
                        </div>
                    </div>
                </cfif>
               


		        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!--- ~~~~~~~ Deductions Reassignment ~~~~~~~ --->
		        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <cfif DeductionAnalystCheck.RecordCount>
                    <div class="details-card">
                        <div class="card-header">
                            <img src="/images/icon_deductions.png"><span>Deductions</span>
                        </div>
                    
                        <div class="card-main">
                            <cfquery name="OtherDeductionAnalysts" datasource="#application.datasource#">
                                SELECT Name_First + ' ' + Name_Last AS User_Full_Name,
                                       User_ID
                                  FROM _Users
                                       INNER JOIN DD_Analyst
                                               ON DD_Analyst.Analyst_User_ID = _Users.User_ID
                                                  AND DD_Analyst.Deleted = 0
                                 WHERE _Users.Deleted = 0
                                       AND _Users.User_ID != '#FORM.User_ID#'
                                 ORDER BY Name_First,
                                          Name_Last 
                            </cfquery>
                            <p>Select a person to reassign this user's deductions to:</p>
                            <select name="Reassign_Analyst_Deductions" id="Reassign_User_Billbacks" class="multi">
                                <option></option>
                                <cfloop query="OtherDeductionAnalysts">
                                    <option value="#USER_ID#"> #USER_FULL_NAME#</option>
                                </cfloop>
                            </select>

                            <!--- Reassign default analyst --->
                            <cfif DeductionAnalystCheck.Default_Analyst IS 1>
                                <p>This user is the default deduction analyst. Please select a new default analyst.</p>
                                <select name="NewDeductionAnalystDefault" id="Reassign_User_Billbacks" class="multi">
                                    <option></option>
                                    <cfloop query="OtherDeductionAnalysts">
                                        <option value="#USER_ID#"> #USER_FULL_NAME#</option>
                                    </cfloop>
                                </select>
                            </cfif>
                        </div>
                    </div> 
                </cfif>
                
		        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!--- ~~~~~~~ Planners Reassignment ~~~~~~~ --->
		        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <cfif qPlanners.RecordCount>
                    <div class="details-card">
                        <div class="card-header">
                            <img src="/images/icon_planners.png"><span>Planners</span>
                        </div>
                    
                        <div class="card-main">
                            <p>Select a person to reassign this user's planners to:</p>
                            <select name="planner_rsp_id" class="multi">
                                <option></option>
                                <cfloop query="Users">
                                    <option value="#User_Positions_ID#_#USER_ID#">[#Position_Label#] #USER_FULL_NAME#</option>
                                </cfloop>
                            </select>
                        </div>
                    </div> 
                </cfif>

                <div style="margin:20px 0">
                    <button class="button recommended" onClick="ReassignPrograms.submit();return false;">Reassign and Delete user</button>
                </div>
		    </form>
            </cfoutput>
            
        <cfelse>
            <!---This user doesn't have any programs--->
            <cfquery NAME="deleteUser" datasource="#application.datasource#">
                UPDATE _Users
                SET deleted = 1,
                    deleted_date = Getdate(),
                    deleted_by = '#request.AccessStructure.user_id#',
                    profiles_id = 0
                WHERE User_ID = '#FORM.User_ID#' 
            </cfquery>

            <cfquery NAME="deleteUserPOSITIONS" datasource="#application.datasource#">
                UPDATE user_position_holders
                SET deleted = 1
                WHERE User_ID = '#FORM.User_ID#'
            </cfquery>

        <!--- 
            Dev Notes: 23086/Anand Rao/21-May-10
            User Traffic Changes
            --->
            <cfquery name="qGetUserCode" datasource="#application.datasource#">
                SELECT User_Code FROM _Users WHERE User_ID = <cfqueryparam value="#FORM.User_ID#" cfsqltype="CF_SQL_VARCHAR">
            </cfquery>

            <cfquery name="AddUserTransInActivate" datasource="#application.datasource#">
                INSERT INTO Audit_User_Transactions
                (
                            Trans_Type,
                            Trans_User_Code,
                            Trans_IP_Address,
                            Trans_By_User_ID
                )
                VALUES
                (
                            'INACTIVATE-USER',
                            < cfqueryparam value = "#qGetUserCode.User_Code#" cfsqltype = "CF_SQL_VARCHAR" > ,
                            < cfqueryparam value = "#UsersIP#" cfsqltype = "CF_SQL_VARCHAR" > ,
                            < cfqueryparam value = "#Request.AccessStructure.User_ID#" cfsqltype = "CF_SQL_VARCHAR" >
                )
            </cfquery>
        
            <cflocation url="/index.cfm?event=settings.users.dspUsers" />
        </cfif>

    <!---they just reassigned--->
    <cfelse>

        <cfif len(trim(form.Responsible_User_Id_Position_Id)) GT 0>
                <CFSET New_User_Position_ID = ListFirst(FORM.Responsible_User_Id_Position_Id, "_")>
                <cfset New_Responsible_User_Id = ListLast(FORM.Responsible_User_Id_Position_Id, "_")>
                <cfset useLakebaseForReassignPrograms = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForReassignPrograms>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"responsible_user_id" = "eq.#FORM.User_ID#"
			},
			{
				"responsible_user_id" = "#New_Responsible_User_Id#",
				"creating_user_position_id" = "#New_User_Position_ID#",
				"original_creating_user_position_id" = "Creating_User_Position_ID"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForReassignPrograms = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForReassignPrograms>
<cfquery name="ReassignPrograms" datasource="#application.datasource#">
                    UPDATE 	Contract_Main
                    SET 	Responsible_User_ID = '#New_Responsible_User_Id#',
                            Creating_User_Position_ID = #New_User_Position_ID#,
                            Original_Creating_User_Position_ID = Creating_User_Position_ID
                    WHERE 	Responsible_User_ID =  '#FORM.User_ID#'
                </cfquery>
</cfif>
                    
            <cfloop query="FindProgramstoReassign">
                <!--- If the progam is unapproved, make an entry to keep track of the sales person responsible --->
                
                <cfset useLakebaseForinsProgramOwner = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_owner")>
<cfif useLakebaseForinsProgramOwner>
	<cftry>
		<cfset application.oLakebase.insertRow("program_owner", {
			"contract_main_id" = "#FindProgramstoReassign.Contract_Main_ID#",
			"contract_number" = "#FindProgramstoReassign.Contract_Number#",
			"responsible_user_id" = "#New_Responsible_User_Id#",
			"creating_user_position_id" = "#New_User_Position_ID#",
			"reassigned_by" = "#request.AccessStructure.User_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsProgramOwner = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsProgramOwner>
<cfquery NAME="insProgramOwner" DATASOURCE="#application.datasource#">
                    INSERT INTO Program_Owner
                                (Contract_Main_ID,
                                Contract_Number,
                                Responsible_User_ID,
                                Creating_User_Position_ID,
                                Reassigned_By)
                        VALUES('#FindProgramstoReassign.Contract_Main_ID#',
                                '#FindProgramstoReassign.Contract_Number#',
                                '#New_Responsible_User_Id#',
                                '#New_User_Position_ID#',
                                '#request.AccessStructure.User_ID#') 
                </cfquery>
</cfif>
            
                <!---TSF: Label 10784 - When reassining delete all the temp files for the user being deleted. --->
                <cfif fileexists("#Application.Doc_Path#\Temp_Files\Program\View_Program_#FindProgramstoReassign.Contract_Main_ID#.htm")>
                    <cffile action = "delete" file = "#Application.Doc_Path#\Temp_Files\Program\View_Program_#FindProgramstoReassign.Contract_Main_ID#.htm">
                </cfif>
                
                <!--- D33597: Budget should get reassigned when program gets reassigned, if the app setting Budgets_Functionality_On is on --->
                <cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn() >
                    <cfset createObject('component','mvc.Models.AdvancedBudget.BudgetManager').updateBudgetForProgramReassign(programId = Contract_Main_ID) />
                </cfif>
            </cfloop> 
        </cfif>
        
		 <cfif isDefined("form.planner_rsp_id")>
		 	<cfset New_Planner_User_Position_ID = ListFirst(FORM.planner_rsp_id, "_")>
            <cfset New_Planner_Responsible_User_Id = ListLast(FORM.planner_rsp_id, "_")>
		 </cfif>
	
        <cfquery datasource="#application.datasource#">
            <cfif len(trim(form.Reassign_User_Id__Primary_Position)) GT 0>
                INSERT INTO user_position_holders
                            (user_positions_id,
                            user_id,
                            user_position_type)
                    VALUES (#user_primaty_position#,
                            '#form.Reassign_User_Id__Primary_Position#',
                            'S') 
            </cfif>
        
            <!--- Reassign analyst billbacks --->
            <cfif isDefined("Reassign_Analyst_Billbacks")>
                UPDATE Billback
                SET Analyst_User_ID = '#Reassign_Analyst_Billbacks#'
                WHERE Deleted = 0
                        AND Analyst_User_ID = '#FORM.User_ID#'
            </cfif>
        
            <!--- Reassign default billback analyst --->
            <cfif isDefined("NewBillbackAnalystDefault")>
                UPDATE BB_Analyst
                SET Default_Analyst = 1
                WHERE Analyst_User_ID = '#NewBillbackAnalystDefault#'
            </cfif>
        
            <!--- Mark user as deleted analyst --->
            <cfif isDefined("Reassign_Analyst_Billbacks") OR isDefined("NewBillbackAnalystDefault")>
                UPDATE BB_Analyst 
                SET Deleted = 1 
                WHERE Analyst_User_ID = '#FORM.User_ID#'
            </cfif>
        
            <!--- Reassign analyst deductions --->
            <cfif isDefined("Reassign_Analyst_Deductions")>
                UPDATE Deductions
                SET Analyst_User_ID = '#Reassign_Analyst_Deductions#'
                WHERE Deleted = 0
                        AND Analyst_User_ID = '#FORM.User_ID#'
            </cfif>

            <!--- Reassign default deduction analyst --->
            <cfif isDefined("form.NEWDEDUCTIONANALYSTDEFAULT")>
                UPDATE DD_Analyst
                SET Default_Analyst = 1
                Where Analyst_User_ID = '#NEWDEDUCTIONANALYSTDEFAULT#'
            </cfif>

            <!--- Reassign planners and planner programs --->
            <cfif isDefined("form.planner_rsp_id")>
                UPDATE Planners
                   SET RSP_ID = '#New_Planner_Responsible_User_Id#',
				   Creator_Position_ID = '#New_Planner_User_Position_ID#'
                 WHERE Deleted = 0 AND RSP_ID = '#FORM.User_ID#'

                UPDATE 	Contract_Main
                   SET 	Responsible_User_ID = '#New_Planner_Responsible_User_Id#'
                 WHERE 	Responsible_User_ID = '#FORM.User_ID#'
            </cfif>

            <!--- Delete as deduction analyst --->
            UPDATE DD_Analyst 
            SET Deleted = 1 
            WHERE Analyst_User_ID = '#FORM.User_ID#'

            UPDATE _Users
            SET deleted = 1,
                    deleted_date = getdate(),
                    deleted_by = '#request.AccessStructure.user_id#',
                    profiles_id = 0
            WHERE User_ID = '#FORM.User_ID#'

            UPDATE user_position_holders
            SET deleted = 1
            WHERE User_ID = '#FORM.User_ID#'

            <!--- 88344 Delete deduction assignments --->
            UPDATE DD_Assignment
            SET Deleted = 1
            WHERE Analyst_User_ID = '#FORM.User_ID#'
        </cfquery>
        
        <cflocation url="/index.cfm?event=settings.users.dspUsers" />	
    </cfif>

    <cfinclude template="/common_files/jQuery.cfm">
    <cfinclude template="/common_files/multiselect.cfm">

    <script>
        let multi_select_min_rows_filter = <cfoutput>#val(application.util.query.get_setting("multi_select_min_rows_filter", 0))#</cfoutput>;
        if (multi_select_min_rows_filter == 0) {
            multi_select_min_rows_filter = 10;
        }
        
        config.multiselect.header = [];
        config.multiselect.maxSelected = 1;
        config.multiselect.buttonWidth = 420;
        config.multiselect.selectedList = 1;
        config.multiselect.noneSelectedText = "Select an option";

        $("select.multi").each(function() {
            $(this).multiselect( config.multiselect );
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- ~ enable search feature when number of options in dropdown is large (customizable) ~ --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            if ($("option", this).length > multi_select_min_rows_filter) {
                $(this).multiselectfilter( { label: "Find", placeholder: "", width: "300px", autoReset: true } );
            }
        });
    </script>

</body>
</html>
