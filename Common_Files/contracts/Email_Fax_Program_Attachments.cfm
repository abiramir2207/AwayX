<!------Email_Fax_Program_Attachments.cfm----->
<CFSET Other_Attachment_List = "">
<CFSET Program_ID = URL.Contract_Main_ID>
<cfset Other_Attachment_List = ListAppend(Other_Attachment_List, "Program_Volume") />

<!------ get template settings ----->
<cfset GetSettings = CreateObject("component", "components.programs.template.TemplateManager").getProgramTemplate(Program_ID) />
<cfset appSettings = CreateObject("component", "components.settings.ApplicationSettingsManager").get()>
<cfset objProgramFreight = CreateObject("component", "components.freight.ProgramFreight")>
<cfset objProgramManager = CreateObject("component", "components.programs.ProgramManager")>

<!------ Get general info about the program ----->
<cfset useLakebaseForGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractInfo>
	<cftry>
		<cfset GetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Program_ID#",
				"select" = "contract_contains_sysco"
			}), "contract_contains_sysco"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractInfo>
<CFQUERY NAME="GetContractInfo" DATASOURCE="#Application.Datasource#">
	SELECT 	Contract_contains_Sysco			
	FROM 	Contract_Main
	WHERE 	Contract_Main_ID = '#Program_ID#'
</CFQUERY>
</cfif>

<!--- Payment Address Detail --->
<cfset useLakebaseForCheckSelection = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForCheckSelection>
	<cftry>
		<cfset CheckSelection = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main_aux_data", {
				"contract_main_id" = "eq.#Program_ID#",
				"select" = "pay_to_distributor,send_to_broker"
			}), "pay_to_distributor,send_to_broker"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckSelection = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckSelection>
<CFQUERY NAME="CheckSelection" DATASOURCE="#Application.Datasource#">
	SELECT 	Pay_To_Distributor,
			Send_To_Broker
	FROM 	Contract_Main_Aux_Data 
	WHERE 	Contract_Main_ID = '#Program_ID#'
</CFQUERY>
</cfif>


<CFSET AttachPaymentInfo = 0>
<CFIF CheckSelection.Pay_To_Distributor EQ 1 AND CheckSelection.Send_To_Broker EQ 1>
	<CFSET AttachPaymentInfo = 1>
<CFELSEIF CheckSelection.Pay_To_Distributor EQ 1 AND CheckSelection.Send_To_Broker NEQ 1>
	<CFSET AttachPaymentInfo = 2>
<CFELSEIF CheckSelection.Pay_To_Distributor NEQ 1 AND CheckSelection.Send_To_Broker EQ 1>
	<CFSET AttachPaymentInfo = 3>
</CFIF> 



<!----- Formula Code ----->
<cfquery name="COMM_GetSettings" datasource="#application.datasource#">
	SELECT 	Discount_Formula_Pricing		
	FROM	Contract_Main			
			INNER JOIN Program_Control_Panel_Options
			ON
			Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	WHERE 
		Contract_Main.Contract_Main_ID = '#Program_ID#'
</cfquery>
<CFIF COMM_GetSettings.Discount_Formula_Pricing EQ 1>
	<CFQUERY NAME="Any_Commodity_Show_Details_Present" datasource="#application.datasource#">
		SELECT     Count(Formula_Pricing_Rule.Rule_Name) AS Any_Formula_Display
		FROM        dbo.BSA_Foodservice_Items_Master 
					INNER JOIN	dbo.Contract_Products 
					ON dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = dbo.Contract_Products.BSA_Foodservice_Items_Master_ID 
					INNER JOIN dbo.Program_Formula_Pricing_Rule_Products 
					ON dbo.Contract_Products.Contract_Products_ID = dbo.Program_Formula_Pricing_Rule_Products.Contract_Product_ID
					INNER JOIN Program_Formula_Pricing_Rule_Mapped
					ON
					Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID = dbo.Program_Formula_Pricing_Rule_Products.Program_Formula_Pricing_Rule_ID
					AND
					Program_Formula_Pricing_Rule_Mapped.Deleted = 0
					LEFT JOIN Formula_Pricing_Rule
					ON
					Formula_Pricing_Rule.Formula_Pricing_Rule_ID = Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID
					AND
					Formula_Pricing_Rule.Deleted = 0
					AND
					Formula_Pricing_Rule.Show_Details = 1
		WHERE     
					(dbo.Contract_Products.Deleted = 0) 
					AND (dbo.Contract_Products.Contract_Main_ID = '#Program_ID#') 
					AND (dbo.Program_Formula_Pricing_Rule_Products.Deleted = 0)
	</CFQUERY>
	<CFIF Any_Commodity_Show_Details_Present.RecordCount GT 0>
		<CFIF Any_Commodity_Show_Details_Present.Any_Formula_Display GT 0>
			<CFSET Other_Attachment_List = "Formula_Details">
		</CFIF>
	</CFIF>
</CFIF>

<!----- Formula Code ----->

<!---check for group deals--->
<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />

<!---if this program/contract has a group then flag for send sku prompt in email create page--->
<cfif GroupDataManager.isGroupDeal(Get_Program_Details.Contract_Main_ID)>
	<cfset Other_Attachment_List = ListAppend(Other_Attachment_List, "Group_Deals") />
</cfif>

<!------ Check if Discount Lump Sums Distributor Mandated and the distributor details is not displaye din view program page----->
<cfif  GetSettings.Discount_Lump_Sums_Distributor_Mandated EQ 1 AND appSettings.getPgmLumpsumDetailedDisplay() EQ 0>
	<cfset LumpSumManager = CreateObject("component", "components.programs.lump_sum_components.LumpSumManager") />
	<cfset getDistributors  = LumpSumManager.getLumpSumDistributors(Get_Program_Details.Contract_Main_ID, "", 1)>
	<!------ Check if there is lump sum with distributor ----->
	<cfif getDistributors.recordCount>
		<cfset Other_Attachment_List = ListAppend(Other_Attachment_List, "Lumpsum_Distributor") />
	</cfif>
</cfif>

<!------ Attach Sysco deal ----->
<cfif GetContractInfo.Contract_contains_Sysco EQ 1 and Get_Profile_Settings.Approve_Sysco_Deals><!------ Approve_Sysco_Deals = can access sysco deal page ----->
	<cfset Other_Attachment_List = ListAppend(Other_Attachment_List, "Sysco_Deal_Sheet") />
</cfif>
<!------ Attach Sysco deal ----->

<!------ Attach Freight Page ----->
<cfset ProgramDistributorFreightCount = objProgramFreight.GetProgramDistributorFreightCount(Program_ID)>
<cfset ProgramFreightOn = objProgramManager.GetIsProgramFreightOn(Program_ID)>
<cfset ProgramFreightComponentType = objProgramManager.GetProgramFreightComponentType(Program_ID)>

<cfif ProgramDistributorFreightCount eq 1 AND ProgramFreightOn eq 1 AND ProgramFreightComponentType neq 0 
			AND Get_Profile_Settings.Approve_Freight_Programs>
	<cfset Other_Attachment_List = ListAppend(Other_Attachment_List, "Freight_Summary") />
</cfif>
<!------ Attach Freight Page ----->


<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>

<CFQUERY NAME="mail_Documents" DATASOURCE = "#Application.Datasource#">
	SELECT 		contract_Attachments.doc_id,
				Doc_Uni_Name,
				doc_title,
				Doc_Description,
				Uploaded_Date,
				Uploaded_By,
				Doc_Type,
				Doc_File_Name,
				Doc_Size 

	FROM 		contract_Attachments
	INNER JOIN 	Document_Details ON contract_Attachments.Doc_ID = Document_Details.Doc_ID 				
				AND	(	
						(	Public_View = 1
							AND User_Position_ID IN (#preservesinglequotes(Access_Position_List)#)
						) 						
						OR Public_View = 0	
					)
	WHERE 		contract_Attachments.Program_ID = #Get_Program_Details.Contract_Main_ID# 
	AND			contract_Attachments.deleted=0
</CFQUERY>
<!--- mail_Documents --->

<CFIF mail_Documents.recordcount GT 0 OR ListLen(Other_Attachment_List, ",") GT 0 OR AttachPaymentInfo NEQ 0>
<BR>
<SPAN CLASS="title2">Attachments</SPAN>
<HR COLOR="Orange">
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="75%">	
	<CFIF mail_Documents.recordcount GT 0>
	<TR >
		<TD>&nbsp;</TD>
		<TD BGCOLOR="#ffce84">&nbsp;</TD>
		<TD ID="headed" STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">Date / Name</TD>
		<TD ID="header" STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">File</TD>
		<TD STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">Title / Description</TD>
		<TD STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">Type</TD>
	</TR>
	</CFIF>
		<CFOUTPUT QUERY="Mail_Documents">
		<cfset useLakebaseForget_userName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForget_userName>
	<cftry>
		<cfset get_userName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Uploaded_By#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_userName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_userName>
<CFQUERY NAME="get_userName" DATASOURCE="#Application.Datasource#">
			SELECT 		Name_First,
						Name_Last
			FROM		_users
			WHERE 		User_ID = '#Uploaded_By#'
		</CFQUERY>
</cfif>
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">		
		<TD WIDTH="100" BGCOLOR="White">&nbsp;</TD>		
		 <TD ALIGN="right"  VALIGN="TOP"><INPUT TYPE="Checkbox" NAME="Doc_ID" VALUE="#Doc_ID#" >&nbsp;&nbsp;</TD> 
		 <TD WIDTH="125" VALIGN="TOP">#dateFormat(Uploaded_Date,"mm/dd/yyyy")#<BR>#get_userName.Name_First# #get_userName.Name_Last#</TD>
		<CFSET SIZEinKB = #Doc_Size#/1024>
		<TD VALIGN="TOP"><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">#Doc_File_Name#</A>&nbsp;&nbsp;<br>#numberFormat(SIZEinKB,"_.___")# KB</TD>
		<TD VALIGN="TOP"><FONT COLOR="red">#Doc_Title#</FONT>&nbsp;&nbsp;<br>Description: #Doc_Description#</TD>
		<TD NOWRAP VALIGN="TOP">#Doc_Type#</TD>
		</TR>
	</CFOUTPUT>
	<CFSET RowCounter = Mail_Documents.RecordCount + 1>
	<CFOUTPUT>
	<CFLOOP LIST="#Other_Attachment_List#" INDEX="O_Attachment_Type">
		<CFSWITCH EXPRESSION="#O_Attachment_Type#">
			<CFCASE VALUE="Formula_Details">
				<TR BGCOLOR="#IIf(RowCounter Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD WIDTH="100" BGCOLOR="White">&nbsp;</TD>
					<TD ALIGN="right"  VALIGN="TOP"><INPUT TYPE="Checkbox" NAME="#O_Attachment_Type#" VALUE="#O_Attachment_Type#" CHECKED>&nbsp;&nbsp;</TD> 
					<TD COLSPAN="4">Formula Pricing Details</TD>
				</TR>
			</CFCASE>
			<CFCASE VALUE="Lumpsum_Distributor">
				<TR BGCOLOR="#IIf(RowCounter Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD WIDTH="100" BGCOLOR="White">&nbsp;</TD>
					<TD ALIGN="right"  VALIGN="TOP"><INPUT TYPE="Checkbox" NAME="#O_Attachment_Type#" VALUE="#O_Attachment_Type#" CHECKED>&nbsp;&nbsp;</TD> 
					<TD COLSPAN="4">#Application.LumpsumLabel# #application.returned_customer_setting.distributor_label_plural#</TD>
				</TR>
			</CFCASE>
			<!---send sku's for groups selection--->
			<CFCASE VALUE="Group_Deals">
				<TR BGCOLOR="#IIf(RowCounter Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD WIDTH="100" BGCOLOR="White">&nbsp;</TD>
					<TD ALIGN="right"  VALIGN="TOP"><INPUT TYPE="Checkbox" NAME="#O_Attachment_Type#" VALUE="#O_Attachment_Type#" CHECKED>&nbsp;&nbsp;</TD> 
					<TD COLSPAN="4">Send Item Summary for Groups</TD>
				</TR>
			</CFCASE>
			<!---send volume--->
			<CFCASE VALUE="Program_Volume">
				<TR BGCOLOR="#IIf(RowCounter Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD WIDTH="100" BGCOLOR="White">&nbsp;</TD>
					<TD ALIGN="right"  VALIGN="TOP"><INPUT TYPE="Checkbox" NAME="#O_Attachment_Type#" VALUE="#O_Attachment_Type#" CHECKED>&nbsp;&nbsp;</TD> 
					<TD COLSPAN="4">Send Program Volume</TD>
				</TR>
			</CFCASE>
			<CFCASE VALUE="Sysco_Deal_Sheet">
				<TR BGCOLOR="#IIf(RowCounter Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD WIDTH="100" BGCOLOR="White">&nbsp;</TD>
					<TD ALIGN="right"  VALIGN="TOP"><INPUT TYPE="Checkbox" NAME="#O_Attachment_Type#" VALUE="#O_Attachment_Type#" CHECKED>&nbsp;&nbsp;</TD> 
					<TD COLSPAN="4">sysco report</TD>
				</TR>
			</CFCASE>
			<CFCASE VALUE="Freight_Summary">
				<TR BGCOLOR="#IIf(RowCounter Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD WIDTH="100" BGCOLOR="White">&nbsp;</TD>
					<TD ALIGN="right"  VALIGN="TOP"><INPUT TYPE="Checkbox" NAME="#O_Attachment_Type#" VALUE="#O_Attachment_Type#">&nbsp;&nbsp;</TD> 
					<TD COLSPAN="4">Freight Summary</TD>
				</TR>
			</CFCASE>	
		</CFSWITCH>
		<CFSET RowCounter = RowCounter + 1>
	</CFLOOP>
	</CFOUTPUT>
	<CFIF AttachPaymentInfo NEQ 0>
		<TR <CFOUTPUT>BGCOLOR="#IIf(RowCounter Mod 2, DE('ffffff'), DE('C6FFC6'))#"</CFOUTPUT>>
			<TD WIDTH="100" BGCOLOR="White">&nbsp;</TD>
			<TD ALIGN="right"  VALIGN="TOP"><CFOUTPUT><INPUT TYPE="Checkbox" NAME="Attach_Payment_Det" VALUE="#AttachPaymentInfo#"></CFOUTPUT>&nbsp;&nbsp;</TD> 
			<TD COLSPAN="4">
			<CFIF AttachPaymentInfo EQ 1>
				<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>'s 'payable to' and 'Send Payment to' Addresses 
			<CFELSEIF AttachPaymentInfo EQ 2>
				<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>'s 'payable to' Addresses
			<CFELSEIF AttachPaymentInfo EQ 3>
				<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>'s 'Send Payment to' Addresses
			</CFIF>			
			</TD>
		</TR>
		<CFSET RowCounter = RowCounter + 1>
	</CFIF>	
	</TABLE>	
<BR>

</CFIF>