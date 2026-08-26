<!---enables filtration delay for keeping the browser more responsive while searching for a longer keyword--->
jQuery.fn.dataTableExt.oApi.fnSetFilteringDelay = function ( oSettings,iDelay ) {
 var _that = this,iDelay = (typeof iDelay == 'undefined') ? 500 : iDelay;
 this.each( function ( i ) {
  $.fn.dataTableExt.iApiIndex = i;
  var $this = this,oTimerId = null,sPreviousSearch = null,
  	anControl = $( 'input', _that.fnSettings().aanFeatures.f );
  	anControl.unbind( 'keyup' ).bind( 'keyup', function() {
  	var $$this = $this;
  	if (sPreviousSearch === null || sPreviousSearch != anControl.val()) {
  		window.clearTimeout(oTimerId);
  		sPreviousSearch = anControl.val();
  		oTimerId = window.setTimeout(function() {
  			$.fn.dataTableExt.iApiIndex = i;
  			_that.fnFilter( anControl.val() );
  		}, iDelay);
  	}
  });
  return this;
 });
 return this;
}

<!---this plug-in removed the default behaviour of DataTables to filter on each keypress, and replaces with it the requirement to press the enter key to perform the filter.--->
jQuery.fn.dataTableExt.oApi.fnFilterOnReturn = function (oSettings) {
 var _that = this;
 this.each(function (i) {
     $.fn.dataTableExt.iApiIndex = i;
     var $this = this;
     var anControl = $('input', _that.fnSettings().aanFeatures.f);
     anControl.unbind('keyup').bind('keypress', function (e) {
         if (e.which == 13) {
             $.fn.dataTableExt.iApiIndex = i;
             _that.fnFilter(anControl.val());
         }
     });
     return this;
 });
 return this;
}
<!---Create an array with the values of all the input boxes in a column--->
$.fn.dataTableExt.afnSortData['dom-text'] = function  ( oSettings, iColumn )
{
	var aData = [];
	$( 'td:eq('+iColumn+') input', oSettings.oApi._fnGetTrNodes(oSettings) ).each( function () {
		aData.push( this.value );
	} );
	return aData;
}
<!---Create an array with the values of all the select options in a column--->
$.fn.dataTableExt.afnSortData['dom-select'] = function  ( oSettings, iColumn )
{
	var aData = [];
	$( 'td:eq('+iColumn+') select', oSettings.oApi._fnGetTrNodes(oSettings) ).each( function () {
		aData.push( $(this).val() );
	} );
	return aData;
}
<!---returns check box sorting value--->
jQuery.fn.dataTableExt.afnSortData['dom-checkbox'] = function  ( oSettings, iColumn ) {
 var aData = [];
 $( 'td:eq('+iColumn+') input', oSettings.oApi._fnGetTrNodes(oSettings) ).each( function () {
 	aData.push( this.checked==true ? "1" : "0" );
 } );
 return aData;
}

<!---filtering check boxes - specify sType='dom-checkbox'--->
$.fn.dataTableExt.ofnSearch['dom-checkbox'] = function ( sData ) {
 return /CHECKED/.test(sData) ? 1 : 0;
}

function htmlToText(html){
  return html
  // Remove line breaks
  .replace(/(?:\n|\r\n|\r)/ig, "")
  // Turn <br>'s into single line breaks.
  .replace(/<\s*br[^>]*>/ig, "\n")
  // Turn </li>'s into line breaks.
  .replace(/<\s*\/li[^>]*>/ig, "\n")
  // Turn <p>'s into double line breaks.
  .replace(/<\s*p[^>]*>/ig, "\n\n")
  // Remove content in script tags.
  .replace(/<\s*script[^>]*>[\s\S]*?<\/script>/mig, "")
  // Remove content in style tags.
  .replace(/<\s*style[^>]*>[\s\S]*?<\/style>/mig, "")
  // Remove content in comments.
  .replace(/<!--.*?-->/mig, "")
  // Format anchor tags properly.
  // e.g.
  // input - <a class='ahref' href='http://pinetechlabs.com/' title='asdfqwer\"><b>asdf</b></a>
  // output - asdf (http://pinetechlabs.com/)
  .replace(/<\s*a[^>]*href=['"](.*?)['"][^>]*>([\s\S]*?)<\/\s*a\s*>/ig, "$2")  // Remove all remaining tags.
  .replace(/(<([^>]+)>)/ig, "")
  // Make sure there are never more than two
  // consecutive linebreaks.
  .replace(/\n{2,}/g, "\n\n")
  // Remove tabs.
  .replace(/\t/g, "")
  // Remove newlines at the beginning of the text.
  .replace(/^\n+/m, "")
  // Replace multiple spaces with a single space.
  .replace(/ {2,}/g, " ");
};

jQuery.fn.dataTableExt.oSort['currency-asc'] = function(a,b) {
  var x = htmlToText(a);
  var y = htmlToText(b);

  x = x.replace("$", "")                    /* remove currency sign */
       .replace( /,/g, "" )                 /* remove commas */
       .replace("[", "").replace("]", "")   /* remove square brackets */
       ;

  y = y.replace("$", "")                    /* remove currency sign */
       .replace( /,/g, "" )                 /* remove commas */
       .replace("[", "").replace("]", "")   /* remove square brackets */
       ;

  /* Parse and return */
  x = parseFloat( x );
  y = parseFloat( y );

	return x - y;
};

jQuery.fn.dataTableExt.oSort['currency-desc'] = function(a,b) {
  var x = htmlToText(a);
  var y = htmlToText(b);

	x = x.replace("$", "")                    /* remove currency sign */
       .replace( /,/g, "" )                 /* remove commas */
       .replace("[", "").replace("]", "")   /* remove square brackets */
       ;

  y = y.replace("$", "")                    /* remove currency sign */
       .replace( /,/g, "" )                 /* remove commas */
       .replace("[", "").replace("]", "")   /* remove square brackets */
       ;

	/* Parse and return */
	x = parseFloat( x );
	y = parseFloat( y );

	return y - x;
};


// IMPORTANT: sType = 'dollar' requires dataTables version 1.9 or higher
jQuery.extend( jQuery.fn.dataTableExt.oSort, {
    "dollar-pre": function ( a ) {
        // get rid of percentage sign, commas
        var z = (a==="-") ? 0 : a.replace( /[^\d\-\.]|,|%/g, "" )
            ,neg = /\([^"\r\n]*\)/;
        // console.log( z );
        // if negative value enclosed in parentheses is found add a negative sign
        if ( neg.test( a ) )
					z = '-' + z;
        return parseFloat( z );
    },

    "dollar-asc": function ( a, b ) {
        return a - b;
    },

    "dollar-desc": function ( a, b ) {
        return b - a;
    }
} );

$.fn.dataTableExt.oApi.fnGetColumnData = function ( oSettings, iColumn, bUnique, bFiltered, bIgnoreEmpty ) {
    // check that we have a column id
    if ( typeof iColumn == "undefined" ) return new Array();

    // by default we only want unique data
    if ( typeof bUnique == "undefined" ) bUnique = true;

    // by default we do want to only look at filtered data
    if ( typeof bFiltered == "undefined" ) bFiltered = true;

    // by default we do not want to include empty values
    if ( typeof bIgnoreEmpty == "undefined" ) bIgnoreEmpty = true;

    // list of rows which we're going to loop through
    var aiRows;

    // use only filtered rows
    if (bFiltered == true) aiRows = oSettings.aiDisplay;
    // use all rows
    else aiRows = oSettings.aiDisplayMaster; // all row numbers

    // set up data array
    var asResultData = new Array();

    for (var i=0,c=aiRows.length; i<c; i++) {
        iRow = aiRows[i];
        var aData = this.fnGetData(iRow);
        var sValue = aData[iColumn];

        // ignore empty values?
        if (bIgnoreEmpty == true && sValue.length == 0) continue;

        // ignore unique values?
        else if (bUnique == true && jQuery.inArray(sValue, asResultData) > -1) continue;

        // else push the value onto the result data array
        else asResultData.push(sValue);
    }

    return asResultData.sort();
};
/**
 * Return an array of table values from a particular column, with various
 * filtering options.
 *
 * DataTables 1.10+ provides the `dt-api column().data()` method, built-in to
 * the core, to provide this ability. As such, this method is marked deprecated,
 * but is available for use with legacy version of DataTables. Please use the
 * new API if you are used DataTables 1.10 or newer.
 *
 *  @name fnGetColumnData
 *  @summary Get the data from a column
 *  @author [Benedikt Forchhammer](http://mind2.de)
 *  @deprecated
 *
 *  @param {integer} iColumn Column to get data from
 *  @param {boolean} [bFiltered=true] Reduce the data set to only unique values
 *  @param {boolean} [bUnique=true] Get data from filter results only
 *  @param {boolean} [bIgnoreEmpty=true] Remove data elements which are empty
 *  @returns {array} Array of data from the column
 *
 *  @example
 *    var table = $('#example').dataTable();
 *    table.fnGetColumnData( 3 );
 BSA NOTE: IN TESTING, WE FOUND THAT WHEN THE CODE IS USED INSIDE A "fnDrawCallback" CALL, "this.fnGetColumnData()" WORKS AND 
 "table.fnGetColumnData()" DOES NOT WORK, AS DESCRIBED ABOVE.
 */

jQuery.fn.dataTableExt.oApi.fnGetColumnData = function ( oSettings, iColumn, bUnique, bFiltered, bIgnoreEmpty ) {
	// check that we have a column id
	if ( typeof iColumn == "undefined" ) {
		return [];
	}

	// by default we only wany unique data
	if ( typeof bUnique == "undefined" ) {
		bUnique = true;
	}

	// by default we do want to only look at filtered data
	if ( typeof bFiltered == "undefined" ) {
		bFiltered = true;
	}

	// by default we do not wany to include empty values
	if ( typeof bIgnoreEmpty == "undefined" ) {
		bIgnoreEmpty = true;
	}

	// list of rows which we're going to loop through
	var aiRows;

	// use only filtered rows
	if (bFiltered === true) {
		aiRows = oSettings.aiDisplay;
	}
	// use all rows
	else {
		aiRows = oSettings.aiDisplayMaster; // all row numbers
	}

	// set up data array    
	var asResultData = [];

	for (var i=0,c=aiRows.length; i<c; i++) {
		var iRow = aiRows[i];
		var sValue = this.fnGetData(iRow, iColumn);

		// ignore empty values?
		if (bIgnoreEmpty === true && sValue.length === 0) {
			continue;
		}

		// ignore unique values?
		else if (bUnique === true && jQuery.inArray(sValue, asResultData) > -1) {
			continue;
		}

		// else push the value onto the result data array
		else {
			asResultData.push(sValue);
		}
	}

	return asResultData;
};

jQuery.fn.dataTableExt.oApi.fnReloadAjax = function ( oSettings, sNewSource, fnCallback, bStandingRedraw )
{
    // DataTables 1.10 compatibility - if 1.10 then `versionCheck` exists.
    // 1.10's API has ajax reloading built in, so we use those abilities
    // directly.
    if ( jQuery.fn.dataTable.versionCheck ) {
        var api = new jQuery.fn.dataTable.Api( oSettings );

        if ( sNewSource ) {
            api.ajax.url( sNewSource ).load( fnCallback, !bStandingRedraw );
        }
        else {
            api.ajax.reload( fnCallback, !bStandingRedraw );
        }
        return;
    }

    if ( sNewSource !== undefined && sNewSource !== null ) {
        oSettings.sAjaxSource = sNewSource;
    }

    // Server-side processing should just call fnDraw
    if ( oSettings.oFeatures.bServerSide ) {
        this.fnDraw();
        return;
    }

    this.oApi._fnProcessingDisplay( oSettings, true );
    var that = this;
    var iStart = oSettings._iDisplayStart;
    var aData = [];

    this.oApi._fnServerParams( oSettings, aData );

    oSettings.fnServerData.call( oSettings.oInstance, oSettings.sAjaxSource, aData, function(json) {
        /* Clear the old information from the table */
        that.oApi._fnClearTable( oSettings );

        /* Got the data - add it to the table */
        var aData =  (oSettings.sAjaxDataProp !== "") ?
            that.oApi._fnGetObjectDataFn( oSettings.sAjaxDataProp )( json ) : json;

        for ( var i=0 ; i<aData.length ; i++ )
        {
            that.oApi._fnAddData( oSettings, aData[i] );
        }

        oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();

        that.fnDraw();

        if ( bStandingRedraw === true )
        {
            oSettings._iDisplayStart = iStart;
            that.oApi._fnCalculateEnd( oSettings );
            that.fnDraw( false );
        }

        that.oApi._fnProcessingDisplay( oSettings, false );

        /* Callback user function - for event handlers etc */
        if ( typeof fnCallback == 'function' && fnCallback !== null )
        {
            fnCallback( oSettings );
        }
    }, oSettings );
};

jQuery.fn.dataTableExt.oApi.fnStandingRedraw = function(oSettings) {
    //if(oSettings.oFeatures.bServerSide === false){
        var before = oSettings._iDisplayStart;
 
        oSettings.oApi._fnReDraw(oSettings);
 
        // iDisplayStart has been reset to zero - so lets change it back
        oSettings._iDisplayStart = before;
        oSettings.oApi._fnCalculateEnd(oSettings);
    //}
 
    // draw the 'current' page
    oSettings.oApi._fnDraw(oSettings);
};


jQuery.fn.dataTableExt.oApi.fnFilterClear  = function ( oSettings )
{
    var i, iLen;
 
    /* Remove global filter */
    oSettings.oPreviousSearch.sSearch = "";
 
    /* Remove the text of the global filter in the input boxes */
    if ( typeof oSettings.aanFeatures.f != 'undefined' )
    {
        var n = oSettings.aanFeatures.f;
        for ( i=0, iLen=n.length ; i<iLen ; i++ )
        {
            $('input', n[i]).val( '' );
        }
    }
 
    /* Remove the search text for the column filters - NOTE - if you have input boxes for these
     * filters, these will need to be reset
     */
    for ( i=0, iLen=oSettings.aoPreSearchCols.length ; i<iLen ; i++ )
    {
        oSettings.aoPreSearchCols[i].sSearch = "";
    }
 
    /* Redraw */
    oSettings.oApi._fnReDraw( oSettings );
};

function fnCreateSelect( aData ) {
    var r='<select><option value=""></option>', i, iLen=aData.length;
    for ( i=0 ; i<iLen ; i++ ) {
        r += '<option value="'+aData[i]+'">'+aData[i]+'</option>';
    }
    return r+'</select>';
}

// this function is useful when a column filter (dropdown or text input) is in the thead
// and you want to stop the sorting from triggering when user perform data entry/selection
function stopTableSorting(e) {
  if (!e)
    var e = window.event;
  e.cancelBubble = true;
  if (e.stopPropagation)
    e.stopPropagation();
}

/******************************************(START) CODE FOR SETTING DATAGRID HEIGHT/WIDTH****************************************/
/*
The purpose of this file is to use the complete available space (height and width) for a datagrid, 
regardless of resolution.
*/
function onWindowResize(callback) {
	var width = $(window).width(),
		height = $(window).height();

	$(window).resize(function() {
		var newWidth = $(window).width(),
			newHeight = $(window).height();

		/* This logic is for IE 9 and below. We could have just used "$(window).resize(function()" 
		on the caller page for other browsers.
		*/
		if (newWidth !== width || newHeight !== height) {
			width = newWidth;
			height = newHeight;
			callback();
		}
	});
}

/* adjust table column width and table height automatically when window is resized.
Pass the "datagrid" object and "gridHeightAdjustment" value.
*/
function doneResizing(datagrid,gridHeightAdjustment){
	/* horizontal resizing */
	datagrid.fnAdjustColumnSizing();
	/* vertical resizing */
	adjustGridheight(datagrid,gridHeightAdjustment);
}

function adjustGridheight(datagrid,gridHeightAdjustment){
	/* "Math.floor($(window).height())" is height of the page.
	Math.floor(jTable.offset().top)" is the height from the top of the page to the top of the grid.
	"gridHeightAdjustment" will be the roughly value from the bottom of the grid to the bottom of the page.
	*/
	var heightDiff = (Math.floor($(window).height()) - Math.floor(datagrid.offset().top))
	gridHeightAdjustment = gridHeightAdjustment;
	var dgridheight = (heightDiff - gridHeightAdjustment);

	datagrid.fnSettings().oScroll.sY = dgridheight;
	/* Use "fnStandingRedraw" and not "fnDraw" due to the following reason:
	- When a user goes to a specific page other than the first page on the grid,
	and then resizes the grid, the grid gets reset to the first page. "fnStandingRedraw"
	preserves the page after redrawing the grid.
	*/
	datagrid.fnStandingRedraw();
}

/* "callResize" function can be called multiple times. "setTimeout" and "clearTimeout" is being used to avoid that.
	When a user drags the window and stops, x milliseconds(value below) after that , "doneResizing" function will be called.
*/
if((typeof mydatagrid != 'undefined') && (typeof height_below_grid_to_bottom_page_in_pixels != 'undefined'))
{
	$(window).load(function() {
		callResize();
	});

	onWindowResize(function() {
		callResize();
	});

	$('#idExpandCollapse').click(function() {
		callResize();
	});
}

/* "callResize" function can be called multiple times. "setTimeout" and "clearTimeout" is being used to avoid that.
	When a user drags the window and stops, x milliseconds(value below) after that , "doneResizing" function will be called.
*/
var resizeId;
function callResize(){
	/* Following steps are needed to use this functionality - 
	1) Before we include this line of code - "/Script/javascript/jquery.dataTables-api.js" on our file, we need to declare two variables -
		a) var height_below_grid_to_bottom_page_in_pixels = 50; (Below are the details of how to set this number)
		b) var mydatagrid = ''; (This must be set to blank)
		e.g. -
		<script type="text/javascript">
		var height_below_grid_to_bottom_page_in_pixels = 50;
		var mydatagrid = '';
		</script>

	The 2 variables must be defined before we call "/Script/javascript/jquery.dataTables-api.js" because, unless these 2 variables are defined,
	we will not call the "callResize" function either on load or on resize.
	Look at this line above -
	if((typeof mydatagrid != 'undefined') && (typeof height_below_grid_to_bottom_page_in_pixels != 'undefined'))

	2) The name of the datatable must be set to "mydatagrid" in the dataTable (caller page). e.g. mydatagrid =  $(".datagrid").dataTable({)}.
	Make sure that any references to the older variable (name of datatable) now points to "mydatagrid" on the caller page.
	3) Set "sScrollY": 0 in the datatable code (caller page).
	4) "height_below_grid_to_bottom_page_in_pixels" must be defined in the dataTable (caller page). To set "height_below_grid_to_bottom_page_in_pixels",
	follow these steps (Note: Look at the instructions above to find out where to use this value) -
		a)First set "height_below_grid_to_bottom_page_in_pixels" to a specific number, e.g. - var height_below_grid_to_bottom_page_in_pixels = 50;
		If the bottom of the dataTable cannot be seen, then increase the number. If the bottom of the dataTable can be seen, but there is still space at the bottom,
		which can be used, then reduce the number. Do this until a desired number is reached.
		b) Then test the changes. Make sure that the height and width of the dataTable always occupies the maximum available screen space "onload" and "onwindowresize".
		c) In some cases, it is possible that there are "search options" above the dataTable, which is hidden by default and a user needs to click on the "expand" sign
		or a link to see the search options. In that case, the dataTable must resize it's height as well. Rename the "id" of the table which has the search options
		to "idExpandCollapse", and the resize code will start working. */
	
		clearTimeout(resizeId);
        /* Leave "250" milliseconds as it is. If you reduce the number, "doneResizing" may be called twice.*/
        
        /* 
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 2020 jun 5 - chrisn ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
        
           Commented this out to eliminate multiple extra Ajax calls to get the backend data in the initial rendering of the grid

         resizeId = setTimeout(function(){doneResizing(mydatagrid,height_below_grid_to_bottom_page_in_pixels)},250);
        */
}
/******************************************(END) CODE FOR SETTING DATAGRID HEIGHT/WIDTH****************************************/