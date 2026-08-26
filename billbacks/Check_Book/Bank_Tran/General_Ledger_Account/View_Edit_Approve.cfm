<HTML>
<BODY BGCOLOR="White" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="8" TOPMARGIN="12" RIGHTMARGIN="8">

<!--- <CFPARAM NAME="URL.Payment_Data_Export_1_ID" DEFAULT="">
<CFPARAM NAME="URL.BBID" DEFAULT="">
<CFPARAM NAME="FORM.Payment_Data_Export_1_ID" DEFAULT="#URL.Payment_Data_Export_1_ID#">
<CFPARAM NAME="FORM.BBID" DEFAULT="#URL.BBID#"> --->

<CFIF IsDefined("URL.FromPaymentTab")>
	
	<CFIF Not IsDefined("URL.Payment_Data_Export_1_ID")>
		<cfset useLakebaseForGetID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_data_export_1")>
<cfif useLakebaseForGetID>
	<cftry>
		<cfset GetID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_data_export_1", {
				"billback_id" = "eq.#URL.BBID#",
				"deleted" = "eq.0",
				"select" = "payment_data_export_1_id"
			}), "payment_data_export_1_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetID>
<CFQUERY NAME="GetID" DATASOURCE="#Application.Datasource#">
			SELECT Payment_Data_Export_1_ID 
			FROM Payment_Data_Export_1 
			WHERE Billback_ID = '#URL.BBID#' AND Deleted = 0
		</CFQUERY>
</cfif>
		<CFPARAM NAME="URL.Payment_Data_Export_1_ID" DEFAULT="">		
		<CFSET URL.Payment_Data_Export_1_ID = GetID.Payment_Data_Export_1_ID>
	</CFIF>
</CFIF>

<CFIF isdefined("FORM.Q_Brand_ID")>
<CFSET Gl_Type_Count=0>
<CFLOOP INDEX="Q_Brand" LIST="#FORM.Q_Brand_ID#" DELIMITERS=",">
	<CFSET Gl_Type_Count= Gl_Type_Count + 1>
	<CFSET BelongToBB = ListGetAt(FORM.MultiBBID,Gl_Type_Count,",")> 
	<CFSET ReplacedBelongToBB = REPLACE(BelongToBB,"-","_","All")>
	<CFSET GL_Type = #EVALUATE("FORM.GL_Type_#Gl_Type_Count#_#ReplacedBelongToBB#")#>

	<CFQUERY NAME="Get_GL_Desc" DATASOURCE="#Application.Datasource#">
		SELECT GL_Type_Desc FROM GL_Type WHERE GL_Type_ID = <CFOUTPUT>#GL_Type#</CFOUTPUT>
	</CFQUERY>
	<CFOUTPUT>
	<CFQUERY NAME="Update_GL_Type" DATASOURCE="#Application.Datasource#">
		UPDATE 	Payment_Data_Export_2 
		
		SET		GL_Type_ID 		= #GL_Type#,
				GL_Type 		= '#Get_GL_Desc.GL_Type_Desc#' 
				
		WHERE 	Payment_Data_Export_1_ID = '#Payment_Data_Export_1_ID#' AND 
				Q_Brand_ID='#Q_Brand#' AND 
				<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
				Billback_ID = '#BelongToBB#' AND
				</CFIF>
				Deleted=0
		
	</CFQUERY> 
	</CFOUTPUT>
</CFLOOP>
</CFIF>


<CFOUTPUT>
	<CFQUERY NAME="Get_Trans_ID" DATASOURCE="#Application.Datasource#">
		SELECT 	Payment_Trans_ID 
		FROM 	Payment_Transaction 
		WHERE 	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
					Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND
				<CFELSE>
					Billback_ID='#BBID#' AND
				</CFIF> 
				Deleted=0
	</CFQUERY>

	<CFPARAM NAME="URL.Payment_Trans_ID" DEFAULT="#Get_Trans_ID.Payment_Trans_ID#">
	
	<CFQUERY NAME="Get_Data" DATASOURCE="#Application.Datasource#">
		SELECT 		* 
		FROM 		Payment_Data_Export_1
			
		WHERE 		Payment_Data_Export_1_ID = '#Payment_Data_Export_1_ID#'
	</CFQUERY>

</CFOUTPUT>


<CFIF Not isdefined("FORM.Form_submit")>	
<CFINCLUDE TEMPLATE="Edit_div.cfm">
<CFOUTPUT>
<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
<CFSET FORM.Lock_Status = 1>
<CFINCLUDE TEMPLATE="/Billbacks/Multi_BB_Payment/Lock_BB.cfm">
</CFIF>

<CFIF Get_Data.Saved EQ 1>
<TABLE BORDER="0" <CFIF IsDefined("Pay_Multi_Billbacks_ID")>WIDTH="85%" ALIGN="Center"<CFELSE>WIDTH="100%"</CFIF> CELLSPACING="0" CELLPADING="0">
<TR>
	
	<TD WIDTH="7%"><CFIF Get_Data.Signed EQ 0>	
	<B>	
	<FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue">
	<CFIF application.returned_customer_setting.Show_BB_Payment_GLCode EQ 1>
	<A href="Edit_Div.cfm" onClick="javaScript: return showtrafficDiv();" ONMOUSEOVER="javaScript: return showtrafficDiv();">edit</A>
	<CFELSE>
	 
		<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
			<A Href="View_Edit_Approve.cfm?Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&BBID=#URL.BBID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_Payee_Info=1">edit</A>		
		<CFELSE>
			<A Href="View_Edit_Approve.cfm?BBID=#URL.BBID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_Payee_Info=1">edit</A>
		</CFIF>
	  
	</CFIF>
	</FONT>
	<FONT SIZE="2" COLOR="Red">]</FONT>
	</B>&nbsp;
	 <B>	
	 </CFIF></TD>
	<!--- <FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue"><A Href="Edit_GL_Type.cfm?BBID=#URL.BBID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_GL_Type=1">edit gl type</A></FONT>
	<FONT SIZE="2" COLOR="Red">]</FONT>
	</B>&nbsp;	
	<B>
	<B>
	<FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue"><A Href="View_Edit_Approve.cfm?BBID=#URL.BBID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_Payee_Info=1">edit payee info</A></FONT>
	<FONT SIZE="2" COLOR="Red">]</FONT>
	</B>&nbsp;	
	<B>
	<B>
	<FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue"><A Href="Edit_GL_Type.cfm?BBID=#URL.BBID#&Payment_Trans_ID=#URL.Payment_Trans_ID#&Edit_GL_Type=1&Edit_Payee_Info=1">edit both</A></FONT>
	<FONT SIZE="2" COLOR="Red">]</FONT>
	</B>&nbsp;	  --->
	<!--- <CFIF not isdefined("URL.Approve")> </CFIF>--->
	<TD WIDTH="68%"><CFIF Get_Data.Signed EQ 0><span id="showsign"><B><FONT SIZE="2" COLOR="Red">[</FONT><FONT SIZE="2" COLOR="Blue"> 
		<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
			<A Href="View_Edit_Approve.cfm?BBID=#URL.BBID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_trans_ID#&Approve=1">sign</A>
		<CFELSE>
			<A Href="View_Edit_Approve.cfm?BBID=#URL.BBID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_trans_ID#&Approve=1">sign</A>
		</CFIF></FONT><FONT SIZE="2" COLOR="Red">]</FONT>
	</B>&nbsp;</span><span id="showApprove" style="visibility: hidden"><B><FONT SIZE="2" COLOR="Red">[</FONT><FONT SIZE="2" COLOR="Blue"> <A Href="##" onclick="Javascript: Confirm_Approve()">approve</A></FONT><FONT SIZE="2" COLOR="Red">]</FONT></B>&nbsp;</span>
	<cfelse><span id="showsign"></span></CFIF></TD>
	<TD WIDTH="8%">
	<B>
	<FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue">
	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
		<A Href="View_Edit_Approve_Content.cfm?BBID=#URL.BBID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_trans_ID#&Send_Mail=1" onclick="NewWindow(this.href,'v_e_a_e','850','600','Yes', 'No');return false;" TITLE="">email</A></FONT>
	<CFELSE>
		<A Href="View_Edit_Approve_Content.cfm?BBID=#URL.BBID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_trans_ID#&Send_Mail=1" onclick="NewWindow(this.href,'v_e_a_e','850','600','Yes', 'No');return false;" TITLE="">email</A></FONT>
	</CFIF>
	<FONT SIZE="2" COLOR="Red">]</FONT>
	</B>&nbsp;
	</TD>
	<TD WIDTH="6%">
	<B>
	<FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue">
	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
		<A Href="View_Edit_Approve_Content.cfm?BBID=#URL.BBID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_trans_ID#&Send_Fax=1" onclick="NewWindow(this.href,'v_e_a_f','850','600','Yes', 'No');return false;" TITLE="">fax</A></FONT>
	<CFELSE>
		<A Href="View_Edit_Approve_Content.cfm?BBID=#URL.BBID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#&Payment_Trans_ID=#URL.Payment_trans_ID#&Send_Fax=1" onclick="NewWindow(this.href,'v_e_a_f','850','600','Yes', 'No');return false;" TITLE="">fax</A></FONT>
	</CFIF>	
	<FONT SIZE="2" COLOR="Red">]</FONT>
	</B>&nbsp;	
	</TD>
	<TD WIDTH="7%">
	<B>
	<FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue"><A Href="javascript: alert_landscape();" <!--- onclick="NewWindow(this.href,'v_e_a_p','800','600','Yes', 'No');return false;" TITLE=""    View_Edit_Approve_Content.cfm?BBID=#URL.BBID#&Payment_Trans_ID=#URL.Payment_trans_ID#&Print=1--->>print</A></FONT>	
	<FONT SIZE="2" COLOR="Red">]</FONT>
	</B>
	</TD>
</TR>	
</TABLE>	
</CFIF>
</CFOUTPUT>	
<SCRIPT language="JavaScript">
function alert_landscape()
{
	alert("Please select LANDSCAPE LAYOUT to get a clear  printout");
	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
		NewWindow("View_Edit_Approve_Content.cfm?BBID=<CFOUTPUT>#URL.BBID#</CFOUTPUT>&Pay_Multi_Billbacks_ID=<CFOUTPUT>#Pay_Multi_Billbacks_ID#</CFOUTPUT>&Payment_Data_Export_1_ID=<CFOUTPUT>#Payment_Data_Export_1_ID#</CFOUTPUT>&Payment_Trans_ID=<CFOUTPUT>#URL.Payment_trans_ID#</CFOUTPUT>&Print=1", 'P_A', '850', '600', 'Yes', 'No', true);return false;
	<CFELSE>	
		NewWindow("View_Edit_Approve_Content.cfm?BBID=<CFOUTPUT>#URL.BBID#</CFOUTPUT>&Payment_Data_Export_1_ID=<CFOUTPUT>#Payment_Data_Export_1_ID#</CFOUTPUT>&Payment_Trans_ID=<CFOUTPUT>#URL.Payment_trans_ID#</CFOUTPUT>&Print=1", 'P_A', '850', '600', 'Yes', 'No', true);return false;
	</CFIF>

}
</SCRIPT>

<BR>
	<CFINCLUDE TEMPLATE = "View_Edit_Approve_Content.cfm">
		<CFIF (ViewMode NEQ 0 and isdefined("URL.Approve")) or isdefined("RcAmountError")><!--- Hide the sign link --->
			<SCRIPT language="JavaScript"> 
				function hide() 
							{ 
							if (document.getElementById('showsign')  != null )
							   {
								document.getElementById('showsign').style.visibility = 'hidden';   
							    } 
								 }
						hide();
			</SCRIPT>
		</cfif>
		<CFOUTPUT>#Mail_FAx#</CFOUTPUT>
		
		 <TABLE  BORDER="0" WIDTH="100%" CELLSPACING="0" CELLPADING="0">					
			<TR>
				<TD ALIGN="Center"><BR>
				<CFIF ViewMode EQ 0>
					<CFOUTPUT>
							<cfif application.returned_customer_setting.BB_PC_GL_reason_codes_on EQ 1><!--- validate reason codes et al. --->
								<CF_button
								button_name		=	""
								button_caption	=	"save"
								button_action	=	"RCvalidate()"
								button_type		=	"javascript_link"
								button_width	=	"75"
								button_color	=	"Navy"
								button_tip		=	""
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold">
							<cfelse><!--- vanilla validate --->
								<CF_button
								button_name		=	""
								button_caption	=	"save"
								button_action	=	"validate()"
								button_type		=	"javascript_link"
								button_width	=	"75"
								button_color	=	"Navy"
								button_tip		=	""
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold">
							</cfif>		
					</CFOUTPUT>
				<CFELSEIF isdefined("URL.Approve")>
					<CFOUTPUT>
							<CF_button
								button_name		=	""
								button_caption	=	"Approve"
								button_action	=	"Javascript: Confirm_Approve()"
								button_type		=	"javascript_link"
								button_width	=	"75"
								button_color	=	"Navy"
								button_tip		=	""
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"
								>
								<SCRIPT language="JavaScript"> 
								function hide() 
									{ 
									document.getElementById('showapprove').style.visibility = 'visible'; 
									}
									hide();
								</SCRIPT>
					</CFOUTPUT>
				<!--- <CFELSE>
					<CFOUTPUT>
							<CF_button
								button_name		=	""
								button_caption	=	"go to ..."
								button_action	=	"Javascript: close_window()"
								button_type		=	"javascript_link"
								button_width	=	"75"
								button_color	=	"Navy"
								button_tip		=	""
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"
								>
					</CFOUTPUT> --->
				</CFIF>
				</TD>
			</TR>
		</TABLE> 
		
	<CFIF isdefined("URL.Edit_Payee_Info") OR isdefined("URL.Approve")>
	</FORM>
	</CFIF>
<CFELSE>
	<CFIF NOT isdefined("FORM.Approve")>
		<CFOUTPUT>
		<cfset useLakebaseForGet_Payee = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_data_export_1")>
<cfif useLakebaseForGet_Payee>
	<cftry>
		<cfset Get_Payee = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_data_export_1", {
				"payment_data_export_1_id" = "eq.#FORM.Payment_Data_Export_1_ID#",
				"select" = "customer_name,address1,address2,city,state,zipcode,vendor_number,due_date"
			}), "customer_name,address1,address2,city,state,zipcode,vendor_number,due_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Payee = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Payee>
<CFQUERY NAME="Get_Payee" DATASOURCE="#Application.Datasource#">
			SELECT 		Customer_Name,
						Address1,
						Address2,
						City,
						State,
						Zipcode,
						Vendor_Number,
						Due_Date
			
			FROM 		Payment_Data_Export_1
			
			WHERE 		Payment_Data_Export_1_ID='#FORM.Payment_Data_Export_1_ID#'
		</CFQUERY>
</cfif>
		<CFSET DueDate = ListFirst(FORM.Due_Date,",")>
		<CFSET VendorNumber = ListFirst(FORM.VENDOR_NUMBER,",")>
		<CFTRANSACTION ACTION="BEGIN">
		<CFQUERY NAME="update_data" DATASOURCE="#Application.Datasource#">
			UPDATE 		Payment_Data_Export_1
			SET			Tax_ID_Number		=	'#FORM.Payee_TAX_ID#',
						Check_To_Name		=	'#Ch_Name#',
						Check_To_Address1 	= 	'#CH_Address1#',
						Check_To_Address2	=	'#CH_Address2#',
						Check_To_City		=	'#CH_City#',
						Check_To_State		=	'#CH_State#',
						Check_To_Zipcode	=	'#CH_Zip#',						
						Vendor_Number		=	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>'#VendorNumber#'<CFELSE>'#FORM.VENDOR_NUMBER#'</CFIF>,
						Due_Date			=	<CFIF IsDefined("Pay_Multi_Billbacks_ID")>'#DueDate#'<CFELSE>'#FORM.Due_Date#'</CFIF>,
						Phone_Number   		=	'#FORM.Phone_Number#',
						Explanation			=	'#Explanation#',						
						Prepared_By_First_Name=	'#request.AccessStructure.Name_First#',
						Prepared_By_Last_Name= 	'#request.AccessStructure.Name_Last#',
						Prepared_Date		=	'#DateFormat(Now())#',
						Saved				=	1
						
			WHERE 	Payment_Data_Export_1_ID='#Payment_Data_Export_1_ID#'
		</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- BillBack reason Code/Profit Center/GlCode section ...Only run for non-enhanced GL code installs xx--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<CFIF application.returned_customer_setting.Show_BB_Payment_GLCode EQ 0>
		  <cfif application.returned_customer_setting.BB_PC_GL_reason_codes_on EQ 1>
			<cfif isdefined("delBBrc") and delBBrc is "yes">
				  <CFQUERY name="qdelBBrc" datasource="#Application.datasource#">
					update BB_Reason_Code_Amount
					set deleted = <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">
					where BBReasonCodeAmountId = #form.BBReasonCodeAmountId#
				  </CFQUERY>
			<cfelse> <!--- update or insert --->
				<CFQUERY name="qSumRCAmount" datasource="#Application.datasource#">
					Select isnull(sum(ReasonAmount),0) as totreasonAmount
					from BB_Reason_Code_Amount BBRCA
					where Billback_Id = '#form.rcBBId#'
						and BBReasonCodeAmountId <> #form.BBReasonCodeAmountId#
						and deleted = 0
			 	</CFQUERY>
					<cfif form.rcAmount is ""><cfset form.rcAmount = 0></cfif>
					<cfset RCtot = form.RCAmount + qSumRCAmount.totreasonAmount>
				<CFIF form.RCAmount gt 0 and decimalFormat(RCtot) lte decimalformat(get_data.Tot_Amount)> <!--- handle for rounding --->
					<!--- Update reason codes and amounts --->
						<CFQUERY NAME="qGetReasonAmountId" DATASOURCE="#Application.Datasource#">
						SELECT 		BBReasonCodeAmountId 
						FROM 		BB_Reason_Code_Amount BBRCA
						where BBReasonCodeAmountId = #form.BBReasonCodeAmountId#
						
						</CFQUERY>
					<cfif qGetReasonAmountId.recordcount eq 0> <!--- insert --->
						<CFQuery name="iReasonAmount" datasource="#application.datasource#">
							insert BB_Reason_Code_Amount
								(Billback_Id, ReasonAmount, DD_Reason_Code_Id, PC_Reason_Code_Id, GL_Reason_Code_Id, Lastmodified<CFIF IsDefined("Pay_Multi_Billbacks_ID")>, Pay_Multi_Billbacks_ID</cfif>)
								values
								(<cfqueryparam value="#form.rcBBId#">,
								 <cfqueryparam value="#form.RCAmount#" cfsqltype="CF_SQL_FLOAT">,
								 <cfqueryparam value="#form.DDCode#">,
								 <cfqueryparam value="#form.PCCode#">,
								 <cfqueryparam value="#form.GLCode#">,
								 <cfqueryparam value="#now()#" cfsqltype="CF_SQL_TimeStamp">
								 <CFIF IsDefined("Pay_Multi_Billbacks_ID")>,<cfqueryparam value="#Pay_Multi_Billbacks_ID#"></cfif>)
						</CFQUERY>
					<cfelse> <!--- update --->
						 <CFQuery name="updReasonAmount" datasource="#application.datasource#">
								Update BB_Reason_Code_Amount
								  Set
								  Billback_Id = <cfqueryparam value="#form.rcBBId#">,
								  ReasonAmount = <cfqueryparam value="#form.RCAmount#" cfsqltype="CF_SQL_FLOAT">, 
								  DD_Reason_Code_Id = <cfqueryparam value="#form.DDCode#">, 
								  PC_Reason_Code_Id = <cfqueryparam value="#form.PCCode#">, 
								  GL_Reason_Code_Id = <cfqueryparam value="#form.GLCode#">, 
								  Lastmodified = <cfqueryparam value="#now()#" cfsqltype="CF_SQL_TimeStamp">
								  <CFIF IsDefined("Pay_Multi_Billbacks_ID")>,Pay_Multi_Billbacks_ID = <cfqueryparam value="#Pay_Multi_Billbacks_ID#"></cfif>
								  WHERE 
								  BBReasonCodeAmountId = #form.BBReasonCodeAmountId#
							</CFQUERY>
					<!--- <cfelse><!--- too much $$ ---> --->
					</cfif>
				<CFELSEIF decimalformat(RCtot) gt decimalFormat(get_data.Tot_Amount)> <!--- if it is 1 penny or more diff....rounding issue --->
					<cfset RcAmountError = RCtot - get_data.Tot_Amount>
				</CFIF> <!--- if amount gt 0 --->
			</cfif> <!--- if delete....DelBBRC --->
		  </cfif> <!--- if returned_customer_setting.BB_PC_GL_reason_codes_on EQ 1 --->
		</CFIF> <!---  if returned_customer_setting.Show_BB_Payment_GLCode --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!---END END BillBack reason Code/Profit Center/GlCode section END END 			xx--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		
		<!--- Updating  Payment_Data_Export_2--->
		<CFLOOP LIST="#FORM.BBID#" INDEX="BBItem">
			<CFSET ReplacedBB = REPLACE(BBItem,"-","_","All")>
			
			<CFIF application.returned_customer_setting.Show_BB_Payment_GLCode EQ 1>
				<CFLOOP LIST="#EVALUATE("FORM.Q_brand_ID_List_#ReplacedBB#")#" INDEX="Item">
					<CFSET ReplaceItem = Replace(Item,"-","_","All")>
					<CFQUERY NAME="UpdateTable2" DATASOURCE="#Application.Datasource#">
						UPDATE 	Payment_Data_Export_2
						SET 	OP_Unit		= '#EVALUATE("FORM.OP_Unit_#ReplaceItem#_#ReplacedBB#")#',
								AC_Number	= '#EVALUATE("FORM.AC_Number_#ReplaceItem#_#ReplacedBB#")#',
								Minor		= '#EVALUATE("FORM.Minor_#ReplaceItem#_#ReplacedBB#")#',
								Dept		= '#EVALUATE("FORM.Dept_#ReplaceItem#_#ReplacedBB#")#',
								Resp		= '#EVALUATE("FORM.Resp_#ReplaceItem#_#ReplacedBB#")#',
								I_C			= '#EVALUATE("FORM.I_C_#ReplaceItem#_#ReplacedBB#")#',
								Channel		= '#EVALUATE("FORM.Channel_#ReplaceItem#_#ReplacedBB#")#',
								Brand_1		= '#EVALUATE("FORM.Brand_1_#ReplaceItem#_#ReplacedBB#")#',
								Shelf		= '#EVALUATE("FORM.Shelf_#ReplaceItem#_#ReplacedBB#")#',
								U_Def		= '#EVALUATE("FORM.U_Def_#ReplaceItem#_#ReplacedBB#")#',
								Brand_2		= '#EVALUATE("FORM.Brand_2_#ReplaceItem#_#ReplacedBB#")#',
								Broker		= <CFIF IsDefined("FORM.Broker_#ReplaceItem#_#ReplacedBB#")>
												'#EVALUATE("FORM.Broker_#ReplaceItem#_#ReplacedBB#")#'
											  <CFELSE>
											  	NULL
											  </CFIF>
						WHERE 	Payment_Data_Export_1_ID='#Payment_Data_Export_1_ID#' AND Q_Brand_ID = '#Item#' AND 
								<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
								Billback_ID = '#BBItem#' AND
								</CFIF>
								Deleted = 0
					</CFQUERY>
				</CFLOOP>
			</CFIF>
		
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<!--- Update Billback status --->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<CFQUERY NAME="Update_BB_Status" DATASOURCE="#Application.Datasource#">
				UPDATE 		Billback
				SET 		Billback_Status_ID = 4,
							Payment_Type = <CFIF IsDefined("Pay_Multi_Billbacks_ID")>2<CFELSE>1</CFIF>
				WHERE
					Billback.Billback_ID = <CFOUTPUT>'#BBItem#'</CFOUTPUT>
					AND
					Billback.Billback_Status_ID = 3			
			</CFQUERY>
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	
		</CFLOOP>
		<CFTRANSACTION action = "commit">
		</CFTRANSACTION>
		
		<CFIF IsDefined("RcAmountError")>
		 <cfset URLRcAmountError="&RcAmountError=#RcAmountError#"> <!--- pass the urlVar --->
		<cfelse>
			<cfset URLRcAmountError=""> <!--- leave it empty --->
		</CFIF>
		
		<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
			<CFLOCATION URL="View_Edit_Approve.cfm?BBID=#FORM.BBID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID##URLRcAmountError#" ADDTOKEN="No">	
		<CFELSE>
			<CFLOCATION URL="View_Edit_Approve.cfm?BBID=#FORM.BBID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID##URLRcAmountError#" ADDTOKEN="No">
		</CFIF>		
		</CFOUTPUT>
		
		<!--- <SCRIPT language="JavaScript">
			window.close();
		</SCRIPT>  --->
	<CFELSE>
	
		<cfset useLakebaseForUpdate_Signed = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_data_export_1")>
<cfif useLakebaseForUpdate_Signed>
	<cftry>
		<cfset application.oLakebase.updateRows("payment_data_export_1",
			{
				"payment_data_export_1_id" = "eq.#Payment_Data_Export_1_ID#"
			},
			{
				"signed" = "1",
				"signed_by_first_name" = "#request.AccessStructure.Name_First#",
				"signed_by_last_name" = "#request.AccessStructure.Name_Last#",
				"signed_date" = "#DateFormat(Now())#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Signed = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Signed>
<CFQUERY NAME="Update_Signed" DATASOURCE="#Application.Datasource#">
			UPDATE		Payment_Data_Export_1
			
			SET			Signed = 1,
						Signed_By_First_Name 	= '#request.AccessStructure.Name_First#',
						Signed_By_Last_Name 	= '#request.AccessStructure.Name_Last#',
						Signed_Date				= '#DateFormat(Now())#'	
						
			WHERE 	Payment_Data_Export_1_ID='#Payment_Data_Export_1_ID#'
		</CFQUERY>
</cfif>		
		<BR><BR><BR>
		<TABLE ALIGN="Center">
			<TR>
				<TD>Please Wait while this payment request is being approved...</TD>
			</TR>
		</TABLE>
		<SCRIPT language="JavaScript">
			function backto()
			{
				<CFIF IsDefined("Pay_Multi_Billbacks_ID")>
					window.location.href ="View_Edit_Approve.cfm?BBID=<CFOUTPUT>#FORM.BBID#</CFOUTPUT>&Pay_Multi_Billbacks_ID=<CFOUTPUT>#Pay_Multi_Billbacks_ID#</CFOUTPUT>&Payment_Data_Export_1_ID=<CFOUTPUT>#Payment_Data_Export_1_ID#</CFOUTPUT>"				
				<CFELSE>				
					window.location.href ="View_Edit_Approve.cfm?BBID=<CFOUTPUT>#FORM.BBID#</CFOUTPUT>&Payment_Data_Export_1_ID=<CFOUTPUT>#Payment_Data_Export_1_ID#</CFOUTPUT>"
				</CFIF>
			}
			window.setTimeout('backto()', 3000);
		</SCRIPT> 			
	</CFIF> 	
</CFIF>


<SCRIPT language="JavaScript">
function validate()
{
	/*ErrorCount = 0;
	todaysDate = document.all.Today.value;
	error_text 		= "The due date can't be less than today.";
	error_oSpan 	= document.all.CheckDueDate;
	temp_Due_Date		= document.all.Due_Date.value;
	
	
	if(checkDate(temp_Due_Date, todaysDate) < 0)			
	{
		ErrorCount++;
		queueMessage(error_text, error_oSpan);
	}
	else
	{
		clearQueue(error_oSpan);
	}
		
	
	if(ErrorCount == 0) 
	{*/
			Check_To.submit()
			return false;
	/*}
	else 
	{
		showMessageWindow()
	}	*/	
}

function close_window()
{
	if (window.opener)
	{
		window.opener.location.reload();
	}
	window.close();
	return false;
}
function Confirm_Approve()
{
	
		Check_To.submit();
		return false;
	
}


</SCRIPT>
<SCRIPT SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>
 
 
 
<SCRIPT>

function checkDate(dateStr1,dateStr2)
{
 var dateSplit; 
 var retVal = null;
 dateSplit = dateStr1.split("/"); 
 if(dateSplit.length > 2)
 {
  var date1 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
  dateSplit = dateStr2.split("/");
  if(dateSplit.length > 2)
  {
   var date2 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
   retVal = days_between(date1, date2, true);
  }
 }
 return retVal;
}
</SCRIPT>

<CF_MessageWindow>
<script>
	if(window.parent.payment_tab)
	{
		window.parent.current_menu_item = "payment";
		window.parent.assignActiveTab();
		window.parent.buildMenu();
	}
</script>
</BODY>
</HTML>

