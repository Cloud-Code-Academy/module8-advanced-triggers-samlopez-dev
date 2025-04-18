public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    private List<Opportunity> newOpportunities;
    private List<Opportunity> oldOpportunities;
    private Map<Id, Opportunity> newOpportunityMap;
    private Map<Id, Opportunity> oldOpportunityMap;

    public OpportunityTriggerHandler() {
        this.newOpportunities = (List<Opportunity>) Trigger.new;
        this.oldOpportunities = (List<Opportunity>) Trigger.old;
        this.newOpportunityMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldOpportunityMap = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    public override void beforeUpdate() {
        OpportunityHelper.checkOppAmount(this.newOpportunities);
        OpportunityHelper.setPrimaryContact(this.newOpportunities);
    }

    public override void beforeInsert() {
        OpportunityHelper.setDefaultTypeOpp(this.newOpportunities);
    }

    public override void beforeDelete() {
        OpportunityHelper.preventOppDeletion(this.oldOpportunities);
    }

    public override void afterUpdate() {
        OpportunityHelper.appendStageChangesToOppDescription(this.newOpportunityMap, this.oldOpportunityMap);
    }

    public override void afterInsert() {
        OpportunityHelper.createTaskForNewOpp(this.newOpportunities);
    }

    public override void afterDelete() {
        OpportunityHelper.notifyOwnersOppDeleted(this.oldOpportunities);
    }

    public override void afterUndelete() {
        OpportunityHelper.assignPrimaryContact(this.newOpportunityMap);
    }


}