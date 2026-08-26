<!----------------------------------------------------------------------------------
Name         :	Planner_Perf_Types_Action.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/09/2016
Created By   : 	Anand Rao
Description  : 	Page to create NUC Targets
---------------------------------------------------------------------------------->
<cfparam name="form.default_use" default="0">

<cfset plannerSettingsManagerCFC = createObject("component", "mvc.Models.Planner.PlannerSettingsManager") />

<cfif FORM.display EQ "Active" AND FORM.command EQ "Save">
	<cfset perfTypesActive = plannerSettingsManagerCFC.getPerfTypeInfo(type="Active") />

	<cfscript>
		param name="form.Accrual" default="0";
		param name="form.allow_duplicate_programs" default="";
	</cfscript>

	<cfloop query="perfTypesActive">
		<cfparam name="form.Default_Use_#replace(perfTypesActive.Planner_Perf_Types_ID, "-", "_", "ALL")#" 				default="0">
		<cfscript>

			slotting_name     = "slotting_" & perfTypesActive.Planner_Perf_Types_ID;
			vSort_Order       = "Priority_" & replace(perfTypesActive.Planner_Perf_Types_ID, "-", "_", "ALL");
			vColor            = "ClrSelected_" & replace(perfTypesActive.Planner_Perf_Types_ID, "-", "_", "ALL");
			vDefault_Duration        = "Default_Duration_" & replace(perfTypesActive.Planner_Perf_Types_ID, "-", "_", "ALL");
			vDefault_Delivery_Days_Start        = "Default_Delivery_Days_Start_" & replace(perfTypesActive.Planner_Perf_Types_ID, "-", "_", "ALL");
			vDefault_Delivery_Days_End       = "Default_Delivery_Days_End_" & replace(perfTypesActive.Planner_Perf_Types_ID, "-", "_", "ALL");
			vDefault_Use = "Default_Use_" & replace(perfTypesActive.Planner_Perf_Types_ID, "-", "_", "ALL");
			vAllow_duplicate_programs = "allow_duplicate_programs_" & replace(perfTypesActive.Planner_Perf_Types_ID, "-", "_", "ALL");

			vSort_Order_value = form[ vSort_Order ];
			vColor_value      = form[ vColor ];
			isEveryDayPrice   = ( form.Everyday_Price eq perfTypesActive.Planner_Perf_Types_ID ? 1 : 0 );
			isAccrual   	= ( form.Accrual eq perfTypesActive.Planner_Perf_Types_ID ? 1 : 0 );
			bAllowDuplicatePrograms   	= form[ vAllow_duplicate_programs ];
			vDefault_Duration = 	form[ vDefault_Duration ];
			vDefault_Delivery_Days_Start = form[ vDefault_Delivery_Days_Start ];
			vDefault_Delivery_Days_End = form[ vDefault_Delivery_Days_End ];
			vDefault_Use = form[ vDefault_Use ];

			if(trim(vDefault_Duration) eq ""){
				vDefault_Duration = 0;
			}
			if(trim(vDefault_Delivery_Days_Start) eq ""){
				vDefault_Delivery_Days_Start = 0;
			}
			if(trim(vDefault_Delivery_Days_End) eq ""){
				vDefault_Delivery_Days_End = 0;
			}

			param name="form.#slotting_name#" default="";
			param name="form.allow_duplicate_programs" default="";
		</cfscript>

		<cfquery name="updPerfTypes" datasource="#application.datasource#">
			UPDATE Planner_Perf_Types
				SET
					Sort_Order		= #vSort_Order_value#,
					Color			= '#vColor_value#',
					Updated_Date	= GetDate(),
					Updated_By		= '#request.accessStructure.User_Id#',
					Everyday_Price	= '#isEveryDayPrice#',
					Slotting        = #(form[ slotting_name ] neq '' ? 1 : 0)#,
					Accrual			= '#isAccrual#',
					allow_duplicate_programs = #bAllowDuplicatePrograms#,
					Default_Duration = #vDefault_Duration#,
					Default_Delivery_Days_Start = #vDefault_Delivery_Days_Start#,
					Default_Delivery_Days_End = #vDefault_Delivery_Days_End#,
					Default_Use  = #vDefault_Use#
				WHERE   Planner_Perf_Types_ID = '#perfTypesActive.Planner_Perf_Types_ID#'
				AND Deleted = 0
		</cfquery>
	</cfloop>

<cfelseif FORM.display EQ "Active" AND FORM.command EQ "deactSel">
	<cfquery name="updPerfTypes" datasource="#application.datasource#">
		UPDATE Planner_Perf_Types
			SET
				Active = 0,
				Updated_Date	= GetDate(),
				Updated_By		= '#request.accessStructure.User_Id#'
			WHERE   Planner_Perf_Types_ID IN (#FORM.CID#)
			AND Deleted = 0
	</cfquery>

<cfelseif FORM.display EQ "inActive" AND FORM.command EQ "actSel">
	<cfquery name="updPerfTypes" datasource="#application.datasource#">
		UPDATE Planner_Perf_Types
			SET
				Active = 1,
				Updated_Date	= GetDate(),
				Updated_By		= '#request.accessStructure.User_Id#'
			WHERE Planner_Perf_Types_ID IN (#FORM.CID#)
			AND Deleted = 0
		</cfquery>
	<script>
		window.location.href = "index.cfm?iTab=inActive";
	</script>

<cfelseif FORM.display EQ "Active" AND FORM.command EQ "Add">
	<cfquery name="updPerfTypes" datasource="#application.datasource#">
		INSERT INTO Planner_Perf_Types(
			Description,
			Sort_Order,
			Color,
			Active,
			Deleted,
			Created_Date,
			Created_By,
			Slotting,
      allow_duplicate_programs,
			Default_Duration,
			Default_Delivery_Days_Start,
			Default_Delivery_Days_End,
			Default_Use
			)
			VALUES
			(
				'#FORM.txtDescription#',
				#FORM.curSortOrder#,
				'#FORM.ClrSelected#',
				1,
				0,
				GETDATE(),
				'#REQUEST.AccessStructure.User_ID#',
				#( structKeyExists(form, "slotting") ? 1 : 0 )#,
				#( structKeyExists(form, "allow_duplicate_programs") ? 1 : 0 )#,
				#FORM.Default_Duration#,
				#FORM.Default_Delivery_Days_Start#,
				#FORM.Default_Delivery_Days_End#,
				#FORM.Default_Use#
			)
	</cfquery>

<cfelseif FORM.display EQ "Active" AND FORM.command EQ "Edit">
 	<cfquery name="updPerfTypes" datasource="#application.datasource#">
			UPDATE Planner_Perf_Types
				SET
					Sort_Order		= #FORM.CurSortOrder#,
					Color			= '#FORM.ClrSelected#',
					Description		= '#FORM.txtDescription#',
					Slotting        = #( structKeyExists(form, "slotting") ? 1 : 0 )#,
					allow_duplicate_programs = #(structKeyExists(form, "allow_duplicate_programs") ? 1 : 0)#,
					Updated_Date	= GetDate(),
					Updated_By		= '#request.accessStructure.User_Id#',
					Default_Duration = 	#FORM.Default_Duration#,
					Default_Delivery_Days_Start = #FORM.Default_Delivery_Days_Start#,
					Default_Delivery_Days_End = #FORM.Default_Delivery_Days_End#,
					Default_Use = #FORM.Default_Use#
				WHERE Planner_Perf_Types_ID = '#FORM.Planner_Perf_Types_ID#'
				AND Deleted = 0
		</cfquery>
</cfif>

<script>
	window.location.href = "index.cfm?iTab=Active";
</script>