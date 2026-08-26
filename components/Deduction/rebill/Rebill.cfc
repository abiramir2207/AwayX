<cfcomponent>

   <cffunction name="set" output="false" returntype="struct">	
   
	  	<cfargument name="compID" type="string" required="true" default="">	
		<cfargument name="compNameId" type="string" required="true" default="">
		<cfargument name="programID" type="numeric" required="true" default=0>
		<cfargument name="compName" type="string" required="true" default="">
		<cfargument name="compUUID" type="string" required="true" default="#CreateUUID()#">
   
   		<cfscript>
		
			tmpStruct = structNew();
			tmpStruct.compID = arguments.compID;
			tmpStruct.compNameId = arguments.compNameId;
			tmpStruct.programID = arguments.programID;
			tmpStruct.compName = arguments.compName;
			tmpStruct.compUUID = arguments.compUUID;

		</cfscript>
		
		<cfreturn tmpStruct />

   </cffunction>
   
   <cffunction name="checkExists" output="false" returntype="boolean">	
   
	  	<cfargument name="aCompToCheck" type="array" required="true" default="">	
		<cfargument name="compID" type="string" required="true" default="">

   
   		<cfscript>
			
			doesExist = false;
			
			for (i=1; i lte ArrayLen(arguments.aCompToCheck); i = i+1)
			{
				if (not CompareNoCase(arguments.aCompToCheck[i].compUUID, arguments.compID))
					doesExist = true;
			}
			
		</cfscript>
		
		<cfreturn doesExist />

   </cffunction>
   
	<cffunction name="getActive" output="false" returntype="query">	
   
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	DD_Rebill.*, DD_Classification.DD_Classification_Desc
			FROM 	DD_Rebill
				LEFT JOIN DD_Classification
				ON DD_Classification.DD_Classification_ID = DD_Rebill.DD_Classification_ID
			WHERE 	DD_Rebill.Deleted = 0
			ORDER BY 	DD_Rebill.Clause_Order, DD_Rebill.Created_Date
		</cfquery>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="getComp" output="false" returntype="query">	
   
   		<cfargument name="compId" required="false" default=0 />
		
		<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 	DD_Rebill.*, DD_Classification.DD_Classification_Desc
			FROM 	DD_Rebill
				LEFT JOIN DD_Classification
				ON DD_Classification.DD_Classification_ID = DD_Rebill.DD_Classification_ID
			WHERE 	DD_Rebill_ID = #arguments.compId#	
		</cfquery>

		<cfreturn qGetComp />
		
   	</cffunction>
	
	
	<cffunction name="getInActive" output="false" returntype="query">	
   
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
		
			SELECT 	DD_Rebill.*, DD_Classification.DD_Classification_Desc
			FROM 	DD_Rebill
				LEFT JOIN DD_Classification
				ON DD_Classification.DD_Classification_ID = DD_Rebill.DD_Classification_ID
			WHERE 	DD_Rebill.Deleted = 1
			ORDER BY DD_Rebill.Clause_Order, DD_Rebill.Created_Date
		</cfquery>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="add" output="false" hint="Function used to add a new component.">
	
		<cfargument name="DD_Rebill_Text" required="false" default="" />	
		<cfargument name="Is_Mandatory" required="false" default="0" />
		<cfargument name="Is_Editable" required="false" default="0" />
		<cfargument name="Clause_Order" required="false" default="0" />
		<cfargument name="User_ID" required="false" default="0">
		<cfargument name="DD_Classification_ID" required="false" default="0">
			
			<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SET NOCOUNT ON 
				INSERT INTO	DD_Rebill
					(DD_Rebill_Text, Changed_By, Changed_On, Created_Date, Is_Mandatory, Is_Editable, Clause_Order, DD_Classification_ID)
				VALUES
					('#arguments.DD_Rebill_Text#', 
					'#arguments.User_ID#',
					#now()#,
					#now()#,
					'#arguments.Is_Mandatory#',
					'#arguments.Is_Editable#',
					#arguments.Clause_Order#,
					#arguments.DD_Classification_ID#)
				SELECT DD_Rebill_ID = @@IDENTITY 
				SET NOCOUNT OFF
			</cfquery>
			
			<Cflocation url="/deductions/settings/rebill/index.cfm">
										
   	</cffunction>
	
	<cffunction name="deactivate" output="false" hint="Function used to deactivate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	DD_Rebill
			SET		Deleted = 1
			WHERE	DD_Rebill_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="activate" output="false" hint="Function used to activate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	DD_Rebill
			SET		Deleted = 0
			WHERE	DD_Rebill_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
		
	<cffunction name="update" output="false" hint="Function used to update components." returntype="boolean">
	
		<cfargument name="compId" required="false" default="" />
		<cfargument name="compName" required="false" default="" />
		<cfargument name="Is_Mandatory" required="false" default="" />
		<cfargument name="Is_Editable" required="false" default="" />
		<cfargument name="Clause_Order" required="false" default="" />
		<cfargument name="User_ID" required="false" default="0">
		<cfargument name="DD_Classification_ID" required="false" default="0">
			
			<cfquery datasource="#application.datasource#">
				UPDATE 	DD_Rebill
				SET		DD_Rebill_Text = '#arguments.compName#', 
						Changed_By = '#arguments.User_ID#', 
						Changed_On = #now()#, 
						Is_Mandatory = '#arguments.Is_Mandatory#', 
						Is_Editable = '#arguments.Is_Editable#', 
						Clause_Order = #arguments.Clause_Order#,
						DD_Classification_ID = #arguments.DD_Classification_ID#
				WHERE	DD_Rebill_ID = #arguments.compId#
			</cfquery>
      
		
		<Cflocation url="/deductions/settings/rebill/index.cfm">
		
   	</cffunction>
	
	<cffunction name="changeorder" output="false" hint="Function used to update components." returntype="boolean">
	
		<cfargument name="compId" required="false" default="" />
		<cfargument name="Clause_Order" required="false" default="" />
		
	
			<cfquery datasource="#application.datasource#">
				UPDATE 	DD_Rebill
				SET		Clause_Order = '#arguments.Clause_Order#'
				WHERE	DD_Rebill_ID = #arguments.compId#
			</cfquery>

		<cfreturn bCompNameExists />
		
   	</cffunction>
   
   
   <!--- 
  	    Dev Notes: 19384/Anand Rao/05-Apr-10
        All the function below are use for the Rebill integration Module.
   ---->
   
   	<cffunction name="addRebillPackage" output="false" hint="Function used to add a Rebill Package">
    
  		<cfargument name="title" required="false" default="" />	
      <cfargument name="chkDefaultMessage"  required="false" default="" />	
  		<cfargument name="rebillMessage" required="false" default="" />
  		<cfargument name="Selected_Reason_Code_ID_List" required="false" default="" />	
      <cfargument name="Selected_Reason_Code_ID" required="false" default="" />
      <cfargument name="Selected_Classification_ID_List" required="false" default="" />	
      <cfargument name="Selected_Classification_ID" required="false" default="" />	
      <cfargument name="User_ID" required="false" default="" />	

 
      <cfset iReturnVal = 0 />
		  <cfquery name="qGetActiveRebillPackage" datasource="#application.datasource#">
			  SELECT	Rebill_Package_Title
			  FROM	DD_Rebill_package_Hdr
			  WHERE	Rebill_Package_Title = '#trim(arguments.title)#'
			  AND		deleted = 0
		  </cfquery>
		
		  <cfif qGetActiveRebillPackage.RecordCount EQ 0>
			
			  <cfquery name="qInsRebillPackage" datasource="#application.datasource#">
			  SET NOCOUNT ON 
				  INSERT INTO	DD_Rebill_package_Hdr
            (Rebill_Package_Title,Default_Message,Rebill_Package_Msg,Active,Created_Date,Created_By)
			    VALUES
					('#arguments.title#', #arguments.chkDefaultMessage#,'#arguments.rebillMessage#', 1, getdate(),
					<cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">)
        SELECT DD_Rebill_Package_Hdr_ID = SCOPE_IDENTITY()
				SET NOCOUNT OFF
			</cfquery>
	
 
    <cfloop index = "i" list = #arguments.Selected_Reason_Code_ID_List#>
      <cfset isReasonCodeDefault = 0 />
      <cfif (arguments.Selected_Reason_Code_ID EQ i)>
        <cfset isReasonCodeDefault = 1 />
      </cfif>  
    	<cfquery name="qInsReasonCode" datasource="#application.datasource#">
      	SET NOCOUNT ON 
        INSERT INTO DD_Rebill_Package_Dtl 
        (DD_Rebill_Package_Hdr_ID,DD_Reason_Code_ID,Is_Default,Created_Date)
        VALUES
        (#qInsRebillPackage.DD_Rebill_Package_Hdr_ID#,#i#,#isReasonCodeDefault#,getdate())
    	SET NOCOUNT OFF
      </cfquery>
    </cfloop> 
    
    <cfloop index = "j" list = #arguments.Selected_Classification_ID_List#>
      <cfset isClassificationDefault = 0 />
      <cfif (arguments.Selected_Classification_ID EQ j)>
        <cfset isClassificationDefault = 1 />
      </cfif>  
    	<cfquery name="qInsClassification" datasource="#application.datasource#">
      	SET NOCOUNT ON 
        INSERT INTO DD_Rebill_Package_Dtl 
        (DD_Rebill_Package_Hdr_ID,DD_Classification_ID,Is_Default,Created_Date)
        VALUES
        (#qInsRebillPackage.DD_Rebill_Package_Hdr_ID#,#j#,#isClassificationDefault#,getdate())
    	SET NOCOUNT OFF
      </cfquery>
    </cfloop> 
    <cfset iReturnVal = qInsRebillPackage.DD_Rebill_Package_Hdr_ID />
    <cfelse>
      <cfset iReturnVal = 0 />
  	</cfif>
    
	<cfreturn iReturnVal />
    
  </cffunction>
   
    <cffunction name="activatePackage" output="false" hint="Function used to Activate Rebill Package.">
     <cfargument name="DD_Rebill_package_Hdr_ID" required="false" default="" />
   		
      <cfquery datasource="#application.datasource#">
			UPDATE 	DD_Rebill_package_Hdr
			SET		Active = 1
			WHERE	DD_Rebill_package_Hdr_ID IN(#arguments.DD_Rebill_package_Hdr_ID#)
		</cfquery>
    </cffunction>
    
    <cffunction name="deActivatePackage" output="false" hint="Function used to deactivate Rebill Package.">
      <cfargument name="DD_Rebill_package_Hdr_ID" required="false" default="" />
   		
      <cfquery datasource="#application.datasource#">
			  UPDATE 	DD_Rebill_package_Hdr
			  SET		Active = 0
			  WHERE	DD_Rebill_package_Hdr_ID IN(#arguments.DD_Rebill_package_Hdr_ID#)
		  </cfquery>
		
	  </cffunction>
 
   
    <cffunction name="deletePackage" output="false" hint="Function used to delete Rebill Package.">
      <cfargument name="DD_Rebill_package_Hdr_ID" required="false" default="" />
   		
      <cfquery datasource="#application.datasource#">
			  UPDATE 	DD_Rebill_package_Hdr
			  SET		Deleted = 1 
			  WHERE	DD_Rebill_package_Hdr_ID IN(#arguments.DD_Rebill_package_Hdr_ID#)
      </cfquery>
      
    </cffunction>

    
<!---- ////////////////////// UPDATE the RECORD  ////////////////////// --->  
    
    <cffunction name="updatePackage" output="false" hint="Function used to update Rebill Package.">
      <cfargument name="DD_Rebill_package_Hdr_ID" required="false" default="" />
      <cfargument name="title" required="false" default="" />	
      <cfargument name="chkDefaultMessage" required="false" default="" />	
  		<cfargument name="rebillMessage" required="false" default="" />
  		<cfargument name="Selected_Reason_Code_ID_List" required="false" default="" />	
      <cfargument name="Selected_Reason_Code_ID" required="false" default="" />
      <cfargument name="Selected_Classification_ID_List" required="false" default="" />	
      <cfargument name="Selected_Classification_ID" required="false" default="" />	
      <cfargument name="User_ID" required="false" default="" />	

		  <cfset bPackageNameExists = false />		
				
		<!---check to see if the name already exists--->		
 		  <cfquery name="qCheckRebillPackageTitle" datasource="#application.datasource#">
			  SELECT	*
			  FROM	DD_Rebill_package_Hdr
			  WHERE	Rebill_Package_Title = '#trim(arguments.title)#'
        AND DD_Rebill_package_Hdr_ID != '#arguments.DD_Rebill_package_Hdr_ID#'
			  AND		deleted = 0
		  </cfquery>
 
      
		<!---If the name exists then set does not exist to false--->
		  <cfif qCheckRebillPackageTitle.RecordCount NEQ 0>
			  <cfset bPackageNameExists = true />
		  <cfelse>
			
        <!---  Update the DD_Rebill_Package_Hdr table --->
        <cfquery name="qUpdPackage" datasource="#application.datasource#">
          UPDATE DD_Rebill_Package_Hdr
          SET 
            Rebill_Package_Title = '#trim(arguments.title)#',
            Default_Message = #arguments.chkDefaultMessage#,
            <cfif arguments.chkDefaultMessage EQ 1>Rebill_Package_Msg = '#trim(arguments.rebillMessage)#',</cfif>
            Updated_Date = getDate(),
            Updated_By = '#arguments.User_ID#'
          WHERE DD_Rebill_package_Hdr_ID = #arguments.DD_Rebill_package_Hdr_ID#         
        </cfquery>
      
      <!--- UPDATE all the Detail records and reinsert them/ Delete them  --->
      <cfquery name="qDelDtls"  datasource="#application.datasource#">
 
       -- DELETE FROM DD_Rebill_Package_Dtl WHERE DD_Rebill_Package_Dtl_ID = #arguments.DD_Rebill_package_Hdr_ID#   
   
        UPDATE DD_Rebill_Package_Dtl SET Deleted = 1 WHERE DD_Rebill_package_Hdr_ID = #arguments.DD_Rebill_package_Hdr_ID#         
      </cfquery>
      
      <cfloop index = "i" list = #arguments.Selected_Reason_Code_ID_List#>
        <cfset isReasonCodeDefault = 0 />
        <cfif (arguments.Selected_Reason_Code_ID EQ i)>
          <cfset isReasonCodeDefault = 1 />
        </cfif>  
      	<cfquery name="qInsReasonCode" datasource="#application.datasource#">
        	SET NOCOUNT ON 
          INSERT INTO DD_Rebill_Package_Dtl 
          (DD_Rebill_Package_Hdr_ID,DD_Reason_Code_ID,Is_Default,Created_Date)
          VALUES
          (#arguments.DD_Rebill_Package_Hdr_ID#,#i#,#isReasonCodeDefault#,getdate())
      	SET NOCOUNT OFF
        </cfquery>
      </cfloop> 
  
      <cfloop index = "j" list = #arguments.Selected_Classification_ID_List#>
        <cfset isClassificationDefault = 0 />
        <cfif (arguments.Selected_Classification_ID EQ j)>
          <cfset isClassificationDefault = 1 />
        </cfif>  
      	<cfquery name="qInsClassification" datasource="#application.datasource#">
        	SET NOCOUNT ON 
          INSERT INTO DD_Rebill_Package_Dtl 
          (DD_Rebill_Package_Hdr_ID,DD_Classification_ID,Is_Default,Created_Date)
          VALUES
          (#arguments.DD_Rebill_Package_Hdr_ID#,#j#,#isClassificationDefault#,getdate())
      	SET NOCOUNT OFF
        </cfquery>
      </cfloop> 
		</cfif>
 
		<cfreturn bPackageNameExists />
   
    </cffunction>
   
    <cffunction name="getActivePackage" output="false"  returntype="query" hint="Function used to get all the active Rebill Packages.">
	    
      <cfquery name="qGetRebillPackage" datasource="#application.datasource#">
        SELECT 
          DDRPH.DD_Rebill_Package_Hdr_ID,
          DDRPH.Rebill_Package_Title,
          DDRPH.Default_Message,
          DDRPH.Rebill_Package_Msg,
          DDRPH.Active,
          DDRPH.Created_Date,
          DDRPH.Deleted,
          DDRPH.Created_By,
          DDRPH.Updated_Date,
          DDRPH.Updated_By,
          _Users.Name_First,
          _Users.Name_Last 
        FROM
          DD_Rebill_package_Hdr DDRPH
      LEFT JOIN _Users ON _Users.User_ID = DDRPH.Updated_By           
        WHERE 	DDRPH.Deleted = 0
        AND		DDRPH.Active = 1
        ORDER BY  DDRPH.Rebill_Package_Title	
		  </cfquery>

		  <cfreturn qGetRebillPackage />
    </cffunction>
   
    <cffunction name="getInActivePackage" output="false" hint="Function used to get all the inactive Rebill Packages.">
    
      <cfquery name="qGetRebillPackage" datasource="#application.datasource#">
        SELECT 
          DD_Rebill_Package_Hdr_ID,
          Rebill_Package_Title,
          Default_Message,
          Rebill_Package_Msg,
          Active,
          Created_Date,
          Deleted,
          Created_By,
          Updated_Date,
          Updated_By
        FROM
          DD_Rebill_package_Hdr
        WHERE 	Deleted = 0
        AND		Active = 0
        ORDER BY  Rebill_Package_Title	
		  </cfquery>

		  <cfreturn qGetRebillPackage />    
    </cffunction>
   
    <cffunction name="getRebillPackage" output="false" hint="Function used to get details of the Rebill package ID that gets passed.">
        <cfargument name="DD_Rebill_package_Hdr_ID" required="false" default="" />
        <cfquery name="qGetRebillPackage" datasource="#application.datasource#">
        SELECT 
          DDRPH.DD_Rebill_Package_Hdr_ID,
          DDRPH.Rebill_Package_Title,
          DDRPH.Default_Message,
          DDRPH.Rebill_Package_Msg,
          DDRPH.Active,
          DDRPH.Created_Date,
          DDRPH.Deleted,
          DDRPH.Created_By,
          DDRPH.Updated_Date,
          DDRPH.Updated_By,
          _Users.Name_First,
          _Users.Name_Last           
        FROM
          DD_Rebill_Package_Hdr DDRPH
        LEFT JOIN _Users ON _Users.User_ID = DDRPH.Updated_By                
        WHERE DDRPH.DD_Rebill_Package_Hdr_ID = #arguments.DD_Rebill_package_Hdr_ID#	
        AND   DDRPH.Deleted = 0
		  </cfquery>

		  <cfreturn qGetRebillPackage />    
    </cffunction>

    <cffunction name="getReasonCode" hint="Function used to get details of the Rebill package ID that gets passed.">
        <cfargument name="DD_Rebill_package_Hdr_ID" required="false" default="" />
        <cfquery name="qGetReasonCode" datasource="#application.datasource#">
        SELECT 
          DDRPD.DD_Rebill_Package_Dtl_ID,
          DDRPD.DD_Reason_Code_ID,
          DDRPD.DD_Classification_ID,
          DDRPD.Is_Default,
          DDRPD.Created_Date,
          DDRPD.Deleted,
          DRC.DD_Reason_Code
        FROM
          DD_Rebill_Package_Dtl DDRPD
          INNER JOIN DD_Reason_Code DRC ON DRC.DD_Reason_Code_ID = DDRPD.DD_Reason_Code_ID
        WHERE DDRPD.DD_Rebill_Package_Hdr_ID = #arguments.DD_Rebill_package_Hdr_ID#	AND DDRPD.DD_Reason_Code_ID IS NOT NULL
        AND   DDRPD.Deleted = 0
		  </cfquery>
		  <cfreturn qGetReasonCode />    
    </cffunction>

    <cffunction name="getDDClassification" hint="Function used to get details of the Rebill package ID that gets passed.">
        <cfargument name="DD_Rebill_package_Hdr_ID" required="false" default="" />
        <cfquery name="qGetDDClassification" datasource="#application.datasource#">
        SELECT 
          DDRPD.DD_Rebill_Package_Dtl_ID,
          DDRPD.DD_Reason_Code_ID,
          DDRPD.DD_Classification_ID,
          DDRPD.Is_Default,
          DDRPD.Created_Date,
          DDRPD.Deleted,
          DDC.DD_Classification_Desc
        FROM
          DD_Rebill_Package_Dtl DDRPD
        INNER JOIN DD_Classification DDC ON DDC.DD_Classification_ID = DDRPD.DD_Classification_ID
        WHERE DDRPD.DD_Rebill_Package_Hdr_ID = #arguments.DD_Rebill_package_Hdr_ID#	AND DDRPD.DD_Classification_ID IS NOT NULL
        AND   DDRPD.Deleted = 0
		  </cfquery>
		  <cfreturn qGetDDClassification />    
    </cffunction>
  
    <cffunction name="canDelete" output="false" hint="Function used to get details of the Rebill package ID that gets passed.">
      <cfargument name="DD_Rebill_Package_Hdr_ID" type="numeric" required="false" default="" />
      <!--- 
          TODO: Rewrite the query after discussion with Ana based on what table needs to be checked for association
          of a Hdr_ID 
          --->
  		<cfquery name="qCheckPackage" datasource="#application.datasource#">
  			SELECT 	count(*) as count
  			FROM 	DD_Rebill_Package_Hdr
  				/* INNER JOIN Currency_Mapping
  				ON Currency_Mapping.Currency_ID = Currency.Currency_ID
  				AND 	Currency_Mapping.Deleted = 0
  				INNER JOIN Program_Control_Panel_Options
  				ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Currency_Mapping.Template_ID */
  			WHERE 	DD_Rebill_Package_Hdr_ID = <cfqueryparam value="#arguments.DD_Rebill_Package_Hdr_ID#" cfsqltype="CF_SQL_INTEGER" />
  			AND 	DD_Rebill_Package_Hdr.Deleted = 0 
  		</cfquery>
		
		<!---if we get a count back from qCheckPackage then set canDelete to false--->
		<cfif qCheckPackage.count>
			<cfset bCanDelete = true />
		<cfelse>
			<cfset bCanDelete = false />
		</cfif>
		
		<cfreturn bCanDelete />
    
    </cffunction>
    
    <cffunction name="getDDClassifications" output="false" hint="Function used to get details of the Rebill package ID that gets passed.">
      <cfquery name="qGetDDClassifications" datasource="#application.datasource#">
      SELECT DD_Classification_ID, DD_Classification_Desc FROM DD_Classification WHERE 
Deleted = 0
      </cfquery>
      <cfreturn qGetDDClassifications />
    </cffunction>

    <cffunction name="getDDReasonCode" output="false" hint="Function used to get details of the Rebill package ID that gets passed.">
      <cfquery name="qGetDDReasonCode" datasource="#application.datasource#">
        SELECT DD_Reason_Code_ID, DD_Reason_Code FROM DD_Reason_Code WHERE Deleted = 0 AND Display_In IN (1,3)
      </cfquery>
      
      <cfreturn qGetDDReasonCode />
    </cffunction>

    <!--- Returns all the records for the variables from DD_Rebill_Package_Variable --->
     <cffunction name="getRebillVariables" output="false" hint="Function used to get details of the Rebill package ID that gets passed.">
      <cfquery name="qGetRebillVariables" datasource="#application.datasource#">
        SELECT DD_Rebill_package_Variable_ID,
               Rebill_Package_Variable,
			         Rebill_Package_Variable_Desc,
               Std_Length,
               Last_Updated_By,
               Last_Updated_Date,
               _Users.Name_First,
               _Users.Name_Last 
        FROM DD_Rebill_Package_Variable 
        LEFT JOIN _Users ON _Users.User_ID = DD_Rebill_Package_Variable.Last_Updated_By 
      </cfquery>
      
      <cfreturn qGetRebillVariables />
    </cffunction>
    
    <!---- Update Function for Variable size updating ---->
    <cffunction name="updRebillVariableSize" output="false" hint="Function used to update the Variable size.">
      <cfargument name="FORM" type="struct" default="" />
      <cfargument name="User_ID" required="false" default="" />	

      <cfset arrVariableIds = ArrayNew(1)>
      
      <cfloop collection="#FORM#" item="i">
        <cfif FindNoCase("DD_Rebill_package_Variable_ID_",i,1)>
        
          <cfset totLength = len(i) />
          <cfset varID = Right(i,(totLength-30)) /> <!--- 31 is the length of DD_Rebill_package_Variable_ID_ --->
          <cfset val= evaluate("FORM.Std_Length_" & varID) />  
         
          <cfset varSize = val />
          <cfquery name="qUpdRebillVariables" datasource="#application.datasource#">
            UPDATE DD_Rebill_Package_Variable
            SET Std_Length = #varSize#,
            Last_Updated_By = '#arguments.User_ID#',
            Last_Updated_Date = getDate() 
            WHERE DD_Rebill_package_Variable_ID = #varID#
         </cfquery>
  
        </cfif>
        
      </cfloop> 
      <cfset bSuccess = true />
      <cfreturn bSuccess />
    </cffunction>
    
    
	<!--- Ana D19384 - ClearRebill - Can be done only if it not interfaced to the client yet --->
	<cffunction name="clearRebill" 
					access="public" 
					returntype="void" 
					output="false" 
					displayname="clearRebill" 
					hint="">
						
		<cfargument name="Deduction_ID" required="true" type="string">
		<cfargument name="User_ID" required="true" type="string">
		
		<CFQUERY NAME="UpdateRebill" DATASOURCE="#Application.Datasource#">
			UPDATE 	DD_Rebill_Integration
			SET 	Deleted = 1,
					Rebill_Cleared_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar">,
					Rebill_Cleared_Date = getdate()
			FROM	DD_Rebill_Integration
			WHERE 	Deduction_ID = <cfqueryparam value="#arguments.Deduction_ID#" cfsqltype="cf_sql_varchar"> AND
					Rebill_Ack_Status = 1 AND Rebill_Sent_On IS NULL
		</CFQUERY>
		
		
		
		<CFQUERY NAME="UpdateRebill" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 	Is_Last_Status_Rebill = 0,
					DD_Status = 2			
			WHERE 	Deduction_ID = <cfqueryparam value="#arguments.Deduction_ID#" cfsqltype="cf_sql_varchar">
		</CFQUERY>
		
	</cffunction>
  
  <cffunction name="getRebillSettings" output="false" hint="Function used to get Settings of the Rebill.">
      <cfquery name="qGetRebillSettings" datasource="#application.datasource#">
        SELECT DES.Rebill_Message_Size,
                DES.Updated_By,
                DES.Updated_Date,
                 _Users.Name_First,
               _Users.Name_Last 
        FROM Deduction_External_Settings DES
        LEFT JOIN _Users ON _Users.User_ID = DES.Deduction_Settings_Updated_By 
      </cfquery>

      <cfreturn qGetRebillSettings />
    </cffunction>  
  
   <cffunction name="updRebillSettings" output="false" hint="Function used to get Settings of the Rebill.">
      <cfargument name="DDRebillMessageMaxSize" type="string" default="0" />
      <cfargument name="User_ID" required="false" default="" />	
      <cfquery name="qGetRebillSettings" datasource="#application.datasource#">
        UPDATE Deduction_External_settings
        SET Rebill_Message_Size = <cfqueryparam value="#arguments.DDRebillMessageMaxSize#" cfsqltype="cf_sql_varchar">,
            Updated_By  = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar">,
            Updated_Date = getDate()
      </cfquery>
  </cffunction>  
  
	</cfcomponent>