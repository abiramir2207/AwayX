/******
	This is the file deletes the previous versions of a program letter, based on individual distributors, 
	All distributors or All operators.
*******/

<!--- 
First create a backup of the program_letters table using the label number. Once the backup is created, then update the
program_letters table with the appropriate distributor_id's. Currently, when we run letters for a list of distributors,
the first distributor's id is used and entered for all distributors. The only way to know the distributor is through name.
I need to update the distributor_id field to delete the previous versions of a letter based on distributor or operator.
Even the previous versions of letters which have "All distributors" or "All operators" need to be deleted.
In case, there is an issue, I have the backup of the program_letters table.
--->

<!---
 This query will execute the first time this file is called, as the program_letters backup will already exist.
--->
<cfquery name="check_program_letters_backup" datasource="#application.datasource#">
if not exists 
(
    SELECT *
    FROM   INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'program_letters_20639'
)
BEGIN
select *
into program_letters_20639
from program_letters

<!--- I need to update the distributor_id field, so that the previous versions of a letter based on distributor, 
			can be successfully deleted.
--->
update program_letters
set distributor_id = bsa_foodservice_customers.bsa_foodservice_customers_id
from program_letters inner join bsa_foodservice_customers
on program_letters.distributor_name = bsa_foodservice_customers.name
where Letter_Type = 2
END
</cfquery>

<cfset objLetterManager = CreateObject("component", "mvc.Models.LetterManager") />
	
	<!--- Get top 450 at a time --->
	<cfquery name="get_previous_version_letters" datasource="#application.datasource#">
		<!--- Delete the previous versions of individual distributor letters for a program. 
					Just keep the most recent version.Get 250 at a time.
		--->
		SELECT DISTINCT TOP 150 tb1.Program_Letters_ID
		from program_letters tb1, program_letters tb2
		WHERE tb1.Program_ID = tb2.Program_ID
		AND tb1.Distributor_ID = tb2.Distributor_ID
		AND tb1.deleted = 0
		AND tb2.deleted =0
		AND tb1.letter_type = tb2.letter_type
		AND tb1.Distributor_ID IS NOT NULL
		AND tb2.Distributor_ID IS NOT NULL
		AND CAST(tb1.Distributor_ID As varchar(50)) <> ''
		AND CAST(tb2.Distributor_ID As varchar(50)) <> ''
		AND tb1.Letter_Type = 2
		AND tb2.Letter_Type = 2
		AND tb1.Program_Letters_ID < tb2.Program_Letters_ID
		
		union
		
		<!--- Delete the previous versions of letters which were created for all distributors for a program.
					Just keep the most recent version.
		--->
		SELECT DISTINCT TOP 150 tb1.Program_Letters_ID
		from program_letters tb1, program_letters tb2
		WHERE tb1.Program_ID = tb2.Program_ID
		AND tb1.deleted = 0
		AND tb2.deleted =0
		AND tb1.letter_type = tb2.letter_type
		AND 
		(
		tb1.Distributor_ID IS NULL
		OR
		CAST(tb1.Distributor_ID As varchar(50))= ''
		)
		AND 
		(
		tb2.Distributor_ID IS NULL
		OR
		CAST(tb2.Distributor_ID As varchar(50))= ''
		)
		AND tb1.Letter_Type = 2
		AND tb2.Letter_Type = 2		
		AND tb1.Program_Letters_ID < tb2.Program_Letters_ID

		union

		<!--- Delete the previous versions of letters which were created for all operators for a program.
				Just keep the most recent version.
		--->
		SELECT DISTINCT TOP 150 tb1.Program_Letters_ID
		from program_letters tb1, program_letters tb2
		WHERE tb1.Program_ID = tb2.Program_ID
		AND tb1.Operator_Name = tb2.Operator_Name
		AND tb1.deleted = 0
		AND tb2.deleted =0
		AND tb1.letter_type = tb2.letter_type
		AND tb1.Distributor_ID IS NULL
		AND tb2.Distributor_ID IS NULL
		AND tb1.Letter_Type = 1
		AND tb2.Letter_Type = 1
		AND tb1.Program_Letters_ID < tb2.Program_Letters_ID
	</cfquery>

		<cfloop query="get_previous_version_letters">
				<cfscript>
						objLetterManager.deletePDFLetterInDBandFile(Program_Letters_ID);
				</cfscript>
		</cfloop>

	
	<!--- If there are no previous version of any letter available, delete the scheduled job --->
	<cfif get_previous_version_letters.recordcount EQ 0>

		<!--- Initialize the Java Service Factory --->
		<cfobject type="JAVA" action="Create" name="factory" class="coldfusion.server.ServiceFactory">

		<!--- Get all the cf jobs from the JAVA service factory --->
		<cfset allTasks = factory.CronService.listAll()>   

			<cfloop from="1" to="#Arraylen(allTasks)#" index="i">
				
				<!--- I am checking the name of task and URL (double check) and then deleting the scheduled job --->
				<cfif allTasks[i].task eq "Delete letter previous versions" AND find("scheduled/delete_letters.cfm",allTasks[i].url) neq 0>
							<cfschedule action = "delete"  
													task	 = "Delete letter previous versions">
							<cfbreak>
				</cfif>

			</cfloop>

	 </cfif>