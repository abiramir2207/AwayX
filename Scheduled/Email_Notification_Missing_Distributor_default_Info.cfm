<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfinvoke component="components.settings.ApplicationSettingsManager" method="get" returnVariable="VarAppSetting">

<!--- Only for Tobersoft Billbacks (Heinz) --->
<cfif VarAppSetting.getThirdPartyBBUpload() eq 2>

<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">

 <!--- Find customers who do not have either a  default vendor id or a default billback closing method --->
<cfquery name="qGetMissingBillbackInfoCustomers" datasource="#application.datasource#">
SELECT DISTINCT bsafc.Shr_Ship_To,bsafc.Name,bsafc.Default_Vendor_ID,bsafc.Default_Billback_Closing_Method_ID
FROM BSA_Foodservice_Customers bsafc
<!--- Only for the customers loaded with the Tibersoft billbacks --->
INNER JOIN Billback_Txt_Upload_Header_log btuhl
on bsafc.BSA_Foodservice_Customers_ID = btuhl.Distributor_ID
WHERE bsafc.Deleted = 0
AND bsafc.Active_Code = 'A'
<!--- Tibersoft billbacks --->
AND btuhl.IS_III_PU = 1
AND 
(
 isnull(nullif(bsafc.Default_Vendor_ID,''),0) = 0 OR isnull(nullif(bsafc.Default_Billback_Closing_Method_ID,''),0) = 0 
)
<!--- billbacks created in the last 7 days --->
AND Datediff(d,btuhl.Created_Date,getdate()) <= 7
ORDER BY bsafc.Shr_Ship_To
</cfquery>

<!--- Find billbacks whose customers do not either a  default vendor id or a default billback closing method --->
<!--- 26298 ChrisN 02/18/2011 - include operators without default vendor or default bb closing method --->
<cfscript>
  distributor_type = 1;
  operator_type    = 2;
</cfscript>
<cfquery name="qGetMissingBillbackInfoBillbacks" datasource="#application.datasource#">
  SELECT DISTINCT Bb.Bb_code,
                  Bb.Bb_title,
                  Bb.Billback_payee_type_id,

                  CASE Bb.Billback_payee_type_id
                    WHEN #distributor_type#  THEN Bsafc.Name
                    WHEN #operator_type#     THEN Bo.Operator_name
                  END AS Name,

                  CASE Bb.Billback_payee_type_id
                    WHEN #distributor_type#  THEN Bsafc.Shr_ship_to
                    WHEN #operator_type#     THEN Coalesce( Bo.Legacy_id, Bo.Bsa_operator_id )
                  END AS Shr_Ship_To,

                  CASE Bb.Billback_payee_type_id
                    WHEN #distributor_type#  THEN Bsafc.Default_vendor_id
                    WHEN #operator_type#     THEN Bo.Default_vendor_id
                  END AS Default_vendor_id,

                  CASE Bb.Billback_payee_type_id
                    WHEN #distributor_type#  THEN Bsafc.Default_billback_closing_method_id
                    WHEN #operator_type#     THEN Bo.Default_billback_closing_method_id
                  END AS Default_billback_closing_method_id

  FROM   Billback Bb
         LEFT JOIN Billback_distributor Bbd
           ON Bb.Billback_id = Bbd.Billback_id AND Bbd.Deleted = 0
         LEFT JOIN Bsa_foodservice_customers Bsafc
           ON Bbd.Distributor_id = Bsafc.Bsa_foodservice_customers_id
         LEFT JOIN Billback_operator Bbo
           ON Bb.Billback_id = Bbo.Billback_id AND Bbo.Deleted = 0
         LEFT JOIN Bsa_operator Bo
           ON Bbo.Operator_id = Bo.Bsa_operator_id

  WHERE  Bb.Deleted = 0
         AND BB.Uploaded_Billback = 3
         AND Bb.Billback_status_id NOT IN ( 5, 8 )
         AND ( ( Bb.Billback_payee_type_id = #distributor_type#
                 AND ( Isnull(Nullif(Bsafc.Default_vendor_id, ''), 0) = 0
                        OR Isnull(Nullif(Bsafc.Default_billback_closing_method_id, ''), 0 ) = 0 ) )
               OR 
               ( Bb.Billback_payee_type_id = #operator_type#
                 AND ( Isnull(Nullif(Bo.Default_vendor_id, ''), 0) = 0
                        OR Isnull(Nullif(Bo.Default_billback_closing_method_id, ''), 0) = 0 ) ) )
         AND Datediff(D, Bb.Created_date, Getdate()) <= 7
  ORDER  BY Bb.Bb_code  
</cfquery>

<cfset useLakebaseForqGetEmailInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForqGetEmailInfo>
	<cftry>
		<cfset qGetEmailInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "send_new_distributor_default_vendor_email"
			}), "send_new_distributor_default_vendor_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetEmailInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetEmailInfo>
<cfquery name="qGetEmailInfo" datasource="#application.datasource#">
SELECT Send_New_Distributor_Default_Vendor_Email
FROM General_Settings
</cfquery>
</cfif>

<!--- Attach the style sheet to the email content --->
<CFSET EmailDetailsCustomerDefaultVendorID = "<STYLE>
.Header
	{
		font-size: 14px;
		font-family:'Century Gothic', Verdana, Arial;
		font-weight:bold;
	}

.Content
	{
		font-size: 13px;
		font-family:'Century Gothic', Verdana, Arial;
	}
</STYLE>">


<!--- BEGIN - (Customers who do not have either a  default vendor id or a default billback closing method) --->
<CFSET EmailDetailsCustomerDefaultVendorID = EmailDetailsCustomerDefaultVendorID & "<span class='Header'>Customers without a default vendor id</span><br /><br />">
<CFSET EmailDetailsCustomerDefaultBillbackClosingMethod = "<br /><br /><span class='Header'>Customers without a default billback closing method</span><br /><br />">

<CFSET EmailDetailsCustomerDefaultVendorIDCount = 0>
<CFSET EmailDetailsCustomerDefaultBillbackClosingMethodCount = 0>

<cfoutput query="qGetMissingBillbackInfoCustomers">

	<cfif Default_Vendor_ID eq "">
		<CFSET EmailDetailsCustomerDefaultVendorIDCount = EmailDetailsCustomerDefaultVendorIDCount + 1>
		<CFSET EmailDetailsCustomerDefaultVendorID = EmailDetailsCustomerDefaultVendorID
		 & "<span class='Content'>#EmailDetailsCustomerDefaultVendorIDCount#. #Shr_Ship_To# #Name#</span> <br />">
	</cfif>

	<cfif Default_Billback_Closing_Method_ID eq "">
		<CFSET EmailDetailsCustomerDefaultBillbackClosingMethodCount = EmailDetailsCustomerDefaultBillbackClosingMethodCount + 1>
		<CFSET EmailDetailsCustomerDefaultBillbackClosingMethod = EmailDetailsCustomerDefaultBillbackClosingMethod
		 & "<span class='Content'>#EmailDetailsCustomerDefaultBillbackClosingMethodCount#. #Shr_Ship_To# #Name#</span> <br />">
	</cfif>

</cfoutput>

<!--- If there are no customers with missing default vendor id info --->
<cfif EmailDetailsCustomerDefaultVendorIDCount eq 0>
	<cfset EmailDetailsCustomerDefaultVendorID = EmailDetailsCustomerDefaultVendorID & "None">
</cfif>

<!--- If there are no customers with missing bb closing method info --->
<cfif EmailDetailsCustomerDefaultBillbackClosingMethodCount eq 0>
	<cfset EmailDetailsCustomerDefaultBillbackClosingMethod = EmailDetailsCustomerDefaultBillbackClosingMethod & "None">
</cfif>
<!---END - (Customers who do not have either a  default vendor id or a default billback closing method) --->


<!--- BEGIN - (Billbacks whose customers do not have either a  default vendor id or a default billback closing method) --->
<CFSET EmailDetailsBillbackDefaultVendorID = "<br /><br /><span class='Header'>3rd party billbacks without a default vendor id</span><br /><br />">
<CFSET EmailDetailsBillbackDefaultBillbackClosingMethod = "<br /><br /><span class='Header'>3rd party billbacks without a default billback closing method</span><br /><br />">

<CFSET EmailDetailsBillbackDefaultVendorIDCount = 0>
<CFSET EmailDetailsBillbackDefaultBillbackClosingMethodCount = 0>

<cfoutput query="qGetMissingBillbackInfoBillbacks">

	<cfif Default_Vendor_ID eq "">
		<CFSET EmailDetailsBillbackDefaultVendorIDCount = EmailDetailsBillbackDefaultVendorIDCount + 1>
		<CFSET EmailDetailsBillbackDefaultVendorID = EmailDetailsBillbackDefaultVendorID
		 & "<span class='Content'>#EmailDetailsBillbackDefaultVendorIDCount#. #bb_code# #bb_title# #Shr_Ship_To# #Name#</span> <br />">
	</cfif>

	<cfif Default_Billback_Closing_Method_ID eq "">
		<CFSET EmailDetailsBillbackDefaultBillbackClosingMethodCount = EmailDetailsBillbackDefaultBillbackClosingMethodCount + 1>
		<CFSET EmailDetailsBillbackDefaultBillbackClosingMethod = EmailDetailsBillbackDefaultBillbackClosingMethod
		 & "<span class='Content'>#EmailDetailsBillbackDefaultBillbackClosingMethodCount#. #bb_code# #bb_title# #Shr_Ship_To# #Name#</span> <br />">
	</cfif>

</cfoutput>

<!--- If there are no billbacks whose customers have missing default vendor id info --->
<cfif EmailDetailsBillbackDefaultVendorIDCount eq 0>
	<cfset EmailDetailsBillbackDefaultVendorID = EmailDetailsBillbackDefaultVendorID & "None">
</cfif>

<!--- If there are no billbacks whose customers have missing bb closing method info --->
<cfif EmailDetailsBillbackDefaultBillbackClosingMethodCount eq 0>
	<cfset EmailDetailsBillbackDefaultBillbackClosingMethod = EmailDetailsBillbackDefaultBillbackClosingMethod & "None">
</cfif>
<!--- END- (Billbacks whose customers do not have either a  default vendor id or a default billback closing method) --->

               
<cfoutput>

<!--- Send out the email only if there are some records which have missing info --->
<cfif EmailDetailsCustomerDefaultVendorIDCount neq 0 OR EmailDetailsCustomerDefaultBillbackClosingMethodCount neq 0
OR EmailDetailsBillbackDefaultVendorIDCount neq 0 OR EmailDetailsBillbackDefaultBillbackClosingMethodCount neq 0>
<CF_EMAILWRAPPER TO		=	"#qGetEmailInfo.Send_New_Distributor_Default_Vendor_Email#"
			        FROM		=	"#Contact_Admin_Email_Address#"
			        SUBJECT	=	"Records without a default vendor id or a billback default closing method"
					messagetype="1" 
					generatedby="1" 
					apparea="3" >

#EmailDetailsCustomerDefaultVendorID#

#EmailDetailsCustomerDefaultBillbackClosingMethod#

#EmailDetailsBillbackDefaultVendorID#

#EmailDetailsBillbackDefaultBillbackClosingMethod#
</CF_EMAILWRAPPER>
</cfif>
</cfoutput>
</cfif>