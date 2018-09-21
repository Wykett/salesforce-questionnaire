public class ManageQuestionnaireController {
    public Questionnaire__c questionnaireToManage {get; set;}
    public List<QuestionnaireQuestionAnswerWrapper> questionAnswerList {get; set;}
    public List<QuestionnaireQuestion__c> questionToDeleteList {get; set;}
    public List<QuestionnaireAnswer__c> answerToDeleteList {get; set;}
    public Integer currentQuestionIndex {get; set;}
    public Integer currentAnswerIndex {get; set;}
    public ID questionnaireId {get; set;}
    
    public ManageQuestionnaireController() {
        questionnaireId = apexpages.currentpage().getparameters().get('questionnaireId');
        questionAnswerList = new List<QuestionnaireQuestionAnswerWrapper>();
        if (questionnaireId != null) {
            questionnaireToManage = [SELECT Name FROM Questionnaire__c WHERE Id = :questionnaireId];
            questionAnswerList = QuestionnaireUtility.findQuestionAnswerFromQuestionnaireId(questionnaireId);
        } else {
            questionnaireToManage = new Questionnaire__c();
        }
    }

    public Pagereference addQuestion() {
        questionAnswerList.add(new QuestionnaireQuestionAnswerWrapper(questionAnswerList.size()));
        return null;
    }

    public Pagereference addAnswer() {
        for (QuestionnaireQuestionAnswerWrapper questionAnswerItem : questionAnswerList) {
            if (currentQuestionIndex == questionAnswerItem.index) {
                questionAnswerItem.answerIndexWrapperList.add(new AnswerIndexWrapper(questionAnswerItem.answerIndexWrapperList.size()));
                return null;
            }
        }
        return null;
    }

    public Pagereference removeAnswer() {
        QuestionnaireAnswer__c answerToDelete = questionAnswerList.get(currentQuestionIndex).answerIndexWrapperList.get(currentAnswerIndex).answer;
        questionAnswerList.get(currentQuestionIndex).answerIndexWrapperList.remove(currentAnswerIndex);
        database.delete(answerToDelete);
        return null;
    }

    public Pagereference removeQuestion() {
        if (questionToDeleteList == null) {
            questionToDeleteList = new List<QuestionnaireQuestion__c>();
            answerToDeleteList = new List<QuestionnaireAnswer__c>();
        }
        questionToDeleteList.add(questionAnswerList.get(currentQuestionIndex).question);
        for (AnswerIndexWrapper answerIndexWrapperItem : questionAnswerList.get(currentQuestionIndex).answerIndexWrapperList)
            answerToDeleteList.add(answerIndexWrapperItem.answer);
        questionAnswerList.remove(currentQuestionIndex);

        return null;
    }

    public Pagereference saveQuestionnaire() {
        database.upsert(questionnaireToManage);
        List<QuestionnaireAnswer__c> answersToInsert = new List<QuestionnaireAnswer__c>();
        for (QuestionnaireQuestionAnswerWrapper questionAnswerItem : questionAnswerList) {
            if (questionAnswerItem.question.QuestionnaireMaster__c == null)
                questionAnswerItem.question.QuestionnaireMaster__c = questionnaireToManage.Id;
            database.upsert(questionAnswerItem.question);
            for (AnswerIndexWrapper answerIndexWrapperItem : questionAnswerItem.answerIndexWrapperList) {
                answerIndexWrapperItem.answer.QuestionnaireQuestion__c = questionAnswerItem.question.Id;
                answersToInsert.add(answerIndexWrapperItem.answer);
            }
        }
        database.upsert(answersToInsert);
        if (answerToDeleteList != null)
            database.delete(answerToDeleteList);
        if (questionToDeleteList != null)
            database.delete(questionToDeleteList);
        
        PageReference currentPage = new PageReference('/apex/ManageQuestionnaire');
        currentPage.getparameters().put('questionnaireId', questionnaireToManage.Id);
        currentPage.setRedirect(true);
        return currentPage;
    }
}