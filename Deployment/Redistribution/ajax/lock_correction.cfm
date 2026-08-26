<cfsetting enablecfoutputonly="true">
<cfsetting showDebugOutput="no">
<!---
  * ==================================================================================================== 
  *    @File: Deployment\Redistribution\ajax\lock_correction.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2019 June
  * 
  * @Remarks: Lock a correction, returns a "success" string or locked by message
  *  
  * ==================================================================================================== 
--->
<cfset return_status = 'unknown'>

<cfif form.mode eq "unlock_all">

    <!--- release all selected locks from current user --->
    <cfquery datasource="#application.datasource#">
        UPDATE REDI_EC_Header
            SET Locked = 0
                ,User_Id_Locked = NULL
                ,Locked_Date = getDate()
        WHERE User_Id_Locked = '#request.AccessStructure.User_ID#'
    </cfquery>
    <cfset return_status = 'success'>

<cfelse>

    <!--- get current lock status --->
    <cfquery name="qLock" datasource="#application.datasource#">
        SELECT  Locked,
                User_Id_Locked,
                u.Name_First + ' ' + u.Name_Last AS Locked_By
        <!--- is it locked by other users? --->
         FROM REDI_EC_HEADER
                LEFT JOIN _Users u ON u.User_ID = User_Id_Locked
        WHERE REDI_EC_Header_id = <cfoutput>#form.header_primary_key#</cfoutput>
    </cfquery>

    <!--- attempt to lock for editing --->
    <cfif form.mode eq "editing">

        <cfif qLock.recordCount 
            and qLock.Locked
            and qLock.User_Id_Locked neq ''
            and qLock.User_Id_Locked neq '#request.AccessStructure.User_ID#'>
            <!--- return locked user name to indicate a problem --->
            <cfset return_status = form.header_primary_key & " is currently locked by " & qLock.Locked_by & ".<br>Please try this option again later.">
        <cfelse>
            <!--- update lock status in database --->
            <cfquery datasource="#application.datasource#">
                UPDATE REDI_EC_Header
                    SET Locked = 1
                        ,User_Id_Locked = '#request.AccessStructure.User_ID#'
                        ,Locked_Date = getDate()
                WHERE REDI_EC_Header_id = #form.header_primary_key#
            </cfquery>
            <cfset return_status = 'success'>
        </cfif>     <!--- qLock.recordCount  --->

    <!--- release lock to read only mode --->
    <cfelse>        <!--- form.mode eq "editing" --->

        <!--- when record is not locked --->
        <cfif qLock.recordCount and not qLock.Locked>
            <!--- do nothing --->
            <cfset return_status = 'success'>
        <cfelse>
            <!--- release lock status in database --->
            <cfquery datasource="#application.datasource#">
                UPDATE REDI_EC_Header
                    SET Locked = 0
                        ,User_Id_Locked = NULL
                        ,Locked_Date = getDate()
                WHERE REDI_EC_Header_id = #form.header_primary_key#
            </cfquery>
            <cfset return_status = 'success'>
        </cfif>     <!--- qLock.recordCount and not qLock.Locked --->

    </cfif>     <!--- form.mode eq "editing" --->

</cfif>     <!--- form.mode eq "unlock_all" --->
<!--- return locking status --->
<cfoutput>#return_status#</cfoutput>