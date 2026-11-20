const K = process.env.K, OPC = process.env.OPC;
const ambr = { downlink: { value: 1, unit: 3 }, uplink: { value: 1, unit: 3 } };
const qos = { index: 9, arp: { priority_level: 8, pre_emption_capability: 1, pre_emption_vulnerability: 1 } };
const sl = (sst, dnn, def) => {
  const s = { sst: sst, session: [{ name: dnn, type: 3, qos: qos, ambr: ambr }] };
  if (def) s.default_indicator = true;
  return s;
};
const subs = {
  '999700000000002': [sl(1, 'internet', true)],
  '999700000000003': [sl(2, 'urllc', true)],
  '999700000000004': [sl(3, 'mmtc', true)],
  '999700000000005': [sl(1, 'internet', true), sl(2, 'urllc', false), sl(3, 'mmtc', false)],
  '999700000000006': [sl(2, 'urllc', true)],
};
for (const [imsi, slice] of Object.entries(subs)) {
  db.subscribers.updateOne({ imsi: imsi }, { $set: {
    imsi: imsi, security: { k: K, opc: OPC, amf: '8000' }, ambr: ambr, slice: slice,
    access_restriction_data: 32, subscriber_status: 0, network_access_mode: 0,
    subscribed_rau_tau_timer: 12, schema_version: 1, __v: 0 } }, { upsert: true });
}
print('subscribers in DB: ' + db.subscribers.countDocuments());
