<!---
planner_program_open.cfm
---->

<cfparam name="url.program_id" 	    default="">
<cfparam name="url.planner_id" 	    default="">
<cfparam name="url.template_id" 	default="">
<!--- D113406 :: bLock -> STAGE2 Program Search Page.  Modify some behaviors and fix issues related to locking and Status filters --->
<cfparam name="url.bLock"           default="0">

<cfif url.program_id eq "" or url.planner_id eq "">
    <cfabort>
</cfif>

<cfset plannerManager = createObject( "component", "mvc.Models.Planner.PlannerManager" )>
<cfset Lock = createObject("component", "components.general.lock")>
<cfset getPlanner = plannerManager.getPlanner(url.planner_id)>
<cfset plannerLock = Lock.getStatus("Planner", url.planner_id)>
    <!--- D113406 :: STAGE2 Program Search Page.  Modify some behaviors and fix issues related to locking and Status filters 
    		This try catch issue was probably due to test data where Programs were deleted = 0 while the Planner Is Deleted = 1.
    --->
    <cfscript>
            try {
                defaultProductFilterAttr      = plannerManager.productFilterAttributes( getPlanner.Planner_Template_ID, 1 );
            }
            catch (any e) {
                writeDump("INVALID Planner_Template_ID: -#getPlanner.Planner_Template_ID#- :");
                abort;
            }
    </cfscript>
<cfset product_group_level_id = 9>
    <cfif defaultProductFilterAttr.recordCount>
        <cfif defaultProductFilterAttr.lookupTable eq "Brand" >
            <cfset product_group_level_id =13>
        <cfelseif defaultProductFilterAttr.lookupTable eq "Q_Brand_Desc" >
            <cfset roduct_group_level_id = 11>
        <cfelseif defaultProductFilterAttr.lookupTable eq "Type_Code_Desc"  >
            <cfset product_group_level_id = 12>
        <cfelseif  defaultProductFilterAttr.lookupTable eq "Type_Group_Desc" >
            <cfset product_group_level_id = 8>
        <cfelseif  defaultProductFilterAttr.lookupTable eq "Prod_Var_A"  >
            <cfset product_group_level_id = 15>
        </cfif>
    </cfif>
                                                        <!--- D113406 :: URL.bLock -> Program Search Page.  Modify some behaviors and fix issues related to locking and Status filters --->
    <cfif ! plannerLock.Is_Locked AND URL.bLock EQ 1>   <!--- IF PLANNER IS NOT LOCKED, WE WILL LOCK IT , PASSED bLock=1---->
       <cfset lockPlanner = Lock.lock("Planner", url.planner_id)>
       <cfset sURL = "/planners/create/planner_program_create.cfm?fromProgramSearch=1&programId=#url.program_id#&plannerID=#url.planner_id#&customerID=#getPlanner.BSA_FoodService_Customers_ID#&templateId=#template_id#&Product_List_Type=#product_group_level_id#&bInit=1&bLock=1" />
    <cfelse> <!--- IF PLANNER IS LOCKED, WE CHECK IF USER LOCK IT, IF YES CURRENT USER CAN EDIT PROGRAM, IF NO WE WILL NOT LET USER PUT PROGRAM IN EDIT MODE, PASSED bLock=0---->
        <cfif ! plannerLock.Locked_By_Other>                                                                                                                                                                                <!--- D113406 ::  Default to "Programs" from the Scorecard to NOT LOCK*/ --->
            <cfset sURL = "/planners/create/planner_program_create.cfm?fromProgramSearch=1&programId=#url.program_id#&plannerID=#url.planner_id#&customerID=#getPlanner.BSA_FoodService_Customers_ID#&templateId=#template_id#&Product_List_Type=#product_group_level_id#&bInit=1&bLock=0" />
        <cfelse>
            <cfset sURL = "/planners/create/planner_program_create.cfm?fromProgramSearch=1&programId=#url.program_id#&plannerID=#url.planner_id#&customerID=#getPlanner.BSA_FoodService_Customers_ID#&templateId=#template_id#&Product_List_Type=#product_group_level_id#&bInit=1&bLock=0" />
        </cfif>
    </cfif>

  <!--- URl taken from planner_scorecard.cfm ---->
<cflocation url="#sURL#" addToken="No" />