

<!--------------------------------------------------------------------------------
Get payee Info
--------------------------------------------------------------------------------->
<cfquery name="Get_Payee_Info" datasource="#application.datasource#">
	SELECT	 bb.Billback_Payee_Type_ID 
		-------------------------State
		,CASE
		WHEN bb.Billback_Payee_Type_ID=1 THEN		
			CAST(IsNull(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,Vendor_Master.Vendor_Master_ID) AS NVARCHAR(50))
		
		WHEN bb.Billback_Payee_Type_ID=2 THEN
			CAST(BSA_Operator.BSA_Operator_ID AS NVARCHAR(50))
		
		WHEN bb.Billback_Payee_Type_ID=3 THEN	
			CAST(BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID AS NVARCHAR(50))
		ELSE
			NULL		
		END AS Payee_ID,
		CASE
		WHEN bb.Billback_Payee_Type_ID=1 THEN		
			IsNull(BSA_Foodservice_Customers.Shr_Ship_To,Vendor_Master.Vendor_ID)		
		WHEN bb.Billback_Payee_Type_ID=2 THEN
			BSA_Operator.Legacy_ID		
		WHEN bb.Billback_Payee_Type_ID=3 THEN	
			BSA_Foodservice_Brokers.Broker_Legcy_Shard
		ELSE
			NULL		
		END AS Payee_Number

		<!--- The billback may have an associated distributor when the payee is an operator OR broker. --->
		,CASE bb.Billback_Payee_Type_ID
			WHEN 2
				THEN 
					Billback_Operator.Associated_Ship_to
			WHEN 3
				THEN				
					Billback_Broker.Associated_Ship_to

			ELSE	
				NULL

			END

		As Associated_Ship_to

		FROM	
		Billback bb
		----------------------------------------------------
		LEFT JOIN	
			(
			Billback_Broker
			LEFT JOIN
			BSA_Foodservice_Brokers
			ON
			(Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)
			)
		ON
		(
		(Billback_Broker.Billback_ID = bb.Billback_ID)
		AND
		(
			(bb.Billback_Payee_Type_ID = 3)
			OR
			(bb.Billback_Payee_Type_ID = 7)
		)
		AND
		(Billback_Broker.Deleted = 0)
		)
		----------------------------------------------------				
		LEFT JOIN	
			(
			Billback_Distributor
			LEFT JOIN 
			BSA_Foodservice_Customers
			ON 
			(Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID)
			)
		ON
		(
		(Billback_Distributor.Billback_ID = bb.Billback_ID)
		AND
		(
			(bb.Billback_Payee_Type_ID = 1)
			OR
			(bb.Billback_Payee_Type_ID = 5)
		)
		AND
		(Billback_Distributor.Deleted = 0)
		)
		
		----------------------------------------------------				
		LEFT JOIN	
			(
			Billback_Operator
			LEFT JOIN
			BSA_Operator
			ON
			(Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID)
			)
		ON
		(
		(Billback_Operator.Billback_ID = bb.Billback_ID)
		AND
		(
			(bb.Billback_Payee_Type_ID = 2)
			OR
			(bb.Billback_Payee_Type_ID = 6)
		)
		AND
		(Billback_Operator.Deleted = 0)				
		)
		LEFT JOIN Vendor_Master
		ON 
		Vendor_Master.Vendor_Master_ID = Billback_Distributor.Distributor_ID
		WHERE
		bb.Deleted = 0				
		AND
		(
			(bb.Billback_Payee_Type_ID = 1 AND Billback_Distributor.Billback_Distributor_ID IS NOT NULL)
			OR
			(bb.Billback_Payee_Type_ID = 2 AND Billback_Operator.Billback_Operator_ID IS NOT NULL)
			OR
			(bb.Billback_Payee_Type_ID = 3 AND Billback_Broker.Billback_Broker_ID IS NOT NULL)
			OR
			(bb.Billback_Payee_Type_ID >= 4)
		)
		AND
		bb.Billback_ID = '#Billback_ID#'
	</cfquery>

<CFSET Billback_Payee_Type_ID = Get_Payee_Info.Billback_Payee_Type_ID>
<CFSET Payee_ID = Get_Payee_Info.Payee_ID>
<CFSET Payee_Number = Get_Payee_Info.Payee_Number>
<CFSET Associated_Ship_To = Get_Payee_Info.Associated_Ship_To>

<cfif Billback_Payee_Type_ID EQ 4><!------ If Payee = Other ----->
	<cfif NOT isDefined("bbDeviationManager")>
		<cfset bbDeviationManager = CreateObject("component", "components.billback.BillbackDeviationManager").init() />
	</cfif>
	<cfset Get_Dist_ID = bbDeviationManager.getBillbackDistributor(Billback_ID, Billback_Payee_Type_ID)>
	<cfif Get_Dist_ID.BSA_Foodservice_Customers_ID NEQ "">
		<CFSET Payee_ID = Get_Dist_ID.BSA_Foodservice_Customers_ID>
		<CFSET Billback_Payee_Type_ID = 1>
	</cfif>
</cfif>
