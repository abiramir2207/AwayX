<!--- 
Peter Stolz
Pegasus Internet 10/22/2000
Last Modified 12/29/2000
Email: see below
Check out http://www.coldfusionnet.com for updates to this tag.


!!! CREATE DYNAMIC EXCEL FILES WITH CUSTOM FORMATTING: COLORS, BORDERS, FONTS ETC.!!!
This custom tag creates a dynamic Excel file from the generated content of a block of ColdFusion code.
The generated content is first saved as an HTML file. 
Then it is opened in Excel and saved with the .xls extension.

!!!--------
Do you need to generate colorful MS Word documents on the fly?
Check out CF_HTML2Word in the Allaire Tag gallery.
!!!--------


!!!PLEASE NOTE THAT THIS TAG IS A 'BETA' VERSION - USE AT YOUR OWN RISK!!!

System Requirements:
- this tag will only work on WindowsNT/2000
- MS Excel or OSE (Office Server Extensions/ requires IIS) MUST BE INSTALLED on the server
- Office HTML filters must also be installed (try to open a simple HTML file manually in Excel - on the server - to check this. You should NOT see the HTML source.)
- ColdFusion must have permissions to access/use Excel COM objects
(Download OLEView from www.microsoft.com and check the launch and access permissions of the "Microsoft Excel Application" COM object) 

 
Usage:
<CF_HTML2Excel 
    DIRECTORY="C:\\CF\"
    FILENAME="test1"
    SHEETNAME="MySheet"
    LEAVEOPEN="YES/NO">
 
Any static or dynamically generated HTML goes here 
Note: HTML code must be properly formatted into tables, rows and columns for this to work

</CF_HTML2Excel>

Input Parameters:
DIRECTORY(optional): the directory path where the Excel file will be created; default is the current template directory
FILENAME(optional): the name of the Excel file that will be created (without the extension); default is a random number preceded by HTML2Excel(eg. HTML2Excel5545678.xls)
SHEETNAME(optional): the name of the WorkSheet that will be generated; default is same as file name without extension.
LEAVEOPEN(optional/use carefully): leaves the Excel application open in the background after it finishes one request. Use this option if you expect multiple requests in a short period of time. It can save Excel start-up time but it uses server resources.

Output Parameters:
EXCELFILE : The absolute path to the just-created Excel File

Note: If another Excel file with same name exists the tag will overwrite it without prompting!!

Please send constructive comments to: pstolz@usa.net (after you have read System Requirements and Usage sections above)

--->

<CFPARAM NAME="Attributes.Directory" DEFAULT="#GetDirectoryFromPath(GetTemplatePath())#">
<CFPARAM NAME="Attributes.FileName" DEFAULT="HTML2Excel#RandRange(1000,100000000)#">
<CFPARAM NAME="Attributes.SheetName" DEFAULT="Sheet1">
<CFPARAM NAME="Attributes.LeaveOpen" DEFAULT="No">
<CFPARAM NAME="Attributes.Orientation" DEFAULT="1">


<CFIF ThisTag.HasEndTag>

    <CFSWITCH EXPRESSION="#ThisTag.ExecutionMode#">
    
        <CFCASE VALUE="START">
            <!---  HTML file name is random --->
            <CFSET HTMLFileName = "HTML2Excel" & RandRange(1000,100000000)>
            <CFSET HTMLFilePath = Attributes.Directory & HTMLFileName  & ".html">
            <CFSET ExcelFilePath = Attributes.Directory & Attributes.FileName & ".xls">
            
            <!--- Delete any files that have the same names --->
            <CFIF FileExists(HTMLFilePath)>
                <CFTRY>
                    <CFFILE ACTION="DELETE" FILE="#HTMLFilePath#">
                <CFCATCH TYPE="Any">
                    <CFABORT SHOWERROR="<FONT COLOR='RED'>Error Occured!!<BR>Cannot delete file <B>#HTMLFilePath#.</B><BR>It may be locked by Excel. Close Excel and try again.<BR></FONT><B>Error Details:</B>  #CFCATCH.MESSAGE#">
                </CFCATCH>
                </CFTRY>
            </CFIF>
            
            <CFIF FileExists(ExcelFilePath)>
                <CFTRY>
                    <CFFILE ACTION="DELETE" FILE="#ExcelFilePath#">
                <CFCATCH TYPE="Any">
                     <!---    <CFABORT SHOWERROR="<FONT COLOR='RED'>Error Occured!!<BR>Cannot delete file <B>#ExcelFilePath#.</B><BR>It may be locked by Excel. Close Excel and try again.<BR></FONT><BR><B>Error Details:</B>  #CFCATCH.MESSAGE#"> --->
                </CFCATCH>
                </CFTRY>
            </CFIF>
        <!--- End file delete --->
        </CFCASE>  
        
        
        <CFCASE VALUE="END">
            <!--- write the HTML file to disk --->
            <CFFILE ACTION="WRITE" FILE="#HTMLFilePath#" OUTPUT="#ThisTag.GeneratedContent#">
            
            <!--- discard generated content so it does not show on the page --->
            <CFSET ThisTag.GeneratedContent = "">   
            
                <!--- Try to connect to Excel  --->
                <!------ <CFTRY> ----->
                     <CFOBJECT 
                        ACTION="CONNECT" 
                        CLASS="Excel.Application" 
                        NAME="objExcel" 
                        TYPE="COM">
                       
                 <!------  <CFCATCH TYPE="ANY">   ----->
                                         
                   <!--- Try to create Excel instance --->
                  <!------   <CFTRY> ----->
                        <CFOBJECT 
                            ACTION="CREATE" 
                            CLASS="Excel.Application" 
                            NAME="objExcel" 
                            TYPE="COM">
                    
                        <!------ <CFCATCH TYPE="Any">
                            <CFABORT SHOWERROR="<FONT COLOR='RED'>Cannot create Excel Object<BR>Make sure Excel is installed and that ColdFusion has permissions to use the Excel COM objects</FONT><BR><B>Error Details:</B>  #CFCATCH.MESSAGE#">                    
                        </CFCATCH>
                    </CFTRY>
                  </CFCATCH>
                </CFTRY> ----->
    
				<!------ <CFTRY> ----->
                    <CFSCRIPT>
                        // open Excel in the background
                        objExcel.Visible = false;
                      
                        // disable Alerts such as: 'Save this workbook?'
                        objExcel.DisplayAlerts =false;
                        
                        // Define the workbooks object 
                        objWorkBook = objExcel.Workbooks;
                        
                       // open the Excel file */
                        objOpenedBook = objWorkBook.Open(HTMLFilePath);
                        
                        // get the WorkSheets collection 
                        objWorkSheets = objExcel.WorkSheets; 
                        
                        // get the active worksheet - will have the same name as the HTML file  
                        objWorkSheet =  objWorkSheets.Item(HTMLFileName); 
                        
                        objWorkSheet.Name = Attributes.SheetName;
						
						objWorkSheet.PageSetup.Orientation = Attributes.Orientation;
                        
                        // Save As does not work with workbooks / only with worksheets
                        objWorkSheet.SaveAs(ExcelFilePath,Val(1));
                </CFSCRIPT>
				 <cfdump var="#ExcelFilePath#">
				<CFSCRIPT>          
                        // Close the document
                        objWorkBook.Close();
                        
                        if(Attributes.LeaveOpen IS "No"){
                            // Quit Excel
                            objExcel.Quit();
                         }

                        //release the object
                        objExcel = "Nothing";
                    </CFSCRIPT>
                
                  
                 <!------ <CFCATCH TYPE="ANY">
                    <CFSCRIPT>
                        objExcel.Quit();
                    </CFSCRIPT> 
                    <CFABORT SHOWERROR="<FONT COLOR='RED'>Error occured while connected to the Excel object!</FONT><BR>Error Details:  #CFCATCH.MESSAGE#"> 
                 </CFCATCH>
               </CFTRY>   ----->  
            
            <!--- delete intermediary HTML file --->
            <CFTRY>
                <CFFILE ACTION="DELETE" FILE="#HTMLFilePath#">
                <CFCATCH TYPE="Any">
                </CFCATCH>
            </CFTRY>
                     
            <!--- pass the generated file name to the calling template--->
            <CFSET Caller.ExcelFile = ExcelFilePath>
                           
        </CFCASE>
    </CFSWITCH>
      
<CFELSE>
    <PRE>
    Error: This tag requires an end tag!!
    Usage:
    <FONT COLOR="MAROON">&lt;CF_HTML2Excel&gt;</FONT>
    Dynamically generated HTML to convert to MS Excel format
    <FONT COLOR="MAROON">&lt;/CF_HTML2Excel</FONT>
    <BR>
    Problems? Contact the author at:&nbsp;<A HREF="mailto:pstolz@usa.net?Subject=cf_html2excel">pstolz@usa.net</A>
    </PRE> 
</CFIF>

