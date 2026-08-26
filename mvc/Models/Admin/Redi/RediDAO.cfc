<cfcomponent displayname="RediDAO" extends="mvc.Models.SettingsService">
	<cffunction name="getRediHeaderData" output="false" access="public" returntype="Query" >
		<!--- <cfargument name="h" type="mvc.Models.Admin.Redi.vos.RediCorrectionHeader" required="false" default="#CreateObject("component","mvc.Models.Admin.Redi.vos.RediCorrectionHeader")#" > --->
		<cfargument name="h" type="struct" required="false" default="#CreateObject("component","mvc.Models.Admin.Redi.vos.RediCorrectionHeader")#" >
		<cfargument name="bGetDetails" type="boolean" default="true">
		<cfargument name="caller" required="false" default="">

		<cfscript>
			//set local variables
			var a = arguments;
		</cfscript>
		<cfquery name="qGetRediHeaderData" datasource="#application.datasource#">
            /*** \mvc\Models\Admin\Redi\RediDAO.cfc - getRediHeaderData() ***/
			SELECT  H.REDI_EC_Header_id 				AS rediCorrectionHeaderId,
				H.Upload_ID								AS uploadId,
				H.REDI_SOURCE 							AS sourceTypeDesc,
				H.Partner_Number 						AS sourceType,
				H.RAW_EDI_Invoice_Number 				AS invoiceNumber,
				convert(datetime, H.Invoice_Date, 112)	AS invoiceDate,
				H.Invoice_Date	                        AS invoiceDateYYYYMMDD,
				/*--ORIGINAL*/
				ISNULL(CustOrig.Ship_to,H.Original_Shared_ship_to)	AS originalCustomerShipTo,
				CustOrig.Name							AS originalCustomerName,
				CustOrig.Address_1						AS originalCustomerAddress,
				CustOrig.City							AS originalCustomerCity,
				CustOrig.State							AS originalCustomerState,
				CustOrig.ZipCode						AS originalCustomerZip,
                CustOrig.BSA_Foodservice_Customers_ID   AS originalCustomerID,
				H.Alias_Original_Shared_ship_to 		AS originalCustomerAliasShipTo,
				XOrig.External_Description				AS originalCustomerAliasName,
				H.OShipto_Add							AS originalCustomerAliasAddress,
				H.OShipto_City							AS originalCustomerAliasCity,
				H.OShipto_State							AS originalCustomerAliasState,
				/*--FINAL*/
				ISNULL(CustFin.Ship_to,H.Current_Shared_ship_to)	AS finalCustomerShipTo,
				CustFin.Name							AS finalCustomerName,
				CustFin.Address_1						AS finalCustomerAddress,
				CustFin.City							AS finalCustomerCity,
				CustFin.State							AS finalCustomerState,
				CustFin.ZipCode							AS finalCustomerZip,
                CustFin.BSA_Foodservice_Customers_ID    AS finalCustomerID,
				H.Alias_Current_Shared_ship_to			AS finalCustomerAliasShipTo,
				XFinal.External_Description				AS finalCustomerAliasName,
				H.CShipto_Add							AS finalCustomerAliasAddress,
				H.CShipto_City							AS finalCustomerAliasCity,
				H.CShipto_State							AS finalCustomerAliasState,
				/*-----*/
				H.PO_Number 							AS poNum,
				convert(datetime,H.PO_Date, 112) 		AS PO_Date,
				H.Created_Date,
				H.Locked								AS isLocked,
				H.User_Id_Locked,
				U.Name_First,
				U.Name_Last,
				H.Err_Msg								AS errorMessage,
				0 										AS isSelected,
				XOrig.BB_Claim_Dist_XREF_ID 			AS OrigXId,
				XFinal.BB_Claim_Dist_XREF_ID 			AS FinalXId,
				XFinal.External_Description				AS finalCustomerAliasName,
				CAST(H.Total_QTY AS DECIMAL(12,4))		AS InvCases,
				CAST(H.Total_Amount	AS DECIMAL(12,4)) 	AS InvDollars,
				XOrig.Shipto							AS originalCustomerShipToNew,
				XFinal.Shipto							AS finalCustomerShipToNew,
				
				
				CASE /*--check for Aliases created elsewhere*/
					WHEN NOT EXISTS (SELECT D.* FROM REDI_EC_Detail D 
										INNER JOIN BB_Claim_Item_XREF XItem ON
											XItem.External_Code = D.Alias_Item_Number AND
											XItem.BB_Claim_Source_XREF_ID = XSource.BB_Claim_Source_XREF_ID 
										LEFT JOIN BSA_FoodService_Items_Master I ON
											I.Item = d.Item_Number
										WHERE D.Redi_H_Id = H.Redi_H_Id AND
												D.Upload_Id = H.Upload_Id AND
													(
													(NULLIF(XItem.Item,'') IS NULL AND NULLIF(I.Item,'') IS NULL)
													/*-- WHEN CALLED FROM Corrections Edit, we only validate Aliases*/
													<cfif bGetDetails EQ TRUE > 
													OR D.Err_Number LIKE '%3%' /*--invalid Price--*/
													</cfif> 
													)
												)
						AND (NULLIF(CustOrig.Ship_to,'') IS NOT NULL OR  H.Partner_Number = '9288030000' OR  H.Partner_Number = 'DOTFOODSINC')  
						AND NULLIF(CustFin.Ship_to,'') IS NOT NULL
						<cfif bGetDetails EQ TRUE > /*-- WHEN CALLED FROM Corrections Edit, we only validate Aliases */
							AND H.Err_Number NOT LIKE '%1%' /*--duplicate header--*/
						</cfif>
					THEN 1
					ELSE 0
				END										AS bReprocess,
				CASE  /*--invalid Price--*/
					WHEN NOT EXISTS (SELECT D.Redi_H_Id FROM REDI_EC_Detail D
										WHERE D.Redi_H_Id = H.Redi_H_Id AND
												D.Upload_Id = H.Upload_Id 
												AND D.Err_Number LIKE '%3%'
												)  
					AND H.Err_Number NOT LIKE '%1%' /*--duplicate header--*/
					THEN 1
					ELSE 0
				END										AS bFixable
			FROM
			 	REDI_EC_Header H
			LEFT JOIN BB_Claim_Source_XREF XSource ON
		 		XSource.Source_Code = H.Partner_Number
		 	LEFT JOIN BB_Claim_Dist_XREF XOrig ON  
		 		XOrig.External_Code = H.Alias_Original_Shared_ship_to AND
		 		XOrig.BB_Claim_Source_XREF_ID = XSource.BB_Claim_Source_XREF_ID
		 	LEFT JOIN BB_Claim_Dist_XREF XFinal ON 
		 		XFinal.External_Code = H.Alias_Current_Shared_ship_to AND
		 		XFinal.BB_Claim_Source_XREF_ID = XSource.BB_Claim_Source_XREF_ID
			LEFT JOIN _Users U ON
				U.User_ID = H.User_Id_Locked
			LEFT JOIN BSA_Foodservice_Customers CustOrig ON
				CustOrig.Ship_To = XOrig.Shipto
			LEFT JOIN BSA_Foodservice_Customers CustFin ON
				CustFin.Ship_To = XFinal.Shipto
			<CFIF h.rediCorrectionHeaderId NEQ 0>
                WHERE REDI_EC_Header_id = #H.rediCorrectionHeaderId#
            <!--- new property from our new distribution page --->
            <cfelseif structKeyExists(h, "header_ids_filter")>
				WHERE REDI_EC_Header_id IN (<cfqueryparam value="#h.header_ids_filter#" list="true">)
            </CFIF>
			<!---GROUP BY 
				H.REDI_EC_Header_id,
				H.Upload_ID,
				H.REDI_SOURCE,
				H.Partner_Number,
				H.RAW_EDI_Invoice_Number,
				H.Invoice_Date,
				H.Alias_Original_Shared_ship_to,
				H.Alias_Current_Shared_ship_to,
				H.Original_Shared_ship_to,
				H.Current_Shared_ship_to,
				H.PO_Number,
				H.PO_Date,
				H.Created_Date,
				H.Locked,
				H.User_Id_Locked,
				U.Name_First,
				U.Name_Last,
				H.Err_Msg,
				XOrig.BB_Claim_Dist_XREF_ID,
				XFinal.BB_Claim_Dist_XREF_ID,
				XOrig.External_Description,
				XFinal.External_Description,
				CustOrig.Name,
				CustFin.Name,
				XOrig.Shipto,
				XFinal.Shipto,
				XItem.Item,
				D.Err_Number,
				H.Err_Number---> 
	    </cfquery>
	    <cfreturn qGetRediHeaderData />

	</cffunction>
	
	<cffunction name="getRediHeaderDataSimple" output="false" access="public" returntype="Query" >
		<!--- <cfargument name="h" type="mvc.Models.Admin.Redi.vos.RediCorrectionHeader" required="false" default="#CreateObject("component","mvc.Models.Admin.Redi.vos.RediCorrectionHeader")#" > --->
		<cfargument name="h" type="struct" required="false" default="#CreateObject("component","mvc.Models.Admin.Redi.vos.RediCorrectionHeader")#" >
		<cfscript>
			//set local variables
			var a = arguments;
		</cfscript>
		<cfquery name="qGetRediHeaderData" datasource="#application.datasource#">
			SELECT DISTINCT H.REDI_EC_Header_id 					AS rediCorrectionHeaderId,
				H.Upload_ID								AS uploadId,
				H.REDI_SOURCE 							AS sourceTypeDesc,
				H.Partner_Number 						AS sourceType,
				H.RAW_EDI_Invoice_Number 				AS invoiceNumber,
				convert(datetime,H.Invoice_Date, 112)	AS invoiceDate,
				H.Alias_Original_Shared_ship_to 		AS originalCustomerAliasShipTo,
				H.Original_Shared_ship_to	AS originalCustomerShipTo,
				H.Alias_Current_Shared_ship_to			AS finalCustomerAliasShipTo,
				H.Current_Shared_ship_to				AS finalCustomerShipTo,
				H.PO_Number 							AS poNum,
				convert(datetime,H.PO_Date, 112) 		AS PO_Date,
				H.Created_Date,
				H.Locked								AS isLocked,
				H.User_Id_Locked,
				H.Err_Msg								AS errorMessage,
				CAST(H.Total_QTY AS DECIMAL(12,4))		AS InvCases,
				CAST(H.Total_Amount	AS DECIMAL(12,4)) 	AS InvDollars,
				U.Name_First,
				U.Name_Last
			FROM
			 	REDI_EC_Header H
			LEFT JOIN _Users U ON
				U.User_ID = H.User_Id_Locked
				WHERE REDI_EC_Header_id = #H.rediCorrectionHeaderId#
	    </cfquery>
	    <cfreturn qGetRediHeaderData />

	</cffunction>
	
	<cffunction name="getRediHistoryData" output="false" access="public" returntype="Query" >
        <cfargument name="caller" required="false" default="">
        
		<cfscript>
			//set local variables
			// var a = arguments;
			// var qRediHistoryData	= queryNew("sourceType,sourceTypeDesc,headerCount,headerFailed,headerLoaded,detailCount,detailFailed,detailLoaded,fileName");
			
		</cfscript>
		<cfquery name="local.qRediHistoryData" datasource="#application.datasource#">
            /*** \mvc\Models\Admin\Redi\RediDAO.cfc - getRediHistoryData() ***/
            SELECT DISTINCT 
				  L.Partner_Number AS sourceType,
				  L.Redi_Source AS sourceTypeDesc,
				 (SELECT COUNT(*) FROM LOG_REDI_HEADER WHERE Upload_Id = DIU.Data_Integration_Upload_Id)  AS headerCount,
				 (SELECT COUNT(*) FROM LOG_REDI_HEADER WHERE Upload_Id = DIU.Data_Integration_Upload_Id AND ISNULL(Invalid,1) = 1) AS headerFailed,
				 (SELECT COUNT(*) FROM LOG_REDI_HEADER WHERE Upload_Id = DIU.Data_Integration_Upload_Id AND ISNULL(Invalid,1) = 0) AS headerLoaded,
				 Total_Count_Received AS detailCount,
				 Count_Rejected AS detailFailed,
				 Count_Inserted AS detailLoaded,
				 Unique_File_Name AS [fileName],
				 Amount_Checksum AS totalDollars,
				 Quantity_Checksum AS totalCases,
				 Data_integration_Upload_ID AS UploadId,
                <cfif arguments.caller is "redistribution.cfm">
				    convert(VARCHAR(8), DIU.Created_Date, 112)	AS runDate
                <cfelse>
    	 			 DIU.Created_Date AS runDate
                </cfif>
			FROM Data_Integration_Upload DIU
			INNER JOIN LOG_REDI_HEADER L ON
			L.Upload_Id = DIU.Data_Integration_Upload_Id
			WHERE	INTRA_ID = <cfqueryparam value='1300'> AND
			DIU.Created_Date > DATEADD(MONTH,-3,GETDATE())
	    </cfquery> 
        
	    <cfreturn local.qRediHistoryData />
	</cffunction>
	
	<cffunction name="getRediSettingsData" output="false" access="public" returntype="query">
	
		
		<cfscript>
			//set local variables
			var qGetRediSettingsData	= "";
			
			//assign local variables

		</cfscript>
		
		<cfquery name="qGetRediSettingsData" datasource="#application.datasource#">
			SELECT	BB_Claim_Source_XREF.Source_Code,
					BB_Claim_Source_XREF.Source_Type,
					BB_Claim_Source_XREF.Source_Type_Description,
					BB_Claim_Source_XREF.BB_Claim_Source_XREF_ID,
					Redi_Process_Settings.Redi_Process_Settings_ID,
					Redi_Process_Settings.Trade_Part_ID,
					ISNULL(Redi_Process_Settings.Enabled, 0) AS Enabled,
					ISNULL(Redi_Process_Settings.Alias_Item, 0) AS Alias_Item,
					ISNULL(Redi_Process_Settings.Alias_Distributor, 0) Alias_Distributor,
					ISNULL(Redi_Process_Settings.Alias_Original_Buyer, 0) AS Alias_Original_Buyer,
					Redi_Process_Settings.FOB_Price_Ind,
					Redi_Process_Settings.Invoice_Price,
					Redi_Process_Settings.Invoice_Number,
					Redi_Process_Settings.Updated_Date,
					Redi_Process_Settings.Updated_By
			FROM 	BB_Claim_Source_XREF
					LEFT JOIN Redi_Process_Settings ON Redi_Process_Settings.BB_Claim_Source_XREF_ID = BB_Claim_Source_XREF.BB_Claim_Source_XREF_ID
					AND Redi_Process_Settings.Deleted = 0
			WHERE	BB_Claim_Source_XREF.Deleted = 0
		</cfquery>
		
		<cfreturn qGetRediSettingsData />
		
	</cffunction>
	
	<cffunction name="getRediSettingsEmailReciptsData" output="false" access="public" returntype="query">
	
		<cfargument name="sourceType" type="Numeric" required="true" />
		
		<cfscript>
			//set local variables
			var nSourceType							= 0;
			var qGetRediSettingsEmailReciptsData	= "";
			
			//assign local variables
			nSourceType 				= arguments.sourceType;
		</cfscript>
		
		<cfquery name="qGetRediSettingsEmailReciptsData" datasource="#application.datasource#">
			SELECT	Redi_Settings_Email_Recipients_ID,
					Source_Type,
					Email_Address
			FROM	Redi_Settings_Email_Recipients
			WHERE	Source_Type = <cfqueryparam cfsqltype="cf_sql_integer" value="#nSourceType#">
			AND		Deleted = 0
		</cfquery>
		
		<cfreturn qGetRediSettingsEmailReciptsData />
		
	</cffunction>
	
	<cffunction name="saveRediSettingsData" output="false" access="public" returntype="void">
		
		<cfargument name="rediSetting" 	type="struct" required="true" />
		<cfargument name="userId"		type="string" required="true" />
		<cfscript>
			//set local variables
			var qSaveRediSettingsData	= "";
			var stRediSetting			= structNew();
			var strUserID				= "";
			
			//assign local variables
			stRediSetting	= arguments.rediSetting;
			strUserID 		= arguments.userId;
		</cfscript>
		
		<cfquery name="qSaveRediSettingsData" datasource="#application.datasource#">
			UPDATE	Redi_Process_Settings
			SET		Redi_Process_Settings.Deleted = 1,
					Redi_Process_Settings.Updated_By = '#strUserID#',
					Redi_Process_Settings.Updated_Date = getDate()
			FROM 	Redi_Process_Settings
					INNER JOIN BB_Claim_Source_XREF ON BB_Claim_Source_XREF.BB_Claim_Source_XREF_ID = Redi_Process_Settings.BB_Claim_Source_XREF_ID
					AND	BB_Claim_Source_XREF.Deleted = 0
			WHERE	Redi_Process_Settings.Deleted = 0
			AND		Redi_Process_Settings.BB_Claim_Source_XREF_ID = '#stRediSetting.claimSourceXREFID#'
			
			INSERT INTO Redi_Process_Settings
				(
					BB_Claim_Source_XREF_ID, Trade_Part_ID, Source_Type, Enabled, 
					Alias_Item, Alias_Distributor, 
					Alias_Original_Buyer, FOB_Price_Ind, Invoice_Price, Invoice_Number, Updated_Date, Updated_By
				)
			VALUES
				(	'#stRediSetting.claimSourceXREFID#', '#stRediSetting.tradePartId#', '#stRediSetting.sourceType#', <cfqueryparam value="#stRediSetting.bEnabled#" cfsqltype="CF_SQL_BIT" />, 
					<cfqueryparam value="#stRediSetting.bAliasItem#" cfsqltype="CF_SQL_BIT" />, <cfqueryparam value="#stRediSetting.bAliasDistributor#" cfsqltype="CF_SQL_BIT" />, 
					<cfqueryparam value="#stRediSetting.bAliasOriginalBuyer#" cfsqltype="CF_SQL_BIT" />, '#stRediSetting.sFOBPricInd#', '#stRediSetting.iInvoicePrice#', '#stRediSetting.iInvoiceNumber#', getDate(), '#strUserID#'
				)
		</cfquery>
	
	</cffunction>
	
	<cffunction name="deleteCorrection" output="false" access="public" returntype="void">
		<cfargument name="h" type="mvc.Models.Admin.Redi.vos.RediCorrectionHeader" required="false" default="#CreateObject("component","mvc.Models.Admin.Redi.vos.RediCorrectionHeader")#" >
		<cfscript>
			//set local variables
			var nSourceType				= 0;
			var qGetRediSettingsData	= "";
			
		</cfscript>
		<cfquery name="qDeleteCorrectionDetail" datasource="#application.datasource#">
			DELETE FROM D
			FROM REDI_EC_Header H
			INNER JOIN REDI_EC_Detail D ON
				D.Redi_H_Id = H.Redi_H_Id AND
				D.Upload_Id = H.Upload_Id 
			WHERE REDI_EC_HEADER_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.h.rediCorrectionHeaderId#">
		</cfquery>
		
		<cfquery name="qDeleteCorrection" datasource="#application.datasource#">
			DELETE FROM REDI_EC_Header
			WHERE REDI_EC_HEADER_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.h.rediCorrectionHeaderId#">
		</cfquery>
		<!---<cfreturn qGetRediSettingsData />--->
	</cffunction>
	
	<cffunction name="getReportData" output="false" access="public" returntype="query">
		<cfscript>
			//set local variables
			var nSourceType				= 0;
			var qGetReportData			= "";
			
		</cfscript>
		<cfquery name="qGetReportData" datasource="#application.datasource#">
			--SELECt * INTO ##tmp
			--FROM(
			SELECT  H.REDI_EC_Header_id 					AS rediCorrectionHeaderId,
					H.Upload_ID								AS uploadId,
					H.REDI_SOURCE 							AS sourceTypeDesc,
					H.Partner_Number 						AS sourceType,
					H.RAW_EDI_Invoice_Number 				AS invoiceNumber,
					convert(datetime,H.Invoice_Date, 112)	AS invoiceDate,
					--ORIGINAL Customer error
					ISNULL(CustOrig.Ship_to,H.Original_Shared_ship_to) AS errId,
	  				CustOrig.Name							AS errDesc,
	  				CustOrig.Address_1						AS errDesc1,
	  				CustOrig.City							AS errDesc2,
	  				CustOrig.State							AS errDesc3,                
	  				CustOrig.ZipCode						AS errDesc4,
	  				                        
	  				H.Alias_Original_Shared_ship_to 		AS errAliasId,
	  				XOrig.External_Description				AS errAliasDesc,
	  				H.OShipto_Add							AS errAliasDesc1,
	  				H.OShipto_City							AS errAliasDesc2,    
	  				H.OShipto_State							AS errAliasDesc3,
	  				''										AS errAliasDesc4,
					-----
					H.PO_Number 							AS poNum,
					convert(datetime,H.PO_Date, 112) 		AS PO_Date,
					H.Created_Date,
					'Invalid Original ship to'				AS errorMessage,
					--H.Err_Msg								AS errorMessage,
					H.Err_number
				FROM
				 	REDI_EC_Header H
				INNER JOIN BB_Claim_Source_XREF XSource ON
			 		XSource.Source_Code = H.Partner_Number
			 	INNER JOIN BB_Claim_Dist_XREF XOrig ON  
			 		XOrig.External_Code = H.Alias_Original_Shared_ship_to AND
			 		XOrig.BB_Claim_Source_XREF_ID = XSource.BB_Claim_Source_XREF_ID
				LEFT JOIN BSA_Foodservice_Customers CustOrig ON
					CustOrig.Ship_To = XOrig.Shipto
				WHERE H.Err_Number Like '%2%'
			UNION
			SELECT  H.REDI_EC_Header_id 					AS rediCorrectionHeaderId,
					H.Upload_ID								AS uploadId,
					H.REDI_SOURCE 							AS sourceTypeDesc,
					H.Partner_Number 						AS sourceType,
					H.RAW_EDI_Invoice_Number 				AS invoiceNumber,
					convert(datetime,H.Invoice_Date, 112)	AS invoiceDate,
					--FINAL Customer error
					ISNULL(CustFin.Ship_to,H.Current_Shared_ship_to)	AS errId,  
					CustFin.Name							AS errDesc,
					CustFin.Address_1						AS errDesc1,
					CustFin.City							AS errDesc2,
					CustFin.State							AS errDesc3,
					CustFin.ZipCode							AS errDesc4,
					H.Alias_Current_Shared_ship_to			AS errAliasId,
					XFinal.External_Description				AS errAliasDesc,
					H.CShipto_Add							AS errAliasDesc1,
					H.CShipto_City							AS errAliasDesc2,
					H.CShipto_State							AS errAliasDesc3,
					''										AS errAliasDesc4,
					-----
					H.PO_Number 							AS poNum,
					convert(datetime,H.PO_Date, 112) 		AS PO_Date,
					H.Created_Date,
					'Invalid Current ship to'				AS errorMessage,
					--H.Err_Msg								AS errorMessage,
					H.Err_number
				FROM
				 	REDI_EC_Header H
				INNER JOIN BB_Claim_Source_XREF XSource ON
			 		XSource.Source_Code = H.Partner_Number
			 	INNER JOIN BB_Claim_Dist_XREF XFinal ON 
			 		XFinal.External_Code = H.Alias_Current_Shared_ship_to AND
			 		XFinal.BB_Claim_Source_XREF_ID = XSource.BB_Claim_Source_XREF_ID
				LEFT JOIN BSA_Foodservice_Customers CustFin ON
					CustFin.Ship_To = XFinal.Shipto
					WHERE H.Err_Number Like '%3%'
			UNION
			SELECT  H.REDI_EC_Header_id 			AS rediCorrectionHeaderId,
					H.Upload_ID						AS uploadId,
					H.REDI_SOURCE 					AS sourceTypeDesc,
					H.Partner_Number 				AS sourceType,
					H.RAW_EDI_Invoice_Number 		AS invoiceNumber,
					convert(datetime,H.Invoice_Date, 112)	AS invoiceDate,
					--Duplicate error has custom data
					'Original Ship to: ' 			AS errId,
	  				ISNULL(CustOrig.Ship_to,H.Original_Shared_ship_to) 	AS errDesc,
	  				CustOrig.Name					AS errDesc1,
					'Final Ship to: '				AS errDesc2,
					ISNULL(CustFin.Ship_to,H.Current_Shared_ship_to) AS errDesc3,
					CustFin.Name					AS errDesc4,
					'Original Ship to: '			AS errAliasId,
					H.Alias_Original_Shared_ship_to	AS errAliasDesc,
					XOrig.External_Description		AS errAliasDesc1,
					'Final Ship to: '				AS errAliasDesc2,
					H.Alias_Current_Shared_ship_to	AS errAliasDesc3,
					XFinal.External_Description		AS errAliasDesc4,
					-----
					H.PO_Number							AS poNum,
					convert(datetime,H.PO_Date, 112)	AS PO_Date,
					H.Created_Date,
					'Duplicate: Invoice already exists' AS errorMessage,
					--H.Err_Msg								AS errorMessage,
					H.Err_number
				FROM REDI_EC_Header H
				INNER JOIN BB_Claim_Source_XREF XSource ON
			 		XSource.Source_Code = H.Partner_Number
			 	INNER JOIN BB_Claim_Dist_XREF XFinal ON 
			 		XFinal.External_Code = H.Alias_Current_Shared_ship_to AND
			 		XFinal.BB_Claim_Source_XREF_ID = XSource.BB_Claim_Source_XREF_ID
				LEFT JOIN BSA_Foodservice_Customers CustFin ON
					CustFin.Ship_To = XFinal.Shipto
				LEFT JOIN BB_Claim_Dist_XREF XOrig ON  
			 		XOrig.External_Code = H.Alias_Original_Shared_ship_to AND
			 		XOrig.BB_Claim_Source_XREF_ID = XSource.BB_Claim_Source_XREF_ID
				LEFT JOIN BSA_Foodservice_Customers CustOrig ON
					CustOrig.Ship_To = XOrig.Shipto
				WHERE H.Err_Number Like '%1%'
			UNION
			SELECT  H.REDI_EC_Header_id 		AS rediCorrectionHeaderId,
					H.Upload_ID					AS uploadId,
					H.REDI_SOURCE 				AS sourceTypeDesc,
					H.Partner_Number 			AS sourceType,
					H.RAW_EDI_Invoice_Number 	AS invoiceNumber,
					convert(datetime,H.Invoice_Date, 112)	AS invoiceDate,
					--Detail (item) level error
					ISNULL(IM.Item,D.Item_Number)	AS errId,  
					IM.[Description]			AS errDesc,
					''							AS errDesc1,
					''							AS errDesc2,
					''							AS errDesc3,
					''							AS errDesc4,
					D.Alias_Item_Number			AS errAliasId,
					D.Alias_Item_Desc			AS errAliasDesc,
					<!--- D.Unit_Price				AS errAliasDesc1, --->
					''							AS errAliasDesc1,
					''							AS errAliasDesc2,
					''							AS errAliasDesc3,
					''							AS errAliasDesc4,
					-----
					H.PO_Number 				AS poNum,
					convert(datetime,H.PO_Date, 112) 		AS PO_Date,
					H.Created_Date,
					--'Invalid Item Number'	AS errorMessage,
					D.Err_Msg					AS errorMessage,
					H.Err_number
				FROM REDI_EC_Header H
				INNER JOIN REDI_EC_Detail D ON
					D.Redi_H_Id = H.Redi_H_Id AND
					D.Upload_Id = H.Upload_Id
				LEFT JOIN BB_Claim_Source_XREF XSource ON
	 				XSource.Source_Code = H.Partner_Number
				LEFT JOIN BB_Claim_Item_XREF X ON
					X.External_Code = D.Alias_Item_Number AND
					X.BB_Claim_Source_XREF_ID = XSource.BB_Claim_Source_XREF_ID
				LEFT JOIN BSA_Foodservice_Items_Master IM ON
					IM.Item = X.Item
				WHERE H.Err_Number Like '%5%' AND
					D.Err_number IS NOT NULL
				--)go
				--select top 50 * from ##tmp 
				ORDER BY rediCorrectionHeaderId
		</cfquery>
	
		<cfreturn qGetReportData />
	</cffunction>
	
	
	
</cfcomponent>