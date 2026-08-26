
<CFQUERY NAME="Get_All_BB" DATASOURCE="#Application.Datasource#">
	SELECT 		Payment_Data_Export_1.Billback_ID,
				Payment_Data_Export_1.BB_Code, 
				Pay_Multi_Billbacks_ID
	
	FROM 		Payment_Data_Export_1 
	INNER JOIN 	Billback ON Billback.Billback_ID = Payment_Data_Export_1.Billback_ID
				AND Billback.Deleted=0
	
	WHERE 		Signed=0 AND Payment_Data_Export_1.Deleted=0 AND Payment_Data_Export_1.Saved=1
</CFQUERY>

<CFSET Unsuccessful_Count = 0>
<CFSET UnSuccess_BB = "">
	
<CFOUTPUT QUERY="Get_All_BB">
	<CFIF Pay_Multi_Billbacks_ID NEQ "">
		<CFQUERY NAME="GetBBInMulti" DATASOURCE="#Application.Datasource#">
			SELECT 		Pay_Multi_Billbacks_List.Billback_ID,
						BB_Is_Locked,
						BB_Locked_By_User_ID,
						BB_Code
								
			FROM 		Pay_Multi_Billbacks_List
			
			INNER JOIN 	Billback_Allied ON Billback_Allied.Billback_Id = Pay_Multi_Billbacks_List.Billback_ID				
			INNER JOIN 	Billback ON Billback.Billback_ID = Pay_Multi_Billbacks_List.Billback_ID	
			
			WHERE 		Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND 
						Pay_Multi_Billbacks_List.Deleted = 0
		</CFQUERY>
		
		<CFSET UnSuccessList = VALUELIST(GetBBInMulti.BB_Code)>			
		<CFSET PayMultiBBIdList = VALUELIST(GetBBInMulti.Billback_ID)>

		<CFIF GetBBInMulti.BB_Is_Locked EQ 0 OR (GetBBInMulti.BB_Is_Locked EQ 1 AND GetBBInMulti.BB_Locked_By_User_ID EQ request.AccessStructure.User_ID)>
			<CFQUERY NAME="Lock_BB" DATASOURCE="#Application.Datasource#">
				UPDATE 		Billback_Allied
				
				SET 		BB_Is_Locked = 1,
							BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
							
				WHERE 		Billback_ID IN (#LISTQUALIFY(PayMultiBBIdList,"'",",","All")#)
			</CFQUERY>
			
			<CFQUERY NAME="ChangeStatus" DATASOURCE="#Application.Datasource#">
				UPDATE 	Payment_Data_Export_1
				
				SET 	Signed = 1,
						Signed_By_First_Name 	= '#request.AccessStructure.Name_First#',
						Signed_By_Last_Name 	= '#request.AccessStructure.Name_Last#',
						Signed_Date				= '#DateFormat(Now())#'	
				
				WHERE 	Pay_Multi_Billbacks_ID = '#Pay_Multi_Billbacks_ID#' AND Deleted=0 AND Saved=1
			</CFQUERY>
			
			<CFQUERY NAME="UNLock_BB" DATASOURCE="#Application.Datasource#">
				UPDATE 		Billback_Allied
				
				SET 		BB_Is_Locked = 0,
							BB_Locked_By_User_ID = NULL
							
				WHERE 		Billback_ID IN (#LISTQUALIFY(PayMultiBBIdList,"'",",","All")#)
				AND BB_Locked_By_Match_Central = 0	
			</CFQUERY>
		<CFELSE>
			<CFLOOP LIST="#UnSuccessList#" INDEX="Deli">
				<CFSET Unsuccessful_Count = Unsuccessful_Count + 1>
				<CFIF Unsuccessful_Count EQ 1>
					<CFSET UnSuccess_BB = "[#Deli#]">
				<CFELSE>
					<CFSET UnSuccess_BB = "#UnSuccess_BB#, [#Deli#]">
				</CFIF>
			</CFLOOP>
		</CFIF>
	<CFELSE>
		<cfset useLakebaseForCheck_Lock = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForCheck_Lock>
	<cftry>
		<cfset Check_Lock = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_allied", {
				"billback_id" = "eq.#Billback_ID#",
				"select" = "bb_is_locked"
			}), "bb_is_locked"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheck_Lock = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheck_Lock>
<CFQUERY NAME="Check_Lock" DATASOURCE="#Application.Datasource#">
			SELECT 	BB_Is_Locked 
			
			FROM 	Billback_Allied
			
			WHERE 	Billback_ID	= '#Billback_ID#' 
		</CFQUERY>
</cfif>
		
		<CFIF Check_Lock.BB_Is_Locked EQ 0>
	
			<CFQUERY NAME="Lock_BB" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Allied
				
				SET		BB_Is_Locked = 1
				
				WHERE 	Billback_ID = '#Billback_ID#' 
			</CFQUERY>
			<CFQUERY NAME="Approve_BB" DATASOURCE="#Application.Datasource#">
				UPDATE		Payment_Data_Export_1
				
				SET			Signed = 1,
							Signed_By_First_Name 	= '#request.AccessStructure.Name_First#',
							Signed_By_Last_Name 	= '#request.AccessStructure.Name_Last#',
							Signed_Date				= '#DateFormat(Now())#'	
							
				WHERE 	Billback_ID = '#Billback_ID#' AND Deleted=0 AND Saved=1
			</CFQUERY>
			<CFQUERY NAME="Lock_BB" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Allied
				
				SET		BB_Is_Locked = 0
				
				WHERE 	Billback_ID = '#Billback_ID#' 
				AND BB_Locked_By_Match_Central = 0
			</CFQUERY>
		<CFELSE>
			<CFSET Unsuccessful_Count = Unsuccessful_Count + 1>
			<CFIF Unsuccessful_Count EQ 1>
				<CFSET UnSuccess_BB = "[#BB_Code#]">
			<CFELSE>
				<CFSET UnSuccess_BB = "#UnSuccess_BB#, [#BB_Code#]">
			</CFIF>
		</CFIF>
	</CFIF>
</CFOUTPUT>


<!--- <TABLE ALIGN="Center">
	<TR>
		<TD>Please wait while the payment requests are being approved.</TD>
	</TR>
</TABLE>
 --->
<CFIF UnSuccess_BB NEQ "">
<SCRIPT language="JavaScript">
	function backto_pay_req()
	{
		var unsuccessful = "<CFOUTPUT>#Unsuccess_BB#</CFOUTPUT>";
		alert("Billback(s) "+ unsuccessful +" is / are currently locked. Please try again later.");
		window.location.href="check_issue_list.cfm"
	}
	window.setTimeout('backto_pay_req()',0);
</SCRIPT>
<CFELSE>
	<CFLOCATION URL="check_issue_list.cfm" ADDTOKEN="No">
</CFIF>







