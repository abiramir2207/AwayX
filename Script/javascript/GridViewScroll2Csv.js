/************************************************************************************************************************************
    File Name: \Script\javascript\GridViewScroll2Csv.js
    Date:      2014 September 23
    Purpose:   Export content of a table (controlled by GridViewScroll() plug-in) to a .csv file

    Remarks:   Created initially to support the new What-if page for Kraft

*************************************************************************************************************************************/
jQuery.fn.table2CSV = function(options) {
    var options = jQuery.extend({
         csvExclude: ''           // single class to be excluded in thead th, tbody tr td - default to nothing (do not filter)
        ,delivery: 'value'        // popup, value
        ,findTHEAD: 'tr.GridviewScrollHeader'    // filter elements in thead tr - default to all tr (do not filter)
        ,findTFOOT: 'tfoot tr'    // filter elements in tfoot tr - default to all tr (do not filter)
        ,findTBODY: 'tr.GridviewScrollItem'    // filter elements in tbody tr - default to all tr (do not filter)
        ,header: []
        ,separator: ','
    },
    options);

    var csvData = [];
    var headerArr = [];
    var el = this;

    //header
    var numCols = options.header.length;
    var tmpRow = []; // construct header available array
    // export table header
    if (numCols > 0) {
        for (var i = 0; i < numCols; i++) {
            tmpRow[tmpRow.length] = formatData(options.header[i]);
        }
         row2CSV(tmpRow);
    } else {
        // go thru each row in thead
        jQuery(el).find( options.findTHEAD ).each(function() {
            tmpRow = [];
            var jThis = jQuery(this);
            jThis.find('th').each(function() {
              // does this element has the exclude class?
              if ( options.csvExclude && jQuery(this).hasClass( options.csvExclude ) ) {
                             // it does have the exclude class, so ignore it
              }
              else {
                if (jQuery(this).css('display') != 'none') {
                    // remove all HTML tags (any pair) - reg-expression pulled from RegexBuddy
                    var tmp = jQuery(this).html().replace(/(<([^>]+)>)/ig,"");
                    tmpRow[tmpRow.length] = formatData( tmp );

                    // determine number of column spans & expand the # of cells
                    var colspan = jQuery(this).prop( "colspan" );
                    if ( typeof colspan === "number" ) {
                      for (var i = 1; i < colspan; i++)
                        tmpRow[tmpRow.length] = '';
                    }
                }
              }
            });
            row2CSV(tmpRow);
        });
    }

    // export table body part 1 = GridViewScroll() creates extra table and places some rows there
    jQuery('#GridView1Copy').find('tr.GridviewScrollItem').each(function() {
        var tmpRow = [];
        jQuery(this).filter(':visible').find('> td').each(function() {
             // does this element has the exclude class?
          if ( options.csvExclude && jQuery(this).hasClass( options.csvExclude ) ) {
            // it does have the exclude class, so ignore it
          }
          else {
            var jThis = jQuery(this);
            if (jThis.css('display') != 'none') {
                // extract value from input text element inside the td
                var itext = jThis.find('input[type=text]');
                if ( itext.length ) {
                    tmpRow[tmpRow.length] = itext.val().replace(/,/g,"");
                }
                // extract value from input radio element inside the td
                else if ( jThis.find('input[type=radio]').length ) {
                    tmpRow[tmpRow.length] = jThis.find('input[type=radio]:checked').val();
                }
                // extract value from input checkbox element inside the td
                else if ( jThis.find('input[type=checkbox]').length ) {
                    tmpRow[tmpRow.length] = ( jThis.find('input[type=checkbox]').is(':checked') ? 'yes' : 'no' );
                }
                else {
                    tmpRow[tmpRow.length] = formatData(jThis.text());
                }

                // determine number of column spans & expand the # of cells
                var colspan = jThis.prop( "colspan" );
                if ( typeof colspan === "number" ) {
                  for (var i = 1; i < colspan; i++)
                    tmpRow[tmpRow.length] = '';
                }
            }
          }
        });
        row2CSV(tmpRow);
    });

    // export table body part 2
    jQuery(el).find( options.findTBODY ).each(function() {
        var tmpRow = [];
        jQuery(this).filter(':visible').find('> td').each(function() {
           // does this element has the exclude class?
          if ( options.csvExclude && jQuery(this).hasClass( options.csvExclude ) ) {
                   // it does have the exclude class, so ignore it
          }
          else {
            if (jQuery(this).css('display') != 'none') {
                // extract value from input text element inside the td
                if ( jQuery(this).find('input[type=text]').length ) {
                    tmpRow[tmpRow.length] = jQuery(this).find('input[type=text]').val();
                }
                // extract value from input radio element inside the td
                else if ( jQuery(this).find('input[type=radio]').length ) {
                    tmpRow[tmpRow.length] = jQuery(this).find('input[type=radio]:checked').val();
                }
                else {
                    tmpRow[tmpRow.length] = formatData(jQuery(this).text());
                }

                // determine number of column spans & expand the # of cells
                var colspan = jQuery(this).prop( "colspan" );
                if ( typeof colspan === "number" ) {
                  for (var i = 1; i < colspan; i++)
                    tmpRow[tmpRow.length] = '';
                }
            }
          }
        });
        row2CSV(tmpRow);
    });

    // export table footer
    // go thru each row in tfoot
    if ( jQuery('tfoot').is(':visible') ) {
              jQuery(el).find( options.findTFOOT ).each(function() {
                 var jThis = jQuery(this);
                  tmpRow = [];
                  jThis.filter(':visible').find('th').each(function() {
                      if (jQuery(this).css('display') != 'none') {
                    tmpRow[tmpRow.length] = formatData(jQuery(this).text());

                    // determine number of column spans & expand the # of cells
                    var colspan = jQuery(this).prop( "colspan" );
                    if ( typeof colspan === "number" ) {
                      for (var i = 1; i < colspan; i++)
                        tmpRow[tmpRow.length] = '';
                    }
                }
                  });
                   row2CSV(tmpRow);
              });
    }

    if (options.delivery == 'popup') {
        var mydata = csvData.join('\n');
        return popup(mydata);
    }
    else {
        var mydata = csvData.join('\n');
        return mydata;
    }



    function row2CSV(tmpRow) {
        var tmp = tmpRow.join('') // to remove any blank rows
        // alert(tmp);
        if (tmpRow.length > 0 && tmp != '') {
            var mystr = tmpRow.join(options.separator);
            csvData[csvData.length] = mystr;
        }
    }

    function formatData(input) {
        var checkbox = '';
        // handling for checkbox inputs: use Y when it is checked otherwise use N
        if ( /\bINPUT/.test(input) && /\bcheckbox/.test(input) ) {
          // console.log( input );
          checkbox = /\bCHECKED/.test(input) ? 'Y' : 'N';
        }
        // replace " with blank
        var regexp = new RegExp(/["]/g);
        var output = input.replace(regexp, "");
        // HTML: remove tags and non-breaking spaces
        var regexp = new RegExp(/\<[^\<]+\>/g);
        var output = output.replace(regexp, "").replace(/&nbsp;/g,"");
        if (output == "") return checkbox;
        return '"' + output + ' ' + checkbox + '"';
    }

    function popup(data) {
        var generator = window.open('', 'csv', 'height=400,width=600');
        generator.document.write('<html><head><title>CSV</title>');
        generator.document.write('</head><body >');
        generator.document.write('<textArea cols=70 rows=15 wrap="off" >');
        generator.document.write(data);
        generator.document.write('</textArea>');
        generator.document.write('</body></html>');
        generator.document.close();
        return true;
    }
};
