<!--- 14363-32470-12748-79810 ----------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<!--- The possibilities for the search query -------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------------
New, start date < 30 days old												66506-53122-68190-18792
Expiring, end date coming up (status 6)										21866-48048-53685-98323
Ready for Approval (CRA for this user)										48843-25185-52768-72116
Big programs (top 25 committed dollars)										12665-92034-26217-45059
All	programs																45640-28601-32997-26470
Custom: string,template,budget etc											41970-74841-13362-76384
----------------------------------------------------------------------------------------------- --->




<CFPARAM NAME="id" DEFAULT='45640-28601-32997-26470'>
<cfparam name="selection_type" default="All Active & Ready for Approval Programs">





<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->




<CFINCLUDE TEMPLATE="/scorecard/access_permissions.cfm">
<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />

<cfset  businessSegmentsOn = 0 />
<cfset  businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset  Business_Segment_ID_List = "">
<cfif businessSegManager.isEnabled()>
      <cfset businessSegmentsOn = 1 />
      <cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.user_id) />
      <cfset Business_Segment_ID_List = ValueList(qGetBusSegments.Business_Segment_ID, ",")>
</cfif>                       

<cfsavecontent variable="base_query">
<cfoutput>
if object_id('tempdb..##Positions_Below_Me') is not null 
drop table ##Positions_Below_Me 

Create  table ##Positions_Below_Me
(
  Below_User_Positions_ID   int          NOT NULL
)
<cfif NOT HQUser><!--- If HQ user no need to check for position --->
CREATE  CLUSTERED  INDEX [I_Below_User_Positions_ID_tmp] ON [dbo].[##Positions_Below_Me]([Below_User_Positions_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

INSERT INTO ##Positions_Below_Me(Below_User_Positions_ID)
SELECT      DISTINCT Below_User_Positions_ID
FROM  Positions_Below_Me
WHERE User_Positions_ID IN (#UserPositionList#)
</cfif>


if object_id('tempdb..##Profile_Forbidden_Template') is not null 
drop table ##Profile_Forbidden_Template 

Create  table ##Profile_Forbidden_Template
(
  template_id int not null
)

INSERT INTO  ##Profile_Forbidden_Template(Template_ID)
<!------ forbit type=1, forbid, 0=allow ----->
<cfif forbidType EQ 1>
SELECT DISTINCT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
FROM Program_Control_Panel_Options
LEFT JOIN Profile_Forbidden_Template
ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
AND Profile_Forbidden_Template.Forbid_Access_Type = 1
AND Profile_Forbidden_Template.deleted = 0
AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
AND Profile_Forbidden_Template.profile_id = #request.AccessStructure..Profiles_ID#
<!--- Show me the templates, which are not in the "Profile_Forbidden_Template" table --->
WHERE Profile_Forbidden_Template.template_id IS NULL

<cfelse>

SELECT DISTINCT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
FROM Program_Control_Panel_Options
INNER JOIN Profile_Forbidden_Template
ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
WHERE Profile_Forbidden_Template.deleted = 0
AND Profile_Forbidden_Template.Forbid_Access_Type = 1
AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
AND Profile_Forbidden_Template.profile_id = #request.AccessStructure..Profiles_ID#
</cfif>

CREATE  CLUSTERED  INDEX [I_Profile_Forbidden_Template_tmp] ON [dbo].[##Profile_Forbidden_Template]([Template_ID]) 
WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

SELECT            dbo.Contract_Main.Contract_Main_ID,
            dbo.Contract_Main.Contract_Number,
            dbo.Contract_Main.Contract_Title,
            dbo.Contract_Main.ProgramType_ID,
            dbo.Program_Control_Panel_Options.Created_Type,
            dbo._Users.Name_First,
            dbo._Users.Name_Last,
                  dbo.Contract_Main_Aux_Data.Program_Spend,
            
            
            -- block used to get the total number of cases ----------------------------------------------------
            (
            SELECT      ISNULL(Sum(Cast(IsNull(Volume_cs, 0) * (Datediff(d, CM.Contract_Start_Date, CM.Contract_End_Date) + 1) / 7 AS DECIMAL(20,0 ))), 0) As Cases
            FROM  Contract_Main CM
            INNER JOIN Program_Product_Volume
            ON          Program_Product_Volume.Program_ID = CM.Contract_Main_ID
            AND         Program_Product_Volume.Deleted = 0
            AND         Program_Product_Volume.Is_Group = 0
            AND         EXISTS 
            ( 
            SELECT 1
            FROM               CONTRACT_PRODUCTS cp
            WHERE             cp.Contract_Main_Id = Program_Product_Volume.Program_Id
            AND                   cp.Deleted = 0
            AND                   cp.bsa_FoodService_Items_Master_Id = Program_Product_Volume.bsa_FoodService_Items_Master_Id 
            )
            WHERE CM.Contract_Main_ID = Contract_Main.Contract_Main_ID
            ) as cases,
            -- end of the cases subquery ----------------------------------------------------------------------






          -- Committed as a subquery in the select
          (
            SELECT  
                    Sum ( CASE WHEN Isnull( Budget.Allocation_Position_Level, 0 ) = 4 THEN Budget_Distributor_Program.Committed_Dollar ELSE Budget_Position_Program.Committed_Dollar END ) AS Committed_Dollar
            FROM   Contract_Main All_Versions -- We will get budget and actual dollar from all versions of the program
                    INNER JOIN Budget_Program_Selection
                    ON Budget_Program_Selection.Program_Id = All_Versions.Contract_Main_Id
                    INNER JOIN Budget
                    ON Budget.Budget_Id = Budget_Program_Selection.Budget_Id
                    LEFT JOIN Budget_Position_Program
                    ON Budget_Position_Program.Contract_Main_Id = All_Versions.Contract_Main_Id
                    AND Budget_Position_Program.Budget_ID = Budget_Program_Selection.Budget_ID
                    AND Isnull( Budget.Allocation_Position_Level, 0 ) != 4
                    LEFT JOIN Budget_Distributor_Program
                    ON Budget_Distributor_Program.Contract_Main_Id = All_Versions.Contract_Main_Id
                    AND Budget_Distributor_Program.Budget_ID = Budget_Program_Selection.Budget_ID
                    AND Isnull( Budget.Allocation_Position_Level, 0 ) = 4
            WHERE  All_Versions.Contract_Number = Contract_Main.Contract_Number
                    AND All_Versions.Approved = 1
          ) as Committed_Dollar












FROM        dbo.Contract_Main

INNER JOIN ##Profile_Forbidden_Template ON Contract_Main.ProgramType_ID = ##Profile_Forbidden_Template.Template_ID
INNER JOIN dbo.Program_Control_Panel_Options ON dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = dbo.Contract_Main.ProgramType_ID
LEFT JOIN dbo._Users ON dbo._Users.User_ID = dbo.Contract_Main.Responsible_User_ID
INNER JOIN dbo.Contract_Main_Aux_Data ON dbo.Contract_Main_Aux_Data.Contract_Main_ID = dbo.Contract_Main.Contract_Main_ID

WHERE       dbo.Contract_Main.Deleted = 0 
                  
            AND 
            dbo.Contract_Main.Contract_Status_Type_IDX IN (2,5,6)-- 2=rfa, 5=active, 6=expiring

            <!--- AND   dbo.Contract_Main.Contract_Start_Date < getdate()
            AND   dbo.Contract_Main.Contract_End_Date > getdate() --->

            <cfif IsNumeric(appSettings.getExpiredRecentlyDays())>
                  AND  Contract_Main.Contract_End_Date >= DateAdd(d,- #appSettings.getExpiredRecentlyDays()#,getDate())
            </cfif>

            <cfif businessSegmentsOn EQ 1>
                  <cfif Len(Business_Segment_ID_List) GT 0>
                        AND Contract_Main.Business_Segment_ID IN (#Business_Segment_ID_List#)
                  <cfelse>
                        AND 1=2
                  </cfif>
            </cfif>
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!------ Access permissions start ----->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
                  AND ( 
                                    Contract_Main.Creating_User_Position_ID IN (#UserPositionList#)
                                    OR
                                    (
                                          Contract_Main.Contract_Status_Type_IDX > 1
                                          <cfif NOT HQUser><!--- If HQ user no need to check for position --->
                                          AND Contract_Main.Creating_User_Position_ID IN (#GP_Position_List_From_My_Position_Down_SC#)
                                          </cfif>
                                    )
                                    OR
                                    (
                                          Contract_Main.Contract_Status_Type_IDX >= 3
                                          <cfif NOT HQUser><!--- If HQ user no need to check for position --->                         
                                          AND
                                          (
                                                1=2
                                                OR EXISTS 
                                                (
                                                SELECT      Contract_Distributors.Contract_Main_ID
                                                FROM  Contract_Distributors                                             
                                                INNER JOIN BSA_Foodservice_Customers
                                                ON      BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
                                                AND   BSA_Foodservice_Customers.Deleted = 0
                                                INNER JOIN BSA_Foodservice_Brokers
                                                ON      BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
                                                INNER JOIN User_Positions
                                                ON    User_Positions.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID
                                                AND   User_Positions.Deleted = 0
                                                AND   User_Positions.User_Positions_ID IN (SELECT Below_User_Positions_ID FROM ##Positions_Below_Me)
                                                WHERE Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
                                                and   Contract_Distributors.Deleted = 0 
                                                )
                                                OR EXISTS 
                                                (
                                                SELECT      Contract_Brokers.Contract_Main_ID
                                                FROM  Contract_Brokers                                            
                                                INNER JOIN BSA_Foodservice_Brokers
                                                ON      BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Contract_Brokers.BSA_Foodservice_Brokers_ID
                                                INNER JOIN User_Positions
                                                ON    User_Positions.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID
                                                AND   User_Positions.Deleted = 0
                                                AND   User_Positions.User_Positions_ID IN (SELECT Below_User_Positions_ID FROM ##Positions_Below_Me)
                                                WHERE Contract_Brokers.Contract_Main_ID = Contract_Main.Contract_Main_ID
                                                and   Contract_Brokers.Deleted = 0 
                                                )                                                                       
                                          )
                                          </cfif>
                                    )                                   
                              )
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!------ Access permissions end     ----->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
</cfoutput>
</cfsavecontent>





<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->







<cfswitch expression="#id#">



	<!--- New - Started within last 30 days --->
    <cfcase value="66506-53122-68190-18792">
        <cfset selection_type	=	"New - Started within last 30 days">
        <cfsavecontent variable="criteria">
            AND
            DATEDIFF(day,dbo.Contract_Main.Contract_Start_Date,getdate()) < 30
        </cfsavecontent>
	</cfcase>



	
    <!--- Expiring - Ending within 30 days --->
    <cfcase value="21866-48048-53685-98323">
        <cfset selection_type	=	"Expiring - Ending within 30 days">
        <cfsavecontent variable="criteria">
            AND
			dbo.Contract_Main.Contract_Status_Type_IDX IN (6)-- 2=rfa, 5=active, 6=expiring
        </cfsavecontent>
	</cfcase>


	
    <!--- CRA - Ready for Approval Programs --->
    <cfcase value="48843-25185-52768-72116">
        <cfset selection_type	=	"CRA - Ready for Approval Programs">
        
        <cfsavecontent variable="criteria">

            AND 
            dbo.Contract_Main.Contract_Status_Type_IDX IN (2)-- 2=rfa, 5=active, 6=expiring

        </cfsavecontent>
	</cfcase>



    <!--- Big - Top 25 committed dollars --->
    <cfcase value="12665-92034-26217-45059">
        <cfset selection_type	=	"Big - Top 25 committed dollars">
        <cfset criteria	=	"">
        <cfsavecontent variable="base_query">
	if object_id('tempdb..#Positions_Below_Me') is not null 
	drop table #Positions_Below_Me 

	Create  table #Positions_Below_Me
	(
		Below_User_Positions_ID   int          NOT NULL
	)
	<cfif NOT HQUser><!--- If HQ user no need to check for position --->
		CREATE  CLUSTERED  INDEX [I_Below_User_Positions_ID_tmp] ON [dbo].[#Positions_Below_Me]([Below_User_Positions_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

		INSERT INTO #Positions_Below_Me(Below_User_Positions_ID)
		SELECT      DISTINCT Below_User_Positions_ID
		FROM  Positions_Below_Me
		WHERE User_Positions_ID IN (<cfoutput>#UserPositionList#</cfoutput>)
	</cfif>

SELECT TOP 25
            dbo.Contract_Main.Contract_Main_ID,
            dbo.Contract_Main.Contract_Number,
            dbo.Contract_Main.Contract_Title,
            dbo.Contract_Main.ProgramType_ID,
            dbo.Program_Control_Panel_Options.Created_Type,
            dbo._Users.Name_First,
            dbo._Users.Name_Last,
            dbo.Contract_Main_Aux_Data.Program_Spend,
                  (
                        SELECT      ISNULL(Sum(Cast(IsNull(Volume_cs, 0) * (Datediff(d, CM.Contract_Start_Date, CM.Contract_End_Date) + 1) / 7 AS DECIMAL(20,0 ))), 0) As Cases
                        FROM  Contract_Main CM
                        INNER JOIN Program_Product_Volume
                        ON          Program_Product_Volume.Program_ID = CM.Contract_Main_ID
                        AND         Program_Product_Volume.Deleted = 0
                        AND         Program_Product_Volume.Is_Group = 0
                        AND         EXISTS 
                              ( 
                                                      SELECT 1
                                    FROM               CONTRACT_PRODUCTS cp
                                    WHERE             cp.Contract_Main_Id = Program_Product_Volume.Program_Id
                                    AND                   cp.Deleted = 0
                                    AND                   cp.bsa_FoodService_Items_Master_Id = Program_Product_Volume.bsa_FoodService_Items_Master_Id 
                              )
                        WHERE CM.Contract_Main_ID = Contract_Main.Contract_Main_ID
                  ) as Cases,

                  -- Committed as a subquery in the select
                  (
					SELECT  
							Sum ( CASE WHEN Isnull( Budget.Allocation_Position_Level, 0 ) = 4 THEN Budget_Distributor_Program.Committed_Dollar ELSE Budget_Position_Program.Committed_Dollar END ) AS Committed_Dollar
					FROM   Contract_Main All_Versions -- We will get budget and actual dollar from all versions of the program
							INNER JOIN Budget_Program_Selection
							ON Budget_Program_Selection.Program_Id = All_Versions.Contract_Main_Id
							INNER JOIN Budget
							ON Budget.Budget_Id = Budget_Program_Selection.Budget_Id
							LEFT JOIN Budget_Position_Program
							ON Budget_Position_Program.Contract_Main_Id = All_Versions.Contract_Main_Id
							
							AND Budget_Position_Program.Budget_ID = Budget_Program_Selection.Budget_ID
							
							AND Isnull( Budget.Allocation_Position_Level, 0 ) != 4
							LEFT JOIN Budget_Distributor_Program
							ON Budget_Distributor_Program.Contract_Main_Id = All_Versions.Contract_Main_Id
							
							AND Budget_Distributor_Program.Budget_ID = Budget_Program_Selection.Budget_ID
							
							AND Isnull( Budget.Allocation_Position_Level, 0 ) = 4
					WHERE  All_Versions.Contract_Number = Contract_Main.Contract_Number
							AND All_Versions.Approved = 1
                  ) as Committed_Dollar
                  
FROM                   dbo.Contract_Main

INNER JOIN dbo.Program_Control_Panel_Options ON dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = dbo.Contract_Main.ProgramType_ID
INNER JOIN dbo._Users ON dbo._Users.User_ID = dbo.Contract_Main.Responsible_User_ID
INNER JOIN dbo.Contract_Main_Aux_Data ON dbo.Contract_Main_Aux_Data.Contract_Main_ID = dbo.Contract_Main.Contract_Main_ID

WHERE       dbo.Contract_Main.Deleted = 0 
            AND dbo.Contract_Main.Contract_Status_Type_IDX IN (5, 6)
            AND	dbo.Contract_Main.Contract_Start_Date < getdate()
            AND	dbo.Contract_Main.Contract_End_Date > getdate()




			-- -------------------------------------------------------------------------------------------------------------------------
			-- used to filter by position
			-- -------------------------------------------------------------------------------------------------------------------------
              AND ( 
                        Contract_Main.Creating_User_Position_ID IN (<cfoutput>#UserPositionList#</cfoutput>)
                        OR
                        (
                              Contract_Main.Contract_Status_Type_IDX > 1
                              <cfif NOT HQUser><!--- If HQ user no need to check for position --->
                              AND Contract_Main.Creating_User_Position_ID IN (<cfoutput>#GP_Position_List_From_My_Position_Down_SC#</cfoutput>)
                              </cfif>
                        )
                        OR
                        (
                          Contract_Main.Contract_Status_Type_IDX >= 3
                          <cfif NOT HQUser><!--- If HQ user no need to check for position --->                         
                          AND
                          (
                                1=2
                                OR EXISTS 
                                (
                                SELECT      Contract_Distributors.Contract_Main_ID
                                FROM  Contract_Distributors                                             
                                INNER JOIN BSA_Foodservice_Customers
                                ON      BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
                                AND   BSA_Foodservice_Customers.Deleted = 0
                                INNER JOIN BSA_Foodservice_Brokers
                                ON      BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
                                INNER JOIN User_Positions
                                ON    User_Positions.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID
                                AND   User_Positions.Deleted = 0
                                AND   User_Positions.User_Positions_ID IN (SELECT Below_User_Positions_ID FROM #Positions_Below_Me)
                                WHERE Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
                                and   Contract_Distributors.Deleted = 0 
                                )
                                OR EXISTS 
                                (
                                SELECT      Contract_Brokers.Contract_Main_ID
                                FROM  Contract_Brokers                                            
                                INNER JOIN BSA_Foodservice_Brokers
                                ON      BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Contract_Brokers.BSA_Foodservice_Brokers_ID
                                INNER JOIN User_Positions
                                ON    User_Positions.Service_market_ID = BSA_Foodservice_Brokers.Service_market_ID
                                AND   User_Positions.Deleted = 0
                                AND   User_Positions.User_Positions_ID IN (SELECT Below_User_Positions_ID FROM #Positions_Below_Me)
                                WHERE Contract_Brokers.Contract_Main_ID = Contract_Main.Contract_Main_ID
                                and   Contract_Brokers.Deleted = 0 
                                )                                                                       
                          )
                          </cfif>
                        )                                   
                  )
			-- -------------------------------------------------------------------------------------------------------------------------
			-- -------------------------------------------------------------------------------------------------------------------------
			-- -------------------------------------------------------------------------------------------------------------------------






	-- ORDER BY    Committed_Dollar DESC



        </cfsavecontent>
	</cfcase>

	<!--- Programs matching your custom criteria --->
    <cfcase value="41970-74841-13362-76384">
        <cfset selection_type	=	"Programs matching your custom criteria">
		
        <cfparam name="form.budget" default="">

        <cfsavecontent variable="criteria">
			<cfif form.budget neq "">
            AND   
            EXISTS 
            (
            SELECT  1
            FROM	Contract_Main All_Versions
            INNER	JOIN Budget_Program_Selection
            ON		Budget_Program_Selection.Program_Id = All_Versions.Contract_Main_Id
                    AND	Budget_Program_Selection.Budget_Id IN (<cfoutput>#form.budget#</cfoutput>)                     

            WHERE	All_Versions.Contract_Number = Contract_Main.Contract_Number
                    AND	All_Versions.Approved = 1
            )
			</cfif>

			AND
            (
            dbo.Contract_Main.Contract_Number like '%<cfoutput>#form.searchfor#</cfoutput>%'
            OR
            dbo.Contract_Main.Contract_Title like '%<cfoutput>#form.searchfor#</cfoutput>%'
            )
		</cfsavecontent>

	</cfcase>

    <cfdefaultcase>
        <cfset selection_type	=	"All - Active & Ready for Approval Programs">
        <cfsavecontent variable="criteria">
            AND
            1 = 1
        </cfsavecontent>
	</cfdefaultcase>

</cfswitch>



<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_programs" datasource="#Application.Datasource#">

			-- ---------------------------------------
            #preservesinglequotes(base_query)#
			-- ---------------------------------------

			-- ---------------------------------------
            #preservesinglequotes(criteria)#
			-- ---------------------------------------

			<!---<cfif id EQ '12665-92034-26217-45059'>--->
            ORDER BY committed_dollar desc
			
			<!---			
			<cfelse>
            ORDER BY	dbo.Contract_Main.Contract_Main_ID
            </cfif>            
			--->

</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->



<style>

a.id
{
	color:			#FFFF00;
	font-weight:	bold;
	font-size:		12px;
}

</style>





<style>

/*
	table wrapper				#FFFFFF		div.dataTables_wrapper
	table wrapper border		#CCCCCC		div.dataTables_wrapper 
	table border				#CCCCCC 	table.pretty td, table.pretty th
	table row titles			#DDDDDD 	table.pretty tbody th
	column headers				#BBBBBB 	table.pretty thead th.sorting th.sorting_asc th.sorting_desc
	table data fields			#FFFFFF 	table.pretty tbody tr.odd td
	table data fields (alte)	#eeeeee 	table.pretty tbody td
*/


/* ---------------------------------------------------------------------------------------------- */
/* Page setup styles */
/* ---------------------------------------------------------------------------------------------- */
#container 
{
	margin: 					0 auto;
	width: 						960px
}


/* ---------------------------------------------------------------------------------------------- */
/* DataTables framework */
/* ---------------------------------------------------------------------------------------------- */
div.dataTables_wrapper 
{
	background-color: 			#222222;
	border:						0px #CCCCCC solid;
}

div.dataTables_length 
{
	float: 						left;
}

div.dataTables_filter 
{
	float: 						right;
}

div.dataTables_info 
{
	padding: 					9px 6px 6px 6px;
	float: 						left;
	font-size:					11px;
	color:						#666666;
}

div.dataTables_paginate 
{
	float: 						right;
}

div.dataTables_length, div.dataTables_filter, div.dataTables_paginate 
{
	padding: 					6px;
}

/* ---------------------------------------------------------------------------------------------- */
/* Self clearing - http://www.webtoolkit.info/css-clearfix.html */
/* ---------------------------------------------------------------------------------------------- */
.dataTables_wrapper:after 
{
	content: 					".";
	display: 					block;
	clear: 						both;
	visibility: 				hidden;
	line-height: 				0;
	height: 					0;	
}
 
html[xmlns] .dataTables_wrapper 
{
	display: 					block;
}
 
* html .dataTables_wrapper 
{
	height: 					1%;
}

/* ---------------------------------------------------------------------------------------------- */
/* Table styles */
/* ---------------------------------------------------------------------------------------------- */
table.pretty 
{
	width: 						100%;
	clear: 						both;
}

table.pretty td, table.pretty th 
{
	padding: 					2px 8px 2px 8px;
	border-bottom: 				0px solid #CCCCCC;
	color:						#CCCCCC;
}


/* ---------------------------------------------------------------------------------------------- */
/* Header cells */
/* ---------------------------------------------------------------------------------------------- */
table.pretty thead th 
{
	text-align: 				left;
	color:						#000000;
	font-weight:				bold;
	cursor:						pointer;

	background: #fefefe; /* Old browsers */
	/* IE9 SVG, needs conditional override of 'filter' to 'none' see below this block */
	background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iI2ZlZmVmZSIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiNkZGRkZGQiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
	background: -moz-linear-gradient(top,  #fefefe 0%, #dddddd 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#fefefe), color-stop(100%,#dddddd)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  #fefefe 0%,#dddddd 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  #fefefe 0%,#dddddd 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  #fefefe 0%,#dddddd 100%); /* IE10+ */
	background: linear-gradient(top,  #fefefe 0%,#dddddd 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#fefefe', endColorstr='#dddddd',GradientType=0 ); /* IE6-8 */
}

/* ---------------------------------------------------------------------------------------------- */
/* Body cells */
/* ---------------------------------------------------------------------------------------------- */

table.pretty tbody td 
{
	text-align: 				left;
	background: 				#222222;
	color:						#FFFFFF;
	border:						0;
	border-right:				0px #000000 solid;
	border-bottom:				1px #990000 solid;
	padding: 					10px 5px 10px 5px;
}
		
table.pretty tbody tr.odd td 
{ 
	background: 				#000000;
	color:						#FFFFFF;
	border-right:				0px #000000 solid;
	border-bottom:				1px #990000 solid;
	padding: 					10px 5px 10px 5px;
}


/* ---------------------------------------------------------------------------------------------- */
/* Pagination */
/* ---------------------------------------------------------------------------------------------- */
a.paginate_button, a.paginate_active 
{
	display: 					inline-block;
	background-color: 			#222222;
	color:						#FFFFFF;
	border:						1px #990000 solid;
	padding: 					2px 6px;
	margin-left: 				2px;
	cursor: 					pointer;
	*cursor: 					pointer;
	font-size:					10px;
}

a.paginate_active 
{
	background-color: 			#FFFFFF;
	border: 					1px solid white;
	color:						#000000;
	font-size:					10px;
}

a.paginate_button_disabled 
{
	color: 						#aaaaaa;
	font-size:					10px;
}

.paging_full_numbers a:active 
{
	outline: 					none
	font-size:					10px;
}

.paging_full_numbers a:hover 
{
	text-decoration: 			none;
	font-size:					10px;
}

div.dataTables_paginate span>a 
{
	width: 						15px;
	text-align: 				center;
	font-size:					10px;
}

/* ---------------------------------------------------------------------------------------------- */
/* Sorting */
/* ---------------------------------------------------------------------------------------------- */
table.pretty thead th.sorting_asc 
{
	background: 				#BBBBBB url('images/sort_asc.png') no-repeat right center;
	border-right:				0px #000000 solid;

	background: #f4f4f4; /* Old browsers */
	/* IE9 SVG, needs conditional override of 'filter' to 'none' */
	background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iI2Y0ZjRmNCIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiM4MjgyODIiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
	background: -moz-linear-gradient(top,  #f4f4f4 0%, #828282 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#f4f4f4), color-stop(100%,#828282)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  #f4f4f4 0%,#828282 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  #f4f4f4 0%,#828282 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  #f4f4f4 0%,#828282 100%); /* IE10+ */
	background: linear-gradient(to bottom,  #f4f4f4 0%,#828282 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f4f4f4', endColorstr='#828282',GradientType=0 ); /* IE6-8 */
}

table.pretty thead th.sorting_desc 
{
	background: 				#BBBBBB url('images/sort_desc.png') no-repeat right center;
	border-right:				0px #000000 solid;

	background: #f4f4f4; /* Old browsers */
	/* IE9 SVG, needs conditional override of 'filter' to 'none' */
	background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iI2Y0ZjRmNCIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiM4MjgyODIiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
	background: -moz-linear-gradient(top,  #f4f4f4 0%, #828282 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#f4f4f4), color-stop(100%,#828282)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  #f4f4f4 0%,#828282 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  #f4f4f4 0%,#828282 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  #f4f4f4 0%,#828282 100%); /* IE10+ */
	background: linear-gradient(to bottom,  #f4f4f4 0%,#828282 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f4f4f4', endColorstr='#828282',GradientType=0 ); /* IE6-8 */
}

table.pretty thead th.sorting 
{
	background: 				#BBBBBB url('images/sort_both.png') no-repeat right center;
	border-right:				0px #000000 solid;

	background: #f4f4f4; /* Old browsers */
	/* IE9 SVG, needs conditional override of 'filter' to 'none' */
	background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iI2Y0ZjRmNCIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiM4MjgyODIiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
	background: -moz-linear-gradient(top,  #f4f4f4 0%, #828282 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#f4f4f4), color-stop(100%,#828282)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  #f4f4f4 0%,#828282 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  #f4f4f4 0%,#828282 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  #f4f4f4 0%,#828282 100%); /* IE10+ */
	background: linear-gradient(to bottom,  #f4f4f4 0%,#828282 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f4f4f4', endColorstr='#828282',GradientType=0 ); /* IE6-8 */
}


label
{
	color:						#FFFFFF;
	font-size:					12px;
}


select
{
	width:						75px;
}


td.datagrid_data
{
}

.align-left, td.align-left, th.align-left 
{
	text-align:				left;
}

.align-center, td.align-center, th.align-center
{
	text-align:				center;
}

.align-right, td.align-right, th.align-right
{
	text-align:				right;
}

</style>
		
		
<script type="text/javascript" language="javascript" src="http://datatables.net/release-datatables/media/js/jquery.js"></script>
<script type="text/javascript" language="javascript" src="jquery.dataTables.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script type="text/javascript" charset="utf-8">
	/* Formatted numbers sorting */
	$.fn.dataTableExt.oSort['formatted-num-asc'] = function(x,y){
		x = parseInt( x.replace(/[^\d\-\.\/]/g,'') );
		y = parseInt( y.replace(/[^\d\-\.\/]/g,'') );
		return x - y;
	}
	$.fn.dataTableExt.oSort['formatted-num-desc'] = function(x,y){
		x = parseInt( x.replace(/[^\d\-\.\/]/g,'') );
		y = parseInt( y.replace(/[^\d\-\.\/]/g,'') );
		return y - x;
	}
	
	/* Initialisation */
	$(document).ready(function() {
		$('#table_id_1').dataTable( {
			"oLanguage": {"sSearch": "Search this table:"},
			"sPaginationType": "full_numbers",

			<!---<cfif url.id EQ '12665-92034-26217-45059'>--->
			"aaSorting": [ [3,'desc'] ], <!--- this sets the column number that is sorted by default. the count starts at zero --->
			<!---</cfif>--->

			"aoColumns": 
			[ 
				{}, 
				{}, 
				{ "sType":"dollar", "bSearchable": false }, 
				{ "sType":"dollar", "bSearchable": false }, 
				{ "sType":"dollar", "bSearchable": false }, 
				{} 
			]


		} );
	} )


</script>


<cfif get_programs.recordcount EQ 0>
	<cfinclude template="no_data.cfm">
<cfelse>


<div class="section_title gradient_fix"><cfoutput>#selection_type#</cfoutput></div>
<br />

<div class="nav rounded_corners dark_gradient gradient_fix" style="float:right;" onclick="javascript: history.go(-1);">back to program search</div>
<br /><br />


    <table id="table_id_1" class="pretty" width="100%" cellpadding="0" cellspacing="0" border="0" align="center" style="	border-bottom:5px black solid;">
    <thead>
    <tr>
    <th class="datagrid_header"><CFOUTPUT>#label.program.singular#</CFOUTPUT> #</th>
    <th class="datagrid_header">Title</th>
    <th class="datagrid_header" style=" text-align:right;"><CFOUTPUT>#label.program.singular#</CFOUTPUT><br />Spend</th>
    <th class="datagrid_header" style=" text-align:right;"><CFOUTPUT>#label.commit.singular#</CFOUTPUT> <br />Dollars</th>
    <th class="datagrid_header" style=" text-align:right;">Cases</th>
    <th class="datagrid_header">Responsible Person</th>
    </tr>
    </thead>
    
    
    <tbody>
    
    <cfoutput query="get_programs">
    
    <!--- ----------------------------------------------------------------------------------------- --->
    <!--- modify the contract id so it less visible by raising to the power of 3 ------------------ --->
    <cfset x_contract_id	=	get_programs.Contract_Main_ID+12345>
    <!--- ----------------------------------------------------------------------------------------- --->
    
    <tr class="grid" bgcolor="###iif(get_programs.currentrow MOD 2,DE('222222'), DE('555555'))#" onClick="location.href='index.cfm?content=52840-22364-22102-87888&id=#x_contract_id#'" style="cursor:pointer;">
    <td class="datagrid_data" style="font-weight:bold; color:##FFFF00;" nowrap="nowrap">#Contract_Number#&nbsp;&nbsp;&nbsp;</td>
    <td class="datagrid_data" style="font-weight:bold; color:##FFFF00;">#Contract_Title#&nbsp;&nbsp;</td>
    <td class="datagrid_data" style="font-weight:bold; text-align:right;">#mydollarformat(Program_Spend)#&nbsp;&nbsp;</td>
    <td class="datagrid_data" style="font-weight:bold; text-align:right;">#mydollarformat(Committed_Dollar)#&nbsp;&nbsp;</td>
    <td class="datagrid_data" style="font-weight:bold; text-align:right;">#numberformat(cases, ',')#&nbsp;&nbsp;</td>
    <td class="datagrid_data" style="font-weight:bold;" nowrap="nowrap">#CapFirst(Name_First)# #CapFirst(Name_last)#&nbsp;&nbsp;</td>
    </tr>
    </cfoutput>
    
    </tbody>
    
    </table>

</cfif>



