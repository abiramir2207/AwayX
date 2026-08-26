
  
<!--- 
 getUSDACommodityPrices.cfm 

USDA XML DATA FEED DOCO:
https://www.marketnews.usda.gov/mnp/assets/ls/USDA-LMR-WebService-Client-User-Guide-v1_prod.pdf
TYPICAL URL (for LM_PK602 report in this case):
https://mpr.datamart.ams.usda.gov/ws/report/v1/cattle/LM_PK602?filter={%22filters%22:[{%22fieldName%22:%22Report%20date%22,%22operatorType%22:%22BETWEEN%22,%22values%22:[%2209/01/2016%22,%2209/29/2016%22]}]} 
 --->
<cfscript>
 d = DateFormat(now(),'mm/dd/yyyy');
 dEnd = DateFormat(now(),'mm/dd/yyyy');
 appSettings = application.appSettingsGet;
</cfscript>
<cfparam name="URL.process" 			default="0" />
<cfparam name="URL.extraDays" 			default="0" />
 <!--- Pass url variable extraDays from nightly task if you want to load data for prior extra days
eg: If extraDays = 4, On 6/24/2022 we will process 6/20, 6/21, 6/22, 6/23 and 6/24.
We will process current day (6/24) plus 4 past extra days
--->
<cfset d = DateAdd("d", -1*URL.extraDays, dEnd) />
<cfparam name="form.Start_Date" 		default="#d#" />
<cfparam name="form.End_Date" 			default="#dEnd#" />
<cfparam name="form.process" 			default="#URL.process#" />
<cfparam name="form.update" 			default="0" />
<cfoutput>
 <cf_include files=#arrayToList( [  "/styles/css-loader.css",
                                     "/styles/font-awesome.min.css" 
                                  ] )#>

<cfinclude template="/common_files/tabnavFlex.cfm"/>
	   <div class="nav">
	        <ul class="nav">
	        	<CFIF request.accessstructure.User_Code contains "msaunders" OR request.accessstructure.User_Code contains "dkunnath" OR request.accessstructure.User_Code contains "fsupport" OR request.accessstructure.User_Code contains "bflame">
		            <li  class="topnav" onclick="showTab(event, 'priceData')">Get Price Data</li>
		            <li  class="topnav" onclick="showTab(event, 'programUpdate')">Program Update</li>
	        	</CFIF>
	            <li  class="topnav" onclick="showTab(event, 'searchCommodityPrices')" id="defaultTab">Search Commodities</li>
				<cfif appSettings.get_Setting('Display_Comm_Setting_Search_Programs') eq 1>
	            	<li  class="topnav" onclick="showTab(event, 'searchPrograms')">Search Programs</li>
				</cfif>
	        </ul>
	    </div>
		<!--- -------------------------- Get Price Data -------------------------- --->
	<CFIF appSettings.get_Setting('Custom_RFP_Process',0) EQ 0>
	<div class="tabContent" id="priceData">
	<CFIF request.accessstructure.User_Code contains "msaunders" OR request.accessstructure.User_Code contains "dkunnath" OR request.accessstructure.User_Code contains "fsupport" OR request.accessstructure.User_Code contains "bflame"> <!--- Can't trust Users --->
	<FIELDSET STYLE="padding:5px; width: 750px; border: 1px solid Silver;">
		<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Get USDA Price Data</LEGEND>
	 <FORM ACTION="getUSDACommodityPrices.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
	 	<table width="600" border="0" cellspacing="5" cellpadding="0">
	    <tr>
	        <td width="75">Start Date: 
	        </td>
	        <td width="100"><CF_EASYDATE 
						FORMNAME="MyForm" 
						FIELDNAME="Start_Date" 
						FORMAT="mm/dd/yyyy" 
						DEFAULT="#form.Start_Date#">
	        </td>
	        <td>
	        </td>
	    </tr>
	    <tr>
	        <td>End Date:
	        </td>
	        <td><CF_EASYDATE 
						FORMNAME="MyForm" 
						FIELDNAME="End_Date" 
						FORMAT="mm/dd/yyyy" 
						DEFAULT="#form.End_Date#">
	        </td>
	        <td>
	        </td>
	    </tr>
	    <tr>
	        <td>Update:
	        </td>
	        <td><input type="checkbox" name="update" value="1">
	        </td>
	        <td>
	        </td>
	    </tr>
		<tr>
	        <td>
	        </td>
	        <td><button type="submit" name="process" value="1" >import USDA commodity price data</button>
	        </td>
	        <td>
	        </td>
	    </tr>
	</table>
	 </Form>
	 </Fieldset>
	 	<br>
		<br> 
	</CFIF> <!--- Can't Trust USERS --->
	</div>
</CFIF>  <!--- IF Custom_RFP_Process = 0 --->
 <!--- -------------------    END GET PRICE DATA MyForm ------------------------------ --->
 <div class="tabContent" id="programUpdate">
 	<CFIF request.accessstructure.User_Code contains "msaunders"  OR request.accessstructure.User_Code contains "dkunnath"> <!--- Can't trust Users --->
		 <!--- Manually Run Scheduled Job Formula_Price_Program_Update --->
		 <cfinclude template="Run_Formula_Price_Program_Update.cfm" > 
		 <!--- Manually Run Scheduled Job Formula_Price_Program_Update --->

  <!---------------------------- Scheduled Job Details ------------------------------------>
	<cfscript>
		scheduledTasksArray=ArrayNew(1);
		taskService=createobject('java','coldfusion.server.ServiceFactory').getCronService();
		aTasks=taskservice.listall();
		thisPath = ExpandPath("/");
		allSet = 0;
		//thisDirectory = GetDirectoryFromPath(thisPath);
	</cfscript>
	<FIELDSET STYLE="padding:5px; width: 750px; border: 1px solid Silver;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Job Schedule</LEGEND>
	<table width="600" border="0" cellspacing="5" cellpadding="3">
	   <cfif ArrayLen(aTasks) GT 0>
		    <tr bgcolor="##ff9900">
		        <td width="55">Job Name
		        </td>
		        <td width="55"> Next Run
		        </td>
		        <td width="55">Status
		        </td>
		    </tr>
			<cfloop index="i" from="1" to="#ArrayLen(aTasks)#" >

				<cfif aTasks[i].task eq "Get USDA Commodity Prices" AND aTasks[i].status eq 'Running' >
				    <tr>
				        <td>#aTasks[i].task# 
				        </td>
				        <td>#aTasks[i].nextfire# 
				        </td>
				        <td>#aTasks[i].status# 
				        </td>
					
				    </tr>
					<cfset allSet = 1/>
				</cfif>
			</cfloop>
		<cfelse> <!--- SCHEDULE IT --->
			<cfset allSet = 1/>
			<!--- <cfschedule action="update" 
								interval="daily" 
								operation="HTTPRequest" 
								startdate="1/1/2017" 
								starttime="6:00 AM" 
								task="Get USDA Commodity Prices" 
								url="HTTP://#CGI.HTTP_HOST#/scheduled/callGetUSDACommodityPrices.cfm?process=1" 
								resolveURL = "Yes"
							    publish="true" 
								file="getUSDACommodityPrices.log"
								path="#thisPath#Scheduled\"> --->
		</cfif>
		<cfif allSet EQ 0> <!--- SCHEDULE IT --->
					<!--- <cfschedule action="update" 
								interval="daily" 
								operation="HTTPRequest" 
								startdate="1/1/2017" 
								starttime="6:00 AM" 
								task="Get USDA Commodity Prices" 
								url="HTTP://#CGI.HTTP_HOST#/scheduled/callGetUSDACommodityPrices.cfm?process=1" 
								resolveURL = "Yes"
							    publish="true" 
								file="getUSDACommodityPrices.log"
								path="#thisPath#Scheduled\"> --->
		</cfif>
	</table>
	</Fieldset>
	</cfif> <!--- SECURE SOME ADMIN TOOLS :: request.accessstructure.User_Code EQ "msaunders2" --->
</div>
  <!---------------------------------- Scheduled Job Details -------------------------------->


<div class="tabContent" id="searchCommodityPrices">
	<!--- Commoddity Search Tool --->
	<cfinclude template="searchCommodityPrices.cfm" >
 
</cfoutput>

 	<cfscript>
	 /*----------------------------------------------------------------------------------------------------------------------------------------------------
	  -----------------------------------------------------------   GET USDA PRICE DATA   ----------------------------------------------------------------- 
	  ----------------------------------------------------------------------------------------------------------------------------------------------------- */
	 //	WriteOutput(isDate(form.Start_Date)& ' :x: ' & form.process & ' :xx: ' &  datediff("d", form.Start_Date,DateFormat(now(),"mm/dd/yyyy"))  & '   <br>  ');
	 	CommodityPrices	= createObject("component","mvc.Models.Admin.Commodity.CommodityPrices");
	 	curhour = hour(now());
		sEmailRecips = 'xmsaunders@blacksmithApplications.com;dkunnath@blacksmithApplications.com';
	 	// DO SOME CLEANUP -> COMMENTED OUT mws 9/19/18...Do we want to delete data?
	 	///CommodityPrices.cleanDeletedData();
	 	//Process Commodity Data
	 	try{
		 	if(form.process == 1 && isDate(form.Start_Date) && datediff("d", form.Start_Date,DateFormat(now(),"mm/dd/yyyy")) >= 0){
		 		DataIntID = CommodityPrices.InsertDataInt();
				qGetExchangeDetails = CommodityPrices.getExchangeDetails();
				sd = form.Start_Date;
				ed = form.End_Date;
				arr = arrayNew(1);
				Commodities_Report_Log_ID = 0;
				if(form.Start_Date != form.End_Date && datediff("d", form.Start_Date,form.End_Date) > 0){
					while (datediff("d", sd,ed) >= 0) {
						arrayAppend(arr,DateFormat(sd,"mm/dd/yyyy"));
						sd = dateAdd("d",1,sd);
					}
				}else{
					arr = [sd];
				}
				ExchgDtCounter = 0;
				urlArray = [];
				FOR (idate=1;idate LTE ArrayLen(arr);idate=idate+1) {
					//	WriteOutput(arr[idate] & '   <br>         OOOOOOO    :');
					Comm_Datetime = arr[idate];
					CommDayofWeek = DayOfWeek(Comm_Datetime);
					bNoData = 0;
					IF(CommDayofWeek != 1 && CommDayofWeek !=7){ // No Price Data for Saturday and Sunday
						For (exDetail IN qGetExchangeDetails){
							counter = 0;
							sUrl = exDetail.WEB_SERVICE_URL;
							sUrlTxt = sUrl;
							Comm_Datetime_Adjusted = Comm_Datetime;
							/************* Custom logic for UB-DAILY, UB-WEEKLY, UB-MONTHLY *************/
							if(exDetail.Exchange_Detail_Abrev == "UB-DAILY"){
							    sUrl = sUrl & '&startDate=#Comm_Datetime#&endDate=#Comm_Datetime#';   
							}
							else if(exDetail.Exchange_Detail_Abrev == "UB-WEEKLY"){
							    if (DayOfWeek( Comm_Datetime ) == 1) { 
							        // It is Sunday, we need prior to prior week, so subtract 8 days.
							        dtLastWeek = (Fix(Comm_Datetime) - 8);
							    }
							    else {
							        //subtract 7 days so we can get same day in last week
							        dtLastWeek = (Fix(Comm_Datetime) - 7);
							    }
							    //Get start of week - should be a Monday
							    wkStart = DateFormat(dtLastWeek - DayOfWeek( dtLastWeek ) + 2);
							    //Get end of week by adding to start date - should be a Sunday
							    wkEnd = DateFormat( wkStart + 6 );
							    sUrl = sUrl & '&startDate=#DateFormat(wkStart,"mm/dd/yyyy")#&endDate=#DateFormat(wkEnd,"mm/dd/yyyy")#';   
							    Comm_Datetime_Adjusted = wkStart;
        
							    /* When running for a date range, if we already processed this URL no need to process again
							   (weekly uses same date for the whole week)
							    */
							    if(arrayFind(urlArray, sUrl) > 0) continue;
        
							}
							else if(exDetail.Exchange_Detail_Abrev == "UB-MONTHLY"){
							    thisMonth = createDate(year(Comm_Datetime), month(Comm_Datetime), 1); // Find first day of the month
							    monthEnd = DateAdd("d", -1, thisMonth); // last day of prior month
							    monthStart = DateFormat(createDate(year(monthEnd), month(monthEnd), 1)); // First day of prior month
							    sUrl = sUrl & '&startDate=#DateFormat(monthStart,"mm/dd/yyyy")#&endDate=#DateFormat(monthEnd,"mm/dd/yyyy")#';   
							    Comm_Datetime_Adjusted = monthStart;

							    /* When running for a date range, if we already processed this URL no need to process again
							    (monthly uses same date for the whole month)
							    */
							    if(arrayFind(urlArray, sUrl) > 0) continue;
							}
							else {
                                sUrl = sUrl & '?filter={"filters":[{"fieldName":"Report%20date","operatorType":"EQUAL","values":["#Comm_Datetime#"]}]}';
							}
							WriteOutput(sUrl & '   <br>');
        
							Category_ID = exDetail.Category_ID;
							Exchange_Detail_ID = exDetail.Exchange_Detail_ID;
							Exchange_Detail_Name = exDetail.Exchange_Detail_Name;
							//if we haven't run this already or we checked the "update" option"
							// When exDetail.Update_Commodities = 1, we should update
							if(form.update == 1 || exDetail.Update_Commodities || CommodityPrices.checkCommoditiesReportLog(Exchange_Detail_ID,Comm_Datetime) == 0){
								//CALL THE WEBSERVICE
								httpGet = new http();
								httpGet.setUrl(sUrl);
								httpGet.setMethod("get");
        
								// Add request headers: Should be stored in this format - key1=value1,key2=value2
								if(exDetail.Request_Header_List != ""){
								    for (reqHdr in exDetail.Request_Header_List) {
								       if(ListLen(reqHdr, "=") > 1)
								        httpGet.addParam(type="header",name=ListFirst(reqHdr, "="), value=ListLast(reqHdr, "="));
								    }
								}
        
								result = httpGet.send().GetPrefix();
								ArrayAppend(urlArray, sUrl);
        
							WriteOutput('Status:' & result.Statuscode & '   <br>');
        
								//PARSE XML RESULTS
								if(trim(result.Statuscode) contains '200'){
									content = result.filecontent;
        							if(isXML(content)){
										xml = xmlParse(content);
										reportHeader = XmlSearch(xml, "/results/report");// Header Data is in This XML Node
										reportName = reportHeader[1].XmlAttributes.label;
										rebortCode = reportHeader[1].XmlAttributes.slug;
										//Log it
										Commodities_Report_Log_ID = CommodityPrices.setCommoditiesReportLog(Exchange_Detail_ID,Comm_Datetime);
										//We Get Price data in 2 differnt Nodes.  This one and further below in the "Cutout and Primal Values" Node
										report = XmlSearch(xml, "/results/report/record/report"); 
										//WriteDump(#report#);
										FOR (i = 1; i LTE ArrayLen(report); i = i + 1) {
											subCat = report[i].XmlAttributes.label;
											subCatId = CommodityPrices.saveSubCategory(subCat,Category_ID);//If it already exists, it returns the ID  else Insert and then Return ID
											FOR (x = 1; x LTE ArrayLen(report[i].XmlChildren); x = x + 1){
												record = report[i].record[x];
												dataStruct = record.XmlAttributes;
												// We need to ignore some nodes that contain Volume data so look for 'Item_Description'
												if(structKeyExists(dataStruct,'Item_Description') || 
													structKeyExists(dataStruct,'Item_Desc') || 
													structKeyExists(dataStruct,'weight_range_desc') ||
													structKeyExists(dataStruct,'trim_description') ||
													(structKeyExists(dataStruct,'purchase_type') && structKeyExists(dataStruct,'wtd_avg')) ){

													if(structKeyExists(dataStruct,'Item_Description')){
														symbol = dataStruct.Item_Description;
														dataStruct.rolling_avg = 0;
														if(exDetail.Exchange_Detail_Abrev == 'LM_XB403'){
															symbol = subCat & ' ' & dataStruct.Item_Description;
														}
													}
													else if(structKeyExists(dataStruct,'Item_Desc')){
														symbol = dataStruct.Item_Desc;
														dataStruct.weighted_average = dataStruct.price_range_avg;
														dataStruct.rolling_avg = 0;
													}else if(structKeyExists(dataStruct,'purchase_type') && structKeyExists(dataStruct,'wtd_avg')){
														symbol = dataStruct.purchase_type;
														dataStruct.weighted_average = dataStruct.wtd_avg;
														dataStruct.price_range_high = dataStruct.price_High;
														dataStruct.price_range_low = dataStruct.price_low;
													}else if(structKeyExists(dataStruct,'weight_range_desc')){
														symbol = subCat & ' ' & dataStruct.weight_range_desc;
														dataStruct.weighted_average = dataStruct.wtd_avg;
														dataStruct.price_range_high = dataStruct.price_High;
														dataStruct.price_range_low = dataStruct.price_low;
														dataStruct.rolling_avg = 0;
													}else if(structKeyExists(dataStruct,'trim_description')){
														symbol = subCat & ' ' & dataStruct.trim_description;
														if(exDetail.Exchange_Detail_Abrev == 'LM_XB403'){
															symbol = dataStruct.trim_description;
														}
														dataStruct.rolling_avg = 0;
													}else{
														break;
													}
													// remove commas
													dataStruct.price_range_high = replace(dataStruct.price_range_high,',','');
													dataStruct.price_range_low = replace(dataStruct.price_range_Low,',','');
													dataStruct.weighted_average = replace(dataStruct.weighted_average,',','');
													dataStruct.rolling_avg = replace(dataStruct.rolling_avg,',','');

													symbolId = CommodityPrices.saveSymbol(symbol,Exchange_Detail_ID);//If it already exists, it returns the ID  else Insert and then Return ID
													if(!isNumeric(dataStruct.weighted_average)){ // Go get the last valid price
														strLastPrice = structNew();
														strLastPrice = CommodityPrices.getLastCommodityPrice(symbolId,Comm_Datetime);
														dataStruct.price_range_high = strLastPrice.price_range_high;
														dataStruct.price_range_low = strLastPrice.price_range_Low;
														dataStruct.weighted_average = strLastPrice.weighted_average;
														dataStruct.rolling_avg = strLastPrice.rolling_avg;
													}
													if(isNumeric(dataStruct.weighted_average)){
														if(!isNumeric(dataStruct.rolling_avg)){
															dataStruct.rolling_avg = 0;
														}
														if(!isNumeric(dataStruct.price_range_high)){
															dataStruct.price_range_high = 0;
														}
														if(!isNumeric(dataStruct.price_range_low)){
															dataStruct.price_range_low = 0;
														}
														commoditiesId = CommodityPrices.saveCommodity(symbolId,
																									Category_ID,
																									subCatId,
																									dataStruct.price_range_high,
																									dataStruct.price_range_low,
																									dataStruct.weighted_average,
																									dataStruct.rolling_avg,
																									Comm_Datetime,
																									Commodities_Report_Log_ID);
														counter++;								
												/*		writeoutput(#symbol#);
														writeoutput('  $$$  ::  ');
														writeoutput(#x#);
														writeoutput('<br>');*/
													}
													
												}//if "Item_Description"
												else if( (structKeyExists(dataStruct,'pork_carcass') || structKeyExists(dataStruct,'avg_cutout_carcass')) && subCat contains "Cutout and Primal Values"){ ///This is the other node with Price data
														/*
															SubCat should be = "Cutout and Primal Values"
														*/
														for (key in dataStruct) {
															//WriteOutput(key);
															symbol = REPLACE(key,'_',' ');
															symbolId = CommodityPrices.saveSymbol(symbol,Exchange_Detail_ID);//If it already exists, it returns the ID  else Insert and then Return ID
															commoditiesId = CommodityPrices.saveCommodity(symbolId,
																										Category_ID,
																										subCatId,
																										dataStruct["#KEY#"],
																										dataStruct["#KEY#"],
																										dataStruct["#KEY#"],
																										0,
																										Comm_Datetime,
																										Commodities_Report_Log_ID);
															counter++;	
														}
													}
													else{
														/*
														  NADA
														*/
													}
											}// for report children	
										}//FOR report nodes
										If(counter > 0){
											ReportDataIntID = CommodityPrices.InsertDataIntReports('2490',exDetail.Exchange_Detail_Abrev,sUrl,Comm_Datetime); 
											CommodityPrices.UpdateDataInt(ReportDataIntID,counter);
										}
										else{
											ReportDataIntID = 0;
											// ADD LOGIC TO DECIDE IF WE EXPECTED DATA HERE -> SEND EMAIL.  HOLIDAY/WEEKEND/WEEKLY LOGIC
											// Key Off Of Comm_Datetime.  LM_PK610 is Friday ONLY   Dayofweek= DayOfWeek(Date1)
											CommDayofWeek = DayOfWeek(Comm_Datetime);
											bNoData = 0;
											switch(CommDayofWeek){
											    case "1": case "7": // Saturday and Sunday
											         WriteOutput("<br>It is Saturday or Sunday<br>");
											         break;
											    // case "6": // Friday
											    //      WriteOutput("Friday");
											    //      break;
											    default:
											    	if(exDetail.Exchange_Detail_Abrev == 'LM_PK610'){ // weekly only publishes Friday
											         	if(CommDayofWeek == 6){
											         		WriteOutput("<br>It is Friday and LM_PK610 has no data<br>");
												         	bNoData = 1;
												         	break;
														}
													}
											        else{ // weekday should have data
											         	writeOutput("<br>This is a weekday<br>");
													     bNoData = 1;
													 }
											}
											if(bNoData == 1){
												writedump(var=result,output='c:\commoditydump.log');
												savecontent variable="mailBody" {
												 	writeDump( result );
												};
												mailService = new mail(
												  to = "#sEmailRecips#",
												  from = "forgeadmin@bigredflame.com",
												  subject = "#CGI.HTTP_HOST# :: Get USDA Commoddity Prices ZERO RECORDCOUNT ERROR :: #exDetail.Exchange_Detail_Abrev#",
												  body = mailBody
												);
												// Send
												mailService.setType("html");
												mailService.send();
												//abort;
											}
										}
											
											CommodityPrices.updCommoditiesReportLog(Commodities_Report_Log_ID,Comm_Datetime,counter);
											writeoutput(#reportName#);
											writeoutput('   :count:  '  & #counter# & '  :date:  ' &  Comm_Datetime);
											writeoutput('<br>');
									}// IF "XML"
									ELSE{  ///txt parser -> Fixed width text file  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
										arrData = arrayNew(1);
										arrData = listToArray(content,"#chr(13)##chr(10)#",false);
									//	if(CommodityPrices.checkCommoditiesReportLog(Exchange_Detail_ID,Comm_Datetime) == 0){ // these Reports are text so we can't process past dates
											switch(exDetail.Exchange_Detail_Abrev) {
											    case "jk_py001":
											       // writeOutput("jk_py001");
											        counter = CommodityPrices.parse_JK_PY001(arrData,
											        								Exchange_Detail_ID,
											        								Category_ID,
											        								sUrlTxt);
											        break; 
											    case "nw_ls440":
											      //  writeOutput("nw_ls440");
											         counter = CommodityPrices.parse_NW_LS440(arrData,
											        								Exchange_Detail_ID,
											        								Category_ID,
											        								sUrlTxt);
											        break; 
											    case "nw_py029":
											       // writeOutput("nw_py029 ::");
											        counter = CommodityPrices.parse_NW_PY029(arrData,
											        								Exchange_Detail_ID,
											        								Category_ID,
											        								sUrlTxt);
											        break; 
											    case "nw_ls442":
											       // writeOutput("nw_ls442");
											        counter = CommodityPrices.parse_NW_LS442(arrData,
											        								Exchange_Detail_ID,
											        								Category_ID,
											        								sUrlTxt);
											        break;
											    case "WA_DA300":
											       // writeOutput("nw_ls442");
											        counter = CommodityPrices.parse_WA_DA300(arrData,
											        								Exchange_Detail_ID,
											        								Category_ID,
											        								sUrlTxt);
											        break;
											    case "MD_DA997":
											        //writeOutput("MD_DA997");
											        counter = CommodityPrices.parse_MD_DA997(arrData,
											        								Exchange_Detail_ID,
											        								Category_ID,
											        								sUrlTxt);
											        break;
											    case "MD_DA599":
											        writeOutput("MD_DA599");
											        counter = CommodityPrices.parse_MD_DA599(arrData,
											        								Exchange_Detail_ID,
											        								Category_ID,
											        								sUrlTxt);
											        break;
												case "2991":
											        //writeOutput("2991");
											        counter = CommodityPrices.parse_2991(content,
											        								Exchange_Detail_ID,
											        								Category_ID,
											        								sUrlTxt,
											        								Comm_Datetime);
											        break;
												case "UB-DAILY": case "UB-WEEKLY": case "UB-MONTHLY":
											        writeOutput(exDetail.Exchange_Detail_Abrev);
											        counter = CommodityPrices.parse_urner_barry(content,
											        								Exchange_Detail_ID,
											        								Exchange_Detail_Name,
											        								Category_ID,
											        								sUrl,
											        								Comm_Datetime_Adjusted);
											        //Urner Barry API is limited to 2 requests per second. Otherwise it gives error "429 Too Many Requests"
											        //We will pause for 1 second after every second request. 
											        if(qGetExchangeDetails.currentRow mod 2){
											         sleep(1000);
											        }
											        break;
											    default: 
											        writeOutput("NO MATCHING USDA REPORT"); 
											}  // SWITCH exDetail.Exchange_Detail_Abrev
										//}
										// Nothing got updated, send email
										If(counter == 0){
											// ADD LOGIC TO DECIDE IF WE EXPECTED DATA HERE -> SEND EMAIL.  HOLIDAY/WEEKEND/WEEKLY LOGIC
											// Key Off Of Comm_Datetime.  LM_PK610 is Friday ONLY   Dayofweek= DayOfWeek(Date1)
											CommDayofWeek = DayOfWeek(Comm_Datetime);
											bNoDataSendEmail = 0;
											switch(CommDayofWeek){
											    case "1": case "7": // Saturday and Sunday
											         WriteOutput("<br>It is Saturday or Sunday<br>");
											         break;
											    default:
													// 2991 publises only once a month and we don't know specific date
											    	if(exDetail.Exchange_Detail_Abrev == '2991'){ 
											         	bNoDataSendEmail = 0;
													}
											        else{ // weekday should have data
											         	writeOutput("<br>This is a weekday. No data was loaded.<br>");
													     bNoDataSendEmail = 1;
													 }
											}
											if(bNoDataSendEmail == 1){
												writedump(var=result,output='c:\commoditydump.log');
												savecontent variable="mailBody" {
												 	writeDump( "URL:" & sUrl);
												 	writeDump( " ");
												 	writeDump( result );
												};
												mailService = new mail(
												  to = "#sEmailRecips#",
												  from = "forgeadmin@bigredflame.com",
												  subject = "#CGI.HTTP_HOST# :: Get USDA Commoddity Prices ZERO RECORDCOUNT ERROR :: #exDetail.Exchange_Detail_Abrev#",
												  body = mailBody
												);
												// Send
												mailService.setType("html");
												mailService.send();
											}
										} // If(counter == 0)
									}// IF ELSE XML -> txt parser   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
								}// IF "200""
								else{
									savecontent variable="mailBody" {
									 	writeDump( result );
									};
									// Create and populate the mail object
									mailService = new mail(
									  to = "#sEmailRecips#",
									  from = "forgeadmin@bigredflame.com",
									  subject = "#CGI.HTTP_HOST# :: Get USDA Commoddity Prices HTTP ERROR",
									  body = mailBody
									);
									// Send
									mailService.setType("html");
									mailService.send();

								}
							}// IF REPORT $ DATE Not Processed
							ExchgDtCounter = ExchgDtCounter + Counter;
						}// FOR LOOP qExchangeDetails
					}  // IF(CommDayofWeek != 1 && CommDayofWeek !=7
				}//FOR Loop Dates array
				writeoutput('DONE! #now()#  :: Exchg: #ExchgDtCounter#');
				CommodityPrices.UpdateDataInt(DataIntID,ExchgDtCounter);
			}// If Form
		} // try
		catch (any e){
	    	// writeOutput("Error: " & e.message);
	    	writedump(var=e,output='c:\commoditydump.log');
	    	
	    	savecontent variable="mailBody" {
			  writeOutput( "Get USDA Commoddity Prices ERROR: " & "<br><br>" & e.message & "<br><br>" & e.detail & "<br><br>");
			};

			mailService = new mail(
			  to = "#sEmailRecips#",
			  from = "forgeadmin@bigredflame.com",
			  subject = "#CGI.HTTP_HOST# :: Get USDA Commoddity Prices RUNTIME ERROR",
			  body = mailBody
			);
			// Send
			mailService.setType("html");
			mailService.send();
			//throw error out to site wide error handler
			throw (message = "#e.message#", detail="#e.detail#");
		}
	/*----------------------------------------------------------------------------------------------------------------------------------------------------
	  -----------------------------------------------------------   GET USDA PRICE DATA   ----------------------------------------------------------------- 
	  ----------------------------------------------------------------------------------------------------------------------------------------------------- */
	</cfscript>
</div>

 <div class="tabContent" id="searchPrograms">
 <!--- Manually Run Scheduled Job Formula_Price_Program_Update --->
 <cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
	<cfinclude template="View_Formula_Price_Item_Level_Programs.cfm" >
 <cfelse>
	<cfinclude template="View_Formula_Price_Programs.cfm" >
 </cfif>
	
 <!--- Manually Run Scheduled Job Formula_Price_Program_Update --->
  </div>
<script>
    // Default to the first tab open
    document.getElementById("defaultTab").click();
</script>