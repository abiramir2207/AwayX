<!----
	Filename:	Bid_Info_Search_Qry.cfm
	Created:	4/8/2013
 	Developer:	Milan        
             
	Description: USED TO MAKE AJAX CALLS TO DB FOR ITEMS (BID)
---->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
  <cfparam name="url.iDisplayStart"   default="0">
  <cfparam name="url.iDisplayLength"  default="100">
  <cfparam name="url.sEcho"           default="10">
  <cfparam name="url.iSortCol_0"	default="">
  <cfparam name="url.sSortDir_0"	default="">

  <cfscript>
    tmp   = {};
    reply = {};
    
    tmp.page_size   = val(url.iDisplayLength);
    if ( tmp.page_size eq -1) {
	    tmp.start_row   = 1;
	    tmp.end_row     = -1;
    }
    else {
	    tmp.start_row   = url.iDisplayStart + 1;
	    tmp.end_row     = url.iDisplayStart + tmp.page_size;
	  }
  </cfscript>

	<cfoutput>

<!--- get the items. --->
<cfinvoke component="components.programs.bid_request.CompetitiveDataManager" method="getProgramCompetitiveProductData" returnVariable="items_info">
   <cfinvokeargument name="programID" value="#trim(URL.Contract_Main_ID)#">
   <!--- "bidInfoPage" means this "bid_info.cfm", which calls this page. --->
   <cfinvokeargument name="source" value="bidInfoPage">
   <!--- search keyword used on the AJAX grid. --->
   <cfinvokeargument name="searchCriteria" value="#url.sSearch#">
   <!--- on the AJAX grid, 0 is for the first column, 1 is for the second column and so on. --->
   <cfinvokeargument name="sortColumnNumber" value="#url.iSortCol_0#">
   <!---  ascending or descending. --->
   <cfinvokeargument name="sortColumnOrder" value="#url.sSortDir_0#">
   <!--- get records from the db starting from start_row (record number based on incremental integer). --->
   <cfinvokeargument name="startRow" value="#tmp.start_row#">
   <!--- get records from the db ending at from end_row (record number based on incremental integer). --->
   <cfinvokeargument name="endRow" value="#tmp.end_row#">
</cfinvoke>

  </cfoutput>
  
  <!--- total number of records BEFORE filtering --->
  <cfset reply.iTotalRecords        = items_info.TotalRecordCount>

  <!--- total number of records AFTER filtering --->
  <cfset reply.iTotalDisplayRecords = items_info.TotalDisplayCount>

  <!--- Generate JSON from Query --->
  <cfset reply.aaData = [] >

  <cfquery name="GetContractInfo" datasource="#application.datasource#">
    SELECT 
		Program_Control_Panel_Options.Created_Type as CreatedType,
		Program_Control_Panel_Options.Include_Competitive_Data_Tracking, 
		Program_Control_Panel_Options.Display_Bid_Info_Page, 
		Program_Control_Panel_Options.Line_Number, 		
		Program_Control_Panel_Options.*,Contract_Main.*
    FROM Contract_Main
    INNER JOIN Program_Control_Panel_Options
            ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
    WHERE Contract_Main_ID = '#URL.Contract_Main_ID#'
    and Program_Control_Panel_Options.deleted = 0
</cfquery>
  
  <cfoutput>

  <cfloop query="items_info">
	
    <!--- The code inside "cfsavecontent" code existed on "bid_Info.cfm". Since the functionality has been modified to make AJAX server calls, the code was removed 
    from there and added here, instead.
    --->
    <cfsavecontent variable ="varList">

    	<cfif GetContractInfo.Display_Bid_Info_Page EQ 1 AND GetContractInfo.Line_Number EQ 1>		
		<input type="text" name="#trim(items_info.item)#_#Replace(items_info.BSA_Foodservice_Items_Master_ID,'-','_','ALL')#_line_number" 
			id="#trim(items_info.item)#_#Replace(items_info.BSA_Foodservice_Items_Master_ID,'-','_','ALL')#_line_number"
			value="#items_info.Line_Number#"  size = "5" maxlength="8" onChange="parent.addProductListNumber(this)"		
			/>
	</cfif>

	<!---<input type="hidden" name= "ItemMasterID" value="#items_info.BSA_Foodservice_Items_Master_ID#" />--->
	<!--- "start_row" and "end_row" need to be included once only --->
	<cfif items_info.recordcount eq items_info.currentrow>
	<input type="hidden" name= "start_row" value="#tmp.start_row#" />
	<input type="hidden" name= "end_row" value="#tmp.end_row#" />
	</cfif>

    </cfsavecontent>

    <cfscript>
    dArrayTmp = [];
       arrayAppend(dArrayTmp, items_info.Item);
       arrayAppend(dArrayTmp, items_info.Group_Desc);
       arrayAppend(dArrayTmp, items_info.Description);
       arrayAppend(dArrayTmp, varList);

       arrayAppend(reply.aaData, dArrayTmp);
    </cfscript>
  </cfloop>
	
</cfoutput>     


  <cfset reply.sEcho  = javacast('int', url.sEcho)>
  <cfset tmp.sOut = SerializeJSON( reply )>

  <!--- Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way --->
  <cfset tmp.sOut = Replace (tmp.sOut, 'SECHO', 'sEcho', 'one')>
  <cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one')>
  <cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one')>
  <cfset tmp.sOut = Replace (tmp.sOut, 'AADATA', 'aaData', 'one')>
</cfsilent>

<!---send JSON data back to client--->
<cfoutput>#tmp.sOut#</cfoutput>
</cfprocessingdirective>