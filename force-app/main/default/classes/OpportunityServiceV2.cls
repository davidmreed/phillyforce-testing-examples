public with sharing class OpportunityServiceV2 {
    public enum OpportunityMode {
        MODE_OVERWRITE,
        MODE_FILL
    }

    @TestVisible
    private interface IOppServiceQueryDelegate {
        List<Industry_Priority__mdt> getPriorityMetadata();
    }

    @TestVisible
    private class OppServiceQueryConcreteDelegate implements IOppServiceQueryDelegate {
        public List<Industry_Priority__mdt> getPriorityMetadata() {
            return [SELECT Id, Industry__c, Priority__c FROM Industry_Priority__mdt];
        }
    }

    @TestVisible
    private IOppServiceQueryDelegate delegate = new OppServiceQueryConcreteDelegate();

    public Map<String, String> getPriorities() {
        Map<String, String> priorityMap = new Map<String, String>();

        for (Industry_Priority__mdt m : delegate.getPriorityMetadata()) {
            priorityMap.put(m.Industry__c, m.Priority__c);
        }

        return priorityMap;
    }

    public void updatePriorities_v2(List<Opportunity> opportunities, OpportunityMode mode) {
        Map<Id, Account> accountMap;
        Set<Id> accountIds = new Set<Id>();
        Map<String, String> priorities = getPriorities();

        for (Opportunity o : opportunities) {
            accountIds.add(o.AccountId);
        }
        accountMap = new Map<Id, Account>(
            [SELECT Id, Industry FROM Account WHERE Id IN :accountIds]
        );

        for (Opportunity o : opportunities) {
            if (accountMap.containsKey(o.AccountId) && (mode == OpportunityMode.MODE_OVERWRITE || String.isBlank(o.Priority__c))) {
                Account a = accountMap.get(o.AccountId);

                if (priorities.containsKey(a.Industry)) {
                    o.Priority__c = priorities.get(a.Industry);
                } else {
                    o.Priority__c = getAmountPriority(o.Amount);
                }
            }
        }
    }

    @TestVisible
    private String getAmountPriority(Decimal amount) {
        if (amount > 100000) {
            return 'Prioritized';
        } else if (amount > 20000) {
            return 'Normal';
        }

        return 'Low';
    }
}
