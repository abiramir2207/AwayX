<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
  <title>Untitled</title>
</head>

<body>
<br>

<cfparam name="FORM.DelActSubmitted" default="0">
<cfparam name="FORM.Is_Default" default="0">

<cfif DelActSubmitted EQ 1>
  <cftransaction>
    <cfset useLakebaseForUpdateDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
    <cfif useLakebaseForUpdateDefault>
      <cftry>
        <cfset application.oLakebase.updateRows("deduction_type",
          { "deductiontype_id" = "eq.#Form.DeductionType_ID#" },
          {
            "deductiontype_desc" = Form.DeductionType_Desc,
            "deleted" = Form.Deleted,
            "is_default" = 0
          }
        )>
        <cfcatch type="any">
          <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
          <cfset useLakebaseForUpdateDefault = false>
        </cfcatch>
      </cftry>
    </cfif>
    <cfif NOT useLakebaseForUpdateDefault>
    <cfquery name="UpdateDefault" datasource="#Application.Datasource#">
      UPDATE Deduction_Type
         SET DeductionType_Desc = '#Form.DeductionType_Desc#'
             ,Deleted           = #Form.Deleted#
             ,Is_Default        =   0
       WHERE DeductionType_ID   = '#Form.DeductionType_ID#'
    </cfquery>
    </cfif>
    
    <cfset useLakebaseForNewDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
    <cfif useLakebaseForNewDefault>
      <cftry>
        <cfset application.oLakebase.updateRows("deduction_type",
          { "deductiontype_id" = "eq.#Form.New_Default#" },
          { "is_default" = 1 }
        )>
        <cfcatch type="any">
          <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
          <cfset useLakebaseForNewDefault = false>
        </cfcatch>
      </cftry>
    </cfif>
    <cfif NOT useLakebaseForNewDefault>
    <cfquery name="NewDefault" datasource="#Application.Datasource#">
      UPDATE Deduction_Type
         SET Is_Default  =   1
       WHERE DeductionType_ID = '#Form.New_Default#'
    </cfquery>
    </cfif>
  </cftransaction>
  
  <script language="JavaScript">
  function refeshOpener()
  {
    if (window.opener)
    {
      window.opener.location.href="index.cfm";
    }
    window.close()
  }
  refeshOpener()
  </script>
<cfelse>
  <cfif FORM.Deleted EQ 1 AND FORM.Is_Default NEQ 0>
    <cfset reasonHere = 1>
  <cfelse>
    <cfset reasonHere = 2>
  </cfif>
  <cfset useLakebaseForGet_all = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
<cfif useLakebaseForGet_all>
	<cftry>
		<cfset Get_all = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_type", {
				"deleted" = "eq.0",
				"deductiontype_id" = "neq.#FORM.DeductionType_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_all = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_all>
<cfquery name="Get_all" datasource="#Application.Datasource#">
    SELECT * FROM Deduction_Type WHERE Deleted=0 AND DeductionType_ID <> '#FORM.DeductionType_ID#'
  </cfquery>
</cfif>
  <form name="DeleteAction" action="DeleteDefault.cfm" method="Post">
  <cfoutput>
  <input type="Hidden" name="DelActSubmitted" value="0">
  <input type="Hidden" name="DeductionType_Desc" value="#FORM.DeductionType_Desc#">
  <input type="Hidden" name="DeductionType_ID" value="#FORM.DeductionType_ID#">
  <input type="Hidden" name="Deleted" value="#FORM.Deleted#">
  <input type="Hidden" name="Is_Default" value="#FORM.Is_Default#">
  </cfoutput>
    <table border="0" cellpadding="0" cellspacing="0" align="Center">
      <tr>
        <td colspan="100%" align="Center">
          <font size="2" color="Red"><b>
          <cfif reasonHere EQ 1>
            You are about to inactivate the current default deduction type
          <cfelse>
            You are about to reset the current default deduction type as not default any more
          </cfif>         
          </b></font><br><br><br>
        </td>
      </tr>
      <tr>
        <td align="Center"><b>Select new default deduction type:</b>
          <select name="New_Default" onChange="Javascript: makeChanges()">
            <option value="">
            <cfoutput query="Get_all">
              <option value="#DeductionType_ID#">#DeductionType_Desc#</option>
            </cfoutput>
          </select>
        </td>
      </tr>
      <tr>
        <td colspan="100%" align="Right"><br><br><br><b><font color="Red" size="2">[ </font><a href="Javascript: closeWind()">abort</a><font color="Red" size="2"> ]</font></b></td>
      </tr>
    </table>
  </form>
    
</cfif>

<script language="JavaScript">
function closeWind()
{
  window.close()  
}

function makeChanges()
{
  if (document.all.New_Default.value == "")
  {
    alert("Please select a deduction type.")
  }
  else
  {
 
    var confirmAction = confirm("Press OK to set the selected deduction type as default.");
    if (confirmAction == true)
    {   
      document.all.DelActSubmitted.value=1
      document.DeleteAction.submit();
    }
    else
    {
      window.close()
    }
  }
}
</script>

</body>
</html>
