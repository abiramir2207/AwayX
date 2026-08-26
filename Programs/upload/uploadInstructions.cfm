<!----------------------------------------------------------------------------------
Name         :  AwayX\Programs\upload\uploadInstructions.cfm
Copyright    :  (c) 2018 Blacksmith Applications, Inc.
Created Date :  18/Oct/2018
Created By   :  Sharon Harris
Description  :  Program Upload user instructions
---------------------------------------------------------------------------------->
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Program Upload Instructions</title>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

        <style>
            .bullets, .bodyText, .standout, .standoutIndented, .sub1 {
                font-size: 12px;
            }
            .bodyText {
                margin: 5px;
            }
            .level1 {
                margin-left: 10px;
            }
            .standout {
                margin: 15px;
                margin-left: 80px;
            }
            .standoutIndented {
                margin-bottom: 15px;
                margin-top: 15px;
                /* margin-left: 40px; */
            }
            .standout > img {
                box-shadow: 1px 2px 4px 1px rgba(86, 87, 96, 0.3);
            }
            .sub1 {
                font-weight: bold;
            }

            table {
                border-collapse: collapse;
                color: #343540;
                margin-left: 25px;
                width: 96%;
            }
            td, th {
                border: 1px solid #D8D9DD;
                text-align: left;
                padding: 2px;
                vertical-align: top;
            }
            th {
                background-color: #FFCE84;
            }
            tr:nth-child(odd) {
                background-color: #F5F6FA;
            }
        </style>
    </head>
    <body>
        <div class="page_title1"> Instructions for Program Upload </div>
        <div style="margin:5px">
            <ol class="bullets">
                <li>Choose a Business Segment</li>
                <li>Choose a Template</li>
                <li>Create the spreadsheet with the programs you want to upload.  The upload can be used for creating new programs, or revising existing programs.</li>
                <br>
                <ol type="a">
                    <li>To create new or revised programs, you will need to have your data in an Excel file.  To get started, download a sample file and edit it.
                        <div class="standoutIndented">
                            <a href="ProgramUploadSample.xlsx" title="Download sample spreadsheet">Sample spreadsheet [download]</a>
                        </div>
                    </li>
                    <li>After a Template is chosen, the Detail information will be available on the screen.  
                        You can refer to this to get the correct values for the spreadsheet.
                        The "copy to clipboard" icons make it easy to copy the fields you want to paste into the spreadsheet.
                    </li>
                </ol>
            </ol>

            <div class="standout">
                <img src="/Images/Programs/copy_clipboard_ex1.png" height="150" alt="example of copying to clipboard">
            </div><br>
            <ol class="bullets" start="4">
                <li>Upload the spreadsheet.</li>
                <li> If there are no errors, there will be a 'success' message on the screen and the programs will be created.
                    You will also receive an email of the successful upload with a report attached.
                    The programs will be in WIP status.
                </li>
                <li>If there are errors, there will be a 'failed' message on the screen.
                    You will be able to click a link to download the spreadsheet to get details of the errors.
                    You will also receive an email of the failed upload that indicates there was an error and has the error spreadsheet available to download.
                    Review the ERROR_INFO column to see the errors.
                </li>
            </ol>


            <br>
            <div class="bodyText sub1">Revising Programs</div>
            <div class="bodyText">
                It is important to understand that when you use Header Action "R" to revise an existing program, it will be a "full refresh".<br>
                A new revision of the program will be created, and it will contain only the items that you include in the upload.
                For example if the existing program has 5 items and the program in the spreadsheet has 2 items, 
                the new revision will only contain those 2 items.<br><br>
                Each template has it's own revision rules that determine what can be changed during a revision.
                In the Detail Information section of the Program Upload page, these rules are displayed in the Template Rules section.
            </div><br>


            <br>
            <div class="bodyText sub1">Format</div>
            <div class="bodyText">You may include many programs in the spreadsheet when uploading into FORGE. The format and required fields are listed below.  
            </div>
            <div class="bodyText">Overview - Columns and Rows</div>
            <ol class="bullets">
                <li>The first row must be the header with the column names.</li>
                <li>The second row and all following rows contain the program data.</li>
                <li>There should be no empty rows.</li>
            </ol>


            <div class="bodyText">Columns</div>
            <div>
                <!--- <img src="/Images/Programs/up_format_sample.png" width="500" alt="Program Upload file format"><br><br> --->
                <table>
                    <tr>
                        <th>Field Name</th>
                        <th>Required?</th>
                        <th>Field Values</th>
                        <th>Comments</th>
                    </tr>
                    <tr>
                        <td>Record Type</td>
                        <td>Yes</td>
                        <td>H = Header<br>C = Customer<br>O = Operator<br>M = Material</td>
                        <td>If you were manually creating a program in the FORGE application, these record types would relate to:<br>
                            <b>H</b> - the row is related to the Basic Information step<br>
                            <b>C</b> - the row is related to the Customer/Distributor step<br>
                            <b>O</b> - the row is related to the Operator step<br>
                            <b>M</b> - the row is related to the Fixed, Rebate, or Lump Sum step
                        </td>
                    </tr>
                    <tr>
                        <td>Header Action</td>
                        <td>Yes</td>
                        <td>A = Add<br>R = Revise</td>
                        <td>
                            <b>A</b> - use for adding/inserting a new program<br>
                            <b>R</b> - use for revising an existing program
                        </td>
                    </tr>
                    <tr>
                        <td>External Program</td>
                        <td>No</td>
                        <td>Program Reference Number</td>
                        <td>
                            An optional string of characters, which will be stored in the Reference Number 2 field,  max 100 characters
                        </td>
                    </tr>
                    <tr>
                        <td>FORGE Program</td>
                        <td>Yes if Header Action = R</td>
                        <td>FORGE program ID</td>
                        <td>
                            The FORGE Program ID. It should be PRG + the base seven digits (Ex: PRG-1234567)<br>
                            This is the key for Revise
                        </td>
                    </tr>
                    <tr>
                        <td>Title</td>
                        <td>Yes for Header row</td>
                        <td>Program title</td>
                        <td>
                            A string of characters which will be stored in the Program Title field, max 255 characters
                        </td>
                    </tr>
                    <tr>
                        <td>Start</td>
                        <td>Yes for Header row</td>
                        <td>Start Date of program</td>
                        <td>
                            The program's start date, format: MM/DD/YY
                        </td>
                    </tr>
                    <tr>
                        <td>End</td>
                        <td>Yes for Header row</td>
                        <td>End Date of program</td>
                        <td>
                            The program's end date, format: MM/DD/YY
                        </td>
                    </tr>
                    <tr>
                        <td>RSP ID</td>
                        <td>Yes for Header row</td>
                        <td>User ID (the one for login)</td>
                        <td>
                            The RSP (Responsible Sales Person) of the program<br>
                            See Detail Information section on the Program Upload page for values
                        </td>
                    </tr>
                    <tr>
                        <td>Position ID</td>
                        <td>Yes for Header row</td>
                        <td>Position ID</td>
                        <td>
                            The RSP's Position ID<br>
                            See Detail Information section on the Program Upload page for values
                        </td>
                    </tr>
                    <tr>
                        <td>Sold To</td>
                        <td>Yes for Customer row</td>
                        <td>Distributor ID</td>
                        <td>
                            The ID for the Distributor on the program
                        </td>
                    </tr>
                    <tr>
                        <td>Operator ID</td>
                        <td>yes for Operator row</td>
                        <td>Operator ID</td>
                        <td>
                            The ID for the Operator on the program
                        </td>
                    </tr>
                    <tr>
                        <td>Material</td>
                        <td>yes for Material row</td>
                        <td>Material ID</td>
                        <td>
                            The ID for the Material on the program
                        </td>
                    </tr>
                    <tr>
                        <td>Rate</td>
                        <td>yes for Material row</td>
                        <td>Rate</td>
                        <td>
                            Price/Rate for the Material (Ex: 1.250000)
                        </td>
                    </tr>
                    <tr>
                        <td>UOM</td>
                        <td>yes for Material row</td>
                        <td>UOM</td>
                        <td>
                            Rate UOM for Material<br>
                            Acceptable UOM values are based on the template selected<br>
                            See Detail Information section on the Program Upload page for values (Ex: CS, LB, %)
                        </td>
                    </tr>
                    <tr>
                        <td>Discount Type</td>
                        <td>yes for Material row</td>
                        <td>Discount Type</td>
                        <td>
                            Acceptable Discount Type values are based on the template selected<br>
                            See Detail Information section on the Program Upload page for values (Ex: F = Fixed Price, R = Rebate, L = Lump Sum)
                        </td>
                    </tr>
                    <tr>
                        <td>Component</td>
                        <td>yes for Material row</td>
                        <td>Component name</td>
                        <td>
                            Acceptable Component values are based on the template selected<br>
                            See Detail Information section on the Program Upload page for values
                        </td>
                    </tr>
                    <tr>
                        <td>Pays To</td>
                        <td>yes for Material row</td>
                        <td>Pays To</td>
                        <td>
                            The Pays To portion of the component<br>
                            Acceptable Pays To values are based on the template selected<br>
                            See Detail Information section on the Program Upload page for values (Ex: D = Distributor, O = Operator)
                        </td>
                    </tr>
                    <tr>
                        <td>Frequency</td>
                        <td>yes for Material row</td>
                        <td>Frequency</td>
                        <td>
                            The Payment Frequency associated to the component<br>
                            Acceptable payment Frequency values are based on the template selected<br>
                            See Detail Information section on the Program Upload page for values (Ex: Monthly, Quarterly, Upon Due)
                        </td>
                    </tr>
                    <tr>
                        <td>Claim Mechanic</td>
                        <td>yes for Material row</td>
                        <td>Claim Mechanic</td>
                        <td>
                            The Claim Mechanic associated to the component<br>
                            Acceptable Claim Mechanic values are based on the template selected<br>
                            See Detail Information section on the Program Upload page for values (Ex: billback, deduction)                            
                        </td>
                    </tr>
                    <tr>
                        <td>Currency</td>
                        <td>yes for Material row</td>
                        <td>Currency</td>
                        <td>
                            The Currency related to the component<br>
                            Acceptable Currency values are based on the template selected<br>
                            See Detail Information section on the Program Upload page for values (Ex: USD, CAD)                            
                        </td>
                    </tr>
                    <tr>
                        <td>Volume</td>
                        <td>yes for Material row</td>
                        <td>Volume</td>
                        <td>
                            Estimated Volume value related to the Material<br>
                        </td>
                    </tr>
                    <tr>
                        <td>Volume UOM</td>
                        <td>yes for Material row</td>
                        <td>Volume UOM</td>
                        <td>
                            The Unit of Measure related to the Volume entered<br>
                        </td>
                    </tr>
                </table>
                    
            </div>


        </div>


        <script>
   
        </script>
        
    </body>
</html>