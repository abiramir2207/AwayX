jQuery.fn.table2CSV = function(options) {
    var options = jQuery.extend({
         csvExclude: ''           // single class to be excluded in thead th, tbody tr td - default to nothing (do not filter)
        ,delivery: 'value'        // popup, value
        ,findTHEAD: 'thead tr'    // filter elements in thead tr - default to all tr (do not filter)
        ,findTFOOT: 'tfoot tr'    // filter elements in tfoot tr - default to all tr (do not filter)
        ,findTBODY: 'tbody tr'    // filter elements in tbody tr - default to all tr (do not filter)
        ,header: []
        ,separator: ','
        ,sScrollY: 0
    },
    options);

    var csvData = [];
    var headerArr = [];
    var el = this;

    //header
    var numCols = options.header.length;
    var tmpRow = []; // construct header available array
    if (options.sScrollY > 0) {
        jQuery(el).parent('.dataTables_scrollBody').prev('.dataTables_scrollHead').find('th').each(function() {
              // does this element has the exclude class?
              if ( options.csvExclude && jQuery(this).hasClass( options.csvExclude ) ) {
                // it does have the exclude class, so ignore it
              }
              else {
                tmpRow[tmpRow.length] = $(this).text();
              }
        });
        row2CSV(tmpRow);
    }
    // export table header
    else if (numCols > 0) {
        for (var i = 0; i < numCols; i++) {
            tmpRow[tmpRow.length] = formatData(options.header[i]);
        }
         row2CSV(tmpRow);
    } else {
        let header_found = 0;
        // go thru each row in thead
        jQuery(el).find( options.findTHEAD ).each(function() {
            header_row = get_column_headers( jQuery(this) );
            if (header_row.length) {
                header_found = 1;
                row2CSV( header_row );
            }
        });

        // no header information found in table - see if a separate GrillViewScroll table for header exists
        if (header_found == 0) {
            let header_table = jQuery("#" + el.attr("id") + "_Header_Fixed_Grid");

            if (header_table.length) {
                header_table.find( options.findTHEAD ).each(function() {
                    row2CSV( get_column_headers( jQuery(this) ) );
                });
            }
        }        
    }

    function get_column_headers(jElement){
        let columns = [];

        jElement.find('th').each(function() {
          // does this element has the exclude class?
          if ( options.csvExclude && jQuery(this).hasClass( options.csvExclude ) ) {
            // it does have the exclude class, so ignore it
          }
          else if (jQuery(this).css('display') != 'none') {
                // remove all HTML tags (any pair) - reg-expression pulled from RegexBuddy
                var text = jQuery(this).html().replace(/(<([^>]+)>)/ig,"");
                columns.push( formatData( text ) );

                // determine number of column spans & expand the # of cells
                var colspan = jQuery(this).prop( "colspan" );
                if ( typeof colspan === "number" ) {
                  for (var i = 1; i < colspan; i++)
                    columns.push('');
                }
            }
        });
        return columns;
    }

    // export table body
    jQuery(el).find( options.findTBODY ).each(function() {
        var tmpRow = [];
        jQuery(this).filter(':visible').find('> td').each(function() {
             // does this element has the exclude class?
          if ( options.csvExclude && jQuery(this).hasClass( options.csvExclude ) ) {
            // it does have the exclude class, so ignore it
          }
          else {
            var $this = jQuery(this);
            // remove script tags and content
            if ($this.has('script').length) {
                $this = $this.clone().find('script').remove().end();
                //alert($this.html())
            }
            if ($this.css('display') != 'none') {
                var child_element_filter = options.csvExclude
                                                ? ":not(." + options.csvExclude + ")"
                                                : '';
                if ($this.hasClass('combo')) {
                    var combval ='';
                    $this.find('input' + child_element_filter + ', select' + child_element_filter ).each(function() {

                    if (jQuery(this).is('input')) {
                        combval = combval + jQuery(this).val().replace(/,/g, "") + ' ';
                    }
                    if(jQuery(this).is('select')) {
                        combval = combval + ' ';
                                combval = combval + jQuery(this).find('option:selected').text().replace(/,/g,"") + ' ';
                    }
                    });
                    tmpRow[tmpRow.length]  = combval.trim();
                }
                else {
                    // extract value from input text element inside the td
                    var itext = $this.find('input[type=text]' + child_element_filter);
                    if ( itext.length ) {
                        tmpRow[tmpRow.length] = itext.val().replace(/,/g,"").trim();
                    }
                    // extract value from input radio element inside the td
                    else if ( $this.find('input[type=radio]' + child_element_filter ).length ) {
                        tmpRow[tmpRow.length] = $this.find('input[type=radio]:checked').val();
                    }
                    // extract value from input checkbox element inside the td
                    else if ( $this.find('input[type=checkbox]' + child_element_filter ).length ) {
                        tmpRow[tmpRow.length] = ( $this.find('input[type=checkbox]').is(':checked') ? 'yes' : 'no' );
                    }
                    else {
                        tmpRow[tmpRow.length] = formatData($this.text());
                    }

                    // determine number of column spans & expand the # of cells
                    var colspan = $this.prop( "colspan" );
                    if ( typeof colspan === "number" ) {
                      for (var i = 1; i < colspan; i++)
                        tmpRow[tmpRow.length] = '';
                    }
              }  // else if ($this.hasClass('combo'))
            }  // if ($this.css('display') != 'none')
          }
        });
        row2CSV(tmpRow);
    });

    // export table footer
    // go thru each row in tfoot
    if ( jQuery('tfoot').is(':visible') ) {
        jQuery(el).find( options.findTFOOT ).each(function() {
            var $this = jQuery(this);
            tmpRow = [];
            $this.filter(':visible').find('th').each(function() {
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

        // replace " with “
        var regexp = new RegExp(/["]/g);
        var output = noscript( input.replace(regexp, "") );
        // HTML: remove tags and non-breaking spaces
        regexp = new RegExp(/\<[^\<]+\>/g);
        output = output.replace(regexp,"").replace(/&nbsp;/g,"");
        if (output == "") return checkbox;
        return '"' + output.replace(/^\s+|\s+$/g,'') + ' ' + checkbox + '"';
    }

    function noscript(strCode) {
       var html = jQuery('<div>').html(strCode);
       html.find('script').remove();
       return html.html();
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