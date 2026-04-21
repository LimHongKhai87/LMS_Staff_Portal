/**
 * Staff Registration Form - Google Apps Script
 * ADE Sdn Bhd Part 145 KUL Line Maintenance
 *
 * CHANGELOG (latest revision):
 * - 'age' column REMOVED from getHeaders() — now 87 columns total
 * - 'age' key REMOVED from buildFormDataMap() — age is now calculated
 *   dynamically on the frontend from date_of_birth via calculateAgeFromDOB()
 * - date_of_birth stored as yyyy-MM-dd string (unchanged)
 * - All other functions resolve columns by name, so removing 'age' from
 *   the sheet is handled automatically with no further changes needed
 */

// ── Configuration ─────────────────────────────────────────────────────────────
const CONFIG = {
  SPREADSHEET_ID:    SpreadsheetApp.getActiveSpreadsheet().getId(),
  DATA_SHEET:        'data',
  NATIONALITY_SHEET: 'nationality',
  TYPE_RATING_SHEET: 'type_rating',
  STAFF_FOLDER_ID:   '1M9Z4EPRY8txsLWY3oXnm_4IlDDOTYlQE'
};

// ── Upload field → subfolder / document-type mapping ─────────────────────────
const UPLOAD_CONFIG = {
  'ic_pdf_link':           { subfolder: 'IC',               documentType: 'IC',       numberField: 'ic_no' },
  'amel_pdf_link':         { subfolder: 'CAAM License',     documentType: 'AMEL',     numberField: 'amel_license' },
  'amtl_pdf_link':         { subfolder: 'CAAM License',     documentType: 'AMTL',     numberField: 'amtl_license_no' },
  'ade_approval_pdf_link': { subfolder: 'Company Approval', documentType: 'ADE',      numberField: 'ade_approval_no' },
  'passport_pdf_link':     { subfolder: 'Passport',         documentType: 'Passport', numberField: 'passport_no' },
  'mab_pass_pdf_link':     { subfolder: 'MAB',              documentType: 'MAB',      numberField: 'staff_no' },
  'adp_pdf_link':          { subfolder: 'ADP',              documentType: 'ADP',      numberField: 'adp_no' }
};

// ── Admin access ──────────────────────────────────────────────────────────────
const ADMIN_EMAIL_GAS = 'limhongkhai@airasia.com';

// ═════════════════════════════════════════════════════════════════════════════
//  CACHE HELPERS
//  GAS CacheService has a 100 KB per-key hard limit.
//  These helpers automatically chunk large payloads across multiple keys.
//  TTL: 5 minutes — auto-invalidated on any write operation.
// ═════════════════════════════════════════════════════════════════════════════

const CACHE_TTL   = 300;    // seconds — 5 minutes
const CACHE_CHUNK = 90000;  // chars per chunk — safely under 100 KB limit

const CACHE_KEYS = {
  dashboard: 'ade_dash_v1',
  absence:   'ade_abs_v1',
  disc:      'ade_disc_v1'
};

function cacheWrite(key, data) {
  try {
    const cache = CacheService.getScriptCache();
    const json  = JSON.stringify(data);
    const total = Math.ceil(json.length / CACHE_CHUNK);
    const pairs = {};
    for (let i = 0; i < total; i++) {
      pairs[key + '_c' + i] = json.slice(i * CACHE_CHUNK, (i + 1) * CACHE_CHUNK);
    }
    pairs[key + '_meta'] = JSON.stringify({ n: total });
    cache.putAll(pairs, CACHE_TTL);
    console.log('Cache WRITE: ' + key + ' (' + total + ' chunk(s), ' + json.length + ' chars)');
  } catch (e) {
    console.warn('cacheWrite failed: ' + e.toString());
  }
}

function cacheRead(key) {
  try {
    const cache   = CacheService.getScriptCache();
    const metaStr = cache.get(key + '_meta');
    if (!metaStr) return null;

    const { n }   = JSON.parse(metaStr);
    const chunkKeys = [];
    for (let i = 0; i < n; i++) chunkKeys.push(key + '_c' + i);

    const chunks = cache.getAll(chunkKeys);
    const parts  = [];
    for (let i = 0; i < n; i++) {
      const chunk = chunks[key + '_c' + i];
      if (!chunk) return null;  // partial miss — treat as full miss
      parts.push(chunk);
    }
    console.log('Cache HIT: ' + key + ' (' + n + ' chunk(s))');
    return JSON.parse(parts.join(''));
  } catch (e) {
    console.warn('cacheRead failed: ' + e.toString());
    return null;
  }
}

function cacheInvalidate() {
  try {
    const cache   = CacheService.getScriptCache();
    const allKeys = [];
    // Accept any number of key arguments
    Array.prototype.slice.call(arguments).forEach(function(key) {
      allKeys.push(key + '_meta');
      for (let i = 0; i < 20; i++) allKeys.push(key + '_c' + i);
    });
    cache.removeAll(allKeys);
    console.log('Cache INVALIDATED: ' + Array.prototype.slice.call(arguments).join(', '));
  } catch (e) {
    console.warn('cacheInvalidate failed: ' + e.toString());
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  ROUTING
// ═════════════════════════════════════════════════════════════════════════════

function doGet(e) {
  const page = e && e.parameter && e.parameter.page ? e.parameter.page : 'landing';

  if (page === 'register') {
    return HtmlService.createHtmlOutputFromFile('Registration')
      .setTitle('Staff Registration')
      .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL)
      .addMetaTag('viewport', 'width=device-width, initial-scale=1');
  }

  if (page === 'profile') {
    return HtmlService.createHtmlOutputFromFile('Profile')
      .setTitle('My Profile — ADE Staff Portal')
      .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL)
      .addMetaTag('viewport', 'width=device-width, initial-scale=1');
  }

  if (page === 'dashboard') {
    return HtmlService.createHtmlOutputFromFile('Dashboard')
      .setTitle('Dashboard — ADE Staff Portal')
      .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL)
      .addMetaTag('viewport', 'width=device-width, initial-scale=1');
  }

  if (page === 'approval') {
    return HtmlService.createHtmlOutputFromFile('ApprovalMatrix')
      .setTitle('Approval Matrix — ADE KUL')
      .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL)
      .addMetaTag('viewport', 'width=device-width, initial-scale=1');
  }

  // Default: landing router
  return HtmlService.createHtmlOutputFromFile('Landing')
    .setTitle('ADE Staff Portal')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL)
    .addMetaTag('viewport', 'width=device-width, initial-scale=1');
}


// ═════════════════════════════════════════════════════════════════════════════
//  USER HELPERS
// ═════════════════════════════════════════════════════════════════════════════

function getUserEmail() {
  return Session.getActiveUser().getEmail();
}

function getScriptUrl() {
  return ScriptApp.getService().getUrl();
}


// ═════════════════════════════════════════════════════════════════════════════
//  USER STATUS & DATA
// ═════════════════════════════════════════════════════════════════════════════

/**
 * Checks whether the current user is registered and returns their profile data.
 */
function checkUserStatus() {
  const email = Session.getActiveUser().getEmail();

  if (!email || !email.toLowerCase().endsWith('@airasia.com')) {
    return {
      status:  'invalid_domain',
      email:   email,
      message: 'Please use your company email address (@airasia.com) to access this portal.'
    };
  }

  try {
    const ss    = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    const sheet = ss.getSheetByName(CONFIG.DATA_SHEET);

    if (!sheet) {
      return { status: 'not_registered', email: email,
               message: 'You are not registered in the system. Please complete the registration form.' };
    }

    const lastRow = sheet.getLastRow();
    if (lastRow < 2) {
      return { status: 'not_registered', email: email,
               message: 'You are not registered in the system. Please complete the registration form.' };
    }

    const headers     = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0];
    const emailColIdx = headers.indexOf('email_address');

    if (emailColIdx === -1) {
      return { status: 'not_registered', email: email,
               message: 'You are not registered in the system. Please complete the registration form.' };
    }

    const dataRange = sheet.getRange(2, 1, lastRow - 1, sheet.getLastColumn()).getValues();

    for (let i = 0; i < dataRange.length; i++) {
      if (dataRange[i][emailColIdx] &&
          dataRange[i][emailColIdx].toString().toLowerCase() === email.toLowerCase()) {

        const userData = {};
        headers.forEach((header, index) => {
          if (header) {
            let value = dataRange[i][index];
            if (value instanceof Date) {
              value = Utilities.formatDate(value, Session.getScriptTimeZone(), 'yyyy-MM-dd');
            }
            userData[header] = value || '';
          }
        });

        return { status: 'registered', email: email, data: userData, headers: headers };
      }
    }

    return { status: 'not_registered', email: email,
             message: 'You are not registered in the system. Please complete the registration form.' };

  } catch (e) {
    console.error('Error checking user status:', e);
    return { status: 'error', email: email,
             message: 'An error occurred while checking your status. Please try again later.' };
  }
}

/**
 * Updates one or more fields for the current user.
 * Resolves all column positions by header name — safe against column reordering.
 */
function updateUserData(updates) {
  try {
    const email = Session.getActiveUser().getEmail();
    const ss    = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    const sheet = ss.getSheetByName(CONFIG.DATA_SHEET);

    if (!sheet) return { success: false, message: 'Data sheet not found' };

    const lastRow = sheet.getLastRow();
    const lastCol = sheet.getLastColumn();
    if (lastRow < 2) return { success: false, message: 'No data found' };

    const headers     = sheet.getRange(1, 1, 1, lastCol).getValues()[0];
    const emailColIdx = headers.indexOf('email_address');
    if (emailColIdx === -1) return { success: false, message: 'Email column not found' };

    const allData       = sheet.getRange(2, 1, lastRow - 1, lastCol).getValues();
    let userRowIndex    = -1;
    let currentUserData = {};

    for (let i = 0; i < allData.length; i++) {
      if (allData[i][emailColIdx] &&
          allData[i][emailColIdx].toString().toLowerCase() === email.toLowerCase()) {
        userRowIndex = i + 2;
        headers.forEach((header, index) => { currentUserData[header] = allData[i][index] || ''; });
        break;
      }
    }

    if (userRowIndex === -1) return { success: false, message: 'User not found' };

    // Auto-calculate employment years when start/end dates are updated
    ['last', 'second_last', 'third_last'].forEach(suffix => {
      const startField = 'start_date_' + suffix;
      const endField   = 'end_date_'   + suffix;
      const yearField  = 'year_'       + suffix;

      const startDate = updates[startField] !== undefined ? updates[startField] : currentUserData[startField];
      const endDate   = updates[endField]   !== undefined ? updates[endField]   : currentUserData[endField];

      if (startDate && endDate) {
        const years = calculateYearsBetweenDates(startDate, endDate);
        if (years !== null) updates[yearField] = years;
      }
    });

    // Read the full row once, patch it, write back in one call
    const fullRow = sheet.getRange(userRowIndex, 1, 1, lastCol).getValues()[0];

    for (const [field, value] of Object.entries(updates)) {
      const colIndex = headers.indexOf(field);
      if (colIndex !== -1) fullRow[colIndex] = value;
    }

    // Always update timestamp
    const tsCol = headers.indexOf('last_update_timestamp');
    if (tsCol !== -1) fullRow[tsCol] = new Date();

    sheet.getRange(userRowIndex, 1, 1, lastCol).setValues([fullRow]);

    // ── Archive if status changed to Resigned or Transfer ───────────────
    if (updates.status && (updates.status === 'Resigned' || updates.status === 'Transfer')) {
      const staffNoCol = headers.indexOf('staff_no');
      const staffNo    = staffNoCol !== -1 ? fullRow[staffNoCol] : '';
      const statusDate = updates.status_date || '';
      if (staffNo) {
        archiveToResignTransferRecords(staffNo, updates.status, statusDate);
      }
    }
    const userKey = 'profinit_' + email.toLowerCase().replace(/[^a-z0-9]/g, '_');
    cacheInvalidate(userKey);
    cacheInvalidate(CACHE_KEYS.dashboard);

    return { success: true, message: 'Data updated successfully' };

  } catch (e) {
    console.error('Error updating user data:', e);
    return { success: false, message: 'Error: ' + e.toString() };
  }
}


// ═════════════════════════════════════════════════════════════════════════════
//  DROPDOWN DATA
// ═════════════════════════════════════════════════════════════════════════════

function getNationalityList() {
  try {
    const ss    = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    const sheet = ss.getSheetByName(CONFIG.NATIONALITY_SHEET);
    if (!sheet) return ['Malaysian', 'Singaporean', 'Indonesian', 'Filipino', 'Indian', 'Bangladeshi', 'Other'];

    const lastRow = sheet.getLastRow();
    if (lastRow < 2) return [];
    return sheet.getRange('A2:A' + lastRow).getValues().flat().filter(v => v !== '');
  } catch (e) {
    console.error('Error getting nationality list:', e);
    return ['Malaysian', 'Singaporean', 'Indonesian', 'Filipino', 'Indian', 'Bangladeshi', 'Other'];
  }
}

function getTypeRatingList() {
  try {
    const ss    = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    const sheet = ss.getSheetByName(CONFIG.TYPE_RATING_SHEET);
    if (!sheet) return ['A320', 'A321', 'A330', 'A350', 'B737', 'B777', 'B787', 'ATR72'];

    const lastRow = sheet.getLastRow();
    if (lastRow < 2) return [];
    return sheet.getRange('A2:A' + lastRow).getValues().flat().filter(v => v !== '');
  } catch (e) {
    console.error('Error getting type rating list:', e);
    return ['A320', 'A321', 'A330', 'A350', 'B737', 'B777', 'B787', 'ATR72'];
  }
}

function getDropdownData() {
  return {
    nationalities: getNationalityList(),
    typeRatings:   getTypeRatingList(),
    userEmail:     getUserEmail()
  };
}

/**
 * Reads the "Com Appr" sheet and returns approval types, EGR, Boroscope options.
 */
function getApprovalTypes() {
  try {
    const ss    = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    const sheet = ss.getSheetByName('Com Appr');
    if (!sheet) return {};

    const lastRow = sheet.getLastRow();
    const lastCol = sheet.getLastColumn();
    if (lastRow < 2 || lastCol < 1) return {};

    const headers = sheet.getRange(1, 1, 1, lastCol).getValues()[0];
    const data    = sheet.getRange(2, 1, lastRow - 1, lastCol).getValues();

    const result = {};
    for (let col = 0; col < headers.length; col++) {
      const header = String(headers[col]).trim();
      if (!header) continue;
      result[header] = data.map(row => String(row[col]).trim()).filter(v => v !== '');
    }

    return result;
  } catch (e) {
    console.error('Error getting approval types:', e);
    return {};
  }
}


// ═════════════════════════════════════════════════════════════════════════════
//  SHEET HEADERS
//  Used only when creating a brand-new Data sheet from scratch.
// ═════════════════════════════════════════════════════════════════════════════

/**
 * Returns the canonical 87-column header row.
 * 'age' has been removed — age is derived dynamically on the frontend
 * from date_of_birth via calculateAgeFromDOB().
 */
function getHeaders() {
  return [
    'department_information_section',                                          // 1
    'email_address', 'full_name', 'staff_no', 'joining_date',                 // 2–5
    'date_of_birth', 'nationality', 'ic_no', 'ic_pdf_link',                  // 6–9   ← age removed
    'gender', 'phone_no', 'designation', 'team', 'main_trade',               // 10–14
    'year_joined_aviation', 'shift', 'nickname',                              // 15–17
    'previous_employment_section',                                             // 18
    'no_of_employment',                                                        // 19
    'company_last', 'section_last', 'designation_last', 'type_last',          // 20–23
    'start_date_last', 'end_date_last', 'year_last',                          // 24–26
    'company_second_last', 'section_second_last', 'designation_second_last',  // 27–29
    'type_second_last', 'start_date_second_last', 'end_date_second_last',     // 30–32
    'year_second_last',                                                        // 33
    'company_third_last', 'section_third_last', 'designation_third_last',     // 34–36
    'type_third_last', 'start_date_third_last', 'end_date_third_last',        // 37–39
    'year_third_last',                                                         // 40
    'caam_licens_section',                                                     // 41
    'available_license', 'amel_license_category', 'amel_license',             // 42–44
    'amel_pdf_link',                                                           // 45
    'b1_type_rating', 'b2_type_rating', 'c_type_rating',                      // 46–48
    'amel_issue_date', 'amel_license_expiry',                                 // 49–50
    'amtl_license_no', 'amtl_license_category', 'amtl_pdf_link',             // 51–53
    'a1_type_rating',                                                          // 54
    'amtl_issue_date', 'amtl_license_expiry',                                 // 55–56
    'year_establish',                                                          // 57
    'ade_approval_section',                                                    // 58
    'ade_approval_no', 'ade_approval_pdf_link', 'ade_system_code',            // 59–61
    'limitation',  
    'b1_ade_approval_type', 'b2_ade_approval_type',                           // 62–63
    'c_ade_approval_type', 'a_ade_approval_type',                             // 64–65
    'ade_approval_expiry', 'egr', 'boroscope', 'compass_swign',              // 66–69
    'personal_details_section',                                                // 70
    'passport_no', 'passport_pdf_link', 'passport_expiry',                    // 71–73
    'home_address', 'states',                                                  // 74–75
    'next_of_kin_name', 'relationship', 'next_of_kin_contact_no', 'race',     // 76–79
    'aiport_authority_section',                                                // 80
    'mab_pass_expiry_date', 'mab_pass_pdf_link',                             // 81–82
    'adp_no', 'adp_expiry_date', 'adp_pdf_link',                             // 83–85
    'last_update_timestamp',                                                   // 86
    'folder_link',                                                              // 87
    'immediate_superior',      // 88  ← ADD
    'role',                    // 89  ← ADD
    'status',               
    'status_date'           
  ];
}


// ═════════════════════════════════════════════════════════════════════════════
//  FORM SUBMISSION
// ═════════════════════════════════════════════════════════════════════════════

/**
 * Appends a new registration row to the Data sheet.
 * Reads actual headers from the sheet so column order is auto-resolved.
 */
function submitForm(formData) {
  try {
    const ss = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    let sheet = ss.getSheetByName(CONFIG.DATA_SHEET);

    if (!sheet) {
      sheet = ss.insertSheet(CONFIG.DATA_SHEET);
      const defaultHeaders = getHeaders();
      sheet.getRange(1, 1, 1, defaultHeaders.length).setValues([defaultHeaders]);
      sheet.getRange(1, 1, 1, defaultHeaders.length).setFontWeight('bold');
    }

    const lastCol = sheet.getLastColumn();
    const headers = sheet.getRange(1, 1, 1, lastCol).getValues()[0];

    // ── STEP 1: Save all text/form data IMMEDIATELY (no files yet) ──────────
    // This ensures employment history and all form fields are persisted even
    // if a subsequent file upload times out (large PDFs can take 30+ seconds).
    const dataMap = buildTextDataMap(formData);
    const rowData = headers.map(h => (h && dataMap[h] !== undefined) ? dataMap[h] : '');
    sheet.appendRow(rowData);
    const newRowNumber = sheet.getLastRow();
    console.log('Row saved at row ' + newRowNumber + ' — now uploading files...');

    // Helper: update a single cell in the saved row by header name
    function updateCell(fieldName, value) {
      if (!value) return;
      const colIdx = headers.indexOf(fieldName);
      if (colIdx !== -1) sheet.getRange(newRowNumber, colIdx + 1).setValue(value);
    }

    // ── STEP 2: Upload files and update those cells in the saved row ─────────
    if (CONFIG.STAFF_FOLDER_ID) {
      try {
        const staffNo   = formData.staff_no  || 'unknown';
        const fullName  = formatName(formData.full_name || 'Unknown');
        const staffFolder = createStaffFolderStructure(CONFIG.STAFF_FOLDER_ID, staffNo, fullName);
        updateCell('folder_link', staffFolder.getUrl());
        console.log('Staff folder: ' + staffFolder.getUrl());

        if (formData.email_address) {
          try { staffFolder.addEditor(formData.email_address); } catch (e) {
            console.error('Error sharing folder: ' + e.toString());
          }
        }

        if (formData.ic_picture_base64) {
          console.log('Uploading IC picture...');
          const ext  = getExtFromBase64(formData.ic_picture_base64, 'jpg');
          const link = savePictureToSubfolder(
            formData.ic_picture_base64, staffFolder, 'IC',
            generateFileName(fullName, formData.ic_no, 'IC', 'ic.' + ext));
          updateCell('ic_pdf_link', link);
          console.log('IC link: ' + (link || 'FAILED'));
        }

        if (formData.amel_picture_base64) {
          console.log('Uploading AMEL picture...');
          const ext  = getExtFromBase64(formData.amel_picture_base64, 'pdf');
          const link = savePictureToSubfolder(
            formData.amel_picture_base64, staffFolder, 'CAAM License',
            generateFileName(fullName, formData.amel_license, 'AMEL', 'amel.' + ext));
          updateCell('amel_pdf_link', link);
          console.log('AMEL link: ' + (link || 'FAILED'));
        }

        if (formData.amtl_picture_base64) {
          console.log('Uploading AMTL picture...');
          const ext  = getExtFromBase64(formData.amtl_picture_base64, 'pdf');
          const link = savePictureToSubfolder(
            formData.amtl_picture_base64, staffFolder, 'CAAM License',
            generateFileName(fullName, formData.amtl_license_no, 'AMTL', 'amtl.' + ext));
          updateCell('amtl_pdf_link', link);
          console.log('AMTL link: ' + (link || 'FAILED'));
        }

        if (formData.passport_picture_base64) {
          console.log('Uploading Passport picture...');
          const ext  = getExtFromBase64(formData.passport_picture_base64, 'jpg');
          const link = savePictureToSubfolder(
            formData.passport_picture_base64, staffFolder, 'Passport',
            generateFileName(fullName, formData.passport_no, 'Passport', 'passport.' + ext));
          updateCell('passport_pdf_link', link);
          console.log('Passport link: ' + (link || 'FAILED'));

          // ── Notify LMS team of new passport document ──────────────────────
          if (link) {
            sendPassportNotificationEmail({
              name:           fullName,
              staffNo:        formData.staff_no        || '',
              designation:    formData.designation     || '',
              nationality:    formData.nationality     || '',
              passportNo:     formData.passport_no     || '',
              passportExpiry: formData.passport_expiry || '',
              passportFileUrl: link
            });
          }
        }

        console.log('All file uploads completed');
      } catch (e) {
        // Row is already saved — log but don't fail the whole submission
        console.error('File upload error (row already saved): ' + e.toString());
      }
    }

    return { success: true, message: 'Registration submitted successfully!' };
  } catch (e) {
    console.error('Error submitting form:', e);
    return { success: false, message: 'Error: ' + e.toString() };
  }
}

/**
 * Extracts the file extension from a base64 data URI.
 * e.g. "data:application/pdf;base64,..." → "pdf"
 *      "data:image/jpeg;base64,..."       → "jpg"
 */
function getExtFromBase64(base64Data, fallback) {
  if (!base64Data) return fallback || 'bin';
  const match = base64Data.match(/^data:([^;]+);base64,/);
  if (!match) return fallback || 'bin';
  const mimeExtMap = {
    'application/pdf': 'pdf',
    'image/jpeg': 'jpg', 'image/jpg': 'jpg',
    'image/png': 'png',  'image/gif': 'gif',
    'image/webp': 'webp', 'image/heic': 'heic', 'image/heif': 'heif'
  };
  return mimeExtMap[match[1].toLowerCase()] || fallback || 'bin';
}

/**
 * Builds a header-name-keyed data map from raw form data — TEXT FIELDS ONLY.
 * File upload links (ic_pdf_link, amel_pdf_link, etc.) are intentionally
 * left empty here; submitForm() updates those cells after uploading.
 * 'age' is intentionally omitted — calculated dynamically by the frontend.
 */
function buildTextDataMap(formData) {
  const timestamp      = new Date();
  const fullName       = formatName(formData.full_name || 'Unknown');
  const yearLast       = calculateYearsBetweenDates(formData.start_date_last,       formData.end_date_last)       || '';
  const yearSecondLast = calculateYearsBetweenDates(formData.start_date_second_last, formData.end_date_second_last) || '';
  const yearThirdLast  = calculateYearsBetweenDates(formData.start_date_third_last,  formData.end_date_third_last)  || '';

  return {
    // ── Department Information ──────────────────────────────────────────────
    'email_address':            formData.email_address        || '',
    'full_name':                fullName,
    'staff_no':                 formData.staff_no             || '',
    'joining_date':             formData.joining_date         || '',
    'date_of_birth':            formData.date_of_birth        || '',  // yyyy-MM-dd; age derived on frontend
    // 'age' intentionally omitted — calculated dynamically by the frontend
    'nationality':              formData.nationality          || '',
    'ic_no':                    formData.ic_no                || '',
    'ic_pdf_link':              '',                                   // updated after upload
    'gender':                   formData.gender               || '',
    'phone_no':                 formData.phone_no             || '',
    'designation':              formData.designation          || '',
    'main_trade':               formData.main_trade           || '',
    'year_joined_aviation':     formData.year_aviation        || '',
    'nickname':                 formData.nickname             || '',

    // ── Previous Employment ─────────────────────────────────────────────────
    'no_of_employment':         formData.no_of_employment     || '',
    'company_last':             formData.company_last         || '',
    'section_last':             formData.section_last         || '',
    'designation_last':         formData.designation_last     || '',
    'type_last':                formData.type_last            || '',
    'start_date_last':          formData.start_date_last      || '',
    'end_date_last':            formData.end_date_last        || '',
    'year_last':                yearLast,
    'company_second_last':      formData.company_second_last  || '',
    'section_second_last':      formData.section_second_last  || '',
    'designation_second_last':  formData.designation_second_last || '',
    'type_second_last':         formData.type_second_last     || '',
    'start_date_second_last':   formData.start_date_second_last || '',
    'end_date_second_last':     formData.end_date_second_last || '',
    'year_second_last':         yearSecondLast,
    'company_third_last':       formData.company_third_last   || '',
    'section_third_last':       formData.section_third_last   || '',
    'designation_third_last':   formData.designation_third_last || '',
    'type_third_last':          formData.type_third_last      || '',
    'start_date_third_last':    formData.start_date_third_last || '',
    'end_date_third_last':      formData.end_date_third_last  || '',
    'year_third_last':          yearThirdLast,

    // ── CAAM License ────────────────────────────────────────────────────────
    'available_license':        formData.available_license    || '',
    'amel_license_category':    formData.amel_category        || '',
    'amel_license':             formData.amel_license         || '',
    'amel_pdf_link':            '',                                   // updated after upload
    'b1_type_rating':           formData.b1_type_rating       || '',
    'b2_type_rating':           formData.b2_type_rating       || '',
    'c_type_rating':            formData.c_type_rating        || '',
    'amel_issue_date':          formData.amel_issue_date      || '',
    'amel_license_expiry':      formData.amel_license_expiry  || '',
    'amtl_license_no':          formData.amtl_license_no      || '',
    'amtl_license_category':    formData.amtl_license_category || '',
    'amtl_pdf_link':            '',                                   // updated after upload
    'a1_type_rating':           formData.a1_type_rating       || '',
    'amtl_issue_date':          formData.amtl_issue_date      || '',
    'amtl_license_expiry':      formData.amtl_license_expiry  || '',
    'year_establish':           formData.year_establish        || '',

    // ── Personal Details ────────────────────────────────────────────────────
    'passport_no':              formData.passport_no          || '',
    'passport_pdf_link':        '',                                   // updated after upload
    'passport_expiry':          formData.passport_expiry      || '',
    'home_address':             formData.address              || '',
    'states':                   formData.state                || '',
    'next_of_kin_name':         formData.next_of_kin_name     || '',
    'relationship':             formData.relationship         || '',
    'next_of_kin_contact_no':   formData.next_of_kin_contact_no || '',

    // ── Meta ────────────────────────────────────────────────────────────────
    'last_update_timestamp':    timestamp,
    'folder_link':              '',                                   // updated after folder creation
  };
}


// ═════════════════════════════════════════════════════════════════════════════
//  FILE / DRIVE UTILITIES
// ═════════════════════════════════════════════════════════════════════════════

function formatName(name) {
  return name.toLowerCase().replace(/\b\w/g, char => char.toUpperCase());
}

function generateFileName(fullName, documentNumber, documentType, originalFileName) {
  const extension     = originalFileName.split('.').pop().toLowerCase();
  const cleanFullName = fullName.replace(/[<>:"/\\|?*]/g, '').replace(/\s+/g, ' ').trim().substring(0, 50);
  const cleanDocNum   = (documentNumber || 'Unknown').toString().replace(/[^a-zA-Z0-9]/g, '').substring(0, 20);
  return cleanFullName + '_' + cleanDocNum + '-' + documentType + '.' + extension;
}

function findStaffFolder(parentFolderId, staffNo) {
  try {
    const parentFolder = DriveApp.getFolderById(parentFolderId);
    const folders      = parentFolder.getFolders();
    while (folders.hasNext()) {
      const folder     = folders.next();
      const folderName = folder.getName();
      if (folderName.startsWith(staffNo + ' - ') || folderName.startsWith(staffNo + '-')) return folder;
    }
    return null;
  } catch (e) {
    console.error('Error finding staff folder:', e);
    return null;
  }
}

function getOrCreateSubfolder(staffFolder, subfolderName) {
  const folders = staffFolder.getFoldersByName(subfolderName);
  return folders.hasNext() ? folders.next() : staffFolder.createFolder(subfolderName);
}

function createStaffFolderStructure(parentFolderId, staffNo, fullName) {
  const folderName   = staffNo + ' - ' + fullName;
  const parentFolder = DriveApp.getFolderById(parentFolderId);
  let staffFolder    = findStaffFolder(parentFolderId, staffNo);

  if (!staffFolder) {
    const existing = parentFolder.getFoldersByName(folderName);
    staffFolder = existing.hasNext() ? existing.next() : parentFolder.createFolder(folderName);
  }

  ['IC', 'CAAM License', 'Company Approval', 'MAB', 'ADP', 'Passport', 'Training', 'PCA']
    .forEach(name => { if (!staffFolder.getFoldersByName(name).hasNext()) staffFolder.createFolder(name); });

  return staffFolder;
}

function markOldFilesAsSuperseded(folder, documentType, fullName) {
  try {
    const files            = folder.getFiles();
    const searchPattern    = fullName + '_';
    const supersededSuffix = '_SUPERSEDED';
    const docTypePattern   = '-' + documentType + '.';

    while (files.hasNext()) {
      const file     = files.next();
      const fileName = file.getName();
      if (fileName.startsWith(searchPattern) &&
          fileName.indexOf(docTypePattern)   !== -1 &&
          fileName.indexOf(supersededSuffix) === -1) {
        const lastDot = fileName.lastIndexOf('.');
        const newName = lastDot !== -1
          ? fileName.substring(0, lastDot) + supersededSuffix + fileName.substring(lastDot)
          : fileName + supersededSuffix;
        file.setName(newName);
        console.log('Marked as superseded: ' + fileName + ' → ' + newName);
      }
    }
  } catch (e) {
    console.error('Error marking files as superseded:', e);
  }
}

/**
 * uploadFile()
 * ─────────────────────────────────────────────────────────────────────────────
 * Called from the Profile page via google.script.run after the user picks a
 * file in the upload widget.
 *
 * Flow:
 *  1. Authenticate caller and locate their row in the data sheet.
 *  2. Re-read the row FRESH (so passport_no / passport_expiry already saved
 *     by the preceding updateUserData call are visible).
 *  3. Resolve the target Drive subfolder from UPLOAD_CONFIG.
 *  4. Mark any previous file of the same document type as _SUPERSEDED.
 *  5. Write the new file and update the pdf-link cell in the data sheet.
 *  6. If the uploaded field is passport_pdf_link, fire the notification email
 *     with the real blob attached.
 *
 * @param {string} base64Data  Raw base64 string (no data-URI prefix).
 * @param {string} fileName    Original filename from the browser.
 * @param {string} mimeType    MIME type reported by the browser.
 * @param {string} fieldName   Sheet column name, e.g. "passport_pdf_link".
 * @returns {{ success: boolean, url?: string, fileName?: string, message?: string }}
 */
function uploadFile(base64Data, fileName, mimeType, fieldName) {
  try {

    // ── 1. Authenticate ────────────────────────────────────────────────────
    const email = Session.getActiveUser().getEmail();
    if (!email) return { success: false, message: 'User not authenticated.' };

    // ── 2. Strip data URI prefix and resolve real MIME type ───────────────
    //   savePictureToSubfolder strips this during registration, but uploadFile
    //   receives raw base64 from the Profile page which may include the prefix.
    //   Failing to strip it corrupts every uploaded file.
    let cleanBase64  = base64Data;
    let resolvedMime = mimeType;
    const dataUriMatch = base64Data.match(/^data:([^;]+);base64,([\s\S]+)$/);
    if (dataUriMatch) {
      resolvedMime = dataUriMatch[1];
      cleanBase64  = dataUriMatch[2].replace(/[\r\n]/g, '');
    }

    // ── 3. Enforce PDF-only for CAAM License and ADE Approval ─────────────
    const PDF_ONLY_FIELDS = ['amel_pdf_link', 'amtl_pdf_link', 'ade_approval_pdf_link'];
    if (PDF_ONLY_FIELDS.includes(fieldName) && resolvedMime !== 'application/pdf') {
      return {
        success: false,
        message: 'CAAM License and ADE Approval documents must be PDF files only. Please upload a PDF and try again.'
      };
    }

    // ── 4. Open sheet and find header positions ────────────────────────────
    const ss      = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    const sheet   = ss.getSheetByName(CONFIG.DATA_SHEET);
    if (!sheet)   return { success: false, message: 'Data sheet not found.' };

    const lastCol = sheet.getLastColumn();
    const lastRow = sheet.getLastRow();
    if (lastRow < 2) return { success: false, message: 'No staff data found.' };

    const headers = sheet.getRange(1, 1, 1, lastCol).getValues()[0];

    const emailCol    = headers.indexOf('email_address');
    const staffNoCol  = headers.indexOf('staff_no');
    const fullNameCol = headers.indexOf('full_name');
    const fieldCol    = headers.indexOf(fieldName);

    if (emailCol    === -1) return { success: false, message: '"email_address" column not found.' };
    if (staffNoCol  === -1) return { success: false, message: '"staff_no" column not found.' };
    if (fullNameCol === -1) return { success: false, message: '"full_name" column not found.' };
    if (fieldCol    === -1) return { success: false, message: 'Unknown field column: ' + fieldName };

    // ── 5. Locate the caller's row ─────────────────────────────────────────
    const emailValues = sheet
      .getRange(2, emailCol + 1, lastRow - 1, 1)
      .getValues();

    let userRow = -1;
    for (let i = 0; i < emailValues.length; i++) {
      if (String(emailValues[i][0] || '').trim().toLowerCase() === email.toLowerCase()) {
        userRow = i + 2;
        break;
      }
    }

    if (userRow === -1) return { success: false, message: 'User not found in data sheet.' };

    // ── 6. Re-read the full row fresh ──────────────────────────────────────
    //   updateUserData (passport_no, passport_expiry, etc.) runs BEFORE
    //   uploadFile in the confirmSave flow. Reading fresh here ensures the
    //   notification email always contains the latest saved values.
    const freshRow = sheet.getRange(userRow, 1, 1, lastCol).getValues()[0];
    const userData  = {};
    headers.forEach((h, i) => {
      if (h) userData[String(h).trim()] = freshRow[i] !== undefined ? freshRow[i] : '';
    });

    const staffNo  = String(userData['staff_no']  || '').trim();
    const fullName = String(userData['full_name'] || '').trim();

    if (!staffNo) return { success: false, message: 'Staff number is empty — cannot determine upload folder.' };

    // ── 7. Validate UPLOAD_CONFIG entry ───────────────────────────────────
    const uploadConfig = UPLOAD_CONFIG[fieldName];
    if (!uploadConfig) return { success: false, message: 'No upload config for field: ' + fieldName };

    // ── 8. Resolve (or create) the staff Drive folder ──────────────────────
    let staffFolder = findStaffFolder(CONFIG.STAFF_FOLDER_ID, staffNo);
    if (!staffFolder) {
      console.log('Staff folder not found — creating for: ' + staffNo);
      staffFolder = createStaffFolderStructure(CONFIG.STAFF_FOLDER_ID, staffNo, fullName);
      try { staffFolder.addEditor(email); } catch (shareErr) {
        console.error('Could not share staff folder with user: ' + shareErr.toString());
      }
      const folderLinkCol = headers.indexOf('folder_link');
      if (folderLinkCol !== -1) {
        sheet.getRange(userRow, folderLinkCol + 1).setValue(staffFolder.getUrl());
      }
    }

    // ── 9. Get or create the document-type subfolder ───────────────────────
    const subfolder = getOrCreateSubfolder(staffFolder, uploadConfig.subfolder);

    // ── 10. Build a clean, descriptive filename ────────────────────────────
    const documentNumber = String(userData[uploadConfig.numberField] || '').trim();
    const ext            = resolvedMime === 'application/pdf' ? 'pdf'
                         : resolvedMime === 'image/png'       ? 'png'
                         : resolvedMime === 'image/jpeg'      ? 'jpg'
                         : resolvedMime === 'image/gif'       ? 'gif'
                         : resolvedMime === 'image/webp'      ? 'webp'
                         : resolvedMime === 'image/heic'      ? 'heic'
                         : fileName.split('.').pop().toLowerCase() || 'bin';
    const newFileName    = generateFileName(
      fullName,
      documentNumber,
      uploadConfig.documentType,
      'file.' + ext
    );

    // ── 11. Supersede any previous file of the same type ──────────────────
    markOldFilesAsSuperseded(subfolder, uploadConfig.documentType, fullName);

    // ── 12. Decode and write the file to Drive ─────────────────────────────
    const decodedBytes = Utilities.base64Decode(cleanBase64);
    const blob         = Utilities.newBlob(decodedBytes, resolvedMime, newFileName);
    const driveFile    = subfolder.createFile(blob);

    // Make viewable by anyone with link — falls back gracefully on Shared Drives
    try {
      driveFile.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);
    } catch (shareErr) {
      console.warn('setSharing skipped (Shared Drive restriction): ' + shareErr.toString());
      // Fallback: at minimum ensure the uploading user can view their own file
      try { driveFile.addViewer(email); } catch (_) {}
    }

    const fileUrl = driveFile.getUrl();
    console.log('File uploaded: ' + newFileName + ' → ' + uploadConfig.subfolder + ' | ' + fileUrl);

    // ── 13. Persist the Drive URL back into the data sheet ─────────────────
    sheet.getRange(userRow, fieldCol + 1).setValue(fileUrl);
    const userKey = 'profinit_' + email.toLowerCase().replace(/[^a-z0-9]/g, '_');
    cacheInvalidate(userKey);

    // ── 14. Passport-specific notification email ───────────────────────────
    if (fieldName === 'passport_pdf_link') {
      console.log('Passport upload detected — firing notification email for staffNo=' + staffNo);

      var passportExpiry = String(userData['passport_expiry'] || '').trim();
      if (passportExpiry) {
        try {
          var expiryDate = new Date(passportExpiry);
          if (!isNaN(expiryDate.getTime())) {
            passportExpiry = Utilities.formatDate(
              expiryDate, Session.getScriptTimeZone(), 'yyyy-MM-dd'
            );
          }
        } catch (_) { /* keep original string */ }
      }

      var html;
      try {
        html = HtmlService.createHtmlOutputFromFile('passportEmailTemplate').getContent();
        console.log('Passport email template loaded, length=' + html.length);
      } catch (templateErr) {
        console.error('passportEmailTemplate load FAILED: ' + templateErr.toString());
        return { success: true, url: fileUrl, fileName: newFileName };
      }

      html = html
        .replace(/{{name}}/g,           fullName)
        .replace(/{{staffNo}}/g,        staffNo)
        .replace(/{{designation}}/g,    String(userData['designation']  || '').trim())
        .replace(/{{nationality}}/g,    String(userData['nationality']  || '').trim())
        .replace(/{{passportNo}}/g,     String(userData['passport_no']  || '').trim())
        .replace(/{{passportExpiry}}/g, passportExpiry);

      var attachments = [];
      try {
        var attachBlob = driveFile.getBlob();
        attachBlob.setName(newFileName);
        attachments = [attachBlob];
        console.log('Attachment ready: ' + newFileName + ' (' + attachBlob.getContentType() + ', ' + attachBlob.getBytes().length + ' bytes)');
      } catch (blobErr) {
        console.error('Could not create attachment blob: ' + blobErr.toString());
      }

      try {
        GmailApp.sendEmail(
          PASSPORT_NOTIFY_RECIPIENTS.join(','),
          PASSPORT_NOTIFY_SUBJECT,
          'Passport document updated for ' + fullName + ' (' + staffNo + ').',
          { htmlBody: html, name: 'ADE KUL LMS', attachments: attachments }
        );
        console.log('Passport notification email sent for staffNo=' + staffNo);
      } catch (mailErr) {
        console.error('GmailApp.sendEmail FAILED: ' + mailErr.toString());
      }
    }

    return { success: true, url: fileUrl, fileName: newFileName };

  } catch (e) {
    console.error('uploadFile FAILED: ' + e.toString());
    return { success: false, message: e.toString() };
  }
}

/**
 * Saves a base64 image to a Drive subfolder and returns the file URL.
 */
function savePictureToSubfolder(base64Data, staffFolder, subfolderName, fileName) {
  if (!base64Data) {
    console.log('No base64 data provided for: ' + fileName);
    return '';
  }

  try {
    const matches = base64Data.match(/^data:(.+);base64,(.+)$/);
    if (!matches) { console.error('Invalid base64 format for: ' + fileName); return ''; }

    const contentType = matches[1];
    const cleanBase64 = matches[2].replace(/[\r\n]/g, '');
    if (!cleanBase64.length) { console.error('Empty base64 for: ' + fileName); return ''; }

    console.log('Base64 length: ' + cleanBase64.length);

    const decodedData = Utilities.base64Decode(cleanBase64);
    if (!decodedData || !decodedData.length) {
      console.error('Failed to decode base64 for: ' + fileName); return '';
    }

    console.log('Decoded size: ' + decodedData.length + ' bytes');

    const safeFileName = fileName
      .replace(/[<>:"/\\|?*]/g, '')
      .replace(/\s+/g, '_')
      .substring(0, 100);

    console.log('Safe filename: ' + safeFileName);

    const blob      = Utilities.newBlob(decodedData, contentType, safeFileName);
    const subfolder = getOrCreateSubfolder(staffFolder, subfolderName);

    const lastDash = safeFileName.lastIndexOf('-');
    const lastDot  = safeFileName.lastIndexOf('.');
    const docType  = (lastDash !== -1 && lastDot !== -1) ? safeFileName.substring(lastDash + 1, lastDot) : 'Document';
    const namePart = safeFileName.split('_')[0] || 'Unknown';

    markOldFilesAsSuperseded(subfolder, docType, namePart);

    console.log('Creating file in Drive...');
    const file = subfolder.createFile(blob);
    console.log('File created with ID: ' + file.getId());

    try {
      file.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);
      console.log('Sharing permissions set');
    } catch (shareError) {
      console.error('Error setting sharing: ' + shareError.toString());
    }

    const fileUrl = file.getUrl();
    console.log('Uploaded: ' + safeFileName + ' → ' + subfolderName + ' | ' + fileUrl);
    return fileUrl;

  } catch (e) {
    console.error('Error saving picture ' + fileName + ':', e.toString());
    return '';
  }
}


// ═════════════════════════════════════════════════════════════════════════════
//  DATE / YEAR CALCULATIONS
// ═════════════════════════════════════════════════════════════════════════════

function calculateYearsBetweenDates(startDate, endDate) {
  if (!startDate || !endDate) return null;
  const start = new Date(startDate);
  const end   = new Date(endDate);
  if (isNaN(start.getTime()) || isNaN(end.getTime())) return null;
  const diffYears = (end - start) / (365.25 * 24 * 60 * 60 * 1000);
  return diffYears >= 0 ? diffYears.toFixed(1) : null;
}


// ═════════════════════════════════════════════════════════════════════════════
//  ADMIN FUNCTIONS
// ═════════════════════════════════════════════════════════════════════════════

/**
 * Returns all registered email addresses.
 * Only callable by the admin user.
 */
function getAllUserEmails() {
  const caller = Session.getActiveUser().getEmail();
  if (caller.toLowerCase() !== ADMIN_EMAIL_GAS.toLowerCase()) throw new Error('Access denied.');

  try {
    const ss    = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    const sheet = ss.getSheetByName(CONFIG.DATA_SHEET);
    if (!sheet || sheet.getLastRow() < 2) return [];

    const headers  = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0];
    const emailCol = headers.indexOf('email_address');
    if (emailCol === -1) return [];

    return sheet.getRange(2, emailCol + 1, sheet.getLastRow() - 1, 1)
      .getValues().flat()
      .map(v => String(v).trim())
      .filter(v => v && v.indexOf('@') !== -1)
      .sort();
  } catch (e) {
    console.error('getAllUserEmails error:', e);
    return [];
  }
}

/**
 * Returns full profile data for any registered user by email.
 * Only callable by the admin user.
 */
function getUserDataByEmail(targetEmail) {
  const caller = Session.getActiveUser().getEmail();
  if (caller.toLowerCase() !== ADMIN_EMAIL_GAS.toLowerCase()) throw new Error('Access denied.');
  if (!targetEmail) return { status: 'error', message: 'No email provided.' };

  try {
    const ss    = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    const sheet = ss.getSheetByName(CONFIG.DATA_SHEET);
    if (!sheet || sheet.getLastRow() < 2) return { status: 'not_registered', email: targetEmail };

    const headers  = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0];
    const emailCol = headers.indexOf('email_address');
    if (emailCol === -1) return { status: 'not_registered', email: targetEmail };

    const allData = sheet.getRange(2, 1, sheet.getLastRow() - 1, sheet.getLastColumn()).getValues();

    for (let i = 0; i < allData.length; i++) {
      if (String(allData[i][emailCol]).trim().toLowerCase() === targetEmail.trim().toLowerCase()) {
        const userData = {};
        headers.forEach((header, index) => {
          if (header) {
            let value = allData[i][index];
            if (value instanceof Date) value = Utilities.formatDate(value, Session.getScriptTimeZone(), 'yyyy-MM-dd');
            userData[header] = value || '';
          }
        });
        return { status: 'registered', email: targetEmail, data: userData, headers: headers };
      }
    }

    return { status: 'not_registered', email: targetEmail };

  } catch (e) {
    console.error('getUserDataByEmail error:', e);
    return { status: 'error', message: e.toString() };
  }
}


// ═════════════════════════════════════════════════════════════════════════════
//  DISCIPLINARY RECORDS
// ═════════════════════════════════════════════════════════════════════════════

/**
 * Reads the "Disciplinary" sheet and returns rows matching the given staffNo.
 *
 * Sheet columns:
 *   Reference No. | Date | Name | Staff No | Designation | Section |
 *   Reason | Issued By | Reference | Action | Google Doc Link
 *
 * Returns an array of plain objects with only the display fields needed by
 * the frontend table/stack view.
 */
function getDisciplinaryRecords(staffNo) {
  if (!staffNo) return [];

  try {
    const ss    = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    const sheet = ss.getSheetByName('disciplinary');
    if (!sheet || sheet.getLastRow() < 2) return [];

    const lastCol = sheet.getLastColumn();
    const headers = sheet.getRange(1, 1, 1, lastCol).getValues()[0]
      .map(h => String(h).trim().toLowerCase());

    const colIdx = {
      referenceNo:   headers.indexOf('reference no.'),
      date:          headers.indexOf('date'),
      name:          headers.indexOf('name'),
      staffNo:       headers.indexOf('staff no'),
      designation:   headers.indexOf('designation'),
      section:       headers.indexOf('section'),
      type:          headers.indexOf('type'),
      reason:        headers.indexOf('reason'),
      issuedBy:      headers.indexOf('issued by'),
      reference:     headers.indexOf('reference'),
      action:        headers.indexOf('action'),
      googleDocLink: headers.indexOf('google doc link')
    };

    // Positional fallbacks matching sheet column order:
    // Reference No. | Date | Name | Staff No | Designation | Section | Type | Reason | Issued By | Reference | Action | Google Doc Link
    if (colIdx.referenceNo   === -1) colIdx.referenceNo   = 0;
    if (colIdx.date          === -1) colIdx.date          = 1;
    if (colIdx.name          === -1) colIdx.name          = 2;
    if (colIdx.staffNo       === -1) colIdx.staffNo       = 3;
    if (colIdx.designation   === -1) colIdx.designation   = 4;
    if (colIdx.section       === -1) colIdx.section       = 5;
    if (colIdx.type          === -1) colIdx.type          = 6;
    if (colIdx.reason        === -1) colIdx.reason        = 7;
    if (colIdx.issuedBy      === -1) colIdx.issuedBy      = 8;
    if (colIdx.reference     === -1) colIdx.reference     = 9;
    if (colIdx.action        === -1) colIdx.action        = 10;
    if (colIdx.googleDocLink === -1) colIdx.googleDocLink = 11;

    const data          = sheet.getRange(2, 1, sheet.getLastRow() - 1, lastCol).getValues();
    const targetStaffNo = String(staffNo).trim().toLowerCase();
    const results       = [];

    for (let i = 0; i < data.length; i++) {
      const rowStaffNo = String(data[i][colIdx.staffNo] || '').trim().toLowerCase();
      if (!rowStaffNo || rowStaffNo !== targetStaffNo) continue;

      let dateVal = data[i][colIdx.date];
      dateVal = dateVal instanceof Date
        ? Utilities.formatDate(dateVal, Session.getScriptTimeZone(), 'dd MMM yyyy')
        : String(dateVal || '').trim();

      results.push({
        referenceNo:   String(data[i][colIdx.referenceNo]   || '').trim(),
        staffNo: String(data[i][colIdx.staffNo] || '').trim(),
        date:          dateVal,
        name:          String(data[i][colIdx.name]          || '').trim(),
        designation:   String(data[i][colIdx.designation]   || '').trim(),
        section:       String(data[i][colIdx.section]       || '').trim(),
        type:          String(data[i][colIdx.type]          || '').trim(),
        reason:        String(data[i][colIdx.reason]        || '').trim(),
        issuedBy:      String(data[i][colIdx.issuedBy]      || '').trim(),
        reference:     String(data[i][colIdx.reference]     || '').trim(),
        action:        String(data[i][colIdx.action]        || '').trim(),
        googleDocLink: String(data[i][colIdx.googleDocLink] || '').trim()
      });
    }

    return results;

  } catch (e) {
    console.error('getDisciplinaryRecords error:', e);
    return [];
  }
}

/**
 * Checks user access level for the landing page router.
 * Returns:
 *   { status: 'role_access', email }    → show landing with Dashboard + Profile buttons
 *   { status: 'registered', email }     → redirect directly to profile
 *   { status: 'not_registered', email } → redirect to registration
 *   { status: 'invalid_domain', email } → show error
 */
function checkUserAccess() {
  const email = Session.getActiveUser().getEmail();

  if (!email || !email.toLowerCase().endsWith('@airasia.com')) {
    return { status: 'invalid_domain', email: email };
  }

  try {
    const ss = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);

    // ── Check Role sheet (column A, from A2 down) ──────────────────────────
    const roleSheet = ss.getSheetByName('Role');
    if (roleSheet && roleSheet.getLastRow() >= 2) {
      const roleEmails = roleSheet.getRange('A2:A' + roleSheet.getLastRow())
        .getValues().flat()
        .map(v => String(v).trim().toLowerCase())
        .filter(v => v && v.indexOf('@') !== -1);

      if (roleEmails.indexOf(email.toLowerCase()) !== -1) {
        return { status: 'role_access', email: email };
      }
    }

    // ── Check Data sheet ───────────────────────────────────────────────────
    const dataSheet = ss.getSheetByName(CONFIG.DATA_SHEET);
    if (dataSheet && dataSheet.getLastRow() >= 2) {
      const headers     = dataSheet.getRange(1, 1, 1, dataSheet.getLastColumn()).getValues()[0];
      const emailColIdx = headers.indexOf('email_address');
      if (emailColIdx !== -1) {
        const emails = dataSheet.getRange(2, emailColIdx + 1, dataSheet.getLastRow() - 1, 1)
          .getValues().flat()
          .map(v => String(v).trim().toLowerCase());
        if (emails.indexOf(email.toLowerCase()) !== -1) {
          return { status: 'registered', email: email };
        }
      }
    }

    return { status: 'not_registered', email: email };

  } catch (err) {
    console.error('checkUserAccess error:', err);
    return { status: 'error', email: email, message: err.toString() };
  }
}

// ── Absence Records ──────────────────────────────────────────────────────────

function getAbsenceRecords(staffNo) {
  try {
    var ss = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    var sheet = ss.getSheetByName('absence');
    if (!sheet) return [];

    var lastRow = sheet.getLastRow();
    if (lastRow < 2) return [];

    var data = sheet.getRange(1, 1, lastRow, sheet.getLastColumn()).getValues();
    var headers = data[0].map(function(h) {
      return String(h || '').trim().toLowerCase().replace(/\s+/g, '_');
    });

    // Find columns — use positional fallback matching the defined header order:
    // control_number | submission_timestamp | email_address | full_name | staff_no |
    // designation | start_date | start_year | end_date | end_year |
    // days | type | remarks | workday_submission | immediate_superior
    var colIdx = {
      controlNumber:     headers.indexOf('control_number'),
      staffNo:           headers.indexOf('staff_no'),
      startDate:         headers.indexOf('start_date'),
      startYear:         headers.indexOf('start_year'),
      endDate:           headers.indexOf('end_date'),
      days:              headers.indexOf('days'),
      type:              headers.indexOf('type'),
      remarks:           headers.indexOf('remarks'),
      immediateSuperior: headers.indexOf('immediate_superior')
    };

    if (colIdx.controlNumber === -1) colIdx.controlNumber = 0;
    if (colIdx.staffNo       === -1) colIdx.staffNo       = 4;
    if (colIdx.startDate     === -1) colIdx.startDate     = 6;
    if (colIdx.startYear     === -1) colIdx.startYear     = 7;
    if (colIdx.endDate       === -1) colIdx.endDate       = 8;
    if (colIdx.days          === -1) colIdx.days          = 10;
    if (colIdx.type          === -1) colIdx.type          = 11;
    if (colIdx.remarks       === -1) colIdx.remarks       = 12;
    if (colIdx.immediateSuperior === -1) colIdx.immediateSuperior = 14;

    var results = [];
    for (var i = 1; i < data.length; i++) {
      var row = data[i];
      var rowStaffNo = String(row[colIdx.staffNo] || '').trim();
      if (rowStaffNo !== String(staffNo).trim()) continue;

      var startRaw = row[colIdx.startDate];
      var endRaw   = row[colIdx.endDate];

      // Handle both stored-as-string (yyyy-mm-dd) and stored-as-Date
      var startStr = '', endStr = '', yearStr = '';
      if (startRaw instanceof Date) {
        startStr = Utilities.formatDate(startRaw, Session.getScriptTimeZone(), 'dd MMM yyyy');
        yearStr  = Utilities.formatDate(startRaw, Session.getScriptTimeZone(), 'yyyy');
      } else {
        startStr = String(startRaw || '');
        yearStr  = startStr.length >= 4 ? startStr.substring(0, 4) : '';
      }

      if (endRaw instanceof Date) {
        endStr = Utilities.formatDate(endRaw, Session.getScriptTimeZone(), 'dd MMM yyyy');
      } else {
        endStr = String(endRaw || '');
      }

      // Prefer the stored start_year column if available
      var storedYear = String(row[colIdx.startYear] || '').trim();
      if (storedYear) yearStr = storedYear;

      results.push({
        controlNumber:     String(row[colIdx.controlNumber]     || '').trim(),
        startDate:         startStr,
        endDate:           endStr,
        startYear:         yearStr,
        days:              String(row[colIdx.days]              || '').trim(),
        type:              String(row[colIdx.type]              || '').trim(),
        remarks:           String(row[colIdx.remarks]           || '').trim(),
        immediateSuperior: String(row[colIdx.immediateSuperior] || '').trim()
      });
    }

    return results;
  } catch (e) {
    throw new Error('getAbsenceRecords: ' + e.toString());
  }
}

function getImmediateSuperiorList() {
  try {
    var ss = SpreadsheetApp.getActiveSpreadsheet();
    var roleSheet = ss.getSheetByName('Role');
    if (!roleSheet) return [];
    var lastRow = roleSheet.getLastRow();
    if (lastRow < 2) return [];
    var values = roleSheet.getRange('B2:B' + lastRow).getValues();
    var list = [];
    for (var i = 0; i < values.length; i++) {
      var val = String(values[i][0] || '').trim();
      if (val && list.indexOf(val) === -1) list.push(val);
    }
    return list.sort();
  } catch (e) { return []; }
}

function submitAbsence(formData) {
  try {
    var ss = SpreadsheetApp.getActiveSpreadsheet();
    var sheet = ss.getSheetByName('absence');
    if (!sheet) return { success: false, message: 'Absence sheet not found' };

    var staffNo   = String(formData.staffNo   || '').trim();
    var startYear = String(formData.startYear || '').trim();

    // ── Running number: count existing rows for this staff + year ──
    var lastRow = sheet.getLastRow();
    var runningNo = 1;
    if (lastRow >= 2) {
      var existingRefs = sheet.getRange(2, 1, lastRow - 1, 1).getValues();
      var prefix = staffNo + '-' + startYear + '-';
      for (var i = 0; i < existingRefs.length; i++) {
        var ref = String(existingRefs[i][0] || '');
        if (ref.indexOf(prefix) === 0) {
          var num = parseInt(ref.replace(prefix, ''), 10);
          if (!isNaN(num) && num >= runningNo) runningNo = num + 1;
        }
      }
    }
    var controlNumber = staffNo + '-' + startYear + '-' + runningNo;

    var tz = Session.getScriptTimeZone();
    var startDateObj = formData.startDate || '';
    var endDateObj   = formData.endDate   || '';
    var endYear      = endDateObj ? endDateObj.substring(0, 4) : startYear;

    sheet.appendRow([
      controlNumber,                              // control_number
      new Date(),                                 // submission_timestamp
      Session.getActiveUser().getEmail(),         // email_address
      formData.staffName   || '',                 // full_name
      staffNo,                                    // staff_no
      formData.designation || '',                 // designation
      startDateObj,                               // start_date
      startYear,                                  // start_year
      endDateObj,                                 // end_date
      endYear,                                    // end_year
      formData.days        || '',                 // days
      formData.type        || '',                 // type
      formData.remarks     || '',                 // remarks
      'Submitted',                                // workday_submission
      formData.immediateSuperior || ''            // immediate_superior
    ]);

    cacheInvalidate(CACHE_KEYS.absence);
    
    return { success: true, controlNumber: controlNumber };
  } catch (e) {
    return { success: false, message: e.toString() };
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  PASSPORT NOTIFICATION EMAIL
// ═════════════════════════════════════════════════════════════════════════════

const PASSPORT_NOTIFY_RECIPIENTS = [
  'manrajsingh@airasia.com',
  'mohamednoorhaimi@airasia.com',
  'syazwanmdsaad@airasia.com',
  'limhongkhai@airasia.com'
];

const PASSPORT_NOTIFY_SUBJECT = 'LMS Staff Passport Updates Notification';

/**
 * Sends a passport update notification using the passportEmailTemplate HTML file.
 *
 * @param {Object} p  Plain object with keys:
 *   name, staffNo, designation, nationality, passportNo, passportExpiry
 */
function sendPassportNotificationEmail(p) {
  console.log('>>> sendPassportNotificationEmail CALLED for staffNo=' + p.staffNo + ', passportNo=' + p.passportNo);

  try {
    if (!p.passportNo) {
      console.log('Skipping — passportNo is empty');
      return;
    }

    // ── Format passport expiry ───────────────────────────────────────────
    var formattedExpiry = '';
    if (p.passportExpiry) {
      try {
        var expiryDate = new Date(p.passportExpiry);
        formattedExpiry = !isNaN(expiryDate.getTime())
          ? Utilities.formatDate(expiryDate, Session.getScriptTimeZone(), 'yyyy-MM-dd')
          : String(p.passportExpiry);
      } catch (dateErr) {
        formattedExpiry = String(p.passportExpiry);
      }
    }

    // ── Load HTML template ───────────────────────────────────────────────
    var html;
    try {
      html = HtmlService.createHtmlOutputFromFile('passportEmailTemplate').getContent();
      console.log('Template loaded OK, length=' + html.length);
    } catch (templateErr) {
      console.error('Template load FAILED: ' + templateErr.toString());
      return;
    }

    html = html
      .replace(/{{name}}/g,           p.name           || '')
      .replace(/{{staffNo}}/g,        p.staffNo        || '')
      .replace(/{{designation}}/g,    p.designation    || '')
      .replace(/{{nationality}}/g,    p.nationality    || '')
      .replace(/{{passportNo}}/g,     p.passportNo     || '')
      .replace(/{{passportExpiry}}/g, formattedExpiry);

    // ── Build email options ──────────────────────────────────────────────
    var emailOptions = {
      htmlBody: html,
      name:     'ADE KUL LMS'
    };

    // ── Attach passport file ─────────────────────────────────────────────
    if (p.passportFileUrl) {
      try {
        var file = getFileFromUrl(p.passportFileUrl);
        if (file) {
          // ✅ Use getBlob() — NOT getAs() — for uploaded Drive files
          var blob = file.getBlob();
          // Give the attachment a clean filename
          var safeFileName = 'Passport_' + (p.staffNo || 'unknown') + '_' + (p.passportNo || '') + '.' +
            (blob.getContentType() === 'application/pdf' ? 'pdf' : 'jpg');
          blob.setName(safeFileName);
          emailOptions.attachments = [blob];
          console.log('Attachment ready: ' + safeFileName + ' (' + blob.getContentType() + ')');
        } else {
          console.warn('getFileFromUrl returned null for: ' + p.passportFileUrl);
        }
      } catch (attachErr) {
        // ✅ Log clearly so you can see it in Executions
        console.error('Attachment FAILED: ' + attachErr.toString());
        // Continue — send email without attachment rather than failing silently
      }
    } else {
      console.warn('passportFileUrl not provided — email will have no attachment');
    }

    console.log('Sending to: ' + PASSPORT_NOTIFY_RECIPIENTS.join(', '));
    console.log('Has attachment: ' + (emailOptions.attachments ? 'YES' : 'NO'));

    GmailApp.sendEmail(
      PASSPORT_NOTIFY_RECIPIENTS.join(','),
      PASSPORT_NOTIFY_SUBJECT,
      'Passport update for ' + (p.name || '') + ' (' + (p.staffNo || '') + ').',
      emailOptions
    );

    console.log('Email sent successfully for staffNo=' + p.staffNo);

  } catch (e) {
    console.error('sendPassportNotificationEmail FAILED: ' + e.toString());
  }
}

// ── Helper function to extract file from Drive URL ──────────────────────
function getFileFromUrl(url) {
  if (!url) return null;
  try {
    var fileId = null;
    
    // Format: https://drive.google.com/file/d/FILE_ID/view
    var match = url.match(/\/file\/d\/([^\/]+)/);
    if (match) fileId = match[1];
    
    // Format: https://drive.google.com/open?id=FILE_ID
    if (!fileId) {
      match = url.match(/[?&]id=([^&]+)/);
      if (match) fileId = match[1];
    }
    
    if (fileId) return DriveApp.getFileById(fileId);
    
    return null;
  } catch (e) {
    console.error('getFileFromUrl error: ' + e.toString());
    return null;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  DASHBOARD DATA
// ═════════════════════════════════════════════════════════════════════════════

/**
 * Returns all staff rows for the Dashboard.
 * Access: ADMIN_EMAIL_GAS  +  anyone listed in Role sheet column A.
 */
function getDashboardData() {
  const ss    = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
  const email = Session.getActiveUser().getEmail().toLowerCase();

  // ── Access gate ──────────────────────────────────────────────────────────
  let hasAccess = (email === ADMIN_EMAIL_GAS.toLowerCase());
  if (!hasAccess) {
    const roleSheet = ss.getSheetByName('Role');
    if (roleSheet && roleSheet.getLastRow() >= 2) {
      const roleEmails = roleSheet
        .getRange('A2:A' + roleSheet.getLastRow())
        .getValues().flat()
        .map(v => String(v || '').trim().toLowerCase())
        .filter(v => v.includes('@'));
      if (roleEmails.includes(email)) hasAccess = true;
    }
  }
  if (!hasAccess) throw new Error('Access denied. Contact the administrator.');

  // ── Try cache first ──────────────────────────────────────────────────────
  const cached = cacheRead(CACHE_KEYS.dashboard);
  if (cached) return cached;

  // ── Cache miss — read from sheet ─────────────────────────────────────────
  const sheet = ss.getSheetByName(CONFIG.DATA_SHEET);
  if (!sheet || sheet.getLastRow() < 2) return { rows: [] };

  const tz      = Session.getScriptTimeZone();
  const lastRow = sheet.getLastRow();
  const lastCol = sheet.getLastColumn();

  // Single batch read — headers + all data in one Sheets API call
  const allValues = sheet.getRange(1, 1, lastRow, lastCol).getValues();
  const headers   = allValues[0];
  const rawData   = allValues.slice(1);

  const rows = rawData
    .map(row => {
      const obj = {};
      headers.forEach((h, i) => {
        if (!h) return;
        let val = row[i];
        if (val instanceof Date && !isNaN(val.getTime())) {
          val = Utilities.formatDate(val, tz, 'yyyy-MM-dd');
        }
        obj[String(h).trim()] = (val === null || val === undefined) ? '' : String(val);
      });
      return obj;
    })
    .filter(r => r.email_address && r.email_address.trim());

  const result = { rows };
  cacheWrite(CACHE_KEYS.dashboard, result);
  return result;
}

// ═════════════════════════════════════════════════════════════════════════════
//  DASHBOARD — ALL ABSENCE DATA
//  Add this function to Code.gs (alongside getDashboardData)
//
//  Called by: Dashboard.html → google.script.run.getAllAbsenceData()
//  Access:    Same gate as getDashboardData — admin + Role sheet col A
// ═════════════════════════════════════════════════════════════════════════════

function getAllAbsenceData() {
  const ss    = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
  const email = Session.getActiveUser().getEmail().toLowerCase();

  // ── Access gate ──────────────────────────────────────────────────────────
  let hasAccess = (email === ADMIN_EMAIL_GAS.toLowerCase());
  if (!hasAccess) {
    const roleSheet = ss.getSheetByName('Role');
    if (roleSheet && roleSheet.getLastRow() >= 2) {
      const roleEmails = roleSheet
        .getRange('A2:A' + roleSheet.getLastRow())
        .getValues().flat()
        .map(v => String(v || '').trim().toLowerCase())
        .filter(v => v.includes('@'));
      if (roleEmails.includes(email)) hasAccess = true;
    }
  }
  if (!hasAccess) throw new Error('Access denied. Contact the administrator.');

  // ── Try cache first ──────────────────────────────────────────────────────
  const cached = cacheRead(CACHE_KEYS.absence);
  if (cached) return cached;

  // ── Cache miss — read from sheet ─────────────────────────────────────────
  const sheet = ss.getSheetByName('absence');
  if (!sheet || sheet.getLastRow() < 2) return { rows: [] };

  const tz      = Session.getScriptTimeZone();
  const lastRow = sheet.getLastRow();
  const lastCol = sheet.getLastColumn();

  // Single batch read
  const allValues = sheet.getRange(1, 1, lastRow, lastCol).getValues();
  const rawHdr    = allValues[0];
  const rawData   = allValues.slice(1);

  const headers = rawHdr.map(h =>
    String(h || '').trim().toLowerCase().replace(/\s+/g, '_')
  );

  function col(name, fallback) {
    const i = headers.indexOf(name);
    return i !== -1 ? i : fallback;
  }
  const c = {
    controlNumber:     col('control_number',    0),
    fullName:          col('full_name',          3),
    staffNo:           col('staff_no',           4),
    designation:       col('designation',        5),
    startDate:         col('start_date',         6),
    startYear:         col('start_year',         7),
    endDate:           col('end_date',           8),
    days:              col('days',               10),
    type:              col('type',               11),
    remarks:           col('remarks',            12),
    immediateSuperior: col('immediate_superior', 14)
  };

  function fmtDate(val) {
    if (!val) return '';
    if (val instanceof Date && !isNaN(val.getTime())) {
      return Utilities.formatDate(val, tz, 'yyyy-MM-dd');
    }
    return String(val).trim();
  }

  const rows = rawData
    .filter(row => row[c.staffNo] || row[c.fullName])
    .map(row => ({
      control_number:     String(row[c.controlNumber]     || '').trim(),
      full_name:          String(row[c.fullName]          || '').trim(),
      staff_no:           String(row[c.staffNo]           || '').trim(),
      designation:        String(row[c.designation]       || '').trim(),
      start_date:         fmtDate(row[c.startDate]),
      start_year:         String(row[c.startYear]         || '').trim(),
      end_date:           fmtDate(row[c.endDate]),
      days:               String(row[c.days]              || '').trim(),
      type:               String(row[c.type]              || '').trim(),
      remarks:            String(row[c.remarks]           || '').trim(),
      immediate_superior: String(row[c.immediateSuperior] || '').trim()
    }));

  const result = { rows };
  cacheWrite(CACHE_KEYS.absence, result);
  return result;
}

// ═════════════════════════════════════════════════════════════════════════════
//  STAFF CHANGE — append to change_history / update data status
//  Add this function to Code.gs
//
//  change_history sheet headers:
//  Staff No | Email Address | Full Name | Change | Date Change |
//  Current Designation | Current Section | Current Shift |
//  To Designation | To Section | To Shift
// ═════════════════════════════════════════════════════════════════════════════

function submitStaffChange(payload) {
  try {
    const ss    = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    const email = Session.getActiveUser().getEmail().toLowerCase();

    // ── Access gate (same as getDashboardData) ──────────────────────────────
    let hasAccess = (email === ADMIN_EMAIL_GAS.toLowerCase());
    if (!hasAccess) {
      const roleSheet = ss.getSheetByName('Role');
      if (roleSheet && roleSheet.getLastRow() >= 2) {
        const roleEmails = roleSheet
          .getRange('A2:A' + roleSheet.getLastRow())
          .getValues().flat()
          .map(v => String(v || '').trim().toLowerCase())
          .filter(v => v.includes('@'));
        if (roleEmails.includes(email)) hasAccess = true;
      }
    }
    if (!hasAccess) return { success: false, message: 'Access denied. Contact the administrator.' };

    const { staffNo, email: staffEmail, fullName,
            curDesig, curSection, curShift,
            changes, statusChange } = payload;

    // ── 1. Append change_history rows (one per changed field) ───────────────
    if (changes && changes.length > 0) {
      let histSheet = ss.getSheetByName('change_history');

      // Auto-create sheet with headers if it doesn't exist
      if (!histSheet) {
        histSheet = ss.insertSheet('change_history');
        const hdrs = [
          'Staff No', 'Email Address', 'Full Name', 'Change', 'Date Change',
          'Current Designation', 'Current Section', 'Current Shift',
          'To Designation', 'To Section', 'To Shift'
        ];
        histSheet.getRange(1, 1, 1, hdrs.length).setValues([hdrs]).setFontWeight('bold');
        histSheet.setFrozenRows(1);
      }

      for (const ch of changes) {
        // Only fill the Current/To column that matches the change type
        const curDesigVal   = ch.type === 'Designation' ? curDesig   : '';
        const curSectionVal = ch.type === 'Section'     ? curSection : '';
        const curShiftVal   = ch.type === 'Shift'       ? curShift   : '';
        const toDesig       = ch.type === 'Designation' ? ch.toVal   : '';
        const toSection     = ch.type === 'Section'     ? ch.toVal   : '';
        const toShift       = ch.type === 'Shift'       ? ch.toVal   : '';

        histSheet.appendRow([
          staffNo,       // Staff No
          staffEmail,    // Email Address
          fullName,      // Full Name
          ch.type,       // Change  (Designation / Section / Shift)
          ch.date,       // Date Change
          curDesigVal,   // Current Designation  — only filled for Designation changes
          curSectionVal, // Current Section       — only filled for Section changes
          curShiftVal,   // Current Shift         — only filled for Shift changes
          toDesig,       // To Designation
          toSection,     // To Section
          toShift        // To Shift
        ]);
      }
    }

    // ── 2. Update status + status_date in data sheet (Resigned / Transfer) ──
    if (statusChange) {
      const dataSheet = ss.getSheetByName(CONFIG.DATA_SHEET);
      if (!dataSheet) return { success: false, message: 'Data sheet not found.' };

      const lastCol    = dataSheet.getLastColumn();
      const headers    = dataSheet.getRange(1, 1, 1, lastCol).getValues()[0];
      const staffNoCol = headers.indexOf('staff_no');

      if (staffNoCol === -1) return { success: false, message: '"staff_no" column not found in data sheet.' };

      // Find the matching row by staff number
      const allData = dataSheet
        .getRange(2, 1, dataSheet.getLastRow() - 1, lastCol)
        .getValues();

      let targetRowIndex = -1;
      for (let i = 0; i < allData.length; i++) {
        if (String(allData[i][staffNoCol]).trim() === String(staffNo).trim()) {
          targetRowIndex = i + 2; // +2: 1-indexed + header row
          break;
        }
      }

      if (targetRowIndex === -1) {
        return { success: false, message: 'Staff No "' + staffNo + '" not found in data sheet.' };
      }

      // Update status column
      const statusCol = headers.indexOf('status');
      if (statusCol !== -1) {
        dataSheet.getRange(targetRowIndex, statusCol + 1).setValue(statusChange.reason);
      }

      // Update status_date column
      const statusDateCol = headers.indexOf('status_date');
      if (statusDateCol !== -1) {
        dataSheet.getRange(targetRowIndex, statusDateCol + 1).setValue(statusChange.date);
      }

      // Update last_update_timestamp
      const tsCol = headers.indexOf('last_update_timestamp');
      if (tsCol !== -1) {
        dataSheet.getRange(targetRowIndex, tsCol + 1).setValue(new Date());
      }

     // ── Archive to resign_transfer_records ──────────────────────────────
      if (statusChange.reason === 'Resigned' || statusChange.reason === 'Transfer') {
        archiveToResignTransferRecords(staffNo, statusChange.reason, statusChange.date);
      }
    }
    cacheInvalidate(CACHE_KEYS.dashboard);

    return { success: true };

  } catch (e) {
    console.error('submitStaffChange error:', e);
    return { success: false, message: e.toString() };
  }
}

function getAllDiscData() {
  const ss    = SpreadsheetApp.getActiveSpreadsheet();
  const email = Session.getActiveUser().getEmail().toLowerCase();

  // ── Access gate ──────────────────────────────────────────────────────────
  let hasAccess = (email === ADMIN_EMAIL_GAS.toLowerCase());
  if (!hasAccess) {
    const roleSheet = ss.getSheetByName('Role');
    if (roleSheet && roleSheet.getLastRow() >= 2) {
      const roleEmails = roleSheet
        .getRange('A2:A' + roleSheet.getLastRow())
        .getValues().flat()
        .map(v => String(v || '').trim().toLowerCase())
        .filter(v => v.includes('@'));
      if (roleEmails.includes(email)) hasAccess = true;
    }
  }
  if (!hasAccess) throw new Error('Access denied. Contact the administrator.');

  // ── Try cache first ──────────────────────────────────────────────────────
  const cached = cacheRead(CACHE_KEYS.disc);
  if (cached) return cached;

  // ── Cache miss — read from sheet ─────────────────────────────────────────
  const sheet = ss.getSheetByName('disciplinary');
  if (!sheet || sheet.getLastRow() < 2) return { rows: [] };

  const lastRow   = sheet.getLastRow();
  const lastCol   = sheet.getLastColumn();

  // Single batch read
  const allValues = sheet.getRange(1, 1, lastRow, lastCol).getValues();
  const hdr       = allValues[0].map(h =>
    String(h).trim().toLowerCase().replace(/[\s.]+/g, '_')
  );
  const rawData   = allValues.slice(1);

  const rows = rawData
    .filter(row => row.some(cell => cell !== ''))
    .map(row => {
      const obj = {};
      hdr.forEach((h, j) => {
        obj[h] = row[j] !== undefined ? String(row[j]).trim() : '';
      });
      return obj;
    });

  const result = { rows };
  cacheWrite(CACHE_KEYS.disc, result);
  return result;
}

// ── MAB Document Generator (Active Spreadsheet → PDF) ────────────────────────
// mab_new / mab_renewal sheets live in the same spreadsheet as all other data.
// Fills cells, exports that sheet as PDF, saves to Drive, then clears the cells.
//
// Cell mapping:  D19 = date,  C27 = name,  D27 = staffNo,  E27 = ic

var MAB_ROOT_FOLDER = '1awuWGnWMDKyt2yXNZ1I9xjxbuDZcHvzq';

function generateMabDocument(payload) {
  try {
    var type    = payload.type;
    var name    = payload.name    || '';
    var staffNo = payload.staffNo || '';
    var ic      = payload.ic      || '';
    var date    = payload.date    || '';

    var sheetName = (type === 'renewal') ? 'mab_renewal' : 'mab_new';
    var docLabel  = (type === 'renewal') ? 'MAB Renewal'  : 'MAB New Application';

    // ── Get the sheet from the active spreadsheet ─────────────────────────
    var ss    = SpreadsheetApp.getActiveSpreadsheet();
    var sheet = ss.getSheetByName(sheetName);
    if (!sheet) {
      return { success: false, message: 'Sheet "' + sheetName + '" not found.' };
    }

    // ── Format date as dd mmm yyyy ────────────────────────────────────────
    var dateObj    = new Date();
    var months     = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var formattedDate =
      ('0' + dateObj.getDate()).slice(-2) + ' ' +
      months[dateObj.getMonth()] + ' ' +
      dateObj.getFullYear();

    // ── Fill in the cells ─────────────────────────────────────────────────
    sheet.getRange('D19').setValue(formattedDate);
    sheet.getRange('C27').setValue(name);
    sheet.getRange('D27').setValue(staffNo);
    sheet.getRange('E27').setValue(ic);
    SpreadsheetApp.flush();

    // ── Resolve or create year subfolder ─────────────────────────────────
    var year       = String(new Date().getFullYear());
    var rootFolder = DriveApp.getFolderById(MAB_ROOT_FOLDER);
    var existing   = rootFolder.getFoldersByName(year);
    var yearFolder = existing.hasNext() ? existing.next() : rootFolder.createFolder(year);

    // ── Export just this sheet as PDF ─────────────────────────────────────
    // margins in inches: top=0, bottom=0, left=0, right=0
    var ssId    = ss.getId();
    var gid     = sheet.getSheetId();
    var pdfExportUrl =
      'https://docs.google.com/spreadsheets/d/' + ssId + '/export' +
      '?format=pdf' +
      '&gid='          + gid +       // export only this sheet
      '&size=A4' +
      '&portrait=true' +
      '&fitw=true' +                  // fit to page width
      '&sheetnames=false' +
      '&printtitle=false' +
      '&pagenumbers=false' +
      '&gridlines=false' +
      '&fzr=false' +
      '&top_margin=0' +
      '&bottom_margin=0' +
      '&left_margin=0' +
      '&right_margin=0';

    var token       = ScriptApp.getOAuthToken();
    var pdfResponse = UrlFetchApp.fetch(pdfExportUrl, {
      headers:            { Authorization: 'Bearer ' + token },
      muteHttpExceptions: true
    });

    if (pdfResponse.getResponseCode() !== 200) {
      throw new Error('PDF export failed (' + pdfResponse.getResponseCode() + ').');
    }

    // ── Save PDF to Drive ─────────────────────────────────────────────────
    var fileName = docLabel + ' - ' + name + ' (' + staffNo + ').pdf';
    var pdfBlob  = pdfResponse.getBlob().setName(fileName);
    var pdfFile  = yearFolder.createFile(pdfBlob);

    // ── Clear the cells after export so the sheet is clean for next use ───
    sheet.getRange('D19').clearContent();
    sheet.getRange('C27').clearContent();
    sheet.getRange('D27').clearContent();
    sheet.getRange('E27').clearContent();

    return {
      success: true,
      pdfUrl:  pdfFile.getUrl()
    };

  } catch (e) {
    return { success: false, message: e.message };
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  ARCHIVE TO RESIGN / TRANSFER RECORDS
//  Called whenever status is set to "Resigned" or "Transfer"
//  from either Dashboard (submitStaffChange) or Profile (updateUserData)
// ═════════════════════════════════════════════════════════════════════════════

function archiveToResignTransferRecords(staffNo, status, statusDate) {
  try {
    const ss        = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    const dataSheet = ss.getSheetByName(CONFIG.DATA_SHEET);
    if (!dataSheet || dataSheet.getLastRow() < 2) return;

    const lastCol    = dataSheet.getLastColumn();
    const headers    = dataSheet.getRange(1, 1, 1, lastCol).getValues()[0];
    const staffNoCol = headers.indexOf('staff_no');
    if (staffNoCol === -1) return;

    const allData = dataSheet.getRange(2, 1, dataSheet.getLastRow() - 1, lastCol).getValues();
    let rowData   = null;

    for (let i = 0; i < allData.length; i++) {
      if (String(allData[i][staffNoCol]).trim() === String(staffNo).trim()) {
        rowData = allData[i].map(function(val) {
          if (val instanceof Date && !isNaN(val.getTime())) {
            return Utilities.formatDate(val, Session.getScriptTimeZone(), 'yyyy-MM-dd');
          }
          return (val === null || val === undefined) ? '' : val;
        });
        break;
      }
    }

    if (!rowData) {
      console.error('archiveToResignTransferRecords: staff_no "' + staffNo + '" not found.');
      return;
    }

    // ── Get or create resign_transfer_records sheet ─────────────────────────
    let archiveSheet = ss.getSheetByName('resign_transfer_records');
    if (!archiveSheet) {
      archiveSheet = ss.insertSheet('resign_transfer_records');
      const archiveHeaders = ['status', 'status_date'].concat(headers);
      archiveSheet.getRange(1, 1, 1, archiveHeaders.length).setValues([archiveHeaders]);
      archiveSheet.getRange(1, 1, 1, archiveHeaders.length).setFontWeight('bold');
      archiveSheet.setFrozenRows(1);
    }

    // ── Append: status | status_date | [entire data row] ────────────────────
    const archiveRow = [status, statusDate].concat(rowData);
    archiveSheet.appendRow(archiveRow);

    console.log('Archived to resign_transfer_records: ' + staffNo + ' (' + status + ')');

  } catch (e) {
    console.error('archiveToResignTransferRecords error: ' + e.toString());
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  DAILY TRIGGER — Remove resigned/transferred staff from data sheet
//  Set this as a daily time-driven trigger in Apps Script
//  Deletes rows where status = Resigned|Transfer AND status_date <= today
//  Uses staff_no to locate rows (safe against row-shift when deleting multiple)
// ═════════════════════════════════════════════════════════════════════════════

function dailyRemoveResignedStaff() {
  try {
    const ss        = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    const dataSheet = ss.getSheetByName(CONFIG.DATA_SHEET);
    if (!dataSheet || dataSheet.getLastRow() < 2) return;

    const lastCol       = dataSheet.getLastColumn();
    const headers       = dataSheet.getRange(1, 1, 1, lastCol).getValues()[0];
    const staffNoCol    = headers.indexOf('staff_no');
    const statusCol     = headers.indexOf('status');
    const statusDateCol = headers.indexOf('status_date');

    if (staffNoCol === -1 || statusCol === -1 || statusDateCol === -1) {
      console.error('dailyRemoveResignedStaff: required columns not found.');
      return;
    }

    const allData = dataSheet.getRange(2, 1, dataSheet.getLastRow() - 1, lastCol).getValues();
    const today   = new Date();
    today.setHours(0, 0, 0, 0);

    // ── Collect staff numbers to remove ─────────────────────────────────────
    const staffNosToRemove = [];

    for (let i = 0; i < allData.length; i++) {
      const status = String(allData[i][statusCol] || '').trim();
      if (status !== 'Resigned' && status !== 'Transfer') continue;

      const rawDate   = allData[i][statusDateCol];
      let statusDate  = null;

      if (rawDate instanceof Date && !isNaN(rawDate.getTime())) {
        statusDate = rawDate;
      } else if (rawDate) {
        statusDate = new Date(String(rawDate));
      }

      if (!statusDate || isNaN(statusDate.getTime())) continue;

      statusDate.setHours(0, 0, 0, 0);

      // If status_date is today or in the past → staff is no longer active
      if (statusDate <= today) {
        staffNosToRemove.push(String(allData[i][staffNoCol]).trim());
      }
    }

    if (staffNosToRemove.length === 0) {
      console.log('dailyRemoveResignedStaff: no rows to remove.');
      return;
    }

    console.log('Removing ' + staffNosToRemove.length + ' staff: ' + staffNosToRemove.join(', '));

    // ── Delete rows by staff_no (reverse order to avoid row-shift issues) ───
    // Re-read fresh data each deletion cycle to be safe, but since we delete
    // bottom-up in a single pass, a single read + reverse iteration is enough.
    const freshData = dataSheet.getRange(2, 1, dataSheet.getLastRow() - 1, lastCol).getValues();

    // Build list of row numbers (1-indexed sheet rows) to delete
    const rowsToDelete = [];
    for (let i = 0; i < freshData.length; i++) {
      const sn = String(freshData[i][staffNoCol]).trim();
      if (staffNosToRemove.indexOf(sn) !== -1) {
        rowsToDelete.push(i + 2); // +2: 1-indexed + header row
      }
    }

    // Delete from bottom to top so row numbers stay valid
    rowsToDelete.sort(function(a, b) { return b - a; });

    for (let r = 0; r < rowsToDelete.length; r++) {
      dataSheet.deleteRow(rowsToDelete[r]);
    }

    console.log('dailyRemoveResignedStaff: removed ' + rowsToDelete.length + ' row(s).');

  } catch (e) {
    console.error('dailyRemoveResignedStaff error: ' + e.toString());
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  APPROVAL MATRIX DATA  — reads from CONFIG.DATA_SHEET ("data")
//  Authority/Operator codes aligned to QN-G-017 Rev 02 (05 Dec 2025)
//  Optimised: all regex / token structures pre-compiled outside row loop.
// ═════════════════════════════════════════════════════════════════════════════
function getApprovalMatrixData() {
  const ss    = SpreadsheetApp.getActiveSpreadsheet();
  const email = Session.getActiveUser().getEmail().toLowerCase();

  // ── Access gate ──────────────────────────────────────────────────────────
  let hasAccess = (email === ADMIN_EMAIL_GAS.toLowerCase());
  if (!hasAccess) {
    const roleSheet = ss.getSheetByName('Role');
    if (roleSheet && roleSheet.getLastRow() >= 2) {
      const roleEmails = roleSheet
        .getRange('A2:A' + roleSheet.getLastRow())
        .getValues().flat()
        .map(v => String(v||'').trim().toLowerCase())
        .filter(v => v.includes('@'));
      if (roleEmails.includes(email)) hasAccess = true;
    }
  }
  if (!hasAccess) throw new Error('Access denied. Contact the administrator.');

  const sheet = ss.getSheetByName(CONFIG.DATA_SHEET);
  if (!sheet || sheet.getLastRow() < 2) return { staff: [], sheetName: CONFIG.DATA_SHEET };

  // ── Single batch read ─────────────────────────────────────────────────────
  const lastCol = sheet.getLastColumn();
  const lastRow = sheet.getLastRow();
  // Read headers + all data in ONE call to minimise Sheets API round-trips
  const allValues = sheet.getRange(1, 1, lastRow, lastCol).getValues();
  const headers   = allValues[0].map(h => String(h).trim());
  const rawData   = allValues.slice(1);

  function col(name) { return headers.indexOf(name); }
  const C = {
    name:     col('full_name'),
    staffNo:  col('staff_no'),
    position: col('designation'),
    section:  col('team'),
    shift:    col('shift'),
    approNo:  col('ade_approval_no'),
    approCat: col('ade_system_code'),
    b1Appr:   col('b1_ade_approval_type'),
    b2Appr:   col('b2_ade_approval_type'),
    cAppr:    col('c_ade_approval_type'),
    aAppr:    col('a_ade_approval_type'),
    b1TR:     col('b1_type_rating'),
    b2TR:     col('b2_type_rating'),
    cTR:      col('c_type_rating'),
  };

  // ── Canonical definitions (updated to match ApprovalMatrix.html) ──────────
  const CANONICALS = [
    { id:'cgk_a320_cfm56_maa',  label:'CGK A320-200 (CFM56-5B) CAAM - MAA'          },
    { id:'cgk_a320_cfm56_iaa',  label:'CGK A320-200 (CFM56-5B) DGCA - IAA'          },
    { id:'cgk_a320_cfm56_paa',  label:'CGK A320-200 (CFM56-5B) CAAP - PAA'          },
    { id:'cgk_a320_cfm56_aac',  label:'CGK A320-200 (CFM56-5B) SSCA - AAC'          },
    { id:'cgk_a320_leap_maa',   label:'CGK A320-200 (CFM LEAP-1A) CAAM - MAA'       },
    { id:'cgk_a320_v2500',      label:'CGK A320-200 (IAE V2500)'                     },
    { id:'cgk_a321_cfm56_maa',  label:'CGK A321-200 (CFM56-5B) CAAM - MAA'          },
    { id:'cgk_a321_leap_maa',   label:'CGK A321-200NX (CFM LEAP-1A) CAAM - MAA'     },
    { id:'cgk_a330_rrt_maa',    label:'CGK A330-343 (RRT772B-60) CAAM - MAA'        },
    { id:'cgk_a330_rrt_aax',    label:'CGK A330-343 (RRT772B-60) CAAM - AAX'        },
    { id:'ab_a330_rrt_aax',     label:'AB A330-343 (RRT772B-60) CAAM - AAX'         },
    { id:'cgk_b737_cfm56',      label:'CGK B737-600/700/800/900 (CFM56)'             },
  ];

  // ── Pre-tokenise canonical labels once (avoids repeat splits per row) ─────
  function norm(s) {
    return String(s||'').toLowerCase().replace(/[\s\-]+/g,' ').trim();
  }
  const canonTokens = CANONICALS.map(ca => ({
    id:     ca.id,
    tokens: norm(ca.label).split(' ').filter(t => t.length > 1)
  }));

  // ── Operator list aligned to QN-G-017 Rev 02 ─────────────────────────────
  const ALL_OPERATORS = [
    'MAA','AAX',        // CAAM  Malaysia
    'IAA','TNU',        // DGCA  Indonesia
    'PAA',              // CAAP  Philippines
    'Scoot',            // CAAS  Singapore
    'TAA',              // CAAT  Thailand
    'HIM',              // CAAN  Nepal
    'MAI',              // DCAM  Myanmar
    'IGO',              // DGCA  India
    'AAC','KME',        // SSCA  Cambodia
    'HKJ',              // BCAA  Bermuda
    'DRK',              // BCAA  Bhutan
    'AFI',              // EASA
    'SPA',              // CAAV  Vietnam
    'Castlelake',       // ODCA  Guernsey
  ];

  // ── Pre-compile one regex per operator (outside every loop) ───────────────
  const DASH = '[\\s\\-\u2013\u2014]+';
  const operatorRegexes = ALL_OPERATORS.map(opId => ({
    id:  opId,
    re:  new RegExp(DASH + opId.replace(/[.*+?^${}()|[\]\\]/g,'\\$&') + '\\s*$', 'i'),
    low: opId.toLowerCase()
  }));

  // ── Pre-compile parseApprStr regexes ──────────────────────────────────────
  const RE_CODE    = /^([A-Z]+)\s/;
  const RE_PAREN   = /\(([^)]+)\)/;
  const RE_ACFT = /(A3[0-3]\d|B737)/;
  const RE_LEAP    = /LEAP/;
  const RE_CFM56   = /CFM56|CFM 56/;
  const RE_RRT     = /RRT772|TRENT 7/;
  const RE_CF6     = /CF6|GE CF/;
  const RE_PW      = /PW1100G?|PW 1100/;
  const RE_V2500   = /V2500|IAE V25/;
  const RE_B737    = /^(cgk|cg\s)/i;   // reused for CGK prefix check too
  const RE_CGK     = /^(cgk|ab)\s/i;   // accept both CGK and AB prefixes

  const RE_B737_CLASSIC = /B737[\s\-]*(300|400|500|3\/4\/5)/;
  const RE_B737_NG      = /B737[\s\-]*(600|700|800|900|600\/700|NG)|B737\-600\/700\/800\/900/;
  const RE_B737_MAX     = /B737[\s\-]*(MAX|6\/7\/8\/9(?!\s*\(CFM))/;
  const RE_DASHSEP      = /\s*[\-\u2013\u2014]\s*/;
  const RE_A350_TRXWB = /A350/i;

  // ── Helper: split a comma-list cell value ─────────────────────────────────
  function parseList(val) {
    if (!val) return [];
    const s = String(val);
    if (s.indexOf(',') === -1) { const t = s.trim(); return t ? [t] : []; }
    return s.split(',').map(x => x.trim()).filter(x => x.length > 0);
  }

  // ── matchCanonical using pre-tokenised tokens ─────────────────────────────
  function matchCanonical(normLine, tokens) {
    return tokens.every(t => normLine.includes(t));
  }

  // ── matchOperator using pre-compiled regex ────────────────────────────────
  function matchOperator(apprLine, opObj) {
    if (opObj.re.test(apprLine)) return true;
    const lastWord = apprLine.split(/[\s,]+/).pop().toLowerCase();
    if (lastWord === opObj.low) return true;
    if (opObj.id.length > 3 && apprLine.toLowerCase().endsWith(opObj.low)) return true;
    return false;
  }

  // ── parseApprStr with pre-compiled regexes ────────────────────────────────
  function parseApprStr(s) {
    s = s.trim();
    const codeM = RE_CODE.exec(s);
    const code  = codeM ? codeM[1] : '';
    const em    = RE_PAREN.exec(s);
    const er    = em ? em[1].toUpperCase() : '';
    const acm   = RE_ACFT.exec(s);

    let aircraft = null;
    if (acm) {
      const a = acm[1];
      if      (a === 'B737')              aircraft = 'B737';
      else if (a === 'A321')              aircraft = 'A321';
      else if (a === 'A330')              aircraft = 'A330';
      else                                aircraft = 'A320';
    }

    let engine = null;
    if      (RE_LEAP.test(er))   engine = 'LEAP-1A';
    else if (RE_CFM56.test(er))  engine = 'CFM56';
    else if (RE_RRT.test(er))    engine = 'RRT772B-60';
    else if (RE_CF6.test(er))    engine = 'GE CF6';
    else if (RE_PW.test(er))     engine = 'PW1100';
    else if (RE_V2500.test(er))  engine = 'V2500';

    const letters = code.split('').filter(ch => ch >= 'A' && ch <= 'Z');
    return { code, letters, aircraft, engine };
  }

  // ── extractAircraftLabel ──────────────────────────────────────────────────
  function extractAircraftLabel(apprLine) {
    const codM = RE_CODE.exec(apprLine);
    const code = codM ? codM[1] : '';
    const em   = RE_PAREN.exec(apprLine);
    const acm  = RE_ACFT.exec(apprLine);
    if (em && acm) return code + ' ' + acm[1] + ' (' + em[1] + ')';
    return '';
  }

  // ── detectB737 ────────────────────────────────────────────────────────────
  function detectB737(val) {
    if (!val) return { classic:false, ng:false, max:false };
    const v = val.toUpperCase();
    return {
      classic: RE_B737_CLASSIC.test(v),
      ng:      RE_B737_NG.test(v),
      max:     RE_B737_MAX.test(v),
    };
  }

  function detectA350(val) {
    if (!val) return { TRXWB: false };
    return { TRXWB: RE_A350_TRXWB.test(val) };
  }

  // ── Main row loop ─────────────────────────────────────────────────────────
  const staff = [];

  for (let ri = 0; ri < rawData.length; ri++) {
    const row  = rawData[ri];
    const name = C.name >= 0 ? String(row[C.name]||'').trim() : '';
    if (!name) continue;

    // Merge all approval items from all four approval columns
    const allApprItems = [];
    const cols = [C.b1Appr, C.b2Appr, C.cAppr, C.aAppr];
    for (let ci = 0; ci < cols.length; ci++) {
      if (cols[ci] < 0) continue;
      const list = parseList(row[cols[ci]]);
      for (let li = 0; li < list.length; li++) allApprItems.push(list[li]);
    }

    // Pre-normalise every approval item once per row
    const normItems = allApprItems.map(norm);

    // ── Canonicals: only test CGK/AB-prefix items ─────────────────────────
    const canonicals = {};
    for (let ci = 0; ci < canonTokens.length; ci++) {
      const ct = canonTokens[ci];
      let hit = false;
      for (let ai = 0; ai < normItems.length; ai++) {
        if (matchCanonical(normItems[ai], ct.tokens)) { hit = true; break; }
      }
      canonicals[ct.id] = hit;
    }

    // ── typeMatrix ────────────────────────────────────────────────────────
    const tmSets = {};
    for (let ai = 0; ai < allApprItems.length; ai++) {
      const p = parseApprStr(allApprItems[ai]);
      if (!p.aircraft || !p.engine || !p.letters.length) continue;
      const key = p.aircraft + '_' + p.engine;
      if (!tmSets[key]) tmSets[key] = [];
      for (let li = 0; li < p.letters.length; li++) {
        if (tmSets[key].indexOf(p.letters[li]) === -1) tmSets[key].push(p.letters[li]);
      }
    }
    const typeMatrixArr = {};
    const tmKeys = Object.keys(tmSets);
    for (let ki = 0; ki < tmKeys.length; ki++) {
      typeMatrixArr[tmKeys[ki]] = tmSets[tmKeys[ki]].sort();
    }

    // ── authApprovals: opId → unique label array ──────────────────────────
    const authApprovals = {};
    for (let oi = 0; oi < operatorRegexes.length; oi++) {
      const opObj   = operatorRegexes[oi];
      const matches = [];
      const seen    = {};
      for (let ai = 0; ai < allApprItems.length; ai++) {
        if (!matchOperator(allApprItems[ai], opObj)) continue;
        const lbl = extractAircraftLabel(allApprItems[ai]);
        if (lbl && !seen[lbl]) { seen[lbl] = 1; matches.push(lbl); }
      }
      if (matches.length) authApprovals[opObj.id] = matches.sort();
    }

    // ── B737 type ratings ─────────────────────────────────────────────────
    const b1tr  = C.b1TR >= 0 ? String(row[C.b1TR]||'') : '';
    const b2tr  = C.b2TR >= 0 ? String(row[C.b2TR]||'') : '';
    const ctr   = C.cTR  >= 0 ? String(row[C.cTR] ||'') : '';
    const b1B   = detectB737(b1tr), b2B = detectB737(b2tr), cB = detectB737(ctr);
    const b737  = {
      classic: [...(b1B.classic?['B1']:[]), ...(b2B.classic?['B2']:[]), ...(cB.classic?['C']:[])],
      ng:      [...(b1B.ng     ?['B1']:[]), ...(b2B.ng     ?['B2']:[]), ...(cB.ng     ?['C']:[])],
      max:     [...(b1B.max    ?['B1']:[]), ...(b2B.max    ?['B2']:[]), ...(cB.max    ?['C']:[])],
    };

    // ── A350 type ratings ─────────────────────────────────────────────────
    const b1A350 = detectA350(b1tr), b2A350 = detectA350(b2tr), cA350 = detectA350(ctr);
    const a350 = {
      TRXWB: [
        ...(b1A350.TRXWB ? ['B1'] : []),
        ...(b2A350.TRXWB ? ['B2'] : []),
        ...(cA350.TRXWB  ? ['C']  : []),
      ],
    };

    // ── Authority set (for legacy .authorities field) ─────────────────────
    const authSet = new Set();
    for (let ai = 0; ai < allApprItems.length; ai++) {
      const parts = allApprItems[ai].split(RE_DASHSEP);
      if (parts.length >= 2) authSet.add(parts[parts.length - 1].trim());
    }

    const approCatRaw = C.approCat >= 0 ? String(row[C.approCat]||'').trim() : '';
    const cats        = approCatRaw
      ? approCatRaw.split(',').map(c => c.trim()).filter(c => c)
      : [];

    staff.push({
      name:          name,
      staffNo:       C.staffNo  >= 0 ? String(row[C.staffNo] ||'').trim() : '',
      approNo:       C.approNo  >= 0 ? String(row[C.approNo] ||'').trim() : '',
      position:      C.position >= 0 ? String(row[C.position]||'').trim() : '',
      section:       C.section  >= 0 ? String(row[C.section] ||'').trim() : '',
      shift:         C.shift    >= 0 ? String(row[C.shift]   ||'').trim() : '',
      approCat:      approCatRaw,
      cats:          cats,
      approvals:     allApprItems,
      authorities:   Array.from(authSet).sort(),
      canonicals:    canonicals,
      typeMatrix:    typeMatrixArr,
      b737:          b737,
      a350:          a350,
      authApprovals: authApprovals,
    });
  }

  return { staff, sheetName: CONFIG.DATA_SHEET, canonicals: CANONICALS };
}

// ═════════════════════════════════════════════════════════════════════════════
//  PROFILE INIT — single batched call for fast mobile load
//  Returns user status + all dropdown data in ONE round-trip
//  Per-user cache: 60s (chunked);  dropdown cache: 5 min (chunked)
// ═════════════════════════════════════════════════════════════════════════════

function getProfileInitData() {
  const email = Session.getActiveUser().getEmail();

  if (!email || !email.toLowerCase().endsWith('@airasia.com')) {
    return {
      status:  'invalid_domain',
      email:   email,
      message: 'Please use your company email address (@airasia.com) to access this portal.'
    };
  }

  // ── Per-user profile cache (60s) — uses chunked helpers ──────────────────
  const userKey = 'profinit_' + email.toLowerCase().replace(/[^a-z0-9]/g, '_');
  const cachedUser = cacheRead(userKey);
  if (cachedUser) {
    console.log('getProfileInitData cache HIT for ' + email);
    return cachedUser;
  }

  try {
    const ss    = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
    const sheet = ss.getSheetByName(CONFIG.DATA_SHEET);

    if (!sheet || sheet.getLastRow() < 2) {
      const result = {
        status: 'not_registered', email: email,
        message: 'You are not registered in the system. Please complete the registration form.'
      };
      return result;
    }

    const tz      = Session.getScriptTimeZone();
    const lastRow = sheet.getLastRow();
    const lastCol = sheet.getLastColumn();

    // ── ONE batch read: headers + all data ─────────────────────────────────
    const allValues   = sheet.getRange(1, 1, lastRow, lastCol).getValues();
    const headers     = allValues[0];
    const emailColIdx = headers.indexOf('email_address');

    if (emailColIdx === -1) {
      return { status: 'not_registered', email: email };
    }

    // ── Find user row (early exit on match) ────────────────────────────────
    const targetEmail = email.toLowerCase();
    let userData = null;

    for (let i = 1; i < allValues.length; i++) {
      const rowEmail = allValues[i][emailColIdx];
      if (rowEmail && rowEmail.toString().toLowerCase() === targetEmail) {
        userData = {};
        for (let j = 0; j < headers.length; j++) {
          if (!headers[j]) continue;
          let val = allValues[i][j];
          if (val instanceof Date) {
            val = Utilities.formatDate(val, tz, 'yyyy-MM-dd');
          }
          userData[headers[j]] = val || '';
        }
        break;
      }
    }

    if (!userData) {
      return {
        status: 'not_registered', email: email,
        message: 'You are not registered in the system. Please complete the registration form.'
      };
    }

    // ── Bundle dropdown data (separate 5-min cache) ────────────────────────
    const dropdowns = getDropdownDataCached(ss);

    const result = {
      status:    'registered',
      email:     email,
      data:      userData,
      headers:   headers,
      dropdowns: dropdowns
    };

    // Cache using chunked writer (handles >100KB payloads safely)
    cacheWriteShort(userKey, result, 60);
    return result;

  } catch (e) {
    console.error('getProfileInitData error:', e);
    return { status: 'error', email: email, message: e.toString() };
  }
}

/**
 * Returns nationality + type rating + approval types in a single object.
 * Cached for 5 minutes via chunked writer.
 */
function getDropdownDataCached(ss) {
  const cached = cacheRead('dropdowns_v1');
  if (cached) return cached;

  const result = {
    nationalities: [],
    typeRatings:   [],
    approvalTypes: {}
  };

  try {
    const natSheet = ss.getSheetByName(CONFIG.NATIONALITY_SHEET);
    if (natSheet && natSheet.getLastRow() >= 2) {
      result.nationalities = natSheet.getRange('A2:A' + natSheet.getLastRow())
        .getValues().flat().filter(v => v !== '');
    } else {
      result.nationalities = ['Malaysian', 'Singaporean', 'Indonesian', 'Filipino', 'Indian', 'Bangladeshi', 'Other'];
    }

    const trSheet = ss.getSheetByName(CONFIG.TYPE_RATING_SHEET);
    if (trSheet && trSheet.getLastRow() >= 2) {
      result.typeRatings = trSheet.getRange('A2:A' + trSheet.getLastRow())
        .getValues().flat().filter(v => v !== '');
    } else {
      result.typeRatings = ['A320', 'A321', 'A330', 'A350', 'B737', 'B777', 'B787', 'ATR72'];
    }

    const apprSheet = ss.getSheetByName('Com Appr');
    if (apprSheet && apprSheet.getLastRow() >= 2) {
      const lastCol  = apprSheet.getLastColumn();
      const apprAll  = apprSheet.getRange(1, 1, apprSheet.getLastRow(), lastCol).getValues();
      const apprHdrs = apprAll[0];
      for (let c = 0; c < apprHdrs.length; c++) {
        const h = String(apprHdrs[c]).trim();
        if (!h) continue;
        const list = [];
        for (let r = 1; r < apprAll.length; r++) {
          const v = String(apprAll[r][c]).trim();
          if (v) list.push(v);
        }
        result.approvalTypes[h] = list;
      }
    }
  } catch (e) {
    console.warn('getDropdownDataCached partial failure: ' + e.toString());
  }

  cacheWriteShort('dropdowns_v1', result, 300);
  return result;
}

/**
 * Chunked cache writer with configurable TTL (extension of cacheWrite).
 * Use this when you need a different TTL than the default CACHE_TTL (300s).
 */
function cacheWriteShort(key, data, ttl) {
  try {
    const cache = CacheService.getScriptCache();
    const json  = JSON.stringify(data);
    const total = Math.ceil(json.length / CACHE_CHUNK);
    const pairs = {};
    for (let i = 0; i < total; i++) {
      pairs[key + '_c' + i] = json.slice(i * CACHE_CHUNK, (i + 1) * CACHE_CHUNK);
    }
    pairs[key + '_meta'] = JSON.stringify({ n: total });
    cache.putAll(pairs, ttl || CACHE_TTL);
    console.log('Cache WRITE: ' + key + ' (' + total + ' chunk(s), ' + json.length + ' chars, TTL=' + (ttl || CACHE_TTL) + 's)');
  } catch (e) {
    console.warn('cacheWriteShort failed: ' + e.toString());
  }
}
