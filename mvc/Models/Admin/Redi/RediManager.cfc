<cfcomponent extends="mvc.Models.SettingsService" output="false" displayName="Redimanager">
	
	<cffunction name="getRediOpen" output="false" access="remote" returntype="Array">
		<cfscript>
			//set local variables
			var a = arguments;
			var qRediOpenData	= queryNew("");
			var objRediDAO 	= CreateObject("component","mvc.Models.Admin.Redi.RediDAO");
			var stData = structNew();
			var arr = arrayNew(1);	
			//run the query
			//var a = getTickCount();
			
			qRediOpenData = objRediDAO.getRediHeaderData();
			arr = getRediCorrectionHeaderObj(qRediOpenData);
			//arr[1] =  CreateObject("component","mvc.Models.Admin.Redi.vos.RediCorrectionHeader");
			
			//var b = getTickCount();
			//this.dmp(b-a);
			return arr;
		</cfscript>
	</cffunction>
	
	<cffunction name="getRediCorrectionHeaderObj" output="false" access="remote" returntype="array">
		<cfargument name="q" type="query" required="true"/>
		<cfscript>
			//set local variables  
			var a = arguments;
			var qRediSettingsData	= queryNew("");
			var objRediDAO 	= CreateObject("component","mvc.Models.Admin.Redi.RediDAO");
			var stData = structNew();
			var arr = arrayNew(1);	
			
			for (intRow = 1 ; intRow LTE q.RecordCount ;intRow ++){
				stData["__type__"] = "mvc.Models.Admin.Redi.vos.RediCorrectionHeader";
				stData["rediCorrectionHeaderId"] = q.rediCorrectionHeaderId[intRow];
				stData["uploadId"] = q.uploadId[intRow];
				//stData["lock"] =  CreateObject("component","mvc.Models.Entity.vos.Lock").init();//q.lock[intRow];
				olockUser["__type__"] = "mvc.Models.Entity.vos.User";
				olockUser["id"] = q.User_Id_Locked[intRow];
				olockUser["fullName"] = q.Name_First[intRow] & ' ' & q.Name_Last[intRow];
				olock["__type__"] = "mvc.Models.Entity.vos.Lock";
				olock["bLocked"] = q.isLocked[intRow];
				olock["userId"] = q.User_Id_Locked[intRow];
				olock["toggleLock"] = 0;
				olock["userLocked"] = olockUser;
			
	
				stData["lock"] = olock;
				stData["isSelected"] = q.isSelected[intRow];
				stData["sourceType"] = q.sourceType[intRow];
				stData["sourceTypeDesc"] = q.sourceTypeDesc[intRow];
				
				//oCust = CreateObject("component","mvc.Models.Entity.vos.Customer").init();
				oCust["__type__"] = "mvc.Models.Entity.vos.Customer";
				oCust["shipTo"] = q.originalCustomerShipTo[intRow];
				oCust["name"] = q.originalCustomerName[intRow];
				oCust["address"] = StructNew();//CreateObject("component","mvc.Models.Entity.vos.Address").init();
				oCust["address"]["__type__"] = "mvc.Models.Entity.vos.Address";
				oCust["address"]["addressLine1"] = q.originalCustomerAddress[intRow];
				oCust["address"]["city"] = q.originalCustomerCity[intRow];
				oCust["address"]["state"] = q.originalCustomerState[intRow];
				oCust["address"]["zipCode"] = q.originalCustomerZip[intRow];
				
				oCust["aliasShipTo"] = q.originalCustomerAliasShipTo[intRow];
				oCust["aliasName"] = q.originalCustomerAliasName[intRow];
				oCust["aliasRecordId"] = q.OrigXId[intRow];
				oCust["aliasAddress"] = StructNew();//CreateObject("component","mvc.Models.Entity.vos.Address").init();
				oCust["aliasAddress"]["__type__"] = "mvc.Models.Entity.vos.Address";
				oCust["aliasAddress"]["addressLine1"] = q.originalCustomerAliasAddress[intRow];
				oCust["aliasAddress"]["city"] = q.originalCustomerAliasCity[intRow];
				oCust["aliasAddress"]["state"] = q.originalCustomerAliasState[intRow];
				oCust["aliasAddress"]["zipCode"] = '';
				oCust["customerId"] = "";
				stData["originalCustomer"] = oCust;  //POPULATE q.originalCustomer[intRow];
				
				fCust["__type__"] = "mvc.Models.Entity.vos.Customer";
				fCust["shipTo"]= q.finalCustomerShipTo[intRow];
				fCust["name"]= q.finalCustomerName[intRow];
				fCust["address"] = StructNew();//CreateObject("component","mvc.Models.Entity.vos.Address").init();
				fCust["address"]["__type__"] = "mvc.Models.Entity.vos.Address";
				fCust["address"]["addressLine1"] = q.finalCustomerAddress[intRow];
				fCust["address"]["city"] = q.finalCustomerCity[intRow];
				fCust["address"]["state"] = q.finalCustomerState[intRow];
				fCust["address"]["zipCode"] = q.finalCustomerZip[intRow];
				fCust["aliasRecordId"] = q.FinalXId[intRow];
				fCust["aliasShipTo"]= q.finalCustomerAliasShipTo[intRow];
				fCust["aliasName"]= q.finalCustomerAliasName[intRow];
				fCust["aliasAddress"] = StructNew();//CreateObject("component","mvc.Models.Entity.vos.Address").init();
				fCust["aliasAddress"]["__type__"] = "mvc.Models.Entity.vos.Address";
				fCust["aliasAddress"]["addressLine1"] = q.finalCustomerAliasAddress[intRow];
				fCust["aliasAddress"]["city"] = q.finalCustomerAliasCity[intRow];
				fCust["aliasAddress"]["state"] = q.finalCustomerAliasState[intRow];
				fCust["aliasAddress"]["zipCode"] = '';
				fCust["customerId"]= "";
				stData["finalCustomer"] = fCust;    //POPULATE q.finalCustomer[intRow];
				
				stData["invoiceNumber"] = q.invoiceNumber[intRow];
				stData["invoiceDate"]= q.invoiceDate[intRow];
				stData["poNum"] = q.poNum[intRow]; 
				stData["InvCases"] = q.InvCases[intRow];
				stData["InvDollars"] = q.InvDollars[intRow];
				stData["errorMessage"] = q.errorMessage[intRow];
				stData["originalCustomerShipToNew"]	= q.originalCustomerShipToNew[intRow];
				stData["finalCustomerShipToNew"]	= q.finalCustomerShipToNew[intRow];
				stData["bReprocess"]	= q.bReprocess[intRow];
				stData["bFixable"]	= q.bFixable[intRow];
				// leave empty stData["arrRediCorrectionItems"] = q.arrRediCorrectionItems[intRow];
				ArrayAppend(arr, duplicate(stData));
			}
			
			return arr;
		</cfscript>
	</cffunction>
	
	<cffunction name="getRediHistory" output="false" access="remote" returntype="Array">
		<cfscript>
			//set local variables
			var a = arguments;
			var qRediHistoryData = queryNew("");
			var objRediDAO 	= CreateObject("component","mvc.Models.Admin.Redi.RediDAO");
			var stData = structNew();
			var arr = arrayNew(1);	
			//run the query
			//this.dmp(a);
			qRediHistoryData = objRediDAO.getRediHistoryData();
			
			for (intRow = 1 ; intRow LTE qRediHistoryData.RecordCount ;intRow ++){
				stData["__type__"] = "mvc.Models.Admin.Redi.vos.RediCorrectionHistory";
				stData["sourceType"] = qRediHistoryData.sourceType[intRow];
				stData["sourceTypeDesc"] = qRediHistoryData.sourceTypeDesc[intRow];
				stData["headerCount"] = qRediHistoryData.headerCount[intRow];
				stData["headerFailed"] = qRediHistoryData.headerFailed[intRow];
				stData["headerLoaded"] = qRediHistoryData.headerLoaded[intRow];
				stData["detailCount"] = qRediHistoryData.detailCount[intRow];
				stData["detailFailed"] = qRediHistoryData.detailFailed[intRow];
				stData["detailLoaded"] = qRediHistoryData.detailLoaded[intRow];
				stData["fileName"] = qRediHistoryData.fileName[intRow];
				stData["uploadId"] = qRediHistoryData.uploadId[intRow];
				stData["runDate"] = qRediHistoryData.runDate[intRow];
				ArrayAppend(arr, duplicate(stData));
			}
			//return the billback struct
			return arr;
		</cfscript>
	</cffunction>
		
	<cffunction name="getRediSettings" output="false" access="remote" returntype="array">
		
		<cfscript>
			//set local variables
			var objRediDAO 			= CreateObject("component","mvc.Models.Admin.Redi.RediDAO");
			var rRediVO 			= CreateObject("component","mvc.Models.Admin.Redi.vos.RediSettings");
			var qRediSettingsData	= "";
			var aRediSettingsData	= ArrayNew(1);
			var stData 				= structNew();	
			
			//assign local variables
			qRediSettingsData 			= objRediDAO.getRediSettingsData();
		
			for (intRow = 1; intRow LTE qRediSettingsData.RecordCount; intRow ++){
			
				stData 							= structNew();
				stData["__type__"] 				= "mvc.Models.Admin.Redi.vos.RediSettings";
				stData["sourceCode"] 			= qRediSettingsData.Source_Code[intRow];
				stData["sourceType"] 			= qRediSettingsData.Source_Type[intRow];
				stData["sourceTypeDesc"]		= qRediSettingsData.Source_Type_Description[intRow];
				stData["claimSourceXREFID"]		= qRediSettingsData.BB_Claim_Source_XREF_ID[intRow];
				stData["tradePartId"] 			= qRediSettingsData.Trade_Part_ID[intRow];
				stData["bEnabled"]				= JavaCast("boolean", qRediSettingsData.Enabled[intRow]);
				stData["bAliasItem"]			= JavaCast("boolean", qRediSettingsData.Alias_Item[intRow]);
				stData["bAliasDistributor"]		= JavaCast("boolean", qRediSettingsData.Alias_Distributor[intRow]);
				stData["bAliasOriginalBuyer"]	= JavaCast("boolean", qRediSettingsData.Alias_Original_Buyer[intRow]);
				stData["sFOBPricInd"]			= qRediSettingsData.FOB_Price_Ind[intRow];
				stData["iInvoicePrice"]			= qRediSettingsData.Invoice_Price[intRow];
				stData["iInvoiceNumber"]		= qRediSettingsData.Invoice_Number[intRow];
				stData["sModifiedUser"]			= qRediSettingsData.Updated_By[intRow];
				stData["dModifiedDate"]			= qRediSettingsData.Updated_Date[intRow];
				
				ArrayAppend(aRediSettingsData, duplicate(stData));
			}
		
			//return the array of settings
			return aRediSettingsData;
			
		</cfscript>
		
	</cffunction>
	
	<cffunction name="saveRediSettings" output="false" access="remote" returntype="array">
		<cfargument name="rediSettings" type="array" required="true" />
		<cfargument name="userId"		type="string" required="true" />
		
		<cfscript>
			//set local variables
			var objRediDAO 			= CreateObject("component","mvc.Models.Admin.Redi.RediDAO");
			var arrRediSettings		= ArrayNew(1);
			var strUserID			= "";	
			
			//assign local variables
			arrRediSettings 		= arguments.rediSettings;
			strUserID		 		= arguments.userId;
		
			//loop over the array of structs and save the data
			for (idx = 1; idx LTE arrayLen(arrRediSettings); idx++){
				objRediDAO.saveRediSettingsData(arrRediSettings[idx], strUserID);
			}
			//return the settings value object
			return arrRediSettings;
			
		</cfscript>
		
	</cffunction>
	
	<cffunction name="deleteCorrection" output="false" access="remote" returntype="Array">
		<cfargument name="arrCorrections"		type="Array" required="true" />
		<cfscript>
			//set local variables
			var qRediOpenData	= queryNew("");
			var objRediDAO 	= CreateObject("component","mvc.Models.Admin.Redi.RediDAO");
			var iCount = ArrayLen(arrCorrections);
			var qRediOpenData = '';
			var arr = ArrayNew(1);
			
			for (i = 1 ; i LTE iCount ;i ++){
				rch = arrCorrections[i];
				objRediDAO.deleteCorrection(rch);
			}
			qRediOpenData = objRediDAO.getRediHeaderData();
			arr = getRediCorrectionHeaderObj(qRediOpenData);

			return arr;
		</cfscript>
	</cffunction>
	
	<cffunction name="reprocessRediCorrection" output="false" access="remote" returntype="Struct" >
		<cfargument name="arr"		type="Array" required="true" />
		<cfscript>
			//declare local variables
			var sourceType				= 	"";
			var arrId				= 	ArrayNew(1);
			var arrInvNum			= 	ArrayNew(1);
			var stObj = StructNew();
			var strBBClaimSourceXREFID	= 	"";
			var objRediEditMan 	= CreateObject("component","mvc.Models.Admin.Redi.RediEditManager");
			var objRediDAO 	= CreateObject("component","mvc.Models.Admin.Redi.RediDAO");
			var objRediEditDAO 	= CreateObject("component","mvc.Models.Admin.Redi.RediEditDAO");
			var newLock = CreateObject("component","mvc.Models.Entity.vos.Lock");
			var qRediLockData = '';
			var rchReturn = '';
			var rch = '';
			var iCount = ArrayLen(arr);
			//set local variables
			newLock.userLocked.id = request.AccessStructure.User_ID;
			
				for (i = 1 ; i LTE iCount ;i ++){
					rch = arr[i];
					if(rch.bReprocess){
						//check Lock
						var newLock = CreateObject("component","mvc.Models.Entity.vos.Lock");
						newLock.userLocked.id = request.AccessStructure.User_ID;
						
						qRediLockData = objRediDAO.getRediHeaderDataSimple(rch);
						if(qRediLockData.RecordCount and qRediLockData.isLocked){
							if(qRediLockData.User_Id_Locked != request.AccessStructure.User_ID){
								//do nothing -> locked by someone else
								rchReturn = objRediEditMan.getRediEditData(rch);
								rchReturn.errorMessage  = rchReturn.errorMessage  & ", correction was locked by " & qRediLockData.Name_First & ' ' & qRediLockData.Name_Last;  // 85971
								rchReturn.invoiceNumber = 'Lock error.';//string "error"" is a key in UI
							}
							else{ //locked by me
								//validate redi record
								rchReturn = objRediEditMan.validateRediCorrection(rch);
							}
						}
						else{//not locked
							//lock and Validate
							//lock
							newLock.bLocked = 1;
							rch.lock = newLock;
							objRediEditDAO.setRediLockData(rch);
							//validate redi record
							rchReturn = objRediEditMan.validateRediCorrection(rch);
							//unlock record
							rch.lock.bLocked = Javacast('Boolean',0);
							lock.userLocked.id = '';
							objRediEditDAO.setRediLockData(rch);
						}
						ArrayAppend(arrId, rchReturn.rediCorrectionHeaderId);
						ArrayAppend(arrInvNum, rchReturn);
					}
					else{
						rchReturn =  objRediEditMan.getRediEditData(rch);
						rchReturn.errorMessage  = rchReturn.errorMessage  & "; Correction record has unassigned aliases or Invalid data (duplicate record or no price)";
						rchReturn.invoiceNumber = 'Lock error.';//string "error"" is a key in UI
						
						ArrayAppend(arrId, rchReturn.rediCorrectionHeaderId);
						ArrayAppend(arrInvNum, rchReturn);
					}
				}
			stObj.arrId = arrId;
			stObj.arrInvNum = arrInvNum;
		</cfscript>
		<cfreturn stObj />
	</cffunction>
	
</cfcomponent>