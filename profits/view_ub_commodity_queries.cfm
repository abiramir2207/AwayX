<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the Urner Barry commodity data --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_UB_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("urner_barry_symbols")>
<cfif useLakebaseForGet_UB_Data>
	<cftry>
		<cfset Get_UB_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("urner_barry_symbols", {
				"ub_symbol" = "eq.#URL.ub_symbol#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_UB_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_UB_Data>
<CFQUERY NAME="Get_UB_Data" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(24, 0, 0, 0)#">
Select	*	from	Urner_Barry_Symbols where ub_symbol	=	#URL.ub_symbol#
</CFQUERY>
</cfif>
