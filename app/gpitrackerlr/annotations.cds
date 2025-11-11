using from '../../srv/API';

annotate GPI.MyService.Payments with @(
    UI.FieldGroup #GeneratedGroup: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'End to end identification',
                Value: end_to_end_identification,
            },
            {
                $Type      : 'UI.DataField',
                Label      : 'Transaction status',
                Value      : transaction_status,
                Criticality: transaction_status_criticality
            },
            {
                $Type: 'UI.DataField',
                Label: 'Transaction status reason',
                Value: transaction_status_reason,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Tracker informing party',
                Value: tracker_informing_party,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Service level',
                Value: service_level,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Interbank settlement amount',
                Value: interbank_settlement_amount_amount,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Remaining to be confirmed amount',
                Value: remaining_to_be_confirmed_amount_amount,
            },

            {
                $Type: 'UI.DataField',
                Label: 'Previously confirmed amount',
                Value: previously_confirmed_amount_amount,
            },
            {
                $Type: 'UI.DataField',
                Value: equivalent_amount_amount,
            },
            {
                $Type: 'UI.DataField',
                Value: equivalent_amount_currency_of_transfer,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Interbank settlement date',
                Value: interbank_settlement_date,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Confirmed date',
                Value: confirmed_date,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Ultimate debtor',
                Value: ultimate_debtor_name,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Ultimate debtor BIC',
                Value: ultimate_debtor_any_bic,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Debtor',
                Value: debtor_name,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Debtor BIC',
                Value: debtor_any_bic,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Creditor',
                Value: creditor_name,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Ultimate creditor',
                Value: ultimate_creditor_name,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Ultimate creditor BIC',
                Value: ultimate_creditor_any_bic,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Debtor IBAN',
                Value: debtor_account_iban,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Creditor IBAN',
                Value: creditor_account_iban,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Creditor agent',
                Value: creditor_agent,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Purpose',
                Value: purpose,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Debit Confirmation URL',
                Value: debit_confirmation_url_address,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Unstructured remittance info',
                Value: remittance_information_unstructured,
            },
        ],
    },
    UI.FieldGroup #status        : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type      : 'UI.DataField',
                Label      : '',
                Value      : transaction_status,
                Criticality: transaction_status_criticality,
            },
            {
                $Type        : 'UI.DataField',
                Label        : '',
                Value        : reject_return_reason,
                ![@UI.Hidden]: reject_reason_visibility
            }
        ]
    },
    UI.FieldGroup #amount        : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Instructed amount',
                Value: instructed_amount_amount,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Confirmed amount',
                Value: confirmed_amount_amount,
            }
        ]
    },
    UI.FieldGroup #date          : {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Label: '',
            Value: transaction_status_date
        }]
    },
    UI.FieldGroup #trackingref   : {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Label: '',
            Value: uetr
        }]
    },
    UI.FieldGroup #instruciden   : {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Label: '',
            Value: instruction_identification
        }]
    },
    UI.Facets                    : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Payment events',
            ID    : 'Paymentevents',
            Target: 'payment_event/@UI.LineItem#Paymentevents1'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'GeneratedFacet1',
            Label : 'General Information',
            Target: '@UI.FieldGroup#GeneratedGroup'
        }
    ],
    UI.HeaderFacets              : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Transaction status',
            ID    : 'Status',
            Target: '@UI.FieldGroup#status'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Amount',
            ID    : 'Amount',
            Target: '@UI.FieldGroup#amount'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Date',
            ID    : 'date',
            Target: '@UI.FieldGroup#date'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Tracking reference',
            ID    : 'trackref',
            Target: '@UI.FieldGroup#trackingref'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Instruction identification',
            ID    : 'instriden',
            Target: '@UI.FieldGroup#instruciden'
        }

    ],
    UI.HeaderInfo                : {
        TypeName      : 'Swift GPI Tracker',
        TypeNamePlural: 'Swift GPI Tracker',
        ImageUrl      : 'sap-icon://clinical-task-tracker',
        Title         : {
            $Type: 'UI.DataField',
            Value: 'Swift GPI Tracker'
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: ''
        }
    },
    UI.LineItem                  : [
        {
            $Type: 'UI.DataField',
            Label: 'UETR',
            Value: uetr,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Instruction identification',
            Value: instruction_identification,
        },
        {
            $Type: 'UI.DataField',
            Label: 'End to end identification',
            Value: end_to_end_identification,
        },
        {
            $Type      : 'UI.DataField',
            Label      : 'Transaction status',
            Value      : transaction_status,
            Criticality: transaction_status_criticality,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Transaction status date',
            Value: transaction_status_date,
        },
        {
            Value        : instructed_amount_currency,
            ![@UI.Hidden]: true
        },
        {
            Value        : confirmed_amount_currency,
            ![@UI.Hidden]: true
        },
        {
            Value        : equivalent_amount_currency,
            ![@UI.Hidden]: true
        },
        {
            Value        : transaction_status_criticality,
            ![@UI.Hidden]: true
        },
        {
            Value        : reject_reason_code_text,
            ![@UI.Hidden]: true
        },
        {
            Value        : transaction_status_text,
            ![@UI.Hidden]: true
        },
        {
            Value        : transaction_status_reason_text,
            ![@UI.Hidden]: true
        },
        {
            Value        : previously_confirmed_amount_currency,
            ![@UI.Hidden]: true
        },
        {
            Value        : remaining_to_be_confirmed_amount_currency,
            ![@UI.Hidden]: true
        },
        {
            Value        : debtor_filter,
            ![@UI.Hidden]: true
        },
        {
            Value        : creditor_filter,
            ![@UI.Hidden]: true
        }


    ],
    UI.v1.SelectionFields        : [PaymentDate],
    UI.SelectionFields           : [
        uetr,
        end_to_end_identification,
        bic,
        service_level,
        transaction_status,
        debtor_any_bic,
        creditor_any_bic
    ],

);

annotate GPI.MyService.Payments with {
    bic                @(Common.ValueList: {
        Label         : 'Creditor BIC',
        CollectionPath: 'BICValuehelp',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: 'bic',
                // field in MyEntity
                ValueListProperty: 'bic' // field in BICValuehelp
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'name' // field in BICValuehelp
            }
        ]
    });

    transaction_status @(Common.ValueList: {
        Label         : 'Transaction status',
        CollectionPath: 'TransactionStatusVH',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: 'transaction_status',
                // field in MyEntity
                ValueListProperty: 'transaction_status'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'text'
            }
        ]
    });

    service_level      @(Common.ValueList: {
        Label         : 'Service Level',
        CollectionPath: 'ServiceLevelVH',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: 'service_level',
                // field in MyEntity
                ValueListProperty: 'service_level'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'text'
            }
        ]
    });
    PaymentDate        @Common.Label: 'Payment Date';
};

annotate GPI.MyService.PaymentEvents with @Capabilities: {SearchRestrictions: {Searchable: false}};

annotate GPI.MyService.PaymentEvents with @(UI.LineItem #Paymentevents1: [
    {
        $Type: 'UI.DataField',
        Value: from,
        Label: 'Sender',
    },
    {
        $Type: 'UI.DataField',
        Value: to,
        Label: 'Receiver',
    },
    {
        $Type: 'UI.DataField',
        Value: processing_date_time,
        Label: 'Processing date',
    },
    {
        $Type: 'UI.DataField',
        Value: charge_amount_amount,
        Label: 'Charge amount',
    },
    {
        $Type: 'UI.DataField',
        Value: charge_bearer,
        Label: 'Sender deducts',
    },
    {
        Value        : bic,
        ![@UI.Hidden]: true
    },
    {
        Value        : service_level,
        ![@UI.Hidden]: true
    },
    {
        Value        : uetr,
        ![@UI.Hidden]: true
    },
    {
        Value        : from_name,
        ![@UI.Hidden]: true
    },
    {
        Value        : to_name,
        ![@UI.Hidden]: true
    },
    {
        Value        : charge_bearer_text,
        ![@UI.Hidden]: true
    },
    {
        Value        : charge_amount_currency,
        ![@UI.Hidden]: true
    },
    {
        Value        : interbank_settlement_amount_currency,
        ![@UI.Hidden]: true
    }

])
