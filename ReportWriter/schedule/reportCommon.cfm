<CFSET fieldShortCut="zone,region,broker,family,buyinggroup,#application.returned_customer_setting.distributor_label_singular#,#application.returned_customer_setting.operator_label_singular#,typegroup,qbrand,typecode,brand,product">
<CFSET fieldExpansion="Zone,Region,Broker,Family,Buying Group, #application.returned_customer_setting.distributor_label_singular#,#application.returned_customer_setting.operator_label_singular#,Type Group,Q Brand,Type Code,Brand,Product">


<!-----<CFSET fProgramColumnHeaderID="programtype,programnumber,programtitle,volume,uom,startdate,enddate"><!----If u edit here edit in 
showReport too as this list is hardcoded in the cfcase to show colum headers in <thead> tag---->
<CFSET fProgramColumnHeaders="Program Type,Program Number,Program Title,Volume,UOM,Start Date,End Date">
<CFSET fProgramColumnFields="pt.Created_Type,cm.Contract_Number,cm.Contract_Title,cm.Contract_Quantity,uom.Abbreviation,cm.Contract_Start_Date,cm.Contract_End_Date">------->

<CFSET fProgramColumnHeaderID="programtype,programnumber,programtitle,startdate,enddate"><!----If u edit here edit in 
showReport too as this list is hardcoded in the cfcase to show colum headers in <thead> tag---->
<CFSET fProgramColumnHeaders="Program Type,Program Number,Program Title,Start Date,End Date">
<CFSET fProgramColumnFields="pt.Created_Type,cm.Contract_Number,cm.Contract_Title,cm.Contract_Start_Date,cm.Contract_End_Date">



<CFSET vProgramColumnHeaderID="fiscalvolume,fiscalexpense,fiscalmargin">
<!-----<CFSET vProgramColumnHeaders="Projected Fiscal Volume,Projected Fiscal Expense,Projected Fiscal Margin">------->
<CFSET vProgramColumnHeaders="Projected Volume,Projected Expense,Projected Margin">
<CFSET vProgramColumnFields="VolumePerDay,PTECPerDay,PTTMPerDay">
<CFSET vProgramExtra=" ,$,$">


<!-----<CFSET fProductColumnHeaderID="programtype,programnumber,programtitle,volume,uom,startdate,enddate"><!----If u edit here edit in 
showReport too as this list is hardcoded in the cfcase to show colum headers in <thead> tag---->
<CFSET fProductColumnHeaders="Program Type,Program Number,Program Title,Volume,UOM,Start Date,End Date">
<CFSET fProductColumnFields="pt.Created_Type,cm.Contract_Number,cm.Contract_Title,cm.Contract_Quantity,uom.Abbreviation,cm.Contract_Start_Date,cm.Contract_End_Date">------->

<CFSET fProductColumnHeaderID="programtype,programnumber,programtitle,startdate,enddate"><!----If u edit here edit in 
showReport too as this list is hardcoded in the cfcase to show colum headers in <thead> tag---->
<CFSET fProductColumnHeaders="Program Type,Program Number,Program Title,Start Date,End Date">
<CFSET fProductColumnFields="pt.Created_Type,cm.Contract_Number,cm.Contract_Title,cm.Contract_Start_Date,cm.Contract_End_Date">

<!-----<CFSET vProductColumnHeaderID="fiscalvolume,fiscalexpense,marginaverage,fiscalmargin">
<!-----<CFSET vProductColumnHeaders="Projected Fiscal Volume,Projected Fiscal Expense,Projected Margin Average,Projected Fiscal Margin $">------->
<CFSET vProductColumnHeaders="Projected Volume,Projected Expense,Projected Margin Average,Projected Margin $">
<CFSET vProductColumnFields="VolumePerDay,ExpensePerDay,MarginAverage,FiscalMarginDollar">
<CFSET vProductExtra=" ,$,$,$">------->
<CFSET vProductColumnHeaderID="fiscalvolume,fiscalexpense,,fiscalmargin">
<!-----<CFSET vProductColumnHeaders="Projected Fiscal Volume,Projected Fiscal Expense,Projected Margin Average,Projected Fiscal Margin $">------->
<CFSET vProductColumnHeaders="Projected Volume,Projected Expense,Projected Margin $">
<CFSET vProductColumnFields="VolumePerDay,ExpensePerDay,FiscalMarginDollar">
<CFSET vProductExtra=" ,$,$">



<CFSET reportFormatTypes="Product and Margin only,Cost Detail,Full #application.returned_customer_setting.Trade_Label# Detail">
<CFSET reportFormatTypeIDs="PMonly,CD,FTD">
<CFSET tradeProgramGenericTypeList="Distributor Trade/Shelter">

<cfset rIntervals="Once,Daily,Weekly,Monthly">

<STYLE>
.di_warning
{
    COLOR: #ff4500;
}
</STYLE>

<CFSET Date_Operators=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
<CFSET Date_Operator_Symbols=" ,>=,=,<=">