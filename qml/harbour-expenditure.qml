import QtQuick 2.6
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "pages"

ApplicationWindow {
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    Item {
        id: storageItem

        // general functions
        function getDatabase() {
           return storageItem.LocalStorage.openDatabaseSync("Bible_DB", "0.1", "BibleDatabaseComplete", 5000000); // 5 MB estimated size
        }
        function removeFullTable (tableName) {
            var db = getDatabase();
            var res = "";
            db.transaction(function(tx) { tx.executeSql('DROP TABLE IF EXISTS ' + tableName) });
        }
        function getTableCount (tableName, default_value) {
             var db = getDatabase();
             var res="";
             try {
              db.transaction(function(tx) {
               var rs = tx.executeSql('SELECT count(*) AS some_info FROM ' + tableName + ';');
                if (rs.rows.length > 0) {
                 res = rs.rows.item(0).some_info;

                } else {
                 res = default_value;
                }
              })
             } catch (err) {
              //console.log("Database " + err);
              res = default_value;
             };
             return res
        }

        // settings
        function setSettings( setting, value ) {
          var db = getDatabase();
          var res = "";
           db.transaction(function(tx) {
             tx.executeSql('CREATE TABLE IF NOT EXISTS ' + 'settings_table' + '(setting TEXT UNIQUE, value TEXT)');
            var rs = tx.executeSql('INSERT OR REPLACE INTO ' + 'settings_table' + ' VALUES (?,?);', [setting,value]);
              if (rs.rowsAffected > 0) {
               res = "OK";
              } else {
               res = "Error";
              }
            }
           );
           return res;
        }
        function getSettings( setting, default_value ) {
           var db = getDatabase();
           var res="";
           try {
            db.transaction(function(tx) {
             var rs = tx.executeSql('SELECT value FROM '+ 'settings_table' +' WHERE setting=?;', [setting]);
              if (rs.rows.length > 0) {
               res = rs.rows.item(0).value;
              } else {
               res = default_value;
              }
              if (res === null) {
                  res = default_value
              }
            })
           } catch (err) {
             //console.log("Database " + err);
            res = default_value;
           };
           //console.log(setting + " = " + res)
           return res
        }

        // all projects available
        function setProject( project_id_timestamp, project_name, project_members, project_recent_payer_boolarray, project_recent_beneficiaries_boolarray, project_base_currency ) {
          var db = getDatabase();
          var res = "";
           db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS ' + 'projects_table' + ' (project_id_timestamp TEXT,
                                                                                project_name TEXT,
                                                                                project_members TEXT,
                                                                                project_recent_payer_boolarray TEXT,
                                                                                project_recent_beneficiaries_boolarray TEXT,
                                                                                project_base_currency TEXT)' );
            var rs = tx.executeSql('INSERT OR REPLACE INTO ' + 'projects_table' + ' VALUES (?,?,?,?,?,?);', [project_id_timestamp,
                                                                                                           project_name,
                                                                                                           project_members,
                                                                                                           project_recent_payer_boolarray,
                                                                                                           project_recent_beneficiaries_boolarray,
                                                                                                           project_base_currency ]);
              if (rs.rowsAffected > 0) {
               res = "OK";
              } else {
               res = "Error";
              }
            }
           );
           return res;
        }
        function updateProject ( project_id_timestamp, project_name, project_members, project_recent_payer_boolarray, project_recent_beneficiaries_boolarray, project_base_currency ) {
            var db = getDatabase();
            var res = "";
              db.transaction(function(tx) {
                  tx.executeSql('CREATE TABLE IF NOT EXISTS ' + 'projects_table' + ' (project_id_timestamp TEXT,
                                                                                      project_name TEXT,
                                                                                      project_members TEXT,
                                                                                      project_recent_payer_boolarray TEXT,
                                                                                      project_recent_beneficiaries_boolarray TEXT,
                                                                                      project_base_currency TEXT)' );
              var rs = tx.executeSql('UPDATE projects_table'
                                     + ' SET project_name="' + project_name
                                     + '", project_members="' + project_members
                                     + '", project_recent_payer_boolarray="' + project_recent_payer_boolarray
                                     + '", project_recent_beneficiaries_boolarray="' + project_recent_beneficiaries_boolarray
                                     + '", project_base_currency="' + project_base_currency
                                     + '" WHERE project_id_timestamp=' + project_id_timestamp + ';');
                if (rs.rowsAffected > 0) {
                 res = "OK";
                } else {
                 res = "Error";
                }
              }
             );
             return res;
        }
        function updateField_Project ( project_id_timestamp, field_name, new_value ) {
            var db = getDatabase();
            var res = "";
              db.transaction(function(tx) {
                  tx.executeSql('CREATE TABLE IF NOT EXISTS ' + 'projects_table' + ' (project_id_timestamp TEXT,
                                                                                      project_name TEXT,
                                                                                      project_members TEXT,
                                                                                      project_recent_payer_boolarray TEXT,
                                                                                      project_recent_beneficiaries_boolarray TEXT,
                                                                                      project_base_currency TEXT)' );
              var rs = tx.executeSql('UPDATE projects_table SET ' + field_name + '="' + new_value + '" WHERE project_id_timestamp=' + project_id_timestamp + ';');
                if (rs.rowsAffected > 0) {
                 res = "OK";
                } else {
                 res = "Error";
                }
              }
             );
             return res;
        }
        function deleteProject (project_id_timestamp) {
          var db = getDatabase();
          var res = "";
           db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS ' + 'projects_table' + ' (project_id_timestamp TEXT,
                                                                                project_name TEXT,
                                                                                project_members TEXT,
                                                                                project_recent_payer_boolarray TEXT,
                                                                                project_recent_beneficiaries_boolarray TEXT,
                                                                                project_base_currency TEXT)' );
            var rs = tx.executeSql('DELETE FROM ' + 'projects_table WHERE project_id_timestamp=' + project_id_timestamp + ';');
              if (rs.rowsAffected > 0) {
               res = "OK";
              } else {
               res = "Error";
              }
            }
           );
           removeFullTable("table_" + project_id_timestamp)
           return res;
        }
        function getAllProjects( default_value ) {
            var db = getDatabase();
            var res=[];
            try {
              db.transaction(function(tx) {
              var rs = tx.executeSql('SELECT * FROM '+ 'projects_table;')
              if (rs.rows.length > 0) {
                for (var i = 0; i < rs.rows.length; i++) {
                   res.push([rs.rows.item(i).project_id_timestamp,
                             rs.rows.item(i).project_name,
                             rs.rows.item(i).project_members,
                             rs.rows.item(i).project_recent_payer_boolarray,
                             rs.rows.item(i).project_recent_beneficiaries_boolarray,
                             rs.rows.item(i).project_base_currency,
                            ])
                 }
               } else {
                 res = default_value;
               }
             })
            } catch (err) {
              //console.log("Database " + err);
             res = default_value;
            };
            return res
         }

        // all exchange rates used
        function countExchangeRateOccurances (exchange_rate_currency, default_value) {
            var db = getDatabase();
             var res="";
             try {
              db.transaction(function(tx) {
               var rs = tx.executeSql('SELECT count(*) AS some_info FROM exchange_rates_table WHERE exchange_rate_currency=?;', [exchange_rate_currency]);
                if (rs.rows.length > 0) {
                 res = rs.rows.item(0).some_info;
                } else {
                 res = default_value;
                }
              })
             } catch (err) {
              //console.log("Database " + err);
              res = default_value;
             };
             return res
        }
        function setExchangeRate( exchange_rate_currency, exchange_rate_value ) {
          var db = getDatabase();
          var res = "";
           db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS ' + 'exchange_rates_table' + ' (exchange_rate_currency TEXT, exchange_rate_value TEXT)' );
            var rs = tx.executeSql('INSERT OR REPLACE INTO ' + 'exchange_rates_table' + ' VALUES (?,?);', [exchange_rate_currency, exchange_rate_value ]);
              if (rs.rowsAffected > 0) {
               res = "OK";
              } else {
               res = "Error";
              }
            }
           );
           return res;
        }
        function updateExchangeRate( exchange_rate_currency, exchange_rate_value ) {
            var db = getDatabase();
            var res = "";
             db.transaction(function(tx) {
              tx.executeSql('CREATE TABLE IF NOT EXISTS exchange_rates_table (exchange_rate_currency TEXT, exchange_rate_value TEXT)');
              var rs = tx.executeSql('UPDATE exchange_rates_table SET exchange_rate_value="' + exchange_rate_value + '" WHERE exchange_rate_currency="' + exchange_rate_currency + '";');
                if (rs.rowsAffected > 0) {
                 res = "OK";
                } else {
                 res = "Error";
                }
              }
             );
             return res;
        }
        function getExchangeRate(exchange_rate_currency, default_value) {
            var db = getDatabase();
            var res=[];
            try {
             db.transaction(function(tx) {
              var rs = tx.executeSql('SELECT * FROM '+ 'exchange_rates_table' +' WHERE exchange_rate_currency=?;', [exchange_rate_currency]);
               if (rs.rows.length > 0) {
                 for (var i = 0; i < rs.rows.length; i++) {
                  res.push(rs.rows.item(i).exchange_rate_value)
                 }
               } else {
                res = default_value;
               }
             })
            } catch (err) {
              //console.log("Database " + err);
             res = default_value;
            };
            return res
        }


        // all expenes in current project
        function setExpense( project_name_table, id_unixtime_created, date_time, expense_name, expense_sum, expense_currency, expense_info, expense_payer, expense_members ) {
          var db = getDatabase();
          var res = "";
           db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS table_' + project_name_table + ' (id_unixtime_created TEXT,
                                                                                            date_time TEXT,
                                                                                            expense_name TEXT,
                                                                                            expense_sum TEXT,
                                                                                            expense_currency TEXT,
                                                                                            expense_info TEXT,
                                                                                            expense_payer TEXT,
                                                                                            expense_members TEXT)' );
            var rs = tx.executeSql('INSERT OR REPLACE INTO table_' + project_name_table + ' VALUES (?,?,?,?,?,?,?,?);', [ id_unixtime_created,
                                                                                                                   date_time,
                                                                                                                   expense_name,
                                                                                                                   expense_sum,
                                                                                                                   expense_currency,
                                                                                                                   expense_info,
                                                                                                                   expense_payer,
                                                                                                                   expense_members ]);
              if (rs.rowsAffected > 0) {
               res = "OK";
               //console.log("project info found and updated")
              } else {
               res = "Error";
              }
            }
           );
           return res;
        }
        function updateExpense ( project_name_table, id_unixtime_created, date_time, expense_name, expense_sum, expense_currency, expense_info, expense_payer, expense_members ) {
            var db = getDatabase();
            var res = "";
              db.transaction(function(tx) {
              tx.executeSql('CREATE TABLE IF NOT EXISTS table_' + project_name_table + ' (id_unixtime_created TEXT,
                                                                                    date_time TEXT,
                                                                                    expense_name TEXT,
                                                                                    expense_sum TEXT,
                                                                                    expense_currency TEXT,
                                                                                    expense_info TEXT,
                                                                                    expense_payer TEXT,
                                                                                    expense_members TEXT)' );
              var rs = tx.executeSql('UPDATE table_' + project_name_table
                                     + ' SET date_time="' + date_time
                                     + '", expense_name="' + expense_name
                                     + '", expense_sum="' + expense_sum
                                     + '", expense_currency="' + expense_currency
                                     + '", expense_info="' + expense_info
                                     + '", expense_payer="' + expense_payer
                                     + '", expense_members="' + expense_members
                                     + '" WHERE id_unixtime_created=' + id_unixtime_created + ';');
                if (rs.rowsAffected > 0) {
                 res = "OK";
                } else {
                 res = "Error";
                }
              }
             );
             return res;
        }
        function deleteExpense (project_id_timestamp, id_unixtime_created) {
            var db = getDatabase();
            var res = "";
             db.transaction(function(tx) {
              tx.executeSql('CREATE TABLE IF NOT EXISTS table_' + project_id_timestamp + ' (id_unixtime_created TEXT,
                                                                                    date_time TEXT,
                                                                                    expense_name TEXT,
                                                                                    expense_sum TEXT,
                                                                                    expense_currency TEXT,
                                                                                    expense_info TEXT,
                                                                                    expense_payer TEXT,
                                                                                    expense_members TEXT)' );
              //var rs = tx.executeSql('DELETE FROM table_' + project_id_timestamp + ';');
              var rs = tx.executeSql('DELETE FROM table_' + project_id_timestamp + ' WHERE id_unixtime_created=' + id_unixtime_created + ';');
                if (rs.rowsAffected > 0) {
                 res = "OK";
                } else {
                 res = "Error";
                }
              }
             );
             return res;
        }
        function deleteAllExpenses (project_id_timestamp) {
            var db = getDatabase();
            var res = "";
             db.transaction(function(tx) {
              tx.executeSql('CREATE TABLE IF NOT EXISTS table_' + project_id_timestamp + ' (id_unixtime_created TEXT,
                                                                                    date_time TEXT,
                                                                                    expense_name TEXT,
                                                                                    expense_sum TEXT,
                                                                                    expense_currency TEXT,
                                                                                    expense_info TEXT,
                                                                                    expense_payer TEXT,
                                                                                    expense_members TEXT)' );
              var rs = tx.executeSql('DELETE FROM table_' + project_id_timestamp + ';');
                if (rs.rowsAffected > 0) {
                 res = "OK";
                } else {
                 res = "Error";
                }
              }
             );
             return res;
        }
        function getAllExpenses( project_name_table, default_value ) {
           var db = getDatabase();
           var res=[];
           try {
             db.transaction(function(tx) {
             var rs = tx.executeSql('SELECT * FROM table_'+ project_name_table + ';');
              if (rs.rows.length > 0) {
                for (var i = 0; i < rs.rows.length; i++) {
                 res.push([rs.rows.item(i).id_unixtime_created,
                           rs.rows.item(i).date_time,
                           rs.rows.item(i).expense_name,
                           rs.rows.item(i).expense_sum,
                           rs.rows.item(i).expense_currency,
                           rs.rows.item(i).expense_info,
                           rs.rows.item(i).expense_payer,
                           rs.rows.item(i).expense_members,
                          ])
                }
              } else {
               res = default_value;
              }
            })
           } catch (err) {
             //console.log("Database " + err);
            res = default_value;
           };
           return res
        }
    }

}
