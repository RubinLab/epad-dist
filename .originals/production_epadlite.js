module.exports = {
  env: "development",
  dbServer: "http://epad_couchdb",
  db: "{epadlite_dbname}",
  dbPort: "5984",
  auth: "{epadlite_auth}",
  dicomweb: "dicomweb",
  logger: "{epadlite_log}",
  https: "{epadlite_https}",
  mode: "{mode}",
  prefix: "{epadlite_loc}",
  thickDb: {
    name: "{mariadb_dbname}",
    host: "epad_mariadb",
    port: "3306",
    user: "{mariadb_user}",
    pass: "{mariadb_pass}",
    logger: {mariadb_log}
  }
};