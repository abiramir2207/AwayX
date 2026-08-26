package com.components
{
	import flash.events.Event;
	import flash.geom.Point;
	import mx.controls.dataGridClasses.DataGridItemRenderer;
	import mx.core.IToolTip;
	import mx.managers.ToolTipManager;
	
	public class baDataGridItemRenderer extends DataGridItemRenderer	
	{
	    private var DmxTooltip:String = null;
	    protected var DmxTooltipInstance:IToolTip;
	    	    
	    public function baDataGridItemRenderer()
	    {
	        super();
	        addEventListener("removedFromStage", killTooltip, false, 0, true); // remove the tooltip when the control is destroyed or removed
	        addEventListener("mouseOut", killTooltip, false, 0, true);         // remote the tooltip when the cursor leaves the control
	        addEventListener("mouseMove", restoreTooltip, false, 0, true);     // create the tooltip when the move moves inside the control
	    }
	    
	    protected function restoreTooltip(event:Event=null):void
	    {
	    	DmxTooltip = data.headerText;
	        // If a tooltip is set AND the tooltip is not showing
	        if (null != DmxTooltip && null == DmxTooltipInstance)
	        {
	            // Calculate global position of tooltip.
	            var pt:Point = new Point(0, height);  // place the tooltip at the bottom of the item renderer
	            pt = localToGlobal(pt);
	            pt = root.globalToLocal(pt);            
	
	            // Create the tooltip
	            DmxTooltipInstance = ToolTipManager.createToolTip(DmxTooltip, pt.x,pt.y);
	        }
	    }
	    
	    protected function killTooltip(event:Event=null):void
	    {
	        // Are we showing a tooltip?
	        if (null != DmxTooltipInstance)
	        {
	            // Yes!  Destroy it.
	            ToolTipManager.destroyToolTip(DmxTooltipInstance);
	            DmxTooltipInstance = null;
	        }
	    }
	}
}