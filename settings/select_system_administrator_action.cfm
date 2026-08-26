<cfset UsersIP = CGI.Remote_Addr>
<CFTRANSACTION ACTION="BEGIN">
	<CFQUERY NAME="clearPriorAdmin" datasource="#application.datasource#">
		UPDATE _Users
		SET Is_System_Administrator = 0
		WHERE Is_System_Administrator = 1
	</CFQUERY>
	<!------
	
	<CFQUERY NAME="assignNewAdmin" datasource="#application.datasource#">
		UPDATE _Users
		SET Is_System_Administrator = 1
		WHERE User_ID = '#FORM.SYSYTEM_ADMIN_ID#'
	</CFQUERY>
	----->
	
	<CFSET SYSYTEM_ADMIN_ID_Clause = ListQualify(FORM.SYSYTEM_ADMIN_ID, "'")>
	<CFQUERY NAME="assignNewAdmin" datasource="#application.datasource#">
		UPDATE _Users
		SET Is_System_Administrator = 1
		WHERE User_ID IN(#PreserveSingleQuotes(SYSYTEM_ADMIN_ID_Clause)#)
	</CFQUERY>
	
	<CFQUERY NAME="clearPriorAdminContact" datasource="#application.datasource#">
		UPDATE _Users
		SET Contact_Administrator = 0
		WHERE Contact_Administrator = 1
	</CFQUERY>
	
	<CFQUERY NAME="assignNewAdminContact" datasource="#application.datasource#">
		UPDATE _Users
		SET Contact_Administrator = 1
		WHERE User_ID = '#FORM.Contact_Admin_ID#'
	</CFQUERY>
	

	
  <!--- 
	Dev Notes: 23086/Anand Rao/21-May-10
	User Traffic Changes
  --->
   <cfloop index = "ListUser_ID" 
    list = "#SYSYTEM_ADMIN_ID_Clause#"> 
     <cfquery name="qGetUserCode" datasource="#application.datasource#">
      SELECT User_Code FROM _Users WHERE User_ID = <cfqueryparam value="#ListUser_ID#" cfsqltype="CF_SQL_VARCHAR">
     </cfquery>

     <cfquery name="AddUserTransAdminChange" datasource="#application.datasource#">
        INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
        VALUES
        (
          'SYSTEM-ADMIN-CHANGE',
          <cfqueryparam value="#qGetUserCode.User_Code#" cfsqltype="CF_SQL_VARCHAR">,
          <cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">, 
          <cfqueryparam value="#REQUEST.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
        )
      </cfquery>  
  </cfloop>
	<CFQUERY NAME="Get_Editor_Info" DATASOURCE="#application.datasource#">
		SELECT	*
		FROM	System_Admin_Settings
	</CFQUERY>
	<CFIF Get_Editor_Info.RecordCount GT 0> 
		<CFQUERY NAME="Update_Editor_Info" DATASOURCE="#application.datasource#">
			UPDATE	System_Admin_Settings
			SET		System_Admin_Editor_ID = '#request.AccessStructure.User_ID#',
					System_Admin_Edited_Date = GetDate()
		</CFQUERY>
	<CFELSE>
		<CFQUERY NAME="Insert_Editor_Info" DATASOURCE="#application.datasource#">
			INSERT INTO System_Admin_Settings (System_Admin_Editor_ID, System_Admin_Edited_Date)
			VALUES ('#request.AccessStructure.User_ID#', GetDate())
		</CFQUERY>
	</CFIF>
	
	<cfparam name="form.Pricing_Admin_ID" 	default="">
	<cfquery name="Update_Extra_Admins" datasource="#application.datasource#">
		UPDATE 	General_Settings
		SET 	Operator_Admin_ID 	= '#form.Operator_Admin_ID#',
				Pricing_Admin_ID 	= '#form.Pricing_Admin_ID#'
	</cfquery>
	
	<CFTRANSACTION ACTION="COMMIT">
</CFTRANSACTION>

<CFQUERY NAME="getCurrentAdmin" datasource="#application.datasource#">
	SELECT *
	FROm _Users
	WHERE Is_System_Administrator = 1
</CFQUERY>
<CFQUERY NAME="getCurrentAdminContact" datasource="#application.datasource#">
	SELECT *
	FROm _Users
	WHERE Contact_Administrator = 1
</CFQUERY>



<CFSET PAGE_TITLE= "">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>
<BODY BACKGROUND="" BGCOLOR="WhiteSmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" ONLOAD="" ONBEFOREUNLOAD="">
<CFSET PageTitle="SYSTEM ADMINISTRATOR CHANGED">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<BR>

<!------
<CFOUTPUT ><B>The System Administrator Is Now</B> <span STYLE="color: red; font-weight: bold;">#getCurrentAdmin.Name_First# #getCurrentAdmin.Name_Last#</span></CFOUTPUT>
<br><br>
----->

<B>Current System Administrator(s)</B>
<span STYLE="color: red; font-weight: bold;">
<CFOUTPUT QUERY="getCurrentAdmin">
<br>#Name_First# #Name_Last#
</CFOUTPUT>
</span>
<br><br>

<CFOUTPUT>
<B>Current Admin Contact is</B>
<span STYLE="color: red; font-weight: bold;">
#getCurrentAdminContact.Name_First# #getCurrentAdminContact.Name_Last#
</span>
</CFOUTPUT>
<br><br>


<span STYLE="color: red; font-weight: bold;">[</span>Please wait while we update the system...<span STYLE="color: red; font-weight: bold;">]</span>

<script language="JavaScript">
function seeya()
{
	//window.parent.window.location.href="index2.cfm";
	window.location.href="select_system_administrator_form.cfm";
}
setTimeout('seeya()',2000); 
</script>






</BODY>
</HTML>
