# Wastage App Replacement Architecture

**Date:** October 16, 2025
**Purpose:** Anonymous-access PWA to replace Salesforce Communities wastage process
**Critical Requirement:** No user authentication required

---

## Executive Summary

This architecture replaces your Salesforce Communities wastage process with a Progressive Web App (PWA) that allows production staff to scan QR codes and enter wastage data without logging in. The solution maintains your current workflow while eliminating the Communities dependency.

**Key Design Principle:** Internal tool with controlled access via QR codes - authentication happens at the QR code level (only authorized Sales Orders get codes), not at the user level.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Production Staff Device                  │
│                    (Phone/iPad with Camera)                  │
│                                                              │
│  1. Scan QR Code → 2. Open URL → 3. Enter Data → 4. Submit │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   PWA (Progressive Web App)                  │
│                  Hosted: Heroku/Vercel/etc.                 │
│                                                              │
│  ┌─────────────────┐  ┌──────────────┐  ┌───────────────┐ │
│  │  Barcode Scanner│  │   Wastage    │  │   Offline     │ │
│  │     Component   │  │     Form     │  │    Cache      │ │
│  └─────────────────┘  └──────────────┘  └───────────────┘ │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Backend Proxy Service (Node.js)                │
│                   Hosted: Same platform                      │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Salesforce API Integration (with stored credentials)│  │
│  │  - getSalesOrder(id)                                  │  │
│  │  - getSalesOrderItems(id)                             │  │
│  │  - createWastageRecords(data)                         │  │
│  └──────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Salesforce Org                           │
│                  (devtyler sandbox)                         │
│                                                              │
│  AcctSeedERP__Sales_Order__c  ←─reads─  Backend Service   │
│  QC_Wastage__c                ←─writes─ Backend Service   │
└─────────────────────────────────────────────────────────────┘
```

---

## Anonymous Access Strategy

### Selected Approach: Backend Proxy with Service Account

**Why This Approach:**
- Users never authenticate - they simply scan QR codes
- QR codes act as authorization tokens (only valid Sales Orders have them)
- Backend service holds Salesforce credentials (not users)
- Simple for production staff - no login friction
- Secure for internal use - QR codes are on printed documents in controlled facility

**How It Works:**

1. **QR Code Contains**: `https://your-app.com/wastage?id=a0X7e000000AbcD`
2. **User Scans**: Opens URL in phone/iPad browser
3. **PWA Requests Data**: `GET /api/sales-order/a0X7e000000AbcD`
4. **Backend Service**:
   - Uses stored Salesforce credentials (Integration User)
   - Queries Sales Order data via REST API
   - Returns data to PWA
5. **User Submits Form**: `POST /api/wastage`
6. **Backend Service**:
   - Validates data
   - Creates QC_Wastage__c records in Salesforce
   - Returns success/error to PWA

**Security Considerations:**
- Backend validates Sales Order ID exists before returning data
- Rate limiting to prevent abuse
- Internal network access only (optional firewall rules)
- QR codes are physical tokens in controlled facility
- No sensitive data exposed in URLs (just record IDs)

---

## Technical Stack

### Frontend (PWA)

**Framework:** React 18+ with Vite
- **Why React:** Modern, well-documented, excellent mobile support
- **Why Vite:** Fast development, optimized builds, PWA plugin support

**Key Libraries:**
```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "html5-qrcode": "^2.3.8",
    "axios": "^1.6.0",
    "workbox-window": "^7.0.0"
  },
  "devDependencies": {
    "vite": "^5.0.0",
    "vite-plugin-pwa": "^0.17.0",
    "@vitejs/plugin-react": "^4.2.0"
  }
}
```

**PWA Features:**
- Installable (Add to Home Screen)
- Offline support (cache Sales Order data)
- App-like experience on mobile devices
- Background sync for submissions

**Barcode Scanning:**
- **Primary:** HTML5 `html5-qrcode` library
- Camera access via browser (no app store required)
- Fallback: Manual Sales Order ID entry

### Backend (Node.js Proxy)

**Framework:** Express.js
- Lightweight, fast, excellent ecosystem
- Easy Salesforce integration via JSforce

**Key Libraries:**
```json
{
  "dependencies": {
    "express": "^4.18.2",
    "jsforce": "^2.0.0-beta.29",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "express-rate-limit": "^7.1.5",
    "dotenv": "^16.3.1"
  }
}
```

**Salesforce Integration:**
- **JSforce:** Official Salesforce REST/SOAP API client
- **Connection Strategy:** OAuth 2.0 JWT Bearer Flow (service-to-service)
- **Credential Storage:** Environment variables (never in code)

### Hosting

**Recommended Platform:** Heroku
- Free/low-cost tier available
- Easy deployment (git push)
- Environment variable management built-in
- Supports both frontend static files and backend Node.js
- HTTPS by default

**Alternative:** Vercel (frontend) + Railway (backend)
- Similar ease of deployment
- Generous free tiers

---

## API Design

### Backend Endpoints

#### 1. Get Sales Order Data
```http
GET /api/sales-order/:salesOrderId
```

**Response:**
```json
{
  "salesOrder": {
    "id": "a0X7e000000AbcD",
    "pressNumber": "Press 1",
    "printer": "John Smith",
    "unloader": "Jane Doe",
    "catcher": "Bob Johnson",
    "jobApprovedBy": "Manager Name",
    "opportunityName": "Acme Corp - T-Shirts"
  },
  "lineItems": [
    {
      "id": "a0Y7e000000XyzA",
      "productSKU": "TS-001",
      "productName": "T-Shirt - Large",
      "color": "Blue",
      "size": "L",
      "quantityOrdered": 100
    }
  ],
  "picklistOptions": {
    "pressNumbers": ["Press 1", "Press 2", "Press 3"],
    "responsibleParties": ["Printer", "Unloader", "Catcher"],
    "issueGroups": ["Print Quality", "Material", "Setup"],
    "locations": ["Press Area", "Unload Station", "QC Area"]
  }
}
```

#### 2. Submit Wastage Data
```http
POST /api/wastage
```

**Request Body:**
```json
{
  "salesOrderId": "a0X7e000000AbcD",
  "pressNumber": "Press 1",
  "printer": "John Smith",
  "unloader": "Jane Doe",
  "catcher": "Bob Johnson",
  "jobApprovedBy": "Manager Name",
  "opportunityName": "Acme Corp - T-Shirts",
  "lineItems": [
    {
      "salesOrderLineId": "a0Y7e000000XyzA",
      "productSKU": "TS-001",
      "productName": "T-Shirt - Large",
      "color": "Blue",
      "size": "L",
      "quantityWasted": 5,
      "responsibleParty": "Printer",
      "issueGroup": "Print Quality",
      "location": "Press Area",
      "issueDescription": "Color misalignment",
      "avoidable": true
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "wastageRecordsCreated": 1,
  "recordIds": ["a1Z7e000000QwErT"]
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Sales Order not found",
  "code": "INVALID_SALES_ORDER_ID"
}
```

---

## Data Flow Details

### 1. QR Code Scan → Data Load

**Current Flow (Communities LWC):**
```
1. Scan QR → https://[domain]/portal/wastage?salesOrderId=XXX
2. connectedCallback() extracts URL param
3. @wire adapters query Salesforce (user authenticated)
4. Component renders with data
```

**New Flow (PWA):**
```
1. Scan QR → https://your-app.com/wastage?id=XXX
2. React useEffect() extracts URL param
3. axios.get('/api/sales-order/XXX') → Backend
4. Backend queries Salesforce (service account)
5. Backend returns JSON to frontend
6. React renders form with data
```

**Code Comparison:**

**OLD (LWC):**
```javascript
connectedCallback() {
    const url = new URL(window.location.href);
    const params = new URLSearchParams(url.search);
    this.salesOrderId = params.get('salesOrderId');
}

@wire(getSalesOrderRecord, { recordId: '$salesOrderId' })
wiredSalesOrderRecord({ error, data }) {
    if (data) {
        this.wastageWrapper.pressNumber = data.Press_Number__c;
        // ... more fields
    }
}
```

**NEW (React PWA):**
```javascript
useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const salesOrderId = params.get('id');

    axios.get(`/api/sales-order/${salesOrderId}`)
        .then(response => {
            setWastageData({
                pressNumber: response.data.salesOrder.pressNumber,
                // ... more fields
            });
        });
}, []);
```

### 2. Form Submission → Record Creation

**Current Flow (Communities LWC):**
```
1. User clicks submit
2. LWC calls insertWastageRecords({ wastageRecSalesItemList })
3. Apex creates QC_Wastage__c records (runs as authenticated user)
4. Success/error returned to component
```

**New Flow (PWA):**
```
1. User clicks submit
2. React calls axios.post('/api/wastage', wastageData)
3. Backend validates data
4. Backend uses JSforce to create QC_Wastage__c records
5. Backend returns success/error to frontend
```

**Code Comparison:**

**OLD (LWC):**
```javascript
handleSubmitClick() {
    insertWastageRecords({ wastageRecSalesItemList: { ...this.wastageWrapper, salesOrderItems } })
        .then(() => {
            this.formDisplay = false;
        })
        .catch(error => {
            // error handling
        });
}
```

**NEW (React PWA):**
```javascript
const handleSubmit = async () => {
    try {
        const response = await axios.post('/api/wastage', wastageData);
        if (response.data.success) {
            setFormSubmitted(true);
        }
    } catch (error) {
        setError(error.response.data.error);
    }
};
```

**NEW (Backend Service):**
```javascript
app.post('/api/wastage', async (req, res) => {
    try {
        const conn = new jsforce.Connection({
            instanceUrl: process.env.SF_INSTANCE_URL,
            accessToken: await getAccessToken()
        });

        const wastageRecords = req.body.lineItems
            .filter(item => item.quantityWasted > 0)
            .map(item => ({
                Sales_Order__c: req.body.salesOrderId,
                Sales_Order_Line__c: item.salesOrderLineId,
                Product_SKU__c: item.productSKU,
                Quantity_Wasted__c: item.quantityWasted,
                Responsible_Party__c: item.responsibleParty,
                Issue_Group__c: item.issueGroup,
                Location__c: item.location,
                Issue_Description__c: item.issueDescription,
                Avoidable__c: item.avoidable
            }));

        const result = await conn.sobject('QC_Wastage__c').create(wastageRecords);

        res.json({
            success: true,
            wastageRecordsCreated: wastageRecords.length,
            recordIds: result.map(r => r.id)
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});
```

---

## Salesforce Integration Setup

### 1. Create Integration User

**Steps:**
1. Go to Setup → Users → New User
2. Create user: `wastage-integration@sundaycool.com.devtyler`
3. Profile: `System Administrator` (or custom profile with required permissions)
4. License: `Salesforce` (not Communities)

**Required Permissions:**
- Read: `AcctSeedERP__Sales_Order__c`
- Read: `AcctSeedERP__Sales_Order_Line__c`
- Create: `QC_Wastage__c`

### 2. Create Connected App

**Steps:**
1. Setup → App Manager → New Connected App
2. Name: `Wastage App Integration`
3. Enable OAuth Settings
4. Callback URL: `https://your-app.com/oauth/callback` (placeholder)
5. Selected OAuth Scopes:
   - `api` - Access and manage data
   - `refresh_token` - Provide access token
6. Enable: `Enable for Device Flow` (for service-to-service)

**Save these credentials:**
- Consumer Key (client_id)
- Consumer Secret (client_secret)

### 3. Generate JWT for Service Account

**Backend will use JWT Bearer Flow:**

```javascript
// backend/services/salesforce-auth.js
const jsforce = require('jsforce');
const jwt = require('jsonwebtoken');
const fs = require('fs');

async function getSalesforceConnection() {
    // JWT Bearer Token Flow (service-to-service)
    const privateKey = fs.readFileSync(process.env.SF_PRIVATE_KEY_PATH, 'utf8');

    const jwtPayload = {
        iss: process.env.SF_CLIENT_ID,
        sub: process.env.SF_USERNAME,
        aud: process.env.SF_LOGIN_URL,
        exp: Math.floor(Date.now() / 1000) + 180
    };

    const token = jwt.sign(jwtPayload, privateKey, { algorithm: 'RS256' });

    const conn = new jsforce.Connection({
        instanceUrl: process.env.SF_INSTANCE_URL,
        version: '62.0'
    });

    await conn.loginByOAuth2(
        token,
        { grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer' }
    );

    return conn;
}

module.exports = { getSalesforceConnection };
```

**Environment Variables:**
```bash
SF_CLIENT_ID=3MVG9...your_consumer_key
SF_USERNAME=wastage-integration@sundaycool.com.devtyler
SF_LOGIN_URL=https://test.salesforce.com
SF_INSTANCE_URL=https://sundaycool--devtyler.sandbox.my.salesforce.com
SF_PRIVATE_KEY_PATH=/app/config/server.key
```

---

## QR Code Migration Strategy

### Challenge
Existing printed Sales Orders have QR codes pointing to:
```
https://[salesforce-domain]/portal/wastage?salesOrderId=XXX
```

New app uses:
```
https://your-app.com/wastage?id=XXX
```

### Solution: Three-Phase Approach

**Phase 1: URL Redirect (Immediate)**
- Set up redirect rule in Salesforce Communities (before shutting down)
- OR create simple redirect page on old domain pointing to new app
- Allows existing QR codes to continue working

**Example Redirect Page:**
```html
<!-- Hosted at: https://[salesforce-domain]/portal/wastage -->
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <script>
        const params = new URLSearchParams(window.location.search);
        const salesOrderId = params.get('salesOrderId');
        window.location.replace(`https://your-app.com/wastage?id=${salesOrderId}`);
    </script>
</head>
<body>
    <p>Redirecting to new wastage app...</p>
</body>
</html>
```

**Phase 2: Parallel Operation (1-3 months)**
- Both old and new URLs work
- Gradually reprint Sales Orders with new QR codes
- Monitor usage to see when old URLs are no longer accessed

**Phase 3: Full Cutover**
- All new Sales Orders use new QR code URLs
- Old printed documents naturally age out of circulation
- Communities can be safely decommissioned

### Update QR Code Generation

**Modify QRCodeGenerator.cls:**

```apex
// OLD
String url = System.Label.QR_Code_URL + recordId;
// Where QR_Code_URL = https://[salesforce-domain]/portal/wastage?salesOrderId=

// NEW
String url = System.Label.QR_Code_URL + recordId;
// Update QR_Code_URL to: https://your-app.com/wastage?id=
```

**Steps:**
1. Setup → Custom Labels → QR_Code_URL
2. Change value to: `https://your-app.com/wastage?id=`
3. All new QR codes will use new URL format

---

## Mobile Optimization

### Camera Access for Barcode Scanning

**HTML5 Camera API:**
```javascript
// React component for barcode scanning
import { Html5Qrcode } from 'html5-qrcode';

function BarcodeScanner({ onScan }) {
    const scannerRef = useRef(null);

    useEffect(() => {
        const scanner = new Html5Qrcode("qr-reader");

        scanner.start(
            { facingMode: "environment" }, // Use back camera
            {
                fps: 10,
                qrbox: { width: 250, height: 250 }
            },
            (decodedText) => {
                // Extract Sales Order ID from scanned URL
                const url = new URL(decodedText);
                const salesOrderId = url.searchParams.get('id');
                onScan(salesOrderId);
                scanner.stop();
            }
        );

        return () => scanner.stop();
    }, []);

    return (
        <div>
            <div id="qr-reader" style={{ width: '100%' }}></div>
            <p>Point camera at QR code</p>
        </div>
    );
}
```

### Touch-Friendly Form Design

**Key Considerations:**
- Large touch targets (44x44px minimum)
- Adequate spacing between form fields
- Native mobile input types (`type="number"`, `type="tel"`)
- Sticky submit button at bottom of screen
- Auto-focus on first empty required field

**Responsive Layout:**
```css
/* Mobile-first approach */
.wastage-form {
    padding: 16px;
    max-width: 100%;
}

.form-field {
    margin-bottom: 20px; /* Adequate spacing */
}

.form-input {
    min-height: 44px; /* Touch-friendly */
    font-size: 16px; /* Prevents zoom on iOS */
    width: 100%;
}

.submit-button {
    position: sticky;
    bottom: 0;
    width: 100%;
    min-height: 48px;
    font-size: 18px;
}

/* Tablet landscape */
@media (min-width: 768px) {
    .wastage-form {
        max-width: 600px;
        margin: 0 auto;
    }
}
```

### PWA Manifest for "Add to Home Screen"

```json
// public/manifest.json
{
  "name": "Sunday Cool Wastage App",
  "short_name": "Wastage",
  "description": "QC Wastage tracking for production staff",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#0176D3",
  "orientation": "portrait",
  "icons": [
    {
      "src": "/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### Offline Support

**Service Worker Strategy:**
```javascript
// Workbox configuration (vite.config.js)
import { VitePWA } from 'vite-plugin-pwa';

export default {
    plugins: [
        VitePWA({
            registerType: 'autoUpdate',
            workbox: {
                runtimeCaching: [
                    {
                        urlPattern: /^https:\/\/your-app\.com\/api\/sales-order\/.*/,
                        handler: 'NetworkFirst', // Try network, fall back to cache
                        options: {
                            cacheName: 'sales-orders',
                            expiration: {
                                maxEntries: 50,
                                maxAgeSeconds: 60 * 60 // 1 hour
                            }
                        }
                    },
                    {
                        urlPattern: /^https:\/\/your-app\.com\/api\/wastage/,
                        handler: 'NetworkOnly', // Submissions must be online
                        options: {
                            backgroundSync: {
                                name: 'wastage-submissions',
                                options: {
                                    maxRetentionTime: 24 * 60 // 24 hours
                                }
                            }
                        }
                    }
                ]
            }
        })
    ]
};
```

**Benefits:**
- Sales Order data cached after first load (works offline)
- Form submissions queue if offline, auto-retry when online
- App shell loads instantly from cache

---

## Security Considerations

### 1. Backend Service Security

**Protection Measures:**
- **Rate Limiting:** Max 100 requests per IP per hour
- **CORS:** Only allow requests from your-app.com domain
- **Input Validation:** Validate all Sales Order IDs (18-character format)
- **Error Messages:** Never expose Salesforce errors directly to frontend

**Implementation:**
```javascript
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');

const limiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 100, // 100 requests per hour
    message: 'Too many requests from this IP'
});

app.use(helmet()); // Security headers
app.use(limiter); // Rate limiting
app.use(cors({
    origin: 'https://your-app.com',
    methods: ['GET', 'POST']
}));

// Validate Sales Order ID format
function isValidSalesforceId(id) {
    return /^[a-zA-Z0-9]{15}$|^[a-zA-Z0-9]{18}$/.test(id);
}
```

### 2. Salesforce Permissions

**Principle of Least Privilege:**
- Integration user has ONLY required permissions
- Cannot delete records
- Cannot modify Sales Orders (read-only)
- Can only create QC_Wastage__c records

**Custom Profile Permissions:**
```
Read: AcctSeedERP__Sales_Order__c
Read: AcctSeedERP__Sales_Order_Line__c
Read: AcctSeedERP__Opportunity__c (for related opportunity name)
Create: QC_Wastage__c
Read: QC_Wastage__c (for validation)
```

### 3. Network Security (Optional)

**If needed for extra security:**
- IP whitelist: Only allow requests from production facility network
- VPN requirement: Require staff to be on internal network
- Heroku IP restrictions: Configure allowed IPs in Heroku settings

**Trade-off:** Adds complexity vs. security benefit for internal tool with QR code authorization model

### 4. Data Privacy

**No PII Exposure:**
- Sales Order IDs in URLs are not sensitive (just record IDs)
- No customer financial data displayed in app
- Staff names are internal information only

**HTTPS Everywhere:**
- App hosted on HTTPS (enforced by Heroku/Vercel)
- API calls encrypted in transit
- No mixed content warnings

---

## Development Roadmap

### Phase 1: Setup & Foundation (Week 1)

**Salesforce Configuration:**
- [ ] Create integration user with required permissions
- [ ] Create Connected App for API access
- [ ] Generate JWT credentials for service account
- [ ] Test API access with Postman/Insomnia

**Backend Development:**
- [ ] Initialize Node.js project with Express
- [ ] Set up JSforce integration
- [ ] Implement `/api/sales-order/:id` endpoint
- [ ] Implement `/api/wastage` endpoint
- [ ] Add rate limiting and security middleware
- [ ] Environment variable configuration

**Frontend Development:**
- [ ] Initialize React + Vite project
- [ ] Set up PWA configuration
- [ ] Create basic routing (/ → scanner, /wastage → form)
- [ ] Implement barcode scanner component

**Deliverable:** Backend API working with Salesforce, basic frontend structure

### Phase 2: Core Functionality (Week 2)

**Frontend Development:**
- [ ] Build Sales Order data display (job details card)
- [ ] Build wastage form (common fields section)
- [ ] Build line items table with dynamic fields
- [ ] Implement form validation (required fields when quantity > 0)
- [ ] Connect form submission to backend API
- [ ] Success/error message handling

**Testing:**
- [ ] Test with real Sales Order IDs from devtyler sandbox
- [ ] Verify data loads correctly
- [ ] Verify QC_Wastage__c records created in Salesforce
- [ ] Test on iPhone and iPad browsers

**Deliverable:** Fully functional wastage entry workflow

### Phase 3: Mobile Optimization (Week 3)

**UI/UX Improvements:**
- [ ] Responsive design for phone screens (320px - 428px)
- [ ] Responsive design for tablet screens (768px - 1024px)
- [ ] Touch-friendly form controls (44x44px targets)
- [ ] Camera permissions handling
- [ ] Loading states and spinners
- [ ] Offline detection and messaging

**PWA Features:**
- [ ] Service worker for offline support
- [ ] App manifest for "Add to Home Screen"
- [ ] App icons (192x192, 512x512)
- [ ] Splash screen
- [ ] Cache strategy for Sales Order data

**Testing:**
- [ ] Test on multiple iOS devices (iPhone, iPad)
- [ ] Test on multiple Android devices
- [ ] Test offline behavior
- [ ] Test "Add to Home Screen" installation

**Deliverable:** Mobile-optimized PWA ready for pilot testing

### Phase 4: QR Code Migration (Week 4)

**Salesforce Updates:**
- [ ] Update Custom Label `QR_Code_URL` to new app URL
- [ ] Generate QR codes for test Sales Orders
- [ ] Print test Sales Orders with new QR codes
- [ ] Verify new QR codes scan and load correctly

**Redirect Setup:**
- [ ] Create redirect page for old Community URLs
- [ ] Test redirect with existing printed QR codes
- [ ] Document redirect strategy

**Deployment:**
- [ ] Deploy backend to Heroku (or chosen platform)
- [ ] Deploy frontend to Heroku/Vercel
- [ ] Configure custom domain (optional)
- [ ] Set up environment variables in production

**Deliverable:** Production app live, both old and new QR codes working

### Phase 5: Pilot Testing (Week 5)

**User Testing:**
- [ ] Select 3-5 production staff for pilot group
- [ ] Train on new app (should be minimal - same workflow)
- [ ] Monitor for issues and feedback
- [ ] Track app usage and error rates

**Bug Fixes & Refinements:**
- [ ] Address any bugs discovered during pilot
- [ ] UI/UX refinements based on feedback
- [ ] Performance optimizations if needed

**Documentation:**
- [ ] User guide (scan QR → enter data → submit)
- [ ] IT/Admin documentation
- [ ] Troubleshooting guide

**Deliverable:** Stable app ready for full rollout

### Phase 6: Full Rollout (Week 6)

**Production Launch:**
- [ ] Announce new app to all production staff
- [ ] Provide brief training/walkthrough
- [ ] Make new app available to all users
- [ ] Monitor usage and errors

**Communities Decommission:**
- [ ] Wait 2-4 weeks for all old QR codes to age out
- [ ] Verify no more traffic to old Community URLs
- [ ] Deactivate Communities in Salesforce
- [ ] Remove Communities from subscription

**Success Metrics:**
- [ ] 100% of wastage entries via new app
- [ ] <5% error rate in submissions
- [ ] Positive user feedback
- [ ] Communities successfully removed

**Deliverable:** Complete migration, Communities decommissioned

---

## Cost Estimate

### Development Time
- **Phase 1 (Setup):** 15-20 hours
- **Phase 2 (Core):** 20-25 hours
- **Phase 3 (Mobile):** 15-20 hours
- **Phase 4 (Migration):** 8-10 hours
- **Phase 5 (Pilot):** 10-12 hours
- **Phase 6 (Rollout):** 5-8 hours

**Total:** 73-95 hours of development work

### Hosting Costs (Annual)
- **Heroku Hobby Dyno:** $7/month × 12 = $84/year (backend)
- **Heroku Hobby Dyno:** $7/month × 12 = $84/year (frontend) OR Vercel Free Tier
- **Custom Domain (optional):** $12/year

**Total:** ~$180/year (or $84/year if using Vercel free tier for frontend)

**Alternative (even cheaper):** Railway.app or Render.com free tiers → $0/year

### Savings
- **Salesforce Communities:** ~$75-150/user/month saved
- Break-even: First month of Communities savings pays for entire year of hosting

---

## Technical Risks & Mitigation

### Risk 1: Salesforce API Rate Limits
**Impact:** Backend could hit API limits with heavy usage
**Probability:** Low (small user base)
**Mitigation:**
- Implement caching layer (Redis) if needed
- Monitor API usage via Salesforce Setup → System Overview
- Salesforce API limits are generous (5,000+ calls/day on sandbox, more in production)

### Risk 2: Camera Access Issues
**Impact:** Users unable to scan QR codes on some devices
**Probability:** Medium (browser compatibility varies)
**Mitigation:**
- Fallback to manual Sales Order ID entry
- Test on all target devices before rollout
- Provide clear error messages and instructions

### Risk 3: Offline Submissions Lost
**Impact:** Data loss if user closes browser before sync
**Probability:** Low (background sync handles this)
**Mitigation:**
- Service worker background sync queues submissions
- Show clear status: "Submitting...", "Queued for sync", "Submitted"
- User education: "Keep app open until submission confirms"

### Risk 4: Integration User Credentials Compromised
**Impact:** Unauthorized Salesforce access
**Probability:** Very Low (credentials stored securely)
**Mitigation:**
- Rotate credentials periodically (every 90 days)
- Monitor integration user login history
- Set up Salesforce alerts for unusual activity
- Use Heroku config vars (not in code)

### Risk 5: Old QR Codes Stop Working
**Impact:** Production disruption if redirect breaks
**Probability:** Low (simple redirect logic)
**Mitigation:**
- Keep redirect page live for 6+ months
- Monitor redirect page traffic to know when safe to remove
- Document process for generating new QR codes

---

## Success Criteria

### Technical Success
- ✅ App loads in <3 seconds on mobile devices
- ✅ QR code scan → data display in <5 seconds
- ✅ Form submission creates QC_Wastage__c records correctly
- ✅ 99%+ uptime (Heroku free tier = 99.99% uptime)
- ✅ Works on iOS 14+, Android 10+
- ✅ PWA installable via "Add to Home Screen"

### User Success
- ✅ Production staff can use app without training (<5 minutes to learn)
- ✅ No login required (critical requirement met)
- ✅ Maintains current workflow (scan → enter → submit)
- ✅ Works on existing devices (phones/iPads)
- ✅ Positive user feedback (informal survey)

### Business Success
- ✅ Communities subscription cancelled (cost savings achieved)
- ✅ No disruption to production operations
- ✅ All wastage data continues to flow into Salesforce
- ✅ Reporting and analytics unchanged
- ✅ Compliance maintained (data audit trail)

---

## Next Steps

### Immediate Actions (This Week)
1. **Salesforce Setup:**
   - Create integration user: `wastage-integration@sundaycool.com.devtyler`
   - Create Connected App: `Wastage App Integration`
   - Test API access with credentials

2. **Development Environment:**
   - Set up GitHub repository for code
   - Initialize backend Node.js project
   - Initialize frontend React project
   - Connect to Heroku or chosen hosting platform

3. **Technical Proof of Concept:**
   - Build simple backend endpoint: `GET /api/sales-order/:id`
   - Test JSforce connection to Salesforce
   - Verify data retrieval works

### Short-Term (Next 2 Weeks)
- Complete Phase 1 & 2 of development roadmap
- Build functional prototype with full workflow
- Test with real Sales Order from devtyler sandbox

### Medium-Term (Next 4-6 Weeks)
- Complete Phase 3-5 of development roadmap
- Pilot test with 3-5 production staff
- Refine based on feedback
- Full rollout

### Long-Term (2-3 Months)
- Decommission Communities
- Cancel Communities subscription
- Document lessons learned

---

## Appendix A: Field Mapping

### Sales Order Fields (Read-Only)

| Salesforce Field | API Name | Frontend Display | Data Type |
|------------------|----------|------------------|-----------|
| Press Number | `Press_Number__c` | Dropdown | Picklist |
| Printer | `Printer__c` | Dropdown | Picklist |
| Unloader | `Unloader__c` | Dropdown | Picklist |
| Catcher | `Catcher__c` | Dropdown | Picklist |
| Job Approved By | `Job_Approved_By__c` | Dropdown | Picklist |
| Opportunity Name | `AcctSeedERP__Opportunity__r.Name` | Text | String |

### Sales Order Line Fields (Read-Only)

| Salesforce Field | API Name | Frontend Display | Data Type |
|------------------|----------|------------------|-----------|
| Product SKU | `AcctSeedERP__Product__r.SKU__c` | Text | String |
| Product Name | `AcctSeedERP__Product__r.Name` | Text | String |
| Product Color | `AcctSeedERP__Product__r.Color__c` | Text | String |
| Product Size | `AcctSeedERP__Product__r.Size__c` | Text | String |
| Quantity | `AcctSeedERP__Quantity_Ordered__c` | Number | Decimal |

### QC Wastage Fields (Created)

| Salesforce Field | API Name | Frontend Input | Data Type | Required If |
|------------------|----------|----------------|-----------|-------------|
| Sales Order | `Sales_Order__c` | (Hidden) | Lookup | Always |
| Sales Order Line | `Sales_Order_Line__c` | (Hidden) | Lookup | Always |
| Product SKU | `Product_SKU__c` | (Read-only) | String | Always |
| Product Name | `Product_Name__c` | (Read-only) | String | Always |
| Color | `Color__c` | (Read-only) | String | Always |
| Size | `Size__c` | (Read-only) | String | Always |
| Quantity Wasted | `Quantity_Wasted__c` | Number input | Integer | Always |
| Responsible Party | `Responsible_Party__c` | Dropdown | Picklist | Qty > 0 |
| Issue Group | `Issue_Group__c` | Dropdown | Picklist | Qty > 0 |
| Location | `Location__c` | Dropdown | Picklist | Qty > 0 |
| Issue Description | `Issue_Description__c` | Textarea | Long Text | Qty > 0 |
| Avoidable | `Avoidable__c` | Checkbox | Boolean | Qty > 0 |
| Press Number | `Press_Number__c` | (From SO) | String | Always |
| Printer | `Printer__c` | (From SO) | String | Always |
| Unloader | `Unloader__c` | (From SO) | String | Always |
| Catcher | `Catcher__c` | (From SO) | String | Always |
| Job Approved By | `Job_Approved_By__c` | (From SO) | String | Always |

---

## Appendix B: Sample Code Snippets

### Backend: Sales Order Query
```javascript
// backend/controllers/salesOrderController.js
const { getSalesforceConnection } = require('../services/salesforce-auth');

async function getSalesOrder(req, res) {
    const { salesOrderId } = req.params;

    // Validate ID format
    if (!/^[a-zA-Z0-9]{15}$|^[a-zA-Z0-9]{18}$/.test(salesOrderId)) {
        return res.status(400).json({
            success: false,
            error: 'Invalid Sales Order ID format'
        });
    }

    try {
        const conn = await getSalesforceConnection();

        // Query Sales Order
        const salesOrder = await conn.sobject('AcctSeedERP__Sales_Order__c')
            .select('Id, Press_Number__c, Printer__c, Unloader__c, Catcher__c, Job_Approved_By__c, AcctSeedERP__Opportunity__r.Name')
            .where({ Id: salesOrderId })
            .execute();

        if (!salesOrder || salesOrder.length === 0) {
            return res.status(404).json({
                success: false,
                error: 'Sales Order not found'
            });
        }

        // Query Sales Order Lines
        const lineItems = await conn.sobject('AcctSeedERP__Sales_Order_Line__c')
            .select('Id, AcctSeedERP__Product__r.SKU__c, AcctSeedERP__Product__r.Name, AcctSeedERP__Product__r.Color__c, AcctSeedERP__Product__r.Size__c, AcctSeedERP__Quantity_Ordered__c')
            .where({ AcctSeedERP__Sales_Order__c: salesOrderId })
            .execute();

        // Query picklist options (cached or from describe)
        const picklistOptions = await getPicklistOptions(conn);

        res.json({
            salesOrder: {
                id: salesOrder[0].Id,
                pressNumber: salesOrder[0].Press_Number__c,
                printer: salesOrder[0].Printer__c,
                unloader: salesOrder[0].Unloader__c,
                catcher: salesOrder[0].Catcher__c,
                jobApprovedBy: salesOrder[0].Job_Approved_By__c,
                opportunityName: salesOrder[0].AcctSeedERP__Opportunity__r?.Name
            },
            lineItems: lineItems.map(item => ({
                id: item.Id,
                productSKU: item.AcctSeedERP__Product__r?.SKU__c,
                productName: item.AcctSeedERP__Product__r?.Name,
                color: item.AcctSeedERP__Product__r?.Color__c,
                size: item.AcctSeedERP__Product__r?.Size__c,
                quantityOrdered: item.AcctSeedERP__Quantity_Ordered__c
            })),
            picklistOptions
        });
    } catch (error) {
        console.error('Salesforce query error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to retrieve Sales Order data'
        });
    }
}

module.exports = { getSalesOrder };
```

### Frontend: Wastage Form Component
```javascript
// frontend/src/components/WastageForm.jsx
import { useState, useEffect } from 'react';
import axios from 'axios';

function WastageForm() {
    const [salesOrderId, setSalesOrderId] = useState('');
    const [loading, setLoading] = useState(true);
    const [formData, setFormData] = useState(null);
    const [lineItems, setLineItems] = useState([]);
    const [submitted, setSubmitted] = useState(false);
    const [error, setError] = useState(null);

    // Extract Sales Order ID from URL on mount
    useEffect(() => {
        const params = new URLSearchParams(window.location.search);
        const id = params.get('id');

        if (!id) {
            setError('No Sales Order ID provided');
            setLoading(false);
            return;
        }

        setSalesOrderId(id);
        loadSalesOrderData(id);
    }, []);

    // Load Sales Order data from backend
    const loadSalesOrderData = async (id) => {
        try {
            const response = await axios.get(`/api/sales-order/${id}`);

            setFormData({
                pressNumber: response.data.salesOrder.pressNumber,
                printer: response.data.salesOrder.printer,
                unloader: response.data.salesOrder.unloader,
                catcher: response.data.salesOrder.catcher,
                jobApprovedBy: response.data.salesOrder.jobApprovedBy,
                opportunityName: response.data.salesOrder.opportunityName
            });

            setLineItems(
                response.data.lineItems.map((item, index) => ({
                    ...item,
                    index,
                    quantityWasted: 0,
                    responsibleParty: '',
                    issueGroup: '',
                    location: '',
                    issueDescription: '',
                    avoidable: false
                }))
            );

            setLoading(false);
        } catch (err) {
            setError('Failed to load Sales Order data');
            setLoading(false);
        }
    };

    // Handle form submission
    const handleSubmit = async (e) => {
        e.preventDefault();

        // Validate that at least one line item has wastage
        const itemsWithWastage = lineItems.filter(item => item.quantityWasted > 0);
        if (itemsWithWastage.length === 0) {
            setError('Please enter at least one wastage quantity');
            return;
        }

        // Validate required fields for items with wastage
        const invalidItems = itemsWithWastage.filter(item =>
            !item.responsibleParty || !item.issueGroup || !item.location || !item.issueDescription
        );
        if (invalidItems.length > 0) {
            setError('Please fill all required fields for items with wastage quantities');
            return;
        }

        try {
            const response = await axios.post('/api/wastage', {
                salesOrderId,
                ...formData,
                lineItems: itemsWithWastage
            });

            if (response.data.success) {
                setSubmitted(true);
            }
        } catch (err) {
            setError(err.response?.data?.error || 'Failed to submit wastage data');
        }
    };

    if (loading) return <div>Loading Sales Order data...</div>;
    if (error) return <div>Error: {error}</div>;
    if (submitted) return <div>Wastage data submitted successfully!</div>;

    return (
        <form onSubmit={handleSubmit}>
            {/* Sales Order details section */}
            <section>
                <h2>Sales Order</h2>
                <div>
                    <label>Press Number</label>
                    <select
                        value={formData.pressNumber}
                        onChange={(e) => setFormData({...formData, pressNumber: e.target.value})}
                    >
                        <option>Press 1</option>
                        <option>Press 2</option>
                    </select>
                </div>
                {/* More fields... */}
            </section>

            {/* Line items table */}
            <section>
                <h2>Wastage Details</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Color</th>
                            <th>Qty Wasted</th>
                            <th>Responsible Party</th>
                            <th>Issue Group</th>
                            {/* More columns... */}
                        </tr>
                    </thead>
                    <tbody>
                        {lineItems.map(item => (
                            <tr key={item.index}>
                                <td>{item.productName}</td>
                                <td>{item.color}</td>
                                <td>
                                    <input
                                        type="number"
                                        value={item.quantityWasted}
                                        onChange={(e) => {
                                            const updated = [...lineItems];
                                            updated[item.index].quantityWasted = parseInt(e.target.value) || 0;
                                            setLineItems(updated);
                                        }}
                                    />
                                </td>
                                {/* More input fields... */}
                            </tr>
                        ))}
                    </tbody>
                </table>
            </section>

            <button type="submit">Submit Wastage</button>
        </form>
    );
}

export default WastageForm;
```

---

**Document prepared by:** Claude Code
**Architecture designed for:** Sunday Cool - QC Wastage App Migration
**Last updated:** October 16, 2025
