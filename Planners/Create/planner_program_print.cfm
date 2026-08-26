<!---------------------------------------------------------------------------------------------------------------------
Template:	/Planners/Create/planner_program_view.cfm
Date:  		11/02/2016
Author:		Tim Ford
Purpose:  	Single Page Planner Program View
----------------------------------------------------------------------------------------------------------------------->
<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm"> 
<cfsavecontent variable="variables.content">

	<cfinclude template="planner_program_view.cfm" />

</cfsavecontent>

<cfoutput>#variables.content#</cfoutput>
