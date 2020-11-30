module.exports = {
  env: "development",
  dbServer: "http://{couchdb_user}:{couchdb_password}@epad_couchdb",
  db: "{dicomweb_dbname}",
  dbPort: "5984",
  auth: "{dicomweb_auth}",
  logger: "{dicomweb_log}",
  prefix: "/{dicomweb_loc}",
  DIMSE: {
    tempDir: "./dimsetemp",
    AET: "{dicomweb_aet}",
    port: "{dicomweb_dimseport}",
  },

};
