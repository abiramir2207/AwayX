<!------
Validation_Req.cfm
----->

	<cfinclude template="/get_access_profile.cfm">

	<CFIF Get_Profile_Settings.BB_View_Deviation NEQ 1>
		<CFLOCATION URL="Billback_Summary.cfm" ADDTOKEN="No">
	</CFIF>
	
	
	<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Amount_Match">
		SELECT	CONVERT(Char(10),Billback.Deviation_Ran_Date,101) Deviation_Ran_Date, Billback.Deviation_Ran_By, _Users.Name_First + ' '+ _Users.Name_Last Ran_By,
		Billback.BB_Amount, 
		-----------------Total Amount claimed for this program
		(IsNUll((SELECT	SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT))
		FROM	Billback_Program
			INNER JOIN	Billback_Product
			ON
			(   (Billback_Product.Billback_ID = '#Billback_ID#') 
				AND
				(Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				(Billback_Product.Deleted = 0)
			)
			INNER JOIN	Billback_Product_Detail
			ON
			(   Billback_Product_Detail.Billback_ID = '#Billback_ID#' 
				AND
				(Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
				AND
				(Billback_Product_Detail.Deleted = 0)
				AND
				(Billback_Product_Detail.BB_Rate IS NOT NULL)
				<!--- 
				AND
				(LEN(Billback_Product_Detail.BB_Rate) > 0)
				 --->
				AND
				(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)
				<!--- 
				AND
				(CAST(Billback_Product_Detail.BB_Rate AS Float) > 0)
				 --->
			)
		WHERE
		Billback_Program.Billback_ID = Billback.Billback_ID
		AND
		Billback_Program.Deleted = 0
		), 0)  + 
		IsNull((SELECT	SUM(CAST(Billback_Program_Lumpsum_Component.Amount AS FLOAT))
		FROM	Billback_Program
			INNER JOIN	 Billback_Program_Lumpsum_Component
			ON
			(
				(Billback_Program_Lumpsum_Component.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				( Billback_Program_Lumpsum_Component.Deleted = 0)
			)
		WHERE
			Billback_Program.Billback_ID = Billback.Billback_ID
			AND
			Billback_Program.Deleted = 0
		), 0)
		) AS BB_Item_Summary
		-----------------Total Amount claimed for this program
		FROM	Billback
		LEFT JOIN _Users ON _Users.User_ID = Billback.Deviation_Ran_By
		WHERE	
			Billback.Billback_ID = '#Billback_ID#'
			AND
			Billback.Deleted = 0
	</CFQUERY>
	<CFSET Go_Forward = 0>
	<CFIF Billback_Amount_Match.recordCount GT 0>
		<CFSET Amount_Diff = Billback_Amount_Match.BB_Amount - Billback_Amount_Match.BB_Item_Summary>	
		<CFSET Amount_Diff = Amount_Diff * 100>
		<CFSET Amount_Diff = Round(Amount_Diff)>
		<CFSET Amount_Diff = Amount_Diff/100>
		<CFIF Amount_Diff EQ 0 AND Billback_Amount_Match.BB_Amount NEQ 0>
			<CFSET Go_Forward = 1>
		</CFIF>
	</CFIF>
	<CFIF NOT Go_Forward>
		<CFOUTPUT>
		<BLOCKQUOTE>			
			<BR><BR>
			<TABLE CELLPADDING="3" CELLSPACING="0" BORDER="0" WIDTH="90%" CLASS="table1">
				<TR>
					<TD>Billback Total</TD>
					<TD>:</TD>
					<TD WIDTH="50%">#DollarFormat(Billback_Amount_Match.BB_Amount)#</TD>
				</TR>
				<TR>
					<TD>Itemized Total</TD>
					<TD>:</TD>
					<TD>#DollarFormat(Billback_Amount_Match.BB_Item_Summary)#</TD>
				</TR>
				<TR>
					<TD COLSPAN="100%">
						<HR COLOR="Black">
					</TD>
				</TR>				
				<TR CLASS="wrongAmount">
					<TD>Variance</TD>
					<TD>:</TD>
					<TD>#DollarFormat(Amount_Diff)#</TD>
				</TR>				
				<TR CLASS="wrongAmount">
					<TD COLSPAN="100%">
						<BR>
						You can validate and approve a Billback only if the Billback Total matches with the Itemized Total, and the Billback Amount cannot be zero
					</TD>
				</TR>
			</TABLE>
		</BLOCKQUOTE>
		</CFOUTPUT>
		<CFABORT>
	</CFIF>
	
	
	<!------------------ Get Status ------------------------------>
	<CFQUERY  dataSource="#application.datasource#" NAME="Get_BB_Status">
		SELECT	Billback_Status_ID, BB_UP, BB_PNF, Billback_Payee_Type_ID,
				Deviation_Ran_Date, Deviation_Ran_By
		FROM	
				Billback
		WHERE
				Billback.Billback_ID = '#Billback_ID#'
	</CFQUERY>
	
	<CFSET BB_Status = Get_BB_Status.Billback_Status_ID>
	<CFSET BB_UP = Get_BB_Status.BB_UP>
	<CFSET BB_PNF = Get_BB_Status.BB_PNF>
	<CFSET Deviation_Ran_Date = Get_BB_Status.Deviation_Ran_Date>
	<CFSET Deviation_Ran_By = Get_BB_Status.Deviation_Ran_By>
	
	<cfif BB_UP>
		<cfset getBillbackDistributor = CreateObject("component", "components.billback.BillbackDeviationManager").getBillbackDistributor(Billback_ID, Get_BB_Status.Billback_Payee_Type_ID) />
		<cfif Len(Trim(getBillbackDistributor.BSA_Foodservice_Customers_ID)) GT 0>
			<cfset BB_UP = 0 />
		</cfif>
	</cfif>
	
	<CFPARAM NAME="RUN_ROUTINES" 	DEFAULT=1>
	
	<CFIF BB_Status GTE 3>
		<CFSET RUN_ROUTINES	=	0>
		<CFSET SHOW_NEXT_PREV = 0>
		<CFSET Deviation_Show_Expected_Values = 0>
	<CFELSEIF TRIM(Deviation_Ran_Date) NEQ "">
		<CFSET RUN_ROUTINES	=	1>
		<CFSET SHOW_NEXT_PREV = 1>
		<!--- BJF: This makes it impossible to ever show the detailed decision
				<CFSET Deviation_Show_Expected_Values = 0> --->
	</CFIF>	
	<CFIF BB_UP EQ 1>
		<CFSET RUN_ROUTINES	=	0>
	</CFIF>

	
	<CFIF BB_UP EQ 1>
		<BLOCKQUOTE>
		<BR><BR>
		<TABLE CELLPADDING="3" CELLSPACING="0" BORDER="0" WIDTH="90%" CLASS="table1">
			<TR CLASS="wrongAmount">
				<TD>You cannot validate a billback if the payee is unknown</TD>
			</TR>
			<TR>
				<TD>
				<CFINCLUDE TEMPLATE="Next_Prev_Buttons.cfm">
				</TD>
			</TR>	
		</TABLE>
		</BLOCKQUOTE>
		<CFABORT>
	</CFIF>
	
	
	<!------------------ Get Payee ------------------------------>
	<cfquery name="Get_Payee_Info" datasource="#application.datasource#">
		SELECT	  
		------------------------Name
		CASE
			WHEN bb.Billback_Payee_Type_ID=1 THEN  
			Billback_Distributor.Billback_Distributor_ID
			
			WHEN bb.Billback_Payee_Type_ID=2 THEN
			Billback_Operator.Billback_Operator_ID
			
			WHEN bb.Billback_Payee_Type_ID=3 THEN 
			Billback_Broker.Billback_Broker_ID
			 
			WHEN bb.Billback_Payee_Type_ID=4 THEN
			Billback_Unidentified_Payee.Billback_Unidentified_Payee_ID
			
			WHEN bb.Billback_Payee_Type_ID=5 THEN
			Billback_Distributor.Billback_Distributor_ID
			
			WHEN bb.Billback_Payee_Type_ID=6 THEN
			Billback_Operator.Billback_Operator_ID			
			
			WHEN bb.Billback_Payee_Type_ID=7 THEN
			Billback_Broker.Billback_Broker_ID
			 
		END AS Payee_ID		
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
		----------------------------------------------------				
		LEFT JOIN	Billback_Unidentified_Payee
		ON
		(
		(Billback_Unidentified_Payee.Billback_ID = bb.Billback_ID)
		AND
		(bb.Billback_Payee_Type_ID = 4)
		AND
		(Billback_Unidentified_Payee.Deleted = 0)
		)
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
	
	<CFIF Get_Payee_Info.RecordCount LTE 0>
		<BLOCKQUOTE>
		<BR><BR>
		<TABLE CELLPADDING="3" CELLSPACING="0" BORDER="0" WIDTH="90%" CLASS="table1">
			<TR CLASS="wrongAmount">
				<TD>You have to select a payee to validate and approve a billback</TD>
			</TR>			
		</TABLE>
		</BLOCKQUOTE>
		<CFABORT>
	</CFIF>