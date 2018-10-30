public class ManageQuestionnaireController {
    public Questionnaire__c questionnaireToManage {get; set;}
    public List<QuestionnaireQuestionAnswerWrapper> questionAnswerList {get; set;}
    public List<QuestionnaireQuestion__c> questionToDeleteList {get; set;}
    public List<QuestionnaireAnswer__c> answerToDeleteList {get; set;}
    public Integer currentQuestionIndex {get; set;}
    public Integer currentAnswerIndex {get; set;}
    public String questionnaireId {get; set;}
    public List<System.SelectOption> questionnaireChoices {get; set;}
    
    public ManageQuestionnaireController() {
        questionnaireId = apexpages.currentpage().getparameters().get('questionnaireId');
        questionAnswerList = new List<QuestionnaireQuestionAnswerWrapper>();
        if (questionnaireId != null) {
            questionnaireToManage = [SELECT Name FROM Questionnaire__c WHERE Id = :questionnaireId];
            questionAnswerList = QuestionnaireUtility.findQuestionAnswerFromQuestionnaireId(questionnaireId);
        } else {
            questionnaireChoices = QuestionnaireUtility.generateAllQuestionnaireSelectOption();
            questionnaireToManage = new Questionnaire__c();
        }
    }

    public void addQuestion() {
        questionAnswerList.add(new QuestionnaireQuestionAnswerWrapper(questionAnswerList.size()));
        return;
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
        QuestionnaireQuestionAnswerWrapper currentQuestionAnswerWrapper = questionAnswerList.get(currentQuestionIndex);
        AnswerIndexWrapper currentAnswerWrapper = currentQuestionAnswerWrapper.answerIndexWrapperList.get(currentAnswerIndex);
        QuestionnaireAnswer__c answerToDelete = currentAnswerWrapper.answer;
        currentQuestionAnswerWrapper.answerIndexWrapperList.remove(currentAnswerIndex);
        if (answerToDelete.Id != null)
            database.delete(answerToDelete);
        
        return null;
    }

    public Pagereference removeQuestion() {
        if (questionToDeleteList == null) {
            questionToDeleteList = new List<QuestionnaireQuestion__c>();
            answerToDeleteList = new List<QuestionnaireAnswer__c>();
        }
        QuestionnaireQuestionAnswerWrapper currentQuestionAnswerWrapper = questionAnswerList.get(currentQuestionIndex);
        QuestionnaireQuestion__c question = currentQuestionAnswerWrapper.question;
        if (question.Id != null)
            questionToDeleteList.add(question);

        for (AnswerIndexWrapper answerIndexWrapperItem : currentQuestionAnswerWrapper.answerIndexWrapperList)
            if (answerIndexWrapperItem.answer.Id != null)
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
                answerIndexWrapperItem.answer.Questionnaire__c = questionnaireToManage.Id;
                answersToInsert.add(answerIndexWrapperItem.answer);
            }
        }
        database.upsert(answersToInsert);
        if (answerToDeleteList != null)
            database.delete(answerToDeleteList);
        if (questionToDeleteList != null)
            database.delete(questionToDeleteList);
        
        return QuestionnaireUtility.redirectSamePageWithQuestionnaireId('/apex/ManageQuestionnaire', questionnaireToManage.Id);
    }

    public Pagereference showQuestionnaire() {
        if (questionnaireId != '-1')
            return QuestionnaireUtility.redirectSamePageWithQuestionnaireId('/apex/ManageQuestionnaire', questionnaireId);
        return null;
    }

    public Pagereference deleteQuestionnaire() {
        if (questionnaireId == '-1')
            return null;

        try {
            List<QuestionnaireSavedAnswer__c> savedAnswerList = [SELECT Id FROM QuestionnaireSavedAnswer__c WHERE Questionnaire__c = :questionnaireId];
            Database.delete(savedAnswerList);

            List<QuestionnaireAnswer__c> answerList = [SELECT Id FROM QuestionnaireAnswer__c WHERE Questionnaire__c = :questionnaireId];
            Database.delete(answerList);

            List<QuestionnaireQuestion__c> questionList = [SELECT Id FROM QuestionnaireQuestion__c WHERE QuestionnaireMaster__c = :questionnaireId];
            Database.delete(questionList);

            Database.delete(questionnaireId);
        } catch (DmlException ex) {
            PageUtility.addErrorMessageOnThePage(ex.getMessage());
        }
        return PageUtility.toPage('ManageQuestionnaire');
    }
}