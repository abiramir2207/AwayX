<!---
Name: 			BillbackEditDAO.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:  	05/18/2011
Created By:    	Tim Ford
Description:	I am responsible DB edit access for all billback data.
Parameters:		N/A
Usage:			N/A
--->
<cfcomponent name="BillbackEditDAO" displayname="BillbackEditDAO" extends="mvc.Models.SettingsService">

	<!--- initialize the BillbackDAO to use for all functions in BillbackEditDAO --->
	<cfscript>
		this.objBillbackDAO	= CreateObject("component","mvc.Models.Billback.BillbackDAO");
		this.strBillbackID	= "";
	</cfscript>

	<!---save billback data--->
	<cffunction name="saveBillbackData" output="true" access="public" hint="Function to save billback data to the DB">

		<cfargument name="billbackData" required="true" type="struct">

		<cfscript>
			//set local variables
			var nBillbackIDInt			= "";
			var stBillbackData			= structNew();
			var stBillbackPayee			= structNew();
			var arrProgDistProdRate		= arrayNew(1);
			var bInsertUpdate			= 1; // 1 = Insert, 2 = Update
			var strBBCode				= "";
			var qUpdateBillbackHeader	= "";
			var qInsertBillbackHeader	= "";
			var qGetBillbackIdInt		= "";
			var nRetBillbackIDInt		= "";
			var nVendorId				= "";
			var bReqAppDateNull			= "";
			var bRevcDateNull			= "";
			var bPostDateNull			= "";
			var nClaimedAmount			= "0.00";
			var nClaimedCS				= "0.00";
			var nClaimedLB				= "0.00";
			var strUserId				= "";
			var qGetPositonId			= "";
			var strPositonId			= "";
			var arrComponents			= arrayNew(1);
			var bCopiedBBNull			= "yes";

			//assign local variables
			stBillbackData		= arguments.billbackData;
			stBillbackPayee		= stBillbackData.bbHeader.payee;
			arrProgDistProdRate	= stBillbackData.bbPrgDistItemRate;
			nBillbackIDInt 		= trim(stBillbackData.bbHeader.billbackIDInt);
			nVendorId			= stBillbackData.bbHeader.vendor.payeeId;
			strUserId			= stBillbackData.bbHeader.creator.id;
			arrComponents		= stBillbackData.bbComponent;

			//stuff the vendor id into the payee object
			structInsert(stBillbackPayee, "vendorId", nVendorId);

			//if we have a billback int id and its not 0 then get the UUID and do an update
			if (len(nBillbackIDInt) and nBillbackIDInt)
			{
				this.strBillbackID 	= this.objBillbackDAO.getBillbackUUID(nBillbackIDInt);
				bInsertUpdate		= 2;
			}

		</cfscript>

		<cfparam name="stBillbackData.bbHeader.requestApprovalDate" default="" />
		<cfparam name="stBillbackData.bbHeader.CopiedBB" 			default="" />

		<cfif len(trim(stBillbackData.bbHeader.CopiedBB))>
			<cfset bCopiedBBNull = "no" />
		</cfif>

		<cfif not len(trim(stBillbackData.bbHeader.BBDate)) or not isDate(stBillbackData.bbHeader.BBDate)>
			<cfset stBillbackData.bbHeader.BBDate = "">
		</cfif>

		<cfif not len(trim(stBillbackData.bbHeader.startDate)) or not isDate(stBillbackData.bbHeader.startDate)>
			<cfset stBillbackData.bbHeader.startDate = "">
		</cfif>

		<cfif not len(trim(stBillbackData.bbHeader.endDate)) or not isDate(stBillbackData.bbHeader.endDate)>
			<cfset stBillbackData.bbHeader.endDate = "">
		</cfif>

		<cfif not len(trim(stBillbackData.bbHeader.requestApprovalDate)) or not isDate(stBillbackData.bbHeader.requestApprovalDate)>
			<cfset stBillbackData.bbHeader.requestApprovalDate = "">
		</cfif>

		<cfif not len(trim(stBillbackData.receivedDate)) or not isDate(stBillbackData.receivedDate)>
			<cfset stBillbackData.receivedDate = "" />
		</cfif>

		<cfif not len(trim(stBillbackData.postDate)) or not isDate(stBillbackData.postDate)>
			<cfset stBillbackData.postDate = "" />
		</cfif>

		<cfif len(trim(stBillbackData.claimedAmount)) and trim(stBillbackData.claimedAmount) neq "NaN" and isNumeric(trim(stBillbackData.claimedAmount))>
			<cfset nClaimedAmount = stBillbackData.claimedAmount />
		</cfif>

		<cfif len(trim(stBillbackData.claimedCS)) and trim(stBillbackData.claimedCS) neq "NaN" and isNumeric(trim(stBillbackData.claimedCS))>
			<cfset nClaimedCS = stBillbackData.claimedCS />
		</cfif>

		<cfif len(trim(stBillbackData.claimedLB)) and trim(stBillbackData.claimedLB) neq "NaN" and isNumeric(trim(stBillbackData.claimedLB))>
			<cfset nClaimedLB = stBillbackData.claimedLB />
		</cfif>


		<!--- Deduct time difference between UTC and EST from the localtimezone passed to flex. This will give us the difference between localtimezone and EST (in minutes) --->
		<cfset DiffLocalTimeZoneAndEST = this.DiffLocalTimeZoneAndEST()>

		<!--- save billback data --->
		<!--- if bInsertUpdate = 1 then its a new billback that doesn't exist in the DB --->
		<cfif bInsertUpdate eq 1>

			<cfinclude template="../../../billbacks/capture/billback_number_generator.cfm">
			<cfset strBBCode = generator_billback_number>

			<cfquery name="qGetPositonId" datasource="#Application.Datasource#">
				SELECT	DISTINCT User_Positions_ID
				FROM	User_Position_Holders
				WHERE	User_ID = <cfqueryparam value="#strUserId#" cfsqltype="CF_SQL_VARCHAR">
				AND 	Deleted = 0
				AND 	User_Position_Type = 'P'
			</cfquery>

			<cfset strPositonId = qGetPositonId.User_Positions_ID />

			<cfquery name="qInsertBillbackHeader" datasource="#Application.Datasource#">
				DECLARE @DateWithTimeZoneDiff int,
				@useDayLightSavingsTime bit

				<!--- When we use "dbo.get_TimeZoneOffset_Date" sql function for a SELECT statement, then we need to modify the date before we send it back to flex.
				For eg:If a user logs for India (which is 9.5 hours ahead of EST based of time of the year), and the date in the db is 12/12/2012 00:00:00,
				the query would return 12/11/2012 14:30:00, so that when flex adds 09:30 for the local time zone, the date goes back to is 12/12/2012 00:00:00.
				In the case below, i.e. insert - when a user creates a new billback and the date in India is 12/12/2012, the date of 12/11/2012 14:30:00 will be
				passed by flex to CF, as that is the local time in EST and so we need to add 09:30 to 12/11/2012 14:30:00 which makes the date 12/12/2012 00:00:00.
				Since we need to add add 09:30, I have reversed the logic below -  Added a minus sign before DiffLocalTimeZoneAndEST.
				One more thing to keep in mind here is that "dbo.get_TimeZoneOffset_Date" sql function is passing "1" as the argument for "timeFormat". This preserves
				the time part of the date, i.e. in our example 12/11/2012 14;30 would be preserved, instead of 12/11/2012 00:00:00. --->

				SET @DateWithTimeZoneDiff = -(#DiffLocalTimeZoneAndEST#) <!--- Minus sign has been added here --->
				<!--- Without using "INT", the value is 'YES' without single quotes, causing issues in the "SET" Statement. --->
				SET @useDayLightSavingsTime = #int(request.AccessStructure.useDayLightSavingsTime)#

				INSERT INTO Billback
					(
						BB_Code, BB_Reference, referenceNum, BB_Title, BB_Request_Approval_Date, BB_Date, BB_Start_Date,
						BB_End_Date, BB_Closing_Method, BB_Received_Date, Postmark_Date, BB_Amount, Claim_Cases, Claim_Pounds, BB_Creator_Notes, Billback_Payee_Type_ID,
						BB_Creator_ID, BB_Creator_User_Position_ID, Analyst_User_ID	, BB_UP, CopiedBB
					)
				VALUES
					(
						<cfqueryparam value="#strBBCode#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#stBillbackData.bbHeader.BBNumber#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#stBillbackData.bbHeader.referenceNumber#" cfsqltype="CF_SQL_VARCHAR">,
						<!---
						Remove the whacky dash - CHAR(150). (It is longer than dash). I can generate it from MS-Outlook. Type in 1-1 and then enter the space key.
						Remove the whacky double quotes - CHAR(148).
						Remove the double quotes ("). chr(34) is double quotes. It creates an issue in the Excel report in Flex.
						--->
						Replace(Replace(Replace('#stBillbackData.bbHeader.title#',CHAR(150),'-'),CHAR(148),''),CHAR(34),''),
						'#stBillbackData.bbHeader.requestApprovalDate#',
						'#stBillbackData.bbHeader.BBDate#',
						'#stBillbackData.bbHeader.startDate#',
						'#stBillbackData.bbHeader.endDate#',
						<cfqueryparam value="#stBillbackData.bbHeader.closingMethod.id#" cfsqltype="CF_SQL_INTEGER">,
						'#stBillbackData.receivedDate#',
						'#stBillbackData.postDate#',
						<cfqueryparam value="#nClaimedAmount#" cfsqltype="CF_SQL_FLOAT">,
						<cfqueryparam value="#nClaimedCS#" cfsqltype="CF_SQL_FLOAT">,
						<cfqueryparam value="#nClaimedLB#" cfsqltype="CF_SQL_FLOAT">,
						<cfqueryparam value="#stBillbackData.bbNotes#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#stBillbackPayee.payeeTypeId#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#strUserId#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#strPositonId#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#stBillbackData.bbHeader.analyst.id#" cfsqltype="CF_SQL_VARCHAR">,
						0,
						<cfqueryparam value="#stBillbackData.bbHeader.CopiedBB#" cfsqltype="CF_SQL_VARCHAR" null="#bCopiedBBNull#">
					)
			</cfquery>

			<cfscript>
				//set Billback UUID
				this.strBillbackID 	= qInsertBillbackHeader.Billback_ID;
			</cfscript>

			<cfquery name="qGetBillbackIdInt" datasource="#Application.Datasource#">
				SELECT	Billback_ID_Int FROM Billback WHERE Billback_ID = <cfqueryparam value="#this.strBillbackID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

			<cfscript>
				//set Billback_ID_Int and Billback UUID
				nBillbackIDInt = qGetBillbackIdInt.Billback_ID_Int;
			</cfscript>

			<!--- otherwise we do an update --->
		<cfelse>

			<cfquery name="qUpdateBillbackHeader" datasource="#Application.Datasource#">
				DECLARE @DateWithTimeZoneDiff int,
				@useDayLightSavingsTime bit

				<!--- When we use "dbo.get_TimeZoneOffset_Date"' sql function for a SELECT statement, then we need to modify the date before we send it back to flex.
				For eg:If a user logs for India (which is 9.5 hours ahead of EST based of time of the year), and the date in the db is 12/12/2012 00:00:00,
				the query would return 12/11/2012 14:30:00, so that when flex adds 09:30 for the local time zone, the date goes back to is 12/12/2012 00:00:00.
				In the case below, i.e. update - when a user creates a new billback and the date in India is 12/12/2012, the date of 12/11/2012 14:30:00 will be
				passed by flex to CF, as that is the local time in EST and so we need to add 09:30 to 12/11/2012 14:30:00 which makes the date 12/12/2012 00:00:00.
				Since we need to add add 09:30, I have reversed the logic below -  Added a minus sign before DiffLocalTimeZoneAndEST. So, now @DateWithTimeZoneDiff will
				be a positive number.
				One more thing to keep in mind here is that "dbo.get_TimeZoneOffset_Date"' sql function is passing "1" as the argument for "timeFormat". This preserves
				the time part of the date, i.e. in our example 12/11/2012 14;30 would be preserved, instead of 12/11/2012 00:00:00. --->

				SET @DateWithTimeZoneDiff = -(#DiffLocalTimeZoneAndEST#)
				<!--- Without using "INT", the value is 'YES' without single quotes, causing issues in the "SET" Statement. --->
				SET @useDayLightSavingsTime = #int(request.AccessStructure.useDayLightSavingsTime)#

				UPDATE	Billback
				SET		BB_Reference 				=  	<cfqueryparam value="#stBillbackData.bbHeader.BBNumber#" cfsqltype="CF_SQL_VARCHAR">,
						referenceNum 				= 	<cfqueryparam value="#stBillbackData.bbHeader.referenceNumber#" cfsqltype="CF_SQL_VARCHAR">,
						<!---
						Remove the whacky dash - CHAR(150). (It is longer than dash). I can generate it from MS-Outlook. Type in 1-1 and then enter the space key.
						Remove the whacky double quotes - CHAR(148).
						Remove the double quotes ("). chr(34) is double quotes. It creates an issue in the Excel report in Flex.
						--->
						BB_Title				= 	Replace(Replace(Replace('#stBillbackData.bbHeader.title#',CHAR(150),'-'),CHAR(148),''),CHAR(34),''),
						<!--- BB_Request_Approval_Date 	= 	<cfqueryparam value="#stBillbackData.bbHeader.requestApprovalDate#" cfsqltype="CF_SQL_DATE" null="#bReqAppDateNull#">, --->
						BB_Date					= 	'#stBillbackData.bbHeader.BBDate#',
						BB_Start_Date				= 	'#stBillbackData.bbHeader.startDate#',
						BB_End_Date				= 	'#stBillbackData.bbHeader.endDate#',
						BB_Closing_Method			= 	<cfqueryparam value="#stBillbackData.bbHeader.closingMethod.id#" cfsqltype="CF_SQL_INTEGER">,
						BB_Received_Date			= 	'#stBillbackData.receivedDate#',
						Postmark_Date				= 	'#stBillbackData.postDate#',
						BB_Amount				=	<cfqueryparam value="#nClaimedAmount#" cfsqltype="CF_SQL_FLOAT">,
						Claim_Cases				= 	<cfqueryparam value="#nClaimedCS#" cfsqltype="CF_SQL_FLOAT">,
						Claim_Pounds				= 	<cfqueryparam value="#nClaimedLB#" cfsqltype="CF_SQL_FLOAT">,
						BB_Creator_Notes			= 	<cfqueryparam value="#stBillbackData.bbNotes#" cfsqltype="CF_SQL_VARCHAR">,
						Billback_Payee_Type_ID		= 	<cfqueryparam value="#stBillbackPayee.payeeTypeId#" cfsqltype="CF_SQL_INTEGER">,
						Analyst_User_ID				= 	<cfqueryparam value="#stBillbackData.bbHeader.analyst.id#" cfsqltype="CF_SQL_VARCHAR">,
						BB_UP						=	0
				WHERE 	Billback_ID_Int  			= 	<cfqueryparam value="#nBillbackIDInt#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>

		</cfif>

		<!--- HACK :) --->
		<cfquery name="qGetUploadType" datasource="#Application.Datasource#">
				SELECT 	Uploaded_Billback, Billback_Status_ID, Billback_ID
				FROM 	Billback
				WHERE 	Billback_ID_Int  = 	<cfqueryparam value="#nBillbackIDInt#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<!--- Even when a billback is paid, the user can edit the bb to change the "start date" and "end date". Update this info below.
		Note: The paid billbacks are stored in the "billback_search" table for search purpose to make the search faster. This is
		important as we have deal with an increased number of paid billbacks over time.
		--->
		<cfif qGetUploadType.Billback_Status_ID eq 5>
			<cfquery name="qUpdatePaidBillbackHeader" datasource="#Application.Datasource#">

				DECLARE @DateWithTimeZoneDiff int,
				@useDayLightSavingsTime bit

				SET @DateWithTimeZoneDiff = -(#DiffLocalTimeZoneAndEST#)
				<!--- Without using "INT", the value is 'YES' without single quotes, causing issues in the "SET" Statement. --->
				SET @useDayLightSavingsTime = #int(request.AccessStructure.useDayLightSavingsTime)#

				UPDATE Billback_Search
				SET	BB_Start_Date		= '#stBillbackData.bbHeader.startDate#',
					BB_End_Date 		= '#stBillbackData.bbHeader.endDate#'
				WHERE Billback_ID_Int  	= <cfqueryparam value="#nBillbackIDInt#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>

			<!--- D34062 / Anand Rao / 14-Sep-2012; Payment Request and Approved: Do not call budget function; Paid: Call budget function --->
			<cfset CreateObject("component", "mvc.Models.AdvancedBudget.BudgetManager").addBillbackToBudget(billbackId=qGetUploadType.Billback_ID) />
		</cfif>

		<!---
			We do not want to delete the details in the BB_Item_Invoice_Level incase the user is just changing the dates in the BB
			So adding the condition qGetUploadType.Billback_Status_ID GTE 3 in the below.
		--->
		<cfif NOT(
					(qGetUploadType.Uploaded_Billback EQ 3 AND qGetUploadType.Billback_Status_ID GTE 3
					AND application.oApplicationAppSettingsManager.getApplicationAppSettings().getBB_Upload_III_P_Qty_Amt_Editable() EQ 0)
					OR
					(qGetUploadType.Uploaded_Billback EQ 2 AND qGetUploadType.Billback_Status_ID GTE 3
					AND application.oApplicationAppSettingsManager.getApplicationAppSettings().getEditableClaimedDollarsQuantity() EQ 0)
				)>
				<cfquery name="qDeleteGridTableEntries" datasource="#application.datasource#">
					DELETE FROM BB_Item_Invoice_Level
					WHERE Billback_ID = '#this.strBillbackID#'
				</cfquery>
		</cfif>

		<!--- D34062 / Anand Rao / 14-Sep-2012; Do not Reset the Deviation_Ran_Date and Deviation_Ran_By, if it already Approved BB. --->
		<cfif qGetUploadType.Billback_Status_ID LTE 2>
			<cfquery name="qResetToRunDeviations" datasource="#Application.Datasource#">
				UPDATE 	Billback
				SET 	Deviation_Ran_Date = NULL,
						Auto_Deviation_On = NULL,
						Deviation_Ran_By = NULL
				WHERE 	Billback_ID_Int	= 	<cfqueryparam value="#nBillbackIDInt#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>


			<cfscript>

				//save billback payee data.
				saveBillbackPayee(stBillbackPayee);
				//save billback product data. Also saves billback_program data
				saveBillbackProgDistProdRate(arrProgDistProdRate);
				//save billback components
				saveBillbackComponents(arrComponents, stBillbackPayee.payeeTypeId);
			</cfscript>
		</cfif>

		<cfscript>
			nRetBillbackIDInt = nBillbackIDInt;

			return nRetBillbackIDInt;
		</cfscript>

	</cffunction>

	<!---save billback payee--->
	<cffunction name="saveBillbackPayee" output="false" access="public" hint="Function to save billback payee data to the DB">

		<cfargument name="billbackPayee" required="true" type="struct">

		<cfscript>
			//set local variables
			var stBillbackPayee	= structNew();
			var nPayeeType		= ""; // 1=Distributor, 2=Operator, 3=Broker
			var strPayeeID		= "";
			var strVendorID		= "";
			var qDeletePayee	= "";
			var qAddPayee		= "";

			//assign local variables
			stBillbackPayee = arguments.billbackPayee;
			nPayeeType		= stBillbackPayee.payeeTypeId;
			strPayeeID		= stBillbackPayee.payeeId;
			strVendorID		= stBillbackPayee.vendorId;

		</cfscript>

		<cftransaction>

			<!--- blow away all payee entries --->
			<cfquery name="qDeletePayee" datasource="#Application.Datasource#">
				UPDATE 	Billback_Distributor
				SET 	Deleted = <cfqueryparam value="1" cfsqltype="CF_SQL_BIT" />
				WHERE 	Billback_ID = <cfqueryparam value="#this.strBillbackID#" cfsqltype="CF_SQL_VARCHAR" />
				AND 	Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />

				UPDATE 	Billback_Operator
				SET 	Deleted = <cfqueryparam value="1" cfsqltype="CF_SQL_BIT" />
				WHERE 	Billback_ID = <cfqueryparam value="#this.strBillbackID#" cfsqltype="CF_SQL_VARCHAR" />
				AND 	Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />

				UPDATE 	Billback_Broker
				SET 	Deleted = <cfqueryparam value="1" cfsqltype="CF_SQL_BIT" />
				WHERE 	Billback_ID = <cfqueryparam value="#this.strBillbackID#" cfsqltype="CF_SQL_VARCHAR" />
				AND 	Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />

				UPDATE 	Billback_Unidentified_Payee
				SET 	Deleted = <cfqueryparam value="1" cfsqltype="CF_SQL_BIT" />
				WHERE 	Billback_ID = <cfqueryparam value="#this.strBillbackID#" cfsqltype="CF_SQL_VARCHAR" />
				AND 	Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />
			</cfquery>

			<!--- insert payee based on payee type --->
			<cfscript>

				switch(nPayeeType)
				{
					//Distributor
					case 1:
						saveBillbackDistributor(strPayeeID, strVendorID);
						break;
					//Operator
					case 2:
						saveBillbackOperator(strPayeeID, strVendorID);
						break;
					//Broker
					case 3:
						saveBillbackBroker(strPayeeID);
						break;
				}

			</cfscript>

		</cftransaction>

	</cffunction>

	<!---save billback BillbackProgDistProdRate--->
	<cffunction name="saveBillbackProgDistProdRate" output="false" access="public" hint="Function to save billback ProgDistProdRate data to the DB">

		<cfargument name="billbackProgDistProdRate" type="array" required="true">

		<cfscript>
			//set local variables
			var arrData 						= arrayNew(1);
			var arrBillbackProgDistProdRate 	= arrayNew(1);
			var idxRow							= "";
			var inx								= "";
			var qAddBillbackDisProgProdRateData	= "";

			//assign local variables
			arrBillbackProgDistProdRate = arguments.billbackProgDistProdRate;

			//loop over the array of Billback/Program/Distributor/Product/Rate data and build a struct
			//for each combination holding the data that has to be inserted into the billback program product tables
			for (idxRow = 1; idxRow LTE arrayLen(arrBillbackProgDistProdRate); idxRow = (idxRow + 1))
			{


				stData = structNew();
				stData["Billback_ID"]									= this.strBillbackID;

				/* Dev Note: Milan (30793) When the payee is an operator on a billback and Ship To is required for billback with operator as payee"
					app setting is OFF, the user does not have to select a distributor from the BB Edit page. In this case, "bbDistributor" is empty.
				*/
				if(IsStruct("#arrBillbackProgDistProdRate[idxRow]['bbDistributor']#")){
					/*if(IsDefined("#Replace(arrBillbackProgDistProdRate[idxRow]['bbDistributor'].customerId,'-','','ALL')#")){*/
					stData["Billback_Distributor_List.Distributor_ID"] 	= arrBillbackProgDistProdRate[idxRow]["bbDistributor"].customerId;
					stData["Billback_Product.Distributor_ID"]			= arrBillbackProgDistProdRate[idxRow]["bbDistributor"].customerId;
				}

				else{
					stData["Billback_Distributor_List.Distributor_ID"] 	= '';
					stData["Billback_Product.Distributor_ID"]			= '';
				}

				stData["Billback_Program.Program_ID"] 					= arrBillbackProgDistProdRate[idxRow]["bbProgram"].programID;

				stData["Billback_Product.BB_Product_Quantity"] 			= arrBillbackProgDistProdRate[idxRow]["bbProdRate"].volume;
				stData["Billback_Product.BB_Product_UOM"] 				= arrBillbackProgDistProdRate[idxRow]["bbProdRate"].uom.uomId;
				stData["Billback_Product.Product_ID"]					= arrBillbackProgDistProdRate[idxRow]["bbProdRate"].itemGuid;

				stData["Billback_Product_Detail.BB_Product_Type_ID"]	= arrBillbackProgDistProdRate[idxRow]["bbProdRate"].discountType;
				stData["Billback_Product_Detail.BB_Rate"]				= arrBillbackProgDistProdRate[idxRow]["bbProdRate"].amount;

				ArrayAppend(arrData, duplicate(stData));

			}
		</cfscript>

		<cftransaction>

			<!--- Create a temp table and populate it with the data from the array of structs built above --->
			<cfquery datasource="#application.datasource#" name="qAddBillbackDisProgProdRateData">

				DECLARE
				@Billback_Payee_Type_ID INT,
				@Billback_ID UNIQUEIDENTIFIER,
				@Default_Assoc_Distributor UNIQUEIDENTIFIER

				SET	@Billback_ID = '#this.strBillbackID#'

				SELECT @Billback_Payee_Type_ID = Billback_Payee_Type_ID FROM Billback WHERE Billback_ID = @Billback_ID

				<!--- Set default distributor. If payee is distributor, use payee id --->
				SET @Default_Assoc_Distributor = '00000000-0000-0000-0000-000000000000'
				IF @Billback_Payee_Type_ID = 1
				BEGIN
					SELECT 	@Default_Assoc_Distributor = Distributor_ID
					FROM 	Billback_Distributor
					WHERE 	Billback_Distributor.Billback_ID = @Billback_ID
					AND 	Billback_Distributor.Deleted = 0
				END

				IF OBJECT_ID('tempdb..##TMP_BB_Dist_Prog_Prod_Rate') IS NOT NULL
				DROP TABLE ##TMP_BB_Dist_Prog_Prod_Rate

				CREATE  TABLE ##TMP_BB_Dist_Prog_Prod_Rate
				(
					Billback_ID									UNIQUEIDENTIFIER,
					Billback_Distributor_List_Distributor_ID	UNIQUEIDENTIFIER NULL,
					Billback_Program_Program_ID					INT,
					Billback_Product_BB_Product_Quantity		NVARCHAR(50),
					Billback_Product_BB_Product_UOM				INT,
					Billback_Product_Product_ID					UNIQUEIDENTIFIER,
					Billback_Product_Distributor_ID				UNIQUEIDENTIFIER,
					Billback_Product_Detail_BB_Product_Type_ID	INT,
					Billback_Product_Detail_BB_Rate				DECIMAL(24,9),
					Billback_Product_Sort_Order					INT
				)
				<cfloop index="inx" from="1" to="#arrayLen(arrData)#">

					INSERT INTO ##TMP_BB_Dist_Prog_Prod_Rate
					(
						Billback_ID,
						Billback_Distributor_List_Distributor_ID,
						Billback_Program_Program_ID,
						Billback_Product_BB_Product_Quantity,
						Billback_Product_BB_Product_UOM,
						Billback_Product_Product_ID,
						Billback_Product_Distributor_ID,
						Billback_Product_Detail_BB_Product_Type_ID,
						Billback_Product_Detail_BB_Rate,
						Billback_Product_Sort_Order
					)
					VALUES
					(
						'#arrData[inx]["Billback_ID"]#',
						<cfif len(trim(arrData[inx]["Billback_Distributor_List.Distributor_ID"]))>
							'#arrData[inx]["Billback_Distributor_List.Distributor_ID"]#',
						<cfelse>
							NULL,
						</cfif>
						'#arrData[inx]["Billback_Program.Program_ID"]#',
						'#arrData[inx]["Billback_Product.BB_Product_Quantity"]#',
						'#arrData[inx]["Billback_Product.BB_Product_UOM"]#',
						<cfif len(trim(arrData[inx]["Billback_Product.Product_ID"]))>
							'#arrData[inx]["Billback_Product.Product_ID"]#',
						<cfelse>
							NULL,
						</cfif>
						<cfif len(trim(arrData[inx]["Billback_Product.Distributor_ID"]))>
							'#arrData[inx]["Billback_Product.Distributor_ID"]#',
						<cfelse>
							@Default_Assoc_Distributor,
						</cfif>
						<cfif len(trim(arrData[inx]["Billback_Product_Detail.BB_Product_Type_ID"])) and (val(arrData[inx]["Billback_Product_Detail.BB_Product_Type_ID"]) eq arrData[inx]["Billback_Product_Detail.BB_Product_Type_ID"])>
							'#arrData[inx]["Billback_Product_Detail.BB_Product_Type_ID"]#',
						<cfelse>
							'2',
						</cfif>
						<!---<cfif len(trim(arrData[inx]["Billback_Product_Detail.BB_Rate"])) and (val(arrData[inx]["Billback_Product_Detail.BB_Rate"]) eq arrData[inx]["Billback_Product_Detail.BB_Rate"])>--->
						<cfif len(trim(arrData[inx]["Billback_Product_Detail.BB_Rate"]))>
							CAST(#arrData[inx]["Billback_Product_Detail.BB_Rate"]# AS FLOAT)
						<cfelse>
							NULL
						</cfif>
						,#inx#
					)

				</cfloop>

				IF OBJECT_ID('tempdb..##tmp_max_version') IS NOT NULL
				DROP TABLE ##tmp_max_version

				SELECT	cm.Contract_Number, MAX(cm.revision_version) as Max_revision_version
				INTO	##tmp_max_version
				FROM	##TMP_BB_Dist_Prog_Prod_Rate
						INNER JOIN Contract_Main cm ON cm.Contract_Main_ID = ##TMP_BB_Dist_Prog_Prod_Rate.Billback_Program_Program_ID
				GROUP BY cm.Contract_Number
				HAVING COUNT(DISTINCT cm.Contract_Main_ID) > 1

				UPDATE	##TMP_BB_Dist_Prog_Prod_Rate
				SET		Billback_Program_Program_ID = cm2.Contract_Main_ID
				FROM	##TMP_BB_Dist_Prog_Prod_Rate
						INNER JOIN Contract_Main cm ON cm.Contract_Main_ID = ##TMP_BB_Dist_Prog_Prod_Rate.Billback_Program_Program_ID
						INNER JOIN ##tmp_max_version tmp ON tmp.Contract_Number = cm.Contract_Number
						INNER JOIN Contract_Main cm2 ON cm2.Contract_Number = tmp.Contract_Number and cm2.revision_version = tmp.Max_revision_version and cm2.Approved = 1
				WHERE	##TMP_BB_Dist_Prog_Prod_Rate.Billback_Program_Program_ID != cm2.Contract_Main_ID

				-- adjust Contract_Main_ID to latest version if applicable
				UPDATE	##TMP_BB_Dist_Prog_Prod_Rate
				SET		Billback_Program_Program_ID = cm2.Contract_Main_ID
				FROM	##TMP_BB_Dist_Prog_Prod_Rate
						INNER JOIN Contract_Main cm ON cm.Contract_Main_ID = ##TMP_BB_Dist_Prog_Prod_Rate.Billback_Program_Program_ID
						INNER JOIN Contract_Main cm2 ON cm2.Contract_Number = cm.Contract_Number and cm2.Deleted = 0 and cm2.Approved = 1
						and cm2.Contract_Main_ID != cm.Contract_Main_ID
						and cm2.revision_version > cm.revision_version

				DELETE FROM ##TMP_BB_Dist_Prog_Prod_Rate WHERE Billback_Product_Product_ID IS NULL

				/* Delete from Billback_Distributor_List then insert if the payee type is not broker */
				IF @Billback_Payee_Type_ID != 3
				BEGIN

					<!--- Dev Note: KAL; 12/1/12; D35307: BB Performance tuning; Add/Delete only new/deleted records --->
					UPDATE 	Billback_Distributor_List
					SET		Deleted = 1
					WHERE 	Billback_ID = @Billback_ID
					AND 	Distributor_ID NOT IN
							(
								SELECT 	DISTINCT Billback_Distributor_List_Distributor_ID
								FROM 	##TMP_BB_Dist_Prog_Prod_Rate
								WHERE	Billback_Distributor_List_Distributor_ID IS NOT NULL
								AND 	Billback_ID = @Billback_ID
							)

					<!--- Dev Note: KAL; 12/1/12; D35307: BB Performance tuning; Add/Delete only new/deleted records --->
					INSERT INTO Billback_Distributor_List(Billback_ID, Distributor_ID)
					SELECT	DISTINCT TMP.Billback_ID, TMP.Billback_Distributor_List_Distributor_ID
					FROM	##TMP_BB_Dist_Prog_Prod_Rate TMP
					LEFT JOIN Billback_Distributor_List BDL
					ON 		TMP.Billback_ID = BDL.Billback_ID
					AND 	TMP.Billback_Distributor_List_Distributor_ID = BDL.Distributor_ID
					AND 	BDL.Deleted = 0
					WHERE	TMP.Billback_Distributor_List_Distributor_ID IS NOT NULL
					AND 	BDL.Distributor_ID IS NULL

				END

				/*** Billback_Program ***/
				<!--- Dev Note: KAL; 12/1/12; D35307: BB Performance tuning; Add/Delete only new/deleted records --->
				/* Set Deleted = 1 in Billback_Program for deleted programs */
				UPDATE 	Billback_Program
				SET		Deleted = 1,
						Deleted_By = '#request.AccessStructure.User_ID#',
						Deleted_Date = getDate()
				WHERE 	Billback_ID = @Billback_ID
				AND 	Deleted = 0
				AND 	Program_ID NOT IN
						(
							SELECT 	DISTINCT Billback_Program_Program_ID
							FROM 	##TMP_BB_Dist_Prog_Prod_Rate
							WHERE	Billback_Program_Program_ID IS NOT NULL
							AND 	Billback_ID = @Billback_ID
						)

				<!--- Dev Note: KAL; 12/1/12; D35307: BB Performance tuning; Add/Delete only new/deleted records --->
				INSERT INTO Billback_Program
					(Billback_ID, Program_ID)
				SELECT	DISTINCT TMP.Billback_ID, TMP.Billback_Program_Program_ID
				FROM	##TMP_BB_Dist_Prog_Prod_Rate TMP
				LEFT JOIN Billback_Program BP
				ON 		TMP.Billback_ID = BP.Billback_ID
				AND 	TMP.Billback_Program_Program_ID = BP.Program_ID
				AND 	BP.Deleted = 0
				WHERE	TMP.Billback_Program_Program_ID IS NOT NULL
				AND 	BP.Program_ID IS NULL



				/* UOM & PRODUCT QUANTITY */
				/* Find the UOM to use and sum the PRODUCT QUANTITY. If there are multiple rows for same product, we will sum up the values and might need to convert to a common UOM */
				IF Object_id('tempdb..##TMP_BB_Dist_Prog_Prod_Rate_Final') IS NOT NULL
				DROP TABLE ##TMP_BB_Dist_Prog_Prod_Rate_Final

				SELECT	R.Billback_ID, R.Billback_Product_Product_ID,
						R.Billback_Program_Program_ID,
						UOM.UOM_To_Use, R.Billback_Product_Distributor_ID,
						UOM.Billback_Product_Sort_Order,
						SUM(CASE
							WHEN UOM.UOM_To_Use = 1 AND R.Billback_Product_BB_Product_UOM = 2 THEN
								R.Billback_Product_BB_Product_Quantity / CAST(BSA_Foodservice_Items_Master.Net_Weight as float)
							WHEN UOM.UOM_To_Use = 2 AND R.Billback_Product_BB_Product_UOM = 1 THEN
								R.Billback_Product_BB_Product_Quantity * CAST(BSA_Foodservice_Items_Master.Net_Weight as float)
							ELSE
								R.Billback_Product_BB_Product_Quantity
							END) as BB_Product_Quantity
				INTO	##TMP_BB_Dist_Prog_Prod_Rate_Final
				FROM	##TMP_BB_Dist_Prog_Prod_Rate R
						INNER JOIN (
							SELECT ##TMP_BB_Dist_Prog_Prod_Rate.Billback_ID,
									##TMP_BB_Dist_Prog_Prod_Rate.Billback_Product_Product_ID,
									##TMP_BB_Dist_Prog_Prod_Rate.Billback_Product_Distributor_ID,
									##TMP_BB_Dist_Prog_Prod_Rate.Billback_Program_Program_ID,
									Min(##TMP_BB_Dist_Prog_Prod_Rate.Billback_Product_BB_Product_UOM) AS UOM_To_Use,
									Min(##TMP_BB_Dist_Prog_Prod_Rate.Billback_Product_Sort_Order) AS Billback_Product_Sort_Order
							FROM   ##TMP_BB_Dist_Prog_Prod_Rate
							GROUP  BY ##TMP_BB_Dist_Prog_Prod_Rate.Billback_ID,
										##TMP_BB_Dist_Prog_Prod_Rate.Billback_Product_Product_ID,
										##TMP_BB_Dist_Prog_Prod_Rate.Billback_Program_Program_ID,
										##TMP_BB_Dist_Prog_Prod_Rate.Billback_Product_Distributor_ID
						) as UOM
						ON R.Billback_ID = UOM.Billback_ID AND
						R.Billback_Product_Product_ID = UOM.Billback_Product_Product_ID AND
						R.Billback_Product_Distributor_ID = UOM.Billback_Product_Distributor_ID AND
						R.Billback_Program_Program_ID = UOM.Billback_Program_Program_ID
						INNER JOIN BSA_Foodservice_Items_Master ON
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = R.Billback_Product_Product_ID
				GROUP BY 	R.Billback_ID, R.Billback_Product_Product_ID,
							R.Billback_Program_Program_ID,
							UOM.UOM_To_Use, R.Billback_Product_Distributor_ID,
							UOM.Billback_Product_Sort_Order

				/*** Billback_Product ***/
				/* DELETE: Delete records from Billback_Product which are not in the temp table*/
				UPDATE 	Billback_Product
				SET 	Billback_Product.Deleted = 1,
						Billback_Product.Deleted_By = '#request.AccessStructure.User_ID#',
						Billback_Product.Deleted_Date = getDate()
				FROM	Billback_Product
						INNER JOIN Billback_Program ON
						Billback_Program.Billback_ID = Billback_Product.Billback_ID AND
						Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID
						LEFT JOIN  ##TMP_BB_Dist_Prog_Prod_Rate_Final ON
						Billback_Product.Billback_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_ID AND
						Billback_Product.Product_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Product_Product_ID AND
						Billback_Product.Distributor_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Product_Distributor_ID AND
						Billback_Product.BB_Product_UOM = ##TMP_BB_Dist_Prog_Prod_Rate_Final.UOM_To_Use AND
						Billback_Program.Program_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Program_Program_ID AND
						Billback_Product.Deleted = 0 AND
						Billback_Program.Deleted = 0
				WHERE   Billback_Product.Billback_ID = @Billback_ID
					AND	Billback_Product_Product_ID IS NULL
					AND	Billback_Product.Product_ID IS NOT NULL


				/* UPDATE: Update mactching records in Billback_Product when QTY is not same with that in the temp table*/
				UPDATE 	Billback_Product
				SET 	BB_Product_Quantity = CAST(CAST(##TMP_BB_Dist_Prog_Prod_Rate_Final.BB_Product_Quantity AS DECIMAL(18,2)) AS VARCHAR(50)),
						BB_Product_UOM = ##TMP_BB_Dist_Prog_Prod_Rate_Final.UOM_To_Use,
						Created_Sort_Order = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Product_Sort_Order
				FROM 	Billback_Product
						INNER JOIN Billback_Program ON
						Billback_Program.Billback_ID = Billback_Product.Billback_ID AND
						Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID AND
						Billback_Program.Deleted = 0
						INNER JOIN ##TMP_BB_Dist_Prog_Prod_Rate_Final ON
						Billback_Product.Billback_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_ID AND
						Billback_Product.Product_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Product_Product_ID AND
						Billback_Product.Distributor_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Product_Distributor_ID AND
						Billback_Program.Program_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Program_Program_ID AND
						Billback_Product.Deleted = 0
						INNER JOIN BSA_Foodservice_Items_Master ON
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Product_Product_ID
				WHERE  	Billback_Product.BB_Product_Quantity != ##TMP_BB_Dist_Prog_Prod_Rate_Final.BB_Product_Quantity
						OR Billback_Product.BB_Product_UOM != ##TMP_BB_Dist_Prog_Prod_Rate_Final.UOM_To_Use


				/* INSERT */
				/* If there are multiple rows for same product, we will sum up the values and need to convert to a common UOM */
				INSERT 	INTO Billback_Product
						(Billback_ID, Product_ID, Billback_Program_ID, BB_Product_Quantity, BB_Product_UOM, Distributor_ID, Created_Sort_Order)
				SELECT 	##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_ID,
						##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Product_Product_ID,
						Billback_Program.Billback_Program_ID,
						CAST(CAST(##TMP_BB_Dist_Prog_Prod_Rate_Final.BB_Product_Quantity AS DECIMAL(18,2)) AS VARCHAR(50)),
						##TMP_BB_Dist_Prog_Prod_Rate_Final.UOM_To_Use,
						##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Product_Distributor_ID,
						##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Product_Sort_Order
				FROM 	##TMP_BB_Dist_Prog_Prod_Rate_Final
						INNER JOIN Billback_Program ON
						Billback_Program.Billback_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_ID AND
						Billback_Program.Program_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Program_Program_ID AND
						Billback_Program.Deleted = 0
						INNER JOIN BSA_Foodservice_Items_Master ON
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Product_Product_ID
						LEFT JOIN  Billback_Product ON
						Billback_Product.Billback_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_ID AND
						Billback_Product.Product_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Product_Product_ID AND
						Billback_Product.Distributor_ID = ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Product_Distributor_ID AND
						Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID AND
						Billback_Product.Deleted = 0
				WHERE   ##TMP_BB_Dist_Prog_Prod_Rate_Final.Billback_Product_Product_ID IS NOT NULL
						AND Billback_Product.Product_ID IS NULL


				/*** Billback_Product_Detail ***/
				IF OBJECT_ID('tempdb..##TMP_BB_Dist_Prog_Prod_Rate_SUM') IS NOT NULL
				DROP TABLE ##TMP_BB_Dist_Prog_Prod_Rate_SUM

				SELECT	Billback_Product.Billback_Product_ID,
						Billback_Product.Billback_Program_ID,
						##TMP_BB_Dist_Prog_Prod_Rate.Billback_Product_Distributor_ID,
						##TMP_BB_Dist_Prog_Prod_Rate.Billback_ID,
						##TMP_BB_Dist_Prog_Prod_Rate.Billback_Product_Detail_BB_Product_Type_ID,
						SUM(##TMP_BB_Dist_Prog_Prod_Rate.Billback_Product_Detail_BB_Rate) AS BB_Rate_Sum
				INTO 	##TMP_BB_Dist_Prog_Prod_Rate_SUM
				FROM	##TMP_BB_Dist_Prog_Prod_Rate
						INNER JOIN Billback_Program ON
						Billback_Program.Billback_ID = ##TMP_BB_Dist_Prog_Prod_Rate.Billback_ID AND
						Billback_Program.Program_ID = ##TMP_BB_Dist_Prog_Prod_Rate.Billback_Program_Program_ID AND
						Billback_Program.Deleted = 0
						INNER JOIN Billback_Product ON
						Billback_Product.Billback_ID = ##TMP_BB_Dist_Prog_Prod_Rate.Billback_ID AND
						Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID AND
						Billback_Product.Product_ID = ##TMP_BB_Dist_Prog_Prod_Rate.Billback_Product_Product_ID AND
						Billback_Product.Distributor_ID = ##TMP_BB_Dist_Prog_Prod_Rate.Billback_Product_Distributor_ID AND
						Billback_Product.Deleted = 0
				GROUP BY Billback_Product.Billback_Product_ID,
						Billback_Product.Billback_Program_ID,
						##TMP_BB_Dist_Prog_Prod_Rate.Billback_Product_Distributor_ID,
						##TMP_BB_Dist_Prog_Prod_Rate.Billback_ID,
						##TMP_BB_Dist_Prog_Prod_Rate.Billback_Product_Detail_BB_Product_Type_ID


				/* DELETE: Delete records from Billback_Product_Detail which are not in the Billback_Product table*/
				UPDATE 	Billback_Product_Detail
				SET		Billback_Product_Detail.Deleted = 1,
						Billback_Product_Detail.Deleted_By = '#request.AccessStructure.User_ID#',
						Billback_Product_Detail.Deleted_Date = getDate()
				FROM 	Billback_Product_Detail
						LEFT JOIN Billback_Product ON
						Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID AND
						Billback_Product_Detail.Billback_ID = Billback_Product.Billback_ID AND
						Billback_Product_Detail.Distributor_ID_Earned = Billback_Product.Distributor_ID  AND
						Billback_Product.Deleted = 0
				WHERE	Billback_Product_Detail.Billback_ID = @Billback_ID
					AND	Billback_Product_Detail.Billback_Product_ID IS NOT NULL
					AND	Billback_Product.Billback_Product_ID IS NULL


				/* UPDATE: Update mactching records in Billback_Product_Detail when rate OR product_type is not same */
				UPDATE 	Billback_Product_Detail
				SET		Billback_Product_Detail.BB_Rate = ##TMP_BB_Dist_Prog_Prod_Rate_SUM.BB_Rate_Sum,
						Billback_Product_Detail.BB_Product_Type_ID = ##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_Product_Detail_BB_Product_Type_ID
				FROM 	Billback_Product_Detail
						INNER JOIN Billback_Product ON
						Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID AND
						Billback_Product_Detail.Billback_ID = Billback_Product.Billback_ID AND
						Billback_Product_Detail.Distributor_ID_Earned = Billback_Product.Distributor_ID AND
						Billback_Product.Deleted = 0
						INNER JOIN ##TMP_BB_Dist_Prog_Prod_Rate_SUM ON
						Billback_Product_Detail.Billback_Product_ID = ##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_Product_ID AND
						Billback_Product.Billback_ID = ##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_ID AND
						Billback_Product.Billback_Program_ID = ##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_Program_ID AND
						Billback_Product.Distributor_ID = ##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_Product_Distributor_ID AND
						Billback_Product.Deleted = 0
				WHERE	Billback_Product_Detail.BB_Rate != ##TMP_BB_Dist_Prog_Prod_Rate_SUM.BB_Rate_Sum
						OR Billback_Product_Detail.BB_Product_Type_ID != ##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_Product_Detail_BB_Product_Type_ID


				INSERT INTO Billback_Product_Detail
						(Billback_Product_ID, Billback_ID, BB_Product_Type_ID, BB_Rate, Distributor_ID_Earned)
				SELECT  ##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_Product_ID,
						##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_ID,
						##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_Product_Detail_BB_Product_Type_ID,
						##TMP_BB_Dist_Prog_Prod_Rate_SUM.BB_Rate_Sum,
						##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_Product_Distributor_ID
				FROM 	##TMP_BB_Dist_Prog_Prod_Rate_SUM
						LEFT JOIN Billback_Product_Detail ON
						Billback_Product_Detail.Billback_Product_ID = ##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_Product_ID AND
						Billback_Product_Detail.Billback_ID = ##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_ID AND
						Billback_Product_Detail.Distributor_ID_Earned = ##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_Product_Distributor_ID AND
						Billback_Product_Detail.BB_Product_Type_ID =##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_Product_Detail_BB_Product_Type_ID AND
						Billback_Product_Detail.Deleted = 0
				WHERE	##TMP_BB_Dist_Prog_Prod_Rate_SUM.Billback_Product_ID IS NOT NULL
					AND Billback_Product_Detail.Billback_Product_ID IS NULL

				IF OBJECT_ID('tempdb..##TMP_BB_Dist_Prog_Prod_Rate') IS NOT NULL
				DROP TABLE ##TMP_BB_Dist_Prog_Prod_Rate

				IF Object_id('tempdb..##TMP_BB_Dist_Prog_Prod_Rate_Final') IS NOT NULL
				DROP TABLE ##TMP_BB_Dist_Prog_Prod_Rate_Final

				IF OBJECT_ID('tempdb..##TMP_BB_Dist_Prog_Prod_Rate_SUM') IS NOT NULL
				DROP TABLE ##TMP_BB_Dist_Prog_Prod_Rate_SUM

			</cfquery>

		</cftransaction>

	</cffunction>

	<!---save billback components --->
	<cffunction name="saveBillbackComponents" output="false" access="public" hint="Function to save billback components data to the DB">

		<cfargument name="billbackComponentData" required="true" type="array">
		<cfargument name="payeeType" default="0">

		<cfscript>
			//set local variables
			var arrCompData 		= arrayNew(1);
			var indx				= "";
			var qDeleteComponent 	= "";
			var qAddComponent 		= "";
			var qGetComponentId		= "";
			var iPrgRebCompID 		= 0;
			var iPayeeType			= 0;
			var iProgramID 			= 0;
			var qCheckBBPrgId 		= "";

			//assign local variables
			arrCompData	= arguments.billbackComponentData;
			iPayeeType	= arguments.payeeType;

		</cfscript>

		<cftransaction>

			<!--- delete from billback program rebate component tables --->
			<cfquery datasource="#application.datasource#" name="qDeleteRebateComponent">
				UPDATE	Billback_Program_Rebate_Component
				SET		Deleted = 1
				WHERE	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#">
			</cfquery>

			<!--- delete from billback program lumpsum component tables --->
			<cfquery datasource="#application.datasource#" name="qDeleteLumpsumComponent">
				UPDATE	Billback_Program_Lumpsum_Component
				SET		Deleted = 1
				WHERE	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#">
			</cfquery>



			<cfloop index="indx" array="#arrCompData#">

				<cfset iPrgRebCompID = 0 />
				<cfset iPrgLSCompID = '' />
				<cfset sBBProgramID = '' />

				<cfquery datasource="#application.datasource#" name="qCheckBBPrgId">
					SELECT	bp.Program_ID AS Program_ID
					FROM	Billback_Program bp
							INNER JOIN Contract_Main cm ON cm.Contract_Main_ID = bp.Program_ID AND cm.Contract_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#indx.programNumber#">
					WHERE	bp.Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#">
					AND		bp.Deleted = 0
				</cfquery>

				<cfif qCheckBBPrgId.RecordCount and qCheckBBPrgId.Program_ID neq indx.programID>
					<cfset iProgramID = qCheckBBPrgId.Program_ID  />
				<cfelse>
					<cfset iProgramID = indx.programID />
				</cfif>

				<cfif indx.componentTypeId eq '1' >
					<!---Fixed--->
					<cfquery datasource="#application.datasource#" name="qGetFixedComponentId">
						SELECT	DISTINCT Program_Fixed_Component_ID
						FROM	Program_Fixed_Component
						WHERE	Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#iProgramID#"  />
						AND		Deleted = 0
						AND
						(
								Program_Fixed_Component_Name_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#indx.componentNameId#"  /> AND
								(
									Fixed_Component_Paid_to = <cfqueryparam cfsqltype="cf_sql_integer" value="#iPayeeType#"  />
									<cfif application.appSettingsGet.Billback_Display_All_Program_Components eq 1>
									OR 1 = 1
									</cfif>
								)
						)
					</cfquery>

					<cfif qGetFixedComponentId.RecordCount>
						<cfset iPrgFixedCompID = qGetFixedComponentId.Program_Fixed_Component_ID />
					</cfif>

					<cfquery datasource="#application.datasource#" name="qAddComponent">
						UPDATE 	Billback_Program
						SET 		Program_Fixed_Component_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#iPrgFixedCompID#" />
						WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#">
						AND			Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#iProgramID#"  />
						AND			Deleted = 0
					</cfquery>

				<!--- componentTypeID = "2"  implies it is Rebate --->
				<cfelseif indx.componentTypeId eq '2' >
					<!---Rebate--->
					<cfquery datasource="#application.datasource#" name="qGetRebComponentId">
						SELECT	DISTINCT Program_Rebates_Component_ID
						FROM	Program_Rebates_Component
						WHERE	Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#iProgramID#"  />
						AND		Deleted = 0
						AND
						(
								Program_Rebates_Component_Name_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#indx.componentNameId#"  /> AND
								(
									Component_Paid_To = <cfqueryparam cfsqltype="cf_sql_integer" value="#iPayeeType#"  />
									<cfif application.appSettingsGet.Billback_Display_All_Program_Components eq 1>
									OR 1 = 1
									</cfif>
								)
						)
					</cfquery>

					<cfif qGetRebComponentId.RecordCount>
						<cfset iPrgRebCompID = qGetRebComponentId.Program_Rebates_Component_ID />
					</cfif>

					<cfquery datasource="#application.datasource#" name="qAddComponent">
						INSERT INTO Billback_Program_Rebate_Component
							(
								Billback_ID,
								Billback_Program_ID,
								Program_Rebates_Component_Name,
								Program_Rebates_Component_Name_ID,
								Program_Rebates_Component_ID,
								Checked
							)
						VALUES
							(
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#">,
								<cfqueryparam cfsqltype="cf_sql_integer" value="#iProgramID#"  />,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#indx.componentName#"  />,
								<cfqueryparam cfsqltype="cf_sql_integer" value="#indx.componentNameId#"  />,
								<cfqueryparam cfsqltype="cf_sql_integer" value="#iPrgRebCompID#"  />,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="true"  />
							)
					</cfquery>
				<!--- componentTypeID = "3"  implies it is Lumpsum --->
				<cfelseif indx.componentTypeId eq '3'>
					<!---Lumpsum--->

					<!--- BB PROGRAM GUID --->
					<cfquery datasource="#application.datasource#" name="qGetBBProgramID">
						SELECT	Billback_Program_ID
						FROM	Billback_Program
						WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#">
						AND		Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#iProgramID#"  />
						AND		Deleted = 0
					</cfquery>

					<cfif qGetBBProgramID.RecordCount>
						<cfset sBBProgramID = qGetBBProgramID.Billback_Program_ID />
					<cfelse>
						<cfset sBBProgramID = saveBillbackProgram(iProgramID) />
					</cfif>

					<cfquery datasource="#application.datasource#" name="qGetLSComponentId">
						SELECT	DISTINCT Program_Lump_Sum_ID
						FROM	Program_Lump_Sums
								INNER JOIN Billback_Program ON Billback_Program.Program_ID = Program_Lump_Sums.Program_ID
								AND Billback_Program.Billback_Program_ID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#sBBProgramID#">
								AND Billback_Program.Deleted = 0
						WHERE	Program_Lump_Sums.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#iProgramID#"  />
						<!---AND		Program_Lump_Sum_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#indx.programComponentId#">--->
						AND		Program_Lump_Sums.Deleted = 0
						AND
						(		Program_Lump_Sum_Name_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#indx.componentNameId#"  /> AND
								(
									Component_Paid_To = <cfqueryparam cfsqltype="cf_sql_integer" value="#iPayeeType#"  />
									<cfif application.appSettingsGet.Billback_Display_All_Program_Components eq 1>
									OR Component_Paid_To = <cfqueryparam cfsqltype="cf_sql_integer" value="#indx.paidTo.paidToId#"  />
									</cfif>
								)
						)

					</cfquery>

					<cfif qGetLSComponentId.RecordCount>
						<cfset iPrgLSCompID = qGetLSComponentId.Program_Lump_Sum_ID />
					<cfelse>
						<cfset iPrgLSCompID = indx.programComponentId />
					</cfif>


					<cfquery datasource="#application.datasource#" name="qAddComponent">
						IF NOT EXISTS(
							SELECT * FROM Billback_Program_Lumpsum_Component WHERE
							Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#"> AND
							Billback_Program_ID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#sBBProgramID#"  /> AND
							Program_Lump_Sum_ID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#iPrgLSCompID#" null="#IIf(trim(iPrgLSCompID) eq '', DE('yes'), DE('no'))#"  /> AND
							Deleted = 0
						)
							BEGIN
								INSERT INTO Billback_Program_Lumpsum_Component
									(
										Billback_ID,
										Billback_Program_ID,
										Program_Lump_Sum_ID,
										Component_Type_ID,
										Amount
									)
								VALUES
									(
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#">,
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#sBBProgramID#"  />,
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#iPrgLSCompID#" null="#IIf(trim(iPrgLSCompID) eq '', DE('yes'), DE('no'))#"  />,
										<cfqueryparam cfsqltype="cf_sql_integer" value="1"  />,
										<cfif indx.componentAmount EQ "NaN">
											<cfqueryparam cfsqltype="cf_sql_varchar" value="0.0"  />
										<cfelse>
											<cfqueryparam cfsqltype="cf_sql_varchar" value="#indx.componentAmount#"  />
										</cfif>
									)
							END
						ELSE
							BEGIN
								UPDATE Billback_Program_Lumpsum_Component
								SET Amount = <cfif indx.componentAmount EQ "NaN">
											<cfqueryparam cfsqltype="cf_sql_varchar" value="0.0"  />
										<cfelse>
											<cfqueryparam cfsqltype="cf_sql_varchar" value="#indx.componentAmount#"  />
										</cfif>
								WHERE
									Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#"> AND
									Billback_Program_ID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#sBBProgramID#"  /> AND
									Program_Lump_Sum_ID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#iPrgLSCompID#" null="#IIf(trim(iPrgLSCompID) eq '', DE('yes'), DE('no'))#"  /> AND
									Deleted = 0
							END
					</cfquery>


				</cfif>

			</cfloop>
			<!---
						D52424 Permanent fix for WR 51902-BBs without entries in the BB Distributor List-Need CF Developer
						Code was moved from inside the loop to outside the loop, to work correctly and not to delete the
						other Distributors.
						START:  D30650 - Update Assoc. Distributor based on payee/Anand Rao/27-Feb-2012
						Since the products array might not have any data in case there is only one LS in the BB
			--->
						<cfif iPayeeType EQ 1>

							<cfquery name="distOnBillbackProduct" datasource="#application.datasource#">
								SELECT 	Distinct(Distributor_ID)
								FROM 	Billback_Product
								WHERE 	Billback_ID = <cfqueryparam value="#this.strBillbackID#" cfsqltype="CF_SQL_VARCHAR">
								AND 	Deleted = 0
							</cfquery>

							<cfif distOnBillbackProduct.RecordCount EQ 0> <!--- No product exists on the Billback --->

								<cfquery name="distOnBillback" datasource="#application.datasource#">
									SELECT Distinct(Distributor_ID) FROM Billback_Distributor WHERE Billback_ID = <cfqueryparam value="#this.strBillbackID#" cfsqltype="CF_SQL_VARCHAR">
									AND Deleted = 0
								</cfquery>

								<!---
								In this scenario remove the existing distributors as only one record will exist in the Billback_Distributor_List
								and then re-Insert the new one.
								--->
								<cfquery datasource="#application.datasource#" name="qDeleteLumpsumComponent">
									UPDATE	Billback_Distributor_List
									SET		Deleted = 1
									WHERE	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#">
								</cfquery>

								<!--- Insert the New distributor record --->
								<cfquery name="distOnBillback" datasource="#application.datasource#">
									INSERT INTO Billback_Distributor_List
										(Billback_ID, Distributor_ID)
									VALUES
									(
										<cfqueryparam value="#this.strBillbackID#" cfsqltype="CF_SQL_VARCHAR">,
										<cfqueryparam value="#distOnBillback.Distributor_ID#" cfsqltype="CF_SQL_VARCHAR">
									)
								</cfquery>

							</cfif>

						</cfif>
			<!--- END:  D30650 - Update Assoc. Distributor based on payee/Anand Rao/27-Feb-2012 --->
		</cftransaction>

	</cffunction>


	<!---save billback distributor--->
	<cffunction name="saveBillbackDistributor" output="false" access="public" hint="Function to save billback distributor data to the DB">

		<cfargument name="billbackDistributorID" 	required="true" 	type="string">
		<cfargument name="billbackVendorID" 		required="false" 	type="string" default="">

		<cfscript>
			//set local variables
			var strDistributorID	= "";
			var strVendorID			= "";
			var qAddDistributor		= "";

			//assign local variables
			strDistributorID	= arguments.billbackDistributorID;
			strVendorID			= arguments.billbackVendorID;

		</cfscript>

		<cftransaction>

			<cfquery name="qAddDistributor" datasource="#application.datasource#">
				INSERT INTO Billback_Distributor
					(
						Billback_ID,Distributor_ID, Uploaded_Vendor_ID
					)
				SELECT 	DISTINCT '#this.strBillbackID#', BSA_Foodservice_Customers_ID, '#strVendorID#'
				FROM	BSA_Foodservice_Customers
				WHERE	Shr_Ship_To = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#strDistributorID#" />
				AND		Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />
			</cfquery>

		</cftransaction>
	</cffunction>

	<!--- save billback operator --->
	<cffunction name="saveBillbackOperator" output="false" access="public" hint="Function to save billback operator data to the DB">

		<cfargument name="billbackOperatorID" 		required="true" 	type="string">
		<cfargument name="billbackVendorID" 		required="false" 	type="string" default="">

		<cfscript>
			//set local variables
			var strOperatorID		= "";
			var strVendorID			= "";
			var qAddOperator		= "";

			//assign local variables
			strOperatorID 	= arguments.billbackOperatorID;
			strVendorID		= arguments.billbackVendorID;

		</cfscript>

		<cftransaction>

			<cfquery name="qAddOperator" datasource="#application.datasource#">

				DECLARE
				@Use_Operator_Legacy_ID	BIT

				SELECT @Use_Operator_Legacy_ID = ISNULL(Operator_Legacy_ID_On, 0) FROM CUSTOMER_SETTINGS

				INSERT INTO Billback_Operator
				(
					Billback_ID, Operator_ID, Uploaded_Vendor_ID
				)
				SELECT	DISTINCT '#this.strBillbackID#', BSA_Operator_ID, '#strVendorID#'
				FROM	BSA_Operator
				WHERE	((@Use_Operator_Legacy_ID = 1 AND Legacy_ID = <cfqueryparam value="#strOperatorID#" cfsqltype="CF_SQL_VARCHAR" />) OR (BSA_Operator_ID = <cfqueryparam value="#strOperatorID#" cfsqltype="CF_SQL_VARCHAR" />))
				AND		Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />

			</cfquery>

		</cftransaction>

	</cffunction>

	<!--- save billback broker --->
	<cffunction name="saveBillbackBroker" output="false" access="public" hint="Function to save billback broker data to the DB">

		<cfargument name="billbackBrokerID" required="true" type="string">

		<cfscript>
			//set local variables
			var strBrokerID		= "";
			var qAddBroker		= "";

			//assign local variables
			strBrokerID = arguments.billbackBrokerID;

		</cfscript>

		<cfquery name="qAddBroker" datasource="#application.datasource#">
			INSERT INTO Billback_Broker
			(
				Billback_ID, Broker_ID
			)
			SELECT 	DISTINCT '#this.strBillbackID#', BSA_Foodservice_Brokers_ID
			FROM	BSA_Foodservice_Brokers
			WHERE	Broker_Legcy_Shard =  <cfqueryparam value="#strBrokerID#" cfsqltype="CF_SQL_VARCHAR" />
			AND		Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />
		</cfquery>

	</cffunction>

	<!--- save billback program --->
	<cffunction name="saveBillbackProgram" output="false" access="public" hint="Function to save billback program data to the DB" returntype="string">

		<cfargument name="billbackProgram" required="true" type="string">

		<cfscript>
			//set local variables
			var nProgramID					= "";
			var qDeleteAddProgram			= "";
			var qGetBillbackProgramID		= "";
			var retStrBillbackProgramID 	= "";

			//assign local variables
			nProgramID = arguments.billbackProgram;

		</cfscript>

		<!--- check entry for Billback_Program otherwise add it --->
		<cfquery name="qCheckAddProgram" datasource="#application.datasource#">
			Declare @Count int

			SET 	@Count = 0

			Select 	@Count = count(Billback_Program_ID)
			FROM	Billback_Program
			WHERE 	Billback_ID = 	<cfqueryparam value="#this.strBillbackID#" cfsqltype="CF_SQL_VARCHAR" />
			AND		Program_ID 	= 	<cfqueryparam value="#nProgramID#" cfsqltype="CF_SQL_INTEGER" />
			AND		Deleted 	=	<cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />

			IF (@Count = 0)
			BEGIN
				INSERT INTO Billback_Program
					(Billback_ID,Program_ID)
				VALUES
					(
						<cfqueryparam value="#this.strBillbackID#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#nProgramID#" cfsqltype="CF_SQL_INTEGER" />
					)
			END
		</cfquery>

		<!--- grab the Billback_Program_ID and return it --->
		<cfquery name="qGetBillbackProgramID" datasource="#application.datasource#">
			SELECT 	Billback_Program_ID
			FROM	Billback_Program
			WHERE 	Billback_ID = 	<cfqueryparam value="#this.strBillbackID#" cfsqltype="CF_SQL_VARCHAR" />
			AND		Program_ID 	= 	<cfqueryparam value="#nProgramID#" cfsqltype="CF_SQL_INTEGER" />
			AND		Deleted 	=	<cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />
		</cfquery>

		<cfscript>
			retStrBillbackProgramID = qGetBillbackProgramID.Billback_Program_ID;
			return retStrBillbackProgramID;
		</cfscript>

	</cffunction>

	<!--- save billback distributor list--->
	<cffunction name="saveBillbackDistributorList" output="false" access="public" hint="Function to save list of billback distributor data to the DB">

		<cfargument name="billbackDistributorIDList" required="true" type="string">

		<cfscript>
			//set local variables
			var lDistributorIDs			= "";
			var qAddDistributorList		= "";
			var qDeleteDistributorList	= "";
			var indx					= "";

			//assign local variables
			lDistributorIDs = arguments.billbackDistributorIDList;

		</cfscript>

		<cfquery name="qDeleteDistributorList" datasource="#application.datasource#">
			UPDATE	Billback_Distributor_List
			SET		Deleted = 1
			WHERE 	Billback_ID = <cfqueryparam value="#this.strBillbackID#" cfsqltype="CF_SQL_VARCHAR" />
		</cfquery>

		<cfloop index="indx" list="#lDistributorIDs#">

			<cfquery name="qAddDistributorList" datasource="#application.datasource#">
				INSERT INTO Billback_Distributor_List
					(Billback_ID,Distributor_ID)
				VALUES
					(
						<cfqueryparam value="#this.strBillbackID#" cfsqltype="CF_SQL_VARCHAR" />,
						CAST('#indx#' AS UNIQUEIDENTIFIER)
					)
			</cfquery>
		</cfloop>

	</cffunction>

	<!--- run billback deviation data --->
	<cffunction name="runBillbackDeviationData" output="false" access="public" hint="Function to run billback deviation if it hasnt been run yet">

		<cfargument name="billbackIDInt"	type="numeric"	required="true">
		<cfargument name="userId" 			type="string"	required="true">

		<cfscript>
			//set local variables
			var nBillbackIDInt			= "";
			var strUserId				= "";
			var qCheckDeviation			= "";
			var qUpdateDeviation		= "";
			var qCheckStatus			= "";
			var qUpdateStatus			= "";

			//assign local variables
			nBillbackIDInt		= arguments.billbackIDInt;
			strUserID			= arguments.userId;
			this.strBillbackID	= this.objBillbackDAO.getBillbackUUID(nBillbackIDInt);

		</cfscript>

		<!--- if the billback is WIP, then set it to RFA first --->
		<cfquery name="qCheckStatus" datasource="#application.datasource#">
			SELECT	Billback_Status_ID
			FROM 	Billback
			WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#">
		</cfquery>

		<cfif qCheckStatus.Billback_Status_ID eq 1>
			<cfquery name="qUpdateStatus" datasource="#application.datasource#">
				UPDATE 	Billback
				SET		Billback_Status_ID =  <cfqueryparam cfsqltype="cf_sql_numeric" value="2">,
						BB_Request_Approval_User_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#strUserID#">,
						BB_Request_Approval_Date = getDate()
				WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#">
			</cfquery>

			<cfstoredproc procedure="Populate_Billback_Approvable_Positions" datasource="#application.datasource#">
				<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@Billback_ID" value="#this.strBillbackID#">
			</cfstoredproc>

		</cfif>

		<cfquery name="qCheckDeviation" datasource="#application.datasource#">
			SELECT	Deviation_Ran_Date
			FROM 	Billback
			WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#">
		</cfquery>

		<CFIF not isDate(qCheckDeviation.Deviation_Ran_Date)>

			<!--- Call billback deviation routine --->
			<cfstoredproc procedure="BB_Deviation_Run_All" datasource="#application.datasource#">
				<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" value="#this.strBillbackID#">
			</cfstoredproc>

			<!--- Flag that billback deviation has run --->
			<cfquery name="qUpdateDeviation" datasource="#application.datasource#">
				UPDATE	Billback
				SET 	Deviation_Ran_Date = getdate(),
						Deviation_Ran_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#strUserID#">
				WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#">
			</cfquery>

		</CFIF>


		<!--- Comment for now untill we have workflow running
		<cfquery name="updLockBillback" datasource="#application.datasource#">
			UPDATE Billback_Allied
			SET    BB_Is_Locked = 1,
					BB_Locked_By_User_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#strUserID#">,
					BB_Lock_Date = GetDate(),
					BB_Locked_By_Deviation_Grid = 1
			WHERE  Billback_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#this.strBillbackID#">
		</cfquery>
		--->
		<cfreturn true />

	</cffunction>

</cfcomponent>