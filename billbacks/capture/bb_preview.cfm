<!---
	Name: bb_preview.cfm
	Description: displays a cached copy of the billback.
	Copyright (c) 2006 Blacksmith Applications, Inc.
--->
<CFPARAM name="matchCENTRAL" type="boolean" default="false" />
<CFPARAM name="URL.FromFlex" default="0" />
<CFPARAM name="URL.byPassCache" default="0" />
<!---D40664 :: Settings page to show Deleted Billbacks --->
<CFPARAM name="URL.deleted_billback" default= "0"/>

<cfset labelSettings = Createobject("component", "mvc.Models.SettingsService") />
<cfset variables.VendorLabel = labelSettings.getBBLabels().vendor />

<cfif matchCENTRAL>
	<CFPARAM name="URL.BBID" default="#bbid#" />
	<CFSET Billback_ID = bbid>
<cfelse>
	<CFPARAM name="URL.BBID" default="0" />
	<CFSET Billback_ID=URL.BBID>
</cfif>
<CFSET url.show_email_version = 1 />
<CFSET sBillbackViewCacheFileName = "View_Billback_" & REREPLACE(Billback_ID,'-','_','ALL') & ".htm" />

<!--- F5 reload URL parameter exists - replace the cached file --->
<cfset temp = structKeyExists( URL, "_F5_Reload" )
				? false
				: fileexists("#Application.Doc_Path#\Temp_Files\Billback\#sBillbackViewCacheFileName#") />

<cfset baseFunctions = CreateObject("component", "components.Base") />

<!--- Dev Note: Milan - If the request is from flex, do not get the cached version --->
<cfif temp and URL.FromFlex eq 0 and URL.byPassCache eq 0>
	<cfsavecontent variable="content">
		<cfinclude template="#Application.Doc_Mapping#/Temp_Files/Billback/#sBillbackViewCacheFileName#" />
	</cfsavecontent>
<cfelse>
	<cfsavecontent variable="content">
		<cfinclude template="billback_summary_content.cfm"/>
	</cfsavecontent>
	<cflock timeout="10" type="exclusive">
		<cffile action="write" nameconflict="OVERWRITE" file="#Application.Doc_Path#\Temp_Files\Billback\#sBillbackViewCacheFileName#" output="<html>#content#</html>">
	</cflock>
</cfif>
<cfoutput>#baseFunctions.stripHTMLTag(content, "removeforemail")#</cfoutput>

<cfif not matchCENTRAL>
	<br>
	<div align="center">
	<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"close window"
			BUTTON_ACTION	=	"window.close();"
			BUTTON_TYPE		=	"javascript_link"
			BUTTON_WIDTH	=	"100"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">
	</div>
</cfif>