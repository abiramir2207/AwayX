<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\whatif\edit_what_if.cfm
      Label:    45383
      Date:     2014 October
      Author:   Chris Nguyen
      Purpose:  Edit what if generic ( no program )

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
      .btn-primary { font-weight:bold; }
  </style>
</head>

<body>
<cfif CGI.Request_Method eq "post">
    <cfset variables.whatIfCFC = createObject("component", "components.programs.whatif")>
    <cfif form.action eq "save">
      <cfset form.id = variables.whatIfCFC.saveWhatIf()>
      <cfoutput><cflocation url="\common_files\whatIF\edit_what_if_product.cfm?id=#form.id#"></cfoutput>

    <cfelseif form.action eq "bail">
      <!--- unlock record prior to going back to the list --->
      <cfif form.whatIF_ID neq '0'>
        <cfset variables.whatIfCFC.updateLock( form.whatIF_ID, "readonly")>
      </cfif>
      <cfoutput><cflocation url="\common_files\whatIF\list_what_if.cfm"></cfoutput>
    </cfif>
</cfif>

<cfscript>
  variables.whatIfCFC      = createObject("component", "components.programs.whatif");
  variables.qWhatIf        = variables.whatIfCFC.getWhatIf( url.id );
  variables.qWhatIfProduct = variables.whatIfCFC.getWhatIfProduct( url.id );
</cfscript>


<fieldset>
    <cfoutput><legend class="legend"> #(url.id eq '0' ? "Create New" : "Edit")# What If P&L </legend></cfoutput>
    <form name="whatIF" method="post">
    <cfoutput>
    <input type="hidden" name="action">
    <input type="hidden" name="whatIF_ID" value="#url.id#">
    <input type="hidden" name="products" value="#valueList(variables.qWhatIfProduct.BSA_Foodservice_Items_Master_ID)#">
    </cfoutput>
    <div id="hdr239">
        <cfoutput>
        <label>Title:</label> <input type="text" name="title" value="#variables.qWhatIf.Title#" size="50">
        <label>Description:</label> <input type="text" name="description" size="150" value="#variables.qWhatIf.Description#"><br>
        </cfoutput>
    </div>

    <!--- previously selected products --->
    <div id="prod211">
        <cfoutput><label class="red">Previously Selected #application.returned_customer_setting.Item_Label#s:</label></cfoutput>
        <cfif variables.qWhatIfProduct.recordCount eq 0> none</cfif>
        <cfoutput query="variables.qWhatIfProduct"><cfif variables.qWhatIfProduct.currentRow gt 1>, </cfif>#variables.qWhatIfProduct.Item#</cfoutput>
    </div>

    <!--- display non-group products and allow multiple selections --->
    <cfmodule template="/customTags/choose_product.cfm"
              products_input_name="products"/>

    <div class="clear"></div>

    <div id="opt947">
      <cfoutput>
       <a href="##" id="save951">#application.util.string.actionLinkFormat2("save & continue", "important")#</a>
       <a href="\common_files\whatIF\list_what_if.cfm" id="bail951">#application.util.string.actionLinkFormat2("or return to list", "cancel")#</a>
       <!--- <a href="/Manufacturers/home.cfm">#application.util.string.actionLinkFormat2("return home")#</a> --->
      </cfoutput>
    </div>
    </form>
</fieldset>

<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>

<script>
    $('#Page_Title', window.parent.frames[0].document).text("What If P&L");

    <!---
    $("#bail951").click(function() {
        $('input[name=action]').val( 'bail' );
        $('form[name="whatIF"]').submit();
    });
     --->

    $("#save951").click(function() {
        var errors = [];
        if ( $('input[name=title]').val() == "" ) {
            errors.push( "You forgot to enter a title." );
        }

        selected_products();

        /* at least 1 product must be selected */
        if ( $('input[name=products]').val() == "" ) {
            errors.push( "You forgot to choose a product." );
        }

        if ( errors.length ) {
            // alert( errors.join("\n") + "\n\nPlease make the corrections and try again." );
            noty( {  text: errors.join("<br>") + "<br><br>Click OK to make the corrections & try again."
                    ,type:'error'
                    ,buttons: [  { text:'OK', addClass:'btn-primary', onClick:function($noty) {  $noty.close(); } } ]
                    ,layout:'center' });
            return false;
        }

        $('#opt947').html("<span class='legend'>Processing...</span>");
        $('body').fadeOut(350);

        $('input[name=action]').val( 'save' );
        $('form[name="whatIF"]').submit();
    });
</script>
</body>
</html>