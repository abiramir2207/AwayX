
<cfcomponent displayname="Retrieve Information for Create List" hint="Create List">
	<cfproperty name="ObjectName" 	type="string"/> 
	<cfproperty name="ListTitle" 	type="string"/> 
	<cfproperty name="ListLabel" 	type="string"/>
	<cfproperty name="ListValue" 	type="string"/>  
	<cffunction name="getListTitle" access="public" returntype="string">
		<cfargument name="PassedObject" type="string" required="true">
		<cfset this.ObjectName = #arguments.PassedObject# />
		<cfswitch expression="#Ucase(this.ObjectName)#">
			<cfcase value="PROGRAM">
				<cfset this.ListTitle = "Program Selection" >
			</cfcase>
  			<cfcase value="OPERATOR">
				<cfset this.ListTitle = "Operator Selection" >
			</cfcase> 
			<cfcase value="CUSTOMERS">
				<cfset this.ListTitle = "Customer Selection" >
			</cfcase> 
			<cfcase value="PRODUCT">
				<cfset this.ListTitle = "Product Selection" >
			</cfcase> 
			<cfcase value="PRODUCTGROUP">
				<cfset this.ListTitle = "Product Group Selection" >
			</cfcase> 
  			 <cfdefaultcase>
			 	<cfset this.ListTitle = "" >
  			 </cfdefaultcase>
		</cfswitch>
		<cfreturn this.ListTitle>
	</cffunction>
	
	<cffunction name="getListLabel" access="public" returntype="string">
		<cfargument name="PassedObject" type="string" required="true">
		<cfset this.ObjectName = #arguments.PassedObject# />
		<cfswitch expression="#Ucase(this.ObjectName)#">
			<cfcase value="PROGRAM">
				<cfset this.ListLabel = "Enter Program Number followed by enter key" >
			</cfcase>
  		<!---30286 - added operator support--->
  		<cfcase value="OPERATOR_LEGACY_ID,BSA_OPERATOR_ID">
				<cfset this.ListLabel = "Enter Operator Number followed by enter key" >
			</cfcase> 
			<cfcase value="CUSTOMERS">
				<cfset this.ListLabel = "Enter #application.returned_customer_setting.shard_ship_to_label# followed by enter key" >
			</cfcase> 
			<cfcase value="PRODUCT">
				<cfset this.ListLabel = "Enter Item No followed by enter key<br><font size='-2' color='666666'>(Please Enter The Entire Product Number)</font>" >
			</cfcase> 
			<cfcase value="PRODUCTGROUP">
				<cfset this.ListLabel = "Enter Group Number No. followed by enter key<br><font size='-2' color='666666'>(Please Enter The Entire Product Group Number)</font>" >
			</cfcase> 
  			 <cfdefaultcase>
			 	<cfset this.ListLabel = "" >
  			 </cfdefaultcase>
		</cfswitch>
		<cfreturn this.ListLabel>
	</cffunction>
	<cffunction name="getListValue" access="public" returntype="string">
		<cfreturn this.ListValue>
	</cffunction>
</cfcomponent>