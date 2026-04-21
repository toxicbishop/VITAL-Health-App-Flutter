/**
 * Google Apps Script Backend for VITAL (Mom's Health Tracker PRD)
 *
 * Deploy as Web App:
 *   Execute as: Me
 *   Who has access: Anyone
 *
 * Payload contracts:
 *   Logs (PRD §6.2):
 *     { "timestamp": "...", "type": "WEIGHT"|"BP"|"BOTH",
 *       "weight": 70.5|null, "bp_sys": 120|null, "bp_dia": 80|null }
 *
 *   Profile (API PRD AC3 — single active record, update if present):
 *     { "timestamp": "...", "type": "PROFILE", "name": "Mom" }
 *
 * Sheet tabs:
 *   Logs:    Date | Time | Type | Weight | BP Systolic | BP Diastolic
 *   Profile: Name | CreatedAt | UpdatedAt
 */

var LOG_HEADERS = ["Date", "Time", "Type", "Weight", "BP Systolic", "BP Diastolic"];
var LOG_SHEET = "Logs";
var PROFILE_HEADERS = ["Name", "CreatedAt", "UpdatedAt"];
var PROFILE_SHEET = "Profile";

function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);

    if (!data.type || !data.timestamp) {
      return _json({ status: "error", message: "Missing 'type' or 'timestamp'" });
    }

    var ts = new Date(data.timestamp);
    if (isNaN(ts.getTime())) {
      return _json({ status: "error", message: "Invalid timestamp" });
    }

    if (data.type === "PROFILE") {
      return _handleProfile(data, ts);
    }
    return _handleLog(data, ts);
  } catch (err) {
    return _json({ status: "error", message: String(err) });
  }
}

function _handleLog(data, ts) {
  var sheet = _ensureSheet(LOG_SHEET, LOG_HEADERS);
  var tz = SpreadsheetApp.getActiveSpreadsheet().getSpreadsheetTimeZone();
  sheet.appendRow([
    Utilities.formatDate(ts, tz, "yyyy-MM-dd"),
    Utilities.formatDate(ts, tz, "HH:mm:ss"),
    data.type,
    _nullable(data.weight),
    _nullable(data.bp_sys),
    _nullable(data.bp_dia),
  ]);
  return _json({ status: "success" });
}

function _handleProfile(data, ts) {
  if (!data.name || String(data.name).trim() === "") {
    return _json({ status: "error", message: "Missing 'name'" });
  }
  var sheet = _ensureSheet(PROFILE_SHEET, PROFILE_HEADERS);
  var tz = SpreadsheetApp.getActiveSpreadsheet().getSpreadsheetTimeZone();
  var nowStr = Utilities.formatDate(ts, tz, "yyyy-MM-dd HH:mm:ss");
  var name = String(data.name).trim();

  // AC3: only one active profile record — update if already present.
  if (sheet.getLastRow() > 1) {
    var row = 2;
    sheet.getRange(row, 1, 1, 3).setValues([[name, sheet.getRange(row, 2).getValue() || nowStr, nowStr]]);
  } else {
    sheet.appendRow([name, nowStr, nowStr]);
  }
  return _json({ status: "success", name: name });
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
  return (v === null || v === undefined) ? "" : v;
}

function _json(obj, _code) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}
