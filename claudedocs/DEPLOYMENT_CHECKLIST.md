# Wastage App Deployment Checklist

**Date Created:** October 16, 2025
**Purpose:** Complete checklist for deploying the Wastage PWA to production

---

## Pre-Deployment Checklist

### ✅ Local Development Complete

- [x] Backend API built and tested
- [x] Frontend PWA built and tested
- [x] Documentation created (README, SETUP_GUIDE)
- [ ] Local testing with real Salesforce data successful
- [ ] All form validations working
- [ ] QC_Wastage__c records created successfully in sandbox

### ✅ Salesforce Configuration

#### Integration User (Sandbox)
- [ ] Integration user created in devtyler sandbox
- [ ] Username: `wastage-integration@sundaycool.com.devtyler`
- [ ] Password and security token saved securely
- [ ] Permissions verified (can read Sales Orders, create QC_Wastage records)

#### Integration User (Production)
- [ ] Integration user created in production org
- [ ] Username: `wastage-integration@sundaycool.com`
- [ ] Password and security token saved securely
- [ ] Same permissions as sandbox user

### ✅ Testing Requirements

#### Functional Testing
- [ ] QR code scanning works (or manual ID entry)
- [ ] Sales Order data loads correctly
- [ ] Picklist values populate dropdowns
- [ ] "Apply to All" button works
- [ ] "Waste All" button works
- [ ] Form validation catches empty required fields
- [ ] Submission creates QC_Wastage__c records
- [ ] Success message displays after submission
- [ ] "Scan Another QR Code" returns to scanner

#### Mobile Testing
- [ ] Tested on iPhone (iOS 14+)
- [ ] Tested on iPad
- [ ] Tested on Android phone (optional)
- [ ] Camera access works on mobile devices
- [ ] Form is touch-friendly (44px+ tap targets)
- [ ] Table scrolls horizontally on small screens
- [ ] PWA installs via "Add to Home Screen"

#### Data Validation
- [ ] All Sales Order fields map correctly
- [ ] Line items display accurate product information
- [ ] Wastage records in Salesforce have all expected fields
- [ ] Record relationships correct (Sales Order → Wastage)

---

## Heroku Deployment Steps

### Option 1: Deploy Backend and Frontend Separately

#### Deploy Backend

1. **Create Heroku App:**
```bash
cd wastage-app/backend
heroku login
heroku create sunday-cool-wastage-api
```

2. **Set Environment Variables:**
```bash
heroku config:set SF_LOGIN_URL=https://login.salesforce.com
heroku config:set SF_USERNAME=wastage-integration@sundaycool.com
heroku config:set SF_PASSWORD=YourProductionPassword
heroku config:set SF_SECURITY_TOKEN=YourProductionToken
heroku config:set NODE_ENV=production
```

3. **Create Procfile:**
```bash
echo "web: node server.js" > Procfile
```

4. **Deploy:**
```bash
git init
git add .
git commit -m "Deploy backend to Heroku"
heroku git:remote -a sunday-cool-wastage-api
git push heroku main
```

5. **Verify Backend:**
```bash
heroku open
# Visit: https://sunday-cool-wastage-api.herokuapp.com/api/health
# Should see: {"status":"healthy","timestamp":"..."}
```

#### Deploy Frontend

1. **Update API URL:**
Edit `frontend/vite.config.js`:
```javascript
// For production, frontend will call backend on Heroku
server: {
  proxy: {
    '/api': {
      target: 'https://sunday-cool-wastage-api.herokuapp.com',
      changeOrigin: true
    }
  }
}
```

2. **Build Production Assets:**
```bash
cd wastage-app/frontend
npm run build
```

3. **Deploy to Vercel (Recommended for frontend):**
```bash
npm install -g vercel
vercel login
vercel --prod
```

**OR Deploy to Heroku:**
```bash
heroku create sunday-cool-wastage-app

# Create static.json for serving React app
echo '{"root": "dist/"}' > static.json

# Use heroku buildpack for static sites
heroku buildpacks:set https://github.com/heroku/heroku-buildpack-static

git init
git add .
git commit -m "Deploy frontend to Heroku"
heroku git:remote -a sunday-cool-wastage-app
git push heroku main
```

4. **Update Backend CORS:**
```bash
heroku config:set FRONTEND_URL=https://sunday-cool-wastage-app.herokuapp.com -a sunday-cool-wastage-api
```

### Option 2: Deploy as Single App (Monorepo)

**Alternative:** Serve frontend from backend Express server

1. Build frontend into backend's public folder
2. Serve static files from Express
3. Deploy single Heroku app

---

## Post-Deployment Configuration

### Update Salesforce QR Code URL

**CRITICAL STEP:** Update Custom Label so new QR codes point to production app

1. Log into Salesforce production org
2. **Setup → Custom Labels**
3. Find: `QR_Code_URL`
4. **Current value:** `https://[salesforce-domain]/portal/wastage?salesOrderId=`
5. **New value:** `https://sunday-cool-wastage-app.herokuapp.com/wastage?id=`
6. Click **Save**

### Test with Real QR Code

1. Create a new Sales Order in production
2. QR code should be generated automatically (via `Create_OR_Code` flow)
3. Print the Sales Order PDF
4. Scan QR code with phone
5. Verify:
   - [ ] QR code opens production app URL
   - [ ] Sales Order data loads
   - [ ] Can submit wastage successfully
   - [ ] Record appears in Salesforce

### Handle Old QR Codes (Transition Period)

For existing printed Sales Orders with old Community URLs:

**Option A: Redirect Page**
1. Keep Communities active temporarily
2. Create simple redirect page at old URL
3. Redirect to new app URL

**Option B: Regenerate QR Codes**
1. Add "Generate QR Code" button to Sales Order page
2. Staff can manually regenerate for active orders
3. Old codes naturally age out

---

## Production Checklist

### Security
- [ ] HTTPS enabled (automatic on Heroku)
- [ ] Environment variables secure (not in code)
- [ ] Rate limiting enabled (100 req/hour)
- [ ] CORS properly configured (only frontend domain)
- [ ] Salesforce credentials use production user (not admin)
- [ ] Integration user has minimal required permissions

### Performance
- [ ] Frontend build optimized (`npm run build`)
- [ ] Service worker caching enabled
- [ ] API responses cached where appropriate
- [ ] No console.log in production code

### Monitoring
- [ ] Heroku logging enabled
- [ ] Error tracking set up (optional: Sentry)
- [ ] Salesforce API usage monitoring
- [ ] Set up uptime monitoring (optional: UptimeRobot)

### Documentation
- [ ] README updated with production URLs
- [ ] Staff training materials created
- [ ] Troubleshooting guide accessible
- [ ] Emergency rollback plan documented

---

## Training & Rollout

### Staff Training (15 minutes)

1. **Show the basics:**
   - Open app URL on phone/iPad
   - Scan QR code (or enter ID manually)
   - Fill out form (emphasize required fields)
   - Submit wastage

2. **Common scenarios:**
   - Multiple items with wastage
   - Using "Apply to All" for common fields
   - Using "Waste All" for total losses

3. **Troubleshooting:**
   - Camera not working? Use manual ID entry
   - Form won't submit? Check required fields are filled
   - App not loading? Check internet connection

### Pilot Phase (Week 1)

- [ ] Select 3-5 production staff for pilot
- [ ] Monitor for issues daily
- [ ] Collect feedback
- [ ] Make quick fixes as needed
- [ ] Verify data accuracy in Salesforce

### Full Rollout (Week 2+)

- [ ] Announce to all production staff
- [ ] Brief walkthrough during shift meeting
- [ ] Make app available to everyone
- [ ] Monitor usage and error rates
- [ ] Respond to issues quickly

---

## Decommission Communities

**WAIT AT LEAST 4-6 WEEKS** after full rollout before canceling Communities subscription.

### Pre-Cancellation Checks

- [ ] No traffic to old Community URLs (check analytics)
- [ ] All active Sales Orders have new QR codes
- [ ] Staff comfortable with new app
- [ ] No reported issues for 2+ weeks

### Cancellation Steps

1. [ ] Export any Community-specific data (if needed)
2. [ ] Remove Community member access
3. [ ] Deactivate Community in Salesforce
4. [ ] Contact Salesforce to cancel Communities subscription
5. [ ] Remove Community profiles and permission sets (cleanup)

---

## Success Metrics

Track these metrics to measure successful migration:

### Week 1
- **Goal:** 100% of pilot users can submit wastage
- **Metric:** Number of successful submissions vs. errors
- **Target:** <5% error rate

### Week 4
- **Goal:** All production staff using new app
- **Metric:** Number of QC_Wastage records created via new app
- **Target:** 100% of wastage entries via new app

### Week 8
- **Goal:** Communities fully decommissioned
- **Metric:** Communities subscription canceled
- **Target:** $150+/month cost savings achieved

### Ongoing
- **Uptime:** >99% availability
- **User Satisfaction:** Positive feedback from staff
- **Data Quality:** No missing or incorrect wastage records

---

## Rollback Plan

If critical issues arise:

### Emergency Rollback (Day 1-7)

1. **Immediate:**
   - Communities still active
   - Staff can use old Community URL
   - No data loss

2. **Fix Issues:**
   - Debug production app
   - Deploy fixes
   - Re-test before retry

### Post-Decommission Rollback (Week 8+)

1. **Re-enable Communities:**
   - Contact Salesforce support
   - Reactivate Community subscription
   - Restore Community configuration

2. **Fix New App:**
   - Identify and resolve issues
   - Test thoroughly before retry

---

## Contact & Support

### Development Team
- Technical issues: [developer email]
- Feature requests: [project manager]

### Salesforce Admin
- User permissions: [admin email]
- Integration issues: [admin email]

### Heroku Dashboard
- App URL: https://dashboard.heroku.com/apps/sunday-cool-wastage-api
- Logs: `heroku logs --tail -a sunday-cool-wastage-api`

---

## Appendix: Useful Commands

### Check Backend Health
```bash
curl https://sunday-cool-wastage-api.herokuapp.com/api/health
```

### View Heroku Logs
```bash
heroku logs --tail -a sunday-cool-wastage-api
```

### Update Environment Variable
```bash
heroku config:set VARIABLE_NAME=value -a sunday-cool-wastage-api
```

### Restart Heroku App
```bash
heroku restart -a sunday-cool-wastage-api
```

### Deploy Update
```bash
git add .
git commit -m "Update description"
git push heroku main
```

---

**Document prepared by:** Claude Code
**Last updated:** October 16, 2025
**Status:** Ready for deployment
