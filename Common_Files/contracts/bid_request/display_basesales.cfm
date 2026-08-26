
<cfparam name="url.Program_ID" default="0">
<cfif url.Program_ID NEQ "" and url.Program_ID NEQ 0>
<cfinclude template="/script/cf/string_functions.cfm">
<cfsilent>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset ViewProgramManager = CreateObject("component", "components.programs.Display_Program.viewprogramtemplateManager") />
<!--- <cfset appSettings = genSettingsManager.get()> --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset displayGroupType = genSettingsManager.getDisplayGroupType(appSettings.getViewProgramProductGroupType()) />
<cfset displayGroupTypeDesc = genSettingsManager.settings.getViewProgramProductGroupTypeDesc() />
<cfset bidRequestProdMan = CreateObject("component", "components.programs.bid_request.BidRequestProductManager") />
<cfset Get_Bidrequest_Products = bidRequestProdMan.getBidRequestProducts(programId=url.Program_ID,displayGroupType=displayGroupType,displayprogram=1)>
	<cfset getcompNames  = bidRequestProdMan.getAllBidrequestComponents(url.Program_ID)>
</cfsilent>
<B><FONT SIZE="2" COLOR="Navy">Bid Fixed Pricing - Base Sales at time of Approval</FONT></B>
<HR COLOR="Navy">
					<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0">
						<!--- TABLE HEADERS --->
						<cfoutput><TR BGCOLOR="##FFCE84" VALIGN="bottom">
							<TR BGCOLOR="##FFCE84" VALIGN="bottom">
						<TD ID="header" WIDTH="75" valign="top"><B><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>UPC/</cfif></cfif>ITEM</B></TD>
						<TD ID="header" WIDTH="200" valign="top"><B>DESCRIPTION</B><cfif displayGroupType>
								/	<strong>#displayGroupTypeDesc#</strong>
								</cfif></TD>
							<TD ID="header" WIDTH="20" valign="top"><B>Spec</B></TD>
							<CFLOOP query="getcompNames">
							<TD ID="header" valign="top"><B>Base Sales</B></TD>
							<TD ID="header" valign="top"><strong>Discount</strong></TD>
								<TD ID="header" valign="top"><B><cfoutput>#getcompNames.Program_Bidrequest_Component_Name#</cfoutput></TD>
								<TD ID="header" valign="top"><strong>Discount%</strong></TD>
								</CFLOOP>	
							</tr></cfoutput>
							<CFOUTPUT QUERY="Get_Bidrequest_Products" group="BSA_Foodservice_Items_Master_ID">
							<CFSET item_num= Get_Bidrequest_Products.BSA_Foodservice_Items_Master_ID>
							<!--- DATA OUTPUT --->
						<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#Get_Bidrequest_Products.BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">
							<TD ID=""><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#Get_Bidrequest_Products.UPC#<br></cfif></cfif>#Get_Bidrequest_Products.ITEM#</TD>
							<TD ID="">#Get_Bidrequest_Products.Description#<cfif displayGroupType><br>#DisplayGroupName#</cfif></TD>
							<TD ID="">#Get_Bidrequest_Products.Bid_Request_Key#</TD>
							<CFLOOP query="getcompNames">
							<cfsilent>
							<cfset getbidrequestbaseprice  = bidRequestProdMan.getbidrequestbaseprice(Get_Bidrequest_Products,getcompNames.Program_Bidrequest_Component_Id,item_num)>
							<cfset allow = getbidrequestbaseprice.Approved_Base_Sales - getbidrequestbaseprice.Bidrequest_Price_Value>
<cfif getbidrequestbaseprice.Approved_Base_Sales NEQ 0>
<cfset discount_percent = ((getbidrequestbaseprice.Approved_Base_Sales - getbidrequestbaseprice.Bidrequest_Price_Value)/getbidrequestbaseprice.Approved_Base_Sales) * 100>
<cfelse>
<cfset discount_percent = 0>
</cfif>
							</cfsilent>
						<TD>
	#trim(numberformat(getbidrequestbaseprice.Approved_Base_Sales, ViewProgramManager.getRateFormatMask()))#  per #left(getbidrequestbaseprice.Abbreviation, 2)#
						</TD>		
			<TD>
			<cfif allow LT 0>
			<cfset allowneg = allow * -1>
			#Negativeformat(numberformat(allowneg, ViewProgramManager.getRateFormatMask()))#
			<cfelse>
			#trim(numberformat(allow, ViewProgramManager.getRateFormatMask()))#
			</cfif>
			</TD>		
			<TD>
			#trim(numberformat(getbidrequestbaseprice.Bidrequest_Price_Value, ViewProgramManager.getRateFormatMask()))#  per #left(getbidrequestbaseprice.Abbreviation, 2)#
			</TD>
			<TD>
			<CFIF discount_percent LT 0>
			<cfset discountperneg = discount_percent * -1>
			#NegativeFormat(numberformat(discountperneg,"____.__"))#%	
			<CFELSE>
			#numberformat(discount_percent,"____.__")#%
			</CFIF>
			</TD>
			
</CFLOOP>
							</tr>
							</cfoutput>
								</TABLE>	
						<br>
<span style="align:center">
<CF_button
						button_name		=	""
						button_caption	=	"print"
						button_action	=	"javascript:printPage();"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Print Page"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>	</span>

								
			

<cfelse>
<strong>Invalid Contract Number. Please try again.</strong>
</cfif>

<script>
		function printPage()
		{
			window.print();
		}
	</script>