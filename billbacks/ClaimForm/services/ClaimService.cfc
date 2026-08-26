<cfcomponent name="ClaimService" alias="billbacks.BrokerClaimForm.Services.ClaimService" hint="Remote Facade for Broker Programs">

<cfset variables.brokerPrograms = createObject('component','components.Billback.BrokerProgramsManager').init(application.datasource) />
<cfset variables.initUser = createObject('component','components.Billback.requestScopeAccess').init() />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="init" access="public" output="false" returntype="ClaimService">
 <cfreturn this />
</cffunction>
<cffunction name="deleteForm" access="remote" output="false" returntype="struct" displayname="deleteForm">
    <cfargument name="formId" type="numeric" required="true" />
	<cfargument name="user_id" type="string" required="true" />
	<cfset var result = structNew() />
	
	<cfif trim(arguments.user_id) EQ '' >
		<cfset arguments.user_id = variables.initUser.getUserId() />
	</cfif>
	<cfset result = variables.brokerPrograms.deleteInfo(argumentCollection=arguments) />
	
	<cfset result["status"] = javacast("boolean",true) />
	<cfset result["message"] = result['message'] />
	
	<cfreturn result />
</cffunction>

<cffunction name="deleteItemInfo" access="remote" output="false" returntype="void" displayname="saveInfo" hint="I delete the form Info">
    <cfargument name="formId" type="numeric" required="true" />
	<cfargument name="ClaimFormId" type="numeric" required="true" />
	<cfargument name="user_id" type="string" required="true" />
	<cfset var result = structNew() />
	
	<cfif trim(arguments.user_id) EQ '' >
		<cfset arguments.user_id = variables.initUser.getUserId() />
	</cfif>
	<cfset variables.brokerPrograms.deleteItemInfo(argumentCollection=arguments) />

</cffunction>

<cffunction name="getBrokerId" access="remote" output="false" returntype="struct" displayname="getbrokerId">
 <cfset var userManager = createObject('component', 'components.user.UserManager').init() />
 <cfset var positionId =   "" />
 <cfset var userStruct = structNew() />
 <cfset var brokerid = "" />
 
 <cfif variables.initUser.getUserId() is '0'>
  <cfset init() />
 <cfelse>
  
  <cfset positionId = userManager.getPositionId('#variables.initUser.getUserId()#',0) />
  <cfset HQPosition = CreateObject("component", "components.geography.position").getHQPosition().User_Positions_ID />
  
  <cfif listfind(positionId, HQPosition)>
  	<cfset brokerid = userManager.getBrokerId(HQPosition) />
  <cfelse>
  	<cfset brokerid = userManager.getBrokerId(positionId) />
  </cfif>
  
  <cfset userStruct['brokerIdValue'] = brokerId />
  <cfset userStruct['userid'] = variables.initUser.getUserId() /> 
</cfif>

 <cfreturn userStruct />
</cffunction>

<cffunction name="getNewClaims" output="false" hint="Get All New Claim Forms" access="remote" returntype="query">
	<cfargument name="broker_Id" required="yes" type="any" /> 
	 
	 <cfreturn variables.brokerPrograms.getNewClaims(argumentCollection=arguments) />
</cffunction>

<cffunction name="getSavedClaims" output="false" hint="Get All New Claim Forms" access="remote" returntype="query">
	<cfargument name="broker_Id" required="yes" type="any" />
	<cfargument name="user_id" type="string" required="true" /> 
	 
	 <cfreturn variables.brokerPrograms.getSavedClaims(argumentCollection=arguments) />
</cffunction>

<cffunction name="getSentClaims" output="false" hint="Get Sent Claim Forms" access="remote" returntype="query">
	<cfargument name="broker_Id" required="yes" type="any" /> 
	<cfargument name="user_id" type="string" required="true" />
	 <cfreturn variables.brokerPrograms.getSentClaims(argumentCollection=arguments) />
</cffunction>

<cffunction name="getPendingClaims" output="false" hint="Get All Pending Claim Forms" access="remote" returntype="query">
	<cfargument name="broker_Id" required="yes" type="any" /> 
	<cfargument name="user_id" type="string" required="true" /> 
	 <cfreturn variables.brokerPrograms.getPendingClaims(argumentCollection=arguments) />
</cffunction>

<cffunction name="getNewClaimDetail" output="false" hint="Get Claims Detail" access="remote" returntype="query">
	<cfargument name="formId" required="yes" type="numeric" />
	 
		<cfreturn variables.brokerPrograms.getNewClaimDetails(argumentCollection=arguments) />
		<!---
		<cfset var a = arrayNew(1) />
        <cfset var claimDetails = "" />
		<cfset var detailsQry = variables.brokerPrograms.getNewClaimDetails(argumentCollection=arguments) />
		
	   <cfoutput query="detailsQry">

		<cfset claimDetails = createObject('component', 'billbacks.ClaimForm.ClaimDetailsBean').init() />
	 	<cfset claimDetails.setitem_Id(detailsQry.item_Id) />
	 	<cfset claimDetails.setProgram_ItemId(detailsQry.Program_ItemId) />
	 	<cfset claimDetails.setItem_Desc(detailsQry.Item_Desc) />
	 	<cfset claimDetails.setSTD(detailsQry.STD) />
	 	<cfset claimDetails.setPromo_rate(detailsQry.Promo_rate) />
	 	<cfset claimDetails.setInvoice_Price(detailsQry.Invoice_Price) />
	 	<cfset claimDetails.setPromo_Amt(detailsQry.Promo_Amt) />
	 	<cfset claimDetails.setLess_Corp_Allow(detailsQry.Less_Corp_Allow) />
	 	<cfset claimDetails.setLess_Local_Allow(detailsQry.Less_Local_Allow) />
	 	<cfset claimDetails.setNet_Promo_Amt(detailsQry.Net_Promo_Amt) />
	 	<cfset claimDetails.setPrice_List(detailsQry.Price_List) />
	 	<cfset claimDetails.setItem_Case_Weight(detailsQry.Item_Case_Weight) />
	 	<cfset claimDetails.setCases_Claimed(detailsQry.Cases_Claimed) />
	 	<cfset claimDetails.setNet_Lbs_Claimed(detailsQry.Net_Lbs_Claimed) />
	 	<cfset claimDetails.setAdj_Extended_Amt(detailsQry.Adj_Extended_Amt) />
	 	<cfset claimDetails.setClaimFormFK(0) />
     
	 <cfset arrayAppend(a,claimDetails) />
   </cfoutput>

		<cfreturn  a />
		--->
</cffunction>

<cffunction name="getClaimDetails" output="false" hint="Get Claims Detail" access="remote" returntype="query">
	<cfargument name="formId" required="yes" type="numeric" />
	<cfargument name="claimFormId" type="numeric" required="true" />
	<cfargument name="user_id" type="string" required="true" />
	 
		<cfreturn variables.brokerPrograms.getClaimDetails(argumentCollection=arguments) />
		<!--- 
		<cfset var a1 = arrayNew(1) />
        	<cfset var claimedDetails = "" />
		<cfset var claimedDetailsQry = variables.brokerPrograms.getClaimDetails(argumentCollection=arguments) />
		
	<cfoutput query="claimedDetailsQry">

		<cfset claimedDetails = createObject('component', 'billbacks.ClaimForm.ClaimDetailsBean').init() />
	 	<cfset claimedDetails.setitem_Id(claimedDetailsQry.item_IdFK) />
	 	<cfset claimedDetails.setProgram_ItemId(claimedDetailsQry.Program_ItemId) />
	 	<cfset claimedDetails.setItem_Desc(claimedDetailsQry.Item_Desc) />
	 	<cfset claimedDetails.setSTD(claimedDetailsQry.STD) />
	 	<cfset claimedDetails.setPromo_rate(claimedDetailsQry.Promo_rate) />
	 	<cfset claimedDetails.setInvoice_Price(claimedDetailsQry.Invoice_Price) />
	 	<cfset claimedDetails.setPromo_Amt(claimedDetailsQry.Promo_Amt) />
	 	<cfset claimedDetails.setLess_Corp_Allow(claimedDetailsQry.Less_Corp_Allow) />
	 	<cfset claimedDetails.setLess_Local_Allow(claimedDetailsQry.Less_Local_Allow) />
	 	<cfset claimedDetails.setNet_Promo_Amt(claimedDetailsQry.Net_Promo_Amt) />
	 	<cfset claimedDetails.setPrice_List(claimedDetailsQry.Price_List) />
	 	<cfset claimedDetails.setItem_Case_Weight(claimedDetailsQry.Item_Case_Weight) />
	 	<cfset claimedDetails.setCases_Claimed(claimedDetailsQry.Cases_Claimed) />
	 	<cfset claimedDetails.setNet_Lbs_Claimed(claimedDetailsQry.Net_Lbs_Claimed) />
	 	<cfset claimedDetails.setAdj_Extended_Amt(claimedDetailsQry.Adj_Extended_Amt) />
	 	<cfset claimedDetails.setClaimFormFK(claimedDetailsQry.ClaimFormFK) />
     
		<cfset arrayAppend(a1,claimedDetails) />
	</cfoutput>
		<cfreturn  a1 /> --->

</cffunction>

<cffunction name="searchClaims" output="false" hint="Search for records" access="remote" returntype="query">
	<cfargument name="broker_Id" type="any" required="true" />
	<cfargument name="searchType" type="String" required="true" />
	<cfargument name="bsProgramNum" type="string" required="false" />
	<cfargument name="lwProgramNum" type="string" required="false" />
	<cfargument name="program" type="string" required="false" />
	<cfargument name="dist" type="string" required="false" />
	<cfargument name="effDate" type="date" required="false" />
	<cfargument name="endDate" type="date" required="false" />
	<cfargument name="user_id" type="string" required="true" />
	<cfargument name="shipToNum" type="string" required="false" />
	<cfargument name="mostRecent" type="boolean" required="true" />
		
		<cfreturn variables.brokerPrograms.claimSearch(argumentCollection=arguments) />
</cffunction> 

<cffunction name="claimExists" access="remote" output="false" returntype="struct" description="I check to see if a claim has been sent previously">

	<!--- <cfargument name="broker_Id" required="yes" type="any" /> --->
	<!--- <cfargument name="user_id" type="string" required="true" /> --->
	<cfargument name="programNum" type="string" required="true" />
	<cfargument name="shipToNum" type="string" required="true" />
	<cfargument name="sentDate" type="Date" required="true" />
	<cfargument name="fromDate" type="Date" required="true" />
	<cfargument name="toDate" type="Date" required="true" />
	<!--- <cfargument name="custName" type="string" required="true" /> --->

	<cfset var stExistingClaims = structNew() />

	<cfset claim = variables.brokerPrograms.existingClaim(argumentCollection=arguments) />	

	<cfset stExistingClaims['claimFormID'] 		= claim.ClaimForm_Id />
	<cfset stExistingClaims['interfaceDate']	= claim.interfaceDate />
	<cfset stExistingClaims['shipNum'] 			= claim.Ship_Num />
	<cfset stExistingClaims['pgmNumber'] 		= claim.Program_Number />
	<cfset stExistingClaims['InvRefNumber'] 	= claim.Inv_Ref_Num />
	<cfset stExistingClaims['count'] 			= claim.Count />

	<cfreturn stExistingClaims />
</cffunction>

<cffunction name="saveInfo" access="remote" output="false" returntype="struct" displayname="saveInfo" description="I save the form Info">
	<cfargument name="formId" type="numeric" required="true" />
	<cfargument name="claimDateFrom" type="Date" required="true" />
	<cfargument name="claimDateTo" type="date" required="true" />
	<cfargument name="inv" type="string" required="true" />
	<cfargument name="amt" type="numeric" required="true" />
	<cfargument name="brokerDate" type="date" required="true" />
	<cfargument name="invoiceDate" type="date" required="true" />
	<cfargument name="casesClaimed" type="numeric" required="true" />
	<cfargument name="formState" type="numeric" required="true" />
	<cfargument name="saveType" type="string" required="true" />
	<cfargument name="ClaimFormId" type="numeric" required="false" />
	<cfargument name="user_id" type="string" required="true" />
	<cfset var saveResult = '' />
	<cfset var result = structNew() />
	
	<cfif trim(arguments.user_id) EQ '' >
		<cfset arguments.user_id = variables.initUser.getUserId() />
	</cfif>
	<cfset saveResult = variables.brokerPrograms.saveFormInfo(argumentCollection=arguments) />
	 <cfset result["status"] = javacast("boolean",true) />
     <cfset result['id'] = saveResult['id'] />
	
	<cfreturn result />
</cffunction>
<!--- D37510 :: One Page Claim Form Not Printing Correctly --->
<cffunction name="Print" access="remote" output="false" returntype="string" >
		<cfinclude template="/billbacks/Claimform/generate_print_data.cfm">
		<cfreturn "PrintPDF" />
</cffunction>
<!--- D37510 :: One Page Claim Form Not Printing Correctly --->
<cffunction name="saveItems" access="remote" output="false" returntype="struct" displayname="saveInfo" description="I save the form Info">
	<cfargument name="id" type="numeric" required="false" />
	<cfargument name="formId" type="numeric" required="true" />
	<cfargument name="saveType" type="string" required="true" />
	<cfargument name="itemId" type="numeric" required="false" />
	<cfargument name="program_ItemID" type="string" required="true" />
	<cfargument name="claimedCases" type="any" required="false" />
	<cfargument name="poundsClaimed" type="numeric" required="false" />
	<cfargument name="adjustedAmt" type="numeric" required="true" />
	<cfargument name="ClaimFormId" type="numeric" required="false" />
	<cfargument name="promoAmt" type="numeric" required="true" />
	<cfargument name="promo_Amt" type="numeric" required="true" />
	<cfargument name="itemDesc" type="string" required="true" />
	<cfargument name="STD" type="string" required="true" />
	<cfargument name="promoRate" type="numeric" required="true" />             
	<cfargument name="invoice" type="numeric" required="true" />            
	<cfargument name="corpAllow" type="numeric" required="true" />             
	<cfargument name="localAllow" type="numeric" required="true" />              
	<cfargument name="priceList" type="string" required="true" />              
	<cfargument name="caseWeight" type="numeric" required="false" />             
	<cfargument name="user_id" type="string" required="true" />             
	<cfset var result = structNew() />
	
	<cfif trim(arguments.user_id) EQ '' >
		<cfset arguments.user_id = variables.initUser.getUserId() />
	</cfif>
	<cfset result = variables.brokerPrograms.saveItemInfo(argumentCollection=arguments) />
	 
	 <cfset result["status"] = javacast("boolean",true) />
	 <cfset result["message"] = result['message'] />
	 
	 <cfreturn result />

</cffunction>

</cfcomponent>