<!----
	Filename:	GL_Code/Vendor_Management/index.cfm
	Created:	10/25/2011
 	Developer:	drachala        
	Copyright (c) 2006 Blacksmith Applications, Inc.                    
	Description:
		Use this as main Vendor mangement.
---->
<!--- Dev Note: drachala; D28955: vendor table in settings  START
Added/Changed: Create this file as main file with two tabs--->
<cfset variables.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<CFSET URL.PageTitle="PAYABLES: Vendor MANAGEMENT">
<cfparam name="form.tabvalue" default="">
<cfparam name="url.tabvalue" default="listvendorxref">
<cfif len(form.tabvalue)>
	<cfset url.tabvalue = #form.tabvalue#>
</cfif>

<cfset selectedIndex = (url.tabvalue eq "listvendormaster" ? 1 : 0)>

<cfmodule template="/customTags/layout.cfm" 
							layoutID = "vendorManagement" 
							selectedIndex = "#selectedIndex#" >

<FORM NAME="SearchForm" ACTION="index.cfm" METHOD="POST" id="SearchForm">
   <cfswitch expression="#url.tabvalue#">    
    	<cfcase value="listvendormaster">    
		   <cfinclude template="Vendor_Master_Search_from_settings.cfm">
    	</cfcase> 
    	<DIV ALIGN="center" style="width: 1100px;">
    	<cfdefaultcase>
			<br><br>
			<cfinclude template="vendor_form.cfm">
		</cfdefaultcase>   
		 </DIV>
    </cfswitch>
</FORM>
</cfmodule>