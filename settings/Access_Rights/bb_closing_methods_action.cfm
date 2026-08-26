<!-----      
		Name: 			bb_closing_methods.cfm     
               			Copyright (c) 2011 Blacksmith Applications, Inc.
		Created:
						07/18/2011
						Dinesh Rachala
		Last Modified:
						07/18/2011   
						Dinesh Rachala  
		Description:
                       This page allows administrators to view and edit the list of BillBack Closing Methods each profile can approve
					   Will be called from inside the profile settings section.
		Parameters:
                       profileId - ID of the the current profile that is getting edited
		Usage:
                       bb_closing_methods.cfm?profileId=6
----->


  <cfquery name="deleteBBCM" datasource="#application.datasource#">
  	  UPDATE BB_Profile_Closing_Methods 
	  SET Deleted = 1
	  WHERE Profile_ID = #trim(form.profileId)#
  </cfquery>

<cfloop from="1"to="#form.count#"index="BCMID">
	<cfif structKeyExists(form,"BillBackClosingMethodList#BCMID#")>
     <cfset closing_method_id = evaluate("form.BillBackClosingMethodList" & BCMID)>
     <cfquery name="INSERTBPCM" datasource="#application.datasource#">
         insert into BB_Profile_Closing_Methods (Profile_ID, Billback_Closing_Method_ID)
        values (#trim(form.profileId)#, #closing_method_id#)
    </cfquery>
	</cfif>
</cfloop>

<cfquery name="UpdateGeneralInformation" datasource="#application.datasource#">
		UPDATE Profiles_Settings
		SET Last_Changed_Date		= getdate(),
		    Last_Changed_User_ID	= '#request.accessStructure.User_ID#'		
</cfquery>

<script language="JavaScript">
self.close();
</script>