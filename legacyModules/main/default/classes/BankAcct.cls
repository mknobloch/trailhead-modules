public class BankAcct {
    private integer balance=0;
    public string acctName;
    public string accttype;
    public void makeDeposit (integer deposit) {
    balance = balance + deposit;
    }
    public integer getBalance() {
    return balance;
    }
}
