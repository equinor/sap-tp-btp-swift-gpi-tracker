sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"gpitrackerlr/test/integration/pages/PaymentsList",
	"gpitrackerlr/test/integration/pages/PaymentsObjectPage"
], function (JourneyRunner, PaymentsList, PaymentsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('gpitrackerlr') + '/test/flp.html#app-preview',
        pages: {
			onThePaymentsList: PaymentsList,
			onThePaymentsObjectPage: PaymentsObjectPage
        },
        async: true
    });

    return runner;
});

