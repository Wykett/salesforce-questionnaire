public class FillQuestionnaireController {
    public Questionnaire__c questionnaireToFill {get; set;}
    public List<QuestionnaireQuestionAnswerWrapper> questionAnswerList {get; set;}
    public Integer addAnswerIndex {get; set;}
    public Id questionnaireId {get; set;}
    public Map<String, Object> answerChosen {get; set;}
    public List<System.SelectOption> questionnaireChoices {get; set;}
    
    public FillQuestionnaireController() {
        questionnaireId = apexpages.currentpage().getparameters().get('questionnaireId');
        questionAnswerList = new List<QuestionnaireQuestionAnswerWrapper>();
        answerChosen = new Map<String, Object>();
        if (questionnaireId != null) {
            questionnaireToFill = [SELECT Name FROM Questionnaire__c WHERE Id = :questionnaireId];
            questionAnswerList = QuestionnaireUtility.findQuestionAnswerFromQuestionnaireId(questionnaireId);
            answerChosen = QuestionnaireUtility.createMapWithAnswers(questionAnswerList);
        } else {
            questionnaireChoices = QuestionnaireUtility.generateAllQuestionnaireSelectOption();
        }
    }

    public Pagereference saveQuestionnaireFilled() {
        System.debug('PRINT answerChosen=' + answerChosen);
        return QuestionnaireUtility.redirectSamePageWithQuestionnaireId('/apex/FillQuestionnaire', questionnaireId);
    }

    public Pagereference showQuestionnaire() {
        return QuestionnaireUtility.redirectSamePageWithQuestionnaireId('/apex/FillQuestionnaire', questionnaireId);
    }
}