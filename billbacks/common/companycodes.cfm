<cffunction name="companyCodes" output="false" returntype="string" hint="Returns company codes for a billback">
  <cfargument name="Billback_ID" type="string" required="true" hint="">

  <cfscript>
    var thisPayeeObj = CreateObject("component", "components.Billback.BillbackSummaryManager").init(arguments.Billback_ID);
    var payeeInfo    = thisPayeeObj.getPayeeInfo();
    var rsCodes      = 0;
  </cfscript>

  <!---filter out empty code--->
  <cfquery name="rsCodes" dbtype="query">
    SELECT Payee_Shipto AS companyCode
      FROM payeeInfo
     WHERE Payee_Shipto IS NOT NULL AND Payee_Shipto > ''
  </cfquery>
  
  <cfreturn QuotedValueList(rsCodes.companyCode)>
</cffunction>