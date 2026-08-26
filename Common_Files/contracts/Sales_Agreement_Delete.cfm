<cf_cryp type="de" key="#request.key#" string = "#FORM.CID#">

<cfset deleteProgramId = cryp.value>

<cfset program = CreateObject("component", "components.export.Sales_Agreement") />

<cfset deleteSuccess = program.deleteSalesAgreement(deleteProgramId, request.AccessStructure.User_ID, request.AccessStructure.User_ID) />

<!------ unlock program ----->			
<cfset program.setLockStatus(deleteProgramId, 0)>
	
<cflocation url="/manufacturers/home.cfm">

