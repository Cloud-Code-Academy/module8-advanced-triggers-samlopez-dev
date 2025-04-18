public with sharing class AccountTriggerHandler extends TriggerHandler {

    private List<Account> newAccounts;
    private List<Account> oldAccounts;
    private Map<Id, Account> newAccountMap;
    private Map<Id, Account> oldAccountMap;

    public AccountTriggerHandler() {
        this.newAccounts = (List<Account>) Trigger.new;
        this.oldAccounts = (List<Account>) Trigger.old;
        this.newAccountMap = (Map<Id, Account>) Trigger.newMap;
        this.oldAccountMap = (Map<Id, Account>) Trigger.oldMap;
    }

    public override void beforeUpdate() {
        AccountHelper.setTypeProspect(this.newAccounts);
        AccountHelper.setRating(this.newAccounts);
    }

    public override void beforeInsert() {
        AccountHelper.accountAddressCopy(this.newAccounts);
    }

    public override void afterInsert() {
        AccountHelper.defaultContact(this.newAccounts);
    }


}