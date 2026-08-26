<cfparam name="url.editMode" default="0" />
<cfparam name="url.forceCachedView" default="0" />
<cfparam name="CID" default="">
<cfparam name="Export_Sales_Agreement_ID" default="">
<cfparam name="Type" default="">

<cf_cryp type="de" key="#request.key#" string="#CID#">

<cfif len(CID) NEQ 0>
<cfset Export_Sales_Agreement_ID = cryp.value>
</cfif>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement_AJAX") />
<cfset Agreement_Manager = CreateObject("component","components.Export.Sales_Agreement") />
<cfset viewProgramManager = createObject("component","components.programs.Display_Program.viewprogramtemplateManager") />

<cfif Export_Sales_Agreement_ID neq "">
	<!--- Get the sales agreement details --->
	<cfset selExportSalesAgreement = Agreement_Details.getExportSalesAgreement('#Export_Sales_Agreement_ID#')>
		<cfif selExportSalesAgreement.Export_Distributor_ID neq "">
			<!--- Get the customer details --->
			<cfset CustomerDetails = Agreement_Details.getCustomerDetails('#selExportSalesAgreement.Export_Distributor_ID#')>
		</cfif>

		<cfif selExportSalesAgreement.recordcount>
			<cfset Export_Sales_Agreement_ID= selExportSalesAgreement.Export_Sales_Agreement_ID>
			<cfset Export_Sales_Agreement_Number= selExportSalesAgreement.Export_Sales_Agreement_ID& '-' & selExportSalesAgreement.Export_ASI_Contract_Number>
		</cfif>
</cfif>

<!--- Name two files - Internal (Private) and External (Public) --->
<cfset sProgramViewCacheFileName1 = "Export_Programs_View_Private_#Export_Sales_Agreement_ID#.htm" />
<cfset sProgramViewCacheFileName2 = "Export_Programs_View_Public_#Export_Sales_Agreement_ID#.htm" />

<cfif (url.editMode eq 0 AND url.forceCachedView EQ 0) OR NOT fileexists("#Application.Doc_Path#\Temp_Files\Program\Export_Programs_#sProgramViewCacheFileName1#") OR Type neq "">

<cfsavecontent variable="PublicData">
<style type="text/css">	
	.ProductTableHeader
	{
		font-family:Arial;
		font-size:11px;
		font-weight:bold;
		border-bottom:solid #93BEE2 1px;
	}
	.TableHeader
	{
		font-family:Arial;
		font-size:11px;
	}	
	.TableData
	{
		font-family:Arial;
		font-size:10px;
	}
	</style>

<cfoutput>
<table  border="0" align ="center" cellpadding="2" cellspacing="0" width="800" class="TableHeader">
	<tr>
		<td colspan="2" class="TableHeader"><b>SALES AGREEMENT ##:<b> #selExportSalesAgreement.Export_Sales_Agreement_Number#</td>
	</tr>
	<tr>
		<td class="TableHeader">LAMB-WESTON<br />
				8701 GAGE BLVD., KENNEWICK, WA 99336<br />	
				PO BOX 1900,  PASCO, WA 99302<br />	
				(509) 735-4651
		</td>
		<td class="TableHeader">
					<b>EFFECTIVE DATE:</b>	#DateFormat(selExportSalesAgreement.Export_Start_Date,"MM/DD/YYYY")# 
				<cfif selExportSalesAgreement.Export_End_Date neq "">
						- #DateFormat(selExportSalesAgreement.Export_End_Date,"MM/DD/YYYY")#
				</cfif><br />
						<b>LAST MODIFIED DATE:</b> #DateFormat(selExportSalesAgreement.Approval_Date,"MM/DD/YYYY")#<br />
						<b>TERMS OF SALE:</b>
				<cfif trim(selExportSalesAgreement.Export_lookup_Terms_of_Sale_Desc) neq "">
						#selExportSalesAgreement.Export_lookup_Terms_of_Sale_Desc#, #selExportSalesAgreement.Named_Place#
				<cfelse>
						None
				</cfif><br />
						
				<cfif trim(selExportSalesAgreement.Mexican_Port) neq "">
						<b>MEXICO FREIGHT PREPAID:</b>
						#selExportSalesAgreement.Mexican_Port#<br />
				</cfif>
						<b>INVOICE TERMS:</b>
				<cfif trim(selExportSalesAgreement.PayTermsDesc) neq "">
						#selExportSalesAgreement.PayTermsDesc#
				<cfelse>
						None
				</cfif>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td valign="top" class="TableHeader">
					<b>SOLD TO:</b><br/>
				<cfif Trim(selExportSalesAgreement.Export_Distributor_ID) neq "">
					#CustomerDetails.Dist_Bill_To_Name# [#selExportSalesAgreement.Export_Shr_Bill_To#]<br />
					#CustomerDetails.Dist_Bill_To_Address_1#<br />
					#CustomerDetails.Dist_Bill_To_Address_2#
					#CustomerDetails.Dist_Bill_To_City#,#CustomerDetails.Dist_Bill_To_State#,#CustomerDetails.Dist_Bill_To_ZipCode#
				<cfelse>
					None
				</cfif>
		</td>
		<td valign="top" class="TableHeader"><b>ORIGIN:</b>
				<cfif selExportSalesAgreement.Export_Lookup_Origin_Desc neq "">
					#selExportSalesAgreement.Export_Lookup_Origin_Desc#
				<cfelse>
					None
				</cfif>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td valign="top" class="TableHeader"><b>SHIP TO:</b><br/>
				<cfif Trim(selExportSalesAgreement.Export_Distributor_ID) neq "">
					#CustomerDetails.Name# [#selExportSalesAgreement.Export_Shr_Ship_To#]<br />
					#CustomerDetails.Address_1#<br />
					#CustomerDetails.Address_2#
					#CustomerDetails.City#,#CustomerDetails.State#,#CustomerDetails.ZipCode#
				<cfelse>
					None
				</cfif>
		</td>
		<td valign="top" class="TableHeader"><b>NOTIFY PARTY:</b><br />	
				#Replace(selExportSalesAgreement.Export_Notify_Party,"#chr(13)##chr(10)#","<br />", "ALL")#
		</td>
	</tr>
</table>
</cfoutput>
<P>

<!--- Get the products where Sale Unit Price is not zero --->
<cfset getProductDetails = Agreement_Details.getProductDetails(Export_Sales_Agreement_ID,1)>

	<table  border="0" align ="center" cellpadding="2" cellspacing="0" width="800">
		<tr>
			<td colspan="100%" class="TableHeader"><B>SALES UNIT PRICE</B></td>
		</tr>
		<tr bgcolor="ffce84">
			<td width="15%" class="ProductTableHeader">Item</td>
			<td width="30%" class="ProductTableHeader">Description</td>
			<td width="10%" class="ProductTableHeader">End User</td>
			<td width="5%"  class="ProductTableHeader">Volume</td>
			<td width="10%" class="ProductTableHeader">Price US$</td>
			<td width="30%" class="ProductTableHeader">Notes</td>
		</tr>

<cfoutput query="getProductDetails">
	<cfset rowcount = getProductDetails.currentrow>
	<cfset Export_Sale_Unit_Price_CS = NumberFormat(val(Export_Sale_Unit_Price) * val(Net_Weight),',.9999')>

		<tr BGCOLOR="#IIf(rowcount Mod 2, DE('C6FFC6'), DE('ffffff'))#">
			<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Item#</td>
			<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Description#</td>
			<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Export_End_User#</td>
			<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Export_Volume_Limit#</td>
			<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Export_Sale_Unit_Price#/LB <br />&nbsp;#Export_Sale_Unit_Price_CS#/CS</td>
			<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Export_Notes#</td>			
		</tr>
</cfoutput>
	</table>

<cfset getStandardCosts = Agreement_Manager.getStandardCosts(Export_Sales_Agreement_ID)>
<cfset getFreightCosts = Agreement_Manager.getFreightCosts(Export_Sales_Agreement_ID)>
<cfset getMiscCosts = Agreement_Manager.getMiscCosts(Export_Sales_Agreement_ID)>

<P>
<table  border="0" align ="center" cellpadding="2" cellspacing="0" width="800">
	<tr>
		<td colspan="100%" class="TableHeader"><B>INVOICE CHARGES</B></td>
	</tr>
	<tr  bgcolor="ffce84">
		<td width="80%" class="ProductTableHeader">Description</td>
		<td width="20%" align="center" class="ProductTableHeader">Rate US$</td>
	</tr>
	
<cfoutput query="getFreightCosts">
<!--- Show Additional Freight Costs (Invoice Charges) --->
<cfif Export_Additional_Freight_Cost neq 0>
	<tr BGCOLOR="#'C6FFC6'#">
		<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;Total Freight costs</td>
		<td align="center" style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Export_Additional_Freight_Cost#</td>
	</tr>
</cfif>

<!--- Show Additional Inland Fuel Surcharge (Invoice Charges) --->
<cfif Export_Additional_Inland_Fuel_Surcharge neq 0>
	<tr BGCOLOR="#'ffffff'#">
		<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;Inland Fuel Surcharge</td>
		<td align="center" style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Export_Additional_Inland_Fuel_Surcharge#</td>
	</tr>
</cfif>

<!--- Show Additional Ocean Fuel Surcharge (Invoice Charges) --->
<cfif Export_Additional_Ocean_Fuel_Surcharge neq 0>
	<tr BGCOLOR="#'C6FFC6'#">
		<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;Ocean Fuel Surcharge</td>
		<td align="center" style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Export_Additional_Ocean_Fuel_Surcharge#</td>
	</tr>
</cfif>
</cfoutput>

<cfoutput query="getStandardCosts">
<!--- Show Standard Costs and Additional Standards Costs (Invoice Charges) --->
	<cfset rowcount = getStandardCosts.currentrow>
	<tr BGCOLOR="#IIf(rowcount Mod 2, DE('ffffff'), DE('C6FFC6'))#">
		<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Export_Lookup_Cost_Desc#</td>
		<td align="center" style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Export_Additional_Cost#</td>
	</tr>
</cfoutput>

<cfif IsDefined("rowcount") AND rowcount MOD 2 EQ 0>
	<cfset FirstColor = 'ffffff'>
	<cfset SecondColor = 'C6FFC6'>
<cfelse>
	<cfset FirstColor = 'C6FFC6'>
	<cfset SecondColor = 'ffffff'>
</cfif>

<cfoutput query="getMiscCosts">
<!--- Show Miscellaneous Costs and Additional Miscellaneous Costs (Invoice Charges) --->
	<cfset rowcount = getMiscCosts.currentrow>
	<tr BGCOLOR="#IIf(rowcount Mod 2, DE(FirstColor), DE(SecondColor))#">
		<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Export_Misc_Cost_Desc#</td>
		<td align="center" style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Export_Misc_Cost#</td>
	</tr>
</cfoutput>
</table>

<P>

	<cfset getNotes = Agreement_Manager.getNotes(Export_Sales_Agreement_ID)>

<!--- Show Terms & Conditions --->
<table border="0" align="center" cellpadding="2" cellspacing="0" width="800">
	<tr>
		<td class="Tableheader"><B>Terms & Conditions</B></td>
	</tr>
	<cfif Trim(getNotes.Export_Special_Conditions) neq "">
	<tr>
		<td class="TableData">Special Conditions:<br /><cfoutput query="getNotes">#Replace(Export_Special_Conditions,"#chr(13)##chr(10)#","<br />", "ALL")#</cfoutput></td>
	</tr>
	</cfif>
	<tr>
		<td class="TableData"> 
			<cfif selExportSalesAgreement.Export_Agreement_Validity eq 1>Price is subject to change at any time with 30 days notice.</cfif>
			<cfif selExportSalesAgreement.Export_Agreement_Validity eq 2>Prices are valid for the validity period shown.</cfif>
		</td>
	 </tr>	
	 <tr>
		<td class="TableData"> 
	 		Freight and fuel charges are subject to change.
	 	</td>
	 </tr>	
	 <tr>
		<td class="TableData"> 
		<cfswitch expression="#selExportSalesAgreement.Export_lookup_Terms_of_Sale_Desc#">
			<cfcase value="EXW">EXW (Ex-Works named place) - Seller delivers when goods are placed at the disposal of the buyer at the named warehouse facility, not cleared for export and not loaded onto any collecting vehicle.</cfcase>
			<cfcase value="FOB">FOB (Free On Board named port of shipment) - Seller delivers when the goods pass the ship's rail at the named port of shipment cleared for export.  Buyer bears all costs and risks of loss of or damage to the goods from that point.</cfcase>
			<cfcase value="CFR">CFR (Cost and Freight named port of destination) - Seller delivers when the goods pass the ship's rail at the port of shipment.  Seller must pay the costs and freight necessary to bring the goods to the named port of destination but the risk of loss of or damage to the goods, as well as any additional costs due to events occurring after the time of delivery, are transferred from the seller to the buyer upon delivery at the port of shipment. CFR requires the seller to clear the goods for export.</cfcase>
			<cfcase value="CIF">CIF (Cost Insurance and Freight named port of destination) - Seller delivers when the goods pass the ship's rail at the port of shipment.  Seller must pay the costs and freight necessary to bring the goods to the named port of destination but the risk of loss of or damage to the goods, as well as any additional costs due to events occurring after the time of delivery, are transferred from the seller to the buyer upon delivery at the port of shipment.  However, in CIF the seller also has to procure marine insurance against the buyer's risk of loss or damage to the goods during the carriage.  Consequently the seller contracts for insurance and pays the insurance premium.  The buyer should note only minimum cover is required.  CIF requires the seller to clear the goods for export.</cfcase>
			<cfcase value="DAF">DAF (Delivered At Frontier named place) - Seller delivers when the goods are placed at the disposal of the buyer on the arriving means of transport not unloaded, cleared for export, but not cleared for import at the named point and place at the frontier, but before the customs border of the adjoining country.  The term "frontier" must be named precisely; point and place.</cfcase>
			<cfcase value="DES">DES (Delivered Ex-Ship named port of destination) - Seller delivers when the goods are placed at the disposal of the buyer on board the ship not cleared for import at the named port of destination.  The seller bears all costs and risks involved in bringing the goods to the named port of destination before discharging.</cfcase>
			<cfcase value="DDU">DDU (Delivered Duty Unpaid named place of destination) - Seller delivers the goods to the buyer, not cleared for import, and not unloaded from any arriving means of transport at the named place of destination.  The seller has to bear the costs and risks involved in bringing the goods thereto, other than any "duty" (including responsibility for and risks of the carrying out of customs formalities, and the payment of formalities, customs duties, taxes and other charges) for import in the country of destination.  Such "duty" must be borne by the buyer as well and any costs and risks caused by his failure to clear the goods for import in time.</cfcase>
		</cfswitch>
		</td>
	 </tr>
	</table>
</cfsavecontent>

<cfsavecontent variable="PrivateData">

<P>

<cfset getProductDetails = Agreement_Details.getProductDetails(Export_Sales_Agreement_ID,2)>

<!--- Show Accrual Information --->
<table  border="0" align ="center" cellpadding="2" cellspacing="0" width="800">
	<tr>
		<td colspan="100%" class="TableHeader"><B>ACCRUAL</B></td>
	</tr>
	<tr bgcolor="ffce84">
		<td class="ProductTableHeader">Item</td>
		<td class="ProductTableHeader">Description</td>
		<td class="ProductTableHeader">Rate US$</td>
	</tr>

<cfoutput query="getProductDetails">
	<cfset rowcount = getProductDetails.currentrow>
	<tr BGCOLOR="#IIf(rowcount Mod 2, DE('C6FFC6'), DE('ffffff'))#">
		<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Item#</td>
		<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Description#</td>
		<td style="border-bottom:solid ##93BEE2 1px;" class="TableData">&nbsp;#Export_Accrual#</td>		
	</tr>
</cfoutput>
</table>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Documents																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif isdefined("request.AccessStructure.name_first")>
<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">

<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>
<cfset Att_display  = Agreement_Manager.Att_display(Export_Sales_Agreement_ID,Access_Position_List)>

<CFIF Att_display.recordcount GT 0>
	
	<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />
	
	<!----- 
	please don't remove the following comment, 
	attachmentstart (and it only needs 2 dashs like html comment, it is purposely done)
	it is used in a regular expression
	to remove the attachment area from the email and fax.
	If any questions, please contact Deepa first before editing :)
	--------------->
	<!--attachmentstart-->
	<cfoutput>
		<table>
		 <tr><td>&nbsp;</td></tr>
		</table>
		<table  border="0" align ="center" cellpadding="2" cellspacing="0" width="800">
		<tr>
		<td colspan="100%" class="TableHeader"><B>Attached Documents</B></td>
	    </tr>
					<!--- TABLE HEADERS --->
					<TR BGCOLOR="##FFCE84" VALIGN="bottom">
					
						<TD ID="header"><FONT SIZE="1"><B>DATE<br>NAME</B></FONT></TD>
						<TD ID="header" ><FONT SIZE="1"><B>FILE</B></FONT></TD>
						<TD ID="header" ><FONT SIZE="1"><B>TITLE<br>DESCRIPTION</B></FONT></TD>
						<TD ID="header"><FONT SIZE="1"><B>TYPE</B></FONT></TD>		
					</TR></cfoutput>
					<CFOUTPUT QUERY="Att_display">
						<!--- DATA OUTPUT --->
						<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
						<cfset User_Name  = ViewProgramManager.User_Name(Uploaded_By)>
							<CFSET SIZEinMB = #Doc_size#/1024>
							<TD ID="" WIDTH="16%">#DateFormat(Uploaded_Date,"mm/dd/yyyy")#<BR>#User_Name.Name_First# #User_Name.Name_Last#&nbsp;</TD>
							<TD NOWRAP ID="" TITLE="File Name: #Doc_File_Name#"><A href="javascript: confirmation('#ReReplace(ReReplace(Doc_Uni_Name,"##","&##35;","ALL"),"'","\'","ALL")#');" TITLE="Click here to view '#Doc_File_Name#'">
									<CFSET Display_Name=Left(Doc_File_Name,20)>
									<CFIF len(trim(Doc_File_Name)) GT 20>
										#LCASE(Display_Name)#...
									<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
										&nbsp;
									<CFELSE>
										#LCASE(Display_Name)#	
									</CFIF>	
									</A><BR>#NumberFormat(SIZEinMB,"_.____")# KB&nbsp;</TD>

							<TD ID="" WIDTH="58%"><FONT color="red"><b>#Doc_Title#</b></FONT><br>Description: #Doc_Description#&nbsp;</TD>
							<TD ID="" WIDTH="12%">#Doc_Type#&nbsp;</TD>
						</TR>	
					</CFOUTPUT>
				</TABLE>		
	
	<!--attachmentend-->
	<!----- 
	please don't remove the above comment, 
	attachmentend (and it only needs 2 dashs like html comment, it is purposely done)
	it is used in a regular expression
	to remove the attachment area from the email and fax
	If any questions, please contact Deepa first before editing :)
	--------------->
	</CFIF>	</cfif>
<P>

<CF_CRYP type="en" string="#Export_Sales_Agreement_ID#" key="#request.key#">

<!--- Show Internal Notes --->
<table border="0" align="center" cellpadding="2" cellspacing="0" width="800">
	<cfif Trim(getNotes.Export_Internal_Notes) neq "">
		<tr>
			<td class="TableHeader"><B>Internal Notes</B></td>
		</tr>
		<cfoutput query="getNotes">
		<tr>
			<td style="border-bottom:solid ##93BEE2 1px;"  class="TableData">#Replace(Export_Internal_Notes,"#chr(13)##chr(10)#","<br />", "ALL")#</td>
		</tr>
		</cfoutput>
	</cfif>
</table>
</cfsavecontent>

<!--- Write two files - Internal (Private) and External (Public) --->
<cflock timeout="10" type="exclusive">
	<cffile action="write" file="#Application.Doc_Path#\Temp_Files\Program\#sProgramViewCacheFileName1#" output="#PublicData##PrivateData#">
	<cffile action="write" file="#Application.Doc_Path#\Temp_Files\Program\#sProgramViewCacheFileName2#" output="#PublicData#">
</cflock>

<cfoutput>#PublicData##PrivateData#</cfoutput>

</cfif>

<!--- <cfsetting showdebugoutput="true"> --->
