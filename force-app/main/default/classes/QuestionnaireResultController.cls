public with sharing class QuestionnaireResultController {
    public Questionnaire__c questionnaireToShow {get; set;}
    public List<QuestionnaireSavedAnswer__c> savedAnswerList {get; set;}
    public String questionnaireId {get; set;}
    public String customerId {get; set;}
    public List<System.SelectOption> questionnaireChoices {get; set;}

    public QuestionnaireResultController() {
        questionnaireId = apexpages.currentpage().getparameters().get('questionnaireId');
        customerId = apexpages.currentpage().getparameters().get('customerId');
        if (questionnaireId != null) {
            questionnaireToShow = QuestionnaireUtility.getQuestionnaireById(questionnaireId);
            savedAnswerList = QuestionnaireUtility.retrieveSavedAnswer(questionnaireId);
        } else {
            questionnaireChoices = QuestionnaireUtility.generateAllQuestionnaireSelectOption();
        }
    }

    public Pagereference showQuestionnaire() {
        return QuestionnaireUtility.redirectSamePageWithQuestionnaireId('/apex/QuestionnaireResult', questionnaireId);
    }
}
