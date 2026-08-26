<cfcomponent extends="mvc.Models.SettingsService" output="false" displayName="FitnessManager">
	
	<cffunction name="getFitnessData" output="false" access="remote" returntype="Array">
		<cfscript>
			//set local variables
			var a = arguments;
			var qFitnessOpenData	= queryNew("");
			var objFitnessDAO 	= CreateObject("component","mvc.Models.Program.Fitness.FitnessDAO");
			var stData = structNew();
			var arr = arrayNew(1);	
			//run the query
			//var a = getTickCount();
			
			qFitnessOpenData = objFitnessDAO.getFitnessHeaderData();
			arr = getFitnessCorrectionHeaderObj(qFitnessOpenData);
			
			//arr[1] =  CreateObject("component","mvc.Models.Program.Fitness.vos.FitnessCorrectionHeader");
			
			//var b = getTickCount();
			//this.dmp(b-a);
			return arr;
		</cfscript>
	</cffunction>
	
	<cffunction name="getFitnessHeaderObj" output="false" access="remote" returntype="mvc.Models.Program.Fitness.vos.FitnessSearchDef">
		<cfargument name="def" type="mvc.Models.Program.Fitness.vos.FitnessSearchDef" required="false" default="#CreateObject("component","mvc.Models.Program.Fitness.vos.FitnessSearchDef")#"/>
		<cfscript>
			//set local variables
			var a = arguments;
			var qFitnessSettingsData	= queryNew("");
			var objFitnessDAO 	= CreateObject("component","mvc.Models.Program.Fitness.FitnessDAO");
			var q = QueryNew('label,sId');
			var s = '';
			//var obj = CreateObject("component","mvc.Models.Program.Fitness.vos.FitnessSearchDef");
			var stData = structNew();
			var arr = arrayNew(1);
		WriteLog(file="mws.log", text="[#def.Current#] [array: ] #now()#"); 
			switch(def.Current) {
			    case "":   //Area1
					 q = objFitnessDAO.getBusSegData();
					 def.Current = 'BusinessSegment0'; //hack for initial load
					 WriteLog(file="mws.log", text="[#def.Current#] [BusinessSegment0 ] #now()#"); 
			         break;
			     case "BusinessSegment0":   //BusSeg
			   		 Idx = def.BusinessSegment0Idx + 1;
					 q = objFitnessDAO.getArea1Data(def.BusinessSegment0['#Idx#']['ID']);
					 def.Current = 'Area1'; //hack for initial load
					  WriteLog(file="mws.log", text="[#def.Current#] [Area1 ] #now()#");
			         break;
			    case "Area1":   //Area1
			    	 Idx = def.Area1Idx + 1;
					 q = objFitnessDAO.getRegion2Data(def.Area1['#Idx#']['ID']);
					 def.Current = 'Region2';
					  WriteLog(file="mws.log", text="[#def.Current#] [Region2 ] #now()#"); 
			         break;
			    case "Region2":		//Region2
			    	if(ISARRAY(def.Region2)){ 
			    		Idx = def.Region2Idx +1;
			         	q = objFitnessDAO.getCustomer3Data(def.Region2['#Idx#']['ID']);
			         }
			         def.Current = 'Customer3';
			         break;
			    case "Customer3":	//Customer3
			    	 Idx = def.Customer3Idx + 1;
			         q = objFitnessDAO.getYear4Data(def.Customer3['#Idx#']['ID']);
			         def.Current = 'Year4';
			         break;
			    case "Year4":		//Year4
			    	 Idx = def.Customer3Idx + 1;
			         Idx2 = def.Year4Idx + 1; // Fiscal_Year 
			         q = objFitnessDAO.getProgram5Data(def.Customer3['#Idx#']['ID'],def.Year4['#Idx2#']['ID']);
			         def.Current = 'Program5';
			         break;
			    case "Program5":	//Program5
			         Idx = def.Program5Idx + 1;
			         Idx2 = def.Year4Idx + 1;
			         //get id's
			         a =listToArray(def.Program5['#Idx#']['ID'],'_');
			         a1 = a[1]; // Contract_main_Id
			         a2 = a[2]; // Component_Id
			         a3 = a[3]; // Discount_Type_Id
			         q = objFitnessDAO.getPeriod6Data(a1,a2,a3,def.Year4['#Idx2#']['ID']);
			         def.Current = 'Period6';
			         break;
			    case "Period6":		//Period6
			         Idx = def.Period6Idx + 1;
			        // WriteLog(file="mws.log", text="#def.Period6['#Idx#']['ID']#");
			         a =listToArray(def.Period6['#Idx#']['ID'],'_');
			         a1 = a[1]; // Fiscal_Year_ID
			         a2 = a[2]; // Payment_Cycle_ID
			         a3 = a[3]; // Period
			         q = objFitnessDAO.getFitnessDetailData(a1,a2,a3);
			         def.Current = 'Period6';
			         break;
			/*    case "Category7":	//Category7
			         WriteOutput("I like Oranges");
			         break;
			    case "Family8":		//Family8
			         WriteOutput("I like Oranges");
			         break;
			    case "Finance9":	//Finance9
			         WriteOutput("I like Oranges");
			         break;*/
			    default: 
			         WriteOutput("we are done");
			}
			//
			stData.label 	=	'Choose One';
			stData.id		=	'';
			ArrayAppend(arr, duplicate(stData));	
			for (intRow = 1 ; intRow LTE q.RecordCount ;intRow ++){
						stData = structNew();
						stData.label 	=	q.label[intRow];
						stData.id		=	q.sId[intRow];
						ArrayAppend(arr, duplicate(stData));
				}
			def['#def.Current#'] = arr;
			return def;
		</cfscript>
	</cffunction>
	
	<cffunction name="getFitnessHistory" output="false" access="remote" returntype="Array">
		<cfscript>
			//set local variables
			var a = arguments;
			var qFitnessHistoryData = queryNew("");
			var objFitnessDAO 	= CreateObject("component","mvc.Models.Program.Fitness.FitnessDAO");
			var stData = structNew();
			var arr = arrayNew(1);	
			//run the query
			//this.dmp(a);
			qFitnessHistoryData = objFitnessDAO.getFitnessHistoryData();
			
			for (intRow = 1 ; intRow LTE qFitnessHistoryData.RecordCount ;intRow ++){
				stData["__type__"] = "mvc.Models.Program.Fitness.vos.FitnessCorrectionHistory";
				stData["sourceType"] = qFitnessHistoryData.sourceType[intRow];
				ArrayAppend(arr, duplicate(stData));
			}
			//return the billback struct
			return arr;
		</cfscript>
	</cffunction>
		
	<cffunction name="getFitnessDetails" output="false" access="remote" returntype="array">
		<cfargument name="def" type="mvc.Models.Program.Fitness.vos.FitnessSearchDef" required="false" default="#CreateObject("component","mvc.Models.Program.Fitness.vos.FitnessSearchDef")#"/>
		<cfscript>
			//set local variables
			var objFitnessDAO 			= CreateObject("component","mvc.Models.Program.Fitness.FitnessDAO");
			var qFitnessDetailData	= "";
			var aFitnessDetailData	= ArrayNew(1);
			var stData 				= structNew();	
			
			var Idx = def.Period6Idx + 1;
	        var a =listToArray(def.Period6['#Idx#']['ID'],'_');
	        var Fiscal_Year_ID = a[1]; // Fiscal_Year_ID
	        var Payment_Cycle_ID = a[2]; // Payment_Cycle_ID
	        var Period = a[3]; // Period
	        Idx = def.Customer3Idx + 1;
	        var cust = def.Customer3['#Idx#']['ID'];
	        Idx = def.Program5Idx + 1;
	        a =listToArray(def.Program5['#Idx#']['ID'],'_');
	        var Contract_main_Id = a[1]; // Contract_main_Id
	        var Component_Id = a[2]; // Component_Id
	        var Discount_Type_Id = a[3]; // Discount_Type_Id
	        Idx = def.Year4Idx + 1;
	        var Fiscal_Year = def.Year4['#Idx#']['ID'];
	         WriteLog(file="mws.log", text="#Fiscal_Year_ID#  ::  #Payment_Cycle_ID#  ::  #Period#  ::  #cust#  ::  #Contract_main_Id#  ::  #Component_Id#  ::  #Discount_Type_Id# :: #Fiscal_Year#");
	         def.Current = 'Period6';
			
			//assign local variables
			qFitnessDetailData 			= objFitnessDAO.getFitnessDetailData(Fiscal_Year_ID,
																			 Payment_Cycle_ID,
																			 Period,
																			 cust,
																			 Contract_main_Id,
																			 Component_Id,
																			 Discount_Type_Id,
																			 Fiscal_Year	);
		
			for (intRow = 1; intRow LTE qFitnessDetailData.RecordCount; intRow ++){
				stData 					= structNew();
				stData["__type__"] 		= "mvc.Models.Program.Fitness.vos.FitnessDetail";
				stData["item"] 			= qFitnessDetailData.item[intRow];
				stData["description"] 	= qFitnessDetailData.description[intRow];
				stData["sigLabel"] 		= qFitnessDetailData.sigLabel[intRow];
				stData["eligibility"] 	= qFitnessDetailData.eligibility[intRow];
				stData["yago"] 			= qFitnessDetailData.yago[intRow];
				stData["revenue"] 		= qFitnessDetailData.revenue[intRow];
				stData["cases"] 		= qFitnessDetailData.cases[intRow];
				stData["lbs"] 			= qFitnessDetailData.lbs[intRow];
				stData["yagoNon"] 		= qFitnessDetailData.yagoNon[intRow];
				stData["revenueNon"] 	= qFitnessDetailData.revenueNon[intRow];
				stData["casesNon"] 		= qFitnessDetailData.casesNon[intRow];
				stData["lbsNon"] 		= qFitnessDetailData.lbsNon[intRow];
				stData["qBrand"] 		= qFitnessDetailData.qBrand[intRow];
				stData["prodVarA"] 		= qFitnessDetailData.prodVarA[intRow];
				stData["typeCodeDesc"] 	= qFitnessDetailData.typeCodeDesc[intRow];
	
				ArrayAppend(aFitnessDetailData, duplicate(stData));
			}
		
			//return the array of settings
			return aFitnessDetailData;
			
		</cfscript>
		
	</cffunction>
	
	<cffunction name="getDropDownData" output="false" access="remote" returntype="array">
		
		<cfscript>
			//set local variables
			var objFitnessDAO 			= CreateObject("component","mvc.Models.Program.Fitness.FitnessDAO");
			var rFitnessVO 			= CreateObject("component","mvc.Models.Program.Fitness.vos.FitnessSettings");
			var qFitnessSettingsData	= "";
			var aFitnessSettingsData	= ArrayNew(1);
			var stData 				= structNew();	
			
			//assign local variables
			qFitnessSettingsData 			= objFitnessDAO.getFitnessSettingsData();
		
			for (intRow = 1; intRow LTE qFitnessSettingsData.RecordCount; intRow ++){
			
				stData 							= structNew();
				stData["__type__"] 				= "mvc.Models.Program.Fitness.vos.FitnessSettings";
				stData["sourceCode"] 			= qFitnessSettingsData.Source_Code[intRow];
				
				
				ArrayAppend(aFitnessSettingsData, duplicate(stData));
			}
		
			//return the array of settings
			return aFitnessSettingsData;
			
		</cfscript>
		
	</cffunction>

	
</cfcomponent>