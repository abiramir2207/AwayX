<CFPARAM NAME="URL.ForReport" DEFAULT="0">
<CFPARAM NAME="Selected_Distributor" DEFAULT="">
<CFPARAM NAME="Selected_Broker" DEFAULT="">
<CFPARAM NAME="FORM.Distributor_List" DEFAULT="">
<CFPARAM NAME="FORM.Broker_List" 	DEFAULT="">
<CFPARAM NAME="FORM.DD_Number" DEFAULT="">
<CFPARAM NAME="FORM.Dollar_Operator" DEFAULT="=">
<CFPARAM NAME="FORM.DD_Amount" DEFAULT="">
<CFPARAM NAME="FORM.DD_To_Amount" DEFAULT="">
<CFPARAM NAME="FORM.Date_Operator" DEFAULT="=">
<CFPARAM NAME="FORM.Date_Time" DEFAULT="">
<CFPARAM NAME="FORM.To_Date_Time" DEFAULT="">

<CFPARAM NAME="FORM.ClDate_Operator" DEFAULT="">
<CFPARAM NAME="FORM.ClDate_Time" DEFAULT="">
<CFPARAM NAME="FORM.ClTo_Date_Time" DEFAULT="">
<CFPARAM NAME="FORM.C1AR_Reference" DEFAULT="">
<CFPARAM NAME="FORM.C1Cust_RefNo" DEFAULT="">

<CFPARAM NAME="FORM.Check_No" DEFAULT="">
<CFPARAM NAME="FORM.Service_Market_ID" DEFAULT="">
<CFPARAM NAME="FORM.Distributor" DEFAULT="">
<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
<CFPARAM NAME="FORM.Family_ID" DEFAULT="">
<CFPARAM NAME="FORM.Analyst_User_ID" DEFAULT="">
<CFPARAM NAME="FORM.Service_Region_ID" DEFAULT="">
<CFPARAM NAME="FORM.Broker" DEFAULT="">
<CFPARAM NAME="FORM.DD_Stage_ID" DEFAULT="">
<CFPARAM NAME="FORM.DD_Aging" DEFAULT="">
<CFPARAM NAME="FORM.Service_Zone_ID" DEFAULT="">
<CFPARAM NAME="FORM.DD_Reason_Code_ID" DEFAULT="">
<CFPARAM NAME="FORM.DD_Status" DEFAULT="">
<CFPARAM NAME="FORM.DD_Parent_ID" DEFAULT="">
<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="">
<CFPARAM NAME="SubmitTheForm" default="0">
<CFPARAM NAME="FORM.Distributor_Bill_To_ID" DEFAULT="">
<CFPARAM NAME="FORM.Distributor_Bill_To" DEFAULT="">
<CFPARAM NAME="FORM.Line_Of_Business_ID" DEFAULT="">
<CFPARAM NAME="FORM.DD_Operator_ID" DEFAULT="">
<CFPARAM NAME="FORM.IsBusEnabled" DEFAULT="">
<CFPARAM NAME="FORM.Business_Segment_ID" DEFAULT="">
<CFPARAM NAME="FORM.Q_Brand_ID" DEFAULT="">
<CFPARAM NAME="FORM.DD_Operator_ID" DEFAULT="">
<CFPARAM NAME="FORM.Operating_Unit_ID" DEFAULT="">
<CFPARAM NAME="FORM.AccessAllDeductions" DEFAULT="0">
<CFPARAM NAME="FORM.DD_Ref" DEFAULT="">
<CFPARAM NAME="FORM.DDAmountFilter" DEFAULT="">
<CFPARAM NAME="FORM.MC_Shr_Ship_to" DEFAULT="">
<CFPARAM NAME="FORM.MC_Shr_Bill_To" DEFAULT="">
<CFPARAM NAME="FORM.MC_Bill_To_Name" DEFAULT="">
<CFPARAM NAME="FORM.MC_Vendor_ID" DEFAULT="">
<CFPARAM NAME="FORM.MC_Vendor_Name" DEFAULT="">

<CFPARAM NAME="FORM.MC_Distributor_Name" DEFAULT="">
<CFPARAM NAME="FORM.Broker_Name" DEFAULT="">
<CFPARAM NAME="SearchSource" DEFAULT="">
<CFPARAM NAME="isMatchCentral" DEFAULT="false">


<cfparam name="FORM.startrow"  default="1">
<CFPARAM NAME="FORM.frompage"   DEFAULT="1">
<cfset FORM.pageLength = 50 />
<cf_Number_of_Rows maxrows="#FORM.pageLength#">

<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="DD_DedID_SP_Number">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">
<CFPARAM NAME="FORM.IsParentDeduction" 	DEFAULT="0">
<CFPARAM NAME="FORM.Filter_Closed" DEFAULT="0">
<CFPARAM NAME="FORM.Only_DD_With_Inactive_Relations" DEFAULT="0">
<CFPARAM NAME="FORM.Filter_Attached" DEFAULT="0">
<CFPARAM NAME="FORM.Rebill_Number" DEFAULT="">

<cfparam name="FORM.Classification" default="0">   <!---26472--->
<cfparam name="FORM.DeductionType" default="0">   <!---26487--->

<cfparam name="FORM.InvoiceNo" default="">
<cfparam name="FORM.OrderNo" default="">
<cfparam name="form.date_type" default="deduction">
<cfparam name="FORM.BBApprovedAmt" default="">

<!---Check on whether to use cleared amount or not--->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<!---if the application settings is in the application scope then get it from there--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFSET displayOnlyAssignedDeductions = appSettings.getDisplayOnlyAssignedDeductions()>

<!--- Dev Note: KAL; 7821 --->
<cfset DD_Status_toHide	= CreateObject("component", "components.Deduction.settings.DeductionSettingsManager").DD_Status_Control(request.AccessStructure.profiles_id) />

<cfset useLakebaseForDeductionSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_settings")>
<cfif useLakebaseForDeductionSettings>
	<cftry>
		<cfset DeductionSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_settings", {})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionSettings>
<cfquery name="DeductionSettings" datasource="#application.datasource#">
SELECT * FROM Deduction_Settings
</cfquery>
</cfif>
<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", {
				"profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
</cfquery>
</cfif>
<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />

<CFSET BusEnabled = 0>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset BusEnabled = businessSegManager.isEnabledForDistributor()>

<!--- DEV NOT: DAA; D14555 --->
<CFPARAM NAME="SrchByAnalystAllowed" DEFAULT="false">
<cfif DeductionsProfilesSettings.DD_Search_By_Analyst>
	<cfset SrchByAnalystAllowed = true>
</cfif>
<!---
<CFIF FORM.DD_Aging NEQ "">
	<CFQUERY NAME="Get_Aging" DATASOURCE="#Application.Datasource#">
		SELECT * FROM DD_AGING WHERE Deleted=0 AND Tier_Number = '#FORM.DD_Aging#'
	</CFQUERY>
	<CFSET Aging_Start = Get_Aging.Start_Range>
	<CFSET Aging_End = Get_Aging.End_Range>
</CFIF> --->

<cfset useLakebaseForUserHasAssignments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
<cfif useLakebaseForUserHasAssignments>
	<cftry>
		<cfset UserHasAssignments = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_analyst", {
				"analyst_user_id" = "eq.#request.AccessStructure.User_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForUserHasAssignments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUserHasAssignments>
<CFQUERY NAME="UserHasAssignments" DATASOURCE="#Application.Datasource#">
	 SELECT * FROM DD_Analyst WHERE Analyst_User_ID = '#request.AccessStructure.User_ID#' AND Deleted=0
</CFQUERY>
</cfif>

<CFQUERY NAME="DefaultSupervisor" DATASOURCE="#Application.Datasource#">
SELECT Name_First, Name_Last
FROM _Users u INNER JOIN  DD_Analyst dda
ON u.User_ID = dda.Analyst_User_ID
WHERE dda.Is_Default_Supervisor = 1
</CFQUERY>

<!--- After Saru complete him work in deductions table
		take away the left join in DD_Analyst and use _users to get user name
		join Zone, region, market with deduction table guid --->
<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>

<CFINCLUDE TEMPLATE="/Deductions/DD_Supervisor_Qry.cfm">

<cfset FORM.Distributor_ID = Replace(FORM.Distributor, "#Chr(32)##chr(13)##chr(10)#", ",", "ALL")>
<cfset FORM.Distributor_ID = Replace(FORM.Distributor_ID, "#chr(32)#", ",", "ALL")>
<cfset NewDist="">
	<CFIF FORM.Distributor NEQ "" OR FORM.Distributor_Name NEQ "">
		<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
			SELECT BSA_Foodservice_Customers_ID
			FROM BSA_Foodservice_Customers
			WHERE
			(
			/* Label 9812- From the advanced search, we have search coming as a text search, and so I made it as varchar */
			/* Label 14445 - Do not add cfqueryparam here. It might not return results. */
			<CFIF FORM.Distributor NEQ "">
				<cfset iCounter = 0 >
				<cfset DistCtr = ListLen(FORM.Distributor_ID,"#chr(13)##chr(10)#") />
				<cfloop List ="#FORM.Distributor_ID#" index="dis_id_ctr" delimiters="#chr(13)##chr(10)#">
					<cfset iCounter = iCounter + 1 >
    	   				<cfset NewDist= NewDist & "'" & dis_id_ctr & "'">
   					<cfif iCounter LT DistCtr>
   				    		<cfset NewDist= NewDist & ",">
	   				</cfif>
				</cfloop>
			BSA_Foodservice_Customers.Shr_Ship_To IN ( #Replace(NewDist,"''","'","ALL")# )
			<CFELSE>
			1 = 1
			</CFIF>
			)
			/* First search by ship_to above and then search by distributor_name on the filtered results */
			<cfif (FORM.Distributor_Name NEQ "")>
			AND
			(
			<CFSET Counter = 0>
			<CFLOOP List ="#FORM.Distributor_Name#" index="dis_name_ctr" delimiters="#chr(13)##chr(10)#">
			<CFSET Counter = Counter + 1>
			<cfif Counter Neq 1>OR</cfif>
			BSA_Foodservice_Customers.Name LIKE '%#TRIM(dis_name_ctr)#%'
			</CFLOOP>
			)
			</cfif>


			AND BSA_Foodservice_Customers.Deleted = 0
			AND BSA_Foodservice_Customers.Active_Code = 'A'

			UNION

			SELECT Distributor_Bill_To_ID As BSA_Foodservice_Customers_ID
			FROM Distributor_Bill_To
			WHERE
			(
			/* Label 9812- From the advanced search, we have search coming as a text search, and so I made it as varchar */
			/* Label 14445 - Do not add cfqueryparam here. It might not return results. */
			/* Label 17719 - Match Central - Sold to / Bill to name field search[Bill to was not working] */
			<CFIF FORM.Distributor NEQ "">
				Distributor_Bill_To.Shr_Bill_To IN ( #Replace(NewDist,"''","'","ALL")# )
			<CFELSE>
			1 = 1
			</CFIF>
			)
			/* First search by ship_to above and then search by distributor_name on the filtered results */
			<cfif (FORM.Distributor_Name NEQ "")>
			AND
			(
			<CFSET Counter = 0>
			<CFLOOP List ="#FORM.Distributor_Name#" index="dis_name_ctr" delimiters="#chr(13)##chr(10)#">
			<CFSET Counter = Counter + 1>
			<cfif Counter Neq 1>OR</cfif>
			Distributor_Bill_To.Name LIKE '%#TRIM(dis_name_ctr)#%'
			</CFLOOP>
			)
			</cfif>
			AND Distributor_Bill_To.Deleted = 0
			AND Distributor_Bill_To.Active_Code = 'A'
		</CFQUERY>



			<CFIF Dist_Search_Result.Recordcount neq 0>
				<CFSET FORM.Distributor_ID = TRIM(ValueList(Dist_Search_Result.BSA_Foodservice_Customers_ID))>
			<CFELSE>
				<CFSET FORM.Distributor_ID = ''>
			</CFIF>
		<CFELSE>
			<CFSET FORM.Distributor_ID = ''>

	</CFIF>


<CFIF NOT ISDefined("FORM.DD_Report_CacheSpan")>
	<cfset FORM.DD_Report_CacheSpan = DateAdd("n",2,Now())  />    <!--- This is a fix for a CF Bug.  Set it to a future date or else it uses cache --->
</CFIF>


<CFPARAM NAME="FORM.apply_pagination" DEFAULT="0">
<cfif FORM.apply_pagination eq "1">
	<cfset vars = StructNew() />
	<cfset vars.start_row = startrow />
	<cfset vars.end_row = vars.start_row + FORM.pageLength - 1 />
</cfif>

<cftransaction isolation="read_uncommitted">

	<cfif isDefined('FORM.MC_CreateList') AND FORM.MC_CreateList NEQ "">
		<cfset FORM.DD_Number = FORM.MC_CreateList>
	</cfif>

<CFQUERY NAME="Get_Data" DATASOURCE="#Application.Datasource#" cachedafter="#FORM.DD_Report_CacheSpan#">

	<!--- 75568 :: Match Central - mass select and create list options START ---->
		<CFIF FORM.DD_Number NEQ "">
			IF OBJECT_ID('tempdb..##TMP_Deductions_List') IS NOT NULL
			DROP TABLE ##TMP_Deductions_List
			CREATE TABLE ##TMP_Deductions_List (DD_dedID nvarchar(100))
			<cfloop list="#form.DD_Number#" index="DD" delimiters=",#chr(13)##chr(10)##chr(9)#">
				INSERT INTO ##TMP_Deductions_List (DD_dedID)
				VALUES ('#TRIM(DD)#')
			</cfloop>
		</CFIF>
	<!--- 75568 :: Match Central - mass select and create list options END ---->

	<CFIF NOT ListFind(UserPositionList, HQPosition.User_Positions_ID)> <!---- not an HQ ----->
	DECLARE @Temp_Market_ID table
		(
			Service_Market_ID int
		)
	INSERT INTO @Temp_Market_ID(Service_Market_ID)
	SELECT DISTINCT Service_Markets.Service_Market_ID
	--INTO @Temp_Market_ID
	FROM 		User_Positions

	LEFT JOIN 	Service_Regions ON Service_Regions.Service_Zone_ID = User_Positions.Service_Zone_ID AND
				User_Positions.Service_Zone_ID IS NOT NULL AND
				User_Positions.Service_Region_ID IS NULL AND
				User_Positions.Service_Market_ID IS NULL

	LEFT JOIN 	Service_Markets ON
				(	(	Service_Markets.Service_Market_ID = User_Positions.Service_Market_ID AND
						User_Positions.Service_Market_ID IS NOT NULL
					) OR
					(	Service_Markets.Service_Region_ID = User_Positions.Service_Region_ID AND
						User_Positions.Service_Region_ID IS NOT NULL AND
						User_Positions.Service_Market_ID IS NULL
					) OR
					(	User_Positions.Service_Zone_ID IS NOT NULL AND
						User_Positions.Service_Region_ID IS NULL AND
						User_Positions.Service_Market_ID IS NULL AND
						Service_Markets.Service_Region_ID = Service_Regions.Service_Region_ID
					) OR
					(	1=1 AND
						User_Positions.Service_Zone_ID IS NULL AND
						User_Positions.Service_Region_ID IS NULL AND
						User_Positions.Service_Market_ID IS NULL
					)
				) AND Service_Markets.Service_Market_ID IS NOT NULL

	WHERE 		User_Positions.User_Positions_ID IN (#PreserveSingleQuotes(UserPositionList)#)
	</cfif>

<cfif FORM.apply_pagination eq "1">
IF OBJECT_ID('tempdb..##tmp_deductions_search_result') IS NOT NULL
DROP TABLE ##tmp_deductions_search_result
</cfif>

	SELECT
					<cfif FORM.apply_pagination eq "1">
	      			Paginate_Row_Number=IDENTITY (int, 1, 1),
	      			</cfif>
	      			datediff(d,dd_date,getdate()) NumberOfDays,
					DD_Aging.DD_Aging_Label,
					Deductions.*,
					DD_Classification.DD_Classification_Desc,
					DD_Stage.DD_Stage_Description,
					Replace(Replace(DD_Ded_Actions.Comments, CHAR(10), ' '), CHAR(13), ' ') as Comments,
					DD_Ded_Actions.Date_Completed,
					DD_Analyst.Is_Supervisor,
					_Users_1.Name_First As Supervisor_FirstName,
					_Users_1.Name_Last As Supervisor_LastName,
					DateDiff(day, DD_Date, getdate()) AS Deduction_Age,
					DD_Reason_Code.DD_Reason_Code,<!--- D26987 Deduction Search Results --->
					DD_Reason_Code.DD_Reason_Code_Description,
					DD_Status.DD_Status_ID,
					DD_Status.DD_Status_Description,
					Distributor_Bill_To.Name,
					Distributor_Bill_To.Shr_Bill_To,
					<CFIF FORM.Distributor_List  NEQ "" OR isMatchCentral>
					BSA_Foodservice_Customers.Name CustomerName,
					BSA_Foodservice_Customers.Ship_To,
					</CFIF>
					BSA_Foodservice_Brokers.Broker_Name,
					BSA_Foodservice_Brokers.Broker_Shard,
					Distributor_Family.Family,
					Distributor_Family.Family_Name,
					Service_Markets.Service_Market_ID,
					Service_Markets.Market_Name,
					Service_Regions.Region_Name,
					Service_Regions.Region_Number,
					Service_Zones.Zone_Name,
					Service_Zones.Zone_Number,
					_Users.Name_First,
					_Users.Name_last,
	<!--- D26987 Deduction Search Results START --->
	CASE WHEN _Users_2.Name_First IS NULL THEN

			CASE DD_Status
				WHEN 3 THEN RFA_By
				WHEN 4 THEN DD_Closed_By
			ELSE 'N/A'
			END
	ELSE
	_Users_2.Name_First + ' ' + _Users_2.Name_last

	END AS DD_UPDATE,
	<!--- D26987 Deduction Search Results END--->
					(SELECT Count(Deleted) FROM Contract_Attachments WHERE Contract_Attachments.Deduction_ID = Deductions.Deduction_ID AND Contract_Attachments.Deleted = 0) AS attachment_count,
				CASE WHEN BSA_Foodservice_Customers.Shr_ship_to IS NULL
				THEN
					Distributor_Bill_To.Name
				ELSE
					BSA_Foodservice_Customers.Name
				END AS Distributor_Name,
				BSA_Foodservice_Customers.Shr_ship_to,
				<!--- Ana D19384 Rebill Interface Arrows --->
				<!--- <cfif (appSettings.getIntegrated_Rebill() EQ 1)> --->
					DD_Rebill_Integration.Rebill_Ack_Status,
					DD_Rebill_Integration.Rebill_Number,
					DD_Rebill_Integration.Rebill_Ack_On,
					DD_Rebill_Integration.Rebill_Sent_On,
				<!--- </cfif> --->
				DD_Notes.DD_Note
        ,Deduction_Type.DeductionType_Desc  <!---26491--->
<cfif FORM.apply_pagination eq "1">
  into	##tmp_deductions_search_result
</cfif>
	FROM			Deductions WITH (NOLOCK)
	LEFT JOIN 		Distributor_Bill_To ON Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID
	LEFT JOIN	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
	INNER JOIN 	DD_Status ON DD_Status.DD_Status_ID = Deductions.DD_Status AND
				<CFIF FORM.DD_Number NEQ "">
				<!--- 75568 :: Match Central - mass select and create list options START ---->
					(EXISTS ( SELECT 1 FROM ##TMP_Deductions_List TMP WHERE  Deductions.DD_DedID_SP_Number like '%' + TMP.DD_dedID + '%')
	                			OR
	                		EXISTS ( SELECT 1 FROM ##TMP_Deductions_List TMP WHERE Deductions.DD_DedID like '%' + TMP.DD_dedID + '%')
	                		)
				<!--- 75568 :: Match Central - mass select and create list options END ---->
					AND
				</CFIF>
				<CFIF FORM.Analyst_User_ID NEQ "">
					Deductions.Analyst_User_ID in ( <!---D42846 :: Deduction tool upgrades--->
										                                    <cfscript>
										                                     listCount = 0;
										                                     listSize  = listLen(FORM.Analyst_User_ID);
										                                    </cfscript>
										                                    <cfloop index="thisStatus" list="#FORM.Analyst_User_ID#">
										                                     		'#thisStatus#'
										                                      <cfset listCount = listCount + 1>
										                                      <!---insert a comma if this status is not the last one in the list--->
										                                      <cfif (listCount lt listSize)>
										                                          ,
										                                      </cfif>
										                                    </cfloop>
										                                  )
					AND
				</CFIF>
				<CFIF FORM.DD_Status NEQ "">
          Deductions.DD_Status in ( <!---26491--->
				                                    <cfscript>
				                                     listCount = 0;
				                                     listSize  = listLen(FORM.DD_Status);
				                                    </cfscript>
				                                    <cfloop index="thisStatus" list="#FORM.DD_Status#">
				                                      #thisStatus#
				                                      <cfset listCount = listCount + 1>
				                                      <!---insert a comma if this status is not the last one in the list--->
				                                      <cfif (listCount lt listSize)>
				                                          ,
				                                      </cfif>
				                                    </cfloop>
				                                  ) AND
				</CFIF>
				<CFIF FORM.Filter_Closed EQ 1>
					Deductions.DD_Status NOT IN (4,5,6,9) AND
				</CFIF>
				<CFIF FORM.Filter_Attached EQ 1>
					Deductions.DD_Closure_ID IS NULL AND
					Deductions.Is_Write_Off = 0 AND
				</CFIF>
				<!--- Dev Note: KAL; 9034: Deduction Report status control --->
				<CFIF LISTLEN(DD_Status_toHide) GT 0>
					Deductions.DD_Status NOT IN (#DD_Status_toHide#) AND
				</CFIF>
			<!--- Dev Note(79256) - When we search for deductions from inside a billback --->
			<CFIF SearchSource EQ "Billback">
				<!--- Filter by billback's payee --->
				<CFIF Form.Filter_Distributor EQ 1>
					<CFIF FORM.Dist_ID NEQ "">
						(
						(Deductions.Distributor_ID IS NOT NULL AND Deductions.Distributor_ID = '#FORM.Dist_ID#')
						<cfif FORM.DistributorBillToID neq"">
						OR
						(Deductions.Distributor_ID IS NULL AND Deductions.Distributor_Bill_To_ID = '#FORM.DistributorBillToID#')
						</cfif>
						)
						AND
					</CFIF>
				<CFELSE>
					<!--- Open search on ship to or bill to --->
					<CFIF FORM.Distributor NEQ "" OR FORM.Distributor_Name NEQ "">
						<CFIF FORM.Distributor_ID NEQ "">
							(Deductions.Distributor_ID IN (#ListQualify(FORM.Distributor_ID, "'", ",")#)  OR Deductions.Distributor_Bill_To_ID IN (#ListQualify(FORM.Distributor_ID, "'", ",")#)	)
						<CFELSE>
							1=2
						</CFIF>
						AND
					</CFIF>
				</CFIF>
			<CFELSE>
			<CFIF FORM.Distributor NEQ "" OR FORM.Distributor_Name NEQ "">

					<CFIF FORM.Distributor_ID NEQ "">
						(Deductions.Distributor_ID IN (#ListQualify(FORM.Distributor_ID, "'", ",")#)  OR Deductions.Distributor_Bill_To_ID IN (#ListQualify(FORM.Distributor_ID, "'", ",")#)	)
					<CFELSE>
					  	1=2
					</CFIF>
			AND
		   <CFELSEIF FORM.Distributor_List NEQ "" >
					Deductions.Distributor_ID IN (#ListQualify(FORM.Distributor_List, "'", ",")#)
			AND
			<CFELSEIF FORM.MC_Shr_Ship_to NEQ "" OR FORM.MC_Shr_Bill_To NEQ "">
				(1=2
                    <cfif (appSettings.get_Setting('Deduction_match_using_bill_to_vendor') EQ '1')>
                    OR (Distributor_Bill_To.Shr_Bill_To = '#FORM.MC_Vendor_ID#'
                                 OR Distributor_Bill_To.Name LIKE '%#TRIM(FORM.MC_Vendor_Name)#%')
                    <cfelse>
                        <cfif (FORM.MC_Shr_Ship_to NEQ "")>
                         OR (BSA_Foodservice_Customers.Shr_Ship_To = '#FORM.MC_Shr_Ship_To#'
                         OR	BSA_Foodservice_Customers.Name LIKE '%#TRIM(FORM.MC_Distributor_Name)#%')
                        </cfif>

                        <CFIF (FORM.MC_Shr_Bill_To NEQ "")>
                         OR (

                            <CFIF (FORM.MC_Shr_Ship_to NEQ "") AND (FORM.MC_Shr_Ship_To NEQ FORM.MC_Shr_Bill_To)>
                            Deductions.Distributor_ID IS NULL AND
                            </CFIF>

                            (Distributor_Bill_To.Shr_Bill_To = '#FORM.MC_Shr_Bill_To#'
                             OR Distributor_Bill_To.Name LIKE '%#TRIM(FORM.MC_Bill_To_Name)#%')
                             )
                        </CFIF>
                    </cfif> <!--- cfelse appSettings.get_Setting('Deduction_match_using_bill_to_vendor' --->

					)
			AND
			</CFIF>
			</CFIF>

				<CFIF FORM.Distributor_Bill_To_ID NEQ "">
					Deductions.Distributor_Bill_To_ID = '#FORM.Distributor_Bill_To_ID#'
		   AND
				</CFIF>
				<CFIF FORM.Broker_List NEQ "">
					<!--- Deductions.Broker_ID = '#FORM.Broker_List#' AND --->
					Deductions.Broker_ID IN (#ListQualify(FORM.Broker_List, "'", ",")#) AND
				</CFIF>
				<CFIF FORM.DD_Stage_ID NEQ "">
					Deductions.DD_Stage in ( <!---D42846 :: Deduction tool upgrades--->
							                                    <cfscript>
							                                     listCount = 0;
							                                     listSize  = listLen(FORM.DD_Stage_ID);
							                                    </cfscript>
							                                    <cfloop index="thisStatus" list="#FORM.DD_Stage_ID#">
							                                      #thisStatus#
							                                      <cfset listCount = listCount + 1>
							                                      <!---insert a comma if this status is not the last one in the list--->
							                                      <cfif (listCount lt listSize)>
							                                          ,
							                                      </cfif>
							                                    </cfloop>
							                                  )
					 AND
				</CFIF>
				<CFIF FORM.DD_Amount NEQ "">
					(Deductions.DD_Amount <CFIF FORM.Dollar_Operator EQ "">=<CFELSE>#FORM.Dollar_Operator#</CFIF> '#FORM.DD_Amount#' <CFIF FORM.Dollar_Operator EQ "between">AND '#FORM.DD_To_Amount#'</CFIF>
					<cfif DeductionSettings.Use_Cleared_Amount IS 1>
					OR
					Deductions.Cleared_Amount <CFIF FORM.Dollar_Operator EQ "">=<CFELSE>#FORM.Dollar_Operator#</CFIF> '#FORM.DD_Amount#' <CFIF FORM.Dollar_Operator EQ "between">AND '#FORM.DD_To_Amount#'</CFIF>
					</cfif>) AND
				</CFIF>
				 <cfif form.date_time neq "">
					<cfif form.date_type is "deduction">
						CAST(Deductions.DD_Date AS DATE) #form.date_operator# #createODBCDate(form.date_time)# AND
					<cfelseif form.date_type is "created">
						CAST(Deductions.Created_Date AS DATE) #form.date_operator# #createODBCDate(form.date_time)# AND
					<cfelseif form.date_type is "closed">
						CAST(Deductions.DD_Date_Closed AS DATE) #form.date_operator# #createODBCDate(form.date_time)# AND
					</cfif>
					<cfif form.date_operator is "between">
						#createODBCDate(form.to_date_time)# AND
					</cfif>
				</cfif>
				<CFIF FORM.Check_No NEQ "">
					Deductions.DD_Check_Number Like '%#FORM.Check_No#%' AND
				</CFIF>
				<CFIF FORM.IsBusEnabled EQ 1>
					<CFIF FORM.Business_Segment_ID NEQ "">
						Deductions.Business_Segment_ID in ( <!---D42846 :: Deduction tool upgrades--->
													                                    <cfscript>
													                                     listCount = 0;
													                                     listSize  = listLen(FORM.Business_Segment_ID);
													                                    </cfscript>
													                                    <cfloop index="thisStatus" list="#FORM.Business_Segment_ID#">
													                                      #thisStatus#
													                                      <cfset listCount = listCount + 1>
													                                      <!---insert a comma if this status is not the last one in the list--->
													                                      <cfif (listCount lt listSize)>
													                                          ,
													                                      </cfif>
													                                    </cfloop>
													                                  )
						AND
					</CFIF>
					<CFIF FORM.Operating_Unit_ID NEQ "">
						Deductions.Operating_Unit_ID in ( <!---D42846 :: Deduction tool upgrades--->
												                                    <cfscript>
												                                     listCount = 0;
												                                     listSize  = listLen(FORM.Operating_Unit_ID);
												                                    </cfscript>
												                                    <cfloop index="thisStatus" list="#FORM.Operating_Unit_ID#">
												                                      #thisStatus#
												                                      <cfset listCount = listCount + 1>
												                                      <!---insert a comma if this status is not the last one in the list--->
												                                      <cfif (listCount lt listSize)>
												                                          ,
												                                      </cfif>
												                                    </cfloop>
												                                  )
						AND
					</CFIF>
				</CFIF>
				<CFIF FORM.Q_Brand_ID NEQ "">
					Deductions.Q_Brand_ID in ( <!---D42846 :: Deduction tool upgrades--->
								                                    <cfscript>
								                                     listCount = 0;
								                                     listSize  = listLen(FORM.Q_Brand_ID);
								                                    </cfscript>
								                                    <cfloop index="thisStatus" list="#FORM.Q_Brand_ID#">
								                                       #PreserveSingleQuotes(thisStatus)#
								                                      <cfset listCount = listCount + 1>
								                                      <!---insert a comma if this status is not the last one in the list--->
								                                      <cfif (listCount lt listSize)>
								                                          ,
								                                      </cfif>
								                                    </cfloop>
								                                  )
					AND
				</CFIF>
				<CFIF FORM.DD_Operator_ID NEQ "">
					Deductions.DD_Operator_ID in ( <!---D42846 :: Deduction tool upgrades--->
										                                    <cfscript>
										                                     listCount = 0;
										                                     listSize  = listLen(FORM.DD_Operator_ID);
										                                    </cfscript>
										                                    <cfloop index="thisStatus" list="#FORM.DD_Operator_ID#">
										                                      #thisStatus#
										                                      <cfset listCount = listCount + 1>
										                                      <!---insert a comma if this status is not the last one in the list--->
										                                      <cfif (listCount lt listSize)>
										                                          ,
										                                      </cfif>
										                                    </cfloop>
										                                  )
					AND
				</CFIF>
				<CFIF FORM.C1AR_Reference NEQ "">
					Deductions.DD_Reference Like '%#FORM.C1AR_Reference#%' AND
				</CFIF>
				<CFIF FORM.C1Cust_RefNo NEQ "">
					Deductions.DD_Customer_RefNo Like '%#FORM.C1Cust_RefNo#%' AND
				</CFIF>
				<CFIF FORM.IsParentDeduction eq 1>
					Deductions.Split_Count = 0 AND
				</CFIF>
				<CFIF FORM.DD_Reason_Code_ID NEQ "">
					Deductions.DD_Resolution_Code in ( <!---D42846 :: Deduction tool upgrades--->
												                                    <cfscript>
												                                     listCount = 0;
												                                     listSize  = listLen(FORM.DD_Reason_Code_ID);
												                                    </cfscript>
												                                    <cfloop index="thisStatus" list="#FORM.DD_Reason_Code_ID#">
												                                      #thisStatus#
												                                      <cfset listCount = listCount + 1>
												                                      <!---insert a comma if this status is not the last one in the list--->
												                                      <cfif (listCount lt listSize)>
												                                          ,
												                                      </cfif>
												                                    </cfloop>
												                                  )
					AND
				</CFIF>
				<CFIF FORM.Family_ID NEQ "">
					(Deductions.Ass_BasedOn_Family_ID in ( <!---D42846 :: Deduction tool upgrades--->
													                                    <cfscript>
													                                     listCount = 0;
													                                     listSize  = listLen(FORM.Family_ID);
													                                    </cfscript>
													                                    <cfloop index="thisStatus" list="#FORM.Family_ID#">
													                                      '#thisStatus#'
													                                      <cfset listCount = listCount + 1>
													                                      <!---insert a comma if this status is not the last one in the list--->
													                                      <cfif (listCount lt listSize)>
													                                          ,
													                                      </cfif>
													                                    </cfloop>
													                                  )

					OR
					 /* BSA_Foodservice_Customers.Family_ID = '#FORM.Family_ID#') AND */
					 BSA_Foodservice_Customers.Family_ID IN (
					  <cfscript>
	                      listCountCus = 0;
	                      listSizeCus  = listLen(FORM.Family_ID);
	                     </cfscript>
	                     <cfloop index="thisStatus" list="#FORM.Family_ID#">
	                       '#thisStatus#'
	                       <cfset listCountCus = listCountCus + 1>
	                       <!---insert a comma if this status is not the last one in the list--->
	                       <cfif (listCountCus lt listSizeCus)>
	                           ,
	                       </cfif>
	                     </cfloop>

					 )
					) AND
				</CFIF>
				Deductions.Deleted=0
	INNER JOIN	DD_Aging ON Start_Range <= datediff(d,Deductions.dd_date,getdate()) AND (End_Range IS NULL OR End_Range >= datediff(d,Deductions.dd_date,getdate())) AND DD_Aging.Deleted = 0
				<CFIF FORM.DD_Aging NEQ "">
									AND Tier_Number in ( <!---D42846 :: Deduction tool upgrades--->
									                                    <cfscript>
									                                     listCount = 0;
									                                     listSize  = listLen(FORM.DD_Aging);
									                                    </cfscript>
									                                    <cfloop index="thisStatus" list="#FORM.DD_Aging#">
									                                      #thisStatus#
									                                      <cfset listCount = listCount + 1>
									                                      <!---insert a comma if this status is not the last one in the list--->
									                                      <cfif (listCount lt listSize)>
									                                          ,
									                                      </cfif>
									                                    </cfloop>
									                                  )
				</CFIF>
	LEFT JOIN 		BSA_Foodservice_Brokers ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Deductions.Broker_ID
	<!---Brokers may not have market currently but may receive it in future so left join on service market table--->
	LEFT JOIN 	Service_Markets ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID

	<!--- Dev Note: Milan 7999 --->
	LEFT JOIN DD_Classification ON Deductions.DD_Classification_ID = DD_Classification.DD_Classification_ID

	LEFT JOIN DD_Ded_Actions ON Deductions.Deduction_ID = DD_Ded_Actions.Deduction_ID
	AND Deductions.DD_Stage = DD_Ded_Actions.DD_Stage_ID
	<!--- Ana: Added for label 8589 --->
	AND DD_Ded_Actions.DD_Ded_Action_ID = Deductions.DD_Ded_Action_ID
	AND DD_Ded_Actions.Deleted = 0
	<!--- END Ana: Added for label 8589 --->
	LEFT JOIN DD_Analyst ON DD_Analyst.Analyst_User_ID = Deductions.Analyst_User_ID
	AND DD_Analyst.Deleted = 0
	LEFT JOIN _Users _Users_1 ON _Users_1.User_ID = DD_Analyst.Supervisor_ID
	<!--- End Note: Milan 7999 --->

	<!--- <CFIF FORM.Line_Of_Business_ID NEQ "">
	INNER JOIN 		BSA_Foodservice_Customers ON BSA_Foodservice_Customers.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID
	INNER JOIN		Line_Of_Business ON Line_Of_Business.Line_Of_Business_ID = BSA_Foodservice_Customers.Line_Of_Business_ID AND
					Line_Of_Business.Line_Of_Business_ID = '#FORM.LINE_OF_BUSINESS_ID#'
	</CFIF> --->
	<!--- Make it as a inner join for family and Users once saru has his part done. --->
	LEFT JOIN		Distributor_Family ON Distributor_Family.Family_ID = Deductions.Ass_BasedOn_Family_ID
	LEFT JOIN 		_Users ON _Users.User_ID = replace(replace(replace(Deductions.Analyst_User_ID,char(13),char(32)),char(10),char(32)),char(9),char(32))
		<!--- D26987 Deduction Search Results START--->
	LEFT JOIN     _Users _Users_2 ON _Users_2.User_ID = CASE DD_Status
	WHEN 3 THEN RFA_BY
	WHEN 4 THEN DD_Closed_By
	END
		<!--- D26987 Deduction Search Results END--->

  LEFT JOIN 		Service_Regions ON Service_Regions.Service_Region_ID = BSA_Foodservice_Brokers.Service_Region_ID

	LEFT JOIN 		DD_Stage ON DD_Stage.DD_Stage_ID = Deductions.DD_Stage
	LEFT JOIN 		Service_Zones ON Service_Zones.Service_Zone_ID = BSA_Foodservice_Brokers.Service_Zone_ID

	LEFT JOIN 		DD_Reason_Code ON DD_Reason_Code.DD_Reason_Code_ID = Deductions.DD_Resolution_Code
	LEFT JOIN 		DD_Notes ON DD_Notes.DD_Note_ID = Deductions.Latest_DD_Note_ID AND DD_Notes.Deleted = 0
  LEFT JOIN     Deduction_Type ON Deductions.DeductionType_ID = Deduction_Type.DeductionType_ID    <!---26491--->
  <!---
     Dev Notes: 19384/Anand Rao/05-Apr-10
     Rebill Interface and changes
      --->
	<!--- Ana - D24651 commenting the below to avoid variable undefined error  --->
  <!--- <cfif (appSettings.getIntegrated_Rebill() EQ 1)> --->
    LEFT JOIN     DD_Rebill_Integration ON DD_Rebill_Integration.Deduction_ID = Deductions.Deduction_ID AND DD_Rebill_Integration.Deleted = 0
  <!--- </cfif> --->

	WHERE 			1=1 AND <!--- Deductions.Deleted=0 AND ---> <cfif appSettings.getDDSentRejectIn1510() NEQ 1>Deductions.DD_Rejected=0 AND</CFIF>
<!------------------------ check access permission - start -------------------------------------->
<!-----
Quick / Advanced Search					Profile Search By Analyst = ON
--------------------------------------------------------------------------------------------------------------------
HQ (not Analyst / not Supervisor)		All
HQ (Analyst / Supervisor)				All
Non HQ (not Analyst / not Supervisor)	All
Non HQ (Analyst / Supervisor)			All
--------------------------------------------------------------------------------------------------------------------
Quick / Advanced Search					Profile Search By Analyst = OFF
--------------------------------------------------------------------------------------------------------------------
HQ (not Analyst / not Supervisor)		All
HQ (Analyst / Supervisor)				All
Non HQ (not Analyst / not Supervisor)	Based on user position only
Non HQ (Analyst / Supervisor)			Based on analyst assignment only
------>
				<CFIF NOT DeductionsProfilesSettings.DD_ACCESS_LEVEL>
				1=2 AND
				<CFELSEIF NOT SrchByAnalystAllowed>
					<cfif displayOnlyAssignedDeductions and UserHasAssignments.RecordCount>
						Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#' AND
					<cfelse>
						<CFIF ListFind(UserPositionList, HQPosition.User_Positions_ID)> <!---- is an HQ ----->
							1=1
						<CFELSEIF UserHasAssignments.RecordCount AND NOT IaASupervisor.RecordCount><!--- not HQ, just an anlayst ---->
							Deductions.Analyst_User_ID = '#request.AccessStructure.User_ID#'
						<CFELSEIF UserIsASupervisor> <!---- not HQ, supervisor ----->
							Deductions.Analyst_User_ID IN (#LISTQUALIFY(AnalystUnderMe_List,"'",",","All")#)
						<CFELSE> <!---- not analyst, not supervisor, not HQ ---->
							Service_Markets.Service_Market_ID IN (SELECT Service_Market_ID FROM @Temp_Market_ID)
						</CFIF>
						 AND
					</cfif>
				</CFIF>
<!------------------------ check access permission - end -------------------------------------->
				<CFIF FORM.Service_Market_ID NEQ "">
					 Service_Markets.Service_Market_ID  in ( <!---D42846 :: Deduction tool upgrades--->
														                                    <cfscript>
														                                     listCount = 0;
														                                     listSize  = listLen(FORM.Service_Market_ID);
														                                    </cfscript>
														                                    <cfloop index="thisStatus" list="#FORM.Service_Market_ID#">
														                                       #PreserveSingleQuotes(thisStatus)#
														                                      <cfset listCount = listCount + 1>
														                                      <!---insert a comma if this status is not the last one in the list--->
														                                      <cfif (listCount lt listSize)>
														                                          ,
														                                      </cfif>
														                                    </cfloop>
														                                  )
					 AND
				</CFIF>
				<CFIF FORM.Service_Region_ID NEQ "">
					Service_Regions.Service_Region_ID in ( <!---D42846 :: Deduction tool upgrades--->
														                                    <cfscript>
														                                     listCount = 0;
														                                     listSize  = listLen(FORM.Service_Region_ID);
														                                    </cfscript>
														                                    <cfloop index="thisStatus" list="#FORM.Service_Region_ID#">
														                                      #PreserveSingleQuotes(thisStatus)#
														                                      <cfset listCount = listCount + 1>
														                                      <!---insert a comma if this status is not the last one in the list--->
														                                      <cfif (listCount lt listSize)>
														                                          ,
														                                      </cfif>
														                                    </cfloop>
														                                  )
					AND
				</CFIF>
				<CFIF FORM.Service_Zone_ID NEQ "">
					Service_Zones.Service_Zone_ID in ( <!---D42846 :: Deduction tool upgrades--->
												                                    <cfscript>
												                                     listCount = 0;
												                                     listSize  = listLen(FORM.Service_Zone_ID);
												                                    </cfscript>
												                                    <cfloop index="thisStatus" list="#FORM.Service_Zone_ID#">
												                                      '#thisStatus#'
												                                      <cfset listCount = listCount + 1>
												                                      <!---insert a comma if this status is not the last one in the list--->
												                                      <cfif (listCount lt listSize)>
												                                          ,
												                                      </cfif>
												                                    </cfloop>
												                                  )
					 AND
				</CFIF>
				<CFIF TRIM(FORM.Distributor_Bill_To) NEQ "">
					(Distributor_Bill_To.Shr_Bill_to LIKE '%#TRIM(FORM.Distributor_Bill_To)#%'
					OR Distributor_Bill_To.Name LIKE '%#TRIM(FORM.Distributor_Bill_To)#%'
					)AND
				</CFIF>
					<!---If no approval, only show those for the user--->
					<!---
					<cfif DeductionsProfilesSettings.DD_Approve IS 0 OR UserHasAssignments.RecordCount GT 0>
						Analyst_User_ID = '#request.AccessStructure.User_ID#' AND
					</cfif>
					 --->
					<CFIF FORM.Line_Of_Business_ID NEQ "">
						EXISTS
						(
							SELECT 		TOP 1 Cust.BSA_Foodservice_Customers_ID
							FROM		BSA_Foodservice_Customers Cust
							INNER JOIN 	Line_Of_Business ON Line_Of_Business.Line_Of_Business_ID = Cust.Line_Of_Business_ID AND
										Line_Of_Business.Line_Of_Business_ID in ( <!---D42846 :: Deduction tool upgrades--->
																			                                    <cfscript>
																			                                     listCount = 0;
																			                                     listSize  = listLen(FORM.LINE_OF_BUSINESS_ID);
																			                                    </cfscript>
																			                                    <cfloop index="thisStatus" list="#FORM.LINE_OF_BUSINESS_ID#">
																			                                      #PreserveSingleQuotes(thisStatus)#
																			                                      <cfset listCount = listCount + 1>
																			                                      <!---insert a comma if this status is not the last one in the list--->
																			                                      <cfif (listCount lt listSize)>
																			                                          ,
																			                                      </cfif>
																			                                    </cfloop>
																			                                  )
							WHERE 		Cust.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID AND
										Cust.Deleted = 0 AND Cust.Active_Code = 'A'
						) AND
					</CFIF>
					<CFIF FORM.Only_DD_With_Inactive_Relations EQ 1>
					(	BSA_Foodservice_Customers.Deleted <> 0
					OR	BSA_Foodservice_Customers.Active_Code <> 'A'
					OR	BSA_Foodservice_Brokers.Deleted <> 0
					OR	BSA_Foodservice_Brokers.Active_Code <> 'A'
					OR	Service_Markets.Deleted <> 0
					OR	Service_Regions.Deleted <> 0
					OR	Service_Zones.Deleted <> 0
					)
					 AND
					</CFIF>
					1=1

				<cfif SearchSource EQ "MatchCentralDD">
					AND Is_Credit = 0
					<!--- Ana 19384: Integrate Rebill
						- Exclude rebill from match central search
						- Rebill can not be matched to BB/Credit/DD
					 --->
					AND DD_Status <> 7
					<cfif FORM.DD_Ref NEQ "">
						AND Deductions.DD_Reference LIKE '%#FORM.DD_Ref#%'
					</cfif>
					<cfif FORM.DDAmountFilter NEQ "">
						AND DD_Amount <= #FORM.DDAmountFilter#
					</cfif>
				<cfelseif SearchSource EQ "MatchCentralCR">
					AND Is_Credit = 1
					<cfif FORM.DDAmountFilter NEQ "">
						AND DD_Amount >= #FORM.DDAmountFilter#
					</cfif>
					<cfif FORM.DD_Ref NEQ "">
						AND Deductions.DD_Reference LIKE '%#FORM.DD_Ref#%'
					</cfif>
				<!--- Dev Note(79256) - When we search for deductions from inside a billback --->
				<cfelseif SearchSource EQ "Billback">
					<cfif FORM.DD_Ref NEQ "">
						AND Deductions.DD_Reference LIKE '%#FORM.DD_Ref#%'
					</cfif>
					AND Is_Credit = 0
					AND DD_Status <> 7
					<cfif FORM.BBApprovedAmt NEQ "">
						<cfif appSettings.getDDCloseWithEqualBBAmt() eq 1>
							AND DD_Amount = #FORM.BBApprovedAmt#
						<cfelse>
							<!--- Since we do not plan to split the billback, we need to find a deduction, which will be of a higher
							or an equal amount of the billback.
							--->
							AND DD_Amount >= #FORM.BBApprovedAmt#
						</cfif>
					</cfif>

				</cfif>

				<cfif FORM.Broker_Name NEQ "">
					AND BSA_Foodservice_Brokers.Broker_Name LIKE '%#FORM.Broker_Name#%'
				</cfif>

				<cfif BusEnabled EQ 1 AND (isdefined('businessSegmentID') and businessSegmentID NEQ '') AND (SearchSource EQ "MatchCentralDD" OR SearchSource EQ "MatchCentralCR")>
				AND
				(
					SELECT BSA_Foodservice_Customers.Business_Segment_ID
					FROM BSA_Foodservice_Customers
					WHERE Deductions.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
				)
				 =
							 <!--- Milan (19466) This is the Billback Payee's Business segment ID. This needs to match the business
										 segment of the deduction's distributor (in the query above)
								--->
								CASE '#businessSegmentID#'
									<!--- Do not filter when the Payee is the Vendor (Vendors do not have a business segment) --->
									WHEN ''
										THEN
											(
											SELECT BSA_Foodservice_Customers.Business_Segment_ID
											FROM BSA_Foodservice_Customers
											WHERE Deductions.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
											)
									ELSE
									'#businessSegmentID#'
								END
				</cfif>
        <!---
	      Dev Notes: 19384/Anand Rao/05-Apr-10
	      Rebill Interface and changes
        --->
        <cfif (appSettings.getIntegrated_Rebill() EQ 1) AND FORM.Rebill_Number NEQ "">
          AND DD_Rebill_Integration.Rebill_Number LIKE '%#FORM.Rebill_Number#%'
        </cfif>

        <!---26472 - 2011-mar-8 chrisn: added classification--->
        <cfif FORM.Classification neq "0">AND Deductions.DD_Classification_ID in (#FORM.Classification#)</cfif>
        <!---26487 - 2011-mar-9 chrisn: added deduction type--->
        <cfif FORM.DeductionType neq "0">AND Deductions.DeductionType_ID in (#FORM.DeductionType#)</cfif>
        <!--- 75584 :: In Advance deduction search screen add two new text fields that user can search on START---->
        <cfif len(FORM.InvoiceNo)>AND DD_Invoice_Number like '%#form.InvoiceNo#%'</cfif>
        <cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1' and len(FORM.OrderNo)>
        	AND EXISTS ( SELECT 1 FROM DD_Notes WHERE DD_Note like 'ORDER NUMBER: %#FORM.OrderNo#%'  AND Deduction_ID = Deductions.Deduction_ID AND Deleted = 0)
        </cfif>
        <!--- 75584 :: In Advance deduction search screen add two new text fields that user can search on END---->
	ORDER BY
					<cfswitch expression="#form.sort_by#">
						<cfcase value="Broker_Name">
							BSA_Foodservice_Brokers.Broker_Name
						</cfcase>
						<cfcase value="Name">
							Distributor_Name
						</cfcase>
						<cfcase value="Classification">
							dd_Classification_desc
						</cfcase>
						<cfdefaultcase>
							#form.sort_by#
						</cfdefaultcase>
					</cfswitch>
					#FORM.SORT_ORDER#

<cfif FORM.apply_pagination eq "1">
	declare @recordcount int
	select @recordcount = count(deduction_id) from ##tmp_deductions_search_result

	select	*,
			@recordcount AS record_count
	from	##tmp_deductions_search_result
	WHERE Paginate_Row_Number >= #vars.start_row#
	AND Paginate_Row_Number <= #vars.end_row#
	ORDER BY Paginate_Row_Number


	IF OBJECT_ID('tempdb..##tmp_deductions_search_result') IS NOT NULL
	DROP TABLE ##tmp_deductions_search_result

	<!--- 75568 :: Match Central - mass select and create list options START ---->
		<CFIF FORM.DD_Number NEQ "">
			IF OBJECT_ID('tempdb..##TMP_Deductions_List') IS NOT NULL
			DROP TABLE ##TMP_Deductions_List
		</CFIF>
	<!--- 75568 :: Match Central - mass select and create list options END ---->

</cfif>

</CFQUERY>
</cftransaction>