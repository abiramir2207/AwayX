<cfcomponent extends="mvc.Models.SettingsService" output="false" displayname="AutoPayManager">
	
	<cffunction name="getAutoPayData" output="false" access="remote" returntype="Array">
		<cfscript>
			//set local variables
			var a = arguments;
			var qAutoPayData	= queryNew("");
			var objAutoPayGet 	= CreateObject("component","components.Billback.BBAutoReportGet");
			var stData = structNew();
			var stStatus = structNew();
			var arr = arrayNew(1);	
			stData["__type__"] = "mvc.Models.Admin.AutoPay.vos.AutoPayDetail";
			stStatus["__type__"] = "mvc.Models.Admin.AutoPay.vos.Status";
			//run the query
			//this.dmp(a);
			qAutoPayData = objAutoPayGet.getAutoPayData(a.dStart,a.dEnd,a.reportId,a.invoiceNumber);
			
			//reportId|reportStatus|Billback_id|bbCode|bbTitle|bbAmount|startDate|endDate|updDate|firstName|lastName|contractTitle|contractNumber|contractId|payeeName|payeeId
			for (intRow = 1 ; intRow LTE qAutoPayData.RecordCount ;intRow ++){
				stData["reportId"] = qAutoPayData.reportId[intRow];
				//STATUS
				stStatus["id"] =  qAutoPayData.statusId[intRow];
				stStatus["description"] =  objAutoPayGet.getReportStatus(qAutoPayData.statusId[intRow]);
				
				stData["reportStatus"] = duplicate(stStatus);
				stData["Billback_id"] = qAutoPayData.Billback_id[intRow];
				stData["bbCode"] = qAutoPayData.bbCode[intRow];
				stData["bbTitle"] = qAutoPayData.bbTitle[intRow];
				stData["reportTitle"] = qAutoPayData.reportTitle[intRow];
				stData["bbAmount"] = qAutoPayData.bbAmount[intRow];
				stData["pullbackAmount"] = qAutoPayData.pullbackAmount[intRow];
				stData["deviationAmount"] = qAutoPayData.deviationAmount[intRow];
				stData["exclusionAmount"] = qAutoPayData.exclusionAmount[intRow];
				stData["startDate"] = qAutoPayData.startDate[intRow];
				stData["endDate"] = qAutoPayData.endDate[intRow];
				stData["updDate"] = qAutoPayData.updDate[intRow];
				stData["firstName"] = qAutoPayData.firstName[intRow];
				stData["lastName"] = qAutoPayData.lastName[intRow];
				stData["contractTitle"] = qAutoPayData.contractTitle[intRow];
				stData["contractNumber"] = qAutoPayData.contractNumber[intRow];
				stData["compName"] = qAutoPayData.compName[intRow];
				stData["contractId"] = qAutoPayData.contractId[intRow];
				stData["payeeName"] = qAutoPayData.payeeName[intRow];
				stData["payeeId"] = qAutoPayData.payeeId[intRow];
				ArrayAppend(arr, duplicate(stData));
			}
			//return the billback struct
			return arr;
		</cfscript>
	
	</cffunction>
	
	<cffunction name="getReportSummary" access="remote" returntype="any">
		<cfargument name="ReportId"	required="no" type="any" default="0" />
		<cfscript>
			//set local variables
			var qAutoPayData	= queryNew("");
			var objAutoPayGet 	= CreateObject("component","components.Billback.BBAutoReportGet");
			var qAutoPayData = objAutoPayGet.getReportSummary(arguments.ReportId);
			var obj = structNew();
			//return the billback struct
			obj = queryRowToStruct(qAutoPayData);
			return obj;
		</cfscript>
	</cffunction>
	<!--- XXXXXXXXXXXX	approve	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="approveReport" access="remote" returntype="any">
		<cfargument name="ReportId"	required="yes" type="any" default="0" />
		<cfscript>
			//set local variables
			var qAutoPayData	= queryNew("");
			var objAutoPayGet 	= CreateObject("component","components.Billback.BBAutoReportGet");
			var objAutoPayUpd 	= CreateObject("component","components.Billback.BBAutoReportUpdate");
			var qAutoPayData = '';
			var obj = structNew();
			var objParms = structNew();
			
			objAutoPayUpd.approveReport(arguments.ReportId,request.accessStructure.User_Id);
			//obj.arr = getAutoPayData('','',arguments.ReportId);
			obj.reportId = arguments.ReportId;
			//return obj;
			return arguments.ReportId;
		</cfscript>
	</cffunction>
	<!--- XXXXXXXXXXXX	delete	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="deleteReport" access="remote" returntype="any">
		<cfargument name="ReportId"	required="yes" type="any" default="0" />
		<cfscript>
			//set local variables
			var qAutoPayData	= queryNew("");
			var objAutoPayGet 	= CreateObject("component","components.Billback.BBAutoReportGet");
			var objAutoPayUpd 	= CreateObject("component","components.Billback.BBAutoReportUpdate");
			//var qAutoPayData = objAutoPayGet.getReportSummary(arguments.ReportId);
			var obj = structNew();
			//this.dmp(qAutoPayData);
			//return the billback struct
			
			objAutoPayUpd.deleteReport(arguments.ReportId,request.accessStructure.User_Id);
			//obj = queryRowToStruct(qAutoPayData);
			return arguments.ReportId;
		</cfscript>
	</cffunction>
	<!--- XXXXXXXXXXXX	run	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="runReport" access="remote" returntype="any">
		<cfargument name="ReportId"	required="yes" type="any" default="0" />
		<cfscript>
			//set local variables
			var qAutoPayData	= queryNew("");
			var objAutoPayGet 	= CreateObject("component","components.Billback.BBAutoReportGet");
			var objAutoPayUpd 	= CreateObject("component","components.Billback.BBAutoReportUpdate");
			var qAutoPayData = '';
			var userId = request.accessStructure.User_Id;
			var obj = structNew();
			var props = structNew(); 
		    props.ReportId = ReportId;
		    props.userId = userId;
		    //build lock obj to send back
		    objAutoPayUpd.setReportProcess(1);
		    obj.reportId = arguments.ReportId;
			obj.lock = getReportLockInfo();
			objAutoPayUpd.setReportProcess(0);
			///THREAD -> SLEEP Test
			thread action="run" name="AutoPay_#ReportId#_user_#request.accessStructure.User_Id#" props="#props#"{
				objAutoPayUpd 	= CreateObject("component","components.Billback.BBAutoReportUpdate");
				objAutoPayUpd.runBBAutoCreate(0,props.ReportId);
				
				 msg.body = structNew();
				 msg.body['message'] =  'Report #props.ReportId# Ran ' & now();
				 msg.body['user_Id'] = props.userId;
				 msg.body['ReportId'] = props.ReportId;
				 msg.body['lock'] = getReportLockInfo();
				 msg.body['arr'] = getAutoPayData(dStart='',dEnd='',reportId=props.ReportId,invoiceNumber='');
				 msg.destination = "ColdFusionGateway";
				 this.dmp(msg);
				 //sendGatewayMessage("cfData",msg);
				 WsPublish("cfData",SerializeJSON(msg)); 
			};
			//obj.arr = getAutoPayData('','',arguments.ReportId);
			//obj.reportId = arguments.ReportId;
			//obj.lock = getReportLockInfo();
			//return obj;
			return obj;
		</cfscript>
	</cffunction>
	
	<!--- XXXXXXXXXXXX	getReportLock	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportLock" access="remote" returntype="mvc.Models.Entity.vos.Lock">
		<cfargument name="lock"	required="yes"	type="mvc.Models.Entity.vos.Lock" />
		<cfscript>
			//set local variables
			var qGetReportLockByMe = "";
			var icon 	= "";
			var tmpUnlock 	= "";
			var objAutoPayGet 	= CreateObject("component","components.Billback.BBAutoReportGet");
			var objAutoPayUpd 	= CreateObject("component","components.Billback.BBAutoReportUpdate");
			var local.lock = CreateObject("component","mvc.Models.Entity.vos.Lock");
			var qLockInfo = '';
			var bStatus = false;
			var userId = request.accessStructure.User_Id;
			//Check to see if report lockholder has an expired Session and Unlock if that is the case
			tmpUnlock	= objAutoPayUpd.UnlockReport();
			//if toggle flag is passed try lock/unlock
			if(arguments.lock.toggleLock){
				bStatus = true;
				if(objAutoPayGet.getReportLockByMe(userId,0)){
					bStatus = false;
				}
				objAutoPayUpd.lockReport(userId,bStatus);
			}
			//now get details to send to UI
			return getReportLockInfo();
		</cfscript>
		
	</cffunction>
	<!--- XXXXXXXXXXXX	getReportLockInfo	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="getReportLockInfo" access="remote" returntype="mvc.Models.Entity.vos.Lock">
		<cfscript>
			//set local variables
			var objAutoPayGet 	= CreateObject("component","components.Billback.BBAutoReportGet");
			var local.lock = CreateObject("component","mvc.Models.Entity.vos.Lock");
			var userId = request.accessStructure.User_Id;
			
			//now get details to send to UI
			qLockInfo = objAutoPayGet.getReportLockInfo();
			if(objAutoPayGet.getReportLock(userId,0) && !qLockInfo.Processing){
					//only locked if it is NOT Processing
				    local.lock.bLocked = true;
					local.lock.userLocked.id = qLockInfo.Locked_By_User_Id;
					local.lock.userLocked.fullName = qLockInfo.Name_First & ' ' & qLockInfo.Name_Last;
			}
			else if(qLockInfo.Processing){
				local.lock.bLocked = false;
				local.lock.userLocked.id = qLockInfo.Locked_By_User_Id;
				local.lock.userLocked.fullName = 'JOB PROCESSING';
			}
			else{
				//lock
				local.lock.bLocked = false;
			}
			return local.lock;
		</cfscript>
	</cffunction>
	
	<cffunction name="queryRowToStruct" access="public" returntype="any">
		<cfargument name="query" required="no" type="any" />
		<cfscript>
			// By default, do this to the first row of the query
			//var row = 1;
			// No. By using getRow() we can call this function sequentially and get the next record each time.
			// Or, we can pass the row number we want as the 2nd parameter as before.
			var row = query.getRow();
			//a var for looping
			var ii = 1;
			//the cols to loop over
			var cols = listToArray(query.columnList);
			//the struct to return
			var stReturn = structnew();
		
			// getRow() will return 0 if next() hasnt been called. 
			// So, to allow this function to work by calling it with one parameter and no previous call to next(), 
			// we need the following:
			if (row eq 0) row = 1; 
		
			//if there is a second argument, use that for the row number
			if(arrayLen(arguments) GT 1)
				row = arguments[2];
			//loop over the cols and build the struct from the query row
			for(ii = 1; ii lte arraylen(cols); ii++){
				stReturn[cols[ii]] = query[cols[ii]][row];
			}		
			//return the struct
			return stReturn;
		</cfscript>
	</cffunction>

</cfcomponent>