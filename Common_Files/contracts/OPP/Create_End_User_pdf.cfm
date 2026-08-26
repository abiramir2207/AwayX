<!--- 
Created By: Mark Saunders
Created On: May 5, 2019
--->

<!--- 1) Set variables and parameters --->
<cfparam name="Contract_Main_ID"		default="">
<cfparam name="PDFLocation"		 		default="">
<cfparam name="PDFPath"		 			default="">
<cfparam name="PDFFileName" 			default="">
<cfparam name="TotalRows" 				default="5"><!--- how many rows across is the table? --->
<cfparam name="url.custId" 					default="">

<cfset oOppMan = CreateObject("component","mvc.Models.Program.OnePageProgramManager").init() />
<cfset oProgMan = CreateObject("component","components.Programs.ProgramManager").init() />
<cfscript>
	qGetProgram =		oProgMan.getProgramInfoComplete(Contract_Main_ID);
	qGetEndUsers =		oOppMan.getOperatorListQuery(0,0,Contract_Main_ID);
	arrGetProducts =	oOppMan.getCpaProductsObject(Contract_Main_ID);
	qGetCpaComps =		oOppMan.getCpaCompsQuery(Contract_Main_ID);
	qGetCustomers =		oOppMan.getCustomers(Contract_Main_ID);
	isLoyalty =			oOppMan.isLoyalty(Contract_Main_ID);
	getLoyaltyJson =	oOppMan.getRebateComps(Contract_Main_ID,1,1);
	getLoyaly = deserializeJson(getLoyaltyJson);
	getCPACompIdList =   deserializeJson(oOppMan.getCPACompIdList(Contract_Main_ID));
	getPriceList 		=	deserializeJson(oOppMan.getOnePriceList(qGetProgram.Gpo_Price_List_Id));

	TotalRows = 1;
	PDFFileName		= "CPA_#Replace(qGetProgram.Contract_Number,' ','_','ALL')#_End_User.pdf";
	PDFLocation = application.Doc_Path & "\Data_Files\Created\contracts\Letters\"  & PDFFileName;
	PDFPath = application.HTTPVar & cgi.SERVER_NAME & "/common_documents/Data_Files/Created/contracts/Letters/"  & PDFFileName;
	variables.labelsObject = createObject("component", "components.settings.labels.labels").init();
	dToday = dateformat(now(),'mm/dd/yyyy');

	dStart = dateformat(qGetProgram.Contract_Start_Date,'mm/dd/yyyy');
	dEnd = dateformat(qGetProgram.Contract_End_Date,'mm/dd/yyyy');
	dApprove = dateformat(qGetProgram.Approval_Date,'mm/dd/yyyy');

	// var lpaCompId = 0
	// for (comp in qGetCpaComps) {
	// 	if(comp.Program_Rebates_Component_Name contains('LPA')){
	// 		lpaCompId = comp.Program_Rebates_Component_ID;
	// 	}
	// }

</cfscript>

<!--- Check to see if it exists before we go through all this again --->
<cfif FileExists(PDFLocation)>
	<cffile action = "delete" file = "#PDFLocation#">
</cfif>

<CFDOCUMENT FORMAT="PDF" FILENAME="#PDFLocation#" OVERWRITE="Yes" ORIENTATION="portrait" MarginTop="3" marginLeft=".2" marginRight=".2">
<!--- 4) Custom stylesheet for the PDF (must be within cfdocument tags) --->
<style type="text/css">
.larger{font-size: 11px;font-family: arial;}
.normal{font-size: 12px;font-family: arial;}/*border-bottom: 1px dashed;*/
.normalheader{font-size: 12px;font-family: arial;font-weight: bold;background-color: #cccccc;padding-top:4px;}
.normalStrong{font-size: 11px;font-family: arial;font-weight: bold;text-align: right;}/*border-bottom: 2px solid;*/
.normalStrongLeft{font-size: 11px;font-family: arial;font-weight: bold;text-align: left;}	/*border-bottom: 2px solid;*/
.SummaryHeader{font-size: 13px;font-family: arial;font-weight: bold;text-align: right;background-color: #cccccc;margin-bottom:10px;}
.space{padding-top:5px;padding-bottom:5px;}
.subTotal{font-size: 13px;font-family: arial;font-weight: bold;text-align: right;background-color: #cccccc;} 	/*border-bottom: 2px solid;*/
.regular{font-size: 10px;font-family: arial;}
.normalRight{font-size: 10px;font-family: arial;text-align: right;}
.normalCenter{font-size: 10px;font-family: arial;text-align: center;}
.reallySmall{font-size: 9px;font-family: arial;padding: 1px;}
.reallySmallNoPad{font-size: 9px;font-family: arial; border-collapse: collapse;border-spacing: 0px;}
.smallRight{font-size: 9px;font-family: arial;text-align: right;}
.tiny{font-size: 10px;font-family: arial;font-weight:bold;background-color: #cccccc;padding-top:4px;}
.strong{font-weight: bold;font-size: 10px;font-family: arial;}
.box{border-top: 1px solid;border-bottom: 1px solid;border-right: 1px solid;border-left: 1px solid;font-size: 10px;font-family: arial;border-collapse: separate;border-spacing: 0px;}
.BigAndStrong{font-weight: bold;font-size: 14px;font-family: arial;}
.tableSpace { border-collapse: collapse;border-spacing: 0px;}
.underlineStrongLeft{font-size: 11px;font-family: arial;font-weight: bold;text-align: left;border-bottom: 1px solid;border-collapse: separate;border-spacing: 0px;}
</style>
<!--- HEADER --->

<cfdocumentitem type="header" evalAtPrint="true">
	
 <style type="text/css">
.larger{font-size: 11px;font-family: arial;}
.normal{font-size: 12px;font-family: arial;}/*border-bottom: 1px dashed;*/
.normalheader{font-size: 12px;font-family: arial;font-weight: bold;background-color: #cccccc;padding-top:4px;}
.normalStrong{font-size: 11px;font-family: arial;font-weight: bold;text-align: right;}/*border-bottom: 2px solid;*/
.normalStrongLeft{font-size: 11px;font-family: arial;font-weight: bold;text-align: left;}	/*border-bottom: 2px solid;*/
.SummaryHeader{font-size: 13px;font-family: arial;font-weight: bold;text-align: right;background-color: #cccccc;margin-bottom:10px;}
.space{padding-top:5px;padding-bottom:5px;}
.subTotal{font-size: 13px;font-family: arial;font-weight: bold;text-align: right;background-color: #cccccc;} 	/*border-bottom: 2px solid;*/
.regular{font-size: 10px;font-family: arial;}
.normalRight{font-size: 10px;font-family: arial;text-align: right;}
.normalCenter{font-size: 10px;font-family: arial;text-align: center;}
.reallySmall{font-size: 9px;font-family: arial;padding: 1px;}
.smallRight{font-size: 9px;font-family: arial;text-align: right;}
.tiny{font-size: 10px;font-family: arial;font-weight:bold;background-color: #cccccc;padding-top:4px;}
.strong{font-weight: bold;font-size: 10px;font-family: arial;}
.box{border-top: 1px solid;border-bottom: 1px solid;border-right: 1px solid;border-left: 1px solid;font-size: 10px;font-family: arial;border-collapse: separate;border-spacing: 0px;}
.BigAndStrong{font-weight: bold;font-size: 14px;font-family: arial;}
.tableSpace { border-collapse: collapse;border-spacing: 0px;}
.underlineStrongLeft{font-size: 11px;font-family: arial;font-weight: bold;text-align: left;border-bottom: 1px solid;border-collapse: separate;border-spacing: 0px;}
</style> 
<table border="0" width="100%" paddingtop="0" paddingbottom="0" class="tableSpace">	
	<tr height="77">
		<td align="left" class="regular" width="30%">
			<img src="/Images/clxlogo.png" width="218" Height="67">
		</td>
		<td  class="BigAndStrong" style="text-align: center;" width="40%">
		 	&nbsp;
		</td>
		<td align="right"  class="normalStrong" width="26%">
			<img src="/Images/End_User_45.PNG" width="84" Height="70">
		</td>
	</tr>
	<tr>
		<td align="left" class="regular" width="30%">
			<table border="0" class="tableSpace">	
				<tr>
					<td align="left" class="normalStrongLeft">
						Clorox Professional Products Company<br>
						4900 Johnson Drive<br>
						Pleasanton CA 94588<br><br>
						Program Number: <cfoutput>#qGetProgram.Contract_Number#</cfoutput><br>
					</td>
				</tr>
			</table>
		</td>
		<td  class="BigAndStrong" style="text-align: center;" width="40%">
			<cfoutput>Clorox Pricing Agreement ##:&nbsp;#qGetProgram.Contract_Reference_Number#<br>
			#qGetProgram.Contract_Title#<br>
			<cfif isLoyalty>
					#getLoyaly[1].name#<br>
			</cfif>
			<cfif ArrayLen(getPriceList) GT 0 AND trim(getPriceList[1].GPO_Name) NEQ ''>
				GPO Pricing is #getPriceList[1].GPO_Name# Tier #getPriceList[1].tier#
			</cfif><br>
			</cfoutput>
			<br>
		</td>
		<td align="right"  class="normalStrong" width="30%">
			Print Date<br>
			<cfoutput>#dToday#</cfoutput>
		</td>
	</tr>
</table>
<table border="0" width="100%" class="box" paddingtop="0" paddingbottom="0" class="tableSpace">	
	<!--- Header Box --->
	<tr>
		<td align="center" class="regular" width="100%" class="regular">
			<table border="0" width="100%" class="tableSpace">
				<cfoutput>	
				<tr>
					<td align="left" class="regular" width="50%">
						<table border="0" width="100%" paddingtop="0" paddingbottom="0" class="tableSpace">	
							<tr>
								<td align="left" class="normalStrongLeft">Effective Date:</td>
								<td align="left" class="regular">#dStart#</td>
							</tr>
							<tr>
								<td align="left" class="normalStrongLeft">Termination:</td>
								<td align="left" class="regular">#dEnd#</td>
							</tr>
						</table>
					</td>
					<td align="left" class="regular" width="50%">
						<table border="0" width="100%" paddingtop="0" paddingbottom="0" class="tableSpace">
							<tr>
								<td align="left" class="normalStrongLeft">Distributor:</td>
								<td align="left" class="regular">Agreement available through authorized distributor</td>
								<!--- <td align="left" class="regular">#qGetCustomers.name#</td> --->
							</tr>

							<tr>
								<td align="left" class="normalStrongLeft">&nbsp;</td>
								<td align="left" class="regular">&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				</cfoutput>
			</table>
		</td>
	</tr>
</table>
<cfif cfdocument.currentpagenumber NEQ cfdocument.totalpagecount>
	<table border="0" width="100%" class="underlineStrongLeft" >
	<tr>
		<td align="left" class="regular" width="15%">Product</td>
		<td align="left" class="regular" width="30%">Description</td>
	<!--- 	<td align="left" class="regular" width="5%">Volume</td> --->
		<td align="left" class="regular" width="10%">UOM</td>
		<!--- <td align="left" class="regular" width="7%">List Price<br>Start Date</td> --->
		<!--- <td align="left" class="regular" width="8%">End<br>Date</td> --->
		<td align="center" class="normalCenter" width="10%">GPO<br>Price</td>
		<cfloop array="#getCPACompIdList#" index="ix">
			<cfif ix.compName contains 'LPA' OR ix.isLoyalty eq 1>
				<cfoutput>
					<td align="center" class="normalCenter" width="10%">#ReplaceNoCase(ix.compname,'Enhancement','ENH')#</td>
				</cfoutput>
			</cfif>
		</cfloop>
		<td align="center" class="normalCenter" width="10%">CPA<br>Price</td>
	</tr>
</table>
</cfif>
</cfdocumentitem>
	<!--- Header Box END--->
<!--- <table border="0" width="100%" class="tableSpace">
	<!--- End Users --->
	<tr>
		<td class="normalStrongLeft">
			Contract End-User(s):
		</td>
	<tr>
	<tr>
		<td class="box">
			<table border="0" width="100%" class="tableSpace">
				<cfoutput query="qGetEndUsers">	<!--- enduser query --->
				<tr class="reallySmall">
					<td align="left"  width="5%">#qGetEndUsers.key#</td>
					<td align="left"  width="21%">#qGetEndUsers.Name# [#qGetEndUsers.level#]</td>
					<td align="left"  width="21%">#qGetEndUsers.Operator_Address#</td>
					<td align="left"  width="13%">#qGetEndUsers.Operator_City#</td>
					<td align="left"  width="5%">#qGetEndUsers.Operator_State#</td>
					<td align="left"  width="8%">#qGetEndUsers.Operator_Zip#</td>
					<td align="left"  width="10%">#dStart#</td>
					<td align="left"  width="10%">#dEnd#</td>
				</tr>
				</cfoutput>
			</table>
		</td>
	<tr>
</table> --->
<!--- <table border="0" width="100%" class="underlineStrongLeft" >
	<tr>
		<td align="left" class="regular" width="8%">Product</td>
		<td align="left" class="regular" width="25%">Description</td>
	<!--- 	<td align="left" class="regular" width="5%">Volume</td> --->
		<td align="left" class="regular" width="5%">UOM</td>
		<td align="left" class="regular" width="8%">List Price<br>Start Date</td>
		<!--- <td align="left" class="regular" width="8%">End<br>Date</td> --->
		<cfif strat eq 1>
			<td align="right" class="normalCenter" width="7%">List<br>Price</td>
		</cfif>
		<!--- <td align="center" class="normalCenter" width="6%">GPO<br>Price</td> --->
		<!--- <td align="center" class="normalCenter" width="6%">Clorox<br>DAA</td> --->
		<cfloop array="#getCPACompIdList#" index="ix">
			<cfoutput>
			<td align="center" class="normalCenter" width="6%">#ix.compname#</td>
			</cfoutput>
		</cfloop>
		<td align="center" class="normalCenter" width="6%">CPA<br>Price</td>
		<cfif strat eq 1>
			<td align="center" class="normalCenter" width="6%">Total<br>Rebate</td>
		</cfif>
	</tr>
</table> --->
<!--- Product details --->
<!--- <table border="0" width="100%" class="tableSpace">
	<tr>
		<td> --->
		<!--- 	<table border="0" width="100%" class="underlineStrongLeft" >
				<tr>
					<td align="left" class="regular" width="15%">Product</td>
					<td align="left" class="regular" width="30%">Description</td>
					<td align="left" class="regular" width="8%">Volume</td>
					<td align="left" class="regular" width="8%">Unit<br>Price</td>
					<td align="left" class="regular" width="5%">Start<br>Date</td>
					<td align="left" class="regular" width="8%">End<br>Date</td>
					<td align="left" class="normalRight" width="8%">GPO<br>Price</td>
					<td align="left" class="normalRight" width="8%">Clorox<br>LPA</td>
					<td align="left" class="normalRight" width="8%">CPA</td>
				</tr>
			</table> --->
			<cfloop from="1" to="#ArrayLen(arrGetProducts)#" index="i">
				<cfoutput> 
			<!--- 	<cfscript>
						if(qGetProducts['unit_of_measure_id_#lpaCompId#'] == 3){
							lpaRate = (qGetProducts['rate_#lpaCompId#']/100) * qGetProducts.base_sales_cs;
						}
						else{
							lpaRate = qGetProducts['rate_#lpaCompId#'];
						}
				</cfscript> --->
				<cfset lpaRate = arrGetProducts[i].base_sales_cs - arrGetProducts[i].fixed_price_value_end_user /> 
				<table border="0" width="100%" class="tableSpace">
					<tr>
						<td align="left" class="reallySmall" width="15%">#arrGetProducts[i].item#</td>
						<td align="left" class="reallySmall" width="30%">#arrGetProducts[i].description#</td>
						<!--- <td align="left" class="reallySmall" width="8%">1</td> --->
						<td align="left" class="reallySmall" width="10%">CS</td>
						<!--- <td align="left" class="reallySmall" width="7%">#dateformat(arrGetProducts[i].start_date,'mm/dd/yyyy')#</td> --->
						<!--- <td align="left" class="regular" width="8%">#dateformat(arrGetProducts[i].end_date,'mm/dd/yyyy')#</td> --->
						<td align="left" class="smallRight" width="10%"><cfif trim(arrGetProducts[i].gpo_key) NEQ ''  AND FindNoCase('NON',arrGetProducts[i].gpo_key) EQ 0>#DollarFormat(arrGetProducts[i].gpo_price)#</cfif></td>
						<cfloop array="#getCPACompIdList#" index="idx">
							<cfif idx.compName contains 'LPA' OR idx.isLoyalty eq 1>
								<cfif arrGetProducts[i]['rate_#idx.compid#'] eq 0>
									<td class="smallRight" width="10%">&nbsp;</td>
								<cfelse>
									<cfif idx.compName contains '%'>
										<cfset rate = arrGetProducts[i].base_sales_cs * (arrGetProducts[i]['rate_#idx.compid#']/100) />
									<cfelse>
										<cfset rate = arrGetProducts[i]['rate_#idx.compid#'] />
									</cfif>
									<td class="smallRight" width="10%">#DollarFormat(rate)#&nbsp;&nbsp;</td>
								</cfif>
							</cfif>
						</cfloop>
						<td class="smallRight" width="10%">#DollarFormat(arrGetProducts[i].fixed_price_value_end_user)#&nbsp;&nbsp;&nbsp;&nbsp;</td>
					</tr>
				</table>
				</cfoutput>
			</cfloop>
		<!--- 	</td>
		</tr>
</table> --->
<cfdocumentitem type = "pagebreak"/>
	<!--- Page break --->
<table border="0" width="100%" class="tableSpace">
	<!--- End Users --->
	<tr>
		<td class="normalStrongLeft">
			Agreement End-User(s):
		</td>
	<tr>
	<tr>
		<td class="box">
			<table border="0" width="100%" class="tableSpace">
				<cfoutput query="qGetEndUsers">	<!--- enduser query --->
				<tr class="reallySmallNoPad">
					<td align="left"  width="5%">#qGetEndUsers.key#</td>
					<td align="left"  width="21%">#qGetEndUsers.Name# [#qGetEndUsers.level#]</td>
					<td align="left"  width="21%">#qGetEndUsers.Operator_Address#</td>
					<td align="left"  width="13%">#qGetEndUsers.Operator_City#</td>
					<td align="left"  width="5%">#qGetEndUsers.Operator_State#</td>
					<td align="left"  width="8%">#qGetEndUsers.Operator_Zip#</td>
					<td align="left"  width="10%">#dStart#</td>
					<td align="left"  width="10%">#dEnd#</td>
				</tr>
				</cfoutput>
			</table>
		</td>
	<tr>
</table>
<table border="0" width="100%" class="tableSpace">
	<cfif isLoyalty GT 0>
		<tr>
			<td align="left" class="regular" width="100%"><p><p>
				Clorox will not honor any billback that exceeds the 5,000 lb (list) price bracket or is for an invoice over 90 days old. The 5,000 lb (list) price is subject to change.<p>

				Clorox may update Clorox Pricing Agreement (CPA) price at any time during the agreement period, with a 30-day notice. If GPO or NPA price changes during term of agreement, agreement will be updated with new/revised pricing.<p>

				All discounts are reflected off of the facility's (or facilities') pricing. Any price changes made to existing pricing (eg GPO) will result in a revised pricing agreement.<p>

				CPA should never be altered by anyone other than the Clorox Pricing Administrator. Changes to the CPA will render it null and void.<p>

				Such prices do not reflect applicable Authorized Distributor fees to eligible facilities listed on CPA.<p>

				Authorized distributors to bill back the difference between price invoiced and the CPA price for all sales to facilities listed on CPA.<p>

				Distributors are required to submit sales in the approved format no later than the 10th of the month via Clorox Professional Products Company Data Intake Web Portal.<p><br><br>


				Contact for questions/problems/access:<br>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Clorox Professional Products Company<br>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="mailto:ProfessionalRebates@clorox.com">ProfessionalRebates@clorox.com</a><p><br><br>
			</td>
		</tr>
	<cfelse>
		<tr>
			<td align="left" class="regular" width="100%"><p><p>
				Clorox will not honor any billback that exceeds the 5,000 lb (list) price bracket or is for an invoice over 90 days old. The 5,000 lb (list) price is subject to change.<p>

				Clorox may update Clorox Pricing Agreement (CPA) price at any time during the agreement period, with a 30-day notice. If GPO or NPA price changes during term of agreement, agreement will be updated with new/revised pricing.<p>

				CPA should never be altered by anyone other than the Clorox Pricing Administrator. Changes to the CPA will render it null and void.<p>

				Such prices do not reflect applicable Authorized Distributor fees to eligible facilities listed on CPA.<p>

				Authorized distributors to bill back the difference between price invoiced and the CPA price for all sales to facilities listed on CPA.<p>

			Distributors are required to submit sales in the approved format no later than the 10th of the month via Clorox Professional Products Company Data Intake Web Portal.<p><br><br>

				Contact for questions/problems/access:<br>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Clorox Professional Products Company<br>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="mailto:ProfessionalRebates@clorox.com">ProfessionalRebates@clorox.com</a><p><br><br>
			</td>
		</tr>
	</cfif>
	</tr>
</table>

<!--- Footer --->
<cfdocumentitem type="footer">
<style>
.ProvidedBy
{
	background-color: #cccccc;font-size: 10px;font-family: arial;border-top: 2px solid;
}

.regularStyle
{
	font-size: 10px;
	font-family: arial;
}
</style>

<cfoutput>
	<table border="0" cellpadding="2" cellspacing="0" width="100%">
	<!--- Provided by --->
	<tr>
		<td colspan="3" class="ProvidedBy" align="center">
			Provided by Blacksmith Applications FORGE Suite
		</td>
	</tr>
	
	<!--- Basic info --->
	<tr>
		<td width="200" class="regularStyle" align="left" >
			#Dateformat(now(), 'mmm dd, yyyy')#
		</td>
		<td class="regularStyle" align="center">
			#cfdocument.currentpagenumber#/#cfdocument.totalpagecount#
		</td>
		<td width="200" class="regularStyle" align="right">
			#application.returned_customer_setting.Company_Name#
		</td>
		
	</tr>

	</table>
</cfoutput>
 </cfdocumentitem >
</CFDOCUMENT>

<!--- Check to see if it exists before we go through all this again --->
<!--- </cfif> --->
