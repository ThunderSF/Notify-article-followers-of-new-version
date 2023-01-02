@istest
public class Test_SendEmailToKnowledgeArticleFollower {
    public static testMethod void testschedule() {
        Test.StartTest();
        Knowledge__kav k = new Knowledge__kav(URLName = 'Apex-Test-URLName',Title= 'Test'); 
        Insert k;
        knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: k.Id];
        KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);
        EntitySubscription follower = new EntitySubscription(ParentId = obj1.KnowledgeArticleId, SubscriberId = userInfo.getUserId());
        insert follower;
        List<Id> listOfKnowledgeArticleIds = new List<Id>();
        listOfKnowledgeArticleIds.add(obj1.KnowledgeArticleId);
        InvocableSendEmailToFollowers.SendEmailToFollower(listOfKnowledgeArticleIds);
        SendEmailToKnowledgeArticleFollower testsche = new SendEmailToKnowledgeArticleFollower();
        testsche.knowledgeArticleId = k.id;
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}