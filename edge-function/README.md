# Wastage App URL Redirect - Edge Function

This Cloudflare Worker intercepts existing Salesforce Community barcode URLs and redirects them to the new Wastage PWA.

## How It Works

**Old URL (from existing barcodes):**
```
https://sundaycool.my.site.com/portal/s/wastage-for-so?salesOrderId=a23VL000008w1LiYAI
```

**New URL (PWA):**
```
https://your-app-domain.com/?salesOrderId=a23VL000008w1LiYAI
```

The edge function:
1. Intercepts requests to `/portal/s/wastage-for-so`
2. Extracts the `salesOrderId` parameter
3. Validates the Salesforce ID format
4. Redirects to your new PWA with the same parameter

## Prerequisites

- [Cloudflare account](https://dash.cloudflare.com/sign-up)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/install-and-update/) installed
- Domain managed by Cloudflare (or use Workers Routes)

## Installation

1. Install Wrangler CLI:
```bash
npm install -g wrangler
```

2. Login to Cloudflare:
```bash
wrangler login
```

## Configuration

Edit `wrangler.toml` and update:

1. **NEW_APP_URL** - Your production app domain:
```toml
[env.production.vars]
NEW_APP_URL = "https://wastage.sundaycool.com"
```

2. **Route pattern** - Match your Salesforce Community domain:
```toml
routes = [
  { pattern = "sundaycool.my.site.com/portal/s/wastage-for-so*", zone_name = "sundaycool.my.site.com" }
]
```

## Deployment Options

### Option 1: Cloudflare Workers (Recommended)

This is the easiest option if your Salesforce Community domain is managed by Cloudflare.

**Deploy to production:**
```bash
cd edge-function
wrangler deploy --env production
```

**Deploy to development (for testing):**
```bash
wrangler deploy --env development
```

### Option 2: Custom Domain with Workers

If the Salesforce Community domain isn't on Cloudflare:

1. Set up a custom domain on Cloudflare
2. Configure DNS to point to your domain
3. Use Workers Routes to intercept specific paths

### Option 3: Cloudflare Pages Function

If deploying the PWA on Cloudflare Pages, you can use a Pages Function instead:

1. Move `worker.js` to `wastage-app/frontend/functions/portal/s/wastage-for-so.js`
2. Deploy with Pages - functions are automatically deployed

## Testing

### Local Development

Test the worker locally:
```bash
wrangler dev --env development
```

Then visit:
```
http://localhost:8787/portal/s/wastage-for-so?salesOrderId=a23VL000008w1LiYAI
```

### Production Testing

After deployment, test with an existing barcode:
1. Scan an existing QR code
2. Verify it redirects to the new PWA
3. Confirm the Sales Order loads correctly

## Alternative: DNS CNAME Method

If you can't use Cloudflare Workers, you can:

1. Create a subdomain: `wastage-legacy.sundaycool.com`
2. Point it to your new PWA
3. Update QRCodeGenerator.cls to use the new subdomain
4. Handle the redirect in your PWA's frontend

## Monitoring

View worker analytics in Cloudflare Dashboard:
- Requests per second
- Response codes
- Error rates

## Troubleshooting

**Worker not intercepting requests:**
- Verify route pattern matches exactly
- Check zone_name is correct
- Ensure domain is on Cloudflare

**Redirect loop:**
- Verify NEW_APP_URL doesn't point back to Community
- Check frontend doesn't redirect to old URL

**Invalid Salesforce ID errors:**
- Verify QR codes contain valid 18-character IDs
- Check ID format starts with 'a'

## Cost

Cloudflare Workers Free Tier:
- 100,000 requests per day
- Should be sufficient for warehouse barcode scanning

## Security Notes

- Worker validates Salesforce ID format before redirecting
- Uses 302 (temporary) redirects to allow future changes
- No sensitive data is stored or logged
