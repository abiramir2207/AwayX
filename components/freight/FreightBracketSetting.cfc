<cfcomponent name="Freight Data">

	<cfset this.FREIGHT_VERSION_ITEM = 'classCode'/>
	<cfset this.bFREIGHT_VERSION_ITEM = false/>
	<cfset this.FREIGHT_VERSION_DEFAULT = '' />
	<cfset this.FREIGHT_VERSION = '' />
	<!--- Get freight settings --->
	<cffunction name="getFreightSettings" output="no" returntype="query">
		<CFQUERY NAME="qrygetFreightSettings" DATASOURCE = "#Application.Datasource#">
			 SELECT *
			 FROM Freight_Settings
			 WHERE Freight_Setting_ID = 1
		</CFQUERY>
		<cfif qrygetFreightSettings.Version EQ this.FREIGHT_VERSION_ITEM>
			<cfset this.bFREIGHT_VERSION_ITEM = true />
		</cfif>
	  <cfset this.FREIGHT_VERSION = qrygetFreightSettings.Version />
	  <cfreturn qrygetFreightSettings>
	</cffunction>
	
	<!--- Get freight bracket Info --->
	<cffunction name="getFreightBracketInfo" output="no" returntype="query">
			<CFQUERY NAME="qrygetFreightBracketInfo" DATASOURCE = "#Application.Datasource#">
			 SELECT flbs.*,u.Name_First + ' ' + u.Name_Last As User_Modifier
			 FROM Freight_Lookup_Bracket_Settings flbs
			 INNER JOIN _Users u
			 ON flbs.Freight_Bracket_Creator_ID = u.User_ID
			 ORDER BY Freight_Bracket_Setting_ID
			</CFQUERY>

	  <cfreturn qrygetFreightBracketInfo>
	</cffunction>
	
	<cffunction name="getMaxFreightBracket" output="no" returntype="numeric"> 
		<CFQUERY NAME="qGetMaxFreightBracket" DATASOURCE = "#Application.Datasource#">
		 	SELECT 	MAX(Freight_Lookup_Bracket_Settings.Freight_Bracket_Setting_ID) as Max_Freight_Bracket_Setting_ID
		 	FROM 	Freight_Lookup_Bracket_Settings
		</CFQUERY>

	  	<cfreturn val(qGetMaxFreightBracket.Max_Freight_Bracket_Setting_ID)>
	</cffunction>	

	<!--- Set freight bracket Info --->
	<cffunction name="SetFreightBracketInfo" output="no">
		<cfargument name="formValues" type="string" required="true">
		<cfargument name="TotalBrackets" type="numeric" required="true">

			<CFQUERY NAME="qrySetFreightBracketInfo" DATASOURCE = "#Application.Datasource#">
			BEGIN TRANSACTION
			BEGIN
			<!--- Insert into "Bracket History", the previous freight values --->
			INSERT INTO Freight_Bracket_History(Freight_Bracket_Setting_ID,Freight_Bracket_Code,Freight_Bracket_Label
			,Freight_Bracket_From,Freight_Bracket_To,Freight_Bracket_Modified_By,Freight_Bracket_Modified_Date)		
			SELECT * FROM Freight_Lookup_Bracket_Settings
			END
			
			BEGIN
			TRUNCATE TABLE Freight_Lookup_Bracket_Settings
			END
			
			<!--- The function argument (formValues) does not need to be used. This CFC can read the values
				  in the form scope ---> 
			BEGIN
			<cfloop from="1" to="#arguments.TotalBrackets#" index="i">
				<cfset Freight_Bracket_Code = Evaluate('form.txtCode_'&i)>	
				<cfset Freight_Bracket_Label = Evaluate('form.txtLabel_'&i)>
				<cfset Freight_Bracket_From = Evaluate('form.txtFrom_'&i)>
				<cfset Freight_Bracket_To = Evaluate('form.txtTo_'&i)>
				
			<!--- Insert the new settings --->
			INSERT INTO Freight_Lookup_Bracket_Settings(Freight_Bracket_Code,Freight_Bracket_Label,Freight_Bracket_From
			,Freight_Bracket_To,Freight_Bracket_Creator_ID)		
			VALUES('#Freight_Bracket_Code#','#Freight_Bracket_Label#','#Freight_Bracket_From#'
			,'#Freight_Bracket_To#','#request.AccessStructure.user_id#')	
			</cfloop>
			
			<!--- Set the settings for freight --->
			UPDATE Freight_Settings
			SET Recalculate_Invoice_Table_Brackets = #chkCalculateInvoice#
			WHERE Freight_Setting_ID = 1
			
			END
			COMMIT TRANSACTION
			</CFQUERY>
	</cffunction>

	<!--- Get freight settings --->
	<cffunction name="getFreightVersionItem" output="no" returntype="boolean">
		<cfset getFreightSettings() />
	  	<cfreturn this.bFREIGHT_VERSION_ITEM />
	</cffunction>
</cfcomponent>