<!---
  * ====================================================================================================
  *    @File: \common_files\popup2022.cfm
  *  @Author: Chris Nguyen
  *    @Date: December 2021
  *
  * @Remarks: Open popup based on easy to understand sizes XS, SM, MD, LG, XL & on user screen dimension
  *
  * ====================================================================================================
--->


<cfscript>
    // retrieve a JSON format percentage dimension setting
    popup_json = application.util.query.get_setting("Popup_dimensions", 0);

    // JSON setting is missing (not expected), use a default
    if ( isJSON( popup_json ) ) {
        popup_dimensions = deserializeJSON( popup_json );
    }
    else {
        popup_dimensions = {};
    }

    // default percentages in case they are missing
    param name="popup_dimensions.height_xl" default=0.85;
    param name="popup_dimensions.height_lg" default=0.75;
    param name="popup_dimensions.height_md" default=0.5;
    param name="popup_dimensions.height_sm" default=0.35;
    param name="popup_dimensions.height_xs" default=0.25;

    param name="popup_dimensions.width_xl"  default=0.85;
    param name="popup_dimensions.width_lg"  default=0.75;
    param name="popup_dimensions.width_md"  default=0.65;
    param name="popup_dimensions.width_sm"  default=0.5;
    param name="popup_dimensions.width_xs"  default=0.35;
</cfscript>


<script>
    <cfoutput>
        /* Convert popup dimension settings into JS object, expected structure:
            {   height_sm: 0.00,   // range from 0 to 1, where 1 is 100% of the screen dimension
                height_md: 0.00,
                height_lg: 0.00,
                height_xl: 0.00,
                height_xs: 0.00,
                width_xs:  0.00,
                width_sm:  0.00,
                width_md:  0.00,
                width_lg:  0.00,
                width_xl:  0.00             } */
        var #toScript(popup_dimensions, "popup_dimensions")#;
    </cfoutput>


    /* Convert XS, SM, MD, LG, XL sizes into pixels based on user screen dimension */
    function popup_dimension( given_width, given_height ) {
        /* define maximum sizes to avoid big popups on ultra large monitors */
        let max_widths  = { xs:800, sm:1100, md:1400, lg:1600, xl:1800 };
        let max_heights = { xs:300, sm:400,  md:600,  lg:900,  xl:1000 };

        // arbitrary default dimension
        let result = { width:max_widths.sm, height:max_heights.md };

        /* turn the given size arguments into lowercase */
        const width_lc  = given_width.trim().toLowerCase();
        const height_lc = given_height.trim().toLowerCase();

        /* unexpected given width */
        if (typeof( max_widths[ width_lc ] ) === "undefined") {
            /* default to a tiny popup for developers to fix the parameters */
            result.width  = 300;
            result.height = 300;
            console.log( "Unexpected width = ", given_width );
        }
        else {
            /* avoid being too wide on ultra large monitors */
            result.width = Math.min( popup_dimensions[ "width_" + width_lc ] * screen.width * window.devicePixelRatio, max_widths[ width_lc ] );
        }

        /* unexpected given height */
        if (typeof( max_heights[ height_lc ] ) === "undefined") {
            /* default to a tiny popup for developers to fix the parameters */
            result.width  = 300;
            result.height = 300;
            console.log( "Unexpected height = ", given_height );
        }
        else {
            /* avoid being too tall on ultra large monitors */
            result.height = Math.min( popup_dimensions[ "height_" + height_lc ] * screen.height * window.devicePixelRatio, max_heights[ height_lc ] );
        }
        return result;
    }


    function popupCenter2022( url, title, width, height ) {
        return popup2022( url, title, width, height, "center" );
    }

    /* open a popup window and send a form into it - form object is the only required parameter */
    function popup2022_form(form, title, w, h) {
        title = title || "_popup_" + random367();
        form.target = title;
        return popupCenter2022("", title, w, h);
    }

    function popup2022( url, title, width, height, position ) {
        title  = title  || "";
        width  = width  || "md";
        height = height || "md";
        position = position || "";

        if (title.trim() === '') {
            title = "_popup_" + Math.random().toString(36).substring(7);
        }

        // convert popup width/height into pixels and figure out the position coordinate
        let popup = popup_dimension( width, height );

        let browser_tab_url_height = 70;

        switch ( position.toLowerCase().trim() ) {
            case 'center':
                position = {  left: Math.floor( ( ( screen.availWidth * window.devicePixelRatio ) - popup.width ) / 2 )
                              ,top: Math.floor( ( ( screen.availHeight * window.devicePixelRatio ) - ( popup.height  + browser_tab_url_height ) ) / 2 ) };
                break;

            default:
                position = { top: 0, left: 0 };
                break;
        }

        // console.log( position, screen, popup, window.devicePixelRatio );
        return window.open( url, title, "scrollbars, resizable, width=" + popup.width + ", height=" + popup.height + ", top=" + position.top + ", left=" + position.left );
    }
</script>
