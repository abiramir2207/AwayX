FILE: Custom Tag - /common_files/contracts/letters/auto_generate_gateway.cfm

5/05/2008 BLee@BigRedFlame.com Brad Lee [RBL]

LEGEND:
[bAddCustomerProductNumbers] 1=ADD customer product numbers, 0=do NOT add customer product numbers (user would have to go back and actually edit these) [REQUIREMENTS ]
[bAuto] 1=AUTO generated letters via scheduled tasks such as this, 0=manually by contract main id (these should always be 1)
[bFormSubmitted] 1=THIS FORM /common_files/contracts/letters/auto_generate_form.cfm WAS submitted 0=THIS FORM was NOT
[bLetterDisplayFreight] 1=INCLUDE freight summary 0=do NOT include freight summary
[bIncludeVolumePage] 1=INCLUDE volume summary 0=do NOT include volume summary
[bInsertWatermark] 1=INSERT a watermark for each letter using the client's logo in application per user/environment 0=do NOT insert a watermark
[bListLast] 1=if this contract_main_id is the last in the current batch getting looped over (list or array, etc.) SEE EXAMPLE ABOVE.
[contract_main_id] each iteration of this CT expects ONE contract_main_id. As shown above, obviously this can be looped over. If string, employ trim()
[customerFreightUom] lb=Pounds will be the UOM for the freight summary area cs=Cases will be the UOM for the freight summary area. This does not affect any other area within the letters.
[distributor_letter_type] 1=one distributor per distributor letter, 2=multiple distributors per distributor letter
[dis_letter_settings] 1=one operator per distributor letter, 2=all operators per distributor letter
[letter_type] 1=operator, 2=distributor, 3=both
[notification_type] 2=generate letters WITHOUT email notification  (MUST always be 2 here)
[operator_letter_type] 1=one operator per operator letter, 2=multiple operators per operator letter
[opr_letter_settings] 1=one distributor per operator letter, 2=all distributors per operator letter
[timeout_seconds] letters avergae about 2 minutes per letter without the freight page at 1 dis per dis ltr and 1 opr per opr ltr
[user_id] user_id is required for full functionality. A valid user_id MUST be submitted.

PURPOSE: Auto Generation of One or Multiple Program ID Letters without going through the normal form: contracts/contract_letters.cfm

all is in the thisTag scope.

|||||||||||||||||||||||||||||||||||||||||

4/1/2008 DEFAULT SETTINGS FOR BATCH LETTERS POST MASS/PRICE FREIGHT UPDATE PER KAREN WOULD BE:

<cfmodule
          template="/common_files/contracts/letters/auto_generate_gateway.cfm"
          bAddCustomerProductNumbers="0"
          bAuto="1"
          bFormSubmitted="0"
          bLetterDisplayFreight="1"
          bIncludeVolumePage="0"
          bInsertWatermark="0"
          bListLast="#variables.bListLast#" <!--- note: see loop example this doc --->
          contract_main_id="#trim(variables.current_contract_main_id)#"
          customerFreightUom="CS"
          distributor_letter_type="1"
          dis_letter_settings="2"
          letter_type="3"
          notification_type="2"
          operator_letter_type="1"
          opr_letter_settings="2"
	  	  timeout_seconds="3600"  <!--- averages 2 min per letter without the freight page... 1000 ltrs could be 33 hrs --->
		  user_id="" /> <!--- CT user_id will attempt to look for a request scoped user_id, IF none it will look for the responsible user_id, but is really expecting a user_id explicitly sent in within the CT call... ---> 

On 4/1/2008 Brad tested these exact settings through the auto_generate_form for these 5 id's: 5130,5237,5238,5239,5268 (5130 is large) It took: m s. After a minute it crashed with a stackTrace error. I believe due to the freight functionality. I cleaned up my folders and SQL table and went back and tried again without freight, and I put 5130 last (a known very large program) and,


|||||||||||||||||||||||||||||||||||||||||

I decided to create a Custom Tag - /common_files/contracts/letters/auto_generate_gateway.cfm and decided to leave it in the /letters folder as of 4/1. To date, all related letters V2.1 files are here. At some future date, perhaps the CT's should move.

In this scenario, to call this CT, one would use this exact code from anywhere in our app... module instead of cf_ syntax. Template instead of name.

I am showing the loop to identify last in for a response to the caller. This is helpful but not required.

I have thought about cfThread and truly feel this should be employed - but it merits quite a bit of thought so it is currently commented out in my code.

All letter settings are for the whole list of Program IDs submitted at one time.

|||||||||||||||||||||||||||||||||||||||||

<cfloop list="#form.contract_main_id#" delimiters="," index="variables.current_contract_main_id">
  
  <!--- legend: we identify our contract_main_id list's last id HERE... --->
  <cfif listLen(form.contract_main_id,',') EQ listFind(form.contract_main_id,variables.current_contract_main_id,',')>
	<cfset variables.bListLast = 1>
  </cfif>
 
        <cfmodule
          template="/common_files/contracts/letters/auto_generate_gateway.cfm"
          bAddCustomerProductNumbers="#form.bAddCustomerProductNumbers#"
          bAuto="#form.bAuto#"
          bFormSubmitted="#form.bFormSubmitted#"
          bLetterDisplayFreight="#form.bLetterDisplayFreight#"
          bIncludeVolumePage="#form.bIncludeVolumePage#"
          bInsertWatermark="#form.bInsertWatermark#"
          bListLast="#variables.bListLast#"
          contract_main_id="#trim(variables.current_contract_main_id)#"
          customerFreightUom="#form.customerFreightUom#"
          distributor_letter_type="#form.distributor_letter_type#"
          dis_letter_settings="#form.dis_letter_settings#"
          letter_type="#form.letter_type#"
          notification_type="#form.notification_type#"
          operator_letter_type="#form.operator_letter_type#"
          opr_letter_settings="#form.opr_letter_settings#" />

    
  </cfloop>

|||||||||||||||||||||||||||||||||||||||||

If you should wish to test a few ID's for the automatic generation, you could visit /common_files/contracts/letters/auto_generate_form.cfm and submit one or more (separate with commas). You may wish to look at the code.

This is an intelligent form and employs a great deal of our business rules for letters. Notice the submit button goes away after one click. I did not surround this page with an ip restricted sandbox. I figured one would have to be logged in to get to it... and KNOW where it is since it is not linked from anywhere. RBL

|||||||||||||||||||||||||||||||||||||||||

INTELLIGENT FORM LOGIC FOR BUSINESS LOGIC DEPENDENCIES ARE EXHIBITED IN THE FOLLOWING SCRIPT SNIPPET FROM /common_files/contracts/letters/auto_generate_form.cfm:

   <cfformitem type="script">
 	public function hideShow()
	{
          if(letter_type.selectedItem.data == 1)
            {
              distributor_letter_type.enabled = false;
              dis_letter_settings.enabled = false; 
              operator_letter_type.enabled = true;
              opr_letter_settings.enabled = true;
                        
              if (opr_letter_settings.selectedItem.data == 1)
                 {
                  bAddCustomerProductNumbers.enabled = true;
                 }
              else
                 {
                  bAddCustomerProductNumbers.enabled = false;
                 } 
           }
          else if (letter_type.selectedItem.data == 2)
           {
              distributor_letter_type.enabled = true;
              dis_letter_settings.enabled = true; 
              operator_letter_type.enabled =false;
              opr_letter_settings.enabled = false;
  
              if (distributor_letter_type.selectedItem.data == 1)
                 {
                  bAddCustomerProductNumbers.enabled = true;
                 }
              else
                 {
                  bAddCustomerProductNumbers.enabled = false;
                 }
            }
           else if (letter_type.selectedItem.data == 3)
            {
               distributor_letter_type.enabled = true;
               dis_letter_settings.enabled = true; 
               operator_letter_type.enabled =true;
               opr_letter_settings.enabled = true;
                        
               if (opr_letter_settings.selectedItem.data == 1 && distributor_letter_type.selectedItem.data == 1)
                  {
                   bAddCustomerProductNumbers.enabled = true;
                  }
               else
                  {
                   bAddCustomerProductNumbers.enabled = false;
                  }
             }
                      
               if(bLetterDisplayFreight.selectedItem.data == 1)
                 {
                   customerFreightUom.enabled = true; 
                 }
               else
                 {
                   customerFreightUom.enabled = false; 
                 }
        }
   </cfformitem>

||||||||||||||||||||||||||||||||||||||||| RBL 4/08

