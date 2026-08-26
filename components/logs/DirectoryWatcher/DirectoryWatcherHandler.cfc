<cfcomponent hint="Handles the calls from Directory Watcher Gateway" output="false" >


	<cffunction name="onAdd" output="no" access="remote">
		<cfargument name="CFEvent" type="struct" required="yes" />
		<cfset var data=CFEvent.data />
		<cflog file="MyDirWatcher" application="No" text="ACTION: #data.type#; FILE: #data.filename#; TIME: #timeFormat(data.lastmodified)#" />

		<cffile action="move" 
				source="#data.filename#"
				destination = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_Doc\" />
		
	</cffunction>


	<cffunction name="onDelete" output="no" access="remote">
		<cfargument name="CFEvent" type="struct" required="yes" />
		<cfset data=CFEvent.data />
		<cflog file="MyDirWatcher" application="No" text=" ACTION: #data.type#; FILE: #data.filename#" />
	</cffunction>


	<cffunction name="onChange" output="no" access="remote">
		<cfargument name="CFEvent" type="struct" required="yes" />
		<cfset data=CFEvent.data />
		<cflog file="MyDirWatcher" application="No" text=" ACTION: #data.type#; FILE: #data.filename#; TIME: #timeFormat(data.lastmodified)#" />
	</cffunction>


</cfcomponent>
