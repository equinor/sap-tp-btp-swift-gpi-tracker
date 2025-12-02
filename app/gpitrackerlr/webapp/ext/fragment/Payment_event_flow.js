sap.ui.define([
    "sap/ui/core/Fragment"
], function (Fragment) {
    "use strict";
    return {
        onNodePress: function (oEvent) {
            var oNode = oEvent.getParameters();
            var sPath = oNode.getBindingContext().getPath();
            var oSource = oEvent.getSource();            // ProcessFlow control
            var oView = oSource.getParent();

            if (!this.oQuickView) {
                this.oQuickView = Fragment.load({
                    name: "gpitrackerlr.ext.fragment.Quickview",
                    type: "XML"
                }).then(function(oFragment) {
					this.oQuickView = oFragment;				
					this.oQuickView.bindElement(sPath);
					this.oQuickView.openBy(oNode);
                    oView.addDependent(this.oQuickView);
				}.bind(this));
			} else {
				this.oQuickView.bindElement(sPath);
				this.oQuickView.openBy(oNode);
			}
		},

		onExit: function () {
			if (this.oQuickView) {
				this.oQuickView.destroy();
			}
		}
    };
});
