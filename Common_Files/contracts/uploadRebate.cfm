<cffile action="upload" destination="#expandpath('./upload')#" nameconflict="makeunique"> <cfoutput>#serializeJSON({STATUS=200,MESSAGE='Passed'})#</cfoutput>

