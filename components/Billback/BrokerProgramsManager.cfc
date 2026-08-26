<cfcomponent>

<cffunction name="init" output="false" access="public" returntype="BrokerProgramsManager">
  <cfargument name="dsn" type="string" required="true" />
  
   <cfset variables.dsn = arguments.dsn />
   
  <cfreturn this />
 </cffunction>

<cffunction name="deleteInfo" access="public" returntype="struct" output="false" displayname="deleteInfo">
   <cfargument name="formId" type="numeric" required="true" />
   <cfargument name="ClaimFormId" type="numeric" required="true" />
   <cfargument name="user_id" type="string" required="true"  />
	
	<cfset var delete = "" />
	<cfset var returnObj = structnew() />
	<cfset returnObj["status"] = true />
	<cfset returnObj["message"] = "" />
	
	<cftry>
	<cfquery name="delete" datasource="#variables.dsn#">
	 Delete From Broker_Program_Claim_Form
	 Where ClaimForm_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ClaimFormId#" />
	 AND   user_IdFK = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.user_id#" />
	 And   Form_IdFK = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formId#" />
	</cfquery>
    
	 
	<cfcatch type="any">
		<cfset returnObj["status"] = false />
		<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
	</cfcatch>
   </cftry>
	
	 <cfif returnObj["status"]>
	  <cfset returnObj["message"] = "Form ID: #arguments.formId# has been successfully deleted" />
	 </cfif>
	
	<cfreturn returnObj />
</cffunction>

<cffunction name="deleteItemInfo" access="public" returntype="void" output="false" displayname="deleteItemInfo">
    <cfargument name="formId" type="numeric" required="true" />
	<cfargument name="ClaimFormId" type="numeric" required="true" />
	<cfargument name="user_id" type="string" required="true"  />
	
	<cfset var deleteItem = "" />
    <cftry>
	<cfquery name="deleteItem" datasource="#variables.dsn#">
	 Delete From Broker_ClaimDtl_Form
	 Where ClaimFormFK = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ClaimFormId#" />
	 AND   user_IdFK = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.user_id#" />
	 And   Form_IDFK = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formId#" />
	</cfquery>
   <cfcatch type="any">
	 <cflog file="deleteItemsLog" text="#CFCATCH.message# : #CFCATCH.detail#" />
   </cfcatch> 
 </cftry>
</cffunction>

<cffunction name="getNewClaims" access="public" output="false" returntype="query" displayname="GetAllNewClaims">
 <cfargument name="broker_Id" type="any" required="true" />

 <cfset var newClaimForms = "" />

<cfquery name="newClaimForms" datasource="#variables.dsn#">
select  LTrim(RTrim(Broker_Name)) As Broker_Name,Cust_Name,Address, State, Form_Id, Broker_Id,Ba_Id,
       Program_Number,BeginDate,EndDate, 
       Ship_Num, Desc_Number, Autos_Fixed, Autos_Deduct, Autos_Pullback, Sent_Date As DateSent,
       Sent_Date, PayTo_Num, PayTo_Name
From   Broker_Program_Claims_Hdr bpch 
       inner join (Select Max(Sent_Date) as "max_sent_date", Program_Number as "Program_Num",Cust_Name as "Distributor",Ship_Num As "shipNum"  
From   Broker_Program_Claims_Hdr 
<cfif len(trim(arguments.broker_Id))>
Where  (Broker_Id In (#arguments.broker_Id#))
</cfif> 
Group By Program_Number,Cust_Name,Ship_Num  
) derived

On bpch.sent_date = derived.max_sent_date
   and bpch.program_number = derived.Program_Num 
   and bpch.cust_name = derived.Distributor 
   and bpch.ship_num = derived.shipNum
Order By  bpch.Program_Number, bpch.Cust_Name, bpch.Sent_Date, bpch.Ship_Num 
</cfquery>
 
 <cfreturn newClaimForms />
</cffunction>

<cffunction name="getSavedClaims" access="public" output="false" returntype="query" displayname="GetAllNewClaims">
	<cfargument name="broker_Id" type="any" required="true" />
	<cfargument name="user_id" type="string" required="true" />
	
	<cfset var savedClaimForms = "" />
	
	<cfquery name="savedClaimForms" datasource="#variables.dsn#">
		SELECT		Broker_Program_Claims_Hdr.Form_Id, Broker_Program_Claim_Form.ClaimForm_ID, Broker_Program_Claim_Form.user_IdFK,
					Broker_Program_Claims_Hdr.Broker_Id, Broker_Program_Claims_Hdr.Broker_Name, 
					Broker_Program_Claims_Hdr.Ship_Num, Broker_Program_Claims_Hdr.Cust_Name, 
					Broker_Program_Claims_Hdr.Address, Broker_Program_Claims_Hdr.State, 
					Broker_Program_Claims_Hdr.Program_Number, Broker_Program_Claims_Hdr.Ba_Id, Broker_Program_Claims_Hdr.Desc_Number, 
					Broker_Program_Claims_Hdr.PayTo_Num, Broker_Program_Claims_Hdr.PayTo_Name, 
					Broker_Program_Claims_Hdr.BeginDate, Broker_Program_Claims_Hdr.EndDate,
					Broker_Program_Claims_Hdr.Sent_Date, 
					Broker_Program_Claims_Hdr.Autos_Fixed, Broker_Program_Claims_Hdr.Autos_Deduct, Broker_Program_Claims_Hdr.Autos_Pullback, 
					Convert(varchar,Broker_Program_Claim_Form.Claim_Date_From,1) As Claim_Date_From, Convert(varchar,Broker_Program_Claim_Form.Claim_Date_To,1) As Claim_Date_To, 
					Convert(varchar,Broker_Program_Claim_Form.Broker_Rcv_Date,1) As Broker_Rcv_Date, Convert(varchar,Broker_Program_Claim_Form.Inv_Date,1) As Inv_Date, 
					Broker_Program_Claim_Form.Inv_Ref_Num, Broker_Program_Claim_Form.Claim_Amt, Broker_Program_Claim_Form.casesClaimed, 
					Broker_Program_Claim_Form.Saved_Date,
					Convert(varchar,Broker_Program_Claim_Form.InterfaceDate,1) As InterfaceDate, 
					Broker_Program_Claims_Hdr.Created_Date, Broker_Program_Claim_Form.Form_State
		FROM       	Broker_Program_Claims_Hdr 
		INNER JOIN	Broker_Program_Claim_Form ON Broker_Program_Claims_Hdr.Form_Id = Broker_Program_Claim_Form.Form_IdFK
		WHERE		Broker_Program_Claim_Form.Form_State = <cfqueryparam cfsqltype="cf_sql_numeric" value="1" />
		<cfif len(trim(arguments.broker_Id))>
		AND			(Broker_Program_Claims_Hdr.Broker_Id In (#arguments.broker_Id#) )
		</cfif>
		<!--- AND        user_IdFK = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.user_id#" /> --->   
		Order By  	Program_Number,Cust_Name,Saved_Date,Ship_Num
	</cfquery>
	 
	<cfreturn savedClaimForms />
</cffunction>

<cffunction name="getSentClaims" access="public" output="false" returntype="query" displayname="getSentClaims">
	<cfargument name="broker_Id" type="any" required="true" />
	<cfargument name="user_id" type="string" required="true" />
	
	<cfset var sentClaimForms = "" />

	<cfquery name="sentClaimForms" datasource="#variables.dsn#">
		SELECT		Broker_Program_Claims_Hdr.Form_Id, Broker_Program_Claim_Form.ClaimForm_ID, Broker_Program_Claim_Form.user_IdFK,
					Broker_Program_Claims_Hdr.Broker_Id, Broker_Program_Claims_Hdr.Broker_Name, 
					Broker_Program_Claims_Hdr.Ship_Num, Broker_Program_Claims_Hdr.Cust_Name, 
					Broker_Program_Claims_Hdr.Address, Broker_Program_Claims_Hdr.State, 
					Broker_Program_Claims_Hdr.Program_Number, Broker_Program_Claims_Hdr.Ba_Id, Broker_Program_Claims_Hdr.Desc_Number, 
					Broker_Program_Claims_Hdr.PayTo_Num, Broker_Program_Claims_Hdr.PayTo_Name, 
					Broker_Program_Claims_Hdr.BeginDate, Broker_Program_Claims_Hdr.EndDate,
					Broker_Program_Claims_Hdr.Sent_Date, 
					Broker_Program_Claims_Hdr.Autos_Fixed, Broker_Program_Claims_Hdr.Autos_Deduct, Broker_Program_Claims_Hdr.Autos_Pullback, 
					Convert(varchar,Broker_Program_Claim_Form.Claim_Date_From,1) As Claim_Date_From, Convert(varchar,Broker_Program_Claim_Form.Claim_Date_To,1) As Claim_Date_To, 
					Convert(varchar,Broker_Program_Claim_Form.Broker_Rcv_Date,1) As Broker_Rcv_Date, Convert(varchar,Broker_Program_Claim_Form.Inv_Date,1) As Inv_Date, 
					Broker_Program_Claim_Form.Inv_Ref_Num, Broker_Program_Claim_Form.Claim_Amt, Broker_Program_Claim_Form.casesClaimed, 
					Broker_Program_Claim_Form.Saved_Date,
					Convert(varchar,Broker_Program_Claim_Form.InterfaceDate,1) As InterfaceDate, 
					Broker_Program_Claims_Hdr.Created_Date, Broker_Program_Claim_Form.Form_State
		FROM       	Broker_Program_Claims_Hdr 
		INNER JOIN	Broker_Program_Claim_Form ON Broker_Program_Claims_Hdr.Form_Id = Broker_Program_Claim_Form.Form_IdFK
		WHERE     	Broker_Program_Claim_Form.Form_State = <cfqueryparam cfsqltype="cf_sql_numeric" value="3" />
		<!--- broker_Id --->
		<cfif len(trim(arguments.broker_Id))>
			AND		Broker_Program_Claims_Hdr.Broker_Id In (#arguments.broker_Id#)
		</cfif>
		
		Order By	Program_Number,Cust_Name,InterfaceDate,Ship_Num
	</cfquery>
 
 	<cfreturn sentClaimForms />
</cffunction>

<cffunction name="getPendingClaims" access="public" output="false" returntype="query" displayname="GetAllNewClaims">
	<cfargument name="broker_Id" type="any" required="true" />
	<cfargument name="user_id" type="string" required="true" />
	
	<cfset var pendingClaimForms = "" />
	
	<cfquery name="pendingClaimForms" datasource="#variables.dsn#">
		SELECT		Broker_Program_Claims_Hdr.Form_Id, Broker_Program_Claim_Form.ClaimForm_ID, Broker_Program_Claim_Form.user_IdFK,
					Broker_Program_Claims_Hdr.Broker_Id, Broker_Program_Claims_Hdr.Broker_Name, 
					Broker_Program_Claims_Hdr.Ship_Num, Broker_Program_Claims_Hdr.Cust_Name, 
					Broker_Program_Claims_Hdr.Address, Broker_Program_Claims_Hdr.State, 
					Broker_Program_Claims_Hdr.Program_Number, Broker_Program_Claims_Hdr.Ba_Id, Broker_Program_Claims_Hdr.Desc_Number, 
					Broker_Program_Claims_Hdr.PayTo_Num, Broker_Program_Claims_Hdr.PayTo_Name, 
					Broker_Program_Claims_Hdr.BeginDate, Broker_Program_Claims_Hdr.EndDate,
					Broker_Program_Claims_Hdr.Sent_Date, 
					Broker_Program_Claims_Hdr.Autos_Fixed, Broker_Program_Claims_Hdr.Autos_Deduct, Broker_Program_Claims_Hdr.Autos_Pullback, 
					Convert(varchar,Broker_Program_Claim_Form.Claim_Date_From,1) As Claim_Date_From, Convert(varchar,Broker_Program_Claim_Form.Claim_Date_To,1) As Claim_Date_To, 
					Convert(varchar,Broker_Program_Claim_Form.Broker_Rcv_Date,1) As Broker_Rcv_Date, Convert(varchar,Broker_Program_Claim_Form.Inv_Date,1) As Inv_Date, 
					Broker_Program_Claim_Form.Inv_Ref_Num, Broker_Program_Claim_Form.Claim_Amt, Broker_Program_Claim_Form.casesClaimed, 
					Broker_Program_Claim_Form.Saved_Date,
					Convert(varchar,Broker_Program_Claim_Form.InterfaceDate,1) As InterfaceDate, 
					Broker_Program_Claims_Hdr.Created_Date, Broker_Program_Claim_Form.Form_State
		FROM       	Broker_Program_Claims_Hdr 
		INNER JOIN	Broker_Program_Claim_Form ON Broker_Program_Claims_Hdr.Form_Id = Broker_Program_Claim_Form.Form_IdFK
		WHERE      Broker_Program_Claim_Form.Form_State = <cfqueryparam cfsqltype="cf_sql_numeric" value="2" />
		<cfif len(trim(arguments.broker_Id))>
		AND		   Broker_Program_Claims_Hdr.Broker_Id In (#arguments.broker_Id#)
		</cfif>
		<!--- AND      user_IdFK = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.user_id#" /> ---> 
		 Order By  Program_Number,Cust_Name,Saved_Date,Ship_Num
	</cfquery>
	 
	<cfreturn pendingClaimForms />
</cffunction>

<cffunction name="getNewClaimDetails" access="public" output="false" returntype="query" displayname="getClaimDetails">
 <cfargument name="formId" type="numeric" required="true" />

 
 <cfset var newClaimDetails = "" />
 
<cftry>
 <cfquery name="newClaimDetails" datasource="#variables.dsn#">
SELECT      Program_ItemId, Item_Desc, STD, Promo_rate,Invoice_Price, Promo_Amt, Less_Corp_Allow, Less_Local_Allow, Net_Promo_Amt, 
            Price_List, Item_Case_Weight, Form_Id, item_Id,Cases_Claimed,Net_Lbs_Claimed,Adj_Extended_Amt
FROM        Broker_Program_Claims_Dtl
WHERE       Form_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formId#"/>       
ORDER BY Program_ItemId
</cfquery>

<cfcatch type="any">
	   <cflog file="newdetailsLog" text="#CFCATCH.message# : #CFCATCH.detail#" />
      </cfcatch>
</cftry>
  
 <cfreturn newClaimDetails />
</cffunction>

<cffunction name="getClaimDetails" access="public" output="false" returntype="query" displayname="getClaimDetails">
 <cfargument name="formId" type="numeric" required="true" />
 <cfargument name="claimFormId" type="numeric" required="true" />
 <cfargument name="user_id" type="string" required="false"  />

 
 <cfset var claimDetails = "" />
 
<cftry>
 <cfquery name="claimDetails" datasource="#variables.dsn#">
SELECT     ClaimFormFK, Form_IDFK, item_Id, Program_ItemId, Item_Desc, STD, Promo_rate, Promo_Amt, Less_Corp_Allow, Invoice_Price, Less_Local_Allow, 
           Price_List, Item_Case_Weight, Cases_Claimed, Net_Lbs_Claimed, Adj_Extended_Amt, Net_Promo_Amt
FROM       Broker_ClaimDtl_Form

WHERE    Broker_ClaimDtl_Form.Form_IdFK = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formId#"/> 
<!--- AND       user_IdFK = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.user_id#" /> --->
AND      Broker_ClaimDtl_Form.ClaimFormFK =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.claimFormId#"/>
</cfquery>

<cfcatch type="any">
	   <cflog file="detailsLog" text="#CFCATCH.message# : #CFCATCH.detail#" />
      </cfcatch>
</cftry>
  
 <cfreturn claimDetails />
</cffunction>

<cffunction name="claimSearch" access="public" output="false" returntype="query" hint="I search forms based on arguments passed">
 <cfargument name="broker_Id" type="any" required="true" />
 <cfargument name="searchType" type="string" required="true" />
 <cfargument name="bsProgramNum" type="string" required="false" />
 <cfargument name="lwProgramNum" type="string" required="false" />
 <cfargument name="program" type="string" required="false" />
 <cfargument name="dist" type="string" required="false" />
 <cfargument name="invoice" type="any" required="false" /><!--- D33806:Add Invoice search field to One Page Claim form --->
 <cfargument name="effDate" type="date" required="false" />
 <cfargument name="endDate" type="date" required="false" />
 <cfargument name="user_id" type="string" required="true" />
 <cfargument name="shipToNum" type="string" required="false" />
 <cfargument name="mostRecent" type="boolean" required="true" />

  <cfset var getInfoSearch = "" />
  
  <cfif structKeyExists(arguments,'searchType') and arguments.searchType is "">
   <cfset arguments.searchType = "0" />
	</cfif>

  <cfquery datasource="#variables.dsn#" name="getInfoSearch">
	<cfswitch expression="#arguments.searchType#">
		<!--- D33192: One Page Claim Form Sorting Issues 
		Removed  Convert(varchar,XXXXX,101)  to fix sorting issue--->
	 <cfcase value="0">
		SELECT	LTrim(RTrim(Broker_Name)) As Broker_Name,
					Cust_Name,
					Address, 
					State, 
					Form_Id, 
					Broker_Id,
					Ba_Id,
					Program_Number,
					BeginDate, 
					EndDate,
					Ship_Num, Desc_Number, 
					Autos_Fixed, 
					Autos_Deduct, 
					Autos_Pullback, 
					Sent_Date As DateSent,
					Sent_Date, 
					PayTo_Num, 
					PayTo_Name
					--Broker_Program_Claim_Form.Inv_Ref_Num<!--- D33806:Add Invoice search field to One Page Claim form --->
		FROM	Broker_Program_Claims_Hdr  bpch 
		--INNER JOIN	Broker_Program_Claim_Form ON bpch.Form_Id = Broker_Program_Claim_Form.Form_IdFK<!--- D33806:Add Invoice search field to One Page Claim form --->
		<cfif arguments.mostRecent>
			INNER JOIN 
			(
				SELECT DISTINCT Max(Sent_Date) as "max_sent_date", Program_Number as "Program_Num", Ship_Num As "shipNum"  
				FROM   Broker_Program_Claims_Hdr
				<cfif len(trim(arguments.broker_Id))>
				WHERE  Broker_Id IN (#arguments.broker_Id#)
				</cfif>  
				GROUP BY Program_Number, Ship_Num  
			) 	derived 
			ON	bpch.sent_date = derived.max_sent_date
			AND bpch.program_number = derived.Program_Num
			AND bpch.ship_num = derived.shipNum
		</cfif>
		WHERE  1=1
		<cfif len(trim(arguments.broker_Id))>
		AND Broker_Id IN (#arguments.broker_Id#)
		</cfif>


	</cfcase>
			<!--- D33192: One Page Claim Form Sorting Issues 
			Removed  Convert(varchar,XXXXX,101)  to fix sorting issue--->
	<cfcase value="1">
		SELECT		Broker_Program_Claims_Hdr.Form_Id, Broker_Program_Claim_Form.ClaimForm_ID, Broker_Program_Claim_Form.user_IdFK,
					Broker_Program_Claims_Hdr.Broker_Id, Broker_Program_Claims_Hdr.Broker_Name, 
					Broker_Program_Claims_Hdr.Ship_Num, Broker_Program_Claims_Hdr.Cust_Name, 
					Broker_Program_Claims_Hdr.Address, Broker_Program_Claims_Hdr.State, 
					Broker_Program_Claims_Hdr.Program_Number, Broker_Program_Claims_Hdr.Ba_Id, Broker_Program_Claims_Hdr.Desc_Number, 
					Broker_Program_Claims_Hdr.PayTo_Num, Broker_Program_Claims_Hdr.PayTo_Name, 
					Broker_Program_Claims_Hdr.BeginDate As BeginDate, 
					Broker_Program_Claims_Hdr.EndDate As EndDate,
					Broker_Program_Claims_Hdr.Sent_Date As Sent_Date, 
					Broker_Program_Claims_Hdr.Autos_Fixed, Broker_Program_Claims_Hdr.Autos_Deduct, Broker_Program_Claims_Hdr.Autos_Pullback, 
					Broker_Program_Claim_Form.Claim_Date_From As Claim_Date_From,
					Broker_Program_Claim_Form.Claim_Date_To As Claim_Date_To, 
					Broker_Program_Claim_Form.Broker_Rcv_Date As Broker_Rcv_Date,
					Broker_Program_Claim_Form.Inv_Date As Inv_Date, 
					Broker_Program_Claim_Form.Inv_Ref_Num, Broker_Program_Claim_Form.Claim_Amt, Broker_Program_Claim_Form.casesClaimed, 
					Broker_Program_Claim_Form.Saved_Date As Saved_Date,
					Broker_Program_Claim_Form.InterfaceDate As InterfaceDate, 
					Broker_Program_Claims_Hdr.Created_Date, Broker_Program_Claim_Form.Form_State
		FROM       	Broker_Program_Claims_Hdr 
		INNER JOIN	Broker_Program_Claim_Form ON Broker_Program_Claims_Hdr.Form_Id = Broker_Program_Claim_Form.Form_IdFK
		WHERE		(Broker_Program_Claim_Form.Form_State = <cfqueryparam cfsqltype="cf_sql_numeric" value="1" />)
		<cfif len(trim(arguments.broker_Id))>
		AND		(Broker_Program_Claims_Hdr.Broker_Id In (#arguments.broker_Id#) ) 
		</cfif> 
     	<!---  AND     user_IdFK = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.user_id#" /> --->
	</cfcase>
     		<!--- D33192: One Page Claim Form Sorting Issues 
     		Removed  Convert(varchar,XXXXX,101)  to fix sorting issue--->
	<cfcase value="2">
		SELECT		Broker_Program_Claims_Hdr.Form_Id, Broker_Program_Claim_Form.ClaimForm_ID, Broker_Program_Claim_Form.user_IdFK,
					Broker_Program_Claims_Hdr.Broker_Id, Broker_Program_Claims_Hdr.Broker_Name, 
					Broker_Program_Claims_Hdr.Ship_Num, Broker_Program_Claims_Hdr.Cust_Name, 
					Broker_Program_Claims_Hdr.Address, Broker_Program_Claims_Hdr.State, 
					Broker_Program_Claims_Hdr.Program_Number, Broker_Program_Claims_Hdr.Ba_Id, Broker_Program_Claims_Hdr.Desc_Number, 
					Broker_Program_Claims_Hdr.PayTo_Num, Broker_Program_Claims_Hdr.PayTo_Name, 
					Broker_Program_Claims_Hdr.BeginDate As BeginDate, 
					Broker_Program_Claims_Hdr.EndDate As EndDate,
					Broker_Program_Claims_Hdr.Sent_Date As Sent_Date, 
					Broker_Program_Claims_Hdr.Autos_Fixed, Broker_Program_Claims_Hdr.Autos_Deduct, Broker_Program_Claims_Hdr.Autos_Pullback, 
					Broker_Program_Claim_Form.Claim_Date_From As Claim_Date_From, 
					Broker_Program_Claim_Form.Claim_Date_To As Claim_Date_To, 
					Broker_Program_Claim_Form.Broker_Rcv_Date As Broker_Rcv_Date, 
					Broker_Program_Claim_Form.Inv_Date As Inv_Date, 
					Broker_Program_Claim_Form.Inv_Ref_Num, Broker_Program_Claim_Form.Claim_Amt, Broker_Program_Claim_Form.casesClaimed, 
					Broker_Program_Claim_Form.Saved_Date As Saved_Date,
					Broker_Program_Claim_Form.InterfaceDate As InterfaceDate, 
					Broker_Program_Claims_Hdr.Created_Date, Broker_Program_Claim_Form.Form_State
		FROM       	Broker_Program_Claims_Hdr 
		INNER JOIN	Broker_Program_Claim_Form ON Broker_Program_Claims_Hdr.Form_Id = Broker_Program_Claim_Form.Form_IdFK

		WHERE		(Broker_Program_Claim_Form.Form_State = <cfqueryparam cfsqltype="cf_sql_numeric" value="2" />)
		<cfif len(trim(arguments.broker_Id))>
		AND		(Broker_Program_Claims_Hdr.Broker_Id In (#arguments.broker_Id#) )
		</cfif>
		<!---   AND      user_IdFK = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.user_id#" /> --->
	</cfcase>
	<!--- D33192: One Page Claim Form Sorting Issues 
	Removed  Convert(varchar,XXXXX,101)  to fix sorting issue--->
	<cfcase value="3">
		SELECT		Broker_Program_Claims_Hdr.Form_Id, Broker_Program_Claim_Form.ClaimForm_ID, Broker_Program_Claim_Form.user_IdFK,
					Broker_Program_Claims_Hdr.Broker_Id, Broker_Program_Claims_Hdr.Broker_Name, 
					Broker_Program_Claims_Hdr.Ship_Num, Broker_Program_Claims_Hdr.Cust_Name, 
					Broker_Program_Claims_Hdr.Address, Broker_Program_Claims_Hdr.State, 
					Broker_Program_Claims_Hdr.Program_Number, Broker_Program_Claims_Hdr.Ba_Id, Broker_Program_Claims_Hdr.Desc_Number, 
					Broker_Program_Claims_Hdr.PayTo_Num, Broker_Program_Claims_Hdr.PayTo_Name, 
					Broker_Program_Claims_Hdr.BeginDate As BeginDate, 
					Broker_Program_Claims_Hdr.EndDate As EndDate,
					Broker_Program_Claims_Hdr.Sent_Date As Sent_Date, 
					Broker_Program_Claims_Hdr.Autos_Fixed, Broker_Program_Claims_Hdr.Autos_Deduct, Broker_Program_Claims_Hdr.Autos_Pullback, 
					Broker_Program_Claim_Form.Claim_Date_From As Claim_Date_From, 
					Broker_Program_Claim_Form.Claim_Date_To As Claim_Date_To, 
					Broker_Program_Claim_Form.Broker_Rcv_Date As Broker_Rcv_Date, 
					Broker_Program_Claim_Form.Inv_Date As Inv_Date, 
					Broker_Program_Claim_Form.Inv_Ref_Num, Broker_Program_Claim_Form.Claim_Amt, Broker_Program_Claim_Form.casesClaimed, 
					Broker_Program_Claim_Form.Saved_Date As Saved_Date,
					Broker_Program_Claim_Form.InterfaceDate As InterfaceDate, 
					Broker_Program_Claims_Hdr.Created_Date, Broker_Program_Claim_Form.Form_State
		FROM       	Broker_Program_Claims_Hdr 
		INNER JOIN	Broker_Program_Claim_Form ON Broker_Program_Claims_Hdr.Form_Id = Broker_Program_Claim_Form.Form_IdFK
		WHERE		(Broker_Program_Claim_Form.Form_State = <cfqueryparam cfsqltype="cf_sql_numeric" value="3" />)
		<cfif len(trim(arguments.broker_Id))>
		AND 		(Broker_Program_Claims_Hdr.Broker_Id In (#arguments.broker_Id#) )  
		</cfif>
		<!--- AND      user_IdFK = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.user_id#" /> --->
		</cfcase>
	</cfswitch>
	
   

	<cfif structKeyExists(arguments, "effDate") and arguments.effDate is not "">
	 And BeginDate = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.effDate#" />
	</cfif>
	
	<cfif structKeyExists(arguments, "endDate") and arguments.endDate is not "">
	 And EndDate = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.endDate#" />
	</cfif>
	
	<cfif structKeyExists(arguments, "bsProgramNum") and arguments.bsProgramNum neq "">
	 And Ba_Id Like <cfqueryparam cfsqltype="numeric" value="%#arguments.bsProgramNum#%" />
	</cfif>
	
	<cfif structKeyExists(arguments, "lwProgramNum") and arguments.lwProgramNum neq "">
	 And Program_Number Like <cfqueryparam cfsqltype="cf_sql_char" value="%#arguments.lwProgramNum#%" />
	</cfif>
	
	<cfif structKeyExists(arguments, "program") and arguments.program neq "">
	 And Desc_Number Like  <cfqueryparam cfsqltype="cf_sql_char" value="%#arguments.program#%" />
	</cfif>
	
	<cfif structKeyExists(arguments, "dist") and arguments.dist neq "">
	 And Cust_Name Like <cfqueryparam cfsqltype="cf_sql_char" value="%#arguments.dist#%" />
	</cfif>
	<!--- D33806:Add Invoice search field to One Page Claim form START--->
	<cfif structKeyExists(arguments, "invoice") and arguments.invoice neq "">
	 And Inv_Ref_Num Like <cfqueryparam cfsqltype="cf_sql_char" value="%#arguments.invoice#%" />
	</cfif>
	<!--- D33806:Add Invoice search field to One Page Claim form END--->
	<cfif structKeyExists(arguments, "shipToNum") and arguments.shipToNum neq "">
	 And Ship_Num = <cfqueryparam cfsqltype="cf_sql_char" value="#Left(arguments.shipToNum,5)#-#Right(arguments.shipToNum,3)#" />
	</cfif>
	
     Order By
	<cfif arguments.searchType is "0">
	  bpch.Program_Number, bpch.Cust_Name, bpch.Sent_Date, bpch.Ship_Num
	<cfelse>
	  Program_Number,Ship_Num,Saved_Date,Desc_Number
	</cfif>
	  
	</cfquery>
	
	<cfreturn getInfoSearch />  
</cffunction>

<cffunction name="saveFormInfo" access="public" returntype="struct" output="false" displayname="saveInfo">
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
	<cfargument name="user_id" type="string" required="true"  />
	
	<cfset var insertInfo = "" />
	<cfset var updateInfo = "" />
	<cfset var message = "" />
	<cfset var returnObj = structnew() />
	<cfset var claimNum = 0 />
	<cfset var claimArg = "" />
	<cfset returnObj["status"] = true />
	<cfset returnObj["message"] = "" />
	
	
	
	<cfif arguments.saveType is "save">
	 <cftry>
	  <cftransaction>
	  <cfquery name="insertInfo" datasource="#variables.dsn#">
		SET NOCOUNT ON
	    
	     Insert Into Broker_Program_Claim_Form (
	       user_IdFK, Form_IdFK,Form_State,Saved_Date,Claim_Date_From,Claim_Date_To,Claim_Amt,
	       Inv_Ref_Num,Broker_Rcv_Date,Inv_Date,casesClaimed
	       )
	     Values(
	      <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.user_id#" />,
	      <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formId#" />,
	      <cfqueryparam cfsqltype="numeric" value="#arguments.formState#" />,
	      <cfqueryparam cfsqltype="cf_sql_date" value="#createodbcdatetime(Now())#" />,
	      <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.claimDateFrom#" />,
	      <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.claimDateTo#" />,
	      <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.amt#" />,
	      <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.inv#" />,
	      <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.brokerDate#" />,
	      <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.invoiceDate#" />,
	      <cfqueryparam cfsqltype="numeric" value="#arguments.casesClaimed#" />
	      )
	      
	     SELECT IDENT_CURRENT('Broker_Program_Claim_Form') AS claimId
		 SET NOCOUNT OFF
	   </cfquery>
	   <cfset claimNum = insertInfo.claimId />
	 </cftransaction>
	    
       
	    <cfcatch type="any">
		 <cfset returnObj["status"] = false />
		 <cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
	    </cfcatch>
       </cftry>
      <cfelse>
	 <cftry>    
	  <cfquery name="updateInfo" datasource="#variables.dsn#">
	     Update Broker_Program_Claim_Form
	       Set Form_State = <cfqueryparam cfsqltype="numeric" value="#arguments.formState#" />,
	       Saved_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#createodbcdatetime(Now())#" />,
	       Claim_Date_From = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.claimDateFrom#" />,
	       Claim_Date_To = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.claimDateTo#" />,
	       Claim_Amt = <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.amt#" />,
	       Inv_Ref_Num = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.inv#" />,
	       Broker_Rcv_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.brokerDate#" />,
	       Inv_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.invoiceDate#" />,
	       casesClaimed = <cfqueryparam cfsqltype="numeric" value="#arguments.casesClaimed#" />
	       Where Form_IdFK = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formId#" />
	       <!--- And   user_IdFK = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.user_id#" /> --->
	       And   ClaimForm_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ClaimFormId#" />
      </cfquery>
	  
	    
	  
	  <cfcatch type="any">
		 <cfset returnObj["status"] = false />
		 <cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
	    </cfcatch>
       </cftry>
      </cfif>
	 
	 <cfif returnObj["status"]>
	  <cfset returnObj["message"] = message />
	 <cfif structKeyExists(arguments, 'ClaimFormId') and arguments.ClaimFormId neq ''>
       <cfset claimArg = arguments.ClaimFormId /> 
	   <cfset returnObj["id"] = arguments.ClaimFormId />
	 <cfelse>
	   <cfset returnObj["id"] = claimNum />
	</cfif>
   </cfif>
	<cfreturn returnObj />
</cffunction>

<cffunction name="saveItemInfo" access="public" returntype="struct" output="false" displayname="saveItemInfo">
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
	
	<cfset var insertItem = "" />
    <cfset var updateItem = "" />
	<cfset var message = "" />
	<cfset var returnObj = structnew() />
	<cfset returnObj["status"] = true />
	<cfset returnObj["message"] = "" />
	
	<cfif arguments.saveType is "save">
	 <cftry>
	  <cfquery name="insertItem" datasource="#variables.dsn#">
	     Insert Into Broker_ClaimDtl_Form (
	     ClaimFormFK,user_IdFK,Form_IDFK,item_Id,Program_ItemId,Item_Desc,STD,Promo_rate,Invoice_Price,
	     Promo_Amt,Less_Corp_Allow,Less_Local_Allow,Price_List,Item_Case_Weight,
	     Cases_Claimed,Net_Lbs_Claimed,Adj_Extended_Amt,Net_Promo_Amt
	     )
	     Values (
	     <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" />,
	     <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.user_id#" />,
	     <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formId#" />,
	     <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.itemId#" />,
	     <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.program_ItemID#" />,
	     <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.itemDesc#" />,
	     <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.STD#" />,
	     <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.promoRate#" />,
	     <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.invoice#" />,
	     <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.Promo_Amt#" />,
	     <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.corpAllow#" />,
	     <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.localAllow#" />,
	     <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.priceList#" />,
	     <cfif isNumeric(arguments.caseWeight)>
	      <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.caseWeight#"/>,
	    <cfelse>
	      <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.caseWeight#" null="true"/>, 
		</cfif>
	    <cfif isNumeric(arguments.claimedCases)>
	     <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.claimedCases#" />,
	    <cfelse>
	     <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.claimedCases#" null="true" />,
	    </cfif>
	    <cfif isNumeric(arguments.poundsClaimed)>
	     <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.poundsClaimed#" />,
	    <cfelse>
	     <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.poundsClaimed#" null="true" />,
	    </cfif>
	     <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.adjustedAmt#" />,
	     <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.promoAmt#" />
	     )
	  </cfquery>
	  
	    <cfset message = "Claim ID: #arguments.id# has been successfully saved..." />
	  
	  <cfcatch type="any">
	   <cfset returnObj["status"] = false />
	   <cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
	   <cflog file="saveItemsLog" text="#CFCATCH.message# : #CFCATCH.detail#" />
      </cfcatch>
	 </cftry>
	<cfelse>
	<cftry>
	 <cfquery name="updateItem" datasource="#variables.dsn#">
	    Update Broker_ClaimDtl_Form
	    
	    Set 
	     Program_ItemId = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.program_ItemID#" />,
	     Item_Desc = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.itemDesc#" />,
	     STD = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.STD#" />,
	     Promo_rate = <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.promoRate#" />,
	     Invoice_Price = <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.invoice#" />,
	     Promo_Amt = <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.Promo_Amt#" />,
	     Less_Corp_Allow = <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.corpAllow#" />,
	     Less_Local_Allow = <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.localAllow#" />,
	     Price_List = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.priceList#" />,
	     <cfif isNumeric(arguments.caseWeight)>
	     Item_Case_Weight = <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.caseWeight#" />
	     <cfelse>
	      Item_Case_Weight = <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.caseWeight#" null="true"/> 
		</cfif>
	     ,
	     <cfif isNumeric(arguments.claimedCases)>
	      Cases_Claimed = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.claimedCases#" />
	    <cfelse>
	      Cases_Claimed = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.claimedCases#" null="true" />
	    </cfif>
        ,
	     <cfif isNumeric(arguments.poundsClaimed)>
	      Net_Lbs_Claimed = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.poundsClaimed#" />
	    <cfelse>
	      Net_Lbs_Claimed = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.poundsClaimed#" null="true" />
	    </cfif>
	     ,
	     Adj_Extended_Amt = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.adjustedAmt#" />,
	     Net_Promo_Amt = <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.promoAmt#" />
	    Where ClaimFormFK = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" />
	    <!--- And   user_IdFK =   <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.user_id#" /> --->
	    And   Form_IDFK = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formId#" />
	    And   item_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.itemId#" />
	</cfquery>
	
	 <cfset message = "Claim ID: #arguments.id# has been successfully updated..." />
	
	<cfcatch type="any">
	   <cfset returnObj["status"] = false />
	   <cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
	   <cflog file="saveItemsLog" text="#CFCATCH.message# : #CFCATCH.detail#" />
      </cfcatch>
	 </cftry>
   </cfif> 

   <cfif returnObj["status"]>
	  <cfset returnObj["message"] = message />
   </cfif>

   <cfreturn returnObj />
</cffunction>

<cffunction name="existingClaim" access="public" returntype="query" output="false" displayname="existingClaim">

   	<!--- <cfargument name="broker_Id" required="yes" type="any" /> --->
	<!--- <cfargument name="user_id" type="string" required="true" /> --->	
	<cfargument name="programNum" type="string" required="true" />
	<cfargument name="shipToNum" type="string" required="true" />
	<cfargument name="sentDate" type="Date" required="true" />
	<cfargument name="fromDate" type="Date" required="true" />
	<cfargument name="toDate" type="Date" required="true" />
	<!--- 	<cfargument name="custName" type="string" required="true" /> --->
	
	<cfset var getExistingClaim = "" />
	<cfquery name="getExistingClaim" datasource="#variables.dsn#">
				
		SELECT		Claims.ClaimForm_Id, Convert(varchar,Claims.InterfaceDate,1) As interfaceDate, 
					Header.Ship_Num, Header.Program_Number, Claims.Inv_Ref_Num, Count(Claims.ClaimForm_Id) as Count
		FROM		Broker_Program_Claim_Form Claims
		INNER JOIN	Broker_Program_Claims_Hdr Header ON Header.Form_Id = Claims.Form_IdFK
		WHERE 		Header.Program_Number  = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.programNum#" />
		AND			Header.Ship_Num = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.shipToNum#" />
		AND			Convert(varchar,Header.Sent_Date,1) = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.sentDate#"/>
		AND			Claims.Form_State in (<cfqueryparam cfsqltype="cf_sql_numeric" value="1,2,3" list="true" />)
		AND			(
						(Convert(varchar,Claims.Claim_Date_From,1) 
						 BETWEEN 	Convert(varchar,<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.fromDate#" />,1)
						 AND		Convert(varchar,<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.toDate#" />,1)
						)
					OR
						(Convert(varchar,Claims.Claim_Date_To,1) 
						 BETWEEN 	Convert(varchar,<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.fromDate#" />,1)
						 AND		Convert(varchar,<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.toDate#" />,1)
						)
					OR
						(Convert(varchar,<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.fromDate#" />,1) 
						 BETWEEN 	(Convert(varchar,Claims.Claim_Date_From,1))
						 AND		(Convert(varchar,Claims.Claim_Date_To,1)) 
						)
					)
		GROUP BY 	Claims.ClaimForm_Id, Convert(varchar,Claims.InterfaceDate,1), Header.Ship_Num, Header.Program_Number, Claims.Inv_Ref_Num
		ORDER BY	Claims.ClaimForm_Id DESC
	</cfquery>
  <cfreturn getExistingClaim />
</cffunction>

<cffunction name="getClaim" access="public" returntype="query" output="false" displayname="getClaim">

	<cfargument name="formId" type="string" required="true" />
	
	<cfset var qGetClaim = "" />
	
	<cfquery name="qGetClaim" datasource="#variables.dsn#">
		
		SELECT	Broker_Id,
				LTRIM(RTRIM(Broker_Name)) As Broker_Name,
				Cust_Name,
				Address, 
				State,
				Ship_Num,
				Program_Number,
				Desc_Number,
				BeginDate,
				EndDate,
				Autos_Fixed,
				Autos_Deduct,
				Autos_Pullback,
				Ba_Id,
				Sent_Date,
				PayTo_Num,
				PayTo_Name
		FROM	Broker_Program_Claims_Hdr
		WHERE	Form_ID = <cfqueryparam value="#arguments.formId#" cfsqltype="CF_SQL_INTEGER" />

	</cfquery>
	
	<cfreturn qGetClaim />
	
</cffunction>

<cffunction name="getClaimForm" access="public" returntype="query" output="false" displayname="getClaimForm">

	<cfargument name="formId" 		type="string" required="true" />
	<cfargument name="claimFormId" 	type="string" required="true" />
	
	<cfset var var_claimFormID 	= arguments.claimFormId />
	<cfset var var_formID 		= arguments.formId />
	<cfset var qGetClaimForm 	= "" />
	
	<cfquery name="qGetClaimForm" datasource="#variables.dsn#">
		SELECT	Claim_Date_From,
				Claim_Date_To,
				Claim_Amt,
				Inv_Ref_Num,
				Broker_Rcv_Date,
				Inv_Date,
				user_IdFK,
				Form_IdFK,
				casesClaimed 
		FROM	Broker_Program_Claim_Form
		WHERE	ClaimForm_ID 	= <cfqueryparam value="#var_claimFormID#" cfsqltype="CF_SQL_INTEGER" />
		AND		Form_IdFK 		= <cfqueryparam value="#var_formID#" cfsqltype="CF_SQL_INTEGER" />

	</cfquery>
	
	<cfreturn qGetClaimForm />
	
</cffunction>
	
</cfcomponent>