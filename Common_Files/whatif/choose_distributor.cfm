<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\whatif\choose_distributor.cfm
      Label:    45383
      Date:     2014 October
      Author:   Chris Nguyen
      Purpose:  Choose distributor for what if generic

      Notes:

----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html>
<head>
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
  <style>
      #hdr239 input { margin-right:15px; }
      #hdr239 { margin:0 0 10px 0; }
      #opt947 a { margin-right: 15px; }
      #opt947 { margin: 5px; }
      #prod211 { margin: 5px 0 20px;}
      .center { text-align: center; }
      .clear { clear:both; }
      .columnfilter { width:99%; }
      .red { color:red; }
      fieldset { padding:10px; border:1px solid blue; }
      hr { margin: 15px 0 ; }
      label { font-weight: bold; }
  </style>
</head>

<body>
<cfif CGI.Request_Method eq "post">
    <cfset variables.whatIfCFC = createObject("component", "components.programs.whatif")>
    <cfset variables.whatIfCFC.saveDistributor()>

    <cfoutput><cflocation url="\common_files\whatIF\edit_what_if_product.cfm?id=#form.id#"></cfoutput>
</cfif>

<cfscript>
  variables.whatIfCFC      = createObject("component", "components.programs.whatif");
  variables.qWhatIf        = variables.whatIfCFC.getWhatIf( url.id );
</cfscript>

<fieldset>
    <cfoutput><legend class="legend"> #(url.id eq '0' ? "Create New" : "Edit")# What If P&L - Select #application.returned_customer_setting.Distributor_Label_Singular#</legend></cfoutput>
    <form name="whatIF" method="post">
    <cfoutput>
    <input type="hidden" name="id" value="#url.id#">
    <input type="hidden" name="distributor" value="#variables.qWhatIf.shr_ship_to#">
    <div id="hdr239">
        <label>Title:</label> <input type="text" name="title" value="#variables.qWhatIf.Title#" size="50" DISABLED>
        <label>Description:</label> <input type="text" name="description" size="150" value="#variables.qWhatIf.Description#" DISABLED><br>
    </div>

    <!--- previously selected products --->
    <div id="prod211">
        <label class="red">Previously Selected #application.returned_customer_setting.Distributor_Label_Singular#:</label>
        <b>#variables.qWhatIf.Distributor_Name#</b>
    </div>
    </cfoutput>

    <!--- display active distributors and allow a single selection --->
    <cfmodule template = "/customTags/choose_distributor.cfm"
              multiple_selection = 0
              distributors_input_name = "distributor"/>

    <div class="clear"></div>

    <div id="opt947">
      <cfoutput>
       <a href="##" id="save951">#application.util.string.actionLinkFormat2("save & continue", "important")#</a>
       <a href="/common_files/whatif/list_what_if.cfm" id="bail951">#application.util.string.actionLinkFormat2("or return to listing", "cancel")#</a>
       <!--- <a href="/Manufacturers/home.cfm">#application.util.string.actionLinkFormat2("return home")#</a> --->
      </cfoutput>
    </div>
    </form>
</fieldset>


<script>
    $('#Page_Title', window.parent.frames[0].document).text("What If P&L");

    $("#save951").click(function() {
        var errors = [];

        selected_distributors();

        // alert ( $('input[name=distributor]').val() ); return false;

        /* at least 1 distributor must be selected */
        if ( $('input[name=distributor]').val() == "" ) {
            errors.push( "You forgot to choose a distributor." );
        }

        if ( errors.length ) {
            alert( errors.join("\n") + "\n\nPlease make the corrections and try again." );
            return false;
        }

        $('#opt947').html("<span class='legend'>Processing...</span>"); $('body').fadeOut(350);
        $('form[name="whatIF"]').submit();
    });
</script>
</body>
</html>