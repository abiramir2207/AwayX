<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />
<html>
<head>
	<title>Print Report</title>
</head>

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">

<STYLE>
TABLE.UnBorderTable TD 
{
	border-bottom:none;
}
</STYLE>

<SCRIPT language="JavaScript">
function exportSubmit()
{
	var formObj = document.ExportDataForm;
	//var oldTarget = formObj.target;	
	//formObj.target = "DDE";
	//NewWindow("", 'DDE', '800', '600', 'Yes', 'No', true);
	document.ExportDataForm.submit();
	//formObj.target = oldTarget;	
}

function sort_by_this_order(fieldName, sOrder)
{
	var oForm = document.GenerateReport;
	oForm.SORT_BY.value = fieldName;
	oForm.SORT_ORDER.value = sOrder;
	oForm.submit();
	return false;
}

function viewStyle()
{	
	document.all.CommunicationType.value = "";
	if (document.all.ViewStyle.value == 1)
	{
		document.all.ViewStyle.value = 2;
	}
	else
	{
		document.all.ViewStyle.value = 1;
	}
	document.GenerateReport.submit();
}
function openNewWindow(CommType)
{
	var formObj = document.GenerateReport;
	formObj.target = "DDReport";
	if (CommType == 1)
	{
		document.all.CommunicationType.value = 1;
		NewWindow("", 'DDReport', '800', '350', 'Yes', 'No', true);  /*25704*/
	}
	else if (CommType == 2)
	{
		document.all.CommunicationType.value = 2;
		NewWindow("", 'DDReport', '600', '350', 'Yes', 'No', true);
	}
	else if (CommType == 3)
	{
		document.all.CommunicationType.value = 3;
		NewWindow("", 'DDReport', '800', '600', 'Yes', 'No', true);
	}
	//var oldTarget = formObj.target;	
	document.GenerateReport.submit();
	formObj.target = "_self";
	//formObj.target = oldTarget;
}
</SCRIPT>

<CFPARAM NAME="FORM.CommunicationType" DEFAULT="">
<CFPARAM NAME="FORM.ViewStyle" DEFAULT="1">

<CFINCLUDE TEMPLATE="Ded_Search_Query.cfm">

<CFIF FORM.Form_Submitted NEQ "">
	<CFSET TrimDisplay = 1>
	<CFIF FORM.CommunicationType EQ 2 OR FORM.CommunicationType EQ 3>
		<CFSET TrimDisplay = 0>
	</CFIF>
	<CFSAVECONTENT VARIABLE="ReportOutPut">
	
		<STYLE>
		TABLE.Maintable TD 
		{
			border-bottom:solid #93BEE2 1px; font-size : 10px;
		}
		#header 
		{
			font-size: 12px;
		}
		Table.Maintable TD.tableheaders
		{
			font-size:12px;
			font-weight:bold;
			border-bottom:none; 
		}
		TABLE.UnBorderTable TD 
		{
			border-bottom:none;
		}		
		</STYLE>
		
<CFOUTPUT>
<FORM NAME="ExportDataForm" ACTION="Ded_ExportData.cfm" METHOD="POST" TARGET="_parent">
<CFLOOP COLLECTION=#FORM# ITEM="thisForm"> 
<CFIF thisForm NEQ "FIELDNAMES">
     <INPUT TYPE="hidden" NAME="#thisForm#" VALUE="#Evaluate("FORM.#thisForm#")#">
</CFIF>
</CFLOOP>
</FORM>
</CFOUTPUT>

 

		
		
		<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="100%" CLASS="maintable" ALIGN="Center"><!--- BorderTable --->
			<FORM NAME="GenerateReport" ACTION="Ded_Report_Builder.cfm" METHOD="Post">
				<CFOUTPUT>
				<INPUT TYPE="hidden" VALUE="#FORM.ViewStyle#" NAME="ViewStyle">
				<INPUT TYPE="hidden" VALUE="#FORM.CommunicationType#" NAME="CommunicationType">
				<INPUT TYPE="hidden" VALUE = "#FORM.SORT_BY#" NAME="SORT_BY">
				<INPUT TYPE="hidden" VALUE = "#FORM.SORT_ORDER#" NAME="SORT_ORDER">
				
				<INPUT TYPE="Hidden" NAME="Distributor_List" VALUE="#FORM.Distributor_List#">
				<INPUT TYPE="Hidden" NAME="Broker_List" VALUE="#FORM.Broker_List#">
				<INPUT TYPE="Hidden" NAME="DD_Number" VALUE="#FORM.DD_Number#">
				<INPUT TYPE="Hidden" NAME="Dollar_Operator" VALUE="#FORM.Dollar_Operator#">
				<INPUT TYPE="Hidden" NAME="DD_Amount" VALUE="#FORM.DD_Amount#">
				<CFIF Isdefined("FORM.DD_To_Amount")>
				<INPUT TYPE="Hidden" NAME="DD_To_Amount" VALUE="#FORM.DD_To_Amount#">
				</CFIF>
				<INPUT TYPE="Hidden" NAME="Date_Operator" VALUE="#FORM.Date_Operator#">
				<INPUT TYPE="Hidden" NAME="Date_Time" VALUE="#FORM.Date_Time#">
				<CFIF Isdefined("FORM.To_Date_Time")>
				<INPUT TYPE="Hidden" NAME="To_Date_Time" VALUE="#FORM.To_Date_Time#">
				</CFIF>
				<INPUT TYPE="Hidden" NAME="Check_No" VALUE="#FORM.Check_No#">
				<INPUT TYPE="Hidden" NAME="Service_Market_ID" VALUE="#FORM.Service_Market_ID#">
				<INPUT TYPE="Hidden" NAME="Distributor" VALUE="#FORM.Distributor#">
				<INPUT TYPE="Hidden" NAME="Family_ID" VALUE="#FORM.Family_ID#">
				<INPUT TYPE="Hidden" NAME="Analyst_User_ID" VALUE="#FORM.Analyst_User_ID#">
				<INPUT TYPE="Hidden" NAME="Service_Region_ID" VALUE="#FORM.Service_Region_ID#">
				<INPUT TYPE="Hidden" NAME="Broker" VALUE="#FORM.Broker#">
				<INPUT TYPE="Hidden" NAME="DD_Stage_ID" VALUE="#FORM.DD_Stage_ID#">
				<INPUT TYPE="Hidden" NAME="DD_Aging" VALUE="#FORM.DD_Aging#">
				<INPUT TYPE="Hidden" NAME="Service_Zone_ID" VALUE="#FORM.Service_Zone_ID#">
				<INPUT TYPE="Hidden" NAME="DD_Reason_Code_ID" VALUE="#FORM.DD_Reason_Code_ID#">
				<INPUT TYPE="Hidden" NAME="DD_Status" VALUE="#FORM.DD_Status#">
				<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="#FORM.Form_Submitted#">
				<INPUT TYPE="Hidden" NAME="Distributor_Bill_To_ID" VALUE="#FORM.Distributor_Bill_To_ID#">
				<INPUT TYPE="Hidden" NAME="Line_Of_Business_ID" VALUE="#FORM.Line_Of_Business_ID#">	
				<INPUT TYPE="Hidden" NAME="Q_Brand_ID" VALUE="#FORM.Q_Brand_ID#">
				<INPUT TYPE="Hidden" NAME="DD_Operator_ID" VALUE="#FORM.DD_Operator_ID#">
				<INPUT TYPE="Hidden" NAME="IsBusEnabled" VALUE="#FORM.IsBusEnabled#">
				<INPUT TYPE="Hidden" NAME="ClDate_Operator" VALUE="#FORM.ClDate_Operator#">
				<INPUT TYPE="Hidden" NAME="ClDate_Time" VALUE="#FORM.ClDate_Time#">
				<INPUT TYPE="Hidden" NAME="ClTo_Date_Time" VALUE="#FORM.ClTo_Date_Time#">	
				<INPUT TYPE="hidden" NAME="Operating_Unit_ID" VALUE="#FORM.Operating_Unit_ID#">
				<INPUT TYPE="Hidden" NAME="IsParentDeduction" VALUE="#FORM.IsParentDeduction#">
				<INPUT TYPE="Hidden" NAME="Filter_Closed" VALUE="#FORM.Filter_Closed#">
				<INPUT TYPE="Hidden" NAME="Only_DD_With_Inactive_Relations" VALUE="#FORM.Only_DD_With_Inactive_Relations#">
				<INPUT NAME="DD_Report_CashSpan" TYPE="Hidden" VALUE="#FORM.DD_Report_CashSpan#">
				<!--- Dev Note: Clay :9447 This code must execute if you are a supervisor
									       and have permission to select the analyst in the search page 
										   for the filters by analyst to work--->
				<cfif isdefined("accessalldeductions")>
					<INPUT TYPE="hidden" NAME="AccessAllDeductions" VALUE="#FORM.ACCESSALLDEDUCTIONS#">			
				</cfif>			
				</CFOUTPUT>
				
				<CFSET na="<FONT color=""CCCCCC"">no criteria</FONT>">
				<TR>
					<TD COLSPAN="100%" NOWRAP STYLE="Border-bottom:none">
						<CFIF FORM.CommunicationType EQ "">
						<CF_openLayer
							Border="yes"
							BorderSize="1"  
							BorderColor="orange"  
							Image="/images/plus2.gif"
							ImageOpen="/images/minus2.gif"
							Title="Hide Criteria Used:"  
							TitleClosed="Show Criteria Used:"  
							TitleTooltip="Click to Show/Hide Criteria Used"  
							TitleFont="font"  
							TitleColor="Blue"  
							TitleSize="9"  
							IsClosed="No"  
							Width="100%">		
						 	
							<CFINCLUDE TEMPLATE="Ded_Report_Criteria_inc.cfm"> 								
						</CF_openLayer>	
						<CFELSE>
							<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
							<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Deduction Report Search Criteria</LEGEND>
							<CFINCLUDE TEMPLATE="Ded_Report_Criteria_inc.cfm"> 
							</FIELDSET>		
						</CFIF>		
						<BR><BR>					
					</TD>
				</TR>
				
				
				
				<CFIF FORM.CommunicationType EQ "" AND Get_Data.RecordCount GT 0>
				<TR>
					<TD COLSPAN="100%" NOWRAP STYLE="Border-bottom:none">
						<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" width="100%">
							<TR>
								<TD STYLE="Border-bottom: none">
									<B><FONT SIZE="2" COLOR="navy"><CFOUTPUT><CFIF Get_Data.RecordCount EQ 1>Deduction<CFELSE>Deductions</CFIF> returned: <FONT COLOR="Red" SIZE="2">#Get_Data.RecordCount#</FONT></CFOUTPUT></FONT></B>
								</TD>								
								<TD STYLE="Border-bottom: none" ALIGN="Right">									
									<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: viewStyle()"><FONT SIZE="2"><CFIF FORM.ViewStyle EQ 1>detailed view<CFELSEIF FORM.ViewStyle EQ 2>summary view</CFIF></FONT></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;
									<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: exportSubmit()"><FONT SIZE="2">export data</FONT></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;
									<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: openNewWindow(1)"><FONT SIZE="2">email</FONT></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;
									<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: openNewWindow(2)"><FONT SIZE="2">fax</FONT></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;
									<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: openNewWindow(3)"><FONT SIZE="2">print</FONT></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
								</TD>				
							</TR>
						</TABLE>
					</TD>
				</TR>
				<CFELSE>
				<TR>
					<TD COLSPAN="100%" NOWRAP STYLE="Border-bottom:none">
						<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" width="100%">
							<TR>
								<TD STYLE="Border-bottom: none">
									<B><FONT SIZE="2" COLOR="Navy"><CFOUTPUT>#Get_Data.RecordCount# <CFIF Get_Data.RecordCount EQ 1>deduction<CFELSE>deductions</CFIF> returned</CFOUTPUT></FONT></B>
								</TD>																										
							</TR>
						</TABLE>
					</TD>
				</TR>	
				</CFIF>
				<CFIF FORM.ViewStyle EQ 1>
					<TR BGCOLOR="FFE083">
						<CFSET A_Header_Name_List = "DEDUCTION ##,STATUS,$ AMOUNT,#ucase(application.returned_customer_setting.distributor_label_singular)#,&nbsp;AGE,&nbsp;#UCase(stDeductionLabels['Action'])#,BROKER,REGION,&nbsp;ANALYST">
						<CFSET A_Header_Value_List = "DD_DedID_SP_Number,DD_Status,DD_Amount,Name,DD_Date,DD_Stage_Description,Broker_Name,Region_Name,_Users.Name_First">
					
						<CFSET Counter = 1>
						<CFOUTPUT>
						<CFLOOP LIST="#A_Header_Value_List#" INDEX="ThisHeaderItem">
							<CFSET thisSortOrder = "ASC">
							<CFSET Image_Name = "/Images/down_1.gif">
							<CFSET ThisHeaderItemName = ListGetAt(A_Header_Name_List, Counter, ",")>
							
							<CFIF ThisHeaderItem EQ FORM.SORT_BY>
								<CFIF FORM.SORT_ORDER EQ "ASC">
									<CFSET thisSortOrder = "DESC">
									<CFSET Image_Name = "/Images/up_1.gif">
								</CFIF>
							</CFIF>		
							<CFIF ThisHeaderItem NEQ "Name" AND ThisHeaderItem NEQ "DD_Stage_Description" AND ThisHeaderItem NEQ "Region_Name">			
							<TD ID="header" STYLE="font-size : 8pt">
							<CFELSE>
							<BR>
							</CFIF>
							<CFIF FORM.CommunicationType EQ "">
							<A HREF="##" onClick="javaSCript: return sort_by_this_order('#ThisHeaderItem#', '#thisSortOrder#');"><B>#ThisHeaderItemName#</B></A><CFIF ThisHeaderItem EQ FORM.SORT_BY>&nbsp;<IMG SRC="#Image_Name#" BORDER="0"></CFIF>			
							<CFELSE>
							<B>#ThisHeaderItemName#</B>	
							</CFIF>
							<CFIF ThisHeaderItem NEQ "DD_Amount" AND ThisHeaderItem NEQ "DD_Date" AND ThisHeaderItem NEQ "Broker_Name">
							</TD>			
							</CFIF>						
							<CFSET Counter = Counter + 1>
						</CFLOOP>
						</CFOUTPUT>
					</TR>	
				 	
					<CFOUTPUT QUERY="Get_Data">
					<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">				
							
						<TD><B><FONT COLOR="red" SIZE="2">[ </FONT>#DD_DedID_SP_Number#<FONT COLOR="red" SIZE="2"> ]</FONT></B>							
						<CFIF FORM.CommunicationType EQ "">
							<CFIF DD_IsParent EQ 1>

								<CFIF Split_Count GT 0>
									<img src="/Images/parent_New.gif" alt="" width="13" height="13" border="0">
								</CFIF>
							<CFELSE>
								<img src="/Images/child_New.gif" alt="" width="13" height="13" border="0">
							</CFIF>		
						</CFIF>
						</TD>
						<TD <!--- WIDTH="65" ---> NOWRAP <CFIF DD_Status_ID EQ "3">TITLE="Request for Approval"</CFIF>>#DD_Status_Description#</TD>
						<TD <cfif Distributor_Name neq "">TITLE="#application.returned_customer_setting.distributor_label_singular#: #Distributor_Name#"</cfif>>#DollarFormat(DD_Amount)#<BR>
							<CFSET DisplayThis = TRIM(Distributor_Name)>
							<CFSET NoOfCharInName = Len(DisplayThis)>	
															
							<CFIF NoOfCharInName GT 25 AND TrimDisplay EQ 1>
								<CFSET DisplayName = LEFT(DisplayThis,25)>
								#DisplayName#...
							<CFELSE>
								#Distributor_Name#
							</CFIF>				
						</TD>	
								
						<TD>
							#DD_Aging_Label# (#NumberOfDays# days)
							<BR>
							#DD_Stage_Description#
						</TD>
						<CFSET DisplayBroker = TRIM(Broker_Name)>
						<CFSET DisplayRegion = TRIM(Region_Name)>
						<TD TITLE="Broker Name: #TRIM(DisplayBroker)##chr(13)#Region Name: #TRIM(DisplayRegion)#">
							
							<CFSET BrokerLen = LEN(DisplayBroker)>							
							<CFIF BrokerLen GT 25 AND TrimDisplay EQ 1>
								<CFSET DisplayBroker = LEFT(DisplayBroker,25)>
								#DisplayBroker#...
							<CFELSE>	
							#DisplayBroker#
							</CFIF>
							<BR>
							<CFSET RegionLen = LEN(DisplayRegion)>
							<CFIF RegionLen GT 25 AND TrimDisplay EQ 1>
								<CFSET DisplayRegion = LEFT(DisplayRegion,25)>
								#DisplayRegion#...
							<CFELSE>
							#DisplayRegion#
							</CFIF>				
						</TD>
						<TD>#Name_First# #Name_Last#&nbsp;</TD>			
					</TR>
					</CFOUTPUT>
				<CFELSE>
					<CFSET dna = "<FONT color=""CCCCCC"">none</FONT>">
					<CFSET DisplayLen = 35>
					<TR>
						<TD COLSPAN="100%" STYLE="Border-bottom:none">
							<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%" CLASS="UnBorderTable">							
								<CFLOOP QUERY="Get_Data">
								<TR>
									<TD COLSPAN="100%" BGCOLOR="FFE083">
										<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
											<TR>
												<TD WIDTH="45%" <CFIF currentrow EQ 1> STYLE="Border-Top:solid A29F9D 1px;"</CFIF>><FONT SIZE="2"><B><CFOUTPUT>#DD_DedID# - <CFIF SP_Number EQ "">000 <CFELSE>#SP_Number#</CFIF></CFOUTPUT></B></FONT></TD>
												<TD ALIGN="Center" <CFIF currentrow EQ 1> STYLE="Border-Top:solid A29F9D 1px;"</CFIF>><FONT SIZE="2"><B><CFIF DD_IsParent EQ 1>Original<CFELSE>Split</CFIF></B></FONT></TD>
												<TD WIDTH="45%" ALIGN="Right" <CFIF currentrow EQ 1> STYLE="Border-Top:solid A29F9D 1px;"</CFIF>><FONT SIZE="2"><B>Date:</B> <CFOUTPUT>#DATEFORMAT(DD_Date,"mm/dd/yyyy")#</CFOUTPUT></FONT>&nbsp;&nbsp;</TD>
											</TR>
										</TABLE>
									</TD>
								</TR>
								<TR <CFOUTPUT>BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"</CFOUTPUT>>
									<TD WIDTH="70"><B>Amount:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;"><CFOUTPUT>#DollarFormat(DD_Amount)#<CFIF DD_IsParent EQ 1 AND Split_Count GT 0>&nbsp;&nbsp;&nbsp;&nbsp;( <B>Balance:</B> #DollarFormat(Parent_Balance_Amt)# )</CFIF></CFOUTPUT></TD>														
									<TD WIDTH="65">&nbsp;&nbsp;<B><cfoutput>#application.returned_customer_setting.shard_ship_to_label#</cfoutput>:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">
										<CFOUTPUT>
										<CFIF TRIM(Distributor_Name) NEQ "">
											#Distributor_Name# (#Shr_ship_to#)
										<CFELSE>
											#dna#
										</CFIF>
										</CFOUTPUT>
									</TD>
									<TD WIDTH="70">&nbsp;&nbsp;<B>Attachment:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">
										<CFOUTPUT>
										<CFIF attachment_count GT 0>
											#attachment_count#
										<CFELSE>	
											#dna#
										</CFIF>
										</CFOUTPUT>
									</TD>
								</TR>
								<TR <CFOUTPUT>BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"</CFOUTPUT>>									
									<TD><B>Aging:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">
											<CFOUTPUT>#DD_Aging_Label# (#NumberOfDays# days)</CFOUTPUT>
									</TD>
									<TD>&nbsp;&nbsp;<B><cfoutput>#application.returned_customer_setting.billto_label#</cfoutput>:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;"><CFOUTPUT>#Get_Data.Name# (#Get_Data.Shr_Bill_To#)</CFOUTPUT></TD>									
									<TD>&nbsp;&nbsp;<B>Notes:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">
										<CFIF Notes_Count GT 0>
											<CFOUTPUT>
												<CFSET DispNotes = TRIM(DD_Note)>
												<CFSET LenCheck = LEN(DispNotes)>
												<CFSET DispNotes= LEFT(DispNotes,DisplayLen)>
												Latest: #DispNotes#<CFIF LenCheck GT DisplayLen>...</CFIF> (#Notes_Count#)
											</CFOUTPUT>
										<CFELSE>
											<CFOUTPUT>#dna#</CFOUTPUT>
										</CFIF>
									</TD>
								</TR>
								<TR <CFOUTPUT>BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"</CFOUTPUT>>
									<TD><B>Analyst:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;"><CFOUTPUT>#Get_Data.Name_First# #Get_Data.Name_last#</CFOUTPUT></TD>
									<TD>&nbsp;&nbsp;<B>Broker:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;"><CFOUTPUT>#Broker_Name#</CFOUTPUT></TD>
									<TD>&nbsp;&nbsp;<B>Action:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;"><CFOUTPUT>#Get_Data.DD_Stage_Description#</CFOUTPUT></TD>
								</TR>
								<TR <CFOUTPUT>BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"</CFOUTPUT>>
									<TD><B>Supervisor:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">										
											<CFOUTPUT><cfif Get_Data.Supervisor_FirstName neq "">#Get_Data.Supervisor_FirstName# #Get_Data.Supervisor_LastName#<cfelse><CFIF Is_Supervisor EQ 1>#Get_Data.Name_First# #Get_Data.Name_last#<CFELSE>#DefaultSupervisor.Name_First# #DefaultSupervisor.Name_Last#</CFIF></cfif></CFOUTPUT>
									</TD>
									<TD>&nbsp;&nbsp;<B>Region:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;"><CFOUTPUT>#Region_Name#</CFOUTPUT></TD>
									<TD>&nbsp;&nbsp;<B>Comments:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">
										<CFOUTPUT>
											<cfif Get_Data.Comments neq "">
												<CFSET DisplayComment = TRIM(Comments)>
												<CFSET NoOfCharInComment = Len(DisplayComment)>	
																				
												<CFIF NoOfCharInComment GT DisplayLen AND TrimDisplay EQ 1>
													<CFSET DisplayComment = LEFT(DisplayComment,DisplayLen)>
													#DisplayComment#...
												<CFELSE>
													#DisplayComment#
												</CFIF>		
											<cfelse>
											#dna#
											</cfif>
										</CFOUTPUT>
									</TD>
								</TR>
								<TR <CFOUTPUT>BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"</CFOUTPUT>>
									<TD><B>Ref #:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">		
										<CFOUTPUT><cfif TRIM(Get_Data.DD_Reference) neq "">#Get_Data.DD_Reference#<cfelse>#dna#</cfif></CFOUTPUT>																		
									</TD>
									<TD>&nbsp;&nbsp;<B>Check #:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">
											<CFOUTPUT><cfif Get_Data.DD_Check_Number neq "">#Get_Data.DD_Check_Number#<cfelse>#dna#</cfif></CFOUTPUT>
									</TD>
									<TD>&nbsp;&nbsp;<B>Action Date:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">
											<CFOUTPUT><cfif Get_Data.Date_Completed neq "">#DateFormat(Get_Data.Date_Completed,"MM/DD/YYYY")#<cfelse>#dna#</cfif></CFOUTPUT>
									</TD>
								</TR>
								<TR <CFOUTPUT>BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"</CFOUTPUT>>
									<TD><cfif application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1 AND businessSegManager.isEnabled() AND Program_ID neq ""><B>Program:</B><cfelse><FONT color="CCCCCC">Program:</FONT></cfif></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">										
									<cfif application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1 AND businessSegManager.isEnabled() AND Program_ID NEQ "">
										<CFIF Program_ID NEQ "">
											<cfset useLakebaseForGetProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetProgram>
<cftry>
<cfset GetProgram = application.oLakebase.toQuery(
application.oLakebase.selectRows("contract_main", {
"select" = "contract_number",
"contract_main_id" = "eq.#Program_ID#",
"limit" = "1"
}),
"contract_number"
)>
<cfcatch type="any">
<cfset useLakebaseForGetProgram = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetProgram><CFQUERY NAME="GetProgram" DATASOURCE="#Application.Datasource#">
												SELECT Top 1 Contract_Number FROM Contract_Main WHERE Contract_Main_ID = '#Program_ID#' 
											</CFQUERY>
</cfif>
											<CFOUTPUT>#GetProgram.Contract_Number#</CFOUTPUT>
										<CFELSE>
											<CFOUTPUT>#dna#</CFOUTPUT>
										</CFIF>
									<cfelse>
									<CFOUTPUT>#dna#</CFOUTPUT>
									</cfif>
									</TD>
									<TD>&nbsp;&nbsp;<B>Cust Ref #:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">
											<CFOUTPUT><cfif Get_Data.DD_Customer_RefNo neq "">#Get_Data.DD_Customer_RefNo#<cfelse>#dna#</cfif></CFOUTPUT>
									</TD>
									<TD>&nbsp;&nbsp;<B>Classification:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">										
											<CFOUTPUT><cfif Get_Data.DD_Classification_Desc neq "">#Get_Data.DD_Classification_Desc#<cfelse>#dna#</cfif></CFOUTPUT>
									</TD>
								</TR>
								<CFSET ThisReason = DD_Reason_Code_Description>
								<CFSET ThisOperator = DD_Operator_ID>
								<CFSET ThisQBrand = Q_Brand_ID>		
								<TR <CFOUTPUT>BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"</CFOUTPUT>>
									<TD VALIGN="Top"><B>Status:</B></TD>
									<TD VALIGN="Top">																		
										<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">							
											<TR>
												<TD COLSPAN="100%"<CFIF DD_Status_ID EQ 4>BGCOLOR="FFE083"<CFELSE>STYLE="Border-bottom:solid 93BEE2 1px;"</CFIF> ><CFOUTPUT>#DD_Status_Description#</CFOUTPUT></TD>
											</TR>				
											<CFIF DD_Status_ID EQ 4>
												<CFIF Is_Trade NEQ "" AND Is_Trade NEQ 0>
													<CFSET TradeDisplayed = 1>
													<TR>
														<TD WIDTH="80"><cfif application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1><B>Type:</B><cfelse>&nbsp;</cfif></TD>
														<TD STYLE="Border-bottom:solid 93BEE2 1px;">
														<cfif application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1>
															<CFIF Is_Trade EQ 1>
																Trade
															<CFELSEIF Is_Trade EQ 0>
																Non - Trade
															</CFIF>
														<cfelse>
														&nbsp;
														</cfif>
														</TD>
													</TR>
												</CFIF>
												<CFIF Business_Segment_ID NEQ "">
													<cfset useLakebaseForGetBus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment")>
<cfif useLakebaseForGetBus>
<cftry>
<cfset GetBus = application.oLakebase.toQuery(
application.oLakebase.selectRows("business_segment", {
"business_segment_id" = "eq.#Business_Segment_ID#"
})
)>
<cfcatch type="any">
<cfset useLakebaseForGetBus = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetBus><CFQUERY NAME="GetBus" DATASOURCE="#Application.Datasource#">
														SELECT * FROM Business_Segment WHERE Business_Segment_ID = '#Business_Segment_ID#'
													</CFQUERY>
</cfif>
													<CFIF GetBus.RecordCount GT 0>
														<TR>
															<TD><cfif application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1 AND businessSegManager.isEnabled()><B>Business Seg:</B><cfelse>&nbsp;</cfif></TD>
															<TD STYLE="Border-bottom:solid 93BEE2 1px;"><cfif application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1 AND businessSegManager.isEnabled()><cfelse><CFOUTPUT>#GetBus.Business_Unit_ID# - #GetBus.Business_Unit_Desc#</CFOUTPUT></cfif></TD>
														</TR>
													</CFIF>
												</CFIF>
												<CFIF Operating_Unit_ID NEQ "">
													<cfset useLakebaseForSelOpUnit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operating_unit")>
<cfif useLakebaseForSelOpUnit>
<cftry>
<cfset SelOpUnit = application.oLakebase.toQuery(
application.oLakebase.selectRows("operating_unit", {
"operating_unit_id" = "eq.#Operating_Unit_ID#"
})
)>
<cfcatch type="any">
<cfset useLakebaseForSelOpUnit = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForSelOpUnit><CFQUERY NAME="SelOpUnit" DATASOURCE="#Application.Datasource#">
														SELECT * FROM Operating_Unit WHERE Operating_Unit_ID = '#Operating_Unit_ID#'
													</CFQUERY>
</cfif>
													<CFIF SelOpUnit.RecordCount GT 0>
														<TR>
															<TD><cfif application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1 AND businessSegManager.isEnabled()><B>Operating Unit:</B></cfif></TD>
															<TD STYLE="Border-bottom:solid 93BEE2 1px;"><cfif application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1 AND businessSegManager.isEnabled()><CFOUTPUT>#SelOpUnit.Code# - #SelOpUnit.Operating_unit_Description#</CFOUTPUT><cfelse>&nbsp;</cfif></TD>
														</TR>
													</CFIF>
												</CFIF>
												<CFIF ThisReason NEQ "">
													<TR>
														<TD WIDTH="80"><B>Reason Code:</B></TD>
														<TD STYLE="Border-bottom:solid 93BEE2 1px;"><CFOUTPUT>#ThisReason#</CFOUTPUT></TD>
													</TR>
													<CFIF ThisOperator NEQ "">
														<cfset useLakebaseForGetOperator = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_operator")>
<cfif useLakebaseForGetOperator>
<cftry>
<cfset GetOperator = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_operator", {
"select" = "dd_operator_name",
"dd_operator_id" = "eq.#ThisOperator#"
}),
"dd_operator_name"
)>
<cfcatch type="any">
<cfset useLakebaseForGetOperator = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetOperator><CFQUERY NAME="GetOperator" DATASOURCE="#Application.Datasource#">
															SELECT DD_Operator_Name FROM DD_Operator WHERE DD_Operator_ID = '#ThisOperator#'
														</CFQUERY>
</cfif>
														<TR WIDTH="80">
															<TD><B><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>:</B></TD>
															<TD STYLE="Border-bottom:solid 93BEE2 1px;"><CFOUTPUT>#GetOperator.DD_Operator_Name#</CFOUTPUT></TD>
														</TR>
													</CFIF>
												</CFIF>	
												<CFIF ThisQBrand NEQ "">
													<TR>
														<TD WIDTH="80"><cfif application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1 AND businessSegManager.isEnabled()><B>Q Brand</B><cfelse>&nbsp;</cfif></TD>
														<cfset useLakebaseForGetQBrand = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("q_brand_desc")>
<cfif useLakebaseForGetQBrand>
<cftry>
<cfset GetQBrand = application.oLakebase.toQuery(
application.oLakebase.selectRows("q_brand_desc", {
"select" = "q_brand",
"q_brand_id" = "eq.#ThisQBrand#"
}),
"q_brand"
)>
<cfcatch type="any">
<cfset useLakebaseForGetQBrand = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetQBrand><CFQUERY NAME="GetQBrand" DATASOURCE="#Application.Datasource#">
															SELECT Q_Brand FROM Q_Brand_Desc WHERE Q_Brand_ID = '#ThisQBrand#'
														</CFQUERY>
</cfif>
														<TD STYLE="Border-bottom:solid 93BEE2 1px;"><CFOUTPUT><cfif application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1 AND businessSegManager.isEnabled()>#GetQBrand.Q_Brand#</CFOUTPUT><cfelse>&nbsp;</cfif></TD>														
													</TR>
												</CFIF>										
											</CFIF>
										</TABLE>
									</TD>	
									<TD>&nbsp;&nbsp;<B>Billback:</B></TD>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">
										<CFIF DD_Closure_ID NEQ "" AND DD_Closure_Type EQ 1>
											<cfset useLakebaseForGetBBCode = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetBBCode>
<cftry>
<cfset GetBBCode = application.oLakebase.toQuery(
application.oLakebase.selectRows("billback", {
"select" = "bb_code",
"billback_id" = "eq.#DD_Closure_ID#"
}),
"bb_code"
)>
<cfcatch type="any">
<cfset useLakebaseForGetBBCode = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetBBCode><CFQUERY NAME="GetBBCode" DATASOURCE="#Application.Datasource#">
												SELECT BB_Code FROM Billback WHERE Billback_ID = '#DD_Closure_ID#'
											</CFQUERY>
</cfif>
											<CFOUTPUT>#GetBBCode.BB_Code#</CFOUTPUT>
										<CFELSE>
											<CFOUTPUT>#dna#</CFOUTPUT>
										</CFIF>
									</TD>																
									<TD>&nbsp;&nbsp;<B>Credit:</B></TD>
								<CFIF len(trim(Get_Data.DD_Closure_ID)) GT 0 AND Get_Data.DD_Closure_Type IS 5>
								<cfset useLakebaseForAssociatedCredit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForAssociatedCredit>
<cftry>
<cfset AssociatedCredit = application.oLakebase.toQuery(
application.oLakebase.selectRows("deductions", {
"select" = "dd_dedid_sp_number",
"deduction_id" = "eq.#Get_Data.DD_Closure_ID#"
}),
"dd_dedid_sp_number"
)>
<cfcatch type="any">
<cfset useLakebaseForAssociatedCredit = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForAssociatedCredit><CFQUERY NAME="AssociatedCredit" DATASOURCE="#Application.Datasource#">
								 SELECT DD_DedID_SP_Number FROM Deductions WHERE Deduction_ID = '#Get_Data.DD_Closure_ID#'
								</CFQUERY>
</cfif>
								<CFIF AssociatedCredit.RecordCount GT 0>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;">
											<CFOUTPUT><cfif DD_DedID_SP_Number neq "">#AssociatedCredit.DD_DedID_SP_Number#<cfelse>#dna#</cfif></CFOUTPUT>											
									</TD>
								<CFELSE>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;"><CFOUTPUT>#dna#</CFOUTPUT></TD>
								</CFIF>
								<CFELSE>
									<TD STYLE="Border-bottom:solid 93BEE2 1px;"><CFOUTPUT>#dna#</CFOUTPUT></TD>
								</CFIF>									
								</TR>
	
								<TR <CFOUTPUT>BGCOLOR="#IIf(currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#"</CFOUTPUT>>
									<CFIF DD_IsParent EQ 1>			

										<CFIF Split_Count GT 0>
										<cfset useLakebaseForGetSplit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGetSplit>
<cftry>
<cfset GetSplit = application.oLakebase.toQuery(
application.oLakebase.selectRows("deductions", {
"select" = "dd_dedid_sp_number,dd_amount",
"dd_dedid" = "eq.#DD_DedID#",
"deduction_id" = "neq.#Deduction_ID#",
"deleted" = "eq.0",
"order" = "dd_dedid_sp_number.asc"
}),
"dd_dedid_sp_number,dd_amount"
)>
<cfcatch type="any">
<cfset useLakebaseForGetSplit = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetSplit><CFQUERY NAME="GetSplit" DATASOURCE="#Application.Datasource#">
											SELECT 		DD_DedID_SP_Number,
														DD_Amount														 
											FROM 		Deductions 
											
											WHERE 		DD_DedID = '#DD_DedID#' AND 
														Deduction_ID <> '#Deduction_ID#' AND 
														Deleted = 0 
											ORDER BY 	DD_DedID_SP_Number
										</CFQUERY>
</cfif>
										</CFIF> 
									<CFELSE>
										<cfset useLakebaseForGetParentAndOtherSplit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGetParentAndOtherSplit>
<cftry>
<cfset GetParentAndOtherSplit = application.oLakebase.toQuery(
application.oLakebase.selectRows("deductions", {
"select" = "dd_dedid_sp_number,dd_isparent,dd_amount",
"dd_dedid" = "eq.#DD_DedID#",
"deduction_id" = "neq.#Deduction_ID#",
"deleted" = "eq.0",
"order" = "dd_isparent.desc"
}),
"dd_dedid_sp_number,dd_isparent,dd_amount"
)>
<cfcatch type="any">
<cfset useLakebaseForGetParentAndOtherSplit = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetParentAndOtherSplit><CFQUERY NAME="GetParentAndOtherSplit" DATASOURCE="#Application.Datasource#">
											SELECT 		DD_DedID_SP_Number,
														DD_IsParent, 
														DD_Amount								
											FROM 		Deductions 											
											WHERE 		DD_DedID = '#DD_DedID#' AND 
														Deduction_ID <> '#Deduction_ID#' AND 
														Deleted = 0 
											ORDER BY 	DD_IsParent DESC
										</CFQUERY>
</cfif>
									</CFIF>
									<TD COLSPAN="2" VALIGN="Top">
										<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
											<CFIF DD_IsParent EQ 1 AND Split_Count GT 0>													
												<CFIF Split_Count GT 0>
												<CFLOOP QUERY="GetSplit">
													<TR>													
														<CFIF CurrentRow EQ 1>
															<TD WIDTH="75">&nbsp;&nbsp;<B>Split:</B></TD>
														<CFELSE>
															<TD>&nbsp;</TD>
														</CFIF>
															<TD STYLE="Border-bottom:solid 93BEE2 1px;"><CFOUTPUT>#DD_DedID_SP_Number# &nbsp;&nbsp;(#DollarFormat(DD_Amount)#)</CFOUTPUT></TD>																										
													</TR>												
												</CFLOOP>
												</CFIF>
											<CFELSEIF DD_IsParent EQ 0 AND GetParentAndOtherSplit.recordcount GT 0>
												<CFLOOP QUERY="GetParentAndOtherSplit">
													<TR>											
														<CFIF CurrentRow EQ 1>
															<TD WIDTH="55">&nbsp;&nbsp;<B>Parent:</B></TD>
														<CFELSEIF CurrentRow EQ 2>
															<TD>&nbsp;&nbsp;<B>Split:</B></TD>
														<CFELSE>
															<TD>&nbsp;</TD>
														</CFIF>
															<TD STYLE="Border-bottom:solid 93BEE2 1px;"><CFOUTPUT>#DD_DedID_SP_Number# &nbsp;&nbsp;(#DollarFormat(DD_Amount)#)</CFOUTPUT></TD>															
													</TR>
												</CFLOOP>	
											</CFIF>
										</TABLE>
									</TD>
									<TD>&nbsp;</TD>
									<TD>&nbsp;</TD>
									<TD>&nbsp;</TD>
									<TD>&nbsp;</TD>
								</TR>
								<TR <CFOUTPUT>BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"</CFOUTPUT>>
									<TD COLSPAN="100%" STYLE="Border-bottom:solid A29F9D 1px;">&nbsp;</TD>
								</TR>
								</CFLOOP>
							</TABLE>
						</TD>
					</TR>	
				</CFIF>		
				<CFIF FORM.CommunicationType EQ "" AND Get_Data.RecordCount GT 0>		
				<TR>
					<TD COLSPAN="100%" NOWRAP STYLE="Border-bottom:none">
						<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" width="100%">

							<TR>
								<TD STYLE="Border-bottom: none">
									<B><FONT SIZE="2" COLOR="Navy"><CFOUTPUT><CFIF Get_Data.RecordCount EQ 1>Deduction<CFELSE>Deductions</CFIF> returned: <FONT COLOR="Red" SIZE="2">#Get_Data.RecordCount#</FONT></CFOUTPUT></FONT></B>
								</TD>								
								<TD STYLE="Border-bottom: none" ALIGN="Right">
									<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: viewStyle()"><FONT SIZE="2"><CFIF FORM.ViewStyle EQ 1>detailed view<CFELSEIF FORM.ViewStyle EQ 2>summary view</CFIF></FONT></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;
									<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: exportSubmit()"><FONT SIZE="2">export data</FONT></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;
									<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: openNewWindow(1)"><FONT SIZE="2">email</FONT></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;
									<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: openNewWindow(2)"><FONT SIZE="2">fax</FONT></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;
									<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: openNewWindow(3)"><FONT SIZE="2">print</FONT></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
								</TD>									
							</TR>
						</TABLE>
					</TD>
				</TR>	
				<CFELSE>
				<TR>
					<TD COLSPAN="100%" NOWRAP STYLE="Border-bottom:none">
						<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" width="100%">
							<TR>								
								<TD STYLE="Border-bottom: none">
									<B><FONT SIZE="2" COLOR="Navy"><CFOUTPUT>#Get_Data.RecordCount# <CFIF Get_Data.RecordCount EQ 1>deduction<CFELSE>deductions</CFIF> returned</CFOUTPUT></FONT></B>
								</TD>																										
							</TR>
						</TABLE>
					</TD>
				</TR>	
				</CFIF>			
			</FORM>
		</TABLE>
	</CFSAVECONTENT>


<CFIF FORM.CommunicationType EQ "">
	<CFOUTPUT>#ReportOutPut#</CFOUTPUT>
<CFELSE>
	<CFIF FORM.CommunicationType EQ 1 OR FORM.CommunicationType EQ 2>
		<CFSET Time = "#DateFormat(now(),"mmddyyyy")#_#TimeFormat(now(),"HHmmss")#">

		<CF_Writing_Email_Attachment
			Naming_Format="Deduction_Report_#Time#"				
			Relative_Path="\Temp_Files\Deduction\"
			Output_Content="#ReportOutPut#"				
			Return_File_Name="fName">
		 
		<CFIF FORM.CommunicationType EQ 1>
			<CFLOCATION URL="Ded_Report_Email.cfm?FileName=#fName#" ADDTOKEN="No">
		<CFELSE>
			<CFLOCATION URL="Ded_Report_Fax.cfm?FileName=#fName#" ADDTOKEN="No">
		</CFIF>

	<CFELSE>
		<BR><BR>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="98%">
			<TR>
				<TD><CFOUTPUT>#ReportOutPut#</CFOUTPUT></TD>
			</TR>
		</TABLE>		
		<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm">
	</CFIF>
</CFIF>	
</CFIF>
</body>
</html>
