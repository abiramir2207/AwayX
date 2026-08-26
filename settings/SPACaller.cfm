<cfsilent><!--- 
##	SPA_Caller either displays "hide/show" of the current Settings panel Module
##	New Links added to the Settings_FramemainWindow should be inserted into the Settings_Panel_Access_Modules table.
##	Module = template name without the .cfm...if it is index:
##	for index.cfm -- go up one dir and add _index...ie. /GL_Code/Upload_Gl_Code/index.cfm = Upload_Gl_Code_index
##  This is the same value used to call this template
 --->
<!---  	<STYLE TYPE="text/css">
		...moved to settings frame mainwindowal1,al0, al2, al3, al4, tal1, tal2.....
</STYLE> ---></cfsilent>
<cfsavecontent variable="variables.longString">
<CFPARAM NAME="Attributes.module"	DEFAULT="x">
	<cfset acVar = "caller.getSPA."&Attributes.module>
	<cfif isdefined("#acVar#")>
		<cfset accessl = "#evaluate(acVar)#">
		<cfif caller.url.maint is 1>
				<cfoutput>
				<SELECT NAME="#Attributes.module#" STYLE="WIDTH: 60px;font-size: 10px;margin:5px;<cfif accessl eq 1>color:red;<cfelse>color:blue;</cfif>" onChange="changeClass(this,this.options[this.selectedIndex].className)">
					<OPTION VALUE="1" <cfif accessl eq 1>selected </cfif>>Show</OPTION>
					<OPTION VALUE="0" <cfif accessl eq 0>selected</cfif>>Hide</OPTION>
				</SELECT>
				</cfoutput>
		</cfif>
	</cfif>
</cfsavecontent>
<cfoutput>#application.util.string.compress( variables.longString )#</cfoutput>
