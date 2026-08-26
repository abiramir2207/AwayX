<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Blacksmith Applications: Update/Delete Vendor Detail</title>
</head>

<body>

<CFPARAM NAME="URL.RID" DEFAULT="">
<CFPARAM NAME="FORM.RID" DEFAULT="#URL.RID#">
<CFPARAM NAME="FORM.FormSubmitted" DEFAULT="">
<CFPARAM NAME="FORM.OPERATOR_ID_NUMBER" DEFAULT="">
<CFPARAM NAME="FORM.Shr_Ship_TO" DEFAULT="">

<CFIF FORM.FormSubmitted EQ "">
	<CFQUERY NAME="GetItem" DATASOURCE="#Application.Datasource#">
		SELECT 		Vendor_Master.Vendor_ID,
					Vendor_Master.Vendor_Name,
					Vendor_Master.Address_1,
					Vendor_Master.Address_2,
					Vendor_Master.Address_3,
					Vendor_Master.City,
					Vendor_Master.State, 
					Vendor_Master.Zipcode,					
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
					BSA_Foodservice_Customers.Shr_Ship_To,
					Name,
					BSA_Operator.BSA_Operator_ID,
					BSA_Operator.Operator_Name,
					BSA_Operator.Legacy_ID Operator_ID_Number
					 
		FROM 		Vendor_Dist_Oper
		<CFIF ISDefined ("FORM.Vendor_ID")>
		RIGHT JOIN
		<CFELSE>
		INNER JOIN
		</CFIF>
				 	Vendor_Master ON Vendor_Master.Vendor_ID = Vendor_Dist_Oper.Vendor_ID
		LEFT JOIN 	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Vendor_Dist_Oper.Distributor_ID AND							
					BSA_Foodservice_Customers.Deleted = 0 				
		LEFT JOIN	BSA_Operator ON BSA_Operator.BSA_Operator_ID = Vendor_Dist_Oper.Operator_ID				
		WHERE 		1 = 2 
					<CFIF FORM.RID NEQ "">OR Vendor_Dist_Oper_ID = '#RID#'</CFIF>
					<CFIF ISDefined ("FORM.Vendor_ID")>OR Vendor_Master.Vendor_ID = '#FORM.Vendor_ID#'</CFIF>
	</CFQUERY>
	<CFSET FORM.Shr_Ship_To = GetItem.Shr_Ship_To>
	<CFSET FORM.Operator_ID_Number = GetItem.Operator_ID_Number>
	<CFPARAM NAME="FORM.Vendor_ID" DEFAULT="#GetItem.Vendor_ID#">
	<!--- <CFPARAM NAME="FORM.Shr_Ship_To" DEFAULT="#GetItem.Shr_Ship_To#"> --->
	<CFPARAM NAME="FORM.Visible_Distributor" DEFAULT="#GetItem.Name#">
	<CFPARAM NAME="FORM.Distributor" DEFAULT="#GetItem.BSA_Foodservice_Customers_ID#">
	<CFPARAM NAME="FORM.Importallflag" DEFAULT="">
	<CFPARAM NAME="FORM.Visible_Operator" DEFAULT="#GetItem.Operator_Name#">
	<CFPARAM NAME="FORM.Operator" DEFAULT="#GetItem.BSA_Operator_ID#">
	<CFPARAM NAME="FORM.Importallflag_Oper" DEFAULT="">
	<!--- <CFPARAM NAME="FORM.Operator_ID_Number" DEFAULT="#GetItem.Operator_ID_Number#"> --->
	<CFPARAM NAME="FORM.Visible_Vendor" DEFAULT="#GetItem.Vendor_Name#">
	<CFIF ISDefined ("FORM.Vendor_ID")>
		<CFSET FORM.Visible_Vendor = GetItem.Vendor_Name>
	</CFIF>
	<CFPARAM NAME="FORM.Vendor" DEFAULT="#GetItem.Vendor_ID#">
	<CFPARAM NAME="FORM.Importallflag_Vend" DEFAULT="">
	<CFPARAM NAME="FORM.Operator_List" DEFAULT="#FORM.Operator#">
	<BR>
	<CFOUTPUT>
	<FORM NAME="SearchForm" ACTION="Vendor_Action.cfm" METHOD="POST">
	<INPUT TYPE="Hidden" NAME="FormSubmitted" VALUE="#FORM.FormSubmitted#">
	<INPUT TYPE="Hidden" NAME="RID" VALUE="#FORM.RID#">
	<INPUT TYPE="Hidden" NAME="DeleteRecord" VALUE="0">
	
	
	<!---Can't change operator information if the vendor is associated with a distributor. Similarly, can't change distributor information if the vendor is associated with an operator--->

	<cfset CanModifyOperator = 1>
	<cfset CanModifyDistributor = 1>
	
	<cfif len(trim(form.operator)) GT 0 OR len(trim(form.operator_id_Number)) GT 0>
		<cfset CanModifyDistributor = 0>
		<cfset CanModifyOperator = 1>
	</cfif>
	
	<cfif len(trim(form.Visible_Distributor)) GT 0 OR len(trim(form.Shr_Ship_To)) GT 0>
		<cfset CanModifyDistributor = 1>
		<cfset CanModifyOperator = 0>
	</cfif><!--- D28955: Modified Action attribute, replace exiting file with index.cfm --->
<B><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="index.cfm">back to vendor search</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B><BR><BR>
		<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="Border-Bottom: 2px Solid Navy;Border-Right: 2px Solid Navy;Border-Left: 2px Solid Navy;Border-Top: 2px Solid Navy;">
			<TR>
				<TD COLSPAN="100%" ALIGN="Center"><B><FONT COLOR="RED" SIZE="2"><CFIF FORM.RID NEQ "">UPDATE / DELETE<CFELSE>CREATE</CFIF> Vendor Cross Reference</B></FONT><BR><HR COLOR="Orange"></TD>
			</TR>
			<TR>
				<TD><B>Vendor ID</B></TD>
				<TD><INPUT TYPE="Text" NAME="Vendor_ID" VALUE="#TRIM(FORM.Vendor_ID)#"></TD>
			</TR>
			<TR>
				<TD><B>Vendor Name</B></TD>
				<TD>
					<SCRIPT LANGUAGE="JavaScript">
						function showVendSearchWindow() 
						{				
							//document.all.Form_Submitted.value=0;		
							document.SearchForm.target = "_self";
							document.SearchForm.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";		
							NewWindow("vendor_master_search.cfm?Formname=SearchForm", "Vensearchwindow", 800, 600, "yes", "yes")
						}
					</SCRIPT>
					<INPUT TYPE="Text" NAME="Visible_Vendor" VALUE="#FORM.Visible_Vendor#" style="font:italic;width:300px;background-color:CCCCCC" READONLY>
					<B>
						<FONT COLOR="Red">[</FONT>
						<FONT COLOR="Blue"><A HREF="javascript: void(0);" onClick="javaScript: showVendSearchWindow();">select</A></FONT>
						<FONT COLOR="Red">]</FONT>
					</B>
					<!--- <INPUT TYPE="Text" NAME="Vendor" VALUE="#FORM.Vendor#" style="width: 350px;"> --->
					<INPUT TYPE="Hidden" NAME="Importallflag_Vend"  VALUE="#FORM.Importallflag_Vend#">
				</TD>
			</TR>
			<CFIF FORM.Distributor NEQ "">
				<cfset useLakebaseForDist_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForDist_Search_Result>
	<cftry>
		<cfset Dist_Search_Result = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#Distributor#",
				"deleted" = "eq.0",
				"active_code" = "eq.A",
				"order" = "name.asc",
				"select" = "bsa_foodservice_customers_id,name,shr_ship_to"
			}), "bsa_foodservice_customers_id,name,shr_ship_to"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDist_Search_Result = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDist_Search_Result>
<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
					SELECT BSA_Foodservice_Customers_ID,Name,
							Shr_Ship_To 
					FROM BSA_Foodservice_Customers 
					WHERE
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#Distributor#'
						AND
						BSA_Foodservice_Customers.Deleted = 0
						AND
						BSA_Foodservice_Customers.Active_Code = 'A'
					ORDER BY Name
				</CFQUERY>
</cfif>
				<CFSET FORM.Shr_Ship_To = Dist_Search_Result.Shr_Ship_To>
				<CFSET FORM.Visible_Distributor=VAlueList(Dist_Search_Result.Name)>
			</CFIF>
			<TR>
				<TD><B><CFOUTPUT>#application.returned_customer_setting.Shard_Ship_To_Label#</CFOUTPUT></B></TD>
				<TD><INPUT TYPE="Text" NAME="Shr_Ship_To" VALUE="#TRIM(FORM.Shr_Ship_To)#" <Cfif CanModifyDistributor IS 0>disabled style="font:italic;background-color:CCCCCC"</CFIF>></TD>
			</TR>
			<TR>
				<TD><B>#application.returned_customer_setting.distributor_label_singular# Name</B></TD>
				<TD>					
					<SCRIPT LANGUAGE="JavaScript">
						function showDistSearchWindow() 
						{				
							//document.all.Form_Submitted.value=0;		
							document.SearchForm.target = "_self";
							document.SearchForm.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";		
							NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=SearchForm&FieldName=Distributor&SelectSingleSearchResultOnly=1", "searchwindow", 800, 600, "yes", "yes")
						}
					</SCRIPT>
					<INPUT TYPE="Text" NAME="Visible_Distributor" VALUE="#FORM.Visible_Distributor#" style="font:italic;width:300px;background-color:CCCCCC" READONLY>
					<B><Cfif CanModifyDistributor IS 1>
						<FONT COLOR="Red">[</FONT>
						<FONT COLOR="Blue"><A HREF="javascript: void(0);" onClick="javaScript: showDistSearchWindow();">select</A></FONT><!--- onclick="window.showModalDialog(this.href,window,'dialogHeight:210px;dialogWidth:450px;center:yes;edge:raised'); return false;" --->
						<FONT COLOR="Red">]</FONT>
					</B></cfif>
				</TD>			
					<INPUT TYPE="Hidden" NAME="Distributor" VALUE="#FORM.Distributor#" style="width: 350px;">
					<INPUT TYPE="Hidden" NAME="Importallflag"  VALUE="#FORM.Importallflag#">
			</TR>
		
					<CFIF FORM.Operator_List NEQ "">
					<cfset useLakebaseForOper_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForOper_Search_Result>
	<cftry>
		<cfset Oper_Search_Result = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"bsa_operator_id" = "eq.#FORM.Operator_List#",
				"select" = "operator_name"
			}), "operator_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForOper_Search_Result = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForOper_Search_Result>
<CFQUERY NAME="Oper_Search_Result" DATASOURCE = "#Application.Datasource#">
						SELECT Operator_Name
						FROM	BSA_Operator
						WHERE 	BSA_Operator_ID = '#FORM.Operator_List#'
					</CFQUERY>
</cfif>
					
					<cfsilent><!--- 
						Dev Note: CPM 8259
						Description: Populate Operator ID and Name fields based on operator search function. 
									 Added Form.Operator_ID_Number = Form.Operator_List
					---></cfsilent>
					
					<CFSET FORM.Operator_ID_Number = Form.Operator_List>
					<CFSET FORM.Visible_Operator=Oper_Search_Result.Operator_Name>
				</CFIF>
				<SCRIPT LANGUAGE="JavaScript">
					function showOperSearchWindow() 
					{				
						//document.all.Form_Submitted.value=0;		
						document.SearchForm.target = "_self";
						document.SearchForm.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";		
						NewWindow("/billbacks/search_screens/PM_select_operators.cfm?Formname=SearchForm&SelectSingleSearchResultOnly=1", "operatorwindow", 800, 600, "yes", "yes")
					}
				</SCRIPT>	
		
			<TR>
				<TD><B>#application.returned_customer_setting.operator_label_singular# ID</B></TD>
				<TD>
					<INPUT TYPE="Text" NAME="Operator_ID_Number" VALUE="<CFIF FORM.Operator_ID_Number NEQ "">#FORM.Operator_ID_Number#<CFELSE>#FORM.Operator#</CFIF>" <Cfif CanModifyOperator IS 0>disabled style="font:italic;background-color:CCCCCC"</cfif>>
				</TD>					
			</TR>
				<INPUT TYPE="Hidden" NAME="Operator_List" VALUE="#FORM.Operator_List#">

			<TR>
				<TD><B>#application.returned_customer_setting.operator_label_singular# Name</B></TD>
				<TD>
					<INPUT TYPE="Text" NAME="Visible_Operator" VALUE="#FORM.Visible_Operator#" style="font:italic;width:300px;background-color:CCCCCC" READONLY>
					<Cfif CanModifyOperator IS 1>
					<B>
						<FONT COLOR="Red">[</FONT>
						<FONT COLOR="Blue"><A HREF="javascript: void(0);" onclick="javaScript: showOperSearchWindow();">select</A></FONT><!--- onclick="window.showModalDialog(this.href,window,'dialogHeight:210px;dialogWidth:450px;center:yes;edge:raised'); return false;" --->
						<FONT COLOR="Red">]</FONT>
					</B>
					</cfif>
				</TD>
					<INPUT TYPE="Hidden" NAME="Operator" VALUE="#FORM.Operator#" style="width: 350px;">
					<INPUT TYPE="Hidden" NAME="Importallflag_Oper"  VALUE="#FORM.Importallflag_Oper#">
			</TR>
			<TR>
				<TD COLSPAN="100%"><BR><BR>
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
						<TR>
							<TD>&nbsp;&nbsp;
								<CFIF URL.RID EQ "">	
								<CF_button
									button_name	=	""
									button_caption	=	"reset"
									button_action	=	"resetAll()"
									button_type	=	"javascript_link"
									button_width	=	"75"
									button_color	=	"Navy"
									button_tip		=	""
									font_color		=	"White"
									font_size		=	"12"
									font_weight	=	"bold"
												><BR>
								</CFIF>
							</TD>
							<TD>&nbsp;&nbsp;
								<CF_button
									button_name	=	""
									button_caption	=	"save"
									button_action	=	"Validate()"
									button_type	=	"javascript_link"
									button_width	=	"75"
									button_color	=	"Navy"
									button_tip		=	""
									font_color		=	"White"
									font_size		=	"12"
									font_weight	=	"bold"
												><BR>
							</TD>
							<TD>&nbsp;&nbsp;
								<CFIF URL.RID NEQ "">							
									<CF_button
										button_name	=	""
										button_caption	=	"delete"
										button_action	=	"DeleteThis()"
										button_type	=	"javascript_link"
										button_width	=	"75"
										button_color	=	"Navy"
										button_tip		=	""
										font_color		=	"White"
										font_size		=	"12"
										font_weight	=	"bold"
													><BR>				
								</CFIF>
							</TD>							
						</TR>
					</TABLE>					
				</TD>
			</TR>
		</TABLE>
	</FORM>
	</CFOUTPUT>
<CFELSE>

	<CFIF FORM.DeleteRecord EQ 0>		
		<CFSET ValidEntry = 1>
		<CFIF FORM.Vendor_ID NEQ "">
			<cfset useLakebaseForCheckMaster = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_master")>
<cfif useLakebaseForCheckMaster>
	<cftry>
		<cfset CheckMaster = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vendor_master", {
				"vendor_id" = "eq.#FORM.Vendor_ID#",
				"active_code" = "eq.A",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckMaster = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckMaster>
<CFQUERY NAME="CheckMaster" DATASOURCE="#Application.Datasource#">
				SELECT * FROM Vendor_Master WHERE Vendor_ID = '#FORM.Vendor_ID#' AND Active_Code = 'A' AND Deleted = 0
			</CFQUERY>
</cfif>
			<!--- <CFQUERY NAME="CheckVendorID" DATASOURCE="#Application.Datasource#">
				SELECT * FROM Vendor_Dist_Oper WHERE Vendor_ID = '#FORM.Vendor_ID#' AND Vendor_Dist_Oper_ID <> '#FORM.RID#' AND Deleted = 0
			</CFQUERY> --->
			<CFIF CheckMaster.RecordCount EQ 0><!--- CheckVendorID.RecordCount GT 0 OR  --->
				<CFSET ValidEntry = 0>
				<BR><BR><BR><BR>
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
					<TR>
						<TD>
						<B><FONT COLOR="Red" SIZE="3">
						<CFIF CheckMaster.RecordCount EQ 0>
						This vendor ID is not a valid entry... 
						<!--- <CFELSEIF CheckVendorID.RecordCount GT 0>
						This vendor ID already exist. Can't save this invalid entry...		 --->				
						</CFIF>
						</FONT></B>
						</TD>
						<td><CF_button
								button_name	=	""
								button_caption	=	"back"
								button_action	=	"history.go(-1);"
								button_type	=	"javascript_link"
								button_width	=	"75"
								button_color	=	"Navy"
								button_tip		=	""
								font_color		=	"White"
								font_size		=	"12"
								font_weight	=	"bold"
								>
						</td>
					</TR>
				</TABLE>
				<SCRIPT language="JavaScript">
				function alertAndClose()
				{
					window.close()
				}
				//window.setTimeout('alertAndClose()', 3000);
				</SCRIPT>
			</CFIF>
		</CFIF>
		
		<CFIF FORM.Shr_Ship_TO NEQ "">
			<CFQUERY NAME="ValidShipTO" DATASOURCE="#Application.Datasource#">
				SELECT 	* 
				FROM 	BSA_Foodservice_Customers
				WHERE 	Shr_Ship_To = '#FORM.Shr_Ship_To#' AND
						<CFIF FORM.Distributor NEQ "0" and trim(FORM.Distributor) NEQ "">
							BSA_Foodservice_Customers_ID = '#FORM.Distributor#' AND
						</CFIF>
						Active_Code = 'A' AND
						Deleted = 0
			</CFQUERY>
			<CFIF ValidShipTO.RecordCount EQ 0>
				<CFSET ValidEntry = 0>
				<BR><BR><BR><BR>
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
					<TR>
						<TD><B><FONT COLOR="Red" SIZE="3">Invalid <CFOUTPUT>#application.returned_customer_setting.Shard_Ship_To_Label#</CFOUTPUT></FONT></B></TD>
						<td><CF_button
								button_name	=	""
								button_caption	=	"back"
								button_action	=	"history.go(-1);"
								button_type	=	"javascript_link"
								button_width	=	"75"
								button_color	=	"Navy"
								button_tip		=	""
								font_color		=	"White"
								font_size		=	"12"
								font_weight	=	"bold"
								>
						</td>
					</TR>
				</TABLE>
				<SCRIPT language="JavaScript">
				function alertAndClose()
				{
					window.close()
				}
				//window.setTimeout('alertAndClose()', 3000);
				</SCRIPT>
			</CFIF> 
		
		</CFIF>	
		<CFIF FORM.Operator_ID_Number NEQ "">
			<!--- D12232 -- Ana: To void picking up the BSA_Operator_ID match when there is a Legacy ID Match --->
			<cfset useLakebaseForValidOpID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForValidOpID>
	<cftry>
		<cfset ValidOpID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"legacy_id" = "eq.#FORM.Operator_ID_Number#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForValidOpID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForValidOpID>
<CFQUERY NAME="ValidOpID" DATASOURCE="#Application.Datasource#">
				SELECT 	* 
				FROM 	BSA_Operator
				WHERE 	legacy_id = '#FORM.Operator_ID_Number#' AND								
						Deleted = 0
			</CFQUERY>
</cfif>
			<CFIF ValidOpID.RecordCount EQ 0 AND IsNumeric(FORM.Operator_ID_Number)>
				<CFQUERY NAME="ValidOpID" DATASOURCE="#Application.Datasource#">
					SELECT 	* 
					FROM 	BSA_Operator
					WHERE 	BSA_Operator_id = #FORM.Operator_ID_Number# AND
							Deleted = 0
				</CFQUERY>			
			</CFIF>
			<CFIF ValidOpID.RecordCount EQ 0>
				<CFSET ValidEntry = 0>
				<BR><BR><BR><BR>
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
					<TR>
						<TD><B><FONT COLOR="Red" SIZE="3">Invalid <CFOUTPUT>#application.returned_customer_setting.operator_label_singular#</CFOUTPUT> ID</FONT></B></TD>
						<td><CF_button
							button_name	=	""
							button_caption	=	"back"
							button_action	=	"history.go(-1);"
							button_type	=	"javascript_link"
							button_width	=	"75"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight	=	"bold"
							><BR>
						</td>
					</TR>
				</TABLE>

				<SCRIPT language="JavaScript">
				function alertAndClose()
				{
					window.close()
				}
				//window.setTimeout('alertAndClose()', 3000);
				</SCRIPT>
			</CFIF> 
		</CFIF>
		<CFIF ValidEntry EQ 1>
			<CFSET DistID = "">
			<CFIF FORM.Distributor NEQ "">
				<CFSET DistID = FORM.Distributor>
			<CFELSEIF FORM.Shr_Ship_TO NEQ "">
				<CFSET DistID = ValidShipTO.BSA_Foodservice_Customers_ID>
			</CFIF>
			<CFSET OpID = "">
			<CFIF FORM.Operator NEQ "">
				<CFSET OpID = FORM.Operator>
			<CFELSEIF FORM.Operator_ID_Number NEQ "">
				<CFSET OpID = ValidOpID.BSA_Operator_ID>
			</CFIF>
			<CFIF FORM.RID NEQ "">
				<CFQUERY NAME="" DATASOURCE="#Application.Datasource#">
					UPDATE 	Vendor_Dist_Oper
					SET 	Vendor_ID 		= <CFIF FORM.Vendor_ID NEQ "">'#FORM.Vendor_ID#',<CFELSE>NULL,</CFIF>
							Distributor_ID 	= <CFIF trim(DistID) NEQ "0" and trim(DistID) NEQ "">'#DistID#',<CFELSE>NULL,</CFIF>
							Operator_ID 	= <CFIF OpID NEQ "">'#OpID#',<CFELSE>NULL,</CFIF>
							UpdateBy 		= '#request.AccessStructure.User_ID#'
							
					WHERE 	Vendor_Dist_Oper_ID = '#FORM.RID#'
				</CFQUERY>
				<BR><BR><BR><BR>
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
					<TR>
						<TD><B><FONT COLOR="Red" SIZE="3">Wait while saving changes...</FONT></B></TD>
					</TR>
				</TABLE>
				<SCRIPT language="JavaScript">
					window.setTimeout('closewindow()', 2000);
				</SCRIPT> 
			<CFELSE>
				<CFQUERY NAME="insertData" DATASOURCE="#Application.Datasource#">
					INSERT INTO 
					Vendor_Dist_Oper	( 	Vendor_ID,
											Distributor_ID,
											Operator_ID,
											Created_By		)
													
					VALUES				(	<CFIF FORM.Vendor_ID NEQ "">'#FORM.Vendor_ID#',<CFELSE>NULL,</CFIF>
											<CFIF DistID NEQ "">'#DistID#',<CFELSE>NULL,</CFIF>
											<CFIF OpID NEQ "">'#OpID#',<CFELSE>NULL,</CFIF>
											'#request.AccessStructure.User_ID#'		)
				</CFQUERY>
				<BR><BR><BR><BR>
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
					<TR>
						<TD><B><FONT COLOR="Red" SIZE="3">Wait while saving this new entry...</FONT></B></TD>
					</TR>
				</TABLE>
				<SCRIPT language="JavaScript">
					window.setTimeout('closewindow()', 2000);
				</SCRIPT>
			</CFIF>		
		</CFIF>
	<CFELSEIF DeleteRecord EQ 1>
		<cfset useLakebaseForDeleteThis = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_dist_oper")>
<cfif useLakebaseForDeleteThis>
	<cftry>
		<cfset application.oLakebase.updateRows("vendor_dist_oper",
			{
				"vendor_dist_oper_id" = "eq.#FORM.RID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteThis = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteThis>
<CFQUERY NAME="DeleteThis" DATASOURCE="#Application.Datasource#">
			UPDATE 	Vendor_Dist_Oper
			SET 	Deleted = 1
			WHERE 	Vendor_Dist_Oper_ID = '#FORM.RID#'
		</CFQUERY>
</cfif>
		<BR><BR><BR><BR>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
			<TR>
				<TD><B><FONT COLOR="Red" SIZE="3">Wait while deleting this entry...</FONT></B></TD>
			</TR>
		</TABLE>
		<SCRIPT language="JavaScript">
			window.setTimeout('closewindow()', 2000);
		</SCRIPT>
	</CFIF>
	<!--- <SCRIPT language="JavaScript">
		window.setTimeout('closewindow()', 2000);
	</SCRIPT> --->
</CFIF>

<SCRIPT language="JavaScript">
function closewindow()
{	
	window.location.href ="index.cfm"//""Vendor_Form.cfm" D28955: vendor table in settings
	//window.opener.location.reload();
	window.close()		
}
</SCRIPT>
	
<SCRIPT language="JavaScript">
function Validate()
{
	var submit_this = 1;
	
	if (document.all.Vendor_ID.value == "")
	{
		submit_this = 0;
		alert("Please enter vendor ID and try again.");
		return;
	}

	if (document.all.Shr_Ship_To.value == "" && document.all.Distributor.value == "" && document.all.Operator.value == "" && document.all.Operator_ID_Number.value == "")
	{
		submit_this = 0;
		alert("You must enter at least one of these: <CFOUTPUT>#application.returned_customer_setting.Shard_Ship_To_Label#</CFOUTPUT>, <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Name, <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> ID, <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name."); 
		return;
	}	
	if ((document.all.Shr_Ship_To.value != "" || document.all.Distributor.value != "") && (document.all.Operator.value != "" || document.all.Operator_ID_Number.value != ""))
	{
		submit_this = 0;
		alert("You cannot enter information for both <cfoutput> #application.returned_customer_setting.distributor_label_singular# </cfoutput>and <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>."); 
		return;
	}
	
	if (submit_this == 1)
	{
		if (document.all.Operator_List.value != "")
		{
			document.all.Operator.value = document.all.Operator_List.value;
		}
		document.all.FormSubmitted.value = 1;
		document.SearchForm.submit()
	}
}
function DeleteThis()
{
	if (confirm("Press OK to delete this entry."))
	{
		document.all.DeleteRecord.value = 1;
		document.all.FormSubmitted.value = 1;
		document.SearchForm.submit()
	}
}

function resetAll()
{
	document.all.Vendor_ID.value = "";
	document.all.Visible_Vendor.value = "";
	document.all.Importallflag_Vend.value = "";
	document.all.Shr_Ship_To.value = "";
	document.all.Visible_Distributor.value = "";
	document.all.Distributor.value = "";
	document.all.Importallflag.value = "";
	document.all.Operator_ID_Number.value = "";
	document.all.Visible_Operator.value = "";
	document.all.Operator.value = "";
	document.all.Importallflag_Oper.value = "";
}
</SCRIPT>
</body>
</html>
