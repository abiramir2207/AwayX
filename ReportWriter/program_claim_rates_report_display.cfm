<cfscript>
	vars = {};
	vars.claimRateCFC = createObject("component", "components.programs.ClaimRates");
  vars.claimRateColumns = vars.claimRateCFC.getClaimRatesColumns( form.report_config_id );
  vars.columnNames = application.util.array.arrayofStructsToList(arry=vars.claimRateColumns, key="name", returnas="array");
  vars.clause = vars.claimRateCFC.getClause( form.report_config_id );

  csvStr = createObject("java", "java.lang.StringBuffer");
  // column header
  csvStr.append( application.util.array.arrayofStructsToList(arry=vars.claimRateColumns, key="label") );
	csvStr.append(Chr(13) & Chr(10));
</cfscript>

<cfloop query="qProgramClaimRatesReport">
	<cfloop array="#vars.columnNames#" index="vars.column">
		<cfset vars.columnValue = qProgramClaimRatesReport[ vars.column ][ qProgramClaimRatesReport.currentRow ]>
		
		<cfif isDate( vars.columnValue ) AND findNoCase('date', vars.column)>
			<cfset csvStr.append(dateFormat(vars.columnValue, 'm/d/yyyy') & ",")>
		<cfelseif isNumeric( vars.columnValue )>
			<cfset csvStr.append('= "' & vars.columnValue & '",')>
		<cfelse>
			<cfset csvStr.append(vars.columnValue & ",")>
		</cfif>
	</cfloop>

	<cfset csvStr.append(Chr(13) & Chr(10))>
</cfloop>

<!--- Output the report --->
<CFOUTPUT>#csvStr.toString()#</CFOUTPUT>