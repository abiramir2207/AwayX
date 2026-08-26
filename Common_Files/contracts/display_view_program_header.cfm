<!------ display_view_program_header.cfm ----->
<cfoutput>
<table BORDER="0" WIDTH="100%" CELLPADDING="0" CELLSPACING="0">
	<cfset col1Width = 171>
	<cfset col2Width = 507>
	<cfset colMidStyle = "border-left: 2px solid ##0000CC;padding-left: 10px;;">
	<TR>
		<TD COLSPAN="100%" BGCOLOR="">
		<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">#application.returned_customer_setting.company_name#</DIV> 
		<B><FONT SIZE="+1" COLOR="Navy">#getprogramstatus.getStatusDesc(CSLGetContractInfo.Contract_Status_Type_IDX)#: #CSLGetContractInfo.Contract_Number#
		<cfif CSLGetContractInfo.contract_status_type_idx GT 2><cfif len(CSLGetContractInfo.revision_version) eq 4>#right("#CSLGetContractInfo.revision_version#", 4)#<cfelseif len(CSLGetContractInfo.revision_version) eq 5>#right("#CSLGetContractInfo.revision_version#", 5)#<cfelse>#right("000#CSLGetContractInfo.revision_version#", 3)#</cfif></cfif>
		</FONT></B>
  		<cfif Sent_To_External_Client EQ 1><font size="3" color="red"><b>&nbsp;&nbsp;* This program is being sent to SAP *</b></font></cfif>
		 <cfif group_processed EQ 1><font size="1" color="red"><b>&nbsp;&nbsp;* Group processing is done on a nightly basis. This program will be ready for approval tomorrow. *</b></font></cfif>
		<!--- is trade eligible --->
		<cfif GetSettings.Include_Trade EQ 0>
		<font SIZE="2" COLOR="red"><I><cfif len(trim(GetSettings.Trade_Blurb)) GT 0>#GetSettings.Trade_Blurb#<cfelse>* Volumes from this program are not eligible for any other trade or promotional allowances</cfif></I></font>
		</cfif>
		<HR COLOR="Navy"></TD>
	</TR>
	<cfif  CSLGetContractInfo.Contract_Status_Type_IDX LT 3>
	<TR>
		<TD COLSPAN="100%" BGCOLOR="" align="left" valign="top">
		<font size="3" color="red"><b>* This program is not approved *</b></font>
		</TD>
	</TR>
	<tr><TD COLSPAN="100%" BGCOLOR=""></td></tr>
	</cfif>
	<tr>
		<td width="#col1Width#">&nbsp;</td>
		<td width="#col2Width#" style="#colMidStyle#">&nbsp;
		</td>
	</tr>
	<tr>
		<td width="#col1Width#"><b><font size="2">Title</font></b></td>
		<td width="#col2Width#" style="#colMidStyle#">		
		<font size="2">
		<b>#CSLGetContractInfo.Contract_Title#</b>		
		</font>&nbsp;</td>
	</tr>
	<tr valign="top">
		<td width="#col1Width#"><b><font size="2">Period</font></b><br>&nbsp;</td>
		<td width="#col2Width#" style="#colMidStyle#">
		<b>
		<font size="2">#MonthAsString(datepart('m', CSLGetContractInfo.Contract_Start_Date))#&nbsp;#datepart('d', CSLGetContractInfo.Contract_Start_Date)#,&nbsp;#datepart('yyyy', CSLGetContractInfo.Contract_Start_Date)# to #MonthAsString(datepart('m', CSLGetContractInfo.Contract_End_Date))#&nbsp;#datepart('d', CSLGetContractInfo.Contract_End_Date)#,&nbsp;#datepart('yyyy', CSLGetContractInfo.Contract_End_Date)#</font></b>&nbsp;</td>
	</tr>
	<!---display business segments if it's turned on--->
	<cfif businessSegmentsOn eq 1>
	<tr>
		<td width="#col1Width#"><font size="2">#appSettings.getbusiness_segment_label()#</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#qGetThisBusSegment.Business_Unit_Desc#</font>&nbsp;
		</td>
	</tr>
	</cfif>
	<cfif appSettings.getSalesOrgOn()>
	<tr>
		<td width="#col1Width#"><font size="2">#appSettings.getlob_label()#</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#Line_Of_Business_Name#</font>&nbsp;
		</td>
	</tr>
	</cfif>
	<!------ Operating Group ----->
	<cfif appSettings.getOperatingGroupOn()>
	<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
			
	<cfset programLevel1Level 				= operatingGroupManager.getProgramLevel1Level() />
	<cfset programLevel1LevelLabel 			= operatingGroupManager.getLabel(programLevel1Level) />
	<cfset programLevel1Desc 				= operatingGroupManager.getProgramOperatingGroupDesc(level=programLevel1Level, programId=CSLGetContractInfo.Contract_Main_ID) />
	
	<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
	<cfset programLevel2LevelLabel 			= operatingGroupManager.getLabel(programLevel2Level) />
	<cfset programLevel2Desc 				= operatingGroupManager.getProgramOperatingGroupDesc(level=programLevel2Level, programId=CSLGetContractInfo.Contract_Main_ID) />	
	<tr>
		<td width="#col1Width#"><font size="2">#programLevel1LevelLabel#</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#programLevel1Desc#</font>&nbsp;
		</td>
	</tr>
	<tr>
		<td width="#col1Width#"><font size="2">#programLevel2LevelLabel#</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#programLevel2Desc#</font>&nbsp;
		</td>
	</tr>
	</cfif>	
	
	<!---Search sequence information--->
	<cfif appSettings.getSearchSequenceOn() AND len(trim(CSLGetContractInfo.Search_Sequence_ID))>
		<cfset searchSequenceManager 			= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
		<cfset Search_Sequence_Name = searchSequenceManager.getSearchSequenceInfo(CSLGetContractInfo.Search_Sequence_ID) />
		<tr>
			<td width="#col1Width#"><font size="2">Search Sequence</font></td>
			<td width="#col2Width#" style="#colMidStyle#">
			<font size="2">#Search_Sequence_Name.Search_Sequence_Legacy# #Search_Sequence_Name.Search_Sequence_Desc#</font>&nbsp;
			</td>
		</tr>
	</cfif>
	<tr>
		<td width="#col1Width#"><font size="2">Program Type</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#CSLGetContractInfo.Created_Type# #CSLGetContractInfo.Template_Filter_Description#</font>&nbsp;
		</td>
	</tr>
	

	
	<cfif appSettings.getUse_Accounting_Program_Type() EQ 1>
		<cfquery name="GetAPT" datasource="#application.datasource#">
		SELECT APT_Name, APT_Reference_Number
		FROM Accounting_Program_Type
			INNER JOIN Contract_Main_Aux_Data
			ON Contract_Main_Aux_Data.Accounting_Program_Type_ID = Accounting_Program_Type.Accounting_Program_Type_ID
		</cfquery>
		
		<cfif GetAPT.Recordcount GT 0>
		<tr>
		<td width="#col1Width#"><font size="2">Program Label</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		
		<font size="2">#GetAPT.APT_Name# <cfif len(trim(GetAPT.APT_Reference_Number)) GT 0>(#trim(GetAPT.APT_Reference_Number)#)</cfif>&nbsp;</font>
		
		</td>
	</tr>
		</cfif>
	</cfif>
	<tr>
		<td width="#col1Width#"><font size="2">#application.returned_customer_setting.reference_number_label#</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<cfif appsettings.getSend_to_SAP()>
		&nbsp;
		<cfelse>
		<font size="2">#CSLGetContractInfo.Contract_Reference_Number#&nbsp;</font>
		</cfif>
		</td>
	</tr>
	<!----Display legacy id if it's on--->
	 <!--- Dev Note: Milan 9360 --->
	<cfif appSettings.getView_Legacy_ID() EQ 1>
	<cfset labelComp = CreateObject("component", "components.settings.labels.labels").init() />
	<cfset legacyIDLabel 	= labelComp.GetGeneralLabels('Legacy ID').General_Labels_Label />
	<tr>
		<td width="#col1Width#"><font size="2">#legacyIDLabel#</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#CSLGetContractInfo.LEGACY_DEAL_ID#&nbsp;</font>
		</td>
	</tr>
	</cfif>
	<!----Display bid id if it's on--->
	<cfif application.returned_customer_setting.display_bid_id>
	<tr>
		<td width="#col1Width#"><font size="2">Bid ID</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#CSLGetContractInfo.BID_NUMBER#&nbsp;</font>
		</td>
	</tr>
	</cfif>
	
	<cfif appSettings.getapprovalStandardOn() AND CSLGetContractInfo.Approved>
	<!------ Estimated $ ----->
	<cfset standardProgramApproval = CreateObject("component", "components.programs.approval.standard_program_approval") />
	<cfset getProgramMargins = standardProgramApproval.getProgramMargins(CSLGetContractInfo.contract_main_id,getSettings.approval_uom)>
	<cfif isNumeric(getProgramMargins.TotalProgramVolume) AND isNumeric(getProgramMargins.TOTAL_Allowance)>
	<cfset program_spend = (getProgramMargins.TotalProgramVolume) *  (getProgramMargins.TOTAL_Allowance)>
	<tr>
		<td width="#col1Width#"><font size="2">Estimated $</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#trim(Dollarformat(program_spend	))#&nbsp;</font>
		</td>
	</tr>
	</cfif>
	</cfif>

	<cfset paymenttypeManager = CreateObject("component","components.programs.payment_type.paymenttype") />
	<tr>
		<td width="#col1Width#"><font size="2">Claim Mechanism</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2"><cfif IsNumeric(CSLGetContractInfo.ClaimMechanics)>#trim(paymenttypeManager.getDesc(CSLGetContractInfo.ClaimMechanics))#</cfif>&nbsp;</font>
		</td>
	</tr>
	
	

	<cfif GetSettings.Billback_Date IS 1 AND GetSettings.Billback_Date_Span GT 1>
	<cfset PaymentRequestDue = dateadd("d", GetSettings.Billback_Date_Span, CSLGetContractInfo.Contract_End_Date)>
	<tr>
		<td width="#col1Width#"><font size="2">Last Date to Claim</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#dateformat(PaymentRequestDue, 'mmmm dd, yyyy')#&nbsp;&nbsp;( #GetSettings.Billback_Date_Span# days after expiration )&nbsp;</font>
		</td>
	</tr>
	</cfif>
	
	<cfif application.returned_customer_setting.Responsible_Person EQ 1>
	<tr>
		<td width="#col1Width#" valign="top"><font size="2">Responsible Sales Person</font></td>
		<td width="#col2Width#" style="#colMidStyle#" valign="bottom">
			<cfsilent>
			<!---if summary view, show detail information of user such as email, phone no--->
			<cfset qUser = CreateObject("component", "components.user.UserManager").getUser(CSLGetContractInfo.Responsible_User_ID) />
			<cfset useLakebaseForPositionDescforCreating = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_positions")>
<cfif useLakebaseForPositionDescforCreating>
	<cftry>
		<cfset PositionDescforCreating = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_positions", {
				"user_positions_id" = "eq.#CSLGetContractInfo.Creating_User_Position_ID#",
				"select" = "position_label"
			}), "position_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForPositionDescforCreating = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForPositionDescforCreating>
<cfquery name="PositionDescforCreating" datasource="#application.datasource#">
				SELECT Position_Label FROM User_Positions
				WHERE User_Positions_ID = '#CSLGetContractInfo.Creating_User_Position_ID#'
			</cfquery>
</cfif>
			<cfset displaySPRAddress2 = "" />
			<cfif appSettings.getPgmViewDisplaySPRAddress2() AND Trim(qUser.Work_Address_2) NEQ "">
				<cfset displaySPRAddress2 = ", #Trim(qUser.Work_Address_2)#" />
			</cfif>
			</cfsilent>
			<cfif qUser.recordCount GT 0 and summaryView>
				<table cellpadding="2" cellspacing="0" border="0" bgcolor="F2F2F2">
				<!--- bgcolor="F3F1B1" --->
					<tr>
						<td><B>Name:</B><font size="2">#qUser.User_Full_Name##displaySPRAddress2# (#PositionDescforCreating.Position_Label#)</font>&nbsp;</td>
						<td width="1px">&nbsp;</td>
						<td><B>Phone:</B> <font size="2">#qUser.User_Work_Phone# <cfif Len(qUser.Work_Phone_Ext) GT 0> Ext: #qUser.Work_Phone_Ext#</cfif></font></td>
					</tr>
					<tr>
					<!--- <font size="2" color="000099">--->
						<td nowrap><B>Title:</B> &nbsp; <font size="2">#qUser.Title#</font></td>
						<td  width="1px">&nbsp;</td>
						<td><B>Email:</B>&nbsp;&nbsp; <a href="mailto:#qUser.User_Email#"><font size="2">#qUser.User_Email#</font></a></td>
					</tr>
				</table>&nbsp;
			<cfelse>
				<font size="2"><cfif qUser.recordCount>#qUser.User_Full_Name##displaySPRAddress2# (#PositionDescforCreating.Position_Label#)</cfif>&nbsp;</font>			
			</cfif>
		</td>
	</tr>
	<tr>
	<td width="#col1Width#"><font size="2">Manager</font></td>
	<td width="#col2Width#" style="#colMidStyle#">
	<cfset getpositionabove = CreateObject("component", "components.geography.position").getFirstPositionAbove(CSLGetContractInfo.Creating_User_Position_ID) />
	<cfif getpositionabove neq -1>
		<cfset useLakebaseForPositionDescforManager = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_positions")>
<cfif useLakebaseForPositionDescforManager>
	<cftry>
		<cfset PositionDescforManager = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_positions", {
				"user_positions_id" = "eq.#getpositionabove#",
				"select" = "position_label"
			}), "position_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForPositionDescforManager = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForPositionDescforManager>
<cfquery name="PositionDescforManager" datasource="#application.datasource#">
			SELECT Position_Label FROM User_Positions
			WHERE User_Positions_ID = '#getpositionabove#'
		</cfquery>
</cfif>
		<cfif PositionDescforManager.recordcount GT 0>
			<cfquery name="getManagerDetails" datasource="#application.datasource#">
				SELECT top 1 name_first, name_last,Work_Phone,Work_Phone_Ext,user_email,title  from
				user_position_holders
				inner join _users on
				_users.user_id = user_position_holders.user_id
				and _users.deleted = 0
				where user_position_holders.user_positions_id = '#getpositionabove#'
				and user_position_type = 'P'
				and user_position_holders.deleted = 0
			</cfquery>
		</cfif>
	
		<cfif getManagerDetails.recordcount GT 0>
			<table cellpadding="2" cellspacing="0" border="0" bgcolor="F2F2F2">
			<tr>
			<td><B>Name:</B><font size="2">#getManagerDetails.name_first# & #getManagerDetails.name_last#(#PositionDescforManager.Position_Label#)</font>&nbsp;</td>
			<td width="1px">&nbsp;</td>
			<td><B>Phone:</B> <font size="2">#getManagerDetails.Work_Phone# <cfif Len(getManagerDetails.Work_Phone_Ext) GT 0> Ext: #getManagerDetails.Work_Phone_Ext#</cfif></font></td>
			</tr>
			<tr>
			<!--- <font size="2" color="000099">--->
			<td nowrap><B>Title:</B> &nbsp; <font size="2">#getManagerDetails.title#</font></td>
			<td  width="1px">&nbsp;</td>
			<td><B>Email:</B>&nbsp;&nbsp; <a href="mailto:#getManagerDetails.User_Email#"><font size="2">#getManagerDetails.User_Email#</font></a></td>
			</tr>
			</table>
		<cfelse>
			<cfif PositionDescforManager.recordcount GT 0>
			<font size="2">#PositionDescforManager.Position_Label#</font>
			</cfif>&nbsp;
		</cfif>
	<cfelse>&nbsp;
	</cfif>
	</td>
	</tr>
	</cfif>
	
	
	<cfif isDefined("CSLGETCONTRACTINFO.Approval_Date")>
	<cfif len(trim(CSLGETCONTRACTINFO.Approval_Date)) GT 0>
	<tr>
		<td width="#col1Width#"><font size="2">Approved On:</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		
		<font size="2">#dateformat(CSLGETCONTRACTINFO.Approval_Date, 'MM/DD/YYYY')#&nbsp;</font>
		</td>
	</tr>
	</cfif>
	</cfif>

	<CFIF GetSettings.Rebate_Recipient_On EQ 1>		
	<tr>
			<td width="#col1Width#"><font size="2">Rebate Recipient</font></TD>
			<cfif CSLGetContractInfo.Rebate_Recipient_Customer_ID NEQ "">
			 <cfset useLakebaseForGetRebateRecipient = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForGetRebateRecipient>
	<cftry>
		<cfset GetRebateRecipient = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#CSLGetContractInfo.Rebate_Recipient_Customer_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetRebateRecipient = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetRebateRecipient>
<CFQUERY NAME="GetRebateRecipient" DATASOURCE="#Application.Datasource#">
					SELECT * FROM BSA_Foodservice_Customers WHERE BSA_Foodservice_Customers_ID ='#CSLGetContractInfo.Rebate_Recipient_Customer_ID#'
			</CFQUERY>
</cfif> -
			<!---FILTER: Do if it's pending--->
			<td width="#col2Width#" style="#colMidStyle#"><font size="2"><CFIF GetRebateRecipient.Recordcount GT 0><CFOUTPUT>#GetRebateRecipient.Name# (#GetRebateRecipient.Shr_Ship_To#)</CFOUTPUT></CFIF>&nbsp;&nbsp;&nbsp;</TD> 
	<cfelse>
		<td width="#col2Width#" style="#colMidStyle#">&nbsp;</td>
	</cfif>
		</TR>
	</cfif>
	<tr valign="top">
		<td width="#col1Width#"><font size="2">Notes</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">
		<!---FILTER: If there aren't any notes then say so--->
		<cfif Len(trim(CSLGetContractInfo.Notes))>#Replace(Replace(CSLGetContractInfo.Notes, " ", " &nbsp;", "ALL"), "#chr(13)#", "<br>", "ALL")#<cfelse>(None)</cfif>&nbsp;</font>
		</td>
	</tr>		
</TABLE>
</cfoutput>