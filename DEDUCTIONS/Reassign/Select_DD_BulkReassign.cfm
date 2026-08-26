<!DOCTYPE HTML>
<html>
<head>
	<title>Deductions to Reassign</title>
</head>
<body>
<CFPARAM NAME="FORM.SORT_BY" 				DEFAULT="DD_DedID">
<CFPARAM NAME="FORM.SORT_ORDER" 			DEFAULT="ASC">
<cfparam name="FORM.startrow"  				DEFAULT="1">
<CFPARAM NAME="FORM.frompage"   			DEFAULT="1">
<cfparam name="FORM.pageLength"  			DEFAULT=11>
<CFSET startrow=FORM.startrow>
<CFSET frompage=FORM.frompage>
<cf_Number_of_Rows maxrows="#FORM.pageLength#">


<CFPARAM NAME="FORM.Deduction_ID" 			DEFAULT="">
<CFPARAM NAME="FORM.Src_Analyst" 			DEFAULT="">
<CFPARAM NAME="FORM.Tar_Analyst" 			DEFAULT="">
<CFPARAM NAME="FORM.Items_OnThis_Page" 		DEFAULT="">
<CFPARAM NAME="FORM.Selected_Deductions" 	DEFAULT="">
<CFPARAM NAME="FORM.Already_Selected_List" 	DEFAULT="#FORM.Selected_Deductions#">
<CFPARAM NAME="FORM.src_status" 			DEFAULT="">
<CFPARAM NAME="FORM.src_stage" 				DEFAULT="">
<CFPARAM NAME="FORM.Distributor_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.Distributor_List" 	DEFAULT="">
<CFPARAM NAME="FORM.Distributor_Status" 	DEFAULT="A,N">
<CFPARAM NAME="FORM.Broker_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.Broker_List" 	DEFAULT="">
<CFPARAM NAME="FORM.Broker_Status" 	DEFAULT="A,N">
<CFPARAM NAME="FORM.Tar_Classification" 			DEFAULT=""><!--- D33578 Ability to reclass when reassigning deduction --->
<cfparam name="form.create_list_numbers" default="">

<CFIF isdefined("FORM.Undo_Seletion")>
	<CFIF FORM.Undo_Seletion EQ 1>
		<CFSET FORM.Items_OnThis_Page = "">
		<CFSET FORM.Already_Selected_List = "">
		<CFSET FORM.Deduction_ID = "">
	</CFIF>
</CFIF> 


<!--- 
<CFIF FORM.PM_Status_ID NEQ "0">
<CFSET PM_Status_ID_List = ListQualify(FORM.PM_Status_ID,"'",",")>
</CFIF> 
--->



<CFIF Not Isdefined("FORM.Already_Selected_List")>
	<CFPARAM NAME="FORM.Already_Selected_List" DEFAULT="#FORM.Selected_Deductions#">
	<CFSET FORM.Already_Selected_List = FORM.Deduction_ID>
<CFELSE>	
	<CFLOOP LIST="#FORM.Deduction_ID#" INDEX="Item">		
		<CFIF NOT ListFindNoCase(FORM.Already_Selected_List,Item,",")>
			<CFSET FORM.Already_Selected_List = ListAppend(FORM.Already_Selected_List,Item,",")>
		</CFIF>
	</CFLOOP> 
</CFIF>


<CFLOOP LIST="#FORM.Items_OnThis_Page#" INDEX="Item">	
	<CFIF Not ListFindNoCase(FORM.Deduction_ID,Item,",")>
		<CFSET DeleteItemPosition = ListFindNoCase(FORM.Already_Selected_List,Item,",")>
		<CFIF DeleteItemPosition GT 0>
			<CFSET FORM.Already_Selected_List = ListDeleteAt(FORM.Already_Selected_List,DeleteItemPosition,",")>
		</CFIF>
	</CFIF>
</CFLOOP>

<cfparam name="form.finishedSearching" default="0">
<cfif form.finishedSearching>
	<!-----  return to paren page ----->
	<script language="JavaScript">
		submitOpener();
		function submitOpener()
		{
			var op = window.opener;
			if(op)
			{
				var parentForm = op.document.DD_Reassign;
				if(parentForm)
				{
					var dedObj = parentForm.Deduction_ID;
					if(dedObj)
					{
						<cfoutput>
						dedObj.value = "#FORM.Already_Selected_List#";
						</cfoutput>
					}
					parentForm.action = "Bulk_DD_Reassign.cfm";
					parentForm.submit();
					window.close();
				}
			}
		}
	</script>
	<cfabort>
</cfif>

<cfif len(trim(form.Broker_ID)) GT 0>
<cfset useLakebaseForGetBrokerID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_brokers")>
<cfif useLakebaseForGetBrokerID>
	<cftry>
		<cfset GetBrokerID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_brokers", {
				"select" = "bsa_foodservice_brokers_id",
				"broker_shard" = "eq.#form.Broker_ID#"
			}),
			"bsa_foodservice_brokers_id"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetBrokerID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBrokerID>
<CFQUERY NAME="GetBrokerID" DATASOURCE="#Application.Datasource#">
 SELECT BSA_Foodservice_Brokers_ID
 FROM BSA_Foodservice_Brokers
 WHERE Broker_Shard= '#form.Broker_ID#'
</CFQUERY>
</cfif>
</cfif>

<!--- Dev Note: Milan; 11425 - These statements are executed in order in the query below. Please be aware of this before you need to 
			add or delete a condition ---> 
<cfset Src_Analyst_QueryClause = "AND">
<cfset Distributor_ID_QueryClause = "AND">
<cfset Distributor_List_QueryClause = "AND">
<cfset Broker_ID_QueryClause = "AND">
<cfset Broker_List_QueryClause = "AND">

	<cfif len(trim(FORM.Src_Analyst))>
		<cfset Src_Analyst_QueryClause = "WHERE">
	<cfelseif len(trim(form.Distributor_ID))>
		<cfset Distributor_ID_QueryClause = "WHERE">
  <cfelseif len(trim(form.Distributor_List))>
		<cfset Distributor_List_QueryClause = "WHERE">
	<cfelseif len(trim(form.Broker_ID))>
		<cfset Broker_ID_QueryClause = "WHERE">
	<cfelseif len(trim(form.Broker_List))>
		<cfset Broker_List_QueryClause = "WHERE">
	</cfif>

<CFQUERY NAME="GetDDDetails" DATASOURCE="#Application.Datasource#">
	SELECT 	DISTINCT Deductions.*,
					Distributor_Bill_To.Name,
					Distributor_Bill_To.Shr_Bill_To,
					DD_Status.DD_Status_Description,
					DD_Stage.DD_Stage_Description,
					BSA_Foodservice_Brokers.Broker_Name,
					Service_Regions.Region_Name
	FROM 		Deductions	
	LEFT JOIN 	Distributor_Bill_To 
	ON Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID
	<cfif len(trim(form.Distributor_ID)) GT 0 OR len(trim(form.Distributor_List)) GT 0>
	INNER JOIN BSA_Foodservice_Customers 	

	ON 	((Deductions.Distributor_ID IS NOT NULL AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID)
			OR 
			(Deductions.Distributor_ID IS NULL AND BSA_Foodservice_Customers.Distributor_Bill_To_ID = Distributor_Bill_To.Distributor_Bill_To_ID)
	) 

	
	AND BSA_Foodservice_Customers.Deleted = 0
	AND BSA_Foodservice_Customers.Active_Code in ( <!---D42846 :: Deduction tool upgrades--->
																		                                    <cfscript>
																		                                     listCount = 0;
																		                                     listSize  = listLen(FORM.Distributor_status);
																		                                    </cfscript>
																		                                    <cfloop index="thisStatus" list="#FORM.Distributor_status#">
																		                                      '#thisStatus#'
																		                                      <cfset listCount = listCount + 1>
																		                                      <!---insert a comma if this status is not the last one in the list--->
																		                                      <cfif (listCount lt listSize)>
																		                                          ,
																		                                      </cfif>
																		                                    </cfloop>   
																		                                  )
	</cfif>
	LEFT JOIN 	BSA_Foodservice_Brokers 
	ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Deductions.Broker_ID
	LEFT JOIN 	Service_Regions 
	ON Service_Regions.Service_Region_ID = BSA_Foodservice_Brokers.Service_Region_ID
	INNER JOIN 	DD_Status 
	ON DD_Status.DD_Status_ID = Deductions.DD_Status
	LEFT JOIN 	DD_Stage 
	ON DD_Stage.DD_Stage_ID = Deductions.DD_Stage

	Where 1 = 1
	
	<cfif trim(form.create_list_numbers) neq "">
		<cfset form.create_list_numbers = replace(form.create_list_numbers, chr(13) & chr(10), ",", "all")>
		AND ( 1 = 2
		<cfloop index="create_list_value" list="#form.create_list_numbers#" delimiters=",">
			<cfif trim(create_list_value) neq "">
				OR Deductions.dd_dedid_sp_number LIKE '%#trim(create_list_value)#%'
			</cfif>
		</cfloop>
		)
	</cfif>
	<cfif len(trim(FORM.Src_Analyst)) GT 0>
	AND Deductions.Analyst_User_ID in ( <!---D42846 :: Deduction tool upgrades--->
																		                                    <cfscript>
																		                                     listCount = 0;
																		                                     listSize  = listLen(FORM.Src_Analyst);
																		                                    </cfscript>
																		                                    <cfloop index="thisStatus" list="#FORM.Src_Analyst#">
																		                                      '#thisStatus#'
																		                                      <cfset listCount = listCount + 1>
																		                                      <!---insert a comma if this status is not the last one in the list--->
																		                                      <cfif (listCount lt listSize)>
																		                                          ,
																		                                      </cfif>
																		                                    </cfloop>   
																		                                  )
	</cfif>
	<cfif len(trim(form.Distributor_ID)) GT 0>
	AND  Deductions.DD_Shr_Ship_To = '#form.Distributor_ID#'
	<cfelseif len(trim(form.Distributor_List)) GT 0>
	AND  Deductions.Distributor_ID IN ('#Replace(FORM.Distributor_List,chr(44), chr(39)&chr(44)&chr(39), "ALL")#')
	</cfif>
	<cfif len(trim(form.Broker_ID)) GT 0>
	AND
		<cfif GetBrokerID.recordcount neq 0>
		 Deductions.Broker_ID = '#GetBrokerID.BSA_Foodservice_Brokers_ID#'
		<cfelse>
		<!--- This is to avoid an error --->
		 Deductions.Broker_ID =  '11111111-1111-1111-1111-111111111111'
		</cfif>			
	<cfelseif len(trim(form.Broker_List)) GT 0>
	AND Deductions.Broker_ID IN ('#Replace(FORM.Broker_List,chr(44), chr(39)&chr(44)&chr(39), "ALL")#')
	</cfif>	
	<cfif len(trim(form.Broker_ID)) GT 0 OR len(trim(form.Broker_List)) GT 0>
	AND BSA_Foodservice_Brokers.Deleted = 0
	AND BSA_Foodservice_Brokers.Active_Code in ( <!---D42846 :: Deduction tool upgrades--->
													                                    <cfscript>
													                                     listCount = 0;
													                                     listSize  = listLen(FORM.Broker_status);
													                                    </cfscript>
													                                    <cfloop index="thisStatus" list="#FORM.Broker_status#">
													                                      '#thisStatus#'
													                                      <cfset listCount = listCount + 1>
													                                      <!---insert a comma if this status is not the last one in the list--->
													                                      <cfif (listCount lt listSize)>
													                                          ,
													                                      </cfif>
													                                    </cfloop>   
													                                  )
	</cfif>
	AND Deductions.Deleted=0 
	AND Deductions.DD_Rejected=0 
	AND Deductions.DD_Status IN (1,2,3,8)
	<cfif len(trim(form.src_status)) GT 0>
	AND Deductions.DD_Status in ( <!---D42846 :: Deduction tool upgrades--->
					                                    <cfscript>
					                                     listCount = 0;
					                                     listSize  = listLen(FORM.src_status);
					                                    </cfscript>
					                                    <cfloop index="thisStatus" list="#FORM.src_status#">
					                                      #thisStatus#
					                                      <cfset listCount = listCount + 1>
					                                      <!---insert a comma if this status is not the last one in the list--->
					                                      <cfif (listCount lt listSize)>
					                                          ,
					                                      </cfif>
					                                    </cfloop>   
					                                  )
	</cfif>
	<cfif isdefined('form.src_Reason_Code') AND len(trim(form.src_Reason_Code)) GT 0>
	AND Deductions.DD_Resolution_Code in ( <!---D42846 :: Deduction tool upgrades--->
										                                    <cfscript>
										                                     listCount = 0;
										                                     listSize  = listLen(FORM.src_Reason_Code);
										                                    </cfscript>
										                                    <cfloop index="thisStatus" list="#FORM.src_Reason_Code#">
										                                      #thisStatus#
										                                      <cfset listCount = listCount + 1>
										                                      <!---insert a comma if this status is not the last one in the list--->
										                                      <cfif (listCount lt listSize)>
										                                          ,
										                                      </cfif>
										                                    </cfloop>   
										                                  )
	</cfif>
	<cfif isdefined('form.Src_Classification') AND len(trim(form.Src_Classification)) GT 0>
	AND DD_Classification_ID in (
						                                <cfscript>
					                                     listCount = 0;
					                                     listSize  = listLen(FORM.Src_Classification);
					                                    </cfscript>
					                                    <cfloop index="thisStatus" list="#FORM.Src_Classification#">
					                                      #thisStatus#
					                                      <cfset listCount = listCount + 1>
					                                      <!---insert a comma if this status is not the last one in the list--->
					                                      <cfif (listCount lt listSize)>
					                                          ,
					                                      </cfif>
					                                    </cfloop>   													
														)
	</cfif>
	<cfif isdefined('form.src_stage') AND len(trim(form.src_stage)) GT 0>
	AND Deductions.DD_Stage in (
						                                <cfscript>
					                                     listCount = 0;
					                                     listSize  = listLen(FORM.src_stage);
					                                    </cfscript>
					                                    <cfloop index="thisStage" list="#FORM.src_stage#">
					                                      #thisStage#
					                                      <cfset listCount = listCount + 1>
					                                      <!---insert a comma if this status is not the last one in the list--->
					                                      <cfif (listCount lt listSize)>
					                                          ,
					                                      </cfif>
					                                    </cfloop>   													
														)
	</cfif>
	ORDER BY 	<CFIF FORM.SORT_BY EQ "DD_DedID">
					DD_DedID,SP_Number 
				<CFELSE>
					#FORM.SORT_BY# 
				</CFIF>
				#FORM.SORT_ORDER#
</CFQUERY>

<CFQUERY NAME="Get_Max_Aging" DATASOURCE="#Application.Datasource#">
	SELECT 	* 
	FROM 	DD_Aging 
	WHERE 	Tier_Number = (	SELECT 	MAX(Tier_Number)  
												FROM 	DD_Aging 
												WHERE 	Deleted=0	) 
	AND 	Deleted=0
</CFQUERY>

<cfquery name="GetSearchedStatusDesc" datasource="#application.datasource#">
SELECT DD_Status_Description 
FROM DD_Status 
WHERE DD_Status_ID <cfif listLen(FORM.src_status)>
											in ( <!---D42846 :: Deduction tool upgrades--->
			                                    <cfscript>
			                                     listCount = 0;
			                                     listSize  = listLen(FORM.src_status);
			                                    </cfscript>
			                                    <cfloop index="thisStatus" list="#FORM.src_status#">
			                                      #thisStatus#
			                                      <cfset listCount = listCount + 1>
			                                      <!---insert a comma if this status is not the last one in the list--->
			                                      <cfif (listCount lt listSize)>
			                                          ,
			                                      </cfif>
			                                    </cfloop>   
			                                  )
									  <cfelse>
									=  '#FORM.src_status#'
				   					  </cfif>
</cfquery>

<cfif GetSearchedStatusDesc.Recordcount IS 1>
	<cfset Status_Descriptor = GetSearchedStatusDesc.DD_Status_Description>
<cfelse>
	<Cfset Status_Descriptor = "Active">
</cfif>

<STYLE>
TABLE.BorderTable TD 
{
	border-bottom:solid #93BEE2 1px;
}
</STYLE>

<CFSET LastAgeEndRange = Get_Max_Aging.Start_Range>
<CFSET LastAgeLabel = Get_Max_Aging.DD_Aging_Label>
<FORM NAME="Select_DD" ACTION="Select_DD_BulkReassign.cfm" METHOD="POST">
<CFOUTPUT>
<INPUT TYPE="hidden" VALUE = "#FORM.SORT_BY#" NAME="SORT_BY">
<INPUT TYPE="hidden" VALUE = "#FORM.SORT_ORDER#" NAME="SORT_ORDER">
<INPUT TYPE="hidden" VALUE = "#FORM.Src_Analyst#" NAME="Src_Analyst">
<INPUT TYPE="hidden" VALUE = "#FORM.Tar_Analyst#" NAME="Tar_Analyst">
<INPUT TYPE="hidden" VALUE = "#FORM.Tar_Classification#" NAME="Tar_Classification"><!--- D33578 Ability to reclass when reassigning deduction --->
<INPUT TYPE="hidden" VALUE = "#FORM.frompage#" NAME="frompage">
<INPUT TYPE="hidden" VALUE = "#FORM.StartRow#" NAME="startrow">
<INPUT TYPE="Hidden" VALUE ="#FORM.Already_Selected_List#" NAME="Already_Selected_List">
<INPUT TYPE="Hidden" VALUE ="#FORM.src_status#" NAME="src_status">
<INPUT TYPE="Hidden" VALUE ="#FORM.Distributor_ID#" NAME="Distributor_ID">
<INPUT TYPE="Hidden" VALUE ="#FORM.Distributor_List#" NAME="Distributor_List">
<INPUT TYPE="Hidden" VALUE ="#FORM.Distributor_Status#" NAME="Distributor_Status">
<INPUT TYPE="Hidden" VALUE ="#FORM.Broker_ID#" NAME="Broker_ID">
<INPUT TYPE="Hidden" VALUE ="#FORM.Broker_List#" NAME="Broker_List">
<INPUT TYPE="Hidden" VALUE ="#FORM.Broker_Status#" NAME="Broker_Status">
</CFOUTPUT>
<BR>
<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
<CFOUTPUT><LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF GetDDDetails.Recordcount GT 1>are<CFELSE>is</CFIF> #GetDDDetails.Recordcount# result<CFIF GetDDDetails.Recordcount GT 1>s</CFIF> that match the above criteria</LEGEND></CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" CLASS="BorderTable">
	<TR BGCOLOR="FFE083">
		<TD><INPUT TYPE="CheckBox" NAME="allbox" ONCLICK="javaScript: selectAll(this);"></TD>
		<CFSET A_Header_Name_List = "DEDUCTION ##,STATUS,$ AMOUNT,#application.returned_customer_setting.distributor_label_singular#,&nbsp;AGE,&nbsp;ACTION,BROKER,REGION">
		<CFSET A_Header_Value_List = "DD_DedID,DD_Status,DD_Amount,Name,DD_Date,DD_Stage_Description,Broker_Name,Region_Name">
		<CFSET Header_Width_List = "90,140,83,110,150,190,86,88">
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
			<A HREF="##" onClick="javaSCript: return sort_by_this_order('#ThisHeaderItem#', '#thisSortOrder#');"><B>#ThisHeaderItemName#</B></A><CFIF ThisHeaderItem EQ FORM.SORT_BY>&nbsp;<IMG SRC="#Image_Name#" BORDER="0"></CFIF>			
			<CFIF ThisHeaderItem NEQ "DD_Amount" AND ThisHeaderItem NEQ "DD_Date" AND ThisHeaderItem NEQ "Broker_Name">
			</TD>			
			</CFIF>						
			<CFSET Counter = Counter + 1>
		</CFLOOP>
		</CFOUTPUT>
	</TR>	
	<CFSET Items_OnThis_Page = "">

	<!--- We have removed pagination on this page
	<CFOUTPUT QUERY="GetDDDetails" startrow="#StartRow#" maxrows="#MaxRows#">
	--->
	<CFOUTPUT QUERY="GetDDDetails">
		<CFSET Items_OnThis_Page = ListAppend(Items_OnThis_Page,Deduction_ID,",")>	
		
		<CFQUERY NAME="CheckLock" DATASOURCE="#Application.Datasource#">
			SELECT 		Deductions.Is_Locked, Locked_By, Name_First, Name_Last 
			FROM 		Deductions 
			INNER JOIN	_Users 
			ON _Users.User_ID = Deductions.Locked_By 
			AND _Users.Deleted=0
			WHERE 		Deduction_ID = '#Deduction_ID#' 
		</CFQUERY>

		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD <CFOUTPUT><CFIF CheckLock.Is_Locked EQ 1>TITLE="This deduction is locked by #CheckLock.Name_First# #CheckLock.Name_Last#"</CFIF></CFOUTPUT>><INPUT TYPE="CheckBox" NAME="Deduction_ID" VALUE="#Deduction_ID#" <CFIF ListFindNoCase(FORM.Already_Selected_List,Deduction_ID,",")>CHECKED</CFIF> <CFIF CheckLock.Is_Locked EQ 1>DISABLED</CFIF> ></TD>
			<TD NOWRAP><B>[ #DD_DedID_SP_Number#<!--- #DD_DedID# - <CFIF SP_Number EQ "">000<CFELSE>#SP_Number#</CFIF>---> ]</B></TD>
			<TD>#DD_Status_Description#</TD>
			<TD TITLE="#application.returned_customer_setting.billto_label#: #Shr_Bill_To#">#DollarFormat(DD_Amount)#<BR>#Name#</TD>			
			<TD>
				<CFSET NumberOfDays = DateDiff("d",DateFormat(DD_Date,"mm/dd/yyyy"),DateFormat(now(),"mm/dd/yyyy"))>
				<CFIF NumberOfDays GTE LastAgeEndRange>
					#LastAgeLabel# (#NumberOfDays# days)
				<CFELSE>
				<CFQUERY NAME="Get_Aging_Details" DATASOURCE="#Application.Datasource#">
					SELECT * 
					FROM DD_Aging 
					WHERE Deleted=0 
					AND Start_Range <= '#NumberOfDays#' 
					AND End_Range >= '#NumberOfDays#'
				</CFQUERY>	
				#Get_Aging_Details.DD_Aging_Label# (#NumberOfDays# days)
				</CFIF><BR>
				#DD_Stage_Description#				
			</TD>
			<TD>#Broker_Name#<BR>#Region_Name#</TD>
		</TR>
	</CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="Items_OnThis_Page" VALUE=<CFOUTPUT>"#Items_OnThis_Page#"</CFOUTPUT>>	
	<TR>
		<TD COLSPAN="100%" STYLE="Border:None"></TD>
	</TR>
</TABLE>
<cfset useLakebaseForGetAnalyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetAnalyst>
	<cftry>
		<cfset GetAnalyst = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"select" = "name_first,name_last",
				"user_id" = "eq.#GetDDDetails.Analyst_User_ID#",
				"deleted" = "eq.0"
			}),
			"name_first,name_last"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetAnalyst = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAnalyst>
<CFQUERY NAME="GetAnalyst" DATASOURCE="#Application.Datasource#">
	SELECT 	Name_First, Name_Last 
	FROM 	_Users 
	WHERE 	User_ID='#GetDDDetails.Analyst_User_ID#' 
	AND Deleted=0
</CFQUERY>
</cfif>
<!--- We have removed pagination on this page
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
	<TR>
		<TD>
			<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<CF_Next_Previous_For_Forms
				formname="Select_DD"
				query="GetDDDetails"
				maxpages="15"
				previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams="">
			</DIV>
		</TD>
	</TR>
</TABLE>
--->
<BR><BR> 
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
	<TR>
		<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HRef="##" ONCLICK="Javascript: SubmitToReDeductions()">import selected deductions</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;&nbsp;</TD>
		<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HRef="##" ONCLICK="Javascript: UncheckAll()">undo selections</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;&nbsp;</TD>
		<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HRef="##" ONCLICK="Javascript: Closewindow()">back to reassign deductions</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
	</TR>
</TABLE>   
</FIELDSET>
<input type="hidden" value="0" name="finishedSearching">
</FORM>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT language="JavaScript">
function SubmitToReDeductions()
{	
	if(Any_Object_Checked(document.all.Deduction_ID))
	{
		document.Select_DD.finishedSearching.value = 1;
		document.Select_DD.submit();			
	}
	else
	{
		alert("Please select at least one deduction to import.")
	}
}
function selectAll(thisobj)
{
	var bCheck = thisobj.checked;
	var chObjs = document.all.Deduction_ID;
	if(chObjs.length)
	{
		var chObjLen = chObjs.length;
		var i;
		for(i=0;i<chObjLen;i++)
		{
			chObjs[i].checked = bCheck;
		}
	}
	else
	{
		chObjs.checked = bCheck;
	}	
}

function UncheckAll()
{
	/* true or false based on browser - IE 10 and above or IE 9 and below. 
	'0' as an argument below means "false". */
	document.all.allbox.checked = checkOrUncheckBeforeFireEvent(0);
	callfireEvent(document,document.all.allbox,'Click');

	document.Select_DD.Already_Selected_List.value="";
	document.Select_DD.Deduction_ID.value="";
}
function Closewindow()
{
	window.close();
}

function sort_by_this_order(fieldName, sOrder)
{
	var oForm = document.Select_DD;
	oForm.SORT_BY.value = fieldName;
	oForm.SORT_ORDER.value = sOrder;
	oForm.submit();
	return false;
}	
</SCRIPT>

</body>
</html>
