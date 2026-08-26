<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Get Program - Product - Rule Information
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<!--- 
	<CFSET release_Date=Now()>
	<CFSET Program_ID = 1015> 
--->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Get Overage Information for thid Program - TO be used later for each Rule ID
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFQUERY datasource="#application.datasource#" NAME="Overage_Data">
	SELECT			Program_Formula_Pricing_Rule_Overage.Program_Formula_Pricing_Rule_ID, Overage_Index, Amount, UOM, Calc_Type,
					Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID
	FROM			Program_Formula_Pricing_Rule_Overage
					INNER JOIN Formula_Pricing_Rule
					ON
					Formula_Pricing_Rule.Formula_Pricing_Rule_ID = Program_Formula_Pricing_Rule_Overage.Program_Formula_Pricing_Rule_ID
					--AND
					--Formula_Pricing_Rule.Deleted = 0
					INNER JOIN Program_Formula_Pricing_Rule_Mapped
					ON
					Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID = Formula_Pricing_Rule.Formula_Pricing_Rule_ID
					AND
					Program_Formula_Pricing_Rule_Mapped.Deleted = 0
					AND
					Program_Formula_Pricing_Rule_Mapped.Program_ID = #Program_ID#
	WHERE	
					Program_Formula_Pricing_Rule_Overage.Active 	= 1
			AND		Program_Formula_Pricing_Rule_Overage.Deleted = 0
	ORDER BY		Program_Formula_Pricing_Rule_Overage.Program_Formula_Pricing_Rule_ID, Program_Formula_Pricing_Rule_Overage.Overage_Index
</CFQUERY>


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Get Commodity information for all the rules in this program
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFQUERY datasource="#application.datasource#" NAME="Commodity_Data">
	SELECT			Program_Formula_Pricing_Rule_Comm_Data.Program_Formula_Pricing_Rule_Comm_Data_ID, Program_Formula_Pricing_Rule_Comm_Data.Program_Formula_Pricing_Rule_ID, Program_Formula_Pricing_Rule_Comm_Data.Symbol, Program_Formula_Pricing_Rule_Comm_Data.Point_In_Time, Program_Formula_Pricing_Rule_Comm_Data.Point_In_Time_UOM, Program_Formula_Pricing_Rule_Comm_Data.Sample_Size, Program_Formula_Pricing_Rule_Comm_Data.Sample_Size_UOM, Program_Formula_Pricing_Rule_Comm_Data.Weight,
					Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID
	FROM
					Program_Formula_Pricing_Rule_Comm_Data
					INNER JOIN Formula_Pricing_Rule
					ON
					Formula_Pricing_Rule.Formula_Pricing_Rule_ID = Program_Formula_Pricing_Rule_Comm_Data.Program_Formula_Pricing_Rule_ID
					--AND
					--Formula_Pricing_Rule.Deleted = 0
					INNER JOIN Program_Formula_Pricing_Rule_Mapped
					ON
					Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID = Formula_Pricing_Rule.Formula_Pricing_Rule_ID
					AND
					Program_Formula_Pricing_Rule_Mapped.Deleted = 0
					AND
					Program_Formula_Pricing_Rule_Mapped.Program_ID = #Program_ID#
	WHERE
					Program_Formula_Pricing_Rule_Comm_Data.Deleted	=	0
			AND		Program_Formula_Pricing_Rule_Comm_Data.Active	=	1
	ORDER BY	Program_Formula_Pricing_Rule_Comm_Data.Program_Formula_Pricing_Rule_ID
</CFQUERY>

<CFSET SubTotal_Weighted_Cost = 0>
<CFSET adjusted_today = release_Date> 


<CFOUTPUT QUERY="Commodity_Data" GROUP="Program_Formula_Pricing_Rule_ID">	
	<CFSET Proper_Commodity = 1>
	<CFSET SubTotal_Weighted_Cost=0>
	<CFQUERY NAME="Get_All_Commodity_Overage" DATASOURCE="#application.datasource#">
		SELECT	*
		FROM	Formula_Pricing_Commodity_Overage
		WHERE
				Program_Formula_Pricing_Rule_ID = '#Program_Formula_Pricing_Rule_ID#' AND
				Deleted = 0
	</CFQUERY>
	<CFOUTPUT GROUP="Program_Formula_Pricing_Rule_Comm_Data_ID">		
		<CFSET comm_symbol = Commodity_Data.Symbol>
		<CFSET comm_avg = "">
	
		<!--- calculate the size/number of data points of the sample  --->
		<CFIF Commodity_Data.Sample_Size_UOM EQ "weeks">
			<!--- set the number of days/data points lag --->
			<CFSET sample_lag=Commodity_Data.Point_In_Time*7>
			
			<!--- find the last friday --->
			<CFSET LAST_FRIDAY = #DATEADD("d", -DAYOFWEEK(adjusted_today)+6-7, adjusted_today)#>
			
			<!--- start date = last friday minus the lag number of days --->
			<CFSET startdate=createodbcdate(last_friday-sample_lag)>
		
			<CFSET C_sample_size=Commodity_data.Sample_Size*7>
			<!--- the begining of the sample period is the startdate variable --->
			<!--- the end of the sample period is the startdate minus the size of the sample plus 3  --->
			<!--- so that the period really ends on the monday: first day of the last week --->
			<CFSET enddate=createodbcdate(startdate - C_sample_size + 3)>
			
			<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
			<!------Get Commodity Value from database----->
			<!------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
			<CFIF DateDiff("d", startdate, Now()) GTE 0>
			<CFSTOREDPROC PROCEDURE="AVG_COMM_LAST" datasource="#application.datasource#">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@@C_SYMBOL"		VALUE="#comm_symbol#">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_TIMESTAMP"	DBVARNAME="@@C_MIN_Date"	VALUE="#enddate#">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_TIMESTAMP"	DBVARNAME="@@C_MAX_Date"	VALUE="#startdate#">
				<CFPROCPARAM TYPE="Out" CFSQLTYPE="CF_SQL_FLOAT"	DBVARNAME="@@COMM_AVG"		VARIABLE="comm_avg">
			</CFSTOREDPROC>
			</CFIF>
		<CFELSE>
			<CFSET sample_lag=Commodity_Data.Point_In_Time>
			<CFSET C_sample_size=Commodity_data.Sample_Size>
			<CFSET startdate=adjusted_today>
			
			<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
			<!------Get Commodity Value from database----->
			<!------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
			<CFIF DateDiff("d", startdate, Now()) GTE 0>
			<CFSTOREDPROC PROCEDURE="AVG_TRADE_COMM_LAST" datasource="#application.datasource#">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@@C_SYMBOL"		VALUE="#comm_symbol#">			
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_TIMESTAMP"	DBVARNAME="@@C_MAX_Date"	VALUE="#startdate#">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@@C_MIN"			VALUE="#sample_lag#">
				<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@@SAMPLE"		VALUE="#C_sample_size#">
				<CFPROCPARAM TYPE="Out" CFSQLTYPE="CF_SQL_FLOAT"	DBVARNAME="@@COMM_AVG"		VARIABLE="comm_avg">
			</CFSTOREDPROC>
			</CFIF>
		</CFIF>

		<CFIF NOT IsNumeric(comm_avg)>
			<CFSET Fully_loaded=0>
			<CFSET Proper_Commodity = 0>
		<CFELSE>
			<CFSET Fully_loaded=comm_avg>
		</CFIF>
		
		<CFSET Fully_loaded_First = Fully_loaded>
		<!------------ add overages ------------------>
		<!------ Commodity level Compunded Calculations Overage calculations----->
		<CFQUERY NAME="This_Overage_Data" DBTYPE="Query">
			SELECT			Overage_Index, Amount, UOM, Description, Calc_Type
			FROM			Get_All_Commodity_Overage
			WHERE	
							Program_Formula_Pricing_Rule_Comm_Data_ID = '#Program_Formula_Pricing_Rule_Comm_Data_ID#'
							AND
							Calc_Type = 2
							And Deleted = 0
			ORDER BY		Overage_Index
		</CFQUERY>
		<CFLOOP QUERY="This_Overage_Data">
			<CFIF UOM EQ "%">
				<CFIF Calc_Type EQ 1><!---- independent --->
					<CFSET Operation_Against = Fully_loaded_First>
				<CFELSE><!---- componded ---->
					<CFSET Operation_Against = Fully_loaded>				
				</CFIF>
				<CFSET thisAvearage = (Operation_Against * Amount)/100>
			<CFELSE>
				<CFSET thisAvearage = Amount>				
			</CFIF>
			<CFSET Fully_loaded = Fully_loaded + thisAvearage>
		</CFLOOP>
		
		<!------ Independent level Compunded Calculations Overage calculations----->
		<CFQUERY NAME="This_Overage_Data" DBTYPE="Query">
			SELECT			Overage_Index, Amount, UOM, Description, Calc_Type
			FROM			Get_All_Commodity_Overage
			WHERE	
							Program_Formula_Pricing_Rule_Comm_Data_ID = '#Program_Formula_Pricing_Rule_Comm_Data_ID#'
							AND
							Calc_Type = 1
							And Deleted = 0
			ORDER BY		Overage_Index
		</CFQUERY>
		<CFLOOP QUERY="This_Overage_Data">
			<CFIF UOM EQ "%">
				<CFIF Calc_Type EQ 1><!---- independent --->
					<CFSET Operation_Against = Fully_loaded_First>
				<CFELSE><!---- componded ---->
					<CFSET Operation_Against = Fully_loaded>				
				</CFIF>
				<CFSET thisAvearage = (Operation_Against * Amount)/100>
			<CFELSE>
				<CFSET thisAvearage = Amount>				
			</CFIF>
			<CFSET Fully_loaded = Fully_loaded + thisAvearage>
		</CFLOOP>
		
		<CFSET Weighted_Cost=Fully_loaded*(Commodity_Data.Weight/100)>
		<CFSET SubTotal_Weighted_Cost=SubTotal_Weighted_Cost + Weighted_Cost>
		
	</CFOUTPUT>
	<CFSET Rule_ID=Commodity_Data.Program_Formula_Pricing_Rule_ID>

	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx----->
	<!------Overage calculations (compounded) ----->
	<!------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx----->
	<CFQUERY NAME="This_Overage_Data" DBTYPE="Query">
		SELECT			Overage_Index, Amount, UOM
		FROM			Overage_Data
		WHERE	
						Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
						AND
						Calc_Type = 2
		ORDER BY		Overage_Index
	</CFQUERY>

	<CFSET total_Overage_Compounded = 0>
	<CFLOOP QUERY="This_Overage_Data">	
		<CFIF This_Overage_Data.UOM EQ "%">
			<CFSET total_Overage_Compounded = total_Overage_Compounded + ((total_Overage_Compounded + SubTotal_Weighted_Cost) * This_Overage_Data.Amount)/100>
		<CFELSEIF  This_Overage_Data.UOM EQ "$">
			<CFSET total_Overage_Compounded = total_Overage_Compounded + This_Overage_Data.Amount>
		</CFIF>	
	</CFLOOP>
	
	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx----->
	<!------Overage calculations----->
	<!------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx----->
	<CFQUERY NAME="This_Overage_Data" DBTYPE="Query">
		SELECT			Overage_Index, Amount, UOM
		FROM			Overage_Data
		WHERE	
						Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
						AND
						Calc_Type = 1
		ORDER BY		Overage_Index
	</CFQUERY>

	<CFSET total_Overage = 0>
	<CFLOOP QUERY="This_Overage_Data">	
		<CFIF This_Overage_Data.UOM EQ "%">
			<CFSET total_Overage = total_Overage + (SubTotal_Weighted_Cost * This_Overage_Data.Amount)/100>
		<CFELSEIF  This_Overage_Data.UOM EQ "$">
			<CFSET total_Overage = total_Overage + This_Overage_Data.Amount>
		</CFIF>	
	</CFLOOP>

	<CFSET Grand_Total = SubTotal_Weighted_Cost + total_Overage + total_Overage_Compounded>

	<!------<FIELDSET STYLE="padding:5px; width: 100%; border: 1px solid Silver;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Commodity Formula Cost</LEGEND>
		<BLOCKQUOTE>
			<FONT SIZE="3">
			Commodity formula value of #release_Date#
			is <B><U>$#numberformat(Grand_Total, '_,___._________')#</U></B> </FONT>		
		</BLOCKQUOTE>
	</FIELDSET>----->
	
	<!------ Update new calculated value to the database----->
	<CFQUERY datasource="#application.datasource#" NAME="Update_Product_Price">
		UPDATE		Program_Formula_Pricing_Rule_Products
		SET			Price = 
		<CFIF Proper_Commodity EQ 1>
		CASE	
			WHEN Unit_Of_Measure_ID = 3 THEN
				#Grand_Total# + (#Grand_Total# * (Program_Formula_Pricing_Rule_Products.Product_Overage / 100.00))
			ELSE
				#Grand_Total# + Program_Formula_Pricing_Rule_Products.Product_Overage
		END
		<CFELSE>0</CFIF>
		WHERE		
					Program_Formula_Pricing_Rule_ID = '#Commodity_Data.Program_Formula_Pricing_Rule_Mapped_ID#'
			AND		Deleted	=	0
			AND 	Active	=	1
	</CFQUERY>

</CFOUTPUT>
