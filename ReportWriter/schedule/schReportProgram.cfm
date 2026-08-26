<CFSET rStatus=-1>
<CFSET rProgramTypes="-1">
<CFSET rFilter="zone">
<CFSET rZones="">
<CFSET rRegions="">
<CFSET rBrokers="">
<CFSET rSortBy="status,programtype">

<CFSET rFilterItems="typegroup">

<CFSET rTypeGroups="">
<CFSET rQBrands="">
<CFSET rTypeCodes="">
<CFSET rBrands="">

<CFSET rReportOutputType="h">
<CFSET rColumnHeaderID=programColumnHeaderID>

<CFSET rEmailAddress="">


	<CFLOOP QUERY="q_getReportStructure">
		<CFSET Evaluate("#Report_Structure#=""#Report_Structure_Value#""")>
	</CFLOOP>
	
	<CFIF isDefined("rFilterValue") AND isDefined("rFilter")>
		<CFSET Evaluate("r#rFilter#s=""#rFilterValue#""")>
	</CFIF>
	
	<CFSET rEmailAddress=q_getReportDetails.Report_EmailAddress>
	
	
	
	

	<!--------------------Generate groupList like status,p---->
	<cfset sGroupByList="">
	<cfif Len(rSortBy) GT 0>
		<cfloop index="i" list="#rSortBy#" delimiters=",">
			<cfif i NEQ "-1">
			<cfif NOT ListFindNoCase(sGroupByList, i,",")>				
				<cfset sGroupByList=ListAppend(sGroupByList,i,",")>
			</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<!--------------------End Generate groupList like status,p---->
	<!--------------------Add zone/region/broker to groupList---->
	<cfif Len(sGroupByList) GT 0>	
		<cfset sGroupByList=ListInsertAt(sGroupByList, 1,"#rFilter#",",")>
	<cfelse>
		<cfset sGroupByList="#rFilter#">
	</cfif>
	<!--------------------End Add zone/region/broker to groupList---->
	
	
	<!-------------Find field name corresponding to fFilter--------------------------------->
	<cfset sFilterField="">
	<cfswitch expression="#rFilter#">
		<cfcase value="zone">
			<cfset sFilterField="sz.Zone_Name">
		</cfcase>
		<cfcase value="region">
			<cfset sFilterField="sr.Region_Name">
		</cfcase>						
		<cfcase value="broker">
			<cfset sFilterField="bla.Broker_Name">
		</cfcase>
	</cfswitch>
	<!-------------End Find field name corresponding to fFilter--------------------------------->
	
	<!--------------------Make exact group By clause 'sGroupBy' from groupList---->
	<cfset sGroupBy=sGroupByList>
	
	
	
	<cfset iIndex=ListFindNoCase(sGroupBy, "status",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "cs.Contract_Status_Type_Desc",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "programtype",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, "pt.Created_Type",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "zone",",")>	
	<cfif iIndex GT 0>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!----Zone/Region/Broker--------->
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "region",",")>	
	<cfif iIndex GT 0>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!----Zone/Region/Broker--------->
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupBy, "broker",",")>	
	<cfif iIndex GT 0>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!----Zone/Region/Broker--------->
		<cfset sGroupBy=ListSetAt(sGroupBy, iIndex, sFilterField,",")>
	</cfif>
	
	<!----
	<cfset sHeaderIDList=sGroupByList>
	<cfset sHeaderNameList=sGroupBy>	
	----->
	<cfset sHeaderIDList="">
	<cfset sHeaderNameList="">
	

	<cfif Len(sGroupBy) GT 0>	
		<cfset sGroupBy="Order By #sGroupBy#">
	</cfif>
	<!--------------------End Make exact group By clause 'sGroupBy' from groupList---->
	
	<!--------------------Make group By fields 'sGroupFieldList' from groupList---->
	<cfset sGroupFieldList=sGroupByList>
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "status",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, "Contract_Status_Type_Desc",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "programtype",",")>	
	<cfif iIndex GT 0>
		<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, "Created_Type",",")>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "zone",",")>	
	<cfif iIndex GT 0>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!-------Get the fieldname part from it ('broker_name' from 'b.broker_name')----->
		<!----Zone/Region/Broker--------->
		<cfif ListLen(sFilterField,".") GT 1>
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, ListGetAt(sFilterField,2,"."),",")>
		<cfelse>
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, sFilterField,",")>
		</cfif>
	</cfif>
	
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "region",",")>	
	<cfif iIndex GT 0>		
		<cfif ListLen(sFilterField,".") GT 1>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!-------Get the fieldname part from it ('broker_name' from 'b.broker_name')----->
		<!----Zone/Region/Broker--------->
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, ListGetAt(sFilterField,2,"."),",")>
		<cfelse>
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, sFilterField,",")>
		</cfif>
	</cfif>
	<cfset iIndex=ListFindNoCase(sGroupFieldList, "broker",",")>	
	<cfif iIndex GT 0>
		<cfif ListLen(sFilterField,".") GT 1>
		<!----sFilterField is the specific field corresponding to rFilter --------->
		<!-------Get the fieldname part from it ('broker_name' from 'b.broker_name')----->
		<!----Zone/Region/Broker--------->
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, ListGetAt(sFilterField,2,"."),",")>
		<cfelse>
			<cfset sGroupFieldList=ListSetAt(sGroupFieldList, iIndex, sFilterField,",")>
		</cfif>
	</cfif>
	<!--------------------End Make group By fields 'sGroupFieldList' from groupList---->
	
	
	<!--------------Populate sHeaderIDList and sHeaderNameList --------------------------------->
	<!-----	
	sHeaderIDList and sHeaderNameList already have the groupsBy Columns
	<cfset sHeaderIDList=sGroupByList>
	<cfset sHeaderNameList=sGroupBy>
	--->
	<cfloop index="i" list="#rColumnHeaderID#" delimiters=",">
		<cfif NOT ListFindNoCase(sGroupByList,i,",")>
			<cfset iIndex=ListFindNoCase(programColumnHeaderID,i,",")>
			<cfif iIndex>
				<cfset sHeaderIDList=ListAppend(sHeaderIDList,ListGetAt(programColumnHeaderID,iIndex,","))>
				<cfset sHeaderNameList=ListAppend(sHeaderNameList,ListGetAt(programColumnFields,iIndex,","))>
			</cfif>
		</cfif>
	</cfloop>
	
	<!--------------End Populate sHeaderIDList and sHeaderNameList ---------------------------------->
	
	<cfset sSelect="cs.Contract_Status_Type_Desc,pt.Created_Type,cm.Contract_Number,cm.Contract_Title,cm.Contract_Start_Date,cm.Contract_End_Date,cm.Contract_Main_ID">	

		
	<cfif Len(sFilterField) GT 0>
		<cfif NOT ListFindNoCase(sSelect,sFilterField,",")>
			<cfset sSelect=ListAppend(sSelect,sFilterField,",")>
		</cfif>
		<!----<cfset sSelect="#sSelect#,#sFilterField#">---->
	</cfif>	
	
	<!--------------Check whether all user selected column headers are there in select list----------------->
	<cfloop index="i" list="#sHeaderNameList#" delimiters=",">
		<cfif NOT ListFindNoCase(sSelect,i,",")>
			<cfset sSelect=ListAppend(sSelect,i,",")>
		</cfif>
	</cfloop>
	<!--------------End Check whether all user selected column headers are there in select list----------------->
	
	<!----------------Remove "tablename." from column header lsit------------------>
	<cfloop index="i" list="#sHeaderNameList#" delimiters=",">	
		<cfif ListLen(i,".") GT 1>
			<cfset sHeaderNameList=ListSetAt(sHeaderNameList, ListFindNoCase(sHeaderNameList,i,","), ListGetAt(i,2,"."),",")>			
		</cfif>
	</cfloop>
	<!----------------End Remove "tablename." from column header lsit------------------>
	
	
	<!---<cfoutput>#sHeaderNameList#<br>#sHeaderIDList#</cfoutput>
	<cfabort>--->
	<cfset sSelect="Select #sSelect#">
	
	<cfset DescSeparator=", ">
	<cfinclude template="schReportDescription.cfm">	
	
	<cfswitch expression="#rFilter#">
		<cfcase value="zone">
			<CFQUERY NAME="q_getReport" datasource="#application.datasource#">			
				#sSelect#
				From	
				broker_lob_active bla,
				Contract_Brokers cb,
				Contract_Main cm,				
				Contract_Status_Types cs,
				Program_Control_Panel_Options pt,
				Service_Zones sz,
				Units_of_Measure uom
				Where	bla.BSA_Foodservice_Brokers_ID = cb.BSA_Foodservice_Brokers_ID
				and		cb.Contract_Main_ID=cm.Contract_Main_ID
				and		cs.Contract_Status_Type_ID=cm.Contract_Status_Type_IDX
				and		pt.ProgramControl_Panel_Options_ID=cm.ProgramType_ID
				and		bla.Service_Zone_ID=sz.Service_Zone_ID
				and		cb.Deleted=0
				and		cm.Deleted=0
				and		uom.Unit_Of_Measure_ID=cm.Contract_Quantity_UOM_IDX
				<cfif rZones NEQ "-1">
				and		sz.Service_Zone_ID='#rZones#'
				</cfif>
				<cfif NOT ListFindNoCase(rStatus,"-1",",")>
				and		cs.Contract_Status_Type_ID in (#rStatus#)
				</cfif>
				<cfif NOT ListFindNoCase(rProgramTypes,"-1",",")>
				and		pt.ProgramControl_Panel_Options_ID in (#rProgramTypes#)
				</cfif>				
				#sGroupBy#
			</CFQUERY>
			<cfset srqueryname="q_getReport">
			<cfinclude template="schSendProgramReport.cfm">
		</cfcase>
 		<cfcase value="region">
			<CFQUERY NAME="q_getReport" datasource="#application.datasource#">
				#sSelect#
				From	
				broker_lob_active bla,
				Contract_Brokers cb,
				Contract_Main cm,
				Contract_Status_Types cs,
				Program_Control_Panel_Options pt,
				Service_Regions sr,
				Units_of_Measure uom
				Where	bla.BSA_Foodservice_Brokers_ID = cb.BSA_Foodservice_Brokers_ID
				and		cb.Contract_Main_ID=cm.Contract_Main_ID
				and		cs.Contract_Status_Type_ID=cm.Contract_Status_Type_IDX
				and		pt.ProgramControl_Panel_Options_ID=cm.ProgramType_ID
				and		bla.Service_Region_ID=sr.Service_Region_ID
				and		cb.Deleted=0
				and		cm.Deleted=0
				and		uom.Unit_Of_Measure_ID=cm.Contract_Quantity_UOM_IDX
				<cfif rRegions NEQ "-1">
				and		sr.Service_Region_ID='#rRegions#'
				</cfif>
				<cfif NOT ListFindNoCase(rStatus,"-1",",")>
				and		cs.Contract_Status_Type_ID in (#rStatus#)
				</cfif>
				<cfif NOT ListFindNoCase(rProgramTypes,"-1",",")>
				and		pt.ProgramControl_Panel_Options_ID in (#rProgramTypes#)
				</cfif>
				#sGroupBy#
			</CFQUERY>
			<cfset srqueryname="q_getReport">
			<cfinclude template="schSendProgramReport.cfm">
		</cfcase>
		<cfcase value="broker">
			<CFQUERY NAME="q_getReport" datasource="#application.datasource#">
				#sSelect#
				From	
				broker_lob_active bla,
				Contract_Brokers cb,
				Contract_Main cm,
				Contract_Status_Types cs,
				Program_Control_Panel_Options pt,
				Units_of_Measure uom
				Where	bla.BSA_Foodservice_Brokers_ID = cb.BSA_Foodservice_Brokers_ID
				and		cb.Contract_Main_ID=cm.Contract_Main_ID
				and		cs.Contract_Status_Type_ID=cm.Contract_Status_Type_IDX
				and		pt.ProgramControl_Panel_Options_ID=cm.ProgramType_ID
				and		cb.Deleted=0
				and		cm.Deleted=0
				and		uom.Unit_Of_Measure_ID=cm.Contract_Quantity_UOM_IDX
				<cfif rBrokers NEQ "-1">
				and		bla.BSA_Foodservice_Brokers_ID='#rBrokers#'
				</cfif>
				<cfif NOT ListFindNoCase(rStatus,"-1",",")>
				and		cs.Contract_Status_Type_ID in (#rStatus#)
				</cfif>
				<cfif NOT ListFindNoCase(rProgramTypes,"-1",",")>
				and		pt.ProgramControl_Panel_Options_ID in (#rProgramTypes#)
				</cfif>
				#sGroupBy#
			</CFQUERY>
			<cfset srqueryname="q_getReport">
			<cfinclude template="schSendProgramReport.cfm">
		</cfcase>
		<cfdefaultcase>
		errror
		</cfdefaultcase>
	</cfswitch>


<!-----<cfmail to = "dkunnath@awayx.com"
      from = "deepa_kunnathu@hotmail.com"
      subject = "schedule test"
	  server = "smtp.awayx.com">
	  This is a test from schReport444 program on #Now()#.
	  rID is #rID#
	  Report type is #reportType#
	  Query Ran
	  Should send report
	  rReportOutputType - #rReportOutputType#
</cfmail>------->