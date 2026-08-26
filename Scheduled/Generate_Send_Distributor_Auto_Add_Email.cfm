<!-----------------------------------------------------------------------------

FILE NAME: 		Generate_Send_Distributor_Auto_Add_Email.cfm
DESCRIPTION:	This file will create a csv and email it to the email addresses.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			Anand Rao	12-Oct-2011	Added 

------------------------------------------------------------------------------> 
 
<cfset strFileOrgName = "Distributor Auto Add" />
<cfset strFileName="#UCase(ReplaceNoCase(strFileOrgName," ","_","ALL"))#_#DateFormat(Now(),"mmddyy")#">
<cfset strFilePath = Application.Doc_Path & "\Data_Files\Created\billbacks\" />

<cfset strFileExtention="csv">
<cfset strCSVFile =  strFileName & "." & strFileExtention />
<cfset strFileURL = strFilePath & strCSVFile />
<cfset vchFileContent = "" />
 
<cfset useLakebaseForgetCompany = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForgetCompany>
	<cftry>
		<cfset getCompany = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"deleted" = "eq.0",
				"select" = "company_main_id"
			}), "company_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCompany = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCompany>
<cfquery name="getCompany" datasource="#application.datasource#">
	select company_main_id
	from company_main
	where deleted = 0
</cfquery>
</cfif>
<CFSET request.AccessStructure.company_main_id = getCompany.company_main_id>
<CFSET request.AccessStructure.user_id = "99999999"> 
 
<!--- Query to get the Email address of the recepients the CSV file has to be sent to ---> 
 	<cfquery name="getCurrentSettings" datasource="#application.datasource#">
		SELECT general_Settings.*, _Users.Name_First, _Users.Name_Last
		FROM general_Settings
			LEFT JOIN _Users
			ON _Users.User_ID = general_Settings.Email_Settings_Updated_By
	</cfquery>
	<cfquery name="getDistributorAutoAddedToPrograms" datasource="#application.datasource#">
		SELECT 
			Billback_ID,
			Contract_main_ID,
			Distributor_ID,
			Billback_Number,
			REPLACE(Billback_Title, ',', '' ) AS Billback_Title,
			Billback_Start_Date,
			Billback_End_Date,
			Program_Number,
			REPLACE(Program_Title, ',', '') AS Program_Title,
			REPLACE(Template_Name, ',', '' ) AS Template_Name,
			Program_RSP,
			Program_RSP_Position,
			Program_Status,
			Program_Start_Date,
			Program_End_Date,
			Distributor_Number,
			REPLACE(Distributor_Name, ',', '' ) AS Distributor_Name,
			REPLACE(Broker_Name, ',', '' ) AS Broker_Name,
			Created_Date
		FROM 
			Log_BB_PRG_AutoAdd_Distributor 
		WHERE 
			Latest = 1
			AND 
			Extracted = 0
	</cfquery>
	
	<!--- 
		Only if the email address is not blank and there are data to be sent run the below to
		a) Generate the CSV 
		b) Email the file to the email addresses from the General_settings table
	--->	
	
    <cfif (isDefined("getCurrentSettings.Send_Distributor_Auto_Add_Email") AND getCurrentSettings.Send_Distributor_Auto_Add_Email NEQ "" AND  getDistributorAutoAddedToPrograms.RecordCount GTE 1)>
		<cfset finalEmailAddress = getCurrentSettings.Send_Distributor_Auto_Add_Email />
		<cfinclude template="/get_Contact_Admin_Email_Address.cfm">
			
        <cfif (getDistributorAutoAddedToPrograms.RecordCount GT 0)>
            <cfscript>
                cells = [   "Billback ##", 
                            "Billback Title", 
                            "Billback Start Date", 
                            "Billback End Date", 
                            "Program ##", 
                            "Program Title", 
                            "Template Name", 
                            "Program RSP", 
                            "Program RSP Position", 
                            "Program Status", 
                            "Program Start Date", 
                            "Program End Date", 
                            "Distributor ##", 
                            "Distributor Name", 
                            "Broker Name"           ]; 
                vchFileContent = cells.toList() & chr(10);
            </cfscript>

			<cfloop Query="getDistributorAutoAddedToPrograms" startRow="1" endRow ="#getDistributorAutoAddedToPrograms.RecordCount#">
                <cfscript>
                    cells = [ application.util.string.csvFormat( Billback_Number ), 
                              application.util.string.csvFormat( Billback_Title ),
                              application.util.string.csvFormat( dateFormat(Billback_Start_Date, "m/d/yyyy") ),
                              application.util.string.csvFormat( dateFormat(Billback_End_Date, "m/d/yyyy") ),
                              application.util.string.csvFormat( Program_Number ),
                              application.util.string.csvFormat( Program_Title ),
                              application.util.string.csvFormat( Template_Name ),
                              application.util.string.csvFormat( Program_RSP ),
                              application.util.string.csvFormat( Program_RSP_Position ),
                              application.util.string.csvFormat( Program_Status ),
                              application.util.string.csvFormat( dateFormat(Program_Start_Date, "m/d/yyyy") ),
                              application.util.string.csvFormat( dateFormat(Program_End_Date, "m/d/yyyy") ),
                              application.util.string.csvFormat( Distributor_Number ),
                              application.util.string.csvFormat( Distributor_Name ),
                              application.util.string.csvFormat( Broker_Name )          ];

                    vchFileContent = vchFileContent & cells.toList() & chr(10);
                </cfscript>
			</cfloop>
             
 	  <cffile action="write" file="#strFileURL#" output="#vchFileContent#" nameconflict="overwrite"> 
		 File Successfully Generated.[Status: OK]....<br><br>    
		</cfif>
 
			 <cf_EmailWrapper 
				to="#finalEmailAddress#" 
				from="#Contact_Admin_Email_Address#" 
				subject="Distributors Auto Added to Programs" 
				type="HTML"
				messagetype="1" 
				generatedby="1" 
				apparea="1">
	 				Attached report shows the distributors which were auto added to programs.<br><br>
					<CF_Writing_Email_Attachment
	  				Naming_Format="#strFileName#"
					File_Extension="#strFileExtention#"
					Relative_Path="\Data_Files\Created\billbacks\"
					Output_Content="#vchFileContent#"
					addNewLine="No"
					Return_File_Name="fName">				
					<cf_emailwrapperparam file = "#fName#" store="yes" />
			 
		</cf_EmailWrapper> 
	
	
		<cfset useLakebaseForupd = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("log_bb_prg_autoadd_distributor")>
<cfif useLakebaseForupd>
	<cftry>
		<cfset application.oLakebase.updateRows("log_bb_prg_autoadd_distributor",
			{
				"latest" = "eq.1",
				"extracted" = "eq.0"
			},
			{
				"latest" = "0",
				"extracted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupd = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupd>
<cfquery name="upd" datasource="#application.datasource#">
			UPDATE 
				Log_BB_PRG_AutoAdd_Distributor
			SET 
				Latest = 0,
				Extracted = 1
			WHERE 
				Latest = 1
			AND 
				Extracted = 0
			
		</cfquery>
</cfif>
 
	</cfif><!--- ENDS: <cfif getCurrentSettings.Send_Distributor_Auto_Add_Email NEQ "" AND  getDistributorAutoAddedToPrograms.RecordCount GTE 1> --->
	 
	
 

 
 