<!---
	Copyright (c)2009 Blacksmith Applications, Inc.
	Filename:			AwayX/Scheduled/ApprovalViaEmailSendEmail.cfm
	Created:			8/2/2009
	Developer:			kvangapalli
	Description:		This file find programs in RFA and sends out the emails to users for mass approval
	Usage:				AwayX/settings/app_settings_approval_via_email.cfm
	Tip:				If a programId is passed to this file, then email is sent only for that program
	Modified:			7/10/2014; D43870; KAL: Run Remote Approval Send on demand for users with Single option
--->
<cfparam name="url.programId" default="0">
<cfparam name="getFixedPriceProducts.recordCount" default="0">
<cfparam name="rebateProductRateData.recordCount" default="0">
<cfparam name="getComponents.recordCount" default="0">
<cfparam name="getLumpSums.recordCount" default="0">
<cfparam name="getOperators.recordCount" default="0">
<cfparam name="getDistributors" default="0">
<cfparam name="previousFixedComponentName" default="0">
<cfparam name="previousRebateComponentName" default="0">


<!--- Run this job obly if the app setting is on --->
<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().getApprovalViaEmail()>
	<!--- Begin: Initalise the components needed --->
	<cfset application.oController.getObject(path="mvc.Models.Program.Approval.EmailApprovalManager",name="EmailApprovalManager",bReload= 0) />
	<cfset variables.programManager     = createobject("component", "components.programs.ProgramManager").init() />
	<cfset variables.businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
	<cfset viewProgramManager           = CreateObject("component", "components.programs.Display_Program.viewprogramtemplateManager") />
	<cfset distGroupManager             = CreateObject("component", "components.programs.distributors.DistributorGroupManager").init() />
	<cfset applicationSettingsManager   = CreateObject("component", "components.settings.ApplicationSettingsManager").init()>
	<!--- End: Initalise the components needed --->

	<!--- Get Auto Approve Email Address for "From" --->
	<cfset variables.autoApproveEmail = application.oEmailApprovalManager.getAutoApproverSettings().Auto_Approve_Email />

	<!--- Get the email instructions --->
	<cfset variables.EmailInst = Application.oApplicationAppSettingsManager.getApplicationAppSettings().getEmailApprovalInstructions() />

	<!--- Business Segment On/Off --->
	<cfset variables.businessSegmentsOn = 0>
	<cfif variables.businessSegManager.isEnabled()>
		<cfset variables.businessSegmentsOn = 1 />
	</cfif>

	<cfset variables.fixedPriceLabel = applicationSettingsManager.getDiscountTypeDesc(1) />
	<cfset variables.rebateLabel     = applicationSettingsManager.getDiscountTypeDesc(2) />
	<cfset variables.lumpSumLabel    = applicationSettingsManager.getDiscountTypeDesc(3) />

	<!--- Get the list of programs by user --->
	<cfset variables.qGetApprovableProgramsUsersList = variables.programManager.getApprovableUsers(
														programId=url.programId,
														businessSegmentsOn=variables.businessSegmentsOn,
														checkMassApprove='1',
														checkRFANotificationEmail='0',
														checkRemoteApprovalOption='1') />


	<!--- Dev Note: Kal; D43870: Run Remote Approval Send on demand for users with Single option  --->
	<cfquery name="variables.qUserList" dbtype="query" >
		SELECT 	DISTINCT user_ID, user_Email, user_Code, user_Full_Name, RFA_Notification_Email, Remote_Approval_Option
		FROM 		variables.qGetApprovableProgramsUsersList
		WHERE  	1 = 1
		<cfif url.programId >
		AND 		Remote_Approval_Option = 1
		</cfif>
	</cfquery>

	<cfoutput query="variables.qUserList">

		<cfset variables.msgHeader	= 	"#variables.qUserList.user_Full_Name#" & " (#variables.qUserList.user_Code#),"/>
		<cfset variables.msgHeader	= 	variables.msgHeader & "#Chr(13)##Chr(10)#" & "#Chr(13)##Chr(10)#"/>
		<cfset variables.msgHeader	= 	variables.msgHeader & "#variables.EmailInst#" & "#Chr(13)##Chr(10)#"/>
		<cfset variables.msgBody 	= 	"Program	|	Title   |   Trade $" & "#Chr(13)##Chr(10)#"/>

		<cfset variables.msgFooter	= 	"--- DO NOT EDIT BELOW THIS LINE ---" & "#Chr(13)##Chr(10)#" />

		<!--- Get Max Sent ID --->
		<cfset variables.qGetMaxSentId = "" />
		<cfquery name="variables.qGetMaxSentId" datasource="#application.dataSource#">
			SELECT ISNULL(MAX(Sent_ID),0)+1  AS maxSentId FROM Email_Approval_User_Programs
		</cfquery>

		<!--- Get the program for each user --->
		<cfset variables.qGetUserPrograms = "" />
		<cfquery name="variables.qGetUserPrograms" dbtype="query" >
			SELECT 	User_ID,User_Full_Name, User_Email, Contract_Main_ID, Contract_Number, Contract_Title,Broker_User_ID,ProgramType_ID,
							Broker_Approved_Date,Contract_Start_Date,Contract_End_Date,Notes,Program_spend
			FROM 		variables.qGetApprovableProgramsUsersList
			WHERE 	user_ID = <cfqueryparam value="#variables.qUserList.user_ID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<!---
			Dev Note: KAL; 7/6/2010; D23915: Remmote approval email option
			Single email per program/Batch email; 1 = Single; 2 = Batch
			If Single add the msg footer and send email
		--->
		<cfif variables.qUserList.Remote_Approval_Option eq 1>

			<!--- Loop through user's programs and insert into Email_Approval_User_Programs table and build the email body --->
			<cfloop query="variables.qGetUserPrograms">
				<!--- Check if we sent email recently, otherwise resend it --->
				<cfset variables.checkResendEmail = application.oEmailApprovalManager.checkResendEmail(
														variables.qGetUserPrograms.User_ID,
														variables.qGetUserPrograms.Contract_Main_ID) />

				<!--- Check if we sent email recently, otherwise resend it --->
				<cfif variables.checkResendEmail>

					<cfset getDistributors  = viewProgramManager.getDistributors(variables.qGetUserPrograms.Contract_Main_ID, businessSegmentsOn, distGroupManager.ProgramDistributorIsGroup(variables.qGetUserPrograms.Contract_Main_ID))>
					<cfset getOperators = viewProgramManager.getOperators(variables.qGetUserPrograms.Contract_Main_ID)>
					<cfset getFixedPriceProducts = viewProgramManager.getFixedPriceOnEmail(variables.qGetUserPrograms.Contract_Main_ID)>
					<cfset rebateProductRateData = viewProgramManager.getRebateOnEmail(variables.qGetUserPrograms.Contract_Main_ID)>
					<cfset getLumpSums = viewProgramManager.getLumbSumOnEmail(variables.qGetUserPrograms.Contract_Main_ID)>
					<cfset ProgramType = viewProgramManager.getProgramTypeOnEmail(variables.qGetUserPrograms.ProgramType_ID)>


					<!--- Get the program resquested approval By --->
					<cfquery name="variables.qGetResquestedApprovalBy" datasource="#application.dataSource#">
						SELECT 	_Users.Name_First + ' ' + _Users.Name_Last as ResquestedApprovalBy
						FROM 	_Users
						WHERE 	user_ID = <cfqueryparam value="#variables.qGetUserPrograms.Broker_User_ID#" cfsqltype="cf_sql_varchar">
					</cfquery>

					<!--- Get the 52 weeks program volume 25878 --->
					<cfquery name="Get52WeeksCasePounds" datasource="#application.dataSource#">
						select  cast(sum(Volume_CS) * 52 as decimal(20, 0)) as Volume_CS_52_Weeks,cast(sum(Volume_LB) * 52 as decimal(20, 0)) as Volume_LB_52_Weeks
						from    program_product_volume
						where 	program_id = <cfqueryparam value="#variables.qGetUserPrograms.Contract_Main_ID# " cfsqltype="cf_sql_integer">
						and     deleted = 0
						and     is_group = 0
					</cfquery>

					<!--- Insert into table Email_Approval_User_Programs --->
					<cfset variables.insertUserPrograms = application.oEmailApprovalManager.insertUserPrograms(
															variables.qGetUserPrograms.User_ID,
															variables.qGetUserPrograms.Contract_Main_ID,
															variables.qGetUserPrograms.Contract_Number,
															variables.qGetMaxSentId.maxSentId,
															variables.qUserList.Remote_Approval_Option) />

					<!--- Build the email msg body/content --->
					<cfset variables.msgBody 	= 	"Program	|	Title" & "#Chr(13)##Chr(10)#"/>
					<cfset variables.msgBody = variables.msgBody & "#variables.qGetUserPrograms.Contract_Number#" & "	|	" />
					<cfset variables.msgBody = variables.msgBody & "#variables.qGetUserPrograms.Contract_Title#"/>


					<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>

					<!--- 24993: 10/18/2010; add more info on single email content in message body		--->
					<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
					<cfset variables.msgBody = variables.msgBody & "--- DO NOT EDIT BELOW THIS LINE ---"/>
					<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>

					<cfset variables.msgBody = variables.msgBody & "**start program information**"/>
					<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
					<cfset variables.msgBody = variables.msgBody & "Requested Approval by:  #variables.qGetResquestedApprovalBy.ResquestedApprovalBy#" />
					<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
					<cfset variables.msgBody = variables.msgBody & "Requested Approval on:  #dateformat(variables.qGetUserPrograms.Broker_Approved_Date, 'mm/dd/yyyy')#" />
					<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
					<cfset variables.msgBody = variables.msgBody & "Program Type:  #ProgramType#" />
					<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
					<cfset variables.msgBody = variables.msgBody & "Dates:  #DateFormat(variables.qGetUserPrograms.Contract_Start_Date, 'mmmm d, yyyy')# to #DateFormat(variables.qGetUserPrograms.Contract_End_Date, 'mmmm d, yyyy')#"/>
					<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
					<!--- Dev Note: Drachala; D27388: Remote Approval email content --->
					<cfset variables.msgBody = variables.msgBody & "Trade $: #dollarFormat(variables.qGetUserPrograms.Program_spend)#" />

					<cfif Get52WeeksCasePounds.recordCount GT 0>
						<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
						<cfset variables.msgBody = variables.msgBody & "Volume - 52 week pounds:  #NumberFormat(Get52WeeksCasePounds.Volume_LB_52_Weeks, ',' )#"/>
						<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
						<cfset variables.msgBody = variables.msgBody & "Volume - 52 week cases:   #NumberFormat(Get52WeeksCasePounds.Volume_CS_52_Weeks, ',' )#"/>
						<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
					</cfif>
					<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
					<cfif getOperators.recordCount GT 0>
						<cfset variables.msgBody = variables.msgBody & "Operators:  " />
						<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
						<cfloop query ="getOperators">
							<cfset variables.msgBody = variables.msgBody & "#getOperators.Operator_Name# (#getOperators.BSA_Operator_ID#)"/>
							<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
						</cfloop>
					</cfif>
					<cfif getDistributors.recordCount GT 0>
						<cfset variables.msgBody = variables.msgBody & "Distributors: " />
						<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
						<cfloop query ="getDistributors">
							<cfset variables.msgBody = variables.msgBody & "#getDistributors.Name# (#getDistributors.Shr_Ship_To#)"/>
							<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
						</cfloop>
					</cfif>

					<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
					<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>

					<cfif getFixedPriceProducts.recordCount GT 0>
						<cfset variables.msgBody = variables.msgBody & "Discount:  #variables.fixedPriceLabel#" />
						<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
						<cfloop query ="getFixedPriceProducts">
							<cfif "#getFixedPriceProducts.Program_Fixed_Component_Name#" NEQ "#previousFixedComponentName#">
								<cfset variables.msgBody = variables.msgBody & "#getFixedPriceProducts.Program_Fixed_Component_Name#" />
								<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
							</cfif>
						</cfloop>
						<!--- Dev Note: Drachala; D27388: Remote Approval email content --->
						<cfset variables.msgBody = variables.msgBody &	"Rate	UOM	Product Group ID	Product Group Desc"/>
						<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>

						<cfloop query ="getFixedPriceProducts">
							<cfset variables.msgBody = variables.msgBody & "$#getFixedPriceProducts.Fixed_Price_Value#	#getFixedPriceProducts.Abbreviation#	#getFixedPriceProducts.Item#	#getFixedPriceProducts.description#" />
							<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
							<cfset previousFixedComponentName = "#getFixedPriceProducts.Program_Fixed_Component_Name#">
						</cfloop>
					</cfif>

					<cfif rebateProductRateData.recordCount GT 0>
						<cfset variables.msgBody = variables.msgBody & "Discount:  #variables.rebateLabel#" />
						<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
						<cfset previousRebateComponentName = "0">
						<cfloop query ="rebateProductRateData">
							<cfif "#rebateProductRateData.Program_Rebates_Component_Name#" NEQ "#previousRebateComponentName#">
								<cfset variables.msgBody = variables.msgBody & "#rebateProductRateData.Program_Rebates_Component_Name#" />
								<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
							</cfif>
						</cfloop>

						<!--- Dev Note: Drachala; D27388: Remote Approval email content --->
						<cfset variables.msgBody = variables.msgBody &	"Rate	UOM	Product Group ID	Product Group Desc"/>
						<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>

						<cfloop query ="rebateProductRateData">
							<cfset variables.msgBody = variables.msgBody & "$#rebateProductRateData.Rate#	#rebateProductRateData.Abbreviation#	#rebateProductRateData.Item#	#rebateProductRateData.description#" />
							<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
							<cfset previousRebateComponentName = "#rebateProductRateData.Program_Rebates_Component_Name#">
						</cfloop>
					</cfif>

					<cfif getLumpSums.recordCount GT 0>
						<cfset variables.msgBody = variables.msgBody & "Discount:  #variables.lumpSumLabel#" />
						<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
						<cfloop query ="getLumpSums">
							<cfset variables.msgBody = variables.msgBody & "#getLumpSums.Program_Lump_Sum_Name#" />
							<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
							<cfset variables.msgBody = variables.msgBody & "$#getLumpSums.Lump_Sum_Amount#" />
							<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
						</cfloop>
					</cfif>
					<cfif variables.qGetUserPrograms.Notes NEQ "">
						<cfset variables.msgBody = variables.msgBody & "Notes:  #variables.qGetUserPrograms.Notes#" & "#Chr(13)##Chr(10)#"/>
						<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>
					</cfif>
					<cfset variables.msgBody = variables.msgBody & "**end program information**"/>
					<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>


					<!--- End 24993: 10/18/2010; add more info on single email content in message body		--->

					<!--- Build Email Footer --->
					<cfset variables.msgFooter	= 	"--- DO NOT EDIT BELOW THIS LINE ---" & "#Chr(13)##Chr(10)#" />
					<cfset variables.msgFooter = variables.msgFooter & "--- " />
					<cfset variables.msgFooter = variables.msgFooter & "#variables.qGetMaxSentId.maxSentId#" & "|" & "#variables.qGetUserPrograms.User_ID#" />
					<cfset variables.msgFooter = variables.msgFooter & " ---" />
					<cfset variables.msgFooter = variables.msgFooter & "#Chr(13)##Chr(10)#" />
					<cfset variables.msgFooter = variables.msgFooter & "#application.returned_customer_setting.Company_Name#"& " -- " &"Contract Management services provided by #Application.CompanyNameFull#" />

					<cfset useLakebaseForGetcompany = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForGetcompany>
	<cftry>
		<cfset Getcompany = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "company_main_id"
			}), "company_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetcompany = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetcompany>
<cfquery name="Getcompany" datasource="#application.datasource#">
						SELECT 	Top 1 Company_Main_ID
						FROM 	Company_Main
						WHERE 	Deleted = 0		<!--- D45803 :: Template error when creating multiple programs --->
					</cfquery>
</cfif>

					<cfset request.AccessStructure.Company_Main_ID = GetCompany.Company_Main_ID />
					<cfset request.AccessStructure.User_ID = variables.qGetUserPrograms.User_ID />
					<!---77408 Product Group sequencing START--->
					<cfif application.appSettingsGet.get_Setting('Product_Group_Sequencing') >
						<cfset request.AccessStructure.numberOfProductGroupLevels = 9>
					<cfelse>
						<cfset request.AccessStructure.numberOfProductGroupLevels = 3>
					</cfif>
					<!---77408 Product Group sequencing END--->
					<cfset variables.pgmThinDisplayIsAttachement = 1 />

					<!--- Include the program attachement --->
					<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().getSendAutoAttachments()>
					   <cfset commonqueries_Called = 0><!--- D36249:Program Approval Request email attachment --->
						<cfset csl_contract_main_id = variables.qGetUserPrograms.Contract_Main_ID>
						<cfinclude template="/common_files/contracts/commonqueries.cfm">
						<cfsavecontent variable = "EmailContents">
							<cfinclude template="/common_files/contracts/thin_contract_general_display.cfm">
						</cfsavecontent>
					</cfif>

					<!--- Email Functionality Begins Here --->
					<CF_EMAILWRAPPER
						to="#variables.qGetUserPrograms.User_Email#"
						from="#variables.autoApproveEmail#"
						subject="BLACKSMITH PROGRAM APPROVAL REQUEST"
						type="text"
						messagetype="1"
						generatedby="1"
						apparea="1"
						logMessage="1">

							#variables.msgHeader#   #Chr(13)##Chr(10)#
							#variables.msgBody#			#Chr(13)##Chr(10)#
							#variables.msgFooter#		#Chr(13)##Chr(10)#

							<!--- Include the program attachement --->
							<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().getSendAutoAttachments() and Application.oApplicationAppSettingsManager.getApplicationAppSettings().getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
								<CF_Writing_Email_Attachment
									naming_format="Program_#variables.qGetUserPrograms.Contract_Title#"
									file_extension="html"
									relative_path="\Temp_Files\Program\"
									output_content="#EmailContents#"
									addNewLine="No"
									return_file_name="fName">
								<cf_emailwrapperparam file = "#fName#" store="yes" />
							</cfif>

					</CF_EMAILWRAPPER>
					<!--- Email Functionality Ends Here --->

					<!--- Set the email as sent in the Email_Approval_User_Programs table  --->
					<cfset variables.qSetEmailSent = "" />
					<cfquery name="variables.qSetEmailSent" datasource="#application.dataSource#">
						UPDATE	Email_Approval_User_Programs
						SET		Email_Sent = <cfqueryparam value="1" cfsqltype="cf_sql_bit" />,
								Email_Sent_Date = getDate()
						WHERE	Sent_ID = <cfqueryparam value="#variables.qGetMaxSentId.maxSentId#" cfsqltype="cf_sql_integer" />
					</cfquery>

					<!--- Get the next Max Sent ID --->
					<cfset variables.qGetMaxSentId = "" />
					<cfquery name="variables.qGetMaxSentId" datasource="#application.dataSource#">
						SELECT ISNULL(MAX(Sent_ID),0)+1  AS maxSentId FROM Email_Approval_User_Programs
					</cfquery>

				</cfif> <!--- end cfif: variables.checkResendEmail --->

			</cfloop> <!---end cfloop: variables.qGetUserPrograms --->

		<!---
			Dev Note: KAL; 7/6/2010; D23915: Remmote approval email option
			Single email per program/Batch email; 1 = Single; 2 = Batch
			Dont send email to batch users when running on demand out emails
		--->
		<cfelseif (variables.qUserList.Remote_Approval_Option eq 2) and not(url.programId) >

			<!--- Loop through user's programs and insert into Email_Approval_User_Programs table and build the email body --->
			<cfloop query="variables.qGetUserPrograms">

			<cfset ProgramSpend = variables.qGetUserPrograms.Program_spend>

			<!--- If the "Spending cap" margin method is ON. --->
			<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().getApprovalSpendingCapOn() IS 1>
				<!--- Curently, "program_Spend" is only populated for clients having standard and layered margin. So, for clients using
				"Spending cap",  "program_Spend" is zero as the "PROGRAM_TRADE_SPEND_UPDATE" SP executes logic for  standard and layered margin only.
				While modifying the "PROGRAM_TRADE_SPEND_UPDATE" SP, we realized that we cannot calculate "program_spend" for fixed price,
				since lambweston does not send us price list (Note Lambweston uses "floor pricing").
				So, we cannot really send them "program_Spend" for all the discount types. They said that it is OK, if we calculate it for lumpsum only.
				For "Spending cap" margin method, we only calculate "program_Spend" for lumpsum below. Other discount types are not accounted for.
				--->
				<!---
				If there is any other discount type other than Lumpsum on the program (Lumpsum and any other discount type), then
				the "program_spend" value will be wrong, as we are not accounting for the other discount type.
				Lambweston was fine with it. They just want the "program spend" populated for programs which have lumpsum (with or without other discount types).
				In the future, if we need to calculate any other discount type for "Spending cap", then perhaps modifying "PROGRAM_TRADE_SPEND_UPDATE"
				SP will be a better solution.
				Currently, no client who is using "Spending cap" is also using Remote Approval, other than Lambweston.
				--->
				<cfquery name="qryTotalLumpsumAmount" datasource="#application.dataSource#">
					SELECT SUM(CAST(Lump_Sum_Amount AS DECIMAL(20,4))) As Total_LS_Amount
					FROM 	Program_Lump_Sums
					WHERE 	Program_ID = #variables.qGetUserPrograms.Contract_Main_ID#
					AND 	Deleted = 0
				</cfquery>

				<cfset ProgramSpend = qryTotalLumpsumAmount.Total_LS_Amount>
			  </cfif>

				<!--- Insert into table Email_Approval_User_Programs --->
				<cfset variables.insertUserPrograms = application.oEmailApprovalManager.insertUserPrograms(
								variables.qGetUserPrograms.User_ID,
								variables.qGetUserPrograms.Contract_Main_ID,
								variables.qGetUserPrograms.Contract_Number,
								variables.qGetMaxSentId.maxSentId,
								variables.qUserList.Remote_Approval_Option) />

				<!--- Build the email msg body/content --->
				<cfset variables.msgBody = variables.msgBody & "#variables.qGetUserPrograms.Contract_Number#" & "	|	" />
				<cfset variables.msgBody = variables.msgBody & "#variables.qGetUserPrograms.Contract_Title#" & "	|	" />
				<cfset variables.msgBody = variables.msgBody & "#dollarFormat(ProgramSpend)#" />

				<cfset variables.msgBody = variables.msgBody & "#Chr(13)##Chr(10)#"/>

			</cfloop>

			<!--- Build Email Footer --->
			<cfset variables.msgFooter = variables.msgFooter & "--- " />
			<cfset variables.msgFooter = variables.msgFooter & "#variables.qGetMaxSentId.maxSentId#" & "|" & "#variables.qGetUserPrograms.User_ID#" />
			<cfset variables.msgFooter = variables.msgFooter & " ---" & "#Chr(13)##Chr(10)#" />
			<cfset variables.msgFooter = variables.msgFooter & "#Chr(13)##Chr(10)#" & "#application.returned_customer_setting.Company_Name#" & " -- " & "Contract Management services provided by #Application.CompanyNameFull#" />

			<!--- Email Functionality Begins Here --->
			<CF_EMAILWRAPPER
				to="#variables.qGetUserPrograms.User_Email#"
				from="#variables.autoApproveEmail#"
				subject="BLACKSMITH PROGRAM APPROVAL REQUEST"
				type="text"
				messagetype="1"
				generatedby="1"
				apparea="1"
				logMessage="1">

					#variables.msgHeader#   	#Chr(13)##Chr(10)#
					#variables.msgBody#			#Chr(13)##Chr(10)#
					#variables.msgFooter#		#Chr(13)##Chr(10)#

			</CF_EMAILWRAPPER>
			<!--- Email Functionality Ends Here --->

			<!--- Set the email as sent in the Email_Approval_User_Programs table  --->
			<cfset variables.qSetEmailSent = "" />
			<cfquery name="variables.qSetEmailSent" datasource="#application.dataSource#">
				UPDATE	Email_Approval_User_Programs
				SET		Email_Sent = <cfqueryparam value="1" cfsqltype="cf_sql_bit" />,
						Email_Sent_Date = getDate()
				WHERE	Sent_ID = <cfqueryparam value="#variables.qGetMaxSentId.maxSentId#" cfsqltype="cf_sql_integer" />
			</cfquery>

		</cfif> <!--- end cfif: variables.qUserList.Remote_Approval_Option --->

	</cfoutput> <!--- end cfoutput: query="variables.qUserList" --->


	<!--- Send job success email to the user in settings panel --->
	<!--- Dev Note: Kal; D43870: Run Remote Approval Send on demand for users with Single option --->
	<cfif not(url.programId) >
		<cfoutput>
			<CF_EMAILWRAPPER
				to="#Application.oApplicationAppSettingsManager.getApplicationAppSettings().emailOutJobSuccess#"
				from="#variables.autoApproveEmail#"
				subject="Email Approval Outbound Job Success"
				type="html"
				messagetype="1"
				generatedby="1"
				apparea="1"
				logMessage="1">

					#variables.qUserList.recordCount# - Email requests sent for Approval

			</CF_EMAILWRAPPER>
		</cfoutput>
	</cfif>

</cfif>