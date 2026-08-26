<cfcomponent hint="Makes updates and deletes to Brokerage Pullbacks" extends="components.Base" output="false">
	<cffunction name="init" output="false" returntype="components.Brk_Pullback.Brk_Pullback_Upd">
		<cfreturn this />
	</cffunction>
	
	<!--- XXXXXXXXXXXX	Run Brk_Upd_PB_Log_LocalOpr proc	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<!--- UpdatePBLog Insert into the Pullback Log --->
	<cffunction access="public" name="UpdatePBLog" returntype="void">
		<cfargument name="Billback_ID" type="any" required="true">
		<cfif application.appSettingsGet.getBrokerage_Functionality_On()>
			<cfstoredproc procedure="Brk_Upd_PB_Log_LocalOpr" datasource="#application.datasource#">	
					<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@BillBack_Id" value ="#arguments.Billback_ID#" null="no" />
			</cfstoredproc>
	 	</cfif>
	</cffunction>
	
	<!--- XXXXXXXXXXXX	BrkPBDelete     	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	<!--- BrkPBDelete remove log entries or unalppy PB's when a BB is deleted --->
	<cffunction access="public" name="BrkPBDelete" returntype="void">
		<cfargument name="Billabck_Id" type="any" required="true">
			<!--- --Update Applied Brokerage Exclusion Records.
				  -- This joins on L.Applied_To_Billback_Id. If the Broker BB gets deleted we unapply them here --->
		<cfif application.appSettingsGet.getBrokerage_Functionality_On()>
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qUnApplyBrkPB">
				UPDATE Brk_PB_Log
				SET Applied = 0,
					Applied_To_Billback_Id = Null,
					Applied_Dollars = 0,
					Brk_Program_Id = NULL,
					Brk_Program_number = NULL,
					Unapplied_by = '00000000-0000-0000-0000000000000000',
					Unapplied_Date = GetDate()
				FROM Brk_PB_Log L
				WHERE	L.Applied_To_Billback_Id = '#arguments.Billabck_Id#' AND
						L.Applied = 1
			</CFQUERY>
			
				<!--- ---Remove Records from Brokerage Exclusion table
					  ---This joins on the L.BillBack_ID. If the Pullback (non-broker) BB is deleted we delete them here--->
			<CFQUERY DATASOURCE="#application.datasource#" NAME="qDelBrkPB">
				UPDATE Brk_PB_Log
				SET Deleted = 1,
					Deleted_By = '00000000-0000-0000-0000000000000000',
					Deleted_Date = GetDate()
				FROM Brk_PB_Log L
				WHERE	L.BillBack_ID = '#arguments.Billabck_Id#' AND
						L.Applied = 0
			</CFQUERY>
		</cfif>
	</cffunction>
</cfcomponent>