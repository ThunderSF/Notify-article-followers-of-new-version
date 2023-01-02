public class InvocableSendEmailToFollowers {
    @InvocableMethod
    public static void SendEmailToFollower( List<Id> articleIds ) {
        new SendEmailToKnowledgeArticleFollower(articleIds[0]).SendEmail();
    }
        
}