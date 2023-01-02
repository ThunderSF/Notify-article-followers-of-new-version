global class SendEmailToKnowledgeArticleFollower implements Schedulable {
    
    global Id knowledgeArticleId;
    global SendEmailToKnowledgeArticleFollower(){}
    
    global SendEmailToKnowledgeArticleFollower(Id kavIds){
        this.knowledgeArticleId = kavIds;
    }
    
    global void execute(SchedulableContext sc){
        SendEmail();
    }
    
    global void SendEmail() {
        Set<Id> knowledgeArticleIdSet = new Set<Id>();
        Map<Id,Knowledge__kav> mapOfKnowledgeArticleVersion = new  Map<Id,Knowledge__kav>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName = 'KnowledgeArticlePublished'];
        List<Knowledge__kav> knowledgeArticlesPublishedToday;
        
        if(String.isNotBlank(knowledgeArticleId)){
            knowledgeArticlesPublishedToday =  [SELECT Id,LastPublishedDate,PublishStatus,KnowledgeArticleId,IsLatestVersion,Title  
                                                FROM Knowledge__kav 
                                                WHERE Id = :knowledgeArticleId AND LastPublishedDate = TODAY ];
        }else{
            knowledgeArticlesPublishedToday =  [SELECT Id,LastPublishedDate,PublishStatus,KnowledgeArticleId,IsLatestVersion,Title  
                                                FROM Knowledge__kav 
                                                WHERE LastPublishedDate = TODAY ];
        }
        
        if (!knowledgeArticlesPublishedToday.isEmpty()) {
            
            for (Knowledge__kav kav : knowledgeArticlesPublishedToday) {
                knowledgeArticleIdSet.add(kav.KnowledgeArticleId);
                mapOfKnowledgeArticleVersion.put(kav.KnowledgeArticleId,kav);
            }
            
            List<EntitySubscription> knowledgeArticleFolower = [SELECT  ID, ParentId, SubscriberId,Subscriber.Name,Subscriber.Email   
                                                                FROM EntitySubscription 
                                                                WHERE ParentId 
                                                                IN :knowledgeArticleIdSet];
            if (!knowledgeArticleFolower.isEmpty()) {
                OrgWideEmailAddress orgWideAddress = [SELECT Id, Address, DisplayName 
                                                      FROM OrgWideEmailAddress 
                                                      WHERE Address='techsupport@on24.com' 
                                                      LIMIT 1 ];
                
                
                for (EntitySubscription follower : knowledgeArticleFolower) {
                    List<String> sendTo = new List<String>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    Messaging.SingleEmailMessage getEmailTempResponse = Messaging.renderStoredEmailTemplate(et.Id, follower.SubscriberId, mapOfKnowledgeArticleVersion.get(follower.ParentId).Id);
                    sendTo.add(follower.Subscriber.Email);
                    // Set email contents - you can use variables!
                    if ( orgWideAddress != null) {
                        mail.setOrgWideEmailAddressId( orgWideAddress.Id );
                        // mail.setSenderDisplayName(orgWideAddress.DisplayName);
                    }
                    mail.setToAddresses(sendTo);
                    mail.setSubject(getEmailTempResponse.getSubject());
                    mail.setHTMLBody(getEmailTempResponse.getHtmlBody());
                    mails.add(mail);
                }
                if(!Test.isRunningTest()){
                     Messaging.sendEmail(mails);
                }
               
            }
            
        }
    }
}