<cfcomponent hint="Manages Activity Template" extends ="cm.com.base">


	<cffunction name="init" output="false">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="get" output="false" returntype="struct">
	
		<cfargument name="id" required="false" default=0 type="numeric" />
		
		<cfset this.activity = CreateObject("component","cm.activity.com.ActivityTemplate").init() />
		
		<!---if we have an id then build object with data from db--->
		<cfif arguments.id>
			
			<!---get the activity--->
			<cfquery name="qGetActivityTemplate" datasource="#application.datasource#">
				SELECT 	CM_Activity_Template_ID,	
						Activity_Template_Name,
						Activity_Template_Notes,
						Created_By_User_ID,
						Updated_By_User_ID
				FROM 	CM_Activity_Template
				WHERE	Deleted = 0
				AND		CM_Activity_Template_ID = #arguments.id#
			</cfquery>
			
			<!---set for activity--->
			<cfloop query="qGetActivityTemplate">
			
				<cfset this.activity.setId(CM_Activity_Template_ID) />
				<cfset this.activity.setName(Activity_Template_Name) />
				<cfset this.activity.setNotes(Activity_Template_Notes) />
				<cfset this.activity.setCreatedBy(Created_By_User_ID) />
				<cfset this.activity.setUpdatedBy(Updated_By_User_ID) />
				
			</cfloop>
			
			<!---get questions--->
			<cfquery name="qGetActivityQuestions" datasource="#application.datasource#">
				SELECT 	CM_Activity_Question_ID,	
						Activity_Question,
						CM_Activity_QA_Type_ID
				FROM 	CM_Activity_Question
				WHERE	Deleted = 0
				AND		CM_Activity_Template_ID = #qGetActivityTemplate.CM_Activity_Template_ID#		
			</cfquery>
			
			<!---loop through and set for questions--->
			<cfloop query="qGetActivityQuestions">
			
				<!---set for free form question--->
				<cfif CM_Activity_QA_Type_ID eq 1>
				
					<cfset this.activity.setFreeFormQuestions(Activity_Question) />
				
				</cfif>
				
				<!---set for option question--->
				<cfif CM_Activity_QA_Type_ID eq 2>
					
					<!---get questions of option type --->
					<cfquery name="qGetActivityQAOption" datasource="#application.datasource#">
						SELECT 	Activity_QA_Option	
						FROM 	CM_Activity_QA_Option
						WHERE	Deleted = 0
						AND		CM_Activity_Question_ID = #CM_Activity_Question_ID#
					</cfquery>

					<cfset aOptions = ArrayNew(1) />
					<cfloop query="qGetActivityQAOption">
					
						<cfset aOptions[CurrentRow] = Activity_QA_Option />
						
					</cfloop>
					
					<cfset stTemp = StructNew() />
					<cfset stTemp.question = Activity_Question />
					<cfset stTemp.answers = aOptions />
					
					<!---set option questions --->
					<cfset this.activity.setOptions(stTemp) />
					
				</cfif>
				
				<!---set for quantitative question--->
				<cfif CM_Activity_QA_Type_ID eq 3>
					
					<!---get the unit of measure data for quantitative type--->
					<cfquery name="qGetActivityQAQty" datasource="#application.datasource#">
						SELECT 	CM_QA_UOM_ID
						FROM 	CM_Activity_QA_Qty
						WHERE	Deleted = 0
						AND		CM_Activity_Question_ID = #CM_Activity_Question_ID#
					</cfquery>
					
					<!---set temp array--->
					<cfset aUom = ArrayNew(1) />
					<cfloop query="qGetActivityQAQty">
						<cfset aUom[CurrentRow] = CM_QA_UOM_ID />
					</cfloop>
					
					<!---get the unit of time data--->
					<cfquery name="qGetActivityQATime" datasource="#application.datasource#">
						SELECT 	CM_QA_UOT_ID
						FROM 	CM_Activity_QA_Time
						WHERE	Deleted = 0
						AND		CM_Activity_Question_ID = #CM_Activity_Question_ID#
					</cfquery>
					
					<!---set temp array--->
					<cfset aUot = ArrayNew(1) />
					<cfloop query="qGetActivityQATime">
						<cfset aUot[CurrentRow] = CM_QA_UOT_ID />
					</cfloop>
					
					<cfset stTemp = StructNew() />
					<cfset stTemp.question = Activity_Question />
					<cfset stTemp.uom = aUom />
					<cfset stTemp.uot = aUot />

					<!---set quantitative questions--->
					<cfset this.activity.setQuantitativeQuestions(stTemp) />
	
				</cfif>
				
			</cfloop>
			
		</cfif>
		
		<cfreturn this.activity />
		
	</cffunction>
	
	<cffunction name="getData" output="false" returntype="struct">
	
		<cfargument name="actObject" type="struct" required="true" default="" /> 
		
		<cfset rStruct =  StructNew() />
		<cfset rStruct.question = arguments.actObject.question />
		<cfset rStruct.id =  arguments.actObject.id />
		<cfset rStruct.name =  arguments.actObject.name />
		<cfset rStruct.notes = arguments.actObject.notes />
		<cfset rStruct.updatedBy = arguments.actObject..updatedBy />
		<cfset rStruct.createdBy = arguments.actObject.createdBy />
		
		<cfreturn rStruct />
		
	</cffunction>
	
	<cffunction name="getActivityQuestionType" output="false" returntype="query">
	
		<cfquery name="qGetActQuestType" datasource="#application.datasource#">
			SELECT 	CM_Activity_QA_Type_ID,
					Activity_QA_Type_Name 
			FROM 	CM_Activity_QA_Type
			WHERE	Deleted = 0
		</cfquery>
		
		<cfreturn qGetActQuestType />
		
	</cffunction>
	
	<cffunction name="getUom" output="false" returntype="query">
	
		<cfargument name="id" type="numeric" required="false" default=0 />
		
		<cfquery name="qGetUom" datasource="#application.datasource#">
			SELECT 	CM_QA_UOM_ID,
					QA_UOM_Abbr,
					QA_UOM_Desc
			FROM 	CM_QA_UOM
			WHERE	Deleted = 0
			<cfif arguments.id>
			AND		CM_QA_UOM_ID = #arguments.id#		
			</cfif>
			
		</cfquery>
		
		<cfreturn qGetUom />
		
	</cffunction>
	
	<cffunction name="getUot" output="false" returntype="query">
		
		<cfargument name="id" type="numeric" required="false" default=0 />
		
		<cfquery name="qGetUot" datasource="#application.datasource#">
			SELECT 	CM_QA_UOT_ID,
					QA_UOT_Abbr,
					QA_UOT_Desc
			FROM 	CM_QA_UOT
			WHERE	Deleted = 0
			<cfif arguments.id>
			AND		CM_QA_UOT_ID = #arguments.id#		
			</cfif>
		</cfquery>
		
		<cfreturn qGetUot />
		
	</cffunction>
	
	<cffunction name="save" output="true">
	
		<cfargument name="stData" type="struct" required="true" default="" />

		<cftransaction action="begin">
			
			<!---////////////////////////////////// Activivty ///////////////////////////////////--->
			<cfquery name="qInsertActivity" datasource="#application.datasource#">
				SET NOCOUNT ON
				
				INSERT INTO CM_Activity_Template
					(Activity_Template_Name, Activity_Template_Notes, Created_By_User_ID, Updated_By_User_ID)
				VALUES
					('#arguments.stData.name#', '#arguments.stData.notes#', '#arguments.stData.createdBy#', '#arguments.stData.updatedBy#')
				
				SELECT CM_Activity_Template_ID = @@IDENTITY
					
				SET NOCOUNT OFF
			</cfquery>
			
			<!---////////////////////////////////// Free Form Questions ///////////////////////////////////--->
			<cfloop index="i" from="1" to="#ArrayLen(stData.question.freeForm.questions)#">
								
				<cfquery name="qInsertFreeForm" datasource="#application.datasource#">
					INSERT INTO CM_Activity_Question
						(Activity_Question, CM_Activity_Template_ID, CM_Activity_QA_Type_ID)
					VALUES
						('#arguments.stData.question.freeForm.questions[i]#', #qInsertActivity.CM_Activity_Template_ID#, #arguments.stData.question.freeForm.type#)
				</cfquery>

			</cfloop>
			
			<!---////////////////////////////////// Options Questions ///////////////////////////////////--->
			<cfloop index="i" from="1" to="#ArrayLen(stData.question.option.options)#">
				
				<cfquery name="qInsertOption" datasource="#application.datasource#">
					SET NOCOUNT ON
					
					INSERT INTO CM_Activity_Question
						(Activity_Question, CM_Activity_Template_ID, CM_Activity_QA_Type_ID)
					VALUES
						('#arguments.stData.question.option.options[i].question#', #qInsertActivity.CM_Activity_Template_ID#, #arguments.stData.question.option.type#)
						
					SELECT CM_Activity_Question_ID = @@IDENTITY
					
					SET NOCOUNT OFF
				</cfquery>
				
				<!---////////////////////////////////// Options ///////////////////////////////////--->
				<cfloop index="n" from="1" to="#ArrayLen(stData.question.option.options[i].answers)#">
					
					<cfquery name="qInsertOptionAnswers" datasource="#application.datasource#">
						INSERT INTO CM_Activity_QA_Option
							(CM_Activity_Question_ID, Activity_QA_Option)
						VALUES
							(#qInsertOption.CM_Activity_Question_ID#, '#arguments.stData.question.option.options[i].answers[n]#')
					</cfquery>
				
				</cfloop>
			
			</cfloop>

			<!---////////////////////////////////// Quantitative Questions ///////////////////////////////////--->
			<cfloop index="i" from="1" to="#ArrayLen(stData.question.quantitative.questions)#">
						
				<cfquery name="qInsertQuant" datasource="#application.datasource#">
					SET NOCOUNT ON
						
					INSERT INTO CM_Activity_Question
						(Activity_Question, CM_Activity_Template_ID, CM_Activity_QA_Type_ID)
					VALUES
						('#arguments.stData.question.option.options[i].question#', #qInsertActivity.CM_Activity_Template_ID#, #arguments.stData.question.quantitative.type#)
							
					SELECT CM_Activity_Question_ID = @@IDENTITY
						
					SET NOCOUNT OFF
				</cfquery>
				
				<!---////////////////////////////////// Quantitative UOM/Qty ///////////////////////////////////--->
				<cfloop index="n" from="1" to="#ArrayLen(stData.question.quantitative.questions[i].uom)#">
				
					<cfquery name="qInsertQuantUom" datasource="#application.datasource#">
						INSERT INTO CM_Activity_QA_Qty
							(CM_Activity_Question_ID, CM_QA_UOM_ID)
						VALUES
							(#qInsertQuant.CM_Activity_Question_ID#, #arguments.stData.question.quantitative.questions[i].uom[n]#)
					</cfquery>
				
				</cfloop>
				
				<!---////////////////////////////////// Quantitative UOT ///////////////////////////////////--->
				<cfloop index="indx" from="1" to="#ArrayLen(stData.question.quantitative.questions[i].uot)#">
									
					<cfquery name="qInsertQuantUom" datasource="#application.datasource#">
						INSERT INTO CM_Activity_QA_Time
							(CM_Activity_Question_ID, CM_QA_UOT_ID)
						VALUES
							(#qInsertQuant.CM_Activity_Question_ID#, #arguments.stData.question.quantitative.questions[i].uot[indx]#)
					</cfquery>

				</cfloop>
			
			</cfloop>
			
		</cftransaction>

		
	</cffunction>
	
</cfcomponent>