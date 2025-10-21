@IsTest (SeeAllData=TRUE)
private class gcInventoryTransferOrder_scanTest {

    public class gcException extends Exception{}

    @IsTest
    private static void test1(){

        gcInventoryTransferOrder_scan.coverage();
    }
}