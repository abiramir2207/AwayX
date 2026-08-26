<!------ Get application settings ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>


<CFQUERY NAME="Get_Data" DATASOURCE="#Application.Datasource#">
	SELECT 		* 
	FROM 		Payment_Data_Export_1
		
	WHERE 		Payment_Data_Export_1_ID = '#URL.Payment_Data_Export_1_ID#'
</CFQUERY>

<CFIF Isdefined("URL.GetPaymentInfo")>	
	<CFQUERY NAME="Get_Payee_Type" DATASOURCE="#Application.Datasource#">
		SELECT Billback_Payee_Type_ID
		FROM Billback 
		WHERE 	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
					Billback_ID = (	SELECT 	TOP 1 Billback_ID 
									FROM 	Pay_Multi_Billbacks_List
									WHERE 	Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND
											Deleted = 0	)
				<CFELSE>
					Billback_ID=<CFOUTPUT>'#URL.BBID#'</CFOUTPUT>
				</CFIF>
	</CFQUERY>
	
	<!--- <CFDUMP VAR="#Get_Data#"> --->
	
	
	<CFIF Get_Payee_Type.Billback_Payee_Type_ID EQ 1>
		<CFQUERY NAME="Get_Data" DATASOURCE="#Application.Datasource#">
			SELECT 		Shr_Ship_To 	Vendor_Number,				
						BB_Reference 	BB_reference,
						Tot_Amount 		Tot_Amount,
						BB_Date 		BB_Date,
						Phone 			Phone_Number,
						BB_code			BB_Code,
						<cfif NOT appSettings.getDistributorMultiPosition()>
						BSA_Foodservice_Brokers.Broker_Name Broker_Name,
						BSA_Foodservice_Brokers.Broker_Shard,
						<cfelse>
						Null as			Broker_Name,
						Null as			Broker_Shard,
						</cfif>
						Payment_Transaction.Payee_Name Customer_Name,
						Payment_Transaction.Payee_Name Check_To_Name,
						Payee_Address1 Address1,
						Payee_Address1 Check_To_Address1,
						Payee_Address2 Address2,
						Payee_Address2 Check_To_Address2,
						Payee_City City,
						Payee_City Check_To_City,
						Payee_State State,
						Payee_State Check_To_State,
						Payee_Zipcode Zipcode,
						Payee_Zipcode Check_To_Zipcode,
						Note Explanation,
						Shr_Ship_To		Customer_number,
						Payment_Data_Export_1.Tax_ID_Number,						
						Payment_Data_Export_1.Phone_Number,																		
						Payment_Data_Export_1.Prepared_By_First_Name,
						Payment_Data_Export_1.Prepared_By_Last_Name,
						Payment_Data_Export_1.Prepared_Date,
						Payment_Data_Export_1.Signed
						
			FROM 		Payment_Data_Export_1 
			
			INNER JOIN 	Billback_Distributor ON Billback_Distributor.Billback_ID = Payment_Data_Export_1.Billback_ID
						AND Billback_Distributor.Deleted=0 
			INNER JOIN 	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
						AND BSA_Foodservice_Customers.Deleted=0
			<cfif NOT appSettings.getDistributorMultiPosition()>
			INNER JOIN 	BSA_Foodservice_Brokers ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID =BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
						AND BSA_Foodservice_Brokers.Deleted=0			
			</cfif>
			INNER JOIN	Payment_Transaction ON Payment_Transaction.Payment_Trans_ID = Payment_Data_Export_1.Payment_Trans_ID

			WHERE 		Payment_Data_Export_1.Billback_ID =	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
																'#Get_Data.Billback_ID#'
															<CFELSE>
																<CFOUTPUT>'#URL.BBID#'</CFOUTPUT>
															</CFIF>	
						AND Payment_Data_Export_1.Payment_Data_Export_1_ID = '#URL.Payment_Data_Export_1_ID#'
						AND Payment_Data_Export_1.Deleted=0
		</CFQUERY>		
	<CFELSEIF Get_Payee_Type.Billback_Payee_Type_ID EQ 3>	
		<CFQUERY NAME="Get_Data" DATASOURCE="#Application.Datasource#">
			SELECT 		Broker_Shard 	Vendor_Number,
						Null as			Broker_Name,
						BB_Reference 	BB_Reference,
						Tot_Amount 		Tot_Amount,
						BB_Date			BB_Date,	
						BB_Code			BB_Code,
						BSA_Foodservice_Brokers.Phone_Number,
						Payment_Transaction.Payee_Name Customer_Name,
						Payment_Transaction.Payee_Name Check_To_Name,
						Payee_Address1 Address1,
						Payee_Address1 Check_To_Address1,
						Payee_Address2 Address2,
						Payee_Address2 Check_To_Address2,
						Payee_City City,
						Payee_City Check_To_City,
						Payee_State State,
						Payee_State Check_To_State,
						Payee_Zipcode Zipcode,
						Payee_Zipcode Check_To_Zipcode,
						Note Explanation,
						Broker_Shard		Customer_number,
						Payment_Data_Export_1.Tax_ID_Number,						
						Payment_Data_Export_1.Phone_Number,																		
						Payment_Data_Export_1.Prepared_By_First_Name,
						Payment_Data_Export_1.Prepared_By_Last_Name,
						Payment_Data_Export_1.Prepared_Date,
						Payment_Data_Export_1.Signed
	
			FROM 		Payment_Data_Export_1
	
			INNER JOIN 	Billback_Broker ON Billback_Broker.Billback_ID = Payment_Data_Export_1.Billback_ID
						AND Billback_Broker.Deleted=0
			INNER JOIN 	BSA_Foodservice_Brokers ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID
						AND BSA_Foodservice_Brokers.Deleted=0			
			INNER JOIN	Payment_Transaction ON Payment_Transaction.Payment_Trans_ID = Payment_Data_Export_1.Payment_Trans_ID
			
			WHERE 		Payment_Data_Export_1.Billback_ID =<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
																'#Get_Data.Billback_ID#'
															<CFELSE>
																<CFOUTPUT>'#URL.BBID#'</CFOUTPUT>
															</CFIF>
						AND Payment_Data_Export_1.Payment_Data_Export_1_ID = '#URL.Payment_Data_Export_1_ID#'
						AND Payment_Data_Export_1.Deleted=0
		</CFQUERY>
	<CFELSEIF Get_Payee_Type.Billback_Payee_Type_ID EQ 2>	
		<CFQUERY NAME="Get_Data" DATASOURCE="#Application.Datasource#">
			SELECT 		Null as 			Vendor_Number,
						Null as				Broker_Name,
						BB_Date				BB_Date,
						BB_Reference 		BB_Reference,
						Tot_Amount 			Tot_Amount,
						BB_Code				BB_Code,
						ZZZ_Operator_Phone 	Phone_Number,
						Payment_Transaction.Payee_Name Customer_Name,
						Payment_Transaction.Payee_Name Check_To_Name,
						Payee_Address1 Address1,
						Payee_Address1 Check_To_Address1,
						Payee_Address2 Address2,
						Payee_Address2 Check_To_Address2,
						Payee_City City,
						Payee_City Check_To_City,
						Payee_State State,
						Payee_State Check_To_State,
						Payee_Zipcode Zipcode,
						Payee_Zipcode Check_To_Zipcode,
						Note Explanation,
						Null AS	Customer_number,
						Payment_Data_Export_1.Tax_ID_Number,						
						Payment_Data_Export_1.Phone_Number,																		
						Payment_Data_Export_1.Prepared_By_First_Name,
						Payment_Data_Export_1.Prepared_By_Last_Name,
						Payment_Data_Export_1.Prepared_Date,
						Payment_Data_Export_1.Signed
	
			FROM 		Payment_Data_Export_1
			
			INNER JOIN 	Billback_Operator ON Billback_Operator.Billback_ID = Payment_Data_Export_1.Billback_ID
						AND Billback_Operator.Deleted=0
			INNER JOIN 	BSA_Operator ON BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID
						AND BSA_Operator.Deleted=0
			INNER JOIN	Payment_Transaction ON Payment_Transaction.Payment_Trans_ID = Payment_Data_Export_1.Payment_Trans_ID
			
			WHERE 		Payment_Data_Export_1.Billback_ID =	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
																'#Get_Data.Billback_ID#'
															<CFELSE>
																<CFOUTPUT>'#URL.BBID#'</CFOUTPUT>
															</CFIF>
						AND Payment_Data_Export_1.Payment_Data_Export_1_ID = '#URL.Payment_Data_Export_1_ID#'
						AND Payment_Data_Export_1.Deleted=0
		</CFQUERY>		
	<CFELSE>
		<CFQUERY NAME="Get_Table_1_Data" DATASOURCE="#Application.Datasource#">
			SELECT 		Null as 			Vendor_Number,
						Null as				Broker_Name,
						BB_Date				BB_Date,
						BB_Reference 		BB_Reference,
						Tot_Amount 			Tot_Amount,
						BB_Code				BB_Code,
						Payment_Transaction.Payee_Name Customer_Name,
						Payment_Transaction.Payee_Name Check_To_Name,
						Payee_Address1 Address1,
						Payee_Address1 Check_To_Address1,
						Payee_Address2 Address2,
						Payee_Address2 Check_To_Address2,
						Payee_City City,
						Payee_City Check_To_City,
						Payee_State State,
						Payee_State Check_To_State,
						Payee_Zipcode Zipcode,
						Payee_Zipcode Check_To_Zipcode,
						Note Explanation,
						Null as		Customer_number,
						Payment_Data_Export_1.Tax_ID_Number,						
						Payment_Data_Export_1.Phone_Number,																		
						Payment_Data_Export_1.Prepared_By_First_Name,
						Payment_Data_Export_1.Prepared_By_Last_Name,
						Payment_Data_Export_1.Prepared_Date,
						Payment_Data_Export_1.Signed
						
			FROM 		Payment_Data_Export_1
			
			INNER JOIN	Payment_Transaction ON Payment_Transaction.Payment_Trans_ID = Payment_Data_Export_1.Payment_Trans_ID
			
			WHERE 		Payment_Data_Export_1.Billback_ID =<CFOUTPUT>'#URL.BBID#'</CFOUTPUT>
						AND Payment_Data_Export_1.Payment_Data_Export_1_ID = '#URL.Payment_Data_Export_1_ID#'
						AND Payment_Data_Export_1.Deleted=0
		</CFQUERY>	
	</CFIF>
	<!--- <CFDUMP VAR="#Get_Data#"> --->

	
	 	<CFIF DayofWeek(now()) EQ 5 OR DayofWeek(now()) EQ 6>
			<CFSET Add_2_working_days = dateAdd("d",4,#Now()#)>
		<CFELSE>
			<CFSET Add_2_working_days = dateAdd("d",2,#Now()#)>
		</CFIF>
		
	<CFSET DateAddition_Done = 0>	
	<CFLOOP CONDITION = "DateAddition_Done EQUAL 0">	
		<CFQUERY NAME="Find_Holidays" DATASOURCE="#Application.Datasource#">
			SELECT 		* 
			FROM 		Holidays 
			WHERE 		Convert(Char(10),Holiday_Date,101) 
						<CFIF isdefined("Next_Date_To_Check")>
							= <CFOUTPUT>'#Next_Date_To_Check#'</CFOUTPUT>
						<CFELSE>
							BETWEEN  <CFOUTPUT>'#DateFormat(Now(),"mm/dd/yyyy")#'</CFOUTPUT> AND <CFOUTPUT>'#Dateformat(Add_2_working_days,"mm/dd/yyyy")#'</CFOUTPUT>
						</CFIF> AND Deleted=0
		</CFQUERY>
		<CFIF Find_Holidays.recordcount GT 0>
			<CFOUTPUT QUERY="Find_Holidays">
				<CFIF DayOfWeek(Holiday_Date) NEQ 7 OR DayOfWeek(Holiday_Date) NEQ 1>					 
					<CFSET Add_2_working_days = dateAdd("d",1,#Add_2_working_days#)>				
					
					<CFIF DayOfWeek(Add_2_working_days) EQ 7>
						<CFSET Add_2_working_days = dateAdd("d",2,#Add_2_working_days#)>
					</CFIF>
					<CFIF DayOfWeek(Add_2_working_days) EQ 1>
						<CFSET Add_2_working_days = dateAdd("d",1,#Add_2_working_days#)>
					</CFIF>
					<CFSET Next_Date_To_Check = DateFormat(Add_2_working_days,"mm/dd/yyyy")>
				</CFIF>
			</CFOUTPUT>
		<CFELSE>
			<CFSET DateAddition_Done = 1>	
		</CFIF>
	</CFLOOP>

</CFIF>

<CFSAVECONTENT variable="mail_Fax">
	<STYLE>
	<CFINCLUDE TEMPLATE="/Common_Files/Main_Style.css">
	TABLE.WITHBORDER TD
	{		
		border-bottom:solid gray 1px;
		border-left:solid gray 1px;
	}
	
	</STYLE>
	
	<CFQUERY NAME="GetBBDetails" DATASOURCE="#Application.Datasource#">
		SELECT 		BB_Code,
					BB_Reference,
					Paid_Amount,
					BB_Date,
					Billback.Billback_ID
					 
		FROM 		Billback
		INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
		WHERE 		<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
						Billback.Billback_ID IN (	SELECT 	Billback_ID 
													FROM 	Pay_Multi_Billbacks_List
													WHERE 	Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND 
															Deleted = 0	)
					<CFELSE>
						Billback.Billback_ID = '#URL.BBID#'
					</CFIF>
		ORDER BY 	BB_Code
	</CFQUERY>
	<CFSET ForMultiBBID = VALUELIST(GetBBDetails.Billback_ID)>
	<CFIF isdefined("URL.Print_All") OR isdefined("URL.Print")>
		<BR><BR><BR>
	</CFIF>
	<CFIF isdefined("URL.Print_All") AND Count GT 1>		
		<div class="pageBreakBefore"></div>		
	</CFIF>
	
	<CFSET ViewMode = 1>
	<CFIF isdefined("URL.Edit_Payee_Info") OR IsDefined("URL.GetPaymentInfo")>
		<CFSET ViewMode = 0>		
	</CFIF>
	
		<!--- Check Reason code total...if it doesn't balance, stay in edit mode xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
		<CFIF application.returned_customer_setting.Show_BB_Payment_GLCode EQ 0>
			<cfif application.returned_customer_setting.BB_PC_GL_reason_codes_on EQ 1>
				<CFQUERY NAME="qGetReasonAmountsum" DATASOURCE="#Application.Datasource#">
					SELECT 		isnull(sum(reasonAmount),0) as totAmount
								 
					FROM 		BB_Reason_Code_Amount BBRCA
					WHERE 		<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
									BBRCA.Billback_ID IN (	SELECT 	Billback_ID 
																FROM 	Pay_Multi_Billbacks_List
																WHERE 	Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND 
																		Deleted = 0	)
								<CFELSE>
									BBRCA.Billback_ID = '#URL.BBID#'
								</CFIF>
								and BBRCA.deleted=0			
				</CFQUERY>
				<CFIF IsDefined("Pay_Multi_Billbacks_ID")><cfset tot_paid = get_data.tot_amount><cfelse><cfset tot_paid = GetBBDetails.Paid_Amount></cfif>
				<!--- <cfif (qGetReasonAmountsum.totAmount - get_data.tot_amount) gt .009999 or (qGetReasonAmountsum.totAmount - get_data.tot_amount) lt -.00999>  ---> <!--- handle for floats...diff must be greater than a penny to throw amount error --->
				<cfif decimalFormat(qGetReasonAmountsum.totAmount) neq decimalFormat(get_data.tot_amount)>
					<cfif isdefined("url.rcamounterror")><!--- leave it --->
					<cfelse>
						<cfset RcAmountError = "-1">
					</cfif>
					<CFSET ViewMode = 0>
					<cfset URL.Edit_Payee_Info = 1>
					<cfset needReasonCode = 1>
				</cfif>
			</CFIF>
		</CFIF>
	<CFIF isdefined("URL.Edit_Payee_Info") OR isdefined("URL.Approve") OR IsDefined("URL.GetPaymentInfo")>
	<FORM NAME="Check_To" ACTION="View_Edit_Approve.cfm" METHOD="Post">
	</CFIF>
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="Today" VALUE="#Dateformat(Now(),"mm/dd/yyyy")#">
	<INPUT TYPE="hidden" NAME="Form_submit" VALUE="1">
	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
		<INPUT TYPE="hidden" NAME="BBID" VALUE="#ForMultiBBID#">
		<INPUT TYPE="Hidden" NAME="Pay_Multi_Billbacks_ID" VALUE="#Pay_Multi_Billbacks_ID#">
	<CFELSE>
		<INPUT TYPE="hidden" NAME="BBID" VALUE="#URL.BBID#">
	</CFIF>	
	<INPUT TYPE="Hidden" NAME="Payment_Data_Export_1_ID" VALUE="#URL.Payment_Data_Export_1_ID#">	
	</CFOUTPUT>
	<CFIF IsDefined("Send_Mail") OR IsDefined("Send_Fax") OR IsDefined("Print") OR IsDefined("Email_All") OR IsDefined("Fax_All") OR IsDefined("Print_All")>
		<CFSET FullTableWidth = 1>
	</CFIF>
	
<!--- 	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD ALIGN="Center"><FONT SIZE="3" COLOR="Navy"><B>Payment Request </B></FONT></TD>
		</TR>		
	</TABLE> --->
	
	<CFOUTPUT QUERY="GetBBDetails"><!---  QUERY="Get_Data" --->
		<!--- <cfset bbAmount = Paid_Amount> --->
		<CFIF Isdefined("URL.GetPaymentInfo")>
			<CFSET Due_Date = DateFormat(Add_2_working_days,"mm/dd/yyyy")>
		<CFELSE>
			<CFSET Due_Date = DateFormat(Get_Data.Due_Date,"mm/dd/yyyy")>
		</CFIF>
	
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" <CFIF IsDefined("Pay_Multi_Billbacks_ID") AND Not IsDefined("FullTableWidth")>WIDTH="85%" ALIGN="Center"<CFELSE>WIDTH="100%"</CFIF>>
			<TR>
				<TD width="37%"><FONT SIZE="2" COLOR="Navy"><B>Billback:&nbsp;&nbsp;#BB_Code#</B></FONT><!--- <HR COLOR="Orange"> ---></TD>
				<TD><FONT SIZE="2" COLOR="Navy"><B>&nbsp;&nbsp;&nbsp;Payment Request </B></FONT></TD>
			</TR>
		</TABLE>
		
		<TABLE BORDER="0" <CFIF IsDefined("Pay_Multi_Billbacks_ID") AND Not IsDefined("FullTableWidth")>WIDTH="85%" ALIGN="Center"<CFELSE>WIDTH="100%"</CFIF> CELLSPACING="0" CELLPADDING="0" <!--- CLASS="WITHBORDER" ---> <CFIF application.returned_customer_setting.Show_BB_Payment_GLCode EQ 1>STYLE="border-right:solid gray 1px;border-top:solid gray 1px;border-Left:solid gray 1px;"<CFELSE>STYLE="border-right:solid gray 1px;border-top:solid gray 1px;border-Left:solid gray 1px;border-bottom:solid gray 1px;"</CFIF>>		
			<TR>
				<TD WIDTH="20%" ALIGN="Center" STYLE="border-right:solid gray 1px;"><B>Vendor No.</B><BR><CFIF ViewMode EQ 0 and GetBBDetails.currentrow eq 1><INPUT TYPE="Text" NAME="Vendor_Number" VALUE="#Get_Data.Vendor_Number#" SIZE="10"><CFELSE>#Get_Data.Vendor_Number#</CFIF></TD>    <!--- _#replace(GetBBDetails.BB_Code,"-","")# --->
				<TD WIDTH="20%" Align="Center" STYLE="border-right:solid gray 1px;"><B>Invoice No.</B><BR>#BB_Reference#</TD>
				<TD WIDTH="20%" ALIGN="Center" STYLE="border-right:solid gray 1px;"><B>Amount<BR>#DollarFormat(Paid_Amount)#</B></TD>
				<TD WIDTH="20%" ALIGN="Center" STYLE="border-right:solid gray 1px;"><B>Inv. Date</B><BR>#Dateformat(BB_Date,"mm/dd/yyyy")#</TD>
				<TD WIDTH="20%" ALIGN="Center"><B>Due Date</B><BR><SPAN ID="CheckDueDate"></SPAN><CFIF ViewMode EQ 0 and GetBBDetails.currentrow eq 1><CF_EASYDATE FORMNAME="Check_To" FIELDNAME="Due_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Due_Date#"><CFELSE>#DateFormat(Due_Date,"mm/dd/yyyy")#</CFIF></TD>  <!--- <cfif GetBBDetails.currentrow gt 1>#DateFormat(Due_Date,"mm/dd/yyyy")#<cfelse>  _#replace(GetBBDetails.BB_Code,"-","")# --->
				
			</TR>			
		</TABLE>
		
	
	<!--- <BR>--- --->
	<CFIF Isdefined("URL.GetPaymentInfo")>
		<CFQUERY NAME="Get_Data_2" DATASOURCE="#Application.Datasource#">
			SELECT 		Payment_Data_Export_2.Amount,
						Payment_Data_Export_2.GL_Type,
						Payment_Data_Export_2.Q_Brand_ID,
						SS_OP_UNIT_NBR OP_Unit,
						SS_ACCOUNT_NBR AC_Number,
						SS_ACCOUNT_MINOR Minor,
						SS_DEPT Dept,
						SS_DEPT_RESP Resp,
						SS_INTER_CO I_C,
						SS_CHANNEL Channel,
						SS_CR_BRAND Brand_1,
						SS_SHELF Shelf,
						SS_UDFLEX U_Def,
						SS_BRAND Brand_2
						 
			FROM 		Payment_Data_Export_2
			INNER JOIN 	GL_Code ON GL_Code.GL_Type_ID = 	Payment_Data_Export_2.GL_Type_ID AND 
						GL_Code.Q_Brand_ID = Payment_Data_Export_2.Q_Brand_ID AND
						GL_Code.Deleted = 0
						
			WHERE 		Payment_Data_Export_1_ID = <CFOUTPUT>'#URL.Payment_Data_Export_1_ID#'</CFOUTPUT> AND
						Billback_ID = '#Billback_ID#'						
		</CFQUERY>
	<CFELSE>
		<CFQUERY NAME="Get_Data_2" DATASOURCE="#Application.Datasource#">
			SELECT 	* 
			FROM 	Payment_Data_Export_2 
			WHERE 	Payment_Data_Export_1_ID=<CFOUTPUT>'#Get_Data.Payment_Data_Export_1_ID#'</CFOUTPUT> AND 
					Billback_ID = '#Billback_ID#' AND
					Deleted=0 
		</CFQUERY>
	</CFIF>
	
	<CFSET Q_brand_ID_List = ValueList(Get_Data_2.Q_Brand_ID)>
	<CFSET BBForInputName = REPLACE(Billback_ID,"-","_","All")>
	<INPUT TYPE="Hidden" NAME="Q_brand_ID_List_#BBForInputName#" VALUE="#Q_brand_ID_List#">	
	<CFIF application.returned_customer_setting.Show_BB_Payment_GLCode EQ 1>
		<TABLE BORDER="0" <CFIF IsDefined("Pay_Multi_Billbacks_ID") AND Not IsDefined("FullTableWidth")>WIDTH="85%" ALIGN="Center"<CFELSE>WIDTH="100%"</CFIF> CELLSPACING="0" CELLPADDING="3" CLASS="WITHBORDER" STYLE="border-right:solid gray 1px;border-top:solid gray 1px;">
			<TR BGCOLOR="ffce84">
				<TD WIDTH="9%">&nbsp;&nbsp;<B>AMOUNT</B></TD>
				<TD>&nbsp;&nbsp;<B>GL TYPE</B></TD>
				<TD>&nbsp;&nbsp;<B>OP.UNIT</B></TD>
				<TD>&nbsp;&nbsp;<B>A/C ##</B></TD>
				<TD>&nbsp;&nbsp;<B>MINOR</B></TD>
				<TD>&nbsp;&nbsp;<B>DEPT</B></TD>
				<TD>&nbsp;&nbsp;<B>RESP</B></TD>
				<TD>&nbsp;&nbsp;<B>I/C</B></TD>
				<TD>&nbsp;&nbsp;<B>CHANNEL</B></TD>
				<TD>&nbsp;&nbsp;<B>BRAND</B></TD>
				<TD>&nbsp;&nbsp;<B>SHELF</B></TD>
				<TD>&nbsp;&nbsp;<B>U.DEF</B></TD>
				<TD>&nbsp;&nbsp;<B>BRAND</B></TD>
				<TD>&nbsp;&nbsp;<B>BROKER</B></TD>
			</TR>
			
			<CFLOOP QUERY="Get_Data_2">
			<CFSET ReplaceItem = Replace(Q_Brand_ID,"-","_","All")>
			
			<TR BGCOLOR="#IIf(currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<TD ALIGN="Right">#Dollarformat(Amount)#&nbsp;&nbsp;&nbsp;</TD>
				<TD>&nbsp;&nbsp;#GL_Type#</TD>
				<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="OP_Unit_#ReplaceItem#_#BBForInputName#" VALUE="#OP_Unit#" SIZE="4"><CFELSE>&nbsp;&nbsp;#OP_Unit#</CFIF></TD>
				<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="AC_Number_#ReplaceItem#_#BBForInputName#" VALUE="#AC_Number#" SIZE="4"><CFELSE>&nbsp;&nbsp;#AC_Number#</CFIF></TD>
				<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="Minor_#ReplaceItem#_#BBForInputName#" VALUE="#Minor#" SIZE="4"><CFELSE>&nbsp;&nbsp;#Minor#</CFIF></TD>
				<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="Dept_#ReplaceItem#_#BBForInputName#" VALUE="#Dept#" SIZE="4"><CFELSE>&nbsp;&nbsp;#Dept#</CFIF></TD>
				<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="Resp_#ReplaceItem#_#BBForInputName#" VALUE="#Resp#" SIZE="4"><CFELSE>&nbsp;&nbsp;#Resp#</CFIF></TD>
				<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="I_C_#ReplaceItem#_#BBForInputName#" VALUE="#I_C#" SIZE="4"><CFELSE>&nbsp;&nbsp;#I_C#</CFIF></TD>
				<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="Channel_#ReplaceItem#_#BBForInputName#" VALUE="#Channel#" SIZE="4"><CFELSE>&nbsp;&nbsp;#Channel#</CFIF></TD>
				<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="Brand_2_#ReplaceItem#_#BBForInputName#" VALUE="#Brand_2#" SIZE="4"><CFELSE>&nbsp;&nbsp;#Brand_2#</CFIF></TD>
				<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="Shelf_#ReplaceItem#_#BBForInputName#" VALUE="#Shelf#" SIZE="4"><CFELSE>&nbsp;&nbsp;#Shelf#</CFIF></TD>
				<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="U_Def_#ReplaceItem#_#BBForInputName#" VALUE="#U_Def#" SIZE="4"><CFELSE>&nbsp;&nbsp;#U_Def#</CFIF></TD>
				<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="Brand_1_#ReplaceItem#_#BBForInputName#" VALUE="#Brand_1#" SIZE="4"><CFELSE>&nbsp;&nbsp;#Brand_1#</CFIF></TD>
				<TD>
					<CFIF IsDefined("URL.GetPaymentInfo")>
						<CFIF Isdefined("Get_Data.Broker_Shard")>
							<CFIF ViewMode EQ 0>
								<INPUT TYPE="Text" NAME="Broker_#ReplaceItem#_#BBForInputName#" VALUE="#Get_Data.Broker_Shard#" SIZE="4">
							<CFELSE>
								&nbsp;&nbsp;#Get_Data.Broker_Shard#
							</CFIF>
						<CFELSE>&nbsp;
						</CFIF>
					<CFELSE>
						<CFIF Broker NEQ "">
							<CFIF ViewMode EQ 0>
								<INPUT TYPE="Text" NAME="Broker_#ReplaceItem#_#BBForInputName#" VALUE="#Broker#" SIZE="4">
							<CFELSE>
								&nbsp;&nbsp;#Broker#
							</CFIF>
						<CFELSE>&nbsp;
						</CFIF>
					</CFIF> 
				</TD>
			</TR>
			</CFLOOP>			
		</TABLE>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" <CFIF IsDefined("Pay_Multi_Billbacks_ID") AND Not IsDefined("FullTableWidth")>WIDTH="85%" ALIGN="Center"<CFELSE>WIDTH="100%"</CFIF>>
			<TR>
				<TD><HR COLOR="Orange"></TD>
			</TR>
		</TABLE>
		<!--- <HR COLOR="Orange"> --->
		<BR>
	</CFIF>
	</CFOUTPUT>
	<TABLE BORDER="0" <CFIF IsDefined("Pay_Multi_Billbacks_ID") AND Not IsDefined("FullTableWidth")>WIDTH="85%" ALIGN="Center"<CFELSE>WIDTH="100%"</CFIF> CELLSPACING="0" CELLPADING="0">
		<CFOUTPUT QUERY="Get_Data">
		<TR>
			<TD WIDTH="33%"><B>Customer Name:</B>&nbsp;&nbsp;#Customer_Name#</TD>
			<TD WIDTH="33%"><B>Customer Number:</B>&nbsp;&nbsp;#Customer_Number#</TD>		
			<cfif NOT appSettings.getDistributorMultiPosition()>
			<TD><B>Broker:</B>&nbsp;&nbsp;#Broker_Name#</TD>
			</cfif>	
		</TR>
		</CFOUTPUT>
		<TR>
			<TD COLSPAN="100%"><HR COLoR="ORANGE"></TD>
		</TR>
	</TABLE>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- set da reason codes...only if Show_BB_Payment_GLCode is OFF...don't want 2 different GL features running        xxxx--->
	<!--- Then make sure they want the GL "Lite" feature BB_PC_GL_reason_codes_on        								      xxxx--->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFIF application.returned_customer_setting.Show_BB_Payment_GLCode EQ 0>
		<cfif application.returned_customer_setting.BB_PC_GL_reason_codes_on EQ 1>
        	<cfinclude template="BBReasonCodeAmountInc.cfm">
		</cfif>
	</CFIF>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- END END set da reason codes ENDS here	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TABLE BORDER="0" <CFIF IsDefined("Pay_Multi_Billbacks_ID") AND Not IsDefined("FullTableWidth")>WIDTH="85%" ALIGN="Center"<CFELSE>WIDTH="100%"</CFIF> CELLSPACING="0" CELLPADING="0">
		<CFOUTPUT QUERY="Get_Data">
		<TR>
			<TD NOWRAP WIDTH="24%" ALIGN="Right"><B>PAYABLE TO:</B></td>
			<TD <CFIF IsDefined("Pay_Multi_Billbacks_ID")>ROWSPAN="9"<CFELSE>ROWSPAN="8"</CFIF> STYLE="border-right:Solid 2px blue;">&nbsp;</TD>
			<TD WIDTH="33%">&nbsp;&nbsp;#Customer_Name#</TD>
			<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
			<TD NOWRAP WIDTH="5%">&nbsp;</TD>
			<TD WIDTH="38%">&nbsp;</TD>
			<CFELSE>
			<TD NOWRAP WIDTH="5%" STYLE="Border-bottom: SOLID blue 2px;">&nbsp;</TD>
			<TD WIDTH="38%" STYLE="Border-bottom: SOLID Blue 2px;"><B>CHECK TO BE SENT TO:</B></TD>
			</CFIF>
		</TR>
		<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
		<TR>
			<TD ALIGN="Right"><B>Amount:</B></TD>
			<TD>&nbsp;&nbsp;<B>#DollarFormat(Tot_Amount)#</B></TD>
			<TD NOWRAP WIDTH="5%" STYLE="Border-bottom: SOLID blue 2px;">&nbsp;</TD>
			<TD WIDTH="38%" STYLE="Border-bottom: SOLID Blue 2px;"><B>CHECK TO BE SENT TO:</B></TD>
		</TR>
		</CFIF>
		<TR>			
			<TD ALIGN="Right"><B>Tax ID Number:</B></TD>
			<TD>&nbsp;&nbsp;<CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="Payee_TAX_ID" SIZE="20" VALUE="#TRIM(Tax_ID_Number)#"><CFELSE>#Tax_ID_Number#</CFIF></TD>
			<TD ALIGN="Right"><B>Name:&nbsp;&nbsp;&nbsp;&nbsp;</B></TD>
			<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="Ch_Name" VALUE="#TRIM(Check_To_Name)#" SIZE="50"><CFELSE> #Check_To_Name#</CFIF></TD>		
		</TR>	
		<TR>
			<TD ALIGN="Right"><B>Phone Number:</B></TD>
			<INPUT TYPE="Hidden" NAME="Phone_Number" VALUE="#Get_Data.Phone_Number#">
			<TD>&nbsp;&nbsp;#Phone_Number#</TD>
			<TD ALIGN="Right"><B>Address:</B>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
			<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="CH_Address1" VALUE="#TRIM(Check_To_Address1)#" SIZE="50"><CFELSE>#Check_To_Address1#</CFIF></TD>				
		</TR>
		<TR>
			<TD ALIGN="Right"><B>Street Address:</B></TD>
			<TD>&nbsp;&nbsp;#Address1#, #Address2#</TD>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
			<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="CH_Address2" VALUE="#TRIM(Check_To_Address2)#" SIZE="50"><CFELSE>#Check_To_Address2#</CFIF></TD>
		</TR>
		<TR>
			<TD ALIGN="Right"><B>City:</B></TD>
			<TD>&nbsp;&nbsp;#City#</TD>
			<TD ALIGN="Right"><B>City:</B>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
			<TD><CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="CH_City" VALUE="#TRIM(Check_To_City)#" SIZE="50"><CFELSE>#Check_To_City#</CFIF></TD>		
		</TR>
		<TR>
			<TD ALIGN="Right"><B>State/Postal code:</B></TD>
			<TD>
				<TABLE>
					<TR>
						<TD>&nbsp;&nbsp;#State#</TD>
						<TD>/</TD>
						<TD>#Zipcode#</TD>
					</TR>
				</TABLE>
			</TD>
			<TD ALIGN="Right"><B>State:</B>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
			<CFQUERY NAME="getStates" datasource="#application.datasource#">
				Select s.*, c.Country_Sort_Order
				from _states s
				join _country c on s.Country_ID = c.Country_ID
				ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
			</CFQUERY>
			<TD>
				<TABLE>
					<TR>
						<TD><CFIF ViewMode EQ 0><SELECT NAME="CH_State">
							<OPTION VALUE="" SELECTED></OPTION>
							<CFLOOP QUERY="getStates">
								<OPTION VALUE="<CFOUTPUT>#getStates.State_Code#</CFOUTPUT>" <CFIF Trim(getStates.State_Code) EQ TRIM(Get_Data.Check_To_State)> SELECTED</CFIF>><CFOUTPUT>#getStates.State_Code#</CFOUTPUT></OPTION>
							</CFLOOP>
							</SELECT><CFELSE>#Check_To_State#</CFIF>
						</TD>
						<TD><B>Postal Code:</B>&nbsp;&nbsp;<CFIF ViewMode EQ 0><INPUT TYPE="Text" NAME="CH_Zip" VALUE="#TRIM(Check_To_Zipcode)#" SIZE="10" MAXLENGTH="10"><CFELSE>#Check_To_Zipcode#</CFIF></TD>					
					</TR>
				</TABLE>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="Right"><B>Prepared By:</B></TD>
			<TD>&nbsp;&nbsp;<CFIF ViewMode EQ 0><CFOUTPUT>#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#</CFOUTPUT><CFELSE>#Prepared_By_First_Name# #Prepared_By_Last_Name#</CFIF></TD>
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
		</TR>
		<TR>
			<TD ALIGN="Right"><B>Date:</B></TD>
			<TD>&nbsp;&nbsp;<CFIF ViewMode EQ 0>#DateFormat(now(),"mm/dd/yyyy")#<CFELSE>#DateFormat(Prepared_Date,"mm/dd/yyyy")#</CFIF></TD>
			<CFIF isdefined("URL.Approve") OR Get_Data.Signed EQ 1>
			<TD STYLE="Border-bottom: SOLID blue 2px;">&nbsp;</TD>
			<TD STYLE="Border-bottom: SOLID blue 2px;"><B>DEPARTMENT APPROVAL</B></TD>
			<CFELSE>
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
			</CFIF>
		</TR>
		<CFIF isdefined("URL.Approve") OR Get_Data.Signed EQ 1>
		<CFIF isdefined("URL.Approve") and not isdefined("needReasonCode")>  <!--- mws Reasoncode addition...above check looks to see if balance of payment has been applied to a reason code xxxxxxxxxxx --->
		 <INPUT TYPE="Hidden" NAME="Approve" VALUE="1"> 		
		</CFIF>
		
		<TR>
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
			<TD STYLE="Border-bottom: SOLID black 2px;"><BR><BR><BR>&nbsp;</TD>
		</TR>	
		<TR>
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
			<TD ALIGN="Center"><CFOUTPUT><B><CFIF Get_Data.Signed EQ 1>#Get_Data.Signed_By_First_Name# #Get_Data.Signed_By_Last_Name#</B> / #DateFormat(Get_Data.Signed_Date,"mm/dd/yyyy")#<CFELSE>#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#</B> / #dateFormat(Now(),"mm/dd/yyyy")#</CFIF></CFOUTPUT></TD>				
		</TR>
		</CFIF>
		</CFOUTPUT>
		<TR>
			<TD COLSPAN="100%"><HR COLOR="Orange"></TD>
		</TR>
		<TR>
			<TD COLSPAN="100%"><B>Comments/Explanation:</B></TD>		
		</TR>
		<CFOUTPUT QUERY="Get_Data">
		<TR>
			<TD COLSPAN="100%"><CFIF ViewMode EQ 0><TEXTAREA NAME="Explanation" COLS="138" ROWS="3"><CFOUTPUT>#Explanation#</CFOUTPUT></TEXTAREA><CFELSE>#Explanation#</CFIF></TD>
		</TR>
		</CFOUTPUT>
		<TR>
			<TD COLSPAN="100%"><HR COLOR="Orange"></TD>
		</TR>
	</TABLE>
</CFSAVECONTENT>
		
<CFIF isdefined("URL.Print_All")>
	<CFIF Count EQ 1>
		<CFSET Print_output = "#Mail_Fax#">
	<CFELSE>
		<CFSET Print_output = "#Print_Output# #Mail_Fax#"> 
	</CFIF>
</CFIF>

<CFSET Unique_ID = createUUID()>
<CFSET File_Name = "#Replace(Unique_ID,"-","_","all")#.html">

<CFIF isdefined("URL.Send_Mail") OR isdefined("URL.Send_Fax")> 		

	<CFIF isdefined("URL.Send_Mail")>
		<CFFILE ACTION	=	"WRITE"
				FILE	=  	"#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#File_Name#"
				OUTPUT	=	"#Mail_Fax#">
			

		<CFSET Rename 	= 	"PMT-REQ-#Get_Data.BB_Code#.html">
		
		
		<CFIF NOT DirectoryExists("#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#")>
		<CFDIRECTORY 	ACTION		=	"CREATE"
						DIRECTORY	=	"#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#">	
		</CFIF>								
		
		
		
		<CFIF FILEEXISTS("#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#\#Rename#")>		
			<CFFILE	ACTION	=	"DELETE"
					FILE	=	"#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#\#Rename#">
		</CFIF>
			
		<CFFILE	ACTION 		= 	"COPY"
				SOURCE 		= 	"#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#File_Name#"
				DESTINATION = 	"#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#\#Rename#">
				
		<CFSET File_Name = Rename>					
		<CFINCLUDE TEMPLATE="Payment_Email_Create.cfm">
		
		
		
		
	<CFELSEIF isdefined("URL.Send_Fax")>
		<!--- <CFSET File_Name = "#Replace(Unique_ID,"-","_","all")#.xls	"> --->
		<CFFILE ACTION	=	"WRITE"
				FILE	=  	"#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Fax_Files\#File_Name#"
				OUTPUT	=	"#Mail_Fax#" >
		<CFINCLUDE TEMPLATE="Payment_Fax_Create.cfm">
	</CFIF>				
</CFIF>


<CFIF isdefined("URL.Print")>

<CFOUTPUT>#mail_Fax#</CFOUTPUT>
<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm"> 		
</CFIF>



<CFIF isdefined("URL.Email_All")>

	<CFFILE ACTION	=	"WRITE"
			FILE	=  	"#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#File_Name#"
			OUTPUT	=	"#Mail_Fax#">
			
	<CFIF IsDefined("URL.Pay_Multi_Billbacks_ID")>
		<CFSET Rename 	= 	"PMT-REQ-Multi-#URL.Pay_Multi_Billbacks_ID#.html">		
	<CFELSE>
		<CFSET Rename 	= 	"PMT-REQ-#Get_Data.BB_Code#.html">			
	</CFIF>

	
	<CFIF NOT DirectoryExists("#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#")>
		<CFDIRECTORY 	ACTION		=	"CREATE"
						DIRECTORY	=	"#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#">	
	</CFIF>		
	
	<CFIF FILEEXISTS("#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#\#Rename#")>		
		<CFFILE	ACTION	=	"DELETE"
				FILE	=	"#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#\#Rename#">
	</CFIF>
	
	<CFFILE	ACTION 		= 	"COPY"
			SOURCE 		= 	"#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#File_Name#"
			DESTINATION = 	"#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#\#Rename#">
	
	<CFSET File_Name = Rename>	
								
	<CFSET Count = Count + 1>
	<CFIF Count EQ 1>
		<CFSET Email_All_File_Name = "#File_Name#">
	<CFELSE>			
		<CFSET Email_All_File_Name = "#Email_All_File_Name#,#File_Name#">
	</CFIF>		
</CFIF>


<CFIF isdefined("URL.Fax_All")>
	<CFFILE ACTION	=	"WRITE"
			FILE	=  	"#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Fax_Files\#File_Name#"
			OUTPUT	=	"#Mail_Fax#" >
			
	<CFSET Count = Count + 1>
	<CFIF Count EQ 1>
		<CFSET Fax_All_File_Name = "#File_Name#">
	<CFELSE>
		<CFSET Fax_All_File_Name = "#Fax_All_File_Name#,#File_Name#">
	</CFIF>
</CFIF>
		
		
