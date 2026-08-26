<cfcomponent alias="mvc.Models.Billback.BillbackUploadManager" extends="mvc.Models.SettingsService">
	<cfset appSettings = application.appSettingsGet />

	<cfscript>
		variables.oBillBackUploadDAO = createObject('component','mvc.Models.Billback.BillbackUploadDAO');
		variables.BBMgr				 = CreateObject("component","mvc.Models.Billback.BillbackManager");
		variables.objBillbackLoadManager= CreateObject("component","mvc.Models.Billback.BillbackLoadManager");
	</cfscript>


	<cffunction name="init" output="false" returntype="mvc.Models.Billback.BillbackUploadManager">
		<cfreturn this />
	</cffunction>

	<!---
		This function will be called on the load of the error correction summary screen and this will
		return all the rows that have errors from the BB_Upload_Header_Error_Correction table.
	--->
	<cffunction name="getErrorCorrectionSummary" returntype="Struct"  access="remote" hint="This will be an array of the header records">
		<cfset BBArr = ArrayNew(1)/>
		<cfset stReturnData = StructNew()>
		<cfset qHeaderData = variables.oBillBackUploadDAO.getHeaderSummary() />
		<cfset qRefreshTime = variables.oBillBackUploadDAO.getBBCorrectionsLastUserRefreshDate() />
		<cfset qErrorCodes = variables.oBillBackUploadDAO.getBBUploadErrorCodes() />

		<cfloop query = "qHeaderData">
			<cfset BBHdrObj = getOneHeaderRow(0,0,qHeaderData) />
 			<cfset BBHdrObj.errObj			= this.getHeaderErrorObject(ErrorMessage = qHeaderData.Err_Msg ) />
			<cfset arrayAppend(bbArr,BBHdrObj) />
		</cfloop>

		<!--- data --->
		<cfset stReturnData.bbArr = bbArr>

		<!--- last refresh date/time --->
		<cfset stReturnData.refreshTime = qRefreshTime.Updated_Date>


		<cfreturn stReturnData />

	</cffunction>

	<cffunction name="getErrorCorrectionSummaryJSON" returntype="string" returnformat="JSON"  access="remote" hint="This will be an array of the header records">
		<cfset BBArr = ArrayNew(1)/>
		<cfset stReturnData = StructNew()>
		<cfset qHeaderData = variables.oBillBackUploadDAO.getHeaderSummary() />
		<cfset qRefreshTime = variables.oBillBackUploadDAO.getBBCorrectionsLastUserRefreshDate() />
		<cfset qErrorCodes = variables.oBillBackUploadDAO.getBBUploadErrorCodes() />

		<cfloop query = "qHeaderData">
			<cfset BBHdrObj = getOneHeaderRowJSON(0,0,qHeaderData) />
 			<cfset BBHdrObj.errObj			= this.getHeaderErrorObjectJSON(ErrorMessage = qHeaderData.Err_Msg ) />
			<cfset arrayAppend(bbArr,BBHdrObj) />
		</cfloop>

		<!--- data --->
		<cfset stReturnData.bbArr = bbArr>

		<!--- last refresh date/time --->
		<cfset stReturnData.refreshTime = qRefreshTime.Updated_Date>

		<cfscript>
			return serializeJson(bbArr);
		</cfscript>
	</cffunction>


	<cffunction name="getBillbackUpload" returntype="mvc.Models.Billback.vos.BBUploadHeader" access="remote">
		<cfargument name="bbHeader" default="00000000-9999-9999-0000000000000000">
			<cfscript>
				var obj = createobject("component", "mvc.Models.Billback.vos.BBUploadHeader").init();
				obj.expPaymentAmount = 999999;
				obj.referenceNumber = 'BBCODE FROM QUERY';
				return obj;
			</cfscript>
		</cffunction>
	<!---
		This function will get the BB Header object and query the BB_Upload_Detail_Error_Correction table, get the
		relevant records and build an array, add it to the BB Header object and return the
		same object again.
	--->
	<cffunction name="getBillbackUploadDetail" returntype="mvc.Models.Billback.vos.BBUploadHeader" access="remote">
	<!--- We should be getting the Header object itself that was clicked and pass the same object back by just adding the details within the object --->
		<cfargument name="argbbUploadHeader" type="mvc.Models.Billback.vos.BBUploadHeader" default="">
		<cfargument name="argbDisplayAll" type="boolean" default="0" required="false">

		<cfset var uploadId = arguments.argbbUploadHeader.uploadId/>
		<cfset var bbHeaderID = arguments.argbbUploadHeader.bbHeaderID/>
		<cfset var bbUploadHeader = createObject("component","mvc.Models.Billback.vos.BBUploadHeader").init() />
		<cfset var BBDetailArr = ArrayNew(1)/>
		<cfset var qHeaderData = variables.oBillBackUploadDAO.getHeaderSummary(uploadID=uploadId, BBUploadHeaderErrorCorrectionID=bbHeaderID) />
		<cfset var qDetailsData = queryNew('qDetailsData')/>
 		<cfset var BBDtlObj = createObject("component","mvc.Models.Billback.vos.BBUploadDetail").init() />
		<cfset var BBLockedUser = createObject("component","mvc.Models.Entity.vos.User").init() />
		<cfset var BBUploadedUser = createObject("component","mvc.Models.Entity.vos.User").init() />
		<!--- call the query to refresh the queryresult --->

		<cfset iRowID = 0 />
		<cfset bbUploadHeader = getOneHeaderRow(uploadID=uploadId, BBUploadHeaderErrorCorrectionID=bbHeaderID,qHeaderDataArg = qHeaderData)/>
		<!--- if updated date matches, then don't reload --->
		<cfset BBDetailArr = argbbUploadHeader.bbUploadDetail />
		<cfif ((argbbUploadHeader.updatedDate NEQ bbUploadHeader.updatedDate) OR (isDefined("arguments.argbbUploadHeader.errMsg") AND  (arguments.argbbUploadHeader.errMsg EQ "reLoad"))) >
			<cfset qDetailsData = variables.oBillBackUploadDAO.getBBUploadDetails(uploadID=uploadId, BBUploadHeaderErrorCorrectionID=bbHeaderID, argbDisplayAll=arguments.argbDisplayAll) />
			<cfset bbUploadHeader.errMsg = 'reLoad'/>
			
			<cfset BBDetailArr = ArrayNew(1)/>
			<cfloop query = "qDetailsData">
				<!---
					The below if condition takes care of the issue where the amount has 10-12 digits in the decimal place.
					This cuts it down to only 2 decimal places.
				--->
				<!--- <cfif isNumeric(Trim(qDetailsData.Award_Amt))> --->
					<!--- <cfset AwardAmt = LTrim(NumberFormat(qDetailsData.Award_Amt, "___,___,___,___.__"))  /> --->
					<cfset AwardAmt = Replace(Replace(qDetailsData.Award_Amt," ","","ALL"),",","","ALL") />
				<!--- <cfelse>
					<cfset AwardAmt = Replace(Replace(qDetailsData.Award_Amt," ","","ALL"),",","","ALL") />
				</cfif> --->
				<!---<cfset BBDtlObj = createObject("component","mvc.Models.Billback.vos.BBUploadDetail").init() />--->
				<cfset iRowID = iRowID + 1 />
				<cfscript>
					BBDtlObj = structNew();
					BBDtlObj["__type__"] = "mvc.Models.Billback.vos.BBUploadDetail";
		 			BBDtlObj["uploadID"] 				= qDetailsData.upload_ID;
			 		BBDtlObj["shipTo"] 				= qDetailsData.Claim_Org_ID;
					BBDtlObj["dupShipTo"] 				= qDetailsData.Dup_Claim_Org_ID;
					BBDtlObj["custNumber"]  			= qDetailsData.DC_Org_ID;
					BBDtlObj["custName"]  				= qDetailsData.DC_Org_Desc;
					BBDtlObj["operatorLegacyId"]  		= qDetailsData.Operator_Org_ID;
					BBDtlObj["custContractNumber"]  	= qDetailsData.Agreement_Num;
					BBDtlObj["custContractDescription"]  = qDetailsData.Agreement_Name;
					// cfset BBDtlObj["agreementNum"]  	= qDetailsData.Agreement_Num;
					//BBDtlObj["agreementName"]  			= qDetailsData.Agreement_Name
					BBDtlObj["operatorId"]  			= qDetailsData.DC_AC_Num;
					BBDtlObj["operatorName"]  			= qDetailsData.DC_AC_Name;
					BBDtlObj["operatorAddress1"]  		= qDetailsData.ST_Address_1;
					BBDtlObj["operatorAddress2"]  		= qDetailsData.ST_Address_2;
					BBDtlObj["operatorCity"]  			= qDetailsData.ST_City;
					BBDtlObj["operatorState"]  			= qDetailsData.ST_State;
					BBDtlObj["operatorZip"]  			= qDetailsData.ST_Zip_Code;
					BBDtlObj["item"]  					= qDetailsData.Product_Num;
					BBDtlObj["custItem"]  				= qDetailsData.DC_Product_Num;
					BBDtlObj["custItemDescription"]  	= qDetailsData.DC_Product_Desc;
					BBDtlObj["BBProductQuantity"]  		= qDetailsData.CS_Qty;
					BBDtlObj["caseRate"]  				= qDetailsData.CS_Claim_Rate;
					BBDtlObj["BBRate"]  				= AwardAmt;
					BBDtlObj["contractNumber"]  		= qDetailsData.Contract_ID;
					BBDtlObj["contractTitle"]  			= "";
					BBDtlObj["bbDetailID"]  			= qDetailsData.BB_Upload_Detail_Error_Correction_ID;
					BBDtlObj["bbHeaderID"]  			= qDetailsData.BB_Upload_Header_Error_Correction_ID;
					BBDtlObj["errMsg"]  				= qDetailsData.Err_Msg;
					BBDtlObj["rowID"] 					= iRowID;
					BBDtlObj["DiscountType"] 			= qDetailsData.Discount_Type;
					if(trim(qDetailsData.Err_Msg) NEQ ''){
						BBDtlObj["errType"]  			= 1 ;
					}
					else{
						BBDtlObj["errType"]  			= 0 ;
					}
					//BBDtlObj["uploadType"]  			= qDetailsData.upload_type ;
					BBDtlObj["errObj"] 					= this.getDetailErrorObject(qDetailsData.Err_Msg);
					BBDtlObj["uploadtype"]  			= qDetailsData.upload_type;
					BBDtlObj["bEdited"] 				= javacast("boolean", 0);

					arrayAppend(BBDetailArr,BBDtlObj);
				</cfscript>
			</cfloop>
		<cfelse>
			
		</cfif> <!--- if updated date matches, then don't reload --->
		<cfscript>
			//SET DETAIL ARRAY SINCE GET HEADER ONLY RETURNS HEADER
			bbUploadHeader.bbUploadDetail	= BBDetailArr;
 			//bbUploadHeader.errObj 			= 	this.getHeaderErrorObject(ErrorMessage = qHeaderData.Err_Msg);
		</cfscript>

 	<!---

	TODO: 1) Read from the BB_Upload_Header_Error_Correction file and get it into the object
					a) View and editing mechanishm (Do not allow two users view [this will be handled in the flex screen])
				2)
	--->
	<cfreturn bbUploadHeader />
	</cffunction>

	<cffunction name="getBillbackUploadDetailJSON" returntype="string" returnformat="JSON" access="remote">
	<!--- We should be getting the Header object itself that was clicked and pass the same object back by just adding the details within the object --->
		<cfargument name="argbbUploadHeader" type="any" default="">
		<cfargument name="argbDisplayAll" type="boolean" default="0" required="false">

		<cfscript>
			// stuff

			var a = arguments;
			//writedump(var=a.argbbUploadHeader,output='c:\dump.log');
			//return;
			var st = deserializeJson(a.argbbUploadHeader);
			//writedump(var=st,output='c:\dump.log');
		</cfscript>

		<cfset var uploadId = st.uploadId/>
		<cfset var bbHeaderID = st.bbHeaderID/>
		<cfset var bbUploadHeader = createObject("component","mvc.Models.Billback.vos.BBUploadHeader").init() />
		<cfset var BBDetailArr = ArrayNew(1)/>
		<cfset var qHeaderData = variables.oBillBackUploadDAO.getHeaderSummary(uploadID=uploadId, BBUploadHeaderErrorCorrectionID=bbHeaderID) />
		<cfset var qDetailsData = queryNew('qDetailsData')/>
 		<cfset var BBDtlObj = createObject("component","mvc.Models.Billback.vos.BBUploadDetail").init() />
		<cfset var BBLockedUser = createObject("component","mvc.Models.Entity.vos.User").init() />
		<cfset var BBUploadedUser = createObject("component","mvc.Models.Entity.vos.User").init() />
		<!--- call the query to refresh the queryresult --->

		<cfset iRowID = 0 />
		<cfset bbUploadHeader = getOneHeaderRowJSON(uploadID=uploadId, BBUploadHeaderErrorCorrectionID=bbHeaderID,qHeaderDataArg = qHeaderData)/>
		<!--- if updated date matches, then don't reload --->
		<!--- <cfset BBDetailArr = st.argbbUploadHeader.bbUploadDetail /> --->
		<!--- <cfif ((st.updatedDate NEQ bbUploadHeader.updatedDate) OR (isDefined("st.errMsg") AND  (st.errMsg EQ "reLoad"))) > --->
			<cfset qDetailsData = variables.oBillBackUploadDAO.getBBUploadDetails(uploadID=uploadId, BBUploadHeaderErrorCorrectionID=bbHeaderID, argbDisplayAll=arguments.argbDisplayAll) />
			<cfset bbUploadHeader.errMsg = 'reLoad'/>
			
			<cfset BBDetailArr = ArrayNew(1)/>
			<cfloop query = "qDetailsData">
				<!---
					The below if condition takes care of the issue where the amount has 10-12 digits in the decimal place.
					This cuts it down to only 2 decimal places.
				--->
				<!--- <cfif isNumeric(Trim(qDetailsData.Award_Amt))> --->
					<!--- <cfset AwardAmt = LTrim(NumberFormat(qDetailsData.Award_Amt, "___,___,___,___.__"))  /> --->
					<cfset AwardAmt = Replace(Replace(qDetailsData.Award_Amt," ","","ALL"),",","","ALL") />
				<!--- <cfelse>
					<cfset AwardAmt = Replace(Replace(qDetailsData.Award_Amt," ","","ALL"),",","","ALL") />
				</cfif> --->
				<!---<cfset BBDtlObj = createObject("component","mvc.Models.Billback.vos.BBUploadDetail").init() />--->
				<cfset iRowID = iRowID + 1 />
				<cfscript>
					BBDtlObj = structNew();
					BBDtlObj["__type__"] = "mvc.Models.Billback.vos.BBUploadDetail";
		 			BBDtlObj["uploadID"] 				= JSStringFormat(qDetailsData.upload_ID);
			 		BBDtlObj["shipTo"] 					= JSStringFormat( qDetailsData.Claim_Org_ID);
					BBDtlObj["dupShipTo"] 				= JSStringFormat( qDetailsData.Dup_Claim_Org_ID);
					BBDtlObj["custNumber"]  			= JSStringFormat( qDetailsData.DC_Org_ID);
					BBDtlObj["custName"]  				= JSStringFormat( qDetailsData.DC_Org_Desc);
					BBDtlObj["operatorLegacyId"]  		= JSStringFormat( qDetailsData.Operator_Org_ID);
					BBDtlObj["custContractNumber"]  	= JSStringFormat( qDetailsData.Agreement_Num);
					BBDtlObj["custContractDescription"]  = JSStringFormat( qDetailsData.Agreement_Name);
					// cfset BBDtlObj["agreementNum"]  	= JSStringFormat( qDetailsData.Agreement_Num);
					//BBDtlObj["agreementName"]  			= JSStringFormat( qDetailsData.Agreement_Name
					BBDtlObj["operatorId"]  			= JSStringFormat( qDetailsData.DC_AC_Num);
					BBDtlObj["operatorName"]  			= JSStringFormat( qDetailsData.DC_AC_Name);
					BBDtlObj["operatorAddress1"]  		= JSStringFormat( qDetailsData.ST_Address_1);
					BBDtlObj["operatorAddress2"]  		= JSStringFormat( qDetailsData.ST_Address_2);
					BBDtlObj["operatorCity"]  			= JSStringFormat( qDetailsData.ST_City);
					BBDtlObj["operatorState"]  			= JSStringFormat( qDetailsData.ST_State);
					BBDtlObj["operatorZip"]  			= JSStringFormat( qDetailsData.ST_Zip_Code);
					BBDtlObj["item"]  					= JSStringFormat( qDetailsData.Product_Num);
					BBDtlObj["custItem"]  				= JSStringFormat( qDetailsData.DC_Product_Num);
					BBDtlObj["custItemDescription"]  	= JSStringFormat( qDetailsData.DC_Product_Desc);
					BBDtlObj["BBProductQuantity"]  		= JSStringFormat( qDetailsData.CS_Qty);
					BBDtlObj["caseRate"]  				= JSStringFormat( qDetailsData.CS_Claim_Rate);
					BBDtlObj["BBRate"]  				= JSStringFormat( AwardAmt);
					BBDtlObj["contractNumber"]  		= JSStringFormat( qDetailsData.Contract_ID);
					BBDtlObj["contractTitle"]  			= JSStringFormat( "");
					BBDtlObj["bbDetailID"]  			= JSStringFormat( qDetailsData.BB_Upload_Detail_Error_Correction_ID);
					BBDtlObj["bbHeaderID"]  			= JSStringFormat( qDetailsData.BB_Upload_Header_Error_Correction_ID);
					BBDtlObj["errMsg"]  				=  qDetailsData.Err_Msg;
					BBDtlObj["rowID"] 					= JSStringFormat( iRowID);
					BBDtlObj["DiscountType"] 			= JSStringFormat( qDetailsData.Discount_Type);
					if(trim(qDetailsData.Err_Msg) NEQ ''){
						BBDtlObj["errType"]  			= 1 ;
					}
					else{
						BBDtlObj["errType"]  			= 0 ;
					}
					//BBDtlObj["uploadType"]  			= JSStringFormat( qDetailsData.upload_type );
					BBDtlObj["errObj"] 					= this.getDetailErrorObject(qDetailsData.Err_Msg);
					BBDtlObj["uploadtype"]  			= JSStringFormat( qDetailsData.upload_type);
					BBDtlObj["bEdited"] 				= JSStringFormat( javacast("boolean", 0));

					arrayAppend(BBDetailArr,BBDtlObj);
				</cfscript>
			</cfloop>
		<!--- <cfelse>
			
		</cfif> ---> <!--- if updated date matches, then don't reload --->
		<cfscript>
			//SET DETAIL ARRAY SINCE GET HEADER ONLY RETURNS HEADER
			bbUploadHeader["bbUploadDetail"]	= BBDetailArr;
			var jsonData = '';
			jsonData = serializeJson(bbUploadHeader);
		</cfscript>


	<cfreturn jsonData />
	</cffunction>

	<!---
		This function will get the Upload_ID and return that row as a BB Header Object from the
		table BB_Upload_Header_Error_Correction
	---->
	<cffunction name="getOneHeaderRow" returntype="mvc.Models.Billback.vos.BBUploadHeader" access="remote">
		<cfargument name="UploadID" type="numeric" required="true">
		<cfargument name="BBUploadHeaderErrorCorrectionID" type="numeric" required="true">
		<cfargument name="qHeaderDataArg" type="query" required="false" default="#queryNew('uploadId')#">
		<cfscript>
			var qHeaderData = arguments.qHeaderDataArg;
			var BBLockedUser = createObject("component","mvc.Models.Entity.vos.User").init();
			var BBUploadedUser = createObject("component","mvc.Models.Entity.vos.User").init();
			var BBLockedUser = createObject("component","mvc.Models.Entity.vos.User").init();
			var BBUploadedUser = createObject("component","mvc.Models.Entity.vos.User").init();
			var bbUploadHeader = createObject("component","mvc.Models.Billback.vos.BBUploadHeader").init();
			if(arguments.qHeaderDataArg.recordcount == 0){
				qHeaderData = variables.oBillBackUploadDAO.getHeaderSummary(uploadID=arguments.UploadID,BBUploadHeaderErrorCorrectionID=arguments.BBUploadHeaderErrorCorrectionID);
			}
			bbLockedUser.id 				= qHeaderData.Locked_User;
			bbLockedUser.fullName			= qHeaderData.Full_Name;
			bbUploadedUser.id				= qHeaderData.User_ID;
			bbUploadedUser.fullName			= qHeaderData.Uploaded_User;
			bbUploadHeader.uploadDateTime	= qHeaderData.Upload_Date;
			bbUploadHeader.updatedDate		= qHeaderData.updated_Date;
			bbUploadHeader.uploadUser		= bbUploadedUser;
			//bbUploadHeader.bbUploadDetail	= BBDetailArr;
			bbUploadHeader.locked 		  	= qHeaderData.Locked;
			bbUploadHeader.lockedUser	   	= bbLockedUser;
			bbUploadHeader.lockedDateTime 	= qHeaderData.Locked_DateTime;
 			bbUploadHeader.uploadID 		= qHeaderData.upload_id;
			bbUploadHeader.bbHeaderID 		= qHeaderData.BB_Upload_Header_Error_Correction_ID;
			bbUploadHeader.bbHdrCounter 	= qHeaderData.Billback_Upload_III_PH_ID;
			bbUploadHeader.vendorId			= qHeaderData.Vendor_ID;
			bbUploadHeader.vendorName		= qHeaderData.Vendor_Name;
			bbUploadHeader.shipTo			= qHeaderData.Claim_Org_ID;
			bbUploadHeader.BBReference		= qHeaderData.Claim_Num;
			bbUploadHeader.BBDate			= qHeaderData.Claim_Date;
			bbUploadHeader.startDate		= qHeaderData.Period_St_Date;
			bbUploadHeader.endDate			= qHeaderData.Period_End_Date;
			bbUploadHeader.BBAmount			= qHeaderData.E_Total_Claimed_Amt;
			bbUploadHeader.TotalVolume		= qHeaderData.Tot_Volume;
			bbUploadHeader.errMsg 			= "";
			bbUploadHeader.errType 			= qHeaderData.Err_Type;
			bbUploadHeader.uploadType		= qHeaderData.upload_type;
			bbUploadHeader.processed		= qHeaderData.processed;
			bbUploadHeader.operatorLegacyID = qHeaderData.Operator_ID;
			bbUploadHeader.billbackTitle	= qHeaderData.billback_Title;
			bbUploadHeader.uploadStatus		= qHeaderData.upload_status;
			bbUploadHeader.agreementNum		= qHeaderData.Agreement_Num;
			bbUploadHeader.agreementName    = qHeaderData.Agreement_name;
			bbUploadHeader.isSelected		= 0;
 			bbUploadHeader.errObj 			= this.getHeaderErrorObject(ErrorMessage = qHeaderData.Err_Msg);
		</cfscript>

		<cfreturn bbUploadHeader />
	</cffunction>

	<cffunction name="getOneHeaderRowJSON" returntype="any" access="remote">
		<cfargument name="UploadID" type="numeric" required="true">
		<cfargument name="BBUploadHeaderErrorCorrectionID" type="numeric" required="true">
		<cfargument name="qHeaderDataArg" type="query" required="false" default="#queryNew('uploadId')#">
		<cfscript>
			var qHeaderData = arguments.qHeaderDataArg;
			var BBLockedUser = StructNew();
			var BBUploadedUser = StructNew();
			var BBLockedUser = StructNew();
			var bbUploadHeader = StructNew(); //createObject("component","mvc.Models.Billback.vos.BBUploadHeader").init();
			if(arguments.qHeaderDataArg.recordcount == 0){
				qHeaderData = variables.oBillBackUploadDAO.getHeaderSummary(uploadID=arguments.UploadID,BBUploadHeaderErrorCorrectionID=arguments.BBUploadHeaderErrorCorrectionID);
			}
			bbLockedUser["id"]					= qHeaderData.Locked_User;
			bbLockedUser["fullName"]			= JSStringFormat(qHeaderData.Full_Name);
			bbUploadedUser["id"]				= qHeaderData.User_ID;
			bbUploadedUser["fullName"]			= JSStringFormat(qHeaderData.Uploaded_User);
			bbUploadHeader["uploadDateTime"]	= qHeaderData.Upload_Date;
			bbUploadHeader["updatedDate"]		= qHeaderData.updated_Date;
			bbUploadHeader["uploadUser"]		= bbUploadedUser;
			//bbUploadHeader["bbUploadDetail	= JSStringFormat(BBDetailArr);
			bbUploadHeader["locked"] 		  	= qHeaderData.Locked;
			bbUploadHeader["lockedUser"]	   	= bbLockedUser;
			bbUploadHeader["lockedDateTime"] 	= qHeaderData.Locked_DateTime;
 			bbUploadHeader["uploadID"] 			= qHeaderData.upload_id;
			bbUploadHeader["bbHeaderID"] 		= qHeaderData.BB_Upload_Header_Error_Correction_ID;
			bbUploadHeader["bbHdrCounter"] 		= qHeaderData.Billback_Upload_III_PH_ID;
			bbUploadHeader["vendorId"]			= JSStringFormat(qHeaderData.Vendor_ID);
			bbUploadHeader["vendorName"]		= JSStringFormat(qHeaderData.Vendor_Name);
			bbUploadHeader["shipTo"]			= JSStringFormat(qHeaderData.Claim_Org_ID);
			bbUploadHeader["BBReference"]		= JSStringFormat(qHeaderData.Claim_Num);
			bbUploadHeader["BBDate"]			= JSStringFormat(qHeaderData.Claim_Date);
			bbUploadHeader["startDate"]			= JSStringFormat(qHeaderData.Period_St_Date);
			bbUploadHeader["endDate"]			= JSStringFormat(qHeaderData.Period_End_Date);
			bbUploadHeader["BBAmount"]			= JSStringFormat(qHeaderData.E_Total_Claimed_Amt);
			bbUploadHeader["TotalVolume"]		= JSStringFormat(qHeaderData.Tot_Volume);
			bbUploadHeader["errMsg"] 			= JSStringFormat("");
			bbUploadHeader["errType"] 			= JSStringFormat(qHeaderData.Err_Type);
			bbUploadHeader["uploadType"]		= qHeaderData.upload_type;
			bbUploadHeader["processed"]			= qHeaderData.processed;
			bbUploadHeader["operatorLegacyID"] 	= JSStringFormat(qHeaderData.Operator_ID);
			bbUploadHeader["billbackTitle"]		= JSStringFormat(replace(replace(qHeaderData.billback_Title,'##','','ALL'),'&','ALL'));
			bbUploadHeader["uploadStatus"]		= JSStringFormat(qHeaderData.upload_status);
			bbUploadHeader["agreementNum"]		= JSStringFormat(qHeaderData.Agreement_Num);
			bbUploadHeader["agreementName"]  	 = JSStringFormat(qHeaderData.Agreement_name);
			bbUploadHeader["isSelected"]		= 0;
 			bbUploadHeader["errObj"] 			= this.getHeaderErrorObjectJSON(ErrorMessage = qHeaderData.Err_Msg);
		</cfscript>

		<cfreturn bbUploadHeader />
	</cffunction>

	<!---
		This function will get the header object and detail array within it and update the
		tables BB_Upload_Header_Error_Correction and BB_Upload_Detail_Error_Correction.
	--->
	<cffunction name="saveUploadHeaderAndDetails" returntype="mvc.Models.Billback.vos.BBUploadHeader" access="remote">
		<cfargument name="bbUploadHeader" type="mvc.Models.Billback.vos.BBUploadHeader" default="">
		<cfargument name="sAction" type="string" default="2">
		<cfset var bbh = arguments.bbUploadHeader />
		<cfset bbh.errMsg = ''/>
		<cfset var qSingleHeaderRow = variables.oBillBackUploadDAO.saveUploadHeaderAndDetailsDAO(bbUploadHeader = arguments.bbUploadHeader,sAction=arguments.sAction) />
		<!---...............
			AFTER SAVE WE NEED TO CALL BB_Claim_Upload_Error_Correction_Parser.
			THEN RETURN RESULTS
				IF ANOTHER ERROR, SEND THE NEW ERROR (HEADER) TO CORRECTION SCREEN
				ELSE RETURN AN EMPTY HEADER -> UI WILL KNOW EMPTY HEADER MEANS SUCCESS
		.....................'--->
		<cfquery name="UploadTypeDetails" datasource="#application.datasource#">
			SELECT Upload_Type, Upload_Type_Desc
			FROM BB_upload_log
			WHERE upload_id = <cfqueryParam cfsqltype="CF_SQL_INTEGER" value="#arguments.bbUploadHeader.uploadID#" />
		</cfquery>
		<!---
				31265: Detail error correction is set deleted = 1 for all claims in an upload/Anand Rao/04-Apr-2012
				The below values for Upload_type and Upload_Type_Desc were hard coded earlier which was
				not working for the 3rd party, changed this to pick up the value from the BB_Upload_Log
				using the above query.
		--->
		<cfif arguments.sAction EQ "2">
			<cfstoredproc procedure="BB_Claim_Upload_Error_Correction_Parser" datasource="#application.datasource#">
				<cfprocparam cfsqltype="CF_SQL_TINYINT" value="#UploadTypeDetails.Upload_Type#" >
				<cfprocparam cfsqltype="CF_SQL_TINYINT" value="#UploadTypeDetails.Upload_Type_Desc#" >
				<cfprocparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bbUploadHeader.uploadID#" >
				<cfprocparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bbUploadHeader.bbHeaderID#" >
				<cfprocresult name = "validateResult" />
			</cfstoredProc>
			<cfset bbh = this.getBillbackUploadDetail(argbbUploadHeader = arguments.bbUploadHeader) />
		</cfif>
		<!--- //FOR TESTING UNTIL VALIDATION IS RUNNING -> RETURN THE ROW WE INSERTED --->

		<cfreturn bbh />
	</cffunction>

	<cffunction name="saveUploadHeaderAndDetailsJSON" returntype="string" returnformat="JSON" access="remote">
		<cfargument name="bbUploadHeader" type="any" default="">
		<cfargument name="sAction" type="string" default="2">
		<cfset var bbh = deserializeJson(arguments.bbUploadHeader) />
		<cfset bbh.errMsg = '' />
		<cfset lsDetailIds = '' />
		<cfset updatedHeaderIdList = ''>
		<cfloop index = "i" from = "1" to="#ArrayLen(bbh.bbUploadDetail)#">
			<!--- Only include detail rows that have been edited.  we still compare before/after values below ::  D115462 Mark S--->
			<cfif bbh.bbUploadDetail[i].bEdited EQ true>
				<cfset lsDetailIds =  ListAppend(lsDetailIds,bbh.bbUploadDetail[i].bbDetailID,",") />
				<cfset lsDetailIds =  Replace(lsDetailIds,",,",",","ALL") />
			</cfif>
		</cfloop>
		<!--- Used to compare if detail row had the item or agreement_num updated -> if yes we look for other "open" corrections that need the same fix ::  D115462 Mark S--->		
		<cfquery name="qGetDetailsBeforeSave" datasource="#application.datasource#">
			SELECT DISTINCT 
				H.Payee_Type,
				CASE WHEN H.Upload_type = 2 THEN BB_Detail_Sum_ID
					 ELSE BB_Upload_Detail_Error_Correction_ID
				END AS BB_Upload_Detail_Error_Correction_ID,
				D.BB_Detail_Sum_ID,
				D.Contract_ID,
				D.Agreement_Num,
				D.Product_Num,
				D.DC_Product_Num,
				D.Vendor_ID,
				H.BB_Upload_Header_Error_Correction_ID
			INTO ##tmp_BB_Upload_Detail_Error_Correction
			FROM BB_Upload_Header_Error_Correction H
			INNER JOIN BB_Upload_Detail_Error_Correction D  ON 
				D.BB_Upload_Header_Error_Correction_ID = H.BB_Upload_Header_Error_Correction_ID 
			WHERE  H.BB_Upload_Header_Error_Correction_ID = <cfqueryParam cfsqltype="CF_SQL_INTEGER" value="#bbh.bbHeaderID#" > AND 
					D.deleted = 0 AND
				<cfif trim(lsDetailIds) NEQ ''>
					(
						(D.BB_Detail_Sum_ID IN (#lsDetailIds#) and H.Upload_type = 2)
							OR
						(D.BB_Upload_Detail_Error_Correction_ID IN (#lsDetailIds#) and H.Upload_type != 2)
					)
				<cfelse>	<!--- No detail rows are updated/visible in Grid --->
					1 = 0 
				</cfif>
				
			SELECT * FROM ##tmp_BB_Upload_Detail_Error_Correction
		</cfquery>
		<!--- ***************		SAVE		*****************--->		
		<cfset var qSingleHeaderRow = variables.oBillBackUploadDAO.saveUploadHeaderAndDetailsDAO(bbUploadHeader = bbh,sAction=arguments.sAction) />
		
		<cfif (isDefined("qGetDetailsBeforeSave") AND qGetDetailsBeforeSave.RecordCount NEQ 0)>
			<cfloop query="qGetDetailsBeforeSave">
				<!--- D115462 :: Find the bbUploadDetail record from the user save() that coresponds with the current query loop row from qGetDetailsBeforeSave --->
				<cfloop index = "i" from = "1" to="#ArrayLen(bbh.bbUploadDetail)#">
					<cfif bbh.bbUploadDetail[i].uploadtype eq 2>
						<cfif bbh.bbUploadDetail[i].bbDetailID EQ qGetDetailsBeforeSave.BB_Detail_Sum_ID>
							<cfset bbUploadDetail = bbh.bbUploadDetail[i] />
							<cfbreak>
						</cfif>
					<cfelse>
						<cfif bbh.bbUploadDetail[i].bbDetailID EQ qGetDetailsBeforeSave.BB_Upload_Detail_Error_Correction_ID>
							<cfset bbUploadDetail = bbh.bbUploadDetail[i] />
							<cfbreak>
						</cfif>
					</cfif>
				</cfloop>	<!--- <cfloop index = "i" from = "1" to="#ArrayLen(bbh.bbUploadDetail)#"> --->

				<!--- ************************************************************************************************************************************
						Check to see if the program/item number has changed in the screen, if yes then Check for other corrections with the same update
							* This looks at other "open corrections" that need the same fix.
							* D115462 Mark S
					  ************************************************************************************************************************************ --->
				<cfscript>
					/* 	since all detail rows are submitted, we need to see wich ones were updated in the ui before the user saved :: D115462 Mark S*/
					dataChanged = 0;
					if (bbUploadDetail.contractNumber NEQ qGetDetailsBeforeSave.Contract_ID AND bbUploadDetail.contractNumber NEQ "" AND qGetDetailsBeforeSave.Agreement_Num NEQ ""){
						dataChanged = 1;
					}
					if (bbUploadDetail.item NEQ qGetDetailsBeforeSave.Product_Num AND bbUploadDetail.item NEQ "" AND qGetDetailsBeforeSave.DC_Product_Num NEQ ""){
						dataChanged = 1;
					}
				</cfscript>

				<cfif dataChanged EQ 1>	
					<cfquery name="qGetDtlRecsForPgm" datasource="#application.datasource#">
						SELECT DISTINCT
							    D.BB_Upload_Detail_Error_Correction_ID,
								h.BB_Upload_Header_Error_Correction_ID,
								h.Upload_ID,
								D.Agreement_Num,
								D.Agreement_Name,
								D.Product_Num,
								D.DC_Product_Num,
								D.DC_Product_Desc,
								D.Contract_ID,
								CASE WHEN H.Upload_type = 2 THEN BB_Detail_Sum_ID
				                     ELSE Billback_Upload_III_PD_ID
				                END AS Billback_Upload_III_PD_ID,
								D.Billback_Upload_III_PH_ID,
								D.Err_Msg,
								D.Err_Type,
								d.Discount_Type,
								h.Upload_Type
							FROM BB_Upload_Header_Error_Correction H
							INNER JOIN BB_Upload_Detail_Error_Correction D  ON 
								D.BB_Upload_Header_Error_Correction_ID = H.BB_Upload_Header_Error_Correction_ID
							WHERE 
								H.Deleted = 0 AND 
								H.Processed = 0 AND 
								H.Upload_WIP = 0 AND
								H.Locked = 0 AND
								H.Payee_Type  = '#qGetDetailsBeforeSave.Payee_Type#' AND
								D.Deleted = 0 AND
								D.Vendor_id = '#qGetDetailsBeforeSave.Vendor_ID#' AND
								( (0 = 1) 
								<cfif (bbUploadDetail.contractNumber NEQ qGetDetailsBeforeSave.Contract_ID AND bbUploadDetail.contractNumber NEQ "" AND qGetDetailsBeforeSave.Agreement_Num NEQ "")>
									OR ( D.Agreement_Num = '#qGetDetailsBeforeSave.Agreement_Num#' AND (D.Contract_ID IS NULL OR LEN(D.Contract_ID) = 0))
								</cfif>
								<cfif (bbUploadDetail.item NEQ qGetDetailsBeforeSave.Product_Num AND bbUploadDetail.item NEQ "" AND qGetDetailsBeforeSave.DC_Product_Num NEQ "")>
									OR ( D.DC_Product_Num = '#qGetDetailsBeforeSave.DC_Product_Num#' AND (D.Product_Num IS NULL OR LEN(D.Product_Num) = 0) )
								</cfif>
								)
						</cfquery>
						<cfif (isDefined("qGetDtlRecsForPgm") AND qGetDtlRecsForPgm.RecordCount GTE 1)>
							<!--- Loop over all the records returned for other "open" correction details that need the same update (Agreement_Num or DC_Product_Num) :: D115462 Mark S--->
							<cfloop query="qGetDtlRecsForPgm">
								<cfif (bbUploadDetail.contractNumber NEQ qGetDetailsBeforeSave.Contract_ID AND bbUploadDetail.contractNumber NEQ "")>
									<cfquery name="updUploadDetailPgm" datasource="#application.datasource#">
										UPDATE BB_Upload_Detail_Error_Correction
										SET Contract_ID = '#bbUploadDetail.contractNumber#'
										WHERE	BB_Upload_Detail_Error_Correction_ID = <cfqueryParam cfsqltype="CF_SQL_INTEGER" value="#qGetDtlRecsForPgm.BB_Upload_Detail_Error_Correction_ID#" />AND 
												Agreement_Num = '#qGetDetailsBeforeSave.Agreement_Num#' AND
												(Contract_ID IS NULL OR LEN(Contract_ID) = 0) AND
												Deleted = 0
										
									</cfquery>
									<cfscript>
										if(ListFind(updatedHeaderIdList,qGetDtlRecsForPgm.BB_Upload_Header_Error_Correction_ID) == 0){
											updatedHeaderIdList = ListAppend(updatedHeaderIdList,qGetDtlRecsForPgm.BB_Upload_Header_Error_Correction_ID);
										}
									</cfscript>
								</cfif>
								<cfif (bbUploadDetail.item NEQ qGetDetailsBeforeSave.Product_Num AND bbUploadDetail.item NEQ "")>
									<cfquery name="updUploadDetailPrd" datasource="#application.datasource#">
										UPDATE BB_Upload_Detail_Error_Correction
										SET Product_Num = '#bbUploadDetail.item#'
										WHERE 	BB_Upload_Detail_Error_Correction_ID = <cfqueryParam cfsqltype="CF_SQL_INTEGER" value="#qGetDtlRecsForPgm.BB_Upload_Detail_Error_Correction_ID#" /> AND 
												DC_Product_Num = '#qGetDetailsBeforeSave.DC_Product_Num#' AND
												(Product_Num IS NULL OR LEN(Product_Num) = 0) AND 
												Deleted = 0 
									</cfquery>
									<cfscript>
										if(ListFind(updatedHeaderIdList,qGetDtlRecsForPgm.BB_Upload_Header_Error_Correction_ID) == 0){
											updatedHeaderIdList = ListAppend(updatedHeaderIdList,qGetDtlRecsForPgm.BB_Upload_Header_Error_Correction_ID);
										}
									</cfscript>
								</cfif>
								<!--- 	************************************************************************************************************************
										D115462 Mark S
										If we decide we want to validate updated corrections use updatedHeaderIdList to loop over and validate.  OUTSIDE OF THE CURRENT CFLOOPS
										Even this is a waste until all corrections are fixed...there could be Many detail rows with errors remaining to fix so running the validation may not be worth the overhea
										
										THEN LOOP LIST
											-> Run SP BB_Claim_Upload_Error_Correction_Parser OUTSIDE OF THE CURRENT CFLOOPS!
										************************************************************************************************************************		
								--->
									
									<!--- DO NOT RUN THE PARSER.  THIS NEEDS A NOTIFICATION BUILT TO ANNOUNCE WHAT WAS PROCESSED IF WE GO THIS ROUTE.  
											*****************	ALSO NEEDS TO MOVE OUTSIDE OF THE CURRENT CFLOOPS! 	*****************	--->
									<!--- <cfquery name="UploadTypeDetailsOthers" datasource="#application.datasource#">
										SELECT Upload_Type, Upload_Type_Desc
										FROM BB_upload_log
										WHERE upload_id = <cfqueryParam cfsqltype="CF_SQL_INTEGER" value="#qGetDtlRecsForPgm.Upload_ID#" />
									</cfquery>

									<cfquery name="updUploadHdr" datasource="#application.datasource#">
										UPDATE BB_Upload_Header_Error_Correction 
										SET Processed = 1, Edited = 1
										WHERE BB_Upload_Header_Error_Correction_ID = <cfqueryParam cfsqltype="CF_SQL_INTEGER" value="#qGetDtlRecsForPgm.BB_Upload_Header_Error_Correction_ID#" />
									</cfquery>
								
									<cfstoredproc procedure="BB_Claim_Upload_Error_Correction_Parser" datasource="#application.datasource#">
										<cfprocparam cfsqltype="CF_SQL_TINYINT" value="#UploadTypeDetailsOthers.Upload_Type#" >
										<cfprocparam cfsqltype="CF_SQL_TINYINT" value="#UploadTypeDetailsOthers.Upload_Type_Desc#" >
										<cfprocparam cfsqltype="CF_SQL_INTEGER" value="#qGetDtlRecsForPgm.Upload_ID#" >
										<cfprocparam cfsqltype="CF_SQL_INTEGER" value="#qGetDtlRecsForPgm.BB_Upload_Header_Error_Correction_ID#" >
										<cfprocresult name = "validateResultOthers" />
									</cfstoredProc> --->
						</cfloop>	<!--- END <cfloop query="qGetDtlRecsForPgm"> --->
					</cfif>
				</cfif>
			</cfloop> <!--- <cfloop query="qGetDetailsBeforeSave"> --->
		</cfif>

		<cfif arguments.sAction EQ "2">	
			<!---.....................................................................
			AFTER SAVE WE NEED TO CALL BB_Claim_Upload_Error_Correction_Parser.
			THEN RETURN RESULTS
				IF ANOTHER ERROR, SEND THE NEW ERROR (HEADER) TO CORRECTION SCREEN
				ELSE RETURN AN EMPTY HEADER -> UI WILL KNOW EMPTY HEADER MEANS SUCCESS
			...........................................................................--->
			<cfquery name="UploadTypeDetails" datasource="#application.datasource#">
				SELECT Upload_Type, Upload_Type_Desc
				FROM BB_upload_log
				WHERE upload_id = <cfqueryParam cfsqltype="CF_SQL_INTEGER" value="#bbh.uploadID#" />
			</cfquery>	 	
			<cfstoredproc procedure="BB_Claim_Upload_Error_Correction_Parser" datasource="#application.datasource#">
				<cfprocparam cfsqltype="CF_SQL_TINYINT" value="#UploadTypeDetails.Upload_Type#" >
				<cfprocparam cfsqltype="CF_SQL_TINYINT" value="#UploadTypeDetails.Upload_Type_Desc#" >
				<cfprocparam cfsqltype="CF_SQL_INTEGER" value="#bbh.uploadID#" >
				<cfprocparam cfsqltype="CF_SQL_INTEGER" value="#bbh.bbHeaderID#" >
				<cfprocresult name = "validateResult" />
			</cfstoredProc>
			<cfset bbh = this.getBillbackUploadDetailJSON(argbbUploadHeader = serializeJSON(bbh)) />
		<cfelse>
			<cfscript>
				//SET DETAIL ARRAY SINCE GET HEADER ONLY RETURNS HEADER
				bbh = serializeJson(bbh);
			</cfscript>
		</cfif>
		<!--- //FOR TESTING UNTIL VALIDATION IS RUNNING -> RETURN THE ROW WE INSERTED --->
		<cfreturn bbh />
	</cffunction>
	<!---
		This function will get the header object and detail array within it and update the
		Deleted flag to 1 in the ttables BB_Upload_Header_Error_Correction and BB_Upload_Detail_Error_Correction.
	--->
<cffunction name="deleteUploadHeaderAndDetails" returntype="any" access="remote">
	<cfargument name="bbUploadHeader" type="mvc.Models.Billback.vos.BBUploadHeader" default="">
	<cfif bbUploadHeader.uploadType NEQ '' >
		<cfset qSingleHeaderRow = variables.oBillBackUploadDAO.deleteUploadHeaderAndDetailsDAO(bbUploadHeader = arguments.bbUploadHeader) />
	</cfif>
	<cfset qSingleHeaderRow = variables.oBillBackUploadDAO.deleteUploadHeaderAndDetailsDAO(bbUploadHeader = arguments.bbUploadHeader) />
	<cfset newBBHeader = createObject("component","mvc.Models.Billback.vos.BBUploadHeader").init() />

	<cfreturn  newBBHeader />
</cffunction>

<cffunction name="deleteUploadAndBranches" returntype="any" access="remote">
	<cfargument name="uploadIDList" type="string" default="">
	<cfset qSingleHeaderRow = variables.oBillBackUploadDAO.deleteUploadAndBranchesDAO(uploadIDList = arguments.uploadIDList) />
</cffunction>


<cffunction name="deleteBBUploadDetail" returntype="any" access="remote">
	<cfargument name="bbUploadDetail" type="struct" default="">
	<cfset tmpDelete = variables.oBillBackUploadDAO.deleteDetailRow(bbUploadDetail = arguments.bbUploadDetail) />

	<cfreturn  arguments.bbUploadDetail />
</cffunction>

<cffunction name="deleteCorrectionRecords" returntype="any" access="remote">
	<cfargument name="BBHeaderIDList" type="string" default="">
	<cfset qSingleHeaderRow = variables.oBillBackUploadDAO.deleteCorrectionRecordsDAO(BBHeaderIDList = arguments.BBHeaderIDList) />

	<cfset newBBHeader = createObject("component","mvc.Models.Billback.vos.BBUploadHeader").init() />

	<cfreturn  newBBHeader />

</cffunction>
<!---
	This function expects the Error message in the format:
	<Error_Code><space>?<space><Error_Desc>,<Error_Code><space>?<space><Error_Desc>,
	<space> - one blank space(not <space> tag)
	if this format is not correct then this function will throw an error.
--->

<cffunction name="getHeaderErrorObject" returntype="any" access="remote">
	<cfargument name="ErrorMessage" type="string" default="">
		<cfset arrData = ArrayNew(1) />
		<cfset arrStrippedData = ArrayNew(2) />
		<cfset loopIndex = 1 />
		<cfset var BBHdrErrorObj = createObject("component","mvc.Models.Billback.vos.BBUploadHeaderError").init() />
		<cfif arguments.ErrorMessage NEQ "">
			<cfloop index = "i" list = "#arguments.ErrorMessage#"  delimiters = ",">
				<cfset arrData[loopIndex] = i />
				<cfset loopIndex =  loopIndex + 1 />
			</cfloop>
			<cfloop index = "arrIndex" from = "1" to ="#ArrayLen(arrData)#">
				<cfset totalLen 	= Len(arrData[arrIndex]) />
				<cfset returnLen 	= FindNoCase("?",arrData[arrIndex]) />
				<cfif returnLen>
					<cfset arrStrippedData[arrIndex][1] = Trim(Left(arrData[arrIndex],  (returnLen-1))) />
					<cfset arrStrippedData[arrIndex][2]	= Trim(Right(arrData[arrIndex],  (totalLen-returnLen))) />
				</cfif>

	 		</cfloop>
 			<!--- <cfloop query="qErrorCodes"> --->

			<cfloop index="arrIndex" From="1" to="#ArrayLen(arrStrippedData)#">
				<!--- <cfif qErrorCodes.Error_Code EQ arrStrippedData[arrIndex][1] --->
				<cfswitch expression="#arrStrippedData[arrIndex][1]#">
					<cfcase value="H1">
						<cfset BBHdrErrorObj.vendorId = arrStrippedData[arrIndex][2] />
						<cfset BBHdrErrorObj.vendorName = "" />
					</cfcase>
					<cfcase value="H2">
					<cfset BBHdrErrorObj.BBReference = arrStrippedData[arrIndex][2] />
						<!--- <cfset BBHdrErrorObj.customerReference = arrStrippedData[arrIndex][2] /> --->
					</cfcase>
					<cfcase value="H3">
						<cfset BBHdrErrorObj.BBAmount = arrStrippedData[arrIndex][2] />
						<!--- <cfset BBHdrErrorObj.totalAmount = arrStrippedData[arrIndex][2] /> --->
					</cfcase>
					<!---<cfcase value="H4">
						<cfset BBHdrErrorObj.volumeQty = arrStrippedData[arrIndex][2] />
					</cfcase>
					 <cfcase value="H5">
						<!--- volume UOM --->
					</cfcase> --->
					<cfcase value="H6">
						<!--- <cfset BBHdrErrorObj.payeeType = arrStrippedData[arrIndex][2] /> --->
						<cfset BBHdrErrorObj.vendorId = BBHdrErrorObj.vendorId & ";" & arrStrippedData[arrIndex][2] />
					</cfcase>
					<cfcase value="H7">
						<!--- <cfset BBHdrErrorObj.distributorID = arrStrippedData[arrIndex][2] /> --->
						<cfset BBHdrErrorObj.shipTo = arrStrippedData[arrIndex][2] />
					</cfcase>
					<cfcase value="H8">
						<cfset BBHdrErrorObj.operatorLegacyID = arrStrippedData[arrIndex][2] />
						<!--- <cfset BBHdrErrorObj.operatorID = arrStrippedData[arrIndex][2] /> --->
					</cfcase>
					<!--- <cfcase value="H9">
						<cfset BBHdrErrorObj.billbackTitle = arrStrippedData[arrIndex][2] />
					</cfcase>
					<cfcase value="H10">
						<cfset BBHdrErrorObj.closingMethod = arrStrippedData[arrIndex][2] />
					</cfcase> --->
					<cfcase value="H11">
						<cfset BBHdrErrorObj.BBDate = arrStrippedData[arrIndex][2] />
						<!--- <cfset BBHdrErrorObj.invoiceDate = arrStrippedData[arrIndex][2] /> --->
					</cfcase>
					<!--- 	<cfcase value="H12">
						  <cfset BBHdrErrorObj.receiptDate = arrStrippedData[arrIndex][2] />
					</cfcase> --->
					<cfcase value="H13">
						<cfset BBHdrErrorObj.startDate = arrStrippedData[arrIndex][2] />
					</cfcase>
					<cfcase value="H14">
						<cfset BBHdrErrorObj.endDate = arrStrippedData[arrIndex][2] />
					</cfcase>
					<!--- <cfcase value="H15">
						<cfset BBHdrErrorObj.postmarkDate = arrStrippedData[arrIndex][2] />
					</cfcase>
					<cfcase value="H18">
						<cfset BBHdrErrorObj.referenceNum = arrStrippedData[arrIndex][2] />
					</cfcase> --->
					<cfdefaultcase>
						<cfif  BBHdrErrorObj.others EQ "">
							<cfset BBHdrErrorObj.others = arrStrippedData[arrIndex][2] />
						<cfelse>
							<cfset BBHdrErrorObj.others = BBHdrErrorObj.others & ", " & arrStrippedData[arrIndex][2] />
						</cfif>
					</cfdefaultcase>
				</cfswitch>
			</cfloop>
		</cfif>
	<cfreturn BBHdrErrorObj />

</cffunction>

<cffunction name="getHeaderErrorObjectJSON" returntype="any" access="remote">
	<cfargument name="ErrorMessage" type="string" default="">
		<cfset arrData = ArrayNew(1) />
		<cfset arrStrippedData = ArrayNew(2) />
		<cfset loopIndex = 1 />
		<cfset var BBHdrErrorObj = StructNew()  />  <!--- createObject("component","mvc.Models.Billback.vos.BBUploadHeaderError").init() /> --->
		<cfset BBHdrErrorObj["others"] = '' />
		<cfset BBHdrErrorObj["vendorId"] = ''/>
		<cfif arguments.ErrorMessage NEQ "">
			<cfloop index = "i" list = "#arguments.ErrorMessage#"  delimiters = ",">
				<cfset arrData[loopIndex] = i />
				<cfset loopIndex =  loopIndex + 1 />
			</cfloop>
			<cfloop index = "arrIndex" from = "1" to ="#ArrayLen(arrData)#">
				<cfset totalLen 	= Len(arrData[arrIndex]) />
				<cfset returnLen 	= FindNoCase("?",arrData[arrIndex]) />
				<cfif returnLen>
					<cfset arrStrippedData[arrIndex][1] = Trim(Left(arrData[arrIndex],  (returnLen-1))) />
					<cfset arrStrippedData[arrIndex][2]	= Trim(Right(arrData[arrIndex],  (totalLen-returnLen))) />
				</cfif>

	 		</cfloop>
 			<!--- <cfloop query="qErrorCodes"> --->

			<cfloop index="arrIndex" From="1" to="#ArrayLen(arrStrippedData)#">
				<!--- <cfif qErrorCodes.Error_Code EQ arrStrippedData[arrIndex][1] --->
				<cfswitch expression="#arrStrippedData[arrIndex][1]#">
					<cfcase value="H1">
						<cfset BBHdrErrorObj["vendorId"] = arrStrippedData[arrIndex][2] />
						<cfset BBHdrErrorObj["vendorName"] = "" />
					</cfcase>
					<cfcase value="H2">
					<cfset BBHdrErrorObj["BBReference"] = arrStrippedData[arrIndex][2] />
						<!--- <cfset BBHdrErrorObj.customerReference = arrStrippedData[arrIndex][2] /> --->
					</cfcase>
					<cfcase value="H3">
						<cfset BBHdrErrorObj["BBAmount"] = arrStrippedData[arrIndex][2] />
						<!--- <cfset BBHdrErrorObj.totalAmount = arrStrippedData[arrIndex][2] /> --->
					</cfcase>
					<!---<cfcase value="H4">
						<cfset BBHdrErrorObj.volumeQty = arrStrippedData[arrIndex][2] />
					</cfcase>
					 <cfcase value="H5">
						<!--- volume UOM --->
					</cfcase> --->
					<cfcase value="H6">
						<!--- <cfset BBHdrErrorObj.payeeType = arrStrippedData[arrIndex][2] /> --->
						<cfset BBHdrErrorObj["vendorId"] = BBHdrErrorObj.vendorId & ";" & arrStrippedData[arrIndex][2] />
					</cfcase>
					<cfcase value="H7">
						<!--- <cfset BBHdrErrorObj.distributorID = arrStrippedData[arrIndex][2] /> --->
						<cfset BBHdrErrorObj["shipTo"] = arrStrippedData[arrIndex][2] />
					</cfcase>
					<cfcase value="H8">
						<cfset BBHdrErrorObj["operatorLegacyID"] = arrStrippedData[arrIndex][2] />
						<!--- <cfset BBHdrErrorObj.operatorID = arrStrippedData[arrIndex][2] /> --->
					</cfcase>
					<!--- <cfcase value="H9">
						<cfset BBHdrErrorObj["billbackTitle = arrStrippedData[arrIndex][2] />
					</cfcase>
					<cfcase value="H10">
						<cfset BBHdrErrorObj["closingMethod = arrStrippedData[arrIndex][2] />
					</cfcase> --->
					<cfcase value="H11">
						<cfset BBHdrErrorObj["BBDate"] = arrStrippedData[arrIndex][2] />
						<!--- <cfset BBHdrErrorObj.invoiceDate = arrStrippedData[arrIndex][2] /> --->
					</cfcase>
					<!--- 	<cfcase value="H12">
						  <cfset BBHdrErrorObj.receiptDate = arrStrippedData[arrIndex][2] />
					</cfcase> --->
					<cfcase value="H13">
						<cfset BBHdrErrorObj["startDate"] = arrStrippedData[arrIndex][2] />
					</cfcase>
					<cfcase value="H14">
						<cfset BBHdrErrorObj["endDate"] = arrStrippedData[arrIndex][2] />
					</cfcase>
					<!--- <cfcase value="H15">
						<cfset BBHdrErrorObj.postmarkDate = arrStrippedData[arrIndex][2] />
					</cfcase>
					<cfcase value="H18">
						<cfset BBHdrErrorObj.referenceNum = arrStrippedData[arrIndex][2] />
					</cfcase> --->
					<cfdefaultcase>
						<cfif  BBHdrErrorObj.others EQ "">
							<cfset BBHdrErrorObj["others"] = arrStrippedData[arrIndex][2] />
						<cfelse>
							<cfset BBHdrErrorObj["others"] = BBHdrErrorObj.others & ", " & arrStrippedData[arrIndex][2] />
						</cfif>
					</cfdefaultcase>
				</cfswitch>
			</cfloop>
		</cfif>
	<cfreturn BBHdrErrorObj />

</cffunction>



<!---
	This function expects the Error message in the format:
	<Error_Code><space>?<space><Error_Desc>,<Error_Code><space>?<space><Error_Desc>,
	if this format is not correct then this function will throw an error.
--->
<cffunction name="getDetailErrorObject" returntype="any" access="remote">
	<cfargument name="ErrorMessage" type="string" default="">

	<cfset arrDetData = ArrayNew(1) />
	<cfset arrStrippedDetData = ArrayNew(2) />
	<cfset loopIndex = 1 />
	<cfscript>
		BBDtlErrorObj = structNew();
		BBDtlErrorObj["__type__"] = "mvc.Models.Billback.vos.BBUploadDetailError";
		BBDtlErrorObj["shipTo"] 				= "";
		BBDtlErrorObj["dupShipTo"]				= "";
		BBDtlErrorObj["custNumber"] 			= "";
		BBDtlErrorObj["custName"] 				= "";
		BBDtlErrorObj["operatorLegacyId"] 		= "";
		BBDtlErrorObj["custContractNumber"] 	= "";
		BBDtlErrorObj["custContractDescription"] = "";
		BBDtlErrorObj["operatorId"] 			= "";
		BBDtlErrorObj["operatorName"] 			= "";
		BBDtlErrorObj["operatorAddress1"] 		= "";
		BBDtlErrorObj["operatorAddress2"] 		= "";
		BBDtlErrorObj["operatorCity"] 			= "";
		BBDtlErrorObj["operatorState"] 			= "";
		BBDtlErrorObj["operatorZip"] 			= "";
		BBDtlErrorObj["item"] 					= "";
		BBDtlErrorObj["custItem"] 				= "";
		BBDtlErrorObj["custItemDescription"] 	= "";
		BBDtlErrorObj["BBProductQuantity"] 		= "";
		BBDtlErrorObj["caseRate"] 				= "";
		BBDtlErrorObj["BBRate"] 				= "";
		BBDtlErrorObj["contractNumber"] 		= "";
		BBDtlErrorObj["contractTitle"] 			= "";
		BBDtlErrorObj["others"] 				= "";
		BBDtlErrorObj["DiscountType"]			= "";
	</cfscript>
	<!---<cfset var BBDtlErrorObj = createObject("component","mvc.Models.Billback.vos.BBUploadDetailError").init() />--->
	<cfif arguments.ErrorMessage NEQ "">
		<cfloop index = "i" list = "#arguments.ErrorMessage#"  delimiters = ",">
			<cfset arrDetData[loopIndex] = i />
			<cfset loopIndex =  loopIndex + 1 />
		</cfloop>
		<cfloop index = "arrIndex" from = "1" to ="#ArrayLen(arrDetData)#">
			<cfset totalLen 	= Len(arrDetData[arrIndex]) />
			<cfset returnLen 	= FindNoCase("?",arrDetData[arrIndex]) />
			<cfif returnLen>
				<cfset arrStrippedDetData[arrIndex][1] = Trim(Left(arrDetData[arrIndex],  (returnLen-1))) />
		 		<cfset arrStrippedDetData[arrIndex][2]	= Trim(Right(arrDetData[arrIndex],  (totalLen-returnLen))) />
			</cfif>
		</cfloop>

		<cfloop index="arrIndex" From="1" to="#ArrayLen(arrStrippedDetData)#">
			<!--- <cfif qErrorCodes.Error_Code EQ arrStrippedData[arrIndex][1] --->
			<cfswitch expression="#arrStrippedDetData[arrIndex][1]#">
				<!---
				<cfcase value="D1">
					<cfset BBDtlErrorObj.vendor = arrStrippedDetData[arrIndex][2] />
				</cfcase>
				<cfcase value="D2">
					<cfset BBDtlErrorObj.customerReference = arrStrippedDetData[arrIndex][2] />
				</cfcase>
				--->
				<cfcase value="D4">
					<cfset BBDtlErrorObj.item = arrStrippedDetData[arrIndex][2] />
					<!--- <cfset BBDtlErrorObj.itemNumber = arrStrippedDetData[arrIndex][2] /> --->
				</cfcase>
				<cfcase value="D5">
					<cfset BBDtlErrorObj.contractNumber = arrStrippedDetData[arrIndex][2] />
					<!--- <cfset BBDtlErrorObj.programNumber = arrStrippedDetData[arrIndex][2] /> --->
				</cfcase>
				<cfcase value="D6">
					<cfset BBDtlErrorObj.BBProductQuantity = arrStrippedDetData[arrIndex][2] />
					<!--- <cfset BBDtlErrorObj.itemVolQty = arrStrippedDetData[arrIndex][2] /> --->
				</cfcase>
				<cfcase value="D8">
					<cfset BBDtlErrorObj.BBRate = arrStrippedDetData[arrIndex][2] />
					<!--- <cfset BBDtlErrorObj.itemAmount = arrStrippedDetData[arrIndex][2] /> --->
				</cfcase>
				<cfcase value="D13">
					<cfset BBDtlErrorObj.dupShipTo = arrStrippedDetData[arrIndex][2] />
				</cfcase>
				<!---
				<cfcase value="D9">
					<cfset BBDtlErrorObj.discountType = arrStrippedDetData[arrIndex][2] />
				</cfcase>
				<cfcase value="D10">
					<cfset BBDtlErrorObj.componentName = arrStrippedDetData[arrIndex][2] />
				</cfcase>
				<cfcase value="D13">
					<cfset BBDtlErrorObj.shipTo = arrStrippedDetData[arrIndex][2] />
					<cfset BBDtlErrorObj.distributorID = arrStrippedDetData[arrIndex][2] />
				</cfcase>
				--->
				<cfdefaultcase>
					<cfif BBDtlErrorObj.others EQ "">
						<cfset BBDtlErrorObj.others = arrStrippedDetData[arrIndex][2] />
					<cfelse>
						<cfset BBDtlErrorObj.others = BBDtlErrorObj.others & ", " & arrStrippedDetData[arrIndex][2] />
					</cfif>
				</cfdefaultcase>
			</cfswitch>
		</cfloop>
	</cfif>
	
	<cfreturn BBDtlErrorObj />
	</cffunction>

	<!---
		This function expects just one parameter: Upload_ID and will return all the
		Headers in that particular upload along with the Details object embedded into it.
	--->
	<cffunction name="getMultipleHeaderRows" returntype="Array" access="remote">
		<!--- <cfargument name="uploadType" type="numeric" required="true"> --->
		<cfargument name="uploadID" type="numeric" required="true">
		<!--- <cfargument name="tblChosen"  type="string" required="false" default="errorCorrection"> --->

		<cfset qGetUploadHeaderSet = variables.oBillBackUploadDAO.getHeaderSummary(uploadID=arguments.uploadID) />
		<cfset BBMultipHdrArr = ArrayNew(1)/>

		<cfloop query = "qGetUploadHeaderSet">
			<cfset BBSingleHdrObj = createObject("component","mvc.Models.Billback.vos.BBUploadHeader").init() />
			<cfset BBSingleHdrObj = this.getOneHeaderRow(uploadID=arguments.uploadID, BBUploadHeaderErrorCorrectionID = qGetUploadHeaderSet.BB_Upload_Header_Error_Correction_ID) />
			<cfset BBSingleHdrObj = this.getBillbackUploadDetail(argbbUploadHeader=BBSingleHdrObj) />
			<cfset arrayAppend(BBMultipHdrArr,BBSingleHdrObj) />
		</cfloop>

		<cfreturn BBMultipHdrArr />
	</cffunction>

	<!---
		This function expects two parameters: month and year. Passes it to the
		DAO function and gets the Upload information.
	--->

	<cffunction name="getBBUploadLogHistory" returntype="Struct" access="remote">
		<cfargument name="argStart" default="#dateAdd('m',-18,now())#" required="false">
		<cfargument name="argEnd" default="#now()#" required="false">

<!--- 		<cfset BBHdrObj 	= createObject("component","mvc.Models.Billback.vos.BBUploadHeader").init() />
		<cfset BBDtlObj 	= createObject("component","mvc.Models.Billback.vos.BBUploadDetail").init() />
 --->
		<cfset var userUploaded = createObject("component","mvc.Models.Entity.vos.User").init() />
 		<cfset bbUploadLogArr = ArrayNew(1) />
		<cfset stReturnData = StructNew()>

		<cfset qBBUploadLogData = variables.oBillBackUploadDAO.getUploadHistory(argStart = arguments.argStart, argEnd = arguments.argEnd) /> <!--- , getCompleteHistory = 1 --->
		<cfset qRefreshTime = variables.oBillBackUploadDAO.getBBUploadLastUserRefreshDate() />

		<!--- last refresh date/time --->
		<cfset stReturnData.refreshTime = qRefreshTime.Updated_Date>

		<!---
			Loop through the qBBUploadLogData query and set the BBUploadLogObj object.
		--->
		<cfloop query = "qBBUploadLogData">
			<cfset BBUploadLogObj	= createObject("component","mvc.Models.Billback.vos.BBUploadLog").init() />
			<cfset userObj = createObject("component","mvc.Models.Entity.vos.User").init() />

			<cfset userObj.id = qBBUploadLogData.user_id />
			<cfset userObj.fullName = '#qBBUploadLogData.Name_First# #qBBUploadLogData.Name_Last#' />

			<cfset BBUploadLogObj.uploadID 				 = qBBUploadLogData.upload_id />
			<cfset BBUploadLogObj.userUploaded			 = userObj />
			<cfset BBUploadLogObj.totalHeaderCount 		 = qBBUploadLogData.total_header_count />
			<cfset BBUploadLogObj.totalHeaderCountFailed = qBBUploadLogData.total_header_count_failed />
			<cfset BBUploadLogObj.totalHeaderCountLoaded = qBBUploadLogData.total_header_count_loaded />
			<cfset BBUploadLogObj.totalDetailCount 		 = qBBUploadLogData.total_detail_count />
			<cfset BBUploadLogObj.totalDetailCountFailed = qBBUploadLogData.total_detail_count_failed />
			<cfset BBUploadLogObj.totalDetailCountLoaded = qBBUploadLogData.total_detail_count_loaded />
			<cfset BBUploadLogObj.uploadDate 			 = qBBUploadLogData.upload_date />
			<cfset BBUploadLogObj.uploadStatus 			 = qBBUploadLogData.upload_status />
			<cfset BBUploadLogObj.deleted 				 = qBBUploadLogData.deleted />
			<cfset BBUploadLogObj.headerFileName 		 = qBBUploadLogData.header_file_name />
			<cfset BBUploadLogObj.detailFileName 		 = qBBUploadLogData.detail_file_name />
			<cfset BBUploadLogObj.deletedBy 			 = qBBUploadLogData.deleted_by />
			<cfset BBUploadLogObj.deletedDate			 = qBBUploadLogData.deleted_date />
			<cfset BBUploadLogObj.uploadType			 = qBBUploadLogData.upload_type />
			<cfset BBUploadLogObj.VendorSearchField		 = qBBUploadLogData.VendorSearchField />
			<cfset BBUploadLogObj.BBTitleSearchField	 = qBBUploadLogData.BBTitleSearchField />
			<cfset BBUploadLogObj.BBCodeSearchField		 = qBBUploadLogData.BBCodeSearchField />


			<!--- TODO: Check if the below line is required. Required if he can pick the upload ID and view what records were created by it --->
			<!--- <cfset BBUploadLogObj.bbUploadHeaderErrCorn  = this.getMultipleHeaderRows(uploadID = qBBUploadLogData.upload_id) /> --->

			<cfset arrayAppend(bbUploadLogArr, BBUploadLogObj) />
		</cfloop>

		<!--- data --->
		<cfset stReturnData.bbArr = bbUploadLogArr>

		<cfreturn stReturnData />
	</cffunction>

	<!---
		This function will receive the complete path along with the file name to be
		extracted, check the type of file and then call the appropriate function
		to read and extract the content and write it to a temp table.
	--->

	<cffunction name="FileReadDiverter" access="public" output="false" returntype="array" hint="Changes the column name of the given query.">
		<cfargument name="theFile" default="" type="string" required="true" hint="Path with FileName" >
		<cfargument name="ulFileName" default="" type="string" required="true" hint="FileName" >
		<cfscript>
			var arrResult	=	ArrayNew(1);
			var errorMsg	=	'';
			var strFileName = arguments.theFile;
			var strFileNameExt = listLast(strFileName, '.');
			if((strFileNameExt EQ "xls") OR (strFileNameExt EQ "xlsx")){
				arrResult = this.ExcelFileReadAndExtract(arguments.theFile,arguments.ulFileName);
			}
			else if((strFileNameExt EQ "csv") OR (strFileNameExt EQ "txt")){
				arrResult = this.CSVFileReadAndExtract(arguments.theFile,arguments.ulFileName);
			}
			else{
				//string is used below on line 1125
				arrResult[1] = 'Invalid File Type';
			}
			return arrResult;
		</cfscript>
	 </cffunction>

<!---
	This function will take the file path along with and file name as argument
	Read the file grab the data and populate the temp table #BB_Claim_Single_File_BLK_INS
--->
<cffunction name="ExcelFileReadAndExtract" access="public" output="false" returntype="array" hint="Changes the column name of the given query.">
	<cfargument name="theFile" default="" type="string" required="true" >
	<cfargument name="ulFileName" default="" type="string" required="true" hint="uploaded FileName" >
	<!--- 	<cfset theFile = "#Application.Doc_Path#\Data_Files\Settings\Billback_Upload_Files\GM_Sample_small_2.xlsx" />   --->
	<!--- <cfset theFile = "#Application.Doc_Path#\Data_Files\Settings\Billback_Upload_Files\GM_Sample.xlsx" /> --->
 	 <cfscript>
		var arrResult	=	ArrayNew(1);
		var errorMsg	=	'';
		var info 		= '';
		var sheetList	 = '';
		var sheetListLen = '';
	</cfscript>

	<!---  "theFile" variable will have the complete path along with the file name to be extracted --->
	<cfspreadsheet action="read" src="#arguments.theFile#" name="SpreadsheetObj" rows="0"/>
		<cfset info = SpreadSheetInfo(SpreadsheetObj)>
		<cfset sheetList = info.SheetNames />
		<cfset sheetListLen = listLen(sheetList) />
		<cfquery name="Dump_Data_To_Table" datasource="#application.datasource#">
			IF object_id('tempdb..##BB_Claim_Single_File_BLK_INS') IS NOT NULL
			BEGIN
				DROP TABLE ##BB_Claim_Single_File_BLK_INS
			END

		  CREATE TABLE ##BB_Claim_Single_File_BLK_INS(
		  [Billback_Title] [varchar](max),
	 	  [Company_Code] [varchar](max),
		  [Payee_Number] [varchar](max),
		  [Payee_Name] [varchar](max),
		  [Customer_Invoice_Number] [varchar](max),
		  [Performance_Period_Start_Date] [varchar](max),
		  [Performance_Period_End_Date] [varchar](max),
		  [Invoice_Date] [varchar](max),
		  [Expected_Payment_Amount] [varchar](max),
		  [SAP_Distributor_Number] [varchar](max),
		  [Customer_Distributor_Code] [varchar](max),
		  [Customer_Distributor_Name] [varchar](max),
		  [Customer_Distributor_Address] [varchar](max),
		  [Customer_Distributor_City] [varchar](max),
		  [Customer_Distributor_State] [varchar](max),
		  [Customer_Distributor_Zip] [varchar](max),
		  [Customer_Promotion_Code] [varchar](max),
		  [Customer_Promotion_Description] [varchar](max),
		  [GMI_Bid_Number] [varchar](max),
		  [GMI_Promotion_Number] [varchar](max),
		  [Payment_Type_Code_BD_VR] [varchar](max),
		  [SAP_Promoted_Customer_Number] [varchar](max),
		  [Customer_GMI_Product_Code] [varchar](max),
		  [GMI_UPC_Code] [varchar](max),
		  [GMI_Base_Product_Code] [varchar](max),
		  [Customer_Product_Code] [varchar](max),
		  [Customer_Product_Description] [varchar](max),
		  [Unit_of_Measure] [varchar](max),
		  [Invoice_Quantity]  [varchar](max),
		  [Customer_Case_Rate] [varchar](max),
		  [Customer_Payment_Amount]  [varchar](max),
		  [Operator_Unit_ID]  [varchar](max),
		  [Operator_Unit_Name]  [varchar](max),
		  [Operator_Unit_Address_Line_1]  [varchar](max),
		  [Operator_Unit_Address_Line_2]  [varchar](max),
		  [Operator_Unit_City]  [varchar](max),
		  [Operator_Unit_State]  [varchar](max),
		  [Operator_Unit_Zip_Code]  [varchar](max),
		  [Uploaded_User_ID] [varchar](50),
		  [Sheet_Name] [varchar](255),
		  [Upload_File_Name] [varchar](255)
		  )
	 	  </cfquery>

		<cfloop from="1" to="#sheetListLen#" index="i">
			<!--- <cfset spreadSheetObj = SpreadSheetRead(arguments.theFile,ListGetAt(sheetList,i)) /> --->
			<cfset SheetName = ListGetAt(sheetList,i) />
			<!---<cfspreadsheet action="read"   src="#arguments.theFile#" sheet="#i#" query="InitialRead" />--->
	 		<cftry>
			 	<cfspreadsheet action="read"   src="#arguments.theFile#" sheet="#i#" query="excelQuery" headerrow="1"  />
				<cfcatch>
					<cfset excelQuery = QueryNew('col1')/>
				</cfcatch>
			</cftry>
			<cfif excelQuery.RecordCount EQ 0>
				<cfset errorMsg =  "#SheetName#: Excluded No Data" />
				<cfset ArrayAppend(arrResult,errorMsg) />
				<CFContinue />
			</cfif>
	 	 	<!--- <cfset SheetName = spreadSheetObj.SheetName /> --->
			<cfif SheetName EQ "">
				<cfset SheetName = "NULL" />
			</cfif>

			<cfset columnListLen = listLen(excelQuery.ColumnList) />
			<cfloop index = "colName"  list = "#excelQuery.ColumnList#">
				<cfset newColumnName = Replace(Replace(Replace(Replace(Replace(Trim(colName)," ","_","ALL"),"/","_","ALL"),"(","_","ALL"),")","_","ALL"),"##","_","ALL") />
				<cfset excelQuery =	this.QueryChangeColumnName(excelQuery,"#colName#","#newColumnName#") />
			</cfloop>
			<!---
				TODO: Need a checking to make sure the columns were generated properly the code would fail,
				if there is no header row in the file from the user.
			--->
				<cfif NOT(isDefined("excelQuery.Company_Code") AND
						  isDefined("excelQuery.Payee_Number") AND
						  isDefined("excelQuery.Payee_Name") AND
					  	  isDefined("excelQuery.Performance_Period_Start_Date_xx_xx_xxxx") AND
						  isDefined("excelQuery.Performance_Period_End_Date_xx_xx_xxxx") AND
						  isDefined("excelQuery.Invoice_Date_xx_xx_xxxx") AND
						  isDefined("excelQuery.Expected_Payment_Amount") AND
					  	  isDefined("excelQuery.Customer_Distributor_Address_Line_1") AND
						  isDefined("excelQuery.Customer_Distributor_City") AND
						  isDefined("excelQuery.Customer_Distributor_State") AND
						  isDefined("excelQuery.Customer_Distributor_Zip") AND
						  isDefined("excelQuery.Payment_Type_Code__BD_VR_") AND
						  isDefined("excelQuery.Unit_of_Measure") AND
						  isDefined("excelQuery.Customer_Case_Rate") AND
						  isDefined("excelQuery.Customer_Payment_Amount") AND
						 <!---  isDefined("excelQuery.Operator_Unit_ID") AND
						  isDefined("excelQuery.Operator_Unit_Name") AND
						  isDefined("excelQuery.Operator_Unit_Address_Line_1") AND
						  isDefined("excelQuery.Operator_Unit_Address_Line_2") AND
						  isDefined("excelQuery.Operator_Unit_City") AND
						  isDefined("excelQuery.Operator_Unit_State") AND
						  isDefined("excelQuery.Operator_Unit_Zip_Code") AND --->
						  isDefined("excelQuery.SAP_Distributor_Number") AND
					 	  isDefined("excelQuery.Customer_Invoice_Number") AND
			 			  isDefined("excelQuery.Customer_Distributor_Code") AND
			 			  isDefined("excelQuery.Customer_Distributor_Name") AND
			 			  isDefined("excelQuery.SAP_Promoted_Customer") AND
			 			  isDefined("excelQuery.Customer_Promotion_Code") AND
			 			  isDefined("excelQuery.Customer_Promotion_Description") AND
			 			  isDefined("excelQuery.Customer_GMI_Product_Code") AND
			 			  isDefined("excelQuery.Customer_Product_Code") AND
			 			  isDefined("excelQuery.Customer_Product_Description") AND
			 			  isDefined("excelQuery.Invoice_Quantity") AND
			 			  isDefined("excelQuery.GMI_Bid_Number") AND
			 			  isDefined("excelQuery.GMI_Promotion_Number")
						)>
						<cfset errorMsg =  "#SheetName#: Excluded Missing Field" />
						<cfset ArrayAppend(arrResult,errorMsg) />
						<CFContinue />
				</cfif>


			<cfif excelQuery.RecordCount GTE 2>
			<!--- Start at row 2 as the first row is the header --->
	 		<cfloop query="excelQuery" startRow="2">
				<!--- Check to see atleast one column has a value to make sure it is not a empty row --->
				<cfif excelQuery.SAP_Distributor_Number NEQ "" OR
					excelQuery.Customer_Invoice_Number NEQ "" OR
				  	excelQuery.Customer_Distributor_Code NEQ "" OR
				  	excelQuery.Customer_Distributor_Name NEQ "" OR
					excelQuery.SAP_Promoted_Customer NEQ "" OR
					excelQuery.Customer_Promotion_Code NEQ "" OR
					excelQuery.Customer_Promotion_Description NEQ "" OR
					excelQuery.Customer_GMI_Product_Code NEQ "" OR
					excelQuery.Customer_Product_Code NEQ "" OR
					excelQuery.Customer_Product_Description NEQ "" OR
					excelQuery.Invoice_Quantity NEQ "" OR
					excelQuery.GMI_Bid_Number NEQ "" OR
					excelQuery.GMI_Promotion_Number NEQ "">

				  <cfif isDefined("excelQuery.Operator_Unit_ID")>
				  	<cfset operatorUnitID =  excelQuery.Operator_Unit_ID />
				  <cfelse>
				  	<cfset operatorUnitID = "" />
				  </cfif>
				  <cfif isDefined("excelQuery.Operator_Unit_Name")>
				  	<cfset operatorUnitName =  excelQuery.Operator_Unit_Name />
				  <cfelse>
				  	<cfset operatorUnitName = "" />
				  </cfif>
				  <cfif isDefined("excelQuery.Operator_Unit_Address_Line_1")>
				  	<cfset operatorUnitAddressLine1 =  excelQuery.Operator_Unit_Address_Line_1 />
				  <cfelse>
				  	<cfset operatorUnitAddressLine1 = "" />
				  </cfif>
				  <cfif isDefined("excelQuery.Operator_Unit_Address_Line_2")>
				  	<cfset operatorUnitAddressLine2 =  excelQuery.Operator_Unit_Address_Line_2 />
				  <cfelse>
				  	<cfset operatorUnitAddressLine2 = "" />
				  </cfif>
				  <cfif isDefined("excelQuery.Operator_Unit_City")>
				  	<cfset operatorUnitCity =  excelQuery.Operator_Unit_City />
				  <cfelse>
				  	<cfset operatorUnitCity = "" />
				  </cfif>
				  <cfif isDefined("excelQuery.Operator_Unit_State")>
				  	<cfset operatorUnitState =  excelQuery.Operator_Unit_State />
				  <cfelse>
				  	<cfset operatorUnitState = "" />
				  </cfif>
				  <cfif isDefined("excelQuery.Operator_Unit_Zip_Code")>
				  	<cfset operatorUnitZipCode =  excelQuery.Operator_Unit_Zip_Code />
				  <cfelse>
				  	<cfset operatorUnitZipCode = "" />
				  </cfif>
				  <cfif isDefined("excelQuery.Billback_Title")>
				  	<cfset BillbackTitle =  excelQuery.Billback_Title />
				  <cfelse>
				  	<cfset BillbackTitle = "" />
				  </cfif>

				<cfquery name="Dump_Data_To_Table" datasource="#application.datasource#">
					INSERT INTO ##BB_Claim_Single_File_BLK_INS
					VALUES
						(
						'#BillbackTitle#',
						'#excelQuery.Company_Code#',
						'#excelQuery.Payee_Number#',
						'#excelQuery.Payee_Name#',
						'#excelQuery.Customer_Invoice_Number#',
						'#excelQuery.Performance_Period_Start_Date_xx_xx_xxxx#',
						'#excelQuery.Performance_Period_End_Date_xx_xx_xxxx#',
						'#excelQuery.Invoice_Date_xx_xx_xxxx#',
						'#excelQuery.Expected_Payment_Amount#',
						'#excelQuery.SAP_Distributor_Number#',
						'#excelQuery.Customer_Distributor_Code#',
						'#excelQuery.Customer_Distributor_Name#',
						'#excelQuery.Customer_Distributor_Address_Line_1#',
						'#excelQuery.Customer_Distributor_City#',
						'#excelQuery.Customer_Distributor_State#',
						'#excelQuery.Customer_Distributor_Zip#',
						'#excelQuery.Customer_Promotion_Code#',
						'#excelQuery.Customer_Promotion_Description#',
						'#excelQuery.GMI_Bid_Number#',
						'#excelQuery.GMI_Promotion_Number#',
						'#excelQuery.Payment_Type_Code__BD_VR_#',
						'#excelQuery.SAP_Promoted_Customer#',
						'#excelQuery.Customer_GMI_Product_Code#',
						'#excelQuery.GMI_UPC_Code#',
						'#excelQuery.GMI_Base_Product_Code#',
						'#excelQuery.Customer_Product_Code#',
						'#excelQuery.Customer_Product_Description#',
						'#excelQuery.Unit_of_Measure#',
						'#excelQuery.Invoice_Quantity#',
						'#excelQuery.Customer_Case_Rate#',
						'#excelQuery.Customer_Payment_Amount#',
						'#operatorUnitID#',
						'#operatorUnitName#',
						'#operatorUnitAddressLine1#',
						'#operatorUnitAddressLine2#',
						'#operatorUnitCity#',
						'#operatorUnitState#',
						'#operatorUnitZipCode#',
						'#request.AccessStructure.User_ID#',
						'#SheetName#',
						'#ulFileName#'
						)
					 </cfquery>
					 <!---********************* PHYSICAL TABLE INSERT FOR TESTING PURPOSE ONLY ************* --->
				<!--- <cfquery name="Dump_Data_To_Table" datasource="#application.datasource#">
					INSERT INTO BB_Claim_Single_File_BLK_INS_TestCases
					VALUES
						(
						'#BillbackTitle#',
						'#excelQuery.Company_Code#',
						'#excelQuery.Payee_Number#',
						'#excelQuery.Payee_Name#',
						'#excelQuery.Customer_Invoice_Number#',
						'#excelQuery.Performance_Period_Start_Date_xx_xx_xxxx#',
						'#excelQuery.Performance_Period_End_Date_xx_xx_xxxx#',
						'#excelQuery.Invoice_Date_xx_xx_xxxx#',
						'#excelQuery.Expected_Payment_Amount#',
						'#excelQuery.SAP_Distributor_Number#',
						'#excelQuery.Customer_Distributor_Code#',
						'#excelQuery.Customer_Distributor_Name#',
						'#excelQuery.Customer_Distributor_Address_Line_1#',
						'#excelQuery.Customer_Distributor_City#',
						'#excelQuery.Customer_Distributor_State#',
						'#excelQuery.Customer_Distributor_Zip#',
						'#excelQuery.Customer_Promotion_Code#',
						'#excelQuery.Customer_Promotion_Description#',
						'#excelQuery.GMI_Bid_Number#',
						'#excelQuery.GMI_Promotion_Number#',
						'#excelQuery.Payment_Type_Code__BD_VR_#',
						'#excelQuery.SAP_Promoted_Customer#',
						'#excelQuery.Customer_GMI_Product_Code#',
						'#excelQuery.GMI_UPC_Code#',
						'#excelQuery.GMI_Base_Product_Code#',
						'#excelQuery.Customer_Product_Code#',
						'#excelQuery.Customer_Product_Description#',
						'#excelQuery.Unit_of_Measure#',
						'#excelQuery.Invoice_Quantity#',
						'#excelQuery.Customer_Case_Rate#',
						'#excelQuery.Customer_Payment_Amount#',
						'#operatorUnitID#',
						'#operatorUnitName#',
						'#operatorUnitAddressLine1#',
						'#operatorUnitAddressLine2#',
						'#operatorUnitCity#',
						'#operatorUnitState#',
						'#operatorUnitZipCode#',
						'#request.AccessStructure.User_ID#',
						'#SheetName#',
						'#ulFileName#'
						)
					 </cfquery>	 --->
					 <cfelse>
					 	 <cfset errorMsg =  "#SheetName#: Excluded Empty Row" />
						 <cfset ArrayAppend(arrResult,errorMsg) />
					</cfif>
				</cfloop><!--- END:  <cfloop from="2"  to="#excelQuery.RecordCount#" index="k"> --->
				 <cfset errorMsg =  "#SheetName#: Parsed" />
				 <cfset ArrayAppend(arrResult,errorMsg) />
			<cfelse>
				<cfset errorMsg =  "#SheetName#: Excluded Header Row Only" />
				<cfset ArrayAppend(arrResult,errorMsg) />
			</cfif>
		</cfloop>
		<!---
			TODO: More code to come here based on input from Priya, once
			we know what SP is going to handle the temp table and insert the
			data into the corresponding tables for error correction.
		--->
		<cfreturn arrResult />
</cffunction>


<cffunction name="CSVFileReadAndExtract" access="public" output="false" returntype="any" hint="Changes the column name of the given query.">
	<cfargument name="theFile" default="" type="string" required="true">
	<cfargument name="ulFileName" default="" type="string" required="true" hint="Uploaded FileName">

	<cffile action = "read" file = "#theFile#" variable = "fileContent">
	<cfset fileContentQuery = this.csvToQuery(fileContent) />
	<cfset errorMsg = ""/>
		<!---
			TODO: More code to come here based on input from Priya, once
			we know what SP is going to handle the temp table and insert the
			data into the corresponding tables for error correction.
		--->
	
	<cfquery name="Dump_Data_To_Table" datasource="#application.datasource#">
	 	 	IF object_id('tempdb..##BB_Claim_Single_File_BLK_INS') IS NOT NULL
			BEGIN
				DROP TABLE ##BB_Claim_Single_File_BLK_INS
			END

		  CREATE TABLE ##BB_Claim_Single_File_BLK_INS(
		  [Billback_Title] [varchar](max),
	 	  [Company_Code] [varchar](max),
		  [Payee_Number] [varchar](max),
		  [Payee_Name] [varchar](max),
		  [Customer_Invoice_Number] [varchar](max),
		  [Performance_Period_Start_Date] [varchar](max),
		  [Performance_Period_End_Date] [varchar](max),
		  [Invoice_Date] [varchar](max),
		  [Expected_Payment_Amount] [varchar](max),
		  [SAP_Distributor_Number] [varchar](max),
		  [Customer_Distributor_Code] [varchar](max),
		  [Customer_Distributor_Name] [varchar](max),
		  [Customer_Distributor_Address] [varchar](max),
		  [Customer_Distributor_City] [varchar](max),
		  [Customer_Distributor_State] [varchar](max),
		  [Customer_Distributor_Zip] [varchar](max),
		  [Customer_Promotion_Code] [varchar](max),
		  [Customer_Promotion_Description] [varchar](max),
		  [GMI_Bid_Number] [varchar](max),
		  [GMI_Promotion_Number] [varchar](max),
		  [Payment_Type_Code_BD_VR] [varchar](max),
		  [SAP_Promoted_Customer_Number] [varchar](max),
		  [Customer_GMI_Product_Code] [varchar](max),
		  [GMI_UPC_Code] [varchar](max),
		  [GMI_Base_Product_Code] [varchar](max),
		  [Customer_Product_Code] [varchar](max),
		  [Customer_Product_Description] [varchar](max),
		  [Unit_of_Measure] [varchar](max),
		  [Invoice_Quantity]  [varchar](max),
		  [Customer_Case_Rate] [varchar](max),
		  [Customer_Payment_Amount]  [varchar](max),
		  [Operator_Unit_ID]  [varchar](max),
		  [Operator_Unit_Name]  [varchar](max),
		  [Operator_Unit_Address_Line_1]  [varchar](max),
		  [Operator_Unit_Address_Line_2]  [varchar](max),
		  [Operator_Unit_City]  [varchar](max),
		  [Operator_Unit_State]  [varchar](max),
		  [Operator_Unit_Zip_Code]  [varchar](max),
		  [Uploaded_User_ID] [varchar](50),
		  [Sheet_Name] [varchar](255),
		  [Upload_File_Name] [varchar](255)
		  )
	 </cfquery>

	<cfif NOT(isDefined("fileContentQuery.Company_Code") AND
		 	isDefined("fileContentQuery.Payee_Number") AND
			isDefined("fileContentQuery.Payee_Name") AND
			isDefined("fileContentQuery.Performance_Period_Start_Date_xx_xx_xxxx") AND
			isDefined("fileContentQuery.Performance_Period_End_Date_xx_xx_xxxx") AND
			isDefined("fileContentQuery.Invoice_Date_xx_xx_xxxx") AND
			isDefined("fileContentQuery.Expected_Payment_Amount") AND
			isDefined("fileContentQuery.Customer_Distributor_Address_Line_1") AND
			isDefined("fileContentQuery.Customer_Distributor_City") AND
			isDefined("fileContentQuery.Customer_Distributor_State") AND
			isDefined("fileContentQuery.Customer_Distributor_Zip") AND
			isDefined("fileContentQuery.Payment_Type_Code__BD_VR_") AND
			isDefined("fileContentQuery.Unit_of_Measure") AND
			isDefined("fileContentQuery.Customer_Case_Rate") AND
			isDefined("fileContentQuery.Customer_Payment_Amount") AND
			<!--- isDefined("fileContentQuery.Operator_Unit_ID") AND
			isDefined("fileContentQuery.Operator_Unit_Name") AND
			isDefined("fileContentQuery.Operator_Unit_Address_Line_1") AND
			isDefined("fileContentQuery.Operator_Unit_Address_Line_2") AND
			isDefined("fileContentQuery.Operator_Unit_City") AND
			isDefined("fileContentQuery.Operator_Unit_State") AND
			isDefined("fileContentQuery.Operator_Unit_Zip_Code") AND --->
			isDefined("fileContentQuery.SAP_Distributor_Number") AND
		 	isDefined("fileContentQuery.Customer_Invoice_Number") AND
 			isDefined("fileContentQuery.Customer_Distributor_Code") AND
 			isDefined("fileContentQuery.Customer_Distributor_Name") AND
 			isDefined("fileContentQuery.SAP_Promoted_Customer") AND
 			isDefined("fileContentQuery.Customer_Promotion_Code") AND
 			isDefined("fileContentQuery.Customer_Promotion_Description") AND
 			isDefined("fileContentQuery.Customer_GMI_Product_Code") AND
 			isDefined("fileContentQuery.Customer_Product_Code") AND
 			isDefined("fileContentQuery.Customer_Product_Description") AND
 			isDefined("fileContentQuery.Invoice_Quantity") AND
 			isDefined("fileContentQuery.GMI_Bid_Number") AND
 			isDefined("fileContentQuery.GMI_Promotion_Number")
			)>
			<cfset errorMsg = "Header error in the uploaded file!" />
				<cfreturn	errorMsg />
			</cfif>
		<cfloop query="fileContentQuery">
			<!--- Check to see atleast one column has a value to make sure it is not a empty row --->
			<cfif Trim(fileContentQuery.SAP_Distributor_Number) NEQ "" OR
				  Trim(fileContentQuery.Customer_Invoice_Number) NEQ "" OR
				  Trim(fileContentQuery.Customer_Distributor_Code) NEQ "" OR
				  Trim(fileContentQuery.Customer_Distributor_Name) NEQ "" OR
				  Trim(fileContentQuery.SAP_Promoted_Customer) NEQ "" OR
				  Trim(fileContentQuery.Customer_Promotion_Code) NEQ "" OR
				  Trim(fileContentQuery.Customer_Promotion_Description) NEQ "" OR
				  Trim(fileContentQuery.Customer_GMI_Product_Code) NEQ "" OR
				  Trim(fileContentQuery.Customer_Product_Code) NEQ "" OR
				  Trim(fileContentQuery.Customer_Product_Description) NEQ "" OR
				  Trim(fileContentQuery.Invoice_Quantity) NEQ "" OR
				  Trim(fileContentQuery.GMI_Bid_Number) NEQ "" OR
				  Trim(fileContentQuery.GMI_Promotion_Number) NEQ "">
				  <!---
				  		These are optional fields in the table use them only if they are
						there and assign blank value if not
					--->
				  <cfif isDefined("fileContentQuery.Operator_Unit_ID")>
				  	<cfset operatorUnitID =  fileContentQuery.Operator_Unit_ID />
				  <cfelse>
				  	<cfset operatorUnitID = "" />
				  </cfif>
				  <cfif isDefined("fileContentQuery.Operator_Unit_Name")>
				  	<cfset operatorUnitName =  fileContentQuery.Operator_Unit_Name />
				  <cfelse>
				  	<cfset operatorUnitName = "" />
				  </cfif>
				  <cfif isDefined("fileContentQuery.Operator_Unit_Address_Line_1")>
				  	<cfset operatorUnitAddressLine1 =  fileContentQuery.Operator_Unit_Address_Line_1 />
				  <cfelse>
				  	<cfset operatorUnitAddressLine1 = "" />
				  </cfif>
				  <cfif isDefined("fileContentQuery.Operator_Unit_Address_Line_2")>
				  	<cfset operatorUnitAddressLine2 =  fileContentQuery.Operator_Unit_Address_Line_2 />
				  <cfelse>
				  	<cfset operatorUnitAddressLine2 = "" />
				  </cfif>
				  <cfif isDefined("fileContentQuery.Operator_Unit_City")>
				  	<cfset operatorUnitCity =  fileContentQuery.Operator_Unit_City />
				  <cfelse>
				  	<cfset operatorUnitCity = "" />
				  </cfif>
				  <cfif isDefined("fileContentQuery.Operator_Unit_State")>
				  	<cfset operatorUnitState =  fileContentQuery.Operator_Unit_State />
				  <cfelse>
				  	<cfset operatorUnitState = "" />
				  </cfif>
				  <cfif isDefined("fileContentQuery.Operator_Unit_Zip_Code")>
				  	<cfset operatorUnitZipCode =  fileContentQuery.Operator_Unit_Zip_Code />
				  <cfelse>
				  	<cfset operatorUnitZipCode = "" />
				  </cfif>

				<cfquery name="Dump_Data_To_Table" datasource="#application.datasource#">
					INSERT INTO ##BB_Claim_Single_File_BLK_INS
						VALUES
						(
						'#fileContentQuery.Company_Code#',
						'#fileContentQuery.Payee_Number#',
						'#fileContentQuery.Payee_Name#',
						'#fileContentQuery.Customer_Invoice_Number#',
						'#fileContentQuery.Performance_Period_Start_Date_xx_xx_xxxx#',
						'#fileContentQuery.Performance_Period_End_Date_xx_xx_xxxx#',
						'#fileContentQuery.Invoice_Date_xx_xx_xxxx#',
						'#fileContentQuery.Expected_Payment_Amount#',
						'#fileContentQuery.SAP_Distributor_Number#',
						'#fileContentQuery.Customer_Distributor_Code#',
						'#fileContentQuery.Customer_Distributor_Name#',
						'#fileContentQuery.Customer_Distributor_Address_Line_1#',
						'#fileContentQuery.Customer_Distributor_City#',
						'#fileContentQuery.Customer_Distributor_State#',
						'#fileContentQuery.Customer_Distributor_Zip#',
						'#fileContentQuery.Customer_Promotion_Code#',
						'#fileContentQuery.Customer_Promotion_Description#',
						'#fileContentQuery.GMI_Bid_Number#',
						'#fileContentQuery.GMI_Promotion_Number#',
						'#fileContentQuery.Payment_Type_Code__BD_VR_#',
						'#fileContentQuery.SAP_Promoted_Customer#',
						'#fileContentQuery.Customer_GMI_Product_Code#',
						'#fileContentQuery.GMI_UPC_Code#',
						'#fileContentQuery.GMI_Base_Product_Code#',
						'#fileContentQuery.Customer_Product_Code#',
						'#fileContentQuery.Customer_Product_Description#',
						'#fileContentQuery.Unit_of_Measure#',
						'#fileContentQuery.Invoice_Quantity#',
						'#fileContentQuery.Customer_Case_Rate#',
						'#fileContentQuery.Customer_Payment_Amount#',
						'#operatorUnitID#',
						'#operatorUnitName#',
						'#operatorUnitAddressLine1#',
						'#operatorUnitAddressLine2#',
						'#operatorUnitCity#',
						'#operatorUnitState#',
						'#operatorUnitZipCode#',
						'#request.AccessStructure.User_ID#',
						'CSV_Single_Sheet',
						'#arguments.ulFileName#'
					)
				</cfquery>
			</cfif>
		</cfloop>
 	<cfreturn ArrayNew(errorMsg) />
</cffunction>

<!---
	This function gets the query, existing column Name and new column name and
	changes the existing column name in the query to the new one given
--->
 <cffunction name="QueryChangeColumnName" access="public" output="false" returntype="query" hint="Changes the column name of the given query.">
	<cfargument name="Query"  type="query" required="true" />
 	<cfargument name="ColumnName" type="string" required="true" />
 	<cfargument name="NewColumnName" type="string" required="true" />
 	<cfscript>
	 // Define the local scope.
	var localScope = StructNew();
	// Get the list of column names. We have to get this
	// from the query itself as the "ColdFusion" query
	// may have had an updated column list.
	localScope.Columns = arguments.Query.GetColumnNames();
	// Convert to a list so we can find the column name.
	// This version of the array does not have indexOf
	// type functionality we can use.
	localScope.ColumnList = ArrayToList(localScope.Columns);
	// Get the index of the column name.
	localScope.ColumnIndex = ListFindNoCase(localScope.ColumnList,arguments.ColumnName);
	// Make sure we have found a column.
	if (localScope.ColumnIndex){
	// Update the column name. We have to create
	// our own array based on the list since we
	// cannot directly update the array passed
	// back from the query object.
	localScope.Columns = ListToArray(
	localScope.ColumnList
	);
	localScope.Columns[ localScope.ColumnIndex ] = arguments.NewColumnName;
	// Set the column names.
	arguments.Query.SetColumnNames(localScope.Columns);
	}

	// Return the query reference.
	return( arguments.Query );

</cfscript>
</cffunction>

<!---
	This function converts the given csvString Object into query object and returns
--->
<cffunction name="csvToQuery" access="public" output="false" returntype="query" hint="Changes the column name of the given query.">
	<cfargument name="csvString"  type="any" required="true" />
 	<!---
		Replace all the comma[,] with "space,[ ,]"  so that the records can be
		read correctly
	--->
	<cfset  arguments.csvString = Replace(arguments.csvString,","," ,","All") />
	<cfscript>
	/**
	 * Transform a CSV formatted string with header column into a query object.
	 *
	 * @param cvsString      CVS Data. (Required)
	 * @param rowDelim      Row delimiter. Defaults to CHR(10). (Optional)
	 * @param colDelim      Column delimiter. Defaults to a comma. (Optional)
	 * @return Returns a query.
 	 */
		var rowDelim = chr(10);
		var colDelim = ",";
		var numCols = 1;
		var newQuery = QueryNew("");
		var arrayCol = ArrayNew(1);
		var i = 1;
		var j = 1;
		csvString = Trim(arguments.csvString);

 /*	  	if(arrayLen(arguments) GE 2) rowDelim = arguments[2];
		if(arrayLen(arguments) GE 3) colDelim = arguments[3];  */

		arrayCol = listToArray(listFirst(arguments.csvString,rowDelim),colDelim);

		// arrayCol = Replace(Replace(Replace(Replace(Replace(Trim(arrayCol)," ","_","ALL"),"/","_","ALL"),"(","_","ALL"),")","_","ALL"),"##","_","ALL");
		for(i=1; i LTE arrayLen(arrayCol); i=i+1)
		{
			newColumnName = Replace(Replace(Replace(Replace(Replace(Trim(arrayCol[i])," ","_","ALL"),"/","_","ALL"),"(","_","ALL"),")","_","ALL"),"##","_","ALL");
			queryAddColumn(newQuery, newColumnName, ArrayNew(1));
		}

		for(i=2; i LTE listLen(arguments.csvString,rowDelim); i=i+1) {
			queryAddRow(newQuery);
			for(j=1; j LTE arrayLen(arrayCol); j=j+1) {
				if(listLen(listGetAt(arguments.csvString,i,rowDelim),colDelim) GTE j) {

					newColumnName2 = Replace(Replace(Replace(Replace(Replace(Trim(arrayCol[j])," ","_","ALL"),"/","_","ALL"),"(","_","ALL"),")","_","ALL"),"##","_","ALL");
					if (listGetAt(listGetAt(arguments.csvString,i,rowDelim),j,colDelim) EQ "")
					{
						columnValue = NULL;
					}
					else
					{
						columnValue = listGetAt(listGetAt(arguments.csvString,i,rowDelim),j,colDelim);
					}
					querySetCell(newQuery, newColumnName2,columnValue, i-1);
				}
			}
		}
		return newQuery;
	 </cfscript>
 </cffunction>

<cffunction name="logUpload_OLD_RETIRED_NOT_USED" output="false">
		<cfargument name="CFEvent" type="struct" required="true">
		<cfscript>
			var data			=	cfevent;
			var message			=	data.message;
			var filePath 		= data.filePath;
			var fileName 		= data.fileName;
			var fileSize		= data.fileSize;
			var arrCorrections	= ArrayNew(1);
			var arrParseResult	= ArrayNew(1);
			var qryResult		= structNew();
			if (NOT IsDefined("CFEvent.Data.file")) {
					CFEvent.Data.file="defaultEventLog"; }
			if (NOT IsDefined("CFEvent.Data.type")) {
				CFEvent.Data.type="info"; }
		</cfscript>

		<cftry>
 			<cfset bbUploadManager = createObject("component","mvc.Models.Billback.BillbackUploadManager") />

<cfquery name="qInsBBUploadLog" datasource="#application.datasource#">
			DECLARE  @upload_id int,
			 		 @upload_date datetime,
					 @user_id varchar(50),
					 @single_file varchar(255)

		  	SET @upload_date = getdate()
	  		SET @user_id = '#data.userStruct.User_ID#'
	  		SET @single_file ='#data.fileName#'

			INSERT INTO BB_upload_log (--upload_ID,
			User_ID,
			total_header_count ,
			total_header_count_failed ,
			total_header_count_loaded ,
			total_detail_count ,
			total_detail_count_failed,
			total_detail_count_loaded,
			upload_date ,
			upload_status,
			header_file_name,
			detail_file_name  ,
			Upload_Type,
			Upload_Type_Desc
			)
	  SELECT
			--34,
			@user_id,
			0,
			0,
			0,
			0,
			0,
			0,
			@upload_date,
			'File Received',
			@single_file,
			@single_file,
			2,
			1

		  SELECT
		  	Upload_ID
		  FROM
		  	BB_upload_log
		  WHERE User_ID = @user_id AND Upload_Status = 'File Received' AND Upload_Date = @Upload_Date AND Header_File_Name = @single_file
		</cfquery>

			<cfset fileSizeMB = (fileSize  /1024)/1024 />
			<cfif fileSizeMB GT 3>
				<cfquery name="qInsBBUploadLog" datasource="#application.datasource#">
					UPDATE
						BB_upload_log
					SET
						upload_status = 'Upload Failed::File size is greater than 3MB'
					WHERE
						upload_ID = #qInsBBUploadLog.Upload_ID#
				</cfquery>
				<cfscript>
					//message = 'UPLOAD ERROR: #message# :: #cfcatch.message# #cfcatch.Detail#';
//					<strong>The file upload failed due to one of the below reasons:</strong><br>a)
					message = '<br>The uploaded file failed due to its size being 3MB or greater. <br>Note:  The file size being so large can be due to there being many rows with empty <br>data. To remove the rows with empty data follow these steps: <br>highlight any empty rows, right click and select delete.';
					msg = structNew();
					// msg.headers = structNew();
					// msg.headers.gatewayid = "cfData";
					// msg.headers['TYPE'] = "DataServicesMessaging";
					 msg.body = structNew();
					 msg.body['message'] =  message;
					 msg.body['arrParseResult'] =  arrParseResult;
					 msg.body['arrCorrections'] =  arrCorrections;
					 msg.body['sFileName'] =  fileName;
					 msg.body['serial'] = timeformat(now(),"long");
					 msg.body['user'] = data.userStruct.user_code;
					 msg.body['user_Id'] = data.userStruct.User_ID;
					 msg.destination = "ColdFusionGateway";
					 //sendGatewayMessage("cfData",msg);
					 WsPublish("cfData",SerializeJSON(msg));
				</cfscript>
				<cfreturn />
			</cfif>


			<cfset arrParseResult = this.FileReadDiverter(filePath,fileName) />
			<!--- make sure temp table is not corrupted with onother sessions data --->
			<cfquery name="checkUpload" datasource="#application.datasource#">
					select  top 1 Upload_File_Name,*
					FROM
					 ##BB_Claim_Single_File_BLK_INS
					WHERE
						Upload_File_Name = '#fileName#'
			</cfquery>
			<cfif arrParseResult[1] NEQ 'Invalid File Type' && checkUpload.recordCount>
				<cfstoredproc procedure="Upload_E_Invoice_Single_File_Parser" datasource="#application.datasource#">
					<cfprocparam type="IN" cfsqltype="cf_sql_integer"  dbVarName = "@Upload_ID" value="#qInsBBUploadLog.Upload_ID#">
					<cfprocresult name = qryResult>
				</cfstoredProc>

			<cfelse>
				<cfset message = 'Parse Error [#arrParseResult[1]#] #message#'/>
			</cfif>


			<!--- TODO: Get return from validation routine and display VALID/INVALID DATA message --->
			<!--- SEND SUCCESS BACK TO UPLOAD count: --->
			<cfscript>
				//this.dmp(checkUpload);
				if(isDefined('qryResult') && StructKeyExists(qryResult,'TOTAL_HEADER_COUNT_FAILED') ){
					for (x = 1; x <= qryResult.RecordCount; x=x+1) {
						if(qryResult.UPLOAD_ID[x] != ''){
							uploadId 		= qryResult.UPLOAD_ID[x];
						bbHeaderID 		= qryResult.BB_UPLOAD_HEADER_ERROR_CORRECTION_ID[x];
						bbUploadHeader 	= getOneHeaderRow(uploadID=uploadId, BBUploadHeaderErrorCorrectionID=bbHeaderID);
						ArrayAppend(arrCorrections,duplicate(bbUploadHeader));
						}
					}
				}
				else{
					if(isDefined('qryResult') && StructKeyExists(qryResult,'ERRORMESSAGE')){
						message = '[DB Error: #qryResult.ERRORMESSAGE#] #message#';
					}
					qryResult = structNew();
					qryResult.TOTAL_HEADER_COUNT = 0;
					qryResult.TOTAL_HEADER_COUNT_FAILED = 0;
					qryResult.TOTAL_HEADER_COUNT_LOADED = 0;
					//message = 'No Database Result #message#';
				}

				message = '[Total:#qryResult.TOTAL_HEADER_COUNT#  Invalid:#qryResult.TOTAL_HEADER_COUNT_FAILED#  Valid:#qryResult.TOTAL_HEADER_COUNT_LOADED#]  #message#';
				msg = structNew();
				// msg.headers = structNew();
				// msg.headers.gatewayid = "cfData";
				// msg.headers['TYPE'] = "DataServicesMessaging";
				 msg.body = structNew();
				 msg.body['message'] =  message;
				 msg.body['arrParseResult'] =  arrParseResult;
				 msg.body['arrCorrections'] =  arrCorrections;
				 msg.body['sFileName'] =  fileName;
				 msg.body['serial'] = timeformat(now(),"long");
				 msg.body['user'] = data.userStruct.user_code;
				 msg.body['user_Id'] = data.userStruct.User_ID;
				 msg.destination = "ColdFusionGateway";
				 //sendGatewayMessage("cfData",msg);
				 WsPublish("cfData",SerializeJSON(msg));
			</cfscript>
			<cfcatch type="any" >
				<!--- SEND ERROR BACK TO UPLOAD --->
				<cfscript>
					//message = 'UPLOAD ERROR: #message# :: #cfcatch.message# #cfcatch.Detail#';
					message = '<br><strong>The file upload failed due to one of the below reasons:</strong><br>a) The file is not an acceptable type(valid types are: xls and xlsx).<br>b) The file uploaded seems to be corrupt and could not be read.';
					msg = structNew();
					// msg.headers = structNew();
					// msg.headers.gatewayid = "cfData";
					// msg.headers['TYPE'] = "DataServicesMessaging";
					 msg.body = structNew();
					 msg.body['message'] =  message;
					 msg.body['arrCorrections'] =  arrCorrections;
					 msg.body['arrParseResult'] =  arrParseResult;
					 msg.body['sFileName'] =  fileName;
					 msg.body['serial'] = timeformat(now(),"long");
					 msg.body['user'] = data.userStruct.user_code;
					 msg.body['user_Id'] = data.userStruct.User_ID;
					 msg.destination = "ColdFusionGateway";
					 //sendGatewayMessage("cfData",msg);
					 WsPublish("cfData",SerializeJSON(msg));
				</cfscript>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="onIncomingMessage" output="no">
	<cfargument name="CFEvent" type="struct" required="yes">

		<!--- Get the message --->
		<cfset data=cfevent.DATA>
		<cfset message="#data.message#">

		<cflog text="#message#" file="cfmlgateway.log" type="Information">

	</cffunction>

	<cffunction name="getBBsForUploadID" returntype="array" access="remote">
		<cfargument name="UploadID" type="numeric" required="true">
		<cfset arrBBHeaders = ArrayNew(1) />
		<cfquery name="qGetBBsForUploadID" datasource="#application.datasource#">
			SELECT * FROM Billback_Txt_Upload_Header_log
			WHERE Upload_ID = <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.UploadID#" />
			AND Deleted = 0
			ORDER BY BB_Code
		</cfquery>

		<cfif qGetBBsForUploadID.RecordCount GTE 1>
			<cfset BBIDsList = QuotedValueList(qGetBBsForUploadID.Billback_ID)>
				<cfquery name="getNumericBBID" datasource="#application.datasource#">
				SELECT BB.Billback_ID_Int, BB.Billback_ID, BB.Billback_Status_ID
				FROM Billback BB
				WHERE BB.Billback_ID in (#PreserveSingleQuotes(BBIDsList)#)
				AND BB.Deleted = 0
				ORDER BY BB.Billback_ID_Int
			</cfquery>
			<cfif (qGetBBsForUploadID.RecordCount GTE 1 AND isDefined("getNumericBBID") AND getNumericBBID.RecordCount GTE 1)>
				<cfset BBIdIntList = "0" />
				<cfloop query = "getNumericBBID">
					<cfset qGetBillbackData 				=  variables.BBMgr.getBillbackData(getNumericBBID.Billback_ID_Int) />
					<cfset stHeaderData						= structNew() />
					<cfset stHeaderData["__type__"] 		= "mvc.Models.Billback.vos.BBHeader" />
					<cfset stHeaderData 					= variables.objBillbackLoadManager.getCreateBillbackHeaderObject(qGetBillbackData) />
					<cfset ArrayAppend(arrBBHeaders, duplicate(stHeaderData))>

					<!---  106138: Uploaded BB's dont populate fixed Comp field in BB_program at upload.
							Its updated during BB deviation or approve, so manually force the update if the BB isnt approved --->
					<cfif Billback_Status_ID lte 2>
						<cfset BBIdIntList = listAppend(BBIdIntList, Billback_ID_Int) />
					</cfif>
				</cfloop>
				<cfset queryScript = "SELECT Billback_ID FROM Billback WHERE Billback_ID_Int IN (#BBIdIntList#)" />
				<cfquery name="UpdateFixedComp" datasource="#application.datasource#">
					EXEC BB_Save_GL_Account NULL, '#queryScript#'
				</cfquery>
			</cfif>
		</cfif>

		<cfreturn arrBBHeaders />
	</cffunction>

	<cffunction name="getBBsForUploadIDJSON"  access="remote" output="false" returnformat="JSON">
		<cfargument name="UploadID" type="numeric" required="true">

		<cfscript>
			var jsonData = '';
			var billbackUpload = getBBsForUploadID(arguments.UploadID);

			billbackUpload = application.util.struct.structSortLowerCase(billbackUpload);
			jsonData = serializeJSON(billbackUpload, "struct");
		</cfscript>
		<cfreturn jsonData/>

	</cffunction>

	<cffunction name="createFlexGateway">
		<cfscript>
			// Login is always required. This example uses two lines of code.
			adminObj = createObject("component","cfide.adminapi.administrator");
		  	local.cf_admin = application.util.query.cf_admin();
		  	if ( adminObj.login( local.cf_admin.password, local.cf_admin.username ) ) {
				// Instantiate the data source object.
				myObj = createObject("component","cfide.adminapi.eventgateway");
				// check gateway instance.
				//arr = myObj.getGatewayInstances('cfData');
				arrPath = arrayNew(1);
				ArrayAppend(arrPath,'{cf.rootdir}/gateway/cfc/examples/menu/main.cfc');
				myObj.setGatewayInstance ( 'cfData', 'DataServicesMessaging', arrPath, '', 'auto' );
				myObj.startGatewayInstance ( 'cfData' );
				arr2 = myObj.getGatewayInstances('cfData');
			}

		</cfscript>
	</cffunction>

	<!--- lockUnlockBB --->
	<cffunction name="lockUnlockBB" access="remote" output="false" returntype="struct">

		<cfargument name="bbHeaderID" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		<cfargument name="lockUnlock" type="boolean" default="1" hint="1 = Lock, 0 = Unlock" />
		<cfargument name="toggleBB" type="boolean" default="0" hint="1 = action is billback lock toggle, 0 = action is NOT billback lock toggle" />
		<cfargument name="unlockExistingLockedByUser" type="boolean" default="0" hint="1 = Unlock, 0 = Nothing" />
		<cfargument name="bbClose" type="boolean" default="0" hint="1 = Called on closing a uploaded record" /><!--- "bbClose" is not being used now in CF (only in flex), but it might be useful at a later time. --->

		<cfscript>
		var stRetStruct			= structNew();

			//set local variables
			var nBBHeaderID			= "";
			var strUserID			= "";
			var qCheckBillbackLocked	= "";
			var qCheckBillbackUserLocked	= "";
			var qGetBillbackUserLocked	= "";
			var objBillBackUploadDAO	= "";
			var qGetUserOnLock		= "";
			var strUserNameOnLock		= "";
			var stRetStruct			= structNew();
			var bLockId			= 1;
			var stData			= structNew();

			//assign local variables
			nBBHeaderID	= arguments.bbHeaderID;
			strUserID	= arguments.userId;
			bLockId		= arguments.lockUnlock;

			objBillBackUploadDAO		= variables.oBillBackUploadDAO;
			qCheckBillbackLocked 		= objBillBackUploadDAO.getBBLockedByID(nBBHeaderID);
			qCheckBillbackUserLocked	= objBillBackUploadDAO.getBBLockedByUser(strUserID);


			/***********************************************************************************************************************
			Handle for the following scenarios:
				1:	Uploaded record is locked by the user id passed to this function
				2:	Uploaded record is locked not by the user id passed to this function
				3:	Uploaded record is not locked but the user id passed in to this function has another Uploaded record locked
				4:	Uploaded record is not locked and the user id passed in to this function does not have another Uploaded record locked
				objId:			Upload ID passed to function
				userId: 		User ID passed to function
				objIdLocked:		Uploaded ID locked by the user id passed to function
				userLocked:		User object currently locking the Uploaded ID passed to function
			*************************************************************************************************************************/
			//if lockUnlock = 0 then unlock this Uploaded record else lock this uploaded record
			if (bLockId eq 0) // unlock
			{
				//call unlock function
				objBillBackUploadDAO.setBBUnLocked(nBBHeaderID);
				structInsert(stRetStruct, "objId", nBBHeaderID);
				structInsert(stRetStruct, "userId", strUserID);
				structInsert(stRetStruct, "objIdLocked", "");
				structInsert(stRetStruct, "bLocked", JavaCast("boolean", 0));

				stData = structNew();
				structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
				structInsert(stData, "id", "");
				structInsert(stData, "idInt", "");
				structInsert(stData, "fullName", "");
				structInsert(stRetStruct, "userLocked", stData);
			}
			else // lock
			{
				//scenario -  uploaded record is locked by the user id passed to this function
				if (qCheckBillbackLocked.RecordCount and qCheckBillbackUserLocked.RecordCount and (qCheckBillbackLocked.BB_Locked_By_User_ID eq strUserID))
				{
					structInsert(stRetStruct, "objId", nBBHeaderID);
					structInsert(stRetStruct, "userId", strUserID);
					structInsert(stRetStruct, "objIdLocked", nBBHeaderID);
					structInsert(stRetStruct, "objIdLockedDesc", "");
					structInsert(stRetStruct, "bLocked", JavaCast("boolean", 1));

					stData = structNew();
					structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
					structInsert(stData, "id", strUserID);
					structInsert(stData, "idInt", "");
					structInsert(stData, "fullName", qCheckBillbackUserLocked.Locked_By_User_Name);
					structInsert(stRetStruct, "userLocked", stData);
				}
				//scenario -  uploaded record is locked not by the user id passed to this function
				if (qCheckBillbackLocked.RecordCount and (qCheckBillbackLocked.BB_Locked_By_User_ID neq strUserID))
				{
					qGetBillbackUserLocked =  objBillBackUploadDAO.getBBLockedByUser(qCheckBillbackLocked.BB_Locked_By_User_ID);
					structInsert(stRetStruct, "objId", nBBHeaderID);
					structInsert(stRetStruct, "userId", strUserID);
					structInsert(stRetStruct, "objIdLocked", "");
					structInsert(stRetStruct, "objIdLockedDesc", "");
					structInsert(stRetStruct, "bLocked", JavaCast("boolean", 1));

					stData = structNew();
					structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
					structInsert(stData, "id", qGetBillbackUserLocked.BB_Locked_By_User_ID);
					structInsert(stData, "idInt", "");
					structInsert(stData, "fullName", qGetBillbackUserLocked.Locked_By_User_Name);
					structInsert(stRetStruct, "userLocked", stData);


				}
				//scenario -  uploaded record is not locked but the user id passed in to this function has another  uploaded record locked
				else if (not qCheckBillbackLocked.RecordCount and qCheckBillbackUserLocked.RecordCount)
				{
					structInsert(stRetStruct, "objId", nBBHeaderID);
					structInsert(stRetStruct, "userId", strUserID);
					structInsert(stRetStruct, "objIdLocked", qCheckBillbackUserLocked.BB_Upload_Header_Error_Correction_ID);
					structInsert(stRetStruct, "objIdLockedDesc", "");
					structInsert(stRetStruct, "bLocked", JavaCast("boolean", 0));

					stData = structNew();
					structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
					structInsert(stData, "id", "");
					structInsert(stData, "idInt", "");
					structInsert(stData, "fullName", "");
					structInsert(stRetStruct, "userLocked", stData);
				}
				//scenario -  uploaded record is not locked and the user id passed in to this function does not have another  uploaded record locked
				else if (not qCheckBillbackLocked.RecordCount and not qCheckBillbackUserLocked.RecordCount)
				{
					if (objBillBackUploadDAO.setBBLocked(nBBHeaderID, strUserID) eq 1)
					{
						qGetUserOnLock = objBillBackUploadDAO.getBBLockedByUser(strUserID);
						strUserNameOnLock = qGetUserOnLock.Locked_By_User_Name;
					}
					structInsert(stRetStruct, "objId", nBBHeaderID);
					structInsert(stRetStruct, "userId", strUserID);
					structInsert(stRetStruct, "objIdLocked", nBBHeaderID);
					structInsert(stRetStruct, "objIdLockedDesc", "");
					structInsert(stRetStruct, "bLocked", JavaCast("boolean", 1));

					stData = structNew();
					structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
					structInsert(stData, "id", strUserID);
					structInsert(stData, "idInt", "");
					structInsert(stData, "fullName", strUserNameOnLock);
					structInsert(stRetStruct, "userLocked", stData);
				}
			}

				// Set "toggleLock" to 1, as it is being called from the "ToggleLock" functionality
				if(arguments.toggleBB == 1)
				{
					structInsert(stRetStruct, "toggleLock", JavaCast("boolean", 1));
				}

				// Set "unlockExistingLockedByUser" to whatever is being passed from flex
				structInsert(stRetStruct, "unlockExistingLockedByUser", JavaCast("boolean", arguments.unlockExistingLockedByUser));

			//stuff type into return struct
			structInsert(stRetStruct, "__type__", "mvc.Models.Entity.vos.Lock");

			//return stRetStruct;
		</cfscript>
		<cfreturn stRetStruct>
	</cffunction>

	<!--- getLockUnlockBB --->
	<cffunction name="getLockUnlockBB" access="remote" output="false" returntype="struct">

		<cfargument name="bbHeaderID" type="numeric" required="true" />
		<cfscript>
		var stRetStruct			= structNew();

			//set local variables
			var nBBHeaderID			= "";
			var strUserID			= "";
			var strUserNameOnLock		= "";
			var nIdLocked			= "";
			var strLockObjDesc		= "";
			var bBBIsLocked			= 0;
			var qCheckBillbackLocked	= "";
			var qGetBillbackUserLocked	= "";
			var objBillBackUploadDAO	= "";
			var stRetStruct			= structNew();
			var stData			= structNew();

			//assign local variables
			nBBHeaderID	= arguments.bbHeaderID;

			objBillBackUploadDAO 		= variables.oBillBackUploadDAO;
			qCheckBillbackLocked 		= objBillBackUploadDAO.getBBLockedByID(nBBHeaderID);
			/***********************************************************************************************************************
				objId:			BBHeaderID passed to function
				userId: 		User ID passed to function
				objIdLocked:		Uploaded record locked by the user id passed to function
				userLocked:		User object currently locking the BBHeaderID passed to function
			*************************************************************************************************************************/

			// if the Uploaded record is locked then get the user data for the user who has it locked
			if (qCheckBillbackLocked.RecordCount){
				strUserID			= qCheckBillbackLocked.BB_Locked_By_User_ID;
				nIdLocked			= nBBHeaderID;
				bBBIsLocked			= 1;
				qGetBillbackUserLocked 		= objBillBackUploadDAO.getBBLockedByUser(strUserID, nBBHeaderID);
				strUserNameOnLock		= qGetBillbackUserLocked.Locked_By_User_Name;
				/* There is no description for uploaded records */
				//strLockObjDesc		= qGetBillbackUserLocked.BB_Code;
			}
			structInsert(stRetStruct, "objId", nBBHeaderID);
			structInsert(stRetStruct, "userId", strUserID);
			structInsert(stRetStruct, "objIdLocked", nIdLocked);
			structInsert(stRetStruct, "objIdLockedDesc", "");
			structInsert(stRetStruct, "bLocked", JavaCast("boolean", bBBIsLocked));

			stData = structNew();
			structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
			structInsert(stData, "id", strUserID);
			structInsert(stData, "idInt", "");
			structInsert(stData, "fullName", strUserNameOnLock);
			structInsert(stRetStruct, "userLocked", stData);

			//stuff type into return struct
			structInsert(stRetStruct, "__type__", "mvc.Models.Entity.vos.Lock");

			//return stRetStruct;
		</cfscript>
		<cfreturn stRetStruct />
	</cffunction>

	<cffunction name="lockUnlockBBJSON" access="remote" output="false" returntype="string" returnformat="JSON" >

		<cfargument name="bbHeaderID" required="true" />
		<cfargument name="userId" type="string" required="true" />
		<cfargument name="lockUnlock" type="boolean" default="1" hint="1 = Lock, 0 = Unlock" />
		<cfargument name="toggleBB" type="boolean" default="0" hint="1 = action is billback lock toggle, 0 = action is NOT billback lock toggle" />
		<cfargument name="unlockExistingLockedByUser" type="boolean" default="0" hint="1 = Unlock, 0 = Nothing" />
		<cfargument name="bbClose" type="boolean" default="0" hint="1 = Called on closing a uploaded record" /><!--- "bbClose" is not being used now in CF (only in flex), but it might be useful at a later time. --->

		<cfscript>
			var stRetStruct              = structNew();
			var nBBHeaderID              = "";
			var strUserID                = "";
			var qCheckBillbackLocked     = "";
			var qCheckBillbackUserLocked = "";
			var qGetBillbackUserLocked   = "";
			var objBillBackUploadDAO     = "";
			var qGetUserOnLock           = "";
			var strUserNameOnLock        = "";
			var stRetStruct              = structNew();
			var bLockId                  = 1;
			var stData                   = structNew();

            // =============================================================================
            // when a numeric "bbHeaderID" is passed use it
            // otherwise use an arbitrary negative value which is not linked to a billback
            // GM production ran into many event errors due to blank bbHeaderID parameter
            // =============================================================================
			nBBHeaderID                  = isNumeric(arguments.bbHeaderID) ? arguments.bbHeaderID : -1;    
			strUserID                    = arguments.userId;
			bLockId                      = arguments.lockUnlock;
			objBillBackUploadDAO		 = variables.oBillBackUploadDAO;
			qCheckBillbackLocked 		 = objBillBackUploadDAO.getBBLockedByID(nBBHeaderID);
			qCheckBillbackUserLocked	 = objBillBackUploadDAO.getBBLockedByUser(strUserID);


			/***********************************************************************************************************************
			Handle for the following scenarios:
				1:	Uploaded record is locked by the user id passed to this function
				2:	Uploaded record is locked not by the user id passed to this function
				3:	Uploaded record is not locked but the user id passed in to this function has another Uploaded record locked
				4:	Uploaded record is not locked and the user id passed in to this function does not have another Uploaded record locked
				objId:			Upload ID passed to function
				userId: 		User ID passed to function
				objIdLocked:		Uploaded ID locked by the user id passed to function
				userLocked:		User object currently locking the Uploaded ID passed to function
			*************************************************************************************************************************/
			//if lockUnlock = 0 then unlock this Uploaded record else lock this uploaded record
			if (bLockId eq 0) // unlock
			{   
				//call unlock function
				objBillBackUploadDAO.setBBUnLocked(nBBHeaderID);
				structInsert(stRetStruct, "objId", nBBHeaderID);
				structInsert(stRetStruct, "userId", strUserID);
				structInsert(stRetStruct, "objIdLocked", "");
				structInsert(stRetStruct, "bLocked", JavaCast("boolean", 0));

				stData = structNew();
				structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
				structInsert(stData, "id", "");
				structInsert(stData, "idInt", "");
				structInsert(stData, "fullName", "");
				structInsert(stRetStruct, "userLocked", stData);
			}
			else // lock
			{
				//scenario -  uploaded record is locked by the user id passed to this function
				if (qCheckBillbackLocked.RecordCount and qCheckBillbackUserLocked.RecordCount and (qCheckBillbackLocked.BB_Locked_By_User_ID eq strUserID))
				{
					structInsert(stRetStruct, "objId", nBBHeaderID);
					structInsert(stRetStruct, "userId", strUserID);
					structInsert(stRetStruct, "objIdLocked", nBBHeaderID);
					structInsert(stRetStruct, "objIdLockedDesc", "");
					structInsert(stRetStruct, "bLocked", JavaCast("boolean", 1));

					stData = structNew();
					structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
					structInsert(stData, "id", strUserID);
					structInsert(stData, "idInt", "");
					structInsert(stData, "fullName", qCheckBillbackUserLocked.Locked_By_User_Name);
					structInsert(stRetStruct, "userLocked", stData);
				}
				//scenario -  uploaded record is locked not by the user id passed to this function
				if (qCheckBillbackLocked.RecordCount and (qCheckBillbackLocked.BB_Locked_By_User_ID neq strUserID))
				{
					qGetBillbackUserLocked =  objBillBackUploadDAO.getBBLockedByUser(qCheckBillbackLocked.BB_Locked_By_User_ID);
					structInsert(stRetStruct, "objId", nBBHeaderID);
					structInsert(stRetStruct, "userId", strUserID);
					structInsert(stRetStruct, "objIdLocked", "");
					structInsert(stRetStruct, "objIdLockedDesc", "");
					structInsert(stRetStruct, "bLocked", JavaCast("boolean", 1));

					stData = structNew();
					structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
					structInsert(stData, "id", qGetBillbackUserLocked.BB_Locked_By_User_ID);
					structInsert(stData, "idInt", "");
					structInsert(stData, "fullName", qGetBillbackUserLocked.Locked_By_User_Name);
					structInsert(stRetStruct, "userLocked", stData);


				}
				//scenario -  uploaded record is not locked but the user id passed in to this function has another  uploaded record locked
				else if (not qCheckBillbackLocked.RecordCount and qCheckBillbackUserLocked.RecordCount)
				{
					structInsert(stRetStruct, "objId", nBBHeaderID);
					structInsert(stRetStruct, "userId", strUserID);
					structInsert(stRetStruct, "objIdLocked", qCheckBillbackUserLocked.BB_Upload_Header_Error_Correction_ID);
					structInsert(stRetStruct, "objIdLockedDesc", "");
					structInsert(stRetStruct, "bLocked", JavaCast("boolean", 0));

					stData = structNew();
					structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
					structInsert(stData, "id", "");
					structInsert(stData, "idInt", "");
					structInsert(stData, "fullName", "");
					structInsert(stRetStruct, "userLocked", stData);
				}
				//scenario -  uploaded record is not locked and the user id passed in to this function does not have another  uploaded record locked
				else if (not qCheckBillbackLocked.RecordCount and not qCheckBillbackUserLocked.RecordCount)
				{
					if (objBillBackUploadDAO.setBBLocked(nBBHeaderID, strUserID) eq 1)
					{
						qGetUserOnLock = objBillBackUploadDAO.getBBLockedByUser(strUserID);
						strUserNameOnLock = qGetUserOnLock.Locked_By_User_Name;
					}
					structInsert(stRetStruct, "objId", nBBHeaderID);
					structInsert(stRetStruct, "userId", strUserID);
					structInsert(stRetStruct, "objIdLocked", nBBHeaderID);
					structInsert(stRetStruct, "objIdLockedDesc", "");
					structInsert(stRetStruct, "bLocked", JavaCast("boolean", 1));

					stData = structNew();
					structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
					structInsert(stData, "id", strUserID);
					structInsert(stData, "idInt", "");
					structInsert(stData, "fullName", strUserNameOnLock);
					structInsert(stRetStruct, "userLocked", stData);
				}
			}

            // Set "toggleLock" to 1, as it is being called from the "ToggleLock" functionality
            if(arguments.toggleBB == 1)
            {
                structInsert(stRetStruct, "toggleLock", JavaCast("boolean", 1));
            }

            // Set "unlockExistingLockedByUser" to whatever is being passed from flex
            structInsert(stRetStruct, "unlockExistingLockedByUser", JavaCast("boolean", arguments.unlockExistingLockedByUser));

			//stuff type into return struct
			structInsert(stRetStruct, "__type__", "mvc.Models.Entity.vos.Lock");

			return serializeJson(stRetStruct);
		</cfscript>

	</cffunction>

	<!--- getLockUnlockBB --->
	<cffunction name="getLockUnlockBBJSON" access="remote" returntype="string" returnformat="JSON"  output="false" >
		<cfargument name="bbHeaderID" type="numeric" required="true" />
		<cfscript>
		var stRetStruct			= structNew();

			//set local variables
			var nBBHeaderID			= "";
			var strUserID			= "";
			var strUserNameOnLock		= "";
			var nIdLocked			= "";
			var strLockObjDesc		= "";
			var bBBIsLocked			= 0;
			var qCheckBillbackLocked	= "";
			var qGetBillbackUserLocked	= "";
			var objBillBackUploadDAO	= "";
			var stRetStruct			= structNew();
			var stData			= structNew();

			//assign local variables
			nBBHeaderID	= arguments.bbHeaderID;

			objBillBackUploadDAO 		= variables.oBillBackUploadDAO;
			qCheckBillbackLocked 		= objBillBackUploadDAO.getBBLockedByID(nBBHeaderID);
			/***********************************************************************************************************************
				objId:			BBHeaderID passed to function
				userId: 		User ID passed to function
				objIdLocked:		Uploaded record locked by the user id passed to function
				userLocked:		User object currently locking the BBHeaderID passed to function
			*************************************************************************************************************************/

			// if the Uploaded record is locked then get the user data for the user who has it locked
			if (qCheckBillbackLocked.RecordCount){
				strUserID			= qCheckBillbackLocked.BB_Locked_By_User_ID;
				nIdLocked			= nBBHeaderID;
				bBBIsLocked			= 1;
				qGetBillbackUserLocked 		= objBillBackUploadDAO.getBBLockedByUser(strUserID, nBBHeaderID);
				strUserNameOnLock		= qGetBillbackUserLocked.Locked_By_User_Name;
				/* There is no description for uploaded records */
				//strLockObjDesc		= qGetBillbackUserLocked.BB_Code;
			}
			structInsert(stRetStruct, "objId", nBBHeaderID);
			structInsert(stRetStruct, "userId", strUserID);
			structInsert(stRetStruct, "objIdLocked", nIdLocked);
			structInsert(stRetStruct, "objIdLockedDesc", "");
			structInsert(stRetStruct, "bLocked", JavaCast("boolean", bBBIsLocked));

			stData = structNew();
			structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
			structInsert(stData, "id", strUserID);
			structInsert(stData, "idInt", "");
			structInsert(stData, "fullName", strUserNameOnLock);
			structInsert(stRetStruct, "userLocked", stData);

			//stuff type into return struct
			structInsert(stRetStruct, "__type__", "mvc.Models.Entity.vos.Lock");

			//return stRetStruct;
		</cfscript>
		<cfscript>
			//writedump(var=qHeaderData,output='c:\dump.log');
			var jsonData = '';
			jsonData = serializeJson(stRetStruct);
		</cfscript>

		<cfreturn jsonData />
	</cffunction>

	<!--- get date filters --->
	<cffunction name="getDateFilters" output="false" access="remote" returntype="array">

		<cfscript>
			//set local variables
			var arrRet				= arrayNew(1);
			var	qGetDates			= "";
			var idxRow				= "";
			var strDisplay			= "";

			qGetDates = variables.oBillBackUploadDAO.getDateFilters();

			stData = structNew();
			stData["monthNumber"]	=	Month(DateAdd("m", -2, now()));
			stData["yearNumber"] 	=  	Year(DateAdd("m", -2, now()));
			stData["description"]	=  	"";
			stData["display"]		= 	"Last 3 months";
			stData["monthSpan"]		=  	3;
			ArrayAppend(arrRet, duplicate(stData));

			stData = structNew();
			stData["monthNumber"]	=	Month(DateAdd("m", -5, now()));
			stData["yearNumber"] 	=  	Year(DateAdd("m", -5, now()));
			stData["description"]	=  	"";
			stData["display"]		= 	"Last 6 months";
			stData["monthSpan"]		=  	6;
			ArrayAppend(arrRet, duplicate(stData));

			//Loop over query object and build an array of Program VOs
			for (idxRow = 1; idxRow LTE qGetDates.RecordCount; idxRow = (idxRow + 1))
			{

				stData = structNew();
				//Populate struct
				stData["monthNumber"]	=	qGetDates["Upload_Month_Number"][idxRow];
				stData["yearNumber"] 	=  	qGetDates["Upload_Year"][idxRow];
				stData["description"]	=  	qGetDates["Upload_Month"][idxRow];
				stData["display"]		=  	stData["yearNumber"] & ' ' & stData["description"];
				stData["monthSpan"]		=  	1;
				ArrayAppend(arrRet, duplicate(stData));

			}
			return arrRet;
		</cfscript>
	</cffunction>

	<cffunction name="Tracker" access="remote" output="true" returntype="any">
		<cfargument name="BB_Bucket" type="string" required="true" />
		<cfargument name="BB_Step" type="string" required="true" />
		<cfargument name="Content" type="string" required="true" />
		<cfargument name="File_Name" type="string" required="true" />
		<cfargument name="uploadId" type="numeric" required = "true" />
		<cfargument name="bbHeaderID" type="numeric" required = "true" />


		<cfset fileName = arguments.File_Name />

	

		<cfif (isDefined(arguments.uploadId) AND arguments.uploadId NEQ "")>
			<cfset useLakebaseForqGetFileName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_upload_log")>
<cfif useLakebaseForqGetFileName>
	<cftry>
		<cfset qGetFileName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_upload_log", {
				"upload_id" = "eq.#arguments.uploadId#",
				"select" = "header_file_name"
			}), "header_file_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetFileName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetFileName>
<cfquery name="qGetFileName" datasource="#application.datasource#">
				SELECT header_file_name FROM BB_upload_log WHERE Upload_id = #arguments.uploadId#
			</cfquery>
</cfif>
			<cfset fileName = qGetFileName.header_file_name />

		</cfif>

			<cfstoredproc procedure="Dumper" datasource="#application.datasource#">
				<cfprocparam type="IN" cfsqltype="cf_sql_varchar" dbVarName = "@BB_Bucket" value="#arguments.BB_Bucket#">
				<cfprocparam type="IN" cfsqltype="cf_sql_varchar" dbVarName = "@BB_Step" value="#arguments.BB_Step#">
				<cfprocparam type="IN" cfsqltype="cf_sql_varchar" dbVarName = "@Content" value="#arguments.Content#">
				<cfprocparam type="IN" cfsqltype="cf_sql_varchar" dbVarName = "@File_Name" value="#fileName#">
				<cfprocparam type="IN" cfsqltype="cf_sql_varchar" dbVarName = "@Upload_or_BB_ID" value="#arguments.uploadId#" >
			</cfstoredProc>
		<cfreturn />
	</cffunction>


<!---------------------------------------------------------------------------------------------------------------------
	***********************************************************************************************************************
	------------------------------------------  BULK UPLOAD FUNCTION STARTS HERE	---------------------------------------
	***********************************************************************************************************************
	---------------------------------------------------------------------------------------------------------------------->

	<cffunction name="logUpload" output="false">
		<cfargument name="CFEvent" type="struct" required="true">
		<cfscript>
			var data			= cfevent;
			var message			= data.message;
			var filePath 		= data.filePath;
			var fileName 		= data.fileName;
			var fileSize		= data.fileSize;
			var arrCorrections	= ArrayNew(1);
			var arrParseResult	= ArrayNew(1);
			var qryResult		= structNew();
			if (NOT IsDefined("CFEvent.Data.file")) {
					CFEvent.Data.file="defaultEventLog"; }
			if (NOT IsDefined("CFEvent.Data.type")) {
				CFEvent.Data.type="info"; }
		</cfscript>

		<cfquery name="qInsBBUploadLog" datasource="#application.datasource#">
			DECLARE  @upload_id int,
			 		 @upload_date datetime,
					 @user_id varchar(50),
					 @single_file varchar(255)

		  	SET @upload_date = getdate()
	  		SET @user_id = '#data.userStruct.User_ID#'
	  		SET @single_file ='#data.fileName#'

			INSERT INTO BB_upload_log (
			User_ID,
			total_header_count ,
			total_header_count_failed ,
			total_header_count_loaded ,
			total_detail_count ,
			total_detail_count_failed,
			total_detail_count_loaded,
			upload_date ,
			upload_status,
			header_file_name,
			detail_file_name  ,
			Upload_Type,
			Upload_Type_Desc
			)
	  SELECT
			@user_id,
			0,
			0,
			0,
			0,
			0,
			0,
			@upload_date,
			'File Received',
			@single_file,
			@single_file,
			2,
			1

		  SELECT
		  	Upload_ID
		  FROM
		  	BB_upload_log
		  WHERE User_ID = @user_id AND Upload_Status = 'File Received' AND Upload_Date = @Upload_Date AND Header_File_Name = @single_file
		</cfquery>

		<cfset fileSizeMB = (fileSize  /1024)/1024 />
			<cfif fileSizeMB GT 8>
				 <cfquery name="qInsBBUploadLog" datasource="#application.datasource#">
					UPDATE
						BB_upload_log
					SET
						upload_status = 'Upload Failed::File size is greater than 8MB'
					WHERE
						upload_ID = #qInsBBUploadLog.Upload_ID#
				</cfquery>
				<cfscript>
					//message = 'UPLOAD ERROR: #message# :: #cfcatch.message# #cfcatch.Detail#';
//					<strong>The file upload failed due to one of the below reasons:</strong><br>a)
					message = '<br>The uploaded file failed due to its size being 8MB or greater. <br>Note:  The file size being so large can be due to there being many rows with empty <br>data. To remove the rows with empty data follow these steps: <br>highlight any empty rows, right click and select delete.';
					msg = structNew();
					// msg.headers = structNew();
					// msg.headers.gatewayid = "cfData";
					// msg.headers['TYPE'] = "DataServicesMessaging";
					 msg.body = structNew();
					 msg.body['message'] =  message;
					 msg.body['arrParseResult'] =  arrParseResult;
					 msg.body['arrCorrections'] =  arrCorrections;
					 msg.body['sFileName'] =  fileName;
					 msg.body['serial'] = timeformat(now(),"long");
					 msg.body['user'] = data.userStruct.user_code;
					 msg.body['user_Id'] = data.userStruct.User_ID;
					 msg.destination = "ColdFusionGateway";
					 //sendGatewayMessage("cfData",msg);
					 WsPublish("cfData",SerializeJSON(msg));
				</cfscript>
				<cfreturn />
			</cfif>

		<cfset arrParseResult = this.BulkFileReader(filePath,fileName,data,qInsBBUploadLog.Upload_ID) />
			<!--- make sure temp table is not corrupted with onother sessions data --->
	</cffunction>

	<cffunction name="BulkFileReader" access="public" output="false" returntype="any" hint="Changes the column name of the given query.">
		<cfargument name="theFile" default="" type="string" required="true" hint="Path with FileName" >
		<cfargument name="ulFileName" default="" type="string" required="true" hint="FileName" >
	 	<cfargument name="data" default="" type="struct" required="true" hint="data" >
		<cfargument name="UploadID" default="" type="any" required="true" hint="upload_id" >

		<cfscript>
			var arrResult		= ArrayNew(1);
			var errorMsg		= '';
			var arrCorrections	= ArrayNew(1);
			var arrParseResult	= ArrayNew(1);
			var qryResult		= structNew();
			var msg 			= structNew();
			data 				= arguments.data;
			message				=	data.message;
		</cfscript>

		<cfset bbUploadManager = createObject("component","mvc.Models.Billback.BillbackUploadManager") />
 		<!--- Create the temp file to be used to insert the Bulk Data --->
 		<cfquery name="Dump_Data_To_Table" datasource="#application.datasource#">
	 	 	IF object_id('tempdb..##BB_Claim_Single_File_BLK_INS') IS NOT NULL
			BEGIN
				DROP TABLE ##BB_Claim_Single_File_BLK_INS
			END

		  CREATE TABLE ##BB_Claim_Single_File_BLK_INS(
	 	  [Company_Code] [varchar](max),
		  [Payee_Number] [varchar](max),
		  [Payee_Name] [varchar](max),
		  [Customer_Invoice_Number] [varchar](max),
		  [Performance_Period_Start_Date] [varchar](max),
		  [Performance_Period_End_Date] [varchar](max),
		  [Invoice_Date] [varchar](max),
		  [Expected_Payment_Amount] [varchar](max),
		  [SAP_Distributor_Number] [varchar](max),
		  [Customer_Distributor_Code] [varchar](max),
		  [Customer_Distributor_Name] [varchar](max),
		  [Customer_Distributor_Address] [varchar](max),
		  [Customer_Distributor_City] [varchar](max),
		  [Customer_Distributor_State] [varchar](max),
		  [Customer_Distributor_Zip] [varchar](max),
		  [Customer_Promotion_Code] [varchar](max),
		  [Customer_Promotion_Description] [varchar](max),
		  [GMI_Bid_Number] [varchar](max),
		  [GMI_Promotion_Number] [varchar](max),
		  [Payment_Type_Code_BD_VR] [varchar](max),
		  [SAP_Promoted_Customer_Number] [varchar](max),
		  [Customer_GMI_Product_Code] [varchar](max),
		  [GMI_UPC_Code] [varchar](max),
		  [GMI_Base_Product_Code] [varchar](max),
		  [Customer_Product_Code] [varchar](max),
		  [Customer_Product_Description] [varchar](max),
		  [Unit_of_Measure] [varchar](max),
		  [Invoice_Quantity]  [varchar](max),
		  [Customer_Case_Rate] [varchar](max),
		  [Customer_Payment_Amount]  [varchar](max),
		  [Operator_Unit_ID]  [varchar](max),
		  [Operator_Unit_Name]  [varchar](max),
		  [Operator_Unit_Address_Line_1]  [varchar](max),
		  [Operator_Unit_Address_Line_2]  [varchar](max),
		  [Operator_Unit_City]  [varchar](max),
		  [Operator_Unit_State]  [varchar](max),
		  [Operator_Unit_Zip_Code]  [varchar](max),
	   	  [Billback_Title] [varchar](max),
		  [Uploaded_User_ID] [varchar](50),
  		  [Sheet_Name] [varchar](255),
		  [Upload_File_Name] [varchar](255)
 		  )
	 	  </cfquery>
<!---  [Uploaded_User_ID] [varchar](50),
  		  [Sheet_Name] [varchar](255),
		  [Upload_File_Name] [varchar](255)
		   --->

   			<cfif FindNoCase("E:", arguments.theFile)>
				<cfset arguments.theFile  = "\\" & Application.WebServerName & Replace(arguments.theFile, "E:", "")>
			<cfelseif FindNoCase("F:", arguments.theFile)>
				<cfset arguments.theFile  = "\\" & Application.WebServerName & Replace(arguments.theFile, "F:", "")>
			<cfelseif FindNoCase("C:", arguments.theFile)>
				<cfset arguments.theFile  = "\\" & Application.WebServerName & Replace(arguments.theFile, "C:", "")>
			<cfelse>
				<cfset arguments.theFile  = "\\" & Application.WebServerName & Replace(arguments.theFile, "D:", "")>
			</cfif>
		<cftry>
		 <cfquery name="qInsBBUploadLog" datasource="#application.datasource#">
			UPDATE
				BB_upload_log
			SET
				upload_status = 'Transferring File Data to DB...'
			WHERE
				upload_ID = #arguments.UploadID#
		</cfquery>
		  <cfstoredproc procedure="Upload_Billback_Data_SSIS" datasource="#application.datasource#">
			<cfprocparam type="IN" cfsqltype="cf_sql_varchar"  dbVarName = "@Complete_File_Path " value="#arguments.theFile#">
			<cfprocparam type="IN" cfsqltype="cf_sql_varchar"  dbVarName = "@Uploaded_User_ID" value="#request.AccessStructure.User_ID#">
			<cfprocparam type="IN" cfsqltype="cf_sql_varchar"  dbVarName = "@Upload_File_Name " value="#arguments.ulFileName#">
		 	<cfprocparam type="IN" cfsqltype="cf_sql_integer"  dbVarName = "@Upload_ID" value="#arguments.UploadID#">
		  </cfstoredProc>

		<cfquery name="checkUpload" datasource="#application.datasource#">
			select  top 1 Upload_File_Name,*
			FROM
			 ##BB_Claim_Single_File_BLK_INS
			WHERE
				Upload_File_Name = '#arguments.ulFileName#'
		</cfquery>

	 <!--- <cfif arrParseResult[1] NEQ 'Invalid File Type' && checkUpload.recordCount> --->
		<cfif checkUpload.recordCount>
			 <cfquery name="qInsBBUploadLog" datasource="#application.datasource#">
				UPDATE
					BB_upload_log
				SET
					upload_status = 'Starting Data Validation...'
				WHERE
					upload_ID = #arguments.UploadID#
			</cfquery>
			 <cfstoredproc procedure="Upload_E_Invoice_Single_File_Parser" datasource="#application.datasource#">
				 <cfprocparam type="IN" cfsqltype="cf_sql_integer"  dbVarName = "@Upload_ID" value="#arguments.UploadID#">
				<cfprocresult name = qryResult>
			</cfstoredProc>

		<cfelse>
			<!--- <cfset message = 'Parse Error [#arrParseResult[1]#] #message#'/> --->
			<cfset message= '' />
		</cfif>
		<cfscript>
				//this.dmp(checkUpload);
				if(isDefined('qryResult') && StructKeyExists(qryResult,'TOTAL_HEADER_COUNT_FAILED') ){
					for (x = 1; x <= qryResult.RecordCount; x=x+1) {
						if(qryResult.UPLOAD_ID[x] != ''){
							uploadId 		= qryResult.UPLOAD_ID[x];
						bbHeaderID 		= qryResult.BB_UPLOAD_HEADER_ERROR_CORRECTION_ID[x];
						bbUploadHeader 	= getOneHeaderRow(uploadID=uploadId, BBUploadHeaderErrorCorrectionID=bbHeaderID);
						ArrayAppend(arrCorrections,duplicate(bbUploadHeader));
						}
					}
				}
				else{
					if(isDefined('qryResult') && StructKeyExists(qryResult,'ERRORMESSAGE')){
						message = '[DB Error: #qryResult.ERRORMESSAGE#] #message#';
						updBBUploadLogRet = updBBUploadLog('#qryResult.ERRORMESSAGE#','#arguments.UploadID#');
					}
					qryResult = structNew();
					qryResult.TOTAL_HEADER_COUNT = 0;
					qryResult.TOTAL_HEADER_COUNT_FAILED = 0;
					qryResult.TOTAL_HEADER_COUNT_LOADED = 0;
				}

				message = '[Total:#qryResult.TOTAL_HEADER_COUNT#  Invalid:#qryResult.TOTAL_HEADER_COUNT_FAILED#  Valid:#qryResult.TOTAL_HEADER_COUNT_LOADED#]  #message#';
				msg = structNew();
				 msg.body = structNew();
				 msg.body['message'] =  message;
				 msg.body['arrParseResult'] =  arrParseResult;
				 msg.body['arrCorrections'] =  arrCorrections;
				 msg.body['sFileName'] =  arguments.ulFileName;
				 msg.body['serial'] = timeformat(now(),"long");
				 msg.body['user'] = data.userStruct.user_code;
				 msg.body['user_Id'] = request.AccessStructure.User_ID;
				 //msg.destination = "ColdFusionGateway";
				 //sendGatewayMessage("cfData",msg);
				 WsPublish("cfData",SerializeJSON(msg));
			</cfscript>
			<cfcatch type="any" >
				<!--- SEND ERROR BACK TO UPLOAD --->
				<cfscript>
					message = '<br><strong>The file upload failed due to one of the below reasons:</strong><br>a) The file is not an acceptable type(valid types are: xls and xlsx).<br>b) The file uploaded seems to be corrupt and could not be read.<br>' & cfcatch.message & '<br>' & cfcatch.Detail;
					msg = structNew();
					 msg.body = structNew();
					 msg.body['message'] =  message;
					 msg.body['arrCorrections'] =  arrCorrections;
					 msg.body['arrParseResult'] =  arrParseResult;
					 msg.body['sFileName'] =  arguments.ulFileName;
					 msg.body['serial'] = timeformat(now(),"long");
					 msg.body['user'] = data.userStruct.user_code;
					 msg.body['user_Id'] = request.AccessStructure.User_ID;
					 //msg.destination = "ColdFusionGateway";
					 //sendGatewayMessage("cfData",msg);
					 WsPublish("cfData",SerializeJSON(msg));
				</cfscript>
			<cfset msg.messge = cfcatch.message  />
			<cfset msg.Detail = cfcatch.Detail />
			</cfcatch>
		</cftry>
		<cfreturn msg/>
	</cffunction>

	<cffunction name="updBBUploadLog" returntype="any" access="remote">
		<cfargument name="ErrorMessage" type="string" default="">
		<cfargument name="uploadID" type="numeric" required="false" default="0">

		<cfquery name="qInsBBUploadLog" datasource="#application.datasource#">
			UPDATE
				BB_Upload_Log
			SET
				Upload_Status = 'Verify Column K & M in the Uploaded Excel sheet [#arguments.ErrorMessage#]'
				WHERE
			Upload_ID = #arguments.UploadID#
		</cfquery>

		<cfreturn 1 />
	</cffunction>

	<!---
		11-Oct-2013/Anand Rao
		This function will be called when clicking on the "Search" button in the Raw EDI tab inside the upload
		tab. The user will need to enter a search criteria and do the search.
	--->
	<cffunction name="getRawEDIHeaderData"   access="remote" hint="Return_RawEDI" returntype="any">
		<cfargument name="searchFilters" default="" type="any" required="true" hint="SearcFilters">
		<cfargument name="startRow" type="numeric" required="false" default="0">
		<cfargument name="endRow" type="numeric" required="false" default="0">
		<cfargument name="sortColumn" type="string" required="false" default="">
		<cfargument name="sortOrder" type="string" required="false" default="">

		<cfset var end_row = arguments.endRow - arguments.startRow>

		<cfquery name="qRawEDIHeaderData" datasource="#application.datasource#">
		SELECT  *,Rows_Cnt = COUNT(1) OVER()
		FROM (
			SELECT
			DISTINCT
				BB_upload_log.Upload_ID,
				Billback_Upload_III_PH_Log.Billback_Upload_III_PH_ID,
				Billback_Upload_III_PH_log.Claim_Num,
				Billback_Upload_III_PH_log.Claim_Date,
				Billback_Upload_III_PH_log.Vendor_ID,
				VM.Vendor_Name,
				<!---
				-- Billback_Upload_III_PH_log.Distributor_ID,
				--	Billback_Upload_III_PD_log.Agreement_Num,
				-- 	Billback_Upload_III_PD_log.Agreement_Name,
				--->
				BSA_Foodservice_Customers.ship_to as Distributor_ID,
				BSA_Foodservice_Customers.Name AS Distributor_Name,
				Billback_Upload_III_PH_log.E_Total_Claimed_Amt,
				Billback_Upload_III_PH_log.Tot_Volume,
				CASE WHEN Billback_Upload_III_PH_Log.Deleted = 1 THEN
					Billback_Upload_III_PH_Log.Deleted_Date
				ELSE
					NULL
				END AS Deleted_Date,
				CASE WHEN Billback_Upload_III_PH_Log.Deleted = 1 THEN
					usr.Name_First + ' ' + usr.Name_Last
				ELSE
					NULL
				END AS Deleted_By
			FROM
				BB_upload_log
				INNER JOIN
					Billback_Upload_III_PH_Log ON Billback_Upload_III_PH_Log.Upload_ID = BB_upload_log.upload_id
				INNER JOIN Billback_Upload_III_PD_log ON
					Billback_Upload_III_PH_Log.Billback_Upload_III_PH_ID = Billback_Upload_III_PD_log.Billback_Upload_III_PH_ID AND
					Billback_Upload_III_PH_Log.upload_ID = Billback_Upload_III_PD_log.upload_ID
					/* AND Billback_Upload_III_PD_log.Deleted = 0 */

				LEFT JOIN Vendor_Master  VM ON  Billback_Upload_III_PH_log.Vendor_ID = VM.Vendor_ID
				LEFT JOIN BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Upload_III_PH_log.Distributor_ID
				LEFT JOIN _Users usr ON usr.User_ID = Billback_Upload_III_PH_Log.Updated_By
				WHERE
					/*
					Billback_Upload_III_PH_Log.Deleted = 0 and BB_upload_log.deleted = 0 AND
					*/

					BB_upload_Log.Upload_Type= 3 AND
					BB_upload_Log.Upload_Type_Desc = 4 AND
					(BB_upload_Log.Source_Code = 'USFS' OR  BB_upload_Log.Source_Code = 'SYSCO')
				<cfif arguments.searchFilters.BBNumberKeyword NEQ "">
					AND Billback_Upload_III_PH_log.Claim_Num like '%#arguments.searchFilters.BBNumberKeyword#%'
				</cfif>
				<cfif arguments.searchFilters.BBDateKeyboard NEQ "">
					AND Billback_Upload_III_PH_log.Claim_Date = <cfqueryparam value="#arguments.searchFilters.BBDateKeyboard#" cfsqltype="cf_sql_date">
				</cfif>
				<cfif arguments.searchFilters.VendorNumber NEQ "">
					AND Billback_Upload_III_PH_log.Vendor_ID like '%#arguments.searchFilters.VendorNumber#%'
				</cfif>
				<cfif arguments.searchFilters.VendorName NEQ "">
					AND VM.Vendor_Name like '%#arguments.searchFilters.VendorName#%'
				</cfif>
				<cfif arguments.searchFilters.agreementNumber NEQ "">
					AND Billback_Upload_III_PD_log.Agreement_Num like '%#arguments.searchFilters.agreementNumber#%'
				</cfif>
				<cfif arguments.searchFilters.agreementName NEQ "">
					AND Billback_Upload_III_PD_log.Agreement_Name like '%#arguments.searchFilters.agreementName#%'
				</cfif>
				<cfif arguments.searchFilters.PayeeNumber NEQ "">
					<!---AND Billback_Upload_III_PH_log.Distributor_ID = '#arguments.searchFilters.PayeeNumber#'--->
					AND BSA_Foodservice_Customers.ship_to like '%#arguments.searchFilters.PayeeNumber#%'
				</cfif>
				<cfif arguments.searchFilters.PayeeName NEQ "">
					AND BSA_Foodservice_Customers.Name LIKE '%#arguments.searchFilters.PayeeName#%'
				</cfif>
				<!--- Below search criteria are only for the new EDI tool and not for the Adobe Flex tool, and that is why
				we need the "IsDefined" logic.
				--->
				<cfif IsDefined("arguments.searchFilters.UploadID") AND arguments.searchFilters.UploadID NEQ "">
					AND BB_upload_log.Upload_ID = #arguments.searchFilters.UploadID#
				</cfif>
				<cfif IsDefined("arguments.searchFilters.HdrID") AND arguments.searchFilters.HdrID NEQ "">
					AND Billback_Upload_III_PH_Log.Billback_Upload_III_PH_ID = #arguments.searchFilters.HdrID#
				</cfif>
				<cfif IsDefined("arguments.searchFilters.TotalAmt") AND  arguments.searchFilters.TotalAmt NEQ "">
					AND Billback_Upload_III_PH_log.E_Total_Claimed_Amt = <cfqueryparam value="#arguments.searchFilters.TotalAmt#" cfsqltype="cf_sql_float">
				</cfif>
				<cfif IsDefined("arguments.searchFilters.Volume") AND  arguments.searchFilters.Volume NEQ "">
					AND Billback_Upload_III_PH_log.Tot_Volume = <cfqueryparam value="#arguments.searchFilters.Volume#" cfsqltype="cf_sql_float">
				</cfif>
				<cfif IsDefined("arguments.searchFilters.DeletedBy") AND  arguments.searchFilters.DeletedBy NEQ "">
					AND Billback_Upload_III_PH_Log.Deleted = 1
					AND usr.Name_First + ' ' + usr.Name_Last LIKE '%#arguments.searchFilters.DeletedBy#%'
				</cfif>
				<cfif IsDefined("arguments.searchFilters.DeletedDate") AND  arguments.searchFilters.DeletedDate NEQ "">
					AND Billback_Upload_III_PH_Log.Deleted = 1
					AND Billback_Upload_III_PH_Log.Deleted_Date = <cfqueryparam value="#arguments.searchFilters.DeletedDate#" cfsqltype="cf_sql_date">
				</cfif>
			) AS tmp

			<!--- arguments.endRow is 0 when we call the query from Flex --->
			<cfif arguments.endRow gt 0>
				ORDER BY
				<cfif arguments.sortColumn neq "">
					<cfswitch expression="#arguments.sortColumn#">
						<cfcase value="Claim_Date">CAST(Claim_Date As datetime)</cfcase>
						<cfcase value="E_Total_Claimed_Amt">CAST(E_Total_Claimed_Amt As float)</cfcase>
						<cfcase value="Tot_Volume">CAST(Tot_Volume As float)</cfcase>
						<cfdefaultcase>#arguments.sortColumn#</cfdefaultcase>
					</cfswitch>
					#arguments.sortOrder#
				<cfelse>
				Upload_ID DESC
				</cfif>

				OFFSET #arguments.startRow# ROWS
				FETCH NEXT #end_row# ROWS ONLY
			</cfif>
		</cfquery>

		<cfreturn qRawEDIHeaderData />
	</cffunction>

	<cffunction name="getRawEDIDetailDataQuery" access="public" returntype="query">
		<cfargument name="UploadID" type="numeric" required="true">
		<cfargument name="BBUploadIIIPHID" type="numeric" required="true">
		<cfargument name="filterModel" type="any" required="false" default=#StructNew()#>
		<cfargument name="startRow" type="numeric" required="false" default="0">
		<cfargument name="endRow" type="numeric" required="false" default="0">
		<cfargument name="sortColumn" type="string" required="false" default="">
		<cfargument name="sortOrder" type="string" required="false" default="">

		<cfset var end_row = arguments.endRow - arguments.startRow>

		<cfquery name="qRawEDIDetailData" datasource="#application.datasource#">
			IF OBJECT_ID ('tempdb..##tmp_PH_Log') is not null
			drop table ##tmp_PH_Log
			SELECT Billback_Upload_III_PH_log.*
			INTO ##tmp_PH_Log
			FROM Billback_Upload_III_PH_log
			WHERE Upload_ID = <cfqueryparam value="#arguments.UploadID#" cfsqltype="cf_sql_integer">
			AND Billback_Upload_III_PH_ID = <cfqueryparam value="#arguments.BBUploadIIIPHID#" cfsqltype="cf_sql_integer">
			CREATE CLUSTERED INDEX tmp_PH_Log on ##tmp_PH_Log(Upload_ID)

			IF OBJECT_ID ('tempdb..##tmp_PD_Log') is not null
			DROP TABLE ##tmp_PD_Log
			SELECT Billback_Upload_III_PD_log.*
			INTO	##tmp_PD_Log
			FROM	Billback_Upload_III_PD_log
			WHERE Upload_ID = <cfqueryparam value="#arguments.UploadID#" cfsqltype="cf_sql_integer">
			AND Billback_Upload_III_PH_ID = <cfqueryparam value="#arguments.BBUploadIIIPHID#" cfsqltype="cf_sql_integer">

			CREATE CLUSTERED INDEX tmp_PD_Log on ##tmp_PD_Log(Upload_ID,Billback_Upload_III_PH_ID)

			IF OBJECT_ID ('tempdb..##tmp_EDI_usfs_1')is not null
			DROP TABLE ##tmp_EDI_usfs_1
			SELECT *,EDI_USFS_TO_CREATE_BB.SIS_Invoice_Num AS Claim_Num,ISNULL(EDI_USFS_TO_CREATE_BB.Payee,EDI_USFS_TO_CREATE_BB.Remit_To_ID) as claim_org_ID
			INTO	##tmp_EDI_usfs_1
			FROM	EDI_USFS_TO_CREATE_BB
			WHERE	EXISTS(SELECT *
							FROM ##tmp_PH_Log
							WHERE	##tmp_PH_Log.upload_ID = EDI_USFS_TO_CREATE_BB.Upload_ID)

			CREATE CLUSTERED INDEX tmp_EDI_usfs_1_IDX ON ##tmp_EDI_usfs_1(Upload_ID,Claim_Num,claim_org_ID)

			IF OBJECT_ID ('tempdb..##tmp_EDI_sysco_1')is not null
			DROP TABLE ##tmp_EDI_sysco_1
			SELECT *,EDI_SYSCO_TO_CREATE_BB.Billback_Invoice_Number  as Claim_Num,ISNULL(EDI_SYSCO_TO_CREATE_BB.Shipto,EDI_SYSCO_TO_CREATE_BB.Distributor_Name_ID) as claim_org_ID
			INTO	##tmp_EDI_sysco_1
			FROM	EDI_SYSCO_TO_CREATE_BB
			WHERE	EXISTS(SELECT *
				FROM ##tmp_PH_Log
				WHERE	##tmp_PH_Log.upload_ID = EDI_SYSCO_TO_CREATE_BB.Upload_ID)

			CREATE CLUSTERED INDEX tmp_EDI_sysco_1_IDX ON ##tmp_EDI_sysco_1(Upload_ID,Claim_Num,claim_org_ID)

			SELECT  *,Rows_Cnt = COUNT(1) OVER()
			FROM (
			SELECT DISTINCT BB_upload_log.upload_id ,
							Billback_Upload_III_PH_log.Billback_Upload_III_PH_ID,
							Billback_Upload_III_PH_log.Claim_Num,
							Billback_Upload_III_PH_log.Claim_Date,
							Billback_Upload_III_PH_log.Period_St_Date,
							Billback_Upload_III_PH_log.Period_End_Date,
							Billback_Upload_III_PD_log.Billback_Upload_III_PD_ID,
							Billback_Upload_III_PD_log.Agreement_Num,
							Billback_Upload_III_PD_log.Agreement_Name,

							EDI_USFS_TO_CREATE_BB.Vendor_Loc_Num ,--(USFS only)
							EDI_USFS_TO_CREATE_BB.Vendor_Inv_Num ,-- USFS only)
							<!---Billback_Upload_III_PH_log.Agreement_Num,
							Billback_Upload_III_PH_log.Agreement_Name,
							--->
							Billback_Upload_III_PD_log.DC_AC_Name,
							Billback_Upload_III_PD_log.DC_AC_Num,
							Billback_Upload_III_PD_log.ST_Address_1,
							Billback_Upload_III_PD_log.ST_City,
							Billback_Upload_III_PD_log.ST_State,
							Billback_Upload_III_PD_log.ST_Zip_Code,
							Billback_Upload_III_PD_log.CS_QTY,
							CASE WHEN BB_upload_log.Source_Code ='SYSCO' then EDI_SYSCO_TO_CREATE_BB.UPC_code
								ELSE EDI_USFS_TO_CREATE_BB.UPC_NUM
							END AS UPC_CODE,

							CASE WHEN BB_upload_log.Source_Code ='SYSCO' then EDI_SYSCO_TO_CREATE_BB.Manufacture_Item_ID
		 					ELSE EDI_USFS_TO_CREATE_BB.Seller_Item_Num
							END AS Manufacture_Item_ID ,
							Billback_Upload_III_PD_log.DC_Product_Num,
							Billback_Upload_III_PD_log.Award_Amt,
							Billback_Upload_III_PD_log.DC_Product_Desc,
							Billback_Upload_III_PD_Log.Deleted_Date,
							CASE WHEN Billback_Upload_III_PD_Log.Deleted = 1 THEN
								usr.Name_First + ' ' + usr.Name_Last
							ELSE
								NULL
							END AS Deleted_By

							FROM BB_upload_log
							INNER JOIN  ##tmp_PH_Log Billback_Upload_III_PH_Log
							ON Billback_Upload_III_PH_Log.Upload_ID = BB_upload_log.upload_id
							INNER JOIN ##tmp_PD_Log Billback_Upload_III_PD_log
							ON 	Billback_Upload_III_PH_Log.Billback_Upload_III_PH_ID = 	Billback_Upload_III_PD_log.Billback_Upload_III_PH_ID
							AND Billback_Upload_III_PH_Log.upload_ID = Billback_Upload_III_PD_log.upload_ID
						   /* AND Billback_Upload_III_PD_log.Deleted = 0 */
							LEFT JOIN Vendor_Master VM
							ON Billback_Upload_III_PH_log.Vendor_ID = VM.Vendor_ID
							LEFT JOIN BSA_Foodservice_Customers
							ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Upload_III_PH_log.Distributor_ID
							LEFT JOIN ##tmp_EDI_usfs_1 EDI_USFS_TO_CREATE_BB
										  ON          EDI_USFS_TO_CREATE_BB.Upload_ID = BB_upload_log.Upload_ID
										  AND         BB_upload_log.Source_Code ='USFS'
										  AND         EDI_USFS_TO_CREATE_BB.Claim_Num = ISNULL(Billback_Upload_III_PH_Log.Original_Claim_Num ,Billback_Upload_III_PH_Log.Claim_Num )
										  AND         EDI_USFS_TO_CREATE_BB.Shipto  = Billback_Upload_III_PH_Log.Claim_Org_ID
										  AND         EDI_USFS_TO_CREATE_BB.Buyer_Item_Num  = Billback_Upload_III_PD_Log.DC_Product_Num
										  and         EDI_USFS_TO_CREATE_BB.Ship_To_ID = Billback_Upload_III_PD_Log.DC_AC_NUM
						   LEFT JOIN ##tmp_EDI_sysco_1 EDI_SYSCO_TO_CREATE_BB
												ON EDI_SYSCO_TO_CREATE_BB.Upload_ID = BB_upload_log.Upload_ID
												AND         BB_upload_log.Source_Code ='SYSCO'
												AND         EDI_SYSCO_TO_CREATE_BB.Claim_Num =ISNULL(Billback_Upload_III_PH_Log.Original_Claim_Num ,Billback_Upload_III_PH_Log.Claim_Num )
												AND         EDI_SYSCO_TO_CREATE_BB.Shipto  = Billback_Upload_III_PH_Log.Claim_Org_ID
												AND         EDI_SYSCO_TO_CREATE_BB.customer_invoice_Item  = Billback_Upload_III_PD_Log.DC_Product_Num
										  and         EDI_SYSCO_TO_CREATE_BB.Ship_To_Name_ID = Billback_Upload_III_PD_Log.DC_AC_NUM

							LEFT JOIN _Users usr ON usr.User_ID = Billback_Upload_III_PD_Log.Updated_By

							WHERE
							/*
								Billback_Upload_III_PH_Log.Deleted = 0 and BB_upload_log.deleted = 0 AND
							*/
							BB_upload_Log.Upload_Type= 3 AND BB_upload_Log.Upload_Type_Desc = 4
							AND
							Billback_Upload_III_PH_Log.Upload_ID = <cfqueryparam value="#arguments.UploadID#" cfsqltype="cf_sql_integer">
						  AND
						  Billback_Upload_III_PH_Log.Billback_Upload_III_PH_ID = <cfqueryparam value="#arguments.BBUploadIIIPHID#" cfsqltype="cf_sql_integer">

						<cfif StructCount(arguments.filterModel) GT 0>
							<cfloop collection="#arguments.filterModel#" item="SearchColumn">
								<cfif SearchColumn eq "CLAIM_NUM">AND Billback_Upload_III_PH_log.Claim_Num</cfif>
								<cfif SearchColumn eq "PERIOD_ST_DATE">AND Billback_Upload_III_PH_log.Period_St_Date</cfif>
								<cfif SearchColumn eq "PERIOD_END_DATE">AND Billback_Upload_III_PH_log.Period_End_Date</cfif>
								<cfif SearchColumn eq "AGREEMENT_NUM">AND Billback_Upload_III_PD_log.Agreement_Num</cfif>
								<cfif SearchColumn eq "AGREEMENT_NAME">AND Billback_Upload_III_PD_log.Agreement_Name</cfif>
								<cfif SearchColumn eq "VENDOR_LOC_NUM">AND EDI_USFS_TO_CREATE_BB.Vendor_Loc_Num</cfif>
								<cfif SearchColumn eq "VENDOR_INV_NUM">AND EDI_USFS_TO_CREATE_BB.Vendor_Inv_Num</cfif>
								<cfif SearchColumn eq "DC_AC_NAME">AND Billback_Upload_III_PD_log.DC_AC_Name</cfif>
								<cfif SearchColumn eq "DC_AC_NUM">AND Billback_Upload_III_PD_log.DC_AC_Num</cfif>
								<cfif SearchColumn eq "ST_ADDRESS_1">AND Billback_Upload_III_PD_log.ST_Address_1</cfif>
								<cfif SearchColumn eq "ST_CITY">AND Billback_Upload_III_PD_log.ST_City</cfif>
								<cfif SearchColumn eq "ST_STATE">AND Billback_Upload_III_PD_log.ST_State</cfif>
								<cfif SearchColumn eq "ST_ZIP_CODE">AND Billback_Upload_III_PD_log.ST_Zip_Code</cfif>
								<cfif SearchColumn eq "CS_QTY">AND Billback_Upload_III_PD_log.CS_QTY</cfif>
								<cfif SearchColumn eq "UPC_CODE">
								AND
								(
								CASE BB_upload_log.Source_Code
									WHEN 'SYSCO'
										THEN EDI_SYSCO_TO_CREATE_BB.UPC_code
									ELSE
										EDI_USFS_TO_CREATE_BB.UPC_NUM
								END
								)
								</cfif>
								<cfif SearchColumn eq "MANUFACTURE_ITEM_ID">
								AND
								(
								CASE BB_upload_log.Source_Code
									WHEN 'SYSCO'
										THEN EDI_SYSCO_TO_CREATE_BB.Manufacture_Item_ID
									ELSE
										EDI_USFS_TO_CREATE_BB.Seller_Item_Num
								END
								)
								</cfif>
								<cfif SearchColumn eq "DC_PRODUCT_NUM">AND Billback_Upload_III_PD_log.DC_Product_Num</cfif>
								<cfif SearchColumn eq "AWARD_AMT">AND Billback_Upload_III_PD_log.Award_Amt</cfif>
								<cfif SearchColumn eq "DC_PRODUCT_DESC">AND Billback_Upload_III_PD_log.DC_Product_Desc</cfif>
								<cfif SearchColumn eq "DELETED_BY">AND Billback_Upload_III_PD_Log.Deleted = 1 AND usr.Name_First + ' ' + usr.Name_Last</cfif>
								<cfif SearchColumn eq "DELETED_DATE">AND Billback_Upload_III_PD_Log.Deleted = 1 AND Billback_Upload_III_PD_Log.Deleted_Date</cfif>

								<!--- get the filter conditions --->
								<cfset qryConditions = application.util.query.getAGGridfilterConditions(arguments.filterModel[SearchColumn])>
								#PreserveSingleQuotes(qryConditions)#

							</cfloop>
						</cfif>

			) AS tmp

			<!--- arguments.endRow is 0 when we call the query from Flex --->
			<cfif arguments.endRow gt 0>
				ORDER BY
				<cfif arguments.sortColumn neq "">
					<cfswitch expression="#arguments.sortColumn#">
						<cfcase value="PERIOD_ST_DATE">CAST(PERIOD_ST_DATE As datetime)</cfcase>
						<cfcase value="PERIOD_END_DATE">CAST(PERIOD_END_DATE As datetime)</cfcase>
						<cfcase value="AWARD_AMT">CAST(AWARD_AMT As float)</cfcase>
						<cfcase value="CS_QTY">CAST(CS_QTY As float)</cfcase>
						<cfdefaultcase>#arguments.sortColumn#</cfdefaultcase>
					</cfswitch>
					#arguments.sortOrder#
				<cfelse>
				Upload_ID DESC
				</cfif>

				OFFSET #arguments.startRow# ROWS
				FETCH NEXT #end_row# ROWS ONLY
			</cfif>
		</cfquery>

		<cfreturn qRawEDIDetailData>

	</cffunction>


	<cffunction name="getRawEDIDetailData" access="remote" hint="Return_RawEDI Details" returntype="any">
		<cfargument name="argbbRawEDIHeader" type="mvc.Models.Billback.vos.BBRawEDIHeader" default="">

 		<cfset BBEDIDetailArr = ArrayNew(1)/>
		<cfset stReturnData = StructNew()>
		<cfset stReturnData = arguments.argbbRawEDIHeader />

		<cfset qRawEDIDetailData = getRawEDIDetailDataQuery(arguments.argbbRawEDIHeader.UploadID,arguments.argbbRawEDIHeader.BBUploadIIIPHID)>

		<cfset BBEDIDetailArr = ArrayNew(1) />
		<cfset iRowID = 0 />
		<cfloop query = "qRawEDIDetailData">
			<cfset iRowID = iRowID + 1 />
			<cfscript>
				BBEDIDtlObj = structNew();
				BBEDIDtlObj["__type__"] 			= "mvc.Models.Billback.vos.BBRawEDIDetail";
				BBEDIDtlObj["UploadID"] 			= qRawEDIDetailData.upload_id;
				BBEDIDtlObj["BBUploadIIIPHID"] 		= qRawEDIDetailData.Billback_Upload_III_PH_ID;
				BBEDIDtlObj["BBNumber"] 			= qRawEDIDetailData.Claim_Num;
				BBEDIDtlObj["BBDate"] 				= DateFormat(qRawEDIDetailData.Claim_Date,"mm/dd/yyyy");
				BBEDIDtlObj["PeriodStDate"] 		= DateFormat(qRawEDIDetailData.Period_St_Date,"mm/dd/yyyy");
				BBEDIDtlObj["PeriodEndDate"] 		= DateFormat(qRawEDIDetailData.Period_End_Date,"mm/dd/yyyy");
				BBEDIDtlObj["AgreementNum"] 		= qRawEDIDetailData.Agreement_Num;
				BBEDIDtlObj["AgreementName"] 		= qRawEDIDetailData.Agreement_Name;
				BBEDIDtlObj["VendorLocNum"] 		= qRawEDIDetailData.Vendor_Loc_Num;
				BBEDIDtlObj["VendorInvNum"] 		= qRawEDIDetailData.Vendor_Inv_Num;
				BBEDIDtlObj["DCACName"] 			= qRawEDIDetailData.DC_AC_Name;
				BBEDIDtlObj["DCACNum"] 				= qRawEDIDetailData.DC_AC_Num;
				BBEDIDtlObj["STAddress1"] 			= qRawEDIDetailData.ST_Address_1;
				BBEDIDtlObj["STCity"]	 			= qRawEDIDetailData.ST_City;
				BBEDIDtlObj["STState"] 				= qRawEDIDetailData.ST_State;
				BBEDIDtlObj["STZipCode"] 			= qRawEDIDetailData.ST_Zip_Code;
				BBEDIDtlObj["CSQTY"] 				= qRawEDIDetailData.CS_QTY;
				BBEDIDtlObj["UPCCODE"] 				= qRawEDIDetailData.UPC_CODE;
				BBEDIDtlObj["ManufactureItemID"] 	= qRawEDIDetailData.Manufacture_Item_ID;
				BBEDIDtlObj["DCProductNum"] 		= qRawEDIDetailData.DC_Product_Num;
				BBEDIDtlObj["AwardAmt"] 			= qRawEDIDetailData.Award_Amt;
				BBEDIDtlObj["DCProductDesc"] 		= qRawEDIDetailData.DC_Product_Desc;
				BBEDIDtlObj["DeletedBy"] 			= qRawEDIDetailData.Deleted_By;
				BBEDIDtlObj["DeletedDate"] 			= qRawEDIDetailData.Deleted_Date;

				arrayAppend(BBEDIDetailArr,BBEDIDtlObj);
			</cfscript>
		</cfloop>

		<cfset stReturnData.bbRawEDIDetail = BBEDIDetailArr />
	    <cfreturn stReturnData />

	</cffunction>

</cfcomponent>