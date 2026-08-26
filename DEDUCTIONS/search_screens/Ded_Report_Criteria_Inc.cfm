

<TABLE WIDTH="98%" CELLPADDING="1" CELLSPACING="0" CLASS="UnBorderTable">
	<CFIF FORM.CommunicationType EQ "">
		<TR>
			<TD COLSPAN="100%"></TD>
		</TR>
	</CFIF>
	<TR>
		<TD WIDTH="10%"><B>Deduction #:</B></TD>
		<TD WIDTH="15%" STYLE="Border-bottom:solid #93BEE2 1px;"><CFOUTPUT><CFIF FORM.DD_Number NEQ "">#FORM.DD_Number#<CFELSE>#na#</CFIF></CFOUTPUT></TD>
		<TD WIDTH="10%">&nbsp;&nbsp;<B>Status:</B></TD>
		<TD WIDTH="15%" STYLE="Border-bottom:solid #93BEE2 1px;">
		<CFOUTPUT>
		<CFIF FORM.DD_Status NEQ "">
			<cfset useLakebaseForCri_Status = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_status")>
<cfif useLakebaseForCri_Status>
<cftry>
<cfset Cri_Status = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_status", {
"select" = "dd_status_description",
"dd_status_id" = "in.(#FORM.DD_Status#)"
}),
"dd_status_description"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_Status = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_Status><CFQUERY NAME="Cri_Status" DATASOURCE="#Application.Datasource#">
				SELECT 	DD_Status_Description 
				FROM 		DD_Status 
				WHERE 	DD_Status_ID in ( <!---26491--->
						                                    <cfscript>
						                                     listCount = 0;
						                                     listSize  = listLen(FORM.DD_Status);
						                                    </cfscript>
						                                    <cfloop index="thisStatus" list="#FORM.DD_Status#">
						                                      #thisStatus#
						                                      <cfset listCount = listCount + 1>
						                                      <!---insert a comma if this status is not the last one in the list--->
						                                      <cfif (listCount lt listSize)>
						                                          ,
						                                      </cfif>
						                                    </cfloop>   
						                                  )
			</CFQUERY>
</cfif>
			
				<cfif Cri_Status.recordCount gt 1>
				  	#Cri_Status.recordCount# selected
				<cfelse>
		  			<cfloop query="Cri_Status">
						#Cri_Status.DD_Status_Description#
		  			</cfloop>
	  			</cfif>
	  			
		<CFELSE>
		#na#
		</CFIF>	
		</CFOUTPUT>												
		</TD>
		<TD WIDTH="10%">&nbsp;&nbsp;<B><cfoutput>#application.returned_customer_setting.shard_ship_to_label#</cfoutput>:</B></TD>
		<TD WIDTH="15%" STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.Distributor_List NEQ "" OR FORM.Distributor_ID NEQ "">
				<cfset useLakebaseForCri_Distri = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForCri_Distri>
<cftry>
<cfset qCri_Distri_ids = (FORM.Distributor_List NEQ "") ? FORM.Distributor_List : FORM.Distributor_ID>
<cfset Cri_Distri = application.oLakebase.toQuery(
application.oLakebase.selectRows("bsa_foodservice_customers", {
"select" = "name",
"bsa_foodservice_customers_id" = "in.(#qCri_Distri_ids#)"
}),
"name"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_Distri = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_Distri><CFQUERY NAME="Cri_Distri" DATASOURCE="#Application.Datasource#">
					SELECT 	NAME 
					FROM 		BSA_Foodservice_Customers 
					WHERE 	BSA_Foodservice_Customers_ID IN
																							<cfif FORM.Distributor_List NEQ ""> 
																							(#ListQualify(FORM.Distributor_List, "'", ",")#)
																							<cfelseif FORM.Distributor_ID NEQ "">
																							(#ListQualify(FORM.Distributor_ID, "'", ",")#)
																							</cfif>
																						</CFQUERY>
</cfif>
																						#Cri_Distri.NAME#
																					<CFELSE>
																						#na#
																					</CFIF>
			</CFOUTPUT>
		</TD>
		<TD WIDTH="10%">&nbsp;&nbsp;<B><cfoutput>#application.returned_customer_setting.zone_label_singular#:</cfoutput></B></TD>
		<TD WIDTH="15%" STYLE="Border-bottom:solid #93BEE2 1px;">							
			<CFOUTPUT>
			<CFIF FORM.Service_Zone_ID NEQ "">
				<cfset useLakebaseForCri_Zone = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_zones")>
<cfif useLakebaseForCri_Zone>
<cftry>
<cfset Cri_Zone = application.oLakebase.toQuery(
application.oLakebase.selectRows("service_zones", {
"select" = "zone_name",
"service_zone_id" = "in.(#FORM.Service_Zone_ID#)"
}),
"zone_name"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_Zone = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_Zone><CFQUERY NAME="Cri_Zone" DATASOURCE="#Application.Datasource#">
					SELECT 	Zone_Name 
					FROM 		Service_Zones 
					WHERE 	Service_Zone_ID  in ( <!---D42846 :: Deduction tool upgrades--->
								                                    <cfscript>
								                                     listCount = 0;
								                                     listSize  = listLen(FORM.Service_Zone_ID);
								                                    </cfscript>
								                                    <cfloop index="thisStatus" list="#FORM.Service_Zone_ID#">
								                                       '#thisStatus#'
								                                      <cfset listCount = listCount + 1>
								                                      <!---insert a comma if this status is not the last one in the list--->
								                                      <cfif (listCount lt listSize)>
								                                          ,
								                                      </cfif>
								                                    </cfloop>   
								                                  )
				</CFQUERY>
</cfif>

					<cfif Cri_Zone.recordCount gt 1>
					  	#Cri_Zone.recordCount# selected
					<cfelse>
			  			<cfloop query="Cri_Zone">
						#Cri_Zone.Zone_Name#
			  			</cfloop>
					</cfif>

			<CFELSE>
				#na#
			</CFIF>
			</CFOUTPUT>
		</TD>							
	</TR>
	<TR>
		<TD><B>Date:</B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.Date_Time NEQ "">
				<CFIF FORM.Date_Operator NEQ "Between">
					#FORM.Date_Operator#
				</CFIF>
				#FORM.Date_Time# 
				<CFIF FORM.Date_Operator EQ "Between">
				- #To_Date_Time#
				</CFIF>
			<CFELSE>
				#na#
			</CFIF>								
			</CFOUTPUT>
		</TD>

		<TD>&nbsp;&nbsp;<B>Deduction Analyst:</B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.Analyst_User_ID NEQ "">
				<cfset useLakebaseForCri_Analyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForCri_Analyst>
<cftry>
<cfset Cri_Analyst = application.oLakebase.toQuery(
application.oLakebase.selectRows("_users", {
"select" = "name_first,name_last",
"user_id" = "in.(#FORM.Analyst_User_ID#)"
}),
"name_first,name_last"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_Analyst = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_Analyst><CFQUERY NAME="Cri_Analyst" DATASOURCE="#Application.Datasource#">
					SELECT 	Name_First, Name_Last 
					FROM 		_Users 
					WHERE 	_Users.User_ID  in ( <!---D42846 :: Deduction tool upgrades--->
								                                    <cfscript>
								                                     listCount = 0;
								                                     listSize  = listLen(FORM.Analyst_User_ID);
								                                    </cfscript>
								                                    <cfloop index="thisStatus" list="#FORM.Analyst_User_ID#">
								                                       '#thisStatus#'
								                                      <cfset listCount = listCount + 1>
								                                      <!---insert a comma if this status is not the last one in the list--->
								                                      <cfif (listCount lt listSize)>
								                                          ,
								                                      </cfif>
								                                    </cfloop>   
								                                  )
				</CFQUERY>
</cfif>

					<cfif Cri_Analyst.recordCount gt 1>
					  	#Cri_Analyst.recordCount# selected
					<cfelse>
			  			<cfloop query="Cri_Analyst">
						#Cri_Analyst.Name_First# #Cri_Analyst.Name_Last#
			  			</cfloop>
					</cfif>
				
			<CFELSE>
				#na#
			</CFIF>
			</CFOUTPUT>
		</TD>
		<TD>&nbsp;&nbsp;<B><CFOUTPUT>#application.returned_customer_setting.broker_label_singular#:</CFOUTPUT></B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.Broker_List NEQ "">
				<cfset useLakebaseForCri_Brok = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_brokers")>
<cfif useLakebaseForCri_Brok>
<cftry>
<cfset Cri_Brok = application.oLakebase.toQuery(
application.oLakebase.selectRows("bsa_foodservice_brokers", {
"select" = "broker_name",
"bsa_foodservice_brokers_id" = "eq.#FORM.Broker_List#"
}),
"broker_name"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_Brok = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_Brok><CFQUERY NAME="Cri_Brok" DATASOURCE="#Application.Datasource#">
					SELECT 	Broker_Name 
					FROM 		BSA_Foodservice_Brokers 
					WHERE 	BSA_Foodservice_Brokers_ID = '#FORM.Broker_List#'
				</CFQUERY>
</cfif>
				#Cri_Brok.Broker_Name#
			<CFELSE>	
				#na#
			</CFIF>
			</CFOUTPUT>
		</TD>
		<TD>&nbsp;&nbsp;<B><CFOUTPUT>#application.returned_customer_setting.region_label_singular#:</CFOUTPUT></B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.Service_Region_ID NEQ "">
				<cfset useLakebaseForCri_Region = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_regions")>
<cfif useLakebaseForCri_Region>
<cftry>
<cfset Cri_Region = application.oLakebase.toQuery(
application.oLakebase.selectRows("service_regions", {
"select" = "region_name",
"service_region_id" = "in.(#FORM.Service_Region_ID#)"
}),
"region_name"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_Region = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_Region><CFQUERY NAME="Cri_Region" DATASOURCE="#Application.Datasource#">
					SELECT 	Region_Name 
					FROM 		Service_Regions
					WHERE 	Service_Region_ID in ( <!---D42846 :: Deduction tool upgrades--->
									                                    <cfscript>
									                                     listCount = 0;
									                                     listSize  = listLen(FORM.Service_Region_ID);
									                                    </cfscript>
									                                    <cfloop index="thisStatus" list="#FORM.Service_Region_ID#">
									                                       #PreserveSingleQuotes(thisStatus)#
									                                      <cfset listCount = listCount + 1>
									                                      <!---insert a comma if this status is not the last one in the list--->
									                                      <cfif (listCount lt listSize)>
									                                          ,
									                                      </cfif>
									                                    </cfloop>   
									                                  )
				</CFQUERY>
</cfif>

					<cfif Cri_Region.recordCount gt 1>
					  	#Cri_Region.recordCount# selected
					<cfelse>
			  			<cfloop query="Cri_Region">
						#Cri_Region.Region_Name#
			  			</cfloop>
					</cfif>

			<CFELSE>
				#na#
			</CFIF>
			</CFOUTPUT>
		</TD>
	</TR>
	<TR>
		<TD><B>Amount:</B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.DD_Amount NEQ "">	
				<CFIF FORM.Dollar_Operator NEQ "Between">
					#FORM.Dollar_Operator#
				</CFIF>								
				#FORM.DD_Amount# 
				<CFIF FORM.Dollar_Operator EQ "Between">
				- #FORM.DD_To_Amount#
				</CFIF>
			<CFELSE>
				#na#
			</CFIF>								
			</CFOUTPUT>
		</TD>
		<TD>&nbsp;&nbsp;<B>Current <cfoutput>#stDeductionLabels["Action"]#</cfoutput>:</B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.DD_Stage_ID NEQ "">
				<cfset useLakebaseForCri_Stage = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
<cfif useLakebaseForCri_Stage>
<cftry>
<cfset Cri_Stage = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_stage", {
"select" = "dd_stage_description",
"dd_stage_id" = "in.(#FORM.DD_Stage_ID#)"
}),
"dd_stage_description"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_Stage = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_Stage><CFQUERY NAME="Cri_Stage" DATASOURCE="#Application.Datasource#">
					SELECT 	DD_Stage_Description 
					FROM 		DD_Stage 
					WHERE 	DD_Stage_ID in ( <!---D42846 :: Deduction tool upgrades--->
						                                    <cfscript>
						                                     listCount = 0;
						                                     listSize  = listLen(FORM.DD_Stage_ID);
						                                    </cfscript>
						                                    <cfloop index="thisStatus" list="#FORM.DD_Stage_ID#">
						                                      #thisStatus#
						                                      <cfset listCount = listCount + 1>
						                                      <!---insert a comma if this status is not the last one in the list--->
						                                      <cfif (listCount lt listSize)>
						                                          ,
						                                      </cfif>
						                                    </cfloop>   
						                                  )
				</CFQUERY>
</cfif>

					<cfif Cri_Stage.recordCount gt 1>
					  	#Cri_Stage.recordCount# selected
					<cfelse>
			  			<cfloop query="Cri_Stage">
						#Cri_Stage.DD_Stage_Description#
			  			</cfloop>
					</cfif>

			<CFELSE>
				#na#
			</CFIF>
			</CFOUTPUT>
		</TD>
		<TD>&nbsp;&nbsp;<B><cfoutput>#application.returned_customer_setting.family_name_label_singular#:</cfoutput></B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.Family_ID NEQ "">
				<cfset useLakebaseForCri_Family = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_family")>
<cfif useLakebaseForCri_Family>
<cftry>
<cfset Cri_Family = application.oLakebase.toQuery(
application.oLakebase.selectRows("distributor_family", {
"select" = "family_name",
"family_id" = "in.(#FORM.Family_ID#)"
}),
"family_name"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_Family = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_Family><CFQUERY NAME="Cri_Family" DATASOURCE="#Application.Datasource#">
					SELECT Family_Name 
					FROM Distributor_Family 
					WHERE Family_ID in ( <!---D42846 :: Deduction tool upgrades--->
				                                    <cfscript>
				                                     listCount = 0;
				                                     listSize  = listLen(FORM.Family_ID);
				                                    </cfscript>
				                                    <cfloop index="thisStatus" list="#FORM.Family_ID#">
				                                       '#thisStatus#'
				                                      <cfset listCount = listCount + 1>
				                                      <!---insert a comma if this status is not the last one in the list--->
				                                      <cfif (listCount lt listSize)>
				                                          ,
				                                      </cfif>
				                                    </cfloop>   
				                                  )
				</CFQUERY>
</cfif>

					<cfif Cri_Family.recordCount gt 1>
					  	#Cri_Family.recordCount# selected
					<cfelse>
			  			<cfloop query="Cri_Family">
						#Cri_Family.Family_Name#
			  			</cfloop>
					</cfif>


			<CFELSE>
			#na#
			</CFIF>
			</CFOUTPUT>
		</TD>
		<TD>&nbsp;&nbsp;<B><CFOUTPUT>#application.returned_customer_setting.market_label_singular#:</CFOUTPUT></B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.Service_Market_ID NEQ "">
				<cfset useLakebaseForCri_Market = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_markets")>
<cfif useLakebaseForCri_Market>
<cftry>
<cfset Cri_Market = application.oLakebase.toQuery(
application.oLakebase.selectRows("service_markets", {
"select" = "market_name",
"service_market_id" = "in.(#FORM.Service_Market_ID#)"
}),
"market_name"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_Market = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_Market><CFQUERY NAME="Cri_Market" DATASOURCE="#Application.Datasource#">
					SELECT Market_Name 
					FROM Service_Markets 
					WHERE Service_Market_ID in ( <!---D42846 :: Deduction tool upgrades--->
								                                    <cfscript>
								                                     listCount = 0;
								                                     listSize  = listLen(FORM.Service_Market_ID);
								                                    </cfscript>
								                                    <cfloop index="thisStatus" list="#FORM.Service_Market_ID#">
								                                      	#PreserveSingleQuotes(thisStatus)#
								                                      <cfset listCount = listCount + 1>
								                                      <!---insert a comma if this status is not the last one in the list--->
								                                      <cfif (listCount lt listSize)>
								                                          ,
								                                      </cfif>
								                                    </cfloop>   
								                                  )
				</CFQUERY>
</cfif>

					<cfif Cri_Market.recordCount gt 1>
					  	#Cri_Market.recordCount# selected
					<cfelse>
			  			<cfloop query="Cri_Market">
						#Cri_Market.Market_Name#
			  			</cfloop>
					</cfif>

			<CFELSE>
				#na#
			</CFIF>
			</CFOUTPUT>
		</TD>
	</TR>
	<TR>
		<TD><B>Closed Date:</B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.ClDate_Time NEQ "">
				<CFIF FORM.ClDate_Operator NEQ "Between">
					#FORM.ClDate_Operator#
				</CFIF>
				#FORM.ClDate_Time# 
				<CFIF FORM.ClDate_Operator EQ "Between">
				- #ClTo_Date_Time#
				</CFIF>
			<CFELSE>
				#na#
			</CFIF>								
			</CFOUTPUT>
		</TD>
		<TD>&nbsp;&nbsp;<B><cfoutput>#stDeductionLabels["Reason Code"]#</cfoutput>:</B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.DD_Reason_Code_ID NEQ "">
				<cfset useLakebaseForCri_ReasonCode = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reason_code")>
<cfif useLakebaseForCri_ReasonCode>
<cftry>
<cfset Cri_ReasonCode = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_reason_code", {
"select" = "dd_reason_code_description",
"dd_reason_code_id" = "in.(#FORM.DD_Reason_Code_ID#)"
}),
"dd_reason_code_description"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_ReasonCode = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_ReasonCode><CFQUERY NAME="Cri_ReasonCode" DATASOURCE="#Application.Datasource#">
					SELECT DD_Reason_Code_Description 
					FROM DD_Reason_Code 
					WHERE DD_Reason_Code_ID in ( <!---D42846 :: Deduction tool upgrades--->
										                                    <cfscript>
										                                     listCount = 0;
										                                     listSize  = listLen(FORM.DD_Reason_Code_ID);
										                                    </cfscript>
										                                    <cfloop index="thisStatus" list="#FORM.DD_Reason_Code_ID#">
										                                      #thisStatus#
										                                      <cfset listCount = listCount + 1>
										                                      <!---insert a comma if this status is not the last one in the list--->
										                                      <cfif (listCount lt listSize)>
										                                          ,
										                                      </cfif>
										                                    </cfloop>   
										                                  )
				</CFQUERY>
</cfif>

					<cfif Cri_ReasonCode.recordCount gt 1>
					  	#Cri_ReasonCode.recordCount# selected
					<cfelse>
			  			<cfloop query="Cri_ReasonCode">
							#Cri_ReasonCode.DD_Reason_Code_Description#
			  			</cfloop>
					</cfif>

				
			<CFELSE>
				#na#
			</CFIF>
			</CFOUTPUT>
		</TD>
		<TD>&nbsp;&nbsp;<B><cfoutput>#application.returned_customer_setting.billto_label#</cfoutput>:</B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.Distributor_Bill_To_ID NEQ "">
				<cfset useLakebaseForCri_BillTo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_bill_to")>
<cfif useLakebaseForCri_BillTo>
<cftry>
<cfset Cri_BillTo = application.oLakebase.toQuery(
application.oLakebase.selectRows("distributor_bill_to", {
"select" = "name",
"distributor_bill_to_id" = "eq.#FORM.Distributor_Bill_To_ID#"
}),
"name"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_BillTo = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_BillTo><CFQUERY NAME="Cri_BillTo" DATASOURCE="#Application.Datasource#">
					SELECT 	Name 
					FROM 		Distributor_Bill_To 
					WHERE 	Distributor_Bill_To_ID = '#FORM.Distributor_Bill_To_ID#'
				</CFQUERY>
</cfif>
				#Cri_BillTo.Name#
			<CFELSE>
				#na#
			</CFIF>
			</CFOUTPUT>
		</TD>
		<cfif application.returned_customer_setting.lob_search_switch EQ 1>
		<TD>&nbsp;&nbsp;<B><cfoutput>#application.returned_customer_setting.lob_label_singular#:</cfoutput></B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.Line_Of_Business_ID NEQ "">
				<cfset useLakebaseForCri_LOB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("line_of_business")>
<cfif useLakebaseForCri_LOB>
<cftry>
<cfset Cri_LOB = application.oLakebase.toQuery(
application.oLakebase.selectRows("line_of_business", {
"select" = "line_of_business_name,line_of_business",
"line_of_business_id" = "in.(#FORM.Line_Of_Business_ID#)"
}),
"line_of_business_name,line_of_business"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_LOB = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_LOB><CFQUERY NAME="Cri_LOB" DATASOURCE="#Application.Datasource#">
					SELECT 	Line_Of_Business_Name, Line_Of_Business 
					FROM 		Line_Of_Business 
					WHERE 	Line_Of_Business_ID in ( <!---D42846 :: Deduction tool upgrades--->
									                                    <cfscript>
									                                     listCount = 0;
									                                     listSize  = listLen(FORM.Line_Of_Business_ID);
									                                    </cfscript>
									                                    <cfloop index="thisStatus" list="#FORM.Line_Of_Business_ID#">
									                                      #PreserveSingleQuotes(thisStatus)#
									                                      <cfset listCount = listCount + 1>
									                                      <!---insert a comma if this status is not the last one in the list--->
									                                      <cfif (listCount lt listSize)>
									                                          ,
									                                      </cfif>
									                                    </cfloop>   
									                                  )
				</CFQUERY>
</cfif>

					<cfif Cri_LOB.recordCount gt 1>
					  	#Cri_LOB.recordCount# selected
					<cfelse>
			  			<cfloop query="Cri_LOB">
							#Cri_LOB.Line_Of_Business_Name# (#Cri_LOB.Line_Of_Business#)
			  			</cfloop>
					</cfif>

				
			<CFELSE>
				#na#
			</CFIF>
			</CFOUTPUT>
		</TD>
		</cfif>
	</TR>
	<TR>
		<TD><B>Aging:</B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
		<CFIF FORM.DD_Aging NEQ "">
				<cfset useLakebaseForCri_Age = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_aging")>
<cfif useLakebaseForCri_Age>
<cftry>
<cfset Cri_Age = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_aging", {
"select" = "dd_aging_label",
"tier_number" = "in.(#FORM.DD_Aging#)",
"deleted" = "eq.0"
}),
"dd_aging_label"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_Age = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_Age><CFQUERY NAME="Cri_Age" DATASOURCE="#Application.Datasource#">
					SELECT 	DD_Aging_Label 
					FROM 		DD_Aging 
					WHERE 	Tier_number in ( <!---D42846 :: Deduction tool upgrades--->
						                                    <cfscript>
						                                     listCount = 0;
						                                     listSize  = listLen(FORM.DD_Aging);
						                                    </cfscript>
						                                    <cfloop index="thisStatus" list="#FORM.DD_Aging#">
						                                      #thisStatus#
						                                      <cfset listCount = listCount + 1>
						                                      <!---insert a comma if this status is not the last one in the list--->
						                                      <cfif (listCount lt listSize)>
						                                          ,
						                                      </cfif>
						                                    </cfloop>   
						                                  )	AND Deleted = 0
				</CFQUERY>
</cfif>
			
					<cfif Cri_Age.recordCount gt 1>
					  	#Cri_Age.recordCount# selected
					<cfelse>
			  			<cfloop query="Cri_Age">
						#Cri_Age.DD_Aging_Label#
			  			</cfloop>
					</cfif>
				
		<CFELSE>
				#na#
		</CFIF>
			</CFOUTPUT>							
		</TD>
		
		<CFIF FORM.IsBusEnabled EQ 1>
			<TD>&nbsp;&nbsp;<B>Business Segment:</B></TD>
			<TD STYLE="Border-bottom:solid #93BEE2 1px;">
				<CFOUTPUT>
				<CFIF FORM.Business_Segment_ID NEQ "">																		
					<cfset useLakebaseForCri_Bus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment")>
<cfif useLakebaseForCri_Bus>
<cftry>
<cfset Cri_Bus = application.oLakebase.toQuery(
application.oLakebase.selectRows("business_segment", {
"select" = "business_unit_desc",
"business_segment_id" = "in.(#FORM.Business_Segment_ID#)"
}),
"business_unit_desc"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_Bus = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_Bus><CFQUERY NAME="Cri_Bus" DATASOURCE="#Application.Datasource#">
						SELECT 	Business_Unit_Desc 
						FROM 		Business_Segment 
						WHERE  	Business_Segment_ID in ( <!---D42846 :: Deduction tool upgrades--->
											                                    <cfscript>
											                                     listCount = 0;
											                                     listSize  = listLen(FORM.Business_Segment_ID);
											                                    </cfscript>
											                                    <cfloop index="thisStatus" list="#FORM.Business_Segment_ID#">
											                                      #thisStatus#
											                                      <cfset listCount = listCount + 1>
											                                      <!---insert a comma if this status is not the last one in the list--->
											                                      <cfif (listCount lt listSize)>
											                                          ,
											                                      </cfif>
											                                    </cfloop>   
											                                  )
					</CFQUERY>
</cfif>		

					<cfif Cri_Bus.recordCount gt 1>
					  	#Cri_Bus.recordCount# selected
					<cfelse>
			  			<cfloop query="Cri_Bus">
						#Cri_Bus.Business_Unit_Desc#
			  			</cfloop>
					</cfif>
						
				<CFELSE>
					#na#
				</CFIF>
				
				</CFOUTPUT>
			</TD>			
			
			<TD>&nbsp;&nbsp;<B>Operating Unit:</B></TD>
			<TD STYLE="Border-bottom:solid #93BEE2 1px;">
				<CFOUTPUT>
				<CFIF FORM.Operating_Unit_ID NEQ "">
					<cfset useLakebaseForSelOpUnit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operating_unit")>
<cfif useLakebaseForSelOpUnit>
<cftry>
<cfset SelOpUnit = application.oLakebase.toQuery(
application.oLakebase.selectRows("operating_unit", {
"operating_unit_id" = "in.(#FORM.Operating_Unit_ID#)"
})
)>
<cfcatch type="any">
<cfset useLakebaseForSelOpUnit = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForSelOpUnit><CFQUERY NAME="SelOpUnit" DATASOURCE="#Application.Datasource#">
						SELECT * 
						FROM 		Operating_Unit 
						WHERE 	Operating_Unit_ID  in ( <!---D42846 :: Deduction tool upgrades--->
										                                    <cfscript>
										                                     listCount = 0;
										                                     listSize  = listLen(FORM.Operating_Unit_ID);
										                                    </cfscript>
										                                    <cfloop index="thisStatus" list="#FORM.Operating_Unit_ID#">
										                                      #thisStatus#
										                                      <cfset listCount = listCount + 1>
										                                      <!---insert a comma if this status is not the last one in the list--->
										                                      <cfif (listCount lt listSize)>
										                                          ,
										                                      </cfif>
										                                    </cfloop>   
										                                  )
					</CFQUERY>
</cfif>

					<cfif SelOpUnit.recordCount gt 1>
					  	#SelOpUnit.recordCount# selected
					<cfelse>
			  			<cfloop query="SelOpUnit">
						#SelOpUnit.Code# - #SelOpUnit.Operating_unit_Description#
			  			</cfloop>
					</cfif>
					
				<CFELSE>
					#na#
				</CFIF>
				</CFOUTPUT>
			</TD>
			
		</CFIF>	
		
		<CFIF application.returned_customer_setting.DD_Show_Operator_For_RC_Of_Accrual EQ 1>
		<TD>&nbsp;&nbsp;<B><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>:</B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			<CFIF FORM.DD_Operator_ID NEQ "">
				<cfset useLakebaseForCri_Op = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_operator")>
<cfif useLakebaseForCri_Op>
<cftry>
<cfset Cri_Op = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_operator", {
"select" = "dd_operator_name",
"dd_operator_id" = "in.(#FORM.DD_Operator_ID#)"
}),
"dd_operator_name"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_Op = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_Op><CFQUERY NAME="Cri_Op" DATASOURCE="#Application.Datasource#">
					SELECT 	DD_Operator_Name 
					FROM 		DD_Operator 
					WHERE 	DD_Operator_ID  in ( <!---D42846 :: Deduction tool upgrades--->
								                                    <cfscript>
								                                     listCount = 0;
								                                     listSize  = listLen(FORM.DD_Operator_ID);
								                                    </cfscript>
								                                    <cfloop index="thisStatus" list="#FORM.DD_Operator_ID#">
								                                      #thisStatus#
								                                      <cfset listCount = listCount + 1>
								                                      <!---insert a comma if this status is not the last one in the list--->
								                                      <cfif (listCount lt listSize)>
								                                          ,
								                                      </cfif>
								                                    </cfloop>   
								                                  )
				</CFQUERY>
</cfif>
				
				
					<cfif Cri_Op.recordCount gt 1>
					  	#Cri_Op.recordCount# selected
					<cfelse>
			  			<cfloop query="Cri_Op">
						#Cri_Op.DD_Operator_Name#
			  			</cfloop>
					</cfif>

			<CFELSE>
				#na#
			</CFIF>
			</CFOUTPUT>
		</TD>
		</CFIF>
	</TR>
	<TR>
		<CFIF application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1>
		<TD><B>Q Brand:</B></TD>
		<TD STYLE="Border-bottom:solid #93BEE2 1px;">
			<CFOUTPUT>
			 	<CFIF FORM.Q_Brand_ID NEQ "">
					<cfset useLakebaseForCri_QBrand = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("q_brand_desc")>
<cfif useLakebaseForCri_QBrand>
<cftry>
<cfset Cri_QBrand = application.oLakebase.toQuery(
application.oLakebase.selectRows("q_brand_desc", {
"select" = "q_brand",
"q_brand_id" = "in.(#FORM.Q_Brand_ID#)"
}),
"q_brand"
)>
<cfcatch type="any">
<cfset useLakebaseForCri_QBrand = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForCri_QBrand><CFQUERY NAME="Cri_QBrand" DATASOURCE="#Application.Datasource#">
						SELECT 	Q_Brand 
						FROM 		Q_Brand_Desc 
						WHERE 	Q_Brand_ID in ( <!---D42846 :: Deduction tool upgrades--->
							                                    <cfscript>
							                                     listCount = 0;
							                                     listSize  = listLen(FORM.Q_Brand_ID);
							                                    </cfscript>
							                                    <cfloop index="thisStatus" list="#FORM.Q_Brand_ID#">
							                                       #PreserveSingleQuotes(thisStatus)#
							                                      <cfset listCount = listCount + 1>
							                                      <!---insert a comma if this status is not the last one in the list--->
							                                      <cfif (listCount lt listSize)>
							                                          ,
							                                      </cfif>
							                                    </cfloop>   
							                                  )
					</CFQUERY>
</cfif>

					<cfif Cri_QBrand.recordCount gt 1>
					  	#Cri_QBrand.recordCount# selected
					<cfelse>
			  			<cfloop query="Cri_QBrand">
						#Cri_QBrand.Q_Brand#
			  			</cfloop>
					</cfif>


				<CFELSE>
					#na#
				</CFIF>
			</CFOUTPUT>
		</TD>
		</CFIF>
	</TR>
</TABLE>	
