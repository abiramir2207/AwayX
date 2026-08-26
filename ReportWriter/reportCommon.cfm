<CFSET programColumnHeaderID="programtype,programnumber,programtitle,quantity,uom,startdate,enddate"><!----If u edit here edit in 
showReport too as this list is hardcoded in the cfcase to show colum headers in <thead> tag---->
<CFSET programColumnHeaders="Program Type,Program Number,Program Title,Quantity,UOM,Start Date,End Date">
<CFSET programColumnFields="pt.Created_Type,cm.Contract_Number,cm.Contract_Title,cm.Contract_Quantity,uom.Abbreviation,cm.Contract_Start_Date,cm.Contract_End_Date">

<CFSET productColumnHeaderID="programtype,programnumber,programtitle,quantity,uom,startdate,enddate"><!----If u edit here edit in 
showReport too as this list is hardcoded in the cfcase to show colum headers in <thead> tag---->
<CFSET productColumnHeaders="Program Type,Program Number,Program Title,Quantity,UOM,Start Date,End Date">
<CFSET productColumnFields="pt.Created_Type,cm.Contract_Number,cm.Contract_Title,cm.Contract_Quantity,uom.Abbreviation,cm.Contract_Start_Date,cm.Contract_End_Date">

<cfset rIntervals="Once,Daily,Weekly,Monthly">
<STYLE>
.di_warning
{
    COLOR: #ff4500;
}
</STYLE>