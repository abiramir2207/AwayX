<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\ajax\listActAdjustment.cfm
      Date:     2014 Jan
      Author:   Chris Nguyen
      Purpose:  aJax processing for volume information apge

      Remarks:  Columns information ( position starts with zero due to javaScript/aJax )
                   0 = 
                   1 = 
                   2 = 
                   3 = 
                   4 = 
                   5 = 
                   6 = 
                   7 = 
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
  <cfparam name="url.iDisplayStart"   default="0">
  <cfparam name="url.iDisplayLength"  default="250">
  <cfparam name="url.sEcho"           default="10">
  <cfparam name="url.iSortCol_0"      default="">
    
  <cfscript>
    variables.reply = {};

    variables.page_size   = val(url.iDisplayLength);
    if ( variables.page_size eq -1) {
      variables.start_row   = 1;
      variables.end_row     = -1;
    }
    else {
      variables.start_row   = url.iDisplayStart + 1;
      variables.end_row     = url.iDisplayStart + variables.page_size;
    }
    url.sSearch = trim(url.sSearch);
    variables.unknown = 'unknown';
    variables.dSearch = ( isDate(url.sSearch) ? dateFormat(parseDateTime(url.sSearch),'short') : variables.unknown );

    // parse search string into an array of words
    if ( len(url.sSearch) ) {
      variables.arrayOfWords = reMatch( "[[:word:]]+", url.sSearch );
    }
    else {
      variables.arrayOfWords = [];
    }   
    // concatenate array of words into a long string delimited by % ( for SQL LIKE condition )
    variables.listOfWords = arrayToList(variables.arrayOfWords, "%");    
  </cfscript>

  <cfoutput>

  <cfquery name="variables.qRows" datasource="#application.datasource#">

	DECLARE   @Display_Item_No BIT
	SET @Display_Item_No = DBO.udf_GetAppSetting('Display_Item_No') 
	
    SELECT PROGRAM_PRODUCT_VOLUME.bsa_FoodService_Items_Master_Id
           ,PROGRAM_PRODUCT_VOLUME.Volume_lb
           ,PROGRAM_PRODUCT_VOLUME.Volume_cs,
		   CASE WHEN @Display_Item_No = '1' THEN
					BSA_FOODSERVICE_ITEMS_MASTER.Item
				ELSE 
					BSA_FOODSERVICE_ITEMS_MASTER.UPC
				END 
				AS Item
           ,BSA_FOODSERVICE_ITEMS_MASTER.Description
           ,BSA_FOODSERVICE_ITEMS_MASTER.Net_Weight
           ,CAST((PROGRAM_PRODUCT_VOLUME.Volume_CS * CAST(#url.Contract_Span# as decimal(20, 4)) / 7.00) as Decimal(20, 0)) as Program_Volume_CS
           ,CAST(CAST((PROGRAM_PRODUCT_VOLUME.Volume_LB * CAST(#url.Contract_Span# as decimal(20, 4)) / 7.00) as Decimal(20, 2)) as Decimal(20, 0)) as Program_Volume_LB
      FROM PROGRAM_PRODUCT_VOLUME
           INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER ON BSA_FOODSERVICE_ITEMS_MASTER.bsa_FoodService_Items_Master_Id = PROGRAM_PRODUCT_VOLUME.bsa_FoodService_Items_Master_Id
     WHERE PROGRAM_PRODUCT_VOLUME.Deleted = 0
           AND PROGRAM_PRODUCT_VOLUME.Program_Id = <cfoutput>#url.program_ID#</cfoutput>
           AND Len( PROGRAM_PRODUCT_VOLUME.Volume_lb ) > 0
           AND PROGRAM_PRODUCT_VOLUME.Is_Group = 0
           AND EXISTS ( SELECT 1
                          FROM CONTRACT_PRODUCTS cp
                         WHERE cp.Contract_Main_Id = PROGRAM_PRODUCT_VOLUME.Program_Id
                               AND cp.Deleted = 0
                               AND cp.bsa_FoodService_Items_Master_Id = PROGRAM_PRODUCT_VOLUME.bsa_FoodService_Items_Master_Id )
             <cfif len(url.sSearch)>
                AND (    BSA_FOODSERVICE_ITEMS_MASTER.Item LIKE '%#variables.listOfWords#%'
                      OR BSA_FOODSERVICE_ITEMS_MASTER.Description LIKE '%#variables.listOfWords#%'
                    )
             </cfif>
   <cfswitch expression="#url.iSortCol_0#">
     <cfcase value='0'> ORDER BY BSA_FOODSERVICE_ITEMS_MASTER.Item #url.sSortDir_0# </cfcase>
     <cfcase value='1'> ORDER BY BSA_FOODSERVICE_ITEMS_MASTER.Description #url.sSortDir_0# </cfcase>
     <cfdefaultcase>    ORDER BY BSA_FOODSERVICE_ITEMS_MASTER.Item </cfdefaultcase>
   </cfswitch>
  </cfquery>
  </cfoutput>

  <!---get total number of records BEFORE filtering--->
  <cfif len(url.sSearch) eq 0>
    <!--- no filtering so grap the count from existing query --->
    <cfset variables.reply.iTotalRecords = variables.qRows.recordCount>
  <cfelse>
    <cfquery name="variables.totalBeforeFilter" datasource="#application.datasource#">
          SELECT COUNT(1) AS rownbr
            FROM PROGRAM_PRODUCT_VOLUME
                 INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER ON BSA_FOODSERVICE_ITEMS_MASTER.bsa_FoodService_Items_Master_Id = PROGRAM_PRODUCT_VOLUME.bsa_FoodService_Items_Master_Id
           WHERE PROGRAM_PRODUCT_VOLUME.Deleted = 0
                 AND PROGRAM_PRODUCT_VOLUME.Program_Id = <cfoutput>#url.program_ID#</cfoutput>
                 AND Len( PROGRAM_PRODUCT_VOLUME.Volume_lb ) > 0
                 AND PROGRAM_PRODUCT_VOLUME.Is_Group = 0
                 AND EXISTS ( SELECT 1
                                FROM CONTRACT_PRODUCTS cp
                               WHERE cp.Contract_Main_Id = PROGRAM_PRODUCT_VOLUME.Program_Id
                                     AND cp.Deleted = 0
                                     AND cp.bsa_FoodService_Items_Master_Id = PROGRAM_PRODUCT_VOLUME.bsa_FoodService_Items_Master_Id )
    </cfquery>
    <cfset variables.reply.iTotalRecords = variables.totalBeforeFilter.rownbr>
  </cfif>
  <cfset variables.reply.iTotalDisplayRecords = variables.qRows.recordCount>

  <!--- Generate JSON from Query --->
  <cfset variables.reply.aaData = [] >
  <cfif variables.end_row eq -1>
    <cfset variables.start_row = 1>
    <cfset variables.end_row   = variables.qRows.recordCount>
  <cfelse>
    <cfset variables.end_row   = min(variables.end_row, variables.qRows.recordCount)>
  </cfif>

  <CFSET objVolumeApplicator = CreateObject("component", "components.volume.VolumeApplicator")>

  <cfscript>
    variables.totalAnnualvolumeCS = 0;
    variables.totalAnnualvolumeLB = 0;

    variables.totalUOTVolumeCS = 0;
    variables.totalUOTVolumeLB = 0;
  </cfscript> 

  <cfloop query="variables.qRows" startRow="#variables.start_row#" endRow="#variables.end_row#">
    <cfscript>
       variables.AnnualvolumeCS = objVolumeApplicator.RoundVolume((variables.qRows.Volume_CS / 7) * 365);
       variables.AnnualvolumeLB = objVolumeApplicator.RoundVolume((variables.qRows.Volume_LB / 7) * 365);

       variables.UOTVolumeCS = objVolumeApplicator.RoundVolume(variables.qRows.Program_Volume_CS);
       variables.UOTVolumeLB = objVolumeApplicator.RoundVolume(variables.qRows.Program_Volume_LB);

       variables.totalAnnualvolumeCS += variables.AnnualvolumeCS;
       variables.totalAnnualvolumeLB += variables.AnnualvolumeLB;

       variables.totalUOTVolumeCS += variables.UOTVolumeCS;
       variables.totalUOTVolumeLB += variables.UOTVolumeLB;

       dArrayTmp = [];
       arrayAppend(dArrayTmp, variables.qRows.item);
       arrayAppend(dArrayTmp, variables.qRows.Description & (listFindNoCase(url.bidLostItems, variables.qRows.bsa_FoodService_Items_Master_Id) ? " *" : ""));
       arrayAppend(dArrayTmp, objVolumeApplicator.FormatVolume(variables.AnnualvolumeCS));
       arrayAppend(dArrayTmp, objVolumeApplicator.FormatVolume(variables.AnnualvolumeLB));

       arrayAppend(dArrayTmp, objVolumeApplicator.FormatVolume(variables.UOTVolumeCS));
       arrayAppend(dArrayTmp, objVolumeApplicator.FormatVolume(variables.UOTVolumeLB));

       arrayAppend(variables.reply.aaData, dArrayTmp);        
    </cfscript>
  </cfloop>

  <!--- there are more rows in the query than what is displayed on the screen or current page is not page 1 so recalculate totals of all rows --->
  <cfif variables.qRows.recordCount gt variables.end_row or variables.start_row gt 1>
    <cfscript>
      variables.totalAnnualvolumeCS = 0;
      variables.totalAnnualvolumeLB = 0;

      variables.totalUOTVolumeCS = 0;
      variables.totalUOTVolumeLB = 0;
    </cfscript> 

    <cfloop query="variables.qRows">
      <cfscript>
         variables.AnnualvolumeCS = objVolumeApplicator.RoundVolume((variables.qRows.Volume_CS / 7) * 365);
         variables.AnnualvolumeLB = objVolumeApplicator.RoundVolume((variables.qRows.Volume_LB / 7) * 365);

         variables.UOTVolumeCS = objVolumeApplicator.RoundVolume(variables.qRows.Program_Volume_CS);
         variables.UOTVolumeLB = objVolumeApplicator.RoundVolume(variables.qRows.Program_Volume_LB);

         variables.totalAnnualvolumeCS += variables.AnnualvolumeCS;
         variables.totalAnnualvolumeLB += variables.AnnualvolumeLB;

         variables.totalUOTVolumeCS += variables.UOTVolumeCS;
         variables.totalUOTVolumeLB += variables.UOTVolumeLB;
      </cfscript>
    </cfloop>
  </cfif>

  <cfscript>
    variables.reply.sEcho  = javacast('int', url.sEcho);

    variables.reply.totalAnnualvolumeCS = objVolumeApplicator.FormatVolume(variables.totalAnnualvolumeCS);
    variables.reply.totalAnnualvolumeLB = objVolumeApplicator.FormatVolume(variables.totalAnnualvolumeLB);

    variables.reply.totalUOTVolumeCS = objVolumeApplicator.FormatVolume(variables.totalUOTVolumeCS);
    variables.reply.totalUOTVolumeLB = objVolumeApplicator.FormatVolume(variables.totalUOTVolumeLB);

    variables.sOut = SerializeJSON( variables.reply );

    // Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way
    variables.sOut = Replace (variables.sOut, 'SECHO', 'sEcho', 'one');
    variables.sOut = Replace (variables.sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one');
    variables.sOut = Replace (variables.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one');
    variables.sOut = Replace (variables.sOut, 'AADATA', 'aaData', 'one');
  </cfscript>
</cfsilent>

<!---send JSON data back to client--->
<cfoutput>#variables.sOut#</cfoutput>
</cfprocessingdirective>















