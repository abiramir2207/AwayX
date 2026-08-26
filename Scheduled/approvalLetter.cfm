<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<!--- Create letter based on app setting [begin] --->

<!---//////////////**********************************************************************************************************************////////////// --->
<!--- CUSTOM 1 (BASED ON "<CFDOCUMENT>") LETTER) --->
<cfif appSettings.getlettersavailable() eq 2>

<!---------------------------------------------------------------------------------------------------------------------
  This scheduled task supports these features:

  - Generate summarized (Internal )letters (Operator Letter: All operators, No distributors) and Distributor Letter: All Distributors and All Operators
    Email these to internal recipients (internal users).
  - Generate Operator Letters letters - One operator per letter and all distributors. Email it to "Operator recipients"
   - Generate distributor letters - One distributor per letter and all operators. Email it to "Distributor recipients"
  - Tracks its running status (saved in Contract_Main_Aux_Data.Approval_Letter_Last_*), can schedule itselft to resume
    where it left off
  - Optionally log all running steps in 3 formats (simple, medium, detail)
  - Delete by itself when it completes

  Task Name = application.returned_customer_setting.Company_Name + " Letter_" + request.Contract_Main_Id
              ( e.g. Dev 7.0 Letter_99992 )
  Log File Name = application.returned_customer_setting.Company_Name + " Letter_" + request.Contract_Main_Id
              ( e.g. Dev 7.0 Letter_99992.log )

  Stage 1: approval_letter_last_group = 'internal'
           approval_letter_last_id_email = 'generated'
            a. generate internal letters (all operators, all distributors)
            b. email internal letters

  Stage 2: approval_letter_last_group = 'operator'
           approval_letter_last_id_email = 'generated' or 'operator_id|email_recipient'
            a. generate all operator letters
            b. email letters to selected operators

  Stage 3: This stage runs for 5 distributors at a time. Generate letters for 5 distributors and then email it to "distributor recipients". Repeat this step.
  		   approval_letter_last_group = 'distributor'
           approval_letter_last_id_email = 'generated' or 'distributor_id|email_recipient'
            a. generate all distributor letters
            b. email letters to selected distributors
----------------------------------------------------------------------------------------------------------------------->

<cfscript>
  Detail_Log = 30;
  Medium_Log = 20;
  Simple_Log = 10;
  TIMEOUT_SECONDS = 300;

  liveSite   = 1;    //TODO:  set this to 1 before checking in the file to CVS

  if ( liveSite eq 1 )
    LogStatus_Level = 0;
  else
    LogStatus_Level = Detail_Log;
</cfscript>

<cfif not StructKeyExists(URL, "Contract_Main_ID")>
  <cfabort>
</cfif>

<cfoutput>
<cfsetting requesttimeout=#TIMEOUT_SECONDS#>
</cfoutput>
<cfset variables.Started = now()>


<!--- Combine gets and posts into the request scope --->
<cfif isDefined("URL")>
  <cfset structAppend(request, URL, true)/>
</cfif>
<cfif isDefined("FORM")>
  <cfset structAppend(request, form, true)/>
</cfif>

<!--- get program info --->
<cfquery name="getProgramInfo" datasource="#application.datasource#">
 SELECT Right(Contract_Number, 7) as Partial_Contract_Number, CASE
									WHEN LEN(revision_version) = 4 THEN RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 4)
									WHEN LEN(revision_version) = 5 THEN RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 3)
								END as Revision_Version, Contract_Title
 FROM Contract_Main
 WHERE Contract_Main_ID	= <cfqueryparam cfsqltype="cf_sql_integer" value="#request.Contract_Main_ID#">
</cfquery>

<!--- retrieve task parameters (contacts, last group, last id). This query checks to see whether letters need to be emailed
      and to whom should it be emailed.
--->
<cfquery name="rsTask" datasource="#application.datasource#">
	SELECT	CMAD.Approval_Letter_Distributor_Emails
	        ,CMAD.Approval_Letter_Operator_Emails
	        ,CMAD.Approval_Letter_Internal_Emails
	        ,CMAD.Approval_Letter_Last_Group
	        ,CMAD.Approval_Letter_Last_Id_Email
	        ,CM.Contract_Start_date
	        ,CMAD.Approval_Letter_Email_Message
  	FROM	Contract_Main_Aux_Data CMAD
  	      INNER JOIN Contract_Main CM ON CM.Contract_Main_ID = CMAD.Contract_Main_ID
	 WHERE	CMAD.Contract_Main_ID	=	<cfqueryparam cfsqltype="cf_sql_integer" value="#request.Contract_Main_ID#">
</cfquery>

<!--- if no record is returned (this should not happen) bail out --->
<cfif rsTask.recordCount eq 0>
  <cfset UpdateTask("Error")>
  <cfset LogStatus("Error: program.Contract_Main_ID " & request.Contract_Main_ID & " was not found.")>
  <cfabort>
</cfif>

<cfset LogStatus("Starting letters generation task...", Simple_Log)>
<!--------------------------------------------------------------------------------------------------------------------->

<!---Stage 1: first time running the task or last processed group was internal--->
<!--- If the Approval_Letter_Last_Group is blank (Internal letters being the first step) OR "Internal" --->
<cfif (trim(rsTask.Approval_Letter_Last_Group) eq "") or (rsTask.Approval_Letter_Last_Group eq "internal")>
    <cfset LogStatus("Starting internal letters...", Simple_Log)>
    <!---are there internal recipients?--->
    <cfif len(trim(rsTask.Approval_Letter_Internal_Emails)) eq 0>
      <cfset LogStatus("Internal recipient was null, skipped internal letters.", Medium_Log)>
    <cfelse>

      <!---a. generate internal letters--->
      <cfif rsTask.approval_letter_last_id_email neq "generated">
        <cfset LogStatus("Generating internal letters...", Medium_Log)>

		<!---start generating internal letters--->
        <cfset GenerateInternalLetters()>

        <!---mark status as generated--->
        <cfset UpdateDb(last_group="internal", last_id_email="generated")>

        <!---<cfset HandleTimeOut(last_group="internal", last_id_email="generated")>--->
        <cfset LogStatus("Done with generating internal letters...", Medium_Log)>
      </cfif>

      <!---b. send letters to internal recipients--->
      <cfset EmailInternalLetters()>

    </cfif>
    <!---update tracking status - last_group="operator" means that next step is now "Operator". --->
    <cfset UpdateDb(last_group="operator", last_id_email="")>
    <!---<cfset HandleTimeOut(last_group="operator", last_id_email="")>--->
    <cfset LogStatus("Ending internal letters...", Simple_Log)>
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->

<!---Stage 2: done with internal group, start with operator group--->
<cfif (rsTask.Approval_Letter_Last_Group eq "operator")>
    <!---are there operator recipients?--->
    <cfif len(trim(rsTask.Approval_Letter_Operator_Emails)) eq 0>
      <cfset LogStatus("Operator recipient was null, skipped operator letters.", Medium_Log)>
    <cfelse>
      <!---a. generate operator letters--->
      <cfset LogStatus("Starting operator letters...", Simple_Log)>
      <!---generate operator letters if it was not done already (last_id_email is empty)--->
      <cfif ( rsTask.approval_letter_last_id_email eq "" )>
        <cfset LogStatus("Generating operator letters...", Medium_Log)>

		<!---start generating operator letters--->
        <cfset GenerateOperatorLetters()>

        <!--- mark status as generated--->
        <cfset UpdateDb(last_group="operator", last_id_email="generated")>

        <!---<cfset HandleTimeOut(last_group="operator", last_id_email="generated")>--->
        <cfset LogStatus("Done with generating operator letters...", Medium_Log)>
      </cfif>

      <!---find unprocessed operators--->
      <cfset operatorsArray = filterEntries(entriesList = rsTask.Approval_Letter_Operator_Emails,
                                            lastEntry = rsTask.Approval_Letter_Last_ID_Email)>

	  <!---b. send letters to operators --->
      <cfset EmailOperatorLetters(operatorsArray)>
      <cfset LogStatus("Ending operator letters...", Simple_Log)>
    </cfif>

    <!---update tracking status- last_group="distributor" means that next step is now "Distributor". --->
    <cfset UpdateDb(last_group="distributor", last_id_email="")>
    <!---<cfset HandleTimeOut(last_group="distributor", last_id_email="")>--->
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->

<!---Stage 3: done with operator group, start with distributor group--->
 <cfif (rsTask.Approval_Letter_Last_Group eq "distributor")>
 	 <!---are there distributor recipients?--->
    <cfif len(trim(rsTask.Approval_Letter_Distributor_Emails)) eq 0>
      <cfset LogStatus("Distributor recipient was null, skipped distributor letters.", Medium_Log)>
	  <!---done with all three groups, bail out--->
	  <cfset LogStatus("Ending letters generation task...", Simple_Log)>
	  <!--- The task is complete. "Last ID Email" is not relevant anymore as we do not have to track the recipients of the email once the task is complete --->
	  <cfset UpdateDb(last_group="done", last_id_email="")>
	  <cfset UpdateTask("done")>
	  <cfabort>
    <cfelse>
      <!---a. generate distributor letters--->
      <cfset LogStatus("Starting distributor letters...", Simple_Log)>
        <cfset LogStatus("Generating distributor letters...", Medium_Log)>

	<!--- THERE CAN BE A LARGE NUMBER OF DISTRIBUTORS IN A PROGRAM. GENERATING LETTERS FOR ALL THESE DISTRIBUTORS IN ONE REQUEST
		  CAUSES CF MEMORY ISSUES BECAUSE WE NEED TO GET DATA FOR ALL THESE DISTRIBUTORS AND KEEP IT IN MEMORY. MOREOVER WE NEED THAT
		  DATA ON THE LETTERS WHICH TAKES EVEN MORE MEMORY COMSUMPTION AS THE LETTERS ARE KEPT IN MEMORY UNTIL THE REQUEST IS COMPLETE
	--->
	<!--- THE DISTRIBUTOR LETTERS ARE BEING GENERATED 5 LETTERS AT A TIME, I.E. IN ONE REQUEST --->

	  <!--- These distributors come from the "contacts" link on the program summary page. So, when the user selects "email recipients"
	  	    from the contact page. some of those recipients could be associated with the same distributor. So, the code below makes
	  	    sure that the distributor list is UNIQUE as we do not want to generate letters for a distributor  more than once
	  --->
	  <cfset unique_list_distributor_IDs = "">
	  <cfloop list="#rsTask.approval_letter_distributor_emails#" index="distributor_ID_email">
	    <cfif Len(distributor_ID_email)>
			<cfif ListFind(unique_list_distributor_IDs,ListFirst(distributor_ID_email,'|')) eq 0>
				<cfset unique_list_distributor_IDs = ListAppend(unique_list_distributor_IDs, ListFirst(distributor_ID_email,'|'))>
			</cfif>
	    </cfif>
	  </cfloop>

	  <!--- If distributors exist, the send the list of those unique distributors to a query. The query will return TOP 5 records
	        of those distributors from the list sent to it for whom letters have not been generated.
	  --->
	  <cfif ListLen(unique_list_distributor_IDs) GT 0>
	  	     <!--- TOP 5 distributors for whom letters have not been generated --->
			<cfset qgetDistributors = getDistributors(unique_list_distributor_IDs)>
			<cfset current_processing_distributor_list = ValueList(qgetDistributors.BSA_Foodservice_Customers_ID)>
		<cfelse>
			<cfset current_processing_distributor_list = "">
	  </cfif>

	    <!--- Get a count of distributors form whom letters still need to be generated. Note: the count takes into account the
			start of the current request and not the end.
		 --->
	    <cfset qgetRemainingDistributors = getDistributors(unique_list_distributor_IDs,1)>

		<!---start generating distributor letters for 5 distributors at a time--->
        <cfset GenerateDistributorLetters(current_processing_distributor_list)>

		<!--- Since we are generating letters for 5 distributors at a time, but more than one (DistID and Email) combinations exist. The
		      code below gets all the emails associated with those 5 distributors.
		      For eg: If we had a request for x number of distributors, the email list will look similar to below -
		      2ccc497e-cd45-43a4-95be-4dd4400de99d|x@y.com,69caf4fa-95bd-4f62-9927-056dd844116d|y@z.com,2ccc497e-cd45-43a4-95be-4dd4400de99d|z@z.com,
		      2ccc497e-cd45-43a4-95be-4dd4400de99d|a@a.com,39968f0f-4ed4-4a35-8eaf-8176bda61c1a|mmushran@bigredflame.com,
		      5ace549c-63e7-4ea9-ab7d-e0a3fd38ede5|mmushran@bigredflame.com,c66b8fb6-246d-4cc0-bbc3-7d194f014067|mmushran@bigredflame.com.

		      In the code above, all the entries of the comma delimited list has distributor id and email address separated by a pipe.

		      In the list above "2ccc497e-cd45-43a4-95be-4dd4400de99d" is associated with multiple email id's and so "unique_list_distributor_IDs"
		      will have list of the unique distributor id's and will not repeat "2ccc497e-cd45-43a4-95be-4dd4400de99d".

		      On the other hand "list_distributor_id_email" will get all the possible combinations of "2ccc497e-cd45-43a4-95be-4dd4400de99d" above
		      as the distributor letter needs to be emailed to all of the users associated with that distributor id.

		      One thing to keep in mind is that both the list will contain only those distributors which are a part of "TOP 5" only as only 5
		      letters are generated at a time.
		--->
		<cfset list_distributor_id_email = "">
		<cfloop list="#rsTask.approval_letter_distributor_emails#" index="distributor_ID_email">
		    <cfif Len(distributor_ID_email)>
				<cfif ListFind(current_processing_distributor_list,ListFirst(distributor_ID_email,'|')) neq 0>
					<cfset list_distributor_id_email = ListAppend(list_distributor_id_email, distributor_ID_email)>
				</cfif>
		    </cfif>
		</cfloop>

		  <!---find unprocessed distributors--->
		  <!---
	      <cfset distributorsArray = filterEntries(entriesList = rsTask.Approval_Letter_Distributor_Emails,
	                                                 lastEntry = rsTask.Approval_Letter_Last_ID_Email)>
	      --->

		 <!---b. send letters to distributors --->
		<cfset EmailDistributorLetters(list_distributor_id_email)>

    </cfif>

</cfif>
<!-----------------------------------------------------------------------------------------------------------------------------------
--->
<!---  USER-DEFINED FUNCTIONS  --------------------------------------------------------------------------------------------------------->

<!-------------------------------------------------------------------------------------------------------------------------------------->
<!---
<cffunction name="HandleTimeOut" output="false" returntype="void" hint="Handles time out situation">
  <cfargument name="last_group" type="string" required="true" hint="">
  <cfargument name="last_id_email" type="string" required="true" hint="">

  <cfscript>
   var x_Seconds = 3;
   var elapsedSeconds = DateDiff('s', variables.started, now());
  </cfscript>
  <!---if the elapsed time since the task started + x seconds
       is greater than or equal to
       the request time out defined at the top we need to bail out
  --->
  <cfif ( elapsedSeconds + x_Seconds ) gte TIMEOUT_SECONDS>
    <cfset UpdateTask("timeout")>
    <cfset LogStatus("Timed out: last_group=" & arguments.last_group
                        & "; last_id_email=" & arguments.last_id_email
                        & "; elapsed time=" & elapsedSeconds & " seconds")>
    <!---bailing out --->
    <cfabort>
  </cfif>
</cffunction>
--->

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="UpdateDb" output="true" returntype="void" hint="Update tracking information in the database">
  <cfargument name="last_group" type="string" required="true" hint="">
  <cfargument name="last_id_email" type="string" required="true" hint="">

  <cfquery name="rsTask" datasource="#application.datasource#">
    UPDATE		Contract_Main_Aux_Data
  	   SET	  Approval_Letter_Last_Group = '#arguments.last_group#'
  	          ,Approval_Letter_Last_Id_Email = '#arguments.last_id_email#'
  	 WHERE		Contract_Main_ID	=	<cfqueryparam cfsqltype="cf_sql_integer" value="#request.Contract_Main_ID#">

  	SELECT	  CMAD.Approval_Letter_Distributor_Emails
  	          ,CMAD.Approval_Letter_Operator_Emails
  	          ,CMAD.Approval_Letter_Internal_Emails
  	          ,CMAD.Approval_Letter_Last_Group
  	          ,CMAD.Approval_Letter_Last_Id_Email
  	          ,CM.Contract_Start_date
	            ,CMAD.Approval_Letter_Email_Message
    	FROM		Contract_Main_Aux_Data CMAD
    	        INNER JOIN Contract_Main CM ON CM.Contract_Main_ID = CMAD.Contract_Main_ID
  	 WHERE		CMAD.Contract_Main_ID	=	<cfqueryparam cfsqltype="cf_sql_integer" value="#request.Contract_Main_ID#">
  </cfquery>

</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<!--- This job will run  and create letters. Once the letters are completed, the job will be deleted. If for some reason,
	  the job did not succeed - eg: CF needed to be restarted, then since the job is scheduled to run every 8 hours, the
	  job will start again and run until the letters are completed and then delete itself.
--->
<cffunction name="UpdateTask" output="true" returntype="void" hint="Update scheduled task">
  <cfargument name="status" type="string" required="true" hint="">

  <cfscript>
    var x_Minutes = 1;
    // schedule the task to run again in x minutes
    var startAgain = DateAdd('s', 60 * x_Minutes, now());
    var endDate  = dateAdd("d",2,dateFormat(now(),'mm/dd/yyyy'));
    var taskName = application.returned_customer_setting.Company_Name & " Letter_" & request.Contract_Main_Id;
  </cfscript>

  <cfswitch expression="#arguments.status#">
    <cfcase value="batches">
      <cfschedule
          action = "update"
          task = #taskName#
          interval = "28800" <!--- Every 8 hours (28800 seconds) --->
          operation = "HTTPRequest"
          startDate = #startAgain#
		  endDate = "#endDate#"
          startTime = #TimeFormat(startAgain,'short')#
          url = "#application.HTTPVar##cgi.server_name#/Scheduled/approvalLetter.cfm?Contract_Main_ID=#request.Contract_Main_ID#">
    </cfcase>
    <cfcase value="error,done">
      <cfschedule
        action = "delete"
        task = #taskName#>
    </cfcase>
  </cfswitch>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="LogStatus" output="true" returntype="void" hint="Log status to a log file.">
  <cfargument name="status" type="string" required="true" hint="">
  <cfargument name="level" type="numeric" required="false" default="#detail_log#">

  <cfscript>
    var logFile = application.returned_customer_setting.Company_Name & " Letter_" & request.Contract_Main_Id;
  </cfscript>

  <!---is logging enabled?--->
  <cfif LogStatus_Level neq 0>
    <!---is there anything to log?--->
    <cfif len(trim(arguments.status))>
      <!---is the overall log level greater than the log message's level write the log message otherwise ignore--->
      <cfif LogStatus_Level gte arguments.level>
        <cflog file="#logFile#" text="#arguments.status#">
      </cfif>
    </cfif>
  </cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="GenerateInternalLetters" output="true" returntype="void" hint="Generate letters for internal recipients.">
  <cfscript>
    var letter_type = 0;
  </cfscript>
  <cfloop from="1" to="2" index="letter_type">
  	<cfmodule
            template = "/common_files/contracts/letters/auto_generate_gateway.cfm"
            bAuto = "1"
            contract_main_id = #request.Contract_Main_ID#
            letter_type = #letter_type#
			<!--- multiple distributors per letter --->
            distributor_letter_type = "2"
			<!--- All operators --->
            dis_letter_settings = "2"
			<!--- multiple operators per letter --->
            operator_letter_type = "2"
			<!--- No distributors --->
            opr_letter_settings = "3"
            timeout_seconds = #(TIMEOUT_SECONDS - 7)#

	    generateoperatorletters = 1

            user_id = "00000000-0000-0000-0000000000000001"
            />
  </cfloop>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="EmailInternalLetters" output="true" returntype="void" hint="Email letters to internal recipients.">
  <cfscript>
    var rsLetters = 0;
  </cfscript>

  <!---locate the generated letters--->
  <cfquery name="rsLetters" datasource="#application.datasource#">
  	SELECT	  Letter_Name
  	          ,Letter_Path
  	          ,Created_Date
  	          ,Operator_Name
  	          ,Distributor_Name
    	FROM		Program_Letters
  	 WHERE		Program_ID	=	<cfqueryparam cfsqltype="cf_sql_integer" value="#request.Contract_Main_ID#">
  	          AND Deleted = 0
  	          AND System_Generated = 1
  	          AND
  	          (
	  			  (Letter_Type = 1 AND Operator_Name = 'All operators' AND Distributor_name = 'No Distributors')
	  			   OR
	  			  (Letter_Type = 2 AND Operator_Name = 'All operators' AND Distributor_name = 'All Distributors')
	  		  )
  </cfquery>


	<cfif rsLetters.recordCount>
  	<cfloop query="rsLetters">
      <cfset LogStatus("Emailing internal letter ["
                          & rsLetters.letter_name
                          & "] to " & rsTask.Approval_Letter_Internal_Emails, Detail_Log)>

        <!---
		Letter Subject format:
		1000306 001[2 spaces] Program Title [2 spaces] Distributor Name [2 spaces] Date/Timestamp
		--->
		<cfset FinalLetterName = getProgramInfo.Partial_Contract_Number
								& " "
								& getProgramInfo.Revision_Version
								& "  "
								& getProgramInfo.Contract_Title
								& "  "
								& dateformat(rsLetters.Created_Date,"mm_dd_yyyy")
					            & "_"
					            & timeformat(rsLetters.Created_Date,"hh_mm_sstt")  />

	<!--- Keep the "from" attribute blank. We cannot use any user's email as this gets generated from the scheduled task.
	The logic to populate the "from" attribute is on "EmailWrapper.cfm".
	--->
    	<cf_EmailWrapper
    		to = #rsTask.Approval_Letter_Internal_Emails#
    		from = ""
    		subject = #FinalLetterName#
    		type = "HTML"
    		messagetype = "1"
    		generatedby = "1"
    		apparea = "1"
		programLettersEmail="1">
 				<cf_emailwrapperparam file = "#ReplaceNoCase(rsLetters.Letter_Path,'.htm','.pdf')#" store="yes" />
 			</cf_EmailWrapper>

    </cfloop>
  </cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="EmailOperatorLetters" output="true" returntype="void" hint="Generate letters for operator recipients">
  <cfargument name="operators" type="array" required="true" hint="">

  <cfscript>
   var ArrayElement = 0;
   var operatorID = 0;
   var email = 0;
   var rsLetters = 0;
  </cfscript>

  <!---email letters to selected operators--->
  <cfloop array="#arguments.operators#" index="ArrayElement">
    <cfset operatorID = ListFirst(ArrayElement, '|')>
    <cfset email = ListGetAt(ArrayElement, 2, '|')>

    <!---locate the generated letters for this operator--->
    <cfquery name="rsLetters" datasource="#application.datasource#">
    	SELECT	  TOP 1
    	          PL.Letter_Name
    	          ,PL.Letter_Path
    	          ,PL.Created_Date
    	          ,BO.Operator_Name
    	  FROM    Bsa_Operator BO, Program_Letters PL
    	 WHERE		BO.Bsa_Operator_Id = #operatorID#
    	          AND PL.Program_ID	=	<cfqueryparam cfsqltype="cf_sql_integer" value="#request.Contract_Main_ID#">
    	          AND PL.Letter_Type = 1
    	          AND PL.Deleted = 0
    	          AND PL.System_Generated = 1
    	          AND PL.Operator_Name = BO.Operator_Name
    	          AND PL.Distributor_name = 'No #application.returned_customer_setting.distributor_label_plural#'
    </cfquery>

  	<cfif rsLetters.recordCount>
    	<cfloop query="rsLetters">
        <cfset LogStatus("Emailing operator letter ["
                            & rsLetters.letter_name
                            & "] to " & email)>

        <!---
		Letter Subject format:
		1000306 001[2 spaces] Program Title [2 spaces] Distributor Name [2 spaces] Date/Timestamp
		--->
		<cfset FinalLetterName = getProgramInfo.Partial_Contract_Number
								& " "
								& getProgramInfo.Revision_Version
								& "  "
								& getProgramInfo.Contract_Title
								& "  "
								& rsLetters.Operator_Name
								& "  "
								& dateformat(rsLetters.Created_Date,"mm_dd_yyyy")
					            & "_"
					            & timeformat(rsLetters.Created_Date,"hh_mm_sstt")  />

	<!--- Keep the "from" attribute blank. We cannot use any user's email as this gets generated from the scheduled task.
	The logic to populate the "from" attribute is on "EmailWrapper.cfm".
	--->
      	<cf_EmailWrapper
      		to = #email#
      		from = ""
      		subject = #FinalLetterName#
      		type = "HTML"
      		messagetype = "1"
      		generatedby = "1"
      		apparea = "1"
		programLettersEmail="1">
   				<cf_emailwrapperparam file = "#ReplaceNoCase(rsLetters.Letter_Path,'.htm','.pdf')#" store="yes" />
          <!---convert all linefeeds to <br/> due to html email format--->
  				#Replace(rsTask.Approval_Letter_Email_Message, chr(13), "<br/>", "all")#
  				<br/><br/>
   			</cf_EmailWrapper>
      </cfloop>
    </cfif>

    <!---save operator id, operator recipient email in db for running status tracking--->
    <cfset UpdateDb(last_group="operator", last_id_email="#operatorID#|#email#")>
    <!---<cfset HandleTimeOut(last_group="operator", last_id_email="#operatorID#|#email#")>--->
  </cfloop>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="EmailDistributorLetters" output="true" returntype="void" hint="Email letters to distributor recipients">
  <cfargument name="distributor_id_email" type="string" required="true" hint="">

    <cfset arr_distributor_id_email = ListToArray(arguments.distributor_id_email)>

  <cfscript>
   var email = 0;
   var ArrayElement = 0;
   var distributorID = 0;
   var rsLetters = 0;
  </cfscript>

  <!---email letters to selected distributors--->
  <cfloop array="#arr_distributor_id_email#" index="ArrayElement">
    <cfset distributorID = ListFirst(ArrayElement, '|')>
    <cfset email = ListGetAt(ArrayElement, 2, '|')>

    <!---locate the generated letters for this distributor--->
    <cfquery name="rsLetters" datasource="#application.datasource#">
    	SELECT	  TOP 1
    	          PL.Letter_Name
    	          ,PL.Letter_Path
    	          ,PL.Created_Date
    	          ,BFC.Name
    	  FROM    Bsa_Foodservice_Customers BFC, Program_Letters PL
    	 WHERE		BFC.Bsa_Foodservice_Customers_Id = '#distributorID#'
    	          AND PL.Program_ID	=	<cfqueryparam cfsqltype="cf_sql_integer" value="#request.Contract_Main_ID#">
    	          AND PL.Letter_Type = 2
    	          AND PL.Deleted = 0
    	          AND PL.System_Generated = 1
    	          AND PL.Distributor_Name = BFC.Name
    	          AND PL.Operator_name = 'All #application.returned_customer_setting.operator_label_plural#'
    </cfquery>

  	<cfloop query="rsLetters">
      <cfset LogStatus("Emailing distributor letter [" & rsLetters.letter_name & "] to " & email)>

		<!---
		Letter Subject format:
		1000306 001[2 spaces] Program Title [2 spaces] Distributor Name [2 spaces] Date/Timestamp
		--->
		<cfset FinalLetterName = getProgramInfo.Partial_Contract_Number
								& " "
								& getProgramInfo.Revision_Version
								& "  "
								& getProgramInfo.Contract_Title
								& "  "
								& rsLetters.Name
								& "  "
								& dateformat(rsLetters.Created_Date,"mm_dd_yyyy")
					            & "_"
					            & timeformat(rsLetters.Created_Date,"hh_mm_sstt")  />

	<!--- Keep the "from" attribute blank. We cannot use any user's email as this gets generated from the scheduled task.
	The logic to populate the "from" attribute is on "EmailWrapper.cfm".
	--->
    	<cf_EmailWrapper
    		to = #email#
    		from = ""
    		subject = #FinalLetterName#
    		type = "HTML"
    		messagetype = "1"
    		generatedby = "1"
    		apparea = "1"
		programLettersEmail="1">

 				<cf_emailwrapperparam file = "#ReplaceNoCase(rsLetters.Letter_Path,'.htm','.pdf')#" store="yes" />
           <!---convert all linefeeds to <br/> due to html email format--->
  				#Replace(rsTask.Approval_Letter_Email_Message, chr(13), "<br/>", "all")#
  				<br/><br/>
 			</cf_EmailWrapper>
    </cfloop>


    <!---save distributor id, distributor recipient email in db for running status tracking--->
    <cfset UpdateDb(last_group="distributor", last_id_email="#distributorID#|#email#")>
    <!---<cfset HandleTimeOut(last_group="distributor", last_id_email="#distributorID#|#email#")>--->
  </cfloop>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="filterEntries" output="true" returntype="array" hint="Returns unprocessed entries (letter not emailed)">
  <cfargument name="entriesList" type="string" required="true" hint="">
  <cfargument name="lastEntry" type="string" required="true" hint="">

  <cfscript>
   var finder = 0;
   var copier = 0;
   var tempArray = 0;
   var returnArray = 0;
  </cfscript>

  <cfset returnArray = ListToArray(arguments.entriesList)>
  <!---if the group was not processed before (last entry is empty), returns everything--->
  <cfif ( Len(Trim(arguments.lastEntry)) eq 0 ) or ( arguments.lastEntry eq "generated" )>
    <cfreturn returnArray>
  </cfif>

  <cfset tempArray = returnArray>
  <!---group was not processed before, find the ones that are done remove them from the temporary array--->
  <cfloop from="1" to="#ArrayLen(tempArray)#" index="finder">
    <!---find the entry that was last processed--->
    <cfif tempArray[finder] eq arguments.lastEntry>
      <!---found it, add the remaining unprocessed entries to the returning array--->
      <!---reset the returning array to blank--->
      <cfset returnArray = ArrayNew(1)>
      <cfloop from="#(finder + 1)#" to="#ArrayLen(tempArray)#" index="copier">
        <cfset ArrayAppend(tempArray[copier], returnArray)>
      </cfloop>
      <!---done, bail out--->
      <cfreturn returnArray>
    </cfif>
  </cfloop>

  <cfreturn returnArray>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="GenerateOperatorLetters" output="true" returntype="void" hint="Generate letters for operator recipients.">

  <cfset var loc = StructNew()>
  <cfset loc.operator_IDs = ArrayNew(1)>

  <!---gather list of operator IDs that are selected on contacts page--->
  <cfloop list="#rsTask.Approval_Letter_Operator_Emails#" index="loc.operator_ID_email">
    <cfif Len(loc.operator_ID_email)>
      <cfset ArrayAppend(loc.operator_IDs, ListFirst(loc.operator_ID_email,'|'))>
    </cfif>
  </cfloop>

  <cfif ArrayLen(loc.operator_IDs)>
    <!---generate letters--->
  	<cfmodule
            template = "/common_files/contracts/letters/auto_generate_gateway.cfm"
            bAuto = "1"
            contract_main_id = #request.Contract_Main_ID#
			<!--- Operator letter --->
            letter_type = "1"
			<!--- One Operator per Letter --->
            operator_letter_type = "1"
			<!--- No distributors --->
            opr_letter_settings = "3"
            operator_IDs = #ArrayToList(loc.operator_IDs, ',')#
            timeout_seconds = #(TIMEOUT_SECONDS - 7)#

	    generateoperatorletters = 1

            user_id = "00000000-0000-0000-0000000000000001"
            />
  </cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="GenerateDistributorLetters" output="true" returntype="void" hint="Generate letters for distributor recipients.">
  <cfargument name="approval_letter_distributor_id" required="true" type="string" >
	<!---
		- If all the distributor letters are not completed, then proceed to generate letters.
	--->
	<cfif ListLen(arguments.approval_letter_distributor_id) GT 0>
	    <!---generate letters--->
	  	<cfmodule
	            template = "/common_files/contracts/letters/auto_generate_gateway.cfm"
	            bAuto = "1"
	            contract_main_id = #request.Contract_Main_ID#
				<!--- Distributor Letter --->
	            letter_type = "2"
				<!--- One distributor per letter --->
	            distributor_letter_type = "1"
				<!--- All operators --->
	            dis_letter_settings = "2"
			    <!--- This is used to generate letters only for these distributors --->
	            distributor_IDs = #arguments.approval_letter_distributor_id#
	            <!--- This might be needed too. "Dist_ID" variable was already being used when the user selected
			  		  certain distributors from the "create letters page". To avoid any potential bug I am using
			  		  Dist_ID variable too.
			    --->
				dist_ID = #arguments.approval_letter_distributor_id#
	            timeout_seconds = #(TIMEOUT_SECONDS - 7)#
	            user_id = "00000000-0000-0000-0000000000000001"
	            />
    </cfif>

	  <!---
	       If there are no more distributors to be processed, call UpdateTask("done")" to delete the job.
	  --->
	 <cfif ListLen(arguments.approval_letter_distributor_id) eq 0>
		<!---update tracking status--->
		<cfset UpdateDb(last_group="done", last_id_email="")>

		 <!---The letters are completed. Now delete the scheduled task--->
		<cfset UpdateTask("done")>

		<!---mark status as generated--->
		 <cfset LogStatus("Done with generating distributor letters...", Medium_Log)>

		 <cfabort>
	<cfelse>
		<!--- Update the scheduled task which will then run for the next batch of distributors --->
		<cfset UpdateTask("batches")>

		<!--- Get the number of distributors for whom the letters still need to be generated. Write to Log --->
		<cfset LogStatus("Done with generating distributor letters...#qgetRemainingDistributors.recordcount# #application.returned_customer_setting.distributor_label_plural# remaining.", Medium_Log)>
	 </cfif>

</cffunction>

<cffunction name="getDistributors" output="false" returntype="query">
	<cfargument name="distributor_IDs" required="yes" type="string">
	<cfargument name="ignoreTopResults" required="no" type="boolean" default="0">

  	  <!--- Generate letters for 5 distributors at a time. Do not generate letter, if it already exists in the "Program_Letters" table for that distributor. --->
	  <cfquery name="qGetDistributors" datasource="#application.datasource#">
		SELECT <cfif arguments.ignoreTopResults eq 0> TOP 5 </cfif> cd.BSA_Foodservice_Customers_ID
		FROM Contract_Distributors cd
		INNER JOIN BSA_Foodservice_Customers bsafc
		ON cd.BSA_Foodservice_Customers_ID = bsafc.BSA_Foodservice_Customers_ID
		WHERE cd.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Trim(request.Contract_Main_ID)#">
		AND cd.BSA_Foodservice_Customers_ID IN (#ListQualify(arguments.distributor_IDs,"'")#)
		AND cd.Deleted = 0
		AND NOT EXISTS
		(
			SELECT Distributor_ID
			FROM Program_Letters
			WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Trim(request.Contract_Main_ID)#">
			AND Letter_Type = 2
			AND Deleted = 0
			AND cd.BSA_Foodservice_Customers_ID = Distributor_ID
		)
	  </cfquery>

	<cfreturn qGetDistributors>

</cffunction>


<!---//////////////**********************************************************************************************************************////////////// --->
<!--- STANDARD (BASED ON "ITEXT") LETTER) --->
<cfelseif appSettings.getlettersavailable() eq 1>

<!---------------------------------------------------------------------------------------------------------------------
  This scheduled task supports these features:

  - Generate Letters for operators and distributors as if the following are selected from the letters page:
	- Both (distributors and operators)
	- One operator per letter and all distributors
	- One distributor per letter and all operators
	- Add "customer product number" by default

  Task Name = application.returned_customer_setting.Company_Name + " Letter_" + request.Contract_Main_Id
              ( e.g. Dev 7.0 Letter_99992 )
  Log File Name = application.returned_customer_setting.Company_Name + " Letter_" + request.Contract_Main_Id
              ( e.g. Dev 7.0 Letter_99992.log )
----------------------------------------------------------------------------------------------------------------------->

<cfscript>
  Detail_Log = 30;
  Medium_Log = 20;
  Simple_Log = 10;
  TIMEOUT_SECONDS = 300;

  liveSite   = 1;    //TODO:  set this to 1 before checking in the file to CVS

  if ( liveSite eq 1 )
    LogStatus_Level = 0;
  else
    LogStatus_Level = Detail_Log;
</cfscript>

<cfif not StructKeyExists(URL, "Contract_Main_ID")>
  <cfabort>
</cfif>

<cfoutput>
<cfsetting requesttimeout=#TIMEOUT_SECONDS#>
</cfoutput>


<!--- Combine gets and posts into the request scope --->
<cfif isDefined("URL")>
  <cfset structAppend(request, URL, true)/>
</cfif>
<cfif isDefined("FORM")>
  <cfset structAppend(request, form, true)/>
</cfif>


<cfquery name="getContractDetails" datasource="#application.datasource#">
	SELECT	CM.Contract_Start_date
  	FROM	Contract_Main CM
	 WHERE	CM.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.Contract_Main_ID#">
</cfquery>

<cfset Log_Status("Generating letters...", Medium_Log)>
<!--- Get the number of distributors for whom the letters still need to be generated --->
<cfset DistRemaining = GenerateDistributorAndOperatorLetters()>
<!--- Write to Log --->
<cfset Log_Status("Done with generating letters...#DistRemaining# distributor remaining.", Medium_Log)>

<!-------------------------------------------------------------------------------------------------------------------------------------->
<!---  USER-DEFINED FUNCTIONS  --------------------------------------------------------------------------------------------------------->
<!-------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="GenerateDistributorAndOperatorLetters" output="true" returntype="numeric" hint="Generate letters for distributor and operators.">
	  <!--- Genarate letters for 5 distributors at a time. Do not generate letter, if it slready exists in the "Program_Letters" table for that distributor.  --->
	  <cfquery name="getDistributors" datasource="#application.datasource#">
		SELECT TOP 5 cd.BSA_Foodservice_Customers_ID
		FROM Contract_Distributors cd
		INNER JOIN BSA_Foodservice_Customers bsafc
		ON cd.BSA_Foodservice_Customers_ID = bsafc.BSA_Foodservice_Customers_ID
		WHERE cd.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Trim(request.Contract_Main_ID)#">
		AND cd.Deleted = 0
		AND NOT EXISTS
		(
			SELECT Distributor_ID
			FROM Program_Letters
			WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Trim(request.Contract_Main_ID)#">
			AND Letter_Type = 2
			AND Deleted = 0
			AND cd.BSA_Foodservice_Customers_ID = Distributor_ID
		)
	  </cfquery>

	<!--- "Distributor_Dist_Product_Codes" is used to decide whether or not to show "CustProdNo" on the letter --->
	<cfquery name="getTemplateSettings" datasource="#application.datasource#">
		SELECT Program_Control_Panel_Options.Distributor_Dist_Product_Codes
		FROM Contract_Main
		INNER JOIN
		Program_Control_Panel_Options on
		Contract_Main.programtype_id = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		WHERE Contract_Main.Contract_Main_ID = '#Trim(request.Contract_Main_ID)#'
	   </cfquery>

	<cfquery name="getProgramInfo" datasource="#application.datasource#">
		SELECT Approved_By_User_ID
		FROM Contract_Main
		WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Trim(request.Contract_Main_ID)#">
	</cfquery>
	<!--- "request.AccessStructure" does not exist when the scheduled task is run and that is why we need to set it here.
	This is needed on "inc_all_vars.cfm" and on "generate_approve_email.cfm" (included below).
	--->
	<cfset request.AccessStructure.User_ID = getProgramInfo.Approved_By_User_ID>

	<cfset ProgramDistCount =  getProgramDistCount()>
	<!---
		- If there are no distributors in the program, then proceed to run for operators only.
		- If all the distributor letters are completed, then no need to proceed.
	--->
	<cfif ProgramDistCount eq 0 OR getDistributors.recordcount neq 0>

	<!--- Operator letters are created in the first loop itself. On the other hand, distributor letters are created in batches.
	From the second loop (batch), ignore operator letters.
	--->
	<cfquery name="getOperatorLetters" datasource="#application.datasource#">
		SELECT Count(*) As OperatorCount
		FROM Program_Letters
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Trim(request.Contract_Main_ID)#">
		AND Letter_Type = 1
		AND Deleted = 0
	</cfquery>

	<cfquery name="getProgramOperators" datasource="#application.datasource#">
		SELECT COUNT(*) As OperatorCount
		FROM Contract_Operators
		WHERE Contract_Main_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#Trim(request.Contract_Main_ID)#">
		AND Deleted = 0
	</cfquery>

	<!--- If operator letters do not already exist (and operators do exist on the program), then only generate operator letters --->
	<cfif getOperatorLetters.OperatorCount eq 0 AND getProgramOperators.OperatorCount GT 0>
		<cfset generateoperatorletters = 1>
	<cfelse>
		<cfset generateoperatorletters = 0>
	</cfif>

	<!--- dist_ID, custprodnum,volumepage,watermark,freightpage are all converted to URL variables on "auto_generate_gateway.cfm"."freightuom" is another url variable needed, but since freight is not
		 run for automated process, I am not passing that in the URL. These URL variables are needed as currently in the manual process, the user selects these options from the "letter generation"
		 page and clicks "Generate letters".
	--->

	<!---
	Dev Note: Milan (45080)
	Operator letters (if needed) are generated the first time this file is called.
	From the second time onwards, distributor letters are generated, 5 letters at a time,
	When the operator letters are generated, we do not want to pass list of distributors (by not populating"distList" below).
	In fact if we do not populate "dist_ID", then all the distributors on the program are listed on the operator letter,
	wich is what is needed.
	--->
	<cfif generateoperatorletters eq 1>
		<!--- Keep this blank, so that all the distributors on the program will be listed on the operator letter. --->
		<cfset distList = "">
		<!--- Operator letter --->
		<cfset letterType = 1>
	<cfelse>
		<!--- list of 5 distributors. Could be less, depending on number of distributors. --->
		<cfset distList = ValueList(getDistributors.BSA_Foodservice_Customers_ID)>
		<!--- Distributor letter --->
		<cfset letterType = 2>
	</cfif>

	<cfset Contract_Main_ID = request.Contract_Main_ID>

	 <cfmodule
	  template="/common_files/contracts/letters/auto_generate_gateway.cfm"
	  dist_ID="#distList#"
	  custprodnum="#getTemplateSettings.Distributor_Dist_Product_Codes#"
	  volumepage="0"
	  watermark="0"
	  freightpage="0"
	  bAuto="1"
	  claimRateDate = "#DateFormat(getContractDetails.Contract_Start_Date, 'mm/dd/yyyy')#"
	  bFormSubmitted="0"
	  bIncludeFreightPage="0"
	  bIncludeVolumePage="0"
	  bInsertWatermark="0"
	  bListLast="0"
	  bAddCustomerProductNumbers="1"
	  contract_main_id="#Trim(request.Contract_Main_ID)#"
	  customerFreightUom="CS"
	  letter_type="#letterType#"
	  <!--- One distributor per letter --->
	  distributor_letter_type="1"
	  <!--- All operators --->
	  dis_letter_settings="2"
	  generateoperatorletters="#generateoperatorletters#"
	  <!--- One operator per letter --->
	  operator_letter_type="1"
	  <!--- All distributors --->
	  opr_letter_settings="2"
	  notification_type="2"
	  user_id = "00000000-0000-0000-0000000000000001"
	  timeout_seconds="#(TIMEOUT_SECONDS - 7)#" />
	</cfif>

 <!--- If there are only operators in the program, the process just needs to run once. So it will run once above and then "Update_Task("done")" will delete the job.
	OR
       If there are no more distributors to be processed, call Update_Task("done")" to delete the job.
 --->
 <cfif getDistributors.recordcount eq 0>
	<!--- The letters are completed. Now delete the scheduled task --->
	<cfset Update_Task("done")>
	<!--- Send an email to the persons who receive the "approval email" that the letters have been generated --->
	<cfset sendLetterGenerationEmail = 1>

	<cfinclude template="/common_files/contracts/generate_approve_email.cfm">
<cfelse>
	<!--- Update the scheduled task which will then run for the next batch of distributors --->
	<cfset Update_Task("batches")>
 </cfif>

 <cfreturn getDistributors.recordcount>

</cffunction>

<cffunction name="getProgramDistCount" output="false" returntype="numeric">

	  <cfquery name="qgetProgramDistCount" datasource="#application.datasource#">
		SELECT Count(cd.BSA_Foodservice_Customers_ID) As Dist_Count
		FROM Contract_Distributors cd
		WHERE cd.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Trim(request.Contract_Main_ID)#">
		AND cd.Deleted = 0
	 </cfquery>

	<cfreturn qgetProgramDistCount.Dist_Count>

</cffunction>

<!--- This job will run  and create letters.Once the letters are completed, the job will be deleted. If for some reason, the job did not succeed - eg: CF needed to be restarted, then
      since the job is scheduled to run, the job will start again and run until the letters are completed and then delete itself.
--->
<cffunction name="Update_Task" output="true" returntype="void" hint="Update scheduled task">
  <cfargument name="status" type="string" required="true" hint="">

  <cfscript>
    var x_Minutes = 1;
    // schedule the task to run again in x minutes
    var startAgain = DateAdd('s', 60 * x_Minutes, now());
    var endDate  = dateAdd("d",2,dateFormat(now(),'mm/dd/yyyy'));
    var taskName = application.returned_customer_setting.Company_Name & " Letter_" & request.Contract_Main_Id;
  </cfscript>

  <cfswitch expression="#arguments.status#">
    <cfcase value="batches">
      <cfschedule
          action = "update"
          task = #taskName#
          interval = "28800" <!---  Every 8 hours. Note:This time is irrelevant,as the job is updated after a set if distrbutor (5) letters are completed, until all are completed.  --->
          operation = "HTTPRequest"
          startDate = #startAgain#
	  endDate = "#endDate#"
          startTime = #TimeFormat(startAgain,'short')#
          url = "#application.HTTPVar##cgi.server_name#/Scheduled/approvalLetter.cfm?Contract_Main_ID=#request.Contract_Main_ID#">
    </cfcase>
    <cfcase value="done">
      <cfschedule
        action = "delete"
        task = #taskName#>
    </cfcase>
  </cfswitch>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="Log_Status" output="true" returntype="void" hint="Log status to a log file.">
  <cfargument name="status" type="string" required="true" hint="">
  <cfargument name="level" type="numeric" required="false" default="#detail_log#">

  <cfscript>
    var logFile = application.returned_customer_setting.Company_Name & " Letter_" & request.Contract_Main_Id;
  </cfscript>

  <!---is logging enabled?--->
  <cfif LogStatus_Level neq 0>
    <!---is there anything to log? --->
    <cfif len(trim(arguments.status))>
      <!---is the overall log level greater than the log message's level write the log message otherwise ignore--->
      <cfif LogStatus_Level gte arguments.level>
        <cflog file="#logFile#" text="#arguments.status#">
      </cfif>
    </cfif>
  </cfif>
</cffunction>


<!---//////////////**********************************************************************************************************************////////////// --->
<!--- "CUSTOM 3 LETTERS" --->
<cfelseif appSettings.getlettersavailable() eq 4>

<cfscript>
  Detail_Log = 30;
  Medium_Log = 20;
  Simple_Log = 10;
  TIMEOUT_SECONDS = 1500;

  liveSite   = 1;    //TODO:  set this to 1 before checking in the file to CVS

  if ( liveSite eq 1 )
    LogStatus_Level = 0;
  else
    LogStatus_Level = Detail_Log;
</cfscript>

<cfif not StructKeyExists(URL, "Contract_Main_ID")>
  <cfabort>
</cfif>

<cfoutput>
<cfsetting requesttimeout=#TIMEOUT_SECONDS#>
</cfoutput>

<!--- Add to request scope --->
<cfif isDefined("URL")>
  <cfset structAppend(request, URL, true)/>
</cfif>

<!--- Commented the log code, as we do not really need it. We can always check the existence of letters under the "common_documents" folder. --->
<!---<cfset LogProgressStatus("Generating letters...", Medium_Log)>--->
<!--- Get the number of distributors for whom the letters still need to be generated --->
<cfset DistRemaining = GenerateDistAndOperLetters()>
<!--- Write to Log --->
<!---<cfset LogProgressStatus("Done with generating letters...#DistRemaining# distributor remaining.", Medium_Log)>--->

<cfset Contract_Main_ID = request.Contract_Main_ID>

<!-------------------------------------------------------------------------------------------------------------------------------------->
<!---  USER-DEFINED FUNCTIONS  --------------------------------------------------------------------------------------------------------->
<!-------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="GenerateDistAndOperLetters" output="true" returntype="numeric" hint="Generate letters for distributor and operators.">

	<cfscript>
	  vars = StructNew();
	  vars.programCFC = CreateObject('component', 'components.programs.display_program.viewProgramTemplateManager');
	</cfscript>

	<cfinvoke component="components.programs.business_segment.BusinessSegmentManager"
		method="isEnabled"
		returnVariable="busSegMgr.isEnabled">
	</cfinvoke>

	<cfset vars.qDistributors = vars.programCFC.getDistributors( Contract_Main_ID, busSegMgr.isEnabled, false )>
	<cfset vars.qOperators = vars.programCFC.getOperators( Contract_Main_ID ) />

	<!--- Get the count of "total number of distributors" on the program. --->
	<cfset ProgramDistCount =  vars.qDistributors.recordcount>

	<cfset JobInBatches = 0>
	<!--- This number can be increased in the future. Right now, it is been set to 6 because there are already around 60 jobs in the KraftHeinz environment,
	which are running but have no letters to generate as this code to generate letters does not exist. As soon as this code isdeployed to production, all those
	60 jobs will start creating letters and may use a lot of memory.
	--->
	<cfset distributorCountForJobInBatches = 6>

	<!--- If there are more than "distributorCountForJobInBatches" disributors on the program, then the CF job which generates letters needs to be run in batches.
	Note: If there are fewer than "distributorCountForJobInBatches" disributors on the program, then all the letters will be generated in one request.
	--->
	<cfif vars.qDistributors.recordcount GT distributorCountForJobInBatches>
		<cfset JobInBatches = 1>
	</cfif>

	<!--- Genarate letters for 5 distributors at a time. Do not generate letter, if it slready exists in the "Program_Letters" table for that distributor.--->
	<cfquery name="qGetDistributors" datasource="#application.datasource#">
	<!--- If the job does not need to run in batches, then do not use "TOP 5", as we need to run the letters for all distributors in one request --->
		SELECT <cfif JobInBatches eq 1>TOP 5</cfif> cd.BSA_Foodservice_Customers_ID,bsafc.Name,Shr_Ship_To AS Account,
					bsafc.BSA_Foodservice_Customers_ID AS Operator_ID,bsafc.BSA_Foodservice_Customers_ID AS Distributor_ID
		FROM Contract_Distributors cd
		INNER JOIN BSA_Foodservice_Customers bsafc
		ON cd.BSA_Foodservice_Customers_ID = bsafc.BSA_Foodservice_Customers_ID
		WHERE cd.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Trim(Contract_Main_ID)#">
		AND cd.Deleted = 0
		AND NOT EXISTS
		(
			SELECT Distributor_ID
			FROM Program_Letters
			WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Trim(Contract_Main_ID)#">
			AND Letter_Type = 2
			AND Deleted = 0
			AND cd.BSA_Foodservice_Customers_ID = Distributor_ID
		)
	</cfquery>

	<!--- If we don't have any distributors on the program then try operators --->
	<cfif not vars.qDistributors.recordCount and vars.qOperators.recordCount>
		<cfquery name="vars.qData" dbtype="query">
			SELECT	Operator_name AS Name,
					Operator_ID AS Account,
					BSA_Operator_ID AS Operator_ID,
					0 AS Distributor_ID
			FROM	vars.qOperators
		</cfquery>
	<cfelse>
		<cfquery name="vars.qData" dbtype="query">
			SELECT	Name AS Name,
					Shr_Ship_To AS Account,
					BSA_Foodservice_Customers_ID AS Operator_ID,
					BSA_Foodservice_Customers_ID AS Distributor_ID
			FROM	vars.qDistributors
		</cfquery>
	</cfif>

	<!--- Get the count of "operator letters". --->
	<cfquery name="getOperatorLetters" datasource="#application.datasource#">
		SELECT Count(*) As OperatorCount
		FROM Program_Letters
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Trim(Contract_Main_ID)#">
		AND Letter_Type = 1
		AND Deleted = 0
	</cfquery>


	<cfquery name="getProgramInfo" datasource="#application.datasource#">
	 SELECT Approved_By_User_ID
	 FROM Contract_Main
	 WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Trim(Contract_Main_ID)#">
	</cfquery>

	<!--- "request.AccessStructure" does not exist when the scheduled task is run and that is why we need to set it here.
	This is needed on "create_letters_custom3.cfm" and on "generate_approve_email.cfm" (included below).
	--->
	<cfset request.AccessStructure.User_ID = getProgramInfo.Approved_By_User_ID>

	<!---
		Operator Letters;
		Only 1 operator letter needs to generated, no matter how many operators there are,
		and so we need to check for the existence of only 1 operator letter.
		- vars.qOperators.recordcount (operators on the program)
		- getOperatorLetters.OperatorCount (Count of existing operator letters)

		Distributor Letters;
		There should be as many distributor letters as the number of distributors on the program
		and so we need to check for the existence of letters for all the distributors on the program.
		- vars.qDistributors.recordcount (distributors on the program)
		- qGetDistributors.recordcount (Count of distributor letters still pending to be created)
	--->
	<cfif (vars.qOperators.recordcount GT 0 AND getOperatorLetters.OperatorCount EQ 0)
		OR
		(vars.qDistributors.recordcount GT 0 AND qGetDistributors.recordcount GT 0)
	>
		<!---
		List of all distributors on the operator letter.
		Note: If there are no distributors on the program, then this list could be an operator list.
		--->
		<cfset form.operLtrDistributors = valueList(vars.qData.Operator_ID)>

		<!---
		List of all distributors on the distributor letter.
		--->
		<cfset form.distLtrDistributors = valueList(qGetDistributors.BSA_Foodservice_Customers_ID)>
		<!---
		<cfset form.distributors = valueList(qGetDistributors.BSA_Foodservice_Customers_ID)>
		--->

		<cfinclude template="/common_files/contracts/letters/quoteLetter/create_letters_custom3.cfm">

		<!--- Update the scheduled task which will then run for the next batch of distributors --->
		<cfset UpdateCFTask("batches")>
	<cfelse>

		<!--- The letters are completed. Now delete the scheduled task --->
		<cfset UpdateCFTask("done")>

		<!--- Send an email to the persons who receive the "approval email" that the letters have been generated --->
		<cfset sendLetterGenerationEmail = 1>
		<!--- APPROVAL EMAIL --->
		<cfinclude template="/common_files/contracts/generate_approve_email.cfm">
	</cfif>

	<cfreturn qGetDistributors.recordcount>
</cffunction>

<!--- This job will run  and create letters.Once the letters are completed, the job will be deleted. If for some reason, the job did not succeed - eg: CF needed to be restarted, then
      since the job is scheduled to run, the job will start again and run until the letters are completed and then delete itself.
--->
<cffunction name="UpdateCFTask" output="true" returntype="void" hint="Update scheduled task">
	<cfargument name="status" type="string" required="true" hint="">

	<cfscript>
	var x_Minutes = 1;
	// schedule the task to run again in x minutes
	var startAgain = DateAdd('s', 60 * x_Minutes, now());
	var endDate  = dateAdd("d",2,dateFormat(now(),'mm/dd/yyyy'));
	var taskName = application.returned_customer_setting.Company_Name & " Letter_" & request.Contract_Main_Id;
	</cfscript>

	<cfswitch expression="#arguments.status#">
		<cfcase value="batches">
			<cfschedule
				action = "update"
				task = #taskName#
				interval = "3600"<!--- Every 1 hour. Note:This time is actually irrelevant,as the job is updated after a set if distributor (5) letters are completed, until all are completed.  --->
				operation = "HTTPRequest"
				startDate = #startAgain#
				endDate = "#endDate#"
				startTime = #TimeFormat(startAgain,'short')#
				url = "#application.HTTPVar##cgi.server_name#/Scheduled/approvalLetter.cfm?Contract_Main_ID=#Contract_Main_ID#">
		</cfcase>
		<cfcase value="done">
			<cfschedule
				action = "delete"
				task = #taskName#>
		</cfcase>
	</cfswitch>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="LogProgressStatus" output="true" returntype="void" hint="Log status to a log file.">
  <cfargument name="status" type="string" required="true" hint="">
  <cfargument name="level" type="numeric" required="false" default="#detail_log#">

  <cfscript>
    var logFile = application.returned_customer_setting.Company_Name & " Letter_" & request.Contract_Main_Id;
  </cfscript>

  <!---is logging enabled?--->
  <cfif LogStatus_Level neq 0>
    <!---is there anything to log? --->
    <cfif len(trim(arguments.status))>
      <!---is the overall log level greater than the log message's level write the log message otherwise ignore--->
      <cfif LogStatus_Level gte arguments.level>
        <cflog file="#logFile#" text="#arguments.status#">
      </cfif>
    </cfif>
  </cfif>
</cffunction>

<!--- Create letter based on app setting [end] --->
</cfif>
