/*
 * 27 Sept 2024 UMESH RANA
 * Description : This class is called from flow "Create OR Code". We are making an callout to generate QR code for the public link. 
*/
public class QRCodeGenerator {
    
    @InvocableMethod
    public static void generateAndSaveQRCode(List<String> recordId) {
        if(!System.isBatch()){    
         	qrApi(recordId[0]);   
        }
    }
    
    @future(callout=true)
    public static void qrApi(String recordId){
		String url = System.Label.QR_Code_URL + recordId;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=' + EncodingUtil.urlEncode(url, 'UTF-8'));
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            // Get the QR code image as a Blob
            Blob qrCodeBlob = response.getBodyAsBlob();
            
            String base64EncodedQrCode = EncodingUtil.base64Encode(qrCodeBlob);
            
            String qrCodeImgTag = '<img src="data:image/png;base64,' + base64EncodedQrCode + '" alt="QR Code" />';
            
            AcctSeedERP__Sales_Order__c record = [SELECT Id,QR_Code__c FROM AcctSeedERP__Sales_Order__c WHERE Id = :recordId LIMIT 1];
            record.QR_Code__c = qrCodeImgTag;
            try{
                update record;   
            }catch(DmlException e) {
    			System.debug('The following exception has occurred: ' + e.getMessage());          	
            }
        }
    }
}