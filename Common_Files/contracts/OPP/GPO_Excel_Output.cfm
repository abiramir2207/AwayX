<!---------------------------------------------------------------------------------------------------------------------
Template:	\Common_Files/contracts\OPP\GPO_Excel_Output.cfm
Date:	A6/5/2019
Author:	Mark Saunders
Purpose: Excel Output for GPO Tier program (Fixed Comps) 
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html>
<cfparam name="URL.contractID" default="">

<cfscript>
	oOPP		= CreateObject("component", "mvc.Models.Program.OnePageProgramManager");
	q			= oOPP.getProductsQuery(URL.contractID);
	qTier		= oOPP.getTierDataQuery(URL.contractID);
</cfscript>

<cfquery name="q2" datasource="#application.datasource#">
	 SELECT Distinct
		CM.Contract_Reference_Number AS [Contract ##], 
		CM.Contract_Title AS [Contract Title], 
		convert(varchar, ISNULL(CM.Effective_Start_Date,Contract_Start_Date), 1) AS [Start Date],
		convert(varchar, ISNULL(CM.Effective_End_Date,Contract_End_Date), 1) AS [End Date],
		Item AS [item],
		GTIN AS [CASE UPC],
		Case_Upc AS [PK/SIZE],
		i.Description,
		cast(ISNULL(pld.Price,0) as decimal(14,2)) AS [List Price]
	 FROM Contract_Main CM
	 INNER JOIN Contract_Main_Aux_Data CMAD ON
		CMAD.Contract_Main_Id = CM.Contract_Main_Id
	 INNER JOIN Contract_products CP ON
		CP.Contract_Main_Id = CM.Contract_Main_Id AND
		CP.Deleted = 0
	 INNER JOIN Bsa_Foodservice_Items_Master I ON
		I.Bsa_Foodservice_Items_Master_id = CP.Bsa_Foodservice_Items_Master_id
	 OUTER APPLY(
						SELECT Top 1 PLD2.* from  Price_List_Detail pld2 WHERE
							pld2.Price_List_Header_ID =
								(SELECT TOP 1 Price_List_Header_ID FROM Price_list_Header WHERE GPO_Key Is Null AND Tier = 4) AND 
							pld2.Product_Id = I.BSA_Foodservice_Items_Master_Id AND
							pld2.Deleted = 0 AND
							pld2.Start_Date <= CM.Contract_End_Date AND 
								pld2.END_Date >= CM.Contract_Start_Date
								ORDER BY PLD2.End_DAte DESC) PLD 
	 WHERE CM.Contract_Main_Id = #URL.contractID# 
	 ORDER BY I.Item
</cfquery>

<cfscript>
	//writedump(var='#q2#');
 // writedump(var='#qTier#');
 // abort;

	i=1;
	for (row in q2) {
	   //writedump(var='#row#');
	   for (tier in qTier) {
	   		//writedump(var='#tier#');
	   		tCol = Replace(tier.T,' ','_','ALL');
	   		if(i==1){QueryAddColumn(q2, '#tCol#' , []);}
	   		for (tData in q) {
	   			if(tData.item == row.item){
	   				tierPrice = tData['#tier.PROGRAM_FIXED_COMPONENT_NAME_ID#'];
	   				//writeOutput(' #tier.T# = #tierPrice#  row[#i#]');
	   				QuerySetCell(q2, tCol, tierPrice , i);
	   			}
			}
		}
		//writeOutput('<br>');
		i++;
	}
//writedump(var='#q2#');
	oGenFunc	= CreateObject("component","components.general.General_Functions");
	file_name	= "GPO_Export.xlsx";
	file_path	= "#Application.Doc_Path#\Temp_Files\contracts\#file_name#";
	exportGpo	= SpreadsheetNew("exportGpo",true);

	arrTextCol = ArrayNew(1);
	ArrayAppend(arrTextCol, 1);

	// POPULATE THE SPREADSHEET WITH QUERY DATA
	 oGenFunc.spreadsheetAddRowsForceTextFormat(exportGpo,q2,arrTextCol,false);

	l = 'Contract ##,Contract Title,Start Date,End Date,EAN/UPC,CASE UPC,PK/SIZE,DESCRIPTION,List Price';
	iTierCol = 10;
	for (tier in qTier) {
		s='';
		startTmp = tier.Start;
		endtTmp = tier.End;
		if(isnumeric(tier.Start)){startTmp = NumberFormat(startTmp,'$___,___');}
		if(isnumeric(tier.End)){endtTmp = NumberFormat(tier.End,'$___,___');}
		s = "'#tier.t# #startTmp# - #endtTmp#'";
		l = ListAppend(l,s);
		//SpreadSheetSetColumnWidth(exportGpo, iTierCol, 12);
		//iTierCol++;
	 }

	iRows = q2.recordcount +1;
	SpreadsheetAddRow(exportGpo,"#l#",1,1); 
	SpreadSheetSetRowHeight(exportGpo,1,42);
	//SpreadsheetAddColumn(exportGpo,"Contract_number",1,1,true,'STRING:'); 

	f3={};
	//f3.dataformat="$##,####0.00_);($##,####0.00)";
	f3.font="Verdana"; 
	f3.fontsize="10";
	// f3.textwrap="true"; 
	f3.bottomborder="thin";
	f3.leftborder="thin";
	f3.rightborder="thin";
	f3.topborder="thin";
	SpreadsheetFormatRows(exportGpo,f3,'1-#iRows#');

	f4={};
	f4.dataformat="$##,####0.00_);($##,####0.00)";
	f4.font="Verdana"; 
	f4.fontsize="10";
	f4.textwrap="true"; 
	f4.bottomborder="thin";
	f4.leftborder="thin";
	f4.rightborder="thin";
	f4.topborder="thin";
	SpreadsheetFormatColumns(exportGpo,f4,'9-#listLen(l)#');

	f1={};
	f1.font="Verdana"; 
	f1.color="dark_blue";
	f1.fgColor="GREY_25_PERCENT";
	f1.bold="true";
	f1.fontsize="10";
	f1.textwrap="true"; 
	f1.bottomborder="thin";
	f1.leftborder="thin";
	f1.rightborder="thin";
	f1.topborder="thin";
	SpreadsheetFormatRow(exportGpo,f1,1);

	SpreadSheetSetColumnWidth(exportGpo, 5, 11);
	SpreadSheetSetColumnWidth(exportGpo, 7, 10);

	iTierCol = 10;
	for (tier in qTier) {
		SpreadSheetSetColumnWidth(exportGpo, iTierCol, 15);
		iTierCol++;
	 }

	cfspreadsheet( action="write", fileName=file_path, overwrite=true, name='exportGpo', sheetName='GPO Tier Data', autosize=false );
</cfscript>
<body>


<!--- 	<cfspreadsheet  
		action="write" 
		filename = "#file_path#"
		name = "DistSheet" 
		sheetname="distributors"> --->


<!--- <cfoutput> --->
		<cfheader name="Cache-Control" value="no-cache" >
		<cfheader name="Content-Disposition" value="attachment; filename=#file_name#" >
		<cfcontent type="application/vnd.ms-excel" file="#file_path#">
</body>
</html>

<!---    reference, title, start, end, I.Item, I.Description, B.Brand, TDS.Type_Code_Desc, Q.Q_Brand, TGS.Type_Group_Desc    --->
Contract #,Contract Title,Start Date,End Date,item,PK/SIZE,CASE UPC,Description,List Price
