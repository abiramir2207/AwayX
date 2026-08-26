

<!--- ----------------------------------------------------------------------------------------- --->
<!--- used by the date pickers --->
<!--- ----------------------------------------------------------------------------------------- --->
<script type="text/javascript" src="datepickers_code/datepickr.js"></script>
<link rel="stylesheet" type="text/css" href="datepickers_code/datepickr.css">


<CFIF url.msgid NEQ 0>

			<!--- ----------------------------------------------------------------------------------------- --->
			<!--- THIS SECTION UPDATES A MESSAGE --->
			<!--- ----------------------------------------------------------------------------------------- --->

			<div class="page_title">UPDATE THIS ADMIN MESSAGE</div>
			<div class="group_content" style="padding:0px 10px 0px 10px;">
			
			<!--- get the details for this message --->
				
			<cfquery name="getdata" datasource="#db_connection#">
	 		Select		*
			From		msg_ctr_admin_msgs
			Where		msg_ctr_admin_msgs.msg_ctr_admin_id	=	'<cfoutput>#url.msgid#</cfoutput>'
			</cfquery>
					
			
			<form action="index.cfm?id=18573-15912-55267-38595" method="post" name="form_name">
			<INPUT name="msg_ctr_admin_id" type="hidden" value="<cfoutput>#url.msgid#</cfoutput>">
			<table class="messages" width="100%" style="background-color:#FFFFFF;">
				<tr>
					<td class="messages indent" colspan="100%"  style="font-size:14px; font-weight:bold;">

						Message text (max 350 characters):
						<hr>
						<textarea
							name="msg_ctr_admin_txt"
							cols="68" 
							rows="5" 
			                maxlength="350" 
			                id="textbox"
			                onFocus="countChars('textbox','char_count',350)" 
			                onKeyDown="countChars('textbox','char_count',350)" 
			                onKeyUp="countChars('textbox','char_count',350)"><cfoutput>#getdata.msg_ctr_admin_txt#</cfoutput></textarea>
				            <br />
				            <p style="color:red; font-size:10px;"> <span id="char_count"></span> characters left.<br />

					</td>
				</tr>
				<tr>
					<td class="messages indent" style="font-size:14px; font-weight:bold;">
						
						<br/>
						Display the message between these dates:
						<hr>
						Start date: <input  id="datepick1" type="text" name="msg_ctr_start_date" value="<cfoutput>#dateformat(getdata.msg_ctr_start_date, 'mm/dd/yy')#</cfoutput>" style="width:100px;" readonly>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						Ending date: <input  id="datepick2" type="text" name="msg_ctr_end_date" value="<cfoutput>#dateformat(getdata.msg_ctr_end_date, 'mm/dd/yy')#</cfoutput>" style="width:100px;" readonly>
						<br/>
						<span style="color:red; font-size:10px;">Ending date must be greater than or equal to the start date.</span>
						<br/><br/>
					</td>
					<td class="messages">&nbsp;</td>
					<td class="messages">&nbsp;</td>
				</tr>
			</table>
			<input name="submit_name" type="submit" value="save this admin message" />
			</form>
			
			</div>

<CFELSE>


			<!--- ----------------------------------------------------------------------------------------- --->
			<!--- THIS SECTION CREATES A NEW MESSAGE --->
			<!--- ----------------------------------------------------------------------------------------- --->

			<div class="page_title"><cfoutput>#title#</cfoutput></div>
			<div class="group_content" style="padding:0px 10px 0px 10px;">
							
			<form action="index.cfm?id=18573-15912-55267-38595" method="post" name="form_name">
			<INPUT name="msg_ctr_admin_id" type="hidden" value="0">
			<table class="messages" width="100%" style="background-color:#FFFFFF;">
				<tr>
					<td class="messages indent" colspan="100%"  style="font-size:14px; font-weight:bold;">
						<br/>
						Message text (max 350 characters):
						<hr>
						<textarea
							name="msg_ctr_admin_txt"
							cols="68" 
							rows="5" 
			                maxlength="350" 
			                id="textbox"
			                onFocus="countChars('textbox','char_count',350)" 
			                onKeyDown="countChars('textbox','char_count',350)" 
			                onKeyUp="countChars('textbox','char_count',350)"></textarea>
				            <br />
				            <p style="color:red; font-size:10px;"> <span id="char_count"></span> Characters left.<br />
					</td>
				</tr>
				<tr>
					<td class="messages indent" style="font-size:14px; font-weight:bold;">
						
						<br/>
						Display the message between these dates:
						<hr>
						Start date: <input  id="datepick1" type="text" name="msg_ctr_start_date" style="width:100px;" readonly>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						Ending date: <input  id="datepick2" type="text" name="msg_ctr_end_date" style="width:100px;" readonly>
						<br/>
						<span style="color:red; font-size:10px;">Ending date must be greater than or equal to the start date.</span>
						<br/><br/>
					</td>
					<td class="messages">&nbsp;</td>
					<td class="messages">&nbsp;</td>
				</tr>
			</table>
			<input name="submit_name" type="submit" value="save this admin message" />
			</form>
			
			</div>	

</CFIF>



<!--- ----------------------------------------------------------------------------------------- --->
<!--- used by the date pickers --->
<!--- ----------------------------------------------------------------------------------------- --->

		<script type="text/javascript">

			new datepickr('datepick1', {
				'dateFormat': 'm/d/y'
			});

			new datepickr('datepick2', {
				'dateFormat': 'm/d/y'
			});			

		</script>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- script used to track how many characters there are in a textbox. it limits it to 250 char --->
<!--- ----------------------------------------------------------------------------------------- --->
<script>
function countChars(textbox, counter, max) {
  var count = max - document.getElementById(textbox).value.length;
  if (count < 0) { document.getElementById(counter).innerHTML = "<span style=\"color: red;\">" + count + "</span>"; }
  else { document.getElementById(counter).innerHTML = count; }
}
</script>
<!--- ----------------------------------------------------------------------------------------- --->









