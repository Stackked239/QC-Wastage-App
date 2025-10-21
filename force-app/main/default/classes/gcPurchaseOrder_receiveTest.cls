@IsTest (SeeAllData=TRUE)
private class gcPurchaseOrder_receiveTest {

    public class gcException extends Exception{}

    @IsTest
    private static void test1(){

        gcPurchaseOrder_receive.coverage();
    }
}