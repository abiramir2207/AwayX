<CFPARAM name="form.IFRAME_Extra_URL" 	default="">
<CFPARAM name="Form.PL_PostSubmit" 		default="">
<CFPARAM name="Form.PL_PreSubmit" 		default="">
<CFPARAM name="Form.PL_Final" 			default="">
<CFPARAM name="form.PL_ImportProducts"  default="0">
<CFPARAM name="form.PL_ImportAllProducts"  default="0">
<CFPARAM name="Form.BidStatus" default="">
<CFPARAM NAME="FORM.Class_Code_ID" DEFAULT="0">
<CFPARAM NAME="FORM.Product_Hierarchy_ID" DEFAULT="0">

<cfparam name="Records_To_Show" default=13>

<!---Includes personal preferences for records to show--->
<!--- <cfinclude template="/settings/personalization/records_to_return.cfm">
 --->

<CFPARAM name="url.SearchIsConductedFromOtherWindow" default="0">

<cfif url.SearchIsConductedFromOtherWindow EQ 1>
	<CFSET Form.IFRAME_Extra_URL = "?ShowCheckBoxes=1&SearchIsConductedFromOtherWindow=1">

	<cf_List_Compare List1="#Form.PL_PostSubmit#" List2="#Form.PL_PreSubmit#">
	
	<cfif listlen(trim(LC_Results1)) GT 0>
		<CFSET Form.PL_Final = listappend(Form.PL_Final, LC_Results1)>
	</cfif>
	
	<cfif listlen(trim(LC_Results2)) GT 0>
		<cfloop index="x" list="#LC_Results2#">
			<CFSET ItemPosition = listfind(Form.PL_Final, x)>
			<cfif ItemPosition NEQ 0>
				<cfset Form.PL_Final = listdeleteAt(Form.PL_Final, ItemPosition)>
			</cfif>
		</cfloop>
	</cfif>
	
	</cfif>

<cfif form.PL_ImportProducts EQ 1>
	<cfoutput>
	<script>
		window.parent.returnValue = '#Form.PL_Final#';
		window.close();
	</script>
	</cfoutput>
<cfabort>
</cfif>

<cfif form.PL_ImportAllProducts EQ 1>
	<cfoutput>
	<script>
		window.parent.returnValue = '#form.PL_AllProductList#';
		window.close();
	</script>
	</cfoutput>
</cfif>

<!------
program_Search_Result.cfm
----->
<CFPARAM name="form.businessSegmentsOn" default="0">
<cfset Business_Segment_ID_List = "">
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabled()>
		<cfset form.businessSegmentsOn = 1 />
		<cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.User_ID) />
		<cfset Business_Segment_ID_List = ValueList(qGetBusSegments.Business_Segment_ID, ",")>
</cfif>

<!----defaults--->
<CFSET table_Width=910>

<CFSET Status_Width=60>
<CFSET Number_Width=90>
<CFSET Type_Width=140>
<CFSET Title_Width=375>
<CFSET SD_Width=45>
<CFSET ED_Width=45>
<CFSET Quantity_Width=80>
<CFSET BusSeg_Width=65>
<CFSET SCISSOR_Width=10>

<CFSET Title_Len=60>
<CFSET Type_Len=28>

<CFSET Default_Sort = "CT">
<CFSET Default_Sort_Order = "ASC">

<CFSET User_Position_Operator_List = "Created By, Requesting Approval,Approved By">
<!---end default--->

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">
<CFIF isdefined("FORM.DOSEARCH")>

<CFSET PW_Type="1">
 <SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<CFFLUSH>
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<CFPARAM NAME="FORM.Program_Title" DEFAULT="">
<CFPARAM NAME="FORM.Program_Number" DEFAULT="">
<CFPARAM NAME="FORM.Status" DEFAULT="0">
<CFPARAM NAME="FORM.Bid_Status" DEFAULT="0">
<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
<cfparam name="FORM.Business_Segment_ID" 	default="0">
<cfparam name="FORM.Legacy_Deal_ID" 	default="">

<CFPARAM NAME="FORM.Start_date_Operator" DEFAULT="">
<CFPARAM NAME="FORM.Start_date" DEFAULT="">
<CFPARAM NAME="FORM.End_date_Operator" DEFAULT="">
<CFPARAM NAME="FORM.End_date" DEFAULT="">
<CFPARAM NAME="FORM.Open_date_Operator" DEFAULT="">
<CFPARAM NAME="FORM.Open_date" DEFAULT="">
<CFPARAM NAME="FORM.Needed_date_Operator" DEFAULT="">
<CFPARAM NAME="FORM.Needed_date" DEFAULT="">

<CFPARAM NAME="FORM.Distributor_Info" DEFAULT="">
<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">
<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
<CFPARAM NAME="FORM.Operator_Name" DEFAULT="">

<CFPARAM NAME="FORM.Service_Zone_ID" 	DEFAULT="0">
<CFPARAM NAME="FORM.Service_Region_ID" 	DEFAULT="0">
<CFPARAM NAME="FORM.Service_Market_ID" 	DEFAULT="0">


<cfif url.SearchIsConductedFromOtherWindow EQ 0>
	<CFINCLUDE TEMPLATE="/scorecard/unlock_programs.cfm">
</cfif>

<cfset useLakebaseForgetUserPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForgetUserPosition>
	<cftry>
		<cfset getUserPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserPosition>
<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>
</cfif>


<!------ Get application settings ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!----------------------------------------------------------
Access Permissions
----------------------------------------------------------->

<CFINCLUDE TEMPLATE="/scorecard/access_permissions.cfm">

<!---------------------------------------------------
Access Permission End
---------------------------------------------------->


<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

<cfparam name="FORM.sort_by" 	default="#Default_Sort#">
<cfparam name="FORM.sort_Order" 	default="#Default_Sort_Order#">

<CFSET sql_Sort_By="dbo.contract_main.contract_number">
<CFSWITCH expression="#FORM.sort_by#">
	<CFCASE value="ST">
		<CFSET sql_Sort_By="contract_main.Contract_Status_Type_IDX">
	</CFCASE>
	<CFCASE value="BS">
		<CFSET sql_Sort_By="Program_Bid_Request.Bid_Request_Status_ID">
	</CFCASE>
	<CFCASE value="PN">
		<CFSET sql_Sort_By="contract_main.Contract_Number">
	</CFCASE>
	<CFCASE value="PT">
		<CFSET sql_Sort_By="contract_main.Contract_Title">
	</CFCASE>
	<CFCASE value="START">
		<CFSET sql_Sort_By="contract_main.Contract_Start_Date">
	</CFCASE>
	<CFCASE value="EN">
		<CFSET sql_Sort_By="contract_main.Contract_End_Date">	
	</CFCASE>
	<CFCASE value="OP">
		<CFSET sql_Sort_By="Program_Bid_Request.Open_Date">		
	</CFCASE>
	<CFCASE value="NB">
		<CFSET sql_Sort_By="Program_Bid_Request.Date_Needed">
	</CFCASE>
	<CFCASE value="BusS">
		<CFSET sql_Sort_By="Business_Segment.Business_Unit_Desc">
	</CFCASE>
</CFSWITCH>

<CFIF FORM.sort_Order EQ "DESC">
	<CFSET sql_Sort_By="#sql_Sort_By# DESC">
<CFELSE>
	<CFSET sql_Sort_By="#sql_Sort_By# ASC">
</CFIF>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->
	
<CFQUERY NAME="TheQuery" datasource="#application.datasource#">

			DECLARE @Positions_Below_Me table
			(
			  Below_User_Positions_ID   int          NOT NULL
			)
			INSERT INTO @Positions_Below_Me(Below_User_Positions_ID)
			SELECT	DISTINCT Below_User_Positions_ID
			FROM	Positions_Below_Me
			WHERE	User_Positions_ID IN (#PreserveSingleQuotes(UserPositionList)#)
			
			
		SELECT	DISTINCT 
				Contract_Main.Contract_Main_ID, 
				Contract_Main.Contract_Number, 
				Contract_Main.Contract_Title, 
				Contract_Main.Contract_Start_Date, 
				Contract_Main.Contract_End_Date, 
				Contract_Main.Contract_Status_Type_IDX, 
				Contract_Main.Contract_Is_Locked,
				<cfif form.businessSegmentsOn EQ 1>
				Contract_Main.Business_Segment_ID,
				</cfif>
				Units_of_Measure.Unit_Of_Measure_Desc, 
				dbo.Units_of_Measure.Abbreviation, 
				Bid_Request_Status.Status_Desc,
				Program_Bid_Request.Open_Date,
				Program_Bid_Request.Date_Needed,
				Program_Bid_Request.Bid_Request_Status_ID,
				Contract_Main.Contract_Quantity, 
				Contract_Main.Contract_Reference_Number, 
				Contract_Main.Contract_Locked_By_User_ID, 
				 _Users.Name_First, 
				 _Users.Name_Last,
				 Approval_date, 
				 Broker_Approved_Date, 
				 Revision_of_Contract_Main_ID, 
				 Is_A_Revision, 
		(
			SELECT 	COUNT(*)
			FROM	Contract_Attachments
			WHERE
					Contract_Attachments.Program_ID = Contract_Main.Contract_Main_ID
					AND
					Contract_Attachments.Deleted = 0
		) AS Contract_Attachments_Count,
		<cfif form.businessSegmentsOn EQ 1>
		Business_Segment.Business_Unit_Desc
		<cfelse>'' As Business_Unit_Desc
		</cfif>
		FROM	
				Contract_Main
				INNER JOIN			dbo.Units_of_Measure 
				ON 
				dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
				INNER JOIN			Program_Control_Panel_Options
				ON
				Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID	
				
							
				LEFT JOIN			_Users 
				ON 
					(
					(Contract_Main.Broker_User_ID = _Users.User_ID)
					AND
					((Contract_Main.Broker_User_ID = _Users.User_ID) AND (Contract_Status_Type_IDX = 2))
					OR
					((Contract_Main.Approved_By_User_ID = _Users.User_ID) AND (Contract_Status_Type_IDX >= 4))
					) 
					
				<!---Join Bid Request stuff--->
				INNER JOIN Program_Bid_Request
				ON Program_Bid_Request.Program_ID = Contract_Main.Contract_Main_ID
				
				<!---Get Bid status--->
				INNER JOIN Bid_Request_Status
				ON Program_Bid_Request.Bid_Request_Status_ID = Bid_Request_Status.Bid_Request_Status_ID
					
				<cfif form.businessSegmentsOn EQ 1>
				LEFT JOIN Business_Segment
				ON
				Business_Segment.Deleted = 0
				AND
				Business_Segment.Business_Segment_ID = Contract_Main.Business_Segment_ID
				</cfif>
				<!---get the list of hierarchy levels--->
				<cfset lHierLevels = application.oApplicationAppSettingsManager.getApplicationAppSettings().getBidRequestHierarchyLevel() />
				<!---handle product filter logic--->
				<cfset bRunProdFilter = 0 />
				<!---build list of string form fields--->
				<cfset lStrFormFields = "item_number,UPC,description" />
				<!---loop over and verify if any of these form fields have a value--->
				<cfloop index="formIndx" list="#lStrFormFields#">
					<cfif Len(trim(Evaluate("form.#formIndx#")))>
						<cfset bRunProdFilter = 1 />
						<cfbreak />
					</cfif>
				</cfloop>
				<!---build list of numeric form fields if bRunProdFilter is 0--->
				<cfif not bRunProdFilter>
					<cfset lIntFormFields = "" />
					<cfloop index="levlIndx" list="#lHierLevels#">
						<cfset lIntFormFields = ListAppend(lIntFormFields, "Product_Hierarchy_ID_#levlIndx#") />
					</cfloop>
					<cfset lIntFormFields = ListAppend(lIntFormFields, "Brand_ID") />
					<cfset lIntFormFields = ListAppend(lIntFormFields, "Class_Code_ID") />
					<!---loop over and verify if any of these form fields were selected--->
					<cfloop index="formIndx" list="#lIntFormFields#">
						<cfif trim(Evaluate("form.#formIndx#")) gt 0>
							<cfset bRunProdFilter = 1 />
							<cfbreak />
						</cfif>
					</cfloop>
				</cfif>
				<!---//////////////Product Filter///////////////--->
				<cfif bRunProdFilter>
					INNER JOIN Contract_Products ON
					Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND Contract_Products.Deleted = 0
					INNER JOIN BSA_Foodservice_Items_Master ON
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					AND BSA_Foodservice_Items_Master.Deleted = 0
					AND
					(
						<!---we have to do logic for and and or operators. it's not pretty--->
						<cfif Len(trim(form.item_number))>
							BSA_Foodservice_Items_Master.Item = '#trim(form.item_number)#'
						</cfif>
						<cfif Len(trim(form.UPC))>
							<cfif Len(trim(form.item_number))>OR</cfif>
							BSA_Foodservice_Items_Master.UPC = '#trim(form.UPC)#'
						</cfif>
						<cfif form.Brand_ID neq 0>
							<cfif Len(trim(form.item_number)) or Len(trim(form.UPC))>OR</cfif>
							BSA_Foodservice_Items_Master.Brand_ID = '#form.Brand_ID#'
						</cfif>
						<cfif Len(trim(form.description))>
							<cfif Len(trim(form.item_number)) or Len(trim(form.UPC)) or form.Brand_ID neq 0>OR</cfif>
							BSA_Foodservice_Items_Master.Description LIKE '%#trim(form.description)#%'
						</cfif>
						<!---class code filter--->
						<cfif FORM.Class_Code_ID>
							<cfif Len(trim(form.item_number)) or Len(trim(form.UPC)) or form.Brand_ID neq 0 or Len(trim(form.description))>OR</cfif>
							BSA_Foodservice_Items_Master.Class_Code_ID = '#trim(form.Class_Code_ID)#'
						</cfif>
						<!---product hierarchy filter--->
						<!---set flag to tell me whether or not to put an and condition--->
						<cfset bAndFlag = 0 />
						<cfloop index="levlIndx" list="#lHierLevels#">
							<cfif Evaluate("form.Product_Hierarchy_ID_#levlIndx#") neq 0>
								<cfif Len(trim(form.item_number)) or Len(trim(form.UPC)) or form.Brand_ID neq 0 or Len(trim(form.description)) or FORM.Class_Code_ID and not bAndFlag>
									OR
								</cfif>
								<cfif bAndFlag>AND</cfif>
								BSA_Foodservice_Items_Master.Product_Hierarchy_ID IN (SELECT Product_Hierarchy_ID FROM udf_GetProductChainBelow('#Evaluate("form.Product_Hierarchy_ID_#levlIndx#")#'))
								<cfset bAndFlag = 1 />
							</cfif>
						</cfloop>
					)
				</cfif>
		WHERE	
				Contract_Main.Deleted = 0
				--AND
				--Contract_Status_Type_IDX >= 0
				AND
				Contract_Main.Flagged_As_Purged = 0				
				AND
				(
					(Contract_Main.Force_Expiration_Flag = 0)
					OR
					(Contract_Status_Type_IDX = 7)
				)
				
			
				<cfif form.businessSegmentsOn EQ 1>
					<CFIF FORM.Business_Segment_ID NEQ "0"  AND FORM.Business_Segment_ID NEQ "">
					AND Contract_Main.Business_Segment_ID IN (#FORM.Business_Segment_ID#)
				</CFIF>
					<CFIF FORM.Legacy_Deal_ID NEQ "">
					AND Contract_Main.Legacy_Deal_ID LIKE '%#FORM.Legacy_Deal_ID#%'
					</CFIF>
				</cfif>
				
				<CFIF Form.Status NEQ "0" and Form.Status NEQ 1>
					AND Contract_Status_Type_IDX = #Form.Status#
				<cfelseif Form.Status EQ 1>
					AND Contract_Status_Type_IDX IN (5,6,7)
				<CFELSE>
					AND Contract_Status_Type_IDX > 1
				</CFIF>		
				
				<!---Bid status--->		
				<CFIF len(trim(Form.BidStatus)) IS 1 >
					AND Bid_Request_Status.Bid_Request_Status_ID = #Form.BidStatus#
				<CFELSEIF len(trim(Form.BidStatus)) GT 1>
					<!---Not lost--->
					AND Bid_Request_Status.Bid_Request_Status_ID IN (#Form.BidStatus#)
				</CFIF>	
				
				
				<CFIF Len(Trim(Form.Start_Date)) GT 0 AND ISDate(Form.Start_Date) AND (Form.Start_date_Operator EQ "Greater_Or_Equal" OR Form.Start_date_Operator EQ "Equal" OR Form.Start_date_Operator EQ "Less_Or_Equal")>
					AND DateDiff(d, '#Form.Start_Date#', Contract_Start_Date)
					<CFSWITCH expression="#Form.Start_date_Operator#">
						<CFCASE value="Greater_Or_Equal">
						>=
						</CFCASE>
						<CFCASE value="Equal">
						=
						</CFCASE>
						<CFCASE value="Less_Or_Equal">
						<=
						</CFCASE>
					</CFSWITCH>					
					0
				</CFIF>
				<CFIF Len(Trim(Form.End_Date)) GT 0 AND ISDate(Form.End_Date) AND (Form.End_date_Operator EQ "Greater_Or_Equal" OR Form.End_date_Operator EQ "Equal" OR Form.End_date_Operator EQ "Less_Or_Equal")>
					AND DateDiff(d, '#Form.End_Date#', Contract_End_Date)
					<CFSWITCH expression="#Form.End_date_Operator#">
						<CFCASE value="Greater_Or_Equal">
						>=
						</CFCASE>
						<CFCASE value="Equal">
						=
						</CFCASE>
						<CFCASE value="Less_Or_Equal">
						<=
						</CFCASE>
					</CFSWITCH>					
					0
				</CFIF>
				
				<!---Open date--->
				<CFIF Len(Trim(Form.Open_Date)) GT 0 AND ISDate(Form.Open_Date) AND (Form.Open_Date_Operator EQ "Greater_Or_Equal" OR Form.Open_Date_Operator EQ "Equal" OR Form.Open_Date_Operator EQ "Less_Or_Equal")>
					AND DateDiff(d, '#Form.Open_Date#', Program_Bid_Request.Open_date)
					<CFSWITCH expression="#Form.Open_Date_Operator#">
						<CFCASE value="Greater_Or_Equal">
						>=
						</CFCASE>
						<CFCASE value="Equal">
						=
						</CFCASE>
						<CFCASE value="Less_Or_Equal">
						<=
						</CFCASE>
					</CFSWITCH>					
					0
				</CFIF>
				
				<!---Needed by date--->
				<CFIF Len(Trim(Form.Needed_Date)) GT 0 AND ISDate(Form.Needed_Date) AND (Form.Needed_Date_Operator EQ "Greater_Or_Equal" OR Form.Needed_Date_Operator EQ "Equal" OR Form.Needed_Date_Operator EQ "Less_Or_Equal")>
					AND DateDiff(d, '#Form.Needed_Date#', Program_Bid_Request.Date_Needed)
					<CFSWITCH expression="#Form.Needed_Date_Operator#">
						<CFCASE value="Greater_Or_Equal">
						>=
						</CFCASE>
						<CFCASE value="Equal">
						=
						</CFCASE>
						<CFCASE value="Less_Or_Equal">
						<=
						</CFCASE>
					</CFSWITCH>					
					0
				</CFIF>
				
				
				<CFIF Trim(Form.Program_Title) GT 0>
					AND Contract_Main.Contract_Title LIKE '%#Form.Program_Title#%'
				</CFIF>
				<CFIF Trim(Form.Program_Number) GT 0>
					AND Contract_Main.Contract_Number LIKE '%#Form.Program_Number#%'
				</CFIF>				
				<CFIF Len(Form.Operator_Name) GT 0>
					AND
					EXISTS
					(
						SELECT	TOP 1 Contract_Operators.Contract_Main_ID
						FROM	Contract_Operators
								INNER JOIN	BSA_Operator
								ON
								(
									(BSA_Operator.Deleted = 0)
									AND
									(Contract_Operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID)									
									AND
									(BSA_Operator.Operator_Name Like '%#Form.Operator_Name#%')
								)
						WHERE
							Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
							AND							
							Contract_Operators.Deleted = 0
					)
				</CFIF>
				<CFIF Form.Broker_ID NEQ "0" OR FORM.Service_Zone_ID  NEQ "0" OR FORM.Service_Region_ID  NEQ "0" OR FORM.Service_Market_ID  NEQ "0">
					AND
					EXISTS
					(
						SELECT TOP 1 Contract_Main_ID FROM
						(
						SELECT	TOP 1 Contract_Distributors.Contract_Main_ID
						FROM	BSA_FoodService_Customers							
							INNER JOIN Contract_Distributors
							ON 
							Contract_Distributors.Deleted = 0 
							AND Contract_Distributors.BSA_FoodService_Customers_ID = BSA_FoodService_Customers.BSA_FoodService_Customers_ID
							<CFIF FORM.Service_Zone_ID  NEQ "0" OR FORM.Service_Region_ID  NEQ "0" OR FORM.Service_Market_ID  NEQ "0">
							INNER JOIN BSA_Foodservice_Brokers
							ON
							BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_FoodService_Customers.BSA_Foodservice_Brokers_ID
							AND
							BSA_Foodservice_Brokers.Deleted = 0
							<CFIF Form.Service_Market_ID NEQ "0">
								AND BSA_Foodservice_Brokers.Service_Market_ID = #Form.Service_Market_ID#
							</CFIF>
							<CFIF Form.Service_Region_ID NEQ "0">
								AND BSA_Foodservice_Brokers.Service_Region_ID = '#Form.Service_Region_ID#'
							</CFIF>
							<CFIF FORM.Service_Zone_ID NEQ "0">								
								INNER JOIN Service_Regions
								ON
								Service_Regions.Service_Region_ID = BSA_Foodservice_Brokers.Service_Region_ID
								AND
								Service_Regions.Deleted = 0
								AND
								Service_Regions.Service_Zone_ID = '#Form.Service_Zone_ID#'
							</CFIF>
							</CFIF>
						WHERE
							<CFIF Form.Broker_ID NEQ "0">
							BSA_FoodService_Customers.BSA_Foodservice_Brokers_ID = '#Form.Broker_ID#'
							AND
							</CFIF>
							Contract_Main_ID = Contract_Main.Contract_Main_ID
						
						UNION
						
						SELECT	TOP 1 Contract_Brokers.Contract_Main_ID
						FROM	Contract_Brokers
							<CFIF FORM.Service_Zone_ID  NEQ "0" OR FORM.Service_Region_ID  NEQ "0" OR FORM.Service_Market_ID  NEQ "0">
							INNER JOIN BSA_Foodservice_Brokers
							ON
							BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Contract_Brokers.BSA_Foodservice_Brokers_ID
							AND
							BSA_Foodservice_Brokers.Deleted = 0
							<CFIF Form.Service_Market_ID NEQ "0">
								AND BSA_Foodservice_Brokers.Service_Market_ID = #Form.Service_Market_ID#
							</CFIF>
							<CFIF Form.Service_Region_ID NEQ "0">
								AND BSA_Foodservice_Brokers.Service_Region_ID = '#Form.Service_Region_ID#'
							</CFIF>
							<CFIF FORM.Service_Zone_ID  NEQ "0">
								INNER JOIN Service_Regions
								ON
								Service_Regions.Service_Region_ID = BSA_Foodservice_Brokers.Service_Region_ID
								AND
								Service_Regions.Deleted = 0
								AND
								Service_Regions.Service_Zone_ID = '#Form.Service_Zone_ID#'
							</CFIF>
							</CFIF>
						WHERE
							Contract_Brokers.Deleted = 0 							
							<CFIF Form.Broker_ID NEQ "0">
							AND Contract_Brokers.BSA_Foodservice_Brokers_ID = '#Form.Broker_ID#'							
							</CFIF>
							AND Contract_Main_ID = Contract_Main.Contract_Main_ID
						
						) AS DDD
					)
				</CFIF>
				<CFIF (((Form.Family_Name NEQ "0") OR (Form.Buying_Group NEQ "0"))) OR (Len(Form.Distributor_Info) GT 0)>
					AND
					EXISTS
					(
					SELECT	TOP 1 Contract_Distributors.Contract_Main_ID
					FROM
							Contract_Distributors							
							---INNER JOIN START
							
							<!---Distributors--->
							INNER JOIN					
							BSA_FoodService_Customers
							ON							
							(BSA_FoodService_Customers.BSA_FoodService_Customers_ID = Contract_Distributors.BSA_FoodService_Customers_ID)							
							<CFIF ((Form.Family_Name NEQ "0") OR (Form.Buying_Group NEQ "0"))>
							AND
							NOT (BSA_FoodService_Customers.BSA_FoodService_Customers_ID IS NULL)
							</CFIF>
							<CFIF Len(Trim(Form.Distributor_Info)) GT 0>
							AND
							(
							BSA_FoodService_Customers.Name LIKE '%#Form.Distributor_Info#%'
							OR
							BSA_FoodService_Customers.Shr_Ship_To LIKE '%#Form.Distributor_Info#%'
							)
							</CFIF>							
						WHERE
							Contract_Distributors.Deleted = 0
							AND
							Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
							<CFIF Form.Family_Name NEQ "0">
							AND
							EXISTS
							(
								SELECT	TOP 1 Distributor_Family.Family_ID
								FROM	Distributor_Family
								WHERE
									Distributor_Family.family_ID = BSA_FoodService_Customers.family_ID
									AND
									Distributor_Family.Deleted=0
									AND
									Distributor_Family.Family_ID = '#Form.Family_Name#'
							)	
							</CFIF>						
							<CFIF Form.Buying_Group NEQ "0">
							AND
							EXISTS
							(
								SELECT	TOP 1 Distributor_Buying_Groups.Buying_Group_ID
								FROM	Distributor_Buying_Groups
								WHERE
									 Distributor_Buying_Groups.Buying_Group_ID = BSA_FoodService_Customers.Buying_Group_ID
									 AND
									 Distributor_Buying_Groups.Deleted=0
									 AND
									 Distributor_Buying_Groups.Buying_Group_ID = '#Form.Buying_Group#'
							)
							</CFIF>
					)					
				</CFIF>				
				----Check Access Permissions
				AND 
				(
					(
						(Creating_User_Position_ID = '#getUserPosition.User_Positions_ID#')						
					)
					OR
					(
						(
						(1=2)
						<CFIF Len(GP_Position_List_From_My_Position_Down) GT 0>
						OR 
						Creating_User_Position_ID IN(#GP_Position_List_From_My_Position_Down#)
						</CFIF>
						)
						AND
						(Contract_Status_Type_IDX >= 2)						
					)
					OR
					(
						(
						(1=2)
						<cfif isDefined("ProgramsWithDistUnderMe") and trim(ProgramsWithDistUnderMe) neq "">
						OR 
						(Contract_Main.Contract_Main_ID IN
						(#PreserveSingleQuotes(ProgramsWithDistUnderMe)#)
						)
						</CFIF>
						<cfif isDefined("ProgramsWithBrokerUnderMe") and trim(ProgramsWithBrokerUnderMe) neq "">
						OR 
						(Contract_Main.Contract_Main_ID IN
						(#PreserveSingleQuotes(ProgramsWithBrokerUnderMe)#)
						)
						</CFIF>
						)
						AND
						(Contract_Status_Type_IDX >= 4)						
					)
				)
				----Check Access Permissions End
				
				<!---Only get bids--->	
				AND	Program_Control_Panel_Options.Generic_Type = 'Bid Request'
				
		ORDER BY #sql_Sort_By#
	</CFQUERY>
	

		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			
			<cfparam name="FORM.startrow" 	default="1">
			<CFPARAM NAME="FORM.frompage" 		DEFAULT="1">
			<cfparam name="FORM.pageLength" 	default=13>
			<CFSET startrow=FORM.startrow>
			<CFSET frompage=FORM.frompage>
			<cf_Number_of_Rows maxrows="#Records_To_Show#">
				
			<CFINCLUDE TEMPLATE="/search_screens/bid_request/bid_request_display.cfm">
			


			<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0">
			<TR>
			<TD>
			<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<CF_Next_Previous_For_Forms
				formname="MyForm"
				query="TheQuery"
				maxpages="30"
				previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams="">
			</DIV>
			</TD>
			<TD ALIGN="RIGHT">
				<FONT COLOR="Red" SIZE="2"><B>There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>Program<CFELSE>Programs</CFIF> That <CFIF TheQuery.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</B></FONT>
			</TD>
			</TR>
			</TABLE>
			<CFOUTPUT>
			<SCRIPT LANGUAGE="javaScript">
				function getthisPage(thisObj)
				{
					window.parent.showSearchResult(false, thisObj.startrow.value,thisObj.frompage.value);
					return false;
				}
				
				function createReport()
				{
							NewWindow('/reportwriter/bidrequest/index.cfm?ProgramList=#ValueList(TheQuery.Contract_Main_ID)#&SortBy=#sql_Sort_By#','BidReports', '800','600','yes','yes','No')
				}
				
			</SCRIPT>
			
			<FORM ACTION="/search_screens/bid_request/bid_request_search_result.cfm#form.IFRAME_Extra_URL#" METHOD="post" NAME="MyForm" ID="MyForm" onSubmit="javaScript: return getthisPage(this);">
			<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
			<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
			<input type="Hidden" name="ImportAllList" value="#ValueList(TheQuery.Contract_Main_ID)#">
			</FORM>
			</CFOUTPUT>
			
			<SCRIPT>
			function generateSelectedProgramsList() {
				returnList = "";
				
				for(var x=0;x<window.document.all.SelectedPrograms.length; x++) {
					oTempBx = window.document.all.SelectedPrograms[x];
					
					if(oTempBx.checked) {
						returnList = returnList + oTempBx.value + ",";
					}
				}

				returnList = returnList.substring(0, returnList.length-1);

				return returnList
			}
			
			function navigate(frompage, startrow)
			{	
				<cfif URL.ShowCheckBoxes EQ 1><cfoutput>
					window.parent.document.all.chkAll.checked 		= false;
					window.parent.SearchForm.PL_PreSubmit.value 	= "#form.ILPL_PreSubmit#";
					window.parent.SearchForm.PL_PostSubmit.value 	= generateSelectedProgramsList();
					window.parent.SearchForm.PL_Final.value 		= "#Form.PL_Final#";
				</cfoutput></cfif>

				window.parent.showSearchResult(false, startrow,frompage);
			}
			</SCRIPT>
			
			
			<!---Generate report link--->
			<div align="center">
			<table width="120" border="0"><tr><td>
				<cf_smallLink
				url="javascript: createReport();"
				title="generate report"
				enabled = 1
				parameters="title=""Generate a report for all the bids shown here"""
				>
			</td></tr></table>
			</div>
			
		<CFELSE>
			<BR>
			<FONT COLOR="Red" SIZE="2"><B>There are no proposals that match the specified criteria</B></FONT>
		</CFIF>	
		
</CFIF>
</BODY>

