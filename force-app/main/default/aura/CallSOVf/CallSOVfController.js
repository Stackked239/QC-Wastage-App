({
	doInit : function(component, event, helper) {
		var recId=component.get('v.recordId');
     /*   console.log('id:::',recId);
       
        var vfURL = 'https://sundaycool--123--c.visualforce.com/apex/SalesOrderPDF?id='+recId;
        console.log('url:::',vfURL);
        
        var urlEvent = $A.get("e.force:navigateToURL"); 
        urlEvent.setParams({
            "url": vfURL,
        }); 
        urlEvent.fire();*/
       // var myPageRef = component.get("v.pageReference");
       // var SalesOrder = myPageRef.state.c__Id;
       // console.log('id'+SalesOrder);
       // console.log('test');
        window.open("/apex/SalesOrderPdf?Id="+recId,"_blank");
        $A.get("e.force:closeQuickAction").fire();
	}
})