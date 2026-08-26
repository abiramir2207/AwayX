
<CFPARAM name="InfoBar_BBID" default="">
<cfparam name="itemized_total" default="0">
<CFSET DefaultInforbarMessage = "Please create a billback or search for one.">
<cfset bb_payee_type_id = 0 />

<CFSET Inforbar_String = "Error Loading Information Bar Data">
<CFSET Amount_String = "$0">
<CFSET BB_Billback_Status_ID = 0>
<CFIF len(trim(InfoBar_BBID)) EQ 0>
	<CFSET Inforbar_String = DefaultInforbarMessage>
<CFELSE>
	<cfquery name="getBillbackInformation" datasource="#Application.Datasource#">
		SELECT	Billback.BB_Title, Billback.BB_Start_Date, Billback.BB_End_Date, Billback.BB_Amount, Billback.BB_Code, Billback.BB_Date, Billback.Billback_Status_ID,
				Billback.BB_Creator_ID, BB_Approved.User_Approved, 
				Billback.BB_Payment_Request_Sent, BB_Approved.BB_Check_Status_ID, BB_Approved.Paid_Amount, Scheduled_Auto_BB 
		FROM	Billback
				LEFT JOIN BB_Approved
				ON
				BB_Approved.Billback_ID = Billback.Billback_ID
		WHERE 	Billback.Billback_ID = '#InfoBar_BBID#'
	</cfquery>
	<CFSET TitleLength = 35>
	<CFSET TitleExtraIndicator = "">
	<CFIF len(trim(getBillbackInformation.BB_Title)) GT TitleLength>
		<CFSET TitleExtraIndicator = "...">
	</CFIF>
	
	<CFIF getBillbackInformation.recordcount GT 0>
		<!--- added for auto BBs...looks ok --->
		<cfset local_bbid = InfoBar_BBID>
		<cfinclude template="bb_menu_stats.cfm"> 
		<!--- new for auto bb  auto_bb--->
		<CFSET BB_Billback_Status_ID = getBillbackInformation.Billback_Status_ID>
		<CFSET Inforbar_String = "#getBillbackInformation.BB_Code#">
		<CFIF NOT getBillbackInformation.Scheduled_Auto_BB>
			<CFSET Amount_String = "#DollarFormat(getBillbackInformation.BB_Amount)#">
		<CFELSE>
			<CFSET Amount_String = "#dollarformat(itemized_total)#">
		</CFIF>
		<!--------------------------------------------------------------------------------
		Get payee Info
		--------------------------------------------------------------------------------->
		<cfquery name="Get_Payee_Info" datasource="#application.datasource#">
		SELECT	  bb.Billback_Payee_Type_ID,
		------------------------Name
		CASE
			WHEN bb.Billback_Payee_Type_ID=1 THEN  
			BSA_Foodservice_Customers.Name  
			
			WHEN bb.Billback_Payee_Type_ID=2 THEN
			BSA_Operator.Operator_Name  
			
			WHEN bb.Billback_Payee_Type_ID=3 THEN 
			BSA_Foodservice_Brokers.Broker_Name
			 
			WHEN bb.Billback_Payee_Type_ID=4 THEN
			Billback_Unidentified_Payee.BB_UP_Name
			
			WHEN bb.Billback_Payee_Type_ID=5 THEN
			Billback_Distributor.BB_Distributor_Name
			
			WHEN bb.Billback_Payee_Type_ID=6 THEN
			Billback_Operator.BB_Operator_Name
			
			WHEN bb.Billback_Payee_Type_ID=7 THEN
			Billback_Broker.BB_Broker_Name
			 
		END AS Payee_Name		
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
		bb.Billback_ID = '#InfoBar_BBID#'
	</cfquery>
	<CFIF Get_Payee_Info.recordCount GT 0>
		<CFSET Inforbar_String = "#Inforbar_String# - #Trim(Get_Payee_Info.Payee_Name)#">
		<cfset bb_payee_type_id = Get_Payee_Info.Billback_Payee_Type_ID />
	</CFIF>
		<CFSET Inforbar_String = "#Inforbar_String# - #left(getBillbackInformation.BB_Title, TitleLength)##TitleExtraIndicator#<BR>Delivery Period: #dateformat(getBillbackInformation.BB_Start_Date, 'm/d/yyyy')# to #dateformat(getBillbackInformation.BB_End_Date, 'm/d/yyyy')# ">
		<CFSET Inforbar_String = Replace(Inforbar_String, "\","\\", "all")>
		<CFSET Inforbar_String = Replace(Inforbar_String,chr(39),"\'", "all")>
	</CFIF>
</CFIF>

<script>
	
	if(window.parent)
	{
		if(window.parent.LoadInfobar)
		{
			window.parent.LoadInfobar(' <cfoutput>#Inforbar_String#</cfoutput>', '<CFOUTPUT>#Amount_String#</CFOUTPUT>')
		}
		<cfoutput>
		if(window.parent.bb_payee_type_id != "undefined")
		{
			window.parent.bb_payee_type_id = #bb_payee_type_id#;
		}
		</cfoutput>
	}
	else
	{
		<cfoutput>
		bb_payee_type_id = #bb_payee_type_id#;
		</cfoutput>
	}
	
</script>