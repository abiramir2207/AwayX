
<!---
Document Name:	application_datasource.cfm
Directory:		Root
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	December 11, 2002

Description: This file should be included in application.cfm files in order to set one universal datasource for the entire application.  (And/or any other application-wide information.) 

PLEASE NOTE: In order for this to work correctly, you must name the application.  An example is below:

<CFAPPLICATION NAME="Chainlink" CLIENTMANAGEMENT="Yes" SESSIONMANAGEMENT="Yes">

Client management and session management are discretionary. The name is required.

--->
<CFAPPLICATION NAME="#hash( ExpandPath( "/" ) )#" SESSIONMANAGEMENT="Yes" CLIENTMANAGEMENT="Yes">
<CFPARAM NAME="Session.DoNotRunThisApplicationCFM" DEFAULT="0">

<!---Sets the datasource name for the application--->
<cfset application.datasource="Resers">

<cfinclude template="/Application_Vars.cfm"> 