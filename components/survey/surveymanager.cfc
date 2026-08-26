<!---
Document Name:	SurveryManager.cfc
Author:			Kal on 09/15/2005
This is check various conditions from the enter.cfm page and the home.cfm page.
--->

<cfcomponent hint="Survey Settings" extends="components.Base">

	<cfset this.SurveyOn				=	0 />
	<cfset this.SurveyURL				=	"http://www.zoomerang.com/survey.zgi?p=WEB224KNDRKVCS" />
	<cfset this.SurveyMaxDisplayCount	=	5 />	
	
	<!--- Function for homepage to check whether any survey is active and to display survery --->	
	<cffunction name="HomeDisplayChek" access="public" output="false">
		<cfargument name="userID" required="true" />
		<cfset displaySurvey = 0 />
		
		<cfif this.surveyOn EQ 1>
			<cfset SurveyUserChk =  CreateObject("component", "components.survey.surveymanager").SurveryUserChk("#arguments.userID#") />

			<cfif SurveyUserChk.LoginPgEntry EQ 1>
				<cfif SurveyUserChk.SurveyResponse EQ 0 AND SurveyUserChk.SurveyPopupCount LT this.surveyMaxDisplayCount >   
				<!--- Note: SurveyResponse =>  Later=0, YES=1, NO=2 --->
					<cfset displaySurvey = 1 />
					<cfset SurveyPopIncrement = SurveyUserChk.SurveyPopupCount +1 />
					<cfquery name="SurveryPopUpdate" datasource="#application.datasource#">
						UPDATE 	Survey_Settings 
						SET		SurveyPopupCount = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#SurveyPopIncrement#">,
								LoginPgEntry = 0
						WHERE 	userID = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
				</cfif>  <!--- SurveryUserChk.SurveyResponse EQ 0 --->
			</cfif> <!--- <cfif SurveryUserChk.LoginPgEntry EQ 1> --->
		</cfif> <!--- this.surveyOn EQ 1 --->
		
		<cfreturn displaySurvey />
	</cffunction>

	<!--- Function for enter.cfm page to set entry from login page --->	
	<cffunction name="LoginPgEntrySet" access="public" output="false">
		<cfargument name="userID" required="true" />
		<cfset ExcededMaxPopup = 1 />
		
		<cfif this.surveyOn EQ 1 >
			<cfset SurveyUserChk =  CreateObject("component", "components.survey.surveymanager").SurveryUserChk("#arguments.userID#") />
			<cfif SurveyUserChk.Recordcount EQ 0>
				<cfset useLakebaseForqSurveryUserEntry = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("survey_settings")>
<cfif useLakebaseForqSurveryUserEntry>
	<cftry>
		<cfset application.oLakebase.insertRow("survey_settings", {
			"userid" = "#arguments.userID#",
			"surveyresponse" = "0",
			"surveypopupcount" = "0",
			"loginpgentry" = "1"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqSurveryUserEntry = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSurveryUserEntry>
<cfquery name="qSurveryUserEntry" datasource="#application.datasource#">
					Insert	Into Survey_Settings 
							( userID, SurveyResponse, SurveyPopupCount, LoginPgEntry )
					Values	('#arguments.userID#', 0, 0, 1)
				</cfquery>
</cfif>
			<cfelse>
				<cfif SurveyUserChk.SurveyResponse EQ 0 AND SurveyUserChk.SurveyPopupCount LT this.surveyMaxDisplayCount >
					<cfset ExcededMaxPopup = 0 />
				</cfif>
			</cfif> <!--- SurveyUserChk.Recordcount GT 0 --->
		</cfif> <!--- this.surveyOn EQ 1 --->
		
		<cfif ExcededMaxPopup EQ 0 >
			<cfquery name="qLoginPgEntryUpdate" datasource="#application.datasource#">
				UPDATE 	Survey_Settings 
				SET		LoginPgEntry = 1
				WHERE 	userID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.userID#">
			</cfquery>
		</cfif>
	</cffunction>	

	<!--- Function to the User entry in Survey Table --->
	<cffunction name="SurveryUserChk" output="No">
		<cfargument name="userID" required="true" />
		<cfquery name="qSurveryUserChk" datasource="#application.datasource#">
			Select 	userID, 
					isnull(SurveyResponse,0) as SurveyResponse, 
					isnull(SurveyPopupCount,0) as SurveyPopupCount, 
					isnull(LoginPgEntry,0) as LoginPgEntry
			From 	Survey_Settings 
			Where 	userID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.userID#">
		</cfquery>
		<cfreturn qSurveryUserChk />
	</cffunction>
	
	<!--- Function to get if Survey is ongoing --->
	<cffunction name="getSurveyOn" returntype="numeric" output="false">
		<cfreturn this.SurveyOn />
	</cffunction>

	<!--- Function to get Survey URL --->
	<cffunction name="getSurveyURL" returntype="string" output="false">
		<cfreturn this.SurveyURL />
	</cffunction>
	
	<!--- User Response to survey popup --->
	<!--- Note: SurveyResponse =>  Later=0, YES=1, NO=2 --->
	<cffunction name="SurveyUserSaid" output="No">
		<cfargument name="userID" required="true" />
		<cfargument name="SurveyPopupResponse" required="true" />

		<cfquery name="qSurveyUserSaid" datasource="#application.datasource#">
				UPDATE 	Survey_Settings 
				SET		SurveyResponse = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.SurveyPopupResponse#">
				WHERE 	userID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.userID#">
		</cfquery>
		<cfquery name="qASurveyUserSaid" datasource="#application.datasource#">
			SELECT	SurveyResponse 
			FROM 	Survey_Settings 
			WHERE 	userID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.userID#">
		</cfquery>
		<cfreturn qASurveyUserSaid.SurveyResponse />
	</cffunction>
	
	
</cfcomponent>