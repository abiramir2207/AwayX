<!------ testPrint.cfm ----->
<cffile action = "read"
    file = "#APPLICATIONPATH#\scheduled\testPrint.txt"
    variable = "fileContent">
<cfset fileContent = "#fileContent##chr(12)##fileContent#">
<cfobject action = "Create"
    type = "COM"
    class = "BSAPrinter.bsaPrint"
    name = "oPrinter"> 
<cfset oPrinter.Text = fileContent>
<cfset oPrinter.LogFilePath = "#APPLICATIONPATH#\scheduled\PrinterLog.log">
<cfset oPrinter.PaperOrientation = 2>
<cfset oPrinter.FontName = "Courier New">
<cfset oPrinter.PrintNow()>

<center>
<font color="blue" size="+1">
Check the printer...
</font>
</center>
<hr>
<cfoutput><pre>#fileContent#</pre></cfoutput>
<hr>