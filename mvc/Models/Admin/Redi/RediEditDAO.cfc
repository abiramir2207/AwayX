<cfcomponent displayname="RediEditDAO" extends="mvc.Models.SettingsService">
	
<!---	<cffunction name="getRediEditHeaderData" output="false" access="public" returntype="Query" >
		<cfargument name="h" type="mvc.Models.Admin.Redi.vos.RediCorrectionHeader" >
		<cfscript>
			//set local variables
			var a = arguments;
			var qRediEditHeaderData	= queryNew("");
		</cfscript>
		 <cfquery name="qRediEditHeaderData" datasource="#application.datasource#">
		 	SELECT H.REDI_H_ID,
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
				H.isLocked,
				H.User_Id_Locked,
				U.Name_First,
				U.Name_Last
			FROM
			 	EDI_REDI_EC_Header H
			LEFT JOIN _Users U ON
				U.User_ID = H.User_Id_Locked
			WHERE REDI_H_ID = #H.rediCorrectionHeaderId#
	    </cfquery>
	    
	    <cfreturn qRediEditHeaderData />
	</cffunction> --->
	
	<cffunction name="getRediLockByMe" output="false" access="public" returntype="Query" >
		<cfscript>
			//set local variables
			var a = arguments;
			var qRediLockData	= queryNew("");
		</cfscript>
		 <cfquery name="qgetRediLockByMe" datasource="#application.datasource#">
			 SELECT * FROM
			 	REDI_EC_Header
			 WHERE User_Id_Locked = '#request.AccessStructure.User_ID#'
	    </cfquery>
	    
	    <cfreturn qRediLockData />
	</cffunction>
	<cffunction name="getRediUNLOCKByMe" output="false" access="public" returntype="Query" >
		<cfscript>
			//set local variables
			var a = arguments;
			var qRediLockData	= queryNew("");
		</cfscript>
		 <cfquery name="qgetRediUNLOCKByMe" datasource="#application.datasource#">
			 UPDATE REDI_EC_Header
			 SET Locked = 0,
			 User_Id_Locked = NULL,
			 Locked_Date = getDate()
			 WHERE User_Id_Locked = '#request.AccessStructure.User_ID#'
	    </cfquery>
	    
	    <cfreturn qRediLockData />
	</cffunction>
	<!--- Lock or Unlock - Set Lock Object in Header to desired result --->
	<cffunction name="setRediLockData" output="false" access="public" returntype="Query" >
		<cfargument name="h" type="any" >
		<cfscript>
			//set local variables
			var a = arguments;
			var qRediLockData	= queryNew("");
			var b = 0;
			if(h.lock.bLocked){
				b=1;
			}
		</cfscript>
		 <cfquery name="qSetRediLockData" datasource="#application.datasource#">
			UPDATE REDI_EC_Header
			SET Locked = #b#
			<cfif b eq 1>
				,User_Id_Locked = '#h.lock.userLocked.id#'
			<cfelse>
				,User_Id_Locked = NULL
			</cfif>
				,Locked_Date = getDate()
			WHERE REDI_EC_Header_id = #H.rediCorrectionHeaderId#
	    </cfquery>
	    <cfreturn qRediLockData />
	</cffunction>
	
	<cffunction name="getRediEditDetailData" output="false" access="public" returntype="Query" >
		<cfargument name="h" type="struct" > <!--- mvc.Models.Admin.Redi.vos.RediCorrectionHeader --->
		<cfscript>
			//set local variables
			var a = arguments;
			var qRediEditDetailData	= queryNew("");
		</cfscript>
		 <cfquery name="qRediEditDetailData" datasource="#application.datasource#">
			SELECT 
				D.REDI_H_ID ,
				D.REDI_D_ID ,
				D.Upload_ID ,
				D.Alias_Item_Number ,
				--D.Alias_Item_Desc ,
				ISNULL(X.External_Description,D.Alias_Item_Desc) AS Alias_Item_Desc, 
				ISNULL(IM.Item,D.Item_Number) AS Item_Number,
				D.line_Number ,
				D.Created_Date,
			    X.BB_Claim_Item_XREF_Id AS Alias_Record_Id,
			    D.Err_Msg,
			    D.qty,
			    D.Unit_Price,
			    IM.[Description],
                D.REDI_EC_DETAIL_ID    <!--- 85971 --->
			FROM REDI_EC_Header H
			INNER JOIN REDI_EC_Detail D ON
				D.Redi_H_Id = H.Redi_H_Id AND
				D.Upload_Id = H.Upload_Id
			LEFT JOIN BB_Claim_Source_XREF XSource ON
 				XSource.Source_Code = H.Partner_Number
			LEFT JOIN BB_Claim_Item_XREF X ON
				X.External_Code = D.Alias_Item_Number AND
				X.BB_Claim_Source_XREF_ID = XSource.BB_Claim_Source_XREF_ID AND
				X.External_Code != ''
			LEFT JOIN BSA_Foodservice_Items_Master IM ON
				IM.Item = X.Item
			WHERE H.REDI_EC_Header_id = #H.rediCorrectionHeaderId#
	    </cfquery>
	 <!---  <cfset this.dmp(qRediEditDetailData)/> ---> 
	    <cfreturn qRediEditDetailData />
	</cffunction>
	
	<cffunction name="saveRediEditDetailData" output="false" access="public" returntype="Any" >
		<cfargument name="D" type="struct" > <!--- mvc.Models.Admin.Redi.vos.RediCorrectionHeader --->
		<cfargument name="UploadID" type="any">

		<cfscript>
			//set local variables
			var a = arguments;
			var qRediEditDetailData	= queryNew("");
			var Detail = createobject('mvc.Models.Admin.Redi.vos.RediCorrectionDetail');
			Detail = D;
		</cfscript>
		 <cfquery name="qSaveRediEditDetailData" datasource="#application.datasource#">	
			UPDATE REDI_EC_Detail
			SET Item_Number = '#Detail.item#'
			WHERE REDI_D_ID = #Detail.rediCorrectionDetailId# AND
			REDI_H_ID 		= #Detail.rediCorrectionHeaderId# AND
			upload_ID 		= #arguments.UploadID#
	    </cfquery>
	  <!---  <cfset s = Detail.item & '  ::  ' & Detail.rediCorrectionDetailId />
	   		<cfset this.dmp(s)/>---> 
	
	   <cfreturn Detail />
	</cffunction>
	
	<cffunction name="validateRedi" output="false" access="public" returntype="Query" >
		<cfscript>
			//set local variables
			var a = arguments;
			var qRediEditDetailData	= queryNew("");
		</cfscript>
	    
	    <cfreturn qRediEditDetailData />
	</cffunction>
	
	<cffunction name="getCustomerInfo" access="public" returntype="query"> 	  
	  <cfargument name="shipTo" type="string" required="true">
	     
	    <cfquery name="qGetCustomerInfo" datasource="#application.datasource#">
		<!--- Active Distributor Only --->	      
		SELECT Name,
				Ship_To,
				City,
				State,
				Address_1,
				ZipCode,
				BSA_Foodservice_Customers_ID 
		FROM BSA_Foodservice_Customers
		WHERE deleted = 0
		--AND Active_code = 'A'
		AND Ship_To = <cfqueryparam value="#arguments.shipTo#" cfsqltype="CF_SQL_VARCHAR">
	    </cfquery>
	  
	   <cfreturn qGetCustomerInfo>

	</cffunction>
	
	<cffunction name="callvalidateSp" output="false" access="public" returntype="query" >
		<cfargument name="h" type="any" >  <!--- type="mvc.Models.Admin.Redi.vos.RediCorrectionHeade --->
		<cfscript>
			//set local variables
			var a = arguments;
			var qValidateRedi	= queryNew("");
		</cfscript>
		 <cfquery name="qValidateRedi" datasource="#application.datasource#">
		 	EXEC Upload_EDI_REDI_Caller_EC #h.rediCorrectionHeaderId#,2,0
		</cfquery>
	    
	    <cfreturn qValidateRedi />
	</cffunction>

</cfcomponent>