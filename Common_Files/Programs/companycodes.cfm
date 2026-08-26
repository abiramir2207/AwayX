<cffunction name="companyCodes" output="false" returntype="string" hint="Returns company codes for a program">
  <cfargument name="contract_main_id" type="string" required="true" hint="">

  <cfscript>
    var rsCodes = "";
  </cfscript>
  
  <cfquery name="rsCodes" datasource="#application.datasource#">
    <!---select only unique codes--->
    SELECT DISTINCT companyCode
      FROM (  
              <!---gather codes for distributors  --->
              SELECT BFC.Ship_To AS Companycode
                FROM Contract_Main CM
                     INNER JOIN Contract_Distributors CD ON CM.Contract_Main_Id = CD.Contract_Main_Id
                     INNER JOIN Bsa_Foodservice_Customers BFC ON BFC.Bsa_Foodservice_Customers_Id = CD.Bsa_Foodservice_Customers_Id
               WHERE CM.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.Contract_Main_Id#">
               
              UNION
              
              <!---gather codes for operators  --->
              SELECT COALESCE(CAST(BO.Legacy_ID as varchar(50)), 
                              CAST(BO.Bsa_Operator_ID as varchar(50))) AS CompanyCode
                FROM Contract_Main CM
                     INNER JOIN Contract_Operators CO ON CM.Contract_Main_Id = CO.Contract_Main_Id
                     INNER JOIN Bsa_Operator BO ON BO.Bsa_Operator_Id = CO.Bsa_Operator_Id
               WHERE CM.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.Contract_Main_Id#">
           ) CODES
     <!---select only non empty codes--->
     WHERE companyCode IS NOT NULL AND LEN(LTRIM(RTRIM(companyCode))) > 0
  </cfquery>

  <cfreturn QuotedValueList(rsCodes.companyCode)>
</cffunction>