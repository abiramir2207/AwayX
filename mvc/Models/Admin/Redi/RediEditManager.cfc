<cfcomponent extends="mvc.Models.SettingsService" output="false" displayName="RediEditmanager">
	
	<cfscript>
		variables.oAliasDAO = createObject('component','mvc.Models.Admin.Alias.AliasManagerDAO');
	</cfscript>
	
    <cffunction name="getRediEditData" output="true" access="remote" returntype="struct">
		<!--- <cfargument name="h" type="mvc.Models.Admin.Redi.vos.RediCorrectionHeader" > --->
		<cfargument name="h" type="struct">         <!--- 85971 --->
		<cfargument name="bGetDetails" type="boolean" default="true">
		<cfscript>
			//set local variables
			var a = arguments;
			var rch =  CreateObject("component","mvc.Models.Admin.Redi.vos.RediCorrectionHeader");
			var arr = ArrayNew(1);
			var arrH = ArrayNew(1);
			var qRediEditHeaderData	= queryNew("");
			var qDet	= queryNew("");
			var objRediEditDAO 	= CreateObject("component","mvc.Models.Admin.Redi.RediEditDAO");
			var objRediDAO 	= CreateObject("component","mvc.Models.Admin.Redi.RediDAO");
			var objRediMan 	= CreateObject("component","mvc.Models.Admin.Redi.RediManager");
			var stRcd = StructNew();
			var origCust = CreateObject("component","mvc.Models.Entity.vos.Customer");
			var finCust = CreateObject("component","mvc.Models.Entity.vos.Customer");
			var arr = arrayNew(1);
			var l = CreateObject("component","mvc.Models.Entity.vos.Lock");

			//GET HEADER DATA
			qRediEditHeaderData = objRediDAO.getRediHeaderData(arguments.h,bGetDetails);
			//this.dmp(qRediEditHeaderData);
			arrH = objRediMan.getRediCorrectionHeaderObj(qRediEditHeaderData);
			if(Arraylen(arrH) > 0){
				rch = arrH[1];
			}
			//this.dmp(qRediEditHeaderData);
			//rch.lock = getRediCorrectionLock(rch);
			//GET DETAIL ARRAY OF ITEMs  qRediEditDetailData.RecordCount
			if(bGetDetails == true){ //Called FORM validate.  we just need to get header data that includes "prevalidate bReprocess bool"
				qDet = objRediEditDAO.getRediEditDetailData(rch);
				
				for (intRow = 1 ; intRow LTE qDet.recordCount;intRow ++){
					var stRcd = StructNew();
					stRcd["__type__"] = "mvc.Models.Admin.Redi.vos.RediCorrectionDetail";
					stRcd["rediCorrectionHeaderId"] = qDet.REDI_H_ID[intRow];
					stRcd["rediCorrectionDetailId"] = qDet.REDI_D_ID[intRow];
					//stRcd["isSelected"] = qDet.isSelected[intRow];
					stRcd["item"] =  qDet.Item_Number[intRow];
					stRcd["itemDesc"] = qDet.Description[intRow];
					stRcd["itemPackSize"] = 0;
					stRcd["aliasItem"] = qDet.Alias_Item_Number[intRow];
					stRcd["aliasItemDesc"] = qDet.Alias_Item_Desc[intRow];
					stRcd["aliasRecordId"] = qDet.Alias_Record_Id[intRow];
					stRcd["invoiceCases"] = qDet.qty[intRow];
					stRcd["invoicePriceCS"] = qDet.Unit_Price[intRow];
					/*stRcd["aliasItemPackSize"] = 4;
					stRcd["invoiceCases"] = 12;
					stRcd["invoicePriceCS"] = 2.5;
					stRcd["invoicePriceLB"] = .50;*/
					stRcd["errorMessage"] = qDet.Err_Msg[intRow];
					ArrayAppend(arr, duplicate(stRcd));
				}
				rch["arrRediCorrectionItems"] = arr;
			}//if bGetDetails

			return rch;
		</cfscript>
	
	</cffunction>
	
	<cffunction name="getRediCorrectionLock" output="false" access="remote" returntype="Any" >
		<cfargument name="h" type="struct" >
		<cfscript>
			//set local variables
			var a = arguments;
			var rch = CreateObject("component","mvc.Models.Admin.Redi.vos.RediCorrectionHeader");
			var qRediLockData	= queryNew("");
			var lock = h.lock;
			var newLock = CreateObject("component","mvc.Models.Entity.vos.Lock");
			//var tmp = "";
			//var lock 	= CreateObject("component","mvc.Models.Entity.vos.Lock");
			var objRediEditDAO 	= CreateObject("component","mvc.Models.Admin.Redi.RediEditDAO");
			var objRediDAO 	= CreateObject("component","mvc.Models.Admin.Redi.RediDAO");
			var objRediMan 	= CreateObject("component","mvc.Models.Admin.Redi.RediManager");
			var qLockByMe = '';
			var stData = structNew();
			var arr = arrayNew(1);
			//toggle
			lock.bLocked = Javacast('Boolean',!lock.bLocked);
			/*lock.objIdLockedDesc = 'locked by: ' & request.AccessStructure.User_Code;
			lock.userLocked = CreateObject("component","mvc.Models.Entity.vos.User").init();
			lock.userLocked.id = request.AccessStructure.User_ID;
			lock.userLocked.fullName = request.AccessStructure.Name_First & ' '  & request.AccessStructure.Name_Last;
			h.lock = lock;*/
			
			
			//reload lock info incase someone got there first
			qRediLockData = objRediDAO.getRediHeaderDataSimple(h);
			//this.dmp(qRediLockData);
			newLock.userLocked.id = request.AccessStructure.User_ID;
			if(lock.bLocked){ //lock it
				//unlock My Corrections
				qLockByMe = objRediEditDAO.getRediUNLOCKByMe();
				if(qRediLockData.isLocked){
					if(qRediLockData.User_Id_Locked != request.AccessStructure.User_ID){
						//do nothing -> locked by someone eles
					}
					else{
						//relock (should not happen)
						newLock.bLocked = 1;
						h.lock = newLock;
						objRediEditDAO.setRediLockData(h);
					}
					
				}
				else{//lock it
					newLock.bLocked = 1;
					h.lock = newLock;
					objRediEditDAO.setRediLockData(h);
				}
			}
			else{//unlock if I have the lock
				if(qRediLockData.User_Id_Locked == request.AccessStructure.User_ID){
					h.lock.bLocked = Javacast('Boolean',0);
					lock.userLocked.id = '';
					objRediEditDAO.setRediLockData(h);
				}
			}
			rch = this.getRediEditData(h);
			return rch;
		</cfscript>
	
	</cffunction>
	
	<cffunction name="validateRediCorrection" output="true" access="remote" returntype="Struct" > <!---  returntype="mvc.Models.Admin.Redi.vos.RediCorrectionHeader  --->
        <cfargument name="h" required="true" type="Any" >

        <!--- <cfset request.dumpToEmail_address = "cnguyen@blacksmithapplications.com">  <cfset application.util.io.dumpToEmail(arguments)> --->

		<cfscript>
			//declare local variables
			var sourceType				= 	"";
			var strBBClaimSourceXREFID	= 	"";
			var objRediEditDAO 	= CreateObject("component","mvc.Models.Admin.Redi.RediEditDAO");
			var rch = '';
			var qResults = QueryNew( 'Order_number,Invoice_Header_ID,BSA_foodservice_Customers_ID,BSA_foodservice_Brokers_ID,Err_Msg,Err_Column,Err_Number,Invalid,Updated_date,Updated_By');
			CR    = Chr(13);             // Carriage return
    		LF    = Chr(10);             // Line feed
    		CRLF  = CR & LF;
			//set local variables
			// gather data to pass to the saveRediDistributorAliasDetails() local function which will in turn call the saveDistributorAliasDetails() function in AliasManagerDAO
			sourceType					=	h.sourceType;
	  		strBBClaimSourceXREFID 		= 	variables.oAliasDAO.getSourceExists(h.sourceType).BB_Claim_Source_XREF_ID;	
			//this.dmp(variables.oAliasDAO.getSourceExists(rch.sourceType));
			if(strBBClaimSourceXREFID NEQ ''){
				//save both customers
				this.saveRediDistributorAliasDetails(h.finalCustomer,strBBClaimSourceXREFID,sourceType);
                this.saveRediDistributorAliasDetails(h.originalCustomer,strBBClaimSourceXREFID,sourceType);
                if (structKeyExists(h, "arrRediCorrectionItems") eq false) {
                    h = getRediEditData(h, true);
                }
			//	this.dmp(h.arrRediCorrectionItems);
				for (i=1;i LTE ArrayLen(h.arrRediCorrectionItems);i=i+1) {
					
					saveItemAliasDetails(h.arrRediCorrectionItems[i],strBBClaimSourceXREFID,sourceType,h.uploadId);
				}
			
			}
			
			//PRE-VALIDATE - SEE IF ALL ALIASES ARE OK
			rch = this.getRediEditData(h,false);
			if(rch.bReprocess EQ 1){
				qResults = objRediEditDAO.callvalidateSp(rch);
				s = 'Validated New Invoice:'  & CRLF;  //& qResults.recordCount & ' Invoice(s):'
				for (i=1;i LTE qResults.recordCount;i=i+1) {
					rch.invoiceNumber = qResults.Order_number[i];
					rch.errorMessage  = qResults.Err_Msg[i];
					if(rch.errorMessage != ''){
						rch.bReprocess = javacast("boolean" ,"0");
					}	
				}

			}
			else{
				rch.errorMessage = 'Please correct unnassigned aliases and validate again.' & TimeFormat(now(),"full" );
				rch.bReprocess = javacast("boolean" ,"0");
			}
			
			//this.dmp(rch);
			//rch.arrRediCorrectionItems= [];
			return rch;
		</cfscript>
	
	</cffunction>
	
	<cffunction name="saveRediDistributorAliasDetails" output="false">
		<!--- <cfargument name="customer" 			required="true"	type="mvc.Models.Entity.vos.Customer" /> --->
		<cfargument name="customer" 			required="true"	type="struct" />
		<cfargument name="bbClaimSourceXREFID" 	required="true" type="string" />
		<cfargument name="sourceType"			required="true" type="string" />
		
		<cfscript>
			//declare local variables
			var objAliasDef = 	CreateObject("component","mvc.Models.Admin.Alias.vos.AliasDef");
			var strSourceID	= 	"";
		
			//set local variables
			objAliasDef.entityType = 1;
			objAliasDef.recordID	= arguments.customer.aliasRecordId;
			objAliasDef.sourceType	= arguments.sourceType;
			objAliasDef.aliasID 	= arguments.customer.aliasShipTo;
			objAliasDef.aliasDesc   = arguments.customer.aliasName;
			objAliasDef.entityID	= arguments.customer.shipTo;
			//objAliasDef.sourceID = ;
			//this.dmp(objAliasDef);
			// run logic
			variables.oAliasDAO.saveDistributorAliasDetails(objAliasDef, bbClaimSourceXREFID, request.AccessStructure.User_ID);
			
		</cfscript>
	
	</cffunction>
	
	<cffunction name="saveItemAliasDetails">
		<!--- <cfargument name="detail" required="true" type="mvc.Models.Admin.Redi.vos.RediCorrectionDetail" /> --->
		<cfargument name="detail" required="true" type="struct" />
		<cfargument name="BBClaimSourceXREFID" required="true" type="string" />
		<cfargument name="sourceType" required="true" type="string" />
		<cfargument name="UploadID" required="false" type="any" />
		
		<cfscript>
			var objAliasDef = 	CreateObject("component","mvc.Models.Admin.Alias.vos.AliasDef");
			var objRediEditDAO 	= CreateObject("component","mvc.Models.Admin.Redi.RediEditDAO");
			
			objRediEditDAO.saveRediEditDetailData(detail,arguments.UploadID); 
			
			objAliasDef.entityType = 2;
			objAliasDef.recordID = detail.aliasRecordId;
			objAliasDef.sourceType = arguments.sourceType;
			objAliasDef.aliasID = detail.aliasItem;
			objAliasDef.aliasDesc = detail.aliasItemDesc;
			objAliasDef.entityID = detail.item;
			//objAliasDef.sourceID = ;
			//this.dmp(objAliasDef);
			oAliasDAO.saveItemAliasDetails(objAliasDef,BBClaimSourceXREFID,request.AccessStructure.User_ID);
		</cfscript>
		
	
	</cffunction>
	
	<cffunction name="lookupItems" output="false" access="remote" returntype="Array" >
		<cfargument name="sItem" required="true" type="string" ><!---  type="mvc.Models.Entity.vos.Lock"  --->
		<cfscript>
			//set local variables
			var a = arguments;
			var arr = ArrayNew(1);
			var s = createObject('component','mvc.Models.Item.ItemSearchService');
			var aItems = s.getCompItems(0,0,1,1,0,0,sItem);
			return aItems;
		</cfscript>
	
	</cffunction>
	
	<cffunction name="getCustomerInfo" output="false" access="remote" returntype="mvc.Models.Entity.vos.Customer" >
		<cfargument name="sShipTo" required="true" type="string" ><!---  type="mvc.Models.Entity.vos.Lock"  --->
		<cfscript>
			//set local variables
			var a = arguments;
			var arr = ArrayNew(1);
			var s = createObject('component','mvc.Models.Admin.Redi.RediEditDAO');
			var q = s.getCustomerInfo(arguments.sShipTo);
			var cust = createObject('component','mvc.Models.Entity.vos.Customer');
			var addr = createObject('component','mvc.Models.Entity.vos.Address');
			
			for (idxRow=1;idxRow LTE q.recordCount;idxRow=idxRow+1) {
				/*stData = structNew();
				stData["__type__"] = "mvc.Models.Entity.vos.Customer";
				stData["shipTo"] = q["Ship_To"][idxRow];
				stData["name"] = q["name"][idxRow];
				stData["customerId"] = q["BSA_Foodservice_Customers_ID"][idxRow];
				stAddressData = structNew();
				stAddressData["__type__"] = "mvc.Models.Entity.vos.Address";
				stAddressData["addressLine1"] = q["Address_1"][idxRow];
				stAddressData["city"] = q["City"][idxRow];
				stAddressData["state"] = q["State"][idxRow];
				stAddressData["zipCode"] = q["zipcode"][idxRow];
				stData["address"] = stAddressData;*/
				
				cust["shipTo"] = q["Ship_To"][idxRow];
				cust["name"] = q["name"][idxRow];
				cust["customerId"] = q["BSA_Foodservice_Customers_ID"][idxRow];
				addr["addressLine1"] = q["Address_1"][idxRow];
				addr["city"] = q["City"][idxRow];
				addr["state"] = q["State"][idxRow];
				addr["zipCode"] = q["zipcode"][idxRow];
				cust["address"] = addr;
				//ArrayAppend(arrRetData, duplicate(stData));
			}
			
			return cust;
		</cfscript>
	
	</cffunction>
	

</cfcomponent>