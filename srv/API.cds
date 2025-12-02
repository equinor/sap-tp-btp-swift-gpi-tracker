namespace GPI;

using {gpi.for.Corporates_types as payment} from './external/SWIFT-API-gpi-corporate_api-7.0.3-swagger';

service MyService {

  type ActiveCurrencyAndAmount {
    currency : payment.ActiveCurrencyCode;

    @Measures.ISOCurrency: (currency)
    amount   : String(19);
  }

  action refreshdata() returns String;

  @Capabilities: {
    FilterRestrictions           : {
      FilterExpressionRestrictions: [
        {
          Property          : 'PaymentDate',
          AllowedExpressions: 'SingleRange'
        },
        {
          Property          : 'bic',
          AllowedExpressions: 'SingleValue'

        },
        {
          Property          : 'service_level',
          AllowedExpressions: 'SingleValue'
        },
        {
          Property          : 'transaction_status',
          AllowedExpressions: 'SingleValue'
        },
        {
          Property          : 'uetr',
          AllowedExpressions: 'SingleValue'
        },
        {
          Property          : 'end_to_end_identification',
          AllowedExpressions: 'SingleValue',
        },
        {
          Property          : 'debtor_account_filter',
          AllowedExpressions: 'SingleValue'
        },
        {
          Property          : 'debtor_any_bic',
          AllowedExpressions: 'SingleValue'
        },
        {
          Property          : 'creditor_account_filter',
          AllowedExpressions: 'SingleValue'
        },
        {
          Property          : 'creditor_any_bic',
          AllowedExpressions: 'SingleValue'
        }
      ],
      RequiredProperties          : [
        PaymentDate,
        bic,
        service_level
      ]
    },
    DeleteRestrictions.Deletable : false,
    UpdateRestrictions.Updatable : false,
    InsertRestrictions.Insertable: false
  }

  @readonly
  entity Payments {
        @Common.Label        : 'BIC'
        @Common.ValueListWithFixedValues
    key bic                                       : String;

        @Common.Label: 'UETR'
    key uetr                                      : payment.UUIDv4Identifier;

        @Common.ValueListWithFixedValues
        @assert.range        : true
        @Common.Label        : 'Service level'
    key service_level                             : payment.ServiceLevel5Code;

        @Common.Label: 'Instruction identification'
        instruction_identification                : payment.RestrictedFINXMax35Text;

        @Common.Label: 'End to end identification'
        end_to_end_identification                 : payment.RestrictedFINXMax35Text;

        @Common.Label        : 'Transaction status'
        @Common.ValueListWithFixedValues
        @assert.range        : true
        @Common              : {
          Text           : transaction_status_text,
          TextArrangement: #TextLast
        }
        transaction_status                        : payment.TransactionIndividualStatus10Code;

        @Common.Label        : 'Transaction status date'
        @UI.DateTimeStyle    : 'medium'
        transaction_status_date                   : Timestamp;

        @Common.Label        : 'Transaction status reason'
        @Common              : {
          Text           : transaction_status_reason_text,
          TextArrangement: #TextLast
        }
        transaction_status_reason                 : payment.PaymentStatusReason13Code;

        @Common.Label        : 'Reject return reason'
        @Common              : {
          Text           : reject_reason_code_text,
          TextArrangement: #TextLast
        }
        reject_return_reason                      : payment.TrackerPaymentStatusReason3Code;

        @Common.Label: 'Tracker informing party'
        tracker_informing_party                   : payment.BICFIDec2014Identifier;

        @Common.Label        : 'Instructed amount'
        @Measures.ISOCurrency: (instructed_amount_currency)
        instructed_amount_amount                  : String(19);

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        instructed_amount_currency                : payment.ActiveOrHistoricCurrencyCode;

        @Common.Label        : 'Equivalent amount'
        @Measures.ISOCurrency: (equivalent_amount_currency)
        equivalent_amount_amount                  : String(19);

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        equivalent_amount_currency                : payment.ActiveOrHistoricCurrencyCode;

        @Common.Label: 'Currency of transfer'
        equivalent_amount_currency_of_transfer    : payment.ActiveOrHistoricCurrencyCode;

        @Common.Label        : 'Interbank settlement amount'
        @Measures.ISOCurrency: (interbank_settlement_amount_currency)
        interbank_settlement_amount_amount        : String(19);

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        interbank_settlement_amount_currency      : payment.ActiveOrHistoricCurrencyCode;

        @Common.Label        : 'Confirmed amount'
        @Measures.ISOCurrency: (confirmed_amount_currency)
        confirmed_amount_amount                   : String(19);

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        confirmed_amount_currency                 : payment.ActiveOrHistoricCurrencyCode;

        @Common.Label        : 'Remaining to be confirmed amount'
        @Measures.ISOCurrency: (remaining_to_be_confirmed_amount_currency)
        remaining_to_be_confirmed_amount_amount   : String(19);

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        remaining_to_be_confirmed_amount_currency : payment.ActiveOrHistoricCurrencyCode;

        @Common.Label        : 'Previously confirmed amount'
        @Measures.ISOCurrency: (previously_confirmed_amount_currency)
        previously_confirmed_amount_amount        : String(19);

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        previously_confirmed_amount_currency      : payment.ActiveOrHistoricCurrencyCode;

        @Common.Label        : 'Requested execution date'
        @UI.DateTimeStyle    : 'long'
        requested_execution_date                  : Timestamp;

        @Common.Label        : 'Interbank settlement date'
        @UI.DateTimeStyle    : 'medium'
        interbank_settlement_date                 : Date;

        @Common.Label        : 'Confirmed date'
        @UI.DateTimeStyle    : 'long'
        confirmed_date                            : Timestamp;

        @Common.Label: 'Ultimate debtor name'
        ultimate_debtor_name                      : payment.Max140Text;

        @Common.Label: 'Ultimate debtor BIC'
        ultimate_debtor_any_bic                   : payment.AnyBICDec2014Identifier;

        @Common.Label: 'Debtor name'
        debtor_name                               : payment.Max140Text;

        @Common.Label: 'Debtor'
        debtor_any_bic                            : payment.AnyBICDec2014Identifier;

        @Common.Label: 'Debtor IBAN'
        debtor_account_iban                       : payment.IBAN2007Identifier;

        @Common.Label: 'Creditor name'
        creditor_name                             : payment.Max140Text;

        @Common.Label: 'Creditor'
        creditor_any_bic                          : payment.AnyBICDec2014Identifier;

        @Common.Label: 'Creditor IBAN'
        creditor_account_iban                     : payment.IBAN2007Identifier;

        @Common.Label: 'Ultimate creditor name'
        ultimate_creditor_name                    : payment.Max140Text;

        @Common.Label: 'Ultimate creditor BIC'
        ultimate_creditor_any_bic                 : payment.BICFIDec2014Identifier;

        @Common.Label: 'Creditor agent'
        creditor_agent                            : payment.BICFIDec2014Identifier;

        @Common.Label: 'Debtor account'
        debtor_filter                             : payment.Max34Text;

        @Common.Label: 'Creditor account'
        creditor_filter                           : payment.Max34Text;

        @Common.Label: 'Purpose'
        purpose                                   : payment.Max4Text;

        @Common.Label: 'Remittance info'
        remittance_information_unstructured       : payment.Max140Text;

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        remittance_information_structured         : many payment.StructuredRemittanceInformation16;

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        remittance_information_related            : many payment.RemittanceLocation7;

        @Common.Label: 'Debit confirmation url'
        debit_confirmation_url_address            : payment.Max2048Text;

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        payment_event                             : Association to many PaymentEvents
                                                      on  $self.bic           = bic
                                                      and $self.uetr          = uetr
                                                      and $self.service_level = service_level;

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        process_flow_lanes                        : Association to many PaymentEventProcessFlowLanes
                                                      on  $self.bic           = bic
                                                      and $self.uetr          = uetr
                                                      and $self.service_level = service_level;

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        process_flow_nodes                        : Association to many PaymentEventProcessFlowNodes
                                                      on  $self.bic           = bic
                                                      and $self.uetr          = uetr
                                                      and $self.service_level = service_level;

        @UI.Interval         : true
        @Commen.Label        : 'Payment Date'
        PaymentDate                               : Date;

        @UI.HiddenFilter     : true
        @UI.AdaptationHidden : true
        transaction_status_text                   : String;

        @UI.HiddenFilter     : true
        @UI.AdaptationHidden : true
        transaction_status_criticality            : Int16;

        @UI.HiddenFilter     : true
        @UI.AdaptationHidden : true
        reject_reason_code_text                   : String;

        @UI.HiddenFilter     : true
        @UI.AdaptationHidden : true
        transaction_status_reason_text            : String;

        reject_reason_visibility                  : Boolean;

  }

  @readonly
  entity BICValuehelp {
        @Common.Label: 'BIC'
        @Common.ValueListWithFixedValues
    key bic  : String;

        @Common.Label: 'Name'
        name : String;
  }

  @readonly
  entity TransactionStatusVH {
        @Common.Label: 'Transaction status'
        @Common.ValueListWithFixedValues
    key transaction_status : payment.TransactionIndividualStatus10Code;
        text               : String;
  }

  @readonly
  entity ServiceLevelVH {
        @Common.Label: 'Service level'
        @Common.ValueListWithFixedValues
    key service_level : payment.ServiceLevel5Code;
        text          : String;
  }

  @readonly
  entity PaymentEvents {
        @UI.hidden   : true
    key uetr                                 : payment.UUIDv4Identifier;

        @UI.hidden   : true
    key bic                                  : String;

        @UI.hidden   : true
    key service_level                        : payment.ServiceLevel5Code;

        @Common.Label        : 'From'
        @Common              : {
          Text           : from_name,
          TextArrangement: #TextFirst
        }
    key ![from]                              : payment.AnyBICDec2014Identifier;

        @Common.Label        : 'To'
        @Common              : {
          Text           : to_name,
          TextArrangement: #TextFirst
        }
    key to                                   : payment.BICFIDec2014Identifier;

        @Common.Label        : 'Interbank settlement amount'
        @Measures.ISOCurrency: (interbank_settlement_amount_currency)
        interbank_settlement_amount_amount   : String(19);

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        interbank_settlement_amount_currency : payment.ActiveOrHistoricCurrencyCode;

        @Common.Label        : 'Senders deducts'
        @Common              : {
          Text           : charge_bearer_text,
          TextArrangement: #TextOnly
        }
        charge_bearer                        : payment.ChargeBearerType3Code;

        @Common.Label        : 'Charge amount'
        @Measures.ISOCurrency: (charge_amount_currency)
        charge_amount_amount                 : String(19);

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        charge_amount_currency               : payment.ActiveOrHistoricCurrencyCode;

        @Common.Label: 'Source currency'
        exchange_rate_data_source_currency   : payment.ActiveOrHistoricCurrencyCode;

        @Common.Label: 'Target currency'
        exchange_rate_data_target_currency   : payment.ActiveOrHistoricCurrencyCode;

        @Common.Label: 'Exchange rate'
        exchange_rate_data_exchange_rate     : payment.BaseOneRate;

        @Common.Label        : 'Processing date'
        @UI.DateTimeStyle    : 'long'
        processing_date_time                 : Timestamp;

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        charge_bearer_text                   : String;

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        from_name                            : String;

        @UI.AdaptationHidden : true
        @UI.HiddenFilter     : true
        to_name                              : String;
  }

  @readonly
  entity PaymentEventProcessFlowNodes {
    key id                          : payment.AnyBICDec2014Identifier;
    key laneId                      : payment.Max35Text;
        uetr                        : payment.UUIDv4Identifier;
        bic                         : String;
        service_level               : payment.ServiceLevel5Code;
        ![from]                     : payment.AnyBICDec2014Identifier;
        to                          : payment.BICFIDec2014Identifier;
        interbank_settlement_amount : GPI.MyService.ActiveCurrencyAndAmount;
        charge_bearer               : payment.ChargeBearerType3Code;
        charge_amount               : GPI.MyService.ActiveCurrencyAndAmount;
        exchange_rate_data          : payment.CurrencyExchange12;
        texts                       : Composition of many NodeTexts
                                        on texts.parent = $self;

        @UI.DateTimeStyle: 'long'
        processing_date_time        : Timestamp;
        title                       : String;
        titleAbbreviation           : String;
        focused                     : Boolean;
        state                       : payment.Max35Text;
        stateText                   : payment.Max35Text;
        highlighted                 : Boolean;
        children                    : Composition of many ChildNodes
                                        on children.parent = $self;
        pageId                      : payment.Max450Text;
        header                      : String;
        icon                        : String;
        description                 : String;
        groups                      : Composition of many QuickViewGroups
                                        on groups.parent = $self;
  }

  @readonly
  entity PaymentEventProcessFlowLanes {
    key laneId        : payment.Max35Text;
        uetr          : payment.UUIDv4Identifier;

        bic           : String;
        service_level : payment.ServiceLevel5Code;
        text          : String;
        iconSrc       : String;
        position      : Integer;
  }

  @readonly
  entity ChildNodes {
    key id     : payment.Max35Text;
        parent : Association to one PaymentEventProcessFlowNodes;
  }

  @readonly
  entity NodeTexts {
    key texts  : payment.Max450Text;
        parent : Association to one PaymentEventProcessFlowNodes;
  }

  @readonly
  entity QuickViewGroups {
    key heading  : String;
        elements : Composition of many QuickViewElements
                     on elements.parent = $self;
        parent   : Association to one PaymentEventProcessFlowNodes;
  }

  @readonly
  entity QuickViewElements {
    key element     : payment.Max450Text;
        label       : String;
        value       : String;
        url         : String;
        elementType : String;
        parent      : Association to one QuickViewGroups;
  }
}
