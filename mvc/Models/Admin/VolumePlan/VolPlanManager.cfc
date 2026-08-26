<cfcomponent output="false" alias="mvc.Models.Admin.VolumePlan.VolPlanManager">
	
	<cfset appSettings = application.appSettingsGet />
	<cfscript>
		variables.oVolPlanMaster = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanMaster');
		variables.oVolPlanMasterDef = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanMasterDef');
		variables.oVolPlanSource = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanSource');
		variables.oVolPlanStatus = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanStatus');
		variables.oVolPlanCalendar = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanCalendar');
		variables.oVolPLanDAO = createObject('component','mvc.Models.Admin.VolumePlan.VolPlanDAO');
	</cfscript>
	
	<cffunction name="init" output="false" returntype="mvc.Models.Admin.VolumePlan.VolumPlanManager">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getSettingsObject" returntype="Struct" access="remote">
		<cfargument name="userId" default="00000000-9999-9999-0000000000000000">
		<cfargument name="programId" default="0">
		<cfset var obj = "" />
		<cfset var stSettings = StructNew()/>
		<cflog text="getSettingsObject:: #arguments.userId#"/>
		
		<!--- profile and user settings [empty for now] -> we may want to write and all use a common function for profile data--->
		<cfset obj = createobject("component", "mvc.Models.SettingsService") />
		<cfset stSettings.user = StructNew()/>
		<cfset stSettings.user = obj.getUserObject(arguments.userId) />

		<!--- APPSETTINGS: return application.appSettingsGet as a structure with keys named the same as the appsettings methods--->
		<cfset stSettings.appSettings = StructNew()/>
		<!--- <cfset stSettings.appSettings = obj.getAppSettingsObject() />  --->
		
		<cfset structinsert(stSettings.appSettings,"Exact_List_Matching_On",appSettings.Exact_List_Matching_On)>
		<!--- APP FLEX: Custom settings --->
		<cfset stSettings.appFlex = StructNew()/>
		<cfset stSettings.appFlex.brand = obj.getProductGroupLabels().brand />
		<cfset stSettings.appFlex.qBrand = obj.getProductGroupLabels().qBrand />
		<cfset stSettings.appFlex.typeCode = obj.getProductGroupLabels().typeCode /> 
		<cfset stSettings.appFlex.typeGroup = obj.getProductGroupLabels().typeGroup />
		<cfset stsettings.UIAttributes = obj.getUIAttributes()> 
		<cfreturn stSettings>
	</cffunction>
	
	<cffunction name="getVolPlanMaster" returntype="array" access="remote" >
		<cfargument name="userId" default="0" />
		<cfargument name="volPlanMasterId" default="0" />
		<!--- Get array of mvc.Models.Admin.VolumePlan.vos.VolPlanMaster --->
		<cfscript>
			var arrVPMaster = arrayNew(1);
			var gData = '';
			var stInnerLoop = '';
			var vpMaster = '';
			//get list of id's
			qData = variables.oVolPlanDAO.getVolPlanMasterIds();
			//loop over and build array of obj's :: mvc.Models.Admin.VolumePlan.vos.VolPlanMaster
			for (	i=1;
					i LTE qData.RecordCount;
					i++) 
					{	//init with id -> load from db uses the id to go to db											
						vpMaster = variables.oVolPlanMaster.init(qData['volPlanMasterId'][i]);
						vpMaster.loadFromDb(arguments.userId);
						//WriteLog(file="application.log", text="#volPlanMasterId# & ' :: getVolPlanMaster"); 
						arrayAppend(arrVPMaster,duplicate(vpMaster));
					}
			//savecontent variable="local.o" { writeDump( arrVPMaster ) }
			//WriteLog(file="mws2.html", text="#o#"); 
			
		</cfscript>
		<cfreturn arrVPMaster />
	</cffunction>
	
	<cffunction name="saveVolPlanMaster" returntype="array" access="remote" >
		<cfargument name="arrVolPlanMaster" type="array" />
		<!--- Get array of mvc.Models.Admin.VolumePlan.vos.VolPlanMaster --->
		<cfscript>
			var arrVPMaster = arrVolPlanMaster;
			var i = 0;
			var x = 0;
			var y = 0;
			var z = 0;
			var iRecapLen = 0;
			var currVolPLan = '';
			var iCustomersLen = 0;
			var iUserPositionsLen = 0;
			WriteLog(file="application", text=" #arrayLen(arrVpMaster)# :: SAVEVolPlanMaster");
		</cfscript>
		<cfloop array="#arrVpMaster#" index="vpMaster">
			<cfscript>
				WriteLog(file="application.log", text=" #arrayLen(arrVpMaster)# :: SAVEVolPlanMaster UPDATE 1");
			</cfscript>
			<cfif isObject(vpMaster) >
				<cfscript>
				//if exists -> UPDATE else -> INSERT
				if (variables.oVolPlanDAO.checkVolPlanMasterExixts(vpMaster.volPlanMasterId)){
					WriteLog(file="application.log", text="#vpMaster.volPlanMasterId# & :: SAVEVolPlanMaster UPDATE"); 
					variables.oVolPlanDAO.updateVolPlanMaster(vpMaster);
					}
				else{
					WriteLog(file="application.log", text="#vpMaster.volPlanMasterId# & :: SAVEVolPlanMaster INSERT"); 
					variables.oVolPlanDAO.InsertVolPlanMaster(vpMaster);
				}

				/* ...................................................... */
				/* Handle the array of Vol Plans For this Master racord. */
				if(isArray(vpMaster.volPlans)){
					iVolPLanLen = ArrayLen(vpMaster.volPlans);
					//WriteLog(file="application.log", text="#vpMaster.volPlanMasterId# & :: SAVEVolPlanMaster INS VOL PLANS"); 
					/* LOOP and save volPlans 1 at a time */
					for( i=1; i <= iVolPLanLen; i++){
						currVolPLan = vpMaster.volPlans[i];
						session._vp = currVolPLan;
					//  TO DO :: LOOP OVER CUSTOMERS AND POSITIONS AND DO iNSERTS [LOOP FROM DAO?]  XXXXXXXXXXXXXXXXXXX
						if(vpMaster.volPlans[i].id == 0){
							//set id returned from insert
							currVolPLan.id = variables.oVolPlanDAO.insertVolPlan(vpMaster.volPlanMasterId,currVolPLan);
						}
						else{
							variables.oVolPlanDAO.updateVolPlan(currVolPLan);
						}
						//NOW LOOP CUSTOMERS ARRAY
						iCustomersLen = ArrayLen(currVolPLan.customers);
						//DELETE EXISTING THEN INSERT
						variables.oVolPlanDAO.deleteVolPlanCustomers(currVolPLan);
						for( x=1; x <= iCustomersLen; x++){
							variables.oVolPlanDAO.saveVolPlanCustomersPG(currVolPLan.id,currVolPLan.customers[x]);
						}
						//NOW LOOP CUSTOMERS PLAN GROUP ARRAY
						iCustomersLen = ArrayLen(currVolPLan.PgCustomers);
						//DELETE EXISTING THEN INSERT IN LOOP
						variables.oVolPlanDAO.deleteVolPlanCustomers(currVolPLan);
						for( y=1; y <= iCustomersLen; y++){
							variables.oVolPlanDAO.saveVolPlanCustomersPG(currVolPLan.id,currVolPLan.PgCustomers[y]);
						}
						//NOW LOOP POSITIONS ARRAY
						iUserPositionsLen = ArrayLen(currVolPLan.positions);
						//DELETE EXISTING THEN INSERT
						variables.oVolPlanDAO.deleteVolPlanPositions(currVolPLan);
						for( z=1; z <= iUserPositionsLen; z++){
							variables.oVolPlanDAO.saveVolPlanPositions(currVolPLan.id,currVolPLan.positions[z]);
						}
				    }
					
				}
				if(isArray(vpMaster.recaptureTemplates)){
					iRecapLen = ArrayLen(vpMaster.recaptureTemplates);
					//WriteLog(file="application.log", text="#vpMaster.volPlanMasterId# & :: SAVEVolPlanMaster INS Recapture"); 
					/* save recapture templates */
					for( i=1; i <= iRecapLen; i++){
				       
					}
				}
				</cfscript>
			</cfif>
		</cfloop>
		
		<cfscript>
			
			arrVPMaster = getVolPlanMaster();
		</cfscript>
		<cfreturn arrVPMaster />
	</cffunction>
	
	<cffunction name="deleteVolPlanMaster" returntype="array" access="remote" >
		<cfargument name="vpMasterObj"  type="mvc.Models.Admin.VolumePlan.vos.VolPlanMaster"/>
		<!--- Get array of mvc.Models.Admin.VolumePlan.vos.VolPlanMaster --->
		<cfscript>
			var arrVPMaster = arrayNew(1);
			ArrayAppend(arrVPMaster, vpMasterObj);
		</cfscript>
		<cfloop array="#arrVpMaster#" index="vpMaster">
			<cfscript>
				WriteLog(file="application.log", text=" #arrayLen(arrVpMaster)# :: SAVEVolPlanMaster UPDATE 1");
			</cfscript>
			<cfif isObject(vpMaster) >
				<cfif variables.oVolPlanDAO.checkVolPlanMasterExixts(vpMaster.volPlanMasterId)>
					<cfscript>
						WriteLog(file="application.log", text="#vpMaster.volPlanMasterId# & :: DELETE VolPlanMaster DELETE"); 
						
						variables.oVolPlanDAO.deleteVolPlanMaster(vpMaster.volPlanMasterId);
						
						if(isArray(vpMaster.volPlans)){
							/* update volPlans */
							WriteLog(file="application.log", text="#vpMaster.volPlanMasterId# & :: SAVEVolPlanMaster UPD VolPLans"); 
						}
						if(isArray(vpMaster.recaptureTemplates)){
							/* update recapture templates */
							WriteLog(file="application.log", text="#vpMaster.volPlanMasterId# & :: SAVEVolPlanMaster UPD Recapture"); 
						}
					</cfscript>
				<cfelse>
					<cfscript>
						WriteLog(file="application.log", text="#vpMaster.volPlanMasterId# & :: DELETE VolPlanMaster NO RECORD");
					</cfscript>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfscript>
			arrVPMaster = getVolPlanMaster();
		</cfscript>
		<cfreturn arrVPMaster />
	</cffunction>
	
	<cffunction name="getVolPlanMasterDef" returntype="mvc.Models.Admin.VolumePlan.vos.VolPlanMasterDef" access="remote" >
		<cfargument name="userId" default="0" />
		<!--- Get --->
		 <cfscript>
			var vpMasterDef = variables.oVolPlanMasterDef.init();
			vpMasterDef.loadFromDb();
		</cfscript>
		
		<cfreturn vpMasterDef />
	</cffunction>
	
	<cffunction name="getVolPlans" returntype="array" access="private" >
		<cfargument name="volPlanMasterId" default="0" />
		<!--- Get array of mvc.Models.Admin.VolumePlan.vos.VolumePlan for
			a specific VPMaster
		 --->
		 
	</cffunction>
	
	<cffunction name="getVolPlanAdjustments" returntype="array" access="private" >
		<cfargument name="volPlanId" default="0" />
		<!--- Get array of mvc.Models.Admin.VolumePlan.vos.VolPlanAdjustments for
			a specific VolPlan
		 --->
	</cffunction>

</cfcomponent>