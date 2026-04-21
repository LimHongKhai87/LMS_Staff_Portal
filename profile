<!DOCTYPE html>
<html>
<head>
  <base target="_top">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
      background-color: #f5f5f5; color: #333; line-height: 1.5; font-size: 14px;
      -webkit-font-smoothing: antialiased; min-height: 100vh;
    }
    .loading-screen { display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; background: #fff; }
    .spinner { border: 4px solid #e5e7eb; border-top: 4px solid #6b7280; border-radius: 50%; width: 50px; height: 50px; animation: spin 0.8s linear infinite; }
    @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    .loading-screen p { margin-top: 16px; color: #6b7280; font-weight: 500; }
    .message-screen { display: none; text-align: center; padding: 60px 20px; background: #fff; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); margin: 40px auto; max-width: 500px; }
    .message-screen.show { display: block; }
    .message-icon { width: 70px; height: 70px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px; font-size: 32px; }
    .message-icon.error { background: #fee2e2; color: #dc2626; }
    .message-icon.info { background: #f3f4f6; color: #6b7280; }
    .message-screen h2 { color: #1f2937; margin-bottom: 12px; font-size: 20px; }
    .message-screen p { color: #6b7280; margin-bottom: 24px; font-size: 14px; }
    .message-screen .email-badge { display: inline-block; background: #f3f4f6; padding: 8px 16px; border-radius: 20px; font-size: 13px; color: #4b5563; margin-bottom: 24px; }
    .btn { display: inline-flex; align-items: center; justify-content: center; padding: 8px 16px; border: none; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s; text-decoration: none; gap: 6px; }
    .btn-primary { background: #1a73e8; color: #fff; }
    .btn-primary:hover { background: #1557b0; }
    .btn-outline-grey { background: transparent; color: #6b7280; border: 1.5px solid #9ca3af; }
    .btn-outline-grey:hover { background: #f3f4f6; border-color: #6b7280; color: #374151; }
    .btn-grey { background: #6b7280; color: #fff; border: none; }
    .btn-grey:hover { background: #4b5563; }
    .btn-danger-outline { background: transparent; color: #dc2626; border: 1.5px solid #dc2626; }
    .btn-danger-outline:hover { background: #fee2e2; }
    .btn-danger { background: #dc2626; color: #fff; border: none; }
    .btn-danger:hover { background: #b91c1c; }
    .btn svg { width: 14px; height: 14px; }
    .profile-layout { display: none; min-height: 100vh; }
    .profile-layout.show { display: flex; }
    .sidebar { width: 220px; background: #fff; border-right: 1px solid #e5e7eb; padding: 20px 0; position: fixed; top: 0; left: 0; height: 100vh; overflow-y: auto; z-index: 100; }
    .sidebar-header { padding: 10px 16px 20px; border-bottom: 1px solid #e5e7eb; margin-bottom: 10px; }
    .sidebar-title { font-size: 13px; font-weight: 600; color: #9ca3af; text-transform: uppercase; letter-spacing: 0.5px; }
    .back-btn {
      display: flex; align-items: center; gap: 7px;
      width: 100%; padding: 8px 10px; margin-bottom: 12px;
      background: #f3f4f6; border: none; border-radius: 7px;
      color: #374151; font-size: 13px; font-weight: 500;
      cursor: pointer; transition: all 0.15s; text-align: left;
    }
    .back-btn:hover { background: #e5e7eb; color: #111827; }
    .back-btn svg { width: 15px; height: 15px; stroke: #6b7280; flex-shrink: 0; transition: stroke 0.15s; }
    .back-btn:hover svg { stroke: #111827; }
    .nav-item { display: block; padding: 12px 16px; color: #4b5563; text-decoration: none; font-size: 14px; cursor: pointer; border-left: 3px solid transparent; transition: all 0.15s; }
    .nav-item:hover { background: #f9fafb; color: #1f2937; }
    .nav-item.active { background: #f3f4f6; color: #1f2937; border-left-color: #6b7280; font-weight: 500; }
    .main-content { flex: 1; margin-left: 220px; padding: 24px 30px; max-width: 1200px; }

    /* ── Profile Header ── */
    .profile-header { background: #fff; border-radius: 12px; padding: 20px 24px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
    .profile-header-top { display: flex; align-items: flex-start; gap: 16px; margin-bottom: 0; }
    .profile-info { flex: 1; }
    .profile-info h1 { font-size: 22px; font-weight: 600; color: #1f2937; margin-bottom: 4px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
    .profile-info p { color: #6b7280; font-size: 14px; }
    .profile-meta { text-align: right; flex-shrink: 0; }
    .profile-meta-item { font-size: 13px; color: #6b7280; margin-bottom: 4px; }
    .profile-meta-item span { color: #1f2937; font-weight: 500; }
    .profile-header-bottom { margin-top: 12px; padding-top: 10px; border-top: 1px solid #f3f4f6; display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
    .last-updated { color: #9ca3af; font-size: 12px; }

    /* ── Status Badge ── */
    .status-badge {
      display: inline-flex; align-items: center; gap: 5px;
      padding: 3px 10px; border-radius: 10px;
      font-size: 12px; font-weight: 600; white-space: nowrap; flex-shrink: 0;
    }
    .status-badge.active   { background: #dcfce7; color: #15803d; }
    .status-badge.departed { background: #fee2e2; color: #dc2626; }
    .status-date-text { font-size: 11px; font-weight: 400; color: #9ca3af; margin-left: 2px; }

    /* ── Admin Email Switcher ── */
    .admin-switcher { display: flex; align-items: center; gap: 8px; }
    .admin-switcher-label { font-size: 11px; font-weight: 600; color: #6b7280; text-transform: uppercase; letter-spacing: 0.4px; white-space: nowrap; }
    .admin-switcher select { font-size: 12px; padding: 5px 8px; border: 1.5px solid #d1d5db; border-radius: 6px; color: #374151; background: #f9fafb; max-width: 260px; cursor: pointer; }
    .admin-switcher select:focus { outline: none; border-color: #1a73e8; }
    .admin-badge { display: inline-flex; align-items: center; padding: 2px 8px; background: #fef3c7; color: #92400e; border-radius: 10px; font-size: 10px; font-weight: 600; letter-spacing: 0.3px; white-space: nowrap; }
    .admin-switcher.loading select { opacity: 0.5; pointer-events: none; }

    .profile-section { display: none; background: #fff; border-radius: 12px; padding: 20px 24px; margin-bottom: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
    .profile-section.active { display: block; }
    .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; padding-bottom: 12px; border-bottom: 1px solid #e5e7eb; }
    .section-title { font-size: 16px; font-weight: 600; color: #1f2937; }
    .section-actions { display: flex; gap: 8px; align-items: center; }
    .edit-actions { display: none; gap: 8px; }
    .edit-actions.show { display: flex; }
    .data-row { display: flex; padding: 10px 0; border-bottom: 1px solid #f9fafb; align-items: flex-start; }
    .data-row:last-child { border-bottom: none; }
    .data-label { width: 160px; flex-shrink: 0; font-size: 13px; color: #6b7280; padding-top: 2px; }
    .data-value { flex: 1; font-size: 13px; color: #1f2937; word-break: break-word; display: flex; align-items: flex-start; gap: 8px; flex-wrap: wrap; }
    .data-value.empty { color: #d1d5db; font-style: italic; }
    .half-width-container { max-width: 50%; }
    .half-width-container .data-row { flex-direction: column; align-items: flex-start; }
    .half-width-container .data-label { width: 100%; margin-bottom: 4px; }
    .editable-field { display: none; width: 100%; align-items: center; gap: 8px; }
    .editable-field.show { display: flex; }
    .editable-field input, .editable-field select, .editable-field textarea { width: 100%; padding: 8px 10px; border: 1.5px solid #d1d5db; border-radius: 6px; font-size: 13px; transition: border-color 0.2s; }
    .editable-field input:focus, .editable-field select:focus, .editable-field textarea:focus { outline: none; border-color: #1a73e8; }
    .editable-field input:disabled, .editable-field select:disabled { background: #f3f4f6; color: #6b7280; cursor: not-allowed; }
    .editable-field textarea { min-height: 80px; resize: vertical; }
    .phone-input-group { display: flex; align-items: center; gap: 6px; width: 100%; }
    .phone-prefix { font-size: 13px; font-weight: 500; color: #374151; }
    .phone-input-group input { flex: 1; }
    .display-value { display: inline-flex; align-items: center; gap: 8px; }
    .display-value.hidden { display: none; }
    .doc-link { display: inline-flex; align-items: center; gap: 4px; color: #1f2937; text-decoration: none; padding: 3px 10px; background: #fff; border: 1.5px solid #1f2937; border-radius: 4px; font-size: 11px; font-weight: 500; transition: all 0.15s; flex-shrink: 0; }
    .doc-link:hover { background: #1f2937; color: #fff; }
    .doc-link:hover svg { stroke: #fff; }
    .doc-link svg { width: 12px; height: 12px; stroke: #1f2937; fill: none; }
    .upload-link { display: inline-flex; align-items: center; gap: 4px; color: #dc2626; text-decoration: none; padding: 3px 10px; background: #fff; border: 1.5px solid #dc2626; border-radius: 4px; font-size: 11px; font-weight: 500; transition: all 0.15s; flex-shrink: 0; cursor: pointer; }
    .upload-link:hover { background: #dc2626; color: #fff; }
    .upload-link:hover svg { stroke: #fff; }
    .upload-link svg { width: 12px; height: 12px; stroke: #dc2626; fill: none; }
    .status-icon { display: inline-flex; align-items: center; justify-content: center; width: 18px; height: 18px; border-radius: 50%; flex-shrink: 0; }
    .status-icon.uploaded { background: #dcfce7; color: #16a34a; }
    .status-icon.uploaded svg { stroke: #16a34a; }
    .status-icon.missing { background: #fee2e2; color: #dc2626; }
    .status-icon.missing svg { stroke: #dc2626; }
    .status-icon svg { width: 12px; height: 12px; fill: none; stroke-width: 2.5; }
    .not-avail-badge { display: inline-flex; align-items: center; padding: 2px 8px; background: #fef2f2; color: #dc2626; border-radius: 10px; font-size: 11px; font-weight: 500; }
    .file-upload-area { border: 2px dashed #d1d5db; border-radius: 8px; padding: 16px; text-align: center; cursor: pointer; transition: all 0.2s; background: #fafafa; margin-top: 8px; }
    .file-upload-area:hover, .file-upload-area.dragover { border-color: #1a73e8; background: #eff6ff; }
    .file-upload-area input { display: none; }
    .file-upload-area .upload-icon { margin-bottom: 8px; }
    .file-upload-area .upload-icon svg { width: 32px; height: 32px; stroke: #9ca3af; }
    .file-upload-area p { font-size: 12px; color: #6b7280; margin: 0; }
    .file-upload-area .file-type { font-size: 11px; color: #9ca3af; margin-top: 4px; }
    .file-selected { display: flex; align-items: center; gap: 8px; margin-top: 8px; padding: 8px 12px; background: #f0fdf4; border-radius: 6px; font-size: 12px; color: #16a34a; }
    .file-selected svg { width: 16px; height: 16px; stroke: #16a34a; flex-shrink: 0; }
    .file-selected .file-name { flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .file-selected .remove-file { background: none; border: none; color: #dc2626; cursor: pointer; padding: 2px; }
    .expiry-badge { display: inline-flex; align-items: center; padding: 2px 8px; border-radius: 10px; font-size: 11px; font-weight: 600; margin-left: 8px; flex-shrink: 0; }
    .expiry-badge.expired { background: #fee2e2; color: #dc2626; }
    .expiry-badge.critical { background: #ffedd5; color: #ea580c; }
    .expiry-badge.warning { background: #fef9c3; color: #ca8a04; }
    .multi-select-container { display: flex; flex-direction: column; gap: 6px; width: 100%; }
    .selected-badges { display: flex; flex-wrap: wrap; gap: 4px; }
    .badge { display: inline-flex; align-items: center; gap: 4px; padding: 3px 8px; background: #374151; color: #fff; border-radius: 12px; font-size: 11px; font-weight: 500; }
    .badge-remove { background: none; border: none; color: #fff; cursor: pointer; font-size: 12px; line-height: 1; padding: 0; margin-left: 2px; opacity: 0.7; }
    .badge-remove:hover { opacity: 1; }
    .multi-select-dropdown { padding: 6px 8px; font-size: 12px; }
    .employment-card { background: #f9fafb; border-radius: 8px; padding: 16px; margin-bottom: 12px; }
    .employment-card:last-child { margin-bottom: 0; }
    .employment-card-title { font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 12px; padding-bottom: 8px; border-bottom: 1px solid #e5e7eb; }
    .subsection { background: #f9fafb; border-radius: 8px; padding: 16px; margin-bottom: 12px; }
    .subsection-title { font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 12px; padding-bottom: 8px; border-bottom: 1px solid #e5e7eb; }
    .two-column { display: grid; grid-template-columns: 1fr 1fr; gap: 0 30px; }
    .column { border-right: 1px solid #f3f4f6; padding-right: 24px; }
    .column:last-child { border-right: none; padding-right: 0; padding-left: 6px; }
    .mobile-nav { display: none; position: fixed; bottom: 0; left: 0; right: 0; background: #fff; border-top: 1px solid #e5e7eb; padding: 8px 0; z-index: 200; box-shadow: 0 -2px 10px rgba(0,0,0,0.05); }
    .mobile-nav-scroll { display: flex; overflow-x: auto; -webkit-overflow-scrolling: touch; padding: 0 10px; gap: 6px; scrollbar-width: none; }
    .mobile-nav-scroll::-webkit-scrollbar { display: none; }
    .mobile-nav-item { flex-shrink: 0; padding: 10px 14px; background: #f3f4f6; border: none; border-radius: 8px; color: #4b5563; font-size: 12px; font-weight: 500; cursor: pointer; white-space: nowrap; transition: all 0.15s; }
    .mobile-nav-item.active { background: #374151; color: #fff; }
    .toast { position: fixed; bottom: 80px; left: 50%; transform: translateX(-50%); background: #1f2937; color: #fff; padding: 12px 24px; border-radius: 8px; font-size: 14px; z-index: 300; display: none; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
    .toast.show { display: block; animation: slideUp 0.3s ease; }
    @keyframes slideUp { from { opacity: 0; transform: translateX(-50%) translateY(20px); } to { opacity: 1; transform: translateX(-50%) translateY(0); } }
    .saving-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(255,255,255,0.95); z-index: 500; justify-content: center; align-items: center; flex-direction: column; }
    .saving-overlay.show { display: flex; }
    .saving-overlay .spinner { border: 4px solid #e5e7eb; border-top: 4px solid #1a73e8; border-radius: 50%; width: 50px; height: 50px; animation: spin 0.8s linear infinite; }
    .saving-overlay p { margin-top: 16px; color: #6b7280; font-weight: 500; text-align: center; }
    .hidden { display: none !important; }
    .input-wide { width: 150% !important; max-width: 400px; }
    .input-narrow { width: 60% !important; }
    .input-half { width: 50% !important; }
    .month-year-picker { display: flex; gap: 8px; width: 100%; }
    .month-year-picker select { flex: 1; }
    .text-value { font-size: 13px; color: #1f2937; padding: 8px 0; }
    .numbered-list { margin: 0; padding-left: 20px; }
    .numbered-list li { margin-bottom: 2px; font-size: 13px; }

    /* ── Disciplinary Table ── */
    .disciplinary-nil { font-size: 13px; color: #9ca3af; font-style: italic; padding: 12px 0; }
    .disc-table-wrap { overflow-x: auto; -webkit-overflow-scrolling: touch; }
    .disc-table { width: 100%; border-collapse: collapse; font-size: 13px; }
    .disc-table th { background: #f3f4f6; color: #374151; font-weight: 600; font-size: 12px; padding: 10px 12px; text-align: left; white-space: nowrap; border-bottom: 2px solid #9ca3af; }
    .disc-table td { padding: 10px 12px; border-bottom: 1px solid #f3f4f6; color: #1f2937; vertical-align: top; }
    .disc-table tr:last-child td { border-bottom: none; }
    .disc-table tr:hover td { background: #fafafa; }
    .disc-doc-link { display: inline-flex; align-items: center; gap: 4px; color: #1a73e8; font-size: 12px; font-weight: 500; text-decoration: none; }
    .disc-doc-link:hover { text-decoration: underline; }
    .disc-loading { font-size: 13px; color: #9ca3af; padding: 12px 0; display: flex; align-items: center; gap: 8px; }
    .disc-loading .mini-spinner { border: 3px solid #e5e7eb; border-top: 3px solid #6b7280; border-radius: 50%; width: 16px; height: 16px; animation: spin 0.8s linear infinite; flex-shrink: 0; }
    .disc-stack { display: none; }
    .disc-card { border: 1px solid #e5e7eb; border-radius: 8px; padding: 14px; margin-bottom: 10px; background: #fff; }
    .disc-card:last-child { margin-bottom: 0; }
    .disc-card-row { display: flex; padding: 5px 0; border-bottom: 1px solid #f9fafb; font-size: 13px; }
    .disc-card-row:last-child { border-bottom: none; padding-bottom: 0; }
    .disc-card-label { width: 110px; flex-shrink: 0; font-size: 11px; font-weight: 600; color: #6b7280; text-transform: uppercase; letter-spacing: 0.3px; padding-top: 1px; }
    .disc-card-value { flex: 1; color: #1f2937; font-size: 13px; word-break: break-word; }
    .disc-card-refno { font-size: 11px; font-weight: 700; color: #374151; background: #f3f4f6; display: inline-flex; align-items: center; padding: 2px 8px; border-radius: 4px; }
    .disc-card-year { font-size: 11px; font-weight: 600; color: #fff; background: #6b7280; display: inline-flex; align-items: center; padding: 2px 8px; border-radius: 4px; }
    .disc-type-badge { display: inline-flex; align-items: center; padding: 2px 8px; border-radius: 10px; font-size: 11px; font-weight: 600; white-space: nowrap; }
    .disc-type-badge.reprimand { background: #fecaca; color: #b91c1c; }
    .disc-type-badge.warning   { background: #dc2626; color: #fff; }
    @media (max-width: 700px) { .disc-table-wrap { display: none; } .disc-stack { display: block; } }

    /* ── Change Status Modal ── */
    .status-modal-overlay {
      display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(0,0,0,0.55); z-index: 600;
      justify-content: center; align-items: center; padding: 20px;
    }
    .status-modal-overlay.show { display: flex; }
    .status-modal {
      background: #fff; border-radius: 14px; width: 100%; max-width: 480px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.18); overflow: hidden;
    }
    .status-modal-header {
      background: #fef2f2; padding: 20px 24px 16px;
      border-bottom: 1px solid #fecaca;
    }
    .status-modal-header h2 { font-size: 17px; font-weight: 700; color: #991b1b; margin-bottom: 4px; display: flex; align-items: center; gap: 8px; }
    .status-modal-header .warning-icon { font-size: 20px; }
    .status-modal-notice {
      margin: 0; padding: 10px 14px; background: #fff7ed;
      border: 1px solid #fed7aa; border-radius: 8px; margin-top: 10px;
      font-size: 12px; color: #92400e; line-height: 1.6;
    }
    .status-modal-body { padding: 20px 24px; }
    .status-modal-field { margin-bottom: 16px; }
    .status-modal-field label { display: block; font-size: 12px; font-weight: 700; color: #374151; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.3px; }
    .status-modal-field select,
    .status-modal-field input[type="date"] {
      width: 100%; padding: 9px 12px; border: 1.5px solid #d1d5db;
      border-radius: 7px; font-size: 13px; background: #fff;
      transition: border-color 0.2s;
    }
    .status-modal-field select:focus,
    .status-modal-field input[type="date"]:focus { outline: none; border-color: #dc2626; }
    .status-modal-footer {
      padding: 14px 24px 20px; display: flex; justify-content: flex-end; gap: 8px;
      border-top: 1px solid #f3f4f6;
    }

    .confirmation-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 500; justify-content: center; align-items: center; padding: 20px; overflow-y: auto; }
    .confirmation-overlay.show { display: flex; }
    .confirmation-modal { background: #fff; border-radius: 12px; max-width: 600px; width: 100%; max-height: 90vh; overflow-y: auto; box-shadow: 0 4px 20px rgba(0,0,0,0.15); }
    .confirmation-header { padding: 20px 24px; border-bottom: 1px solid #e5e7eb; }
    .confirmation-header h2 { font-size: 18px; font-weight: 600; color: #1f2937; margin-bottom: 4px; }
    .confirmation-header p { font-size: 13px; color: #6b7280; }
    .confirmation-content { padding: 16px 24px; }
    .confirmation-section { margin-bottom: 16px; }
    .confirmation-section:last-child { margin-bottom: 0; }
    .confirmation-section-title { font-size: 13px; font-weight: 600; color: #374151; padding: 8px 12px; background: #f3f4f6; border-radius: 6px; margin-bottom: 8px; }
    .confirmation-item { display: flex; padding: 8px 0; border-bottom: 1px solid #f3f4f6; font-size: 13px; }
    .confirmation-item:last-child { border-bottom: none; }
    .confirmation-label { width: 140px; flex-shrink: 0; color: #6b7280; }
    .confirmation-values { flex: 1; }
    .confirmation-old { color: #9ca3af; margin-right: 8px; }
    .confirmation-new { color: #1a73e8; font-weight: 500; }
    .confirmation-arrow { color: #9ca3af; margin-right: 8px; }
    .confirmation-file { display: inline-flex; align-items: center; gap: 4px; padding: 2px 8px; background: #dbeafe; color: #1d4ed8; border-radius: 4px; font-size: 11px; }
    .confirmation-footer { padding: 16px 24px; border-top: 1px solid #e5e7eb; display: flex; justify-content: flex-end; gap: 8px; }
    .no-changes { text-align: center; padding: 40px 20px; color: #6b7280; }
    .no-changes-icon { font-size: 48px; margin-bottom: 12px; }
    .approval-no-input { display: flex; align-items: center; gap: 0; width: 100%; }
    .approval-prefix { background: #e5e7eb; color: #6b7280; padding: 8px 10px; border: 1.5px solid #d1d5db; border-right: none; border-radius: 6px 0 0 6px; font-size: 13px; font-weight: 500; }
    .approval-no-input input.input-digits { border-radius: 0 6px 6px 0 !important; width: 80px !important; flex-shrink: 0; }
    .mandatory-field.unfilled input, .mandatory-field.unfilled select, .mandatory-field.unfilled textarea, .mandatory-field.unfilled .multi-select-dropdown, .mandatory-field.unfilled .month-year-picker select { border-color: #f59e0b !important; }
    .mandatory-field.filled input, .mandatory-field.filled select, .mandatory-field.filled textarea, .mandatory-field.filled .multi-select-dropdown, .mandatory-field.filled .month-year-picker select { border-color: #16a34a !important; }
    .mandatory-field .data-label::after { content: ' *'; color: #dc2626; font-weight: 600; }
    .mandatory-indicator { display: inline-flex; align-items: center; gap: 4px; padding: 4px 8px; background: #fef3c7; color: #92400e; border-radius: 4px; font-size: 11px; margin-bottom: 12px; }
    .validation-error-field input, .validation-error-field select, .validation-error-field textarea, .validation-error-field .multi-select-dropdown, .validation-error-field .month-year-picker select { border-color: #dc2626 !important; animation: shake 0.3s ease-in-out; }
    @keyframes shake { 0%, 100% { transform: translateX(0); } 25% { transform: translateX(-4px); } 75% { transform: translateX(4px); } }

    /* ── Absence Section ── */
    .abs-year-group { margin-bottom: 20px; }
    .abs-year-group:last-child { margin-bottom: 0; }
    .abs-year-header { font-size: 12px; font-weight: 700; color: #fff; background: #374151; display: inline-block; padding: 3px 10px; border-radius: 4px; margin-bottom: 10px; letter-spacing: 0.3px; }
    .abs-table-wrap { overflow-x: auto; -webkit-overflow-scrolling: touch; }
    .abs-table { width: 100%; border-collapse: collapse; font-size: 13px; table-layout: fixed; }
    .abs-table th { background: #f3f4f6; color: #374151; font-weight: 600; font-size: 12px; padding: 10px 12px; text-align: left; white-space: nowrap; border-bottom: 2px solid #9ca3af; overflow: hidden; text-overflow: ellipsis; }
    .abs-table td { padding: 10px 12px; border-bottom: 1px solid #f3f4f6; color: #1f2937; vertical-align: top; overflow: hidden; text-overflow: ellipsis; }
    .abs-table tr:last-child td { border-bottom: none; }
    .abs-table tr:hover td { background: #fafafa; }
    .abs-type-badge { display: inline-flex; align-items: center; padding: 2px 8px; border-radius: 10px; font-size: 11px; font-weight: 600; white-space: nowrap; }
    .abs-type-badge.medical    { background: #dbeafe; color: #1d4ed8; }
    .abs-type-badge.emergency  { background: #fef3c7; color: #92400e; }
    .abs-type-badge.hospital   { background: #fce7f3; color: #9d174d; }
    .abs-type-badge.quarantine { background: #dcfce7; color: #15803d; }
    .abs-type-badge.other      { background: #f3f4f6; color: #374151; }
    .abs-stack { display: none; }
    .abs-card { border: 1px solid #e5e7eb; border-radius: 8px; padding: 14px; margin-bottom: 10px; background: #fff; }
    .abs-card:last-child { margin-bottom: 0; }
    .abs-card-row { display: flex; padding: 5px 0; border-bottom: 1px solid #f9fafb; font-size: 13px; }
    .abs-card-row:last-child { border-bottom: none; padding-bottom: 0; }
    .abs-card-label { width: 120px; flex-shrink: 0; font-size: 11px; font-weight: 600; color: #6b7280; text-transform: uppercase; letter-spacing: 0.3px; padding-top: 1px; }
    .abs-card-value { flex: 1; color: #1f2937; font-size: 13px; word-break: break-word; }
    .abs-card-ref { font-size: 11px; font-weight: 700; color: #374151; background: #f3f4f6; display: inline-flex; align-items: center; padding: 2px 8px; border-radius: 4px; }
    @media (max-width: 700px) { .abs-table-wrap { display: none; } .abs-stack { display: block; } }
    .abs-submit-bar { display: flex; justify-content: flex-end; margin-bottom: 14px; }
    .abs-form-panel { display: none; background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 10px; padding: 20px 24px; margin-bottom: 16px; }
    .abs-form-panel.show { display: block; }
    .abs-form-title { font-size: 14px; font-weight: 600; color: #1f2937; margin-bottom: 16px; padding-bottom: 10px; border-bottom: 1px solid #e5e7eb; }
    .abs-form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px 24px; }
    .abs-form-field { display: flex; flex-direction: column; gap: 5px; }
    .abs-form-field label { font-size: 12px; font-weight: 600; color: #6b7280; }
    .abs-form-field input, .abs-form-field select { padding: 8px 10px; border: 1.5px solid #d1d5db; border-radius: 6px; font-size: 13px; background: #fff; transition: border-color 0.2s; }
    .abs-form-field input:focus, .abs-form-field select:focus { outline: none; border-color: #1a73e8; }
    .abs-form-field input:disabled { background: #f3f4f6; color: #6b7280; cursor: not-allowed; }
    .abs-form-footer { display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px; padding-top: 14px; border-top: 1px solid #e5e7eb; }
    @media (max-width: 600px) { .abs-form-grid { grid-template-columns: 1fr; } .abs-form-panel { padding: 14px; } }

    @media (max-width: 900px) {
      .sidebar { width: 200px; } .main-content { margin-left: 200px; padding: 20px; }
      .two-column { grid-template-columns: 1fr; gap: 0; }
      .column { border-right: none; padding-right: 0; } .column:last-child { padding-left: 0; }
      .half-width-container { max-width: 100%; }
      .input-wide { width: 100% !important; }
    }
    @media (max-width: 700px) {
      .sidebar { display: none; }
      .mobile-nav { display: block; }
      .main-content { margin-left: 0; padding: 12px; padding-bottom: 100px; }
      .profile-header { padding: 14px 14px 12px; }
      .profile-header-top { flex-direction: column; gap: 6px; }
      .profile-info h1 { font-size: 18px; }
      .profile-meta { text-align: left; }
      .profile-meta-item { font-size: 12px; }
      .profile-header-bottom { flex-direction: column; align-items: flex-start; gap: 8px; }
      .admin-switcher { flex-wrap: wrap; }
      .admin-switcher select { max-width: 100%; width: 100%; }
      .profile-section { padding: 12px; margin-bottom: 12px; }
      .section-header { flex-direction: column; align-items: flex-start; gap: 10px; margin-bottom: 12px; padding-bottom: 10px; }
      .section-title { font-size: 15px; }
      .section-actions { width: 100%; flex-wrap: wrap; }
      .section-actions .edit-btn { flex: 1; justify-content: center; }
      .section-actions .change-status-btn { flex: 1; justify-content: center; }
      .edit-actions { width: 100%; }
      .edit-actions.show { display: flex; width: 100%; }
      .edit-actions button { flex: 1; }
      .data-row { flex-direction: column; padding: 6px 0; }
      .data-label { width: 100%; margin-bottom: 2px; font-size: 11px; }
      .data-value { font-size: 13px; }
      .half-width-container { max-width: 100%; }
      .two-column { gap: 0; }
      .column { padding-right: 0; } .column:last-child { padding-left: 0; }
      .employment-card { padding: 12px; margin-bottom: 8px; }
      .employment-card-title { font-size: 12px; margin-bottom: 8px; padding-bottom: 6px; }
      .subsection { padding: 12px; margin-bottom: 8px; }
      .subsection-title { font-size: 12px; margin-bottom: 8px; padding-bottom: 6px; }
      .editable-field input, .editable-field select, .editable-field textarea { padding: 6px 8px; font-size: 13px; }
      .badge { padding: 2px 6px; font-size: 10px; }
      .expiry-badge { font-size: 10px; padding: 1px 6px; margin-left: 4px; }
      .doc-link, .upload-link { font-size: 10px; padding: 2px 8px; }
      .status-icon { width: 16px; height: 16px; }
      .status-icon svg { width: 10px; height: 10px; }
      .toast { bottom: 120px; left: 12px; right: 12px; transform: none; font-size: 13px; padding: 10px 16px; }
      .confirmation-modal { margin: 10px; }
      .confirmation-header { padding: 16px; }
      .confirmation-header h2 { font-size: 16px; }
      .confirmation-content { padding: 12px 16px; }
      .confirmation-section-title { font-size: 12px; padding: 6px 10px; }
      .confirmation-item { flex-direction: column; padding: 6px 0; font-size: 12px; }
      .confirmation-label { width: 100%; margin-bottom: 2px; }
      .confirmation-footer { padding: 12px 16px; }
      .status-modal { margin: 0; }
      .status-modal-header { padding: 16px; }
      .status-modal-body { padding: 16px; }
      .status-modal-footer { padding: 12px 16px; }
    }
  </style>
</head>
<body>
  <div class="loading-screen" id="loadingScreen">
    <div class="spinner"></div>
    <p>Checking your access...</p>
  </div>
  
  <div class="message-screen" id="invalidDomainScreen">
    <div class="message-icon error">!</div>
    <h2>Access Restricted</h2>
    <div class="email-badge" id="invalidEmail"></div>
    <p>Please use your company email address (@airasia.com) to access this portal.</p>
  </div>
  
  <div class="message-screen" id="notRegisteredScreen">
    <div class="message-icon info">+</div>
    <h2>Welcome!</h2>
    <div class="email-badge" id="newUserEmail"></div>
    <p>You are not registered in the system yet. Please complete the registration form to continue.</p>
    <button class="btn btn-primary" onclick="goToRegistration()">Start Registration</button>
  </div>
  
  <div class="profile-layout" id="profileLayout">
    <div class="sidebar">
      <div class="sidebar-header">
        <button class="back-btn" onclick="goToLanding()">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
          Back to Home
        </button>
        <div class="sidebar-title">My Profile</div>
      </div>
      <nav id="sidebarNav"></nav>
    </div>
    <div class="main-content">
      <div class="profile-header">
        <div class="profile-header-top">
          <div class="profile-info">
            <h1 id="profileName">
              <!-- name + status badge injected by renderProfile() -->
            </h1>
            <p id="profileRole"></p>
          </div>
          <div class="profile-meta">
            <div class="profile-meta-item">Staff No: <span id="profileStaffNo"></span></div>
            <div class="profile-meta-item">Email: <span id="profileEmail"></span></div>
          </div>
        </div>
        <div class="profile-header-bottom">
          <div class="last-updated" id="lastUpdated"></div>
          <div class="admin-switcher hidden" id="adminSwitcher">
            <span class="admin-badge">ADMIN</span>
            <span class="admin-switcher-label">Viewing as:</span>
            <select id="adminEmailSelect" onchange="switchViewUser(this.value)">
              <option value="">Loading users...</option>
            </select>
          </div>
        </div>
      </div>

      <div id="sectionsContainer"></div>
    </div>
    <div class="mobile-nav"><div class="mobile-nav-scroll" id="mobileNav"></div></div>
  </div>
  
  <div class="toast" id="toast"></div>
  <div class="saving-overlay" id="savingOverlay">
    <div class="spinner"></div>
    <p id="savingMessage" style="margin-top: 16px; color: #6b7280;">Saving changes...</p>
  </div>

  <!-- Change Status Modal -->
  <div class="status-modal-overlay" id="statusModalOverlay">
    <div class="status-modal">
      <div class="status-modal-header">
        <h2><span class="warning-icon">⚠️</span> LMS Departing — Staff Status Change</h2>
        <p class="status-modal-notice">
          This section is intended for staff who are <strong>leaving Line Maintenance Services (LMS)</strong>.<br>
          Proceed only if you intend to tender a <strong>resignation</strong> or are undergoing a <strong>transfer</strong> out of the department.<br><br>
          Once submitted, your profile status will be updated accordingly and this action is visible to management.
        </p>
      </div>
      <div class="status-modal-body">
        <div class="status-modal-field">
          <label>Reason for Departure *</label>
          <select id="statusReason">
            <option value="">Select reason...</option>
            <option value="Resigned">Resigned</option>
            <option value="Transfer">Transfer</option>
          </select>
        </div>
        <div class="status-modal-field">
          <label>Effective Date *</label>
          <input type="date" id="statusDate">
        </div>
      </div>
      <div class="status-modal-footer">
        <button class="btn btn-outline-grey" onclick="closeStatusModal()">Cancel</button>
        <button class="btn btn-grey" id="revertStatusBtn" onclick="revertStatusChange()" style="display:none;">↩ Revert to Active</button>
        <button class="btn btn-danger" onclick="submitStatusChange()">Confirm &amp; Submit</button>
      </div>
    </div>
  </div>

  <div class="confirmation-overlay" id="confirmationOverlay">
    <div class="confirmation-modal">
      <div class="confirmation-header">
        <h2>Confirm Changes</h2>
        <p>Please review your changes before saving:</p>
      </div>
      <div class="confirmation-content" id="confirmationContent"></div>
      <div class="confirmation-footer">
        <button class="btn btn-grey" onclick="closeConfirmation()">Cancel</button>
        <button class="btn btn-primary" onclick="confirmSave()">Confirm &amp; Save</button>
      </div>
    </div>
  </div>
  
  <script>
    var ADMIN_EMAIL = 'limhongkhai@airasia.com';
    var currentUserEmail = '';
    var isAdmin = false;
    var currentViewingEmail = '';

    var icons = {
      edit: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>',
      document: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>',
      upload: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>',
      check: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>',
      cross: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>',
      file: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/><polyline points="13 2 13 9 20 9"/></svg>'
    };
    
    var sectionConfig = {
      'department_information_section': { name: 'Department Information' },
      'previous_employment_section': { name: 'Previous Employment' },
      'caam_licens_section': { name: 'CAAM License' },
      'ade_approval_section': { name: 'ADE Approval' },
      'personal_details_section': { name: 'Personal Details' },
      'aiport_authority_section': { name: 'Airport Authority' }
    };
    
    var fieldLabels = {
      'email_address': 'Email Address', 'full_name': 'Full Name', 'staff_no': 'Staff No',
      'joining_date': 'Joining Date', 'date_of_birth': 'Date of Birth', 'age': 'Age',
      'nationality': 'Nationality', 'ic_no': 'IC No', 'ic_pdf_link': 'IC Document',
      'gender': 'Gender', 'phone_no': 'Phone No', 'designation': 'Designation',
      'team': 'Team', 'main_trade': 'Main Trade', 'year_joined_aviation': 'Year Joined Aviation',
      'years_in_aviation': 'Years in Aviation','immediate_superior': 'Immediate Superior',
      'shift': 'Shift', 'nickname': 'Nickname', 'no_of_employment': 'No. of Employment',
      'company_last': 'Company', 'section_last': 'Section', 'designation_last': 'Designation',
      'type_last': 'Aircraft Type', 'start_date_last': 'Start Date', 'end_date_last': 'End Date', 'year_last': 'Years',
      'company_second_last': 'Company', 'section_second_last': 'Section', 'designation_second_last': 'Designation',
      'type_second_last': 'Aircraft Type', 'start_date_second_last': 'Start Date', 'end_date_second_last': 'End Date', 'year_second_last': 'Years',
      'company_third_last': 'Company', 'section_third_last': 'Section', 'designation_third_last': 'Designation',
      'type_third_last': 'Aircraft Type', 'start_date_third_last': 'Start Date', 'end_date_third_last': 'End Date', 'year_third_last': 'Years',
      'available_license': 'Available License', 'amel_license_category': 'AMEL License Category',
      'amel_license': 'AMEL License No', 'amel_pdf_link': 'AMEL Document',
      'b1_type_rating': 'B1 Type Rating', 'b2_type_rating': 'B2 Type Rating', 'c_type_rating': 'C Type Rating',
      'amel_issue_date': 'AMEL Issue Date', 'amel_license_expiry': 'AMEL Expiry Date',
      'amtl_license_no': 'AMTL License No', 'amtl_license_category': 'AMTL License Category',
      'amtl_pdf_link': 'AMTL Document', 'a1_type_rating': 'A1 Type Rating',
      'amtl_issue_date': 'AMTL Issue Date', 'amtl_license_expiry': 'AMTL Expiry Date',
      'year_establish': 'Year Established', 'year_signing': 'Years Signing',
      'ade_approval_no': 'Approval No', 'ade_approval_pdf_link': 'Approval Document',
      'ade_system_code': 'System Code',
      'b1_ade_approval_type': 'B1.1 Approval Type', 'b2_ade_approval_type': 'B2 Approval Type',
      'c_ade_approval_type': 'C Approval Type', 'a_ade_approval_type': 'A Approval Type',
      'ade_approval_expiry': 'Approval Expiry', 'egr': 'EGR', 'boroscope': 'Boroscope', 'compass_swign': 'Compass Swing',
      'address': 'Address', 'state': 'State', 'passport_no': 'Passport No',
      'passport_pdf_link': 'Passport Document', 'passport_expiry': 'Passport Expiry',
      'next_of_kin_name': 'Next of Kin Name', 'relationship': 'Relationship',
      'next_of_kin_contact_no': 'Next of Kin Contact', 'race': 'Race',
      'mab_pass_expiry_date': 'MAB Pass Expiry', 'mab_pass_pdf_link': 'MAB Pass Document',
      'adp_no': 'ADP No', 'adp_expiry_date': 'ADP Expiry', 'adp_pdf_link': 'ADP Document',
      'limitation': 'Limitation'
    };
    
    var fieldDocumentMap = { 'ic_no': 'ic_pdf_link', 'amel_license': 'amel_pdf_link', 'amtl_license_no': 'amtl_pdf_link', 'passport_no': 'passport_pdf_link', 'ade_approval_no': 'ade_approval_pdf_link', 'adp_no': 'adp_pdf_link', 'mab_pass_expiry_date': 'mab_pass_pdf_link' };
    var documentFields = ['ic_pdf_link', 'amel_pdf_link', 'amtl_pdf_link', 'ade_approval_pdf_link', 'passport_pdf_link', 'mab_pass_pdf_link', 'adp_pdf_link', 'folder_link'];
    var expiryFields = ['amel_license_expiry', 'amtl_license_expiry', 'ade_approval_expiry', 'passport_expiry', 'mab_pass_expiry_date', 'adp_expiry_date'];
    var headerFields = ['email_address', 'full_name', 'staff_no'];
    var deptEditableFields = ['phone_no', 'nickname', 'year_joined_aviation', 'date_of_birth', 'nationality', 'gender', 'designation', 'ic_no'];
    var skipFields = ['department_information_section', 'previous_employment_section', 'caam_licens_section', 'ade_approval_section', 'personal_details_section', 'aiport_authority_section', 'last_update_timestamp', 'folder_link', 'role', 'age', 'status', 'status_date', 'immediate_superior'];
    var decimalFields = ['years_in_aviation'];
    var pendingConfirmationData = {};
    var notAvailFields = ['passport_no', 'mab_pass_expiry_date', 'adp_no', 'adp_expiry_date'];
    var pdfOnlySections = ['caam_licens_section', 'ade_approval_section'];
    var sectionOptions = ['Continuing Airworthiness', 'Base Maintenance', 'Line Maintenance', 'Leasing/Commercial', 'Materials', 'NDT', 'Production Planning', 'Procurement', 'Quality Assurance', 'Technical Service', 'Technical Records', 'Training', 'Workshop'];
    var designationOptions = ['Manager', 'Licensed Aircraft Engineer', 'QAI', 'Instructor', 'Certifying Technician', 'Technician', 'NDT Inspector', 'Store Inspector', 'Admin', 'TSE/Planning/Records Executive', 'Trainee'];
    var deptDesignationOptions = ['Driver - Non Technical', 'Technician - Cat A', 'Technician', 'LAE - B1', 'LAE - B2', 'Lead Engineer', 'Lead Technician', 'Lead Engineer Ops', 'Maintenance Supervisor', 'Manager'];
    var licenseOptions = ['CAAM AMEL (B/C)', 'CAAM AMTL (A)', 'None'];
    var amelCategoryOptions = ['B1.1', 'B1.1 Limited', 'B2', 'B2 Limited', 'C'];
    var systemCodeOptions = ['A', 'B', 'C', 'G', 'K', 'M'];
    var compassSwingOptions = ['Avail', 'Not Avail'];
    var stateOptions = ['Johor', 'Kedah', 'Kelantan', 'Kuala Lumpur', 'Labuan', 'Melaka', 'Negeri Sembilan', 'Pahang', 'Penang', 'Perak', 'Perlis', 'Putrajaya', 'Sabah', 'Sarawak', 'Selangor', 'Terengganu'];
    var relationshipOptions = ['Spouse', 'Parent', 'Sibling', 'Child', 'Other'];
    var monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    var employmentGroups = {
      'last': ['company_last', 'section_last', 'designation_last', 'type_last', 'start_date_last', 'end_date_last', 'year_last'],
      'second_last': ['company_second_last', 'section_second_last', 'designation_second_last', 'type_second_last', 'start_date_second_last', 'end_date_second_last', 'year_second_last'],
      'third_last': ['company_third_last', 'section_third_last', 'designation_third_last', 'type_third_last', 'start_date_third_last', 'end_date_third_last', 'year_third_last']
    };
    var amelFields = ['amel_license_category', 'amel_license', 'b1_type_rating', 'b2_type_rating', 'c_type_rating', 'amel_issue_date', 'amel_license_expiry'];
    var amtlFields = ['amtl_license_category', 'amtl_license_no', 'a1_type_rating', 'amtl_issue_date', 'amtl_license_expiry'];
    var multiSelectData = {};
    var userData = {};
    var editMode = {};
    var pendingFileUploads = {};
    var typeRatingList = [];
    var nationalityList = [];
    var approvalTypes = {};
    var pendingLicenseChanges = { available_license: null, amel_license_category: null };
    var mandatoryFields = {
      employment: {
        last: ['company_last', 'section_last', 'designation_last', 'type_last', 'start_date_last', 'end_date_last'],
        second_last: ['company_second_last', 'section_second_last', 'designation_second_last', 'type_second_last', 'start_date_second_last', 'end_date_second_last'],
        third_last: ['company_third_last', 'section_third_last', 'designation_third_last', 'type_third_last', 'start_date_third_last', 'end_date_third_last']
      },
      amel: ['amel_license_category', 'amel_license', 'b1_type_rating', 'amel_issue_date', 'amel_license_expiry'],
      amtl: ['amtl_license_category', 'amtl_license_no', 'a1_type_rating', 'amtl_issue_date', 'amtl_license_expiry']
    };
    var activeMandatoryFields = [];
    var originalEmploymentCount = 0;
    var originalLicenses = [];
    
    document.addEventListener('DOMContentLoaded', function() {
      var attempts = 0;
      var maxAttempts = 2;

      function tryLoad() {
        attempts++;
        var timeoutId = setTimeout(function() {
          if (attempts < maxAttempts) {
            console.warn('Attempt ' + attempts + ' timed out, retrying...');
            tryLoad();
          } else {
            document.getElementById('loadingScreen').style.display = 'none';
            document.getElementById('invalidDomainScreen').querySelector('h2').textContent = 'Connection Slow';
            document.getElementById('invalidDomainScreen').querySelector('p').innerHTML =
              'The server is taking too long. <br><br>' +
              '<button class="btn btn-primary" onclick="location.reload()">Try Again</button>';
            document.getElementById('invalidDomainScreen').classList.add('show');
          }
        }, 30000);

        google.script.run
          .withSuccessHandler(function(result) {
            clearTimeout(timeoutId);
            handleProfileInit(result);
          })
          .withFailureHandler(function(error) {
            clearTimeout(timeoutId);
            if (attempts < maxAttempts) tryLoad();
            else handleError(error);
          })
          .getProfileInitData();
      }

      tryLoad();
    });

    function handleProfileInit(result) {
      document.getElementById('loadingScreen').style.display = 'none';

      if (result.status === 'invalid_domain') {
        document.getElementById('invalidEmail').textContent = result.email || 'Unknown';
        document.getElementById('invalidDomainScreen').classList.add('show');
        return;
      }

      if (result.status === 'not_registered') {
        document.getElementById('newUserEmail').textContent = result.email;
        document.getElementById('notRegisteredScreen').classList.add('show');
        return;
      }

      if (result.status === 'registered') {
        currentUserEmail = result.email || '';
        currentViewingEmail = currentUserEmail;
        isAdmin = (currentUserEmail.toLowerCase() === ADMIN_EMAIL.toLowerCase());
        userData = result.data;

        // ── Apply dropdown data from the SAME server call ──────────────────────
        var dd = result.dropdowns || {};
        typeRatingList = dd.typeRatings || ['A320', 'A321', 'A330', 'A350', 'B737', 'B777', 'B787', 'ATR72'];
        if (typeRatingList.indexOf('No Type Task Rating') === -1) {
          typeRatingList.unshift('No Type Task Rating');
        }
        nationalityList = dd.nationalities || ['Malaysia', 'Non-Malaysia'];
        approvalTypes = dd.approvalTypes || {};

        initMultiSelectData();
        renderProfile(result.data, result.headers);
        document.getElementById('profileLayout').classList.add('show');

        if (isAdmin) {
          document.getElementById('adminSwitcher').classList.remove('hidden');
          loadAdminEmailList(currentUserEmail);
        }
      }
    }

    // ── Change Status Modal ───────────────────────────────────────────────────

    function openStatusModal() {
      var statusVal = userData.status || '';
      var dateVal   = userData.status_date || '';
      var isDeparted = (statusVal === 'Resigned' || statusVal === 'Transfer');

      // Pre-fill if already set
      document.getElementById('statusReason').value = statusVal || '';
      document.getElementById('statusDate').value = dateVal ? dateVal.substring(0, 10) : '';

      // Only show Revert button when a departure status already exists
      document.getElementById('revertStatusBtn').style.display = isDeparted ? 'inline-flex' : 'none';

      document.getElementById('statusModalOverlay').classList.add('show');
    }

    function closeStatusModal() {
      document.getElementById('statusModalOverlay').classList.remove('show');
    }

    function revertStatusChange() {
      if (!confirm('This will revert the staff status back to Active and clear the departure record. Are you sure?')) return;

      closeStatusModal();

      document.getElementById('savingMessage').textContent = 'Reverting status...'; 
      document.getElementById('savingOverlay').classList.add('show');

      google.script.run
        .withSuccessHandler(function(result) {
          document.getElementById('savingOverlay').classList.remove('show');
          if (result.success) {
            showToast('Status reverted — staff is now Active');
            if (isAdmin && currentViewingEmail && currentViewingEmail !== currentUserEmail) {
              switchViewUser(currentViewingEmail);
            } else {
              reloadCurrentProfile();
            }
          } else {
            showToast('Error: ' + result.message);
          }
        })
        .withFailureHandler(function(err) {
          document.getElementById('savingOverlay').classList.remove('show');
          showToast('Error: ' + (err.message || err));
        })
        .updateUserData({ status: '', status_date: '' });
    }

    function submitStatusChange() {
      var reason = document.getElementById('statusReason').value;
      var date   = document.getElementById('statusDate').value;
      if (!reason) { showToast('Please select a reason (Resigned or Transfer)'); return; }
      if (!date)   { showToast('Please select an effective date'); return; }

      closeStatusModal();

      document.getElementById('savingMessage').textContent = 'Updating status...';
      document.getElementById('savingOverlay').classList.add('show');

      var updates = { status: reason, status_date: date };

      google.script.run
        .withSuccessHandler(function(result) {
          document.getElementById('savingOverlay').classList.remove('show');
          if (result.success) {
            showToast('Status updated to: ' + reason);
            // Refresh profile
            if (isAdmin && currentViewingEmail && currentViewingEmail !== currentUserEmail) {
              switchViewUser(currentViewingEmail);
            } else {
              reloadCurrentProfile();
            }
          } else {
            showToast('Error: ' + result.message);
          }
        })
        .withFailureHandler(function(err) {
          document.getElementById('savingOverlay').classList.remove('show');
          showToast('Error: ' + (err.message || err));
        })
        .updateUserData(updates);
    }

    // ── Admin email switcher ──────────────────────────────────────────────────

    function loadAdminEmailList(selectedEmail) {
      var switcher = document.getElementById('adminSwitcher');
      switcher.classList.add('loading');
      google.script.run
        .withSuccessHandler(function(emails) {
          switcher.classList.remove('loading');
          var select = document.getElementById('adminEmailSelect');
          select.innerHTML = '';
          if (!emails || emails.length === 0) { select.innerHTML = '<option value="">No users found</option>'; return; }
          for (var i = 0; i < emails.length; i++) {
            var opt = document.createElement('option');
            opt.value = emails[i]; opt.textContent = emails[i];
            if (emails[i].toLowerCase() === selectedEmail.toLowerCase()) opt.selected = true;
            select.appendChild(opt);
          }
        })
        .withFailureHandler(function(err) {
          switcher.classList.remove('loading');
          document.getElementById('adminEmailSelect').innerHTML = '<option value="">Error loading users</option>';
        })
        .getAllUserEmails();
    }

    function switchViewUser(targetEmail) {
      if (!targetEmail || !isAdmin) return;
      currentViewingEmail = targetEmail;
      document.getElementById('savingMessage').textContent = 'Loading profile...';
      document.getElementById('savingOverlay').classList.add('show');
      google.script.run
        .withSuccessHandler(function(result) {
          document.getElementById('savingOverlay').classList.remove('show');
          if (!result || result.status !== 'registered') {
            showToast('Could not load profile for ' + targetEmail);
            return;
          }
          editMode = {}; pendingFileUploads = {}; multiSelectData = {}; activeMandatoryFields = [];
          pendingLicenseChanges = { available_license: null, amel_license_category: null };
          disciplinaryLoaded = false; absenceLoaded = false; superiorListLoaded = false;
          userData = result.data;

          // Reuse dropdowns already in memory — no need to refetch
          initMultiSelectData();
          document.getElementById('sectionsContainer').innerHTML = '';
          document.getElementById('sidebarNav').innerHTML = '';
          document.getElementById('mobileNav').innerHTML = '';
          renderProfile(result.data, result.headers);
        })
        .withFailureHandler(function(err) {
          document.getElementById('savingOverlay').classList.remove('show');
          showToast('Error: ' + (err.message || err));
        })
        .getUserDataByEmail(targetEmail);
    }

    function reloadCurrentProfile() {
      document.getElementById('savingMessage').textContent = 'Loading latest data...';
      document.getElementById('savingOverlay').classList.add('show');
      google.script.run
        .withSuccessHandler(function(result) {
          document.getElementById('savingOverlay').classList.remove('show');
          if (!result || result.status !== 'registered') {
            showToast('Could not reload profile.');
            return;
          }
          editMode = {}; pendingFileUploads = {}; multiSelectData = {}; activeMandatoryFields = [];
          pendingLicenseChanges = { available_license: null, amel_license_category: null };
          disciplinaryLoaded = false; absenceLoaded = false; superiorListLoaded = false;
          userData = result.data;

          // Reuse dropdowns already in memory — no need to refetch
          initMultiSelectData();
          document.getElementById('sectionsContainer').innerHTML = '';
          document.getElementById('sidebarNav').innerHTML = '';
          document.getElementById('mobileNav').innerHTML = '';
          renderProfile(result.data, result.headers);
          var firstNav = document.querySelector('.nav-item');
          if (firstNav) showSection(firstNav.getAttribute('data-section'));
        })
        .withFailureHandler(function(err) {
          document.getElementById('savingOverlay').classList.remove('show');
          showToast('Error reloading: ' + (err.message || err));
        })
        .getProfileInitData();
    }
    
    function initMultiSelectData() {
      var fields = ['section_last', 'section_second_last', 'section_third_last', 'designation_last', 'designation_second_last', 'designation_third_last', 'type_last', 'type_second_last', 'type_third_last', 'available_license', 'amel_license_category', 'b1_type_rating', 'b2_type_rating', 'c_type_rating', 'a1_type_rating', 'ade_system_code', 'b1_ade_approval_type', 'b2_ade_approval_type', 'c_ade_approval_type', 'a_ade_approval_type', 'egr', 'boroscope'];
      for (var i = 0; i < fields.length; i++) {
        var field = fields[i];
        var value = userData[field] || '';
        multiSelectData[field] = value ? value.split(',').map(function(v) { return v.trim(); }).filter(function(v) { return v; }) : [];
      }
    }
    
    function handleError(error) {
      document.getElementById('loadingScreen').style.display = 'none';
      document.getElementById('invalidDomainScreen').querySelector('h2').textContent = 'Error';
      document.getElementById('invalidDomainScreen').querySelector('p').textContent = 'An error occurred: ' + (error.message || error);
      document.getElementById('invalidDomainScreen').classList.add('show');
    }
    
    function goToRegistration() {
      google.script.run.withSuccessHandler(function(url) { window.top.location.href = url + '?page=register'; }).withFailureHandler(function() {
        window.top.location.href = window.location.href.split('?')[0] + '?page=register';
      }).getScriptUrl();
    }

    function goToLanding() {
      google.script.run.withSuccessHandler(function(url) {
        window.top.location.href = url;
      }).withFailureHandler(function() {
        window.top.location.href = window.location.href.split('?')[0];
      }).getScriptUrl();
    }
    
    function showToast(message) {
      var toast = document.getElementById('toast');
      toast.textContent = message;
      toast.classList.add('show');
      setTimeout(function() { toast.classList.remove('show'); }, 3000);
    }
    
    function toggleEditMode(sectionId) {
      editMode[sectionId] = !editMode[sectionId];
      var section = document.querySelector('.profile-section[data-section="' + sectionId + '"]');
      var editBtn = section.querySelector('.edit-btn');
      var editActions = section.querySelector('.edit-actions');
      var changeStatusBtn = section.querySelector('.change-status-btn');
      var editableFields = section.querySelectorAll('.editable-field');
      var displayValues = section.querySelectorAll('.display-value');
      for (var i = 0; i < editableFields.length; i++) editableFields[i].classList.toggle('show', editMode[sectionId]);
      for (var j = 0; j < displayValues.length; j++) displayValues[j].classList.toggle('hidden', editMode[sectionId]);
      if (editMode[sectionId]) {
        editBtn.style.display = 'none';
        if (changeStatusBtn) changeStatusBtn.style.display = 'none';
        editActions.classList.add('show');
        pendingFileUploads[sectionId] = {};
        updateAllMultiSelectBadges(sectionId);
        if (sectionId === 'previous_employment_section') originalEmploymentCount = parseInt(userData.no_of_employment) || 0;
        if (sectionId === 'caam_licens_section') { originalLicenses = (userData.available_license || '').split(',').map(function(v) { return v.trim(); }).filter(function(v) { return v; }); updateAmelCategoryOptions(); updateTypeRatingOptions(); }
        if (sectionId === 'ade_approval_section') { updateApprovalTypeDropdowns(); updateEgrBoroscopeDropdowns(); }
        activeMandatoryFields = [];
      } else {
        editBtn.style.display = 'flex';
        if (changeStatusBtn) changeStatusBtn.style.display = 'flex';
        editActions.classList.remove('show');
      }
    }
    
    function cancelEdit(sectionId) {
      editMode[sectionId] = false;
      initMultiSelectData();
      pendingFileUploads[sectionId] = {};
      pendingLicenseChanges.available_license = null;
      pendingLicenseChanges.amel_license_category = null;
      clearMandatoryMarkers(sectionId);
      if (sectionId === 'previous_employment_section') originalEmploymentCount = parseInt(userData.no_of_employment) || 0;
      if (sectionId === 'caam_licens_section') originalLicenses = (userData.available_license || '').split(',').map(function(v) { return v.trim(); }).filter(function(v) { return v; });
      var section = document.querySelector('.profile-section[data-section="' + sectionId + '"]');
      var editableFields = section.querySelectorAll('.editable-field');
      var displayValues = section.querySelectorAll('.display-value');
      for (var i = 0; i < editableFields.length; i++) editableFields[i].classList.remove('show');
      for (var j = 0; j < displayValues.length; j++) displayValues[j].classList.remove('hidden');
      section.querySelector('.edit-btn').style.display = 'flex';
      var changeStatusBtn = section.querySelector('.change-status-btn');
      if (changeStatusBtn) changeStatusBtn.style.display = 'flex';
      section.querySelector('.edit-actions').classList.remove('show');
      var fileSelectedDivs = section.querySelectorAll('.file-selected');
      for (var k = 0; k < fileSelectedDivs.length; k++) fileSelectedDivs[k].remove();
      if (sectionId === 'previous_employment_section') {
        var empSelect = section.querySelector('[data-field="no_of_employment"]');
        if (empSelect) empSelect.value = originalEmploymentCount;
        updateEmploymentVisibility(originalEmploymentCount);
      }
      if (sectionId === 'caam_licens_section') updateLicenseSections();
    }
    
    function saveChanges(sectionId) {
      var section = document.querySelector('.profile-section[data-section="' + sectionId + '"]');
      var errorFields = section.querySelectorAll('.validation-error-field');
      for (var i = 0; i < errorFields.length; i++) errorFields[i].classList.remove('validation-error-field');
      var missingFields = validateMandatoryFields(sectionId);
      if (missingFields.length > 0) { showToast('Please fill in: ' + missingFields.slice(0, 3).join(', ') + (missingFields.length > 3 ? ' and ' + (missingFields.length - 3) + ' more' : '')); return; }
      var changes = collectChanges(sectionId);
      var fileUploads = pendingFileUploads[sectionId] || {};
      var hasChanges = Object.keys(changes).length > 0;
      var hasFiles = Object.keys(fileUploads).length > 0;
      if (!hasChanges && !hasFiles) { showToast('No changes to save'); return; }
      pendingConfirmationData = { sectionId: sectionId, changes: changes, fileUploads: fileUploads };
      showConfirmation(sectionId, changes, fileUploads);
    }

    function showConfirmation(sectionId, changes, fileUploads) {
      var content = document.getElementById('confirmationContent');
      var hasChanges = Object.keys(changes).length > 0;
      var hasFiles = Object.keys(fileUploads).length > 0;
      if (!hasChanges && !hasFiles) {
        content.innerHTML = '<div class="no-changes"><div class="no-changes-icon">✓</div><p>No changes detected</p></div>';
      } else {
        var html = '<div class="confirmation-section">';
        html += '<div class="confirmation-section-title">' + (sectionConfig[sectionId] ? sectionConfig[sectionId].name : sectionId) + '</div>';
        for (var field in changes) {
          var change = changes[field];
          var label = formatLabel(field);
          var oldDisplay = change.oldValue || '<em>Empty</em>';
          var newDisplay = change.newValue || '<em>Empty</em>';
          if (field.indexOf('date') !== -1 || field.indexOf('expiry') !== -1) { if (change.oldValue) oldDisplay = formatDateDisplay(change.oldValue); if (change.newValue) newDisplay = formatDateDisplay(change.newValue); }
          if (field === 'year_establish') { oldDisplay = formatMonthYear(change.oldValue) || '<em>Empty</em>'; newDisplay = formatMonthYear(change.newValue) || '<em>Empty</em>'; }
          html += '<div class="confirmation-item"><div class="confirmation-label">' + label + ':</div><div class="confirmation-values"><span class="confirmation-old">' + oldDisplay + '</span><span class="confirmation-arrow">→</span><span class="confirmation-new">' + newDisplay + '</span></div></div>';
        }
        for (var fileField in fileUploads) {
          var fileData = fileUploads[fileField];
          var fileLabel = formatLabel(fileField.replace('_pdf_link', '').replace('_link', ''));
          html += '<div class="confirmation-item"><div class="confirmation-label">' + fileLabel + ':</div><div class="confirmation-values"><span class="confirmation-file">' + icons.file + ' ' + fileData.name + '</span></div></div>';
        }
        html += '</div>';
        content.innerHTML = html;
      }
      document.getElementById('confirmationOverlay').classList.add('show');
    }

    function formatDateDisplay(dateValue) {
      if (!dateValue) return '';
      try { var d = new Date(dateValue); if (isNaN(d.getTime())) return dateValue; return d.toLocaleDateString('en-MY', { year: 'numeric', month: 'short', day: 'numeric' }); } catch (e) { return dateValue; }
    }

    function closeConfirmation() {
      document.getElementById('confirmationOverlay').classList.remove('show');
      pendingConfirmationData = {};
    }

    function confirmSave() {
      document.getElementById('confirmationOverlay').classList.remove('show');
      var sectionId = pendingConfirmationData.sectionId;
      var changes = pendingConfirmationData.changes;
      var fileUploads = pendingConfirmationData.fileUploads;
      var updates = {};
      for (var field in changes) updates[field] = changes[field].newValue;
      var hasFiles = Object.keys(fileUploads).length > 0;
      var hasUpdates = Object.keys(updates).length > 0;

      document.getElementById('savingMessage').textContent = 'Saving changes...';
      document.getElementById('savingOverlay').classList.add('show');

      if (hasFiles && hasUpdates) {
        google.script.run
          .withSuccessHandler(function(result) {
            if (!result.success) { document.getElementById('savingOverlay').classList.remove('show'); showToast('Error: ' + result.message); return; }
            document.getElementById('savingMessage').textContent = 'Uploading files...';
            uploadFiles(sectionId, fileUploads, function(fileUrls) {
              var fileUpdates = {};
              for (var f in fileUrls) fileUpdates[f] = fileUrls[f];
              if (Object.keys(fileUpdates).length > 0) saveUpdatesToServer(fileUpdates);
              else { document.getElementById('savingMessage').textContent = 'Loading latest data...'; setTimeout(function() { if (isAdmin && currentViewingEmail && currentViewingEmail !== currentUserEmail) { document.getElementById('savingOverlay').classList.remove('show'); switchViewUser(currentViewingEmail); } else reloadCurrentProfile(); }, 500); }
            });
          })
          .withFailureHandler(function(error) { document.getElementById('savingOverlay').classList.remove('show'); showToast('Error saving: ' + (error.message || error)); })
          .updateUserData(updates);
      } else if (hasFiles) {
        document.getElementById('savingMessage').textContent = 'Uploading files...';
        uploadFiles(sectionId, fileUploads, function(fileUrls) {
          var fileUpdates = {};
          for (var f in fileUrls) fileUpdates[f] = fileUrls[f];
          if (Object.keys(fileUpdates).length > 0) saveUpdatesToServer(fileUpdates);
          else { document.getElementById('savingMessage').textContent = 'Loading latest data...'; setTimeout(function() { if (isAdmin && currentViewingEmail && currentViewingEmail !== currentUserEmail) { document.getElementById('savingOverlay').classList.remove('show'); switchViewUser(currentViewingEmail); } else reloadCurrentProfile(); }, 500); }
        });
      } else {
        saveUpdatesToServer(updates);
      }

      pendingLicenseChanges.available_license = null;
      pendingLicenseChanges.amel_license_category = null;
      pendingConfirmationData = {};
    }

    function collectChanges(sectionId) {
      var changes = {};
      var section = document.querySelector('.profile-section[data-section="' + sectionId + '"]');
      var inputs = section.querySelectorAll('[data-field]');
      for (var i = 0; i < inputs.length; i++) {
        var input = inputs[i];
        if (!input.disabled && input.type !== 'hidden') {
          var field = input.dataset.field;
          var newValue = input.value;
          var oldValue = userData[field] || '';
          if (field === 'phone_no' || field === 'next_of_kin_contact_no') {
            newValue = newValue.replace(/^\+/, '');
            if (newValue && !/^60/.test(newValue)) newValue = '60' + newValue;
            var normalizedOld = String(oldValue).replace(/^\+/, '');
            if (normalizedOld && !/^60/.test(normalizedOld) && normalizedOld.length > 0) normalizedOld = '60' + normalizedOld;
            if (newValue.trim() !== normalizedOld.trim()) changes[field] = { oldValue: oldValue, newValue: newValue };
            continue;
          }
          if (field === 'ade_approval_no' && newValue) newValue = 'ADE' + newValue;
          if (String(newValue).trim() !== String(oldValue).trim()) changes[field] = { oldValue: oldValue, newValue: newValue };
        }
      }
      var monthSel = section.querySelector('#year_establish_month');
      var yearSel = section.querySelector('#year_establish_year');
      if (monthSel && yearSel && monthSel.value && yearSel.value) {
        var newYearEstablish = yearSel.value + '-' + monthSel.value;
        var oldYearEstablish = userData['year_establish'] || '';
        if (newYearEstablish !== oldYearEstablish) changes['year_establish'] = { oldValue: oldYearEstablish, newValue: newYearEstablish };
      }
      var keys = Object.keys(multiSelectData);
      for (var j = 0; j < keys.length; j++) {
        var field = keys[j];
        if (section.querySelector('[data-multiselect="' + field + '"]')) {
          var newValue = multiSelectData[field].join(', ');
          var oldValue = userData[field] || '';
          if (newValue !== oldValue) changes[field] = { oldValue: oldValue, newValue: newValue };
        }
      }
      return changes;
    }
    
    function saveUpdatesToServer(updates) {
      google.script.run.withSuccessHandler(function(result) {
        if (result.success) {
          document.getElementById('savingMessage').textContent = 'Loading latest data...';
          setTimeout(function() {
            if (isAdmin && currentViewingEmail && currentViewingEmail !== currentUserEmail) {
              document.getElementById('savingOverlay').classList.remove('show');
              switchViewUser(currentViewingEmail);
            } else {
              reloadCurrentProfile();
            }
          }, 500);
        } else {
          document.getElementById('savingOverlay').classList.remove('show');
          showToast('Error: ' + result.message);
        }
      }).withFailureHandler(function(error) {
        document.getElementById('savingOverlay').classList.remove('show');
        showToast('Error saving changes: ' + (error.message || error));
      }).updateUserData(updates);
    }
    
    function uploadFiles(sectionId, fileUploads, callback) {
      var fields = Object.keys(fileUploads);
      var uploadedUrls = {};
      var uploadCount = 0;
      var totalFiles = fields.length;
      if (fields.length === 0) { callback(uploadedUrls); return; }
      for (var i = 0; i < fields.length; i++) {
        (function(field, index) {
          var fileData = fileUploads[field];
          document.getElementById('savingMessage').textContent = 'Uploading file ' + (index + 1) + ' of ' + totalFiles + '...';
          google.script.run.withSuccessHandler(function(result) {
            if (result.success) uploadedUrls[field] = result.url;
            uploadCount++;
            if (uploadCount === fields.length) callback(uploadedUrls);
          }).withFailureHandler(function(error) {
            console.error('Error uploading ' + field + ':', error);
            uploadCount++;
            if (uploadCount === fields.length) callback(uploadedUrls);
          }).uploadFile(fileData.data, fileData.name, fileData.mimeType, field);
        })(fields[i], i);
      }
    }
    
    function extractUrl(value) {
      if (!value) return null;
      var strValue = String(value).trim();
      if (strValue.indexOf('http') === 0) return strValue;
      var hyperlinkMatch = strValue.match(/=?HYPERLINK\s*\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*\)/i);
      if (hyperlinkMatch) return hyperlinkMatch[1];
      var urlMatch = strValue.match(/https?:\/\/[^\s"'<>]+/);
      return urlMatch ? urlMatch[0] : null;
    }
    
    function getExpiryBadge(dateValue) {
      if (!dateValue) return '';
      var today = new Date(); today.setHours(0, 0, 0, 0);
      var expiryDate = dateValue instanceof Date ? new Date(dateValue) : new Date(dateValue);
      if (isNaN(expiryDate.getTime())) return '';
      expiryDate.setHours(0, 0, 0, 0);
      var diffDays = Math.ceil((expiryDate - today) / (1000 * 60 * 60 * 24));
      if (diffDays < 0) return '<span class="expiry-badge expired">Expired</span>';
      if (diffDays <= 90) return '<span class="expiry-badge critical">Expires in ' + diffDays + ' days</span>';
      if (diffDays <= 180) return '<span class="expiry-badge warning">Expires in ' + diffDays + ' days</span>';
      return '';
    }
    
    function getNotAvailBadge(field, value) { if (notAvailFields.indexOf(field) !== -1 && !value) return '<span class="not-avail-badge">Not Avail</span>'; return ''; }
    var valueNotAvailFields = ['egr', 'boroscope', 'compass_swign'];
    function getValueNotAvailBadge(field, value) { if (valueNotAvailFields.indexOf(field) !== -1 && String(value || '').trim() === 'Not Avail') return '<span class="not-avail-badge">Not Avail</span>'; return ''; }
    function formatDecimalValue(value) { if (value === null || value === undefined || value === '') return '-'; var n = parseFloat(value); return !isNaN(n) ? n.toFixed(1) : String(value); }
    function formatValue(value, field) { if (value === null || value === undefined || value === '') return '-'; return decimalFields.indexOf(field) !== -1 ? formatDecimalValue(value) : String(value); }
    function formatYearsValue(value) { if (value === null || value === undefined || value === '') return '-'; var n = parseFloat(value); return !isNaN(n) ? n.toFixed(1) : value; }
    function formatDateForInput(value) { if (!value) return ''; if (value instanceof Date) return value.toISOString().split('T')[0]; var d = new Date(value); return isNaN(d.getTime()) ? value : d.toISOString().split('T')[0]; }
    function formatDate(dateString) { if (!dateString) return ''; try { return new Date(dateString).toLocaleDateString('en-MY', { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' }); } catch (e) { return dateString; } }
    function formatMonthYear(value) { if (!value) return '-'; var parts = String(value).split('-'); if (parts.length >= 2) { var idx = parseInt(parts[1]) - 1; if (idx >= 0 && idx < 12) return monthNames[idx] + ' ' + parts[0]; } return value; }
    function formatLabel(field) { return fieldLabels[field] || field.replace(/_/g, ' ').replace(/\b\w/g, function(c) { return c.toUpperCase(); }); }
    function formatAsNumberedList(value) { if (!value || value === '-') return '-'; var items = String(value).split(',').map(function(i) { return i.trim(); }).filter(function(i) { return i; }); if (items.length === 0) return '-'; var html = '<ol class="numbered-list">'; for (var i = 0; i < items.length; i++) html += '<li>' + items[i] + '</li>'; return html + '</ol>'; }
    
    function getDocLinkHtml(field, data, sectionId) {
      var docField = fieldDocumentMap[field];
      if (!docField) return '';
      var url = extractUrl(data[docField]);
      if (url) return '<span class="status-icon uploaded">' + icons.check + '</span><a href="' + url + '" target="_blank" class="doc-link">' + icons.document + ' View</a>';
      return '<span style="font-size:11px;color:#9ca3af;font-style:italic;">Click Edit to upload document</span>';
    }
    
    function getFileUploadHtml(docField, sectionId, isPdfOnly) {
      var acceptType = isPdfOnly ? 'application/pdf,.pdf' : 'image/*,.pdf,.heic,.heif';
      var captureAttr = isPdfOnly ? '' : ' capture="environment"';
      var fileTypeText = isPdfOnly ? 'PDF only' : 'PNG, JPEG, HEIC or PDF — or take a photo';
      return '<div class="file-upload-area" id="upload_area_' + docField + '" onclick="document.getElementById(\'file_' + docField + '\').click()" ondragover="handleDragOver(event, \'' + docField + '\')" ondragleave="handleDragLeave(event, \'' + docField + '\')" ondrop="handleDrop(event, \'' + docField + '\', \'' + sectionId + '\', ' + isPdfOnly + ')">' +
        '<input type="file" id="file_' + docField + '" accept="' + acceptType + '"' + captureAttr + ' onchange="handleFileSelect(this, \'' + docField + '\', \'' + sectionId + '\', ' + isPdfOnly + ')">' +
        '<div class="upload-icon">' + icons.upload + '</div>' +
        '<p>Drop file here or click to browse</p>' +
        '<p class="file-type">' + fileTypeText + '</p>' +
        '</div>' +
        '<div id="file_selected_' + docField + '"></div>';
    }
    
    function triggerFileUpload(docField, sectionId) { var fileInput = document.getElementById('file_' + docField); if (fileInput) fileInput.click(); else showToast('Click Edit to upload documents'); }
    function handleDragOver(event, docField) { event.preventDefault(); event.stopPropagation(); document.getElementById('upload_area_' + docField).classList.add('dragover'); }
    function handleDragLeave(event, docField) { event.preventDefault(); event.stopPropagation(); document.getElementById('upload_area_' + docField).classList.remove('dragover'); }
    function handleDrop(event, docField, sectionId, isPdfOnly) { event.preventDefault(); event.stopPropagation(); document.getElementById('upload_area_' + docField).classList.remove('dragover'); var files = event.dataTransfer.files; if (files.length > 0) processFile(files[0], docField, sectionId, isPdfOnly); }
    function handleFileSelect(input, docField, sectionId, isPdfOnly) { if (input.files.length > 0) processFile(input.files[0], docField, sectionId, isPdfOnly); }
    
    function processFile(file, docField, sectionId, isPdfOnly) {
      var validTypes = isPdfOnly ? ['application/pdf'] : ['image/jpeg', 'image/png', 'image/gif', 'image/heic', 'image/heif', 'application/pdf'];
      if (validTypes.indexOf(file.type) === -1) { showToast(isPdfOnly ? 'Please select a PDF file' : 'Please select an image (PNG, JPEG, HEIC) or PDF file'); return; }
      if (file.size > 10 * 1024 * 1024) { showToast('File size must be less than 10MB'); return; }
      var reader = new FileReader();
      reader.onload = function(e) {
        var base64Data = e.target.result.split(',')[1];
        if (!pendingFileUploads[sectionId]) pendingFileUploads[sectionId] = {};
        pendingFileUploads[sectionId][docField] = { data: base64Data, name: file.name, mimeType: file.type };
        var selectedDiv = document.getElementById('file_selected_' + docField);
        if (selectedDiv) selectedDiv.innerHTML = '<div class="file-selected">' + icons.file + '<span class="file-name">' + file.name + '</span><button type="button" class="remove-file" onclick="removeSelectedFile(\'' + docField + '\', \'' + sectionId + '\')">' + icons.cross + '</button></div>';
      };
      reader.readAsDataURL(file);
    }

    function updateLimitationField() {
      var section = document.querySelector('.profile-section[data-section="ade_approval_section"]');
      if (!section) return;
      // Uncheck Nil when any number is selected
      var nilCb = section.querySelector('input[data-nil-limitation]');
      if (nilCb) nilCb.checked = false;
      var checkboxes = section.querySelectorAll('input[type="checkbox"][data-limitation]');
      var selected = [];
      for (var i = 0; i < checkboxes.length; i++) {
        if (checkboxes[i].checked) selected.push(parseInt(checkboxes[i].value));
      }
      selected.sort(function(a, b) { return a - b; });
      var hidden = document.getElementById('limitation_hidden');
      if (hidden) hidden.value = selected.join(',');
    }
    
    function removeSelectedFile(docField, sectionId) {
      if (pendingFileUploads[sectionId]) delete pendingFileUploads[sectionId][docField];
      var selectedDiv = document.getElementById('file_selected_' + docField);
      if (selectedDiv) selectedDiv.innerHTML = '';
      var fileInput = document.getElementById('file_' + docField);
      if (fileInput) fileInput.value = '';
    }

    function onNilLimitationChange() {
      var section = document.querySelector('.profile-section[data-section="ade_approval_section"]');
      if (!section) return;
      var nilCb = section.querySelector('input[data-nil-limitation]');
      var checkboxes = section.querySelectorAll('input[type="checkbox"][data-limitation]');
      var hidden = document.getElementById('limitation_hidden');
      if (nilCb && nilCb.checked) {
        // Nil selected — clear and disable all number checkboxes
        for (var i = 0; i < checkboxes.length; i++) {
          checkboxes[i].checked = false;
          checkboxes[i].disabled = true;
        }
        if (hidden) hidden.value = 'Nil';
      } else {
        // Nil deselected — re-enable number checkboxes, clear value
        for (var i = 0; i < checkboxes.length; i++) {
          checkboxes[i].disabled = false;
        }
        if (hidden) hidden.value = '';
      }
    }
    
    function renderProfile(data, headers) {
      var name = data.full_name || 'Unknown';

      // ── Status badge ──────────────────────────────────────────────────────
      var statusVal  = (data.status || '').trim();
      var statusDate = (data.status_date || '').trim();
      var isDeparted = (statusVal === 'Resigned' || statusVal === 'Transfer');
      var badgeHtml = '';
      if (isDeparted) {
        var dateText = statusDate ? '<span class="status-date-text">(' + statusDate.substring(0, 10) + ')</span>' : '';
        badgeHtml = '<span class="status-badge departed">' + statusVal + '</span>' + dateText;
      } else {
        badgeHtml = '<span class="status-badge active">● Active</span>';
      }

      // Insert name as text node then badge
      var h1 = document.getElementById('profileName');
      h1.innerHTML = '';
      h1.appendChild(document.createTextNode(name + ' '));
      // createElement avoids the null-ref crash caused by h1.innerHTML='' destroying
      // the static #profileStatusBadge span that was originally inside the h1.
      var badgeSpan = document.createElement('span');
      badgeSpan.id = 'profileStatusBadge';
      badgeSpan.innerHTML = badgeHtml;
      h1.appendChild(badgeSpan);

      document.getElementById('profileRole').textContent = data.designation || 'Staff';
      document.getElementById('profileEmail').textContent = data.email_address || '';
      document.getElementById('profileStaffNo').textContent = data.staff_no || '';
      if (data.last_update_timestamp) {
        document.getElementById('lastUpdated').textContent = 'Last updated: ' + formatDate(data.last_update_timestamp);
      } else {
        document.getElementById('lastUpdated').textContent = '';
      }
      
      var sections = parseHeadersIntoSections(headers);
      var container = document.getElementById('sectionsContainer');
      var sidebarNav = document.getElementById('sidebarNav');
      var mobileNav = document.getElementById('mobileNav');
      
      for (var i = 0; i < sections.length; i++) {
        var section = sections[i];
        var isFirst = (i === 0);
        var navItem = document.createElement('div');
        navItem.className = 'nav-item' + (isFirst ? ' active' : '');
        navItem.textContent = section.name;
        navItem.setAttribute('data-section', section.id);
        (function(sid) { navItem.onclick = function() { showSection(sid); }; })(section.id);
        sidebarNav.appendChild(navItem);
        var mobileNavItem = document.createElement('button');
        mobileNavItem.className = 'mobile-nav-item' + (isFirst ? ' active' : '');
        mobileNavItem.textContent = section.name;
        mobileNavItem.setAttribute('data-section', section.id);
        (function(sid) { mobileNavItem.onclick = function() { showSection(sid); }; })(section.id);
        mobileNav.appendChild(mobileNavItem);
        container.innerHTML += renderSection(section, data, isFirst);

        var icRow = document.getElementById('row_ic_no');
        if (icRow) {
          var storedNationality = userData.nationality || '';
          var isMalaysia = !storedNationality || storedNationality === 'Malaysia';
          if (!isMalaysia) icRow.classList.add('hidden');
        }
      }

      // Disciplinary tab
      var discNavItem = document.createElement('div');
      discNavItem.className = 'nav-item';
      discNavItem.textContent = 'Disciplinary';
      discNavItem.setAttribute('data-section', 'disciplinary_section');
      discNavItem.onclick = function() { showSection('disciplinary_section'); };
      sidebarNav.appendChild(discNavItem);
      var discMobileItem = document.createElement('button');
      discMobileItem.className = 'mobile-nav-item';
      discMobileItem.textContent = 'Disciplinary';
      discMobileItem.setAttribute('data-section', 'disciplinary_section');
      discMobileItem.onclick = function() { showSection('disciplinary_section'); };
      mobileNav.appendChild(discMobileItem);
      container.innerHTML += renderDisciplinarySection();
      container.innerHTML += renderAbsenceSection();

      // Absence tab
      var absNavItem = document.createElement('div');
      absNavItem.className = 'nav-item';
      absNavItem.textContent = 'Absence';
      absNavItem.setAttribute('data-section', 'absence_section');
      absNavItem.onclick = function() { showSection('absence_section'); };
      sidebarNav.appendChild(absNavItem);
      var absMobileItem = document.createElement('button');
      absMobileItem.className = 'mobile-nav-item';
      absMobileItem.textContent = 'Absence';
      absMobileItem.setAttribute('data-section', 'absence_section');
      absMobileItem.onclick = function() { showSection('absence_section'); };
      mobileNav.appendChild(absMobileItem);
    }
    
    function showSection(sectionId) {
      var navItems = document.querySelectorAll('.nav-item');
      var mobileNavItems = document.querySelectorAll('.mobile-nav-item');
      var sections = document.querySelectorAll('.profile-section');
      for (var i = 0; i < navItems.length; i++) navItems[i].classList.toggle('active', navItems[i].getAttribute('data-section') === sectionId);
      for (var j = 0; j < mobileNavItems.length; j++) mobileNavItems[j].classList.toggle('active', mobileNavItems[j].getAttribute('data-section') === sectionId);
      for (var k = 0; k < sections.length; k++) sections[k].classList.toggle('active', sections[k].getAttribute('data-section') === sectionId);
      window.scrollTo({ top: 0, behavior: 'smooth' });
      var activeMobileItem = document.querySelector('.mobile-nav-item.active');
      if (activeMobileItem) activeMobileItem.scrollIntoView({ behavior: 'smooth', inline: 'center', block: 'nearest' });
      if (sectionId === 'disciplinary_section') loadDisciplinaryData();
      if (sectionId === 'absence_section')      loadAbsenceData();
    }
    
    function parseHeadersIntoSections(headers) {
      var sections = [];
      var currentSec = null;
      for (var i = 0; i < headers.length; i++) {
        var header = headers[i];
        if (header && header.indexOf('_section') === header.length - 8) {
          if (currentSec) sections.push(currentSec);
          currentSec = { id: header, name: (sectionConfig[header] && sectionConfig[header].name) || header, fields: [] };
        } else if (currentSec && header && skipFields.indexOf(header) === -1) {
          currentSec.fields.push(header);
        }
      }
      if (currentSec) sections.push(currentSec);
      return sections;
    }
    
    function renderSection(section, data, isActive) {
      var content = '';
      if (section.id === 'department_information_section') content = renderDepartmentSection(section, data);
      else if (section.id === 'previous_employment_section') content = renderEmploymentSection(section, data);
      else if (section.id === 'caam_licens_section') content = renderLicenseSection(section, data);
      else if (section.id === 'personal_details_section') content = renderPersonalSection(section, data);
      else if (section.id === 'ade_approval_section') content = renderApprovalSection(section, data);
      else if (section.id === 'aiport_authority_section') content = renderAirportSection(section, data);
      else content = renderGenericSection(section, data);

      // Change Status button only on Department Information section
      var changeStatusBtn = section.id === 'department_information_section'
        ? '<button class="btn btn-danger-outline change-status-btn" onclick="openStatusModal()" style="white-space:nowrap;">⚠ Change Status</button>'
        : '';

      return '<div class="profile-section ' + (isActive ? 'active' : '') + '" data-section="' + section.id + '">' +
        '<div class="section-header">' +
          '<div class="section-title">' + section.name + '</div>' +
          '<div class="section-actions">' +
            '<div class="edit-actions">' +
              '<button class="btn btn-primary" onclick="saveChanges(\'' + section.id + '\')">Save</button>' +
              '<button class="btn btn-grey" onclick="cancelEdit(\'' + section.id + '\')">Cancel</button>' +
            '</div>' +
            '<button class="btn btn-outline-grey edit-btn" onclick="toggleEditMode(\'' + section.id + '\')">' + icons.edit + ' Edit</button>' +
            changeStatusBtn +
          '</div>' +
        '</div>' +
        content +
        '</div>';
    }
    
    function renderDepartmentSection(section, data) {
      var fields = section.fields.filter(function(f) { return documentFields.indexOf(f) === -1 && f !== 'immediate_superior'; });
      var html = '<div class="two-column"><div class="column">';
      var midpoint = Math.ceil(fields.length / 2);
      for (var j = 0; j < fields.length; j++) {
        if (j === midpoint) html += '</div><div class="column">';
        html += renderDeptField(fields[j], data[fields[j]], data, section.id);
      }
      var yearsInAde = calculateYearsFromDate(data.joining_date);
      html += '<div class="data-row"><div class="data-label">Years in ADE:</div><div class="data-value"><span class="display-value">' + yearsInAde + '</span><div class="editable-field"><span class="text-value" id="years_in_ade_display">' + yearsInAde + '</span></div></div></div>';
      return html + '</div></div>';
    }

    function calculateYearsFromDate(dateValue) {
      if (!dateValue) return '-';
      var date = dateValue instanceof Date ? dateValue : new Date(dateValue);
      if (isNaN(date.getTime())) return '-';
      return ((new Date() - date) / (365.25 * 24 * 60 * 60 * 1000)).toFixed(1);
    }

    function calculateAgeFromDOB(dobString) {
      if (!dobString) return '-';
      var parts = String(dobString).split('-');
      if (parts.length < 3) return '-';
      var dob = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
      if (isNaN(dob.getTime())) return '-';
      var today = new Date();
      var age = today.getFullYear() - dob.getFullYear();
      var m = today.getMonth() - dob.getMonth();
      if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) age--;
      return age;
    }
    
    function renderDeptField(field, value, data, sectionId) {
      if (documentFields.indexOf(field) !== -1) return '';
      var label = formatLabel(field);
      var stringValue = (value !== null && value !== undefined) ? String(value) : '';
      var displayValue = formatValue(value, field);
      var isEmpty = value === null || value === undefined || value === '';

      if (field === 'date_of_birth') {
        var dobEditField = '<div class="editable-field"><input type="date" data-field="date_of_birth" value="' + formatDateForInput(value) + '" onchange="onDobChange(this.value)"></div>';
        var dobRow = '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + displayValue + '</span>' + dobEditField + '</div></div>';
        var ageVal = calculateAgeFromDOB(stringValue);
        var ageDisplay = ageVal !== '-' ? ageVal + ' yrs' : '-';
        var ageRow = '<div class="data-row"><div class="data-label">Age:</div><div class="data-value"><span class="display-value" id="dynamic_age_display">' + ageDisplay + '</span><div class="editable-field"><span class="text-value" id="age_display">' + ageDisplay + '</span></div></div></div>';
        return dobRow + ageRow;
      }

      if (field === 'nationality') {
        var natOpts = '<option value="">Select...</option>';
        for (var n = 0; n < nationalityList.length; n++) natOpts += '<option value="' + nationalityList[n] + '"' + (stringValue === nationalityList[n] ? ' selected' : '') + '>' + nationalityList[n] + '</option>';
        var editField = '<div class="editable-field"><select data-field="nationality" onchange="updateIcNoVisibility(this.value)">' + natOpts + '</select></div>';
        return '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + displayValue + '</span>' + editField + '</div></div>';
      }

      if (field === 'gender') {
        var editField = '<div class="editable-field"><select data-field="gender"><option value="">Select...</option><option value="Male"' + (stringValue === 'Male' ? ' selected' : '') + '>Male</option><option value="Female"' + (stringValue === 'Female' ? ' selected' : '') + '>Female</option></select></div>';
        return '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + displayValue + '</span>' + editField + '</div></div>';
      }

      if (field === 'designation') {
        var desigOpts = '<option value="">Select...</option>';
        for (var d = 0; d < deptDesignationOptions.length; d++) desigOpts += '<option value="' + deptDesignationOptions[d] + '"' + (stringValue === deptDesignationOptions[d] ? ' selected' : '') + '>' + deptDesignationOptions[d] + '</option>';
        var editField = '<div class="editable-field"><select data-field="designation">' + desigOpts + '</select></div>';
        return '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + displayValue + '</span>' + editField + '</div></div>';
      }

      if (field === 'ic_no') {
        var docField = fieldDocumentMap['ic_no'];
        var url = extractUrl(data[docField]);
        var docHint = '<span style="font-size:11px;color:#9ca3af;font-style:italic;">Click Edit to upload document</span>';
        var docViewLink = url ? '<span class="status-icon uploaded">' + icons.check + '</span><a href="' + url + '" target="_blank" class="doc-link">' + icons.document + ' View</a>' : docHint;
        var icDigits = stringValue ? stringValue.replace(/-/g, '') : '';
        var icFormatted = (icDigits.length >= 12) ? icDigits.substring(0,6) + '-' + icDigits.substring(6,8) + '-' + icDigits.substring(8,12) : (stringValue || '-');
        var existingParts = stringValue ? stringValue.split('-') : [];
        var p1 = existingParts[0] || ''; var p2 = existingParts[1] || ''; var p3 = existingParts[2] || '';
        var stackedDisplay = '<div style="display:flex;flex-direction:column;gap:4px;"><span>' + icFormatted + '</span><span>' + docViewLink + '</span></div>';
        var stackedEdit = '<div class="editable-field" style="flex-direction:column;align-items:flex-start;">' +
          '<div style="display:flex;align-items:center;gap:6px;width:100%;">' +
          '<input type="text" id="ic_part1" maxlength="6" placeholder="YYMMDD" inputmode="numeric" value="' + p1 + '" style="width:80px;" oninput="combineIcNo()">' +
          '<span style="font-weight:600;color:#374151;">-</span>' +
          '<input type="text" id="ic_part2" maxlength="2" placeholder="PB" inputmode="numeric" value="' + p2 + '" style="width:48px;" oninput="combineIcNo()">' +
          '<span style="font-weight:600;color:#374151;">-</span>' +
          '<input type="text" id="ic_part3" maxlength="4" placeholder="XXXX" inputmode="numeric" value="' + p3 + '" style="width:64px;" oninput="combineIcNo()">' +
          '<input type="text" data-field="ic_no" id="ic_no_combined" value="' + stringValue + '">' +
          '</div>' +
          (docField ? getFileUploadHtml(docField, sectionId, false) : '') +
          '</div>';
        return '<div class="data-row" id="row_ic_no"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + stackedDisplay + '</span>' + stackedEdit + '</div></div>';
      }

      if (field === 'phone_no') {
        var phoneValue = stringValue.replace(/^\+?60/, '');
        var editField = '<div class="editable-field"><div class="phone-input-group"><span class="phone-prefix">+60</span><input type="text" data-field="phone_no" value="' + phoneValue + '" maxlength="10" inputmode="numeric"></div></div>';
        return '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + displayValue + '</span>' + editField + '</div></div>';
      }

      if (deptEditableFields.indexOf(field) !== -1) {
        var editField = '<div class="editable-field"><input type="text" data-field="' + field + '" value="' + stringValue + '"></div>';
        return '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + displayValue + '</span>' + editField + '</div></div>';
      }

      var docField = fieldDocumentMap[field];
      var expiryBadge = expiryFields.indexOf(field) !== -1 && value ? getExpiryBadge(value) : '';
      var docLink = getDocLinkHtml(field, data, sectionId);
      var editField = '';
      if (decimalFields.indexOf(field) !== -1) {
        editField = '<div class="editable-field"><input type="text" value="' + formatDecimalValue(value) + '" disabled>' + (docField ? getFileUploadHtml(docField, sectionId, false) : '') + '</div>';
      } else if (field.indexOf('date') !== -1 || field.indexOf('expiry') !== -1) {
        editField = '<div class="editable-field"><input type="date" value="' + formatDateForInput(value) + '" disabled>' + (docField ? getFileUploadHtml(docField, sectionId, false) : '') + '</div>';
      } else {
        editField = '<div class="editable-field"><input type="text" value="' + stringValue + '" disabled>' + (docField ? getFileUploadHtml(docField, sectionId, false) : '') + '</div>';
      }
      return '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + displayValue + docLink + '</span>' + expiryBadge + editField + '</div></div>';
    }
    
    function renderEmploymentSection(section, data) {
      var noOfEmployment = parseInt(data.no_of_employment) || 0;
      var options = '';
      for (var n = 0; n <= 3; n++) options += '<option value="' + n + '"' + (n === noOfEmployment ? ' selected' : '') + '>' + n + '</option>';
      var html = '<div class="data-row"><div class="data-label">No. of Employment:</div><div class="data-value"><span class="display-value">' + noOfEmployment + '</span><div class="editable-field"><select data-field="no_of_employment" onchange="updateEmploymentVisibility(this.value)" style="width: auto;">' + options + '</select></div></div></div>';
      html += renderEmploymentCard('1st Employment (Most Recent)', 'last', data, noOfEmployment >= 1);
      html += renderEmploymentCard('2nd Employment', 'second_last', data, noOfEmployment >= 2);
      html += renderEmploymentCard('3rd Employment', 'third_last', data, noOfEmployment >= 3);
      return html;
    }
    
    function renderEmploymentCard(title, suffix, data, visible) {
      var fields = employmentGroups[suffix];
      var html = '<div class="employment-card ' + (visible ? '' : 'hidden') + '" id="emp_card_' + suffix + '"><div class="employment-card-title">' + title + '</div><div class="half-width-container">';
      for (var i = 0; i < fields.length; i++) html += renderEmploymentField(fields[i], data[fields[i]], suffix);
      return html + '</div></div>';
    }

    function calculateYearsInAviation(yearJoined) {
      var display = document.getElementById('years_in_aviation_display');
      if (display) display.textContent = yearJoined ? (new Date().getFullYear() - parseInt(yearJoined)).toFixed(1) : '-';
    }

    function calculateEmploymentYears(suffix) {
      var startDateInput = document.querySelector('[data-field="start_date_' + suffix + '"]');
      var endDateInput = document.querySelector('[data-field="end_date_' + suffix + '"]');
      var yearDisplay = document.getElementById('year_' + suffix + '_display');
      if (!startDateInput || !endDateInput || !yearDisplay) return;
      var startDate = startDateInput.value; var endDate = endDateInput.value;
      if (startDate && endDate) {
        var start = new Date(startDate); var end = new Date(endDate);
        if (!isNaN(start.getTime()) && !isNaN(end.getTime())) {
          var diffYears = (end - start) / (365.25 * 24 * 60 * 60 * 1000);
          if (diffYears < 0) { yearDisplay.textContent = 'Invalid'; yearDisplay.style.color = '#dc2626'; }
          else { yearDisplay.textContent = diffYears.toFixed(1); yearDisplay.style.color = '#1f2937'; }
        } else yearDisplay.textContent = '-';
      } else yearDisplay.textContent = '-';
    }
    
    function renderEmploymentField(field, value, suffix) {
      var label = formatLabel(field);
      var isYearField = field.indexOf('year_') === 0;
      var isMultiSelect = field.indexOf('section_') === 0 || field.indexOf('designation_') === 0 || field.indexOf('type_') === 0;
      var isCompany = field.indexOf('company_') === 0;
      var isStartDate = field.indexOf('start_date_') === 0;
      var isEndDate = field.indexOf('end_date_') === 0;
      var displayValue = isYearField ? formatYearsValue(value) : (value || '-');
      var isEmpty = !value;
      var editField = '';
      if (isMultiSelect) {
        var options = [];
        if (field.indexOf('section_') === 0) options = sectionOptions;
        else if (field.indexOf('designation_') === 0) options = designationOptions;
        else if (field.indexOf('type_') === 0) options = typeRatingList;
        editField = renderMultiSelectField(field, options);
      } else if (isStartDate) {
        editField = '<div class="editable-field"><input type="date" data-field="' + field + '" value="' + formatDateForInput(value) + '" onchange="calculateEmploymentYears(\'' + suffix + '\')"></div>';
      } else if (isEndDate) {
        editField = '<div class="editable-field"><input type="date" data-field="' + field + '" value="' + formatDateForInput(value) + '" onchange="calculateEmploymentYears(\'' + suffix + '\')"></div>';
      } else if (isYearField) {
        editField = '<div class="editable-field"><span class="text-value" id="year_' + suffix + '_display">' + formatYearsValue(value) + '</span></div>';
      } else if (isCompany) {
        editField = '<div class="editable-field"><input type="text" class="input-wide" data-field="' + field + '" value="' + (value || '') + '"></div>';
      } else {
        editField = '<div class="editable-field"><input type="text" data-field="' + field + '" value="' + (value || '') + '"></div>';
      }
      return '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + displayValue + '</span>' + editField + '</div></div>';
    }

    function onDobChange(newDob) {
      var ageVal = calculateAgeFromDOB(newDob);
      var ageDisplay = document.getElementById('age_display');
      var dynamicAge = document.getElementById('dynamic_age_display');
      if (ageDisplay) ageDisplay.textContent = ageVal !== '-' ? ageVal + ' yrs' : '-';
      if (dynamicAge) dynamicAge.textContent = ageVal !== '-' ? ageVal + ' yrs' : '-';
    }

    function updateIcNoVisibility(nationalityValue) {
      var row = document.getElementById('row_ic_no');
      if (!row) return;
      var isMalaysia = !nationalityValue || nationalityValue === 'Malaysia';
      row.classList.toggle('hidden', !isMalaysia);
    }
    
    function renderMultiSelectField(field, options) {
      var optionsHtml = '<option value="">+ Add</option>';
      for (var i = 0; i < options.length; i++) optionsHtml += '<option value="' + options[i] + '">' + options[i] + '</option>';
      return '<div class="editable-field" data-multiselect="' + field + '"><div class="multi-select-container"><div class="selected-badges" id="badges_' + field + '"></div><select id="select_' + field + '" class="multi-select-dropdown" onchange="addMultiSelectValue(\'' + field + '\', this.value); this.value=\'\';">' + optionsHtml + '</select></div></div>';
    }
    
    function renderLicenseSection(section, data) {
      var sectionId = 'caam_licens_section';
      var availableLicense = data.available_license || '';
      var hasAMEL = availableLicense.indexOf('AMEL') !== -1;
      var hasAMTL = availableLicense.indexOf('AMTL') !== -1;
      var hasNoLicense = availableLicense === 'None' || availableLicense === '';
      var licOpts = '';
      for (var i = 0; i < licenseOptions.length; i++) licOpts += '<option value="' + licenseOptions[i] + '">' + licenseOptions[i] + '</option>';
      var html = '<div class="half-width-container"><div class="data-row"><div class="data-label">Available License:</div><div class="data-value"><span class="display-value">' + (availableLicense || '-') + '</span><div class="editable-field" data-multiselect="available_license"><div class="multi-select-container"><div class="selected-badges" id="badges_available_license"></div><select id="select_available_license" class="multi-select-dropdown" onchange="addLicense(this.value); this.value=\'\';""><option value="">+ Add License</option>' + licOpts + '</select></div></div></div></div></div>';
      html += '<div class="subsection ' + (hasAMEL ? '' : 'hidden') + '" id="amel_subsection"><div class="subsection-title">AMEL License (B/C)</div><div class="half-width-container">';
      for (var j = 0; j < amelFields.length; j++) html += renderLicenseField(amelFields[j], data[amelFields[j]], data, sectionId);
      html += '</div></div>';
      html += '<div class="subsection ' + (hasAMTL ? '' : 'hidden') + '" id="amtl_subsection"><div class="subsection-title">AMTL License (A)</div><div class="half-width-container">';
      for (var k = 0; k < amtlFields.length; k++) html += renderLicenseField(amtlFields[k], data[amtlFields[k]], data, sectionId);
      html += '</div></div>';
      var showYearFields = !hasNoLicense;
      html += '<div class="half-width-container ' + (showYearFields ? '' : 'hidden') + '" id="year_fields_container">';
      if (section.fields.indexOf('year_establish') !== -1) html += renderYearEstablishField(data['year_establish']);
      if (section.fields.indexOf('year_signing') !== -1) html += renderYearSigningField(data['year_signing']);
      html += '</div>';
      return html;
    }
    
    function renderYearEstablishField(value) {
      var displayValue = formatMonthYear(value);
      var monthValue = '', yearValue = '';
      if (value) { var parts = String(value).split('-'); if (parts.length >= 2) { yearValue = parts[0]; monthValue = parts[1]; } }
      var monthOpts = '<option value="">Month</option>';
      for (var m = 0; m < 12; m++) { var mVal = String(m + 1); if (mVal.length === 1) mVal = '0' + mVal; monthOpts += '<option value="' + mVal + '"' + (monthValue === mVal ? ' selected' : '') + '>' + monthNames[m] + '</option>'; }
      var currentYear = new Date().getFullYear();
      var yearOpts = '<option value="">Year</option>';
      for (var y = currentYear; y >= 1970; y--) yearOpts += '<option value="' + y + '"' + (yearValue === String(y) ? ' selected' : '') + '>' + y + '</option>';
      return '<div class="data-row"><div class="data-label">Year Established:</div><div class="data-value"><span class="display-value">' + displayValue + '</span><div class="editable-field"><div class="month-year-picker"><select id="year_establish_month" onchange="calculateYearSigning()">' + monthOpts + '</select><select id="year_establish_year" onchange="calculateYearSigning()">' + yearOpts + '</select></div></div></div></div>';
    }
    
    function renderYearSigningField(value) {
      var displayValue = formatYearsValue(value);
      return '<div class="data-row"><div class="data-label">Years Signing:</div><div class="data-value"><span class="display-value">' + displayValue + '</span><div class="editable-field"><span class="text-value" id="year_signing_display">' + displayValue + '</span></div></div></div>';
    }
    
    function calculateYearSigning() {
      var monthSel = document.getElementById('year_establish_month');
      var yearSel = document.getElementById('year_establish_year');
      var display = document.getElementById('year_signing_display');
      if (monthSel && yearSel && display && monthSel.value && yearSel.value) {
        var establishDate = new Date(parseInt(yearSel.value), parseInt(monthSel.value) - 1, 1);
        var today = new Date();
        var years = today.getFullYear() - establishDate.getFullYear();
        var months = today.getMonth() - establishDate.getMonth();
        if (months < 0) { years--; months += 12; }
        display.textContent = (years + (months / 12)).toFixed(1);
      }
    }

    function combineIcNo() {
      var p1 = document.getElementById('ic_part1'); var p2 = document.getElementById('ic_part2');
      var p3 = document.getElementById('ic_part3'); var combined = document.getElementById('ic_no_combined');
      if (!p1 || !p2 || !p3 || !combined) return;
      if (p1 === document.activeElement && p1.value.length === 6) p2.focus();
      if (p2 === document.activeElement && p2.value.length === 2) p3.focus();
      var val = '';
      if (p1.value || p2.value || p3.value) val = p1.value + '-' + p2.value + '-' + p3.value;
      combined.value = val;
    }
    
    function renderLicenseField(field, value, data, sectionId) {
      var label = formatLabel(field);
      var isExpiry = expiryFields.indexOf(field) !== -1;
      var isTypeRating = ['b1_type_rating', 'b2_type_rating', 'c_type_rating', 'a1_type_rating'].indexOf(field) !== -1;
      var isMultiSelect = field === 'amel_license_category' || isTypeRating;
      var isLicenseNo = field === 'amel_license' || field === 'amtl_license_no';
      var displayValue = isTypeRating ? formatAsNumberedList(value) : formatValue(value, field);
      var isEmpty = !value;
      var expiryBadge = isExpiry && value ? getExpiryBadge(value) : '';
      var isPdfOnly = true;
      var docField = fieldDocumentMap[field];
      var url = docField ? extractUrl(data[docField]) : null;
      var docHint = '<span style="font-size:11px;color:#9ca3af;font-style:italic;">Click Edit to upload document</span>';
      var docViewLink = url ? '<span class="status-icon uploaded">' + icons.check + '</span><a href="' + url + '" target="_blank" class="doc-link">' + icons.document + ' View</a>' : docHint;
      var editField = '';

      if (isMultiSelect) {
        if (field === 'amel_license_category') editField = renderAmelCategoryField();
        else editField = renderTypeRatingMultiSelectField(field, typeRatingList);
      } else if (field.indexOf('date') !== -1 || field.indexOf('expiry') !== -1) {
        editField = '<div class="editable-field"><input type="date" data-field="' + field + '" value="' + formatDateForInput(value) + '"></div>';
      } else if (isLicenseNo) {
        editField = '<div class="editable-field" style="flex-direction:column;align-items:flex-start;">' +
          '<input type="text" class="input-narrow" data-field="' + field + '" value="' + (value || '') + '" style="width:100%">' +
          (docField ? getFileUploadHtml(docField, sectionId, isPdfOnly) : '') + '</div>';
      } else if (field === 'amtl_license_category') {
        editField = '<div class="editable-field"><select data-field="' + field + '"><option value="">Select...</option><option value="A1"' + (value === 'A1' ? ' selected' : '') + '>A1</option></select></div>';
      } else {
        editField = '<div class="editable-field"><input type="text" data-field="' + field + '" value="' + (value || '') + '"></div>';
      }

      if (isLicenseNo) {
        var stackedDisplay = '<div style="display:flex;flex-direction:column;gap:4px;"><span>' + (value || '-') + '</span><span>' + docViewLink + '</span></div>';
        return '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + stackedDisplay + '</span>' + expiryBadge + editField + '</div></div>';
      }
      return '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + displayValue + '</span>' + expiryBadge + editField + '</div></div>';
    }
    
    function renderTypeRatingMultiSelectField(field, options) {
      var optionsHtml = '<option value="">+ Add</option>';
      for (var i = 0; i < options.length; i++) optionsHtml += '<option value="' + options[i] + '">' + options[i] + '</option>';
      return '<div class="editable-field" data-multiselect="' + field + '"><div class="multi-select-container"><div class="selected-badges" id="badges_' + field + '"></div><select id="select_' + field + '" class="multi-select-dropdown" onchange="addTypeRating(\'' + field + '\', this.value); this.value=\'\';">' + optionsHtml + '</select></div></div>';
    }
    
    function renderAmelCategoryField() {
      var optionsHtml = '<option value="">+ Add Category</option>';
      for (var i = 0; i < amelCategoryOptions.length; i++) optionsHtml += '<option value="' + amelCategoryOptions[i] + '">' + amelCategoryOptions[i] + '</option>';
      return '<div class="editable-field" data-multiselect="amel_license_category"><div class="multi-select-container"><div class="selected-badges" id="badges_amel_license_category"></div><select id="select_amel_license_category" class="multi-select-dropdown" onchange="addAmelCategory(this.value); this.value=\'\';">' + optionsHtml + '</select></div></div>';
    }
    
    function renderApprovalSection(section, data) {
      var sectionId = 'ade_approval_section';
      var availableLicense = pendingLicenseChanges.available_license !== null ? pendingLicenseChanges.available_license : (userData.available_license || '');
      var hasNoLicense = availableLicense === 'None' || availableLicense === '';
      var hasAMTL = availableLicense.indexOf('AMTL') !== -1;
      var amelCategories = pendingLicenseChanges.amel_license_category !== null ? pendingLicenseChanges.amel_license_category.split(',').map(function(v) { return v.trim(); }).filter(function(v) { return v; }) : (multiSelectData.amel_license_category || []);
      var hasB1 = amelCategories.indexOf('B1.1') !== -1; var hasB1Limited = amelCategories.indexOf('B1.1 Limited') !== -1;
      var hasB2 = amelCategories.indexOf('B2') !== -1; var hasB2Limited = amelCategories.indexOf('B2 Limited') !== -1;
      var hasC = amelCategories.indexOf('C') !== -1;
      var isPdfOnly = true;
      if (hasNoLicense) return '<div class="half-width-container"><div class="data-row"><div class="data-value" style="color: #6b7280; font-style: italic;">Update CAAM License to update ADE Approval</div></div></div>';
      var html = '<div class="half-width-container">';
      var approvalNo = data.ade_approval_no || '';
      var approvalDigits = approvalNo.replace(/^ADE/i, '');
      var approvalDocUrl = extractUrl(data['ade_approval_pdf_link']);
      var approvalDocHint = '<span style="font-size:11px;color:#9ca3af;font-style:italic;">Click Edit to upload document</span>';
      var approvalDocViewLink = approvalDocUrl ? '<span class="status-icon uploaded">' + icons.check + '</span><a href="' + approvalDocUrl + '" target="_blank" class="doc-link">' + icons.document + ' View</a>' : approvalDocHint;
      var approvalStackedDisplay = '<div style="display:flex;flex-direction:column;gap:4px;"><span>' + (approvalNo || '-') + '</span><span>' + approvalDocViewLink + '</span></div>';
      html += '<div class="data-row"><div class="data-label">Approval No:</div><div class="data-value ' + (!approvalNo ? 'empty' : '') + '"><span class="display-value">' + approvalStackedDisplay + '</span><div class="editable-field" style="flex-direction:column;align-items:flex-start;"><div class="approval-no-input" style="width:100%"><span class="approval-prefix">ADE</span><input type="text" class="input-digits" data-field="ade_approval_no" value="' + approvalDigits + '" placeholder="001" maxlength="3" inputmode="numeric" oninput="this.value=this.value.replace(/[^0-9]/g,\'\')"></div>' + getFileUploadHtml('ade_approval_pdf_link', sectionId, isPdfOnly) + '</div></div></div>';
      var systemCode = data.ade_system_code || '';
      var systemCodeOpts = '<option value="">+ Add Code</option>';
      for (var sc = 0; sc < systemCodeOptions.length; sc++) { var code = systemCodeOptions[sc]; if (code === 'M' && !hasAMTL) continue; systemCodeOpts += '<option value="' + code + '">' + code + '</option>'; }
      html += '<div class="data-row"><div class="data-label">System Code:</div><div class="data-value ' + (!systemCode ? 'empty' : '') + '"><span class="display-value">' + (systemCode || '-') + '</span><div class="editable-field" data-multiselect="ade_system_code"><div class="multi-select-container"><div class="selected-badges" id="badges_ade_system_code"></div><select id="select_ade_system_code" class="multi-select-dropdown" onchange="addMultiSelectValue(\'ade_system_code\', this.value); this.value=\'\';">' + systemCodeOpts + '</select></div></div></div></div>';
      var limitationValue = data.limitation || '';
      var isNil = limitationValue.trim().toLowerCase() === 'nil';
      var limitationSelected = (!isNil && limitationValue)
        ? limitationValue.split(',').map(function(v) { return v.trim(); }).filter(function(v) { return v; })
        : [];
      var limitationDisplay = limitationValue || '-';

      var checkboxHtml = '<div class="editable-field" style="flex-direction:column;align-items:flex-start;gap:6px;">';

      // ── Nil Limitation option (mutually exclusive with numbers) ──
      checkboxHtml += '<label style="display:flex;align-items:center;gap:8px;font-size:13px;' +
        'cursor:pointer;padding:4px 0;font-weight:600;color:#374151;">' +
        '<input type="checkbox" data-nil-limitation="1"' + (isNil ? ' checked' : '') +
        ' onchange="onNilLimitationChange()" style="width:16px;height:16px;">' +
        'Nil Limitation</label>';

      // ── Divider ──
      checkboxHtml += '<div style="width:100%;border-top:1px dashed #e5e7eb;margin:4px 0;"></div>';

      // ── Number checkboxes 1–18 ──
      checkboxHtml += '<div style="display:grid;grid-template-columns:repeat(6,1fr);gap:6px 16px;padding:4px 0;">';
      for (var lim = 1; lim <= 18; lim++) {
        var isChecked  = limitationSelected.indexOf(String(lim)) !== -1 ? ' checked' : '';
        var isDisabled = isNil ? ' disabled' : '';
        checkboxHtml += '<label style="display:flex;align-items:center;gap:5px;font-size:13px;' +
          'cursor:pointer;white-space:nowrap;' + (isNil ? 'opacity:0.4;' : '') + '">' +
          '<input type="checkbox" data-limitation="1" value="' + lim + '"' +
          isChecked + isDisabled + ' onchange="updateLimitationField()">' +
          lim + '</label>';
      }
      checkboxHtml += '</div>';
      checkboxHtml += '<input type="text" data-field="limitation" id="limitation_hidden" value="' +
        limitationValue + '" style="display:none;">';
      checkboxHtml += '</div>';

      html += '<div class="data-row"><div class="data-label">Limitation:</div>' +
        '<div class="data-value ' + (!limitationValue ? 'empty' : '') + '">' +
          '<span class="display-value">' + limitationDisplay + '</span>' +
          checkboxHtml +
        '</div></div>';
      html += renderApprovalTypeField('b1_ade_approval_type', data.b1_ade_approval_type, 'B1.1', hasB1 || hasB1Limited);
      html += renderApprovalTypeField('b2_ade_approval_type', data.b2_ade_approval_type, 'B2', hasB2 || hasB2Limited);
      html += renderApprovalTypeField('c_ade_approval_type', data.c_ade_approval_type, 'C', hasC);
      html += renderApprovalTypeField('a_ade_approval_type', data.a_ade_approval_type, 'A', hasAMTL);
      var expiryValue = data.ade_approval_expiry || '';
      var expiryBadge = expiryValue ? getExpiryBadge(expiryValue) : '';
      html += '<div class="data-row"><div class="data-label">Approval Expiry:</div><div class="data-value ' + (!expiryValue ? 'empty' : '') + '"><span class="display-value">' + (expiryValue || '-') + '</span>' + expiryBadge + '<div class="editable-field"><input type="date" data-field="ade_approval_expiry" value="' + formatDateForInput(expiryValue) + '"></div></div></div>';
      var egrValue = data.egr || '';
      var egrNotAvail = getValueNotAvailBadge('egr', egrValue);
      html += '<div class="data-row"><div class="data-label">EGR:</div><div class="data-value ' + (!egrValue ? 'empty' : '') + '"><span class="display-value">' + (egrNotAvail || formatAsNumberedList(egrValue)) + '</span><div class="editable-field" data-multiselect="egr"><div class="multi-select-container"><div class="selected-badges" id="badges_egr"></div><select id="select_egr" class="multi-select-dropdown" onchange="addMultiSelectValue(\'egr\', this.value); this.value=\'\';"><option value="">+ Add</option></select></div></div></div></div>';
      var boroscopeValue = data.boroscope || '';
      var boroscopeNotAvail = getValueNotAvailBadge('boroscope', boroscopeValue);
      html += '<div class="data-row"><div class="data-label">Boroscope:</div><div class="data-value ' + (!boroscopeValue ? 'empty' : '') + '"><span class="display-value">' + (boroscopeNotAvail || formatAsNumberedList(boroscopeValue)) + '</span><div class="editable-field" data-multiselect="boroscope"><div class="multi-select-container"><div class="selected-badges" id="badges_boroscope"></div><select id="select_boroscope" class="multi-select-dropdown" onchange="addMultiSelectValue(\'boroscope\', this.value); this.value=\'\';"><option value="">+ Add</option></select></div></div></div></div>';
      var compassValue = data.compass_swign || '';
      var compassOpts = '<option value="">Select...</option>';
      for (var cs = 0; cs < compassSwingOptions.length; cs++) compassOpts += '<option value="' + compassSwingOptions[cs] + '"' + (compassValue === compassSwingOptions[cs] ? ' selected' : '') + '>' + compassSwingOptions[cs] + '</option>';
      var compassNotAvail = getValueNotAvailBadge('compass_swign', compassValue);
      html += '<div class="data-row"><div class="data-label">Compass Swing:</div><div class="data-value ' + (!compassValue ? 'empty' : '') + '"><span class="display-value">' + (compassNotAvail || compassValue || '-') + '</span><div class="editable-field"><select data-field="compass_swign">' + compassOpts + '</select></div></div></div>';
      return html + '</div>';
    }
    
    function renderApprovalTypeField(field, value, category, visible) {
      var displayValue = formatAsNumberedList(value);
      var isEmpty = !value;
      var hiddenClass = visible ? '' : ' hidden';
      return '<div class="data-row' + hiddenClass + '" id="row_' + field + '"><div class="data-label">' + category + ' Approval Type:</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + displayValue + '</span><div class="editable-field" data-multiselect="' + field + '"><div class="multi-select-container"><div class="selected-badges" id="badges_' + field + '"></div><select id="select_' + field + '" class="multi-select-dropdown" onchange="addMultiSelectValue(\'' + field + '\', this.value); this.value=\'\';"><option value="">+ Add</option></select></div></div></div></div>';
    }
    
    function updateApprovalTypeDropdowns() {
      var amelCategories = multiSelectData.amel_license_category || [];
      var approvalFieldMap = { 'b1_ade_approval_type': { categories: ['B1.1', 'B1.1 Limited'] }, 'b2_ade_approval_type': { categories: ['B2', 'B2 Limited'] }, 'c_ade_approval_type': { categories: ['C'] }, 'a_ade_approval_type': { categories: ['A'] } };
      for (var field in approvalFieldMap) {
        var config = approvalFieldMap[field];
        var select = document.getElementById('select_' + field);
        if (!select) continue;
        var userCategory = null; var hasCategory = false;
        if (field === 'a_ade_approval_type') { hasCategory = (userData.available_license || '').indexOf('AMTL') !== -1; userCategory = 'A'; }
        else { for (var c = 0; c < config.categories.length; c++) { if (amelCategories.indexOf(config.categories[c]) !== -1) { hasCategory = true; userCategory = config.categories[c]; break; } } }
        var optionsHtml = '<option value="">+ Add</option>';
        var selected = multiSelectData[field] || [];
        if (userCategory && approvalTypes[userCategory]) { var approvalList = approvalTypes[userCategory]; for (var a = 0; a < approvalList.length; a++) { var approvalType = approvalList[a]; var isSelected = selected.indexOf(approvalType) !== -1; optionsHtml += '<option value="' + approvalType + '"' + (isSelected ? ' disabled' : '') + '>' + approvalType + '</option>'; } }
        select.innerHTML = optionsHtml;
        var row = document.getElementById('row_' + field);
        if (row) row.classList.toggle('hidden', !hasCategory);
      }
    }
    
    function updateEgrBoroscopeDropdowns() {
      var egrList = approvalTypes['EGR'] || [];
      var egrSelect = document.getElementById('select_egr');
      if (egrSelect) { var egrOptions = '<option value="">+ Add</option>'; var egrSelected = multiSelectData.egr || []; for (var i = 0; i < egrList.length; i++) { var isSelected = egrSelected.indexOf(egrList[i]) !== -1; egrOptions += '<option value="' + egrList[i] + '"' + (isSelected ? ' disabled' : '') + '>' + egrList[i] + '</option>'; } egrSelect.innerHTML = egrOptions; }
      var boroscopeSelect = document.getElementById('select_boroscope');
      if (boroscopeSelect) { var boroscopeOptions = '<option value="">+ Add</option>'; var boroscopeSelected = multiSelectData.boroscope || []; for (var j = 0; j < egrList.length; j++) { var isSelected = boroscopeSelected.indexOf(egrList[j]) !== -1; boroscopeOptions += '<option value="' + egrList[j] + '"' + (isSelected ? ' disabled' : '') + '>' + egrList[j] + '</option>'; } boroscopeSelect.innerHTML = boroscopeOptions; }
    }
    
    function renderPersonalSection(section, data) {
      var sectionId = 'personal_details_section';
      var fields = section.fields.filter(function(f) { return documentFields.indexOf(f) === -1; });
      if (fields.length === 0) return '<p style="color: #6b7280; font-style: italic;">No fields in this section.</p>';
      var html = '<div class="two-column"><div class="column">';
      var midpoint = Math.ceil(fields.length / 2);
      for (var i = 0; i < fields.length; i++) {
        if (i === midpoint) html += '</div><div class="column">';
        html += renderPersonalField(fields[i], data[fields[i]], data, sectionId);
      }
      return html + '</div></div>';
    }
    
    function renderPersonalField(field, value, data, sectionId) {
      var label = formatLabel(field);
      var isExpiry = expiryFields.indexOf(field) !== -1 || field === 'passport_expiry';
      var displayValue = formatValue(value, field);
      var isEmpty = !value;
      var expiryBadge = isExpiry && value ? getExpiryBadge(value) : '';
      var notAvailBadge = getNotAvailBadge(field, value);
      var isPdfOnly = false;
      var docField = fieldDocumentMap[field];
      var url = docField ? extractUrl(data[docField]) : null;
      var docHint = '<span style="font-size:11px;color:#9ca3af;font-style:italic;">Click Edit to upload document</span>';
      var docViewLink = url ? '<span class="status-icon uploaded">' + icons.check + '</span><a href="' + url + '" target="_blank" class="doc-link">' + icons.document + ' View</a>' : docHint;
      var editField = '';

      if (field === 'home_address' || field === 'address') {
        editField = '<div class="editable-field"><textarea data-field="' + field + '">' + (value || '') + '</textarea></div>';
      } else if (field === 'states' || field === 'state') {
        var stateOpts = '<option value="">Select...</option>';
        for (var i = 0; i < stateOptions.length; i++) stateOpts += '<option value="' + stateOptions[i] + '"' + (value === stateOptions[i] ? ' selected' : '') + '>' + stateOptions[i] + '</option>';
        editField = '<div class="editable-field"><select data-field="' + field + '">' + stateOpts + '</select></div>';
      } else if (field === 'relationship') {
        var relOpts = '<option value="">Select...</option>';
        for (var j = 0; j < relationshipOptions.length; j++) relOpts += '<option value="' + relationshipOptions[j] + '"' + (value === relationshipOptions[j] ? ' selected' : '') + '>' + relationshipOptions[j] + '</option>';
        editField = '<div class="editable-field"><select data-field="' + field + '">' + relOpts + '</select></div>';
      } else if (field === 'next_of_kin_contact_no') {
        var stringValue = (value !== null && value !== undefined) ? String(value) : '';
        var phoneValue = stringValue.replace(/^\+?60/, '');
        editField = '<div class="editable-field"><div class="phone-input-group"><span class="phone-prefix">+60</span><input type="text" data-field="' + field + '" value="' + phoneValue + '" maxlength="10" inputmode="numeric"></div></div>';
      } else if (field === 'passport_no') {
        editField = '<div class="editable-field" style="flex-direction:column;align-items:flex-start;"><input type="text" data-field="' + field + '" value="' + (value || '') + '" style="width:100%">' + (docField ? getFileUploadHtml(docField, sectionId, isPdfOnly) : '') + '</div>';
        var stackedDisplay = '<div style="display:flex;flex-direction:column;gap:4px;"><span>' + (notAvailBadge || displayValue) + '</span><span>' + docViewLink + '</span></div>';
        return '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + stackedDisplay + '</span>' + expiryBadge + editField + '</div></div>';
      } else if (field.indexOf('date') !== -1 || field.indexOf('expiry') !== -1) {
        editField = '<div class="editable-field"><input type="date" data-field="' + field + '" value="' + formatDateForInput(value) + '">' + (docField ? getFileUploadHtml(docField, sectionId, isPdfOnly) : '') + '</div>';
      } else {
        editField = '<div class="editable-field"><input type="text" data-field="' + field + '" value="' + (value || '') + '">' + (docField ? getFileUploadHtml(docField, sectionId, isPdfOnly) : '') + '</div>';
      }
      return '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + (notAvailBadge || displayValue) + '</span>' + expiryBadge + editField + '</div></div>';
    }
    
    function renderAirportSection(section, data) {
      var sectionId = 'aiport_authority_section';
      var fields = section.fields.filter(function(f) { return documentFields.indexOf(f) === -1; });
      var html = '<div class="half-width-container">';
      for (var i = 0; i < fields.length; i++) html += renderAirportField(fields[i], data[fields[i]], data, sectionId);
      return html + '</div>';
    }
    
    function renderAirportField(field, value, data, sectionId) {
      var label = formatLabel(field);
      var isExpiry = expiryFields.indexOf(field) !== -1;
      var displayValue = formatValue(value, field);
      var isEmpty = !value;
      var expiryBadge = isExpiry && value ? getExpiryBadge(value) : '';
      var notAvailBadge = getNotAvailBadge(field, value);
      var isPdfOnly = false;
      var docField = fieldDocumentMap[field];
      var url = docField ? extractUrl(data[docField]) : null;
      var docHint = '<span style="font-size:11px;color:#9ca3af;font-style:italic;">Click Edit to upload document</span>';
      var docViewLink = url ? '<span class="status-icon uploaded">' + icons.check + '</span><a href="' + url + '" target="_blank" class="doc-link">' + icons.document + ' View</a>' : docHint;
      var hasDocField = !!docField;
      var editField = '';
      if (hasDocField) {
        var inputHtml = (field.indexOf('date') !== -1 || field.indexOf('expiry') !== -1) ? '<input type="date" data-field="' + field + '" value="' + formatDateForInput(value) + '" style="width:100%">' : '<input type="text" data-field="' + field + '" value="' + (value || '') + '" style="width:100%">';
        editField = '<div class="editable-field" style="flex-direction:column;align-items:flex-start;">' + inputHtml + getFileUploadHtml(docField, sectionId, isPdfOnly) + '</div>';
        var stackedDisplay = '<div style="display:flex;flex-direction:column;gap:4px;"><span>' + (notAvailBadge || displayValue) + '</span><span>' + docViewLink + '</span></div>';
        return '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + stackedDisplay + '</span>' + expiryBadge + editField + '</div></div>';
      }
      if (field.indexOf('date') !== -1 || field.indexOf('expiry') !== -1) {
        editField = '<div class="editable-field"><input type="date" data-field="' + field + '" value="' + formatDateForInput(value) + '"></div>';
      } else {
        editField = '<div class="editable-field"><input type="text" data-field="' + field + '" value="' + (value || '') + '"></div>';
      }
      return '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + (notAvailBadge || displayValue) + '</span>' + expiryBadge + editField + '</div></div>';
    }
    
    function renderGenericSection(section, data) {
      var html = '';
      for (var i = 0; i < section.fields.length; i++) {
        var field = section.fields[i];
        if (documentFields.indexOf(field) !== -1) continue;
        var value = data[field];
        var label = formatLabel(field);
        var displayValue = formatValue(value, field);
        var isEmpty = !value;
        var docLink = getDocLinkHtml(field, data, section.id);
        var expiryBadge = expiryFields.indexOf(field) !== -1 && value ? getExpiryBadge(value) : '';
        var editField = field.indexOf('date') !== -1 || field.indexOf('expiry') !== -1 ? '<div class="editable-field"><input type="date" data-field="' + field + '" value="' + formatDateForInput(value) + '">' + docLink + '</div>' : '<div class="editable-field"><input type="text" data-field="' + field + '" value="' + (value || '') + '">' + docLink + '</div>';
        html += '<div class="data-row"><div class="data-label">' + label + ':</div><div class="data-value ' + (isEmpty ? 'empty' : '') + '"><span class="display-value">' + displayValue + docLink + '</span>' + expiryBadge + editField + '</div></div>';
      }
      return html;
    }
    
    function updateEmploymentVisibility(count) {
      var n = parseInt(count) || 0;
      var empLast = document.getElementById('emp_card_last');
      var empSecondLast = document.getElementById('emp_card_second_last');
      var empThirdLast = document.getElementById('emp_card_third_last');
      if (empLast) { empLast.classList.toggle('hidden', n < 1); if (n < 1) clearEmploymentFields('last'); }
      if (empSecondLast) { empSecondLast.classList.toggle('hidden', n < 2); if (n < 2) clearEmploymentFields('second_last'); }
      if (empThirdLast) { empThirdLast.classList.toggle('hidden', n < 3); if (n < 3) clearEmploymentFields('third_last'); }
      updateEmploymentMandatoryFields(n);
    }

    function updateEmploymentMandatoryFields(newCount) {
      clearMandatoryMarkers('previous_employment_section');
      if (newCount > originalEmploymentCount) {
        if (newCount >= 1 && originalEmploymentCount < 1) setMandatoryFields(mandatoryFields.employment.last, 'previous_employment_section');
        if (newCount >= 2 && originalEmploymentCount < 2) setMandatoryFields(mandatoryFields.employment.second_last, 'previous_employment_section');
        if (newCount >= 3 && originalEmploymentCount < 3) setMandatoryFields(mandatoryFields.employment.third_last, 'previous_employment_section');
      }
    }

    function setMandatoryFields(fields, sectionId) {
      var section = document.querySelector('.profile-section[data-section="' + sectionId + '"]');
      if (!section) return;
      for (var i = 0; i < fields.length; i++) {
        var field = fields[i];
        var input = section.querySelector('[data-field="' + field + '"]');
        if (input) {
          var dataRow = input.closest('.data-row');
          if (dataRow) {
            dataRow.classList.add('mandatory-field');
            activeMandatoryFields.push({ field: field, sectionId: sectionId, type: 'input' });
            updateMandatoryFieldState(dataRow, input.value);
            input.addEventListener('input', function() { updateMandatoryFieldState(this.closest('.data-row'), this.value); });
            input.addEventListener('change', function() { updateMandatoryFieldState(this.closest('.data-row'), this.value); });
          }
        }
        var multiSelect = section.querySelector('[data-multiselect="' + field + '"]');
        if (multiSelect) {
          var dataRow = multiSelect.closest('.data-row');
          if (dataRow) {
            dataRow.classList.add('mandatory-field');
            activeMandatoryFields.push({ field: field, sectionId: sectionId, type: 'multiselect' });
            updateMandatoryFieldState(dataRow, (multiSelectData[field] || []).join(''));
          }
        }
      }
      var indicator = section.querySelector('.mandatory-indicator');
      var sectionFields = activeMandatoryFields.filter(function(item) { return item.sectionId === sectionId; });
      if (!indicator && sectionFields.length > 0) {
        var sectionHeader = section.querySelector('.section-header');
        if (sectionHeader) sectionHeader.insertAdjacentHTML('afterend', '<div class="mandatory-indicator">* Required fields for new entries</div>');
      }
    }

    function updateMultiSelectMandatoryState(field) {
      var section = null;
      for (var i = 0; i < activeMandatoryFields.length; i++) {
        if (activeMandatoryFields[i].field === field) { section = document.querySelector('.profile-section[data-section="' + activeMandatoryFields[i].sectionId + '"]'); break; }
      }
      if (!section) return;
      var multiSelect = section.querySelector('[data-multiselect="' + field + '"]');
      if (multiSelect) {
        var dataRow = multiSelect.closest('.data-row');
        if (dataRow && dataRow.classList.contains('mandatory-field')) updateMandatoryFieldState(dataRow, (multiSelectData[field] || []).join(''));
      }
    }

    function updateMandatoryFieldState(dataRow, value) {
      if (!dataRow || !dataRow.classList.contains('mandatory-field')) return;
      if (value && value.trim() !== '') { dataRow.classList.remove('unfilled'); dataRow.classList.add('filled'); }
      else { dataRow.classList.remove('filled'); dataRow.classList.add('unfilled'); }
    }

    function clearMandatoryMarkers(sectionId) {
      var section = document.querySelector('.profile-section[data-section="' + sectionId + '"]');
      if (!section) return;
      var mandatoryRows = section.querySelectorAll('.mandatory-field');
      for (var i = 0; i < mandatoryRows.length; i++) mandatoryRows[i].classList.remove('mandatory-field', 'filled', 'unfilled');
      var errorRows = section.querySelectorAll('.validation-error-field');
      for (var j = 0; j < errorRows.length; j++) errorRows[j].classList.remove('validation-error-field');
      var indicator = section.querySelector('.mandatory-indicator');
      if (indicator) indicator.remove();
      activeMandatoryFields = activeMandatoryFields.filter(function(item) { return item.sectionId !== sectionId; });
    }

    function validateMandatoryFields(sectionId) {
      var missingFields = [];
      var sectionMandatory = activeMandatoryFields.filter(function(item) { return item.sectionId === sectionId; });
      var section = document.querySelector('.profile-section[data-section="' + sectionId + '"]');
      if (!section) return missingFields;
      for (var i = 0; i < sectionMandatory.length; i++) {
        var item = sectionMandatory[i]; var value = ''; var dataRow = null;
        if (item.type === 'multiselect') { value = (multiSelectData[item.field] || []).join(''); var multiSelect = section.querySelector('[data-multiselect="' + item.field + '"]'); if (multiSelect) dataRow = multiSelect.closest('.data-row'); }
        else { var input = section.querySelector('[data-field="' + item.field + '"]'); if (input) { value = input.value; dataRow = input.closest('.data-row'); } }
        if (dataRow) {
          var parentCard = dataRow.closest('.employment-card'); var parentSubsection = dataRow.closest('.subsection');
          if (parentCard && parentCard.classList.contains('hidden')) continue;
          if (parentSubsection && parentSubsection.classList.contains('hidden')) continue;
        }
        if (!value || value.trim() === '') { missingFields.push(formatLabel(item.field)); if (dataRow) dataRow.classList.add('validation-error-field'); }
        else { if (dataRow) dataRow.classList.remove('validation-error-field'); }
      }
      return missingFields;
    }

    function clearEmploymentFields(suffix) {
      var fields = employmentGroups[suffix];
      for (var i = 0; i < fields.length; i++) {
        var field = fields[i];
        var input = document.querySelector('[data-field="' + field + '"]');
        if (input) input.value = '';
        if (multiSelectData[field]) multiSelectData[field] = [];
        var badges = document.getElementById('badges_' + field);
        if (badges) badges.innerHTML = '';
      }
      var yearDisplay = document.getElementById('year_' + suffix + '_display');
      if (yearDisplay) { yearDisplay.textContent = '-'; yearDisplay.style.color = '#1f2937'; }
    }
    
    function addMultiSelectValue(field, value) {
      if (!value) return;
      if (!multiSelectData[field]) multiSelectData[field] = [];
      if (multiSelectData[field].indexOf(value) !== -1) return;
      multiSelectData[field].push(value);
      updateMultiSelectBadges(field);
      disableSelectedOptions(field);
      if (field === 'egr' || field === 'boroscope') updateEgrBoroscopeDropdowns();
      updateMultiSelectMandatoryState(field);
    }
    
    function removeMultiSelectValue(field, value) {
      if (!multiSelectData[field]) return;
      multiSelectData[field] = multiSelectData[field].filter(function(v) { return v !== value; });
      updateMultiSelectBadges(field);
      disableSelectedOptions(field);
      if (field === 'available_license') { updateLicenseSections(); pendingLicenseChanges.available_license = multiSelectData.available_license.join(', '); updateLicenseMandatoryFields(); }
      if (field === 'amel_license_category') { updateAmelCategoryOptions(); updateApprovalTypeDropdowns(); pendingLicenseChanges.amel_license_category = multiSelectData.amel_license_category.join(', '); }
      if (['b1_type_rating', 'b2_type_rating', 'c_type_rating', 'a1_type_rating'].indexOf(field) !== -1) { updateTypeRatingOptions(); updateApprovalTypeDropdowns(); }
      if (field === 'egr' || field === 'boroscope') updateEgrBoroscopeDropdowns();
      updateMultiSelectMandatoryState(field);
    }
    
    function disableSelectedOptions(field) {
      var select = document.getElementById('select_' + field);
      if (!select) return;
      var selected = multiSelectData[field] || [];
      var options = select.querySelectorAll('option');
      for (var i = 0; i < options.length; i++) { var opt = options[i]; if (opt.value && opt.value !== '') opt.disabled = selected.indexOf(opt.value) !== -1; }
    }
    
    function updateMultiSelectBadges(field) {
      var container = document.getElementById('badges_' + field);
      if (!container) return;
      var html = '';
      var values = multiSelectData[field] || [];
      for (var i = 0; i < values.length; i++) {
        var escapedValue = values[i].replace(/'/g, "\\'").replace(/"/g, '&quot;');
        html += '<span class="badge">' + values[i] + ' <button type="button" class="badge-remove" onclick="removeMultiSelectValue(\'' + field + '\', \'' + escapedValue + '\')">&times;</button></span>';
      }
      container.innerHTML = html;
    }
    
    function updateAllMultiSelectBadges(sectionId) {
      var section = document.querySelector('.profile-section[data-section="' + sectionId + '"]');
      if (!section) return;
      var multiselects = section.querySelectorAll('[data-multiselect]');
      for (var i = 0; i < multiselects.length; i++) {
        var field = multiselects[i].dataset.multiselect;
        updateMultiSelectBadges(field);
        disableSelectedOptions(field);
      }
    }
    
    function addLicense(value) {
      if (!value) return;
      if (!multiSelectData.available_license) multiSelectData.available_license = [];
      if (multiSelectData.available_license.indexOf(value) !== -1) return;
      if (value === 'None') multiSelectData.available_license = ['None'];
      else { multiSelectData.available_license = multiSelectData.available_license.filter(function(v) { return v !== 'None'; }); multiSelectData.available_license.push(value); }
      updateMultiSelectBadges('available_license');
      disableSelectedOptions('available_license');
      updateLicenseSections();
      pendingLicenseChanges.available_license = multiSelectData.available_license.join(', ');
      updateLicenseMandatoryFields();
      updateMultiSelectMandatoryState('available_license');
    }

    function updateLicenseMandatoryFields() {
      var currentLicenses = multiSelectData.available_license || [];
      var hasAMEL = currentLicenses.some(function(l) { return l.indexOf('AMEL') !== -1; });
      var hasAMTL = currentLicenses.some(function(l) { return l.indexOf('AMTL') !== -1; });
      var hadAMEL = originalLicenses.some(function(l) { return l.indexOf('AMEL') !== -1; });
      var hadAMTL = originalLicenses.some(function(l) { return l.indexOf('AMTL') !== -1; });
      clearMandatoryMarkers('caam_licens_section');
      if (hasAMEL && !hadAMEL) {
        var amelMandatory = ['amel_license_category', 'amel_license', 'amel_issue_date', 'amel_license_expiry'];
        var amelCategories = multiSelectData.amel_license_category || [];
        if (amelCategories.indexOf('B1.1') !== -1 || amelCategories.indexOf('B1.1 Limited') !== -1) amelMandatory.push('b1_type_rating');
        if (amelCategories.indexOf('B2') !== -1 || amelCategories.indexOf('B2 Limited') !== -1) amelMandatory.push('b2_type_rating');
        if (amelCategories.indexOf('C') !== -1) amelMandatory.push('c_type_rating');
        setMandatoryFields(amelMandatory, 'caam_licens_section');
      }
      if (hasAMTL && !hadAMTL) setMandatoryFields(mandatoryFields.amtl, 'caam_licens_section');
    }
    
    function updateLicenseSections() {
      var licenses = multiSelectData.available_license || [];
      var hasAMEL = licenses.some(function(l) { return l.indexOf('AMEL') !== -1; });
      var hasAMTL = licenses.some(function(l) { return l.indexOf('AMTL') !== -1; });
      var hasNoLicense = licenses.length === 0 || (licenses.length === 1 && licenses[0] === 'None');
      var amelSection = document.getElementById('amel_subsection');
      var amtlSection = document.getElementById('amtl_subsection');
      var yearFieldsContainer = document.getElementById('year_fields_container');
      if (amelSection) amelSection.classList.toggle('hidden', !hasAMEL);
      if (amtlSection) amtlSection.classList.toggle('hidden', !hasAMTL);
      if (yearFieldsContainer) yearFieldsContainer.classList.toggle('hidden', hasNoLicense);
    }
    
    function addAmelCategory(value) {
      if (!value) return;
      if (!multiSelectData.amel_license_category) multiSelectData.amel_license_category = [];
      if (multiSelectData.amel_license_category.indexOf(value) !== -1) return;
      var conflictMap = { 'B1.1': 'B1.1 Limited', 'B1.1 Limited': 'B1.1', 'B2': 'B2 Limited', 'B2 Limited': 'B2' };
      if (conflictMap[value]) multiSelectData.amel_license_category = multiSelectData.amel_license_category.filter(function(v) { return v !== conflictMap[value]; });
      multiSelectData.amel_license_category.push(value);
      updateMultiSelectBadges('amel_license_category');
      updateAmelCategoryOptions();
      updateApprovalTypeDropdowns();
      updateLicenseMandatoryFields();
      updateMultiSelectMandatoryState('amel_license_category');
    }
    
    function updateAmelCategoryOptions() {
      var select = document.getElementById('select_amel_license_category');
      if (!select) return;
      var selected = multiSelectData.amel_license_category || [];
      var hasB1 = selected.indexOf('B1.1') !== -1; var hasB1Limited = selected.indexOf('B1.1 Limited') !== -1;
      var hasB2 = selected.indexOf('B2') !== -1; var hasB2Limited = selected.indexOf('B2 Limited') !== -1;
      var options = select.querySelectorAll('option');
      for (var i = 0; i < options.length; i++) {
        var opt = options[i]; var val = opt.value;
        var shouldDisable = selected.indexOf(val) !== -1;
        if (val === 'B1.1' && hasB1Limited) shouldDisable = true;
        if (val === 'B1.1 Limited' && hasB1) shouldDisable = true;
        if (val === 'B2' && hasB2Limited) shouldDisable = true;
        if (val === 'B2 Limited' && hasB2) shouldDisable = true;
        opt.disabled = shouldDisable;
      }
    }
    
    function addTypeRating(field, value) {
      if (!value) return;
      if (!multiSelectData[field]) multiSelectData[field] = [];
      if (multiSelectData[field].indexOf(value) !== -1) return;
      if (value === 'No Type Task Rating') multiSelectData[field] = ['No Type Task Rating'];
      else { multiSelectData[field] = multiSelectData[field].filter(function(v) { return v !== 'No Type Task Rating'; }); multiSelectData[field].push(value); }
      updateMultiSelectBadges(field);
      updateTypeRatingOptions();
      updateApprovalTypeDropdowns();
      updateMultiSelectMandatoryState(field);
    }
    
    function updateTypeRatingOptions() {
      var typeRatingFields = ['b1_type_rating', 'b2_type_rating', 'c_type_rating'];
      for (var f = 0; f < typeRatingFields.length; f++) {
        var field = typeRatingFields[f]; var select = document.getElementById('select_' + field);
        if (!select) continue;
        var selected = multiSelectData[field] || []; var hasNoType = selected.indexOf('No Type Task Rating') !== -1;
        var options = select.querySelectorAll('option');
        for (var i = 0; i < options.length; i++) {
          var opt = options[i]; var val = opt.value; var shouldDisable = selected.indexOf(val) !== -1;
          if (hasNoType && val !== '' && val !== 'No Type Task Rating') shouldDisable = true;
          opt.disabled = shouldDisable;
        }
      }
    }

    // ── Disciplinary Section ──────────────────────────────────────────────────
    function renderDisciplinarySection() {
      return '<div class="profile-section" data-section="disciplinary_section">' +
        '<div class="section-header"><div class="section-title">Disciplinary</div></div>' +
        '<div id="disciplinaryContent"><div class="disc-loading"><div class="mini-spinner"></div>Loading records...</div></div>' +
        '</div>';
    }

    var disciplinaryLoaded = false;
    function loadDisciplinaryData() {
      if (disciplinaryLoaded) return;
      disciplinaryLoaded = true;
      var staffNo = userData.staff_no || '';
      if (!staffNo) { document.getElementById('disciplinaryContent').innerHTML = '<p class="disciplinary-nil">Nil</p>'; return; }
      google.script.run
        .withSuccessHandler(function(rows) { renderDisciplinaryTable(rows); })
        .withFailureHandler(function(err) { document.getElementById('disciplinaryContent').innerHTML = '<p class="disciplinary-nil">Could not load records.</p>'; })
        .getDisciplinaryRecords(staffNo);
    }

    function renderDisciplinaryTable(rows) {
      var el = document.getElementById('disciplinaryContent');
      if (!el) return;
      if (!rows || rows.length === 0) { el.innerHTML = '<p class="disciplinary-nil">Nil</p>'; return; }
      rows.sort(function(a, b) { var da = a.date ? new Date(a.date) : new Date(0); var db = b.date ? new Date(b.date) : new Date(0); return db - da; });
      var docLinkSvg = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>';
      function getTypeBadge(type) { if (!type) return ''; var lower = type.toLowerCase(); var cls = lower.indexOf('reprimand') !== -1 ? 'reprimand' : lower.indexOf('warning') !== -1 ? 'warning' : 'other'; return '<span class="disc-type-badge ' + cls + '">' + type + '</span>'; }
      var colgroup = '<colgroup><col style="width:110px"><col style="width:50px"><col style="width:100px"><col style="width:90px"><col style="width:220px"><col style="width:110px"><col style="width:100px"><col style="width:150px"></colgroup>';
      var tableHtml = '<div class="disc-table-wrap"><table class="disc-table" style="min-width:930px;width:100%">' + colgroup;
      tableHtml += '<thead><tr><th>Ref No.</th><th>Year</th><th>Date</th><th>Type</th><th>Reason</th><th>Issued By</th><th>Reference</th><th>Action</th></tr></thead><tbody>';
      var stackHtml = '<div class="disc-stack">';
      for (var i = 0; i < rows.length; i++) {
        var r = rows[i];
        var docLink = r.googleDocLink ? '<a href="' + r.googleDocLink + '" target="_blank" class="disc-doc-link">' + docLinkSvg + ' View</a>' : '';
        var actionCell = r.action ? r.action + (docLink ? '&nbsp;' + docLink : '') : (docLink || '-');
        var typeBadge = getTypeBadge(r.type);
        var yearVal = '-';
        if (r.date) { var yearMatch = r.date.match(/\b(19|20)\d{2}\b/); if (yearMatch) yearVal = yearMatch[0]; }
        tableHtml += '<tr><td style="font-size:11px;font-weight:700;color:#374151">' + (r.referenceNo || '-') + '</td><td style="white-space:nowrap;font-weight:600">' + yearVal + '</td><td style="white-space:nowrap">' + (r.date || '-') + '</td><td>' + (typeBadge || '-') + '</td><td>' + (r.reason || '-') + '</td><td style="white-space:nowrap">' + (r.issuedBy || '-') + '</td><td>' + (r.reference || '-') + '</td><td>' + actionCell + '</td></tr>';
        stackHtml += '<div class="disc-card"><div style="margin-bottom:10px;display:flex;align-items:center;gap:6px;flex-wrap:wrap;"><span class="disc-card-refno">' + (r.referenceNo || '-') + '</span><span class="disc-card-year">' + yearVal + '</span>' + (typeBadge ? typeBadge : '') + (docLink ? docLink : '') + '</div><div class="disc-card-row"><div class="disc-card-label">Date</div><div class="disc-card-value">' + (r.date || '-') + '</div></div><div class="disc-card-row"><div class="disc-card-label">Reason</div><div class="disc-card-value">' + (r.reason || '-') + '</div></div><div class="disc-card-row"><div class="disc-card-label">Issued By</div><div class="disc-card-value">' + (r.issuedBy || '-') + '</div></div><div class="disc-card-row"><div class="disc-card-label">Reference</div><div class="disc-card-value">' + (r.reference || '-') + '</div></div><div class="disc-card-row"><div class="disc-card-label">Action</div><div class="disc-card-value">' + actionCell + '</div></div></div>';
      }
      tableHtml += '</tbody></table></div>';
      stackHtml += '</div>';
      el.innerHTML = tableHtml + stackHtml;
    }

    // ── Absence Section ───────────────────────────────────────────────────────
    function renderAbsenceSection() {
      return '<div class="profile-section" data-section="absence_section">' +
        '<div class="section-header"><div class="section-title">Absence</div></div>' +
        '<div class="abs-submit-bar"><button class="btn btn-primary" onclick="toggleAbsenceForm()">+ Submit Absence</button></div>' +
        '<div class="abs-form-panel" id="absFormPanel">' +
        '<div class="abs-form-title">New Absence Request</div>' +
        '<div class="abs-form-grid">' +
        '<div class="abs-form-field"><label>Start Date</label><input type="date" id="absStartDate" onchange="calcAbsenceDays()"></div>' +
        '<div class="abs-form-field"><label>End Date</label><input type="date" id="absEndDate" onchange="calcAbsenceDays()"></div>' +
        '<div class="abs-form-field"><label>No. of Days</label><input type="text" id="absDays" disabled placeholder="Auto-calculated"></div>' +
        '<div class="abs-form-field"><label>Absence Type</label><select id="absType"><option value="">Select type...</option><option value="Medical Leave">Medical Leave</option><option value="Emergency Leave">Emergency Leave</option><option value="Hospitalisation">Hospitalisation</option><option value="Quarantine">Quarantine</option></select></div>' +
        '<div class="abs-form-field"><label>Immediate Superior</label><select id="absSuperior"><option value="">Loading...</option></select></div>' +
        '<div class="abs-form-field"><label>Remarks <span style="color:#9ca3af;font-weight:400">(optional)</span></label><input type="text" id="absRemarks" placeholder="e.g. MC attached"></div>' +
        '</div>' +
        '<div class="abs-form-footer"><button class="btn btn-grey" onclick="toggleAbsenceForm()">Cancel</button><button class="btn btn-primary" onclick="submitAbsenceForm()">Submit</button></div>' +
        '</div>' +
        '<div id="absenceContent"><div class="disc-loading"><div class="mini-spinner"></div>Loading records...</div></div>' +
        '</div>';
    }

    var absenceLoaded = false;
    var superiorListLoaded = false;

    function loadAbsenceData() {
      if (absenceLoaded) return;
      absenceLoaded = true;
      var staffNo = userData.staff_no || '';
      if (!staffNo) { document.getElementById('absenceContent').innerHTML = '<p class="disciplinary-nil">Nil</p>'; return; }
      google.script.run
        .withSuccessHandler(function(rows) { try { renderAbsenceTable(rows); } catch(ex) { document.getElementById('absenceContent').innerHTML = '<p class="disciplinary-nil">Display error: ' + ex.message + '</p>'; } })
        .withFailureHandler(function(err) { var msg = err && err.message ? err.message : String(err); document.getElementById('absenceContent').innerHTML = '<p class="disciplinary-nil">Could not load records: ' + msg + '</p>'; })
        .getAbsenceRecords(staffNo);
    }

    function loadSuperiorList() {
      if (superiorListLoaded) return;
      superiorListLoaded = true;
      google.script.run
        .withSuccessHandler(function(list) {
          var sel = document.getElementById('absSuperior');
          if (!sel) return;
          sel.innerHTML = '<option value="">Select superior...</option>';
          for (var i = 0; i < list.length; i++) sel.innerHTML += '<option value="' + list[i] + '">' + list[i] + '</option>';
        })
        .withFailureHandler(function() { var sel = document.getElementById('absSuperior'); if (sel) sel.innerHTML = '<option value="">Could not load list</option>'; })
        .getImmediateSuperiorList();
    }

    function toggleAbsenceForm() {
      var panel = document.getElementById('absFormPanel');
      if (!panel) return;
      var opening = !panel.classList.contains('show');
      panel.classList.toggle('show');
      if (opening) loadSuperiorList();
    }

    function calcAbsenceDays() {
      var start = document.getElementById('absStartDate').value; var end = document.getElementById('absEndDate').value;
      var field = document.getElementById('absDays');
      if (!start || !end) { field.value = ''; return; }
      var s = new Date(start); var e = new Date(end);
      if (isNaN(s) || isNaN(e) || e < s) { field.value = e < s ? 'Invalid' : ''; return; }
      field.value = Math.round((e - s) / (1000 * 60 * 60 * 24)) + 1;
    }

    function submitAbsenceForm() {
      var startDate = document.getElementById('absStartDate').value; var endDate = document.getElementById('absEndDate').value;
      var days = document.getElementById('absDays').value; var type = document.getElementById('absType').value;
      var superior = document.getElementById('absSuperior').value; var remarks = document.getElementById('absRemarks').value;
      if (!startDate) { showToast('Please select a Start Date'); return; }
      if (!endDate) { showToast('Please select an End Date'); return; }
      if (days === 'Invalid' || !days) { showToast('End Date must be on or after Start Date'); return; }
      if (!type) { showToast('Please select an Absence Type'); return; }
      if (!superior) { showToast('Please select an Immediate Superior'); return; }
      document.getElementById('savingMessage').textContent = 'Submitting absence...';
      document.getElementById('savingOverlay').classList.add('show');
      google.script.run
        .withSuccessHandler(function(result) {
          document.getElementById('savingOverlay').classList.remove('show');
          if (result.success) {
            showToast('Absence submitted — ' + result.controlNumber);
            document.getElementById('absFormPanel').classList.remove('show');
            ['absStartDate','absEndDate','absDays','absType','absRemarks'].forEach(function(id) { var el = document.getElementById(id); if (el) el.value = ''; });
            document.getElementById('absSuperior').selectedIndex = 0;
            absenceLoaded = false;
            document.getElementById('absenceContent').innerHTML = '<div class="disc-loading"><div class="mini-spinner"></div>Loading records...</div>';
            loadAbsenceData();
          } else { showToast('Error: ' + result.message); }
        })
        .withFailureHandler(function(err) { document.getElementById('savingOverlay').classList.remove('show'); showToast('Error: ' + (err.message || err)); })
        .submitAbsence({ staffNo: userData.staff_no || '', staffName: userData.full_name || '', designation: userData.designation || '', startDate: startDate, startYear: startDate.substring(0, 4), endDate: endDate, days: days, type: type, remarks: remarks, immediateSuperior: superior });
    }

    function getAbsTypeBadge(type) {
      if (!type) return '';
      var lower = type.toLowerCase();
      var cls = lower.indexOf('medical') !== -1 ? 'medical' : lower.indexOf('emergency') !== -1 ? 'emergency' : lower.indexOf('hospital') !== -1 ? 'hospital' : lower.indexOf('quarantine') !== -1 ? 'quarantine' : 'other';
      return '<span class="abs-type-badge ' + cls + '">' + type + '</span>';
    }

    function renderAbsenceTable(rows) {
      var el = document.getElementById('absenceContent');
      if (!el) return;
      if (!rows || rows.length === 0) { el.innerHTML = '<p class="disciplinary-nil">Nil</p>'; return; }
      var groups = {};
      for (var i = 0; i < rows.length; i++) { var yr = rows[i].startYear || 'Unknown'; if (!groups[yr]) groups[yr] = []; groups[yr].push(rows[i]); }
      var years = Object.keys(groups).sort(function(a, b) { return b - a; });
      var colgroup = '<colgroup><col style="width:160px"><col style="width:110px"><col style="width:110px"><col style="width:60px"><col style="width:140px"><col><col style="width:200px"></colgroup>';
      var html = '';
      for (var y = 0; y < years.length; y++) {
        var yr = years[y];
        var groupRows = groups[yr].slice();
        groupRows.sort(function(a, b) { var aNum = parseInt((a.controlNumber || '').split('-').pop(), 10) || 0; var bNum = parseInt((b.controlNumber || '').split('-').pop(), 10) || 0; return bNum - aNum; });
        var tableHtml = '<div class="abs-table-wrap"><table class="abs-table">' + colgroup + '<thead><tr><th>Ref</th><th>Start Date</th><th>End Date</th><th style="text-align:center">Days</th><th>Type</th><th>Remarks</th><th>Immediate Superior</th></tr></thead><tbody>';
        var stackHtml = '<div class="abs-stack">';
        for (var r = 0; r < groupRows.length; r++) {
          var row = groupRows[r];
          var badge = getAbsTypeBadge(row.type);
          var superiorDisplay = row.immediateSuperior ? (row.immediateSuperior.length > 35 ? row.immediateSuperior.substring(0, 35) + '…' : row.immediateSuperior) : '-';
          tableHtml += '<tr><td style="font-size:11px;font-weight:700;color:#374151">' + (row.controlNumber || '-') + '</td><td style="white-space:nowrap">' + (row.startDate || '-') + '</td><td style="white-space:nowrap">' + (row.endDate || '-') + '</td><td style="text-align:center;font-weight:600">' + (row.days || '-') + '</td><td>' + (badge || '-') + '</td><td>' + (row.remarks || '-') + '</td><td style="font-size:12px">' + superiorDisplay + '</td></tr>';
          stackHtml += '<div class="abs-card"><div style="margin-bottom:10px;display:flex;align-items:center;gap:6px;flex-wrap:wrap;"><span class="abs-card-ref">' + (row.controlNumber || '-') + '</span>' + (badge ? badge : '') + '</div><div class="abs-card-row"><div class="abs-card-label">Start Date</div><div class="abs-card-value">' + (row.startDate || '-') + '</div></div><div class="abs-card-row"><div class="abs-card-label">End Date</div><div class="abs-card-value">' + (row.endDate || '-') + '</div></div><div class="abs-card-row"><div class="abs-card-label">Days</div><div class="abs-card-value">' + (row.days || '-') + '</div></div><div class="abs-card-row"><div class="abs-card-label">Remarks</div><div class="abs-card-value">' + (row.remarks || '-') + '</div></div><div class="abs-card-row"><div class="abs-card-label">Superior</div><div class="abs-card-value">' + superiorDisplay + '</div></div></div>';
        }
        tableHtml += '</tbody></table></div>';
        stackHtml += '</div>';
        html += '<div class="abs-year-group"><div class="abs-year-header">' + yr + '</div>' + tableHtml + stackHtml + '</div>';
      }
      el.innerHTML = html;
    }
  </script>
</body>
</html>
