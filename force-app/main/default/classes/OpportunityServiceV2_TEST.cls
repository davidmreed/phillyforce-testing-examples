@isTest
public with sharing class OpportunityServiceV2_TEST {
    private class MockQueryDelegate implements OpportunityServiceV2.IOppServiceQueryDelegate {
        public List<Industry_Priority__mdt> getPriorityMetadata() {
            return new List<Industry_Priority__mdt>{
                new Industry_Priority__mdt(
                    Priority__c = 'Prioritized',
                    Industry__c = 'Spaceflight'
                )
            };
        }
    }

    @testSetup
    public static void setup() {
        insert new List<Account> {
            new Account(Name = 'Mao-Kwikowski Mercantile', Industry = 'Spaceflight'),
            new Account(Name = 'Protogen Corp.', Industry = 'Nanobiology'),
            new Account(Name = 'Beratnas Gas', Industry = 'Mining')
        };
    }

    @isTest
    public static void test_v2_sets_priority_from_custom_metadata() {
        Opportunity o = new Opportunity(
            AccountId = [SELECT Id FROM Account WHERE Industry = 'Spaceflight'].Id,
            Name = 'Expansive Deal',
            CloseDate = Date.today(),
            StageName = 'New'
        );
        OpportunityServiceV2 os = new OpportunityServiceV2();

        os.delegate = new MockQueryDelegate();

        Test.startTest();
        os.updatePriorities_v2(new List<Opportunity>{o}, OpportunityServiceV2.OpportunityMode.MODE_OVERWRITE);
        Test.stopTest();

        System.assertEquals('Prioritized', o.Priority__c, 'opportunity priority');
    }

    @isTest
    public static void test_v2_sets_priority_from_amount() {
        Opportunity o = new Opportunity(
            AccountId = [SELECT Id FROM Account WHERE Industry = 'Mining'].Id,
            Name = 'Expansive Deal',
            CloseDate = Date.today(),
            StageName = 'New',
            Amount = 150000
        );
        OpportunityServiceV2 os = new OpportunityServiceV2();

        os.delegate = new MockQueryDelegate();

        Test.startTest();
        os.updatePriorities_v2(new List<Opportunity>{o}, OpportunityServiceV2.OpportunityMode.MODE_OVERWRITE);
        Test.stopTest();

        System.assertEquals('Prioritized', o.Priority__c, 'opportunity priority');
    }

    @isTest
    public static void test_v2_getAmountPriority() {
        OpportunityServiceV2 os = new OpportunityServiceV2();

        System.assertEquals('Prioritized', os.getAmountPriority(200000), 'high dollar priority');
        System.assertEquals('Normal', os.getAmountPriority(30000), 'medium dollar priority');
        System.assertEquals('Low', os.getAmountPriority(1000), 'low dollar priority');
    }

    @isTest
    public static void test_v2_concrete_delegate() {
        System.assertNotEquals(
            null,
            new OpportunityServiceV2.OppServiceQueryConcreteDelegate().getPriorityMetadata(),
            'org metadata query'
        );
    }
}
