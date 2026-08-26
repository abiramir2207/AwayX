<cfcomponent extends="mvc.Models.SettingsService">
	<cfset appSettings = application.appSettingsGet />

	<cfscript>
		variables.oAliasDAO = createObject('component','mvc.Models.Admin.Alias.AliasManagerDAO');
	</cfscript>


	<cffunction name="init" output="false" returntype="mvc.Models.Admin.Alias.AliasManager">
		<cfreturn this />
	</cffunction>

	<!--- Get Sources --->
	<cffunction name="getSourceTypes" returntype="Array" access="remote">

		<cfset var arrSourceTypes = ArrayNew(1)>

		<cfset qSourceTypes = variables.oAliasDAO.getSourceTypeLookup()>

		  <cfloop query="qSourceTypes">
		     <!--- Create a array of struct for source types --->
		     <cfset getSourceTypesStruct(qSourceTypes)>
		     <cfset ArrayAppend(arrSourceTypes, duplicate(stData))>
		  </cfloop>

		<!---
		   <cfset arrSourceTypes[1] = 'PAYEE ALIAS'>
		   <cfset arrSourceTypes[2] = 'SYSCO EDI'>
		   <cfset arrSourceTypes[3] = 'USFS EDI'>
		   <cfset arrSourceTypes[4] = 'ALL ALIAS'>
		--->

	   <cfreturn arrSourceTypes>

	</cffunction>

	<!--- Take the source types query and create a structure --->
	<cffunction name="getSourceTypesStruct" access="private" returntype="Struct">
	  <cfargument name="qSourceTypes" type="query" required="true">

		    <cfscript>
			stData = structNew();
			stData["sourceType"] = qSourceTypes.Source_Type;
			stData["sourceCode"] = qSourceTypes.Source_Code;
			stData["sourceCodeDisplay"] = qSourceTypes.Source_Code_Display;
			stData["useSearchTool"] = qSourceTypes.Use_Search_Tool;
		    </cfscript>

	   <cfreturn stData>
	</cffunction>

	<!--- Query distributor information for a specific distributor and send it as an array --->
	<cffunction name="getDistributorInfo" returntype="array" access="remote">
	  <cfargument name="distributorID" type="string" required="true">
	  <!--- Sometimes GUID is passed and sometimes it is the ship_to --->
	  <cfargument name="isGUID" type="boolean" required="false" default="false">
	  <cfargument name="Check_shipto_OR_Shrshipto" type="boolean" required="false" default="false">

	  <cfset var qGetDistributorInfo = variables.oAliasDAO.getDistributorDetails(arguments.distributorID,arguments.isGUID,arguments.Check_shipto_OR_Shrshipto) />

	  <cfset var arrDistInfo = ArrayNew(1)>

		     <!--- No need to send it as an object. "aliasDesc" is a property of the Alias Object and it means Name,Address.
		        We use Name,Address from here to populate that property in flex.
		     --->
		    <cfscript>
			stData = structNew();
			//stData["__type__"] = "mvc.Models.Entity.vos.Customer";
			stData["shipTo"] = qGetDistributorInfo.Ship_To;
			stData["name"] = LTrim(RTrim(qGetDistributorInfo.Name));
			stData["address"] = LTrim(RTrim(qGetDistributorInfo.City)) & ',' & LTrim(RTrim(qGetDistributorInfo.State));
		    </cfscript>

			<cfset ArrayAppend(arrDistInfo, stData)>

	     <cfreturn arrDistInfo>

	</cffunction>

	<!--- Query distributor information for a specific distributor and send it in JSON format --->
	<cffunction name="getDistributorInfoJSON" access="remote" returnFormat="json">
	  <cfargument name="distributorID" type="string" required="true">
	  <cfargument name="isGUID" type="boolean" required="true">

	  <cfset var qGetDistributorInfo = variables.oAliasDAO.getDistributorDetails(arguments.distributorID,arguments.isGUID) />

		<cfscript>
		stData = structNew();
		stData["shipTo"] = qGetDistributorInfo.Ship_To;
		stData["name"] = LTrim(RTrim(qGetDistributorInfo.Name));
		if(qGetDistributorInfo.Ship_To neq ""){
			stData["address"] = LTrim(RTrim(qGetDistributorInfo.City)) & ',' & LTrim(RTrim(qGetDistributorInfo.State));
		}
		else{
			stData["address"] = "";
		}
		</cfscript>

		<cfset stData = serializeJSON(stData, "struct")>

		<cfreturn stData>

	</cffunction>

	<!--- Query item information for a specific item and send it as an array --->
	<cffunction name="getItemInfo" returntype="array" access="remote">
	  <cfargument name="itemID" type="string" required="true">
	  <cfargument name="isGUID" type="boolean" required="true">

	  <cfset var qGetItemInfo = variables.oAliasDAO.getItemDetails(arguments.itemID,arguments.isGUID) />

	  <cfset var arrItemInfo = ArrayNew(1)>

		    <cfscript>
			stData = structNew();
			stData["ItemID"] = LTrim(RTrim(qGetItemInfo.Item));
			stData["desc"] = LTrim(RTrim(qGetItemInfo.Description));
		    </cfscript>

			<cfset ArrayAppend(arrItemInfo, stData)>

	     <cfreturn arrItemInfo>

	</cffunction>

	<!--- Query item information for a specific item and send it in JSON format --->
	<cffunction name="getItemInfoJSON" access="remote" returnFormat="json">
	  <cfargument name="itemID" type="string" required="true">
	  <cfargument name="isGUID" type="boolean" required="true">

	  <cfset var qGetItemInfo = variables.oAliasDAO.getItemDetails(arguments.itemID,arguments.isGUID) />

		<cfscript>
		stData = structNew();
		stData["ItemID"] = LTrim(RTrim(qGetItemInfo.Item));
		stData["desc"] = LTrim(RTrim(qGetItemInfo.Description));
		</cfscript>

		<cfset stData = serializeJSON(stData, "struct")>

	 <cfreturn stData>

	</cffunction>

	<!--- Query program information for a specific program and send it as an array --->
	<cffunction name="getProgramInfo" returntype="array" access="remote">
	  <cfargument name="programID" type="string" required="true">
	  <cfargument name="isContractNumber" type="boolean" required="true">

	  <cfset var qGetProgramInfo = variables.oAliasDAO.getProgramDetails(arguments.programID,arguments.isContractNumber) />

	  <cfset var arrProgramInfo = ArrayNew(1)>

		    <cfscript>
			stData = structNew();
			stData["contractID"] = LTrim(RTrim(qGetProgramInfo.Contract_Number));
			stData["desc"] = LTrim(RTrim(qGetProgramInfo.Contract_Title));
			// stData["isAssigned"] = qGetProgramInfo.isAssigned;
			//stData["contractDates"] = LTrim(RTrim(qGetProgramInfo.Contract_Start_Date)); & '-' & LTrim(RTrim(qGetProgramInfo.Contract_End_Date));
		    </cfscript>

			<cfset ArrayAppend(arrProgramInfo, stData)>

	     <cfreturn arrProgramInfo>

	</cffunction>

	<!--- Query program information for a specific program and send it in JSON format --->
	<cffunction name="getProgramInfoJSON" access="remote" returnFormat="json">
	  <cfargument name="programID" type="string" required="true">
	  <cfargument name="isContractNumber" type="boolean" required="true">

	  <cfset var qGetProgramInfo = variables.oAliasDAO.getProgramDetails(arguments.programID,arguments.isContractNumber) />

		    <cfscript>
			stData = structNew();
			stData["contractID"] = LTrim(RTrim(qGetProgramInfo.Contract_Number));
			stData["desc"] = LTrim(RTrim(qGetProgramInfo.Contract_Title));
		    </cfscript>

			<cfset stData = serializeJSON(stData, "struct")>

	     <cfreturn stData>

	</cffunction>


	<!--- Query operator information for a specific operator and send it as an array --->
	<cffunction name="getOperatorInfo" returntype="array" access="remote">
	  <cfargument name="operatorID" type="string" required="true">
	  <cfargument name="isLegacyID" type="boolean" required="true">

	  <cfset var qGetOperatorInfo = variables.oAliasDAO.getOperatorDetails(arguments.operatorID,arguments.isLegacyID) />

	  <cfset var arrOperatorInfo = ArrayNew(1)>

		     <!--- No need to send it as an object. "aliasDesc" is a property of the Alias Object and it means Name,Address.
		        We use Name,Address from here to populate that property in flex.
		     --->
		    <cfscript>
			stData = structNew();
			stData["legacyID"] = qGetOperatorInfo.legacy_id;
			stData["name"] = LTrim(RTrim(qGetOperatorInfo.Operator_Name));
			stData["address"] = LTrim(RTrim(qGetOperatorInfo.Operator_City)) & ',' & LTrim(RTrim(qGetOperatorInfo.Operator_State));
			stData["BSA_Operator_ID"] = qGetOperatorInfo.BSA_Operator_ID;
		//	stData["isAssigned"] = qGetOperatorInfo.isAssigned;
		    </cfscript>

			<cfset ArrayAppend(arrOperatorInfo, stData)>

	     <cfreturn arrOperatorInfo>

	</cffunction>

	<!--- Query operator information for a specific operator and send it in JSON format --->
	<cffunction name="getOperatorInfoJSON" access="remote" returnFormat="json">
	  <cfargument name="operatorID" type="string" required="true">
	  <cfargument name="isLegacyID" type="boolean" required="true">

	  <cfset var qGetOperatorInfo = variables.oAliasDAO.getOperatorDetails(arguments.operatorID,arguments.isLegacyID) />

		<cfscript>
		stData = structNew();
		stData["legacyID"] = qGetOperatorInfo.legacy_id;
		stData["BSA_Operator_ID"] = qGetOperatorInfo.BSA_Operator_ID;
		stData["name"] = LTrim(RTrim(qGetOperatorInfo.Operator_Name));
		if(qGetOperatorInfo.BSA_Operator_ID neq ""){
			stData["address"] = LTrim(RTrim(qGetOperatorInfo.Operator_City)) & ',' & LTrim(RTrim(qGetOperatorInfo.Operator_State));
		}
		else{
			stData["address"] = "";
		}
		</cfscript>

		<cfset stData = serializeJSON(stData, "struct")>

	 <cfreturn stData>

	</cffunction>

	<!--- Query vendor information and send it as a "Payee" object --->
	<cffunction name="getVendorInfo" returntype="struct" access="remote">
	  <cfargument name="vendorID" type="string" required="true">

	  <cfset var qGetVendorInfo = variables.oAliasDAO.getVendorDetails(arguments.vendorID) />
	  <cfset Vendor_Details = LTrim(RTrim(qGetVendorInfo.City))>

	  <cfif qGetVendorInfo.State neq "">
		<cfset Vendor_Details = Vendor_Details & ',' & LTrim(RTrim(qGetVendorInfo.State))>
	  </cfif>

		    <!--- Send it as a "Payee" object. I have added "address" to the "name" property as address is an object by itself
			  and has other properties like address1, address2 etc.
		    --->
		    <cfscript>
			stData = structNew();
			stData["__type__"] = "mvc.Models.Entity.vos.Payee";
			stData["payeeTypeId"] = "";
			stData["name"] = LTrim(RTrim(qGetVendorInfo.Vendor_Name)) & "#chr(13)##chr(10)#" & Vendor_Details;
			stData["payeeId"] = qGetVendorInfo.Vendor_ID;
			//stData["address"] = LTrim(RTrim(qGetVendorInfo.City)) & ',' & LTrim(RTrim(qGetVendorInfo.State));
		    </cfscript>

	     <cfreturn stData>

	</cffunction>

	<!--- Query vendor information and send it in JSON format --->
	<cffunction name="getVendorInfoJSON" access="remote" returnFormat="json">
	  <cfargument name="vendorID" type="string" required="true">

		<cfset var qGetVendorInfo = variables.oAliasDAO.getVendorDetails(arguments.vendorID) />
		<cfset Vendor_Details = LTrim(RTrim(qGetVendorInfo.City))>

		<cfif qGetVendorInfo.State neq "">
			<cfset Vendor_Details = Vendor_Details & ',' & LTrim(RTrim(qGetVendorInfo.State))>
		</cfif>

		<cfscript>
		stData = structNew();
		stData["name"] = LTrim(RTrim(qGetVendorInfo.Vendor_Name));
		stData["address"] = Vendor_Details;
		</cfscript>

		<cfset stData = serializeJSON(stData, "struct")>

		<cfreturn stData>

	</cffunction>


		<!--- Query distributor aliases for a source and send it as an "AliasDef" object --->
	<cffunction name="getDistributorAliases" returntype="array" access="remote">
	  <cfargument name="sourceType" type="numeric" required="true">
	  <cfargument name="sourceID" type="string" required="false" default="">
	  <cfargument name="aliasID" type="string" required="false" default="">
	  <cfargument name="arrAliasID" required="false" default="#ArrayNew(1)#">

	  <cfset var arrDistAlias = ArrayNew(1)>
	  <cfset var StructErrorMessage = StructNew()>

	  <!--- Check if the source exists --->
	  <cfset qGetSourceInfo = variables.oAliasDAO.getSourceDetails(arguments.sourceID) />

	  <!--- If the source exists OR the source not Vendor. Currently non-vendor sources include "EDI", "CBS" and "All Aliases" --->
	  <cfif (arguments.sourceType eq 2 AND qGetSourceInfo.recordcount eq 1) OR arguments.sourceType neq 2>

		<!--- Load distributor aliases for the source --->
		<cfset qGetDistributorAliases = variables.oAliasDAO.getDistributorAliasDetails(arguments.sourceType,arguments.sourceID,arguments.aliasID,arguments.arrAliasID) />

		<!--- If the distributor aliases exists for the source, loop through those distributor aliases --->
		<cfif qGetDistributorAliases.recordcount neq 0>
		  <cfloop query="qGetDistributorAliases">
		   <!--- Create an "AliasDef" object of the aliases --->
		   <cfset getDistributorAliasesObject(qGetDistributorAliases)>
		   <cfset ArrayAppend(arrDistAlias, duplicate(stData))>
		  </cfloop>

		<cfelse>
		   <!--- If there are no aliases for the source, send an empty shell of the "AliasDef" object --->
		   <cfset getDistributorAliasesObject(qGetDistributorAliases)>
		   <cfset ArrayAppend(arrDistAlias, duplicate(stData))>
		</cfif>

	    <cfelse>
		     <!--- If the source does not exist, send the error message in the "sourceID" property of the struct - "StructErrorMessage".
			   Note: Even the "AliasDef" object has a "sourceID" property. Whenever there is no error message, i.e. the code is not executed
			   for this condition, the "sourceID" property of the AliasDef is empty.
		     --->
		     <cfset StructErrorMessage.sourceID = "Source Not Found">
		     <cfset ArrayAppend(arrDistAlias, StructErrorMessage)>
	   </cfif>

	     <cfreturn arrDistAlias>

	</cffunction>

	<!--- Query distributor aliases for a source --->
	<cffunction name="getDistributorAliasesQuery" access="remote" returntype="query">
	  <cfargument name="sourceType" type="numeric" required="true">
	  <cfargument name="sourceID" type="string" required="false" default="">
	  <cfargument name="aliasID" type="string" required="false" default="">
	  <cfargument name="arrAliasID" required="false" default="#ArrayNew(1)#">
	  <cfargument name="startRow" type="numeric" required="true">
	  <cfargument name="endRow" type="numeric" required="true">
	  <cfargument name="filterModel" type="any" required="false" default=#StructNew()#>
	  <cfargument name="sortColumn" type="string" required="false">
	  <cfargument name="sortOrder" type="string" required="false">

	  <cfset var arrDistAlias = ArrayNew(1)>
	  <cfset var StructErrorMessage = StructNew()>
	  <cfset var strFilterModel = DeserializeJSON(arguments.filterModel)>
	  <cfset var qGetDistributorAliases = QueryNew("")>

	  <!--- Check if the source exists --->
	  <cfset qGetSourceInfo = variables.oAliasDAO.getSourceDetails(arguments.sourceID) />

	  <!--- If the source exists OR the source not Vendor. Currently non-vendor sources include "EDI", "CBS" and "All Aliases" --->
	  <cfif (arguments.sourceType eq 2 AND qGetSourceInfo.recordcount eq 1) OR arguments.sourceType neq 2>

		<!--- Load distributor aliases for the source --->
		<cfset qGetDistributorAliases = variables.oAliasDAO.getDistributorAliasDetails(arguments.sourceType,arguments.sourceID,arguments.aliasID,arguments.arrAliasID,
										arguments.startRow,arguments.endRow,strFilterModel,arguments.sortColumn,arguments.sortOrder) />
	   </cfif>

	   <cfreturn  qGetDistributorAliases>
	</cffunction>

	<!--- Take the distributor aliases query and create an "AliasDef" object --->
	<cffunction name="getDistributorAliasesObject" access="private" returntype="Struct">
	  <cfargument name="qGetDistributorAliases" type="query" required="true">

		    <cfscript>
			stData = structNew();
			stData["__type__"] = "mvc.Models.Admin.Alias.vos.AliasDef";
			/* Using "0" as the entity type for "Distributor" */
			stData["entityType"] = 0;
			stData["sourceType"] = "";
			stData["sourceTypeDesc"] = qGetDistributorAliases.sourceTypeDesc;
			stData["sourceID"] = "";
			stData["payeeID"] = qGetDistributorAliases.payeeID;
			stData["recordID"] = qGetDistributorAliases.recordID;
			stData["aliasID"] = qGetDistributorAliases.aliasID;
			stData["aliasRegion"] = qGetDistributorAliases.aliasRegion;
			stData["aliasDesc"] = qGetDistributorAliases.aliasDesc;
			stData["aliasAddress"] = qGetDistributorAliases.aliasAddress;
			stData["aliasCity"] = qGetDistributorAliases.aliasCity;
			stData["aliasState"] = qGetDistributorAliases.aliasState;
			stData["aliasZIP"] = qGetDistributorAliases.aliasZIP;
			stData["aliasUniproNum"] = qGetDistributorAliases.aliasUniproNum;
			stData["aliasLoc"] = qGetDistributorAliases.aliasLoc;
			stData["entityID"] = qGetDistributorAliases.entityID;
			stData["entityDesc"] = qGetDistributorAliases.entityDesc;
			stData["isAssigned"] = qGetDistributorAliases.isAssigned;
			stData["Unknown"] = qGetDistributorAliases.Unknown;
			stData["holdInvoiceCount"] = qGetDistributorAliases.holdInvoiceCount;
		    </cfscript>

	   <cfreturn stData>
	</cffunction>


	<!--- Query item aliases for a source and send it as an "AliasDef" object --->
	<cffunction name="getItemAliases" returntype="array" access="remote">
	  <cfargument name="sourceType" type="numeric" required="true">
	  <cfargument name="sourceID" type="string" required="false" default="">
	  <cfargument name="aliasID" type="string" required="false" default="">
	  <cfargument name="arrAliasID" required="false" default="#ArrayNew(1)#">

	  <cfset var arrItemAlias = ArrayNew(1)>
	  <cfset var StructErrorMessage = StructNew()>

	  <!--- Check if the source exists --->
	  <cfset qGetSourceInfo = variables.oAliasDAO.getSourceDetails(arguments.sourceID) />

	  <!--- If the source exists OR the source not Vendor. Currently non-vendor sources include "EDI", "CBS" and "All Aliases" --->
	  <cfif (arguments.sourceType eq 2 AND qGetSourceInfo.recordcount eq 1) OR arguments.sourceType neq 2>

		<!--- Load distributor aliases for the source --->
		<cfset qGetItemAliases = variables.oAliasDAO.getItemAliasDetails(arguments.sourceType,arguments.sourceID,arguments.aliasID,arguments.arrAliasID) />

		<!--- If the distributor aliases exists for the source, loop through those distributor aliases --->
		<cfif qGetItemAliases.recordcount neq 0>
		  <cfloop query="qGetItemAliases">
		   <!--- Create an "AliasDef" object of the aliases --->
		   <cfset getItemAliasesObject(qGetItemAliases)>
		   <cfset ArrayAppend(arrItemAlias, duplicate(stData))>
		  </cfloop>

		<cfelse>
		   <!--- If there are no aliases for the source, send an empty shell of the "AliasDef" object --->
		   <cfset getItemAliasesObject(qGetItemAliases)>
		   <cfset ArrayAppend(arrItemAlias, duplicate(stData))>
		</cfif>

	    <cfelse>
		    <!--- If the source does not exist, keep the "sourceID" property of the struct - "StructErrorMessage" blank. We are already passing the
			   error message from the first query - "getDistributorAliases".
		     --->
		     <cfset StructErrorMessage.sourceID = "">
		     <cfset ArrayAppend(arrItemAlias, StructErrorMessage)>

	   </cfif>

	     <cfreturn arrItemAlias>

	</cffunction>

	<!--- Query item aliases for a source --->
	<cffunction name="getItemAliasesQuery" access="remote" returntype="query">
	  <cfargument name="sourceType" type="numeric" required="true">
	  <cfargument name="sourceID" type="string" required="false" default="">
	  <cfargument name="aliasID" type="string" required="false" default="">
	  <cfargument name="arrAliasID" required="false" default="#ArrayNew(1)#">
	  <cfargument name="startRow" type="numeric" required="false">
	  <cfargument name="endRow" type="numeric" required="false">
	  <cfargument name="filterModel" type="any" required="false" default=#StructNew()#>
	  <cfargument name="sortColumn" type="string" required="false">
	  <cfargument name="sortOrder" type="string" required="false">

	  <cfset var arrItemAlias = ArrayNew(1)>
	  <cfset var StructErrorMessage = StructNew()>
	  <cfset var strFilterModel = DeserializeJSON(arguments.filterModel)>
	  <cfset var qGetItemAliases = QueryNew("")>

	  <!--- Check if the source exists --->
	  <cfset qGetSourceInfo = variables.oAliasDAO.getSourceDetails(arguments.sourceID) />

	  <!--- If the source exists OR the source not Vendor. Currently non-vendor sources include "EDI", "CBS" and "All Aliases" --->
	  <cfif (arguments.sourceType eq 2 AND qGetSourceInfo.recordcount eq 1) OR arguments.sourceType neq 2>

		<!--- Load distributor aliases for the source --->
		<cfset qGetItemAliases = variables.oAliasDAO.getItemAliasDetails(arguments.sourceType,arguments.sourceID,arguments.aliasID,arguments.arrAliasID,
								arguments.startRow,arguments.endRow,strFilterModel,arguments.sortColumn,arguments.sortOrder) />
	   </cfif>

	   <cfreturn qGetItemAliases>
	</cffunction>

	<!--- Take the item aliases query and create an "AliasDef" object --->
	<cffunction name="getItemAliasesObject" access="private" returntype="Struct">
	  <cfargument name="qGetItemAliases" type="query" required="true">

		    <cfscript>
			stData = structNew();
			stData["__type__"] = "mvc.Models.Admin.Alias.vos.AliasDef";
			/* Using "1" as the entity type for "Item" */
			stData["entityType"] = 1;
			stData["sourceType"] = "";
			stData["sourceTypeDesc"] = qGetItemAliases.sourceTypeDesc;
			stData["sourceID"] = "";
			stData["payeeID"] = qGetItemAliases.payeeID;
			stData["recordID"] = qGetItemAliases.recordID;
			stData["aliasID"] = qGetItemAliases.aliasID;
			stData["aliasDesc"] = qGetItemAliases.aliasDesc;
			stData["entityID"] = qGetItemAliases.entityID;
			stData["entityDesc"] = qGetItemAliases.entityDesc;
			stData["isAssigned"] = qGetItemAliases.isAssigned;
			stData["Unknown"] = qGetItemAliases.Unknown;
			stData["holdInvoiceCount"] = qGetItemAliases.holdInvoiceCount;
		    </cfscript>

	   <cfreturn stData>
	</cffunction>

	<!--- Query program aliases for a source and send it as an "AliasDef" object --->
	<cffunction name="getProgramAliases" returntype="array" access="remote">
	  <cfargument name="sourceType" type="numeric" required="true">
	  <cfargument name="sourceID" type="string" required="false" default="">
	  <cfargument name="aliasID" type="string" required="false" default="">
	  <cfargument name="arrAliasID" required="false" default="#ArrayNew(1)#">

	  <cfset var arrProgramAlias = ArrayNew(1)>
	  <cfset var StructErrorMessage = StructNew()>

	  <!--- Check if the source exists --->
	  <cfset qGetSourceInfo = variables.oAliasDAO.getSourceDetails(arguments.sourceID) />

	  <!--- If the source exists OR the source not Vendor. Currently non-vendor sources include "EDI", "CBS" and "All Aliases" --->
	  <cfif (arguments.sourceType eq 2 AND qGetSourceInfo.recordcount eq 1) OR arguments.sourceType neq 2>

		<!--- Load program aliases for the source --->
		<cfset qGetProgramAliases = variables.oAliasDAO.getProgramAliasDetails(arguments.sourceType,arguments.sourceID,arguments.aliasID,arguments.arrAliasID) />

		<!--- If the program aliases exists for the source, loop through those program aliases --->
		<cfif qGetProgramAliases.recordcount neq 0>
		  <cfloop query="qGetProgramAliases">
		   <!--- Create an "AliasDef" object of the aliases --->
		   <cfset getProgramAliasesObject(qGetProgramAliases)>
		   <cfset ArrayAppend(arrProgramAlias, duplicate(stData))>
		  </cfloop>

		<cfelse>
		   <!--- If there are no aliases for the source, send an empty shell of the "AliasDef" object --->
		   <cfset getProgramAliasesObject(qGetProgramAliases)>
		   <cfset ArrayAppend(arrProgramAlias, duplicate(stData))>
		</cfif>

	    <cfelse>
		     <!--- If the source does not exist, keep the "sourceID" property of the struct - "StructErrorMessage" blank. We are already passing the
			   error message from the first query - "getDistributorAliases".
		     --->
		     <cfset StructErrorMessage.sourceID = "">
		     <cfset ArrayAppend(arrProgramAlias, StructErrorMessage)>
	   </cfif>

	     <cfreturn arrProgramAlias>

	</cffunction>

	<!--- Query program aliases for a source --->
	<cffunction name="getProgramAliasesQuery" access="remote" returntype="query">
	  <cfargument name="sourceType" type="numeric" required="true">
	  <cfargument name="sourceID" type="string" required="false" default="">
	  <cfargument name="aliasID" type="string" required="false" default="">
	  <cfargument name="arrAliasID" required="false" default="#ArrayNew(1)#">
	  <cfargument name="startRow" type="numeric" required="false">
	  <cfargument name="endRow" type="numeric" required="false">
	  <cfargument name="filterModel" type="any" required="false" default=#StructNew()#>
	  <cfargument name="sortColumn" type="string" required="false">
	  <cfargument name="sortOrder" type="string" required="false">

	  <cfset var arrProgramAlias = ArrayNew(1)>
	  <cfset var StructErrorMessage = StructNew()>
	  <cfset var strFilterModel = DeserializeJSON(arguments.filterModel)>
	  <cfset var qGetProgramAliases = QueryNew("")>

	  <!--- Check if the source exists --->
	  <cfset qGetSourceInfo = variables.oAliasDAO.getSourceDetails(arguments.sourceID) />

	  <!--- If the source exists OR the source not Vendor. Currently non-vendor sources include "EDI", "CBS" and "All Aliases" --->
	  <cfif (arguments.sourceType eq 2 AND qGetSourceInfo.recordcount eq 1) OR arguments.sourceType neq 2>

		<!--- Load program aliases for the source --->
		<cfset qGetProgramAliases = variables.oAliasDAO.getProgramAliasDetails(arguments.sourceType,arguments.sourceID,arguments.aliasID,arguments.arrAliasID,
									arguments.startRow,arguments.endRow,strFilterModel,arguments.sortColumn,arguments.sortOrder) />
	   </cfif>

	   <cfreturn qGetProgramAliases>
	</cffunction>

	<!--- Take the program aliases query and create an "AliasDef" object --->
	<cffunction name="getProgramAliasesObject" access="private" returntype="Struct">
	  <cfargument name="qGetProgramAliases" type="query" required="true">

		    <cfscript>
			stData = structNew();
			stData["__type__"] = "mvc.Models.Admin.Alias.vos.AliasDef";
			/* Using "2" as the entity type for "Program" */
			stData["entityType"] = 2;
			stData["sourceType"] = "";
			stData["sourceTypeDesc"] = qGetProgramAliases.sourceTypeDesc;
			stData["sourceID"] = "";
			stData["payeeID"] = qGetProgramAliases.payeeID;
			stData["recordID"] = qGetProgramAliases.recordID;
			stData["aliasID"] = qGetProgramAliases.aliasID;
			stData["aliasDesc"] = qGetProgramAliases.aliasDesc;
			stData["entityID"] = qGetProgramAliases.entityID;
			stData["entityDesc"] = qGetProgramAliases.entityDesc;
			stData["isAssigned"] = qGetProgramAliases.isAssigned;
			stData["holdInvoiceCount"] = qGetProgramAliases.holdInvoiceCount;
			stData["Unknown"] = qGetProgramAliases.Unknown;
		    </cfscript>

	   <cfreturn stData>
	</cffunction>

	<!--- Query operator aliases for a source and send it as an "AliasDef" object --->
	<cffunction name="getOperatorAliases" returntype="array" access="remote">
	  <cfargument name="sourceType" type="numeric" required="true">
	  <cfargument name="sourceID" type="string" required="false" default="">
	  <cfargument name="aliasID" type="string" required="false" default="">
	  <cfargument name="arrAliasID" required="false" default="#ArrayNew(1)#">

	  <cfset var arrOperatorAlias = ArrayNew(1)>
	  <cfset var StructErrorMessage = StructNew()>

	  <!--- Check if the source exists --->
	  <cfset qGetSourceInfo = variables.oAliasDAO.getSourceDetails(arguments.sourceID) />

	  <!--- If the source exists OR the source not Vendor. Currently non-vendor sources include "EDI", "CBS" and "All Aliases" --->
	  <cfif (arguments.sourceType eq 2 AND qGetSourceInfo.recordcount eq 1) OR arguments.sourceType neq 2>

		<!--- Load operator aliases for the source --->
		<cfset qGetOperatorAliases = variables.oAliasDAO.getOperatorAliasDetails(arguments.sourceType,arguments.sourceID,arguments.aliasID,arguments.arrAliasID) />

		<!--- If the operator aliases exists for the source, loop through those operator aliases --->
		<cfif qGetOperatorAliases.recordcount neq 0>
		  <cfloop query="qGetOperatorAliases">
		   <!--- Create an "AliasDef" object of the aliases --->
		   <cfset getOperatorAliasesObject(qGetOperatorAliases)>
		   <cfset ArrayAppend(arrOperatorAlias, duplicate(stData))>
		  </cfloop>

		<cfelse>
		   <!--- If there are no aliases for the source, send an empty shell of the "AliasDef" object --->
		   <cfset getOperatorAliasesObject(qGetOperatorAliases)>
		   <cfset ArrayAppend(arrOperatorAlias, duplicate(stData))>
		</cfif>

	    <cfelse>
		     <!--- If the source does not exist, send the error message in the "sourceID" property of the struct - "StructErrorMessage".
			   Note: Even the "AliasDef" object has a "sourceID" property. Whenever there is no error message, i.e. the code is not executed
			   for this condition, the "sourceID" property of the AliasDef is empty.
		     --->
		     <cfset StructErrorMessage.sourceID = "Source Not Found">
		     <cfset ArrayAppend(arrOperatorAlias, StructErrorMessage)>
	   </cfif>

	     <cfreturn arrOperatorAlias>

	</cffunction>

	<!--- Query operator aliases for a source --->
	<cffunction name="getOperatorAliasesQuery" access="remote" returntype="query">
	  <cfargument name="sourceType" type="numeric" required="true">
	  <cfargument name="sourceID" type="string" required="false" default="">
	  <cfargument name="aliasID" type="string" required="false" default="">
	  <cfargument name="arrAliasID" required="false" default="#ArrayNew(1)#">
	  <cfargument name="startRow" type="numeric" required="false">
	  <cfargument name="endRow" type="numeric" required="false">
	  <cfargument name="filterModel" type="any" required="false" default=#StructNew()#>
	  <cfargument name="sortColumn" type="string" required="false">
	  <cfargument name="sortOrder" type="string" required="false">

	  <cfset var arrOperatorAlias = ArrayNew(1)>
	  <cfset var StructErrorMessage = StructNew()>
	  <cfset var strFilterModel = DeserializeJSON(arguments.filterModel)>
	  <cfset var qGetOperatorAliases = QueryNew("")>

	  <!--- Check if the source exists --->
	  <cfset qGetSourceInfo = variables.oAliasDAO.getSourceDetails(arguments.sourceID) />

	  <!--- If the source exists OR the source not Vendor. Currently non-vendor sources include "EDI", "CBS" and "All Aliases" --->
	  <cfif (arguments.sourceType eq 2 AND qGetSourceInfo.recordcount eq 1) OR arguments.sourceType neq 2>

		<!--- Load operator aliases for the source --->
		<cfset qGetOperatorAliases = variables.oAliasDAO.getOperatorAliasDetails(arguments.sourceType,arguments.sourceID,arguments.aliasID,arguments.arrAliasID,
									arguments.startRow,arguments.endRow,strFilterModel,arguments.sortColumn,arguments.sortOrder, 1) />
	   </cfif>

	   <cfreturn qGetOperatorAliases>
	</cffunction>

	<!--- Take the operator aliases query and create an "AliasDef" object --->
	<cffunction name="getOperatorAliasesObject" access="private" returntype="Struct">
	  <cfargument name="qGetOperatorAliases" type="query" required="true">

		    <cfscript>
			var sAddress = '';
			if(rtrim(ltrim(qGetOperatorAliases.entityAddress)) != '' || rtrim(ltrim(qGetOperatorAliases.Operator_City != ''))){
				sAddress = qGetOperatorAliases.entityAddress & ' ' & qGetOperatorAliases.Operator_City & ', ' & qGetOperatorAliases.Operator_State & ' ' & qGetOperatorAliases.Operator_Zip;
			}
			stData = structNew();
			stData["__type__"] = "mvc.Models.Admin.Alias.vos.AliasDef";
			/* Using "3" as the entity type for "Operator" */
			stData["entityType"] = 3;
			stData["sourceType"] = "";
			stData["sourceTypeDesc"] = qGetOperatorAliases.sourceTypeDesc;
			stData["sourceID"] = "";
			stData["payeeID"] = qGetOperatorAliases.payeeID;
			stData["recordID"] = qGetOperatorAliases.recordID;
			stData["aliasID"] = qGetOperatorAliases.aliasID;
			stData["aliasDesc"] = qGetOperatorAliases.aliasDesc;
			stData["aliasAddress"] = qGetOperatorAliases.aliasAddress & ' ' & qGetOperatorAliases.City & ', ' & qGetOperatorAliases.State & ' ' & qGetOperatorAliases.Zip;
			stData["aliasZIP"] = qGetOperatorAliases.Zip;
			stData["entityID"] = qGetOperatorAliases.entityID;
			stData["entityDesc"] = qGetOperatorAliases.entityDesc;
			stData["entityAddress"] = sAddress;
			stData["bsaId"] = qGetOperatorAliases.bsaId;
			stData["isAssigned"] = qGetOperatorAliases.isAssigned;
			stData["holdInvoiceCount"] = qGetOperatorAliases.holdInvoiceCount;
			stData["Unknown"] = qGetOperatorAliases.Unknown;
		    </cfscript>

	   <cfreturn stData>
	</cffunction>

	<!--- save aliases and send the saved alias entry as an "AliasDef" object --->
	<cffunction name="saveAlias" returntype="array" access="remote">
	  <cfargument name="AliasDef" required="true">
	  <cfargument name="entityType" type="numeric" required="true">
	  <cfargument name="userID" type="string" required="true">
	  <cfargument name="bRefreshData" type="boolean" required="false" default="1">

		<cfif arguments.AliasDef.ALIASID EQ '~Infinity'>
			<cfset arguments.AliasDef.ALIASID = 'Infinity' >
		</cfif>
		<cfif arguments.AliasDef.ALIASDESC EQ '~Infinity'>
			<cfset arguments.AliasDef.ALIASDESC = 'Infinity' >
		</cfif>

	  <cfset var arrEntityAliases = ArrayNew(1)>
	  <cfset var StructErrorMessage = StructNew()>
	  <cfset var SourceAliasExists = 0>
	  <cfset var bError = 0 />
	  <cfset var sErrorMessage = "" />

	   <!--- Check if the source is valid --->
	   <cfset qGetSourceInfo = variables.oAliasDAO.getSourceDetails(arguments.AliasDef.sourceID) />

	   <!--- If the source exists OR the source not Vendor. Currently non-vendor sources include "EDI", "CBS" and "All Aliases" --->
	   <cfif (arguments.AliasDef.sourceType eq 2 AND qGetSourceInfo.recordcount eq 1) OR arguments.AliasDef.sourceType neq 2>


		<!--- Check to see whether the source exists in the "BB_Claim_Source_XREF" table --->
		<cfset qGetSourceInfo = variables.oAliasDAO.getSourceExists(arguments.AliasDef.sourceID) />

		    <!--- If the "SOURCE" does not exist in the Main "SOURCE" lookup table: "BB_Claim_Source_XREF". Saving source is not for EDI sourceType
			  as there is no source. The source in case of EDI is hardcoded as "SYSCO EDI" and "USFS EDI".
		    --->
		    <cfif qGetSourceInfo.BB_Claim_Source_XREF_ID eq "" AND arguments.AliasDef.sourceType eq 2>

		         <!--- We save the source and then save the alias for that source --->
				<cfset qSaveSourceAlias = variables.oAliasDAO.saveSourceAlias(arguments.entityType,arguments.AliasDef,arguments.userID)>
		    <cfelse>

				<!--- Dev Note: (38685) Commented this code. We just need the first part of the CFIF statement below. --->
				<!--- If the source is "Vendor"--->
				<!---<cfif arguments.AliasDef.sourceType eq 2>
					<cfset Claim_Source_XREF_ID = qGetSourceInfo.BB_Claim_Source_XREF_ID>--->
				<!---If the source is "EDI"
				<cfelse>
					<cfset Claim_Source_XREF_ID = arguments.AliasDef.sourceType>
				</cfif>
				--->

				<cfset Claim_Source_XREF_ID = qGetSourceInfo.BB_Claim_Source_XREF_ID>

				<!--- If the "SOURCE" already exists, then we just save the alias for an existing source --->

				<!--- Distributor --->
				<cfif arguments.entityType eq 0>
					<cfset SourceAliasExists = variables.oAliasDAO.saveDistributorAliasDetails(arguments.AliasDef,Claim_Source_XREF_ID,arguments.userID)>
				<!--- Item --->
				<cfelseif arguments.entityType eq 1>
					<cfset SourceAliasExists = variables.oAliasDAO.saveItemAliasDetails(arguments.AliasDef,Claim_Source_XREF_ID,arguments.userID)>
				<!--- Program --->
				<cfelseif arguments.entityType eq 2>
					<cfset SourceAliasExists = variables.oAliasDAO.saveProgramAliasDetails(arguments.AliasDef,Claim_Source_XREF_ID,arguments.userID)>
				<!--- Operator --->
				<cfelseif arguments.entityType eq 3>
					<!---- Extra custom data valiation --->
					<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') eq '1'>
						<cfset returnStruct = variables.oAliasDAO.validateGPOKey(arguments.AliasDef,Claim_Source_XREF_ID) />
						<cfif returnStruct.valid eq 0>
							<cfset bError = 1 />
							<cfset sErrorMessage = returnStruct.ErrorMessage />
						</cfif>
					</cfif>
					<cfif not bError>
						<cfset SourceAliasExists = variables.oAliasDAO.saveOperatorAliasDetails(arguments.AliasDef,Claim_Source_XREF_ID,arguments.userID)>
					</cfif>
				</cfif>

				<!--- In case the same Alias already exists for the source (Source and Alias combination is unique), then do not let the user add the alias again
					  as there cannot be a duplicate alias for a specific source.
				--->
				 <cfif SourceAliasExists eq 1>
					<!--- If the alias for the source already exist, send the error message in the "sourceID" property of the struct - "StructErrorMessage".
					Note: Even the "AliasDef" object has a "sourceID" property. Whenever there is no error message, i.e. the code is not executed
					for this condition, the "sourceID" property of the AliasDef is empty.
					--->
					<cfset StructErrorMessage.sourceID = "This Alias already exists.">

					<cfset ArrayAppend(arrEntityAliases, StructErrorMessage)>

				<cfelseif bError eq 1>
					<!--- If data validation failed, send the error message in the "sourceID" property of the struct - "StructErrorMessage".
					Note: Even the "AliasDef" object has a "sourceID" property. Whenever there is no error message, i.e. the code is not executed
					for this condition, the "sourceID" property of the AliasDef is empty.
					--->
					<cfset StructErrorMessage.sourceID = sErrorMessage />

					<cfset ArrayAppend(arrEntityAliases, StructErrorMessage)>

				</cfif>

		    </cfif>

			<!--- When multiple records ("save selected" functionality) need to be updated in a loop, this function gets called multiple times and so
			we do not want to return records after every update. For "save selected" functionality, we have the "saveSelectedAlias" function, which
			returns data after all records have been updated.
			--->
			<cfif arguments.bRefreshData eq 1>
				<!--- If the alias for the source does not already exist, then the new alias for the source has already been added above. Here we just
				      send the added distributor "alias" as an "AliasDef" object.
				--->
				<cfif SourceAliasExists eq 0 and bError eq 0>
					<!--- Distributor --->
					<cfif arguments.entityType eq 0>
						<cfset arrEntityAliases = getDistributorAliases(arguments.AliasDef.sourceType,arguments.AliasDef.sourceID,arguments.AliasDef.aliasID) />
					<!--- Item --->
					<cfelseif arguments.entityType eq 1>
						<cfset arrEntityAliases = getItemAliases(arguments.AliasDef.sourceType,arguments.AliasDef.sourceID,arguments.AliasDef.aliasID) />
					<!--- Program --->
					<cfelseif arguments.entityType eq 2>
						<cfset arrEntityAliases = getProgramAliases(arguments.AliasDef.sourceType,arguments.AliasDef.sourceID,arguments.AliasDef.aliasID) />
					<!--- Operator --->
					<cfelseif arguments.entityType eq 3>
						<cfset arrEntityAliases = getOperatorAliases(arguments.AliasDef.sourceType,arguments.AliasDef.sourceID,arguments.AliasDef.aliasID) />
					</cfif>
				</cfif>
			</cfif>
	   </cfif>

	     <cfreturn arrEntityAliases>

	</cffunction>

	<!--- save aliases ("single record" or "multiple record" update) --->
	<cffunction name="saveAliasJSON" access="remote" returnFormat="json">
	  <cfargument name="AliasDef" required="true">
	  <cfargument name="entityType" type="numeric" required="true">
	  <cfargument name="userID" type="string" required="true">
	  <cfargument name="singleRecord" type="boolean" required="true">

		<cfset AliasDef = DeserializeJSON(arguments.AliasDef)>

		<cfif arguments.singleRecord eq 1>
			<cfset saveAlias(arguments.AliasDef[1],arguments.entityType,arguments.userID,0)>
		<cfelse>
			<cfset saveSelectedAlias(arguments.AliasDef,arguments.entityType,arguments.userID,0)>
		</cfif>

	  	<cfscript>
			local.reply = {};
			local.reply = serializeJSON(local.reply, "struct");
		</cfscript>

		<cfreturn local.reply>

	</cffunction>

	<cffunction name="saveSelectedAlias" returntype="array" access="remote">
		<cfargument name="AliasSelectedRowsDef" required="true">
	  	<cfargument name="entityType" type="numeric" required="true">
	  	<cfargument name="userID" type="string" required="true">
		<cfargument name="bRefreshData" type="boolean" required="false" default="1">

	    <cfset var arrEntityAliases = ArrayNew(1)>
	  	<cfset var StructErrorMessage = StructNew()>
		<cfset var SourceAliasExists = 0>

		<!--- 99611: Code to update the AliasDef to Add the SourceID and SourceType when it is not defined in certain elements --->
		<cfset arrLength = ArrayLen(AliasSelectedRowsDef) />
		<cfif arrLength GTE 2>
			<cfloop from="1" to="#ArrayLen(AliasSelectedRowsDef)#" index="i">
				<cfif (structKeyExists(AliasSelectedRowsDef[i],"sourceID") AND AliasSelectedRowsDef[i].sourceID NEQ "")>
					<cfset strSourceID = AliasSelectedRowsDef[i].sourceID />
					<cfset strSourceType = AliasSelectedRowsDef[i].SourceType />
				</cfif>
			</cfloop>
			<cfloop from="1" to="#ArrayLen(AliasSelectedRowsDef)#" index="i">
				<cfif NOT (structKeyExists(AliasSelectedRowsDef[i],"sourceID")) >
					<cfset  AliasSelectedRowsDef[i].SourceID = strSourceID />
					<cfset AliasSelectedRowsDef[i].SourceType = strSourceType />
				</cfif>

				<cfif AliasSelectedRowsDef[i].ALIASID EQ '~Infinity'>
					<cfset AliasSelectedRowsDef[i].ALIASID = 'Infinity' >
				</cfif>
				<cfif AliasSelectedRowsDef[i].ALIASDESC EQ '~Infinity'>
					<cfset AliasSelectedRowsDef[i].ALIASDESC = 'Infinity' >
				</cfif>


			</cfloop>
		</cfif>

		<!--- Loop through the records which need to be updated and update those records. --->
		<cfloop from="1" to="#ArrayLen(AliasSelectedRowsDef)#" index="i">
	  		<cfset arReturned = saveAlias(AliasSelectedRowsDef[i],arguments.entityType,arguments.userID,0) />
	  	</cfloop>

		<!--- Below code is not needed for AG Grid --->
		<cfif arguments.bRefreshData eq 1>
			<!--- Once all the records have been updated, get refreshed records: Only those which have been updated --->
			<!--- Distributor --->
			<cfif arguments.entityType eq 0>
				<cfset arrEntityAliases = getDistributorAliases(AliasSelectedRowsDef[1].sourceType,AliasSelectedRowsDef[1].sourceID,"",AliasSelectedRowsDef) />
			<!--- Item --->
			<cfelseif arguments.entityType eq 1>
				<cfset arrEntityAliases = getItemAliases(AliasSelectedRowsDef[1].sourceType,AliasSelectedRowsDef[1].sourceID,"",AliasSelectedRowsDef) />
			<!--- Program --->
			<cfelseif arguments.entityType eq 2>
				<cfset arrEntityAliases = getProgramAliases(AliasSelectedRowsDef[1].sourceType,AliasSelectedRowsDef[1].sourceID,"",AliasSelectedRowsDef) />
			<!--- Operator --->
			<cfelseif arguments.entityType eq 3>
				<cfset arrEntityAliases = getOperatorAliases(AliasSelectedRowsDef[1].sourceType,AliasSelectedRowsDef[1].sourceID,"",AliasSelectedRowsDef) />
			</cfif>
		</cfif>

		<cfreturn arrEntityAliases />
	</cffunction>

	<!--- Delete a specific Alias/Entity combination for s source. The rowobjData has "recordID". This is the unique ID of the record (IncremenTal ID). --->
	<cffunction name="deleteAlias" returntype="boolean" access="remote">
	  <cfargument name="rowObjData" required="true">

		<cfset bDeleteAlias = variables.oAliasDAO.deleteAliasRow(arguments.rowObjData) />

	  <cfreturn true>

	</cffunction>

	<cffunction name="deleteAliasJSON" access="remote" returnFormat="json">
		<cfargument name="AliasDef" required="true">
		<cfargument name="entityType" type="numeric" required="true">

		<cfset var strAliasDef = DeserializeJSON(arguments.AliasDef)>
		<cfset AliasDef = DeserializeJSON(arguments.AliasDef)>

		<!--- Loop through the records which need to be delete and delete those records.--->
		<cfloop from="1" to="#ArrayLen(AliasDef)#" index="i">
			<!--- Add the "ENTITYTYPE" property, as it is required by the "deleteAliasRow" function --->
			<cfset AliasDef[i]['ENTITYTYPE'] = arguments.entityType>
			<cfset bDelete = variables.oAliasDAO.deleteAliasRow(AliasDef[i]) />
	  	</cfloop>

	  	<cfscript>
			local.reply = {};
			local.reply = serializeJSON(local.reply, "struct");
		</cfscript>

		<cfreturn local.reply>

	</cffunction>

</cfcomponent>