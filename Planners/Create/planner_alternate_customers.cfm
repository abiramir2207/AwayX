<!----------------------------------------------------------------------------------
Name         :  AwayX/Planners/Create/planner_alternate_customers.cfm
Copyright    :  (c) 2022 Blacksmith Applications, Inc.
Created Date :  18-Feb-2022
Created By   :  Anand Rao
Description  :  Main Screen for the alternate customer popup. The save/delete functionality
				and different tabs are housed in this page.
---------------------------------------------------------------------------------->

<cfparam name="URL.bEdit"	default="0" /> <!--- 1 = Edit; 0 = View --->
<cfparam name="form.plannerID" default="#URL.plannerID#" />
<cfparam name="form.grpSubmitted" default="0" />
<cfparam name="form.is_Group" default="0" />
<cfparam name="form.indDistSubmitted" default="0" />
<cfparam name="form.delAllClicked" default="0" />
<cfparam name="form.programID" default="0" />

<cfset clsliSelected = "nav active"/>
<cfset clsliGroup = "nav "/>
<cfset clsliIndv = "nav "/>

<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
<cfset local.programID = cryp.value />
<cfif local.programID EQ "0">
	<cfset local.programID = URL.programID />
	<cf_cryp type="en" key="#request.key#" string="#local.programID#">
	<cfset FORM.CID = cryp.value>
	<cfset URL.CID = FORM.CID>
</cfif>
<cfif (form.grpSubmitted EQ 1 AND isDefined("form.selectedItems") AND form.selectedItems NEQ "")>
	<cfloop index="DistGroupID" list="#form.selectedItems#">
		<cfquery name="qCheckDistGroupExists" datasource="#application.datasource#">
			/* User can check the checkbox, pick the alternate customer and then may not save the main page so updating this flag here also */
			UPDATE Contract_Main SET Alternate_Customer_ON = 1 WHERE Contract_Main_ID = #form.Contract_Main_ID#
			SELECT 1 AS rowExists
			FROM Contract_Distributors 
			WHERE 	BSA_Foodservice_Customers_ID = '#DistGroupID#' AND 
					Contract_Main_ID = '#form.Contract_Main_ID#' AND
					is_Group = '#form.is_Group#' AND
					Distributor_Group_Level_ID = '#form.Top_Level#' AND
					Distributor_Group_ID = '#DistGroupID#' AND
					Alternate_Customer_Flag = 1 AND
					Deleted = 0
		</cfquery>
		<cfif (isDefined("qCheckDistGroupExists") AND qCheckDistGroupExists.Recordcount EQ 0)>
			<cfquery name="qAddDistributorGroup" datasource="#application.datasource#">
				/* Remove all the rows that is not  Alternate_Customer_Flag = 0 (the default Distributor rows) first time, mainly */
				UPDATE Contract_Distributors SET Deleted = 1 WHERE Contract_Main_ID = '#form.Contract_Main_ID#' AND Alternate_Customer_Flag = 0
				INSERT INTO Contract_Distributors
				(BSA_Foodservice_Customers_ID, Contract_Main_ID, Program_Weight, Is_Group, Distributor_Group_Level_ID, Distributor_Group_ID, Alternate_Customer_Flag)
				VALUES
				('#DistGroupID#', '#form.Contract_Main_ID#', '100', '#form.is_Group#', '#form.Top_Level#', '#DistGroupID#', 1)
			</cfquery>
			<cfstoredproc procedure="CAPTURE_CUSTOMER_GROUPS" datasource="#application.datasource#">
				<cfprocparam type = "IN" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID"           value = "#form.Contract_main_ID#" />
				<cfprocparam type = "IN" CFSQLType="CF_SQL_DECIMAL" dbVarName = "@@PROGRAM_WEIGHT"             value = "100" />
				<cfprocparam type = "IN" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@DISTRIBUTOR_GROUP_LEVEL_ID" value = "#form.Top_Level#" />
				<cfprocparam type = "IN" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@DISTRIBUTOR_GROUP_ID"       value = "#DistGroupID#" />
				<cfprocparam type = "IN" CFSQLType="CF_SQL_BIT"     dbVarName = "@@DYNAMIC_STATIC_GROUPS"      value = "0" />
			</cfstoredproc>
		</cfif>
	</cfloop>
	<cfset form.grpSubmitted = 0 />
	<cfset local.programID = form.Contract_Main_ID />
	<cfquery name="calcUpdDistWeightGrp" datasource="#application.datasource#">
		DECLARE @Distributor_Count Float = 0,
		@Distributor_Weight decimal(10,2) = 0,
		@Distributor_Weight_Balance decimal(10,2) = 0;
		SELECT @Distributor_Count = COUNT(*) FROM Contract_Distributors WHERE Is_Group = 1 AND Deleted = 0 AND Contract_Main_ID = #form.Contract_Main_ID#				
		SELECT @Distributor_Weight = (100.0 / @Distributor_Count)
		SELECT @Distributor_Weight_Balance = (100.0 - (@Distributor_Weight * (@Distributor_Count-1)))
		/*  SELECT @Distributor_Weight Distributor_Weight, @Distributor_Weight_Balance Distributor_Weight_Balance */
		UPDATE Contract_Distributors SET Program_Weight = @Distributor_Weight WHERE Is_Group = 1 AND Deleted = 0 AND Contract_Main_ID = #form.Contract_Main_ID# 
		UPDATE 	TOP (1) Contract_Distributors
					SET 	Program_Weight = @Distributor_Weight_Balance
					WHERE 	Contract_Main_ID = #form.Contract_Main_ID# 
					AND  Deleted = 0 AND is_Group = 1 /* AND Alternate_Customer_Flag = 1 */
	</cfquery>
	<cfstoredproc procedure="Planner_Program_Product_Volume_From_Volume_Plan" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#form.Contract_main_ID#" null="no">
	</cfstoredproc>
</cfif>

<cfif (form.indDistSubmitted EQ 1 AND isDefined("form.selectedItems") AND form.selectedItems NEQ "")>
	<cfoutput>
	<cfquery name="calcDistWeight" datasource="#application.datasource#">
		DECLARE @Distributor_Count Float = 0,
		@Distributor_Weight decimal(10,2) = 0,
		@Distributor_Weight_Balance decimal(10,2) = 0;
		SELECT @Distributor_Count = #listLen(form.selectedItems)#						
		SELECT @Distributor_Weight = (100.0 / @Distributor_Count)
		SELECT @Distributor_Weight_Balance = (100.0 - (@Distributor_Weight * (@Distributor_Count-1)))
		SELECT @Distributor_Weight Distributor_Weight, @Distributor_Weight_Balance Distributor_Weight_Balance
	</cfquery>
	<cfquery name="qDelAllDists" datasource="#application.datasource#">
		/* Remove all the rows that is not  Alternate_Customer_Flag = 0 (the default Distributor rows) first time, mainly  */
		UPDATE Contract_Distributors SET Deleted = 1 WHERE Contract_Main_ID = '#form.Contract_Main_ID#'  AND Alternate_Customer_Flag = 0
	</cfquery>
	</cfoutput>
	<cfloop index="DistID" list="#form.selectedItems#">
		<!--- Check if the distributor already exists --->
		<cfquery name="qAddDistributor" datasource="#application.datasource#">
		/* User can check the checkbox, pick the alternate customer and then may not save the main page so updating this flag here also */
			UPDATE Contract_Main SET Alternate_Customer_ON = 1 WHERE Contract_Main_ID = #form.Contract_Main_ID#
			IF NOT EXISTS
			(	SELECT 1 
				FROM Contract_Distributors 
				WHERE 	BSA_Foodservice_Customers_ID = '#DistID#' AND 
						Contract_Main_ID = '#form.Contract_Main_ID#' AND
						Distributor_Group_Level_ID = 0 AND
						Alternate_Customer_Flag = 1 AND
						Deleted = 0
			)
			BEGIN
				INSERT INTO Contract_Distributors
					(BSA_Foodservice_Customers_ID, Contract_Main_ID, Program_Weight, Is_Group, Distributor_Group_Level_ID, Alternate_Customer_Flag)
				VALUES
					('#DistID#',#form.Contract_Main_ID#, '100', 0, 0 ,1)
			END
		</cfquery>
	</cfloop>
	<cfset form.indDistSubmitted = 0 />
	<!--- UPDATE Program_Weight FOR Individual --->
	<cfquery name="calcUpdDistWeightInd" datasource="#application.datasource#">
		DECLARE @Distributor_Count Float = 0,
		@Distributor_Weight decimal(10,2) = 0,
		@Distributor_Weight_Balance decimal(10,2) = 0;
		SELECT @Distributor_Count = COUNT(*) FROM Contract_Distributors WHERE Is_Group = 0 AND Deleted = 0 AND Contract_Main_ID = #form.Contract_Main_ID#				
		SELECT @Distributor_Weight = (100.0 / @Distributor_Count)
		SELECT @Distributor_Weight_Balance = (100.0 - (@Distributor_Weight * (@Distributor_Count-1)))
		/* SELECT @Distributor_Weight Distributor_Weight, @Distributor_Weight_Balance Distributor_Weight_Balance  */
		UPDATE Contract_Distributors SET Program_Weight = @Distributor_Weight WHERE Is_Group = 0 AND Deleted = 0 AND Contract_Main_ID = #form.Contract_Main_ID# 
		UPDATE 	TOP (1) Contract_Distributors
					SET 	Program_Weight = @Distributor_Weight_Balance
					WHERE 	Contract_Main_ID = #form.Contract_Main_ID# 
					AND  Deleted = 0 AND is_Group = 0 /* AND Alternate_Customer_Flag = 1 */
	</cfquery>
	<cfstoredproc procedure="Planner_Program_Product_Volume_From_Volume_Plan" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#form.Contract_main_ID#" null="no">
	</cfstoredproc>
</cfif>	

<cfif (form.delAllClicked EQ 1)>
	<cfquery name="qDelAllDists" datasource="#application.datasource#">
		UPDATE Contract_Distributors SET Deleted = 1 WHERE Contract_Main_ID = '#form.Contract_Main_ID#'
	</cfquery>
	<cfscript>
	stData	= structNew();
	stdata.plannerId = form.plannerID;
	New_Contract_Main_ID = form.Contract_Main_ID;
	</cfscript>
	<cfset oPlannerProgram 	= CreateObject("component", "mvc.Models.Planner.PlannerProgramManager") />
	<cfset updDistributor = oPlannerProgram.saveProgramPlannerDist(stdata,New_Contract_Main_ID) />
	<cfstoredproc procedure="Planner_Program_Product_Volume_From_Volume_Plan" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#form.Contract_main_ID#" null="no">
	</cfstoredproc>
</cfif> 

<cfoutput>
	<cfquery name="GetPrgAltDistInfo" datasource="#application.datasource#">
		SELECT * FROM Contract_Distributors WHERE Contract_Main_ID = #local.programID# AND Alternate_Customer_Flag = 1 AND Deleted = 0
	</cfquery>
</cfoutput>

<!--- Setting the tab display --->
<cfset clsliSelected = "nav active"/>
<cfset clsliGroup = "nav "/>
<cfset clsliIndv = "nav "/>

<cfif (URL.bEdit EQ 0)>
	<cfset clsliSelected = "nav active"/>
	<cfset clsliGroup 	 = "hidden "/>
	<cfset clsliIndv 	 = "hidden "/>
<cfelse>	
	<cfif (GetPrgAltDistInfo.RecordCount GTE 1)>
		<cfif ((find("1","#valuelist(GetPrgAltDistInfo.is_Group)#") GTE 1) OR (find("true","#valuelist(GetPrgAltDistInfo.is_Group)#") GTE 1) )>
			<cfset clsliSelected = "nav active"/>
			<cfset clsliGroup = "nav "/>
			<cfset clsliIndv = "hidden "/>
		<cfelse>
			<cfset clsliSelected = "nav active"/>
			<cfset clsliGroup = "hidden  "/>
			<cfset clsliIndv = "nav "/>
		</cfif>
	</cfif>
</cfif>

<html>
<head>
	<title>Planner Alternate Customers</title>
</head>

<body>
   <cfsavecontent variable="styles">
            <style>
                body {
                    overflow: hidden;
                    padding: 0px;
                    margin: 0;
                }
                iframe {
                    border: 0;
                    box-sizing: border-box;
                    width: 100%;
                    padding: 0;
                    height: 90vh;
                }
                header {
                    margin: 0;
                    padding: 0;
                }
                li.hidden {
                    display: none;
                }
                div#planner{
                    display:none;
                }
            </style>
            <cf_include files="/styles/tabnav-2020.css, /styles/css-loader.css">
        </cfsavecontent>
        <cfhtmlhead text="#application.util.string.compress( styles )#">

        <!--- Tabs Navigation --->
        <nav>
            <ul>
				<cfoutput><li name="selectedCus" class="#clsliSelected#" src="planner_alternate_customers.cfm?#application.util.list.queryString(url)#">Selected</li></cfoutput>
				<cfoutput><li name="selGroups" class="#clsliGroup#" src="planner_alternate_customers.cfm?#application.util.list.queryString(url)#">Select Groups</li></cfoutput>
                <cfoutput><li name="IndCustomers" class="#clsliIndv#">Select #application.returned_customer_setting.Shard_Ship_To_Label#s</li></cfoutput>
            </ul>
        </nav>
		   <!--- iframes --->
    <main>
        <cfoutput>
            <cfset selected_src = "selected_customers.cfm?programID=#local.ProgramID#&CID=#URL.CID#&plannerID=#url.plannerID#&bEdit=#URL.bEdit#&grpsubmitted=#form.grpSubmitted#">
			<cfset group_src = "select_customer_groups.cfm?CID=#URL.CID#&plannerID=#url.plannerID#&bEdit=#URL.bEdit#">
			<cfset indv_src = "select_customers.cfm?CID=#URL.CID#&plannerID=#url.plannerID#&bEdit=#URL.bEdit#">
			<iframe name="selectedCus" class="#clsliSelected#" src="#selected_src#"></iframe>						
           	<iframe name="selGroups" class="#clsliGroup#" src="#group_src#"></iframe>
            <iframe name="IndCustomers" class="#clsliIndv#" src="#indv_src#"></iframe>
        </cfoutput>
    </main>
	<br>

    <cfinclude template="/common_files/jQuery.cfm">
    <cfinclude template="/common_files/noty.cfm">

    <script>
        <!--- ~~~~~~~~~~ global variables defined inside 'glob' object ~~~~~~~~~~ --->
        let glob = { tab_counter: $("li.nav").length };

        function refresh_tab_name ( tab_name, tab_content_changed ) {
            let tab = get_navli( tab_name );
            if ( tab ) {
                let tab_title = tab.text();
                // add tab content changed indicator
                if ( tab_content_changed !== 1) {
                    tab.text( tab_title.replace("*", "") );
                }
                // save button was clicked, reset tab title
                else if (tab_title.indexOf("*") == -1) {
                    tab.text( tab_title + " * ");
                }
            }
        }

        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        function set_iframe_height( name ) {
            glob.iframe_height = $(window).innerHeight() - $("iframe:first-child")[0].offsetTop - 10;
            $("iframe" + (name ? "[name='" + name + "']" : '')).css("height", glob.iframe_height + "px");
        }

        <!---  get navigation jQuery element based on name  --->
        function get_navli( name ) {
            return $("li.nav[name='" + name + "']");
        }

        <!--- get iframe jQuery element based on name --->
        function get_iframe( name ) {
            return $("iframe[name='" + name + "']");
        }

        <!--- make active tab inactive, its iframe hidden --->
        function make_tabs_inactive() {
            // $("li.active").each(function(){
			$("li.nav").each(function(){
                $(this).removeClass("active");
                get_iframe( $(this).attr("name") ).hide();
            });
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~ tab click event handler ~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        $("nav").on("click", "li.nav", function(event){
            let clicked_tab = $(event.target);
            if ( !clicked_tab.hasClass("active") ) {
                let active_tab = $("li.active");
                let iframe = null;

                make_tabs_inactive();
                clicked_tab.addClass("active");

                iframe = get_iframe( clicked_tab.attr("name") );

                if (iframe.attr("src")) {
                }
                else {
                    <cfoutput>
                    if (iframe.attr("name") === 'program') {
						iframe.attr("src", "/Common_Files/contracts/Groups/group_items.cfm").removeClass("hidden");
                     /* //   iframe.attr("src", "/Common_Files/contracts/Groups/group_items.cfm"
                                                + "?Group_ID= url.group_id "
                                                + "&program_ID=## url.program_id ##"
                                                + "&showProgramItems=1"
                                                + "&tabs=1"
                                                + "&title=Program Group Items").removeClass("hidden"); */
                    }
                    </cfoutput>
                }
                iframe.show();
            }
        });

        <!--- ~~~~~~ make home tab active ~~~~~~ --->
        get_navli( "current" ).click();
        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        set_iframe_height();

        $(window).resize(function(){ 
            set_iframe_height(); 
        });
		
		function refreshAndCloseAltCustMain(){
			window.close();
		}
    </script>

    <cfset request.focusHiLightOff = 1>    
</body>
</html>