/**
 * Google Apps Script Backend for VITAL Health (PRD Version)
 * Deploy this as a Web App (Access: Anyone)
 */

function doPost(e) {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName("Logs") || ss.insertSheet("Logs");
  
  // Headers if sheet is new
  if (sheet.getLastRow() == 0) {
    sheet.appendRow(["Timestamp", "Type", "Weight (kg)", "Systolic", "Diastolic", "Date"]);
  }
  
  var data = JSON.parse(e.postData.contents);
  var timestamp = new Date();
  
  if (data.type === 'weight') {
    sheet.appendRow([timestamp, 'Weight', data.weight, '', '', data.date]);
  } else if (data.type === 'bp') {
    sheet.appendRow([timestamp, 'BP', '', data.systolic, data.diastolic, data.date]);
  } else if (data.type === 'both') {
    sheet.appendRow([timestamp, 'Both', data.weight, data.systolic, data.diastolic, data.date]);
  }
  
  return ContentService.createTextOutput(JSON.stringify({status: "success"}))
    .setMimeType(ContentService.MimeType.JSON);
}
