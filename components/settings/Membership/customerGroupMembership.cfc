<cfcomponent output="false" displayname="Membership">
<cfsetting showDebugOutput="no">	
<!--- Family look up function --->
	<cffunction name="lookupFamily" access="remote" >
        <cfargument name="search" type="any" required="false" default="">
		
		 	<cfset var family="">
		    <cfset var result=ArrayNew(1)>
		
			<cfquery name="family" datasource="#application.datasource#">
					SELECT (rtrim(Family_Name) + '('+rtrim(Family)+')') AS familyName, family_id
					FROM Distributor_Family 
					WHERE Deleted = 0 
					AND (family_name like '#trim(arguments.search)#%' or family like '#trim(arguments.search)#%')
					ORDER BY Family_Name
			</cfquery>
			
	   <cfloop query="family">

			<cfset returnStruct = StructNew() />
			<cfset returnStruct["value"] = familyName />
			<cfset returnStruct["id"] = family_id />
			<cfset ArrayAppend(result,returnStruct) />

        </cfloop>
        
        <cfreturn SerializeJSON(result)/>
	
	</cffunction>
	
<!--- Buying Group look up function --->
	<cffunction name="lookupBuyingGroup" access="remote" >
        <cfargument name="search" type="any" required="false" default="">
		
		 	<cfset var buyinggroup="">
		    <cfset var result=ArrayNew(1)>
		
			<cfquery name="buyinggroup" datasource="#application.datasource#">
					SELECT (rtrim(Buying_Group) + '('+rtrim(Buying_Group_Name)+')') AS BuyingGroup, Buying_Group_ID
					FROM Distributor_Buying_Groups 
					WHERE Deleted = 0 
					AND (Buying_Group_Name like '#trim(arguments.search)#%' or Buying_Group like '#trim(arguments.search)#%')
					ORDER BY Buying_Group_Name
			</cfquery>
			
	   <cfloop query="buyinggroup">

			<cfset returnStruct = StructNew() />
			<cfset returnStruct["value"] = BuyingGroup />
			<cfset returnStruct["id"] = Buying_Group_ID />
			<cfset ArrayAppend(result,returnStruct) />

        </cfloop>
        
        <cfreturn SerializeJSON(result)/>
	
	</cffunction>
	
<!--- Ship To look up function --->
	<cffunction name="lookupShipTo" access="remote" >
        <cfargument name="search" type="any" required="false" default="">
		
	 	<cfset var family="">
	    <cfset var result=ArrayNew(1)>
		
			<cfquery name="shipto" datasource="#application.datasource#">
					SELECT (rtrim(name) + '('+rtrim(shr_ship_to)+')') AS SharedshipTo, BSA_Foodservice_Customers_id 
					FROM BSA_Foodservice_Customers 
					WHERE deleted = 0 
					AND (name like '#trim(arguments.search)#%' or shr_ship_to like '#trim(arguments.search)#%')
					ORDER BY name
			</cfquery>
			
	   <cfloop query="shipto">

			<cfset returnStruct = StructNew() />
			<cfset returnStruct["value"] = SharedshipTo />
			<cfset returnStruct["id"] = BSA_Foodservice_Customers_id />
			<cfset ArrayAppend(result,returnStruct) />
			
        </cfloop>
        
        <cfreturn SerializeJSON(result)/>
		
	</cffunction>

	<cffunction name="membershipDetails" returntype="Query">
			<cfargument name="grouptype" type="numeric" required="true" default="">
			<cfargument name="groupid" 		type="any" required="false" default="">
			<cfargument name="shiptoid" 		type="any" required="false" default="">
			<cfargument name="startdate" 	type="any" required="false" default="">
	
			<cfquery name="membersinfo" datasource="#application.datasource#">
						SELECT 	cgm.customer_group_members_id,
										cgm.Customer_Group_Type,
						            	f.Group_GUID, 
						            	f.Group_Number, 
						            	f.Group_Desc,
						            	c.BSA_Foodservice_Customers_ID, 
						            	c.Shr_Ship_To, 
						            	c.Name,
						            	cgm.Start_Date, 
						            	cgm.End_Date
						FROM  	Customer_Group_Members cgm
						INNER JOIN All_Customer_Group_Types f 
						ON          f.Group_GUID = cgm.Customer_Group_ID
						INNER JOIN BSA_Foodservice_Customers c
						ON          c.BSA_Foodservice_Customers_ID = cgm.BSA_Foodservice_Customers_ID
						WHERE cgm.Deleted = 0
						AND         cgm.Customer_Group_Type = #arguments.grouptype#
						<cfif len(trim(arguments.groupid))>
						AND f.Group_GUID = '#trim(arguments.groupid)#'
						</cfif>
						<cfif len(trim(arguments.shiptoid))>
						AND c.BSA_Foodservice_Customers_ID = '#trim(arguments.shiptoid)#'
						</cfif>
						<cfif len(trim(arguments.startdate))>
						AND cgm.Start_Date = '#trim(arguments.startdate)#'
						</cfif>
			</cfquery>
			<cfreturn membersinfo/>
	</cffunction>

	<cffunction name="minstartdate" returntype="Query">
			<cfargument name="shiptoid" 		type="any" required="false" default="">
			<cfargument name="startdate" 	type="any" required="false" default="">
	
				<cfquery name="allowedstartdate" datasource="#application.datasource#">
						SELECT 	DateAdd(d, 1, Max(cgm.Start_Date)) as Min_Allowed_Date
						FROM  	Customer_Group_Members cgm
						WHERE cgm.Deleted = 0
						AND         cgm.Customer_Group_Type = 2
						AND cgm.BSA_Foodservice_Customers_ID = '#arguments.shiptoid#'
						AND DateDiff(d, cgm.Start_Date, '#arguments.startdate#') > 0
				</cfquery>
				<cfreturn allowedstartdate/>
	</cffunction>

	<cffunction name="updateMemeber" returntype="any" >
					<cfargument name="formvalues" type="any" default="">
					<cfset passedForm = structNew()>
					<cfset passedForm = #arguments.formvalues#>
<!--- REMOVE --->
<cfif passedForm.remove>
	 
	<cftransaction>	
<cfif passedForm.previousMemberId>
		<cfquery name="updateMemberStartDate" datasource="#application.datasource#">
				UPDATE customer_group_members
				SET end_date = '#passedForm.updateEndDate#'
				WHERE customer_group_members_id = #passedForm.previousMemberId#
				AND customer_group_type = '#passedForm.groupType#'	
		</cfquery>
</cfif>
		<cfquery name="deleteMember" datasource="#application.datasource#">
				UPDATE  customer_group_members
				SET deleted = 1
				WHERE customer_group_members_id = '#passedForm.currentMemberId#'
				AND customer_group_type = '#passedForm.groupType#'
		</cfquery>
		
	</cftransaction>
	
<!--- UPDATE --->	
<cfelseif passedForm.update>

	<cftransaction>		

		<cfquery name="updateMemberStartDate" datasource="#application.datasource#">
				UPDATE customer_group_members
				SET start_date = '#passedForm.startDate#'
				WHERE customer_group_members_id = '#passedForm.currentMemberId#'
				AND customer_group_type = '#passedForm.groupType#'
		</cfquery>
<cfif passedForm.previousMemberId>
		<cfquery name="updateMemberEndDate" datasource="#application.datasource#">
				UPDATE customer_group_members
				SET end_date = DATEADD(day,-1,#CreateODBCDateTime(passedForm.startDate)#)
				WHERE customer_group_members_id = '#passedForm.previousMemberId#'
				AND customer_group_type = '#passedForm.groupType#'
		</cfquery>
</cfif>

	</cftransaction>
		
</cfif>
		
	</cffunction>

</cfcomponent>
