
<!---
Document Name:	application_datasource.cfm
Directory:		Root
Author:			Brenda Flynn
Date Created:	December 11, 2002

Mark S - 9/15/22 :: - application.datasource is set in /application.cfc where it is read from /Awayx.config
                    - Application_Vars.cfm checks for application.datasource and sets it if necessary from /Awayx.config since that file is included from other sub-application.cfc
                    - keeping both files since /application_datasource.cfm and /Application_Vars.cfm since they are each called as includes and want to minimize build dependencies
--->
<CFAPPLICATION NAME="#hash( ExpandPath( "/" ) )#" SESSIONMANAGEMENT="Yes" CLIENTMANAGEMENT="Yes">
<cfinclude template="/Application_Vars.cfm"> 