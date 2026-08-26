<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      Template:  \Common_Files\Programs\emailsubject.cfm
          Date:  March 9 2012
        Author:  Chris Nguyen
       Purpose:  Return email subject for approved/rfa/cancelled/expired/pending/revised programs

         Usage:   1.  Include this template prior to calling the EmailSubject() function:

                        <cfinclude template="/Common_Files/Programs/emailsubject.cfm"/>   <!--- 30738 --->

                  2.  Call EmailSubject() function and pass in contract number, contract title and subject message

                        <cf_emailwrapper
                          to      = "#finalEmailAddress#;cnguyen@bigredflame.com"
                          from    = "#uEmail#"
                          subject = "#EmailSubject( getThisProgramsStatusEmail.Contract_Number         <!--- 30738 --->
                                                  ,getThisProgramsStatusEmail.Contract_Title
                                                  ,'has been approved')#">

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

<cffunction name="EmailSubject" output="false">
  <cfargument name="contract_number" type="string" required="false" default="" hint="" displayname="contract_number" />
  <cfargument name="contract_title" type="string" required="false" default="" hint="" displayname="contract_title" />
  <cfargument name="message" type="string" required="false" default="" hint="" displayname="message" />

  <!--- place the first 6 words from program title in the middle (wrapped it inside a pair of double quotes) --->
  <cfreturn 'Program ' & arguments.contract_number & ' "' & getWords(arguments.contract_title, 6) & '" ' & arguments.message>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

<cffunction name="getWords" output="false">
  <cfargument name="str" required="true">
  <cfargument name="words" required="true">

  <cfscript>
  /**
   * Shortens a string without cutting words in half.
   * Modified by Raymond Camden on July 30, 2001
   *
   * @param str      The string to modify.
   * @param words      The number of words to display.
   * @author David Grant (david@insite.net)
   * @version 2, July 30, 2001
   */
      var numWords = 0;
      var oldPos = 1;
      var i = 1;
      var strPos = 0;

      str = trim(str);
      str = REReplace(str,"[[:space:]]{2,}"," ","ALL");
      numWords = listLen(str," ");
      if (words gte numWords) return str;
      for (i = 1; i lte words; i=i+1) {
          strPos = find(" ",str,oldPos);
          oldPos = strPos + 1;
      }
      if (len(str) lte strPos) return left(str,strPos-1);
      return left(str,strPos-1) & "...";
  </cfscript>
</cffunction>
