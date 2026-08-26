<cfset form.bIsFromTradePlan = 1 />
<cfinclude template="../../Common_Files/contracts/replicate_program.cfm" />

<!---Gets the current user's position--->
<cfscript>
	oUser = createObject("component","components.trade_plan.users");
	getUserPosition = oUser.getUserPosition(request.AccessStructure.user_id);
</cfscript>

<CFSET GP_Supplied_Position = getUserPosition>

<!---Includes approval rights stuff--->
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">

<!---set a UUID for file name--->
<cfset tpFileName = CreateUUID() />
<!---create instance of trade plan and call function to create WIP--->
<cfscript>
	tradePlan = createObject("component","components.trade_plan.trade_plan");
	tpProgram = tradePlan.convertIntoWIP(Trade_Plan_ID,GP_Position_List_From_My_Position_Down,Program,tpFileName);
	qGetTradePlanCostsReb = tradePlan.getTradePlanCosts(Trade_Plan_ID,1);
	rebSum = tradePlan.getTradePlanCostsSum(Trade_Plan_ID,1);
	qGetTradePlanCostsLumpSum = tradePlan.getTradePlanCosts(Trade_Plan_ID,3);
	lumpSumSum = tradePlan.getTradePlanCostsSum(Trade_Plan_ID,3);
</cfscript>

<!---set variables for what program types we can use with this trade plan--->
<cfset bHasRebate = true />
<cfset bHasLumpSum = true />
<cfset bCheckLBS = false />
<cfset bCheckPerc = false />

<cfif qGetTradePlanCostsReb.RecordCount eq 1 and qGetTradePlanCostsReb.Cost lte 0 or not qGetTradePlanCostsReb.RecordCount>
	<cfset bHasRebate = false />
</cfif>

<cfif qGetTradePlanCostsLumpSum.RecordCount eq 1 and qGetTradePlanCostsLumpSum.Cost lte 0 or not qGetTradePlanCostsLumpSum.RecordCount>
	<cfset bHasLumpSum = false />
</cfif>

<cfif bHasRebate>
	<!---check uom for rebate--->
	<cfloop query="qGetTradePlanCostsReb">
		<!---if the percent id equals 1 then we have to check for the percent uom--->
		<cfif Trade_Plan_Cost_Percent_ID eq 1>
			<cfset bCheckPerc = true />
		</cfif>
	
		<!---if the percent id equals 2 then we have to check for the pounds uom--->
		<cfif Trade_Plan_Cost_Percent_ID eq 2>
			<cfset bCheckLBS = true />
		</cfif>
	</cfloop>
</cfif>


<!---convert to WDDX--->
<CFWDDX ACTION="CFML2WDDX" INPUT="#tpProgram#" OUTPUT="Program_Packet" USETIMEZONEINFO="Yes">

<!--- get install path --->
<cfset APPPATH = request.app_general_functions.Get_Application_Path() />

<!--- END get install path --->
<!--- create usable directory information --->
<CFSET The_File_Location = Application.Doc_Path&"\temp_files\contracts\XML_Programs\#replace('#Createuuid()##createuuid()#', '-','','ALL')#.xml">
<!--- end create usable directory information --->	

<!--- save the wddx packet to the disk because --->
<CFSET XML_File_Location = The_File_Location>	
<CFFILE ACTION="WRITE" FILE="#XML_File_Location#" OUTPUT="#Program_Packet#" ADDNEWLINE="Yes">
	
 <CFQUERY NAME="savePacket" datasource="#application.datasource#">
	SET NOCOUNT ON
	INSERT INTO Contract_Renewal_Packets
		(Packet_Data, XML_File_Location)
	VALUES
		('#Program_Packet#', '#XML_File_Location#')
	
	SELECT Contract_Renewal_Packets_ID = @@IDENTITY  
	SET NOCOUNT OFF	
</CFQUERY>

<CFOUTPUT>
<FORM ACTION="../../Common_Files/select_new_program_type.cfm" METHOD="post" NAME="MyForm">
	<INPUT TYPE="Hidden" NAME="Contract_Renewal_Packets_ID" value="#savePacket.Contract_Renewal_Packets_ID#">
	<INPUT TYPE="Hidden" NAME="IsRevisionOfExistingContract" VALUE="0">
	<INPUT TYPE="Hidden" NAME="tpFileName" VALUE="#tpFileName#">
	<INPUT TYPE="Hidden" NAME="bIsFromTradePlan" VALUE="#FORM.bIsFromTradePlan#">
	<INPUT TYPE="Hidden" NAME="tradePlanId" VALUE="#Trade_Plan_ID#">
	<INPUT TYPE="Hidden" NAME="On_Release_Contract_Status_Type_IDX" VALUE="4">
	<INPUT TYPE="Hidden" NAME="hasRebate" VALUE="#bHasRebate#">
	<INPUT TYPE="Hidden" NAME="hasLumpSum" VALUE="#bHasLumpSum#">
	<INPUT TYPE="Hidden" NAME="bCheckLBS" VALUE="#bCheckLBS#">
	<INPUT TYPE="Hidden" NAME="bCheckPerc" VALUE="#bCheckPerc#">
	<INPUT TYPE="Hidden" NAME="start_date" VALUE="#Program.BASIC_INFORMATION.CONTRACT_START_DATE#">
	<INPUT TYPE="Hidden" NAME="end_date" VALUE="#Program.BASIC_INFORMATION.CONTRACT_END_DATE#">
</form>
</CFOUTPUT>	
<script>
	document.all.MyForm.submit();
</script>