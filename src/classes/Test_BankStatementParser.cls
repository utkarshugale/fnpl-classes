@isTest
private class Test_BankStatementParser{
    @isTest
    private static void BankStatementParserTest(){
        BankStatementParser bankPar = new BankStatementParser();
        bankPar.getTrasactions('123');
    }
}