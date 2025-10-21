/**
 * Cloudflare Worker - Wastage App URL Redirect
 *
 * Intercepts old Salesforce Community URLs and redirects to new PWA
 * Old: https://sundaycool.my.site.com/portal/s/wastage-for-so?salesOrderId=a23VL000008w1LiYAI
 * New: https://your-app-domain.com/?salesOrderId=a23VL000008w1LiYAI
 */

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const url = new URL(request.url)

  // Check if this is a Community wastage URL
  if (url.pathname === '/portal/s/wastage-for-so') {
    const salesOrderId = url.searchParams.get('salesOrderId')

    if (salesOrderId) {
      // Validate Salesforce ID format (18 chars starting with 'a')
      if (/^a[0-9A-Za-z]{17}$/.test(salesOrderId)) {
        // Redirect to new PWA
        const newUrl = `${NEW_APP_URL}/?salesOrderId=${salesOrderId}`

        return Response.redirect(newUrl, 302)
      } else {
        // Invalid Salesforce ID
        return new Response('Invalid Sales Order ID format', {
          status: 400,
          headers: { 'Content-Type': 'text/plain' }
        })
      }
    }

    // No salesOrderId parameter - redirect to app home
    return Response.redirect(NEW_APP_URL, 302)
  }

  // Not a wastage URL - pass through to origin
  return fetch(request)
}
