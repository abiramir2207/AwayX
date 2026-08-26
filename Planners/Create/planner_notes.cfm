<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
Name         :  /planners/create/planner_notes.cfm
Created Date :  2017 Sep
Created By   :  Chris Nguyen
Description  :  Enter notes for planner

Remarks      :  
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cf_layout-bare jQueryUI_widgets="tooltip">
	<cfset request.minWidth = 0>
	<style>
		textarea {
			resize: none;
			overflow: auto;
			width: 99%;
		}
		#actions {
			width: 100%;
			text-align: center;
		}
		#actions a.primary {
			margin-right: 50px;
		}
		#chars {
			margin-top: 5px;
		}
		p {
			color: #333;
			font-size: 12px;
		}
	</style>

	<cfoutput>
	<div id="content">
		<cfset max_length = application.util.query.columnInfo('planner_notes', 'notes').column_size>
		<p>Enter reason(s) for not approving this plan (optional).</p>
		<textarea id="text" name="notes" rows="#(max_length / 120 * 0.75)#" wrap="off"></textarea><div id="chars" class="opaque-l"></div>  
	</div>    <!---end of div content--->
	<div id="actions">
		<a id=save class="primary" title="click to save reason(s) and change plan to wip">#application.util.string.linkFormat("change to wip")#</a>
		<a id=cancel class="secondary" title="click to cancel this disagreement action">#application.util.string.linkFormat("cancel")#</a>
	</div>
	</cfoutput>

	<cfinclude template="/common_files/jQuery.cfm">
	<cfinclude template="/common_files/focus.cfm">

	<script>
		(function($) {
		    $.fn.extend( {
		        limiter: function(limit, elem) {
		            $(this).on("keyup focus", function() {
		                setCount(this, elem);
		            });
		            function setCount(src, elem) {
		                var chars = src.value.length;
		                if (chars > limit) {
		                    src.value = src.value.substr(0, limit);
		                    chars = limit;
		                }
		                elem.html( "limit " + limit + " characters, remaining " + (limit - chars) );
		            }
		            setCount($(this)[0], elem);
		        }
		    });
			var elem = $("#chars");
			$("#text").limiter(<cfoutput>#max_length#</cfoutput>, elem);
			$("#cancel").click(function(){
				parent.dhx_window_close();
			});
			$("#save").click(function(){
				// save notes into parent element
				$("input[name=notes]", parent.document).val( $("#text").val() );
				// submit parent form
				parent.disagree();
				// close this page
				parent.dhx_window_close();
			});
			$("#text").focus();
		})(jQuery);
	</script>
</cf_layout-bare>