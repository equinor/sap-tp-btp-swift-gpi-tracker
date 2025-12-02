sap.ui.define(['sap/ui/core/mvc/ControllerExtension'], function (ControllerExtension) {
    'use strict';

    return ControllerExtension.extend('gpitrackerlr.ext.controller.ListCustom', {
        // this section allows to extend lifecycle hooks or hooks provided by Fiori elements
        override: {
            /**
             * Called when a controller is instantiated and its View controls (if available) are already created.
             * Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
             * @memberOf gpitrackerlr.ext.controller.Format
             */
            onBeforeRendering: function () {           
                let mParameters = { model: this.base.editFlow.getView().getModel(), invocationGrouping: true }
                this.base.editFlow.invokeAction("refreshdata", mParameters).then(function () {
                 })

            }
        }
    });
});