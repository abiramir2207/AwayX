//   * =========================================================================================================
//   *    @File: Script\javascript\gridviewscroll_init.js
//   *  @Author: Chris Nguyen
//   *    @Date: 2022 June 22
//   *
//   * @Remarks: Automatically add the required CSS classes to support Grid view scroll framework
//   * =========================================================================================================

function gridviewscroll_init( table_id ) {
    const HEADER_CLASS = "GridViewScrollHeader";
    const BODY_CLASS   = "GridViewScrollItem";

    let table = document.getElementById( table_id );

    if ( table && table.rows ) {
        // conditionally add CSS class to header row
        if ( ! table.rows[ 0 ].classList.contains( HEADER_CLASS ) ) {
            table.rows[ 0 ].classList.add( HEADER_CLASS );
        }

        // loop through each row of the table body to conditionally add CSS class
        for ( let row = 1; row < table.rows.length; row++ ) {
            if ( ! table.rows[ row ].classList.contains( BODY_CLASS ) ) {
                table.rows[ row ].classList.add( BODY_CLASS );
            }
        }
    }
}
