<cfcomponent name="BillbackSearchDetails" displayname="BillbackSearchDetails" hint="Billback Search Details">
<cfset appSettings = application.appSettingsGet />

	<!--- Any change to this function may require a corresponding change in the "Update_billback_search" stored procedure and  
	mvc\models\billback\billbackLoadManager.cfc
	--->
	<cffunction name="getUnderReviewOrPendingApprovalOrAgreedBillbacks" output="true" returntype="array">
		
		<cfargument name="userId" type="string" required="true" default="00000000-9999-9999-0000000000000000">
		<cfargument name="profiles_Id" type="string" required="true">
		<cfargument name="status_list" type="string" required="true">

		<!--- "UseHashTables" to make sure that the hash tables are used for billback permission query in "Billback_Access_Permission.cfm" --->
		<cfset var UseHashTables = 1>
		
		<cfset var a = arrayNew(1) />

		<cfset var qUserNumber = ''>

		<!--- App setting exists on "Billback_Access_Permission.cfm" --->
		<cfset var forbidType = appSettings.getForbidAllowProfilesInTemplates() />

		<cfset var stSearch = StructNew()>

               <cfquery name="qDropTempTables" datasource="#application.datasource#">
		<!---if object_id('tempdb..##tmp_billack_pre_filter') is not null 
		drop table ##tmp_billack_pre_filter 
		--->

		if object_id('tempdb..##tmp_billacks_cannot_see') is not null 
		drop table ##tmp_billacks_cannot_see 

		if object_id('tempdb..##Profile_Forbidden_Template') is not null 
		drop table ##Profile_Forbidden_Template 

		if object_id('tempdb..##tmp_billack_templates') is not null
		drop table ##tmp_billack_templates

		if object_id('tempdb..##Allow_Only_Billbacks') is not null
		drop table ##Allow_Only_Billbacks

		if object_id('tempdb..##Allow_Analysts') is not null
		drop table ##Allow_Analysts	
		
		if object_id('tempdb..##Positions_Below_Me') is not null
		drop table ##Positions_Below_Me
		
		if object_id('tempdb..##Billback') is not null
		drop table ##Billback
		</cfquery>

		<!--- We unlock all billbacks of the user during loading only. --->
		<CFINCLUDE TEMPLATE="/billbacks/scorecard/unlock_billbacks.cfm">
		
		<CFINCLUDE TEMPLATE="/billbacks/Billback_Access_Permission.cfm">


		<cfif Not isDefined("request.AccessStructure")>
			<cfset request.AccessStructure = structNew() />
			<cfset request.AccessStructure.user_id = arguments.user_id />
			<cfset request.AccessStructure.profiles_id = arguments.profiles_id />
		</cfif>

		<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

		<cfset stSearch.Profiles_ID = arguments.profiles_id>

		<cfif Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
			<cfset stSearch.programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>
		</cfif>


		<!---<CFIF Get_Profile_Settings.BB_RFA_Agreed EQ 1>--->
			<CFSET Auth_Sequence_Order = 0>
			<CFSET Auth_Sequence_ID = 0>
			<CFQUERY NAME="AuthoritySeq" DATASOURCE="#Application.Datasource#">
				SELECT Authority_Sequence_Order, Authority_Sequence_ID FROM Authority_Sequence WHERE Authority_Sequence_ID = 
				(
					SELECT Authority_Sequence_ID FROM _Users WHERE User_ID = '#request.AccessStructure.User_ID#'
				)
			</CFQUERY>	
			<CFIF AuthoritySeq.recordCount GT 0>
				<CFSET Auth_Sequence_Order = AuthoritySeq.Authority_Sequence_Order>
				<CFSET Auth_Sequence_ID = AuthoritySeq.Authority_Sequence_ID>
			</CFIF>
		<!---</CFIF>--->

		
	<!--- This query is meant for Agreed and Pending Approval and Under Review --->
        <cfquery name="qgetUnderReviewOrPendingApprovalOrAgreedBillbacks" datasource="#application.datasource#">
            set transaction isolation level read uncommitted

	    DECLARE @DatesToInt int

            <cfif NOT UserIsAnalyst>
                #PreserveSingleQuotes(AllowBillbackIDs)#
            <cfelse>
                #PreserveSingleQuotes(AllowAnalystIds)#
            </cfif>
                
		if object_id('tempdb..##Profile_Forbidden_Template') is not null 
		drop table ##Profile_Forbidden_Template 

		if object_id('tempdb..##tmpBillbackList') is not null 
		drop table ##tmpBillbackList 
	
		Create  table ##Profile_Forbidden_Template
		(
		  template_id int not null
		)

		INSERT INTO  ##Profile_Forbidden_Template(Template_ID)
		<!------ forbid type=1, forbid, 0=allow ----->
		<cfif forbidType EQ 1>
		SELECT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		FROM Program_Control_Panel_Options
		LEFT JOIN Profile_Forbidden_Template
		ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
		AND Profile_Forbidden_Template.Forbid_Access_Type = 1
		AND Profile_Forbidden_Template.deleted = 0
		AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
		AND Profile_Forbidden_Template.profile_id = #stSearch.Profiles_ID#
		<!--- Show me the templates, which are not in the "Profile_Forbidden_Template" table --->
		WHERE Profile_Forbidden_Template.template_id IS NULL

		<cfelse>

		SELECT Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		FROM Program_Control_Panel_Options
		INNER JOIN Profile_Forbidden_Template
		ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Profile_Forbidden_Template.template_id
		WHERE Profile_Forbidden_Template.deleted = 0
		AND Profile_Forbidden_Template.Forbid_Access_Type = 1
		AND Profile_Forbidden_Template.Forbid_Type = #forbidType#
		AND Profile_Forbidden_Template.profile_id = #stSearch.Profiles_ID#
		</cfif>

		CREATE  CLUSTERED  INDEX [I_Profile_Forbidden_Template_tmp] ON [dbo].[##Profile_Forbidden_Template]([Template_ID]) 
		WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

	    SELECT    Billback.Billback_ID
	    INTO ##tmp_billacks_cannot_see
	    FROM Billback
	    INNER JOIN Billback_Program
	    ON    Billback.Billback_ID = Billback_Program.Billback_ID
	    AND   Billback_Program.Deleted = 0
            INNER JOIN Contract_Main
	    ON  Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
	    WHERE Billback.Deleted = 0
	    AND  ProgramType_ID NOT IN
	    (
		  SELECT Template_ID
		  FROM ##Profile_Forbidden_Template
	    )
	   
	    <!--- Send the Billback_ID_Int to flex for filtering on Billback_ID_Int --->
	    <!--- Populate a temp table with the billback_ID_Int and Program_Agree_Status_ID and then use it below for 
	          Agreed, Pending Approval and Under Review queries which are separate.
	    --->
            SELECT DISTINCT
	    Billback.Billback_ID_Int,Program_Agree_Status.Program_Agree_Status_ID
	   
	   INTO ##tmpBillbackList
	   FROM billback
		LEFT JOIN Program_Agree_Status
		ON
		<!---1=2--->
		<!---<cfif arguments.Get_Profile_Settings.BB_RFA_Agreed EQ 1>
		 OR
		 --->
		Billback.Billback_Status_ID = 2
		<!---</cfif>--->

	   WHERE  billback.deleted = 0
		
            <cfif IsDefined("stSearch.programScorecardRestrictCreatedByUserId")>
            <!--- If the below profile settings is on, then the user should only be allowed to see programs 
            that have him/her as an RSP OR where the program creator's RSP has the user number same as
            this user's User number 
            --->
            AND NOT EXISTS
            (
           <cfif appSettings.getUserNumberRestrict()>
                <cfset qUser = createObject("component", "components.user.UserManager").getUser(stSearch.programScorecardRestrictCreatedByUserId) />
                <cfset qUserNumber = qUser.User_Number />
            </cfif>
            SELECT Billback_ID
            FROM Billback_Program
            INNER JOIN Contract_Main
            ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
            LEFT JOIN _Users responsibleSalesPerson
            ON 	responsibleSalesPerson.User_ID = Contract_Main.Responsible_User_ID
            AND	responsibleSalesPerson.Deleted = 0
            WHERE Billback_Program.Billback_ID = Billback.Billback_ID
            AND Billback_Program.Deleted = 0
            AND(
            Isnull(rtrim(ltrim(Contract_Main.Responsible_User_ID)),'') != '#stSearch.programScorecardRestrictCreatedByUserId#'
            <cfif len(qUserNumber)>
                AND Isnull(rtrim(ltrim(responsibleSalesPerson.User_Number)),'') != '#qUserNumber#'
            </cfif>				
            )
            )
            </cfif>

	    AND NOT EXISTS
            (
		select Billback_ID 
		FROM ##tmp_billacks_cannot_see
		WHERE ##tmp_billacks_cannot_see.Billback_ID = Billback.Billback_ID 
	    )

            <!---TSF - Label 16253: Add Billback filter logic if search by analyst is not on for this profile--->
	    <!--- The values of "UserPositionList" and "##Allow_Only_Billbacks" and "AnalystList" comes from "/billbacks/Billback_Access_Permission.cfm" --->
            <cfif not Get_Profile_Settings.BB_Search_By_Analyst>
            <cfif HQUser NEQ 1 OR UserIsAnalyst> <!--- if user is an analyst or not HQ --->
            AND (
                Billback.BB_Creator_ID = '#request.AccessStructure.User_ID#'
                <cfif UserIsAnalyst EQ 0>
                    OR Billback.BB_Creator_User_Position_ID IN (#PreserveSingleQuotes(UserPositionList)#)
                    <cfif listlen(BillbackIDs) GT 0>
                        OR Billback.Billback_ID IN (SELECT Billback_ID FROM ##Allow_Only_Billbacks)
                    </cfif>
                <cfelse><!------ If billback analyst do not look at the position tree, use the analyst logic alone ----->
                    <cfif AnalystList NEQ "">
                        OR	Billback.Analyst_User_ID IN (#PreserveSingleQuotes(AnalystList)#)
                        OR	Billback.BB_Creator_ID IN (#PreserveSingleQuotes(AnalystList)#)
                    </cfif>
                </cfif>
            )
            </cfif>            
            </cfif>

	    </cfquery>


	    <!--- UNDER REVIEW STATUS QUERY  --->
	    <cfif arguments.status_list.IndexOf('Under Review') neq -1>  
	      <cfquery name="qgetUnderReviewBillbacks" datasource="#application.datasource#">    
	      SELECT DISTINCT Billback.Billback_ID_Int
	      FROM Billback
	      INNER JOIN ##tmpBillbackList tmpBB
	      ON Billback.Billback_ID_Int = tmpBB.Billback_ID_Int
	      WHERE 1 = 1
              AND
                ( Billback.Billback_Status_ID = 2 AND tmpBB.Program_Agree_Status_ID = 1 	  
                  AND Not Exists
                    (SELECT bb_agreed_info_ID FROM BB_Agreed_Info WHERE Deleted = 0 AND Billback_ID = Billback.Billback_ID AND User_position_ID IN (#PreserveSingleQuotes(UserPositionList)#) AND Authority_Sequence_ID = '#Auth_Sequence_ID#')
                  AND 	
                    (
                        #Get_Profile_Settings.BB_Approve# = 0
                        
                        OR
                        
                        ((	SELECT 	Top 1 User_positions_ID
                                FROM 	BillbackApprovablePositions 		
                                WHERE 	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND 
                                        NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR 
                                                    Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0) 
                                                                                    FROM 		BB_Agreed_Info 
                                                                                    INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
                                                                                    WHERE 		Billback_ID = Billback.Billback_ID
                                                                                    AND			BB_Agreed_Info.Deleted = 0)
                                                ) AND
                                                User_positions_ID IN (		SELECT 	DISTINCT User_position_ID 
                                                                            FROM 	BB_Agreed_Info
                                                                            WHERE 	Billback_ID = Billback.Billback_ID AND 
                                                                            Deleted = 0)
                                            )
                            ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
                            ) NOT IN (#PreserveSingleQuotes(UserPositionList)#) )
                        OR
                
                        (	ISNULL((	SELECT 	Top 1 Authority_Sequence_Order 
                                        FROM 	BillbackApprovablePositions 		
                                        WHERE 	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND
                                                NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR 
                                                            Authority_Sequence_Order IN (	SELECT ISNULL(Authority_Sequence_ORDER,0) 
                                                                                            FROM BB_Agreed_Info 
                                                                                            INNER JOIN Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
                                                                                            WHERE Billback_ID = Billback.Billback_ID
                                                                                            AND			BB_Agreed_Info.Deleted = 0)
                                                        ) AND
                                                        User_positions_ID IN (		SELECT 	DISTINCT User_position_ID 
                                                                                    FROM 	BB_Agreed_Info
                                                                                    WHERE 	Billback_ID = Billback.Billback_ID AND 
                                                                                    Deleted = 0)
                                                    ) 
                                        ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
                                    ),0) <> '#Auth_Sequence_Order#'
                        )
                    )
                )
		</cfquery>
	     </cfif>

	     <!--- PENDING APPROVAL STATUS QUERY ---> 
	     <cfif arguments.status_list.IndexOf('Pending Approval') neq -1> 
		<cfquery name="qgetPendingApprovalBillbacks" datasource="#application.datasource#">
	        SELECT DISTINCT Billback.Billback_ID_Int
	        FROM Billback
	        INNER JOIN ##tmpBillbackList tmpBB
	        ON Billback.Billback_ID_Int = tmpBB.Billback_ID_Int
	        WHERE 1 = 1
                AND
                ( Billback.Billback_Status_ID = 2 AND tmpBB.Program_Agree_Status_ID = 2 AND
                  Not Exists
                    (SELECT bb_agreed_info_ID FROM BB_Agreed_Info WHERE Deleted = 0 AND Billback_ID = Billback.Billback_ID AND User_position_ID 
		    IN 
		    (
			#PreserveSingleQuotes(UserPositionList)#) AND Authority_Sequence_ID = '#Auth_Sequence_ID#'
		    )
                  AND 	
                    (
                        #Get_Profile_Settings.BB_Approve# = 1
                        
                        AND
                        
                        ((	SELECT 	Top 1 User_positions_ID
                                FROM 	BillbackApprovablePositions 		
                                WHERE 	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND 
                                        NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR 
                                                    Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0) 
                                                                                    FROM 		BB_Agreed_Info 
                                                                                    INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
                                                                                    WHERE 		Billback_ID = Billback.Billback_ID
                                                                                    AND			BB_Agreed_Info.Deleted = 0)
                                                ) AND
                                                User_positions_ID IN (	SELECT 	DISTINCT User_position_ID 
                                                                        FROM 	BB_Agreed_Info
                                                                        WHERE 	Billback_ID = Billback.Billback_ID AND 
                                                                                Deleted = 0)
                                            )
                            ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
                            ) IN (#PreserveSingleQuotes(UserPositionList)#) )
                        AND
            
                        (	ISNULL((	SELECT 	Top 1 Authority_Sequence_Order 
                                        FROM 	BillbackApprovablePositions 		
                                        WHERE 	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND
                                                NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR 
                                                            Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0) 
                                                                                            FROM 		BB_Agreed_Info 
                                                                                            INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
                                                                                            WHERE 		Billback_ID = Billback.Billback_ID
                                                                                            AND			BB_Agreed_Info.Deleted = 0)
                                                        ) AND
                                                        User_positions_ID IN (	SELECT 	DISTINCT User_position_ID 
                                                                                FROM 	BB_Agreed_Info
                                                                                WHERE 	Billback_ID = Billback.Billback_ID AND 
                                                                                        Deleted = 0)
                                                    ) 
                                        ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
                                    ),0) = '#Auth_Sequence_Order#'
                        )
                    )
                )
		</cfquery>
	      </cfif>


		<!--- AGREED STATUS QUERY ---> 
		<cfif arguments.status_list.IndexOf('Agreed') neq -1>
		  <cfquery name="qgetAgreedBillbacks" datasource="#application.datasource#">
		   SELECT DISTINCT Billback.Billback_ID_Int
	           FROM Billback
	           INNER JOIN ##tmpBillbackList tmpBB
	           ON Billback.Billback_ID_Int = tmpBB.Billback_ID_Int
	           WHERE 1 = 1
		   AND
		   (Billback.Billback_Status_ID = 2 AND tmpbb.Program_Agree_Status_ID = 3 AND
		   Exists
		   (SELECT bb_agreed_info_ID FROM BB_Agreed_Info WHERE Deleted = 0 AND Billback_ID = Billback.Billback_ID AND User_position_ID IN (#PreserveSingleQuotes(UserPositionList)#) AND Authority_Sequence_ID = '#Auth_Sequence_ID#')
                   )
		  </cfquery>
		</cfif>
	
		
		<cfquery name="qClearTempTables" datasource="#application.datasource#">
		if object_id('tempdb..##tmp_billack_pre_filter') is not null 
		drop table ##tmp_billack_pre_filter 

		if object_id('tempdb..##tmp_billacks_cannot_see') is not null 
		drop table ##tmp_billacks_cannot_see 

		if object_id('tempdb..##Profile_Forbidden_Template') is not null 
		drop table ##Profile_Forbidden_Template 

		if object_id('tempdb..##tmp_billack_templates') is not null
		drop table ##tmp_billack_templates

		if object_id('tempdb..##Allow_Only_Billbacks') is not null
		drop table ##Allow_Only_Billbacks

		if object_id('tempdb..##Allow_Analysts') is not null
		drop table ##Allow_Analysts	
		
		if object_id('tempdb..##Positions_Below_Me') is not null
		drop table ##Positions_Below_Me
		
		if object_id('tempdb..##Billback') is not null
		drop table ##Billback

		if object_id('tempdb..##tmpBillbackList') is not null
		drop table ##tmpBillbackList
		</cfquery>
		 
		 <!--- If the user searches for "Under Review" status billbacks, add it to array "a". --->
		 <cfif arguments.status_list.IndexOf('Under Review') neq -1> 
			<cfset a.AddAll(qgetUnderReviewBillbacks[ "Billback_ID_Int" ])  />
		 </cfif>
		
		 <!--- If the user searches for "Pending Approval" status billbacks, add it to array "a". --->
		 <cfif arguments.status_list.IndexOf('Pending Approval') neq -1>  
			<cfset a.AddAll(qgetPendingApprovalBillbacks[ "Billback_ID_Int" ])  />
		 </cfif>
		 
		 <!--- If the user searches for "Agreed" status billbacks, add it to array "a". --->
		 <cfif arguments.status_list.IndexOf('Agreed') neq -1>
			<cfset a.AddAll(qgetAgreedBillbacks[ "Billback_ID_Int" ])  />
		 </cfif>
		
		
		<!---<cfset a[1] = int(43257) />--->
		
		<!--- Array "a" could store "billback_id_int" for Agreed and/or Pending Approval and/or Under Review --->
		<cfreturn a />
	
	</cffunction>

	<cffunction name="fullTextStringClean" access="public" returntype="String">
		<cfargument name="s" required="true" default="" />
		<cfscript>
			var r = "";
			if (len(arguments.s) GT 0)
				{
					// remove all non-alphanumeric characters from string
					r = trim(reReplace(arguments.s,'[^a-zA-Z0-9\,_]',' ','ALL')); // replace with spaces
					if(len(r) GT 0)
						{
							// If criteria is not blank then break apart the words and create a new list with qualifiers for full text search
							r = reReplace(r, '(\s)+',',','ALL');      // replace multiple spaces with comma
							r = reReplace(r, '(\,)+\1','\1','ALL');      // replace multiple commas with a single comma
							//  r = listQualify(r,'*',',');     // Add wildcard for each term 
							//  r = listQualify(r,'""',',');    // Add quotes around the wilcard search term E.g: ""*Subway*""
						}
                }
		</cfscript>
		<cfreturn r />
	</cffunction>

	<cffunction name="fullTextStringModify" access="public" returntype="String">
		<cfargument name="s" required="true" default="" />
		<cfscript>
			var r = "";
			if (len(arguments.s) GT 0)
				{
					// Replace comma-delimited list with a list delimited by " OR "
					r = Replace(arguments.s, ",", '" OR "' ,"ALL");
                }
		</cfscript>

		<cfreturn r />
	</cffunction>
	
	<!--- Any change to this function may require a corresponding change in mvc\models\billback\billbackLoadManager.cfc  --->
	<cffunction name="fullTextBillbackFilter" output="false" access="public" returntype="Array">
		<cfargument name="BBFilterparams" required="true" default="" />
<!---else if(arguments.prgStatus.indexOf('Agreed') != -1)
		<cfset ArrStatus = ArrayNew(1)>

		<cfloop from="1" to="#Arraylen(arguments.BBFilterparams.statusListSelect)#" index="i">

			<cfset ArrStatus[i] = arguments.BBFilterparams.statusListSelect[i].description>
		
		</cfloop>

		<cfquery name="test" datasource="#application.datasource#">
		INSERT INTO test_flex(user_id, profile_id)
		values('#arguments.BBFilterparams.entitySelect#','#arrn[1]#')
		</cfquery>
		
--->	
     		<!---<cfset User_ID = '#request.AccessStructure.user_id#'> --->
		<cfscript>
				var qBillbackFilter = '';
				var a = ArrayNew(1);
				var d = 0;
				var o = 0;
				//var i = 0;
                var eString = this.fullTextStringClean(arguments.BBFilterparams.programKeyword);
               //var oString = this.fullTextStringClean(arguments.OprString);
                //var iString = this.fullTextStringClean(arguments.ItemString);
		//var bgString = this.fullTextStringModify(arguments.BuyingGroup);
		//var fmlyString = this.fullTextStringModify(arguments.Family);
		</cfscript>

		<cfquery name="qBillbackFilter" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		<!--- Convert it to varchar because now we are loading all the program data as string, 
		including contract_main_id and so any other query getting program data needs to get data
		as string only, so that there are no data type issues. Without conversion, Flex will not
		return any records as the filter will fail.
		--->
		
		SELECT DISTINCT BB.Billback_ID_Int As Billback_ID_Int
		FROM Billback BB
		
		<!----
		TEST QUERY
		where billback_id_int in (100666)
		where billback_id_int in (143,147) ,101290,103955
		--->
			
		<!--- FULL-TEXT ON PROGRAM SEARCH --->
		<cfif arguments.BBFilterparams.programKeyword neq ""> 
			INNER JOIN Program_Search PS ON 1 = 1
			<cfloop from="1" to="#listLen(arguments.BBFilterparams.programKeyword)#" index="p">
			INNER JOIN CONTAINSTABLE(Program_Search, *, '"*#ListGetAt(arguments.BBFilterparams.programKeyword,p)#*"') AS PROGRAM_TABLE_#p#
			ON PROGRAM_TABLE_#p#.[KEY] = PS.Program_ID
			</cfloop>
			
			INNER JOIN Contract_Main CM
			ON PS.Program_ID = CM.Contract_Main_ID
			AND CM.Deleted = 0
			<!---Some of the programs which are actually not cancelled have manual_cancel = 1 and CM.Cancel_And_End_Dated = 1. These programs should be included. 
			   The "Cancel_And_End_Dated" is a date field and the program has been end dated with this date but should be included as it is not cancelled.
			--->
			AND (CM.Manual_Cancel = 0 OR CM.Cancel_And_End_Dated = 1)
			AND CM.Flagged_As_Purged = 0

			INNER JOIN Billback_Program BP ON
			PS.Program_ID = BP.Program_ID AND
			BB.Billback_ID =  BP.Billback_ID AND
			BP.Deleted = 0
		</cfif>

		<!--- FULL-TEXT ON DISTRUBUTOR SEARCH --->
		<cfif arguments.BBFilterparams.entitySelect eq application.returned_customer_setting.distributor_label_singular AND arguments.BBFilterparams.entityKeyword neq ""> 
			INNER JOIN dbo.BSA_Foodservice_Customers BFC ON 1 = 1
			<cfloop from="1" to="#listLen(arguments.BBFilterparams.entityKeyword)#" index="e">
			INNER JOIN CONTAINSTABLE(BSA_Foodservice_Customers, *, '"*#ListGetAt(arguments.BBFilterparams.entityKeyword,e)#*"') AS DIST_TABLE_#e#  
			ON DIST_TABLE_#e#.[KEY] = BFC.BSA_Foodservice_Customers_ID
			</cfloop>

			INNER JOIN Billback_Distributor_List BD ON
			BFC.BSA_Foodservice_Customers_ID = BD.Distributor_ID AND
			BB.Billback_ID =  BD.Billback_ID AND
			BD.Deleted = 0 
		</cfif>

		<!--- FULL-TEXT ON OPERATOR SEARCH --->
		<cfif arguments.BBFilterparams.entitySelect eq application.returned_customer_setting.operator_label_singular AND arguments.BBFilterparams.entityKeyword neq ""> 
			INNER JOIN Billback_Program BBP
			ON BBP.Billback_ID = BB.Billback_ID

			INNER JOIN Contract_Operators CO ON
			BBP.Program_ID = CO.Contract_Main_ID		

			INNER JOIN dbo.BSA_Operator BSO 
			ON CO.BSA_Operator_ID =  BSO.BSA_Operator_ID
			<cfloop from="1" to="#listLen(arguments.BBFilterparams.entityKeyword)#" index="o">
			INNER JOIN CONTAINSTABLE(BSA_Operator, *, '"*#ListGetAt(arguments.BBFilterparams.entityKeyword,o)#*"') AS OPR_TABLE_#o#  
			ON OPR_TABLE_#o#.[KEY] = BSO.BSA_Operator_ID
			</cfloop>

			AND CO.deleted = 0 
			AND BBP.deleted = 0
		</cfif>

		<!--- FULL-TEXT ON ACCOUNT SEARCH --->
		<cfif arguments.BBFilterparams.payeeKeyword neq "">
				LEFT JOIN Billback_Operator						
				ON Billback_Operator.Billback_ID = BB.Billback_ID
				AND Billback_Operator.Deleted = 0
		
				LEFT JOIN Billback_Distributor
				ON Billback_Distributor.Billback_ID = BB.Billback_ID
				AND Billback_Distributor.deleted = 0
		
				INNER JOIN Vendor_Dist_Oper vdo on 
				((Billback_Distributor.Distributor_ID is not null and Billback_Distributor.Deleted = 0 and vdo.Distributor_ID = Billback_Distributor.Distributor_ID)
				or (Billback_Operator.Operator_ID is not null and Billback_Operator.Deleted = 0 and vdo.Operator_ID =  Billback_Operator.Operator_ID) )
				INNER JOIN Vendor_Master vm ON vm.Vendor_ID = vdo.Vendor_ID AND vm.Active_Code = 'A' AND vm.Deleted = 0 
		</cfif>

		WHERE BB.Deleted = 0

		<!--- FULL-TEXT ON BROKER SEARCH --->
		<!--- If the payee is a distributor, "Billback_Distributor_List" table will have an entry. Look for broker_id in the "dbo.BSA_Foodservice_Customers" table.
		      If the payee is a broker "Billback_Broker" table will have an entry. Look for broker_id in the "Billback_Broker" table.
		--->
		<cfif arguments.BBFilterparams.entitySelect eq application.returned_customer_setting.broker_label_singular AND arguments.BBFilterparams.entityKeyword neq "">
			AND EXISTS
			(
			<!--- Payee is broker --->
			  SELECT Billback_ID_Int
			  FROM Billback BB1	
			  
				INNER JOIN Billback_Broker BBR 
				ON BB1.Billback_ID = BBR.Billback_ID		
				AND BBR.Deleted = 0 			
				
				INNER JOIN dbo.BSA_Foodservice_Brokers BFB ON 
				BFB.BSA_Foodservice_Brokers_ID = BBR.Broker_ID
				
				<cfloop from="1" to="#listLen(arguments.BBFilterparams.entityKeyword)#" index="b">
				INNER JOIN CONTAINSTABLE(BSA_Foodservice_Brokers, *, '"*#ListGetAt(arguments.BBFilterparams.entityKeyword,b)#*"') AS BRK_TABLE_1  
				ON BRK_TABLE_1.[KEY] = BFB.BSA_Foodservice_Brokers_ID
				</cfloop>

				WHERE  BB1.Deleted = 0
				AND BB.Billback_ID = BB1.Billback_ID

				
			  UNION

			<!--- Payee is distributor --->
			   SELECT Billback_ID_Int
			   FROM Billback BB2
				  
				INNER JOIN Billback_Distributor_List BD
				ON BB2.Billback_ID = BD.Billback_ID
				AND BD.Deleted = 0 		
				   
				INNER JOIN dbo.BSA_Foodservice_Customers BFC ON 
				BFC.BSA_Foodservice_Customers_ID = BD.Distributor_ID
				   
				INNER JOIN dbo.BSA_Foodservice_Brokers BFB 
				ON  BFC.BSA_Foodservice_Brokers_ID = BFB.BSA_Foodservice_Brokers_ID
				
				<cfloop from="1" to="#listLen(arguments.BBFilterparams.entityKeyword)#" index="b">
				INNER JOIN CONTAINSTABLE(BSA_Foodservice_Brokers, *, '"*#ListGetAt(arguments.BBFilterparams.entityKeyword,b)#*"')  AS BRK_TABLE_1  
				ON BRK_TABLE_1.[KEY] = BFC.BSA_Foodservice_Brokers_ID
				</cfloop>	
						
				WHERE  BB2.Deleted = 0
				AND BB.Billback_ID = BB2.Billback_ID
			)			
		</cfif>
		
		<!--- FULL-TEXT ON VENDOR SEARCH --->
		<!--- Vendor data is now being loaded to flex. No need for full-text search.
		Note: A request is made to this function when we are searching for billbacks in non-paid status and so we do not
		require full-text search on vendor, as vendor information for non paid billbacks is already loaded to flex.		
		--->
				<!--- FULL-TEXT ON ACCOUNT SEARCH --->
		<cfif arguments.BBFilterparams.payeeKeyword neq "">
			and (
					VM.vendor_Id = '#arguments.BBFilterparams.payeeKeyword#'
					or
					VM.Vendor_Name like '%#arguments.BBFilterparams.payeeKeyword#%'
			)
		</cfif>

		</cfquery>

		<cfset a.AddAll(qBillbackFilter[ "Billback_ID_Int" ])  />

		<cfreturn a />
	</cffunction>
</cfcomponent>