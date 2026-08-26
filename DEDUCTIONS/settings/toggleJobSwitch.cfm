<!-----------------------------------------------------------------------------

FILE NAME:		toggleJobSwitch
DESCRIPTION:	Confirms and toggles the job switch from Enable to Disabled and vice versa
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	11-Dec-2015		Initial page 
------------------------------------------------------------------------------>

 <cfparam name="URL.iAction" default="1">
 <cfparam name="URL.iJobType" default="1">
 
<CFSET PAGETITLE = "PAYABLES SETTINGS::Toggle Job Switch">
<HTML>
<HEAD>
	<TITLE></TITLE>
	
<script>
	function fnSubmit() {
	alert
		document.frmJobSwitch.submit();
	}
</script>		
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- <CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<!--- ONLY IF FORM IS SUBMITTED THEN TURN ON OR OFF THE JOBS --->
<cfif isDefined("FORM.bSubmit")>
	<cfdump var="#FORM#">

		<cfif (isDefined("FORM.iAction") AND FORM.iAction EQ "0")>
			 FORM.iAction = <cfdump var="#FORM.iAction#" /><br>
		<cfelseif (isDefined("FORM.iAction") AND FORM.iAction EQ "1")>	 
			FORM.iAction = <cfdump var="#FORM.iAction#" /><br>
		</cfif>
		<cfif (isDefined("FORM.iJobType") AND FORM.iJobType EQ "1")>
			 FORM.iJobType = <cfdump var="#FORM.iJobType#" /><br>
		<cfelseif (isDefined("FORM.iJobType") AND FORM.iJobType EQ "2")>	 
			 FORM.iJobType = <cfdump var="#FORM.iJobType#" /><br>
		</cfif>
	

	<cfset useLakebaseForAdvanceFoodsTask = application.oLakebase.isEnabled() AND application.oLakebase.isProcMigrated("AdvanceFoods_MonthEnd_EOP_Tasks")>
	<cfif useLakebaseForAdvanceFoodsTask>
		<cfset procArgs = structNew()>
		<cfif (isDefined("FORM.iAction") AND FORM.iAction EQ "0")>
			<cfset procArgs.iAction = 0>
		<cfelseif (isDefined("FORM.iAction") AND FORM.iAction EQ "1")>
			<cfset procArgs.iAction = 1>
		</cfif>
		<cfif (isDefined("FORM.iJobType") AND FORM.iJobType EQ "1")>
			<cfset procArgs.iJobType = 1>
		<cfelseif (isDefined("FORM.iJobType") AND FORM.iJobType EQ "2")>
			<cfset procArgs.iJobType = 2>
		</cfif>
		<cfset procArgs.user_id = request.AccessStructure.User_ID>
		<cftry>
			<cfset AdvanceFoods_MonthEnd_EOP_Tasks_Results = application.oLakebase.callProcedure("AdvanceFoods_MonthEnd_EOP_Tasks", procArgs)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForAdvanceFoodsTask = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForAdvanceFoodsTask>
	 <cfstoredproc procedure="AdvanceFoods_MonthEnd_EOP_Tasks" datasource="#application.datasource#">
		<cfif (isDefined("FORM.iAction") AND FORM.iAction EQ "0")>
			 <cfprocparam cfsqltype="CF_SQL_TINYINT" null="no" type="IN" value = "0">
		<cfelseif (isDefined("FORM.iAction") AND FORM.iAction EQ "1")>	 
			 <cfprocparam cfsqltype="CF_SQL_TINYINT" null="no" type="IN" value = "1">
		</cfif>
		<cfif (isDefined("FORM.iJobType") AND FORM.iJobType EQ "1")>
			 <cfprocparam cfsqltype="CF_SQL_TINYINT" null="no" type="IN" value = "1">
		<cfelseif (isDefined("FORM.iJobType") AND FORM.iJobType EQ "2")>	 
			 <cfprocparam cfsqltype="CF_SQL_TINYINT" null="no" type="IN" value = "2">
		</cfif>
		<cfprocparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
		<cfprocresult name="AdvanceFoods_MonthEnd_EOP_Tasks_Results">  
	</cfstoredproc>
	</cfif>
	<cfoutput>	
	<cfquery name="UpdBBSettings" datasource="#Application.Datasource#">
		UPDATE Billback_Settings
		SET 
			
		<cfif (isDefined("FORM.iJobType") AND FORM.iJobType EQ "1")>
			 Enable_Jobs_1_To_4 = '#FORM.iAction#',
			 Enable_Jobs_1_To_4_Updated_By =  <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">, 
			 Enable_Jobs_1_To_4_Updated_Date = getDate()
		<cfelseif (isDefined("FORM.iJobType") AND FORM.iJobType EQ "2")>	
			 Enable_Job_5 = '#FORM.iAction#', 
			 Enable_Jobs_5_Updated_By =  <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">, 
			 Enable_Jobs_5_Updated_Date = getDate()
		</cfif>
	</cfquery>
	</cfoutput>
 
	<script language="javascript">
		window.opener.location.reload();
		window.close();
	</script>
	
<cfelse>
	<form action="" method="post" name="frmJobSwitch" id="frmJobSwitch">
		 <b>
	 	Are you sure you want to 
	 	<cfif URL.iAction EQ "0"> Disable <cfelse> Enable </cfif>
	 	<cfif URL.iJobType EQ "1"> 
		 	Jobs 1 through 4?<br><br>
			
		 	1) AdvanceFoods_Prod_BB_III_Party_Claim_Upload (SQL23)&nbsp;&nbsp;&nbsp;&nbsp;<br>
			2) Advancefood_900_GL_Request (APF)<br>
			3) BA_AdvanceFoods_Auto_Deviation (APF) <br>
			4) BA_AdvanceFoods_Auto_Match (APF)<br>
	 	<cfelse> 
	 	Job 5?<br>
		AdvanceFoods_1510_Credit_Request<br>
		
	 </cfif>
	 <br>
	 <font color="red">[</font> <a href="##" onclick="javascript:fnSubmit();">Yes</a> <font color="red">]</font>
	 <font color="red">[</font> <a href="##" onclick="javascript:window.close();">No</a> <font color="red">]</font>
	 </b>
		
			<cfoutput>
			<input type="hidden" name="iAction" id="iAction" value="#URL.iAction#" />
			<input type="hidden" name="iJobType" id="iJobType" value="#URL.iJobType#" />
			<input type="hidden" name="bSubmit" id="bSubmit" value="1" />		
			</cfoutput>
		</form>
 
 </cfif>
 </body>
 </html>