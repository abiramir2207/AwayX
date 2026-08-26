<cfsilent>
<!---  
       Name:          upload_instructions.cfm           
       Copyright:     Copyright (c) 2010 Blacksmith Applications, Inc.       
       Created Date:  12/01/2010
       Created By:    Kal
       Label:		  25195
       Description:   Mass Program Change Upload Utility
--->
</cfsilent>

<!--- css --->
<link rel="stylesheet" type="text/css" href="/common_files/upload_styles.css">

<div class="displayHeader">
	Using the mass price change tool
</div>

<div class="Instructions">
	<ul>
		<li>Select one ore more templates.</li>
		<li>Pick a unit of measure for the increase. [5.00 % or 0.50/Cs]</li>
		<li>Pick an effective date for the price increase. This the date the new program version will start from.</li>
		<li>Upload an Excel(xlsx/xls) file with two fileds, PRODUCT_ID and RATE as headers.</li>
		<li>In the PRODUCT_ID column use the Prod_Var_B values. For RATE enter a value of how much the increase should be by. 
			<ul>
		      	<li> UOM = M; Rate = 1.00 will increase the price by $1/M. Old price = 3/M, New price = [3.00 +1.00] = 4M </li>
				<li> UOM = %; Rate = 5.00 will increase the price by 5%. Old price = 3/M, New price = [3 + 3x(5/100)] = [3 + 0.15] = 3.15/M </li>
			</ul>
		</li>
		<li>File will be uploaded and validated. A larger file might take a while to upload/validate. </li>
		<li>Invalid Prod_Var_B will be removed from the file and the rest will be uploaded. Prod_Var_B's removed will be listed on screen. </li>
		<li>If no valid products were found then upload form will display, otherwise an option to execute/cancel the price increase will display. </li>
		<li>To continue with price increase click the execute option. At this point the programs will revise and prices will be increased on the revisions.  </li>
		<li>After the process completes, a link to download the report will display. </li>
	</ul>
</div>
