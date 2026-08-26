<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_all_volume.cfm
CREATED: 	03/04/2008 - RBL
EDITED:		08/18/2008 - RBL [reverted]
EDITED:		08/16/2010 - Milan [Convert to Itext in Java]

FUNCTIONALITY:
- This include template is utilized to display the Volume by Item module for all versionS of the Deal Letters v2...
The cfoutput tags ARE needed for this include.
--->

<!--- These parameters are required for this template to process correctly --->
<cfparam name="thisTag.stPDFHeaderInfo.program_id" 		default="">
<cfparam name="thisTag.stPDFBodyInfo.bPreDefinedPageBreaks" default="1">

</cfsilent>

<cfset Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume")>

<!--- TO DELETE request.AccessStructure.Company_Main_ID
NOTE: this file will always be included in the PDF generator... which includes the inc_all_vars... which creates the primary PDF structs... --->
<cfset Program_Volume.Load_Basic_Information(thisTag.stPDFHeaderInfo.program_id, thisTag.stPDFIntroInfo.company_id)>

<!--- Load Program data to the pdf document --->
<cfset Program_Volume.fnProgramVolumeResult(itext=1,document=document,bPreDefinedPageBreaks=thisTag.stPDFBodyInfo.bPreDefinedPageBreaks,bShowVolumeSummary=bShowVolumeSummary)>