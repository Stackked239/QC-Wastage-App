# Salesforce Barcode/QR Code System Analysis

**Date:** October 16, 2025
**Org:** devtyler sandbox (austin@sundaycool.com.devtyler)
**Purpose:** Document existing barcode system to migrate away from Salesforce Communities

---

## Executive Summary

Your Salesforce org uses QR codes on **Sales Orders** (`AcctSeedERP__Sales_Order__c`) to enable external access via Salesforce Communities. The QR codes link to community pages where users can scan and take actions. Since you're dropping Communities from your subscription, we need to build a custom application to replace this functionality.

---

## Current System Architecture

### 1. QR Code Generation

**Primary Object:** `AcctSeedERP__Sales_Order__c`
**QR Code Field:** `QR_Code__c` (Rich Text field storing base64-encoded image)

**Generation Process:**
- **Flow:** `Generate_QR_Code_from_Button` (flow-meta.xml)
- **Apex Class:** `QRCodeGenerator.cls`
- **API Used:** https://api.qrserver.com/v1/create-qr-code/
- **URL Format:** Uses Custom Label `QR_Code_URL` + `recordId`
- **Storage:** Stores as `<img>` tag with base64-encoded PNG

```apex
// Key code from QRCodeGenerator.cls:line 16
String url = System.Label.QR_Code_URL + recordId;
// Generates QR code pointing to: https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=[URL]
```

**File Reference:** `force-app/main/default/classes/QRCodeGenerator.cls:3-41`

### 2. Barcode Scanning Components

**Aura Components:**
1. **Inventory Transfer Scanning**
   - Component: `glcInventoryTransferOrder_scan`
   - Uses: Gimbal Barcode Scanner (`GMBLBC:barcodeScanner`)
   - Supports: CODE_128 barcodes
   - File: `force-app/main/default/aura/glcInventoryTransferOrder_scan/glcInventoryTransferOrder_scan.cmp:1-199`

2. **Purchase Order Receiving**
   - Component: `glcPurchaseOrder_receive`
   - Similar barcode scanning functionality
   - File: `force-app/main/default/aura/glcPurchaseOrder_receive/`

**Visualforce Test Page:**
- `testscananythingvfp.page` - Test page using ScanAnything component
- File: `force-app/main/default/pages/testscananythingvfp.page:1-20`

**Third-Party Package:**
- Gimbal Barcode Scanner package (`GMBLBC`)
- Permission Set: `Gimbal_Barcode_for_Sunday_Cool`
- File: `force-app/main/default/permissionsets/Gimbal_Barcode_for_Sunday_Cool.permissionset-meta.xml`

### 3. Communities (Experience Cloud) Configuration

**Active Communities:**
1. **portal** (Primary)
   - URL Prefix: `/portal`
   - Site: `portal1`
   - Status: Live
   - Guest File Access: Enabled
   - Internal User Login: Allowed
   - File: `force-app/main/default/networks/portal.network-meta.xml`

2. **Alpha Test**
   - Testing environment
   - File: `force-app/main/default/networks/Alpha Test.network-meta.xml`

3. **Customer Account Portal - Test**
   - Customer-facing test portal
   - File: `force-app/main/default/networks/Customer Account Portal - Test.network-meta.xml`

**Community Profiles:**
- `Customer Community Plus Login User`
- `Customer Community Plus Login User 1`
- `portal Profile`
- `Alpha Test Profile`

**Network Member Groups:**
- Admin
- System Admin - Sales
- Customer Community Plus Login User 1
- System Admin - Art

### 4. Related Objects and Processes

**Primary Objects Using Barcodes:**
1. `AcctSeedERP__Sales_Order__c` - Sales orders with QR codes
2. `Inventory_Transfer_Order__c` - Inventory transfers
3. `AcctSeedERP__Purchase_Order__c` - Purchase orders

**Visual Documents:**
- `SalesOrderPDF.page` - Displays QR code on printed sales orders
- File: `force-app/main/default/pages/SalesOrderPDF.page:123-125`

---

## Current Workflow

### User Journey (Current State)

```
1. Sales Order Created in Salesforce
   ↓
2. QR Code Generated via Flow/Button
   - Calls QRCodeGenerator.cls
   - Stores QR code image in QR_Code__c field
   ↓
3. QR Code Printed on Sales Order PDF
   - Rendered via Visualforce page
   ↓
4. User Scans QR Code
   - Opens Community URL
   - Format: https://[domain]/portal/[path]?id=[recordId]
   ↓
5. Community Page Loads
   - Authenticates user (or guest access)
   - Displays Sales Order information
   - Allows actions (update status, add comments, etc.)
```

### Authentication Model
- **Community users:** Customer Community Plus Login license
- **Guest access:** Enabled for file access
- **Internal users:** Can also access via Communities

---

## Technical Dependencies

### Apex Classes
- `QRCodeGenerator.cls` - QR code generation (27 Sep 2024 by Umesh Rana)
- `GenerateCodeHelper.cls` - Random code generation utility
- `QRCodeGenerator_Test.cls` - Test coverage
- `gcSobject_printLabel.cls` - Print label generation

### Custom Labels
- `QR_Code_URL` - Base URL for QR code links (referenced in QRCodeGenerator.cls:16)

### External APIs
- **QR Server API:** https://api.qrserver.com/v1/create-qr-code/
  - Size: 150x150
  - Format: PNG
  - Encoding: Base64

### Managed Packages
- **AcctSeedERP:** ERP package (Sales Orders, Purchase Orders, Inventory)
- **Gimbal Barcode Scanner (GMBLBC):** Barcode scanning functionality

---

## Migration Challenges

### 1. **Authentication & Access Control**
- Current: Communities provide built-in authentication and guest access
- Challenge: Need to replicate user authentication outside Salesforce
- Consideration: Guest access vs authenticated access for external users

### 2. **URL Structure**
- Current QR codes embed Community URLs
- All existing printed QR codes point to Community URLs
- Need strategy for:
  - Regenerating QR codes with new URLs
  - OR redirecting old URLs to new app

### 3. **Data Access**
- Communities provide automatic OWD/sharing rule enforcement
- Custom app needs Salesforce API integration
- Must implement proper security model

### 4. **User Experience**
- Communities provide mobile-responsive interface
- Custom app must match or exceed UX
- Barcode scanning must work on mobile devices

### 5. **Existing Printed Materials**
- QR codes already printed on physical documents
- May need transition period where both systems work

---

## Recommended Migration Path

### Phase 1: Analysis (Complete)
- [x] Retrieved all Salesforce metadata
- [x] Identified QR code generation process
- [x] Documented Community configuration
- [x] Mapped current workflow

### Phase 2: Architecture Design (Next)
- [ ] Design custom app architecture
- [ ] Plan authentication mechanism
- [ ] Design barcode scanning implementation
- [ ] Plan URL structure and QR code migration

### Phase 3: Implementation
- [ ] Build custom web/mobile app
- [ ] Implement Salesforce API integration
- [ ] Implement barcode scanning
- [ ] Create QR code regeneration utility

### Phase 4: Migration
- [ ] Deploy new app
- [ ] Update QR code generation to use new URLs
- [ ] Test with subset of users
- [ ] Full rollout
- [ ] Decommission Communities

---

## Key Files for Reference

### QR Code Generation
- `force-app/main/default/classes/QRCodeGenerator.cls`
- `force-app/main/default/flows/Generate_QR_Code_from_Button.flow-meta.xml`

### Barcode Scanning
- `force-app/main/default/aura/glcInventoryTransferOrder_scan/`
- `force-app/main/default/aura/glcPurchaseOrder_receive/`
- `force-app/main/default/pages/testscananythingvfp.page`

### PDF Generation
- `force-app/main/default/pages/SalesOrderPDF.page`
- `force-app/main/default/pages/gpInventoryTransferOrderPDF.page`

### Communities Configuration
- `force-app/main/default/networks/portal.network-meta.xml`
- `force-app/main/default/profiles/Customer Community Plus Login User.profile-meta.xml`

### Permission Sets
- `force-app/main/default/permissionsets/Gimbal_Barcode_for_Sunday_Cool.permissionset-meta.xml`

---

## Questions to Answer

Before proceeding with the custom app design, we need to clarify:

1. **User Type:** Are users internal employees, external customers, or both?
2. **Authentication:** Should users log in, or use guest/anonymous access?
3. **Actions:** What specific actions do users take after scanning the QR code?
4. **Platform:** Mobile app (iOS/Android), web app, or both?
5. **QR Code Migration:** Can we regenerate QR codes, or must we support existing ones?
6. **Timeline:** When is the Communities subscription ending?
7. **Budget:** Any constraints on development approach (native vs hybrid vs web)?

---

## Next Steps

1. **Discuss requirements** with stakeholders
2. **Choose app platform** (mobile native, PWA, web)
3. **Design authentication flow** (OAuth, API, guest access)
4. **Create technical architecture** document
5. **Build proof-of-concept** for key functionality
6. **Develop full application**
7. **Migrate and test**
8. **Deploy and monitor**

---

**Document prepared by:** Claude Code
**Source org:** devtyler sandbox
**Metadata retrieved:** October 16, 2025
**Total files analyzed:** 2,068 files
