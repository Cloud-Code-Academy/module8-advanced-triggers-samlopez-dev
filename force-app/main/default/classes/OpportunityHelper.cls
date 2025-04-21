public with sharing class OpportunityHelper {
    
    public static void checkOppAmount(List<Opportunity> opps) {
        for(Opportunity opp : opps){
            if(opp.Amount < 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }

    
    public static void preventOppDeletion(List<Opportunity> opps) {
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id IN :opps)]);
        for(Opportunity opp : opps){
            if(opp.IsClosed) {
                opp.addError('Cannot delete closed opportunity');
            } 
        }
    }

    
    public static void setPrimaryContact(List<Opportunity> opps) {     
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : opps){
            accountIds.add(opp.AccountId);
        }
        
        Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, FirstName, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO' ORDER BY FirstName ASC]);
        Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();

        for (Contact cont : contacts.values()) {
            if (!accountIdToContact.containsKey(cont.AccountId)) {
                accountIdToContact.put(cont.AccountId, cont);
            }
        }

        for(Opportunity opp : opps){
            if(opp.Primary_Contact__c == null){
                if (accountIdToContact.containsKey(opp.AccountId)){
                    opp.Primary_Contact__c = accountIdToContact.get(opp.AccountId).Id;
                }
            }
        }
    } 

        
    public static void setDefaultTypeOpp(List<Opportunity> opps) {
    for (Opportunity opp : opps) {
            if (opp.Type == null) {
                opp.Type = 'New Customer';
            }       
        } 
    }

    public static void createTaskForNewOpp(List<Opportunity> opps) {
            List<Task> tasksToInsert = new List<Task>();

            for (Opportunity opp : opps) {
                tasksToInsert.add(new Task(
                    Subject = 'Call Primary Contact',
                    WhatId = opp.Id,
                    WhoId = opp.Primary_Contact__c,
                    OwnerId = opp.OwnerId,
                    ActivityDate = Date.today().addDays(3)
                ));
            }

            if (!tasksToInsert.isEmpty()) {
                Database.insert(tasksToInsert, AccessLevel.SYSTEM_MODE);
            }
    }

    public static void appendStageChangesToOppDescription(Map<Id, Opportunity> oppNewMap, Map<Id, Opportunity> oppOldMap) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();  

        for (Id oppId : oppNewMap.keySet()) {
            Opportunity newOpp = oppNewMap.get(oppId);
            Opportunity oldOpp = oppOldMap.get(oppId);
        
            if (newOpp.StageName != oldOpp.StageName && newOpp.StageName != null) {
                Opportunity updatedOpp = new Opportunity();
                    updatedOpp.Id = newOpp.Id;
                    updatedOpp.Description = (newOpp.Description == null ? '' : newOpp.Description) + '\n Stage Change: ' + newOpp.StageName + ' : ' + DateTime.now().format();
                    oppsToUpdate.add(updatedOpp);
            }
        }
        
        if (!oppsToUpdate.isEmpty()) {
            Database.insert(oppsToUpdate, AccessLevel.SYSTEM_MODE);
        }
    }

    public static void notifyOwnersOppDeleted(List<Opportunity> opps) {
        Set<Id> ownerIds = new Set<Id>();
        for (Opportunity opp : opps) {
            ownerIds.add(opp.OwnerId);
        }
    
        Map<Id, User> ownerMap = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :ownerIds]);
    
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
        for (Opportunity opp : opps) {
            User owner = ownerMap.get(opp.OwnerId);
            if (owner != null && owner.Email != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { owner.Email });
                mail.setSubject('Opportunity Deleted : ' + opp.Name);
                mail.setPlainTextBody('Your Opportunity: ' + opp.Name + ' has been deleted.');
                mails.add(mail);
            }
        }
    
        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
        }
    }

    public static void assignPrimaryContact(Map<Id, Opportunity> oppNewMap) {
        Set<Id> accountIds = new Set<Id>();
    
        for (Opportunity opp : oppNewMap.values()) {
            if (opp.AccountId != null && opp.Primary_Contact__c == null) {
                accountIds.add(opp.AccountId);
            }
        }
    
        Map<Id, Contact> vpContactsByAccount = new Map<Id, Contact>();
        for (Contact c : [SELECT Id, AccountId FROM Contact WHERE Title = 'VP Sales' AND AccountId IN :accountIds WITH SECURITY_ENFORCED]) {
            if (!vpContactsByAccount.containsKey(c.AccountId)) {
                vpContactsByAccount.put(c.AccountId, c);
            }
        }
    
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Opportunity opp : oppNewMap.values()) {
            if (opp.Primary_Contact__c == null &&
                vpContactsByAccount.containsKey(opp.AccountId)) {
    
                oppsToUpdate.add(new Opportunity(
                    Id = opp.Id,
                    Primary_Contact__c = vpContactsByAccount.get(opp.AccountId).Id
                ));
            }
        }

        if (!oppsToUpdate.isEmpty()) {
            Database.update(oppsToUpdate, AccessLevel.SYSTEM_MODE);
        }
    }


}