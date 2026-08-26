		<cfloop query="getProfiles">
			<cfset LOOPCOUNT = getProfiles.profiles_id>

			<CFPARAM NAME="BB_CREATE_#LOOPCOUNT#" 					DEFAULT="0">
			<CFPARAM NAME="BB_DELETE_#LOOPCOUNT#" 					DEFAULT="0">
			<!--- Dev Note: Drachala; D27781 : new bb profile settings START--->
			<CFPARAM NAME="BB_CLOSING_METHODS_VIEW_#LOOPCOUNT#" 	DEFAULT="0">
			<CFPARAM NAME="BB_ADJUST_#LOOPCOUNT#" 					DEFAULT="0">
			<CFPARAM NAME="BB_Mass_Approve_#LOOPCOUNT#" 			DEFAULT="0">
			<CFPARAM NAME="BB_Mass_Delete_#LOOPCOUNT#" 				DEFAULT="0">
			<!--- Dev Note: Drachala; D27781 : new bb profile settings END--->
			<CFPARAM NAME="BB_View_Deviation_#LOOPCOUNT#" 			DEFAULT="0">
			<CFPARAM NAME="BB_Approve_#LOOPCOUNT#" 					DEFAULT="0">
			<!--- D28359:Deviation Grid - don't consider volume, only can approve Expected $/ Anand Rao/09-Jan-2012 --->
			<CFPARAM NAME="BB_DevGrid_Expected_#LOOPCOUNT#" 		DEFAULT="0">
			<CFPARAM NAME="BB_DevGrid_ELT_#LOOPCOUNT#" 				DEFAULT="0">
			<CFPARAM NAME="BB_DevGrid_Claimed_#LOOPCOUNT#" 			DEFAULT="0">
			<CFPARAM NAME="BB_DevGrid_Selected_#LOOPCOUNT#" 		DEFAULT="0">

			<CFPARAM NAME="BB_Approve_Amount_#LOOPCOUNT#" 			DEFAULT=0>
			<CFPARAM NAME="BB_Tot_Approve_Amount_#LOOPCOUNT#" 		DEFAULT=0>
			<CFPARAM NAME="BB_Approve_Critical_#LOOPCOUNT#" 		DEFAULT="0">
			<CFPARAM NAME="BB_RFA_Agreed_#LOOPCOUNT#" 				DEFAULT="0">
			<CFPARAM NAME="BB_Pay_Req_Approval_Amount_#LOOPCOUNT#" 	DEFAULT="0">
			<CFPARAM NAME="Approve_Last_Date_To_Claim_#LOOPCOUNT#" 	DEFAULT="0">
			<CFPARAM NAME="BB_Reverse_#LOOPCOUNT#" 					DEFAULT="0">
			<CFPARAM NAME="Autopay_Reverse_#LOOPCOUNT#" 			DEFAULT="0">
			<CFPARAM NAME="BB_Apply_Rebate_Rates_#LOOPCOUNT#" 		DEFAULT="0">
			<CFPARAM NAME="Mass_Billback_Pay_#LOOPCOUNT#" 			DEFAULT="0">
			<CFPARAM NAME="BB_Allow_Vendor_Master_Search_#LOOPCOUNT#" DEFAULT="0">
			<CFPARAM NAME="BB_Apply_Pullback_#LOOPCOUNT#" 			DEFAULT="0">
			<CFPARAM NAME="BB_Apply_Pullback_Amount_#LOOPCOUNT#" 	DEFAULT="0">
			<CFPARAM NAME="BB_UnApply_Pullback_#LOOPCOUNT#" 		DEFAULT="0">
			<CFPARAM NAME="BB_Add_Program_#LOOPCOUNT#" 				DEFAULT="0">
			<CFPARAM NAME="Approve_BB_Beyond_Budget_#LOOPCOUNT#" 	DEFAULT="0">
			<CFPARAM NAME="BB_Volume_Override_#LOOPCOUNT#" 	        DEFAULT="0">
			<CFPARAM NAME="BB_Rate_Override_#LOOPCOUNT#" 	        DEFAULT="0">
			<CFPARAM NAME="BB_Search_By_Analyst_#LOOPCOUNT#"		DEFAULT="0">
			<CFPARAM NAME="BB_Add_Payee_Any_Position_#LOOPCOUNT#"	DEFAULT="0">
			<CFPARAM NAME="Credit_Memo_Amount_#LOOPCOUNT#"	DEFAULT="0">
     			<CFPARAM NAME="BB_Dev_Grid_Manual_Rate_Override_Check_#LOOPCOUNT#"		DEFAULT="0">
			<CFPARAM NAME="View_BB_CRA_Analysis_Report_#LOOPCOUNT#"		DEFAULT="0">
			<CFPARAM NAME="Change_BB_Start_End_Date_#LOOPCOUNT#"		DEFAULT="0">
			<CFPARAM NAME="BB_Reassign_#LOOPCOUNT#"					DEFAULT="0">
			<CFPARAM NAME="Void_Credit_Request_#LOOPCOUNT#"					DEFAULT="0">
			<CFPARAM NAME="Display_BB_EDI_Download_#LOOPCOUNT#"				DEFAULT="0">
			<CFPARAM NAME="Display_BB_User_Download_#LOOPCOUNT#"			DEFAULT="0">
			<CFPARAM NAME="Display_BB_III_Party_Download_#LOOPCOUNT#"		DEFAULT="0">
			<CFPARAM NAME="Auto_Approve_Analysis_#LOOPCOUNT#"		DEFAULT="0">
			<CFPARAM NAME="Allow_RFA_With_Default_Program_#LOOPCOUNT#"		DEFAULT="0"><!---61486 : Default program only when $'s equal to $0.00...  --->
            <CFPARAM NAME="BB_Display_Dist_Channel_Per_Program_Distributor_#LOOPCOUNT#"		DEFAULT="0">
			<CFPARAM NAME="Max_BB_Oper_Location_Level_Dup_Approval_Amount_#LOOPCOUNT#"		DEFAULT="0">
			<CFPARAM NAME="View_Deviated_Items_Only_OnLoad_#LOOPCOUNT#"		DEFAULT="0">
			<CFPARAM NAME="View_Count_Column_In_Deviation_Grid_#LOOPCOUNT#"		DEFAULT="0">
			<CFPARAM NAME="Settlements_#LOOPCOUNT#"		DEFAULT="0">
			<CFPARAM NAME="Search_Customer_Invoice_#LOOPCOUNT#"		DEFAULT="0">
			<CFPARAM NAME="AQP_Max_Overspend_#LOOPCOUNT#"		DEFAULT="0"><!--- 97929--->
            <CFPARAM NAME="AQP_Available_#LOOPCOUNT#"		DEFAULT="0"><!--- 108221 --->

			<CFIF (Trim(Evaluate("BB_Approve_Amount_#LOOPCOUNT#")) EQ "") OR ((Evaluate("BB_Approve_#LOOPCOUNT#") EQ 0) AND (Evaluate("BB_Approve_Critical_#LOOPCOUNT#") EQ 0))>
				<CFSET "BB_Approve_Amount_#LOOPCOUNT#"=0>
			</CFIF>
			<CFIF (Trim(Evaluate("Max_BB_Oper_Location_Level_Dup_Approval_Amount_#LOOPCOUNT#")) EQ "")>
				<CFSET "Max_BB_Oper_Location_Level_Dup_Approval_Amount_#LOOPCOUNT#"=0>
			</CFIF>
			<CFIF (Trim(Evaluate("View_Deviated_Items_Only_OnLoad_#LOOPCOUNT#")) EQ "")>
				<CFSET "View_Deviated_Items_Only_OnLoad_#LOOPCOUNT#"=0>
			</CFIF>
			<CFIF (Trim(Evaluate("View_Count_Column_In_Deviation_Grid_#LOOPCOUNT#")) EQ "")>
				<CFSET "View_Count_Column_In_Deviation_Grid_#LOOPCOUNT#"=0>
			</CFIF>

			<!----------
			<CFIF (Trim(Evaluate("BB_Approve_Critical_Amount_#LOOPCOUNT#")) EQ "")  OR (Evaluate("BB_Approve_Critical_#LOOPCOUNT#") EQ 0)>
				<CFSET "BB_Approve_Critical_Amount_#LOOPCOUNT#"=0>
			</CFIF>
			----------->

			<CFIF Evaluate("BB_View_Deviation_#LOOPCOUNT#") NEQ "1">
				<CFSET "BB_Approve#LOOPCOUNT#" = "0">
				<CFSET "BB_Approve_Amount_#LOOPCOUNT#" = 0>
				<CFSET "BB_Approve_Critical_#LOOPCOUNT#" = "0">
				<CFSET "BB_Tot_Approve_Amount_#LOOPCOUNT#" = "0">
				<CFSET "BB_Pay_Req_Approval_Amount_#LOOPCOUNT#" = "0">
				<CFSET "Approve_BB_Beyond_Budget_#LOOPCOUNT#" = "0">

				<!---
				/* Not sure if this needs to be added */
				<CFSET "BB_DevGrid_Expected_#LOOPCOUNT#" ="0">
				<CFSET "BB_DevGrid_ELT_#LOOPCOUNT#" 	 ="0">
				<CFSET "BB_DevGrid_Claimed_#LOOPCOUNT#"  ="0">
				<CFSET "BB_DevGrid_Selected_#LOOPCOUNT#" ="0">
				--->
				<!-----
				<CFSET "BB_Approve_Critical_Amount_#LOOPCOUNT#" = 0>
				--------->
			</CFIF>
			<!--- AUDITING - CAPTURE ORIGINAL --->
			<cfquery name="variables.qOriginal" datasource="#application.datasource#">
				SELECT Profiles_Desc, BS.*
				FROM BB_Profiles_Settings  BS
				INNER JOIN Profiles p on BS.profiles_id  = p.profiles_id 
				WHERE BS.Profiles_ID = #loopCount# AND BS.deleted = 0 and p.deleted = 0
			</cfquery>

			<CFQUERY NAME="Save_Data" DATASOURCE="#application.datasource#">
				DELETE
				FROM		BB_Profiles_Settings
				WHERE		Profiles_ID = #LOOPCOUNT#;
				INSERT INTO
				BB_Profiles_Settings
				(
					Profiles_ID,
					BB_Create,
					BB_Delete,
					<!--- Dev Note: Drachala; D27781 : new bb profile settings START--->
					BB_closing_methods_view,
					BB_Adjust,
					BB_Mass_Approve,
					BB_Mass_Delete,
					<!--- Dev Note: Drachala; D27781 : new bb profile settings END--->
					BB_View_Deviation,
					BB_Approve,
					BB_DevGrid_Expected,
					BB_DevGrid_ELT,
					BB_DevGrid_Claimed,
					BB_DevGrid_Selected,
					BB_Approve_Amount,
					BB_Tot_Approve_Amount,
					BB_Pay_Req_Approval_Amount,
					BB_RFA_Agreed,
					BB_Approve_Critical,
					Approve_Last_Date_To_Claim,
					<!---BB_Approve_Critical_Amount, ---->
					BB_User_ID,
					BB_Updated_Date,
					BB_Reverse,
					Autopay_Reverse,
					BB_Apply_Rebate_Rates,
					Mass_Billback_Pay,
					BB_Allow_Vendor_Master_Search,
					BB_Apply_Pullback,
					BB_Apply_Pullback_Amount,
					BB_UnApply_Pullback,
					BB_Add_Program,
					Approve_BB_Beyond_Budget,
					BB_Volume_Override,
					BB_Rate_Override,
					BB_Search_By_Analyst,
					BB_Add_Payee_Any_Position,
					Credit_Memo_Amount,
          BB_Dev_Grid_Manual_Rate_Override_Check,
					View_BB_CRA_Analysis_Report,
					Change_BB_Start_End_Date,
					BB_Reassign,
					Void_Credit_Request,
					Display_BB_EDI_Download,
					Display_BB_User_Download,
					Display_BB_III_Party_Download,
					Auto_Approve_Analysis,
					Allow_RFA_With_Default_Program,
					BB_Display_Dist_Channel_Per_Program_Distributor,
					Max_BB_Oper_Location_Level_Dup_Approval_Amount,
					View_Deviated_Items_Only_OnLoad,
					View_Count_Column_In_Deviation_Grid
					,Settlements
					,Search_Customer_Invoice
					,AQP_Max_Overspend<!--- 97929--->
					,AQP_Available
				)
				VALUES
				(
					#LOOPCOUNT#,
					#Evaluate("BB_CREATE_#LOOPCOUNT#")#,
					#Evaluate("BB_DELETE_#LOOPCOUNT#")#,
					<!--- Dev Note: Drachala; D27781 : new bb profile settings START--->
					#Evaluate("BB_CLOSING_METHODS_VIEW_#LOOPCOUNT#")#,
					#Evaluate("BB_ADJUST_#LOOPCOUNT#")#,
					#Evaluate("BB_Mass_Approve_#LOOPCOUNT#")#,
					#Evaluate("BB_Mass_Delete_#LOOPCOUNT#")#,
					<!--- Dev Note: Drachala; D27781 : new bb profile settings END--->
					#Evaluate("BB_View_Deviation_#LOOPCOUNT#")#,
					#Evaluate("BB_Approve_#LOOPCOUNT#")#,

					#Evaluate("BB_DevGrid_Expected_#LOOPCOUNT#")#,
					#Evaluate("BB_DevGrid_ELT_#LOOPCOUNT#")#,
					#Evaluate("BB_DevGrid_Claimed_#LOOPCOUNT#")#,
					#Evaluate("BB_DevGrid_Selected_#LOOPCOUNT#")#,

					'#Evaluate("BB_Approve_Amount_#LOOPCOUNT#")#',
					'#Evaluate("BB_Tot_Approve_Amount_#LOOPCOUNT#")#',
					'#Evaluate("BB_Pay_Req_Approval_Amount_#LOOPCOUNT#")#',
					'#Evaluate("BB_RFA_Agreed_#LOOPCOUNT#")#',
					#Evaluate("BB_Approve_Critical_#LOOPCOUNT#")#,
					#Evaluate("Approve_Last_Date_To_Claim_#LOOPCOUNT#")#,
					<!----'#Evaluate("BB_Approve_Critical_Amount_#LOOPCOUNT#")#',---->
					'#request.AccessStructure.User_ID#',
					GetDate(),
					#Evaluate("BB_Reverse_#LOOPCOUNT#")#,
					#Evaluate("Autopay_Reverse_#LOOPCOUNT#")#,
					#Evaluate("BB_Apply_Rebate_Rates_#LOOPCOUNT#")#,
					#Evaluate("Mass_Billback_Pay_#LOOPCOUNT#")#,
					#Evaluate("BB_Allow_Vendor_Master_Search_#LOOPCOUNT#")#,
					#Evaluate("BB_Apply_Pullback_#LOOPCOUNT#")#,
					'#Evaluate("BB_Apply_Pullback_Amount_#LOOPCOUNT#")#',
					#Evaluate("BB_UnApply_Pullback_#LOOPCOUNT#")#,
					#Evaluate("BB_Add_Program_#LOOPCOUNT#")#,
					#Evaluate("Approve_BB_Beyond_Budget_#LOOPCOUNT#")#,
					#Evaluate("BB_Volume_Override_#LOOPCOUNT#")#,
					#Evaluate("BB_Rate_Override_#LOOPCOUNT#")#,
					#Evaluate("BB_Search_By_Analyst_#LOOPCOUNT#")#,
					#Evaluate("BB_Add_Payee_Any_Position_#LOOPCOUNT#")#,
					'#Evaluate("Credit_Memo_Amount_#LOOPCOUNT#")#',
 					#Evaluate("BB_Dev_Grid_Manual_Rate_Override_Check_#LOOPCOUNT#")#,
 					#Evaluate("View_BB_CRA_Analysis_Report_#LOOPCOUNT#")#,
 					#Evaluate("Change_BB_Start_End_Date_#LOOPCOUNT#")#,
					#Evaluate("BB_Reassign_#LOOPCOUNT#")#,
					#Evaluate("Void_Credit_Request_#LOOPCOUNT#")#,
					#Evaluate("Display_BB_EDI_Download_#LOOPCOUNT#")#,
					#Evaluate("Display_BB_User_Download_#LOOPCOUNT#")#,
					#Evaluate("Display_BB_III_Party_Download_#LOOPCOUNT#")#,
					#Evaluate("Auto_Approve_Analysis_#LOOPCOUNT#")#,
					#Evaluate("Allow_RFA_With_Default_Program_#LOOPCOUNT#")#,
					#Evaluate("BB_Display_Dist_Channel_Per_Program_Distributor_#LOOPCOUNT#")#,
					'#Evaluate("Max_BB_Oper_Location_Level_Dup_Approval_Amount_#LOOPCOUNT#")#',
					'#Evaluate("View_Deviated_Items_Only_OnLoad_#LOOPCOUNT#")#',
					'#Evaluate("View_Count_Column_In_Deviation_Grid_#LOOPCOUNT#")#'
					,#Evaluate("Settlements_#LOOPCOUNT#")#
					,#Evaluate("Search_Customer_Invoice_#LOOPCOUNT#")#
					,'#Evaluate("AQP_Max_Overspend_#LOOPCOUNT#")#'<!--- 97929--->
					,'#Evaluate("AQP_Available_#LOOPCOUNT#")#'<!--- 108221--->
				)
			</CFQUERY>
			<!--- If Profile doesn't have a closing method by default we will insert an entry per profile with default closing method = deduction --->
			<cfset useLakebaseForqCheckCM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_profile_closing_methods")>
<cfif useLakebaseForqCheckCM>
	<cftry>
		<cfset qCheckCM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_profile_closing_methods", {
				"profile_id" = "eq.#LOOPCOUNT#",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckCM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckCM>
<cfquery name="qCheckCM" datasource="#application.datasource#">
			  	  SELECT 1
			  	  FROM BB_Profile_Closing_Methods
				  WHERE Profile_ID = #LOOPCOUNT#
			  </cfquery>
</cfif>

			<cfif qCheckCM.recordcount EQ 0>
				<cfset useLakebaseForINSERTBPCM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_profile_closing_methods")>
<cfif useLakebaseForINSERTBPCM>
	<cftry>
		<cfset application.oLakebase.insertRow("bb_profile_closing_methods", {
			"profile_id" = "#LOOPCOUNT#",
			"billback_closing_method_id" = "2"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForINSERTBPCM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForINSERTBPCM>
<cfquery name="INSERTBPCM" datasource="#application.datasource#">
			         insert into BB_Profile_Closing_Methods (Profile_ID, Billback_Closing_Method_ID)
			        values (#LOOPCOUNT#, 2)
			    </cfquery>
</cfif>
			</cfif>
			<!--- AUDITING - CAPTURE CHANGES --->
			<cfquery name="variables.qUpdated" datasource="#application.datasource#">
				SELECT Profiles_Desc, BS.*
				FROM BB_Profiles_Settings  BS
				INNER JOIN Profiles p on BS.profiles_id  = p.profiles_id 
				WHERE BS.Profiles_ID = #loopCount# AND BS.deleted = 0 and p.deleted = 0
			</cfquery>
			<cfscript>
				variables.udf = createObject( "component", "components.udf" );
				variables.udf.WriteSettingsAudit( variables.qOriginal, variables.qUpdated, "BB_Profiles_Settings", loopCount, "#variables.qUpdated.Profiles_Desc#", "Profiles_Id,Created_Date,BB_Profiles_Settings_ID,BB_User_ID,BB_Updated_Date" );
			</cfscript>

		</CFLOOP>