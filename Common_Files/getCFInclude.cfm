<!---
  * ====================================================================================================
  *    @File: \Common_Files\getCFInclude.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2022 June 30
  *
  * @Remarks: Passing parameter must include the relative path of the include
  *             ( i.e. /common_files/contracts/layered_approval_include_t_js.cfm )
  *
  * ====================================================================================================
--->
<cfscript>
    param name="request.cfinclude" default=[];

    function getCFInclude( required string cfm ) output="true" hint="Pull and keeps track of CF included files used on a given page" {
        request.cfinclude.append( arguments.cfm );

        // pull in the passing relative path CFM file
        include arguments.cfm;
    }
</cfscript>
