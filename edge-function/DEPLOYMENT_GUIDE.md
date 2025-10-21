# Wastage App Redirect - Deployment Guide

This guide explains how to redirect existing Salesforce Community barcode URLs to your new Wastage PWA.

## The Problem

Your existing QR codes point to:
```
https://sundaycool.my.site.com/portal/s/wastage-for-so?salesOrderId=a23VL000008w1LiYAI
```

Your new PWA expects:
```
https://your-new-app.com/?salesOrderId=a23VL000008w1LiYAI
```

## Solutions

### Option 1: Cloudflare Workers (Best Performance)

**Pros:**
- Edge-level redirect (fastest)
- No visible redirect page
- Professional solution
- Free for low traffic

**Cons:**
- Requires Cloudflare account
- Domain must be on Cloudflare or use Workers Routes

**Setup:**

1. Install Wrangler CLI:
```bash
npm install -g wrangler
```

2. Login to Cloudflare:
```bash
wrangler login
```

3. Update `wrangler.toml` with your app URL:
```toml
[env.production.vars]
NEW_APP_URL = "https://wastage.sundaycool.com"
```

4. Deploy:
```bash
cd edge-function
npm run deploy
```

5. Configure route in Cloudflare Dashboard:
   - Go to Workers & Pages
   - Click on your worker
   - Add Route: `sundaycool.my.site.com/portal/s/wastage-for-so*`

---

### Option 2: Static HTML Redirect Page (Simplest)

**Pros:**
- No infrastructure needed
- Can host anywhere (S3, GitHub Pages, Netlify, etc.)
- Easy to understand and modify

**Cons:**
- Users see brief redirect page
- Slightly slower than edge function

**Setup:**

1. Edit `redirect.html` and update the URL:
```javascript
const NEW_APP_URL = 'https://wastage.sundaycool.com';
```

2. Host the file at:
```
https://sundaycool.my.site.com/portal/s/wastage-for-so
```

**Hosting Options:**

**A. Salesforce Experience Cloud (Community):**
1. Go to Experience Builder
2. Upload `redirect.html` as a static resource
3. Configure routing to serve at `/portal/s/wastage-for-so`

**B. AWS S3 + CloudFront:**
1. Create S3 bucket
2. Upload `redirect.html` as `index.html`
3. Configure CloudFront with custom domain
4. Point `sundaycool.my.site.com/portal/s/wastage-for-so` to CloudFront

**C. Netlify/Vercel (Free):**
1. Create new site
2. Upload `redirect.html` as `index.html`
3. Configure custom domain in DNS

---

### Option 3: Salesforce Custom Domain + Visualforce Page

**Pros:**
- No external services needed
- Uses existing Salesforce infrastructure

**Cons:**
- Requires Salesforce administrator access
- More complex setup

**Setup:**

1. Create Visualforce page in Salesforce:

```apex
<apex:page showHeader="false" sidebar="false" standardStylesheets="false">
<html>
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Redirecting...</title>
</head>
<body>
    <script>
        var urlParams = new URLSearchParams(window.location.search);
        var salesOrderId = urlParams.get('salesOrderId');
        var newAppUrl = 'https://wastage.sundaycool.com';

        if (salesOrderId && /^a[0-9A-Za-z]{17}$/.test(salesOrderId)) {
            window.location.href = newAppUrl + '/?salesOrderId=' + salesOrderId;
        } else {
            window.location.href = newAppUrl;
        }
    </script>
    <p>Redirecting to Wastage App...</p>
</body>
</html>
</apex:page>
```

2. Configure Community to use this page at `/wastage-for-so`

---

## Testing

### Test the Redirect

**Using curl:**
```bash
curl -I "https://sundaycool.my.site.com/portal/s/wastage-for-so?salesOrderId=a23VL000008w1LiYAI"
```

Should return:
```
HTTP/2 302
Location: https://your-app.com/?salesOrderId=a23VL000008w1LiYAI
```

**Using browser:**
1. Visit: `https://sundaycool.my.site.com/portal/s/wastage-for-so?salesOrderId=a23VL000008w1LiYAI`
2. Should redirect to your new app
3. Sales Order should load automatically

### Test with Real Barcode

1. Print a test QR code with existing URL format
2. Scan with phone camera
3. Verify redirects to new app
4. Confirm Sales Order loads correctly

---

## Recommended Approach

**For Sunday Cool, I recommend:**

1. **Short term (today):** Use Option 2 (Static HTML) hosted on Netlify
   - Takes 5 minutes to deploy
   - Works immediately
   - No infrastructure complexity

2. **Long term (next week):** Migrate to Option 1 (Cloudflare Workers)
   - Better performance
   - More professional
   - Better analytics

---

## Quick Start: Netlify Deployment (5 minutes)

1. Create free Netlify account
2. Update `redirect.html` with your app URL
3. Drag and drop the file to Netlify
4. Get the Netlify URL (e.g., `wonderful-app-123.netlify.app`)
5. Set up DNS CNAME:
   - Point `wastage-redirect.sundaycool.com` to `wonderful-app-123.netlify.app`
6. Update Community URL or create URL shortener

---

## Monitoring

After deployment, monitor:
- Redirect success rate
- Load times
- Any error reports from users

All solutions validate the Salesforce ID format before redirecting to prevent invalid requests.

---

## Support

If you encounter issues:
1. Check browser console for errors
2. Verify URL parameters are being passed correctly
3. Test with different Sales Order IDs
4. Check DNS configuration if using custom domains
