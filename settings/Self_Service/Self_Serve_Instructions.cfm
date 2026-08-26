<!---
  * ====================================================================================================
  *    @File:   AwayX\settings\Self_Service\instructions.cfm
  *    @Author: Anand Rao
  *    @Date:   16 Sep 2024
  *
  *    @Remarks: Planner Volume Upload Main Page
  *
  * ====================================================================================================
--->

<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Upload Instructions</title>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
    </head>
    <body>
        <style>
            html {
                font-size: 62.5%;
            }
            * {
                box-sizing: border-box;
            }
            body {
                font-size: 1.2rem;
            }
            .container {
                margin-left: 0.75rem;
            }
            table {
                border-collapse: collapse;
                color: #343540;
                margin-left: 25px;
                width: 100ch;
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
            ol {
                // padding: 3rem;
            }
            li {
                width: 100ch;
            }
        </style>

        <div class="page_title1"> Instructions for Planner Volume Excel Upload </div>

        <div class="container">
            <h3>Upload Overview</h3>
            <ul>
                <li>The first row must be the header with the column names. </li>
                <li>The second row and all following rows contain self serve data.</li>
                <li>The end of file should be the last row with data and should be no empty rows.</li>
                <li>Make sure the columns for the date is in the date format with yyyy-mm-dd format in excel.</li>
                <li>BB_Reference column should be of type text. the Length of the reference cannot exceed 255 characters.</li>
                <li>The Distributor column should be of type text.</li>
                <li>For "Move Billbacks from RFA or Approved to Paid"<br> 
                        a) >= RFA or < Paid <br> 
                        b) BB should have a Program and that program should not be the default program.<br> 
                        c) BB should have a valid Payee.<br> 
                        d) BB should have either products or have lumpsum component.</li>

<li> For "Move Billbacks from RFA or Approved to Paid" option<br>
    a) We are not updating the interface flag<br>
    b) If the BB has the closing method "Deduction", we will not match to a Deduction.</li>

<li>For "Update Program and component on billback" option<br>
    a) The required fields are BB_Code, Program, Action_By_User_code and Component is optional.<br>
    b) BB cannot have multiple programs.<br>
    c) When the component is not given; use the given program and find the component that matches on:<br>
        i)  Dates(Program dates should match the BB delivery dates)<br>
        ii) Pays to(Program's component pays to should match Billback's Payee type)<br>
        iii) Component's restrict from billback should be off<br>
    d) When a component is given in the file we will not check the dates but we will match on <br>
        i) Pays to(Program's component pays to should match Billback's Payee type)<br>
        ii)Component's restrict from billback should be off<br>
    e) We will not update the program if the program has more than one component that has the same pays to<br>
    f) If the current program on the billback has a Rebate or Fixed price discount type we will only update it to Rebate or Fixed <br>Price and not Lumpsum. If there are products on the Billback, and the discount type on the current program is different from the discount type on the uploaded program, then we will update the billback to have the discount type of the uploaded program.<br>
    g) If the current program on the billback has a lumpsum discount type we will not update it to Rebate or Fixed price.<br>
    h) If a component is given for the program it should be match the component name exactly as in the program.<br>
    i) The user cannot repeat the same Billback twice. </li>
<li>For "Update item volume on billback" option:
    a) The required fields are BB_Code, Item, Cases, Action_By_User_code.<br>
    b) BB cannot have multiple programs.<br>
    c) The Final Paid amount remains the same we are only updating the volume that are in Cases(UOM).<br>
    d) In the excel the cell format for cases should be set to numeric with no commas or any other special characters. <br>
    e) The item should be present on the BB.<br>
    f) BB should be in status Paid or Approved-void.</li>
            </ul>

             <h3>Excel Columns</h3>
            <table>
                <tr>
                    <th>Field Name</th>
                    <th>Required for below actions</th>
                    <th>Optional</th --->
                </tr>
                
                <tr>
                    <td>BB_Code</td>
                    <td>- All</td>
                    <td></td>
                    
                </tr>
                <tr>
                    <td>BB_Reference</td>
                    <td>- Update BB Reference Number</td>
                    <td></td>
                </tr>
                <tr>
                    <td>BB_Start_Date</td>
                    <td>- Update BB Delivery Dates</td>
                    <td></td>
                </tr>
                <tr>
                    <td>BB_End_Date</td>
                    <td>- Update BB Delivery Dates</td>
                    <td></td>
                </tr>
                <tr>
                    <td>Operator</td>
                    <td>- Update Operator on billback </td>
                    <td></td>
                </tr>
                <tr>
                    <td>Distributor</td>
                    <td>- Update Customer on billback</td>
                    <td></td>
                </tr>
                <tr>
                    <td>Item</td>
                    <td>- Update item volume on billback</td>
                    <td></td>
                </tr>
                <tr>
                    <td>Program</td>
                    <td>- Update Program and component on billback</td>
                    <td></td>
                </tr>
                <tr>
                    <td>Component</td>
                    <td></td>
                    <td>- Update Program and component on billback</td>
                </tr>
                <tr>
                    <td>Cases</td>
                    <td>- Update item volume on billback</td>
                    <td></td>
                </tr>
                 <tr>
                    <td>Action_By_User_Code</td>
                    <td>- All</td>
                    <td></td>
                </tr>
 
            </table>
         </div>


        <script>
   
        </script>
        
    </body>
</html>