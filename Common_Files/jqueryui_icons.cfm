<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template:  \common_files\jqueryui_icons.cfm
          Date:  2016 September
        Author:  Chris Nguyen
       Purpose:  Include a collection of jQuery UI icons with optional color defined in "jqueryui_icons.color" variable
                 (default to orange if the color is not specified).  All icons are stored in one .png file and being used
                 with CSS sprites to help performance.

                 See the list of icons at http://roam.be/lab/jquery-ui-icon-name-map/

                 Download link for other color (replace color hex number after /ui-icons_) is available at:

                 http://download.jqueryui.com/themeroller/images/ui-icons_000000_256x240.png
----------------------------------------------------------------------------------------------------------------------->
<cfscript>
  colors.white         = "ffffff";
  colors.blue          = "0000ff";
  colors.red           = "ff0000";
  colors.green         = "00ff00";

  colors.black         = "000000";
  colors.orange        = "FFA500";
  colors.indigo        = "4B0082";
  colors.navy          = "000080";
  colors.midnight_blue = "191970";
  colors.dark_gray     = "333333";

  colors.to_use        = (isDefined("jqueryui_icons.color") ? colors[ jqueryui_icons.color ] : colors[ "dark_gray" ]);
</cfscript>
</cfsilent>
<cf_include files="/script/javascript/jQueryUI_1_11/jquery-ui.css">
<style>
  .ui-icon { background-image: url(/images/jqueryui_icons/ui-icons_<cfoutput>#colors.to_use#</cfoutput>_256x240.png) !important; }
</style>
