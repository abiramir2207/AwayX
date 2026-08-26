<cfcomponent hint="Fixed Component Rate">

	<cffunction Name="saveFixedPriceRate" access="public" output="false" returntype="array">
	  <!--- 27063 - CF 9 puts the passing Ajax array argument in position 2, CF 8 puts in position 1!!
	        Replaced the hard-coded of arguments[1] with a call to getArrayArgument() to find 
	        the array data needed to process --->
		<cfset var argArray = getArrayArgument( arguments ) />
		<cfset var rate			= '' />
		<cfset var uom 			= '' />
		<cfset var prodCompId 	= '' />
		
		<cfloop index="x" from="1" to="#arrayLen(argArray)#">
			<cfset rate			= argArray[x][1] />
			<cfset uom 			= argArray[x][2] />
			<cfset prodCompId 	= argArray[x][3] />
			<cfset competitorNameID 		= argArray[x][4] />
			<cfset competitorPrice 			= argArray[x][5] />
			<cfset competitorTimeFrame 		= argArray[x][6] />
			<cfset CompetitorSourceOther	= argArray[x][7] />
			<cfset Program_ID				= argArray[x][8] />
			
			<cfif trim(rate) eq ''>
				<cfset rate = 0 />
			</cfif>
			
			<!--- If competitiro name = other selected --->
			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUseFixedPriceType() and competitorNameID EQ -1>
				<!--- see if "other" record exists --->
				<cfset useLakebaseForgetOtherWonBy = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_won_by")>
<cfif useLakebaseForgetOtherWonBy>
	<cftry>
		<cfset getOtherWonBy = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_won_by", {
				"program_bid_won_by_description" = "eq.#CompetitorSourceOther#",
				"select" = "program_bid_won_by_description,program_bid_won_by_id"
			}), "program_bid_won_by_description,program_bid_won_by_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetOtherWonBy = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetOtherWonBy>
<cfquery name="getOtherWonBy" datasource="#application.datasource#">
					SELECT Program_Bid_Won_By_Description,Program_Bid_Won_By_ID
					FROM	Program_Bid_Won_By 
					WHERE Program_Bid_Won_By_Description = '#CompetitorSourceOther#' 
				</cfquery>
</cfif>
				<!--- Dont insert if it already exists --->
				<cfif getOtherWonBy.RecordCount>
					<cfset competitorNameID = getOtherWonBy.Program_Bid_Won_By_ID>	
				<cfelse>	
					<cfquery name="qInsertOther_Won_By" datasource="#application.datasource#">
						SET NOCOUNT ON
						INSERT INTO Program_Bid_Won_By
						(
							Program_Bid_Won_By_Code,
			            	Program_Bid_Won_By_Description,
			           		Active,
			            	Deleted,
			            	Updated_By
		            	)
						VALUES
						(
							#Program_ID#,
							'#CompetitorSourceOther#',
							0,
							0,
							'#request.AccessStructure.User_ID#'
						)
						SELECT Program_Bid_Won_By_ID = @@IDENTITY
						SET NOCOUNT OFF
					</cfquery>
					<cfset competitorNameID = qInsertOther_Won_By.Program_Bid_Won_By_ID>
				</cfif>
			</cfif>
			<cfquery name="qUpdFixedProduct" datasource="#application.datasource#">
				UPDATE	Program_Fixed_Price_Product_Data
				SET		Fixed_Price_Value = '#rate#',
						Unit_Of_Measure_ID = '#uom#'
						<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUseFixedPriceType()>
						,Competitor_Name_ID = '#Val(competitorNameID)#',
						Competitor_Price = '#Val(competitorPrice)#',
						Competitor_Time_Frame = '#competitorTimeFrame#'
						</cfif>
				WHERE	Program_Fixed_Price_Product_Data_ID = '#prodCompId#'	
			</cfquery>
		</cfloop>

		<cfreturn argArray />
	</cffunction>
	
  <cffunction name="getArrayArgument" output="false" hint="Returns the first array argument in the arguments structure.">
    <cfscript>
      var idx = 0;
      // search for array in the passing argument (note: arguments is an array of an array)
      for ( idx=1;  idx LTE ArrayLen(arguments[ 1 ]);  idx=idx+1 ) {
        // found the first array element, bail out
        if ( IsArray(arguments[ 1 ][ idx ]) ) {
          return arguments[ 1 ][ idx ];
        }
      }
      // no array is found in the passing argument structure, return a bizzare number
      return -1;
    </cfscript>
  </cffunction>	
   
</cfcomponent>