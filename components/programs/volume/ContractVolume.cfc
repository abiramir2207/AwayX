<FORM<!------ ContractVolume.cfc ----->
<cfcomponent displayname="Contract Volume" hint="Contract Volume">
   	<!------<cfproperty name="Program_ID" type="numeric" hint="Program ID">----->

   	<!----------------- Load_Basic_Information() -------------------->
   	<cffunction name="Load_Basic_Information" output="false" hint="load with Basic Information values">
		<cfargument name="Program_ID" type="numeric" required="true" default="">
		<cfargument name="Load_Full_Info" type="numeric" required="false" default="1">
		<cfargument name="Load_Saved_Settings" type="numeric" required="false" default="1">
		<cfset this.Program_ID 				= arguments.Program_ID>
		<cfinvoke component="components.general.General_Functions" method="GenerateKey" returnVariable="key">
		<CF_Cryp type="en" key="#request.key#" string ="#this.Program_ID#">
		<CFSET this.Encrypted_Program_ID 	= cryp.value>
		
		<cfset this.Default_Sort_By = "Item">
		<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="#this.Default_Sort_By#">
		<cfset this.Default_Sort_Order = "ASC">
		<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="#this.Default_Sort_Order#">		
		<CFPARAM NAME="FORM.FID" 	DEFAULT="">
		<CFPARAM NAME="URL.FID" 	DEFAULT="#FORM.FID#">
		<CFSET this.FID = URL.FID>
		
		<CFIF Arguments.Load_Saved_Settings>
			<CFSET this.OBJ_FORM_VALUES = CreateObject("component", "components.general.Stored_Form_Values")>
			<cfinvoke component="components.general.General_Functions" method="Get_Application_Path" returnVariable="APPLICATIONPATH">
			<cfinvoke component="components.general.General_Functions" method="Get_Document_Path" returnVariable="Doc_Path">
			<CFSET this.FID = this.OBJ_FORM_VALUES.Set_File_Properties(Application.Doc_Path, "\Temp_Files\Program\Volume\", URL.FID)>
			<CFSET this.Saved_Settings = this.OBJ_FORM_VALUES.Load(2)>
		</CFIF>
		
		<CFPARAM NAME="this.Saved_Settings.Any_DB_Changes" 	DEFAULT="0">
		
		<CFSET this.Window_Max_Width 	= 790>
		
		<CFIF Arguments.Load_Full_Info EQ 1>
			<CFQUERY NAME="Get_Program_Details" DATASOURCE="#application.datasource#">
				SELECT	Contract_Main.Contract_Number, Contract_Main.Contract_Title, Contract_Main.Contract_Status_Type_IDX, 
						Contract_Main.Contract_Quantity_UOM_IDX, Contract_Main.Contract_Daily_Volume, Generic_Type.Generic_Type_ID, 
						Contract_Main.Contract_Quantity, Units_of_Measure.Unit_Of_Measure_Desc, Units_of_Measure.Abbreviation, 
						Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date
				FROM	Contract_Main
						INNER JOIN Program_Control_Panel_Options
						ON
						Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
						INNER JOIN Generic_Type
						ON
						Generic_Type.Generic_Type = Program_Control_Panel_Options.Generic_Type
						INNER JOIN Units_of_Measure
						ON
						Units_of_Measure.Unit_Of_Measure_ID = Contract_Main.Contract_Quantity_UOM_IDX
				WHERE
						Contract_Main.Contract_Main_ID = #this.Program_ID#
			</CFQUERY>
			
			<CFPARAM NAME="URL.action" 				DEFAULT="">
			<cfset this.action			 			= URL.action>
			<CFPARAM NAME="URL.context" 			DEFAULT="">
			<cfset this.context			 			= URL.context>
			<cfset this.pass_url					= "">
			<CFIF IsDefined("URL.Program_ID")>
				<cfset this.pass_url					= Build_To_URL(this.pass_url, "Program_ID", URL.Program_ID)>
			</CFIF>
			<CFIF IsDefined("URL.context")>
				<cfset this.pass_url					= Build_To_URL(this.pass_url, "context", URL.context)>
			</CFIF>
			<CFIF IsDefined("URL.FID")>
				<cfset this.pass_url					= Build_To_URL(this.pass_url, "FID", this.FID)>
			</CFIF>
			<!----- forecast Defaults ----->
			<cfset this.Previous_Forecast			= false>
			<cfset this.Load_From_Forecast			= false>
			<cfset this.Default_Span_Len 			= 90>
			<cfset this.Load_From_Forecast 			= false>
			
			<!----- Program Info ----->
			<cfset this.Contract_Number 			= Get_Program_Details.Contract_Number>
			<cfset this.Contract_Title 				= Get_Program_Details.Contract_Title>
			<cfset this.Contract_Status				= Get_Program_Details.Contract_Status_Type_IDX>			
			<cfset this.Contract_Start_Date 		= Get_Program_Details.Contract_Start_Date>
			<cfset this.Contract_End_Date 			= Get_Program_Details.Contract_End_Date>
			<cfset this.Contract_Span 				= DateDiff("d", Get_Program_Details.Contract_Start_Date, Get_Program_Details.Contract_End_Date) + 1>
			<cfset this.Contract_Quantity			= Get_Program_Details.Contract_Quantity>
			<cfset this.Weekly_Volume				= Get_Program_Details.Contract_Daily_Volume * 7>
			<cfset this.Unit_Of_Measure_Desc		= Get_Program_Details.Unit_Of_Measure_Desc>
			<cfset this.UOM_Abbreviation			= Trim(Get_Program_Details.Abbreviation)>
			<cfset this.UOM 						= Get_Program_Details.Contract_Quantity_UOM_IDX>
			
			<!---- determine which volume to be used for validations and global application ---->
			<cfset this.Check_Volume				= this.Contract_Quantity>
			
			<CFIF Get_Program_Details.Generic_Type_ID EQ 1 OR Get_Program_Details.Generic_Type_ID EQ 5>
				<cfset this.Can_Do_Forecast = true>
			<CFELSE>
				<cfset this.Can_Do_Forecast = false>
			</CFIF>			
			<!-------- save some status to file ---->
			
		</CFIF><!------<CFIF Arguments.Load_Full_Info EQ 1>----->
   	</cffunction>
	
	<!----------------- CallBodyOnunload() -------------------->
   	<cffunction name="CallBodyOnunload" output="true" hint="CallBodyOnunload">
		<CFSET D_TEMP = this.General_JS_Functions()>
		<CFIF this.Saved_Settings.Any_DB_Changes>
			<script LANGUAGE="JavaScript">
				//window.onbeforeunload = new Function("reloadParent();");
				reloadParent();
			</script>
		</CFIF>
		<CFSET this.Saved_Settings.Any_DB_Changes = 0>
		<CFSET URL.FID = this.OBJ_FORM_VALUES.Save(0, this.Saved_Settings)>
	</cffunction>
	
	<!----------------- General_JS_Functions() -------------------->
   	<cffunction name="General_JS_Functions" output="true" hint="General_JS_Functions">
		<script LANGUAGE="JavaScript">
			function closeWindow()
			{
				window.close();
			}
			function reloadParent()
			{
				<CFIF this.Saved_Settings.Any_DB_Changes>
					if(window.opener)
					{
						window.opener.location.reload();
					}
				</CFIF>
			}			
		</script>
	</cffunction>
	
	<!----------------- Get_Total_Program_Volume() -------------------->
   	<cffunction name="Get_Total_Program_Volume" output="true" hint="Get_Total_Program_Volume">
		<CFSET D_Temp = this.Get_Product_List()>
		<CFSET Total_Volume = 0>
		<CFLOOP QUERY="Get_Distinct_Products">
			<CFSET Total_Volume = Total_Volume + this.GetProductVolume(BSA_Foodservice_Items_Master_ID)>
		</CFLOOP>		
		<CFRETURN Total_Volume>
	</cffunction>
	
	<!----------------- save_program_volume() -------------------->
   	<cffunction name="save_program_volume" output="false" hint="save_program_volume">
		<cfargument name="Program_Volume" type="numeric" required="true" default="">
		<CFSET Program_Volume = Arguments.Program_Volume>
		<CFSET DailyContractQuantity = Program_Volume / this.Contract_Span>

		<cfset useLakebaseForSave_Program_Volume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForSave_Program_Volume>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#this.Program_ID#"
			},
			{
				"contract_quantity" = "#Program_Volume#",
				"contract_daily_volume" = "#DailyContractQuantity#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Program_Volume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Program_Volume>
<CFQUERY NAME="Save_Program_Volume" DATASOURCE="#application.datasource#">
			UPDATE	Contract_Main
			SET		Contract_Quantity = #Program_Volume#,
					Contract_Daily_Volume = #DailyContractQuantity#
			WHERE
					Contract_Main_ID = #this.Program_ID#
		</CFQUERY>
</cfif>		
	</cffunction>
	
	<!----------------- Check_Any_NULL_Volume() -------------------->
   	<cffunction name="Check_Any_NULL_Volume" output="true" hint="Check_Any_NULL_Volume">
		<CFSET Null_Volume_Products = this.Get_Null_Volume_Product_List()>
		<CFSET All_Proper_Volume = true>
		<CFIF Null_Volume_Products.RecordCount GT 0>
			<CFSET All_Proper_Volume = false>
		</CFIF>
		<CFRETURN All_Proper_Volume>
	</cffunction>
	
	<!----------------- displayStep0Details() -------------------->
   	<cffunction name="display_Step0_Details" output="true" hint="display forecast, produc list choice and last forecast info">
		<TABLE WIDTH="#this.Window_Max_Width#" CELLPADDING="0" CELLSPACING="0">
		<TR>
		<TD>
		<CFSET D_Temp = this.Show_Program_Info()>
		</TD>
		</TR>
		</TABLE>
		<CFIF this.action EQ "forecast">
			<CFSET D_Temp = this.Show_Please_Wait()>
			<SPAN ID="Hide_For_Please_Wait">
			<CFSET D_Temp = this.Load_Forecast_Summary(1)>
			<CFSET D_Temp = this.Show_Forecast_Form()>
			</SPAN>
		<CFELSEIF this.action EQ "list">
			<CFSET D_Temp = this.Show_Product_List()>
		<CFELSEIF this.action EQ "loadforecast">
			<cfset this.Load_From_Forecast 			= true>
			<CFSET D_Temp = this.Show_Product_List()>
		<CFELSEIF this.Can_Do_Forecast>
			<!------
			<!--------Display last forecast details ------>			
			<CFSET D_Temp = this.Load_Forecast_Summary(1)>
			<CFSET D_Temp = this.Show_Forecast_Small_Menu()>
			----->
			<CFSET Not_Null_Volume_Products = this.Get_Null_Volume_Product_List(1)>
			<CFSET Any_Proper_Volume = false>
			<CFIF Not_Null_Volume_Products.RecordCount GT 0>
				<CFSET Any_Proper_Volume = true>
			</CFIF>
			<CFIF Any_Proper_Volume>
				<CFSET D_Temp = this.Show_Product_List()>
			<CFELSE>
				<CFSET D_Temp = this.Show_Please_Wait()>
				<SPAN ID="Hide_For_Please_Wait">
				<CFSET D_Temp = this.Load_Forecast_Summary(1)>
				<CFSET D_Temp = this.Show_Forecast_Form()>
				</SPAN>
			</CFIF>
		<CFELSE>
			<CFSET D_Temp = this.Show_Product_List()>
		</CFIF>		
   	</cffunction>
	
	<!----------------- Load_Forecast_Summary() -------------------->
	<cffunction name="Load_Forecast_Summary" output="true" hint="Show_Forecast_Small_Menu">
		<cfargument name="Show_Details" type="numeric" required="false" default="0">
		<CFQUERY NAME="Get_Forecast_Summary" DATASOURCE="#application.datasource#">
				SELECT	Forecast_Summary_ID, Forecast_From_Date, Forecast_To_Date, Forecast_Update_Date, Forecast_Overage, Forecast_Overage_UOM, _Users.Name_First + ' ' + _Users.Name_Last AS Forecast_User_Name
				FROM	Forecast_Summary
						INNER JOIN _Users
						ON
						_Users.User_ID = Forecast_Summary.Forecast_Update_User_ID
				WHERE
						Forecast_Summary.Program_ID = #this.Program_ID#
						AND
						Forecast_Summary.Deleted = 0
			</CFQUERY>
			<CFQUERY NAME="Distributor_In_Forecast_Not_In_Program" DATASOURCE="#application.datasource#">
				SELECT	DISTINCT Customer_ID
				FROM	Forecast_Volume_Detail						
				WHERE				
						Program_ID = #this.Program_ID#
						AND
						NOT EXISTS
						(
							SELECT	BSA_Foodservice_Customers_ID
							FROM	Contract_Distributors
							WHERE
									Contract_Distributors.Contract_Main_ID = Forecast_Volume_Detail.Program_ID
									AND
									Contract_Distributors.Deleted = 0
									AND
									Contract_Distributors.BSA_Foodservice_Customers_ID = Forecast_Volume_Detail.Customer_ID
						)
			</CFQUERY>
			<CFQUERY NAME="Distributor_In_Program_Not_In_Forecast" DATASOURCE="#application.datasource#">
				SELECT	BSA_Foodservice_Customers_ID
				FROM	Contract_Distributors
				WHERE				
						Contract_Distributors.Contract_Main_ID = #this.Program_ID#
						AND
						Contract_Distributors.Deleted = 0
						AND
						NOT EXISTS
						(
							SELECT	Customer_ID
							FROM	Forecast_Volume_Detail
							WHERE
									Contract_Distributors.Contract_Main_ID = Forecast_Volume_Detail.Program_ID									
									AND
									Contract_Distributors.BSA_Foodservice_Customers_ID = Forecast_Volume_Detail.Customer_ID
						)
			</CFQUERY>
			<CFIF Get_Forecast_Summary.RecordCount GT 0>
				<cfset this.Previous_Forecast			= true>
				<cfset this.Load_From_Forecast			= true>
				<CFSET this.Forecast_From_Date 			= Get_Forecast_Summary.Forecast_From_Date>
				<CFSET this.Forecast_To_Date 			= Get_Forecast_Summary.Forecast_To_Date>
				<CFSET this.Forecast_User_Name 			= Get_Forecast_Summary.Forecast_User_Name>
				<CFSET this.Forecast_Update_Date		= Get_Forecast_Summary.Forecast_Update_Date>
				<CFSET this.Forecast_Span				= DateDiff("d", this.Forecast_From_Date, this.Forecast_To_Date) + 1>
				<CFSET this.Forecast_Distributor_More	= Distributor_In_Forecast_Not_In_Program.RecordCount>
				<CFSET this.Forecast_Distributor_Less	= Distributor_In_Program_Not_In_Forecast.RecordCount>
				<CFSET this.Forecast_Summary_ID			= Get_Forecast_Summary.Forecast_Summary_ID>
				<CFIF Arguments.Show_Details EQ 1>
				
				<CFSET D_Temp = this.Get_Product_List(1, 0)>
				<CFSET this.Forecast_Product_Less	= Get_Distinct_Products.RecordCount>
				
				<TABLE ALIGN="center" WIDTH="100%" CELLPADDING="0" CELLSPACING="0" BORDER="0" STYLE="border-top:1px navy solid;border-bottom:1px navy solid;">
				<TR>
				<TD>
				<TABLE ALIGN="left" CELLPADDING="2" CELLSPACING="0" BORDER="0" BORDERCOLOR="Orange">
				<TR>
					<TD STYLE="font-size:13px;color:Navy;">
						<TABLE WIDTH="100%">
						<TR>
						<TD>Last forecast was done by <B>#this.Forecast_User_Name#</B> on <B>#DateFormat(this.Forecast_Update_Date, "mm/dd/yyyy")#</B></TD>
						</TR>
						<TR>
						<TD><B>forecast Span:</B> #DateFormat(this.Forecast_From_Date, "mm/dd/yyyy")# - #DateFormat(this.Forecast_To_Date, "mm/dd/yyyy")# (#this.Forecast_Span# days)</TD>
						</TR>						
						<CFIF this.Forecast_Distributor_More GT 0>
							<TR>
							<TD STYLE="color:red"><IMG SRC="/Images/exclamation_1.gif">&nbsp;There <CFIF this.Forecast_Distributor_More GT 1>are<CFELSE>is</CFIF> #this.Forecast_Distributor_More# <CFIF this.Forecast_Distributor_More GT 1>#LCase(application.returned_customer_setting.distributor_label_plural)#<CFELSE>#LCase(application.returned_customer_setting.distributor_label_singular)#</CFIF> who exist in the recent forecast but does not exist in the program</TD>
							</TR>
						</CFIF>
						<CFIF this.Forecast_Distributor_Less GT 0>
							<TR>
							<TD STYLE="color:red"><IMG SRC="/Images/exclamation_1.gif">&nbsp;There <CFIF this.Forecast_Distributor_Less GT 1>are<CFELSE>is</CFIF> #this.Forecast_Distributor_Less# <CFIF this.Forecast_Distributor_Less GT 1>#LCase(application.returned_customer_setting.distributor_label_plural)#<CFELSE>#LCase(application.returned_customer_setting.distributor_label_singular)#</CFIF> who exist in the program but does not exist in the recent forecast</TD>
							</TR>
						</CFIF>
						<CFIF this.Forecast_Product_Less GT 0>
							<TR>
							<TD STYLE="color:red"><IMG SRC="/Images/exclamation_1.gif">&nbsp;There <CFIF this.Forecast_Product_Less GT 1>are<CFELSE>is</CFIF> #this.Forecast_Product_Less# product<CFIF this.Forecast_Product_Less GT 1>s</CFIF> that exist in the program but does not exist in the recent forecast</TD>
							</TR>
						</CFIF>						
						</TABLE>
					</TD>
				</TR>
				</TABLE>
				</TD>
				</TR>
				</TABLE>
				</CFIF>			
			<CFELSE>
				<CFIF Arguments.Show_Details EQ 1>
				<HR COLOR="Orange">
				<B>This program doesn't have any recent forecast information</B>
				</CFIF>
			</CFIF>
   	</cffunction>
	
	<!----------------- Load_Forecast_Invoice_Detail() -------------------->
	<cffunction name="Load_Forecast_Invoice_Detail" output="true" hint="Load_Forecast_Invoice_Detail">
		<cfargument name="Product_ID" type="string" required="true" default="">
		<cfargument name="Distributor_ID" type="string" required="true" default="">
		<cfargument name="Show_Details" type="numeric" required="false" default="1">
		<cfset useLakebaseForGet_Product_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGet_Product_Info>
	<cftry>
		<cfset Get_Product_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"bsa_foodservice_items_master_id" = "eq.#Arguments.Product_ID#",
				"select" = "item,upc,description"
			}), "item,upc,description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Product_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Product_Info>
<CFQUERY NAME="Get_Product_Info" DATASOURCE="#application.datasource#">
			SELECT	Item, UPC, Description
			FROM	BSA_Foodservice_Items_Master
			WHERE
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#Arguments.Product_ID#'
		</CFQUERY>
</cfif>
		<cfset useLakebaseForGet_Distributor_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForGet_Distributor_Info>
	<cftry>
		<cfset Get_Distributor_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#Arguments.Distributor_ID#",
				"select" = "name,ship_to"
			}), "name,ship_to"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Distributor_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Distributor_Info>
<CFQUERY NAME="Get_Distributor_Info" DATASOURCE="#application.datasource#">
			SELECT	Name, Ship_to
			FROM	BSA_Foodservice_Customers
			WHERE
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#Arguments.Distributor_ID#'
		</CFQUERY>
</cfif>
		<CFQUERY NAME="Get_Invoice_Detail" DATASOURCE="#application.datasource#">
			SELECT	
					ISNULL(<CFIF this.UOM EQ 1>Cases_Invoiced<CFELSE>Pounds_Invoiced</CFIF>,0) AS Volume,
					Invoice_Header.Invoice_Version + '-' + Invoice_Header.Order_Number AS Invoice_Number, 
					Invoice_Detail.Invoice_Date, Shared_Invoice_Number
			FROM	Invoice_Header
					INNER JOIN Invoice_Detail
					ON
					Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
					AND Invoice_Detail.Deleted = 0
					AND Invoice_Detail.BSA_Foodservice_Items_Master_ID = '#Arguments.Product_ID#'
					AND Invoice_Detail.Invoice_Date >= #CreateODBCDate(this.Forecast_From_Date)# 
					AND Invoice_Detail.Invoice_Date <= #CreateODBCDate(this.Forecast_To_Date)# 
			WHERE
					Invoice_Header.BSA_Foodservice_Customers_ID = '#Arguments.Distributor_ID#'
					AND Invoice_Header.Deleted = 0
		</CFQUERY>
		<SPAN CLASS="Title3" STYLE="font-weight: bold;">
		Product: <SPAN STYLE="font-weight:normal;">#Get_Product_Info.Item# #Get_Product_Info.UPC# #Get_Product_Info.Description#</SPAN>
		<BR>Distributor: <SPAN STYLE="font-weight:normal;">#Get_Distributor_Info.Ship_To# #Get_Distributor_Info.Name#</SPAN>
		</SPAN>
		<CFIF Get_Invoice_Detail.RecordCount GT 0>
			<CFIF Arguments.Show_Details EQ 1>
				<CFSET Total_Volume = 0>
				<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" CLASS="Maintable" WIDTH="90%">
				<TR BGCOLOR="##FFCE84" VALIGN="bottom">
					<TD>&nbsp;</TD>
					<TD ID="header" NOWRAP WIDTH="50%"><B>Invoice Number</B></TD>
					<TD ID="header" NOWRAP WIDTH="100"><B>Invoice Date</B></TD>
					<TD ID="header" NOWRAP WIDTH="200"><B>Secondary Invoice ##</TD>
					<TD ID="header">&nbsp;</TD>
					<TD ID="header" ALIGN="RIGHT" NOWRAP><B>Volume (#this.UOM_Abbreviation#)</B></TD>
					<TD ID="header">&nbsp;</TD>
					<TD ID="header" ALIGN="RIGHT" NOWRAP><B>&##931; Volume</B></TD>
				</TR>
				<CFLOOP QUERY="Get_Invoice_Detail">
					<CFSET Total_Volume = Total_Volume + Volume>
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
					<TD>&nbsp;</TD>
					<TD>#Invoice_Number#</TD>
					<TD>#DateFormat(Invoice_Date, 'mm/dd/yyyy')#</TD>
					<TD>#Shared_Invoice_Number#</TD>					
					<TD ALIGN="right">+</TD>
					<TD ALIGN="RIGHT">#this.FormatVolume(Volume)#</TD>
					<TD>=</TD>
					<TD ALIGN="RIGHT">#this.FormatVolume(Total_Volume)#</TD>
				</TR>
				</CFLOOP>
				<TR ALIGN="CENTER">
					<TD COLSPAN="7" ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
					<B>Total Volume (&##931; Volume) = </B>
					</TD>
					<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="right">
					<CFSET data = Total_Volume>
					<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>#data#</B></SPAN>"></CFIF>
					<CFSET data = this.FormatVolume(Total_Volume)>
					<B>#data#</B>
					</TD>
				</TR>
				</TABLE>
			</CFIF>
		</CFIF>
	</cffunction>
	
	
	<!----------------- Load_Forecast_Detail() -------------------->
	<cffunction name="Load_Forecast_Detail" output="true" hint="Load_Forecast_Detail">
		<cfargument name="Product_ID" type="string" required="true" default="">
		<cfargument name="Show_Details" type="numeric" required="false" default="1">
		<CFQUERY NAME="Get_Product_Info" DATASOURCE="#application.datasource#">
			SELECT	Item, UPC, Description
			FROM	BSA_Foodservice_Items_Master
			WHERE
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#Arguments.Product_ID#'
		</CFQUERY>
		<CFQUERY NAME="Get_Forecast_Detail" DATASOURCE="#application.datasource#">
			SELECT	
					<CFIF this.UOM EQ 1>
					Volume_CS
					<CFELSE>
					Volume_LB
					</CFIF>AS Volume,
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, BSA_Foodservice_Customers.Name, BSA_Foodservice_Customers.Ship_To
			FROM	Forecast_Volume_Detail
					INNER JOIN BSA_Foodservice_Customers
					ON
					Forecast_Volume_Detail.Customer_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
			WHERE
					Product_ID = '#Arguments.Product_ID#'
					AND
					Program_ID = #this.Program_ID#
			ORDER BY BSA_Foodservice_Customers.Name
		</CFQUERY>
		<SCRIPT LANGUAGE="JavaScript">
		function Show_Invoice_Details(Dist_ID)
		{
			NewWindow('Contract_Volume_Invoice_Detail.cfm?PID=#Arguments.Product_ID#&CID=#this.Encrypted_Program_ID#&DID=' + Dist_ID, 'Forecast_Ivoice_Detail','750','350','Yes', 'Yes')
			return false;
		}
		</SCRIPT>
		<SPAN CLASS="Title3" STYLE="font-weight:bold;">Product: <SPAN STYLE="font-weight:normal;">#Get_Product_Info.Item# - #Get_Product_Info.UPC# - #Get_Product_Info.Description#</SPAN></SPAN>
		<CFIF Get_Forecast_Detail.RecordCount GT 0>
			<CFIF Arguments.Show_Details EQ 1>
				<CFSET Total_Volume = 0>
				<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" CLASS="Maintable" WIDTH="90%">
				<TR BGCOLOR="##FFCE84" VALIGN="bottom">
					<TD>&nbsp;</TD>
					<TD ID="header" NOWRAP width="75"><B>#application.returned_customer_setting.shard_ship_to_label#</B></TD>
					<TD ID="header" WIDTH="80%"><B>Name</B></TD>
					<TD ID="header">&nbsp;</TD>
					<TD ID="header" ALIGN="RIGHT" NOWRAP><B>Volume (#this.UOM_Abbreviation#)</B></TD>
					<TD ID="header">&nbsp;</TD>
					<TD ID="header" ALIGN="RIGHT" NOWRAP><B>&##931; Volume</B></TD>
				</TR>
				<CFLOOP QUERY="Get_Forecast_Detail">
					<CFSET Total_Volume = Total_Volume + Volume>
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
					<TD>&nbsp;</TD>
					<TD>#Ship_To#</TD>
					<TD>#Name#</TD>
					<TD ALIGN="left">+</TD>
					<CFSET A_START = "">
					<CFSET A_END = "">
					<CFIF Volume NEQ 0>
						<CFSET A_START = "<A HREF=""void(0);"" onClick=""javaScript:return Show_Invoice_Details('#BSA_Foodservice_Customers_ID#');"">">
						<CFSET A_END = "</A>">
					</CFIF>
					<TD ALIGN="RIGHT">#A_START##this.FormatVolume(Volume)##A_END#</TD>
					<TD>=</TD>
					<TD ALIGN="RIGHT">#this.FormatVolume(Total_Volume)#</TD>
				</TR>
				</CFLOOP>
				<TR ALIGN="CENTER">
					<TD COLSPAN=6 ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
					<B>Total Volume (&##931; Volume) = </B>
					</TD>
					<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="right">
					<CFSET data = Total_Volume>
					<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>#data#</B></SPAN>"></CFIF>
					<CFSET data = this.FormatVolume(Total_Volume)>
					<B>#data#</B>
					</TD>
				</TR>
				</TABLE>
			</CFIF>
		<CFELSE>
			<CFIF Arguments.Show_Details EQ 1>
			<B>This product doesn't have any forecast detail information</B>
			</CFIF>
		</CFIF>
   	</cffunction>
	
	<!----------------- Show_Program_Info() -------------------->
	<cffunction name="Show_Program_Info" output="true" hint="Show_Program_Info">
		<TABLE BGCOLOR="FFE4B5" WIDTH="100%">
		<TR>
		<TD>
		<SPAN CLASS="Title2" STYLE="color:black;">
		[#this.Contract_Number#] - #this.Contract_Title#
		<BR>
		Program Span: <SPAN STYLE="font-weight:normal;">#DateFormat(this.Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(this.Contract_End_Date, "mm/dd/yyyy")# (#this.Contract_Span# days)</SPAN>
		</SPAN>
		</TD>
		</TR>
		</TABLE>
   	</cffunction>
	
	<!----------------- Show_Forecast_Small_Menu() -------------------->
	<cffunction name="Show_Forecast_Small_Menu" output="true" hint="Show_Forecast_Small_Menu">		
		<TABLE CELLPADDING="0" CELLSPACING="0" BGCOLOR="EEEEEE" WIDTH="#this.Window_Max_Width#">
		<TR>
		<TD>
		<table WIDTH="50%" ALIGN="center">
		<tr>
		<CFIF this.Can_Do_Forecast>
		<td>
		<B><FONT COLOR="FF0000">[</FONT><a HREF="#CGI.SCRIPT_NAME#?#Build_To_URL(this.pass_url, "action", "forecast")#" title="do forecast...">forecast</a><FONT COLOR="FF0000">]</FONT></B>
		</td>
		</CFIF>
		<td>
		<B><FONT COLOR="FF0000">[</FONT><a HREF="#CGI.SCRIPT_NAME#?#Build_To_URL(this.pass_url, "action", "list")#" title="view the saved volume for all the products....">product list</a><FONT COLOR="FF0000">]</FONT></B>
		</td>
		<CFIF this.Previous_Forecast>
		<td>
		<B><FONT COLOR="FF0000">[</FONT><a HREF="#CGI.SCRIPT_NAME#?#Build_To_URL(this.pass_url, "action", "loadforecast")#" title="view the forecast volume for all the products....">recent forecast</a><FONT COLOR="FF0000">]</FONT></B>
		</td>
		</CFIF>
		</tr>
		</table>
		</TD>
		</TR>
		</TABLE>
   	</cffunction>
	
	<!----------------- Show_Volume_Applicator() -------------------->
	<cffunction name="Show_Volume_Applicator" output="true" hint="Show_Volume_Applicator">
		<cfargument name="Product_Count" type="numeric" required="true" default="">
		<CFSET AverageVolume = 1>
		<CFIF Product_Count GT 0>
			<CFSET AverageVolume = trim(Round(this.Check_Volume / Product_Count))>
		</CFIF> 
			
		<CFIF AverageVolume EQ 0>
			<CFSET AverageVolume = 1>
		</CFIF>
		<SCRIPT LANGUAGE="JavaScript">
		function applyGlobalVolume(volumeToApply)
		{
			var Field_Name_End_Len = Field_Name_End.length;
			for(var i=0;i<Field_Name_End_Len;i++)
			{
				if(eval("document.all.Ch_Product_Volume_" + Field_Name_End[i] + ".checked"))
				{
					//eval("document.all.WEEKLYVOLUME_" + FormattedFormElementName[i] + ".value=volumeToApply");					
					imp_obj = eval("document.all." + CheckVolumeFields[i]);
					imp_obj.value = volumeToApply;
					change_Volume_UOM_Value(imp_obj);
				}
			}
		}
		</SCRIPT>
		<TABLE WIDTH="#this.Window_Max_Width#" BORDER="0" CELLPADDING="2" CELLSPACING="0">
		<TR>
			<TD COLSPAN="4"  STYLE="border-top:1px navy solid;"><B>Volume Applicator</B></TD>
			<TD STYLE="border-top:1px navy solid;"><B>Overage Applicator</B></TD>			
		</TR>	
		<TR>
		<TD VALIGN="top" width="35%">
		<FONT SIZE="2">
		Assign a calculated weekly volume of: <CFOUTPUT><div id="AverageVolume" STYLE="DISPLAY:INLINE;">#trim(numberformat(AverageVolume, '___,___,___,___,___'))#</div></CFOUTPUT>
		<BR><FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="applyGlobalVolume(document.all.formAverageVolume.value)" STYLE="cursor: pointer;">apply calculated volume</a><FONT COLOR="Red"><B> ]</B></FONT></LI>			
		</FONT>
		</TD>
		<TD WIDTH="50" ALIGN="center"><DIV><strong>&nbsp;OR&nbsp;</strong></DIV></TD>
		<TD VALIGN="top" width="35%">
			<input type="hidden" name="formAverageVolume" value="<CFOUTPUT>#AverageVolume#</CFOUTPUT>">
			<FONT SIZE="2">
			Enter weekly volume per item:&nbsp;<input TYPE="Text" SIZE="1" NAME="globalVolume" ONKEYUP="clenseText(this,'0123456789')"> <CFOUTPUT>#this.Unit_Of_Measure_Desc#</CFOUTPUT> 
			<BR><FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="applyGlobalVolume(document.all.globalVolume.value)" STYLE="cursor: pointer;">apply entered volume</A><FONT COLOR="Red"><B> ]</B></FONT></LI>
			</FONT>
		</TD>
		<SCRIPT LANGUAGE="JavaScript">
			function ApplyOverage()
			{
				var overage_val = parseFloat(document.all.Overage_Value.value);
				var overage_uom = document.all.Overage_UOM.value;
				var apply_source = 1;
				if(document.all.Apply_Overage_On[1].checked)
				{
					apply_source = 2;
				}
				if(!isNaN(overage_val))
				{
					ApplyThisOverage(overage_val, overage_uom, apply_source);
				}
				return false;
			}
			
			function Calc_Overage(val, overage)
			{
				return val + ((val * overage) / 100);
			}
			
			function ApplyThisOverage(iVal, sUOM, apply_source)
			{
				event.returnValue = false;
				var tempVolumeObject, Forecast_pair, overaged_Value;
				
				for(var i=0;i<CheckVolumeFields.length;i++)
				{
					//Forecast_pair
					if(eval("document.all.Ch_Product_Volume_" + Field_Name_End[i] + ".checked"))
					{
						tempVolumeObject = eval("document.all." + CheckVolumeFields[i]);
						
						if(apply_source == 2)
						{
							Forecast_pair = tempVolumeObject;
							if(Forecast_pair)
							{
								overaged_Value = parseFloat(Forecast_pair.value);							
								overaged_Value = Calc_Overage(overaged_Value, iVal);
								tempVolumeObject.value = overaged_Value;
								change_Volume_UOM_Value(tempVolumeObject);
							}
						}
						else
						{
							Forecast_pair = eval("document.all." + tempVolumeObject.Forecast_pair);
							if(Forecast_pair)
							{
								overaged_Value = parseFloat(Forecast_pair.innerText);							
								overaged_Value = Calc_Overage(overaged_Value, iVal);							
								tempVolumeObject.value = ConvertToProgramVolume(overaged_Value);
								change_Volume_UOM_Value(tempVolumeObject);
							}
						}
					}
				}
			}
			<CFIF this.Previous_Forecast>
			function ConvertToProgramVolume(Forecast_Volume)
			{
				var return_Value = 0;
				var Contract_Span = #this.Contract_Span#;
				var Forecast_Span = #this.Forecast_Span#;
				if(Forecast_Span > 0)
				{
					return_Value = (Forecast_Volume / Forecast_Span) * Contract_Span;
				}
				return return_Value;
			}
			</CFIF>
			<!----
/*
			function overage_keyup(thisObj, uom_select_name)
			{
				var uom_Select = eval("document.all." + uom_select_name);
				var char_Restriction = ".-0123456789";
				if(uom_Select.value == "%")
				{
					char_Restriction = ".-0123456789";
				}
	
				clenseText(thisObj, char_Restriction);
				
				if(uom_Select.value == "%")
				{
					var tValue = thisObj.value;
					if(tValue.length > 0 && tValue != "-")
					{
						tValue = parseFloat(tValue);
						if(isNaN(tValue))
						{
							tValue = 1;
						}						
						thisObj.value = tValue;
					}
				}
			}
			*/
---->
		</SCRIPT>
		<TD WIDTH="50" ALIGN="center"><DIV><strong>&nbsp;&nbsp;</strong></DIV></TD>
		<TD ID="header" WIDTH="30%" VALIGN="top">
		<INPUT TYPE="Text" NAME="Overage_Value" VALUE="" SIZE="4" ONKEYPRESS="javaScript: return Allow_Key_List('-.0123456789');" ONKEYUP="javaScript: Numeric_Key_Only(this, true, true);"<!------ ONKEYUP="overage_keyup(this, 'Overage_UOM')"----->>
		<SELECT NAME="Overage_UOM">
			<OPTION VALUE="%" SELECTED>%</OPTION>
		</SELECT>
		<B><FONT COLOR="FF0000">[</FONT><a HREF="void(0);" onclick="javaScript: return ApplyOverage();">apply</a><FONT COLOR="FF0000">]</FONT></B>
		
		<BR>
		<INPUT TYPE="RADIO" NAME="Apply_Overage_On" <CFIF this.Previous_Forecast>CHECKED<CFELSE>DISABLED</CFIF>>Forecast Value
		<INPUT TYPE="RADIO" NAME="Apply_Overage_On" <CFIF NOT this.Previous_Forecast>CHECKED</CFIF>>Program Value
		
		</TD>
	</TR>
	<tr>
		<td colspan="100%" STYLE="border-top:1px navy solid;">		
		<strong>You may apply the same volume to all the items using the above tool, or you may specify the volume for each item below.  Click on the save button when you are done.<br></strong>
		</td>
	</tr>
</table>
	</cffunction>
	
	<!----------------- Show_Please_Wait() -------------------->
   	<cffunction name="Show_Please_Wait" output="true" hint="Show_Please_Wait">
		<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER" STYLE="display:none">
		<br><br><br>
		<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
		<br><br><br>
		</SPAN>
		<CFFLUSH>
		<SCRIPT>
		function show_please_wait(hideForm)
		{
			document.all.PleaseWaitMessage.style.display = "";
			hideForm.style.display = "none";
		}
		</SCRIPT>
	</cffunction>
	
	
	<!----------------- Show_Forecast_Form() -------------------->
   	<cffunction name="Show_Forecast_Form" output="true" hint="display forecast form">		
		<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>	
		<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
		<SCRIPT LANGUAGE="JavaScript">
			function resetDates(thisObj)
			{
				
				var thisForm 	= thisObj.form;
				var FromObj 	= thisForm.Forecast_From_Date;
				var ToObj 		= thisForm.Forecast_To_Date;
				
				var SpanArray 	= thisObj.value.split("~");
				ToObj.value 	= SpanArray[1];
				
				var ToObjAr 	= ToObj.value.split("/");
				var date1 		= new Date(ToObjAr[2], parseInt(ToObjAr[0], 10) - 1, ToObjAr[1]);
				var addDays 	= parseInt(SpanArray[0]);
				if(isNaN(addDays))
					addDays 	= 0;
				var fromDate 	= dateAdd("d", date1, (addDays * -1) + 1);
				
				var fromDateStr = "";
				fromDateStr 	= fromDateStr + PadString(fromDate.getMonth() + 1, 2, "0") + "/";				
				fromDateStr 	= fromDateStr + PadString(fromDate.getDate(), 2, "0") + "/";
				fromDateStr 	= fromDateStr + fromDate.getFullYear();				
				FromObj.value 	= fromDateStr;				
				recalc_Forecast_Span();
			}			
			
			function disableForecastOptions(index)
			{
				disableDiv("Forecast_Form_Div_" + index, false, false);
				disableDiv("Forecast_Form_Div_" + (3 - (index %  3)), true, false);
				document.all.Forecast_Option[Math.abs(1 - index)].checked = true;
				document.all.Forecast_Option[Math.abs(2 - index)].checked = false;
			}			
		</SCRIPT>
		<CFSET D_Temp = this.Show_Forecast_Small_Menu()>
		
		<!------ Build the dynamic date spans ----->		
		<CFSET Date1 = DateAdd("d", -1, this.Contract_Start_Date)>
		<CFSET Year_Ago = DateAdd("yyyy", -1, this.Contract_End_Date)>
		
		
		<CFSET Forecast_Span_Category = "Year ago volume, Most recent, Program Start">
		<CFSET Forecast_Span_Category_Date_End = "#DateFormat(Year_Ago, "mm/dd/yyyy")#,#DateFormat(DateAdd("d", -1, Now()), "mm/dd/yyyy")#,#DateFormat(DateAdd("d", -1, this.Contract_Start_Date), "mm/dd/yyyy")#">
		<CFSET DateSpanList = "90,180,365">
		<CFSET DateSpanList = ListPrepend(DateSpanList, "#this.Contract_Span#", ",")>
		
		<cfset this.Default_Span_Len 			= ListFirst(ListFirst(DateSpanList, ","), "~")>
		<CFSET Forecast_To_Date 				= DateFormat(Year_Ago, "mm/dd/yyyy")>
		<CFSET Forecast_From_Date = DateAdd("d", Evaluate((this.Default_Span_Len*-1) + 1), Forecast_To_Date)>
		
		<CFSET D_TEMP = this.CallBodyOnunload()>
		
		<FORM NAME="Forecast_Form" ACTION="Contract_Volume_Forcast_Action.cfm?#this.pass_url#" METHOD="post" STYLE="Display:Inline;">
			<INPUT TYPE="Hidden" NAME="Program_ID" VALUE="#this.Program_ID#">
			<INPUT TYPE="Hidden" NAME="FID" VALUE="#this.FID#">
			<TABLE CELLPADDING="4" CELLSPACING="0" BORDER="0" ALIGN="center" WIDTH="600">
			<TR>
				<TD ONCLICK="javaScript: disableForecastOptions(1);" STYLE="cursor:pointer;" ALIGN="center"><INPUT TYPE="CHECKBOX" CHECKED ID="Forecast_Option">
				<B>Day Option</B></TD>
				<TD ONCLICK="javaScript: disableForecastOptions(2);" STYLE="cursor:pointer;" ALIGN="center"><INPUT TYPE="CHECKBOX" ID="Forecast_Option">
				<B>Date Option</B>
				</TD>
			</TR>
			<TR VALIGN="top">
				<TD WIDTH="250" ALIGN="center">
					<DIV STYLE="DISPLAY:INLINE;" ID="Forecast_Form_Div_1">
					<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="100%">
					<CFSET counter=1>
					<CFLOOP LIST="#Forecast_Span_Category#" INDEX="This_Category" DELIMITERS=",">
					<CFSET Current_End_Date = ListGetAt(Forecast_Span_Category_Date_End, counter, ",")>
					<TR BGCOLOR="##FFE4B5">
						<TD COLSPAN="100%" NOWRAP><B>#This_Category#</B></TD>
					</TR>
					<CFSET bDisabled 	= false>
					<CFSET BGCOLOR 		= "White">
					<CFSET CH_DISABLED 	= "">
					<CFIF DATEDIFF("d", Now(), Current_End_Date) GT 0>
						<CFSET bDisabled 	= true>
						<CFSET BGCOLOR 		= "##EEEEEE">
						<CFSET CH_DISABLED 	= " DISABLED">
					</CFIF>
					
					<CFLOOP LIST="#DateSpanList#" INDEX="This_Item">
						<TR BGCOLOR="#BGCOLOR#">
							<TD BGCOLOR="White" STYLE="border-left:##FFE4B5 1px solid;">&nbsp;</TD>
							<TD NOWRAP><CFIF bDisabled><IMG SRC="/Images/radio_disabled.gif"><CFELSE><INPUT<CFIF Forecast_To_Date EQ Current_End_Date AND this.Default_Span_Len EQ This_Item> CHECKED</CFIF> ONCLICK="javaScript: resetDates(this)" VALUE="#This_Item#~#DateFormat(Current_End_Date, "mm/dd/yyyy")#" TYPE="Radio" VALUE="" NAME="Radio1" #CH_DISABLED#></CFIF></TD>
							<TD NOWRAP STYLE="font-size:12px;">#This_Item#</TD>
							<TD NOWRAP>days before</TD>
							<TD NOWRAP>#DateFormat(Current_End_Date, "mm/dd/yyyy")#</TD>
							<TD BGCOLOR="#BGCOLOR#" STYLE="border-right:##FFE4B5 1px solid;">&nbsp;</TD>
						</TR>
					</CFLOOP>
					<CFSET counter=counter+1>
					</CFLOOP>
					<TR>
						<TD BGCOLOR="White" COLSPAN="100%" STYLE="border-top:##FFE4B5 1px solid;">&nbsp;</TD>
					</TR>
					</TABLE>
					</DIV>
				</TD>			
				<TD WIDTH="200">					
					<DIV STYLE="DISPLAY:INLINE;" ID="Forecast_Form_Div_2">
					<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0">
					<TR>
						<TD><B>From</B>&nbsp;&nbsp;</TD>
						<TD><CF_EASYDATE2 FORMNAME="Forecast_Form" FIELDNAME="Forecast_From_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Forecast_From_Date#" INP_ARGUMENTS="previous_value=""#dateFormat(Forecast_From_Date, "mm/dd/yyyy")#"" onpropertychange=""reset_Forecast_Span();"" STYLE=""border:1px gray solid;"""></TD>
					</TR>
					<TR>
						<TD><B>To</B>&nbsp;&nbsp;</TD>
						<TD><CF_EASYDATE2 FORMNAME="Forecast_Form" FIELDNAME="Forecast_To_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Forecast_To_Date#" INP_ARGUMENTS="previous_value=""#dateFormat(Forecast_To_Date, "mm/dd/yyyy")#"" onpropertychange=""reset_Forecast_Span();"" STYLE=""border:1px gray solid;"""></TD>
					</TR>
					<TR>
						<TD COLSPAN="2" ALIGN="center"><B><DIV STYLE="DISPLAY:INLINE" ID="DIV_Curr_Forecast_Span">#Evaluate(DateDiff("d", Forecast_From_Date, Forecast_To_Date) + 1)#</DIV>&nbsp;days</B></TD>
					</TR>
					</TABLE>
					</DIV>
					<CFSET Date_Error_Message = "From date cannot be less than To date. And both the dates cannot be after today">
					<cf_MessageWindow>
					<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
					<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
					<SCRIPT LANGUAGE="JavaScript">
					//changeOnBlur();
					function submitForecastForm()
					{
						event.returnValue = false;
						var dateErrObj = document.all.Forecast_Form_Dates;
						if(checkValid_Dates())
						{
							clearQueue(dateErrObj);
							disableForecastOptions(2);
							document.Forecast_Form.submit();
							show_please_wait(document.all.Hide_For_Please_Wait);
						}
						else
						{
							queueMessage("#Date_Error_Message#", dateErrObj);
							showMessageWindow();
						}
					}
					
					function changeOnBlur()
					{
						//document.all.Forecast_To_Date.onpropertychange = new Function("reset_Forecast_Span()");
						//document.all.Forecast_From_Date.onpropertychange = new Function("reset_Forecast_Span()");
					}
					function reset_Forecast_Span()
					{
						if(event.propertyName == "value")
						{
							recalc_Forecast_Span();							
						}
					}
					
					function checkValid_Dates()
					{
						var returnValue = true;
						var dToDate = build_Date(document.all.Forecast_To_Date.value);
						var dFromDate = build_Date(document.all.Forecast_From_Date.value);
						
						if(dToDate != null & dFromDate != null)
						{
							var today = new Date();
							returnValue = (days_between(dToDate, dFromDate, true) >= 0) && (days_between(today, dFromDate, true) >= 0) && (days_between(today, dToDate, true) >= 0);
							if(!returnValue)
							{	
								if(event.srcElement.tagName == "INPUT")
								{
									event.srcElement.style.border = "1px red solid";
								}
							}
							else
							{
								if(event.srcElement.tagName == "INPUT")
								{
									document.all.Forecast_From_Date.style.border = "1px gray solid";
									document.all.Forecast_To_Date.style.border = "1px gray solid";
								}
							}
						}
						return returnValue;
					}
					
					function recalc_Forecast_Span()
					{
						try
						{
							var toDate = document.all.Forecast_To_Date.value;
							var fromDate = document.all.Forecast_From_Date.value;
							var dToDate = build_Date(toDate);
							var dFromDate = build_Date(fromDate);
							
							if(dToDate != null & dFromDate != null)
							{
								var days = days_between(dToDate, dFromDate, true);
								if(days < 0)
								{
									days = 0;
								}
								else
								{
									days++;
								}							
								document.all.DIV_Curr_Forecast_Span.innerText = days;
								checkValid_Dates();
							}
						}
						catch(e)
						{
							alert(e.description);
						}
					}
					</SCRIPT>
					<BR><BR>
					<FONT COLOR="red">#Date_Error_Message#</FONT>
				</TD>
				<TD ALIGN="center" WIDTH="100">
				<SPAN ID="Forecast_Form_Dates">&nbsp;&nbsp;&nbsp;</SPAN>
				<B><FONT COLOR="FF0000">[</FONT><a HREF="void(0);" ONCLICK="javaScript: return submitForecastForm()">do forecast</a><FONT COLOR="FF0000">]</FONT></B>
				</TD>
			</TR>
			</TABLE>			
		</FORM>
		<SCRIPT LANGUAGE="JavaScript">
			disableForecastOptions(1);
		</SCRIPT>
   	</cffunction>
	
	<!----------------- Do_Forecast() -------------------->
   	<cffunction name="Do_Forecast" output="true" hint="Do_Forecast">
		<cfargument name="AccessStructure" type="struct" required="true" default="">
		
		<CFPARAM NAME="Forecast_To_Date" 	DEFAULT="#Now()#">
		<CFPARAM NAME="Forecast_From_Date" 	DEFAULT="#Now()#">
		
		<CFTRANSACTION ACTION="BEGIN">
			<CFTRY>				
				<CFSTOREDPROC PROCEDURE="GET_FORECAST_VOLUME" datasource="#application.datasource#">
					<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@@C_Program_ID"	VALUE="#this.Program_ID#">
					<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_TIMESTAMP"	DBVARNAME="@@C_Start_Date"	VALUE="#DateFormat(Forecast_From_Date, "mm/dd/yyyy")#">
					<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_TIMESTAMP"	DBVARNAME="@@C_End_Date"	VALUE="#DateFormat(Forecast_To_Date, "mm/dd/yyyy")#">
				</CFSTOREDPROC>
				<!---- update format summary ----->
				<CFQUERY NAME="Delete_Existing_Record" DATASOURCE="#application.datasource#">
					UPDATE	Forecast_Summary
					SET		Deleted = 1
					WHERE
							Program_ID = #this.Program_ID#
				</CFQUERY>
				<CFQUERY NAME="Insert_New_Record" DATASOURCE="#application.datasource#">
					INSERT	INTO	Forecast_Summary
					(
						Program_ID,
						Forecast_From_Date,
						Forecast_To_Date,
						Forecast_Update_User_ID
					)
					VALUES
					(
						#this.Program_ID#,
						#CreateODBCDate(Forecast_From_Date)#,
						#CreateODBCDate(Forecast_To_Date)#,
						'#Arguments.AccessStructure.User_ID#'
					)
				</CFQUERY>
				<CFTRANSACTION ACTION="COMMIT">				
				<CFCATCH>
					<CFTRANSACTION ACTION="ROLLBACK">
					<CFRETHROW>
				</CFCATCH>
			</CFTRY>
		</CFTRANSACTION>
   	</cffunction>
	
	
	<cffunction name="Get_Null_Volume_Product_List" output="true" hint="Get_Null_Volume_Product_List">
		<cfargument name="Check_Not_Null" type="numeric" required="false" default="0">
		
		<CFQUERY NAME="Null_Volume_Product_List" DATASOURCE="#application.datasource#">
			SELECT     	DISTINCT 
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
			FROM		Contract_Products 
						INNER JOIN	BSA_Foodservice_Items_Master ON 
                      	Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
			WHERE 		Contract_Products.Contract_Main_ID = #this.Program_ID# 
						AND dbo.Contract_Products.Deleted = 0
						AND 
						( -- start and
						(--start Product_Type_ID = 1
							Contract_Products.Product_Type_ID = 1 
							AND
							exists(
								SELECT 	Program_Fixed_Price_Product_Data_ID
								FROM 	Program_Fixed_Price_Product_Data
								WHERE 	
										<CFIF Arguments.Check_Not_Null EQ 0>
										(len(Volume) <= 0 OR Volume IS NULL)
										<CFELSE>
										(len(Volume) > 0 AND Volume IS NOT NULL AND IsNumeric(Volume) = 1)
										</CFIF>										
										AND len(Fixed_Price_Value) > 0
										AND Unit_Of_Measure_ID IS NOT NULL
										AND Deleted = 0 
										AND Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
							)
						
						)--end Product_Type_ID = 1
				
						OR
						
						(--start Product_Type_ID = 2
							Contract_Products.Product_Type_ID = 2 
							AND
							exists(
								SELECT 	Program_Rebates_Product_Data_ID
								FROM 	Program_Rebates_Product_Data
								WHERE 	
										<CFIF Arguments.Check_Not_Null EQ 0>
										(len(Volume) <= 0  OR Volume IS NULL)
										<CFELSE>
										(len(Volume) > 0 AND Volume IS NOT NULL AND IsNumeric(Volume) = 1)
										</CFIF>												
										AND Deleted = 0 
										AND Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
							)
						
						)--end Product_Type_ID = 2
				
						OR
						
						(--start Product_Type_ID = 3
							Contract_Products.Product_Type_ID = 3
							AND
							exists(
								SELECT 	Program_Lump_Sum_Product_Data_ID
								FROM 	Program_Lump_Sum_Product_Data
										INNER JOIN Program_Lump_Sums
										ON
										Program_Lump_Sums.Program_Lump_Sum_ID = Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID
										AND
										Program_Lump_Sums.Deleted = 0
								WHERE 	
										<CFIF Arguments.Check_Not_Null EQ 0>
										(len(Program_Lump_Sum_Product_Data.Volume) <= 0  OR Program_Lump_Sum_Product_Data.Volume IS NULL)
										<CFELSE>
										(len(Program_Lump_Sum_Product_Data.Volume) > 0 AND Program_Lump_Sum_Product_Data.Volume IS NOT NULL AND IsNumeric(Program_Lump_Sum_Product_Data.Volume) = 1)
										</CFIF>
										AND Program_Lump_Sum_Product_Data.Deleted = 0 
										AND Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
							)
						
						)--end Product_Type_ID = 3
				
						OR
						
						(--start Product_Type_ID = 4
							Contract_Products.Product_Type_ID = 4
							AND
							exists(
								SELECT     	Program_Growth_Component_Product_Data.Contract_Products_ID
								FROM       	Program_Growth_Component_Product_Data 
											INNER JOIN	Program_Growth_Components ON 
												Program_Growth_Component_Product_Data.Program_Growth_Component_ID = dbo.Program_Growth_Components.Program_Growth_Component_ID
												AND dbo.Program_Growth_Components.Deleted = 0
											INNER JOIN	Program_Growth_Component_Tiers ON 
												Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Tiers.Program_Growth_Component_ID 
												AND dbo.Program_Growth_Component_Tiers.Tier_Number = N'1'
												AND dbo.Program_Growth_Component_Tiers.Deleted = 0 
											INNER JOIN	Program_Growth_Component_Product_Tier_Data ON 
												Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID = dbo.Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID
												AND Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID = dbo.Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID
												AND dbo.Program_Growth_Component_Product_Tier_Data.Deleted = 0
								WHERE     	(dbo.Program_Growth_Component_Product_Data.Deleted = 0) 
											AND Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
											AND 
											<CFIF Arguments.Check_Not_Null EQ 0>
											(len(Program_Growth_Component_Product_Data.Weekly_Volume) <= 0  OR Program_Growth_Component_Product_Data.Weekly_Volume IS NULL)
											<CFELSE>
											(len(Program_Growth_Component_Product_Data.Weekly_Volume) > 0 AND Program_Growth_Component_Product_Data.Weekly_Volume IS NOT NULL AND IsNumeric(Program_Growth_Component_Product_Data.Weekly_Volume) = 1)
											</CFIF>
		  					)
						)--end Product_Type_ID = 4
	
						OR
						
						(--start Product_Type_ID = 5
							Contract_Products.Product_Type_ID = 5 
							AND
							exists(
								SELECT 	Program_Formula_Pricing_Rule_Product_ID
								FROM 	Program_Formula_Pricing_Rule_Products
								WHERE 	len(Price) > 0 
										AND
										<CFIF Arguments.Check_Not_Null EQ 0>
										(len(Weekly_Volume) <= 0  OR Weekly_Volume IS NULL)
										<CFELSE>
										(len(Weekly_Volume) > 0 AND Weekly_Volume IS NOT NULL AND IsNumeric(Weekly_Volume) = 1)
										</CFIF>		
										AND Unit_Of_Measure_ID IS NOT NULL
										AND Deleted = 0 
										AND Program_Formula_Pricing_Rule_Products.Contract_Product_ID = Contract_Products.Contract_Products_ID
							)
						)--end Product_Type_ID = 5
						
						OR
						
						(--start Product_Type_ID = 8
							Contract_Products.Product_Type_ID = 8 
							AND
							exists(
								SELECT 	Program_OffInvoice_Product_Data_ID
								FROM 	Program_OffInvoice_Product_Data
								WHERE 	Discount_Amount IS NOT NULL
										AND
										<CFIF Arguments.Check_Not_Null EQ 0>
										(len(Volume) <= 0  OR Volume IS NULL)
										<CFELSE>
										(len(Volume) > 0 AND Volume IS NOT NULL AND IsNumeric(Volume) = 1)
										</CFIF>
										AND UOM IS NOT NULL
										AND Deleted = 0 
										AND Program_OffInvoice_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
							)
						)--end Product_Type_ID = 8	
						)-- end
		</CFQUERY>
		<CFRETURN Null_Volume_Product_List>
	</cffunction>
	
	<cffunction name="Get_Product_List" output="true" hint="Get_Product_List">		
		<cfargument name="Not_In_Forecast" type="numeric" required="false" default="0">
		<cfargument name="Load_Individual_Volume" type="numeric" required="false" default="1">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.Item">
		<CFSWITCH expression="#FORM.SORT_BY#">			
			<CFCASE value="Item">
				<CFSET sql_Sort_By="BSA_Foodservice_Items_Master.Item">
			</CFCASE>
			<CFCASE value="UPC">
				<CFSET sql_Sort_By="BSA_Foodservice_Items_Master.UPC">
			</CFCASE>
			<CFCASE value="Description">
				<CFSET sql_Sort_By="BSA_Foodservice_Items_Master.Description">
			</CFCASE>
		</CFSWITCH>
		<CFIF FORM.SORT_ORDER NEQ "ASC">
			<CFSET FORM.SORT_ORDER = "DESC">
		</CFIF>
		<CFSET sql_Sort_By = "#sql_Sort_By# #FORM.SORT_ORDER#">
		
		<CFQUERY NAME="Get_Distinct_Products" DATASOURCE="#application.datasource#">
			SELECT     	DISTINCT 
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
						BSA_Foodservice_Items_Master.Item, 
						BSA_Foodservice_Items_Master.UPC, 
                      	BSA_Foodservice_Items_Master.Description,
						BSA_Foodservice_Items_Master.Net_Weight
			FROM		Contract_Products 
						INNER JOIN	BSA_Foodservice_Items_Master ON 
                      	Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
			WHERE 		Contract_Products.Contract_Main_ID = #this.Program_ID# 
						AND dbo.Contract_Products.Deleted = 0
						AND 
						( -- start and
						(--start Product_Type_ID = 1
							Contract_Products.Product_Type_ID = 1 
							AND
							exists(
								SELECT 	Program_Fixed_Price_Product_Data_ID
								FROM 	Program_Fixed_Price_Product_Data
								WHERE 	Unit_Of_Measure_ID IS NOT NULL
										AND Deleted = 0 
										AND Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
							)
						
						)--end Product_Type_ID = 1
				
						OR
						
						(--start Product_Type_ID = 2
							Contract_Products.Product_Type_ID = 2 
							AND
							exists(
								SELECT 	Program_Rebates_Product_Data_ID
								FROM 	Program_Rebates_Product_Data
								WHERE 
										Deleted = 0 
										AND Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
							)
						
						)--end Product_Type_ID = 2
				
						OR
						
						(--start Product_Type_ID = 3
							Contract_Products.Product_Type_ID = 3
							AND
							exists(
								SELECT 	Program_Lump_Sum_Product_Data_ID
								FROM 	Program_Lump_Sum_Product_Data
										INNER JOIN Program_Lump_Sums
										ON
										Program_Lump_Sums.Program_Lump_Sum_ID = Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID
										AND
										Program_Lump_Sums.Deleted = 0
								WHERE 
										Program_Lump_Sum_Product_Data.Deleted = 0 
										AND Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
							)
						
						)--end Product_Type_ID = 3
				
						OR
						
						(--start Product_Type_ID = 4
							Contract_Products.Product_Type_ID = 4
							AND
							exists(
								SELECT     	Program_Growth_Component_Product_Data.Contract_Products_ID
								FROM       	Program_Growth_Component_Product_Data 
											INNER JOIN	Program_Growth_Components ON 
												Program_Growth_Component_Product_Data.Program_Growth_Component_ID = dbo.Program_Growth_Components.Program_Growth_Component_ID
												AND dbo.Program_Growth_Components.Deleted = 0
											INNER JOIN	Program_Growth_Component_Tiers ON 
												Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Tiers.Program_Growth_Component_ID 
												AND dbo.Program_Growth_Component_Tiers.Tier_Number = N'1'
												AND dbo.Program_Growth_Component_Tiers.Deleted = 0 
											INNER JOIN	Program_Growth_Component_Product_Tier_Data ON 
												Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID = dbo.Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID
												AND Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID = dbo.Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID
												AND dbo.Program_Growth_Component_Product_Tier_Data.Deleted = 0
								WHERE     	(dbo.Program_Growth_Component_Product_Data.Deleted = 0) 
											AND Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
		  					)
						)--end Product_Type_ID = 4
	
						OR
						
						(--start Product_Type_ID = 5
							Contract_Products.Product_Type_ID = 5 
							AND
							exists(
								SELECT 	Program_Formula_Pricing_Rule_Product_ID
								FROM 	Program_Formula_Pricing_Rule_Products
								WHERE 	len(Price) > 0 
										AND Unit_Of_Measure_ID IS NOT NULL
										AND Deleted = 0 
										AND Program_Formula_Pricing_Rule_Products.Contract_Product_ID = Contract_Products.Contract_Products_ID
							)
						)--end Product_Type_ID = 5
						
						OR
						
						(--start Product_Type_ID = 8
							Contract_Products.Product_Type_ID = 8 
							AND
							exists(
								SELECT 	Program_OffInvoice_Product_Data_ID
								FROM 	Program_OffInvoice_Product_Data
								WHERE 	Discount_Amount IS NOT NULL
										AND UOM IS NOT NULL
										AND Deleted = 0 
										AND Program_OffInvoice_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
							)
						)--end Product_Type_ID = 8	
						)-- end
						<CFIF Arguments.Not_In_Forecast EQ 1>
						AND
						NOT EXISTS
						(
							SELECT	Product_ID
							FROM	Forecast_Volume
							WHERE
									Contract_Products.Contract_Main_ID = Forecast_Volume.Program_ID									
									AND
									Contract_Products.BSA_Foodservice_Items_Master_ID = Forecast_Volume.Product_ID
						)
						</CFIF>
			ORDER BY #sql_Sort_By#
		</CFQUERY>
		<CFIF Arguments.Load_Individual_Volume EQ 1>
		<!------------- forecast Volume ---------------->
		<CFQUERY NAME="Get_Forecast_Volume" DATASOURCE="#application.datasource#">
			SELECT	<CFIF this.UOM EQ 1>Volume_CS<CFELSE>Volume_LB</CFIF> AS Volume, Product_ID
			FROM	Forecast_Volume
			WHERE
					Program_ID = #this.Program_ID#
		</CFQUERY>
		<CFIF this.action NEQ "loadforecast">
			<!------------- Fixed Volume ---------------->
			<CFQUERY NAME="Get_Fixed_Volume" DATASOURCE="#application.datasource#">
				SELECT 	Program_Fixed_Price_Product_Data.Volume, 
						Contract_Products.BSA_Foodservice_Items_Master_ID
				FROM 	Program_Fixed_Price_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #this.Program_ID#
				WHERE 	len(Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID) > 0
						AND Program_Fixed_Price_Product_Data.Deleted = 0 
			</CFQUERY>
			
			<!------------- Rebate Volume ---------------->
			<CFQUERY NAME="Get_Rebate_Volume" DATASOURCE="#application.datasource#">
				SELECT 	Program_Rebates_Product_Data.Volume, 
						Contract_Products.BSA_Foodservice_Items_Master_ID
				FROM 	Program_Rebates_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #this.Program_ID#
				WHERE 	len(Program_Rebates_Product_Data.Unit_Of_Measure_ID) > 0
						AND Program_Rebates_Product_Data.Deleted = 0 
			</CFQUERY>
			
			<!------------- Growth Volume ---------------->
			<CFQUERY NAME="Get_Growth_Volume" DATASOURCE="#application.datasource#">
				SELECT 	Program_Growth_Component_Product_Data.Weekly_Volume AS Volume, 
						Contract_Products.BSA_Foodservice_Items_Master_ID
				FROM 	Program_Growth_Component_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #this.Program_ID#
						INNER JOIN Program_Growth_Component_Tiers
						ON
						Program_Growth_Component_Tiers.Program_Growth_Component_ID = Program_Growth_Component_Product_Data.Program_Growth_Component_ID
						AND
						Program_Growth_Component_Tiers.Tier_Number = '1'
						AND
						Program_Growth_Component_Tiers.Deleted = 0
						INNER JOIN Program_Growth_Component_Product_Tier_Data
						ON
						Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID = Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
						AND
						Program_Growth_Component_Product_Tier_Data.Deleted = 0
						AND
						Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID
						
				WHERE 	len(Program_Growth_Component_Product_Tier_Data.Unit_Of_Measure_ID) > 0
						AND Program_Growth_Component_Product_Data.Deleted = 0 
			</CFQUERY>
			
			<!------------- Formula Volume ---------------->
			<CFQUERY NAME="Get_Formula_Volume" DATASOURCE="#application.datasource#">
				SELECT 	Program_Formula_Pricing_Rule_Products.Weekly_Volume AS Volume, 
						Contract_Products.BSA_Foodservice_Items_Master_ID
				FROM 	Program_Formula_Pricing_Rule_Products
						INNER JOIN Contract_Products
						ON
						Program_Formula_Pricing_Rule_Products.Contract_Product_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #this.Program_ID#
				WHERE 	len(Program_Formula_Pricing_Rule_Products.Unit_Of_Measure_ID) > 0
						AND Program_Formula_Pricing_Rule_Products.Deleted = 0 
			</CFQUERY>
			
			<!------------- Off_Invoice Volume ---------------->
			<CFQUERY NAME="Get_Off_Invoice_Volume" DATASOURCE="#application.datasource#">
				SELECT 	Program_OffInvoice_Product_Data.Volume, 
						Contract_Products.BSA_Foodservice_Items_Master_ID
				FROM 	Program_OffInvoice_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_OffInvoice_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #this.Program_ID#
				WHERE 	len(Program_OffInvoice_Product_Data.UOM) > 0
						AND Program_OffInvoice_Product_Data.Deleted = 0 
			</CFQUERY>
			
			<!------------- Lumpsum Volume ---------------->
			<CFQUERY NAME="Get_Lumpsum_Volume" DATASOURCE="#application.datasource#">
				SELECT 	Program_Lump_Sum_Product_Data.Volume, 
						Contract_Products.BSA_Foodservice_Items_Master_ID
				FROM 	Program_Lump_Sum_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #this.Program_ID#
				WHERE 	len(Program_Lump_Sum_Product_Data.Volume) > 0
						AND Program_Lump_Sum_Product_Data.Deleted = 0 
			</CFQUERY>
		</CFIF>
		</CFIF>
	</cffunction>
	
	
<!----****************************************************************************
****************************************************************Show_Product_List()
******************************************************************************---->
   	<cffunction name="Show_Product_List" output="true" hint="Show_Product_List">
		<CFSET D_Temp = this.Load_Forecast_Summary()>
		<CFSET D_Temp = this.Show_Forecast_Small_Menu()>
		
		<CFSET D_Temp = this.Get_Product_List()>
		<CFIF Get_Distinct_Products.RecordCount EQ 0>
			<CFRETURN>
		</CFIF>
		<CFSET D_Temp = this.Show_Volume_Applicator(Get_Distinct_Products.RecordCount)>
		
		<CFSET This_Template_Name = "#CGI.SCRIPT_NAME#?#Build_To_URL(this.pass_url, "action", action)#">
		<CFSET Save_Template_Name = "contract_volume_action.cfm?#Build_To_URL(this.pass_url, "action", action)#">
		
		<STYLE>
			.MainHead TD
			{
				font-size: 12px;
			}
			.DIV_HIDE_OVERFLOW
			{
				overflow:hidden;
			}
			TABLE.Maintable TD 
			{
				border:none;
			}
			.BlackBorder
			{
				border:1px solid black;
			}
			.RedBorder
			{
				border:1px solid red;
			}
			.BlueBorder
			{
				border:1px solid blue;
			}
			.GreenBorder
			{
				border:1px solid ##C71585;
			}
		</STYLE>
		<CFSET Good_Input_Border = "BlackBorder">
		<CFSET Bad_Input_Border = "RedBorder">
		<CFIF this.action EQ "loadforecast">
			<CFSET Good_Input_Border = "BlueBorder">
		</CFIF>
		<CFSET Edited_Input_Border = "GreenBorder">
		
		<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/math_functions.js"></SCRIPT>
		<SCRIPT LANGUAGE="JavaScript">
		<CFOUTPUT>
		var Contract_Span = #this.Contract_Span#;
		</CFOUTPUT>
		function ConvertToUOM(UOM_1_Value, To_UOM, Net_Weight)
		{
			var UOM_2_Value = 0;
			if(To_UOM == 1)//to case
			{
				if(Net_Weight != 0)
				{
					UOM_2_Value = UOM_1_Value / Net_Weight;
				}
			}
			else//to lb
			{
				UOM_2_Value = UOM_1_Value * Net_Weight;
			}
			return UOM_2_Value;
		}
		function change_Volume_UOM_Value(thisObj)
		{
			var newVal2 = null;
			var AnnualNewVal1 = "";
			var AnnualNewVal2 = "";
			
			var pgm_totalobj = null;
			
			var newVal1 = parseFloat(thisObj.value);
			var oAnnual_pair = document.getElementById(thisObj.annual_pair);
			var pair_volume_field = thisObj.pair_volume_field;
			var obj_pair_volume_field = document.getElementById(pair_volume_field);
			var oAnnual_pair2 = document.getElementById(obj_pair_volume_field.annual_pair);
			if(isNaN(newVal1))
			{
				newVal1 = 0;
			}
			
			if(!isNaN(newVal1))
			{				
				var dailyVolume = newVal1/Contract_Span;
				AnnualNewVal1 = dailyVolume * 360;
				//annual volume for same uom
							
				//get the other uom pair
				
				
				if(pair_volume_field)
				{
					
					var netweight = parseFloat(thisObj.netweight);
					if(!isNaN(netweight))
					{					
						if(thisObj.current_uom == 1)//cs
						{
							AnnualNewVal2 = AnnualNewVal1 * netweight;
							newVal2 = ConvertToUOM(newVal1, 2, netweight);
							AnnualNewVal2 = ConvertToUOM(AnnualNewVal1, 2, netweight);
							pgm_totalobj = document.all.DIV_Program_Total_CS;
						}
						else//lb
						{
							newVal2 = ConvertToUOM(newVal1, 1, netweight);
							AnnualNewVal2 = ConvertToUOM(AnnualNewVal1, 1, netweight);
							pgm_totalobj = document.all.DIV_Program_Total_LB;
						}
					}//if(!isNaN(netweight))
				}//if(pair_volume_field)			
			}//if(!isNaN(newVal1))						
			thisObj.value = removeExponentialFormatting(newVal1);
			obj_pair_volume_field.value = removeExponentialFormatting(Math.round(newVal2));
			oAnnual_pair.value = removeExponentialFormatting(AnnualNewVal1);
			oAnnual_pair.innerText = format_Volume(removeExponentialFormatting(AnnualNewVal1));
			oAnnual_pair.title = format_Volume(removeExponentialFormatting(AnnualNewVal1));
			oAnnual_pair2.value = removeExponentialFormatting(AnnualNewVal2);
			oAnnual_pair2.innerText = format_Volume(removeExponentialFormatting(AnnualNewVal2));
			oAnnual_pair2.title = format_Volume(removeExponentialFormatting(AnnualNewVal2));
			
			var suffix_text1, suffix_text1;
			if(thisObj.current_uom == 1)
			{
				suffix_text1 = "_CS";
				suffix_text2 = "_LB";				
			}
			else
			{
				suffix_text1 = "_LB";
				suffix_text2 = "_CS";
			}
			adjustThisTotalValue(eval("document.all.DIV_Program_Total" + suffix_text1), thisObj);
			adjustThisTotalValue(eval("document.all.DIV_Program_Total" + suffix_text2), obj_pair_volume_field);
			adjustThisTotalValue(eval("document.all.DIV_Annual_Total" + suffix_text1), oAnnual_pair);
			adjustThisTotalValue(eval("document.all.DIV_Annual_Total" + suffix_text2), oAnnual_pair2);
			
			if(pgm_totalobj != null)
			{
				document.all.DIV_Program_Volume.innerText = removeExponentialFormatting(Math.round(pgm_totalobj.total_value));
			}
			
			
			if(thisObj.current_uom == "#this.UOM#")
			{
				var Err_Check_Obj = thisObj;
				var Err_Check_Obj_Value = newVal1;
			}
			else
			{
				var Err_Check_Obj = obj_pair_volume_field;
				var Err_Check_Obj_Value = Math.round(newVal2);
			}
			if(Err_Check_Obj_Value <= 0)
			{
				Err_Check_Obj.className = "#Bad_Input_Border#";
			}
			else
			{
				Err_Check_Obj.className = "#Good_Input_Border#";
			}			
			
			//originalValue
			adjustTableWidth();
		}
		
		
		function adjustThisTotalValue(tot_div, thisObj)
		{
			var total_value = parseInt(tot_div.total_value);			
			total_value = total_value - parseInt(thisObj.previous_value);			
			total_value = total_value + parseInt(thisObj.value);
			thisObj.previous_value = thisObj.value;
			tot_div.total_value = removeExponentialFormatting(Math.round(total_value));
			tot_div.innerText = format_Volume(total_value);			
		}
		
		function format_Volume(vol)
		{
			//return formatToDecimalPlaces(vol, 2);
			return formatWithComma(vol, 3, false);
		}
		
		
		function sort_by_This(thisVal, thisOrder)
		{
			document.MyForm.SORT_BY.value = thisVal;
			document.MyForm.SORT_ORDER.value = thisOrder;			
			document.MyForm.submit();
			return false;
		}
		
		function save_volume()
		{
			event.returnValue = false;
			var Total_Product_Volume = 0;
			var ErrorCount = 0;
			var sErr = "";
			for(var i=0;i<CheckVolumeFields.length;i++)
			{
				tempVolumeObject = eval("document.all." + CheckVolumeFields[i]);
				tempVolumeObjectSpan	= eval("document.all." + SP_VolumeFields[i])
				
				Total_Product_Volume = Total_Product_Volume + parseInt(tempVolumeObject.value);
				sErr = checkThisVolume(tempVolumeObject.value);
				if(sErr.length > 0)
				{
					ErrorCount++;
					queueMessage(sErr, tempVolumeObjectSpan);
				}
				else 
				{
					clearQueue(tempVolumeObjectSpan);
				}
			}
			var Contract_Quantity = <CFOUTPUT>#this.Check_Volume#</CFOUTPUT>;
			if(ErrorCount==0)
			{
				if(Contract_Quantity != Total_Product_Volume)
				{
					if(confirm("The total program volume you have entered (" + Total_Product_Volume + " <CFOUTPUT>#this.Unit_Of_Measure_Desc#</CFOUTPUT>) does not equal the calculated total program volume (" + Contract_Quantity + " <CFOUTPUT>#this.Unit_Of_Measure_Desc#</CFOUTPUT>). Press OK to continue or CANCEL to adjust."))
					{
						save_volume_submit();
					}
				}
				else
				{
					save_volume_submit();
				}
			}
			else
			{
				showMessageWindow();
			}
			return false;
		}
		
		function checkThisVolume(sVol)
		{
			var sErr = "";
			var iVol = parseFloat(sVol);
			if(sVol.length == 0)
			{
				sErr = "Enter a volume";
			}
			else if(isNaN(iVol))
			{
				sErr = "Invalid volume";
			}
			else if(iVol <= 0)
			{
				sErr = "Volume should be greater than zero";
			}
			return sErr;
		}
		
		function save_volume_submit()
		{
			document.MyForm.action = "<CFOUTPUT>#Save_Template_Name#</CFOUTPUT>";
			document.MyForm.submit();
		}
		
		function adjustTableWidth()
		{
			adjustThisTD("TD_Checkbox");
			adjustThisTD("TD_Item");
			adjustThisTD("TD_Description");
			adjustThisTD("TD_Forecast_CS");
			adjustThisTD("TD_Forecast_LB");
			adjustThisTD("TD_Annual_CS");
			adjustThisTD("TD_Annual_LB");
			adjustThisTD("TD_Program_CS");
			adjustThisTD("TD_Program_LB");
			adjustThisTD("TD_Program_Error_CS");
			adjustThisTD("TD_Program_Error_LB");
		}
		
		function adjustThisTD(TDName)
		{
			var tCells = document.getElementsByName(TDName);
			var i, tCellLen;
			tCellLen = tCells.length;
			if(tCellLen >= 2)
			{
				tCells[0].style.width = tCells[1].offsetWidth;
			}
			if(tCellLen >= 3)
			{
				tCells[tCellLen-1].style.width = tCells[1].offsetWidth;
			}
		}
		document.body.onload = new Function("adjustTableWidth();setDetailDivHeight();");
		document.body.onresize = new Function("setDetailDivHeight();");
		</SCRIPT>
		
		<CFSET D_TEMP = this.CallBodyOnunload()>
		
		<FORM METHOD="post" ACTION="#This_Template_Name#" NAME="MyForm" STYLE="DISPLAY:INLINE;">
		<CFOUTPUT>
		<INPUT TYPE="Hidden" NAME="SORT_BY" VALUE="#FORM.SORT_BY#">
		<INPUT TYPE="Hidden" NAME="SORT_ORDER" VALUE="#FORM.SORT_ORDER#">		
		<INPUT TYPE="Hidden" NAME="Program_ID" VALUE="#this.Program_ID#">
		<INPUT TYPE="Hidden" NAME="Product_List" VALUE="#ValueList(Get_Distinct_Products.BSA_Foodservice_Items_Master_ID, ",")#">
		</CFOUTPUT>
		<TABLE border="0" cellspacing="1" cellpadding="2" CLASS="MainHead" WIDTH="#this.Window_Max_Width#" BGCOLOR="##ffce84">
		<TR VALIGN="top" BGCOLOR="White">
			<TD COLSPAN="3"></TD>
			<CFIF this.Previous_Forecast>
			<TD COLSPAN="2" ID="header" ALIGN="center" STYLE="border:none;">			
			<B>#DateFormat(this.Forecast_From_Date, "mm/dd/yyyy")# - #DateFormat(this.Forecast_To_Date, "mm/dd/yyyy")# (#this.Forecast_Span#)</B>			
			</TD>
			<TD COLSPAN="2"></TD>
			<CFELSE>
			<TD COLSPAN="2"></TD>
			</CFIF>			
			<TD COLSPAN="10" ID="header" ALIGN="center" STYLE="border:none;">
			<B>#DateFormat(this.Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(this.Contract_End_Date, "mm/dd/yyyy")# (#this.Contract_Span#)</B>
			</TD>
		</TR>
		<TR ID="header" BGCOLOR="##ffce84" VALIGN="bottom">
			<TD ROWSPAN="2" align="center" ID="TD_Checkbox"><INPUT Name="allbox" TYPE="Checkbox" onClick="CHSelectAll('Ch_Product_Volume_', this.checked);" TITLE="Click here to select all Products" checked></TD>
			<TD ROWSPAN="2" align="left" ID="TD_Item">
				<cfset D_Temp = this.Show_Sort_String("Item", "#application.returned_customer_setting.item_label# ##")>
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
				<B>/</B><BR>
				<cfset D_Temp = this.Show_Sort_String("UPC", "#application.returned_customer_setting.upc_label#")>
				</cfif></cfif>
				</TD>
			<TD ROWSPAN="2" align="left" ID="TD_Description">
			<cfset D_Temp = this.Show_Sort_String("Description", "Description")>
			</TD>			
			<CFIF this.Previous_Forecast>
			<TD COLSPAN="2" STYLE="border-bottom:2px solid black;" align="center"><B>Actual Volume</B></TD>
			</CFIF>
			<TD COLSPAN="2" STYLE="border-bottom:2px solid black;" align="center"><B>Annual Volume</B></TD>
			<TD COLSPAN="4" STYLE="border-bottom:2px solid black;" align="center"><B>Program Volume</B></TD>
		</TR>
		<TR ID="header" BGCOLOR="##ffce84" VALIGN="bottom">
			<CFIF this.Previous_Forecast>
			<TD ALIGN="right" ID="TD_Forecast_CS"><B>Case</B></TD>
			<TD ALIGN="right" ID="TD_Forecast_LB"><B>Pound</B></TD>
			</CFIF>
			<TD ALIGN="right" ID="TD_Annual_CS"><B>Case</B></TD>
			<TD ALIGN="right" ID="TD_Annual_LB"><B>Pound</B></TD>
			<TD ALIGN="right" ID="TD_Program_CS"><B>Case</B></TD>
			<TD ALIGN="right" ID="TD_Program_LB"><B>Pound</B></TD>
		</TR>
		</TABLE>
		<CFSET Volume_Col_Min_Width = 80>
		<span ID="SP_Details" class="Scroll_Table_Body" STYLE="width:816px;height:100px;overflow:auto;border-bottom:1px solid ##93BEE2;">
		<TABLE border="0" cellspacing="1" cellpadding="2" CLASS="Maintable" WIDTH="#this.Window_Max_Width#" ID="Table_Product_List" BGCOLOR="##93BEE2">
		<script>
			var CheckVolumeFields = new Array();
			var SP_VolumeFields = new Array();
			var Field_Name_End = new Array();
		</script>
		<CFSET Forecast_Total_CS = 0>
		<CFSET Forecast_Total_LB = 0>
		<CFSET Annual_Total_CS = 0>
		<CFSET Annual_Total_LB = 0>
		<CFSET Program_Total_CS = 0>
		<CFSET Program_Total_LB = 0>
		
		<CFLOOP QUERY="Get_Distinct_Products">
			<CFSET FieldNameEnd = InputNameCompatableGUID(BSA_Foodservice_Items_Master_ID)>
			<CFSET Input_CS_Name = "Product_Volume_#FieldNameEnd#_CS">
			<CFSET Input_LB_Name = "Product_Volume_#FieldNameEnd#_LB">
			
			<CFSET Forecast_Volume_CS = "Forecast_Volume_#FieldNameEnd#_CS">
			<CFSET Forecast_Volume_LB = "Forecast_Volume_#FieldNameEnd#_LB">
			
			<CFSET Err_PS_CS_Name = "error_Vol_#FieldNameEnd#_cs">
			<CFSET Err_PS_LB_Name = "error_Vol_#FieldNameEnd#_lb">
			<script>
				<cfif this.UOM EQ 1>
					CheckVolumeFields[CheckVolumeFields.length] = "#Input_CS_Name#";
					SP_VolumeFields[SP_VolumeFields.length] = "#Err_PS_CS_Name#";
					//FieldNameEnd
				<CFELSE>
					CheckVolumeFields[CheckVolumeFields.length] = "#Input_LB_Name#";
					SP_VolumeFields[SP_VolumeFields.length] = "#Err_PS_LB_Name#";
				</cfif>
				Field_Name_End[Field_Name_End.length] = "#FieldNameEnd#";
			</script>
			<TR VALIGN="top"<CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
				<CFSET Annual_Volume_CS = "">
				<CFSET Annual_Volume_LB = "">
				<CFIF this.Previous_Forecast>
					<CFIF this.UOM EQ 1>
						<CFSET Forecast_Volume_CS 	= this.GetProductVolume(BSA_Foodservice_Items_Master_ID, 1)>
						<CFSET Forecast_Volume_LB 	= ConvertToUOM(Forecast_Volume_CS, 2, Net_Weight)>
					<CFELSE>
						<CFSET Forecast_Volume_LB 	= this.GetProductVolume(BSA_Foodservice_Items_Master_ID, 1)>
						<CFSET Forecast_Volume_CS 	= ConvertToUOM(Forecast_Volume_LB, 1, Net_Weight)>
					</CFIF>
				<CFELSE>
					<CFSET Forecast_Volume_CS = 0>
					<CFSET Forecast_Volume_LB = 0>
				</CFIF>
				
				<CFSET Volume_Good = true>
				<CFIF this.UOM EQ 1><!---- program UOM is CS ---->
					
					<CFIF this.action EQ "loadforecast"><!---- load from forecast table ---->
						<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#ConvertToProgramVolume(Forecast_Volume_CS)#">
					<CFELSE>						
						<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#this.GetProductVolume(BSA_Foodservice_Items_Master_ID)#">
					</CFIF>
					
					<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
					<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#ConvertToUOM(This_Volume_CS, 2, Net_Weight)#">
					<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>
					<CFIF This_Volume_CS NEQ 0 AND IsNumeric(This_Volume_CS)>
						<CFSET Annual_Volume_CS 			= (This_Volume_CS / this.Contract_Span) * 360>
						<CFSET Annual_Volume_LB 			= (This_Volume_LB / this.Contract_Span) * 360>
					</CFIF>
					
					<CFSET LB_Input_Class = Good_Input_Border>
					<CFSET CS_Input_Class = Good_Input_Border>
					<CFIF This_Volume_CS LTE 0>
						<CFSET CS_Input_Class = Bad_Input_Border>
						<CFSET Volume_Good = false>
					</CFIF>
				<CFELSE><!---- program UOM is LB ---->
					
					<CFIF this.action EQ "loadforecast">
						<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#ConvertToProgramVolume(Forecast_Volume_LB)#">
					<CFELSE>
						<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#this.GetProductVolume(BSA_Foodservice_Items_Master_ID)#">
					</CFIF>
					
					<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>					
					<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#ConvertToUOM(This_Volume_LB, 1, Net_Weight)#">
					<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
					<CFSET Annual_Volume_CS 				= ConvertToAnnualVolume(This_Volume_CS)>
					<CFSET Annual_Volume_LB 				= ConvertToAnnualVolume(This_Volume_LB)>
					
					<CFSET CS_Input_Class = Good_Input_Border>
					<CFSET LB_Input_Class = Good_Input_Border>
					<CFIF This_Volume_LB LTE 0>
						<CFSET LB_Input_Class = Bad_Input_Border>
						<CFSET Volume_Good = false>
					</CFIF>
				</CFIF>
				
				<TD align="center" ID="TD_Checkbox"><span ID="checkBoxCollection"><INPUT type="Checkbox" NAME="Ch_Product_Volume_#FieldNameEnd#" VALUE="1" <CFIF NOT Volume_Good>checked</CFIF>></span></TD>
				<TD NOWRAP ID="TD_Item">
					#ITEM#
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
					<BR>#UPC#
					</cfif></cfif>
				</TD>
				<TD ID="TD_Description">#Description#</TD>
				
				<CFIF this.Previous_Forecast>
				<TD ALIGN="right" ID="TD_Forecast_CS" WIDTH="#Volume_Col_Min_Width#" STYLE="cursor:pointer;color:blue;" onClick="Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');"><DIV ID="Forecast_cs_#FieldNameEnd#" STYLE="display:none">#Forecast_Volume_CS#</DIV><DIV>#this.FormatVolume(Forecast_Volume_CS)#</DIV>&nbsp;</TD>
				<TD ALIGN="right" ID="TD_Forecast_LB" WIDTH="#Volume_Col_Min_Width#" STYLE="cursor:pointer;color:blue;" onClick="Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');"><DIV ID="Forecast_lb_#FieldNameEnd#" STYLE="display:none">#Forecast_Volume_LB#</DIV><DIV>#this.FormatVolume(Forecast_Volume_LB)#</DIV>&nbsp;</TD>
				</CFIF>
				<TD ALIGN="right" ID="TD_Annual_CS" WIDTH="#Volume_Col_Min_Width#"><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#px;" ID="annual_cs_#FieldNameEnd#" previous_value="#this.FormatVolume(Annual_Volume_CS, 0)#" value="#this.FormatVolume(Annual_Volume_CS, 0)#">#this.FormatVolume(Annual_Volume_CS)#</DIV>&nbsp;</TD>
				<TD ALIGN="right" ID="TD_Annual_LB" WIDTH="#Volume_Col_Min_Width#"><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#px;" ID="annual_lb_#FieldNameEnd#" previous_value="#this.FormatVolume(Annual_Volume_LB, 0)#" value="#this.FormatVolume(Annual_Volume_LB, 0)#">#this.FormatVolume(Annual_Volume_LB)#</DIV>&nbsp;</TD>
				<TD ALIGN="right" ID="TD_Program_CS" WIDTH="#Evaluate(Volume_Col_Min_Width+20)#">
				<SPAN ID="#Err_PS_CS_Name#">&nbsp;</SPAN>&nbsp;				
				<INPUT STYLE="text-align:right;width:#Evaluate(Volume_Col_Min_Width-9)#px;" CLASS="#CS_Input_Class#" SIZE="3" TYPE="Text" NAME="#Input_CS_Name#" VALUE="#this.FormatVolume(This_Volume_CS, 0)#" SIZE="10" ONKEYPRESS="javaScript: return Allow_Key_List('0123456789');" ONKEYUP="javaScript: Numeric_Key_Only(this, false, false);" onChange="change_Volume_UOM_Value(this);" pair_volume_field="#Input_LB_Name#" annual_pair="annual_cs_#FieldNameEnd#" Forecast_pair="Forecast_cs_#FieldNameEnd#" netweight="#Net_Weight#" current_uom="1" previous_value="#this.FormatVolume(This_Volume_CS, 0)#"></TD>
				<TD ALIGN="right" ID="TD_Program_LB" WIDTH="#Evaluate(Volume_Col_Min_Width+20)#">
				<SPAN ID="#Err_PS_LB_Name#">&nbsp;</SPAN>&nbsp;
				<INPUT STYLE="text-align:right;width:#Evaluate(Volume_Col_Min_Width-9)#px;" CLASS="#LB_Input_Class#" SIZE="3" TYPE="Text" NAME="#Input_LB_Name#" VALUE="#this.FormatVolume(This_Volume_LB, 0)#" SIZE="10" ONKEYPRESS="javaScript: return Allow_Key_List('0123456789');" ONKEYUP="javaScript: Numeric_Key_Only(this, false, false);" onChange="change_Volume_UOM_Value(this);" pair_volume_field="#Input_CS_Name#" annual_pair="annual_lb_#FieldNameEnd#" Forecast_pair="Forecast_lb_#FieldNameEnd#" netweight="#Net_Weight#" current_uom="2" previous_value="#this.FormatVolume(This_Volume_LB, 0)#"></TD>
			</TR>
			<CFIF IsNumeric(Forecast_Volume_CS)>
				<CFSET Forecast_Total_CS 	= Forecast_Total_CS + RoundVolume(Forecast_Volume_CS)>
			</CFIF>
			<CFIF IsNumeric(Forecast_Volume_LB)>
				<CFSET Forecast_Total_LB 	= Forecast_Total_LB + RoundVolume(Forecast_Volume_LB)>
			</CFIF>
			<CFIF IsNumeric(Annual_Volume_CS)>
				<CFSET Annual_Total_CS 		= Annual_Total_CS + RoundVolume(Annual_Volume_CS)>
			</CFIF>
			<CFIF IsNumeric(Annual_Volume_LB)>
				<CFSET Annual_Total_LB 		= Annual_Total_LB + RoundVolume(Annual_Volume_LB)>
			</CFIF>
			<CFIF IsNumeric(This_Volume_CS)>
				<CFSET Program_Total_CS 	= Program_Total_CS + RoundVolume(This_Volume_CS)>
			</CFIF>
			<CFIF IsNumeric(This_Volume_LB)>
				<CFSET Program_Total_LB 	= Program_Total_LB + This_Volume_LB>
			</CFIF>
		</CFLOOP>
		</TABLE>		
		</span>
		<TABLE border="0" cellspacing="1" cellpadding="2" ID="Totals_TABLE" CLASS="MainHead" WIDTH="#this.Window_Max_Width#">
		<TR ID="header" VALIGN="top" BGCOLOR="##FFFFFF">
			<TD align="center" ID="TD_Checkbox" BGCOLOR="white">&nbsp;</TD>
			<TD align="left" ID="TD_Item" BGCOLOR="white">&nbsp;</TD>
			<TD align="right" ID="TD_Description" BGCOLOR="white"><B>Total volume :</B></TD>
			<CFIF this.Previous_Forecast>
			<TD ALIGN="right" ID="TD_Forecast_CS"><B>#this.FormatVolume(Forecast_Total_CS)#</B></TD>
			<TD ALIGN="right" ID="TD_Forecast_LB"><B>#this.FormatVolume(Forecast_Total_LB)#</B></TD>
			</CFIF>
			<TD ALIGN="right" ID="TD_Annual_CS"><DIV ID="DIV_Annual_Total_CS" total_value="#this.FormatVolume(Annual_Total_CS, 0)#" STYLE="font-weight:bold;">#this.FormatVolume(Annual_Total_CS)#</DIV></TD>
			<TD ALIGN="right" ID="TD_Annual_LB"><DIV ID="DIV_Annual_Total_LB" total_value="#this.FormatVolume(Annual_Total_LB, 0)#" STYLE="font-weight:bold;">#this.FormatVolume(Annual_Total_LB)#</TD>
			<TD ALIGN="right" ID="TD_Program_CS"><DIV ID="DIV_Program_Total_CS" total_value="#this.FormatVolume(Program_Total_CS, 0)#" STYLE="font-weight:bold;">#this.FormatVolume(Program_Total_CS)#</DIV></TD>
			<TD ALIGN="right" ID="TD_Program_LB"><DIV ID="DIV_Program_Total_LB" total_value="#this.FormatVolume(Program_Total_LB, 0)#" STYLE="font-weight:bold;">#this.FormatVolume(Program_Total_LB)#</DIV></TD>
		</TR>
		</TABLE>
		<TABLE BORDER="0" WIDTH="#this.Window_Max_Width#" ID="Save_Link_TABLE" CELLPADDING="0" CELLSPACING="0">
			<TR VALIGN="top">
				<TD ROWSPAN="100%" WIDTH="200">
				<TABLE CELLPADDING="0" CELLSPACING="0" STYLE="border:1px ##00BFFF solid;" WIDTH="100%">
					<TR>
						<TD WIDTH="10">&nbsp;</TD>
						<TD><INPUT DISABLED TYPE="Text" CLASS="#Good_Input_Border#" STYLE="width:15px;height:10px;"></TD>
						<TD>&nbsp;&nbsp;&nbsp;<CFIF this.action EQ "loadforecast">Forcast volume. </CFIF>Valid volume</TD>
					</TR>
					<TR>
						<TD WIDTH="10">&nbsp;</TD>
						<TD><INPUT DISABLED TYPE="Text" CLASS="#Bad_Input_Border#" STYLE="width:15px;height:10px;"></TD>
						<TD>&nbsp;&nbsp;&nbsp;Invalid volume</TD>
					</TR>
				</TABLE>
				</TD>
				<TD COLSPAN="3" ALIGN="center" STYLE="color:##800000;font-size:11px;">
				<sup>*</sup>All values are rounded to the nearest whole number
				</TD>
			</TR>
			<TR>
				<TD COLSPAN="3" ALIGN="center">
				<CFIF this.UOM EQ 1>
					<CFSET Total_Program_Volume = Program_Total_CS>
				<CFELSE>
					<CFSET Total_Program_Volume = Program_Total_LB>
				</CFIF>
				<INPUT TYPE="Checkbox" NAME="Save_Program_Volume" VALUE="1" CHECKED>Save&nbsp;<DIV ID="DIV_Program_Volume" STYLE="DISPLAY:INLINE;font-weight:bold;">#this.FormatVolume(Total_Program_Volume)#</DIV>&nbsp;as Program Quantity
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right" WIDTH="25%">
					<B><FONT SIZE="2" COLOR="FF0000">[</FONT> <a HREF="void(0);" onClick="save_volume();return false;"><FONT SIZE="2">save</FONT></a> <FONT SIZE="2" COLOR="FF0000">]</FONT></B>
				</TD>
				<TD width="50">&nbsp;</TD>
				<TD ALIGN="left" WIDTH="25%">
					<B><FONT SIZE="2" COLOR="FF0000">[</FONT> <a HREF="void(0);" onClick="closeWindow();return false;"><FONT SIZE="2">close</FONT></a> <FONT SIZE="2" COLOR="FF0000">]</FONT></B>
				</TD>
			</TR>
		</TABLE>
		<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
		<SCRIPT LANGUAGE="JavaScript">
		var oDiv;
		function setDetailDivHeight()
		{
			oDiv = document.all.SP_Details;
			oDiv.style.height = getDetailsDivHeight();	
		}
		function getDetailsDivHeight()
		{
			var retunValue = "";
			var oTable_Product_List = document.all.Table_Product_List;
			var oRows = oTable_Product_List.rows;
			if(oRows.length > 0)
			{
				var lastRow = oRows[oRows.length-1];
				var lastRowTop = getTotalOffsetProperty(lastRow, "body", "offsetTop", 0);
				maxHeight = document.body.clientHeight;

				var oSave_Link_TABLE_offsetHeight = 0;
				var oSave_Link_TABLE = document.all.Save_Link_TABLE;
				var Totals_TABLE = document.all.Totals_TABLE;
					
				if(oSave_Link_TABLE)
				{
					oSave_Link_TABLE_offsetHeight = oSave_Link_TABLE_offsetHeight + oSave_Link_TABLE.offsetHeight;
				}
				if(Totals_TABLE)
				{
					oSave_Link_TABLE_offsetHeight = oSave_Link_TABLE_offsetHeight + Totals_TABLE.offsetHeight;
				}
				lastRowTop = lastRowTop + oSave_Link_TABLE_offsetHeight;
				
				if((lastRowTop  + 15) < maxHeight)
				{
					maxHeight = lastRowTop;
				}
				else
				{
					maxHeight = maxHeight - oSave_Link_TABLE_offsetHeight - 15;
				}
				
				getTotalOffsetProperty(oDiv, "body", "offsetTop", 0);
				retunValue = (maxHeight - getTotalOffsetProperty(oDiv, "body", "offsetTop", 0));
				var detailsTableHeight = oTable_Product_List.offsetHeight + 1;
				if(retunValue > detailsTableHeight)
				{
					retunValue = detailsTableHeight;
				}
				if(retunValue <=0)
				{
					retunValue = 30;
				}
				retunValue = retunValue + "px";
			}
			return retunValue;
		}
		function Show_Forecast_Details(Product_ID)
		{
			event.returnValue = false;
			NewWindow('Contract_Volume_Forcast_Detail.cfm?PID=' + Product_ID + '&CID=#this.Encrypted_Program_ID#', 'Forecast_Detail','750','350','Yes', 'Yes')
		}
		</SCRIPT>
		
		</FORM>
		<cf_MessageWindow>
		
   	</cffunction>
	

	<cffunction name="View_Program_Product_List" output="true" hint="Show_Product_List">
		<CFSET D_Temp = this.Load_Forecast_Summary()>
		<CFSET D_Temp = this.Get_Product_List()>
		
		<CFIF Get_Distinct_Products.RecordCount EQ 0>
			<CFRETURN>
		</CFIF>
		<BR>
		<B><FONT SIZE="2" COLOR="Navy">Program Volume</FONT></B><HR COLOR="Navy">
		<SCRIPT LANGUAGE="JavaScript">
		function Show_Forecast_Details(Product_ID)
		{
			event.returnValue = false;
			NewWindow('Contract_Volume_Forcast_Detail.cfm?PID=' + Product_ID + '&CID=#this.Encrypted_Program_ID#', 'Forecast_Detail','750','350','Yes', 'Yes')
		}
		</SCRIPT>
		<STYLE>			
			TABLE.VOlumeMaintable TD 
			{
				border:none;
				font-size : 10px;				
			}
			TABLE.VOlumeMaintable
			{
				page-break-before: always;
			}
			
		</STYLE>
		<!------<TABLE border="0" cellspacing="2" cellpadding="2" CLASS="MainHead" WIDTH="#this.Window_Max_Width#" BGCOLOR="##ffce84">----->
		<TABLE border="0" cellspacing="1" cellpadding="2" CLASS="VOlumeMaintable" WIDTH="100%" BGCOLOR="##ffce84">
		<TR VALIGN="top" BGCOLOR="White">
			<TD COLSPAN="2"></TD>
			<CFIF this.Previous_Forecast>
			<TD COLSPAN="2" ID="header" ALIGN="center" STYLE="border:none;">			
			<B>#DateFormat(this.Forecast_From_Date, "mm/dd/yyyy")# - #DateFormat(this.Forecast_To_Date, "mm/dd/yyyy")# (#this.Forecast_Span#)</B>			
			</TD>
			<TD COLSPAN="2"></TD>
			<CFELSE>
			<TD COLSPAN="1"></TD>
			</CFIF>			
			<TD COLSPAN="10" ID="header" ALIGN="center" STYLE="border:none;">
			<B>#DateFormat(this.Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(this.Contract_End_Date, "mm/dd/yyyy")# (#this.Contract_Span#)</B>
			</TD>
		</TR>
		<TR BGCOLOR="##ffce84" VALIGN="bottom">
			<TD ROWSPAN="2" align="left" ID="header"><B>
				Item ##
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
				<B>/</B><BR>
				UPC
				</cfif></cfif></B>
				</TD>
			<TD ROWSPAN="2" align="left" ID="header">
			<B>Description</B>
			</TD>			
			<CFIF this.Previous_Forecast>
			<TD COLSPAN="2" STYLE="border-bottom:2px solid black;" align="center" ID="header"><B>Actual Volume</B></TD>
			</CFIF>
			<TD COLSPAN="2" STYLE="border-bottom:2px solid black;" align="center" ID="header"><B>Annual Volume</B></TD>
			<TD COLSPAN="4" STYLE="border-bottom:2px solid black;" align="center" ID="header"><B>Program Volume</B></TD>
		</TR>
		<TR ID="header" BGCOLOR="##ffce84" VALIGN="bottom">
			<CFIF this.Previous_Forecast>
			<TD ALIGN="right" ID="header"><B>Case</B></TD>
			<TD ALIGN="right" ID="header"><B>Pound</B></TD>
			</CFIF>
			<TD ALIGN="right" ID="header"><B>Case</B></TD>
			<TD ALIGN="right" ID="header"><B>Pound</B></TD>
			<TD ALIGN="right" ID="header"><B>Case</B></TD>
			<TD ALIGN="right" ID="header"><B>Pound</B></TD>
		</TR>
		<CFSET Forecast_Total_CS = 0>
		<CFSET Forecast_Total_LB = 0>
		<CFSET Annual_Total_CS = 0>
		<CFSET Annual_Total_LB = 0>
		<CFSET Program_Total_CS = 0>
		<CFSET Program_Total_LB = 0>
		<CFSET Volume_Col_Min_Width = 80>		
		<CFLOOP QUERY="Get_Distinct_Products">
			<CFSET FieldNameEnd = InputNameCompatableGUID(BSA_Foodservice_Items_Master_ID)>
			<CFSET Input_CS_Name = "Product_Volume_#FieldNameEnd#_CS">
			<CFSET Input_LB_Name = "Product_Volume_#FieldNameEnd#_LB">
			
			<CFSET Forecast_Volume_CS = "Forecast_Volume_#FieldNameEnd#_CS">
			<CFSET Forecast_Volume_LB = "Forecast_Volume_#FieldNameEnd#_LB">
			
			<CFSET Err_PS_CS_Name = "error_Vol_#FieldNameEnd#_cs">
			<CFSET Err_PS_LB_Name = "error_Vol_#FieldNameEnd#_lb">
			
			<TR VALIGN="top"<CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
				<TD NOWRAP ID="TD_Item">
					#ITEM#
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
					<BR>#UPC#
					</cfif></cfif>
				</TD>
				<TD ID="TD_Description">#Description#</TD>
				<CFSILENT>
				<CFSET Annual_Volume_CS = "">
				<CFSET Annual_Volume_LB = "">
				<CFIF this.Previous_Forecast>
					<CFIF this.UOM EQ 1>
						<CFSET Forecast_Volume_CS 	= this.GetProductVolume(BSA_Foodservice_Items_Master_ID, 1)>
						<CFSET Forecast_Volume_LB 	= ConvertToUOM(Forecast_Volume_CS, 2, Net_Weight)>
					<CFELSE>
						<CFSET Forecast_Volume_LB 	= this.GetProductVolume(BSA_Foodservice_Items_Master_ID, 1)>
						<CFSET Forecast_Volume_CS 	= ConvertToUOM(Forecast_Volume_LB, 1, Net_Weight)>
					</CFIF>
				<CFELSE>
					<CFSET Forecast_Volume_CS = 0>
					<CFSET Forecast_Volume_LB = 0>
				</CFIF>
				
				<CFIF this.UOM EQ 1><!---- program UOM is CS ---->
					
					<CFIF this.action EQ "loadforecast"><!---- load from forecast table ---->
						<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#ConvertToProgramVolume(Forecast_Volume_CS)#">
					<CFELSE>						
						<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#this.GetProductVolume(BSA_Foodservice_Items_Master_ID)#">
					</CFIF>
					
					<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
					<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#ConvertToUOM(This_Volume_CS, 2, Net_Weight)#">
					<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>
					<CFIF This_Volume_CS NEQ 0 AND IsNumeric(This_Volume_CS)>
						<CFSET Annual_Volume_CS 			= (This_Volume_CS / this.Contract_Span) * 360>
						<CFSET Annual_Volume_LB 			= (This_Volume_LB / this.Contract_Span) * 360>
					</CFIF>
					
				<CFELSE><!---- program UOM is LB ---->
					
					<CFIF this.action EQ "loadforecast">
						<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#ConvertToProgramVolume(Forecast_Volume_LB)#">
					<CFELSE>
						<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#this.GetProductVolume(BSA_Foodservice_Items_Master_ID)#">
					</CFIF>
					
					<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>					
					<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#ConvertToUOM(This_Volume_LB, 1, Net_Weight)#">
					<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
					<CFSET Annual_Volume_CS 				= ConvertToAnnualVolume(This_Volume_CS)>
					<CFSET Annual_Volume_LB 				= ConvertToAnnualVolume(This_Volume_LB)>
					
				</CFIF>
				</CFSILENT>
				<CFIF this.Previous_Forecast>
				<TD ALIGN="right" ID="TD_Forecast_CS" WIDTH="#Volume_Col_Min_Width#"><A HREF="void(0);" onClick="javaScript: return Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');"><DIV>#this.FormatVolume(Forecast_Volume_CS)#</DIV></A>&nbsp;</TD>
				<TD ALIGN="right" ID="TD_Forecast_LB" WIDTH="#Volume_Col_Min_Width#"><A HREF="void(0);" onClick="javaScript: return Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');"><DIV>#this.FormatVolume(Forecast_Volume_LB)#</DIV></A>&nbsp;</TD>
				</CFIF>
				<TD ALIGN="right" ID="TD_Annual_CS" WIDTH="#Volume_Col_Min_Width#"><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#px;" ID="annual_cs_#FieldNameEnd#">#this.FormatVolume(Annual_Volume_CS)#</DIV>&nbsp;</TD>
				<TD ALIGN="right" ID="TD_Annual_LB" WIDTH="#Volume_Col_Min_Width#"><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#px;" ID="annual_lb_#FieldNameEnd#">#this.FormatVolume(Annual_Volume_LB)#</DIV>&nbsp;</TD>
				<TD ALIGN="right" ID="TD_Program_CS" WIDTH="#Evaluate(Volume_Col_Min_Width+20)#">
				#this.FormatVolume(This_Volume_CS)#</TD>
				<TD ALIGN="right" ID="TD_Program_LB" WIDTH="#Evaluate(Volume_Col_Min_Width+20)#">
				#this.FormatVolume(This_Volume_LB)#</TD>
			</TR>
			<CFIF IsNumeric(Forecast_Volume_CS)>
				<CFSET Forecast_Total_CS 	= Forecast_Total_CS + RoundVolume(Forecast_Volume_CS)>
			</CFIF>
			<CFIF IsNumeric(Forecast_Volume_LB)>
				<CFSET Forecast_Total_LB 	= Forecast_Total_LB + RoundVolume(Forecast_Volume_LB)>
			</CFIF>
			<CFIF IsNumeric(Annual_Volume_CS)>
				<CFSET Annual_Total_CS 		= Annual_Total_CS + RoundVolume(Annual_Volume_CS)>
			</CFIF>
			<CFIF IsNumeric(Annual_Volume_LB)>
				<CFSET Annual_Total_LB 		= Annual_Total_LB + RoundVolume(Annual_Volume_LB)>
			</CFIF>
			<CFIF IsNumeric(This_Volume_CS)>
				<CFSET Program_Total_CS 	= Program_Total_CS + RoundVolume(This_Volume_CS)>
			</CFIF>
			<CFIF IsNumeric(This_Volume_LB)>
				<CFSET Program_Total_LB 	= Program_Total_LB + This_Volume_LB>
			</CFIF>	
		</CFLOOP>
			<TR VALIGN="top" BGCOLOR="##FFFFFF">
				<TD ID="header" align="right" COLSPAN="2"><B>Total volume :</B>&nbsp;&nbsp;</TD>
				<CFIF this.Previous_Forecast>
				<TD ID="header" ALIGN="right"><B>#this.FormatVolume(Forecast_Total_CS)#</B></TD>
				<TD ID="header" ALIGN="right"><B>#this.FormatVolume(Forecast_Total_LB)#</B></TD>
				</CFIF>
				<TD ID="header" ALIGN="right"><B>#this.FormatVolume(Annual_Total_CS)#</B></TD>
				<TD ID="header" ALIGN="right"><B>#this.FormatVolume(Annual_Total_LB)#</B></TD>
				<TD ID="header" ALIGN="right"><B>#this.FormatVolume(Program_Total_CS)#</B></TD>
				<TD ID="header" ALIGN="right"><B>#this.FormatVolume(Program_Total_LB)#</B></TD>
			</TR>
		</TABLE>
   	</cffunction>

	
	<!----------------- Build_To_URL() -------------------->
   	<cffunction name="Build_To_URL" output="false" hint="Build_To_URL">
		<cfargument name="sOriginal" type="string" required="true" default="">
		<cfargument name="sName" type="string" required="true" default="">
		<cfargument name="sValue" type="string" required="true" default="">
		<cfset addValue = "#Arguments.sName#=#Arguments.sValue#">
		<cfset sReturnValue = Arguments.sOriginal>
		<cfif NOT ListFindNoCase(sReturnValue, addValue, "&")>
			<cfset sReturnValue = ListAppend(sReturnValue, addValue, "&")>
		</cfif>
		<cfreturn sReturnValue>
	</cffunction>
		
	<!----------------- ConvertToProgramVolume() -------------------->
   	<cffunction name="ConvertToProgramVolume" output="false" hint="ConvertToProgramVolume">
		<cfargument name="Forecast_Volume" type="string" required="true" default="">
		<CFSET Return_Program_Volume = "">
		<CFIF this.Forecast_Span GT 0 AND IsNumeric(Arguments.Forecast_Volume) AND IsNumeric(this.Forecast_Span)>
			<CFSET Return_Program_Volume = (Arguments.Forecast_Volume / this.Forecast_Span) * this.Contract_Span>		
		</CFIF>
		<cfreturn Return_Program_Volume>
	</cffunction>
	
	<!----------------- ConvertToAnnualVolume() -------------------->
   	<cffunction name="ConvertToAnnualVolume" output="false" hint="ConvertToAnnualVolume">
		<cfargument name="Program_Volume" type="string" required="true" default="">
		<CFSET Return_Annual_Volume = "">
		<CFIF IsNumeric(this.Contract_Span) AND this.Contract_Span GT 0 AND IsNumeric(Arguments.Program_Volume)>
			<CFSET Return_Annual_Volume = (Arguments.Program_Volume / this.Contract_Span) * 365>		
		</CFIF>
		<cfreturn Return_Annual_Volume>
	</cffunction>
	
	
	<!----------------- ConvertToUOM() -------------------->
   	<cffunction name="ConvertToUOM" output="false" hint="ConvertToUOM">
		<cfargument name="UOM_1_Value" type="string" required="true" default="">
		<cfargument name="To_UOM" type="numeric" required="true" default="">
		<cfargument name="Net_Weight" type="numeric" required="true" default="">
		<CFSET UOM_2_Value = "">
		<CFSET UOM_1_Value = arguments.UOM_1_Value>
		
		<CFIF IsNumeric(UOM_1_Value)>
			<CFIF arguments.To_UOM EQ 1><!---- convert to case ---->
				<CFIF UOM_1_Value NEQ 0 AND IsNumeric(UOM_1_Value) AND Net_Weight NEQ 0 AND IsNumeric(Net_Weight)>
					<CFSET UOM_2_Value = UOM_1_Value / Net_Weight>
				</CFIF>
			<CFELSE><!---- convert to pounds ---->
				<CFSET UOM_2_Value = UOM_1_Value * Net_Weight>
			</CFIF>
		</CFIF>
		
		<cfreturn UOM_2_Value>
	</cffunction>
	
   <!----------------- GetProductVolume() -------------------->
   	<cffunction name="GetProductVolume" output="false" hint="Get product volume out of any one of the discount types">
		<cfargument name="Product_ID" type="string" required="true" default="">
		<cfargument name="loadForecast" type="numeric" required="false" default="0">
		<cfset product_volume = 0>
		<CFIF Arguments.loadForecast EQ 1>
			<!------------- forecast Volume ---------------->
			<cfset useLakebaseForThis_Forecast_Volume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_forecast_volume")>
<cfif useLakebaseForThis_Forecast_Volume>
	<cftry>
		<cfset This_Forecast_Volume = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_forecast_volume", {
				"product_id" = "eq.#Product_ID#",
				"select" = "volume"
			}), "volume"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForThis_Forecast_Volume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForThis_Forecast_Volume>
<CFQUERY NAME="This_Forecast_Volume" DBTYPE="query">
				SELECT		Volume
				FROM		Get_Forecast_Volume
				WHERE
							Product_ID = '#Product_ID#'
			</CFQUERY>
</cfif>
			<CFIF This_Forecast_Volume.RecordCount EQ 0>
				<!---- nothing to be done -------->							
				<cfset product_volume = "">
			<CFELSE>
				<cfset product_volume = This_Forecast_Volume.Volume>
			</CFIF>	
		<CFELSE>
			<!------------- Fixed Volume ---------------->
			<cfset useLakebaseForThis_Fixed_Volume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_fixed_volume")>
<cfif useLakebaseForThis_Fixed_Volume>
	<cftry>
		<cfset This_Fixed_Volume = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_fixed_volume", {
				"bsa_foodservice_items_master_id" = "eq.#Product_ID#",
				"select" = "volume"
			}), "volume"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForThis_Fixed_Volume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForThis_Fixed_Volume>
<CFQUERY NAME="This_Fixed_Volume" DBTYPE="query">
				SELECT		Volume
				FROM		Get_Fixed_Volume
				WHERE
							BSA_Foodservice_Items_Master_ID = '#Product_ID#'
			</CFQUERY>
</cfif>
			
			<!------------- Rebate Volume ---------------->
			<cfset useLakebaseForThis_Rebate_Volume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_rebate_volume")>
<cfif useLakebaseForThis_Rebate_Volume>
	<cftry>
		<cfset This_Rebate_Volume = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_rebate_volume", {
				"bsa_foodservice_items_master_id" = "eq.#Product_ID#",
				"select" = "volume"
			}), "volume"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForThis_Rebate_Volume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForThis_Rebate_Volume>
<CFQUERY NAME="This_Rebate_Volume" DBTYPE="query">
				SELECT		Volume
				FROM		Get_Rebate_Volume
				WHERE
							BSA_Foodservice_Items_Master_ID = '#Product_ID#'
			</CFQUERY>
</cfif>
			
			<!------------- Growth Volume ---------------->
			<cfset useLakebaseForThis_Growth_Volume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_growth_volume")>
<cfif useLakebaseForThis_Growth_Volume>
	<cftry>
		<cfset This_Growth_Volume = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_growth_volume", {
				"bsa_foodservice_items_master_id" = "eq.#Product_ID#",
				"select" = "volume"
			}), "volume"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForThis_Growth_Volume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForThis_Growth_Volume>
<CFQUERY NAME="This_Growth_Volume" DBTYPE="query">
				SELECT		Volume
				FROM		Get_Growth_Volume
				WHERE
							BSA_Foodservice_Items_Master_ID = '#Product_ID#'
			</CFQUERY>
</cfif>
			
			<!------------- Formula Volume ---------------->
			<cfset useLakebaseForThis_Formula_Volume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_formula_volume")>
<cfif useLakebaseForThis_Formula_Volume>
	<cftry>
		<cfset This_Formula_Volume = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_formula_volume", {
				"bsa_foodservice_items_master_id" = "eq.#Product_ID#",
				"select" = "volume"
			}), "volume"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForThis_Formula_Volume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForThis_Formula_Volume>
<CFQUERY NAME="This_Formula_Volume" DBTYPE="query">
				SELECT		Volume
				FROM		Get_Formula_Volume
				WHERE
							BSA_Foodservice_Items_Master_ID = '#Product_ID#'
			</CFQUERY>
</cfif>
			
			<!------------- Off invoice Volume ---------------->
			<cfset useLakebaseForThis_Off_Invoice_Volume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_off_invoice_volume")>
<cfif useLakebaseForThis_Off_Invoice_Volume>
	<cftry>
		<cfset This_Off_Invoice_Volume = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_off_invoice_volume", {
				"bsa_foodservice_items_master_id" = "eq.#Product_ID#",
				"select" = "volume"
			}), "volume"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForThis_Off_Invoice_Volume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForThis_Off_Invoice_Volume>
<CFQUERY NAME="This_Off_Invoice_Volume" DBTYPE="query">
				SELECT		Volume
				FROM		Get_Off_Invoice_Volume
				WHERE
							BSA_Foodservice_Items_Master_ID = '#Product_ID#'
			</CFQUERY>
</cfif>
			
			<!------------- Lumpsum Volume ---------------->
			<cfset useLakebaseForThis_Lumpsum_Volume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_lumpsum_volume")>
<cfif useLakebaseForThis_Lumpsum_Volume>
	<cftry>
		<cfset This_Lumpsum_Volume = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_lumpsum_volume", {
				"bsa_foodservice_items_master_id" = "eq.#Product_ID#",
				"select" = "volume"
			}), "volume"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForThis_Lumpsum_Volume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForThis_Lumpsum_Volume>
<CFQUERY NAME="This_Lumpsum_Volume" DBTYPE="query">
				SELECT		Volume
				FROM		Get_Lumpsum_Volume
				WHERE
							BSA_Foodservice_Items_Master_ID = '#Product_ID#'
			</CFQUERY>
</cfif>
			
			<cfset product_volume = 0>
			<cfset product_volume = this.Get_Larger_Volume(This_Fixed_Volume, product_volume)>
			<cfset product_volume = this.Get_Larger_Volume(This_Rebate_Volume, product_volume)>
			<cfset product_volume = this.Get_Larger_Volume(This_Growth_Volume, product_volume)>
			<cfset product_volume = this.Get_Larger_Volume(This_Formula_Volume, product_volume)>
			<cfset product_volume = this.Get_Larger_Volume(This_Lumpsum_Volume, product_volume)>
			<cfset product_volume = this.Get_Larger_Volume(This_Off_Invoice_Volume, product_volume)>
			
			<CFIF IsNumeric(product_volume)>
				<cfset product_volume = product_volume * 7>
			</CFIF>
		</CFIF>	<!------<CFIF Arguments.loadForecast NEQ 1>----->
		<cfreturn product_volume/>
	</cffunction>
	
	<!----------------- Get_Larger_Volume() -------------------->
   	<cffunction name="Get_Larger_Volume" output="false" hint="Get_Larger_Volume">
		<cfargument name="Query_Volume" type="query" required="true" default="">
		<cfargument name="Current_Volume" type="numeric" required="true" default="">
		<cfset product_volume = Arguments.Current_Volume>
		<cfset Query_Volume = Arguments.Query_Volume>
		<CFIF Query_Volume.RecordCount GT 0>
			<CFIF Query_Volume.Volume GT product_volume>
				<CFSET product_volume = Query_Volume.Volume>
			</CFIF>
		</CFIF>
		<cfreturn product_volume>
	</cffunction>
	
	<!----------------- FormatVolume() -------------------->
   	<cffunction name="FormatVolume" output="false" hint="Format Volume">
		<cfargument name="Volume" type="string" required="true" default="">
		<cfargument name="AddComma" type="numeric" required="false" default="1">
		
		<CFIF AddComma EQ 1>
			<cfset formatted_volume = NumberFormat(Arguments.Volume, "(___,___,___,___,___")>
		<CFELSE>
			<cfset formatted_volume = RoundVolume(Arguments.Volume)>
		</CFIF>
							
		<cfreturn formatted_volume/>
	</cffunction>
	
	<!----------------- RoundVolume() -------------------->
   	<cffunction name="RoundVolume" output="false" hint="Round Volume">
		<cfargument name="Volume" type="string" required="true" default="">
		
		<cfset rounded_volume = Arguments.Volume>
		
		<cfif rounded_volume EQ "">
			<cfset rounded_volume = 0>
		</cfif>
		
		<cfset rounded_volume = Round(rounded_volume)>
							
		<cfreturn rounded_volume/>
	</cffunction>
	
	<!----------------- InputNameCompatableGUID() -------------------->
   	<cffunction name="InputNameCompatableGUID" output="true" hint="InputNameCompatableGUID">
		<cfargument name="GUID" type="string" required="true" default="">
		
		<cfset formatted_guid = replace(GUID,"-","_", "ALL")>
							
		<cfreturn formatted_guid/>
	</cffunction>
	
	<!----------------- Show_Sort_String() -------------------->
   	<cffunction name="Show_Sort_String" output="true" hint="Show_Sort_String">
		<cfargument name="Sort_Value" type="string" required="true" default="">
		<cfargument name="Display_Text" type="string" required="true" default="">
		<cfset This_Sort_Order = "ASC">
		<CFSET Img_String = "">
		<CFIF Arguments.Sort_Value EQ FORM.SORT_BY>
			
			<CFSET Img_String = "<IMG SRC=""/Images/up_1.gif"">">
			<CFIF FORM.SORT_ORDER EQ "ASC">
				<CFSET Img_String = "<IMG SRC=""/Images/down_1.gif"">">
				<cfset This_Sort_Order = "DESC">
			</CFIF>
		</CFIF>
		<A HREF="##" OnClick="JavaScript: return sort_by_This('#Arguments.Sort_Value#', '#This_Sort_Order#');"><B>#Arguments.Display_Text#</B></A>&nbsp;#Img_String#
	</cffunction>
	
	<!----------------- save_product_volume() -------------------->
	<cffunction name="save_product_volume" output="true" hint="save product volume">
		<cfargument name="Product_List" type="string" required="true" default="">
		<CFSET Total_Volume = 0>
		<CFLOOP LIST="#Product_List#" INDEX="This_Product">
			<CFSET FieldNameEnd = InputNameCompatableGUID(This_Product)>
			<CFIF this.UOM EQ 1>
				<CFSET This_Volume_Field = "Product_Volume_#FieldNameEnd#_CS">
			<CFELSE>
				<CFSET This_Volume_Field = "Product_Volume_#FieldNameEnd#_LB">
			</CFIF>
			<CFSET This_Volume = Evaluate("FORM.#This_Volume_Field#")>
			<CFIF IsNumeric(This_Volume)>
				<CFSET Total_Volume = Total_Volume + This_Volume>
				<CFSET This_Volume = This_Volume / 7>
				<CFSET This_Volume = NumberFormat(This_Volume, "__.___")>				
			<CFELSE>
				<CFSET This_Volume = "NULL">				
			</CFIF>
			<!------<CFOUTPUT>#FieldNameEnd# #This_Volume#<BR></CFOUTPUT>----->
			<!---------- Save Fixed Price ------------>
			<CFQUERY NAME="Get_Fixed_Volume" DATASOURCE="#application.datasource#">				
				UPDATE	Program_Fixed_Price_Product_Data
				SET 	Program_Fixed_Price_Product_Data.Volume = #This_Volume#
				FROM 	Program_Fixed_Price_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #this.Program_ID#
						AND Contract_Products.BSA_Foodservice_Items_Master_ID = '#This_Product#'
				WHERE 	len(Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID) > 0
						AND Program_Fixed_Price_Product_Data.Deleted = 0 
			</CFQUERY>
			
			<!---------- Save Rebate Price ------------>
			<CFQUERY NAME="Get_Rebate_Volume" DATASOURCE="#application.datasource#">
				UPDATE	Program_Rebates_Product_Data
				SET 	Program_Rebates_Product_Data.Volume = #This_Volume#		
				FROM 	Program_Rebates_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #this.Program_ID#
						AND Contract_Products.BSA_Foodservice_Items_Master_ID = '#This_Product#'
				WHERE 	len(Program_Rebates_Product_Data.Unit_Of_Measure_ID) > 0
						AND Program_Rebates_Product_Data.Deleted = 0 
			</CFQUERY>
			
			<!---------- Save Lumpsum Price ------------>
			<CFQUERY NAME="Get_Lumpsum_Volume" DATASOURCE="#application.datasource#">
				UPDATE	Program_Lump_Sum_Product_Data
				SET 	Program_Lump_Sum_Product_Data.Volume = #This_Volume#		
				FROM 	Program_Lump_Sum_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #this.Program_ID#
						AND Contract_Products.BSA_Foodservice_Items_Master_ID = '#This_Product#'
				WHERE 	Program_Lump_Sum_Product_Data.Deleted = 0 
			</CFQUERY>
			
			<!---------- Save Growth Price ------------>
			<CFQUERY NAME="Get_Growth_Volume" DATASOURCE="#application.datasource#">
				UPDATE	Program_Growth_Component_Product_Data
				SET 	Program_Growth_Component_Product_Data.Weekly_Volume = #This_Volume#
				FROM 	Program_Growth_Component_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #this.Program_ID#
						AND Contract_Products.BSA_Foodservice_Items_Master_ID = '#This_Product#'
						INNER JOIN Program_Growth_Component_Tiers
						ON
						Program_Growth_Component_Tiers.Program_Growth_Component_ID = Program_Growth_Component_Product_Data.Program_Growth_Component_ID
						AND
						Program_Growth_Component_Tiers.Tier_Number = '1'
						AND
						Program_Growth_Component_Tiers.Deleted = 0
						INNER JOIN Program_Growth_Component_Product_Tier_Data
						ON
						Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID = Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
						AND
						Program_Growth_Component_Product_Tier_Data.Deleted = 0
						AND
						Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID
						
				WHERE 	len(Program_Growth_Component_Product_Tier_Data.Unit_Of_Measure_ID) > 0
						AND Program_Growth_Component_Product_Data.Deleted = 0 
			</CFQUERY>
			
			<!---------- Save Formula Price ------------>
			<CFQUERY NAME="Get_Formula_Volume" DATASOURCE="#application.datasource#">
				UPDATE	Program_Formula_Pricing_Rule_Products
				SET 	Program_Formula_Pricing_Rule_Products.Weekly_Volume = #This_Volume#
				FROM 	Program_Formula_Pricing_Rule_Products
						INNER JOIN Contract_Products
						ON
						Program_Formula_Pricing_Rule_Products.Contract_Product_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #this.Program_ID#
						AND Contract_Products.BSA_Foodservice_Items_Master_ID = '#This_Product#'
				WHERE 	len(Program_Formula_Pricing_Rule_Products.Unit_Of_Measure_ID) > 0
						AND Program_Formula_Pricing_Rule_Products.Deleted = 0 
			</CFQUERY>
			
			<!---------- Save Off_Invoice ------------>
			<CFQUERY NAME="Get_Off_Invoice_Volume" DATASOURCE="#application.datasource#">				
				UPDATE	Program_OffInvoice_Product_Data
				SET 	Program_OffInvoice_Product_Data.Volume = #This_Volume#
				FROM 	Program_OffInvoice_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_OffInvoice_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #this.Program_ID#
						AND Contract_Products.BSA_Foodservice_Items_Master_ID = '#This_Product#'
				WHERE 	len(Program_OffInvoice_Product_Data.UOM) > 0
						AND Program_OffInvoice_Product_Data.Deleted = 0 
			</CFQUERY>
		</CFLOOP>
		<CFSET this.Saved_Settings.Any_DB_Changes = 1>
		<CFSET URL.FID = this.OBJ_FORM_VALUES.Save(0, this.Saved_Settings)>
		<cfreturn Total_Volume>
	</cffunction>
</cfcomponent>