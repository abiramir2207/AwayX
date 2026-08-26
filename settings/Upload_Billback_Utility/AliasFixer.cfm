<!-----------------------------------------------------------------------------

FILE NAME:		AliasFixer.cfm
DESCRIPTION:	This is the landing screen for the user when they encounter an 
				issue with the uploaded file and need to fix the Aliases
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	08-Jul-2014	Added check number and 
							 

------------------------------------------------------------------------------> 

<cfparam name="submitted" default="0">
<cfparam name="URL.UploadID" default="0">
<cfparam name="URL.OCRUploadID" default="0">
<cfparam name="FORM.Distributor_List" default=""/>
<cfparam name="FORM.CurrentImgClick" default="" />
<cfparam name="FORM.Operator_List" default=""/>
<cfparam name="FORM.Product_List" default="" />
<cfparam name="FORM.ProductListToExcludeFromSelecting" default="" />
<cfparam name="FORM.ExistingProductList" default="" />
<cfset Upload_ID = URL.UploadID />

<html>
<head>
	<title>Alias Fixer</title>
 
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<script>
function showSearchWindow(URLtoOpen,CurrentImgClick)
{
	document.DataForm.CurrentImgClick.value = CurrentImgClick;
	document.DataForm.Distributor_List.value="";
	document.DataForm.Product_List.value="";
	document.DataForm.Operator_List.value="";
	window.open(URLtoOpen, "searchform", "height=800,width=600,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=no,location=no");
}

function doUnload()
{
 var txt;
    var r = confirm("This will abort the upload! Are you sure you want to close?");
    if (r == true) {
        window.close();
    } else {
		window.event.returnvalue=false;
    //    return false;
    }
}

function clearRows()
{
	/* event.altKey When press Alt +F4, event.ctrlKey When press Ctrl +F4, event.clientY 107 or 129 is  Alt F4 postion on window 
	screen it may change base on screen resolution */
	if ((event.clientY < 0) ||(event.altKey) ||(event.ctrlKey)||((event.clientY < 129) && (event.clientY>107)))
	{
		// open a popup window to delete the rows when the window is closed abruptly
		window.open("deleteTableRows.cfm?upload_ID=<cfoutput>#Upload_ID#&OCRUploadID=#URL.OCRUploadID#</cfoutput>" , "Deleteing","location=0,status=0,scrollbars=1,resizable=1, width=5,height=5");
	}
}

function disableSubmit()
{
 	document.getElementById("validate2").style.display = 'none';
	document.getElementById("validate1").style.display = 'none';
	document.getElementById("dummyVal1").style.display = 'block';
	document.getElementById("dummyVal2").style.display = 'block';
}

function close_window()
{
/* For chrome, we use the code id "/script/javascript/nonIE.js" for window.showModalDialog().
So, we need to use different logic to close the window.
*/
<cfif findNoCase("Chrome", CGI.HTTP_User_Agent)>
window.parent.parent.document.getElementsByTagName('dialog')[0].close(); 
/* we can also use this code to close the modal window, instead of the one above */
//window.parent.parent.document.getElementById('dialog-close').click();
<cfelse>
window.close()
</cfif>
}
</script>
</head>

<!--- <body onunload="doUnload();"> --->
<body onunload="javascript:clearRows();">
<cfoutput>
 
<table border="0" cellpadding="2" cellspacing="0" width="100%">
<tr>
	<td align="left" bgcolor="##A7CAF2" width="100%" height="25" style="background-image: url(/Images/gradient.jpg); background-repeat:no-repeat;"><span style="color:white; font-size:14px; font-weight: bold; padding-left:5px;">ALIAS FIXER</SPAN></TD>
</tr>
</table>

<br>
<form action="AliasFixer.cfm?UploadID=#Upload_ID#&OCRUploadID=#URL.OCRUploadID#" method="post" name="DataForm" id="DataForm" style="DISPLAY:INLINE" target="_self">
<!--- 
-	From application; insert the file name into both header and detail fields with user id into BB_upload_log. 
-	Update the status BB_upload_Log.Upload_status = 'File received' 
-	Don't restrict the file size.
-	Create "#BB_Single_File_BLK_INS" temp table. Transfer file to DB server.
-	Update BB_upload_Log.Upload_status = 'Trasferring file data to DB'
-	Call the routine 1
 --->
	
	<!--- 
			47734: User uploaded BB with Alias is creating duplicates/Anand Rao/23-Feb-2014
			Drop and recreate the temp tables as they were getting data from another session
	--->
 	
	<cfquery name="Create_Data_Table" datasource="#application.datasource#">
		IF object_id('tempdb..##BB_New_Single_File_BLK_INS') IS NOT NULL
			BEGIN	 
                 DROP TABLE ##BB_New_Single_File_BLK_INS
			END

            CREATE TABLE ##BB_New_Single_File_BLK_INS(
				[Source] [varchar](max), 
				[Vendor_Number] [varchar](max),
				[Program_Number] [varchar](max),
				[Customer_Reference] [varchar](max),
				--[Total_Dollar_Amount] [varchar](max),
				[Payee_Type] [varchar](max),
				[Distributor_ID] [varchar](max),
				[Operator_ID] [varchar](max),
				[Closing_Method] [varchar](max),
				[Billback_Date] [varchar](max),
				[BB_Start_Date] [varchar](max),
				[BB_End_Date] [varchar](max),
				[Item_Number] [varchar](max),
				[Item_Volume_Qty] [varchar](max),
				[Item_Dollar_Amount] [varchar](max),
				[Associated_Distributor_ID] [varchar](max),
				[UOM] [varchar](max),
				[Trade_Indicator] [varchar](max),
				[Lump_Sum_Indicator] [varchar](max),
				[File_Name] [varchar](max),
				[Component_Name] [varchar](max),
				[Unknown] [varchar](max),                             
				[Upload_File_Name] [varchar](max),
				[Cust_Desc] [VARCHAR](max),
				[Address] [VARCHAR](max),
				[State] [VARCHAR](max)
				)
			 
 	 	IF object_id('tempdb..##BB_Unmapped_Alias_List') IS NOT NULL
			BEGIN	 
	        	DROP TABLE ##BB_Unmapped_Alias_List
			END
						  
		CREATE TABLE ##BB_Unmapped_Alias_List(
				Upload_ID INT,
				Alias_Type INT, /* 1 = Distributor, 2 = Operator, 3 = Item */
				Source_Code VARCHAR(255),
				BB_Claim_Source_XREF_ID INT,
				BB_Claim_Alias_XREF_ID INT,
				External_Code VARCHAR(255),
				External_Description VARCHAR(255),
				BA_ID VARCHAR(255),
				BA_Desc VARCHAR(255),
				Unknown BIT
			)	
	 </cfquery>  
	<!--- 
		47734: User uploaded BB with Alias is creating duplicates/Anand Rao/23-Feb-2014
		Call the SP for the first time to populate the values in the temp table #BB_Unmapped_Alias_List
	--->  
 	<cfstoredproc datasource="#application.datasource#" procedure="Upload_Single_File_Alias_Validate">
		<cfprocparam type="IN"  variable="@Uploaded_Single_File"	value="" cfsqltype="CF_SQL_VARCHAR">
		<cfprocparam type="IN"  variable="@Upload_ID"	value="#Upload_ID#" cfsqltype="CF_SQL_INTEGER">
		<cfprocparam type="IN"  variable="@Process_Type" value="2" cfsqltype="CF_SQL_INTEGER"> 	
		<cfprocresult name = "UploadSingleFileResult2" > <!--- Original result set that returns status etc --->
 	</cfstoredproc>
	 
	<cfquery name="chkUnmappedAliasList" datasource="#application.datasource#">
		SELECT * FROM ##BB_Unmapped_Alias_List order by Alias_Type
	</cfquery>
	
 	<cfscript> 
		stData = structNew();
		stError = structNew();
		stData["__type__"] = "mvc.Models.Admin.Alias.vos.AliasDef";
		AliasMgr = createObject("component","mvc.Models.Admin.Alias.AliasManager");		
		strError = "";
		isError  = "";
	</cfscript>	
 
	<cfif isDefined("FORM.submitted") AND FORM.submitted EQ 1>
		<cfloop query ="chkUnmappedAliasList">
			<cfset strError = "" />
			<!--- Dev Note (70533) - Added the following condition:
			AND "#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#" NEQ FORM.CurrentImgClick
			Note: The above condition was important due to following reason:
			Before this change, when a user imported an item from the popup for alias fixer, below code was getting called
			and it would return "Invalid Item ID". The reason was that the below code was called even before the textbox with the item
			was populated. The condition will make sure that the imported item is not sent for validation. Once the user imports a second item, then
			the first imported item can be sent for validation. The user can also click on "Validate" buttin to do validation.
			It is also important to use <cfset FORM.CurrentImgClick = ""> (Search for "70533" in this file). This way we do not prevent the item's
			validation after a item in imported. For eg: A user can put the cursor on the textbox and press enter. This would validate as well.
			--->
			<cfif isDefined("FORM.BA_ID_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#") AND "#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#" NEQ FORM.CurrentImgClick>
			<!--- 
				1. Build the Structure for passing into the existing functions.
				2. Check the Type of the Alias
				3. Call the appropriate function to update the alias
			--->
			<!--- 			
			 	Entity Types: 
				 	0 = Distributor
					1 = Item
					2 = Program	 
					3 = Operator
	 		--->
				<cfset useLakebaseForBBClaimSourceXREFDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_claim_source_xref")>
<cfif useLakebaseForBBClaimSourceXREFDetails>
	<cftry>
		<cfset BBClaimSourceXREFDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_claim_source_xref", {
				"bb_claim_source_xref_id" = "eq.#chkUnmappedAliasList.BB_Claim_Source_XREF_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBBClaimSourceXREFDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBBClaimSourceXREFDetails>
<cfquery name="BBClaimSourceXREFDetails" datasource="#application.datasource#">
					SELECT * FROM BB_Claim_Source_XREF WHERE BB_Claim_Source_XREF_ID = #chkUnmappedAliasList.BB_Claim_Source_XREF_ID# 	
				</cfquery>
</cfif>
								 
				<cfif (chkUnmappedAliasList.Alias_Type EQ 0)>
					<!--- 0 = Distributor --->
					<cfscript>
						stData["entityType"] 	 = 0;
						stData["sourceType"] 	 = BBClaimSourceXREFDetails.Source_Type;
						stData["sourceTypeDesc"] = BBClaimSourceXREFDetails.Source_Type_Description;
						stData["sourceID"] 	 	 = chkUnmappedAliasList.Source_Code;
						stData["recordID"] 		 = chkUnmappedAliasList.BB_Claim_Alias_XREF_ID;
						stData["aliasID"] 		 = chkUnmappedAliasList.External_Code;
						stData["aliasDesc"] 	 = chkUnmappedAliasList.External_Description;
						stData["entityID"] 		 = '#evaluate("FORM.BA_ID_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#")#';
						stData["entityDesc"] 	 = ""; // '#evaluate("FORM.BA_Desc_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#")#';
						stData["PayeeID"]		 = "";
						stData["aliasUniproNum"] = "";
						stData["aliasLoc"] 		 = "";
						stData["bsaId"] 		 = "";
						stData["Unknown"]		 = 0;
						
						errEntity = AliasMgr.getDistributorInfo(stData["entityID"],0,1);

						if(arrayLen(errEntity) NEQ 0 AND errEntity[1].Name NEQ "")
						{
							arrAliasSaveOutput = AliasMgr.saveAlias(stData,chkUnmappedAliasList.Alias_Type,request.AccessStructure.User_ID);
						} 
						else
						{
							strError = "Invalid Entity ID";
							stError["err_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#"] = strError;
						}								
					</cfscript>

				<cfelseif (chkUnmappedAliasList.Alias_Type EQ 1)>
					<!--- 1 = Item --->
					<cfscript>
						stData["entityType"] 	 = 1;
						stData["sourceType"] 	 = BBClaimSourceXREFDetails.Source_Type;
						stData["sourceTypeDesc"] = BBClaimSourceXREFDetails.Source_Type_Description;
						stData["sourceID"] 	 	 = chkUnmappedAliasList.Source_Code;
						stData["recordID"] 		 = chkUnmappedAliasList.BB_Claim_Alias_XREF_ID;
						stData["aliasID"] 		 = chkUnmappedAliasList.External_Code;
						stData["aliasDesc"] 	 = chkUnmappedAliasList.External_Description;
						stData["entityID"] 		 = '#evaluate("FORM.BA_ID_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#")#';
						stData["entityDesc"] 	 = ""; // '#evaluate("FORM.BA_Desc_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#")#';		
						stData["bsaId"] 		 = "";
						if (isDefined("FORM.chkUnknown_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#"))
						{
							stData["Unknown"]		 = '#evaluate("FORM.chkUnknown_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#")#';
						}
						else
						{
							stData["Unknown"]		 = 0;
						}
						errEntity = AliasMgr.getItemInfo(stData["entityID"],0);
						if((arrayLen(errEntity) NEQ 0 AND errEntity[1].ItemID NEQ "") OR stData["Unknown"] EQ 1)
						{	
							arrAliasSaveOutput = AliasMgr.saveAlias(stData,chkUnmappedAliasList.Alias_Type,request.AccessStructure.User_ID);
						}
						else
						{
							strError = "Invalid Entity ID";
							stError["err_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#"] = strError;
						}								
					</cfscript>

				<cfelseif (chkUnmappedAliasList.Alias_Type EQ 2)>
					<!---  2 = Program	  --->
					
					<cfscript>
						stData["entityType"] 	 = 2;
						stData["sourceType"] 	 = BBClaimSourceXREFDetails.Source_Type;
						stData["sourceTypeDesc"] = BBClaimSourceXREFDetails.Source_Type_Description;
						stData["sourceID"] 	 	 = chkUnmappedAliasList.Source_Code;
						stData["recordID"] 		 = chkUnmappedAliasList.BB_Claim_Alias_XREF_ID;
						stData["aliasID"] 		 = chkUnmappedAliasList.External_Code;
						stData["aliasDesc"] 	 = chkUnmappedAliasList.External_Description;
						stData["entityID"] 		 = '#evaluate("FORM.BA_ID_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#")#';
						stData["entityDesc"] 	 = ""; // '#evaluate("FORM.BA_Desc_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#")#';
						stData["bsaId"] 		 = "";	
						stData["Unknown"]		 = 0;
						
						errEntity = AliasMgr.getProgramInfo(stData["entityID"],0);
						if(arrayLen(errEntity) NEQ 0 AND errEntity[1].contractID NEQ "")
						{
							arrAliasSaveOutput = AliasMgr.saveAlias(stData,chkUnmappedAliasList.Alias_Type,request.AccessStructure.User_ID);
						}
						else
						{
							strError = "Invalid Entity ID";
							stError["err_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#"] = strError;
						}								
					</cfscript>
 				
				<cfelseif (chkUnmappedAliasList.Alias_Type EQ 3)>	
					<!--- 3 = Operator --->				
					<cfscript>
						stData["entityType"] 	 = 3;
						stData["sourceType"] 	 = BBClaimSourceXREFDetails.Source_Type;
						stData["sourceTypeDesc"] = BBClaimSourceXREFDetails.Source_Type_Description;
						stData["sourceID"] 	 	 = chkUnmappedAliasList.Source_Code;
						stData["recordID"] 		 = chkUnmappedAliasList.BB_Claim_Alias_XREF_ID;
						stData["aliasID"] 		 = chkUnmappedAliasList.External_Code;
						stData["aliasDesc"] 	 = chkUnmappedAliasList.External_Description;
						stData["entityID"] 		 = '#evaluate("FORM.BA_ID_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#")#';
						stData["entityDesc"] 	 = ""; // '#evaluate("FORM.BA_Desc_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#")#';	
						stData["bsaId"] 		 = "";		
						stData["Unknown"]		 = 0;
						
						errEntity = AliasMgr.getOperatorInfo(stData["entityID"],1);
						if(arrayLen(errEntity) NEQ 0 AND errEntity[1].name NEQ "")
						{
							arrAliasSaveOutput = AliasMgr.saveAlias(stData,chkUnmappedAliasList.Alias_Type,request.AccessStructure.User_ID);
						} 
						else
						{
							strError = "Invalid Entity ID";
							stError["err_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#"] = strError;
						}								
					</cfscript>
 				
				</cfif> <!--- <cfif (chkUnmappedAliasList.Alias_Type EQ 0)> --->

			</cfif> <!--- <cfif isDefined("FORM.BA_ID_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#") --->
				
 		</cfloop> 	
		<!--- 
				47734: User uploaded BB with Alias is creating duplicates/Anand Rao/24-Feb-2014
				Call the SP second time to refresh the ##BB_Unmapped_Alias_List table when the form is 
				submitted and as aliases are fixed. Truncate the temp table so that it will get the 
				rows correctly and to stop duplicating.
		--->
			<cfquery name="blkinsert2" datasource="#application.datasource#">
				TRUNCATE TABLE ##BB_New_Single_File_BLK_INS 
			</cfquery>
		
		<cfstoredproc datasource="#application.datasource#" procedure="Upload_Single_File_Alias_Validate">
			<cfprocparam type="IN"  variable="@Uploaded_Single_File"	value="" cfsqltype="CF_SQL_VARCHAR">
			<cfprocparam type="IN"  variable="@Upload_ID"	value="#Upload_ID#" cfsqltype="CF_SQL_INTEGER">
			<cfprocparam type="IN"  variable="@Process_Type" value="2" cfsqltype="CF_SQL_INTEGER"> 	
			<cfprocresult name = "UploadSingleFileResult2" > <!--- Original result set that returns status etc --->
	 	</cfstoredproc>
		
	</cfif>	<!--- <cfif isDefined("FORM.submitted" AND FORM.submitted EQ 1)> --->
	
	<cfif (UploadSingleFileResult2.Status EQ 1)><br>
		<br>
			The Upload Encountered the following error: "Error Number: #UploadSingleFileResult2.ErrorNumber#", <br>
			Error Message: <font color="red">"#UploadSingleFileResult2.ErrorMessage#"</font>
			<script language="javascript">
				window.opener.location.reload();
			</script>
				<!--- 	
					47734: User uploaded BB with Alias is creating duplicates/Anand Rao/25-Feb-2015
					Delete the rows from the perm table as we do not need it any more 
				--->
				<!--- <cfquery name="delDataFromTable" datasource="#application.datasource#">
					DELETE FROM BB_New_Single_File_BLK_INS WHERE Upload_ID = #Upload_ID#
				</cfquery>  --->
			<cfabort>
	<cfelse>
			<cfset useLakebaseForchkBBUploadLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_upload_log")>
<cfif useLakebaseForchkBBUploadLog>
	<cftry>
		<cfset chkBBUploadLog = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_upload_log", {
				"upload_id" = "eq.#Upload_ID#",
				"select" = "upload_status"
			}), "upload_status"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForchkBBUploadLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForchkBBUploadLog>
<cfquery name="chkBBUploadLog" datasource="#application.datasource#">
				SELECT Upload_Status FROM BB_Upload_Log where Upload_id = #Upload_ID#
			</cfquery>
</cfif>
			<cfif chkBBUploadLog.Upload_Status EQ "Creation Complete" OR chkBBUploadLog.Upload_Status EQ "Validation Completed">
				<br>
				<br>
				<strong>The Upload is Queued for Billback Creation.</strong>
			<cfelse>
				<br>
					The Upload Encountered the following error: <strong><cfoutput>#chkBBUploadLog.Upload_Status#</cfoutput></strong>
			</cfif>

			<cfif UploadSingleFileResult2.Status EQ 3> 
				<cfset useLakebaseForchkOCRUploadLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForchkOCRUploadLog>
	<cftry>
		<cfset chkOCRUploadLog = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ocr_upload_log", {
				"bb_upload_id" = "eq.#Upload_ID#",
				"deleted" = "eq.0",
				"select" = "ocr_step,ocr_upload_id,ocr_upload_status"
			}), "ocr_step,ocr_upload_id,ocr_upload_status"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForchkOCRUploadLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForchkOCRUploadLog>
<cfquery name="chkOCRUploadLog" datasource="#application.datasource#">
					SELECT OCR_Step,OCR_Upload_ID,OCR_Upload_Status  FROM OCR_Upload_Log WHERE BB_Upload_ID = #Upload_ID# AND Deleted = 0
				</cfquery>
</cfif>

				<cfif (chkOCRUploadLog.RecordCount GTE 1)>
					<cfquery name="qGetOCRUploadArchive" datasource="#application.datasource#">				
					 	UPDATE	l
						SET		-- SELECT 
								OCR_Step = CASE WHEN BB_upload_log.Upload_Status NOT in ( 'Validation Completed' ,'Creation Complete') THEN  '10'
												when BB_upload_log.Upload_Status in ( 'Validation Completed' ) THEN  '11'
												when BB_upload_log.Upload_Status in ( 'Creation Complete' ) THEN  '12'
											END,
								OCR_Upload_Status  =  CASE WHEN BB_upload_log.Upload_Status NOT in ( 'Validation Completed' ,'Creation Complete') THEN 'Validation completed with errors'
															when BB_upload_log.Upload_Status in ( 'Validation Completed' ) THEN  'Validation completed – BB queued for creation' 
															when BB_upload_log.Upload_Status in ( 'Creation Complete' ) THEN  'BB creation complete - get the status FROM BB upload'
														END,
								Updated_Date = GETDATE() 
					  	FROM      OCR_Upload_Log L
					    INNER JOIN BB_upload_log ON BB_upload_log.upload_id = L.BB_Upload_ID
					      	AND BB_Upload_ID = #Upload_ID#
					</cfquery> 
					<script language="javascript">
						window.opener.location.reload();
					</script>
				</cfif>
			</cfif>
	</cfif> 		
	
		<cfquery name="chkUnmappedAliasList" datasource="#application.datasource#">
			SELECT * FROM ##BB_Unmapped_Alias_List order by Alias_Type
		</cfquery>
				
	<cfif (chkUnmappedAliasList.RecordCount GTE 1)>
		<!--- CF loop over all the products --->	
		<table width="720" border="0" align="center">
			<tr>
				<td align="right">
					<!--- <strong>[<a href="##" onclick="document.DataForm.submit()">Validate</a>]</strong>&nbsp; --->
					<input type="submit"  value=" Validate " name="validate1" id="validate1"  style="display:block;" onclick="disableSubmit();"/>
					<input type="button"  value=" Validate " name="dummyVal1" id="dummyVal1" disabled style="display:none;"/>
				</td>	
			</tr> 
		</table>
		<br>
		<table width="850" cellpadding="1" cellspacing="0" height="25" border="1px" bordercolor="006600" ALIGN="center"> 
			<tr id="HEADER" bgcolor="##FFCE84">
				<td width="75"><strong>Alias Type</strong></td>
				<td width="85"><strong>Alias Id</strong></td>
				<td width="135"><strong>Alias Desc</strong></td>
				<td width="65"><strong>Mark as <br>Unknown</strong></td>
				<td width="190"><strong>ID</strong></td>
				<td width="180"><strong>Desc</strong></td>
			</tr>
				<cfset  CURRENTROW = 1 />		
				<cfloop query ="chkUnmappedAliasList">
					<cfset Selected_FieldValue = "">
					<cfset Selected_Alias_Detail = "">
					<tr  <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
						<td> 
							<!--- Alias_Type INT, /* 
								0 = Distributor
								1 = Item
								2 = Program	 
								3 = Operator */ 
							--->
							<cfif (chkUnmappedAliasList.Alias_Type EQ 0)>
								Distributor
							<cfelseif (chkUnmappedAliasList.Alias_Type EQ 1)>	
								Item
							<cfelseif (chkUnmappedAliasList.Alias_Type EQ 2)>
								Program
							<cfelseif (chkUnmappedAliasList.Alias_Type EQ 3)>	
								Operator
							</cfif>
						</td>
						<td>	
							#chkUnmappedAliasList.External_Code#
						</td>
						<td>
							#chkUnmappedAliasList.External_Description#
						</td>
						<td align="center"> 
							<!--- Alias_Type INT, /* 
								0 = Distributor
								1 = Item
								2 = Program	 
								3 = Operator */ 
							--->
							<cfif (chkUnmappedAliasList.Alias_Type EQ 0)>
								&nbsp;
							<cfelseif (chkUnmappedAliasList.Alias_Type EQ 1)>	
								<input type="checkbox" name="chkUnknown_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#" value="1">
							<cfelseif (chkUnmappedAliasList.Alias_Type EQ 2)>
								&nbsp;
							<cfelseif (chkUnmappedAliasList.Alias_Type EQ 3)>	
								&nbsp;
							</cfif>
						</td>
						
						<td>
						
							<cfset valToCheck = "#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#" />
							<cfif FORM.Distributor_List NEQ "" AND valToCheck EQ FORM.CurrentImgClick>
									<cfquery name="Dist_Search_Result" datasource = "#Application.Datasource#">
										DECLARE @Manual_Upload_Ship_To_Column VARCHAR(20)
										
										SELECT @Manual_Upload_Ship_To_Column = Manual_Upload_Ship_To_Column
										FROM Billback_Upload_Settings
										
										SELECT BSA_Foodservice_Customers_ID,
										CASE WHEN @Manual_Upload_Ship_To_Column = 'shr_ship_to' THEN
											Shr_Ship_To
										ELSE 
											Ship_To
										END 
										AS ship_to, 
										Name, Address_1, State, ZipCode 
										FROM BSA_Foodservice_Customers 
										WHERE
											BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = <cfqueryparam value="#FORM.Distributor_List#" cfsqltype="CF_SQL_VARCHAR">
											AND
											BSA_Foodservice_Customers.Deleted = 0
											AND
											BSA_Foodservice_Customers.Active_Code = 'A'
										ORDER BY Name
									</cfquery>
								<cfset Selected_FieldValue = Dist_Search_Result.ship_to>
								<cfset Selected_Alias_Detail = Dist_Search_Result.Name & ", " & Dist_Search_Result.Address_1  & ", " & Dist_Search_Result.State & ", " & Dist_Search_Result.zipcode /> 
							</cfif>			
						
							<cfif FORM.Operator_List NEQ "" AND valToCheck EQ FORM.CurrentImgClick>
									<cfset useLakebaseForOpr_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForOpr_Search_Result>
	<cftry>
		<cfset Opr_Search_Result = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"bsa_operator_id" = "eq.#FORM.Operator_List#",
				"select" = "bsa_operator_id,operator_name,operator_location_type,operator_city,operator_state,operator_number_of_locations,operator_dba,legacy_id"
			}), "bsa_operator_id,operator_name,operator_location_type,operator_city,operator_state,operator_number_of_locations,operator_dba,legacy_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForOpr_Search_Result = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForOpr_Search_Result>
<cfquery name="Opr_Search_Result" datasource = "#Application.Datasource#">
										SELECT	BSA_Operator_ID, operator_name, Operator_Location_Type, Operator_City, Operator_State, Operator_Number_Of_Locations, Operator_DBA, legacy_id
										FROM 	BSA_Operator
										WHERE 	BSA_Operator_ID = '#FORM.Operator_List#'
									</cfquery>
</cfif>
								<cfset Selected_FieldValue = Opr_Search_Result.legacy_id>
								<cfset Selected_Alias_Opr_ID = " [" & Opr_Search_Result.BSA_Operator_ID & "]" />
								<cfset Selected_Alias_Detail = Opr_Search_Result.Operator_Name & Selected_Alias_Opr_ID & ", " & Opr_Search_Result.Operator_City  & ", " & Opr_Search_Result.Operator_State  /> 
							</cfif>							
						
							<cfif FORM.Product_List NEQ "" AND valToCheck EQ FORM.CurrentImgClick>
									<cfset useLakebaseForItem_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForItem_Search_Result>
	<cftry>
		<cfset Item_Search_Result = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"bsa_foodservice_items_master_id" = "eq.#FORM.Product_List#",
				"active_code" = "eq.A",
				"deleted" = "eq.0",
				"select" = "bsa_foodservice_items_master_id,item,description"
			}), "bsa_foodservice_items_master_id,item,description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForItem_Search_Result = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForItem_Search_Result>
<cfquery name="Item_Search_Result" datasource = "#Application.Datasource#">
										SELECT	BSA_Foodservice_Items_Master_ID,Item, Description 
										FROM 	BSA_Foodservice_Items_Master
										WHERE 	BSA_Foodservice_Items_Master_ID = '#FORM.Product_List#' AND Active_Code = 'A' AND Deleted = 0
									</cfquery>
</cfif>
								<cfset Selected_FieldValue = Item_Search_Result.Item>
								<cfset Selected_Alias_Detail = Item_Search_Result.Description  /> 
							</cfif>							
						
							<input type="text" name="BA_ID_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#" width="12" <cfif Selected_FieldValue NEQ "">value="#Selected_FieldValue#"<cfelseif isDefined("FORM.BA_ID_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#") AND evaluate("FORM.BA_ID_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#") NEQ ""> value='#evaluate("FORM.BA_ID_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#")#'<Cfelse> value=""</cfif>>
							<cfif (isDefined("stError.err_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#") <!--- AND evaluate("FORM.BA_ID_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#") NEQ "" --->)>
								<cfset isError = Evaluate("stError.err_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#") />
							</cfif>	
							 <!--- 
<cfif (evaluate(stError.err_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#"#]) NEQ "")>  --->
							<cfif isError NEQ "">   
								<b><font color="Red"><cfoutput>#isError#</cfoutput></font></b>
							</cfif>	
							
							<cfif (chkUnmappedAliasList.Alias_Type EQ 0)>
								<!--- Distributor --->
								<a href="javascript: void(0);" onClick="javaScript: showSearchWindow('/billbacks/search_screens/PM_select_distributors.cfm?FormName=DataForm&OnlyDistributorsUnderMe=0','#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#');"><img src="/images/searchtool.gif" border="0"></a>								
							<cfelseif (chkUnmappedAliasList.Alias_Type EQ 1)>	
								<!--- Item --->
								<a href="javascript: void(0);" onClick="javaScript: showSearchWindow('/common_files/contracts/product_select_V1.cfm?FormName=DataForm&Discountype=0&EZTemplate=0&SourceCaller=DataForm&FirstParentID=0&prgID=0','#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#');"><img src="/images/searchtool.gif" border="0"></a>
							<cfelseif (chkUnmappedAliasList.Alias_Type EQ 2)>
								<!--- Program --->
							<a href="javascript: void(0);" onClick="javaScript: showSearchWindow('/billbacks/search_screens/search_programs.cfm?Formname=DataForm&fieldname=BA_ID_#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#&SELECTSINGLESEARCHRESULTONLY=1&ProgramRestrictions=0','#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#');"><img src="/images/searchtool.gif" border="0" ></a>
							<cfelseif (chkUnmappedAliasList.Alias_Type EQ 3)>	
								<!--- Operator --->
								<a href="javascript: void(0);" onClick="javaScript: showSearchWindow('/billbacks/search_screens/pm_select_operators.cfm?Formname=DataForm','#chkUnmappedAliasList.Alias_Type#_#BB_Claim_Alias_XREF_ID#');"><img src="/images/searchtool.gif" border="0" ></a>
							</cfif>							 
						</td>
						 <td>
						 <cfif Selected_Alias_Detail NEQ "">
						 	#Selected_Alias_Detail#
						</cfif>	&nbsp;
						</td>  
					</tr>
					<cfset CURRENTROW =  CURRENTROW + 1 />    				
					<cfset isError = "" />
				</cfloop>
				<!--- Dev Note (70533) -  Reasons for adding below line (<cfset FORM.CurrentImgClick = "">) is listed towards the uper portion of the file. 
				Search for "70533". --->
				<cfset FORM.CurrentImgClick = "">
			
	 	</table>
	 	<br>
		<table width="720" border="0" align="center">
			<tr>
				<td align="right">
					<!--- <strong>[<a href="##" onclick="document.DataForm.submit()">Validate</a>]</strong>&nbsp; --->
					<input type="submit"  value=" Validate " name="validate2" id="validate2" style="display:block;" onclick="disableSubmit();"/>
					<input type="button"  value=" Validate " name="dummyVal2" id="dummyVal2" disabled style="display:none;"/>					
				</td>	
			</tr> 
		</table>
	<cfelse><br>
	<br>
	
		<strong>All of the Aliases have been fixed.</strong>
		<br>
		<br>
		<div align="center"><input type="button" value="Close Window" onClick="javascript:close_window();"></div>
		<script language="javascript">
			alert("All Aliases have been fixed!!");
		</script>
	</cfif>	
	<input name="submitted" type="hidden" value="1"> 
	
	<!--- DUMMY hidden form fields--->
		<input name="Distributor_List" type="hidden" value="#FORM.Distributor_List#"> 
		<input name="CurrentImgClick" type="hidden" value="#FORM.CurrentImgClick#" />
		<input name="Operator_List" type="hidden" value="#FORM.Operator_List#" />
		<input name="Product_List" type="hidden" value="#FORM.Product_List#" />
		<input name="ProductListToExcludeFromSelecting" type="hidden" value="#FORM.ProductListToExcludeFromSelecting#" />
		<input name="ExistingProductList" type="hidden" value="#FORM.ExistingProductList#" />		
		
</form>		
</cfoutput>   
</body>
</html>

<cffunction name="dumper" access="remote" output="false">
	<cfargument name="arrBBPDIR"	required="true"		type="any" />	
	<cfargument name="filename" required = "false" type="string" />
	<cfif (isDefined("arguments.filename") and arguments.filename NEQ "")>
		<cfdump var="#arguments.arrBBPDIR#" output="#arguments.filename#" />
	<cfelse>	
		<cfdump var="#arguments.arrBBPDIR#"/>
	</cfif>
	<cfreturn />	
</cffunction>