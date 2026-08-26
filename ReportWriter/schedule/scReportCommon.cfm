<CFINCLUDE TEMPLATE="reportCommon.cfm">

<!-----<CFSET programColumnHeaderID="programtype,programnumber,programtitle,quantity,uom,startdate,enddate"><!----If u edit here edit in 
showReport too as this list is hardcoded in the cfcase to show colum headers in <thead> tag---->
<CFSET programColumnHeaders="Program Type,Program Number,Program Title,Quantity,UOM,Start Date,End Date">
<CFSET programColumnFields="pt.Created_Type,cm.Contract_Number,cm.Contract_Title,cm.Contract_Quantity,uom.Abbreviation,cm.Contract_Start_Date,cm.Contract_End_Date">

<CFSET productColumnHeaderID="programtype,programnumber,programtitle,quantity,uom,startdate,enddate"><!----If u edit here edit in 
showReport too as this list is hardcoded in the cfcase to show colum headers in <thead> tag---->
<CFSET productColumnHeaders="Program Type,Program Number,Program Title,Quantity,UOM,Start Date,End Date">
<CFSET productColumnFields="pt.Created_Type,cm.Contract_Number,cm.Contract_Title,cm.Contract_Quantity,uom.Abbreviation,cm.Contract_Start_Date,cm.Contract_End_Date">

<cfset rIntervals="Once,Daily,Weekly,Monthly">------->

<CFSCRIPT>

//smtpServerName = "smtp.awayx.com";
reportFromAddress = "reportscheduler@" & application.CompanyEmailSuffix;
schPerformancePage = "schPerformanceReport.cfm";
schSendPerformance = "schSendPerformanceReport.cfm";
schProductPage="schReportProduct.cfm";
//schProgramPage="schReportProgram.cfm";
schProgramPage="schReportDistributor.cfm";

schSendProduct="schSendProductReport.cfm";
//schSendProgram="schSendProgramReport.cfm";
schSendProgram="schSendDistributorReport.cfm";

schGenerateProduct="generateProductReport.cfm";
schGenerateInvoiceProduct = "generatenewProductReport.cfm";
schGenerateProgram="generateDistributorReport.cfm";
schGenerateInvoiceProgramVolumePage = "generatenewDistributorVolumeReport.cfm";
schGenerateInvoiceProgramExpensePage = "generatenewDistributorExpenseReport.cfm";
schGenerateInvoiceProgramMarginPage = "generatenewDistributorMarginReport.cfm";
schGenerateInvoiceProgramPage = "generatenewDistributorReport.cfm";

//displayProduct="reportDisplayProduct.cfm";
displayProduct="reportDisplayProductGP.cfm";
displayInvoiceProductVolume = "reportnewDisplayProductVolumeGP.cfm";
displayInvoiceProductExpense = "reportnewDisplayProductExpenseGP.cfm";
displayInvoiceProductMargin = "reportnewDisplayProductMarginGP.cfm";
displayInvoiceProgramVolume = "reportnewDisplayDistributorVolumeGP.cfm";
displayInvoiceProgramExpense = "reportnewDisplayDistributorExpenseGP.cfm";
displayInvoiceProgramMargin = "reportnewDisplayDistributorMarginGP.cfm";
//displayProduct="reportDisplayProductFY.cfm";
//displayProgram="reportDisplayDistributor.cfm";
displayProgram="reportDisplayDistributorGP.cfm";
//displayProgram="reportDisplayDistributorFY.cfm";


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//Added from 9/30/02 onwards for Product/Program Margin Ananysis Report   
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/
schMaginProduct					=	"MarginProduct.cfm";
schGenerateMarginProduct		= 	"MarginProductGenerate.cfm";
displayProductMarginPage		=	"marginProductDisplayReport.cfm";
SendMarginProduct				=	"MarginProductSendReport.cfm";
displayMarginProduct			=	"marginProductDisplayReport.cfm";
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//End Added from 9/30/02 onwards for Product/Program Margin Ananysis Report
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/


</CFSCRIPT>
