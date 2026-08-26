<!---BidRequestManager.cfc--->
<cfcomponent>

	<!--- CONSTRUCTOR --->
	<cffunction name="init" access="public" returntype="void" output="false">
	</cffunction>

	<cffunction name="getBidRequest" output="true" returntype="components.programs.bid_request.BidRequest">

		<cfargument name="programId" default="0" />

		<!---if the programId is empty then set it to zero--->
		<cfif not Len(trim(arguments.programId))>
			<cfset arguments.programId = 0 />
		</cfif>

		<!---create an instance of BidRequest--->
		<cfset rBidReqObj = CreateObject("component", "components.programs.bid_request.BidRequest") />

		<!---grab bid request data from db for this program id. if there is no record then an empty BidRequest object will get returned--->
		<cfset useLakebaseForqGetBidRequest = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_request")>
<cfif useLakebaseForqGetBidRequest>
	<cftry>
		<cfset qGetBidRequest = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_request", {
				"deleted" = "eq.0",
				"program_id" = "eq.#arguments.programId#",
				"select" = "program_bid_request_id,open_date,open_time,date_needed,expected_reply_date,line_item,bid_request_status_id,status_changed_by,status_changed_date,program_bid_source_id,program_bid_source_type_id"
			}), "program_bid_request_id,open_date,open_time,date_needed,expected_reply_date,line_item,bid_request_status_id,status_changed_by,status_changed_date,program_bid_source_id,program_bid_source_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetBidRequest = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetBidRequest>
<cfquery name="qGetBidRequest" datasource="#application.datasource#">

			SELECT 	Program_Bid_Request_ID,
					Open_Date,
					Open_Time,
					Date_Needed,
					Expected_Reply_Date,
					Line_Item,
					Bid_Request_Status_ID,
					Status_Changed_By,
					Status_Changed_Date,
					Program_Bid_Source_ID,
					Program_Bid_Source_Type_ID
			FROM	Program_Bid_Request
			WHERE	Deleted = 0
			AND		Program_ID = #arguments.programId#

		</cfquery>
</cfif>

		<cfloop query="qGetBidRequest">

			<cfset rBidReqObj.setId(Program_Bid_Request_ID) />
			<cfset rBidReqObj.setOpenDate(Open_Date) />
			<cfset rBidReqObj.setOpenTime(Open_Time) />
			<cfset rBidReqObj.setDateNeeded(Date_Needed) />
			<cfset rBidReqObj.setExpectedReplyDate(Expected_Reply_Date) />
			<cfset rBidReqObj.setLineItem(Line_Item) />
			<cfset rBidReqObj.setStatus(Bid_Request_Status_ID) />
			<cfset rBidReqObj.setSourceID(Program_Bid_Source_ID) />
			<cfset rBidReqObj.setSourceType(Program_Bid_Source_Type_ID) />

		</cfloop>

		<cfreturn rBidReqObj />

	</cffunction>

		<cffunction name="setBidRequest" output="false" returntype="components.programs.bid_request.BidRequest">

		<cfargument name="bidRequestId" required="false" default="0" />
		<cfargument name="programId" required="false" default="" />
		<cfargument name="openDate" required="false" default="" />
		<cfargument name="dateNeeded" required="false" default="" />
		<cfargument name="expectedReplyDate" required="false" default="" />
		<cfargument name="lineItem" required="false" default="0" />
		<cfargument name="bid_request_status" required="false" default="1" />
		<cfargument name="openTime" required="false" default="" />
		<cfargument name="sourceID" required="false" default="" />
		<cfargument name="sourceType" required="false" default="" />

		<!---create an instance of BidRequest--->
		<cfset rBidReqObj = CreateObject("component", "components.programs.bid_request.BidRequest") />

		<cfset rBidReqObj.setId(arguments.bidRequestId) />
		<cfset rBidReqObj.setProgramId(arguments.programId) />
		<cfset rBidReqObj.setOpenDate(arguments.openDate) />
		<cfset rBidReqObj.setOpenTime(arguments.openTime) />
		<cfset rBidReqObj.setDateNeeded(arguments.dateNeeded) />
		<cfset rBidReqObj.setExpectedReplyDate(arguments.expectedReplyDate) />
		<cfset rBidReqObj.setLineItem(arguments.lineItem) />
		<cfif isDefined("arguments.bid_request_status") and arguments.bid_request_status neq "">
			<cfset rBidReqObj.setStatus(arguments.bid_request_status) />
		<cfelse>
			<cfset rBidReqObj.setStatus(1) />
		</cfif>
		<!--- Dev Note: Milan (28153) --->
		<cfif arguments.sourceID neq "">
			<cfset rBidReqObj.setSourceID(arguments.sourceID) />
		</cfif>
		<cfif arguments.sourceType neq "">
			<cfset rBidReqObj.setSourceType(arguments.sourceType) />
		</cfif>
		<cfreturn rBidReqObj />

	</cffunction>

	<cffunction name="saveBidRequest" output="false">
		<cfargument name="bidRequestObj" required="false" default="" type="components.programs.bid_request.BidRequest" />
		<cfargument name="skipStatus" required="false" default="0" type="Boolean" />
		<!---if the BidRequest object has a program id then we want to update, otherwise insert--->
		<cfquery name="qBidRequest" datasource="#application.datasource#">
			select * from Program_Bid_Request where program_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bidRequestObj.getProgramId()#" /> and deleted = 0
		</cfquery>
		<cfif qBidRequest.recordCount gt 0>
			<cfquery name="qUpdateBidRequest" datasource="#application.datasource#">
				UPDATE 	Program_Bid_Request
				SET		Open_Date = <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.bidRequestObj.getOpenDate()#" />,
						Date_Needed = <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.bidRequestObj.getDateNeeded()#" />,
						<cfif not arguments.skipStatus>
						Bid_Request_Status_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bidRequestObj.getStatus()#" />,
						</cfif>
						Expected_Reply_Date = <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.bidRequestObj.getExpectedReplyDate()#" />,
						Line_Item = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.bidRequestObj.getLineItem()#" />,
						Open_Time = <cfqueryparam cfsqltype="CF_SQL_TIME" value="#arguments.bidRequestObj.getOpenTime()#" null="#IIF(len(arguments.bidRequestObj.getOpenTime()), DE("no"), DE("yes"))#" />
						<cfif arguments.bidRequestObj.getSourceID() neq "">
						,Program_Bid_Source_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bidRequestObj.getSourceID()#" />
						</cfif>
						<cfif arguments.bidRequestObj.getSourceType() neq "">
						,Program_Bid_Source_Type_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bidRequestObj.getSourceType()#" />
						</cfif>
				WHERE	Deleted = 0
				AND		Program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bidRequestObj.getProgramId()#" />
			</cfquery>

		<cfelse>

			<cfquery name="qInsertBidRequest" datasource="#application.datasource#">

				INSERT INTO Program_Bid_Request
					(Program_ID, Bid_Request_Status_ID, Open_Date, Date_Needed, Expected_Reply_Date, Line_Item, Open_Time
					<cfif arguments.bidRequestObj.getSourceID() neq "">,Program_Bid_Source_ID</cfif>
					<cfif arguments.bidRequestObj.getSourceType() neq "">,Program_Bid_Source_Type_ID</cfif>
					)
				VALUES
					(
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bidRequestObj.getProgramId()#" />,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bidRequestObj.getStatus()#" />,
						<cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.bidRequestObj.getOpenDate()#" />,
						<cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.bidRequestObj.getDateNeeded()#" />,
						<cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.bidRequestObj.getExpectedReplyDate()#" />,
						<cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.bidRequestObj.getLineItem()#" />,
						<cfqueryparam cfsqltype="CF_SQL_TIME" value="#arguments.bidRequestObj.getOpenTime()#" null="#IIF(len(arguments.bidRequestObj.getOpenTime()), DE("no"), DE("yes"))#" />
						<cfif arguments.bidRequestObj.getSourceID() neq "">
						,<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bidRequestObj.getSourceID()#" />
						</cfif>
						<cfif arguments.bidRequestObj.getSourceType() neq "">
						,<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bidRequestObj.getSourceType()#" />
						</cfif>

					)

			</cfquery>

		</cfif>

	</cffunction>

	<cffunction name="getStatus" output="false">

		<cfargument name="programId" required="true" default="" />

		<cfquery name="qStatus" datasource="#application.datasource#">
			SELECT 	Bid_Request_Status_ID
			FROM	Program_Bid_Request
			WHERE	Deleted = 0
			AND		Program_ID = #arguments.programId#
		</cfquery>

		<cfreturn qStatus />

	</cffunction>

	<cffunction name="applyStatus" output="false">

		<cfargument name="programId" required="true" default="" />
		<cfargument name="statusId" required="true" default="" />

		<cfquery name="qApplyStatus" datasource="#application.datasource#">
			UPDATE	Program_Bid_Request
			SET 	Bid_Request_Status_ID = #arguments.statusId#,
					Status_Changed_Date = #now()#,
					Status_Changed_By = '#request.accessstructure.User_ID#'
			WHERE	Deleted = 0
			AND		Program_ID = #arguments.programId#
		</cfquery>

		<cfquery name="qApplyStatusHistory" datasource="#application.datasource#">
			INSERT INTO	Program_Bid_Request_History
				(
					Program_ID
					,Bid_Request_Status_ID
					,Updated_By
					,Updated_DateTime
					,Deleted
				)
			VALUES
				(
					#arguments.programId#
					,#arguments.statusId#
					,'#request.accessstructure.User_ID#'
					,#now()#
					,0
				)
		</cfquery>

		<cfset CreateObject("component", "components.programs.bid_request.BidRequestProductStatusManager").saveBidRequestProductStatus(arguments.programId, arguments.statusId) />

		<cfset useLakebaseForqCheckProgramApproved = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqCheckProgramApproved>
	<cftry>
		<cfset qCheckProgramApproved = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#arguments.programId#",
				"select" = "approved"
			}), "approved"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckProgramApproved = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckProgramApproved>
<cfquery name="qCheckProgramApproved" datasource="#application.datasource#">
			SELECT	Approved
			FROM	Contract_Main
			WHERE	contract_main_id = #arguments.programId#
		</cfquery>
</cfif>

		<cfset useLakebaseForcheckRevision = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForcheckRevision>
	<cftry>
		<cfset checkRevision = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#arguments.programId#",
				"select" = "revision_of_contract_main_id,contract_status_type_idx"
			}), "revision_of_contract_main_id,contract_status_type_idx"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckRevision = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckRevision>
<CFQUERY NAME="checkRevision" datasource="#application.datasource#">
			SELECT	Revision_Of_Contract_Main_ID,
					Contract_Status_Type_IDX
			FROM	Contract_Main
			WHERE 	Deleted = 0
			AND		Contract_Main_ID = '#arguments.programId#'
		</CFQUERY>
</cfif>

		<cfset revisionId = trim(checkRevision.Revision_Of_Contract_Main_ID) />

		<cfif qCheckProgramApproved.Approved EQ 1><!------ only if current program is approved ----->

			<!--- locking will be done outside the component --->
			<cfif arguments.statusId neq 4 and arguments.statusId neq 1>

				<!---if the Revision_Of_Contract_Main_ID is not null then set the parent to deleted --->
				<cfif (revisionId neq "" or revisionId neq 0) and checkRevision.Contract_Status_Type_IDX eq 5 OR checkRevision.Contract_Status_Type_IDX eq 6>

					<cfset useLakebaseForupdateParentRevision = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForupdateParentRevision>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#revisionId#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateParentRevision = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateParentRevision>
<CFQUERY NAME="updateParentRevision" datasource="#application.datasource#">
						UPDATE 	Contract_Main
						SET 	Deleted = 1
						WHERE 	Deleted = 0
						AND		Contract_Main_ID = '#revisionId#'
					</CFQUERY>
</cfif>

				</cfif>

			</cfif>

		</cfif><!------ only if current program is approved ----->

		<!---set all products to lost--->
		<cfif arguments.statusId eq 4>
			<cfset useLakebaseForsetBidProdsToLost = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_request_product")>
<cfif useLakebaseForsetBidProdsToLost>
	<cftry>
		<cfset application.oLakebase.updateRows("program_bid_request_product",
			{
				"deleted" = "eq.0",
				"program_id" = "eq.#arguments.programId#"
			},
			{
				"won" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForsetBidProdsToLost = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsetBidProdsToLost>
<CFQUERY NAME="setBidProdsToLost" datasource="#application.datasource#">
				UPDATE 	Program_Bid_Request_Product
				SET 	Won = 0
				WHERE 	Deleted = 0
				AND		Program_ID = #arguments.programId#
			</CFQUERY>
</cfif>
		</cfif>

		<!---handle revision--->
		<cfif (revisionId neq "" or revisionId neq 0) and arguments.statusId eq 2>
			<CFQUERY NAME="setBidProdsToLost" datasource="#application.datasource#">
				UPDATE 	Program_Bid_Request_Product
				SET 	Won = 1
				WHERE 	Deleted = 0
				AND		Program_ID = #arguments.programId#
			</CFQUERY>
		</cfif>

		<!--- Dev Note: 12814; - This query fires the trigger on Contract_Main, which sets the status of the contract --->
			<cfset useLakebaseForupdStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForupdStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#arguments.programId#"
			},
			{
				"deleted" = "Deleted"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdStatus>
<CFQUERY NAME="updStatus" datasource="#application.datasource#">
			 UPDATE 	Contract_Main
			 SET 	Deleted = Deleted
			 WHERE 	Contract_Main_ID = #arguments.programId#
			</CFQUERY>
</cfif>

		<!---delete the temp file if it exists--->
		<cfif FileExists("#Application.Doc_Path#\Temp_Files\Program\View_Program_#arguments.programId#.htm")>
			<cffile action = "delete" file = "#Application.Doc_Path#\Temp_Files\Program\View_Program_#arguments.programId#.htm">
		</cfif>

	</cffunction>

	<cffunction name="getBidHistory"
					access="public"
					returntype="query"
					output="false"
					displayname="getBidHistory">

		<cfargument name="programId" required="true" default="" />

		<cfquery name="qGetBidHistory" datasource="#application.datasource#">
			SELECT a.updated_datetime,
					b.Name_First + ' ' + b.Name_Last AS User_Full_Name,
					b.user_email,
					c.Status_Desc
			FROM	Program_Bid_Request_History a
				INNER JOIN _Users b
					ON a.updated_by = b.User_ID
				INNER JOIN Bid_Request_Status c
					ON a.Bid_Request_Status_ID = c.Bid_Request_Status_ID
			WHERE	a.program_id = #arguments.programId#
			ORDER BY a.Updated_DateTime DESC
		</cfquery>

		<cfreturn qGetBidHistory>

	</cffunction>

	<cffunction name="getHistory" output="false">

		<cfargument name="lItemMasterId" required="true" default="" />
		<cfargument name="lOperatorId" required="true" default="" />
		<cfargument name="programId" required="true" default="" />

		<!---only run query if we have the lists--->
		<cfif Len(trim(arguments.lOperatorId)) and Len(trim(arguments.lItemMasterId)) and Len(trim(arguments.programId))>

			<cfquery name="qGetHistory" datasource="#application.datasource#">
				SELECT 	Contract_Main.Contract_Title,
						Contract_Main.Contract_Start_Date,
						Contract_Main.Contract_End_Date,
						Program_Bid_Request_Product.Program_ID,
						Program_Bid_Request_Product.Bid_Request_Spec_ID,
						Program_Bid_Request_Product.Allowance,
						Program_Bid_Request_Product.UOM,
						Program_Bid_Request_Product.Price,
						Program_Bid_Request_Product.Won,
						Program_Bid_Request_Product.Won_By,
						Program_Bid_Request_Product.Won_Price,
						Program_Bid_Request_Product.Won_Uom,
						Program_Bid_Request_Product.Previous_Won_Delivery_Type,
						Contract_Products.Contract_Products_ID,
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
						BSA_Foodservice_Items_Master.Item,
						BSA_Foodservice_Items_Master.UPC,
						BSA_Foodservice_Items_Master.Description,
						BSA_Foodservice_Items_Master.Pack_Size,
						BSA_Foodservice_Items_Master.Pack_Size_UOM,
						BSA_Operator.Operator_Name,
						BSA_Operator.BSA_Operator_ID
				FROM 	Program_Bid_Request_Product
						INNER JOIN Program_Bid_Request
						ON Program_Bid_Request.Program_ID = Program_Bid_Request_Product.Program_ID
						AND Program_Bid_Request.Deleted = 0
						AND Program_Bid_Request.Bid_Request_Status_ID != 1
						INNER JOIN Contract_Products
						ON Contract_Products.Contract_Products_ID = Program_Bid_Request_Product.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						INNER JOIN Contract_Main
						ON Contract_Main.Contract_Main_ID = Program_Bid_Request_Product.Program_ID
						AND Contract_Main.Deleted = 0
						INNER JOIN Contract_Operators
						ON Contract_Operators.Contract_Main_ID = Program_Bid_Request_Product.Program_ID
						AND Contract_Operators.Deleted = 0
						INNER JOIN BSA_Operator
						ON BSA_Operator.BSA_Operator_ID = Contract_Operators.BSA_Operator_ID
						AND BSA_Operator.Deleted = 0
						INNER JOIN BSA_Foodservice_Items_Master
						ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						AND BSA_Foodservice_Items_Master.Deleted = 0
				AND		Program_Bid_Request_Product.Deleted = 0
				AND		Contract_Products.BSA_Foodservice_Items_Master_ID IN (<cfqueryparam value="#arguments.lItemMasterId#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
				AND		BSA_Operator.BSA_Operator_ID IN (<cfqueryparam value="#arguments.lOperatorId#" cfsqltype="CF_SQL_INTEGER" list="yes" />)
				AND		Program_Bid_Request_Product.Program_ID != #arguments.programId#

				ORDER BY BSA_Operator.BSA_Operator_ID
			</cfquery>

		<cfelse>

			<cfset qGetHistory = QueryNew("") />

		</cfif>

		<cfreturn qGetHistory />

	</cffunction>

	<!--- This function handles "Other" Program Bid Sources. These are inserted into the "Program_Bid_Source" table as "Inactive".
	      Program_Bid_Source is a lookup table and this case is one of the exceptions where we are insering a value in this table from
	      the application. Note: These entries are inserted as Inactive (currently) from the program. These entries could be updated
	      too.
	--->
	<cffunction name="updProgramBidSourceOther" output="false" returntype="numeric">
		<cfargument name="ProgramBidSourceID" required="true" default="0" />
		<cfargument name="ProgramBidSourceCode" required="true" default="" />
		<cfargument name="ProgramBidSourceDescription" required="false" default="" />
		<cfargument name="Active" required="false" default="1" />

		<cfset var iProgramBidSourceID = "">

		<cfquery name="getIsProgramBidSourceOtherExist" datasource="#application.datasource#">
			SELECT COUNT(*) As ProgramSourceOtherExist
			FROM	Program_Bid_Source
			WHERE Program_Bid_Source_ID = '#arguments.ProgramBidSourceID#'
		</cfquery>

		<cfif getIsProgramBidSourceOtherExist.ProgramSourceOtherExist eq 0>

			<!--- Insert the record --->
			<cfquery name="InsProgramBidSourceOther" datasource="#application.datasource#">
			INSERT INTO Program_Bid_Source
				(Program_Bid_Source_Code,Program_Bid_Source_Description,Active,Updated_Date,Updated_By)
			VALUES
				(
				<cfqueryparam value="#arguments.ProgramBidSourceCode#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.ProgramBidSourceDescription#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.Active#" cfsqltype="CF_SQL_BIT" />,
				getDate(),
				<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR" />
				)
			SELECT Program_Bid_Source_Code_ID = @@IDENTITY
			</cfquery>

			<cfset iProgramBidSourceID = InsProgramBidSourceOther.Program_Bid_Source_Code_ID>
		<cfelse>

			<!--- Update the record --->
			<cfquery name="UpdProgramBidSourceOther" datasource="#application.datasource#">
			UPDATE	Program_Bid_Source
			SET     Program_Bid_Source_Code = <cfqueryparam value="#arguments.ProgramBidSourceCode#" cfsqltype="CF_SQL_VARCHAR" />,
				Program_Bid_Source_Description = <cfqueryparam value="#arguments.ProgramBidSourceDescription#" cfsqltype="CF_SQL_VARCHAR" />,
				Active = <cfqueryparam value="#arguments.Active#" cfsqltype="CF_SQL_BIT" />,
				Updated_Date	= getDate(),
				Updated_By	= <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR" />
			WHERE	Program_Bid_Source_ID 	= <cfqueryparam value="#arguments.ProgramBidSourceID#" cfsqltype="CF_SQL_INTEGER" />
			</cfquery>

			<cfset iProgramBidSourceID = arguments.ProgramBidSourceID>
		</cfif>

		<cfreturn iProgramBidSourceID>
	</cffunction>

</cfcomponent>