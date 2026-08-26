<cfcomponent  name="AppProxy" hint="extend base Application.cfc" extends="Application" output="false">
	<!--- extends="/Application.cfc
				- This is needed in order for other Application.cfc files in other directories to extend The Base application.cfc
				- They can then inherit all of the application settings and then override specific ones like onRequestStart() in order to modify access rights
					- \components\Interfaces\Service\Application.cfc
					- \mvc\Models\Application.cfc
					- \contracts\ajax\Application.cfc
					- \support\Application.cfc
					- \billbacks\OCR_Upload\Scheduled\Application.cfc
					- \Scheduled\Application.cfc
	 --->
</cfcomponent>