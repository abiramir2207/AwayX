<!---  
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\ajax\Customer_PG_Query.cfm
	Created:	3/12/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USED TO MAKE  CALLS TO DB FOR MASTER DATA
	Usage:
		SETTING>>ADMINISTRATOR>>EDIT_MASTER_DATA.
--->

<cfcomponent displayname="ItemMaster" hint="get info for edit master data">

	<cffunction name="getBrandNames"  access="remote"  output="false" hint="get brand name">    
		<cfargument name="suggestvalue" required="true">
		<cfquery name="brand" datasource="#application.datasource#" >
			SELECT 	Brand
			FROM 	Brand 
			WHERE 	Brand LIKE <cfqueryparam value="#suggestvalue#%" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfset BrandArray = ListToArray(ValueList(brand.Brand)) />    
    <cfreturn  BrandArray>    
    </cffunction>
 
	<cffunction name="getProductGroup"  access="remote"  output="false" hint="get product group">   
    	<cfargument name="suggestvalue" required="true">
		<cfquery name="product" datasource="#application.datasource#" >
			SELECT 	product_group_desc 
			FROM 	BSA_Product_Group 
			WHERE 	product_group_desc LIKE <cfqueryparam value="#suggestvalue#%" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfset ProductArray = ListToArray(ValueList(product.product_group_desc)) />    
    <cfreturn  ProductArray>    
    </cffunction> 

	<cffunction name="getClass"  access="remote"  output="false" hint="get class info">   
    	<cfargument name="suggestvalue" required="true">
		<cfquery name="class" datasource="#application.datasource#" >
			SELECT 	Class_Code_Desc 
			FROM 	Class_Code 
			WHERE 	Class_Code_Desc LIKE <cfqueryparam value="#suggestvalue#%" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfset ClassArray = ListToArray(ValueList(class.Class_Code_Desc)) />    
    <cfreturn  ClassArray>    
    </cffunction> 
 
	<cffunction name="getBrandid"  access="remote"  output="false" hint="get Brand ID info">   
    	<cfargument name="suggestvalue" required="true">
			
   			<cfset var result=arraynew(1)>
		<cfquery name="brand" datasource="#application.datasource#" >
			SELECT 	Brand_ID 
			FROM 	Brand 
			WHERE 	Brand LIKE <cfqueryparam value="#suggestvalue#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfloop query="brand">
			<cfset ArrayAppend(result, "#Brand_ID#")/>
		</cfloop>   
    <cfreturn  result>    
    </cffunction>  

	<cffunction name="getClassid"  access="remote"  output="false" hint="get class ID info">   
    	<cfargument name="suggestvalue" required="true">
			
   			<cfset var result=arraynew(1)>
		<cfquery name="class" datasource="#application.datasource#" >
			SELECT 	Class_Code_ID 
			FROM 	Class_Code 
			WHERE 	Class_Code_Desc LIKE <cfqueryparam value="#suggestvalue#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfloop query="class">
			<cfset ArrayAppend(result, "#Class_Code_ID#")/>
		</cfloop>   
    <cfreturn  result>    
    </cffunction>  

	<cffunction name="getClassUUID"  access="remote"  output="false" hint="get class UUID info">   
    	<cfargument name="suggestvalue" required="true">
			
   			<cfset var result=arraynew(1)>
		<cfquery name="class" datasource="#application.datasource#" >
			SELECT 	Class_Code_UUID 
			FROM 	Class_Code 
			WHERE 	Class_Code_Desc LIKE <cfqueryparam value="#suggestvalue#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfloop query="class">
			<cfset ArrayAppend(result, "#Class_Code_UUID#")/>
		</cfloop>   
    <cfreturn  result>    
    </cffunction> 

	<cffunction name="getProductid"  access="remote"  output="false" hint="get Product ID info">   
    	<cfargument name="suggestvalue" required="true">
			
   			<cfset var result=arraynew(1)>
		<cfquery name="product" datasource="#application.datasource#" >
			SELECT 	BSA_Product_Group_ID 
			FROM 	BSA_Product_Group 
			WHERE 	Product_Group_Desc LIKE <cfqueryparam value="#trim(suggestvalue)#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfloop query="product">
			<cfset ArrayAppend(result, "#BSA_Product_Group_ID#")/>
		</cfloop>   
    <cfreturn  result>    
    </cffunction>
        
	<cffunction name="getItems"  access="public"  output="false" hint="get items"> 
		 <cfargument name="BSAID" required="true" type="any">
		 <cfquery name="Items" datasource="#application.datasource#">
				SELECT     BSA.Item AS Item, BSA.Description AS Description, Brand.Brand AS Brand_ID, Brand.Brand_Name AS Brand, Class_Code.Class_Code_Desc AS Class, 
						   BSA_Product_Group.Product_Group_Desc AS Product, BSA.BSA_Foodservice_Items_Master_ID, (_Users.Name_First + ' ' + _Users.Name_Last) AS Name, BSA.Manually_Updated_Date AS Date  
				FROM       BSA_Foodservice_Items_Master BSA
				INNER JOIN Brand ON BSA.Brand_ID = Brand.Brand_ID 
				LEFT JOIN  Class_Code ON BSA.Class_Code_ID = Class_Code.Class_Code_ID 
				LEFT JOIN  BSA_Product_Group ON BSA.BSA_Product_Group_ID = BSA_Product_Group.BSA_Product_Group_ID
				LEFT JOIN  _Users ON BSA.Manually_Updated_BY = _Users.User_ID
				WHERE	   BSA.Deleted = 0 
				AND 	   BSA.Active_Code = 'A'
				AND 	   BSA.BSA_Foodservice_Items_Master_ID = '#trim(arguments.BSAID)#'
		</cfquery>
	<cfreturn  Items> 
	</cffunction> 

	<cffunction name="UpdateBSAItemMaster"  access="public"  output="false" hint="">
		<cfargument name="BSA_Item_Master_ID" 	required="true" 	type="any">
		<cfargument name="Description" 			required="true" 	type="any">
		<cfargument name="Brand_ID" 			required="true" 	type="any">
		<cfargument name="Class_ID" 			required="true" 	type="any">
		<cfargument name="Product_ID" 			required="true" 	type="any">
		<cfargument name="Class_Code_UUID" 		required="true" 	type="any">
		<cfargument name="UserID" 				required="true" 	type="any">
			

		<cfquery name="UpdateItems" datasource="#application.datasource#">
			UPDATE 	BSA_Foodservice_Items_Master
			SET 	Description = '#arguments.Description#',
				 	Brand_ID = '#arguments.Brand_ID#',
				 	Class_Code_ID = <cfif len(arguments.Class_ID) EQ 0>NULL<cfelse>'#arguments.Class_ID#'</cfif>,
				 	BSA_Product_Group_ID = <cfif len(arguments.Product_ID) EQ 0>NULL<cfelse>'#arguments.Product_ID#'</cfif>,
					Class_Code_UUID = <cfif len(arguments.Class_Code_UUID) EQ 0>NULL<cfelse>'#arguments.Class_Code_UUID#'</cfif>,
					Manually_Updated_BY = '#arguments.UserID#',
					Manually_Updated_Date = getdate() 
			WHERE 	BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#trim(arguments.BSA_Item_Master_ID)#" cfsqltype="cf_sql_varchar" >
		</cfquery>
	<cfreturn  >
	</cffunction>

	<cffunction name="getDistributors" access="public" output="false" hint="get distributors">
		<cfargument name="CUSID" required="true" type="any">
		 <cfquery name="Distributors" datasource="#application.datasource#">
			SELECT 		BSA.ship_to, 
								BSA.name, BSA.buying_group_id, 
								CWB.freight_bracket_setting_id, 
								BSA.BSA_Foodservice_Customers_ID, 
								PLH.price_list_id, 
								BSA.distributor_type_id, 
								BSA.distributor_type_c_id, 
								BSA.distributor_type_b_id, 
								BSA.distributor_type_h_id,								
								FLB.Freight_Bracket_Label, 
								PLH.Price_List_Description, 
								DT.Distributor_Type_Name, 
								DTC.Distributor_Type_C_Desc, 
								DTB.Distributor_Type_B, 
								DTB.Distributor_Type_B_Desc,
								DTH.Distributor_Type_H, 
								DTH.Distributor_Type_H_Desc,
								(U.Name_First + ' ' + U.Name_Last) AS UserName, 
								BSA.Manually_Updated_Date AS Date,
								ISNULL(BSA.Address_1,'N/A')+',&nbsp;&nbsp;'+ISNULL(BSA.City,'N/A')+',&nbsp;&nbsp;'+ISNULL(BSA.State,'N/A')+',&nbsp;&nbsp;'+ISNULL(BSA.ZipCode,'N/A') As Address ------ D39476 :: Edit Master Data - Distributor - add address, city, state
			FROM 		BSA_Foodservice_Customers BSA 
			LEFT JOIN 	Customer_Warehouse_Bracket CWB ON CWB.distributor_id = BSA.BSA_Foodservice_Customers_ID 
			AND 			CWB.deleted = 0 
			LEFT JOIN 	Freight_Lookup_Bracket_Settings FLB ON FLB.Freight_Bracket_Setting_ID = CWB.Freight_Bracket_Setting_ID 
			LEFT JOIN 	price_list_header PLH ON PLH.Price_List_Header_ID = BSA.Price_List_Header_ID
			AND  			PLH.Deleted = 0
			LEFT JOIN 	Distributor_Type DT ON DT.Distributor_Type_ID = BSA.Distributor_Type_ID
			AND 			DT.Deleted = 0
			LEFT JOIN 	Distributor_Type_C DTC ON DTC.Distributor_Type_C_ID = BSA.Distributor_Type_C_ID
			LEFT JOIN 	Distributor_Type_B DTB ON DTB.Distributor_Type_B_ID = BSA.Distributor_Type_B_ID
			LEFT JOIN 	Distributor_Type_H DTH ON DTH.Distributor_Type_H_ID = BSA.Distributor_Type_H_ID
			LEFT JOIN	_Users U ON	U.User_ID = BSA.Manually_Updated_By
			WHERE 		BSA.deleted = 0 
			AND 			BSA.BSA_Foodservice_Customers_ID = '#trim(arguments.CUSID)#'		 	 
		 </cfquery>
	<cfreturn Distributors>
	</cffunction>

	<cffunction name="getBracketNames"  access="remote"  output="false" hint="get bracket name">    
		<cfargument name="suggestvalue" required="true">
		<cfquery name="Bracket" datasource="#application.datasource#" >
			SELECT 	Freight_Bracket_Label
			FROM 	Freight_Lookup_Bracket_Settings
			WHERE 	Freight_Bracket_Label LIKE <cfqueryparam value="#suggestvalue#%" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfset BracketArray = ListToArray(ValueList(Bracket.Freight_Bracket_Label)) />    
    <cfreturn  BracketArray>    
    </cffunction>

	<cffunction name="getBracketid"  access="remote"  output="false" hint="get Bracket ID info">   
    	<cfargument name="suggestvalue" required="true">
	   			<cfset var result=arraynew(1)>
				<cfquery name="Bracket" datasource="#application.datasource#" >
					SELECT 	Freight_Bracket_Code 
					FROM 	Freight_Lookup_Bracket_Settings 
					WHERE 	Freight_Bracket_Label LIKE <cfqueryparam value="#suggestvalue#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfloop query="Bracket">
					<cfset ArrayAppend(result, "#Freight_Bracket_Code#")/>
				</cfloop>   
		    	<cfreturn  result> 
    </cffunction>  

	<cffunction name="getDistributorsType" access="remote"  output="false" returntype="query" hint="get Distributor Types" >
		<cfquery name="DistributorsType" datasource="#application.datasource#" >
		SELECT 	Distributor_Type_name, Distributor_type_id
		FROM 	Distributor_Type
		WHERE 	Deleted = 0
		</cfquery>
   	 <cfreturn  DistributorsType>    
	</cffunction>
	
	<cffunction name="getDistributorsTypeB" access="remote"  output="false" returntype="query" hint="get Distributor B Types" >
		<cfquery name="DistributorsTypeB" datasource="#application.datasource#" >
			SELECT 	Distributor_Type_B_ID, Distributor_Type_B, Distributor_Type_B_Desc
			FROM 	Distributor_Type_B
			WHERE 	Deleted = 0
		</cfquery>
   	 <cfreturn  DistributorsTypeB>    
	</cffunction>
	
	<cffunction name="getDistributorsTypeH" access="remote"  output="false" returntype="query" hint="get Distributor H Types" >
		<cfquery name="DistributorsTypeH" datasource="#application.datasource#" >
			SELECT 	Distributor_Type_H_ID, Distributor_Type_H, Distributor_Type_H_Desc
			FROM 	Distributor_Type_H
			WHERE 	Deleted = 0
		</cfquery>
   	 <cfreturn  DistributorsTypeH>    
	</cffunction>
	
	<cffunction name="getPriceList"  access="remote"  output="false" hint="get Price List Description">   
		<cfargument name="suggestvalue" required="true">
		<cfquery name="PriceList" datasource="#application.datasource#" >
			SELECT 	price_list_Description 
			FROM 	price_list_header
			WHERE 	price_list_Description LIKE <cfqueryparam value="#suggestvalue#%" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfset PriceList = ListToArray(ValueList(PriceList.price_list_Description)) />    
    	<cfreturn  PriceList>
    </cffunction> 
    
   	<cffunction name="getPriceListid"  access="remote"  output="false" hint="get Price List ID info">   
    	<cfargument name="suggestvalue" required="true">
			
   			<cfset var result=arraynew(1)>
		<cfquery name="PricList" datasource="#application.datasource#" >
			SELECT 	price_list_ID 
			FROM 	price_list_header
			WHERE 	price_list_Description LIKE <cfqueryparam value="#suggestvalue#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfloop query="PricList">
			<cfset ArrayAppend(result, "#price_list_ID#")/>
		</cfloop>   
    <cfreturn  result>    
    </cffunction> 
    
	<cffunction name="getTypeC"  access="remote"  output="false" hint="get Distributor Type C Desc">   
		<cfargument name="suggestvalue" required="true">
		<cfquery name="TypeC" datasource="#application.datasource#" >
    		SELECT 	Distributor_Type_C_Desc
			FROM 	Distributor_Type_C
			WHERE 	Deleted = 0
		</cfquery>
		<cfset TypeC = ListToArray(ValueList(TypeC.Distributor_Type_C_Desc)) />    
    	<cfreturn  TypeC>
    </cffunction> 

 	<cffunction name="getTypeCid"  access="remote"  output="false" hint="get Distributor Type C ID info">   
    	<cfargument name="suggestvalue" required="true">
   			<cfset var result=arraynew(1)>
   			<cfset arguments.suggestvalue = trim(arguments.suggestvalue)>
		<cfquery name="TypeC" datasource="#application.datasource#" >
			SELECT 	Distributor_Type_C_ID 
			FROM 	Distributor_Type_C
			WHERE 	Distributor_Type_C_Desc LIKE <cfqueryparam value="#arguments.suggestvalue#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<!--- 34835 - allowed any new value entered by users (see Paul's email attached to label)--->
		<cfif TypeC.recordCount eq 0>
			<cfquery name="TypeC" datasource="#application.datasource#" >
				INSERT 	INTO Distributor_Type_C 
								(Distributor_Type_C, Distributor_Type_C_Desc)
				VALUES ('#arguments.suggestvalue#', '#arguments.suggestvalue#')

				SELECT 	Distributor_Type_C_ID 
				  FROM 	Distributor_Type_C
				 WHERE 	Distributor_Type_C_Desc LIKE <cfqueryparam value="#arguments.suggestvalue#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
		<cfloop query="TypeC">
			<cfset ArrayAppend(result, "#TypeC.Distributor_Type_C_ID#")/>
		</cfloop>   
    <cfreturn  result>    
    </cffunction> 

	<cffunction name="UpdateBSAFoodserviceCustomers" acess="remote" output="true" hint="Update BSA Food Service Customers" >
		<cfargument name="BSA_Foodservice_Customer_Id" 	required="true" 	type="any"> 
		<cfargument name="Freight_Bracket_Setting_Id"	required="true" 	type="any">
		<cfargument name="Price_List_Id"				required="true" 	type="any">
		<cfargument name="Price_List_Header_Id"			required="true" 	type="any">
		<cfargument name="Distributor_Type_Id"			required="true" 	type="any">
		<cfargument name="Distributor_Type_c_Id"		required="true" 	type="any">
		<cfargument name="Distributor_type_b_Id"		required="true" 	type="any">
		<cfargument name="UserID" 						required="true" 	type="any">
		<cfargument name="Distributor_type_h_Id" 				required="true" 	type="any">		
		
		

			<cfquery name="UpdateData" datasource="#application.datasource#" >
					UPDATE 	Customer_Warehouse_Bracket
					SET		Freight_Bracket_Setting_ID = #val(arguments.Freight_Bracket_Setting_Id)#
					WHERE 	Distributor_Id = <cfqueryparam value="#trim(arguments.BSA_Foodservice_Customer_Id)#" cfsqltype="cf_sql_varchar">

					UPDATE	BSA_FOODSERVICE_CUSTOMERS
					SET		Price_List_Id 					= 	'#arguments.price_list_id#',
							<cfif len(arguments.price_list_header_id)> 
							Price_List_Header_Id 			= 	'#arguments.price_list_header_id#',
							<cfelse>
								Price_List_Header_Id 			= 	 NULL,
							</cfif>
							<cfif len(arguments.Distributor_type_id)>   <!---32240--->
								Distributor_Type_Id 		= 	'#arguments.Distributor_type_id#',
							<cfelse>
								Distributor_Type_Id 		= 	NULL,
							</cfif>
							<cfif len(arguments.Distributor_type_c_id)>
								Distributor_Type_C_Id 		= 	'#arguments.Distributor_type_c_id#',
							<cfelse>
								Distributor_Type_C_Id 		= 	NULL,
							</cfif>
							<cfif len(arguments.Distributor_type_b_id)>
								Distributor_Type_B_Id 		= 	'#arguments.Distributor_type_b_id#',
							<cfelse>
								Distributor_Type_B_Id 		= 	NULL,
							</cfif>							
							<cfif len(arguments.Distributor_type_h_id)>
								Distributor_Type_H_Id 		= 	'#arguments.Distributor_type_h_id#',
							<cfelse>
								Distributor_Type_H_Id 		= 	NULL,
							</cfif>														
							Manually_Updated_By				=	'#arguments.UserID#',
							Manually_Updated_Date 			= 	getdate()
					WHERE	BSA_FOODSERVICE_CUSTOMERS_ID	=  <cfqueryparam value="#trim(arguments.BSA_Foodservice_Customer_Id)#" cfsqltype="cf_sql_varchar">
			</cfquery>
		
	</cffunction>
 
   	<cffunction name="getPriceListheaderid"  access="remote"  output="false" hint="get Price List Header ID info">   
    	<cfargument name="suggestvalue" required="true">
			
   			<cfset var result=arraynew(1)>
		<cfquery name="PricList" datasource="#application.datasource#" >
			SELECT 	price_list_Header_ID 
			FROM 	price_list_header
			WHERE 	price_list_Description LIKE <cfqueryparam value="#suggestvalue#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfloop query="PricList">
			<cfset ArrayAppend(result, "#price_list_header_ID#")/>
		</cfloop>   
    <cfreturn  result>    
    </cffunction>    

</cfcomponent>
