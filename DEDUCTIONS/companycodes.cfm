<cffunction name="companyCodes" output="false" returntype="string" hint="Returns company codes for a deduction">
  <cfargument name="deduction_id" type="string" required="true" hint="">

  <cfscript>
    var rsCodes = "";
  </cfscript>
  
  <cfquery name="rsCodes" datasource="#application.datasource#">
    SELECT DISTINCT companyCode
      FROM (  
              SELECT BFC.Shr_Bill_To AS Companycode
                FROM Deductions DD
                LEFT JOIN Bsa_Foodservice_Customers BFC ON BFC.Bsa_Foodservice_Customers_Id = DD.Distributor_Id
               WHERE DD.Deduction_Id = <cfqueryparam value="#arguments.Deduction_Id#" cfsqltype="cf_sql_varchar">
           ) Codes
     WHERE companyCode IS NOT NULL AND LEN(LTRIM(RTRIM(companyCode))) > 0
  </cfquery>

  <cfreturn QuotedValueList(rsCodes.companyCode)>
</cffunction>