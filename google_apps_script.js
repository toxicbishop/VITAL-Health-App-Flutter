/**
 * Google Apps Script Backend for VITAL App
 *
 * Deploy as Web App:
 *   Execute as: Me
 *   Who has access: Anyone
 *
 * Payload contracts:
 *   Logs (Create):
 *     { "timestamp": "...", "type": "...", "uid": "...",
 *       "weight": ..., "bp_sys": ..., "bp_dia": ..., "hr": ..., "value": ..., "unit": ..., "notes": ... }
 *
 *   Delete:
 *     { "type": "DELETE", "uid": "..." }
 *
 *   Profile:
 *     { "timestamp": "...", "type": "PROFILE", "name": "Mom" }
 */

var LOG_HEADERS = [
  "UID",
  "Date",
  "Time",
  "Type",
  "Value",
  "Unit",
  "Weight",
  "BP Systolic",
  "BP Diastolic",
  "Heart Rate",
  "Notes",
];
var LOG_SHEET = "Logs";
var PROFILE_HEADERS = ["Name", "CreatedAt", "UpdatedAt"];
var PROFILE_SHEET = "Profile";

function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);

    if (!data.type) {
      return _json({ status: "error", message: "Missing 'type'" });
    }

    if (data.type === "DELETE") {
      return _handleDelete(data);
    }

    if (data.type === "PROFILE") {
      var ts = data.timestamp ? new Date(data.timestamp) : new Date();
      return _handleProfile(data, ts);
    }

    // Default: Handle as a Log Entry (Create/Update)
    var ts = data.timestamp ? new Date(data.timestamp) : new Date();
    return _handleLog(data, ts);
  } catch (err) {
    return _json({ status: "error", message: String(err) });
  }
}

function _handleLog(data, ts) {
  var sheet = _ensureSheet(LOG_SHEET, LOG_HEADERS);
  var tz = SpreadsheetApp.getActiveSpreadsheet().getSpreadsheetTimeZone();

  // Use provided UID or generate one
  var uid = data.uid || Utilities.getUuid();

  // If UID exists, update it. Otherwise append.
  var existingRow = _findRowByUid(sheet, uid);

  var rowData = [
    uid,
    Utilities.formatDate(ts, tz, "yyyy-MM-dd"),
    Utilities.formatDate(ts, tz, "HH:mm:ss"),
    data.type,
    _nullable(data.value),
    _nullable(data.unit),
    _nullable(data.weight),
    _nullable(data.bp_sys),
    _nullable(data.bp_dia),
    _nullable(data.hr),
    _nullable(data.notes),
  ];

  if (existingRow > 0) {
    sheet.getRange(existingRow, 1, 1, rowData.length).setValues([rowData]);
  } else {
    sheet.appendRow(rowData);
  }

  return _json({ status: "success", uid: uid });
}

function _handleDelete(data) {
  if (!data.uid)
    return _json({ status: "error", message: "Missing 'uid' for delete" });
  var sheet = _ensureSheet(LOG_SHEET, LOG_HEADERS);
  var row = _findRowByUid(sheet, data.uid);
  if (row > 0) {
    sheet.deleteRow(row);
    return _json({ status: "success", message: "Deleted row " + row });
  }
  return _json({ status: "error", message: "Record not found" });
}

function _handleProfile(data, ts) {
  if (!data.name || String(data.name).trim() === "") {
    return _json({ status: "error", message: "Missing 'name'" });
  }
  var sheet = _ensureSheet(PROFILE_SHEET, PROFILE_HEADERS);
  var tz = SpreadsheetApp.getActiveSpreadsheet().getSpreadsheetTimeZone();
  var nowStr = Utilities.formatDate(ts, tz, "yyyy-MM-dd HH:mm:ss");
  var name = String(data.name).trim();

  if (sheet.getLastRow() > 1) {
    var row = 2;
    sheet
      .getRange(row, 1, 1, 3)
      .setValues([[name, sheet.getRange(row, 2).getValue() || nowStr, nowStr]]);
  } else {
    sheet.appendRow([name, nowStr, nowStr]);
  }
  return _json({ status: "success", name: name });
}

function _findRowByUid(sheet, uid) {
  if (sheet.getLastRow() < 2) return -1;
  var data = sheet.getRange(2, 1, sheet.getLastRow() - 1, 1).getValues();
  for (var i = 0; i < data.length; i++) {
    if (data[i][0] == uid) return i + 2;
  }
  return -1;
}

function _ensureSheet(name, headers) {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName(name);
  if (!sheet) {
    sheet = ss.insertSheet(name);
    sheet.appendRow(headers);
  } else if (sheet.getLastRow() === 0) {
    sheet.appendRow(headers);
  }
  return sheet;
}

function _nullable(v) {
  return v === null || v === undefined ? "" : v;
}

function _json(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(
    ContentService.MimeType.JSON,
  );
}
