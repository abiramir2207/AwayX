<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Gets the profile of the current user from the Access WDDX package								 --->
<!--- And checks it again the profile settings table												 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Get the Profile settings for the current user --->

<cfset profile = CreateObject("component","components.user.Profile").init() />
<cfset Get_Profile_Settings = profile.getProfileSettings(request.AccessStructure.Profiles_ID)>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- For debugging purposes out put this code. It lists all of the access rights and permissions    --->
<!--- <CFLOOP INDEX="Item" LIST="#Get_Profile_Settings.columnlist#"><CFOUTPUT>#item#</CFOUTPUT>:<CFOUTPUT>#evaluate('Get_Profile_Settings.'&'#item#')#</CFOUTPUT><BR></CFLOOP> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- MVC v11 EXAMPLE [begin]
<cfset application.oController.getObject("components.user.Profile").init() />
<cfset Get_Profile_Settings = application.oProfile.getProfileSettings(request.AccessStructure.Profiles_ID)>

<cfdump var="#application.stMVCAppInfo.aCreatedObjects#" label="application.stMVCAppInfo.aCreatedObjects" expand="no">
<cfdump var="#application.stMVCAppInfo.aKilledObjects#" label="application.stMVCAppInfo.aKilledObjects" expand="no">

<cfset application.oController.getObject(bReload=1,path="components.user.Profile").init() />

<cfdump var="#application.stMVCAppInfo.aCreatedObjects#" label="application.stMVCAppInfo.aCreatedObjects" expand="no">
<cfdump var="#application.stMVCAppInfo.aKilledObjects#" label="application.stMVCAppInfo.aKilledObjects" expand="no">
MVC v11 EXAMPLE [end] --->