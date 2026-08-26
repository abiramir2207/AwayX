<cfset application.returned_customer_setting.PayBy_awayX = 0 /><!--- D8914 Payby_awayX  Get rid of the switch  --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<HTML>

<HEAD>
<TITLE>Amount to Pay</TITLE>
<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">
<!--- For textareaChecklength --->
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js">
</HEAD>

<CFIF URL.new_bb_check EQ 1>
	<!--- <CFSET URL.PageTitle="BILLBACK: Payment Request Data Entry Form"> --->
<CFELSE>
	<CFSET URL.PageTitle="#application.CompanyName#: Payment Request Data Entry Form">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</CFIF>
<BODY>
<Cfsilent>
<cfset useLakebaseForCom_Bank_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_bank_info")>
<cfif useLakebaseForCom_Bank_Info>
	<cftry>
		<cfset Com_Bank_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_bank_info", {
				"bank_info_deleted" = "eq.0",
				"select" = "debit_account_no"
			}), "debit_account_no"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCom_Bank_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCom_Bank_Info>
<CFQUERY name="Com_Bank_Info" datasource="#application.datasource#">
	SELECT debit_Account_No FROM company_bank_Info WHERE Bank_Info_Deleted = 0
</CFQUERY>
</cfif>
<CFOUTPUT>
<CFIF Com_Bank_Info.recordcount EQ 0 and application.returned_customer_setting.PayBy_awayX EQ 1>
	<CFLOCATION URL = "../Company_Bank_Info_Form.cfm?FromPayment=1&new_bb_check=#URL.new_bb_check#&Trans_type=#URL.Trans_type#&CRID=#URL.RID#" ADDTOKEN = "No">
</CFIF>
</CFOUTPUT>
<!--- <CFOUTPUT>#url.bank_info_id#
<br>#url.category#
</CFOUTPUT> 
 --->
<!--- <CFOUTPUT>
#URL.category#<br>
#URL.bank_info_id#<br>
#URL.new_bb_check#<br>
#URL.trans_type#<br>
#URL.RID#<br>
</CFOUTPUT>
 --->
 
<cfset useLakebaseForget_data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ledger_table")>
<cfif useLakebaseForget_data>
	<cftry>
		<cfset get_data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ledger_table", {
				"ledger_id" = "eq.#url.RID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_data>
<CFQUERY name = "get_data" datasource="#application.datasource#">
	Select * from ledger_table where ledger_ID = '#url.RID#'
</CFQUERY>
</cfif>

<!--- fix for an issue when 2 useres submit payments at exactly the same time.  The ledger recoed gets deleted --->
<!--- if no record...try again --->
<cfif get_data.recordcount eq 0>
	<cflocation url="/Billbacks/Approval/payment_display.cfm" addtoken="No">
</cfif>
<CFIF Get_Data.Pay_Multi_Billbacks_ID NEQ "">
	<CFSET FromMultiBB = 1>
	<CFSET Pay_Multi_Billbacks_ID = get_data.Pay_Multi_Billbacks_ID>
	
	<CFSET FORM.Lock_Status = 1>
	<CFINCLUDE TEMPLATE="/Billbacks/Multi_BB_Payment/Lock_BB.cfm">
</CFIF>

<CFIF "#url.new_bb_check#" NEQ 0>
<cfquery name="Get_Payee_Info" datasource="#application.datasource#">
 SELECT DISTINCT bb.billback_payee_Type_ID billback_payee_type_ID,   

 ------------------------ID
 CASE
  WHEN bb.Billback_Payee_Type_ID=1 THEN  
  CAST(Billback_Distributor.Distributor_ID AS NVARCHAR(50))
  
  WHEN bb.Billback_Payee_Type_ID=2 THEN
  CAST(Billback_Operator.Operator_ID AS NVARCHAR(50))
  
  WHEN bb.Billback_Payee_Type_ID=3 THEN 
  CAST(Billback_Broker.Broker_ID AS NVARCHAR(50))
   
  WHEN bb.Billback_Payee_Type_ID=4 THEN
  NULL
  
  WHEN bb.Billback_Payee_Type_ID=5 THEN
  NULL
  
  WHEN bb.Billback_Payee_Type_ID=6 THEN
  NULL
  
  WHEN bb.Billback_Payee_Type_ID=7 THEN
  NULL
   
 END AS Payee_ID




    ------------------------Name
    ,CASE
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
	------------------------Address1
    ,CASE
     WHEN bb.Billback_Payee_Type_ID=1 THEN  
     replace(BSA_Foodservice_Customers.Address_1,'"','')
     
     WHEN bb.Billback_Payee_Type_ID=2 THEN
     replace(BSA_Operator.Operator_Address,'"','')
     
     WHEN bb.Billback_Payee_Type_ID=3 THEN 
     replace(BSA_Foodservice_Brokers.Address,'"','')
      
     WHEN bb.Billback_Payee_Type_ID=4 THEN
    replace( Billback_Unidentified_Payee.BB_UP_Address1,'"','')
     
     WHEN bb.Billback_Payee_Type_ID=5 THEN
     replace(Billback_Distributor.BB_Distributor_Address1,'"','')
     
     WHEN bb.Billback_Payee_Type_ID=6 THEN
     replace(Billback_Operator.BB_Operator_Address1,'"','')
     
     WHEN bb.Billback_Payee_Type_ID=7 THEN
     replace(Billback_Broker.BB_Broker_Address1,'"','')
      
    END AS Address1
	------------------------Address2
    ,CASE
     WHEN bb.Billback_Payee_Type_ID=1 THEN  
     replace(BSA_Foodservice_Customers.Address_2,'"','')
     
     <!--- WHEN bb.Billback_Payee_Type_ID=2 THEN
     BSA_Operator.Operator_Name   --->
     
     WHEN bb.Billback_Payee_Type_ID=3 THEN 
     replace(BSA_Foodservice_Brokers.Address_2,'"','')
      
     WHEN bb.Billback_Payee_Type_ID=4 THEN
     replace(Billback_Unidentified_Payee.BB_UP_Address2,'"','')
     
     WHEN bb.Billback_Payee_Type_ID=5 THEN
     replace(Billback_Distributor.BB_Distributor_Address2,'"','')
     
     WHEN bb.Billback_Payee_Type_ID=6 THEN
     replace(Billback_Operator.BB_Operator_Address2,'"','')
     
     WHEN bb.Billback_Payee_Type_ID=7 THEN
     replace(Billback_Broker.BB_Broker_Address2,'"','')
      
    END AS Address2
    
    
    -------------------------City
    ,CASE
    WHEN bb.Billback_Payee_Type_ID=1 THEN  
     BSA_Foodservice_Customers.City
     
    WHEN bb.Billback_Payee_Type_ID=2 THEN
     BSA_Operator.Operator_City
     
    WHEN bb.Billback_Payee_Type_ID=3 THEN 
     BSA_Foodservice_Brokers.City
     
    WHEN bb.Billback_Payee_Type_ID=4 THEN
     Billback_Unidentified_Payee.BB_UP_Name
 
    WHEN bb.Billback_Payee_Type_ID=5 THEN  
     Billback_Distributor.BB_Distributor_City
     
    WHEN bb.Billback_Payee_Type_ID=6 THEN
      Billback_Operator.BB_Operator_City
 
    WHEN bb.Billback_Payee_Type_ID=7 THEN 
      Billback_Broker.BB_Broker_City
 
    END AS City
    -------------------------State
    ,CASE
    WHEN bb.Billback_Payee_Type_ID=1 THEN  
     BSA_Foodservice_Customers.State  
    
    WHEN bb.Billback_Payee_Type_ID=2 THEN
     BSA_Operator.Operator_State
    
    WHEN bb.Billback_Payee_Type_ID=3 THEN 
     BSA_Foodservice_Brokers.State
    
    WHEN bb.Billback_Payee_Type_ID=4 THEN
     _States.State_Code
    
    WHEN bb.Billback_Payee_Type_ID=5 THEN  
     _States.State_Code
    
    WHEN bb.Billback_Payee_Type_ID=6 THEN
     _States.State_Code
    
    WHEN bb.Billback_Payee_Type_ID=7 THEN 
     _States.State_Code
    
    END AS State_Code
    -------------------------Zipcode
    ,CASE
    WHEN bb.Billback_Payee_Type_ID=1 THEN  
     BSA_Foodservice_Customers.ZipCode
     
    WHEN bb.Billback_Payee_Type_ID=2 THEN
     BSA_Operator.Operator_Zip
     
    WHEN bb.Billback_Payee_Type_ID=3 THEN 
     BSA_Foodservice_Brokers.Zip
     
    WHEN bb.Billback_Payee_Type_ID=4 THEN
     Billback_Unidentified_Payee.BB_UP_Zipcode
 
    WHEN bb.Billback_Payee_Type_ID=5 THEN  
     Billback_Distributor.BB_Distributor_Zipcode
     
    WHEN bb.Billback_Payee_Type_ID=6 THEN
      Billback_Operator.BB_Operator_Zipcode
 
    WHEN bb.Billback_Payee_Type_ID=7 THEN 
      Billback_Broker.BB_Broker_Zipcode
 
    END AS Zipcode
	
	
	    -------------------------Country
    ,CASE
    WHEN bb.Billback_Payee_Type_ID=1 THEN  
     BSA_Foodservice_Customers.Country_Code 
    
    WHEN bb.Billback_Payee_Type_ID=2 THEN
     BSA_Operator.Operator_Country_Code
    
    WHEN bb.Billback_Payee_Type_ID=3 THEN 
     BSA_Foodservice_Brokers.Country_Code
    
    WHEN bb.Billback_Payee_Type_ID=4 THEN
     _Country.Country_Code
    
    WHEN bb.Billback_Payee_Type_ID=5 THEN  
     _Country.Country_Code
    
    WHEN bb.Billback_Payee_Type_ID=6 THEN
     _Country.Country_Code
    
    WHEN bb.Billback_Payee_Type_ID=7 THEN 
     _Country.Country_Code
 
    END AS Country_code
	
    
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
    LEFT JOIN Billback_Unidentified_Payee
    ON
    (
    (Billback_Unidentified_Payee.Billback_ID = bb.Billback_ID)
    AND
    (bb.Billback_Payee_Type_ID = 4)
    AND
    (Billback_Unidentified_Payee.Deleted = 0)
    )
    ----------------------------------------------------    
    LEFT JOIN _States
    ON
    (
    ((bb.Billback_Payee_Type_ID = 5) AND (_States.State_ID=Billback_Distributor.BB_Distributor_State))
    OR
    ((bb.Billback_Payee_Type_ID = 6) AND (_States.State_ID=Billback_Operator.BB_Operator_State))
    OR
    ((bb.Billback_Payee_Type_ID = 7) AND (_States.State_ID=Billback_Broker.BB_Broker_State))
    OR
    ((bb.Billback_Payee_Type_ID = 4) AND (_States.State_ID=Billback_Unidentified_Payee.BB_UP_State))
    )
	
	LEFT JOIN _Country
    ON
    (
    ((bb.Billback_Payee_Type_ID = 5) AND (_Country.Country_Code=Billback_Distributor.BB_Distributor_Country_Code))
    OR
    ((bb.Billback_Payee_Type_ID = 6) AND (_Country.Country_Code=Billback_Operator.BB_Operator_Country_Code))
    OR
    ((bb.Billback_Payee_Type_ID = 7) AND (_Country.Country_Code=Billback_Broker.BB_Broker_Country_Code))
    OR
    ((bb.Billback_Payee_Type_ID = 4) AND (_Country.Country_Code=Billback_Unidentified_Payee.BB_UP_Country_Code))
    )
	
    WHERE
    bb.Deleted = 0    
    AND
	<CFIF IsDefined("FromMultiBB")>
		BB.Billback_ID IN (	SELECT 	Billback_ID 
							FROM 	Pay_Multi_Billbacks_List 
							WHERE 	Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND 
									Deleted = 0	)
	<CFELSE>
		bb.Billback_ID = '#get_data.BillBack_ID#'
	</CFIF>    
   </cfquery>
     
<CFQUERY name = "Bank_Info" datasource="#application.datasource#">
	SELECT * FROM Customer_Bank_Info 
	WHERE customer_ID = '#get_payee_info.payee_ID#' 
	AND Bank_Info_Deleted = 0 
	<CFIF URL.trans_type EQ 0>
	AND Customer_Transit_Routing_No  is not null
	AND ltrim(Customer_Transit_Routing_No)<>''
	</CFIF>
	<!--- <CFIF URL.trans_type = 0>
	and Customer_Transit_No is not null
	</CFIF> --->
</CFQUERY>
<!--- <CFOUTPUT>RECORD_COUNT: #bank_info.recordcount#</CFOUTPUT> --->
<CFSET record_count = #bank_info.recordcount#>
<!--- <CFOUTPUT>bank record count: #record_count#</CFOUTPUT> --->
</CFIF>
</CFSILENT>

<!--- 	if it is a create transaction or if it is from billback and have no bank info, 
		link to bank info page		--->

<CFPARAM NAME = "URL.bank_info_ID" DEFAULT="">
<CFPARAM NAME = "URL.category" DEFAULT="">
<CFPARAM NAME = "record_count" DEFAULT="">
<CFIF URL.new_bb_check EQ 0>
<CFOUTPUT>
<B>	
<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="../Distributor_Bank_Info.cfm?new_bb_check=#url.new_bb_check#&Trans_Type=#URL.trans_type#&LRID=#url.RID#"><B>#application.returned_customer_setting.distributor_label_singular#</B></A>
<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
</B>

<B>	
<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="../Operator_Bank_Info.cfm?new_bb_check=#url.new_bb_check#&Trans_Type=#URL.Trans_Type#&LRID=#url.RID#"><B>#application.returned_customer_setting.operator_label_singular#</B></A>
<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
</B>

<B>	
<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="../Broker_Bank_Info.cfm?new_bb_check=#url.new_bb_check#&Trans_Type=#URL.Trans_Type#&LRID=#url.RID#"><B>broker</B></A>
<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
</B>
<B>	
<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="../UnknownPayee_Bank_Info.cfm?new_bb_check=#url.new_bb_check#&Trans_Type=#URL.Trans_Type#&LRID=#url.RID#"><B>unknown</B></A>
<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
</B>

<!--- <B>	
<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="../Distributor_Bank_Info.cfm"><B>distributor</B></A>
<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
</B> --->
</CFOUTPUT>
</CFIF>
<!--- Link to the bank_info, If it is from bb --->
<CFIF URL.new_bb_check EQ 1 and record_count EQ 0 and trans_type EQ 0 and url.bank_info_ID EQ "">

<CFOUTPUT>
<!--- #get_payee_info.payee_name#<br>
#get_payee_info.payee_id#<br> 
skdjhaf : #get_Payee_Info.billback_payee_type_ID#--->
<CFIF get_payee_Info.billback_payee_type_ID EQ 1>
	<CFLOCATION URL = "../Distributor_Bank_Info.cfm?payee_name=#get_payee_info.payee_name#&payee_ID=#get_payee_info.payee_id#&new_bb_check=#url.new_bb_check#&Trans_Type=#URL.Trans_Type#&LRID=#url.RID#" ADDTOKEN="NO">

<!--- <B>	
<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="../Distributor_Bank_Info.cfm?payee_name=#get_payee_info.payee_name#&payee_ID=#get_payee_info.payee_id#&new_bb_check=#url.new_bb_check#&Trans_Type=#URL.Trans_Type#&LRID=#url.RID#"><B>distributor</B></A>
<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
</B>
 ---></CFIF>
<CFIF get_payee_Info.billback_payee_type_ID EQ 2>
	<CFLOCATION URL = "../Operator_Bank_Info.cfm?payee_name=#get_payee_info.payee_name#&payee_ID=#get_payee_info.payee_id#&new_bb_check=#url.new_bb_check#&Trans_Type=#URL.Trans_Type#&LRID=#url.RID#" ADDTOKEN = "NO">
<!--- <B>	
<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="../Operator_Bank_Info.cfm?payee_name=#get_payee_info.payee_name#&payee_ID=#get_payee_info.payee_id#&new_bb_check=#url.new_bb_check#&Trans_Type=#URL.Trans_Type#&LRID=#url.RID#"><B>operator</B></A>
<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
</B>
 ---></CFIF>
<CFIF get_payee_Info.billback_payee_type_ID EQ 3>
	<CFLOCATION URL = "../Broker_Bank_Info.cfm?payee_name=#get_payee_info.payee_name#&payee_ID=#get_payee_info.payee_id#&new_bb_check=#url.new_bb_check#&Trans_Type=#URL.Trans_Type#&LRID=#url.RID#" ADDTOKEN = "NO">
<!--- <B>	
<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="../Broker_Bank_Info.cfm?payee_name=#get_payee_info.payee_name#&payee_ID=#get_payee_info.payee_id#&new_bb_check=#url.new_bb_check#&Trans_Type=#URL.Trans_Type#&LRID=#url.RID#"><B>broker</B></A>
<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
</B>
 ---></CFIF>
<CFIF 	get_payee_Info.billback_payee_type_ID EQ 4 or 
		get_payee_Info.billback_payee_type_ID EQ 5 or
		get_payee_Info.billback_payee_type_ID EQ 6 or
		get_payee_Info.billback_payee_type_ID EQ 7>
	<CFLOCATION URL = "../UnknownPayee_Bank_Info.cfm?payee_name=#get_payee_info.payee_name#&address1=#get_payee_info.address1#&address2=#get_payee_info.address2#&city=#get_payee_info.city#&state_code=#get_payee_info.state_code#&zipcode=#get_payee_info.zipcode#&new_bb_check=#url.new_bb_check#&Trans_Type=#URL.Trans_Type#&LRID=#url.RID#" ADDTOKEN = "NO">
<!--- <B>	
<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>

	<A HREF="../UnknownPayee_Bank_Info.cfm?payee_name=#get_payee_info.payee_name#&address1=#get_payee_info.address1#&address2=#get_payee_info.address2#&city=#get_payee_info.city#&state_code=#get_payee_info.state_code#&zipcode=#get_payee_info.zipcode#&new_bb_check=#url.new_bb_check#&Trans_Type=#URL.Trans_Type#&LRID=#url.RID#"><B>unknown</B></A>

<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
</B> --->
</CFIF>
</CFOUTPUT>
</CFIF>
 

<!--- select the bank info and customer address, if it from bank_info--->  
<cfsilent>
<CFIF url.bank_info_id NEQ "">

<CFIF url.category EQ "Distributor">
	<CFQUERY name="return_bank_info" datasource ="#application.datasource#">
		SELECT 
			b.customer_transit_routing_no 	customer_transit_routing_no,
			b.customer_bank_name 			customer_bank_name,
			b.customer_bank_address			customer_bank_address,
			b.customer_bank_city			customer_bank_city,
			b.customer_bank_statecode		customer_bank_statecode,
			b.customer_bank_zipcode			customer_bank_zipcode,
			b.customer_bank_country_Code	customer_bank_country_Code,
			b.customer_account_no			customer_account_no,
			b.customer_bank_location		customer_bank_location,
			c.name							payee_name,
			c.address_1						address1,
			c.address_2						address2,
			c.city							city,
			c.state							state_code,
			c.country_code					country_code,
			c.zipcode 						zipcode
			
		FROM customer_bank_info b,BSA_foodservice_customers c 
		WHERE 
				b.customer_ID = CAST(c.BSA_foodservice_customers_ID AS NVARCHAR(60))
				and b.Bank_info_ID = '#url.bank_info_id#'	
	</CFQUERY>
<CFELSEIF url.category EQ "Broker">
	<CFQUERY name="return_bank_info" datasource="#application.datasource#">
		SELECT 
			b.customer_transit_routing_no	customer_transit_routing_no,
			b.customer_bank_name			customer_bank_name,
			b.customer_bank_address			customer_bank_address,
			b.customer_bank_city			customer_bank_city,
			b.customer_bank_statecode		customer_bank_statecode,
			b.customer_bank_zipcode			customer_bank_zipcode,
			b.customer_bank_country_Code	customer_bank_country_Code,
			b.customer_account_no			customer_account_no,
			b.customer_bank_location		customer_bank_location,
			c.broker_name					payee_name,
			c.address						address1,
			c.address_2						address2,
			c.city							city,
			c.state							state_code,
			c.country_code					country_code,
			c.zip 							zipcode
		FROM customer_bank_info b,BSA_foodservice_brokers c 
		WHERE b.customer_ID = CAST(c.BSA_foodservice_brokers_ID AS NVARCHAR(60)) and b.Bank_Info_ID = '#URL.bank_info_id#'		
	</CFQUERY>
<CFELSEIF url.category EQ "Operator">
	<CFQUERY name="return_bank_info" datasource="#application.datasource#">
		SELECT 
			b.customer_transit_routing_no 	customer_transit_routing_no,
			b.customer_bank_name			customer_bank_name,
			b.customer_bank_address			customer_bank_address,
			b.customer_bank_city			customer_bank_city,
			b.customer_bank_statecode		customer_bank_statecode,
			b.customer_bank_zipcode			customer_bank_zipcode,
			b.customer_bank_country_Code	customer_bank_country_Code,
			b.customer_account_no			customer_account_no,
			b.customer_bank_location		customer_bank_location,
			c.operator_name					payee_name,
			c.operator_address				address1,
			c.operator_city					city,
			c.operator_state				state_code,
			c.operator_country_code			country_code,
			c.operator_zip					zipcode 
		FROM customer_bank_info b,BSA_operator c 
		WHERE b.customer_ID = CAST(c.BSA_Operator_ID AS NVARCHAR(60)) and b.bank_info_id = '#URL.Bank_Info_ID#'		
	</CFQUERY>
<CFELSEIF url.category EQ "UnknownPayee">
	<CFQUERY name="return_bank_info" datasource="#application.datasource#">
		SELECT
			Customer_Transit_routing_no,
			Customer_Bank_Name,
			Customer_Bank_Address,
			Customer_Bank_City,
			Customer_Bank_Statecode,
			Customer_Bank_Zipcode,
			customer_bank_country_Code,
			Customer_Account_No,
			customer_bank_location,
			Payee_name,
			Address1,
			Address2,
			city,
			state_code,
			zipcode,
			country_code
		FROM UnknownPayee_Bank_Info_Temp where Unknown_Bank_ID = '#URL.Bank_Info_ID#'
	</CFQUERY>
</CFIF>
</CFIF>
</cfsilent>




<STYLE>
	.section
		{
			font: 16px;
			font-weight: bold;
		}
</STYLE>

<!---<CFOUTPUT>
#url.trans_type#
</CFOUTPUT>--->
 <SCRIPT type = "text/javascript">
function validate()
{
	x = document.Payment_data_entry
	if(x.Amount.value != "")
	{
		if(x.foreign_amount.value != "")
		{
			alert("Enter amount either in USD or foreign currency")
			x.Amount.focus() 
			return false
		}
	}
	/*if(x.foreign_amount.value != "")
	{
		if(x.Currency.value == "")
		{
			alert("Enter Foreign Currency Name")
			x.Currency.focus()
			return false
		}
	}*/
}
</SCRIPT> 


<cfsilent>
<CFPARAM NAME = "get_data.Memo_field" DEFAULT = "">
<CFPARAM NAME = "get_data.Amount" DEFAULT = "0.00">
<CFPARAM NAME = "Get_Payee_Info.Payee_Name" DEFAULT = "">
<CFPARAM NAME = "get_Payee_Info.address1" DEFAULT = "">
<CFPARAM NAME = "get_Payee_Info.address2" DEFAULT = "">
<CFPARAM NAME = "get_Payee_Info.city" DEFAULT = "">
<CFPARAM NAME = "get_Payee_Info.state_code" DEFAULT = "">
<CFPARAM NAME = "get_Payee_Info.zipcode" DEFAULT = "">
<CFPARAM NAME = "get_Payee_Info.Country_Code" DEFAULT = "">
<CFPARAM NAME = "Bank_Info.Customer_Account_no" DEFAULT = "">
<CFPARAM NAME = "Bank_Info.Customer_Bank_Name" DEFAULT = "">
<CFPARAM NAME = "Bank_Info.Customer_Bank_Address" DEFAULT = "">
<CFPARAM NAME = "Bank_Info.Customer_Bank_city" DEFAULT = "">
<CFPARAM NAME = "Bank_Info.Customer_Bank_statecode" DEFAULT = "">
<CFPARAM NAME = "Bank_Info.Customer_Bank_zipcode" DEFAULT = "">
<CFPARAM NAME = "Bank_Info.Customer_Bank_country_Code" DEFAULT = "">
<CFPARAM NAME = "Bank_Info.Customer_Transit_routing_no" DEFAULT = "">
<CFPARAM NAME = "Bank_Info.Customer_Bank_Location" DEFAULT = "">
<CFPARAM NAME = "return_bank_info.Payee_Name" DEFAULT = "">
<CFPARAM NAME = "return_bank_info.address1" DEFAULT = "">
<CFPARAM NAME = "return_bank_info.address2" DEFAULT = "">
<CFPARAM NAME = "return_bank_info.city" DEFAULT = "">
<CFPARAM NAME = "return_bank_info.state_code" DEFAULT = "">
<CFPARAM NAME = "return_bank_info.zipcode" DEFAULT = "">
<CFPARAM NAME = "return_bank_info.country_Code" DEFAULT = "">
<CFPARAM NAME = "return_bank_info.Customer_Account_no" DEFAULT = "">
<CFPARAM NAME = "return_Bank_Info.Customer_Bank_Name" DEFAULT = "">
<CFPARAM NAME = "return_Bank_Info.Customer_Bank_Address" DEFAULT = "">
<CFPARAM NAME = "return_Bank_Info.Customer_Bank_city" DEFAULT = "">
<CFPARAM NAME = "return_Bank_Info.Customer_Bank_statecode" DEFAULT = "">
<CFPARAM NAME = "return_Bank_Info.Customer_Bank_zipcode" DEFAULT = "">
<CFPARAM NAME = "return_Bank_Info.Customer_Bank_country_code" DEFAULT = "">
<CFPARAM NAME = "return_Bank_Info.Customer_Bank_Location" DEFAULT = "">
<CFPARAM NAME = "return_Bank_Info.Customer_Transit_routing_no" DEFAULT = "">

<CFPARAM NAME = "Pay_By_Order_Of" DEFAULT = "#application.CompanyNameFull#">
<CFPARAM NAME = "Debit_Account_No" DEFAULT = "88723407865774536">


<CFQUERY NAME="getStates" datasource="#application.datasource#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY>
<!--- Country code --->
<cfset useLakebaseForgetCountry = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_country")>
<cfif useLakebaseForgetCountry>
	<cftry>
		<cfset getCountry = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_country", {
				"active" = "eq.1",
				"order" = "country_id.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCountry = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCountry>
<CFQUERY NAME="getCountry" datasource="#application.datasource#">
	SELECT *
	FROM _Country
	where active = 1
	ORDER BY Country_id ASC
</CFQUERY>
</cfif>
</cfsilent>

<SCRIPT LANGUAGE = "javascript">
function validate()
{
	var confirmation = confirm("Press OK if you are sure to make this Payment");
	if (confirmation == true)
	{
		document.Payment_data_entry.submit();
	}
}
function validate1()
{
	var submittrue = 1;
	/*if (document.Payment_data_entry.Mail_To.value == "")
	{
		alert("Please enter the email address in the Mail TO Box");
		document.Payment_data_entry.Mail_To.focus();
		submittrue = 0;
	} */
	if (submittrue == 1)
	{
		
			document.Payment_data_entry.submit();

	}
}
</SCRIPT>

<CENTER>
<FORM name = "Payment_data_entry" action="Save_Payment_Transaction.cfm" method="post" onsubmit = "return validate()">
<CFOUTPUT>
<INPUT TYPE = "hidden" NAME = "Billback_ID" VALUE = "#get_data.Billback_ID#">
<INPUT TYPE = "hidden" NAME = "trans_type" VALUE = "#url.trans_type#">
<INPUT TYPE = "hidden" NAME = "currency" VALUE = "#get_data.curr_symbol#">
<INPUT TYPE = "hidden" NAME = "Category" VALUE = "#URL.category#">
<INPUT TYPE = "hidden" NAME = "RID" VALUE = "#URL.RID#">
<CFIF IsDefined("FromMultiBB")>
<INPUT TYPE	= "Hidden" NAME = "Pay_Multi_Billbacks_ID" VALUE = "#Pay_Multi_Billbacks_ID#">
</CFIF> 
</CFOUTPUT>
  <TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" STYLE="border-collapse: collapse" BORDERCOLOR="#111111" ID="AutoNumber1">
    <TR>
      <TD NOWRAP COLSPAN="4" VALIGN="bottom" STYLE="border-bottom: 2px solid #000080"><SPAN CLASS="section">Amount to Pay</SPAN></TD>
    </TR>
    <TR>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">Transaction Date:</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
	  <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom"><CFOUTPUT>#dateformat(now(), 'm/d/yyyy')#</CFOUTPUT></TD>
    </TR>
    <TR>
	  <CFIF "#url.trans_type#" EQ 1>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">Amount To be Paid (USD):</TD>
	  <CFELSEIF "#url.trans_type#" EQ 0>
	  <TD ALIGN="right" NOWRAP VALIGN="bottom">Amount To be Wired (USD):</TD>
	  </CFIF>
      <TD VALIGN="bottom">&nbsp;</TD>
	  
	<CFSET get_data.Amount = get_data.amount>
		<TD VAlIGN="bottom">$</TD>	
      <TD VALIGN="bottom"><INPUT TYPE="text" NAME="Amount" SIZE="45" VALUE = "<CFIF get_data.curr_symbol EQ "US"><CFOUTPUT>#numberformat(get_data.Amount,"_.__")#</CFOUTPUT></CFIF>" READONLY></TD>
    </TR>
    <TR>
	  <CFIF "#url.trans_type#" EQ 1>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">
	  	Amount To be Paid (
		<CFIF get_data.curr_symbol EQ "BP">
			British Pounds 
		<CFELSEIF get_data.curr_symbol EQ "CD">
			Canadian Dollar
		<CFELSEIF get_data.curr_symbol EQ "EC">
			European Euro
		<CFELSE>
			Foreign Currency
		</CFIF>):</TD>
	  <CFELSEIF "#url.trans_type#" EQ 0>
	  <TD ALIGN="right" NOWRAP VALIGN="bottom">
	  	Amount To be Wired (
		<CFIF get_data.curr_symbol EQ "BP">
			British Pounds 
		<CFELSEIF get_data.curr_symbol EQ "CD">
			Canadian Dollar
		<CFELSEIF get_data.curr_symbol EQ "EC">
			European Euro
		<CFELSE>
			Foreign Currency
		</CFIF>):</TD>
	  </CFIF>
      <TD VALIGN="bottom">&nbsp;</TD>
 	  <TD VALIGN="bottom">
	  <CFIF get_data.curr_symbol EQ "BP">
	  &#163;
	  <CFELSEIF get_data.curr_symbol EQ "CD">
	  $
	  <CFELSEIF get_data.curr_symbol EQ "EC">
	  &#128; 
	  </CFIF>
	  </TD>
      <TD VALIGN="bottom">
	  <INPUT TYPE="text" NAME="foreign_amount" SIZE="45"VALUE = "<CFIF get_data.curr_symbol NEQ "US"><CFOUTPUT>#numberformat(get_data.Foreign_curr_amount,"_.__")#</CFOUTPUT></CFIF>" READONLY></TD>
    </TR>
	<!--- <TR>
	  <TD ALIGN="right" NOWRAP VALIGN="bottom">Foreign Currency:</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;&nbsp;<INPUT TYPE="text" NAME="Currency" SIZE="40"></TD>
     --->
	</TR>
<!---     <TR>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
	  <TD VALIGN="bottom">&nbsp;</TD>
    </TR> --->
    <TR>
      <TD NOWRAP COLSPAN="4" VALIGN="bottom" STYLE="border-bottom: 2px solid #000080"><SPAN CLASS="section">Beneficiary Account Information</SPAN></TD>
    </TR>
	<CFIF "#url.trans_type#" EQ 0>
    <TR>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">Credit Account Number:</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">
	  <CFIF url.bank_info_id NEQ "">

	  	<INPUT TYPE="text" NAME="Payee_Account_No" SIZE="45" VALUE = "<CFOUTPUT>#return_Bank_Info.Customer_Account_no#</CFOUTPUT>" READONLY>
	  <CFELSE>	
	 	<INPUT TYPE="text" NAME="Payee_Account_No" SIZE="45" VALUE = "<CFOUTPUT>#Bank_Info.Customer_Account_no#</CFOUTPUT>" READONLY>
	  </CFIF>
	  </TD>
    </TR>
	</CFIF>
    <TR>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">For Credit To:</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>	 
      <TD VALIGN="bottom">
	  <CFIF url.bank_info_id NEQ "">
	  <INPUT TYPE="text" NAME="Payee_Name" SIZE="45" VALUE = "<CFOUTPUT>#Replace(return_bank_Info.Payee_Name, '"', '')#</CFOUTPUT>" READONLY>
	  <CFELSE>
	  <INPUT TYPE="text" NAME="Payee_Name" SIZE="45" VALUE = "<CFOUTPUT>#Replace(Get_Payee_Info.Payee_Name, '"', '')#</CFOUTPUT>" READONLY>
	  </CFIF>
	  </TD>
	  
    </TR>

    <TR>
      <TD ALIGN="right" NOWRAP VALIGN="top">Address:</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">
	  <CFIF url.bank_info_id NEQ "">
	  	<INPUT TYPE="text" NAME="Payee_Address1" SIZE="45" VALUE = "<CFOUTPUT>#return_bank_Info.address1#</CFOUTPUT>"><BR>		
	  	<INPUT TYPE="text" NAME="Payee_Address2" SIZE="45" VALUE = "<CFIF url.category NEQ "operator"><CFOUTPUT>#return_bank_Info.address2#</CFOUTPUT></CFIF>"><BR>		
      	<INPUT TYPE="text" NAME="Payee_City" SIZE="24" VALUE = "<CFOUTPUT>#return_bank_Info.City#</CFOUTPUT>">&nbsp;
		<SELECT NAME="Payee_State">
			<OPTION VALUE="" SELECTED></OPTION>
			<CFLOOP QUERY="getStates">
				<OPTION VALUE="<CFOUTPUT>#getStates.State_Code#</CFOUTPUT>" <CFIF Trim(getStates.State_Code) EQ Trim(return_bank_Info.state_code)> SELECTED</CFIF>><CFOUTPUT>#getStates.State_Code#</CFOUTPUT></OPTION>
			</CFLOOP>
		</SELECT>&nbsp;

<!--- 		<INPUT TYPE="text" NAME="Payee_State" SIZE="3" VALUE = "<CFOUTPUT>#return_bank_Info.state_code#</CFOUTPUT>">&nbsp; --->
		<INPUT TYPE="text" NAME="Payee_Zipcode" SIZE="7" VALUE = "<CFOUTPUT>#return_bank_Info.Zipcode#</CFOUTPUT>" MAXLENGTH="10"><br>
		
		<SELECT NAME="Payee_Country_Code"><OPTION VALUE="" SELECTED></OPTION><CFLOOP QUERY="getCountry"><OPTION VALUE="<cfoutput>#getCountry.Country_Code#</cfoutput>" <CFIF getCountry.Country_Code EQ return_bank_Info.Country_Code> SELECTED</CFIF>><cfoutput>#getCountry.Country_Name#</cfoutput></OPTION></CFLOOP></SELECT>&nbsp;  
		
	  <CFELSE>
	  	<INPUT TYPE="text" NAME="Payee_Address1" SIZE="45" VALUE = "<CFOUTPUT>#get_Payee_Info.address1#</CFOUTPUT>"><BR>
	  	<INPUT TYPE="text" NAME="Payee_Address2" SIZE="45" VALUE = "<CFOUTPUT>#get_Payee_Info.address2#</CFOUTPUT>"><BR>
      	<INPUT TYPE="text" NAME="Payee_City" SIZE="24" VALUE = "<CFOUTPUT>#Get_Payee_Info.City#</CFOUTPUT>">&nbsp;
		<SELECT NAME="Payee_State">
			<OPTION VALUE="" SELECTED></OPTION>
			<CFLOOP QUERY="getStates">
				<OPTION VALUE="<CFOUTPUT>#getStates.State_Code#</CFOUTPUT>" <CFIF getStates.State_Code EQ Get_Payee_Info.state_code> SELECTED</CFIF>><CFOUTPUT>#getStates.State_Code#</CFOUTPUT></OPTION>
			</CFLOOP>
		</SELECT>&nbsp;

<!--- 		<INPUT TYPE="text" NAME="Payee_State" SIZE="3" VALUE = "<CFOUTPUT>#Get_Payee_Info.state_code#</CFOUTPUT>">&nbsp; --->
		<INPUT TYPE="text" NAME="Payee_Zipcode" SIZE="7" VALUE = "<CFOUTPUT>#Get_Payee_Info.Zipcode#</CFOUTPUT>"  MAXLENGTH="10"><br>  <!--- ONKEYUP="clenseText(this,'0123456789')" --->
		<SELECT NAME="Payee_Country_Code"><OPTION VALUE="" SELECTED></OPTION><CFLOOP QUERY="getCountry"><OPTION VALUE="<cfoutput>#getCountry.Country_Code#</cfoutput>" <CFIF getCountry.Country_Code eq Get_Payee_Info.Country_Code> SELECTED</CFIF>><cfoutput>#getCountry.Country_Name#</cfoutput></OPTION></CFLOOP></SELECT>&nbsp;  
			
	  </CFIF>
	  </TD>
    </TR>
    <CFIF "#url.trans_type#" EQ 0>
    <TR>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">Bank Name:</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">
	  <CFIF url.bank_info_id NEQ "">
	  	<INPUT TYPE="text" NAME="Payee_Bank_Name" SIZE="45" VALUE = "<CFOUTPUT>#return_Bank_Info.Customer_Bank_Name#</CFOUTPUT>" READONLY>
	  <CFELSE>
	  	<INPUT TYPE="text" NAME="Payee_Bank_Name" SIZE="45" VALUE = "<CFOUTPUT>#Bank_Info.Customer_Bank_Name#</CFOUTPUT>" READONLY>
	  </CFIF>	
	  </TD>
    </TR>

    <TR>
      <TD ALIGN="right" NOWRAP VALIGN="top">Bank Address:</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">
	  
	  <CFIF url.bank_info_id NEQ "">
		<TEXTAREA COLS="47" ROWS="2" NAME="Payee_Bank_Address" <!--- onPaste="javaScript: return restrictLength(this,255);" onKeyPress="javaScript: return restrictLength(this,255);" --->><CFOUTPUT>#return_Bank_Info.Customer_Bank_Address#</CFOUTPUT></TEXTAREA><br>		
<!--- 	  <INPUT TYPE="text" NAME="Payee_Bank_Address" SIZE="40" VALUE = "<CFOUTPUT>#return_Bank_Info.Customer_Bank_Address#</CFOUTPUT>" READONLY><BR> --->

		<CFIF return_Bank_Info.customer_bank_location EQ 1>
		<INPUT TYPE="text" NAME="Payee_Bank_City" SIZE="24"VALUE = "<CFOUTPUT>#return_Bank_Info.Customer_Bank_city#</CFOUTPUT>" READONLY>&nbsp;
		<INPUT TYPE="text" NAME="Payee_Bank_State" SIZE="3" VALUE = "<CFOUTPUT>#return_Bank_Info.Customer_Bank_Statecode#</CFOUTPUT>" READONLY>&nbsp;
		<INPUT TYPE="text" NAME="Payee_Bank_Zipcode" SIZE="7" VALUE = "<CFOUTPUT>#return_Bank_Info.Customer_Bank_Zipcode#</CFOUTPUT>" MAXLENGTH="10" READONLY>
		</CFIF>
	  <CFELSE>	
		<TEXTAREA COLS="47" ROWS="2" NAME="Payee_Bank_Address" <!--- onPaste="javaScript: return restrictLength(this,255);" onKeyPress="javaScript: return restrictLength(this,255);" --->><CFOUTPUT>#Bank_Info.Customer_Bank_Address#</CFOUTPUT></TEXTAREA><br>
<!--- 	  <INPUT TYPE="text" NAME="Payee_Bank_Address" SIZE="40" VALUE = "<CFOUTPUT>#Bank_Info.Customer_Bank_Address#</CFOUTPUT>" READONLY><BR> --->
		<CFIF Bank_info.customer_bank_location EQ 1>
	    <INPUT TYPE="text" NAME="Payee_Bank_City" SIZE="24" VALUE = "<CFOUTPUT>#Bank_Info.Customer_Bank_city#</CFOUTPUT>" READONLY>
		<INPUT TYPE="text" NAME="Payee_Bank_State" SIZE="3" VALUE = "<CFOUTPUT>#Bank_Info.Customer_Bank_Statecode#</CFOUTPUT>" READONLY>&nbsp;
		<INPUT TYPE="text" NAME="Payee_Bank_Zipcode" SIZE="7" VALUE = "<CFOUTPUT>#Bank_Info.Customer_Bank_Zipcode#</CFOUTPUT>" MAXLENGTH="10" READONLY>
		</CFIF>
	  </CFIF>
	  </TD>
    </TR>

    <TR>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">Transit Routing (ABA):</TD>
	
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">
	  <CFIF url.bank_info_id NEQ "">
	  	<INPUT TYPE="text" NAME="transit_routing_no" SIZE="45" VALUE = "<CFOUTPUT>#return_Bank_Info.Customer_Transit_routing_no#</CFOUTPUT>" READONLY>
	  <CFELSE>
	  	<INPUT TYPE="text" NAME="transit_routing_no" SIZE="45" VALUE = "<CFOUTPUT>#Bank_Info.Customer_Transit_routing_no#</CFOUTPUT>" READONLY>
	  </CFIF>
	  </TD>
    </TR>
	</CFIF>
	<INPUT TYPE="hidden" NAME="Pay_By_Order_Of" SIZE="45" VALUE = "<CFOUTPUT>#Pay_By_Order_Of#</CFOUTPUT>">
	<INPUT TYPE="hidden" NAME="Debit_Account_No" SIZE="45" VALUE = "<CFOUTPUT>#Com_Bank_Info.Debit_Account_No#</CFOUTPUT>">
<!---     <TR>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
    </TR>
    <TR>
      <TD NOWRAP COLSPAN="4" VALIGN="bottom" STYLE="border-bottom: 2px solid #000080"><SPAN CLASS="section">Originator Account Information (Silicon Valley)</SPAN></TD>
    </TR>
	 
    <TR>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">Pay by order of: </TD>
      <TD VALIGN="bottom">&nbsp;</TD>
	  <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom"><INPUT TYPE="text" NAME="Pay_By_Order_Of" SIZE="45" VALUE = "<CFOUTPUT>#Pay_By_Order_Of#</CFOUTPUT>" READONLY></TD>
    </TR>
    <TR>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">SVB Debit Account No.:</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
	  <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom"><INPUT TYPE="password" NAME="Debit_Account_No" SIZE="45" VALUE = "<CFOUTPUT>#Com_Bank_Info.Debit_Account_No#</CFOUTPUT>" READONLY></TD>
    </TR>
    <TR>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
	  <TD VALIGN="bottom">&nbsp;</TD>
    </TR>
 --->    <TR><CFSET Note_Max_Length = 1000>
      <TD NOWRAP COLSPAN="4" VALIGN="bottom" STYLE="border-bottom: 2px solid #000080"><SPAN CLASS="section">Notes</SPAN> (limit <cfoutput>#Note_Max_Length#</cfoutput> characters)</TD>
    </TR>
    <TR>
      <TD NOWRAP VALIGN="bottom" COLSPAN="4">
	  
	  <CFOUTPUT><TEXTAREA COLS="95" ROWS="5" NAME="Note" onPaste="javaScript: return textareaChecklength(#Note_Max_Length#, this);"  onkeyPress="javaScript: return textareaChecklength(#Note_Max_Length#, this);">#get_data.memo_field#</TEXTAREA></CFOUTPUT></TD>
    </TR>
   <!---  <TR>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
    </TR>
    <TR>
      <TD ALIGN="right" NOWRAP VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
      <TD VALIGN="bottom">&nbsp;</TD>
    </TR> --->
	<!--- <CFIF "#url.trans_type#" EQ 1> --->
	<TR>
					
	<TD colspan="4" align="center">
		<CFIF application.returned_customer_setting.PayBy_awayX EQ 0>
		<CFOUTPUT>
			<CF_button
				button_name		=	""
				button_caption	=	"prepare payment request"
				button_action	=	"validate1()"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				>
		</CFOUTPUT>

		<CFELSE>
		<CFOUTPUT>
			<CF_button
				button_name		=	""
				button_caption	=	"make payment"
				button_action	=	"validate()"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				>
		</CFOUTPUT>

		</CFIF>
	</TD>
</TR>

<!--- 	<TR>
	  <TD ALIGN="right" NOWRAP VALIGN="bottom">&nbsp;&nbsp;<INPUT TYPE="Submit" VALUE="Check Payment"></TD>
	</TR>
 --->	<!--- <CFELSEIF "#url.trans_type#" EQ 0>
 <TR>
					
	<TD colspan="3" align="center">
		<CFOUTPUT>
			<CF_button
				button_name		=	""
				button_caption	=	"make payment"
				button_action	=	"validate()"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				>
		</CFOUTPUT>
	</TD>
</TR>

	<!--- <TR>
	  <TD ALIGN="right" NOWRAP VALIGN="bottom">&nbsp;&nbsp;<INPUT TYPE="Submit" VALUE="Wire Transfer"></TD>
	</TR> --->
	</CFIF> --->
  </TABLE>
</CENTER>
</FORM> 
<script>
	var url = '<cfoutput>#lcase(cgi.script_name)#</cfoutput>';
   {
	try { window.parent.dyniframesize(); } catch (err) { };
   }
</script>
</BODY>

</HTML>

 