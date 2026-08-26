<cfcomponent extends="components.Ajaxcfc.Ajax">
	<cffunction name="init" output="false" returntype="components.Billback.Programs.Billback_Programs_Products">
		<cfreturn this />
</cffunction>

<cffunction name="getBillbackProgramId" access="public" ouput="false" returntype="query">
 <cfargument name="Billback_Id" type="string" required="true" />
 <cfargument name="Program_Id" type="numeric" required="true" />

 <cfset var getBillback_Program_ID = "" />

	 <cfquery name="getBillback_Program_ID" datasource="#Application.Datasource#">
	  Select Billback_Program_ID
	  from Billback_Program
	  where Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Billback_Id#" />
	  and program_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Program_Id#" />
	  and deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
	</cfquery>
	
	<cfreturn getBillback_Program_ID />
</cffunction>

<cffunction name="deleteProductsOnProgam" access="public" ouput="false" returntype="string">
   <cfargument name="billback_Id" type="string" required="true" />
   <cfargument name="billback_ProgramId" type="string" required="true"/>
   <cfargument name="Product_Id" type="string" required="true" />
   <cfargument name="Customer_Id" type="string" required="true" />
   <cfargument name="Product_Type" type="numeric" required="true" />
   
   <cfset var deleteProgramProductDetail = "" />
   <cfset var deleteProgramProducts = "" />
   <cftry>
	<cfquery name="deleteProgramProductDetail" datasource="#Application.Datasource#">
		UPDATE Billback_Product_Detail
		SET Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="1" />
		From Billback_Product_Detail
		Inner Join Billback_Product On
		<CFIF Product_Type EQ 3>
		Billback_Product.Billback_Product_Id = Billback_Product_Detail.Billback_Product_Id
   		And Billback_Product.Billback_Product_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Product_Id#" /> 
		<CFELSE>
		Billback_Product.Billback_Id = Billback_Product_Detail.Billback_Id
		And Billback_Product.Billback_Product_Id = Billback_Product_Detail.Billback_Product_Id
		And Billback_Product.Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billback_id#" />
		And Billback_Product.Billback_Program_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billback_ProgramId#" /> 
		And Billback_Product.Product_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Product_Id#" /> 
		And Billback_Product.Distributor_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Customer_Id#" /> 
		</CFIF>
		And Billback_Product_Detail.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
		And Billback_Product.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
		
	</cfquery>
	
	<cfquery name="deleteProgramProducts" datasource="#Application.Datasource#">
		UPDATE Billback_Product
		SET Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="1" />
		WHERE 
		<CFIF Product_Type EQ 3>
		/* Billback_Product.Billback_Product_Id = Billback_Product_Detail.Billback_Product_Id	AND */
		Billback_Product.Billback_Product_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Product_Id#" /> 
		<CFELSE>
		Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billback_id#" />
		And Billback_Program_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billback_ProgramId#"> 
		And Billback_Product.Product_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Product_Id#" />
		And Billback_Product.Distributor_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Customer_Id#" />
		</CFIF>
		And Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
	</cfquery>
	<cfcatch type="any">
	 <cflog file="productDetail" text="#cfcatch.QueryError# #cfcatch.SQL# billback_id=#arguments.billback_Id# billback_ProgramId = #arguments.billback_ProgramId# Product_Id = #arguments.Product_Id#" />
	</cfcatch>
   </cftry>
   <cfreturn "" />
</cffunction>

<cffunction name="undeleteProductsOnProgam" access="public" ouput="false" returntype="string">
   <cfargument name="billback_Id" type="string" required="true" />
   <cfargument name="billback_ProgramId" type="string" required="true"/>
   <cfargument name="Product_Id" type="string" required="true" />
   <cfargument name="Customer_Id" type="string" required="true" />
   <cfargument name="Product_Type" type="numeric" required="true" />
   
   <cfset var undeleteProgramProductDetail = "" />
   <cfset var undeleteProgramProducts = "" />
   <cftry>
	<cfquery name="undeleteProgramProductDetail" datasource="#Application.Datasource#">
		UPDATE Billback_Product_Detail
		SET Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
		From Billback_Product_Detail
		Inner Join Billback_Product On
		<CFIF Product_Type EQ 3>
		Billback_Product.Billback_Product_Id = Billback_Product_Detail.Billback_Product_Id
		And Billback_Product.Billback_Product_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Product_Id#" /> 
		<CFELSE>
		Billback_Product.Billback_Id = Billback_Product_Detail.Billback_Id
		And Billback_Product.Billback_Product_Id = Billback_Product_Detail.Billback_Product_Id
		And Billback_Product.Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billback_id#" />
		And Billback_Product.Billback_Program_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billback_ProgramId#" />
		And Billback_Product.Distributor_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Customer_Id#" /> 
		And Billback_Product.Product_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Product_Id#" /> 
		</CFIF>
		And Billback_Product_Detail.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="1" />
		And Billback_Product.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="1" />
	</cfquery>
	
	<cfquery name="undeleteProgramProducts" datasource="#Application.Datasource#">
		UPDATE Billback_Product
		SET Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
		WHERE 
		<CFIF Product_Type EQ 3>
		Billback_Product.Billback_Product_Id = Billback_Product_Detail.Billback_Product_Id
		And Billback_Product.Billback_Product_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Product_Id#" /> 
		<CFELSE>
		Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billback_id#" />
		And Billback_Program_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billback_ProgramId#"> 
		And Billback_Product.Distributor_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Customer_Id#" />
		And Billback_Product.Product_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Product_Id#" />
		</CFIF>
		And Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="1" />
	</cfquery>
	<cfcatch type="any">
	 <cflog file="productDetail" text="#cfcatch.QueryError# #cfcatch.SQL# billback_id=#arguments.billback_Id# billback_ProgramId = #arguments.billback_ProgramId# Product_Id = #arguments.Product_Id#" />
	</cfcatch>
   </cftry>
   <cfreturn "" />
</cffunction>
</cfcomponent>