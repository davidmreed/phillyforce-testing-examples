@isTest
public without sharing class OpportunityServiceTEST {
    @testSetup
    public static void setup() {
        insert new List<Account> {
            new Account(Name = 'Mao-Kwikowski Mercantile', Industry = 'Spaceflight'),
            new Account(Name = 'Protogen Corp.', Industry = 'Nanobiology'),
            new Account(Name = 'Beratnas Gas', Industry = 'Mining')
        };
    }

    @isTest
    public static void test_v1_spaceflight_high_priority_override() {
        Opportunity o = new Opportunity(
            AccountId = [SELECT Id FROM Account WHERE Industry = 'Spaceflight'].Id,
            Name = 'Expansive Deal',
            CloseDate = Date.today(),
            StageName = 'New'
        );
        OpportunityService os = new OpportunityService();

        Test.startTest();
        os.updatePriorities(new List<Opportunity>{o}, OpportunityService.OpportunityMode.MODE_OVERWRITE);
        Test.stopTest();

        System.assertEquals('Prioritized', o.Priority__c, 'opportunity priority');
    }

    @isTest
    public static void test_v1_spaceflight_high_priority_no_override() {
        Opportunity o = new Opportunity(
            AccountId = [SELECT Id FROM Account WHERE Industry = 'Spaceflight'].Id,
            Name = 'Expansive Deal',
            CloseDate = Date.today(),
            StageName = 'New'
        );
        OpportunityService os = new OpportunityService();

        Test.startTest();
        os.updatePriorities(new List<Opportunity>{o}, OpportunityService.OpportunityMode.MODE_FILL);
        Test.stopTest();

        System.assertEquals('Prioritized', o.Priority__c, 'opportunity priority');
    }

    @isTest
    public static void test_v1_spaceflight_high_priority_no_override_negative() {
        Opportunity o = new Opportunity(
            AccountId = [SELECT Id FROM Account WHERE Industry = 'Spaceflight'].Id,
            Name = 'Expansive Deal',
            CloseDate = Date.today(),
            Priority__c = 'Low',
            StageName = 'New'
        );
        OpportunityService os = new OpportunityService();

        Test.startTest();
        os.updatePriorities(new List<Opportunity>{o}, OpportunityService.OpportunityMode.MODE_FILL);
        Test.stopTest();

        System.assertEquals('Low', o.Priority__c, 'opportunity priority');
    }
}
