public with sharing class AccountHelper {

    public static void setTypeProspect(List<Account> accounts){
        for (Account acc : accounts) {
            if (acc.Type == null) {
                acc.Type = 'Prospect';
            }
        }
    }

    public static void accountAddressCopy(List<Account> accounts){
        for (Account acc : accounts) {
            if (acc.ShippingStreet != null) {
                acc.BillingStreet = acc.ShippingStreet;
            }
            if (acc.ShippingCity != null) {
                acc.BillingCity = acc.ShippingCity;
            }
            if (acc.ShippingState != null) {
                acc.BillingState = acc.ShippingState;
            }
            if (acc.ShippingPostalCode != null) {
                acc.BillingPostalCode = acc.ShippingPostalCode;
            }
            if (acc.ShippingCountry != null) {
                acc.BillingCountry = acc.ShippingCountry;
            }
        }        
    }

    public static void setRating(List<Account> accounts) {
        for (Account acc : accounts) {
            if (acc.Phone != null && acc.Website != null && acc.Fax != null) {
                acc.Rating = 'Hot';
            }
        }
    }

    public static void defaultContact(List<Account> accounts) {
        if (accounts == null || accounts.isEmpty()){
            return;
        } 

        List<Contact> contacts = new List<Contact>();   
        for(Account acc : accounts) {
            contacts.add(new Contact(
                LastName = 'DefaultContact',
                Email = 'default@email.com',
                AccountId = acc.Id
            ));
        }

        if (!contacts.isEmpty()) {
                Database.insert(contacts, AccessLevel.SYSTEM_MODE);
            }
    }
}