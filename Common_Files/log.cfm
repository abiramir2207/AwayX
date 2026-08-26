<!---
  * ==================================================================================================== 
  *    @File: \common_files\log.cfm
  *  @Author: Chris Nguyen
  *    @Date: December 2020
  * 
  * @Remarks: JavaScript Logging functions, default to enabled for web developers
  *
  * ==================================================================================================== 
--->
<cf_include files="/script/javascript/loglevel/1.6.8/loglevel.min.js">

<!--- enable logging for web developers, other users would not see debug logging on their browser console --->
<cfif structKeyExists(request, "is_developer") and request.is_developer>
    <script>   
        log.enableAll();
    </script>
</cfif>


