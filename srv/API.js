const cds = require('@sap/cds');

const transaction_status_texts = [
  { "transaction_status": "ACCC", "text": "Settled to creditor's account", "criticality": 3 },
  { "transaction_status": "ACCP", "text": "Validations successful", "criticality": 2 },
  { "transaction_status": "ACSC", "text": "Settled to debtor's account.", "criticality": 3 },
  { "transaction_status": "ACSP", "text": "Payment initiation accepted", "criticality": 2 },
  { "transaction_status": "PDNG", "text": "Payment initiation is pending.", "criticality": 2 },
  { "transaction_status": "RCVD", "text": "Payment initiation received by agent", "criticality": 2 },
  { "transaction_status": "RJCT", "text": "Payment initiation rejected.", "criticality": 1 }
];

const charge_bearer_codes = [
  { "code": "CRED", "text": "Creditor" },
  { "code": "DEBT", "text": "Debtor" },
  { "code": "SHA", "text": "Shared" }
];

module.exports = async function () {

  const ext = await cds.connect.to('Swift_CAP_GPITracker');

  this.on('READ', 'Payments', async req => {
    const filters = req.query.SELECT?.where;
    if (filters !== undefined) {

      const parsed = parseFilters(req, filters);
      try {
        return await fetchPayments(ext, filters, parsed);
      } catch (error) {
        console.log("Response from remote:", error.message);
        var errormsg = "Error receiving payments: " + error.message;
        req.error(400, errormsg);
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


  });

  this.on('READ', 'BICValuehelp', async req => {
    try {
      const response = await ext.send({
        method: 'GET',
        path: 'v1/g4c-tracker/x-bics', // relative path after destination URL
      });

      const bankBICs = response["x-bics"].flatMap(obj =>
        Object.entries(obj).map(([bic, name]) => ({ bic, name }))
      );

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
    let paymentevents, response;
    const uetr = req.params[0].uetr;
    const bic = req.params[0].bic;
    const service_level = req.params[0].service_level;
    try {
      console.log("Inputs", uetr, bic, service_level);
      response = await ext.send({
        method: 'POST',
        path: 'v1/g4c-tracker/payments/corporate', // relative path after destination URL
        headers: {
          'x-bic': bic   // 👈 only this extra header
        },
        data: {
          service_level: service_level,
          uetr: uetr
        }
      });
    }
    catch (e) {
      console.log("⬅️ Response from remote:", e.message);
      var errormsg = "Error receiving payment details: " + e.message;
      req.error(400, errormsg);
    }
    if (response["payment_transaction"][0]?.payment_event === undefined) { return [] };

    paymentevents = await getPaymentEvents(response["payment_transaction"][0].payment_event, bic, uetr, service_level);
    return paymentevents;

  })

  this.on('READ', 'PaymentEventProcessFlowNodes', async req => {

    let paymentevents, final_data, edges, response;
    const uetr = req.params[0].uetr;
    const bic = req.params[0].bic;
    const service_level = req.params[0].service_level;
    try {
      response = await ext.send({
        method: 'POST',
        path: 'v1/g4c-tracker/payments/corporate', // relative path after destination URL
        headers: {
          'x-bic': bic   // 👈 only this extra header
        },
        data: {
          service_level: service_level,
          uetr: uetr
        }
      });
    }
    catch (e) {
      var errormsg = "Error receiving event details: " + e.message;
      req.error(400, errormsg);
    }

    if (response?.payment_transaction[0]?.payment_event === undefined) return [];
    edges = await getPaymentEvents(response["payment_transaction"][0].payment_event, bic, uetr, service_level);

    graph = buildGraph(edges);

    const result = calculateLanes(edges[0].from, graph);

    var lane_input = {
      laneMap: result.laneMap,
      laneCount: result.laneCount,
      bic: bic,
      uetr: uetr,
      service_level: service_level
    };

    const lanes = buildLanes(lane_input, response["payment_transaction"]);

    const nodes = buildNodes(lane_input, response["payment_transaction"], edges);

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
    let start, end, service_level, transaction_status, uetr, bic, end_to_end_identification;

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
        }
      }
    }

    return { start, end, service_level, transaction_status, uetr, bic, end_to_end_identification };
  }

  function buildGraph(edges) {
    const graph = {};
    edges.forEach(({ from, to }) => {
      if (!graph[from]) graph[from] = [];
      graph[from].push(to);
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

    return { laneMap, laneCount: maxLane };
  }

  function buildLanes(result, details) {
    var lanes = []
    if (Object.keys(result.laneMap).length === result.laneCount) {
      var length = result.laneCount + 1;
    }
    else {
      var length = result.laneCount + 2;
    }
    if (details[0].service_level === "G003") {
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
          text: (details[0]?.debtor !== undefined ? details[0].debtor.name : debtor),
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
            text: (details[0]?.creditor !== undefined ? details[0].creditor.name : creditor),
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


  async function fetchPayments(ext, filters, parsed) {
    const { start, end, service_level, transaction_status, uetr, bic, end_to_end_identification } = parsed;

    const startutcTimestamp = new Date(start).toJSON();
    const endutcTimestamp = new Date().toJSON();

    const response = await ext.send({
      method: 'POST',
      path: 'v1/g4c-tracker/payments/corporate',
      headers: { 'x-bic': bic },
      data: {
        start_date_time: startutcTimestamp,
        end_date_time: endutcTimestamp,
        service_level,
        status_filter: transaction_status,
        end_to_end_identification,
        event_filter: true,
        maximum_number: "100"
      }
    });

    if (response?.payment_transaction === undefined) return [];

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
      confirmed_amount_amount: obj.confirmed_amount?.amount ?? "",
      confirmed_amount_currency: obj.confirmed_amount?.currency ?? "",
      confirmed_date: obj?.confirmed_date ?? "",
      ultimate_debtor_name: obj.ultimate_debtor?.name ?? "",
      debtor_name: obj.debtor?.name ?? "",
      creditor_name: obj.creditor?.name ?? "",
      debtor_account_identification_iban: obj.debtor_account?.identification?.iban ?? "",
      creditor_any_bic: obj.creditor?.any_bic ?? "",
      creditor_account_identification_iban: obj.creditor_account?.identification?.iban ?? "",
      ultimate_creditor_name: obj.ultimate_creditor?.name ?? "",
      creditor_agent: obj?.creditor_agent ?? "",
      purpose: obj?.purpose ?? "",
      remittance_information_unstructured: obj.remittance_information?.unstructured ?? "",
      debit_confirmation_url_address: obj?.debit_confirmation_url_address ?? "",
      bic,
      transaction_status_text: transaction_status_texts.find(t => t.transaction_status === obj.transaction_status)?.text,
      transaction_status_criticality: transaction_status_texts.find(t => t.transaction_status === obj.transaction_status)?.criticality
    }));

    if (filters !== undefined) {
      for (let i = 0; i < filters.length; i++) {
        var item = filters[i];
        if (Array.isArray(item)) continue;
        var filterfield = filters[i]?.ref?.[0];
        var filtervalue = filters[i + 2]?.val;
        if (
          filterfield !== 'service_level' &&
          filterfield !== 'status_filter' &&
          filterfield !== 'end_to_end_identification' &&
          filterfield !== 'PaymentDate') {
          var filtered = result.filter(obj => obj[filterfield] === filtervalue);
          result = filtered;
        }
      }
    }

    return result;
  }



  async function fetchPaymentDetail(ext, req) {

    let paymentevents, final_data, edges;
    var uetr = req.data.uetr;
    var bic = req.data.bic;
    var service_level = req.data.service_level;
    const response = await ext.send({
      method: 'POST',
      path: 'v1/g4c-tracker/payments/corporate', // relative path after destination URL
      headers: {
        'x-bic': bic   // 👈 only this extra header
      },
      data: {
        service_level: service_level,
        uetr: uetr
      }
    });

    if (response?.payment_transaction === undefined) return [];

    edges = await getPaymentEvents(response["payment_transaction"][0].payment_event, bic, uetr, service_level);
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

    const lanes = buildLanes(lane_input, response["payment_transaction"]);
    const nodes = buildNodes(lane_input, response["payment_transaction"], edges);

    final_data = response["payment_transaction"].map(obj => ({
      uetr: obj.uetr,
      transaction_status: obj?.transaction_status ?? "",
      end_to_end_identification: obj?.end_to_end_identification ?? "",
      instruction_identification: obj?.instruction_identification ?? "",
      service_level: obj?.service_level ?? "",
      transaction_status_date: obj?.transaction_status_date ?? "",
      transaction_status_reason: obj?.transaction_status_reason ?? "",
      reject_return_reason: obj?.reject_return_reason ?? "",
      tracker_informing_party: obj?.tracker_informing_party ?? "",
      instructed_amount_currency: (obj.instructed_amount !== undefined ? obj.instructed_amount.currency : ""),
      instructed_amount_amount: (obj.instructed_amount !== undefined ? obj.instructed_amount.amount : ""),
      interbank_settlement_date: obj?.interbank_settlement_date ?? "",
      confirmed_amount_amount: (obj.confirmed_amount !== undefined ? obj.confirmed_amount.amount : ""),
      confirmed_amount_currency: (obj.confirmed_amount !== undefined ? obj.confirmed_amount.currency : ""),
      confirmed_date: obj?.confirmed_date ?? "",
      ultimate_debtor_name: (obj.ultimate_debtor !== undefined ? obj.ultimate_debtor.name : ""),
      debtor_name: (obj.debtor !== undefined ? obj.debtor.name : ""),
      creditor_name: (obj.creditor !== undefined ? obj.creditor.name : ""),
      debtor_account_identification_iban: (obj.debtor_account !== undefined && obj.debtor_account.identification !== undefined ? obj.debtor_account.identification.iban : ""),
      creditor_any_bic: (obj.creditor !== undefined ? obj.creditor.any_bic : ""),
      creditor_account_identification_iban: (obj.creditor_account !== undefined && obj.creditor_account.identification !== undefined ? obj.creditor_account.identification.iban : ""),
      ultimate_creditor_name: (obj.ultimate_creditor !== undefined ? obj.ultimate_creditor.name : ""),
      creditor_agent: obj?.creditor_agent ?? "",
      purpose: obj?.purpose ?? "",
      remittance_information_unstructured: (obj.remittance_information !== undefined ? obj.remittance_information.unstructured : ""),
      // remittance_information_structured: obj.remittance_information.structured,
      // remittance_information_related: obj.remittance_information.related,
      debit_confirmation_url_address: obj?.debit_confirmation_url_address ?? "",
      payment_event: paymentevents,
      bic: bic,
      process_flow_nodes: nodes,
      process_flow_lanes: lanes,
      transaction_status_text: transaction_status_texts.find(text => text.transaction_status === obj.transaction_status).text,
      transaction_status_criticality: transaction_status_texts.find(text => text.transaction_status === obj.transaction_status).criticality
    }))

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

    const nodes = [];
    const laneMap = lane_input.laneMap;
    let date;
    let index = 0;
    let state, statetext;
    for (const node in laneMap) {
      if (!Object.prototype.hasOwnProperty.call(laneMap, node)) continue;
      const lane = laneMap[node];
      if (index === lane_input.laneCount) {
        var endNode = edges.find(edge => edge.to === node);
        var bankName = endNode?.to_name;
        var currentEdge = "";
        var chargecode = "";
        var nextNode = [];
        switch (details[0].transaction_status) {
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
        var currentEdge = edges.find(edge => edge.from === node);
        var bankName = currentEdge?.from_name;
        state = "Positive";
        statetext = "Completed";
        var chargecode = charge_bearer_codes.find(code => code.code === currentEdge?.charge_bearer)?.text || "";
        var nextNode = graph[node]?.[0];
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
          "Charge bearer: " + chargecode,
          "Date: " + date
        ],
        from: node,
        to: nextNode,
        pageId:node,
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
}