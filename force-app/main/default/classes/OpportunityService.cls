public without sharing class OpportunityService {
    public enum OpportunityMode {
        MODE_OVERWRITE,
        MODE_FILL
    }

    public void updatePriorities(List<Opportunity> opportunities, OpportunityMode mode) {
        Map<Id, Account> accountMap;
        Set<Id> accountIds = new Set<Id>();

        for (Opportunity o : opportunities) {
            accountIds.add(o.AccountId);
        }

        accountMap = new Map<Id, Account>(
            [SELECT Id, Industry FROM Account WHERE Id IN :accountIds]
        );

        for (Opportunity o : opportunities) {
            if (accountMap.containsKey(o.AccountId)) {
                Account a = accountMap.get(o.AccountId);

                if (a.Industry == 'Spaceflight') {
                    if (mode == OpportunityMode.MODE_OVERWRITE || String.isBlank(o.Priority__c)) {
                        o.Priority__c = 'Prioritized';
                    }
                } else if (a.Industry == 'Nanobiology') {
                    if (mode == OpportunityMode.MODE_OVERWRITE || String.isBlank(o.Priority__c)) {
                        o.Priority__c = 'Low';
                    }
                } else {
                    if (mode == OpportunityMode.MODE_OVERWRITE || String.isBlank(o.Priority__c)) {
                        if (o.Amount > 100000) {
                            o.Priority__c = 'Prioritized';
                        } else if (o.Amount > 20000) {
                            o.Priority__c = 'Normal';
                        } else {
                            o.Priority__c = 'Low';
                        }
                    }
                }
            }
        }
    }
}
