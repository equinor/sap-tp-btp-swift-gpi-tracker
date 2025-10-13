/* checksum : 74a72208952400062f747e7635d10d95 */
namespace gpi.for;

@Capabilities.BatchSupported : false
@Capabilities.KeyAsSegmentSupported : true
@Core.Description : 'gpi for Corporates'
@Core.SchemaVersion : '7.0.3'
@Core.LongDescription : ```
About SWIFT gpi for Corporates (g4C)

Faster, traceable and transparent cross-border payments.

With SWIFT gpi for Corporates (g4C), gpi flows are now directly integrated into corporate treasury applications (TMS/ERP), allowing multi-bank corporates to initiate and track their outgoing payments (Pay and trace) and to be notified about incoming payments (Inbound tracking) in a bank-agnostic way.

gpi for Corporates delivers the following benefits:

  * Multi-bank unique end-to-end reference generated at payment initiation
  * Full visibility on outgoing and incoming cross-border transactions (time, routing, number of intermediaries, fees)
  * Certainty and visibility on receivables with structured payment advice information, allowing for accelerated reconciliation and optimized liquidity management
  * Improved supplier relationship with certainty of payment, proof of execution and proactive issue-resolution
  * SWIFT gpi for Corporates is based on a common rulebook and is ISO 20022 compliant.
  
About the g4C API

With this API, g4C payment tracking is now real-time allowing corporates to track their own payments and g4C banks to track their customer’s payments. As such, the g4C API can be used in a tracker-to-corporate or a tracker-to-bank mode (under the control of the account servicer of the corporate). 
The API connectivity between Tracker and bank and Tracker and corporate happens via Swift (SDK/Microgateway). Being subscribed to gpi for Corporates is a pre-requisite to the use of these APIs over the Swift network. Please contact SWIFT for more details.

**Release note for changes between 6.0.2 and the new 7.0.0 version**|

Note that the availability of the API does not mean that the features are immediately available for consumption. Features will be released within a 2-year timeframe.

  *inclusion of rich elements to support richness: end to end identification, purpose code, related remittance information, structured remittance information, ultimate debtor and ultimate creditor. These rich fields, in case used in the underlying pacs.008, will be fed into the g4C notification.
  
  *merge of outbound (pay and trace) and inbound POST endpoint into one single endpoint since formats are almost equal. Inclusion of service level element in search parameters to allow for selection of outbound (G003) or inbound (G007).
  
  *addition of new optional search parameter (apart from service level) in GET request: end to end identification 
  
  *inclusion of new element debit confirmation URL address to support the proof of debit functionality replacing copy of MT 103
  
  *tracking of payment initiation legs (MT 101/pain.001): Corporate to bank flows on SCORE FINplus InterAct will be tracked as part of the g4C outbound service. In this context a new status RCVD (received) is introduced to allow reporting the event where payment initiation (from corporate) is received by the debtor agent (his bank). In the relay scenario, also the leg between the forwarding agent and the debtor agent will receive a RCVD status once received by the debtor agent.
   To support the tracking of payment initiation legs, following changes have been introduced: |
   
   -new status RCVD (mentioned before)
   
   -inclusion of equivalent amount element while instructed amount has been made optional (pain.001 allows choice between these two amount elements)
   
   -inclusion of requested execution date element while interbank settlement date has been made optional (pain.001 only allows for a requested execution date)
   
   -from element in payment event is redefined with AnyBIC (previously BICFI) since from will include corporate BIC in case payment initiation is tracked.
   
**Release note for changes between 7.0.0 and the new 7.0.1 version**|       
   
Change is related to the AccountIdentification47Choice in terms of the location of the OneOf 

**Release note for changes between 7.0.1 and the new 7.0.2 version**|       
   
Component Paymenttransaction125 became Paymenttransaction150

PaymentStatusReason12Code became PaymentStatusReason13Code because now that pay and trace and inbound tracking APIs are merged we need all values in list: G001, G005 and G006.

PaymentEvent14 became PaymentEvent16 introducing the ‘interbank settlement amount’ at payment event level as optional additional element. Examples also updated to reflect this new element.

**Release note for changes between 7.0.2 and the new 7.0.3 version**|       
   
Change is related to the AccountIdentification47Choice which was replaced by AccountIdentification58Choice that applies the correct format of the OneOf. Also component ExternalPaymentStatus. Component Paymenttransaction150 became Paymenttransaction150  

```
service Corporates {
  @Common.Label : 'Corporate payments'
  @Core.Description : 'Corporate payments search.'
  @Core.LongDescription : ```
  This API provides the status and the related transaction-level information regarding a specific outbound or inbound payment. Corporate customers must pass the BIC of their servicing bank.
  
  This API allows for multiple combinations of search criteria. For example the UETR search should only supply the UETR. See the request examples for an illustration of the different varieties of searches that are supported. For each illustrative search there is a corresponding response example. Note that a search without a request body is invalid.      
  
  ```
  @openapi.path : '/payments/corporate'
  action payments_corporate_post(
    @assert.format : '^[a-z]{6,6}[a-z2-9][a-np-z0-9]$'
    @Core.Example.$Type : 'Core.PrimitiveExampleValue'
    @Core.Example.Value : 'cclabeb0'
    @description : 'The BIC of your account holding bank – must be provided by corporate customers, does not have to be provided by banks.'
    @openapi.in : 'header'
    @openapi.name : 'x-bic'
    x_bic : String,
    @assert.format : '^[a-z]{6,6}[a-z2-9][a-np-z0-9]$'
    @Core.Example.$Type : 'Core.PrimitiveExampleValue'
    @Core.Example.Value : 'cclabeb0'
    @description : 'The BIC of the bank or corporate customer calling the service. '
    @openapi.in : 'header'
    @openapi.required : true
    client : String,
    @openapi.in : 'body'
    body : Corporates_types.CorporateTransactionTrackingRequest1
  ) returns Corporates_types.CorporateTransactionTrackingResponse1;
};

type Corporates_types.ErrorMessage {
  @assert.range : true
  @mandatory : true
  severity : String enum {
    Fatal;
    Transient;
    Logic;
  };
  @mandatory : true
  code : String;
  @mandatory : true
  text : String;
  user_message : String;
  more_info : String;
};

@description : 'Choice of formats for the type of address.'
@openapi.oneOf : '[{"type":"object","additionalProperties":false,"properties":{"code":{"$ref":"#/components/schemas/AddressType2Code"}},"required":["code"]},{"type":"object","additionalProperties":false,"properties":{"proprietary":{"$ref":"#/components/schemas/GenericIdentification30"}},"required":["proprietary"]}]'
@open : true
type Corporates_types.AddressType3Choice { };

@description : 'Specifies the unique identification of an account as assigned by the account servicer.'
@openapi.oneOf : '[{"type":"object","additionalProperties":false,"properties":{"iban":{"$ref":"#/components/schemas/IBAN2007Identifier"}},"required":["iban"]},{"type":"object","additionalProperties":false,"properties":{"identification":{"$ref":"#/components/schemas/Max34Text"}},"required":["identification"]}]'
@open : true
type Corporates_types.AccountIdentification58Choice { };

@description : 'A number of monetary units specified in an active currency where the unit of currency is explicit and compliant with ISO 4217.'
type Corporates_types.ActiveCurrencyAndAmount {
  @mandatory : true
  currency : Corporates_types.ActiveCurrencyCode;
  @assert.format : '^0*(([0-9]{0,13}\.[0-9]{1,5})|([0-9]{0,14}\.[0-9]{1,4})|([0-9]{0,15}\.[0-9]{1,3})|([0-9]{0,16}\.[0-9]{1,2})|([0-9]{0,17}\.[0-9]{1,1})|([0-9]{0,18}\.)|0*|([0-9]{0,18}))$'
  @mandatory : true
  amount : String(19);
};

@description : 'A code allocated to a currency by a Maintenance Agency under an international identification scheme as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds".'
@assert.format : '^[A-Z]{3,3}$'
type Corporates_types.ActiveCurrencyCode : String;

@description : 'A number of monetary units specified in an active or a historic currency where the unit of currency is explicit and compliant with ISO 4217.'
type Corporates_types.ActiveOrHistoricCurrencyAndAmount {
  @mandatory : true
  currency : Corporates_types.ActiveOrHistoricCurrencyCode;
  @Measures.ISOCurrency: (currency) 
  @assert.format : '^0*(([0-9]{0,13}\.[0-9]{1,5})|([0-9]{0,14}\.[0-9]{1,4})|([0-9]{0,15}\.[0-9]{1,3})|([0-9]{0,16}\.[0-9]{1,2})|([0-9]{0,17}\.[0-9]{1,1})|([0-9]{0,18}\.)|0*|([0-9]{0,18}))$'
  @mandatory : true
  amount : String(19);
};

@description : 'A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds".'
@assert.format : '^[A-Z]{3,3}$'
type Corporates_types.ActiveOrHistoricCurrencyCode : String;

@description : ```
Specifies the type of address.
*\`ADDR\`-Address is the complete postal address.
*\`PBOX\`-Address is a postal office (PO) box.
*\`HOME\`-Address is the home address.
*\`BIZZ\`-Address is the business address.
*\`MLTO\`-Address is the address to which mail is sent.
*\`DLVY\`-Address is the address to which delivery is to take place.
```
@assert.range : true
type Corporates_types.AddressType2Code : String enum {
  ADDR;
  PBOX;
  HOME;
  BIZZ;
  MLTO;
  DLVY;
};

@description : 'Code allocated to a financial or non-financial institution by the ISO 9362 Registration Authority, as described in ISO 9362: 2014 - "Banking - Banking telecommunication messages - Business identifier code (BIC)".'
@assert.format : '^[A-Z0-9]{4,4}[A-Z]{2,2}[A-Z0-9]{2,2}([A-Z0-9]{3,3}){0,1}$'
type Corporates_types.AnyBICDec2014Identifier : String;

@description : 'Code allocated to a financial institution by the ISO 9362 Registration Authority as described in ISO 9362: 2014 - "Banking - Banking telecommunication messages - Business identifier code (BIC)".'
@assert.format : '^[A-Z0-9]{4,4}[A-Z]{2,2}[A-Z0-9]{2,2}([A-Z0-9]{3,3}){0,1}$'
type Corporates_types.BICFIDec2014Identifier : String;

@description : 'Rate expressed as a decimal, for example, 0.7 is 7/10 and 70%.'
type Corporates_types.BaseOneRate : String(12);

@description : 'Provides the details to identify an account.'
type Corporates_types.CashAccount204 {
  @mandatory : true
  identification : Corporates_types.AccountIdentification58Choice;
};

@description : ```
Specifies which party/parties will bear the charges associated with the processing of the payment transaction.
*\`SHAR\`-In a credit transfer context, means that transaction charges on the sender side are to be borne by the debtor, transaction charges on the receiver side are to be borne by the creditor. In a direct debit context, means that transaction charges on the sender side are to be borne by the creditor, transaction charges on the receiver side are to be borne by the debtor.
*\`DEBT\`-All transaction charges are to be borne by the debtor.
*\`CRED\`-All transaction charges are to be borne by the creditor.
```
@assert.range : true
type Corporates_types.ChargeBearerType3Code : String enum {
  SHAR;
  DEBT;
  CRED;
};

@description : 'Specifies the details of the contact person.'
type Corporates_types.Contact4 {
  name_prefix : Corporates_types.NamePrefix2Code;
  name : Corporates_types.Max140Text;
  phone_number : Corporates_types.PhoneNumber;
  mobile_number : Corporates_types.PhoneNumber;
  fax_number : Corporates_types.PhoneNumber;
  email_address : Corporates_types.Max2048Text;
  email_purpose : Corporates_types.Max35Text;
  job_title : Corporates_types.Max35Text;
  responsibility : Corporates_types.Max35Text;
  department : Corporates_types.Max70Text;
  other : many Corporates_types.OtherContact1;
  preferred_method : Corporates_types.PreferredContactMethod1Code;
};

@description : 'Includes resource for Corporate Tracking Transaction Request.'
type Corporates_types.CorporateTransactionTrackingRequest1 {
  uetr : Corporates_types.UUIDv4Identifier;
  start_date_time : Corporates_types.ISONormalisedDateTime;
  end_date_time : Corporates_types.ISONormalisedDateTime;
  @mandatory : true
  service_level : Corporates_types.ServiceLevel5Code;
  event_filter : Corporates_types.TrueFalseIndicator;
  status_filter : Corporates_types.TransactionIndividualStatus10Code;
  end_to_end_identification : Corporates_types.Max35Text;
  debtor : Corporates_types.AnyBICDec2014Identifier;
  debtor_account : Corporates_types.Max34Text;
  creditor : Corporates_types.AnyBICDec2014Identifier;
  creditor_account : Corporates_types.Max34Text;
  maximum_number : Corporates_types.Max3Number;
  next : Corporates_types.Max450Text;
};

@description : 'Includes the resource for the Corporate Transaction Tracking Response'
type Corporates_types.CorporateTransactionTrackingResponse1 {
  @mandatory : true
  payment_transaction : many Corporates_types.PaymentTransaction163;
  next : Corporates_types.Max450Text;
};

@description : 'Code to identify a country, a dependency, or another area of particular geopolitical interest, on the basis of country names obtained from the United Nations (ISO 3166, Alpha-2 code).'
@assert.format : '^[A-Z]{2,2}$'
type Corporates_types.CountryCode : String;

@description : `Specifies if an operation is an increase or a decrease.
*\`CRDT\`-Operation is an increase.
*\`DBIT\`-Operation is a decrease.`
@assert.range : true
type Corporates_types.CreditDebitCode : String enum {
  CRDT;
  DBIT;
};

@description : 'Reference information provided by the creditor to allow the identification of the underlying documents.'
type Corporates_types.CreditorReferenceInformation2 {
  type : Corporates_types.CreditorReferenceType2;
  reference : Corporates_types.Max35Text;
};

@description : 'Specifies the type of creditor reference.'
type Corporates_types.CreditorReferenceType2 {
  @mandatory : true
  code_or_proprietary : Corporates_types.CreditorReferenceType1Choice;
  issuer : Corporates_types.Max35Text;
};

@description : 'Specifies the type of document referred by the creditor.'
@openapi.oneOf : '[{"type":"object","additionalProperties":false,"properties":{"code":{"$ref":"#/components/schemas/DocumentType3Code"}},"required":["code"]},{"type":"object","additionalProperties":false,"properties":{"proprietary":{"$ref":"#/components/schemas/Max35Text"}},"required":["proprietary"]}]'
@open : true
type Corporates_types.CreditorReferenceType1Choice { };

@description : 'Contains the set of elements used to provide details of the currency exchange.'
type Corporates_types.CurrencyExchange12 {
  @mandatory : true
  source_currency : Corporates_types.ActiveOrHistoricCurrencyCode;
  @mandatory : true
  target_currency : Corporates_types.ActiveOrHistoricCurrencyCode;
  @mandatory : true
  exchange_rate : Corporates_types.BaseOneRate;
};

@description : 'Choice between a date or a date and time format.'
@openapi.oneOf : '[{"type":"object","additionalProperties":false,"properties":{"date":{"$ref":"#/components/schemas/ISODate"}},"required":["date"]},{"type":"object","additionalProperties":false,"properties":{"date_time":{"$ref":"#/components/schemas/ISODateTime"}},"required":["date_time"]}]'
@open : true
type Corporates_types.DateAndDateTime2Choice { };

@description : 'Date and place of birth of a person.'
type Corporates_types.DateAndPlaceOfBirth1 {
  @mandatory : true
  birth_date : Corporates_types.ISODate;
  province_of_birth : Corporates_types.Max35Text;
  @mandatory : true
  city_of_birth : Corporates_types.Max35Text;
  @mandatory : true
  country_of_birth : Corporates_types.CountryCode;
};

@description : 'Range of time defined by a start date and an end date.'
type Corporates_types.DatePeriod2 {
  @mandatory : true
  from_date : Corporates_types.ISODate;
  @mandatory : true
  to_date : Corporates_types.ISODate;
};

@description : 'Specifies the amount with a specific type.'
type Corporates_types.DiscountAmountAndType1 {
  type : Corporates_types.DiscountAmountType1Choice;
  @mandatory : true
  amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
};

@description : 'Specifies the amount type.'
@openapi.oneOf : '[{"type":"object","additionalProperties":false,"properties":{"code":{"$ref":"#/components/schemas/ExternalDiscountAmountType1Code"}},"required":["code"]},{"type":"object","additionalProperties":false,"properties":{"proprietary":{"$ref":"#/components/schemas/Max35Text"}},"required":["proprietary"]}]'
@open : true
type Corporates_types.DiscountAmountType1Choice { };

@description : 'Set of elements used to provide information on the amount and reason of the document adjustment.'
type Corporates_types.DocumentAdjustment1 {
  @mandatory : true
  amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
  credit_debit_indicator : Corporates_types.CreditDebitCode;
  reason : Corporates_types.Max4Text;
  additional_information : Corporates_types.Max140Text;
};

@description : 'Identifies the documents referred to in the remittance information.'
type Corporates_types.DocumentLineIdentification1 {
  type : Corporates_types.DocumentLineType1;
  number : Corporates_types.Max35Text;
  related_date : Corporates_types.ISODate;
};

@description : `Provides document line information.
`
type Corporates_types.DocumentLineInformation1 {
  @mandatory : true
  identification : many Corporates_types.DocumentLineIdentification1;
  description : Corporates_types.Max2048Text;
  amount : Corporates_types.RemittanceAmount3;
};

@description : 'Specifies the type of the document line identification.'
type Corporates_types.DocumentLineType1 {
  @mandatory : true
  code_or_proprietary : Corporates_types.DocumentLineType1Choice;
  issuer : Corporates_types.Max35Text;
};

@description : 'Specifies the type of the document line identification.'
@openapi.oneOf : '[{"type":"object","additionalProperties":false,"properties":{"code":{"$ref":"#/components/schemas/ExternalDocumentLineType1Code"}},"required":["code"]},{"type":"object","additionalProperties":false,"properties":{"proprietary":{"$ref":"#/components/schemas/Max35Text"}},"required":["proprietary"]}]'
@open : true
type Corporates_types.DocumentLineType1Choice { };

@description : ```
Specifies a type of financial or commercial document.
*\`RADM\`-Document is a remittance advice sent separately from the current transaction.
*\`RPIN\`-Document is a linked payment instruction to which the current payment instruction is related, for example, in a cover scenario.
*\`FXDR\`-Document is a pre-agreed or pre-arranged foreign exchange transaction to which the payment transaction refers.
*\`DISP\`-Document is a dispatch advice.
*\`PUOR\`-Document is a purchase order.
*\`SCOR\`-Document is a structured communication reference provided by the creditor to identify the referred transaction.
```
@assert.range : true
type Corporates_types.DocumentType3Code : String enum {
  RADM;
  RPIN;
  FXDR;
  DISP;
  PUOR;
  SCOR;
};

@description : ```
Specifies a type of financial or commercial document.
*\`MSIN\`-Document is an invoice claiming payment for the supply of metered services, for example gas or electricity supplied to a fixed meter.
*\`CNFA\`-Document is a credit note for the final amount settled for a commercial transaction.
*\`DNFA\`-Document is a debit note for the final amount settled for a commercial transaction.
*\`CINV\`-Document is an invoice.
*\`CREN\`-Document is a credit note.
*\`DEBN\`-Document is a debit note.
*\`HIRI\`-Document is an invoice for the hiring of human resources or renting goods or equipment.
*\`SBIN\`-Document is an invoice issued by the debtor.
*\`CMCN\`-Document is an agreement between the parties, stipulating the terms and conditions of the delivery of goods or services.
*\`SOAC\`-Document is a statement of the transactions posted to the debtor's account at the supplier.
*\`DISP\`-Document is a dispatch advice.
*\`BOLD\`-Document is a shipping notice.
*\`VCHR\`-Document is an electronic payment document.
*\`AROI\`-Document is a payment that applies to a specific source document.
*\`TSUT\`-Document is a transaction identifier as assigned by the Trade Services Utility.
*\`PUOR\`-Document is a purchase order.
```
@assert.range : true
type Corporates_types.DocumentType6Code : String enum {
  MSIN;
  CNFA;
  DNFA;
  CINV;
  CREN;
  DEBN;
  HIRI;
  SBIN;
  CMCN;
  SOAC;
  DISP;
  BOLD;
  VCHR;
  AROI;
  TSUT;
  PUOR;
};

@description : 'Amount of money to be moved between the debtor and creditor, expressed in the currency of the debtor''s account, and the currency in which the amount is to be moved.'
type Corporates_types.EquivalentAmount2 {
  @mandatory : true
  amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
  @mandatory : true
  currency_of_transfer : Corporates_types.ActiveOrHistoricCurrencyCode;
};

@description : 'Specifies an alphanumeric string with a length of 4 characters.'
@assert.format : '^[a-zA-Z0-9]{4}$'
type Corporates_types.Exact4AlphaNumericText : String;

@description : `Specifies the nature, or use, of the amount in the format of character string with a maximum length of 4 characters.
The list of valid codes is an external code list published separately.
External code sets can be downloaded from www.iso20022.org. `
type Corporates_types.ExternalDiscountAmountType1Code : String(4);

@description : 'Specifies the document line type as published in an external document type code list.'
type Corporates_types.ExternalDocumentLineType1Code : String(4);

@description : 'Specifies the garnishment type as published in an external document type code list.'
type Corporates_types.ExternalGarnishmentType1Code : String(4);

@description : ```
Provides reason for reject/return.
*\`AM06\`-Below limit.
*\`RC01\`-Bank identifier code specified in the message has an incorrect format (formerly IncorrectFormatForRoutingCode).
*\`AC06\`-Account specified is blocked, prohibiting posting of transactions against it.
*\`AM07\`-Amount specified in message has been blocked by regulatory authorities.
*\`AC04\`-Account number specified has been closed on the bank of account's books.
*\`AC07\`-Creditor account number closed.
*\`G004\`-Credit to the creditor's account is pending as status Originator is waiting for funds provided via a cover.
*\`DUPL\`-Payment is a duplicate of another payment.
*\`ERIN\`-The Extended Remittance Information (ERI) option is not supported.
*\`FOCR\`-Return following a cancellation request.
*\`FR01\`-Returned as a result of fraud.
*\`BE01\`-Identification of end customer is not consistent with associated account number. (formerly CreditorConsistency).
*\`AC01\`-Account number is invalid or missing
*\`AGNT\`-Agent in the payment workflow is incorrect.
*\`CURR\`-Currency of the payment is incorrect.
*\`AM04\`-Amount of funds available to cover specified message amount is insufficient.
*\`FF06\`-Category Purpose code is missing or invalid.
*\`RC08\`-Routing code not valid for local clearing.
*\`RC04\`-Creditor bank identifier is invalid or missing.
*\`AC02\`-Debtor account number invalid or missing\r

*\`AC13\`-Debtor account type is missing or invalid.
*\`RR11\`-Invalid or missing identification of a bank proprietary service.
*\`RC03\`-Debtor bank identifier is invalid or missing
*\`RC11\`-Intermediary Agent is invalid or missing.
*\`FF05\`-Local Instrument code is missing or invalid.
*\`RR12\`-Invalid or missing identification required within a particular country or payment type.
*\`FF03\`-Payment Type Information is missing or invalid. Generic usage if cannot specify Service Level or Local Instrument code.
*\`FF07\`-Purpose is missing or invalid.
*\`FF04\`-Service Level code is missing or invalid.
*\`RR09\`-Structured creditor reference invalid or missing.
*\`BE04\`-Specification of creditor's address, which is required for payment, is missing/not correct (formerly IncorrectCreditorAddress).
*\`RR03\`-Specification of the creditor's name and/or address needed for regulatory requirements is insufficient or missing.
*\`RR01\`-Specification of the debtor’s account or unique identification needed for reasons of regulatory requirements is insufficient or missing
*\`BE07\`-Specification of debtor's address, which is required for payment, is missing/not correct.
*\`RR02\`-Specification of the debtor’s name and/or address needed for regulatory requirements is insufficient or missing.\r

*\`NOAS\`-Failed to contact beneficiary.
*\`AM02\`-Specific transaction/message amount is greater than allowed maximum.
*\`AM03\`-Specific message amount is an non processable currency outside of existing agreement.
*\`NOCM\`-Customer account is not compliant with regulatory requirements, for example FICA (in South Africa) or any other regulatory requirements which render an account inactive for certain processing.
*\`MS03\`-Reason has not been specified by agent.
*\`MS02\`-Reason has not been specified by end customer.
*\`RR05\`-Regulatory or Central Bank Reporting information missing, incomplete or invalid.
*\`RR04\`-Regulatory Reason 
*\`RR07\`-Remittance information structure does not comply with rules for payment type.
*\`RR08\`-Remittance information truncated to comply with rules for payment type.
*\`CUST\`-At request of creditor.
*\`RR06\`-Tax information missing, incomplete or invalid.
*\`UPAY\`-Payment is not justified.
*\`BE05\`-Party who initiated the message is not recognised by the end customer.
*\`AM09\`-Amount received is not the amount agreed or expected.
*\`RUTA\`-Return following investigation request and no remediation possible.
```
@assert.range : true
type Corporates_types.TrackerPaymentStatusReason3Code : String enum {
  AM06;
  RC01;
  AC06;
  AM07;
  AC04;
  AC07;
  G004;
  DUPL;
  ERIN;
  FOCR;
  FR01;
  BE01;
  AC01;
  AGNT;
  CURR;
  AM04;
  FF06;
  RC08;
  RC04;
  AC02;
  AC13;
  RR11;
  RC03;
  RC11;
  FF05;
  RR12;
  FF03;
  FF07;
  FF04;
  RR09;
  BE04;
  RR03;
  RR01;
  BE07;
  RR02;
  NOAS;
  AM02;
  AM03;
  NOCM;
  MS03;
  MS02;
  RR05;
  RR04;
  RR07;
  RR08;
  CUST;
  RR06;
  UPAY;
  BE05;
  AM09;
  RUTA;
};

@description : `Specifies the external organisation identification scheme name code in the format of character string with a maximum length of 4 characters.
The list of valid codes is an external code list published separately.
External code sets can be downloaded from www.iso20022.org.      `
type Corporates_types.ExternalOrganisationIdentification1Code : String(4);

@description : `Specifies the external person identification scheme name code in the format of character string with a maximum length of 4 characters.
The list of valid codes is an external code list published separately.
External code sets can be downloaded from www.iso20022.org.      `
type Corporates_types.ExternalPersonIdentification1Code : String(4);

@description : `Specifies the nature, or use, of the amount in the format of character string with a maximum length of 4 characters.
The list of valid codes is an external code list published separately.
External code sets can be downloaded from www.iso20022.org.      `
type Corporates_types.ExternalTaxAmountType1Code : String(4);

@description : 'Provides remittance information about a payment for garnishment-related purposes.'
type Corporates_types.Garnishment3 {
  @mandatory : true
  type : Corporates_types.GarnishmentType1;
  garnishee : Corporates_types.PartyIdentification135;
  garnishment_administrator : Corporates_types.PartyIdentification135;
  reference_number : Corporates_types.Max140Text;
  date : Corporates_types.ISODate;
  remitted_amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
  family_medical_insurance_indicator : Corporates_types.TrueFalseIndicator;
  employee_termination_indicator : Corporates_types.TrueFalseIndicator;
};

@description : 'Specifies the type of garnishment.'
type Corporates_types.GarnishmentType1 {
  @mandatory : true
  code_or_proprietary : Corporates_types.GarnishmentType1Choice;
  issuer : Corporates_types.Max35Text;
};

@description : 'Specifies the type of garnishment.'
@openapi.oneOf : '[{"type":"object","additionalProperties":false,"properties":{"code":{"$ref":"#/components/schemas/ExternalGarnishmentType1Code"}},"required":["code"]},{"type":"object","additionalProperties":false,"properties":{"proprietary":{"$ref":"#/components/schemas/Max35Text"}},"required":["proprietary"]}]'
@open : true
type Corporates_types.GarnishmentType1Choice { };

@description : 'Information related to an identification, for example, party identification or account identification.'
type Corporates_types.GenericIdentification30 {
  @mandatory : true
  identification : Corporates_types.Exact4AlphaNumericText;
  @mandatory : true
  issuer : Corporates_types.Max35Text;
  scheme_name : Corporates_types.Max35Text;
};

@description : 'Information related to an identification of an organisation.'
type Corporates_types.GenericOrganisationIdentification1 {
  @mandatory : true
  identification : Corporates_types.Max35Text;
  scheme_name : Corporates_types.OrganisationIdentificationSchemeName1Choice;
  issuer : Corporates_types.Max35Text;
};

@description : 'Information related to an identification of a person.'
type Corporates_types.GenericPersonIdentification1 {
  @mandatory : true
  identification : Corporates_types.Max35Text;
  scheme_name : Corporates_types.PersonIdentificationSchemeName1Choice;
  issuer : Corporates_types.Max35Text;
};

@description : 'An identifier used internationally by financial institutions to uniquely identify the account of a customer at a financial institution, as described in the latest edition of the international standard ISO 13616: 2007 - "Banking and related financial services - International Bank Account Number (IBAN)".'
@assert.format : '^[A-Z]{2,2}[0-9]{2,2}[a-zA-Z0-9]{1,30}$'
type Corporates_types.IBAN2007Identifier : String;

@description : 'A particular point in the progression of time in a calendar year expressed in the YYYY-MM-DD format. This representation is defined in "XML Schema Part 2: Datatypes Second Edition - W3C Recommendation 28 October 2004" which is aligned with ISO 8601.'
@assert.format : '^(?:[1-9]\d{3}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1\d|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[1-9]\d(?:0[48]|[2468][048]|[13579][26])|(?:[2468][048]|[13579][26])00)-02-29)(?:Z|[+-][01]\d:[0-5]\d)?$'
type Corporates_types.ISODate : String;

@description : ```
A particular point in the progression of time defined by a mandatory date and a mandatory time component, expressed in either UTC time format (YYYY-MM-DDThh:mm:ss.sssZ), local time with UTC offset format (YYYY-MM-DDThh:mm:ss.sss+/-hh:mm), or local time format (YYYY-MM-DDThh:mm:ss.sss). These representations are defined in "XML Schema Part 2: Datatypes Second Edition - W3C Recommendation 28 October 2004" which is aligned with ISO 8601.
Note on the time format:
1) beginning / end of calendar day
00:00:00 = the beginning of a calendar day
24:00:00 = the end of a calendar day
2) fractions of second in time format
Decimal fractions of seconds may be included. In this case, the involved parties shall agree on the maximum number of digits that are allowed.
```
@assert.format : '^(?:[1-9]\d{3}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1\d|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[1-9]\d(?:0[48]|[2468][048]|[13579][26])|(?:[2468][048]|[13579][26])00)-02-29)T(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d(?:\.[0-9]+)?(?:Z|[+-][01]\d:[0-5]\d)?$'
type Corporates_types.ISODateTime : String;

@description : 'an ISODateTime whereby all timezoned dateTime values are UTC.'
@assert.format : '^(?:[1-9]\d{3}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1\d|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[1-9]\d(?:0[48]|[2468][048]|[13579][26])|(?:[2468][048]|[13579][26])00)-02-29)T(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d(?:\.[0-9]+)?(?:Z)$'
type Corporates_types.ISONormalisedDateTime : String;

@description : 'Legal Entity Identifier is a code allocated to a party as described in ISO 17442 "Financial Services - Legal Entity Identifier (LEI)".'
@assert.format : '^[A-Z0-9]{18,18}[0-9]{2,2}$'
type Corporates_types.LEIIdentifier : String;

@description : 'Specifies a character string with a maximum length of 16 characters.'
type Corporates_types.Max16Text : String(16);

@description : 'Specifies a character string with a maximum length of 70characters.'
type Corporates_types.Max70Text : String(70);

@description : 'Specifies a character string with a maximum length of 128 characters.'
type Corporates_types.Max128Text : String(128);

@description : 'Specifies a character string with a maximum length of 140 characters.'
type Corporates_types.Max140Text : String(140);

@description : 'Specifies a character string with a maximum length of 2048 characters.'
type Corporates_types.Max2048Text : String(2048);

@description : 'Specifies a character string with a maximum length of 34 characters.'
type Corporates_types.Max34Text : String(34);

@description : 'Specifies a character string with a maximum length of 350 characters.'
type Corporates_types.Max450Text : String(350);

@description : 'Specifies a character string with a maximum length of 35 characters.'
type Corporates_types.Max35Text : String(35);

@description : 'Number (max 999) of objects represented as an integer.'
type Corporates_types.Max3Number : String(4);

@description : 'Specifies a character string with a maximum length of 4 characters.'
type Corporates_types.Max4Text : String(4);

@description : 'Information that locates and identifies a party.'
type Corporates_types.NameAndAddress16 {
  @mandatory : true
  name : Corporates_types.Max140Text;
  @mandatory : true
  address : Corporates_types.PostalAddress24;
};

@description : ```
Specifies the terms used to formally address a person.
*\`DOCT\`-Title of the person is Doctor or Dr.
*\`MADM\`-Title of the person is Madam.
*\`MISS\`-Title of the person is Miss.
*\`MIST\`-Title of the person is Mister or Mr.
*\`MIKS\`-Title of the person is gender neutral (Mx).
```
@assert.range : true
type Corporates_types.NamePrefix2Code : String enum {
  DOCT;
  MADM;
  MISS;
  MIST;
  MIKS;
};

@description : 'Number of objects represented as an integer.'
type Corporates_types.Number : String(19);

@description : 'Unique and unambiguous way to identify an organisation.'
type Corporates_types.OrganisationIdentification29 {
  any_bic : Corporates_types.AnyBICDec2014Identifier;
  lei : Corporates_types.LEIIdentifier;
  other : many Corporates_types.GenericOrganisationIdentification1;
};

@description : 'Sets of elements to identify a name of the organisation identification scheme.'
@openapi.oneOf : '[{"type":"object","additionalProperties":false,"properties":{"code":{"$ref":"#/components/schemas/ExternalOrganisationIdentification1Code"}},"required":["code"]},{"type":"object","additionalProperties":false,"properties":{"proprietary":{"$ref":"#/components/schemas/Max35Text"}},"required":["proprietary"]}]'
@open : true
type Corporates_types.OrganisationIdentificationSchemeName1Choice { };

@description : 'Communication device number or electronic address used for communication.'
type Corporates_types.OtherContact1 {
  @mandatory : true
  channel_type : Corporates_types.Max4Text;
  identification : Corporates_types.Max128Text;
};

@description : 'Specifies the identification of a person or an organisation.'
type Corporates_types.PartyIdentification135 {
  name : Corporates_types.Max140Text;
  postal_address : Corporates_types.PostalAddress24;
  identification : Corporates_types.Party38Choice;
  country_of_residence : Corporates_types.CountryCode;
  contact_details : Corporates_types.Contact4;
};

@description : 'Specifies the identification of a person or an organisation.'
type Corporates_types.PartyIdentification221 {
  name : Corporates_types.Max140Text;
  any_bic : Corporates_types.AnyBICDec2014Identifier;
};

@description : 'Nature or use of the account.'
@openapi.oneOf : '[{"type":"object","additionalProperties":false,"properties":{"organisation_identification":{"$ref":"#/components/schemas/OrganisationIdentification29"}},"required":["organisation_identification"]},{"type":"object","additionalProperties":false,"properties":{"private_identification":{"$ref":"#/components/schemas/PersonIdentification13"}},"required":["private_identification"]}]'
@open : true
type Corporates_types.Party38Choice { };

@description : `This groups the information of an event, namely of a payment message or status confirmation update. \r
Usage:\r
It is repeated as many times as there are events to be returned.`
type Corporates_types.PaymentEvent16 {
  @mandatory : true
  ![from] : Corporates_types.AnyBICDec2014Identifier;
  to : Corporates_types.BICFIDec2014Identifier;
  interbank_settlement_amount : Corporates_types.ActiveCurrencyAndAmount;
  charge_bearer : Corporates_types.ChargeBearerType3Code;
  charge_amount : Corporates_types.ActiveCurrencyAndAmount;
  exchange_rate_data : Corporates_types.CurrencyExchange12;
  @mandatory : true
  processing_date_time : Corporates_types.ISONormalisedDateTime;
};

@description : ```
Provides the reason for a payment status.
*\`G001\`-The status originator transferred the Credit Transfer to the next agent or to a Market Infrastucture where the transaction’s service obligations may no longer be guaranteed.        
*\`G005\`-Credit Transfer has been delivered to creditor agent with transaction’s service obligations maintained.
*\`G006\`-Credit Transfer has been delivered to creditor agent where the transaction’s service obligations were no longer maintained.        
```
@assert.range : true
type Corporates_types.PaymentStatusReason13Code : String enum {
  G001;
  G005;
  G006;
};

@description : 'Specifies the status of a single payment transaction.'
type Corporates_types.PaymentTransaction163 {
  @mandatory : true
  uetr : Corporates_types.UUIDv4Identifier;
  instruction_identification : Corporates_types.RestrictedFINXMax35Text;
  end_to_end_identification : Corporates_types.RestrictedFINXMax35Text;
  @mandatory : true
  transaction_status : Corporates_types.TransactionIndividualStatus10Code;
  transaction_status_date : Corporates_types.ISONormalisedDateTime;
  transaction_status_reason : Corporates_types.PaymentStatusReason13Code;
  reject_return_reason : Corporates_types.TrackerPaymentStatusReason3Code;
  @mandatory : true
  tracker_informing_party : Corporates_types.BICFIDec2014Identifier;
  @mandatory : true
  service_level : Corporates_types.ServiceLevel5Code;
  instructed_amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
  equivalent_amount : Corporates_types.EquivalentAmount2;
  interbank_settlement_amount : Corporates_types.ActiveCurrencyAndAmount;
  confirmed_amount : Corporates_types.ActiveCurrencyAndAmount;
  remaining_to_be_confirmed_amount : Corporates_types.ActiveCurrencyAndAmount;
  previously_confirmed_amount : Corporates_types.ActiveCurrencyAndAmount;
  requested_execution_date : Corporates_types.DateAndDateTime2Choice;
  interbank_settlement_date : Corporates_types.ISODate;
  confirmed_date : Corporates_types.ISONormalisedDateTime;
  ultimate_debtor : Corporates_types.PartyIdentification221;
  debtor : Corporates_types.PartyIdentification221;
  debtor_account : Corporates_types.CashAccount204;
  creditor : Corporates_types.PartyIdentification221;
  creditor_account : Corporates_types.CashAccount204;
  ultimate_creditor : Corporates_types.PartyIdentification221;
  creditor_agent : Corporates_types.BICFIDec2014Identifier;
  purpose : Corporates_types.Max4Text;
  remittance_information : Corporates_types.Remittance1;
  debit_confirmation_url_address : Corporates_types.Max2048Text;
  @mandatory : true
  payment_event : many Corporates_types.PaymentEvent16;
};

@description : 'Rate expressed as a percentage, that is, in hundredths, for example, 0.7 is 7/10 of a percent, and 7.0 is 7%.'
type Corporates_types.PercentageRate : String(13);

@description : 'Unique and unambiguous way to identify a person.'
type Corporates_types.PersonIdentification13 {
  date_and_place_of_birth : Corporates_types.DateAndPlaceOfBirth1;
  other : many Corporates_types.GenericPersonIdentification1;
};

@description : 'Sets of elements to identify a name of the identification scheme.'
@openapi.oneOf : '[{"type":"object","additionalProperties":false,"properties":{"code":{"$ref":"#/components/schemas/ExternalPersonIdentification1Code"}},"required":["code"]},{"type":"object","additionalProperties":false,"properties":{"proprietary":{"$ref":"#/components/schemas/Max35Text"}},"required":["proprietary"]}]'
@open : true
type Corporates_types.PersonIdentificationSchemeName1Choice { };

@description : `The collection of information which identifies a specific phone or FAX number as defined by telecom services.
It consists of a "+" followed by the country code (from 1 to 3 characters) then a "-" and finally, any combination of numbers, "(", ")", "+" and "-" (up to 30 characters).`
@assert.format : '^\+[0-9]{1,3}-[0-9()+\-]{1,30}$'
type Corporates_types.PhoneNumber : String;

@description : 'Information that locates and identifies a specific address, as defined by postal services.'
type Corporates_types.PostalAddress24 {
  address_type : Corporates_types.AddressType3Choice;
  department : Corporates_types.Max70Text;
  sub_department : Corporates_types.Max70Text;
  street_name : Corporates_types.Max70Text;
  building_number : Corporates_types.Max16Text;
  building_name : Corporates_types.Max35Text;
  floor : Corporates_types.Max70Text;
  post_box : Corporates_types.Max16Text;
  room : Corporates_types.Max70Text;
  post_code : Corporates_types.Max16Text;
  town_name : Corporates_types.Max35Text;
  town_location_name : Corporates_types.Max35Text;
  district_name : Corporates_types.Max35Text;
  country_sub_division : Corporates_types.Max35Text;
  country : Corporates_types.CountryCode;
  address_line : many Corporates_types.Max70Text;
};

@description : ```
Preferred method used to reach the individual contact within an organisation.
*\`LETT\`-Preferred method used to reach the contact is per letter.
*\`MAIL\`-Preferred method used to reach the contact is per email.
*\`PHON\`-Preferred method used to reach the contact is per phone.
*\`FAXX\`-Preferred method used to reach the contact is per fax.
*\`CELL\`-Preferred method used to reach the contact is per mobile or cell phone.
```
@assert.range : true
type Corporates_types.PreferredContactMethod1Code : String enum {
  LETT;
  MAIL;
  PHON;
  FAXX;
  CELL;
};

@description : 'Specifies the type of the document referred in the remittance information.'
@openapi.oneOf : '[{"type":"object","additionalProperties":false,"properties":{"code":{"$ref":"#/components/schemas/DocumentType6Code"}},"required":["code"]},{"type":"object","additionalProperties":false,"properties":{"proprietary":{"$ref":"#/components/schemas/Max35Text"}},"required":["proprietary"]}]'
@open : true
type Corporates_types.ReferredDocumentType3Choice { };

@description : 'Specifies the type of the document referred in the remittance information.'
type Corporates_types.ReferredDocumentType4 {
  @mandatory : true
  code_or_proprietary : Corporates_types.ReferredDocumentType3Choice;
  issuer : Corporates_types.Max35Text;
};

@description : 'Set of elements used to identify the documents referred to in the remittance information.'
type Corporates_types.ReferredDocumentInformation7 {
  type : Corporates_types.ReferredDocumentType4;
  number : Corporates_types.Max35Text;
  related_date : Corporates_types.ISODate;
  line_details : many Corporates_types.DocumentLineInformation1;
};

@description : 'Specifies the remittance resource for direct access to the remittance information. Either unstructured or structured is supplied.'
type Corporates_types.Remittance1 {
  unstructured : Corporates_types.Max140Text;
  structured : many Corporates_types.StructuredRemittanceInformation16;
  related : many Corporates_types.RemittanceLocation7;
};

@description : 'Nature of the amount and currency on a document referred to in the remittance section, typically either the original amount due/payable or the amount actually remitted for the referenced document.'
type Corporates_types.RemittanceAmount2 {
  due_payable_amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
  discount_applied_amount : many Corporates_types.DiscountAmountAndType1;
  credit_note_amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
  tax_amount : many Corporates_types.TaxAmountAndType1;
  adjustment_amount_and_reason : many Corporates_types.DocumentAdjustment1;
  remitted_amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
};

@description : 'Nature of the amount and currency on a document referred to in the remittance section, typically either the original amount due/payable or the amount actually remitted for the referenced document.'
type Corporates_types.RemittanceAmount3 {
  due_payable_amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
  discount_applied_amount : many Corporates_types.DiscountAmountAndType1;
  credit_note_amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
  tax_amount : many Corporates_types.TaxAmountAndType1;
  adjustment_amount_and_reason : many Corporates_types.DocumentAdjustment1;
  remitted_amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
};

@description : 'Provides information on the remittance advice.'
type Corporates_types.RemittanceLocation7 {
  remittance_identification : Corporates_types.Max35Text;
  remittance_location_details : many Corporates_types.RemittanceLocationData1;
};

@description : 'Provides additional details on the remittance advice.'
type Corporates_types.RemittanceLocationData1 {
  @mandatory : true
  method : Corporates_types.RemittanceLocationMethod2Code;
  electronic_address : Corporates_types.Max2048Text;
  postal_address : Corporates_types.NameAndAddress16;
};

@description : ```
Specifies the method used to deliver the remittance advice information.
*\`FAXI\`-Remittance advice information must be faxed.
*\`EDIC\`-Remittance advice information must be sent through Electronic Data Interchange (EDI).
*\`URID\`-Remittance advice information needs to be sent to a Uniform Resource Identifier (URI). URI is a compact string of characters that uniquely identify an abstract or physical resource. URI's are the super-set of identifiers, such as URLs, email addresses, ftp sites, etc, and as such, provide the syntax for all of the identification schemes.
*\`EMAL\`-Remittance advice information must be sent through e-mail.
*\`POST\`-Remittance advice information must be sent through postal services.
*\`SMSM\`-Remittance advice information must be sent through by phone as a short message service (SMS).
```
@assert.range : true
type Corporates_types.RemittanceLocationMethod2Code : String enum {
  FAXI;
  EDIC;
  URID;
  EMAL;
  POST;
  SMSM;
};

@description : 'Specifies a character string with a maximum length of 35 characters limited to character set X, that is, a-z A-Z / - ? : ( ) . , ‘ + .'
@assert.format : '^[0-9a-zA-Z/\-\?:\(\)\.,''\+ ]{1,35}$'
type Corporates_types.RestrictedFINXMax35Text : String(35);

@description : ```
Indicates the gpi for corporates service level.\r
\r
G003 for outbound tracking (Pay and Trace) and G007 for inbound tracking.
*\`G007\`-gpi Inbound Tracking Service
*\`G003\`-gpi Pay And Trace Service
```
@assert.range : true
type Corporates_types.ServiceLevel5Code : String enum {
  G007;
  G003;
};

@description : 'Information supplied to enable the matching/reconciliation of an entry with the items that the payment is intended to settle, such as commercial invoices in an accounts'' receivable system, in a structured form.'
type Corporates_types.StructuredRemittanceInformation16 {
  referred_document_information : many Corporates_types.ReferredDocumentInformation7;
  referred_document_amount : Corporates_types.RemittanceAmount2;
  creditor_reference_information : Corporates_types.CreditorReferenceInformation2;
  invoicer : Corporates_types.PartyIdentification135;
  invoicee : Corporates_types.PartyIdentification135;
  tax_remittance : Corporates_types.TaxInformation7;
  garnishment_remittance : Corporates_types.Garnishment3;
  additional_remittance_information : many Corporates_types.Max140Text;
};

@description : 'Set of elements used to provide information on the tax amount(s) of tax record.'
type Corporates_types.TaxAmount2 {
  rate : Corporates_types.PercentageRate;
  taxable_base_amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
  total_amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
  details : many Corporates_types.TaxRecordDetails2;
};

@description : 'Specifies the amount with a specific type.'
type Corporates_types.TaxAmountAndType1 {
  type : Corporates_types.TaxAmountType1Choice;
  @mandatory : true
  amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
};

@description : 'Specifies the amount type.'
@openapi.oneOf : '[{"type":"object","additionalProperties":false,"properties":{"code":{"$ref":"#/components/schemas/ExternalTaxAmountType1Code"}},"required":["code"]},{"type":"object","additionalProperties":false,"properties":{"proprietary":{"$ref":"#/components/schemas/Max35Text"}},"required":["proprietary"]}]'
@open : true
type Corporates_types.TaxAmountType1Choice { };

@description : 'Details of the authorised tax paying party.'
type Corporates_types.TaxAuthorisation1 {
  title : Corporates_types.Max35Text;
  name : Corporates_types.Max140Text;
};

@description : 'Details about tax paid, or to be paid, to the government in accordance with the law, including pre-defined parameters such as thresholds and type of account.'
type Corporates_types.TaxInformation7 {
  creditor : Corporates_types.TaxParty1;
  debtor : Corporates_types.TaxParty2;
  ultimate_debtor : Corporates_types.TaxParty2;
  administration_zone : Corporates_types.Max35Text;
  reference_number : Corporates_types.Max140Text;
  method : Corporates_types.Max35Text;
  total_taxable_base_amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
  total_tax_amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
  date : Corporates_types.ISODate;
  sequence_number : Corporates_types.Number;
  record : many Corporates_types.TaxRecord2;
};

@description : 'Details about the entity involved in the tax paid or to be paid.'
type Corporates_types.TaxParty1 {
  tax_identification : Corporates_types.Max35Text;
  registration_identification : Corporates_types.Max35Text;
  tax_type : Corporates_types.Max35Text;
};

@description : 'Details about the entity involved in the tax paid or to be paid.'
type Corporates_types.TaxParty2 {
  tax_identification : Corporates_types.Max35Text;
  registration_identification : Corporates_types.Max35Text;
  tax_type : Corporates_types.Max35Text;
  authorisation : Corporates_types.TaxAuthorisation1;
};

@description : 'Period of time details related to the tax payment.'
type Corporates_types.TaxPeriod2 {
  year : Corporates_types.ISODate;
  type : Corporates_types.TaxRecordPeriod1Code;
  from_to_date : Corporates_types.DatePeriod2;
};

@description : 'Set of elements used to define the tax record.'
type Corporates_types.TaxRecord2 {
  type : Corporates_types.Max35Text;
  category : Corporates_types.Max35Text;
  category_details : Corporates_types.Max35Text;
  debtor_status : Corporates_types.Max35Text;
  certificate_identification : Corporates_types.Max35Text;
  forms_code : Corporates_types.Max35Text;
  period : Corporates_types.TaxPeriod2;
  tax_amount : Corporates_types.TaxAmount2;
  additional_information : Corporates_types.Max140Text;
};

@description : 'Provides information on the individual tax amount(s) per period of the tax record.'
type Corporates_types.TaxRecordDetails2 {
  period : Corporates_types.TaxPeriod2;
  @mandatory : true
  amount : Corporates_types.ActiveOrHistoricCurrencyAndAmount;
};

@description : ```
Specifies the period related to the tax payment.
*\`MM01\`-Tax is related to the second month of the period.
*\`MM02\`-Tax is related to the first month of the period.
*\`MM03\`-Tax is related to the third month of the period.
*\`MM04\`-Tax is related to the fourth month of the period.
*\`MM05\`-Tax is related to the fifth month of the period.
*\`MM06\`-Tax is related to the sixth month of the period.
*\`MM07\`-Tax is related to the seventh month of the period.
*\`MM08\`-Tax is related to the eighth month of the period.
*\`MM09\`-Tax is related to the ninth month of the period.
*\`MM10\`-Tax is related to the tenth month of the period.
*\`MM11\`-Tax is related to the eleventh month of the period.
*\`MM12\`-Tax is related to the twelfth month of the period.
*\`QTR1\`-Tax is related to the first quarter of the period.
*\`QTR2\`-Tax is related to the second quarter of the period.
*\`QTR3\`-Tax is related to the third quarter of the period.
*\`QTR4\`-Tax is related to the forth quarter of the period.
*\`HLF1\`-Tax is related to the first half of the period.
*\`HLF2\`-Tax is related to the second half of the period.
```
@assert.range : true
type Corporates_types.TaxRecordPeriod1Code : String enum {
  MM01;
  MM02;
  MM03;
  MM04;
  MM05;
  MM06;
  MM07;
  MM08;
  MM09;
  MM10;
  MM11;
  MM12;
  QTR1;
  QTR2;
  QTR3;
  QTR4;
  HLF1;
  HLF2;
};

@description : ```
Specifies the status of a single payment transaction.
*\`ACCC\`-Settlement on the creditor's account has been completed. 
*\`ACCP\`-Preceding check of technical validation was successful. Customer profile check was also successful.
*\`ACSC\`-Settlement on the debtor's account has been completed. 

Usage : this can be used by the first agent to report to the debtor that the transaction has been completed. Warning : this status is provided for transaction status reasons, not for financial information. It can only be used after bilateral agreement
*\`ACSP\`-All preceding checks such as technical validation and customer profile were successful and therefore the payment initiation has been accepted for execution.
*\`PDNG\`-Payment initiation or individual transaction included in the payment initiation is pending.  Further checks and status update will be performed.
*\`RCVD\`-Payment initiation has been received by the receiving agent.
*\`RJCT\`-Payment initiation or individual transaction included in the payment initiation has been rejected.
```
@assert.range : true
type Corporates_types.TransactionIndividualStatus10Code : String enum {
  ACCC;
  ACCP;
  ACSC;
  ACSP;
  PDNG;
  RCVD;
  RJCT;
};

@description : 'A flag indicating a True or False value.'
type Corporates_types.TrueFalseIndicator : Boolean;

@description : 'Universally Unique IDentifier (UUID) version 4, as described in IETC RFC 4122 "Universally Unique IDentifier (UUID) URN Namespace".'
@assert.format : '^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$'
type Corporates_types.UUIDv4Identifier : String;

