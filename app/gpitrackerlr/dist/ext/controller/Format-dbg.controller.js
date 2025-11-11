sap.ui.define(['sap/ui/core/mvc/ControllerExtension'], function (ControllerExtension) {
	'use strict';

	return ControllerExtension.extend('gpitrackerlr.ext.controller.Format', {
		// this section allows to extend lifecycle hooks or hooks provided by Fiori elements
		override: {
			/**
			 * Called when a controller is instantiated and its View controls (if available) are already created.
			 * Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
			 * @memberOf gpitrackerlr.ext.controller.Format
			 */
			onInit: function () {	
			},
			onBeforeRendering: function () {
				this.oProcessFlow = this.base.getView().byId("gpitrackerlr::PaymentsObjectPage--fe::CustomSubSection::Payment_event_flow--_IDGenProcessFlow1");
				this.oProcessFlow.optimizeLayout(true);
				this.oProcessFlow.setZoomLevel(sap.suite.ui.commons.ProcessFlowZoomLevel.One);
			}
		},

		formatMyField: function (val) {
			this.oProcessFlow = this.base.getView().byId("gpitrackerlr::PaymentsObjectPage--fe::CustomSubSection::Payment_event_flow--_IDGenProcessFlow1");
			this.oProcessFlow.updateModel();
			return val;		
		},
	});
});
