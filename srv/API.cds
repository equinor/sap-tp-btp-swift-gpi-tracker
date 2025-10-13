namespace GPI;

using {gpi.for.Corporates_types as payment} from './external/SWIFT-API-gpi-corporate_api-7.0.3-swagger';

service MyService {

  type ActiveCurrencyAndAmount {
    currency : payment.ActiveCurrencyCode;

    @Measures.ISOCurrency: (currency)
    amount   : String(19);
  }

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

  entity Payments {
        @Common.Label: 'BIC'
    key bic                              : String;

        @Common.Label: 'UETR'
    key uetr                             : payment.UUIDv4Identifier;

        @Common.ValueListWithFixedValues
        @assert.range    : true
        @Common.Label    : 'Service level'
    key service_level                    : payment.ServiceLevel5Code;

        @Common.Label: 'Instruction identification'
        instruction_identification       : payment.RestrictedFINXMax35Text;

        @Common.Label: 'End to end identification'
        end_to_end_identification        : payment.RestrictedFINXMax35Text;

        @Common.Label    : 'Transaction status'
        @Common.ValueListWithFixedValues
        @assert.range    : true
        @Common          : {
          Text           : transaction_status_text,
          TextArrangement: #TextLast
        }
        transaction_status               : payment.TransactionIndividualStatus10Code;

        @Common.Label    : 'Transaction status date'
        @UI.DateTimeStyle: 'medium'
        transaction_status_date          : Timestamp;

        @Common.Label: 'Transaction status reason'
        transaction_status_reason        : payment.PaymentStatusReason13Code;

        @Common.Label: 'Reject return reason'
        reject_return_reason             : payment.TrackerPaymentStatusReason3Code;

        @Common.Label: 'Tracker informing party'
        tracker_informing_party          : payment.BICFIDec2014Identifier;
        instructed_amount                : payment.ActiveOrHistoricCurrencyAndAmount;
        equivalent_amount                : payment.EquivalentAmount2;
        interbank_settlement_amount      : GPI.MyService.ActiveCurrencyAndAmount;
        confirmed_amount                 : GPI.MyService.ActiveCurrencyAndAmount;
        remaining_to_be_confirmed_amount : GPI.MyService.ActiveCurrencyAndAmount;
        previously_confirmed_amount      : GPI.MyService.ActiveCurrencyAndAmount;

        @Common.Label    : 'Requested execution date'
        @UI.DateTimeStyle: 'long'
        requested_execution_date         : Timestamp;

        @Common.Label    : 'Interbank settlement date'
        @UI.DateTimeStyle: 'medium'
        interbank_settlement_date        : Date;

        @Common.Label    : 'Confirmed date'
        @UI.DateTimeStyle: 'long'
        confirmed_date                   : Timestamp;
        ultimate_debtor                  : payment.PartyIdentification221;
        debtor                           : payment.PartyIdentification221;

        @Common.Label    : 'Debtor account'
        debtor_account                   : payment.CashAccount204;

        @Common.Label : 'Creditor'
        creditor                         : payment.PartyIdentification221;
        @Common.Label : 'Creditor account'
        creditor_account                 : payment.CashAccount204;
        ultimate_creditor                : payment.PartyIdentification221;
        creditor_agent                   : payment.BICFIDec2014Identifier;

        @Common.Label: 'Purpose'
        purpose                          : payment.Max4Text;

        remittance_information           : payment.Remittance1;

        @Common.Label: 'Debit confirmation url'
        debit_confirmation_url_address   : payment.Max2048Text;
        payment_event                    : Association to many PaymentEvents
                                             on  $self.bic           = bic
                                             and $self.uetr          = uetr
                                             and $self.service_level = service_level;
        process_flow_lanes               : Association to many PaymentEventProcessFlowLanes
                                             on  $self.bic           = bic
                                             and $self.uetr          = uetr
                                             and $self.service_level = service_level;
        process_flow_nodes               : Association to many PaymentEventProcessFlowNodes
                                             on  $self.bic           = bic
                                             and $self.uetr          = uetr
                                             and $self.service_level = service_level;

        @UI.Interval     : true
        @Commen.Label    : 'Payment Date'
        PaymentDate                      : Date;

        transaction_status_text          : String;
        transaction_status_criticality   : Int16;
  }

  entity BICValuehelp {
    key bic  : String;
        name : String;
  }

  entity TransactionStatusVH {
        @Common.Label: 'Transaction status'
        @Common.ValueListWithFixedValues
    key transaction_status : payment.TransactionIndividualStatus10Code;
        text               : String;
  }

  entity ServiceLevelVH {
        @Common.Label: 'Service level'
        @Common.ValueListWithFixedValues
    key service_level : payment.ServiceLevel5Code;
        text          : String;
  }

  entity PaymentEvents {
        @UI.hidden   : true
    key uetr                        : payment.UUIDv4Identifier;

        @UI.hidden   : true
    key bic                         : String;

        @UI.hidden   : true
    key service_level               : payment.ServiceLevel5Code;

        @Common.Label: 'From'
        @Common          : {
          Text           : from_name,
          TextArrangement: #TextLast
        }
    key ![from]                     : payment.AnyBICDec2014Identifier;

        @Common.Label: 'To'
        @Common          : {
          Text           : to_name,
          TextArrangement: #TextLast
        }
    key to                          : payment.BICFIDec2014Identifier;

        @Common.Label: 'Interbank settlement amount'
        interbank_settlement_amount : GPI.MyService.ActiveCurrencyAndAmount;

        @Common.Label    : 'Senders deducts'
        @Common          : {
          Text           : charge_bearer_text,
          TextArrangement: #TextOnly
        }
        charge_bearer               : payment.ChargeBearerType3Code;

        @Common.Label: 'Charge amount'
        charge_amount               : GPI.MyService.ActiveCurrencyAndAmount;

        @Common.Label: 'Exchange rate'
        exchange_rate_data          : payment.CurrencyExchange12;

        @Common.Label    : 'Processing date'
        @UI.DateTimeStyle: 'long'
        processing_date_time        : Timestamp;

        charge_bearer_text          : String;

        from_name                   : String;
        to_name                     : String;
  }

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

  entity PaymentEventProcessFlowLanes {
    key laneId        : payment.Max35Text;
        uetr          : payment.UUIDv4Identifier;

        bic           : String;
        service_level : payment.ServiceLevel5Code;
        text          : String;
        iconSrc       : String;
        position      : Integer;
  }

  entity ChildNodes {
    key id     : payment.Max35Text;
        parent : Association to one PaymentEventProcessFlowNodes;
  }

  entity NodeTexts {
    key texts  : payment.Max450Text;
        parent : Association to one PaymentEventProcessFlowNodes;
  }

  entity QuickViewGroups {
    key heading  : String;
        elements : Composition of many QuickViewElements
                     on elements.parent = $self;
        parent   : Association to one PaymentEventProcessFlowNodes;
  }

  entity QuickViewElements {
    key element     : payment.Max450Text;
        label       : String;
        value       : String;
        url         : String;
        elementType : String;
        parent      : Association to one QuickViewGroups;
  }
}
