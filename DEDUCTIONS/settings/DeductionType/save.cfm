<cfparam name="Form.Is_Default" default="0">

<!--- Delete record --->
<cfif FORM.DeleteRecord EQ 1>
  <cftransaction>
    <cfset useLakebaseFordelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
    <cfif useLakebaseFordelete_Data>
      <cftry>
        <cfset application.oLakebase.deleteRows("deduction_type", { "deductiontype_id" = "eq.#Form.DeductionType_ID#" })>
        <cfcatch type="any">
          <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
          <cfset useLakebaseFordelete_Data = false>
        </cfcatch>
      </cftry>
    </cfif>
    <cfif NOT useLakebaseFordelete_Data>
    <cfquery name="delete_Data" datasource="#application.datasource#">
      DELETE 
        FROM Deduction_Type 
       WHERE DeductionType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Form.DeductionType_ID#">
    </cfquery>
    </cfif>
    
    <cfset useLakebaseForgetDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
    <cfif useLakebaseForgetDefault>
      <cftry>
        <cfset getDefault = application.oLakebase.toQuery(
          application.oLakebase.selectRows("deduction_type", {
            "select" = "deductiontype_id",
            "deleted" = "eq.0",
            "is_default" = "eq.1"
          }),
          "deductiontype_id"
        )>
        <cfcatch type="any">
          <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
          <cfset useLakebaseForgetDefault = false>
        </cfcatch>
      </cftry>
    </cfif>
    <cfif NOT useLakebaseForgetDefault>
    <cfquery name="getDefault" datasource="#Application.Datasource#">
      SELECT DeductionType_ID FROM Deduction_Type WHERE Deleted=0 AND Is_Default = 1
    </cfquery>
    </cfif>
    
    <cfif getDefault.Recordcount GT 0>
      <cfset useLakebaseForUpdateDDStages = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
      <cfif useLakebaseForUpdateDDStages>
        <cftry>
          <cfset application.oLakebase.updateRows("deductions",
            { "deductiontype_id" = "eq.#Form.DeductionType_ID#" },
            { "deductiontype_id" = getDefault.DeductionType_ID }
          )>
          <cfcatch type="any">
            <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
            <cfset useLakebaseForUpdateDDStages = false>
          </cfcatch>
        </cftry>
      </cfif>
      <cfif NOT useLakebaseForUpdateDDStages>
      <cfquery name="UpdateDDStages" datasource="#Application.Datasource#">
        UPDATE  Deductions
           SET  DeductionType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#getDefault.DeductionType_ID#"> 
         WHERE  DeductionType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Form.DeductionType_ID#">
      </cfquery>
      </cfif>
    </cfif>
  </cftransaction>
  
<!--- Update / Add record --->
<cfelse>
  <cfset useLakebaseForIsThereDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
  <cfif useLakebaseForIsThereDefault>
    <cftry>
      <cfset IsThereDefault = application.oLakebase.toQuery(
        application.oLakebase.selectRows("deduction_type", {
          "is_default" = "eq.1",
          "deleted" = "eq.0"
        })
      )>
      <cfcatch type="any">
        <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
        <cfset useLakebaseForIsThereDefault = false>
      </cfcatch>
    </cftry>
  </cfif>
  <cfif NOT useLakebaseForIsThereDefault>
  <cfquery name="IsThereDefault" datasource="#application.datasource#">
    SELECT * FROM Deduction_Type WHERE Is_Default = 1 AND Deleted = 0
  </cfquery>
  </cfif>
  <!---See if something is already set as default--->
  <cfparam name="SetAsDefault" default="0">
  
  <cfif IsThereDefault.RecordCount IS 0>
    <cfset SetAsDefault = 1>
    <cfset Form.Is_Default = 1>
  </cfif>
  
  <!--- remove default from another entry if necessary --->
  <cfif Form.Is_Default IS 1>
    <cfset useLakebaseForRemoveDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
    <cfif useLakebaseForRemoveDefault>
      <cftry>
        <cfset application.oLakebase.updateRows("deduction_type",
          { "is_default" = "eq.1" },
          { "is_default" = 0 }
        )>
        <cfcatch type="any">
          <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
          <cfset useLakebaseForRemoveDefault = false>
        </cfcatch>
      </cftry>
    </cfif>
    <cfif NOT useLakebaseForRemoveDefault>
    <cfquery name="RemoveDefault" datasource="#application.datasource#">
      UPDATE Deduction_Type
         SET Is_Default = 0
       WHERE Is_Default = 1
    </cfquery>
    </cfif>
  </cfif>
  
  <cfif Form.DeductionType_ID EQ "">
    <!--- Insert the record --->
    <cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
    <cfif useLakebaseForSave_Data>
      <cftry>
        <cfset application.oLakebase.insertRow("deduction_type", {
          "deductiontype_desc" = Form.DeductionType_Desc,
          "created_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
          "created_by" = request.AccessStructure.User_ID,
          "deleted" = Form.Deleted,
          "is_default" = Form.Is_Default
        })>
        <cfcatch type="any">
          <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
          <cfset useLakebaseForSave_Data = false>
        </cfcatch>
      </cftry>
    </cfif>
    <cfif NOT useLakebaseForSave_Data>
    <cfquery name="Save_Data" datasource="#application.datasource#">
      INSERT INTO   Deduction_Type
          ( DeductionType_Desc,
            Created_Date,
            Created_By,
            Deleted,
            Is_Default )
      VALUES      
          ( <cfqueryparam cfsqltype="cf_sql_varchar" value="#Form.DeductionType_Desc#">
            ,GetDate()
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
            ,<cfqueryparam cfsqltype="cf_sql_bit" value="#Form.Deleted#">
            ,<cfqueryparam cfsqltype="cf_sql_bit" value="#Form.Is_Default#"> )
    </cfquery>
    </cfif>
  <cfelse>
    <!--- Update the record --->
    <cfset useLakebaseForSave_Data2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
    <cfif useLakebaseForSave_Data2>
      <cftry>
        <cfset application.oLakebase.updateRows("deduction_type",
          { "deductiontype_id" = "eq.#Form.DeductionType_ID#" },
          {
            "deductiontype_desc" = Form.DeductionType_Desc,
            "deleted" = Form.Deleted,
            "is_default" = Form.IS_Default,
            "updated_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
            "updated_by" = request.AccessStructure.User_ID
          }
        )>
        <cfcatch type="any">
          <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
          <cfset useLakebaseForSave_Data2 = false>
        </cfcatch>
      </cftry>
    </cfif>
    <cfif NOT useLakebaseForSave_Data2>
    <cfquery name="Save_Data" datasource="#application.datasource#">
      UPDATE Deduction_Type
         SET DeductionType_Desc = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Form.DeductionType_Desc#">
             ,Deleted           = <cfqueryparam cfsqltype="cf_sql_bit" value="#Form.Deleted#">
             ,Is_Default        = <cfqueryparam cfsqltype="cf_sql_bit" value="#Form.IS_Default#">
             ,Updated_Date      = GetDate()
             ,Updated_By        = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
       WHERE DeductionType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Form.DeductionType_ID#">
    </cfquery>
    </cfif>
  </cfif>
</cfif>

<!--- clear out cached queries --->
<cfset useLakebaseForrsDeductionType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_type")>
<cfif useLakebaseForrsDeductionType>
  <cftry>
    <cfset rsDeductionType = application.oLakebase.toQuery(
      application.oLakebase.selectRows("deduction_type", {
        "select" = "deductiontype_desc,deductiontype_id",
        "deleted" = "eq.0",
        "order" = "deductiontype_desc.asc"
      }),
      "deductiontype_desc,deductiontype_id"
    )>
    <cfcatch type="any">
      <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
      <cfset useLakebaseForrsDeductionType = false>
    </cfcatch>
  </cftry>
</cfif>
<cfif NOT useLakebaseForrsDeductionType>
<cfquery name="rsDeductionType" datasource="#application.DataSource#" cachedWithin="#CreateTimeSpan(0,0,0,-1)#">
  SELECT DeductionType_Desc, DeductionType_ID
    FROM Deduction_Type
   WHERE Deleted = 0
ORDER BY DeductionType_Desc
</cfquery>
</cfif>


<cflocation url="index.cfm" addtoken="No">
