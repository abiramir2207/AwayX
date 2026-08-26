<!------inc_login_process_redirect.cfm----->
<CFPARAM NAME="FORM.token" 	DEFAULT="">
<CFPARAM NAME="URL.programid" DEFAULT="">

<CFSET FORM.token = Trim(FORM.token)>
<!---- Token Exist ----->

<CFSET First_Loken_Len = 0>
<CFSET Second_Loken_Len = 0>

<CFIF Len(FORM.token) GT 0>
	<CFOUTPUT>
	<!------ Token length  ------->
	<CFSET Token_String = FORM.token>

	<CFSET Token_String = Left(Token_String, len(Token_String) - 5)>
	<CFSET Token_String = Right(Token_String, len(Token_String) - 5)>

	<CFSET first_Token_Start = FindNoCase("_", Token_String)>
	<CFIF first_Token_Start GT 1>
		<CFSET First_Loken_Len = Left(Token_String, first_Token_Start-1)>
		<CFIF IsNumeric(First_Loken_Len)>
			<CFSET First_Loken_Len = Int(First_Loken_Len)>
		<CFELSE>
			<CFSET First_Loken_Len = 0>
		</CFIF>
		<CFSET Token_String = Right(Token_String, Len(Token_String) - first_Token_Start)>
	</CFIF>
	<CFSET second_Token_Start = FindNoCase("_", Token_String)>
	<CFIF second_Token_Start GT 1>
		<CFSET Second_Loken_Len = Right(Token_String, Len(Token_String) - second_Token_Start)>
		<CFIF IsNumeric(Second_Loken_Len)>
			<CFSET Second_Loken_Len = Int(Second_Loken_Len)>
		<CFELSE>
			<CFSET Second_Loken_Len = 0>
		</CFIF>
		<CFSET Token_String = Left(Token_String, second_Token_Start - 1)>
	</CFIF>
	<CFIF First_Loken_Len GT 0 AND Second_Loken_Len GT 0>
		<CFSET Part_1 		= Left(Token_String, First_Loken_Len)>
		<CFSET Token_String = Right(Token_String, Len(Token_String) - First_Loken_Len)>
		<CFSET Part_2 		= Left(Token_String, Second_Loken_Len)>
		<CFSET Token_String = Right(Token_String, Len(Token_String) - Second_Loken_Len)>
		<CFSET Part_3 		= Token_String>

		<CF_CRYP type="de" key="#Part_2#" string="#Part_1#">
		<CFSET Val_Part_1 = cryp.value>

		<CF_CRYP type="de" key="#Part_2#" string="#Part_3#">
		<CFSET Val_Part_3 = cryp.value>

		<CFPARAM name="form.businessSegmentsOn" default="0">

		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif businessSegManager.isEnabled()>
			<cfset form.businessSegmentsOn = 1 />
		</cfif>

		<CFSWITCH EXPRESSION="#Val_Part_1#">
			<CFCASE VALUE="Invoice_Report">
				<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
					window.location.href = '#application.HTTPVar##CGI.HTTP_HOST##Val_Part_3#';
				</SCRIPT>
				<CFABORT>
			</CFCASE>
			<CFCASE VALUE="Billback">
				<CFINCLUDE TEMPLATE="/billbacks/Billback_Access_Permission.cfm">
				<CFIF ListFindNoCase(BillbackIDs, "'#Val_Part_3#'", ",")>
					<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
						window.location.href = '#application.HTTPVar##CGI.HTTP_HOST#/Billbacks/capture/index.cfm?BBID=#Val_Part_3#';
					</SCRIPT>
					<CFABORT>
				</CFIF>
			</CFCASE>
			<CFCASE VALUE="BillbackInbox">
				<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
					window.location.href = '#application.HTTPVar##CGI.HTTP_HOST#/Route/Inbox.cfm';
				</SCRIPT>
				<CFABORT>
			</CFCASE>
			<CFCASE VALUE="Program">
				<CFINCLUDE TEMPLATE="/scorecard/access_permissions.cfm">
				<CFQUERY NAME="Check_Contract_Access" DATASOURCE="#application.datasource#">
					SELECT	*
					FROM	Contract_Main
					WHERE
							Contract_Main.Contract_Main_ID = #Val_Part_3#
							AND
							(
								Creating_User_Position_ID = '#getUserPosition.User_Positions_ID#'
								<CFIF GP_Position_List_From_My_Position_Down NEQ "">
								OR
								(
									Contract_Main.Contract_Status_Type_IDX >= 2
									AND
									Creating_User_Position_ID IN (#GP_Position_List_From_My_Position_Down#)
								)
								</CFIF>
								OR
								(
									Contract_Main.Contract_Status_Type_IDX >= 4
									AND
									(
										1=2
										<CFIF listlen(GP_Position_List_From_My_Position_Down)GT 0>
										OR dbo.Contract_Main.Contract_Main_ID IN
										(
										#PreserveSingleQuotes(ProgramsWithDistUnderMe)#
										)
										</CFIF>
										<CFIF listlen(GP_Position_List_From_My_Position_Down)GT 0>
										OR dbo.Contract_Main.Contract_Main_ID IN
										(
										#PreserveSingleQuotes(ProgramsWithBrokerUnderMe)#
										)
										</CFIF>
									)
								)
							)
				</CFQUERY>
				<CFIF Check_Contract_Access.recordCount GT 0>
					<!--- <cfinvoke component="components.general.General_Functions" method="GenerateKey" returnVariable="key"> --->
					<cfset key = request.app_general_functions.GenerateKey() />

					<CF_CRYP type="en" key="#request.key#" string="#Check_Contract_Access.contract_main_id#">
					<CFSET CID = cryp.value>
					<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
						window.location.href = '#application.HTTPVar##CGI.HTTP_HOST#/common_files/contracts/contract_edit_menu.cfm?CID=#CID#';
					</SCRIPT>
					<CFABORT>
				</CFIF>
			</CFCASE>
		</CFSWITCH>
	</CFIF>
	</CFOUTPUT>
</CFIF>
<!--- 70720L LOL-SFDC link to a program --->
<cfoutput>
	<cfif Len(url.programid) GT 0>
		<cfinclude template="/scorecard/access_permissions.cfm">
		<cfinclude template="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">
		<cfquery name="Check_Contract_Access" datasource="#application.datasource#">
			SELECT	*
			FROM	Contract_Main
			WHERE   Contract_Main.contract_number = '#url.programid#'
					AND ( Creating_User_Position_ID IN (#UserPositionList#)
							<cfif GP_Position_List_From_My_Position_Down NEQ "">
							OR
							(
								Contract_Main.Contract_Status_Type_IDX >= 2
								AND
								Creating_User_Position_ID IN (#GP_Position_List_From_My_Position_Down#)
							)
							</cfif>
							OR
							(
								Contract_Main.Contract_Status_Type_IDX >= 4
								AND
								(
									1=2
									<cfif listlen(GP_Position_List_From_My_Position_Down)GT 0>
									OR dbo.Contract_Main.Contract_Main_ID IN
									(
									#PreserveSingleQuotes(ProgramsWithDistUnderMe)#
									)
									</cfif>
									<cfif listlen(GP_Position_List_From_My_Position_Down)GT 0>
									OR dbo.Contract_Main.Contract_Main_ID IN
									(
									#PreserveSingleQuotes(ProgramsWithBrokerUnderMe)#
									)
									</cfif>
								)
							)
						)
		</cfquery>
		<cfif Check_Contract_Access.recordCount GT 0>
			<cfinvoke component="components.general.General_Functions" method="GenerateKey" returnVariable="key">
			<CF_CRYP type="en" key="#key#" string="#Check_Contract_Access.contract_main_id#">
			<CFSET CID = cryp.value>
			<script language="javascript" type="text/javascript">
				window.location.href = '#HTTPVariable##CGI.HTTP_HOST#/common_files/contracts/contract_edit_menu.cfm?CID=#CID#';
			</script>
			<cfabort>
		<cfelse>
			<cfset error="<div class='alert' align='center'><br/><br/>Your account does not have access to the program #url.programid#.</div>">
			<cfoutput>#error#</cfoutput>
			<cfabort>
		</cfif>
	</cfif>
</cfoutput>