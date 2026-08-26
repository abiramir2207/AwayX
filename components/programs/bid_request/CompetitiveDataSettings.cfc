<!--- 	
FILENAME:   CompetitiveDataSettings.cfc 				
CREATED:  	04/27/2011 - Tim Ford
--->						

<cfcomponent displayname="CompetitiveDataManager" hint="Handles backend DB access for Competitive Data Settings">

	<cffunction name="getWonBy"output="false" returntype="query" hint="function to return won by competitive data">
	
		<cfscript>
			//set local variables
			var qGetData	= "";	
			var qRetData	= "";

		</cfscript>
		
		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT	Program_Bid_Won_By_ID,
					Program_Bid_Won_By_Code,
					Program_Bid_Won_By_Description,
					Active,
					Deleted,
					Created_Date,
					Updated_Date,
					Updated_By
			FROM	Program_Bid_Won_By 
		  	WHERE 	Deleted = 0  
			ORDER BY Program_Bid_Won_By_Description
		</cfquery>
		
		<cfset qRetData = qGetData />
		
		<cfreturn qRetData />
		
	</cffunction>
	
	<cffunction name="getCategory"output="false" returntype="query" hint="function to return category competitive data">
	
		<cfscript>
			//set local variables
			var qGetData	= "";	
			var qRetData	= "";

		</cfscript>
		
		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT	Program_Bid_Category_ID,
					Program_Bid_Category_Code,
					Program_Bid_Category_Description,
					Active,
					Deleted,
					Created_Date,
					Updated_Date,
					Updated_By
			FROM	Program_Bid_Category 
		  	WHERE 	Deleted = 0  
			ORDER BY Program_Bid_Category_Description
		</cfquery>
		
		<cfset qRetData = qGetData />
		
		<cfreturn qRetData />
		
	</cffunction>
	
	<cffunction name="getPackage"output="false" returntype="query" hint="function to return package competitive data">
	
		<cfscript>
			//set local variables
			var qGetData	= "";	
			var qRetData	= "";

		</cfscript>
		
		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT	Program_Bid_Package_ID,
					Program_Bid_Package_Code,
					Program_Bid_Package_Description,
					Active,
					Deleted,
					Created_Date,
					Updated_Date,
					Updated_By
			FROM	Program_Bid_Package 
	  		WHERE 	Deleted = 0  
			ORDER BY Program_Bid_Package_Description
		</cfquery>
		
		<cfset qRetData = qGetData />
		
		<cfreturn qRetData />
		
	</cffunction>
	
	<cffunction name="getSource"output="false" returntype="query" hint="function to return source competitive data">
	
		<cfscript>
			//set local variables
			var qGetData	= "";	
			var qRetData	= "";

		</cfscript>
		
		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT	Program_Bid_Source_ID,
					Program_Bid_Source_Code,
					Program_Bid_Source_Description,
					Active,
					Deleted,
					Created_Date,
					Updated_Date,
					Updated_By
			FROM	Program_Bid_Source 
			WHERE 	Deleted = 0  
			ORDER BY Program_Bid_Source_Description
		</cfquery>
		
		<cfset qRetData = qGetData />
		
		<cfreturn qRetData />
		
	</cffunction>
	
	<cffunction name="getSourceType"output="false" returntype="query" hint="function to return source type competitive data">
	
		<cfscript>
			//set local variables
			var qGetData	= "";	
			var qRetData	= "";

		</cfscript>
		
		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT	Program_Bid_Source_Type_ID,
					Program_Bid_Source_Type_Code,
					Program_Bid_Source_Type_Description,
					Active,
					Deleted,
					Created_Date,
					Updated_Date,
					Updated_By
			FROM	Program_Bid_Source_Type 
			WHERE 	Deleted = 0  
			ORDER BY Program_Bid_Source_Type_Description
		</cfquery>
		
		<cfset qRetData = qGetData />
		
		<cfreturn qRetData />
		
	</cffunction>
	
</cfcomponent>