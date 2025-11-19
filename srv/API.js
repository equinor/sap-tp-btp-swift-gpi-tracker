const cds = require('@sap/cds');
var Paymentsdata;
var Paymentslistcache = [];
var Paymentslistresponse = [];
var filterscache = [];
var bankBICscache = [];

const transaction_status_texts = [
  { "transaction_status": "ACCC", "text": "Settled to creditor's account", "criticality": 3 },
  { "transaction_status": "ACCP", "text": "Validations successful", "criticality": 2 },
  { "transaction_status": "ACSC", "text": "Settled to debtor's account.", "criticality": 3 },
  { "transaction_status": "ACSP", "text": "Payment initiation accepted", "criticality": 2 },
  { "transaction_status": "PDNG", "text": "Payment initiation is pending.", "criticality": 2 },
  { "transaction_status": "RCVD", "text": "Payment initiation received by agent", "criticality": 2 },
  { "transaction_status": "RJCT", "text": "Payment initiation rejected.", "criticality": 1 }
];

const reject_reason_code_texts = [
  { "reject_reason_code": "AM06", "text": "Below limit" },
  { "reject_reason_code": "RC01", "text": "Bank identifier code specified in the message has an incorrect format" },
  { "reject_reason_code": "AC06", "text": "Account specified is blocked, prohibiting posting of transactions against it" },
  { "reject_reason_code": "AM07", "text": "Amount specified in message has been blocked by regulatory authorities" },
  { "reject_reason_code": "AC04", "text": "Account number specified has been closed on the bank of account's books" },
  { "reject_reason_code": "AC07", "text": "Creditor account number closed" },
  { "reject_reason_code": "G004", "text": "Credit to the creditor's account is pending as status Originator is waiting for funds provided via a cover" },
  { "reject_reason_code": "DUPL", "text": "Payment is a duplicate of another payment" },
  { "reject_reason_code": "ERIN", "text": "The Extended Remittance Information (ERI) option is not supported" },
  { "reject_reason_code": "FOCR", "text": "Return following a cancellation request" },
  { "reject_reason_code": "FR01", "text": "Returned as a result of fraud" },
  { "reject_reason_code": "BE01", "text": "Identification of end customer is not consistent with associated account number" },
  { "reject_reason_code": "AC01", "text": "Account number is invalid or missing" },
  { "reject_reason_code": "AGNT", "text": "Agent in the payment workflow is incorrect" },
  { "reject_reason_code": "CURR", "text": "Currency of the payment is incorrect" },
  { "reject_reason_code": "AM04", "text": "Amount of funds available to cover specified message amount is insufficient" },
  { "reject_reason_code": "FF06", "text": "Category Purpose code is missing or invalid" },
  { "reject_reason_code": "RC08", "text": "Routing code not valid for local clearing" },
  { "reject_reason_code": "RC04", "text": "Creditor bank identifier is invalid or missing" },
  { "reject_reason_code": "AC02", "text": "Debtor account number invalid or missing" },
  { "reject_reason_code": "AC13", "text": "Debtor account type is missing or invalid" },
  { "reject_reason_code": "RR11", "text": "Invalid or missing identification of a bank proprietary service" },
  { "reject_reason_code": "RC03", "text": "Debtor bank identifier is invalid or missing" },
  { "reject_reason_code": "RC11", "text": "Intermediary Agent is invalid or missing" },
  { "reject_reason_code": "FF05", "text": "Local Instrument code is missing or invalid" },
  { "reject_reason_code": "RR12", "text": "Invalid or missing identification required within a particular country or payment type" },
  { "reject_reason_code": "FF03", "text": "Payment Type Information is missing or invalid" },
  { "reject_reason_code": "FF07", "text": "Purpose is missing or invalid" },
  { "reject_reason_code": "FF04", "text": "Service Level code is missing or invalid" },
  { "reject_reason_code": "RR09", "text": "Structured creditor reference invalid or missing" },
  { "reject_reason_code": "BE04", "text": "Specification of creditor's address, which is required for payment, is missing/not correct (formerly IncorrectCreditorAddress)" },
  { "reject_reason_code": "RR03", "text": "Specification of the creditor's name and/or address needed for regulatory requirements is insufficient or missing" },
  { "reject_reason_code": "RR01", "text": "Specification of the debtor’s account or unique identification needed for reasons of regulatory requirements is insufficient or missing" },
  { "reject_reason_code": "BE07", "text": "Specification of debtor's address, which is required for payment, is missing/not correct" },
  { "reject_reason_code": "RR02", "text": "Specification of the debtor’s name and/or address needed for regulatory requirements is insufficient or missing" },
  { "reject_reason_code": "NOAS", "text": "Failed to contact beneficiary" },
  { "reject_reason_code": "AM02", "text": "Specific transaction/message amount is greater than allowed maximum" },
  { "reject_reason_code": "AM03", "text": "Specific message amount is an non processable currency outside of existing agreement" },
  { "reject_reason_code": "NOCM", "text": "Customer account is not compliant with regulatory requirements, for example FICA (in South Africa) or any other regulatory requirements which render an account inactive for certain processing" },
  { "reject_reason_code": "MS03", "text": "Reason has not been specified by agent" },
  { "reject_reason_code": "MS02", "text": "Reason has not been specified by end customer" },
  { "reject_reason_code": "RR05", "text": "Regulatory or Central Bank Reporting information missing, incomplete or invalid" },
  { "reject_reason_code": "RR04", "text": "Regulatory Reason" },
  { "reject_reason_code": "RR07", "text": "Remittance information structure does not comply with rules for payment type" },
  { "reject_reason_code": "RR08", "text": "Remittance information truncated to comply with rules for payment type" },
  { "reject_reason_code": "CUST", "text": "At request of creditor" },
  { "reject_reason_code": "RR06", "text": "Tax information missing, incomplete or invalid" },
  { "reject_reason_code": "UPAY", "text": "Payment is not justified" },
  { "reject_reason_code": "BE05", "text": "Party who initiated the message is not recognised by the end customer" },
  { "reject_reason_code": "AM09", "text": "Amount received is not the amount agreed or expected" },
  { "reject_reason_code": "RUTA", "text": "Return following investigation request and no remediation possible" }
];

const transaction_status_reason_texts = [{ "trans_status_reason": "G001", "text": "The status originator transferred the Credit Transfer to the next agent or to a Market Infrastucture where the transaction’s service obligations may no longer be guaranteed." },
{ "trans_status_reason": "G005", "text": "Credit Transfer has been delivered to creditor agent with transaction’s service obligations maintained" },
{ "trans_status_reason": "G006", "text": "Credit Transfer has been delivered to creditor agent where the transaction’s service obligations were no longer maintained" }
];

const charge_bearer_codes = [
  { "code": "CRED", "text": "Creditor" },
  { "code": "DEBT", "text": "Debtor" },
  { "code": "SHA", "text": "Shared" }
];

module.exports = async function () {

  const ext = await cds.connect.to('Swift_CAP_GPITracker');

  this.on('READ', 'Payments', async req => {
    let Payments;
    const filters = req.query.SELECT?.where;
    const orderBy = req.query.SELECT?.orderBy;
    if (JSON.stringify(filterscache) === JSON.stringify(filters) && Paymentslistcache?.length > 0) {
      Payments = Paymentslistcache;
    }
    else {
      if (filters !== undefined) {       
        const parsed = parseFilters(req, filters);
        try {
          Payments = await fetchPayments(ext, filters, parsed, req);
          filterscache = filters;
        } catch (error) {
          const status = error.reason?.response?.status || error.statusCode;
          if (status === 401) {
            await delay(500);
            try {
              ext = await cds.connect.to('Swift_CAP_GPITracker');
              Payments = await fetchPayments(ext, filters, parsed, req);
              filterscache = filters;             
            }
            catch (error) {
              var errormsg = "Error retrieving data";
              Paymentslistcache = [];
              req.error(400, errormsg);
            }
          }
          else {
            var errormsg = "Error receiving payments: " + error.message;
            Paymentslistcache = [];
            req.error(400, errormsg);
          }
        }
      }
      else {
        try {
          return await fetchPaymentDetail(ext, req);
        } catch (error) {
          var errormsg = "Error receiving payment details: " + error.message;
          req.error(400, errormsg);
        }
      }
    }
    if (orderBy && Payments?.length > 0) {
      Payments.sort((a, b) => {
        for (let o of orderBy) {
          const field = o.ref[0];
          const dir = o.sort === 'desc' ? -1 : 1;
          if (a[field] < b[field]) return -1 * dir;
          if (a[field] > b[field]) return 1 * dir;
        }
        return 0;
      });
    }
    const limit = req.query.SELECT.limit?.rows?.val;
    const offset = req.query.SELECT.limit?.offset?.val || 0;
    if (limit) Payments = Payments?.slice(offset, offset + limit);

    return Payments;

  });

  this.on('READ', 'BICValuehelp', async req => {

    if (bankBICscache.length > 0) {
      return bankBICscache;
    }
    try {
      const response = await ext.send({
        method: 'GET',
        path: 'v1/g4c-tracker/x-bics'

      });

      const bankBICs = response["x-bics"].flatMap(obj =>
        Object.entries(obj).map(([bic, name]) => ({ bic, name }))
      );
      bankBICscache = bankBICs;
      return bankBICs;

    } catch (e) {
      console.log("⬅️ Response from remote:", e.message);
      var errormsg = "Error receiving BICs: " + e.message;
      req.error(400, errormsg);
    }
  });

  this.on('READ', 'TransactionStatusVH', async req => {
    const transaction_status = [
      { "transaction_status": "ACCC", "text": "Settled to creditor's account" },
      { "transaction_status": "ACCP", "text": "Validations successful" },
      { "transaction_status": "ACSC", "text": "Settled to debtor's account." },
      { "transaction_status": "ACSP", "text": "Payment initiation accepted" },
      { "transaction_status": "PDNG", "text": "Payment initiation is pending." },
      { "transaction_status": "RCVD", "text": "Payment initiation received by agent" },
      { "transaction_status": "RJCT", "text": "Payment initiation rejected." }]
    return transaction_status;
  });

  this.on('READ', 'ServiceLevelVH', async req => {
    const service_level = [
      { "service_level": "G007", "text": "Inbound" },
      { "service_level": "G003", "text": "Outbound" }
    ]
    return service_level;
  });

  this.on('READ', 'PaymentEvents', async req => {
    let paymentevents;
    const uetr = req.params[0].uetr;
    const bic = req.params[0].bic;
    const service_level = req.params[0].service_level;
    if (Paymentsdata?.uetr === req.params[0].uetr) {
      var current_payment = Paymentsdata;
      console.log("Existing payment event detail", current_payment);
    }
    else {
      if (Paymentslistresponse.length > 0) {
        var current_payment = Paymentslistresponse.find(pay => pay.uetr === uetr);
        console.log("Fetching payment event detail from list");
      }
      else {
        try {
          const response = await ext.send({
            method: 'POST',
            path: 'v1/g4c-tracker/payments/corporate', // relative path after destination URL
            headers: {
              'x-bic': bic,
              'X-SAP-Uid': req.user.id
              // 👈 only this extra header
            },
            data: {
              service_level: service_level,
              uetr: uetr
            }
          });

          var current_payment = response?.payment_transaction?.[0];
          console.log("Fetching payment event detail from API", current_payment);
        }
        catch (error) {
          var errormsg = "Error receiving payment event details: " + error.message;
          req.error(400, errormsg);
        }
      }
    }
    if (current_payment?.payment_event === undefined) { return [] };
    paymentevents = await getPaymentEvents(current_payment.payment_event, bic, uetr, service_level);
    return paymentevents;
  })

  this.on('READ', 'PaymentEventProcessFlowNodes', async req => {
    const nodes = Paymentsdata?.process_flow_nodes;

    if (req.params[1] !== undefined) {
      var laneId = req.params[1].laneId;
      var id = req.params[1].id;
      const filteredNodes = nodes.filter(node =>
        node.id === id && node.laneId === laneId
      );
      return filteredNodes;
    }

  })

  function parseFilters(req, filters) {
    let start, end, service_level, transaction_status, uetr, bic, end_to_end_identification, debtor, debtor_account, creditor, creditor_account;

    if (filters) {
      for (let i = 0; i < filters.length; i++) {
        const item = filters[i];
        if (Array.isArray(item)) continue;

        const field = item?.ref?.[0];
        const operator = filters[i + 1];
        const value = filters[i + 2]?.val;

        switch (field) {
          case 'PaymentDate':
            if (operator === '>=') start = value;
            if (operator === '<=') end = value;
            const fromDate = new Date(start);
            const toDate = new Date(end);
            const now = new Date();

            if (fromDate && (now - fromDate) / (1000 * 60 * 60 * 24) > 7) {
              req.reject(400, 'Payment date cannot be older than 7 days', field);
            }
            if (toDate && (toDate - now) / (1000 * 60 * 60 * 24) > 7) {
              req.reject(400, 'Payment date cannot be more than 7 days ahead.', field);
            }
            break;
          case 'service_level': if (operator === '=') service_level = value; break;
          case 'bic': if (operator === '=') bic = value; break;
          case 'transaction_status': if (operator === '=') transaction_status = value; break;
          case 'uetr': if (operator === '=') uetr = value; break;
          case 'end_to_end_identification': if (operator === '=') end_to_end_identification = value; break;
          case 'debtor_any_bic': if (operator === '=') debtor = value; break;
          case 'debtor_filter': if (operator === '=') debtor_account = value; break;
          case 'creditor_any_bic': if (operator === '=') creditor = value; break;
          case 'creditor_filter': if (operator === '=') creditor_account = value; break;
        }
      }
    }

    return { start, end, service_level, transaction_status, uetr, bic, end_to_end_identification, debtor, debtor_account, creditor, creditor_account };
  }

  function buildGraph(edges) {
    const graph = {};

    edges.forEach(({ from, to }) => {
      if (from !== to) {
        if (!graph[from]) graph[from] = [];
        graph[from].push(to);
      }
    });

    return graph;

  }

  function calculateLanes(start, graph) {
    const laneMap = {};
    const queue = [[start, 0]];
    while (queue.length > 0) {
      const [node, lane] = queue.shift();
      if (laneMap[node] !== undefined && laneMap[node] >= lane) continue;
      laneMap[node] = lane;
      (graph[node] || []).forEach(next => queue.push([next, lane + 1]));
    }
    const maxLane = Math.max(...Object.values(laneMap));
    for (const key in laneMap) {
      if (key === "undefined" || laneMap[key] === undefined) {
        delete laneMap[key];
      }
    }
    console.log("Lanesbuild:", laneMap, maxLane)
    return { laneMap, laneCount: maxLane };
  }

  function buildLanes(result, details) {
    console.log("Lanes:");
    var lanes = [];
    if (Object.keys(result.laneMap).length === result.laneCount) {
      var length = result.laneCount + 1;
    }
    else {
      var length = result.laneCount + 2;
    }
    if (details.service_level === "G003") {
      var debtor = "Equinor entity";
      var creditor = "Undisclosed creditor";
    }
    else {
      var creditor = "Equinor entity";
      var debtor = "Undisclosed debtor";
    }

    for (let i = 0; i <= length; i++) {
      if (i === 0) {
        lanes.push({
          laneId: i.toString(),
          iconSrc: "sap-icon://open-command-field",
          text: details?.debtor?.name ?? debtor,
          position: i,
          bic: result.bic,
          uetr: result.uetr,
          service_level: result.service_level
        });
      }
      else {
        if (i === length) {
          lanes.push({
            laneId: i.toString(),
            iconSrc: "sap-icon://close-command-field",
            text: details?.creditor?.name ?? creditor,
            position: i,
            bic: result.bic,
            uetr: result.uetr,
            service_level: result.service_level
          });
        }
        else {
          lanes.push({
            laneId: i.toString(),
            iconSrc: "sap-icon://loan",
            text: "",
            position: i,
            bic: result.bic,
            uetr: result.uetr,
            service_level: result.service_level
          });
        }
      }
    }
    console.log("Lanes:", lanes);
    return lanes;
  }

  function serviceLevelVH() {
    return [{ service_level: "G007", text: "Inbound" }, { service_level: "G003", text: "Outbound" }];
  }

  async function getPaymentEvents(events, bic, uetr, service_level) {

    const payevents = [];

    for (let i = 0; i < events.length; i++) {
      const obj = events[i];

      const item = {
        uetr: uetr,
        bic: bic,
        service_level: service_level,
        from: obj.from !== undefined ? obj.from.slice(0, 8) : undefined,
        to: obj.to !== undefined ? obj.to.slice(0, 8) : undefined,
        charge_bearer: obj?.charge_bearer ?? "",
        charge_amount_amount: obj?.charge_amount?.amount ?? "",
        charge_amount_currency: obj?.charge_amount?.currency ?? "",
        interbank_settlement_amount_amount: obj?.interbank_settlement_amount?.amount ?? "",
        interbank_settlement_amount_currency: obj?.interbank_settlement_amount?.currency ?? "",
        exchange_rate_data_source_currency: obj?.exchange_rate_data?.source_currency ?? "",
        exchange_rate_data_target_currency: obj?.exchange_rate_data?.target_currency ?? "",
        exchange_rate_data_exchange_rate: obj?.exchange_rate_data?.exchange_rate ?? "",
        processing_date_time: obj?.processing_date_time,
        charge_bearer_text: charge_bearer_codes.find(code => code.code === obj?.charge_bearer)?.text || "",
        from_name: obj.from !== undefined ? await get_bankname(obj.from.slice(0, 8)) : "",
        to_name: obj.to !== undefined ? await get_bankname(obj.to.slice(0, 8)) : ""
      };

      payevents.push(item);
    }
    return payevents;

  }


  async function fetchPayments(ext, filters, parsed, req) {
    const { start, end, service_level, transaction_status, uetr, bic, end_to_end_identification, debtor, debtor_account, creditor, creditor_account } = parsed;

    const startutcTimestamp = new Date(start).toJSON();
    const endutcTimestamp = new Date().toJSON();

    const response = await ext.send({
      method: 'POST',
      path: 'v1/g4c-tracker/payments/corporate',
      headers: { 'x-bic': bic, 'X-SAP-Uid': req.user.id },
      data: {
        start_date_time: startutcTimestamp,
        end_date_time: endutcTimestamp,
        service_level,
        status_filter: transaction_status,
        end_to_end_identification,
        debtor_account,
        debtor,
        creditor_account,
        creditor,
        event_filter: true
      }
    });

    if (response?.payment_transaction === undefined) { Paymentslistcache = []; return [] };

    Paymentslistresponse = response?.payment_transaction;

    var result = response.payment_transaction.map(obj => ({
      uetr: obj.uetr,
      transaction_status: obj?.transaction_status ?? "",
      end_to_end_identification: obj?.end_to_end_identification ?? "",
      instruction_identification: obj?.instruction_identification ?? "",
      service_level: obj?.service_level ?? "",
      transaction_status_date: obj?.transaction_status_date ?? "",
      transaction_status_reason: obj?.transaction_status_reason ?? "",
      reject_return_reason: obj?.reject_return_reason ?? "",
      tracker_informing_party: obj?.tracker_informing_party ?? "",
      instructed_amount_currency: obj?.instructed_amount.currency ?? "",
      instructed_amount_amount: obj.instructed_amount?.amount ?? "",
      interbank_settlement_date: obj?.interbank_settlement_date ?? "",
      confirmed_amount_amount: obj?.confirmed_amount?.amount ?? "",
      confirmed_amount_currency: obj?.confirmed_amount?.currency ?? "",
      interbank_settlement_amount_amount: obj?.interbank_settlement_amount?.amount ?? "",
      interbank_settlement_amount_currency: obj?.interbank_settlement_amount?.currency ?? "",
      remaining_to_be_confirmed_amount_amount: obj?.remaining_to_be_confirmed_amount?.amount ?? "",
      remaining_to_be_confirmed_amount_currency: obj?.remaining_to_be_confirmed_amount?.currency ?? "",
      previously_confirmed_amount_amount: obj?.previously_confirmed_amount?.amount ?? "",
      previously_confirmed_amount_currency: obj?.previously_confirmed_amount?.currency ?? "",
      equivalent_amount_amount: obj?.equivalent_amount?.amount?.amount ?? "",
      equivalent_amount_currency: obj?.equivalent_amount?.amount?.currency ?? "",
      equivalent_amount_currency_of_transfer: obj?.equivalent_amount?.currency_of_transfer ?? "",
      confirmed_date: obj?.confirmed_date ?? "",
      ultimate_debtor_name: obj?.ultimate_debtor?.name ?? "",
      debtor_name: obj?.debtor?.name ?? "",
      creditor_name: obj?.creditor?.name ?? "",
      debtor_account_iban: obj?.debtor_account?.identification?.iban ?? "",
      creditor_any_bic: obj?.creditor?.any_bic ?? "",
      debtor_any_bic: obj?.debtor?.any_bic ?? "",
      creditor_account_iban: obj?.creditor_account?.identification?.iban ?? "",
      ultimate_creditor_name: obj?.ultimate_creditor?.name ?? "",
      creditor_agent: obj?.creditor_agent ?? "",
      purpose: obj?.purpose ?? "",
      remittance_information_unstructured: obj?.remittance_information?.unstructured ?? "",
      debit_confirmation_url_address: obj?.debit_confirmation_url_address ?? "",
      bic,
      transaction_status_text: transaction_status_texts.find(t => t.transaction_status === obj.transaction_status)?.text,
      transaction_status_criticality: transaction_status_texts.find(t => t.transaction_status === obj.transaction_status)?.criticality,
      reject_reason_code_text: reject_reason_code_texts.find(t => t.reject_reason_code === obj.reject_return_reason)?.text,
      transaction_status_reason_text: transaction_status_reason_texts.find(t => t.trans_status_reason === obj.transaction_status_reason)?.text,
      reject_reason_visibility: obj.transaction_status === "RJCT" ? false : true,
      debtor_filter: "",
      creditor_filter: "",
    }));

    if (filters !== undefined) {
      for (let i = 0; i < filters.length; i++) {
        var item = filters[i];
        if (Array.isArray(item)) continue;
        var filterfield = filters[i]?.ref?.[0];
        var filtervalue = filters[i + 2]?.val;
        if (
          filterfield !== 'service_level' &&
          filterfield !== 'transaction_status' &&
          filterfield !== 'end_to_end_identification' &&
          filterfield !== 'PaymentDate' &&
          filterfield !== 'debtor_filter' &&
          filterfield !== 'creditor_filter' &&
          filterfield !== 'debtor_any_bic' &&
          filterfield !== 'creditor_any_bic') {
          var filtered = result.filter(obj => obj[filterfield] === filtervalue);
          result = filtered;
        }
      }
    }

    Paymentslistcache = result;
    return result;
  }



  async function fetchPaymentDetail(ext, req) {

    let paymentevents, final_data, edges;
    if (Paymentsdata?.uetr === req.data.uetr) {
      final_data = Paymentsdata;
      console.log("Fetching payment detail from cache");
    }
    else {
      var uetr = req.data.uetr;
      var bic = req.data.bic;
      var service_level = req.data.service_level;
      if (Paymentslistresponse.length > 0) {
        var current_payment = Paymentslistresponse.find(pay => pay.uetr === uetr);
      }
      else {
        const response = await ext.send({
          method: 'POST',
          path: 'v1/g4c-tracker/payments/corporate', // relative path after destination URL
          headers: {
            'x-bic': bic,
            'X-SAP-Uid': req.user.id
            // 👈 only this extra header
          },
          data: {
            service_level: service_level,
            uetr: uetr
          }
        });
        var current_payment = response?.payment_transaction?.[0];
      }

      if (current_payment === undefined) return [];

      edges = await getPaymentEvents(current_payment.payment_event, bic, uetr, service_level);
      graph = buildGraph(edges);
      const result = calculateLanes(edges[0].from, graph);
      console.log(graph);

      var lane_input = {
        laneMap: result.laneMap,
        laneCount: result.laneCount,
        bic: bic,
        uetr: uetr,
        service_level: service_level
      };

      var lanes = buildLanes(lane_input, current_payment);
      var nodes = buildNodes(lane_input, current_payment, edges);

      final_data = {
        uetr: current_payment.uetr,
        transaction_status: current_payment?.transaction_status ?? "",
        end_to_end_identification: current_payment?.end_to_end_identification ?? "",
        instruction_identification: current_payment?.instruction_identification ?? "",
        service_level: current_payment?.service_level ?? "",
        transaction_status_date: current_payment?.transaction_status_date ?? "",
        transaction_status_reason: current_payment?.transaction_status_reason ?? "",
        reject_return_reason: current_payment?.reject_return_reason ?? "",
        tracker_informing_party: current_payment?.tracker_informing_party ?? "",
        instructed_amount_currency: current_payment?.instructed_amount?.currency ?? "",
        instructed_amount_amount: current_payment?.instructed_amount?.amount ?? "",
        interbank_settlement_date: current_payment?.interbank_settlement_date ?? "",
        confirmed_amount_amount: current_payment?.confirmed_amount?.amount ?? "",
        confirmed_amount_currency: current_payment?.confirmed_amount?.currency ?? "",
        interbank_settlement_amount_amount: current_payment?.interbank_settlement_amount?.amount ?? "",
        interbank_settlement_amount_currency: current_payment?.interbank_settlement_amount?.currency ?? "",
        remaining_to_be_confirmed_amount_amount: current_payment?.remaining_to_be_confirmed_amount?.amount ?? "",
        remaining_to_be_confirmed_amount_currency: current_payment?.remaining_to_be_confirmed_amount?.currency ?? "",
        previously_confirmed_amount_amount: current_payment?.previously_confirmed_amount?.amount ?? "",
        previously_confirmed_amount_currency: current_payment?.previously_confirmed_amount?.currency ?? "",
        equivalent_amount_amount: current_payment?.equivalent_amount?.amount?.amount ?? "",
        equivalent_amount_currency: current_payment?.equivalent_amount?.amount?.currency ?? "",
        equivalent_amount_currency_of_transfer: current_payment?.equivalent_amount?.currency_of_transfer ?? "",
        confirmed_date: current_payment?.confirmed_date ?? "",
        ultimate_debtor_name: current_payment?.ultimate_debtor?.name ?? "",
        debtor_name: current_payment?.debtor?.name ?? "",
        creditor_name: current_payment?.creditor?.name ?? "",
        debtor_account_iban: current_payment?.debtor_account?.identification?.iban ?? "",
        creditor_any_bic: current_payment?.creditor?.any_bic ?? "",
        debtor_any_bic: current_payment?.debtor?.any_bic ?? "",
        creditor_account_iban: current_payment?.creditor_account?.identification?.iban ?? "",
        ultimate_creditor_name: current_payment?.ultimate_creditor?.name ?? "",
        creditor_agent: current_payment?.creditor_agent ?? "",
        purpose: current_payment?.purpose ?? "",
        remittance_information_unstructured: current_payment?.remittance_information?.unstructured ?? "",
        // remittance_information_structured: current_payment.remittance_information.structured,
        // remittance_information_related: current_payment.remittance_information.related,
        debit_confirmation_url_address: current_payment?.debit_confirmation_url_address ?? "",
        payment_event: edges,
        bic: bic,
        process_flow_nodes: nodes,
        process_flow_lanes: lanes,
        transaction_status_text: transaction_status_texts.find(text => text.transaction_status === current_payment.transaction_status).text,
        transaction_status_criticality: transaction_status_texts.find(text => text.transaction_status === current_payment.transaction_status).criticality,
        reject_reason_code_text: reject_reason_code_texts.find(t => t.reject_reason_code === current_payment.reject_return_reason)?.text,
        transaction_status_reason_text: transaction_status_reason_texts.find(t => t.trans_status_reason === current_payment.transaction_status_reason)?.text,
        reject_reason_visibility: current_payment.transaction_status === "RJCT" ? false : true,
        debtor_filter: "",
        creditor_filter: "",
      }

      nodes = [];
      lanes = [];

      Paymentsdata = final_data;
    }

    return final_data;

  }

  async function get_bankname(bic) {
    var bankname = await ext.send({
      method: 'GET',
      path: `v1/g4c-tracker/bank/${bic}`
    });
    return bankname.Name;
  }

  function buildNodes(lane_input, details, edges) {

    var nodes = [];
    var laneMap = lane_input.laneMap;
    let date;
    let index = 0;
    let state, statetext;
    for (var node in laneMap) {
      if (!Object.prototype.hasOwnProperty.call(laneMap, node)) continue;
      var lane = laneMap[node];
      if (index === lane_input.laneCount) {
        var endNode = edges.find(edge => edge.to === node);
        var bankName = endNode?.to_name;
        var currentEdge = "";
        var chargecode = "";
        var amount = "";
        var nextNode = [];
      }
      else {
        var currentEdge = edges.find(edge => edge.from === node);
        var bankName = currentEdge?.from_name;
        var chargecode = charge_bearer_codes.find(code => code.code === currentEdge?.charge_bearer)?.text || "";
        var amount = currentEdge?.charge_amount_amount + " " + currentEdge?.charge_amount_currency;
        var nextNode = graph[node]?.[0];
      }
      if (index === Object.keys(laneMap).length - 1) {
        switch (details.transaction_status) {
          case 'RJCT':
            state = "Negative"
            statetext = "Rejected"
            break;
          case 'RCVD':
            state = "Neutral"
            statetext = "Pending"
            break;
          case 'PDNG':
            state = "Neutral"
            statetext = "Pending"
            break;
          case 'ACSP':
            state = "Neutral"
            statetext = "Pending"
            break;
          case 'ACSC':
            state = "Positive";
            statetext = "Completed"
            break;
          case 'ACCP':
            state = "Neutral";
            statetext = "Pending"
            break;
          case 'ACCC':
            state = "Positive";
            statetext = "Completed"
            break;
        }
      }
      else {
        state = "Positive";
        statetext = "Completed";
      }
      if (currentEdge?.processing_date_time !== undefined) {
        var timestamp = new Date(currentEdge?.processing_date_time);
        date = timestamp.toLocaleString("en-US", {
          year: "numeric",
          month: "long",
          day: "numeric",
          hour: "numeric",
          minute: "2-digit",
          second: "2-digit",
          hour12: false,
          timeZone: "Europe/Berlin",
          timeZoneName: "shortOffset" // 👈 shows GMT+02:00
        });
      }
      else {
        date = "";
      }

      nodes.push({
        id: node,
        laneId: (lane + 1).toString(),
        title: bankName + "\nBIC: " + node,
        state: state,
        stateText: statetext,
        children: nextNode ? graph[node] : [],
        bic: lane_input.bic,
        uetr: lane_input.uetr,
        service_level: lane_input.service_level,
        texts: [
          chargecode + " " + amount,
          "Date: " + date
        ],
        from: node,
        to: nextNode,
        pageId: node,
        header: bankName,
        icon: "sap-icon://begin",
        description: "BIC: " + node,
        groups: [
          {
            heading: "Payment details",
            elements: [
              {
                label: "Date",
                value: date,
                url: null,
                elementType: "text",
              },
              {
                label: "Sender's Deducts",
                value: chargecode,
                url: null,
                elementType: "text",
              },
              {
                label: "Charged amount",
                value:
                  (currentEdge?.charge_amount_amount ?? "") +
                  " " +
                  (currentEdge?.charge_amount_currency ?? ""),
                url: null,
                elementType: "text",
              },
              {
                label: "Interbank settlement amount",
                value:
                  (currentEdge?.interbank_settlement_amount_amount ?? "") +
                  " " +
                  (currentEdge?.interbank_settlement_amount_currency ?? ""),
                url: null,
                elementType: "text",
              },
              {
                label: "Exchange rate info",
                value:
                  "Source " +
                  (currentEdge?.exchange_rate_data_source_currency ?? "") +
                  " - Target " +
                  (currentEdge?.exchange_rate_data_target_currency ?? ""),
                url: null,
                elementType: "text",
              },
            ],
          },
        ],
      });
      index++;
    }
    return nodes;
  }

  function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

}