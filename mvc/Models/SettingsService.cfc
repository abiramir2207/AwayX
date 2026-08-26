<!--- 
FILE: 		BA Application - Model: SettingsService Component	
FILEname:   SettingsService.cfc											
CREATED:  	03/06/2009 - Brad Lee MMCP/ACI
EDITED:   	03/06/2009 - Brad Lee MMCP/ACI

FUNCTIONALITY: 
- Flex Settings are obtained by this object.

LEGEND:
- I always return a structure of string labels --->

<!--- COLDFUSION COMPONENT: Model - Settings [Service] --->
<cfcomponent name="SettingsService" displayname="SettingsService" hint="Settings Values" alias="mvc.Models.SettingsService">
	<cfscript>
		/*variables.oBillbackDAO = CreateObject("component","mvc.Models.Billback.BillbackDAO");
		variavbles.oSettlementDAO = CreateObject("component","mvc.Models.Billback.BillbackSettlementDAO");
		variables.oBillbackMan = CreateObject("component","mvc.Models.Billback.BillbackManager");*/
	</cfscript>	
	
	<cffunction name="getSettingsObject" returntype="Struct" access="remote">
		<cfargument name="userId" default="00000000-9999-9999-0000000000000000">
		<cfargument name="timeZoneOffset" default="0">
		<cfargument name="useDayLightSavingsTime" type="boolean" default="0">

		<cfscript>
			var obj = this;
			var stSettings = StructNew();
			var appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
			var defaultSortSettings = getDefaultSortSettings();
			var billbackSettings	= getBillbackSettings();
			
			//profile and user settings [empty for now] -> we may want to write and all use a common function for profile data
			stSettings.USER = StructNew();
			stSettings.USER = obj.getUserObject(request.AccessStructure.User_ID);

            // BB UPLOAD FILE PATH 
			uploadUtility  = CreateObject("component","components.Billback.BillbackUploadUtility");
			uploadFilePath = 'common_documents';
			uploadFilePath = '#uploadFilePath#/Data_Files/Settings/Billback_Upload_Files/';

			//APPSETTINGS: return application.appSettingsGet as a structure with keys named the same as the appsettings methods
			 
             stSettings.APPSETTINGS["__type__"]=                               "mvc.Models.Settings.vos.AppSettings";
             stSettings.APPSETTINGS["Exact_List_Matching_On"]=                 JavaCast("boolean",appSettings.Exact_List_Matching_On);
             stSettings.APPSETTINGS["BB_Ref_Num_Max_Length"]=                  appSettings.BB_Ref_Num_Max_Length;
             stSettings.APPSETTINGS["BB_2Ref_Num_Max_Length"]=                 appSettings.BB_2Ref_Num_Max_Length;
             stSettings.APPSETTINGS["Budgets_Functionality_On"]=               appSettings.BudgetsFunctionalityOn;
             stSettings.APPSETTINGS["BusinessConsiderations_On"]=              appSettings.BusinessConsiderations_On;
             stSettings.APPSETTINGS["BillBack_Statement_Type"]=                appSettings.BillBack_Statement_Type;
             stSettings.APPSETTINGS["BB_Fractional_Volume"]=                   appSettings.BB_Fractional_Volume;
             stSettings.APPSETTINGS["BB_PAYEE_OPERATOR_SHIP_TO_REQ"]=          appSettings.BillBack_Statement_Type;
             stSettings.APPSETTINGS["Shard_Ship_To_Label"]=                    application.returned_customer_setting.Shard_Ship_To_Label;
             stSettings.APPSETTINGS["Operator_Label_Singular"]=                application.returned_customer_setting.operator_label_singular;
             stSettings.APPSETTINGS["Distributor_Label_Singular"]=             application.returned_customer_setting.distributor_label_singular;
             stSettings.APPSETTINGS["Multiple_BillTos_For_ShipTo"]=            appSettings.Multiple_BillTos_For_ShipTo;
             stSettings.APPSETTINGS["DD_Restrict_ShipTo_For_BB"]=              appSettings.DD_Restrict_ShipTo_For_BB;
             stSettings.APPSETTINGS["Billback_Display_All_Program_Components"]=JavaCast("boolean", appSettings.Billback_Display_All_Program_Components);
             stSettings.APPSETTINGS["BB_LS_Claimed_Rebate_Expected"]=          appSettings.BB_LS_Claimed_Rebate_Expected;
             stSettings.APPSETTINGS["View_Program_Volume_UOM"]=                appSettings.View_Program_Volume_UOM;
             stSettings.APPSETTINGS["Template_Multiple_Product_Attr_Groups"]=  appSettings.Template_Multiple_Product_Attr_Groups;
             stSettings.APPSETTINGS["Pullback_Label"]=                         appSettings.getPullbackLabel();
             stSettings.APPSETTINGS["Original_Buyer_Label"]=                   'Orig. Buyer';
             stSettings.APPSETTINGS["Final_Buyer_Label"]=                      'Ult. Buyer';
             stSettings.APPSETTINGS["BB_Created_Recently_Days"]=               appSettings.BBCreatedRecentlyDays;
             stSettings.APPSETTINGS["SHOW_HOLDING_PEN"]=                       JavaCast("boolean",appSettings.getShowHoldingPen());
             stSettings.APPSETTINGS["Zone_Label"]=                             obj.getCustomerSettingsLabels().Zone_Label;
             stSettings.APPSETTINGS["Region_Label"]=                           obj.getCustomerSettingsLabels().Region_Label;
             stSettings.APPSETTINGS["Prod_Var_A"]=                             obj.getProductGroupLabels().prodVarA;
             stSettings.APPSETTINGS["Business_Segment_Label"]=                 appSettings.business_segment_label;
             stSettings.APPSETTINGS["Enable_EDI_Upload_Raw_Data_Viewer"]=      JavaCast("boolean",appsettings.getEnableEDIUploadRawDataViewer());
             stSettings.APPSETTINGS["bbUploadFilePath"]=                       uploadFilePath;
             stSettings.APPSETTINGS["EnableBBDupCheck"]=                       JavaCast("boolean",billbackSettings.Enable_BB_Dup_Check);
             stSettings.APPSETTINGS["Search_inactive_products_programs"]=      JavaCast("boolean",appSettings.Search_inactive_products_programs);
			
			// APP FLEX: Custom settings For FLEX APPS
			stSettings.APPFLEX = {
                  BBLABELS: obj.getBBLabels()
                , DISTRIBUTORSINGULARLABEL: application.returned_customer_setting.distributor_label_singular neq ""
                                                                ? application.returned_customer_setting.distributor_label_singular
                                                                : "Distributor"
                , BRAND       : obj.getProductGroupLabels().brand
                , QBRAND      : obj.getProductGroupLabels().qBrand
                , TYPECODE    : obj.getProductGroupLabels().typeCode
                , TYPEGROUP   : obj.getProductGroupLabels().typeGroup
                , BILLTOLABEL : obj.getCustomerSettingsLabels().BillTo_Label
            };
            
			stSettings.CFAPP_BUTTONHEIGHT         = 16;
			stSettings.CFAPP_COMBOBOXHEIGHT       = 15;
			stSettings.CFAPP_TEXTINPUTHEIGHT      = 20;
			stSettings.CFAPP_COMBOBOXCONTENTWIDTH = 360;
			
			// BILLBACK SORT COLUMN AND ORDER
			stSettings.CFAPP_SCORECARDSORTOPTION = defaultSortSettings.DefaultSortColumn;
			stSettings.CFAPP_SCORECARDSORTMETHOD = defaultSortSettings.DefaultSortOrder;
			
			//SET TIMEZONE FROM CLIENT
			setFlexClientValues(arguments.timeZoneOffset,arguments.useDayLightSavingsTime);
        </cfscript>
        
		<!---  persist timeZone Offset  --->
		<CFWDDX ACTION="CFML2WDDX" INPUT="#request.AccessStructure#" OUTPUT="myPacket">
		<!--- Create cookie with contents of the WDDX packet --->
		<CFCOOKIE NAME="User_Info" VALUE="#myPacket#" expires="never">
		
		<CFQUERY NAME="Get" datasource="#application.datasource#">
			--HACK To get BOOLEAN DATATYPE IN FLEX
			select 0 as bool
		</CFQUERY>

		<!--- Not yet created ap setting.  Allow multiple deductions to be used to pay against a BB --->
		<cfset stSettings.APPSETTINGS.Allow_Multiple_Deduction_Settlement = Get.bool>
		
		<cfif appSettings.SSL_On>
			<cfset sUrl = 'https://#CGI.HTTP_HOST#/'/>
		<cfelse>
			<cfset sUrl = 'http://#CGI.HTTP_HOST#/'/>
        </cfif>
		<cfset stSettings["sURL"] = sUrl />
		
		<cfreturn stSettings>
	</cffunction>

	<!--- MODEL METHOD: getSpecificAppLabels() FUNCTIONALITY: I always return a structure of string labels. [begin] --->
	<cffunction name="getSpecificAppLabels" access="remote" output="false" returntype="struct" hint="I always return a structure of string labels.">
    	<cfscript>
			var currentKey 			= '';
			var specificAppLabels 	= structNew();
		</cfscript>
        <cfloop collection="#application.appsettingsget#" item="currentKey">
            <cfif 	(	findNoCase('brand',currentKey,1)
						OR
						findNoCase('code',currentKey,1)
						OR
						findNoCase('group',currentKey,1)
						OR
						findNoCase('header',currentKey,1)
						OR
						findNoCase('label',currentKey,1)
						OR
						findNoCase('type',currentKey,1)
					)
						AND
						isSimpleValue(application.appsettingsget[currentKey])
						AND NOT
						isNumeric(application.appsettingsget[currentKey])
			>
                <cfset structInsert(specificAppLabels,currentKey,application.appsettingsget[currentKey],true)>
            </cfif>
        </cfloop>
        <cfscript>
			return specificAppLabels;
		</cfscript>
	</cffunction>
    <!--- MODEL METHOD: getSpecificAppLabels() FUNCTIONALITY: I always return a structure of string labels. [end] --->
    
    <!--- MODEL METHOD: getProductGroupLabels() FUNCTIONALITY: I return a structure of ProductGroup string labels. [begin] --->
    <cffunction name="getProductGroupLabels" access="remote" output="false" returntype="struct" hint="I return a structure of ProductGroup string labels.">
    
    	<!--- Parameters associated with this method (Function-level variables are prefixed with "") ---> 
    	<cfset var appSettings = application.appSettingsGet />
    	<cfset var oProductGroupAttributeManager = '' />
        <cfset var qGetProductGroupAttributes = queryNew('cols') />
        <cfset var label_brand = "" />
        <cfset var label_qBrand = "" />
        <cfset var label_typeCode = "" />
        <cfset var label_typeGroup = "" />
        <cfset var stLabels = structNew() />
        
		<cfset oProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
        <cfset qGetProductGroupAttributes = oProductGroupAttributeManager.getProductGroupAttributes(active=1) />

        <!------ Common file to display the drop down for product groups (Brand, Q Brand, Type Code, Type Group, etc.) ----->
		<!------ ************************** Brand ************************* ----->
        <!---<cfif oProductGroupAttributeManager.getProductLevelSearchFilterOn(qGetProductGroupAttributes, 7)>--->
            <cfset label_brand = oProductGroupAttributeManager.getGroupTypeInfo(groupLevelTypeId = 7).label />
        <!---<cfelse>          
            <cfset label_brand ="Brand">              
        </cfif>--->
        
        <!------ ************************** Q Brand ************************* ----->				
        <!---<cfif oProductGroupAttributeManager.getProductLevelSearchFilterOn(qGetProductGroupAttributes, 5)>--->
            <cfset label_qBrand = oProductGroupAttributeManager.getGroupTypeInfo(groupLevelTypeId = 5).label />
        <!---<cfelse> 
            <cfset label_qBrand = "Q Brand">
        </cfif>--->
        
        <!------ ************************** Type Code ************************* ----->
        <!---<cfif oProductGroupAttributeManager.getProductLevelSearchFilterOn(qGetProductGroupAttributes, 6)>--->
            <cfset label_typeCode = oProductGroupAttributeManager.getGroupTypeInfo(groupLevelTypeId = 6).label />
        <!---<cfelse>
            <cfset label_typeCode = "Type Code">			
        </cfif>--->
        
        <!------ ************************** Type Group ************************* ----->
        <!---<cfif oProductGroupAttributeManager.getProductLevelSearchFilterOn(qGetProductGroupAttributes, 3)>--->
            <cfset label_typeGroup = oProductGroupAttributeManager.getGroupTypeInfo(groupLevelTypeId = 3).label />
        <!---<cfelse> 
            <cfset label_typeGroup = "Type Group">   
        </cfif> --->
        <cfset label_prodVarA = oProductGroupAttributeManager.getGroupTypeInfo(groupLevelTypeId = 9).label />
        
        <cfset structInsert(stLabels,"brand",label_brand,true)>
        <cfset structInsert(stLabels,"qBrand",label_qBrand,true)>
        <cfset structInsert(stLabels,"typeCode",label_typeCode,true)>
        <cfset structInsert(stLabels,"typeGroup",label_typeGroup,true)>
		<cfset structInsert(stLabels,"prodVarA",label_prodVarA,true)>
        
        <!--- Return the final container to the caller --->
        <cfreturn stLabels>
    
    </cffunction>
    <!--- MODEL METHOD: getProductGroupLabels() FUNCTIONALITY: I return a structure of ProductGroup string labels. [end] --->
	
	<cffunction name="getUserObject" returntype="Struct" access="public">
		<cfargument name="userId" default="00000000-9999-9999-0000000000000000">
		<cfset var obj = ""/>
		<cfset var tmp = ""/>
		<cfset var s = ""/>
		<cfset var i = ""/>
		<cfset var stUser = StructNew()/>
		<cfset var stAccessStructure = StructNew()/>
		<cfset var stProfileSettings = StructNew()/>
		
		<cfset stProfile.accessStructure = "" />
		<!---<cfif Not isDefined("session.stUser")>--->
				<CFQUERY NAME="GetUserData" datasource="#application.datasource#" DBTYPE="ODBC">
				Select
						_Users.User_ID,
						_Users.User_Code,
						_Users.Name_First,
						_Users.Name_Last,
						_Users.Profiles_ID,
						_Users.Company_Main_ID,
						_Users.Access_Level,
						_Users.User_Email,
						_Users.User_Rights_ID,
						_Users.Is_USDA_User,
						_Users.Password_Update_Date,
						Company_Main.Company_Name,
						Company_Main.Company_Main_ID,
						Company_Main.Company_Type_ID,
						Company_Main.National_Affiliation_Code,
						Company_Main.Company_logo
						
					From
						_Users,
						Company_Main
					Where	_Users.User_ID = <cfqueryparam value="#arguments.UserId#" cfsqltype="cf_sql_varchar" />
				</CFQUERY>
				<CFSET StructInsert(stAccessStructure, 'User_ID', 					GetUserData.User_ID, True)>
				<CFSET StructInsert(stAccessStructure, 'User_Code', 				GetUserData.User_Code, True)>
				<CFSET StructInsert(stAccessStructure, 'Name_First', 				GetUserData.Name_First, True)>
				<CFSET StructInsert(stAccessStructure, 'Name_Last', 				GetUserData.Name_Last, True)>
				<CFSET StructInsert(stAccessStructure, 'Profiles_ID', 				GetUserData.Profiles_ID, True)>
				<CFSET StructInsert(stAccessStructure, 'National_Affiliation_Code', GetUserData.National_Affiliation_Code, True)>
				<CFSET StructInsert(stAccessStructure, 'Company_Name', 				GetUserData.Company_Name, True)>
				<CFSET StructInsert(stAccessStructure, 'Company_Main_ID', 			GetUserData.Company_Main_ID, True)>
				<CFSET StructInsert(stAccessStructure, 'Company_Type_ID', 			GetUserData.Company_Type_ID, True)>
				<CFSET StructInsert(stAccessStructure, 'Company_logo', 				GetUserData.Company_logo, True)>
				<!--- <CFSET StructInsert(stAccessStructure, 'User_Directory', 		User_Directory, True)>
				<CFSET StructInsert(stAccessStructure, 'Access_Level', 				GetUserData.Access_Level, True)> --->
				<CFSET StructInsert(stAccessStructure, 'User_Rights_ID', 			GetUserData.User_Rights_ID, True)>
				<CFSET StructInsert(stAccessStructure, 'User_Email', 				GetUserData.User_Email, True)>
				<CFSET StructInsert(stAccessStructure, 'userId_Arg', 				arguments.UserId, True)>
				<cfif isnumeric(stAccessStructure.Profiles_ID)>
					<cfset obj = createObject("component","components.user.Profile") />
					<cfset tmp = obj.getProfileSettings(stAccessStructure.Profiles_ID)>
					<cfloop list="#tmp.columnlist#" index="i">
						<cfset s = "tmp." & i>
						<cfset structinsert(stProfileSettings,i,evaluate(s),true)>
					</cfloop>
				</cfif>
				<cfset StructInsert(stUser,"stAccessStructure",stAccessStructure,true)>
				<cfset StructInsert(stUser,"stProfileSettings",stProfileSettings,true)>
				<cfset session.stUser = stUser>
		<!---</cfif>--->
		<cfreturn session.stUser>
	</cffunction>
	
	<cffunction name="getAppSettingsObject" returntype="Struct" access="public">
		<cfset var stSettings = structnew()/>
		<cfif Not isdefined("Application.stFlexAppSettings")>
			<cfloop collection="#Application.appSettingsGet#" item="i">	
				<cfif left(i,3) eq "get">
					<cfset s = "Application.appSettingsGet." & i & "()">
					<cfset structinsert(stSettings,i,evaluate(s))>
					<!--- <cfoutput>#evaluate(s)#<br></cfoutput> --->
				</cfif>
			</cfloop>
			<cfset Application.stFlexAppSettings = stSettings />
		</cfif>
		<cfreturn Application.stFlexAppSettings>
	</cffunction>

	<!--- Set the Attributes for Flex Controls --->
	<cffunction name="getUIAttributes" returntype="Struct" access="public">
		<cfset var stUIAttributes = structnew()/>
			
			<cfset stUIAttributes.cfApp_buttonHeight = 16>
			<cfset stUIAttributes.cfApp_comboBoxHeight = 15>
			<cfset stUIAttributes.cfApp_textInputHeight = 20>
			<cfset stUIAttributes.cfApp_comboBoxContentWidth = 440>  <!--- changed from 360 to 440 : 41142 MARKET/POSITION DISPLAY CUTOFF IN VIEW --->

		<cfreturn stUIAttributes>
	</cffunction>

	<!--- get the billback labels --->
	<cffunction name="getBBLabels" returntype="Struct" access="public">
		<cfset var stBBLabels = structnew()/>
		<cfset var labelSettings = Createobject("component", "components.settings.Labels.Labels") />
		<cfset var qBBLabels = labelSettings.getBillBackLabels() />

		<cfloop query="qBBLabels">
			<cfset structInsert(stBBLabels, replace(qBBLabels.Billback_Labels_Desc, ' ', '_', 'all'),	qBBLabels.Billback_Labels_Label, true) />
		</cfloop>

		<cfreturn stBBLabels />
	</cffunction>

		<!--- get the deduction labels --->
		<cffunction name="getDDLabels" returntype="Struct" access="public">
			<cfset var stDDLabels = structnew()/>
			<cfset LabelComp 		= Createobject("component", "components.settings.labels.labels").init() />
			<cfset var qDDLabels	= LabelComp.GetDeductionLabels() />
			<cfloop query="qDDLabels">
				<cfset structInsert(stDDLabels, replace(qDDLabels.Deduction_Labels_Desc, ' ', '_', 'all'),	qDDLabels.Deduction_Labels_Label, true) />
			</cfloop>
			<cfreturn stDDLabels />
		</cffunction>
	<!--- get the customer setting labels --->
	<cffunction name="getCustomerSettingsLabels" returntype="query" access="public">

		<cfset var objLabel = Createobject("component", "components.settings.labels.labels").init() />
		<cfset var qGetCustomerSettingLabels = objLabel.GetCustomerSettingsLabels() />

		<cfreturn qGetCustomerSettingLabels />
		
	</cffunction>
	
	<!--- Set "timeZoneOffset" and "useDayLightSavingsTime" --->
	<cffunction name="setFlexClientValues" returntype="void" access="public">
		<cfargument name="timeZoneOffset" type="numeric">
		<cfargument name="useDayLightSavingsTime" type="boolean">

		<cfscript>
			//SET TIMEZONE FROM CLIENT
			if(IsDefined("timeZoneOffset"))
			{
				StructInsert(request.AccessStructure, 'timeZoneOffset', timeZoneOffset, True);
			}

			//SET DAYLIGHTSAVINGSTIME FROM CLIENT
			if(IsDefined("useDayLightSavingsTime"))
			{
				StructInsert(request.AccessStructure, 'useDayLightSavingsTime', useDayLightSavingsTime, True);
			}
			
			Session.AccessStructure = request.AccessStructure;
		</cfscript>

	</cffunction>
	
	<!--- GET EST timezoneOffset --->
	<cffunction name="getTimeZoneOffsetEST" returntype="Numeric" access="public">
		<cfset var ESTDiff = 0 />
		<!--- 
	        D115794 Turn off 'timeZoneOffset' functionality.  It was introduced because flex automatically converted dates based on local timezone.
	        Now in JS billbacks it is causing issues.  Flex is deprecated so this is not needed.
	       --->
		<cfreturn ESTDiff>
		<!--- Difference between UTC and EST (in minutes) --->
		<cfquery name="qESTDiff" datasource="#application.datasource#">
		  SELECT DATEDIFF(mi, GetDate(),GetUtcDate()) As ESTDiff
		</cfquery>
		<cfset ESTDiff = qESTDiff.ESTDiff />

		
	</cffunction>
	
	<!--- Get the difference between the user's Local TimeZone and EST --->
	<cffunction name="DiffLocalTimeZoneAndEST" returntype="Numeric" access="public">
		<cfset var DiffLocalTimeZoneAndEST = 0>
		<!--- 
	        D115794 Turn off 'timeZoneOffset' functionality.  It was introduced because flex automatically converted dates based on local timezone.
	        Now in JS billbacks it is causing issues.  Flex is deprecated so this is not needed.
	       --->
		<cfreturn DiffLocalTimeZoneAndEST>
		<cfif IsDefined("request.AccessStructure.timeZoneOffset")>
			<cfset DiffLocalTimeZoneAndEST = request.AccessStructure.timeZoneOffset - this.getTimeZoneOffsetEST()>
		</cfif>
		
		
	</cffunction>
	
	<!--- Billback default sort column and order --->
	<cffunction name="getDefaultSortSettings" returntype="query" access="private">

	<cfquery name="qDefaultSortSettings" datasource="#application.datasource#">
		SELECT 	Default_Sort_By As DefaultSortOrder, 
				CASE WHEN Default_Sort_Option_For_Scorecard = 'BBI' THEN 'BBCode'
				 	 WHEN Default_Sort_Option_For_Scorecard = 'BBD' THEN 'BBDate'	
				 	 WHEN Default_Sort_Option_For_Scorecard = 'BBNUM' THEN 'BBNumber'
				 	 WHEN Default_Sort_Option_For_Scorecard = 'BBT' THEN 'title'
				 	 WHEN Default_Sort_Option_For_Scorecard = 'BBSD' THEN 'startDate'
				 	 WHEN Default_Sort_Option_For_Scorecard = 'BBED' THEN 'endDate'
				 	 WHEN Default_Sort_Option_For_Scorecard = 'BBA' THEN 'amount'
				ELSE 'BBCode'	 
				END 
					AS DefaultSortColumn
		FROM 	
				Billback_settings
	</cfquery>
	
	<!--- If the record for default sorting does not exist, hardcode the values --->
	<cfif qDefaultSortSettings.RecordCount EQ 0>

		<cfset qDefaultSortSettings = QueryNew("DefaultSortColumn,DefaultSortOrder")>

		<cfset QueryAddRow(qDefaultSortSettings, "1")>
		<cfset QuerySetCell(qDefaultSortSettings,"DefaultSortColumn","BBCode", 1)>
		<cfset QuerySetCell(qDefaultSortSettings,"DefaultSortOrder","ASC", 1)>

	</cfif>

		<cfreturn qDefaultSortSettings>

	</cffunction>
	
		<!--- Billback default sort column and order --->
	<cffunction name="getBillbackSettings" returntype="query" access="public">

	<cfquery name="qBillbackSettings" datasource="#application.datasource#">
		SELECT 	Enable_BB_Dup_Check,
				Same_Dollar_Amount,
				Same_Reference_Number,
				Same_Payee,
				Same_Start_End_Dates,
				Auto_Approve_CM_OFF,
				Auto_Approve_On
		FROM 	
				Billback_settings
	</cfquery>
	
	<cfreturn qBillbackSettings />
	
	</cffunction>
	
	<cfscript>
	    function GetQueryRow(query, rowNumber) {
	        var i = 0;
	        var rowData = StructNew();
	        var cols    = ListToArray(query.columnList);
	        for (i = 1; i lte ArrayLen(cols); i = i + 1) {
	            rowData[cols[i]] = query[cols[i]][rowNumber];
	        }
	        return rowData;
	    }
	</cfscript>
		
	<cffunction name="dmp" >
		<cfargument name="x" type="any" required="true" default="">	
		<cfdump var="#x#" output="c:\dump.log">
	</cffunction>
	
	<cffunction name="dmp2" >
		<cfargument name="x" type="any" required="true" default="">	
		<cfdump var="#x#">
	</cffunction>

	
	
</cfcomponent>