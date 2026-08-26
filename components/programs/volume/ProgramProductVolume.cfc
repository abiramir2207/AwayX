<!------ ProgramProductVolume.cfc 
components.programs.volume.ProgramProductVolume
----->
<cfcomponent displayname="Program Product Volume" hint="Product Volume for a specific program">

	<cfset this.id = 0 />
	<cfset this.programId = 0 />
	<cfset this.itemMasterId = "" />
	<cfset this.volumeLB = 0 />
	<cfset this.volumeCS = 0 />
	<cfset this.multiplier = "" />
	<cfset this.volume = 0 />
	
	<cffunction name="init" output="false" returntype="components.programs.volume.ProgramProductVolume">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- id setter --->
	<cffunction name="setId" access="public" output="false">
		<cfargument name="id" required="true" default="" />
		<cfset this.id = arguments.id />
	</cffunction>
	<!--- id getter --->
	<cffunction name="getId" access="public" output="false">
		<cfreturn this.id />
	</cffunction>
	
	<!--- programId setter --->
	<cffunction name="setProgramId" access="public" output="false">
		<cfargument name="programId" required="true" default="" />
		<cfset this.programId = arguments.programId />
	</cffunction>
	<!--- programId getter --->
	<cffunction name="getProgramId" access="public" output="false">
		<cfreturn this.programId />
	</cffunction>
	
	<!--- itemMasterId setter --->
	<cffunction name="setItemMasterId" access="public" output="false">
		<cfargument name="itemMasterId" required="true" default="" />
		<cfset this.itemMasterId = arguments.itemMasterId />
	</cffunction>
	<!--- itemMasterId getter --->
	<cffunction access="public" name="getItemMasterId" output="false">
		<cfreturn this.itemMasterId />
	</cffunction>
	
	<!--- volumeLB setter --->
	<cffunction name="setVolumeLB" access="public" output="false">
		<cfargument name="volumeLB" required="true" default="" />
		<cfset this.volumeLB = arguments.volumeLB />
	</cffunction>
	<!--- volumeLB getter --->
	<cffunction  name="getVolumeLB" access="public" output="false">
		<cfreturn this.volumeLB />
	</cffunction>
	
	<!--- volumeCS setter --->
	<cffunction name="setVolumeCS" access="public" output="false">
		<cfargument name="volumeCS" required="true" default="" />
		<cfset this.volumeCS = arguments.volumeCS />
	</cffunction>
	<!--- volumeCS getter --->
	<cffunction name="getVolumeCS" access="public" output="false">
		<cfreturn this.volumeCS />
	</cffunction>
	
	<!--- multiplier setter --->
	<cffunction name="setMultiplier" access="public" output="false">
		<cfargument name="multiplier" required="true" default="" />
		<cfset this.multiplier = arguments.multiplier />
	</cffunction>
	<!--- multiplier getter --->
	<cffunction name="getMultiplier" access="public" output="false">
		<cfreturn this.multiplier />
	</cffunction>
	
	<!--- volume setter --->
	<cffunction name="setVolume" access="public" output="false">
		<cfargument name="volume" required="true" default="" />
		<cfset this.volume = arguments.volume />
	</cffunction>
	<!--- volume getter --->
	<cffunction name="getVolume" access="public" output="false">
		<cfreturn this.volume />
	</cffunction>
	
</cfcomponent>