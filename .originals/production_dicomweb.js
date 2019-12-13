module.exports = {
  env: "development",
  dbServer: "http://epad_couchdb",
  db: "{dicomweb_dbname}",
  dbPort: "5984",
  auth: "{dicomweb_auth}",
  logger: "{dicomweb_log}",
  prefix: "/{dicomweb_loc}"
};
