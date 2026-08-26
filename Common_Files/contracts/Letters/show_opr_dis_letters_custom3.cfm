<cfsilent>
	<!--- These parameters are required for this template to process correctly --->
	<cfparam name="url.bAll" type="boolean" default="0">
	<cfparam name="form.letter_id" type="numeric" default="0">
	<cfparam name="url.msg" type="string" default="">
	<cfparam name="url.CID" default="">
	<cfparam name="emailaddresslist" type="string" default="">
	<cfparam name="variables.bLettersAvailable" type="boolean" default="0">
	<cfparam name="url.print" type="boolean" default="0">
	<cfparam name="url.delete" type="boolean" default="0">
	<cfparam name="url.LID" type="numeric" default="0">
	<cfparam name="url.Contract_Main_ID"  default="#url.CID#">
	<cfparam name="url.generate" type="numeric" default="0">

	<cfif url.delete>
		<cfif url.bAll>
			<cfwindow center="true" closable="false" draggable="true" height=70 initshow="true" modal="true" name="pdfDeletion"
								resizable="false" source="delete_letter.cfm?CID=#url.CID#&bAll=1" title="ALL PDF Letters for Program:#url.CID# Are NOW Deleted!" width=340/>
		<cfelse>
			<cfwindow center="true" closable="false" draggable="true" height=70 initshow="true" modal="true" name="pdfDeletion"
								resizable="false" source="delete_letter.cfm?LID=#url.LID#&CID=#url.CID#&bAll=0" title="PDF Letter #url.LID# Is NOW Deleted!" width=340/>
		</cfif>
		<cfabort>
	</cfif>

	<!--- MVC V11 Edit [begin] --->
	<cfscript>
		application.oController.getObject("mvc.Models.LetterManager");
	</cfscript>
	<!--- MVC V11 Edit [end] --->

    <cfif !isDefined("request.getfieldsettings")>
        <cfset templateManager  = CreateObject("component", "components.programs.template.TemplateManager").init()>
        <cfset request.getFieldSettings = templateManager.getProgramTemplate(url.CID)>
    </cfif>
</cfsilent>

<cfparam name="request.html_started" default="0">
<cfif !request.html_started>
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    <html>
        <head>
            <title>
                Letters
            </title>
        </head>
        <body bgcolor="White" text="Black" link="Blue" vlink="Blue" alink="Red" leftmargin="0" topmargin="0" onload="popupInit()">
</cfif>

        <cf_include files="/script/javascript/string_functions.js, /script/javascript/string_validations.js, /Script/javascript/dhtml.js">
		<style>
			TABLE.Maintable TD {
				border-bottom: solid #93BEE2 1px;
				font-size: 11px;
			}
			#header {
				font-size: 12px;
			}
			.cLinks{font-size:13px;}
            td.header {
                padding-left: 10px;
            }
            table.maintable {
                margin-bottom: 10px;
            }
			table.maintable tr {
                height: 26px;
			}
            img.rfp {
                margin-right: 10px;
            }
		</style>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<cfinclude template="/includes/top_header.cfm">

		<cf_messagewindow>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<cfif len(trim(URL.CID))>
			<cfset CSL_Contract_Main_ID = URL.CID>
		</cfif>
		<cfset CSL_CallingPageCode = "letters">

		<!--- IF we got nuttin... [begin] (1 of 2) --->
		<!--- <cfquery name="variables.qAllLtr" datasource="#application.datasource#">
			SELECT  COUNT(Program_Letters_ID) as netCount
			FROM    Program_Letters
			WHERE program_id = '#URL.CID#'
        </cfquery> --->

		<cfquery name="qLetters" datasource="#application.datasource#">
            SELECT
                Program_letters.Program_Letters_id,
                Program_letters.Program_Id,
                Program_letters.Letter_Type,
                Program_letters.Letter_Name,
                Program_letters.Letter_Path,
                Program_letters.Operator_Name,
                Program_letters.Distributor_Name,
                Program_letters.System_Generated,
                Program_letters.Created_Date,
                Program_letters.Created_By,
                Program_letters.Distributor_Id,
                Program_letters.Claim_Rates_Date,
                _users.Name_first + ' ' + _users.Name_last As User_name
            FROM
                Program_letters
                LEFT JOIN _users ON _users.User_id = Program_letters.Created_by
            WHERE
                Program_ID = '#URL.CID#'
                AND Program_letters.Deleted = 0
                ORDER BY Created_date DESC
        </cfquery>

		<cfquery name="getProgramDetails" datasource="#application.datasource#">
            SELECT Product_Group_Members_File_Path,Program_Control_Panel_Options.Distributor_Generate_Excel_File_Product_Group_Members,Operator_Generate_Excel_File_Product_Group_Members
            FROM Contract_Main_Aux_Data
            INNER JOIN Contract_Main
            ON Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
            INNER JOIN Program_Control_Panel_Options
            ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
            WHERE Contract_Main.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.CID#">
        </cfquery>

		<cfif getProgramDetails.Product_Group_Members_File_Path neq "">
			<!--- Get the Excel file name --->
			<cfset variables.excel_file_name  = ListLast(getProgramDetails.Product_Group_Members_File_Path,"\")>
		</cfif>

        <!--- nada... --->
		<cfif Get_Profile_Settings.Generate_Program_letters AND NOT qLetters.recordCount>
			<cf_cryp type="en" string="#URL.CID#" key="#request.key#" return="abstr">
			<cfset EncryptedCID = abstr.value>
			<!--- redirect --->
			<cflocation url="/Common_Files/contracts/contract_letters.cfm?CID=#EncryptedCID#" addtoken="yes">
			<cfabort>
		</cfif>
		<!--- IF we got nuttin... [end] --->

		<div id="Layer1" style="position:relative; z-index:1; padding:5px; margin:5px;">


		<cfset FORM.Contract_Main_ID = CSL_Contract_Main_ID>

		<!--- create some temporary objects... RBL --->
		<cfset variables.oProgramData = createObject("component", "components.programs.program")/>
		<cfset variables.oUserData = createObject("component", "components.user.usermanager")/>
		<!--- retreive the query data... RBL --->
		<cfset variables.qProgramInfo = variables.oProgramData.getProgramInfo(CSL_Contract_Main_ID)>

		<cfset variables.qUserInfo = variables.oUserData.getUser(variables.qProgramInfo.responsible_user_id[1])>

		<cfset variables.authorRSPFirstName = trim(variables.qUserInfo.name_first[1])>
		<cfset variables.authorRSPLastName = trim(variables.qUserInfo.name_last[1])>
        <cfset variables.authorRSPEmail = trim(variables.qUserInfo.user_email[1])>

		<cfquery name="variables.qGetAuthorID" datasource="#application.datasource#">
			SELECT User_ID
			FROM dbo._Users
			WHERE Name_First = '#variables.authorRSPFirstName#'
			AND Name_Last = '#variables.authorRSPLastName#'
		</cfquery>
		<cfset variables.authorRSPID = variables.qGetAuthorID.User_ID/>

		<cfoutput>

			<form action="email_or_print.cfm" method="post" name="LetterForm">

				<!--- ==========================================================
				===================== Operator [begin] =========================
				=========================================================== --->
				<cfinvoke component="#application.oLetterManager#"
									method="getLetters"
									program_id="#CSL_Contract_Main_ID#"
									letter_type="1"
									order_by_clause="program_letters.operator_name,created_date DESC"
									returnvariable="variables.qGetOprLetters">

				<cfif variables.qGetOprLetters.recordCount>

					<!--- D17619 [begin] RBL 12/01/08 style="margin-left:30px;" --->
					<font color="##ff0000">
						<i>
							#url.msg#
						</i>
					</font>
					<!--- D17619 [end] RBL 12/01/08 --->
					<!--- width="800" --->
					<table width="750" class="maintable" border="0" cellpadding="0" cellspacing="0" style="margin-left:0px;">
                        <tr class="header">
							<td class="header" colspan="6" style="font-size:14px;" bgcolor="##C6FFC6">
								<b>
									#application.returned_customer_setting.operator_label_singular#
									Section
								</b>
							</td>
						</tr>
						<tr>
							<td width="50" style="font-size: 12px;">
								<input name="opr_check_all" type="checkbox" onclick="selectall('O');">
								<span id="checkopr">
								</span>
							</td>
							<td width="80" wrap style="font-size: 12px; font-weight:bold">
								Letters
							</td>
							<td width="120" style="font-size: 12px; font-weight:bold" wrap>
								#application.returned_customer_setting.operator_label_singular#
								Name
							</td>
							<td width="80" style="font-size: 12px; font-weight:bold">
								Date
							</td>
							<td width="100" nowrap style="font-size: 12px; font-weight:bold">
								Created By
							</td>
							<td width="120" style="font-size: 12px; font-weight:bold" nowrap>
								Email Addresses
							</td>
						</tr>

						<cfset variables.bLettersAvailable = 1>
						<cfset variables.bNoDistributors = 0>
						<cfloop query="variables.qGetOprLetters">

							<!--- [begin] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [begin] --->
							<cfif application.oLetterManager.letterExistsInDBwithXMLandAsFile(variables.qGetOprLetters.program_letters_id)>
								<cfset current_opr_letter_name_pdf = trim(variables.qGetOprLetters.letter_name) & '.pdf'>
								<cfset current_opr_letter_name_pdf_tip = lCase(replace(current_opr_letter_name_pdf, '_', ' ', 'all'))>
								<cfset current_opr_absolute_path_pdf = "#Application.Doc_Mapping#/data_files/created/contracts/letters/output/operators/#CSL_Contract_Main_ID#/#current_opr_letter_name_pdf#">

								<cfset current_opr_absolute_path = application.doc_path & '\data_files\created\contracts\letters\output\operators\' & CSL_Contract_Main_ID & '\' & current_opr_letter_name_pdf>

								<cfif fileExists(current_opr_absolute_path)>
									<cfpdf action="getinfo" name="stPDFInfo" source="#current_opr_absolute_path#" password="#CSL_Contract_Main_ID#">
									<tr>
										<td width="50">
											<span id="error_oprcheckbox">
											</span>
											<span id="checkAllOprLetters">
												<input name="letter_id" type="checkbox" value="#program_letters_id#">
											</span>
										</td>
										<td width="80">
											<!--- <a href="#current_opr_absolute_path_htm#" target="htm" style="cursor:pointer;" onMouseOver="initTheTooltip('#current_opr_letter_name_htm_tip#')" onMouseOut="popOut()"><img src="images/icon_TXT.gif" border="0"></a>   --->
												<a href="/GetDocument.cfm?FilePath=data_files/created/contracts/letters/output/operators/#CSL_Contract_Main_ID#/#urlEncodedFormat( current_opr_letter_name_pdf )#" style="cursor:pointer;" onMouseOver="initTheTooltip('VIEW and/or PRINT Letter #variables.qGetOprLetters.program_letters_id# #current_opr_letter_name_pdf_tip# [#stPDFInfo.TotalPages# Pages]')" onMouseOut="popOut()">
													<img src="images/icon_PDF.gif" border="0">
												</a>
												<cfif getProgramDetails.Operator_Generate_Excel_File_Product_Group_Members eq 1>
													<cfif getProgramDetails.Product_Group_Members_File_Path neq "" AND FileExists("#getProgramDetails.Product_Group_Members_File_Path#")>
													<a href="/GetDocument.cfm?FilePath=Temp_Files/Program/letters/#CSL_Contract_Main_ID#/#urlEncodedFormat( variables.excel_file_name )#" style="cursor:pointer;" onMouseOver="initTheTooltip('VIEW Product Group Members')" onMouseOut="popOut()">
													<img src="/images/excel.png" width="20" height="20">
													</cfif>
												</cfif>
											<!---  <a href="#current_opr_absolute_path_xml#" target="xml" style="cursor:pointer;" onMouseOver="initTheTooltip('#current_opr_letter_name_xml_tip#')" onMouseOut="popOut()"><img src="images/icon_XML.gif" border="0"></a> --->
										</td>
										<td width="120">
											#operator_name#
										</td>
										<td width="80">
											#dateformat(variables.qGetOprLetters.created_date, "mm/dd/yyyy")#
										</td>
										<td width="100" nowrap>
											#user_name#
										</td>
										<td width="120">
											<span id="checkAllOprEmail">
												<input type="text" name="email_address_#program_letters_id#" size="30" value="#variables.authorRSPEmail#">
											</span>
											<span id="error_oprAddress">
											</span>
										</td>
									</tr>
								</cfif>

								<input type="hidden" name="letter_path_#program_letters_id#" value="#variables.qGetOprLetters.letter_path#">
								<input type="hidden" name="Include_File_path" value="/data_files/created/contracts/letters/output/operators/#CSL_Contract_Main_ID#/#current_opr_letter_name_pdf#">

							<cfelse>

								<cfscript>
									application.oLetterManager.deletePDFLetterInDBandFile(variables.qGetOprLetters.program_letters_id);
								</cfscript>

							</cfif>
							<!--- [end] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [end] --->
						</cfloop>
					</table>
				</cfif>
				<!--- ==========================================================
				===================== Operator [end] ===========================
				=========================================================== --->

				<!--- ==========================================================
				===================== Distributor [begin] ======================
				=========================================================== --->
				<cfinvoke component="#application.oLetterManager#"
									method="getLetters"
									program_id="#CSL_Contract_Main_ID#"
									letter_type="2"
									order_by_clause="program_letters.Distributor_Name,created_date DESC"
									returnvariable="variables.qGetDisLetters">

				<!--- D16774 8/14/08 [end] --->
				<cfif variables.qGetDisLetters.recordCount>

					<!---   When there are only distributor letters and not operator letters, then we still need to show message: 'x letters successfully emailed' when the user emails the letters.
									When there are both (distributor and operators), then this message at the top of the page (before the operator section) is valid for both on emailing.
					--->
					<cfif variables.qGetOprLetters.recordCount eq 0>
						<font color="##ff0000">
							<i>
								#url.msg#
							</i>
						</font>
					</cfif>

					<cfset getdistributoremail = application.oLetterManager.getdistributoremail(CSL_Contract_Main_ID)>
					<!--- D16774 8/14/08 [end] --->
					<table width="750" class="maintable" border="0" cellpadding="0" cellspacing="0" style="margin-left:0px;">
                        <tr class="header">
							<td class="header" colspan="6" style="font-size: 14px;" bgcolor="##C6FFC6">
								<b>
									#application.returned_customer_setting.distributor_label_singular#
									Section
								</b>
							</td>
						</tr>
						<tr>
							<td width="50" style="font-size: 12px;">
								<input name="dis_check_all" type="checkbox" onclick="selectall('D');">
								<span id="checkdis">
								</span>
							</td>
							<td width="80" style="font-size: 12px; font-weight:bold">
								Letters
							</td>
							<td width="120" style="font-size: 12px; font-weight:bold" wrap>
								#application.returned_customer_setting.distributor_label_singular#
								Name
							</td>
							<td width="80" style="font-size: 12px; font-weight:bold">
								Date
							</td>
							<td width="100" nowrap style="font-size: 12px; font-weight:bold">
								Created By
							</td>
							<td width="120" style="font-size: 12px; font-weight:bold" nowrap>
								Email Addresses
							</td>
						</tr>
						<cfset variables.bLettersAvailable = 1>

						<cfloop query="variables.qGetDisLetters">

							<!--- [begin] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [begin] --->
							<cfif application.oLetterManager.letterExistsInDBwithXMLandAsFile(variables.qGetDisLetters.program_letters_id)>
								<cfset current_dis_letter_name_pdf = trim(variables.qGetDisLetters.letter_name) & '.pdf'>
								<cfset current_dis_letter_name_pdf_tip = lCase(replace(current_dis_letter_name_pdf, '_', ' ', 'all'))>
								<cfset current_dis_absolute_path_pdf = "#Application.Doc_Mapping#/data_files/created/contracts/letters/output/distributors/#CSL_Contract_Main_ID#/#current_dis_letter_name_pdf#">
								<cfset current_dis_absolute_path = application.doc_path & '\data_files\created\contracts\letters\output\distributors\' & CSL_Contract_Main_ID & '\' & current_dis_letter_name_pdf>

								<cfif fileExists(current_dis_absolute_path)>

									<cfpdf action="getinfo" name="stPDFInfo" source="#current_dis_absolute_path#" password="#CSL_Contract_Main_ID#">

									<cfif len(trim(variables.qGetDisLetters.distributor_id))>
										<cfset useLakebaseForgetdisemailaddress = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getdistributoremail")>
<cfif useLakebaseForgetdisemailaddress>
	<cftry>
		<cfset getdisemailaddress = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getdistributoremail", {
				"bsa_foodservice_customers_id" = "eq.#variables.qGetDisLetters.distributor_id#",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetdisemailaddress = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetdisemailaddress>
<cfquery name="getdisemailaddress" dbtype="query">
											select distinct user_email from
											getdistributoremail
											where bsa_foodservice_customers_id = '#variables.qGetDisLetters.distributor_id#'
										</cfquery>
</cfif>
										<cfset emailaddresslist = ValueList(getdisemailaddress.user_email)>
									<cfelse>
										<cfset emailaddresslist = "">
									</cfif>
									<tr id="TR_Dis_Letters">
										<td width="50">
											<span id="error_discheckbox">
											</span>
											<span id="checkAllDisLetters">
												<input name="letter_id" type="checkbox" value="#program_letters_id#">
											</span>
										</td>
										<td width="80">
											<!--- <a href="#current_dis_absolute_path_htm#" target="htm" style="cursor:pointer;" onMouseOver="initTheTooltip('#current_dis_letter_name_htm_tip#')" onMouseOut="popOut()"><img src="images/icon_TXT.gif" border="0"></a>  --->
												<a href="/GetDocument.cfm?FilePath=data_files/created/contracts/letters/output/distributors/#CSL_Contract_Main_ID#/#urlEncodedFormat( current_dis_letter_name_pdf )#" style="cursor:pointer;" onMouseOver="initTheTooltip('VIEW and/or PRINT Letter #variables.qGetDisLetters.program_letters_id# #current_dis_letter_name_pdf_tip#  [#stPDFInfo.TotalPages#] Pages')" onMouseOut="popOut()">
													<img src="images/icon_PDF.gif" border="0">
												</a>
												<cfif getProgramDetails.Distributor_Generate_Excel_File_Product_Group_Members eq 1>
													<cfif getProgramDetails.Product_Group_Members_File_Path neq "" AND FileExists("#getProgramDetails.Product_Group_Members_File_Path#")>
													<a href="/GetDocument.cfm?FilePath=Temp_Files/Program/letters/#CSL_Contract_Main_ID#/#urlEncodedFormat( variables.excel_file_name )#" style="cursor:pointer;" onMouseOver="initTheTooltip('VIEW Product Group Members')" onMouseOut="popOut()">
													<img src="/images/excel.png" width="20" height="20">
													</cfif>
												</cfif>
											<!---  <a href="#current_dis_absolute_path_xml#" target="xml" style="cursor:pointer;" onMouseOver="initTheTooltip('#current_dis_letter_name_xml_tip#')" onMouseOut="popOut()"><img src="images/icon_XML.gif" border="0"></a>  --->
										</td>
										<td width="120">
											#Distributor_name#
										</td>
										<td width="80">
											#dateformat(variables.qGetDisLetters.created_date, "mm/dd/yyyy")#
										</td>
										<td width="100" nowrap>
											#user_name#
										</td>
										<td width="120">
											<span id="checkAllDisEmail">
												<!--- <input type="text" name="email_address_#program_letters_id#" size="30" value="#emailaddresslist#"> --->
												<input type="text" name="email_address_#program_letters_id#" size="30" value="#variables.authorRSPEmail#">
											</span>
											<span id="error_disAddress">
											</span>
										</td>
									</tr>
								</cfif>

								<input type="hidden" name="letter_path_#program_letters_id#" value="#variables.qGetDisLetters.letter_path#">
								<input type="hidden" name="Include_File_path" value="/data_files/created/contracts/letters/output/distributors/#CSL_Contract_Main_ID#/#current_dis_letter_name_pdf#">

							<cfelse>

								<cfscript>
									application.oLetterManager.deletePDFLetterInDBandFile(variables.qGetDisLetters.program_letters_id);
								</cfscript>

							</cfif>
							<!--- [end] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [end] --->
						</cfloop>
					</table>
				</cfif>
				<!--- ==========================================================
				===================== Distributor [end] ========================
				=========================================================== --->

				<cfif url.print>

					<cfwindow center="true" closable="false" draggable="true" height=400 initshow="true" modal="true" name="pdfSmallWin"
										resizable="false" title="Combined PDF Print Instructions" width=400>
						<ol>
							<li>
								Click PDF thumbnail below to open All requested PDFs in window.
							</li>
							<li>
								Once PDFs are open, click printer icon to print All requested PDFs as one document to selected printer in selected quality.
							</li>
							<li>
								This small window will close upon opening the larger window containing All requested and combined PDFs.
							</li>
						</ol>

                        <cfset pdf_relative_path = application.doc_path & "/temp_files/program/combined#CSL_Contract_Main_ID#PDFPrint.pdf">

						<div align="center" onclick="javascript:ColdFusion.Window.hide('pdfSmallWin')">
							<a href="/GetDocument.cfm?FilePath=#pdf_relative_path#" target="pdfLargeWin">
								<img src="thumbnails/tn_page_1.png" border="0" align="absmiddle" title="Click to Print All Selected PDF Letters"/>
							</a>
						</div>
						<div align="right" onclick="javascript:ColdFusion.Window.hide('pdfSmallWin')">
							<font size="1" color="Red">[</font>&nbsp;
							<font size="1" color="Blue"><a href="javascript:history.back()">back</a></font>&nbsp;
							<font size="1" color="Red">]</font>
						</div>
					</cfwindow>
				</cfif>

                <cfquery name="qExcelExports" dbtype="query">
                    SELECT *
                    FROM qLetters
                    WHERE Letter_Type = 11 OR Letter_Type = 12 OR Letter_Type = 13
                </cfquery>

                <cfset excel_exports_count = qExcelExports.recordCount>

                <!--- show excel export when at least one excel export is selected in program template  --->
                <cfif excel_exports_count
                        and ( request.getfieldsettings.Non_Blended_Delivered_Freight_Matrix_Excel_Export
                                or request.getfieldsettings.Blended_Delivered_Freight_Matrix_Excel_Export
                                or request.getfieldsettings.Escalator_Excel_Export )>

                    <table width="750" class="maintable" border="0" cellpadding="0" cellspacing="0" style="margin-left:0px;">
                        <tr class="header"  bgcolor="##C6FFC6">
                            <td width="50" style="font-size: 12px;">
                                <input name="export_check_all" type="checkbox" class="toggle_excel_exports">
                                <span id="checkdis"></span>
                            </td>
                            <td width="200" style="font-size: 12px; font-weight:bold">
                                <b>Excel Exports</b>
                            </td>
                            <td width="80" style="font-size: 12px; font-weight:bold">
                                Date
                            </td>
                            <td width="100" nowrap style="font-size: 12px; font-weight:bold">
                                Created By
                            </td>
                            <td width="120" style="font-size: 12px; font-weight:bold" nowrap>
                                Email Addresses
                            </td>
                        </tr>

                        <cfset render_exports( { letter_type: 11
                                                ,setting: request.getfieldsettings.Non_Blended_Delivered_Freight_Matrix_Excel_Export
                                                ,label: "Non Blended Delivered Freight Matrix" } )>

                        <cfset render_exports( { letter_type: 12
                                                ,setting: request.getfieldsettings.Blended_Delivered_Freight_Matrix_Excel_Export
                                                ,label: "Blended Delivered Freight Matrix" } )>

                        <cfset render_exports( { letter_type: 13
                                                ,setting: request.getfieldsettings.Escalator_Excel_Export
                                                ,label: "Escalator" } )>

                        <cffunction name="render_exports" output="true">
                            <cfargument name="profile" required="true">

                            <cfquery name="local.qExcelExports" dbtype="query">
                                SELECT * FROM qLetters WHERE Letter_Type = #arguments.profile.letter_type#
                            </cfquery>

                            <!--- export file exists and program template setting for export is enabled --->
                            <cfif local.qExcelExports.recordCount and arguments.profile.setting>
                                <tr>
                                    <td>
                                        <input type="checkbox" class="rfp" name="letter_id" value="#local.qExcelExports.program_letters_id#">
                                        <input type="hidden" name="letter_path_#local.qExcelExports.program_letters_id#" value="#local.qExcelExports.letter_path#">
                                        <input type="hidden" name="Include_File_path" value="#local.qExcelExports.letter_path#\#local.qExcelExports.letter_name#">
                                    </td>
                                    <td>
                                        <a href="/getDocument.cfm?filePath=#local.qExcelExports.letter_path#/#urlencodedformat( local.qExcelExports.letter_name )#"><img src="/images/excel-icon.png" class="rfp"> #arguments.profile.label# </a>
                                    </td>
                                    <td> #dateFormat(local.qExcelExports.Created_Date, 'mm/dd/yyyy')# </td>
                                    <td> #local.qExcelExports.user_name# </td>
                                    <td>
                                        <input type="text" name="email_address_#local.qExcelExports.program_letters_id#" class="rfp_email" size="30" value="#variables.authorRSPEmail#">
                                    </td>
                                </tr>
                            </cfif>
                        </cffunction>

                    </table>
                </cfif>

				<cfif excel_exports_count or variables.bLettersAvailable>
					<table style="margin-left:30px;">
                        <tr>
                            <cfset letters_label = "program letters">
                            <!--- show excel export when at least one excel export is selected in program template  --->
                            <cfif request.getfieldsettings.Non_Blended_Delivered_Freight_Matrix_Excel_Export neq 0
                                    or request.getfieldsettings.Blended_Delivered_Freight_Matrix_Excel_Export neq 0
                                    or request.getfieldsettings.Escalator_Excel_Export neq 0>
                                <cfset letters_label = "program letters / excel exports">
                            </cfif>

							<td height="20" align="left" valign="middle">
								<!--- Let's email 'em... --->
								<a id="email" title="EMAIL selected letter(s) to listed email addresses" onClick="submitRequest('email_letters');" class="cLinks">#application.util.string.linkFormat("email #letters_label#")#</a>
							</td>

							<td height="20" align="left" valign="middle">&nbsp
							</td>

							<td height="20" align="left" valign="middle">
								<!--- Let's print 'em... --->
								<a id="print" title="PRINT selected letter(s)" onClick="submitRequest('print_letters');" class="cLinks">#application.util.string.linkFormat("print letters")#</a>
							</td>
						</tr>
					</table>
					<!--- WHY do we have so many aliases for this one value? RBL --->
					<input type="hidden" name="contract_main_id" value="#CSL_Contract_Main_ID#">
					<input type="hidden" name="requestType">
				</cfif>
			</form>

		<cfif variables.qGetDisLetters.recordCount EQ 0 AND variables.qGetOprLetters.recordCount EQ 0>
			<div align="center" style="color:red; font-size:12px;">
				There are no letters generated for the program.
			</div>
		</cfif>
		</cfoutput>

		<!--- Tech Note: Much of the following js may no longer be needed. Have not thoroughly investigated... 2/14/2008 --->
		<script>
			function submitRequest(request)
			{
				LetterForm.requestType.value = request;
				LetterForm.submit();
			}

			var ErrorCount = 0;
			function submitForm(thisForm) {
				var oprbox, opremailbox, errorspan;
				var oprcheckcomplete = 0;
				var ErrorCount = 0
				var discheckcomplete = 0;
				var oprcheckemail = 0;
				var discheckemail = 0;

			    if (document.getElementById("checkAllOprLetters") != null) {
                    if (window.checkAllOprLetters.length) {
                        for (var x = 0; x < window.checkAllOprLetters.length; x++) {
                            oprbox = getFirstChild(window.checkAllOprLetters[x]);
                            opremailbox = getFirstChild(window.checkAllOprEmail[x]);
                            oprerrorspan = window.error_oprAddress[x];

                            if (oprbox.checked == true) {
                                oprcheckcomplete = 1;
                                clearQueue(document.all.checkopr);

                                if (opremailbox.value != "" && opremailbox.value != "NULL") {
                                    var ValidEmail1 = replaceInvalidEmailAndValidate(opremailbox.value);

                                    if (ValidEmail1 != true) {
                                            ErrorCount++;
                                            queueMessage("Invalid email Address", oprerrorspan);
                                        }
                                        else {
                                            oprcheckemail = 1;
                                            clearQueue(oprerrorspan);
                                        }
                                    }
                                    else {
                                        ErrorCount++;
                                        queueMessage("You must enter an email address", oprerrorspan);
                                    }
                            }
                        }
                    }
                    else {
                            oprbox = getFirstChild(window.checkAllOprLetters);
                            opremailbox = getFirstChild(window.checkAllOprEmail);
                            oprerrorspan = window.error_oprAddress;

                			if (oprbox.checked == true) {
                                oprcheckcomplete = 1;
                                clearQueue(document.all.checkopr);

                                if (opremailbox.value != "" && opremailbox.value != "NULL") {
                                    var ValidEmail1 = replaceInvalidEmailAndValidate(opremailbox.value);

                                    if (ValidEmail1 != true) {
                                        ErrorCount++;
                                        queueMessage("Invalid email Address", oprerrorspan);
                                    }
                                    else {
                                        oprcheckemail = 1;
                                        clearQueue(oprerrorspan);
                                    }
                                }
                                else {
                                    ErrorCount++;
                                    queueMessage("You must enter an email address", oprerrorspan);
                                }
                            }
					}
				}

			    if (document.getElementById("checkAllDisLetters") != null) {
			        if (window.checkAllDisLetters.length) {
						for (var x = 0; x < window.checkAllDisLetters.length; x++) {
							disbox = getFirstChild(window.checkAllDisLetters[x]);
							disemailbox = getFirstChild(window.checkAllDisEmail[x]);
							diserrorspan = window.error_disAddress[x];
							diserrorcheck = window.error_discheckbox[x];

			                if (disbox.checked == true) {
								discheckcomplete = 1;
								clearQueue(document.all.checkdis);

								//var ValidEmail1 = true;
								if (disemailbox.value != "" && disemailbox.value != "NULL") {
									var ValidEmail1 = replaceInvalidEmailAndValidate(disemailbox.value);

			                        if (ValidEmail1 != true) {
										ErrorCount++;
										queueMessage("Invalid email Address", diserrorspan);
									}
									else {
										discheckemail = 1;
										clearQueue(diserrorspan);
									}
								}
								else {
									ErrorCount++;
									queueMessage("You must enter an email address", diserrorspan);
								}
							}
						}
					}
					else {
						disbox = getFirstChild(window.checkAllDisLetters);
						disemailbox = getFirstChild(window.checkAllDisEmail);
						diserrorspan = window.error_disAddress;
						diserrorcheck = window.error_discheckbox;

			            if (disbox.checked == true) {
							discheckcomplete = 1;
							clearQueue(document.all.checkdis);

			                if (disemailbox.value != "" && disemailbox.value != "NULL") {
								var ValidEmail1 = replaceInvalidEmailAndValidate(disemailbox.value);

			                if (ValidEmail1 != true) {
									ErrorCount++;
									queueMessage("Invalid email Address", diserrorspan);
								}
								else {
									discheckemail = 1;
									clearQueue(diserrorspan);
								}
							}
							else {
								ErrorCount++;
								queueMessage("You must enter an email address", diserrorspan);
							}
						}
					}
				}

			    if ((oprcheckcomplete == 0) && (discheckcomplete == 0)) {
			        if (document.getElementById("checkAllOprLetters") != null) {
						ErrorCount++;
						queueMessage("You must select a letter to send", document.all.checkopr);
					}

			        if (document.getElementById("checkAllDisLetters") != null) {
						ErrorCount++;
						queueMessage("You must select a letter to send", document.all.checkdis);
					}
				}

			    if (ErrorCount == 0) {
					thisForm.submit();
					return false;
				}
				else {
					showMessageWindow();
				}
            }



			function selectall(type){

			if (type == 'D') {
					var obj = window.checkAllDisLetters;
				}
				else

			if (type == 'O') {
						var obj = window.checkAllOprLetters;
					}

			if (obj != null) {

			if (obj.length) {
						for (var x = 0; x < obj.length; x++) {
							box = getFirstChild(obj[x])

			if (box.disabled == false) {

			if (type == 'O') {
									box.checked = document.all.opr_check_all.checked
								}
								else

			if (type == 'D') {
										box.checked = document.all.dis_check_all.checked
									}
							}
							else {
								box.disabled = true
							}
						}
					}
					else {
						box = getFirstChild(obj)

			if (type == 'O') {
							box.checked = document.all.opr_check_all.checked
						}
						else

			if (type == 'D') {
								box.checked = document.all.dis_check_all.checked
							}
					}
				}
            }

            $("input.toggle_excel_exports").click(function(){
                $("input.rfp").prop("checked", $(this).attr("checked") ? true : false);
            });
        </script>

<cfif !request.html_started>
        </body>
    </html>
</cfif>