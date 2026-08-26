	<cfquery name="GetAllContractInfo" datasource="#application.datasource#">
		SELECT * 
		FROM Contract_Main
		WHERE Contract_Main_ID = #hack_Contract_Main_ID#
	</cfquery>
	
	<cfquery name="GetAllContractProducts" datasource="#application.datasource#">
		SELECT dbo.BSA_Foodservice_Items_Master.*, 
		    dbo.Contract_Products.Discount_Value
		FROM dbo.Contract_Products INNER JOIN
		    dbo.BSA_Foodservice_Items_Master ON 
		    dbo.Contract_Products.Product_UPC = dbo.BSA_Foodservice_Items_Master.UPC
		WHERE (dbo.Contract_Products.Contract_Main_ID = #hack_Contract_Main_ID#)
	</cfquery>

	<cfquery name="GetContractBrokers" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Brokers
		WHERE BSA_Foodservice_Brokers_ID IN(#GetAllContractInfo.Broker_IDs#)
	</cfquery>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get UOM description																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	
<cfset useLakebaseForGetUOMDesc = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForGetUOMDesc>
	<cftry>
		<cfset Get_UOM_Desc = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", { "select" = "unit_of_measure_desc", "unit_of_measure_id" = "eq.#GetAllContractInfo.Contract_Quantity_UOM_IDX#" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUOMDesc = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUOMDesc>
	<CFQUERY NAME="Get_UOM_Desc" datasource="#application.datasource#">
	Select		Unit_of_Measure_Desc
	From		Units_Of_Measure
	Where		Unit_of_Measure_ID		=	'#GetAllContractInfo.Contract_Quantity_UOM_IDX#'
	</CFQUERY>
</cfif>

	

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Capture in a variable the content to be displayed and later emailed							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfsavecontent variable = "var">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Contract <CFOUTPUT>#GetAllContractInfo.Contract_Number#</CFOUTPUT></TITLE>
	<STYLE>
		BODY, TD, .normal{font-family : Arial; font-size : 8pt; color : Black;		}
	</STYLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="20" TOPMARGIN="10">
	<cfoutput>
	<TABLE BORDER="0" CELLSPACING="6" CELLPADDING="0">
		<TR>
			<TD align="right" nowrap><B>Contract Number:</B></TD>
			<TD rowspan="16" bgcolor="Orange">&nbsp;</TD>
			<TD><FONT SIZE="+1">#GetAllContractInfo.Contract_Number#</FONT></TD>
		</TR>
		<TR>
			<TD align="right" nowrap><B>Contract Ref. Number:</B></TD>
			<TD>#GetAllContractInfo.Contract_Reference_Number#</TD>
		</TR>
		<TR>
			<TD align="right" nowrap><B>Contract Title:</B></TD>
			<TD>#GetAllContractInfo.contract_title#</TD>
		</TR>
		<TR>
			<TD ALIGN="right" valign="top"><B>Brokers</B></TD>
			<TD>
				<cfloop query="GetContractBrokers">
					#trim(Broker_Name)#<BR>
				</CFLOOP>
			</TD>
		</TR>
		<TR>
			<TD align="right" nowrap VALIGN="top"><B>Contract Span:</B></TD>
			<TD>
				Start Date: #GetAllContractInfo.Contract_start_date#<BR>
				End Date: #GetAllContractInfo.Contract_end_date#			
			</TD>
			
		</TR>
		<TR>
			<TD align="right" nowrap><B>Dist.Brand Eligibility:</B></TD>
			<TD>
				<CFIF GetAllContractInfo.Dist_Brand_Eligibility EQ 1>Yes<CFELSE>No</CFIF>
			</TD>
		</TR>
		<TR>
			<TD align="right" nowrap><B>Discount Type:</B></TD>
			<TD>
				#GetAllContractInfo.Discount_Type_ID#
			</TD>
		</TR>
		<TR>
			<TD align="right" nowrap><B>Quantity:</B></TD>
			<TD>#numberformat(GetAllContractInfo.Contract_Quantity, '_,___,___,___,___')#</TD>
		</TR>
		<TR>
			<TD align="right" nowrap><B>U.O.M:</B></TD>
			<TD>#Get_UOM_Desc.Unit_of_Measure_Desc#</TD>
		</TR>
		<CFIF isdefined("HideProducts")>
		<CFELSE>
		<TR>
			<TD align="right" nowrap valign="top"><B>Products:</B></TD>
			<TD>
				<TABLE cellspacing="0" cellpadding="5" WIDTH="600">
					<TR bgcolor="000080" VALIGN="bottom">
						<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD><B><FONT COLOR="White">UPC Code</FONT></B></TD></cfif></cfif>
						<TD><B><FONT COLOR="White">Description</FONT></B></TD>
						<TD><B><FONT COLOR="White">Brand</FONT></B></TD>
						<TD><B><FONT COLOR="White">Case<BR>Count</FONT></B></TD>
						<TD><B><FONT COLOR="White">Pack<BR>Size</FONT></B></TD>
						<TD><B><FONT COLOR="White">UOM</FONT></B></TD>
						<TD><B><FONT COLOR="White" id="DTH">#Application.RebateLabel#<BR>Case</FONT></B></TD>
					</TR>
					<cfloop query="GetAllContractProducts">
						<tr bgcolor="#IIF(GetAllContractProducts.currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">
							<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD>#GetAllContractProducts.UPC#</TD></cfif></cfif>
							<TD>#GetAllContractProducts.Description#</TD>							
							<TD>#GetAllContractProducts.Brand#</TD>
							<TD>#GetAllContractProducts.Case_Count#</TD>
							<TD>#GetAllContractProducts.Pack_Size#</TD>
							<TD>#GetAllContractProducts.Pack_Size_UOM#</TD>
							<TD>#dollarformat(GetAllContractProducts.Discount_Value)#&nbsp;</TD>
						</TR>
					</CFLOOP>
				</TABLE>			
			</TD>
		</TR>
		</CFIF>
	</TABLE>
	</cfoutput>
</BODY>
</HTML>
</cfsavecontent> 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Date/Time stamp construction																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Create the name of the file that will be created...											 --->
<!--- It uses the following mask: contract number_month,day,year,hour,minutes,seconds				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET filename="#GetAllContractInfo.Contract_Number#_#datetimestamp#">

	<!--- get install path --->	
	<CFSET InstallPath = APPLICATIONPATH>
	<!--- END get install path --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Complete path of the file to be saved and later emailed...									 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET completepath="#Application.Doc_Path#\temp_files\contracts\contract_documents\#filename#.htm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Create the contract in static HTML format														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cffile action="write" file="#completepath#" output="#var#">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Display the contract details																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#/temp_files/contracts/contract_documents/#filename#.htm">







<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Encrypt list of brokers																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_cryp type="en" string="#GetAllContractInfo.Broker_IDs#" key="#request.key#">
<!--- The output produced is the variable #cryp.value# --->
<CFSET broker_list=cryp.value>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Encrypt Contract Title																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_cryp type="en" string="#GetAllContractInfo.Contract_Number#" key="#request.key#">
<!--- The output produced is the variable #cryp.value# --->
<CFSET contract_title=cryp.value>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Encrypt Contract filename_date 																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_cryp type="en" string="#filename#" key="#request.key#">
<!--- The output produced is the variable #cryp.value# --->
<CFSET filename=cryp.value>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- BID	=	Broker id's, CID	=	Contract file name											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Link to the contract in static HTML format													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<P ALIGN="right">
<CFOUTPUT>
<FONT SIZE="+1">
<FONT COLOR="ORANGE" SIZE="4"><B>[</B></FONT>
<A HREF="contract_create_email.cfm?BID=#broker_list#&TID=#contract_title#&CID=#filename#">create email package</A>
<FONT COLOR="ORANGE" SIZE="4"><B>]</B></FONT>
</FONT>
</CFOUTPUT>
</P>

<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Email the contract to the following address													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFMAIL TO="#request.AccessStructure.User_Email#"
        FROM="Awayx@awayx.com"
        SUBJECT="Contract #GetAllContractInfo.Contract_Number# #datetimestamp#"
        MIMEATTACH="#completepath#"
        SERVER="smtp.clipboardsolutions.com"
        TYPE="HTML">
		#var#
</CFMAIL>
 --->



	