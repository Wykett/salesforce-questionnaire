public class FillQuestionnaireController {
    public Questionnaire__c questionnaireToFill {get; set;}
    public List<QuestionnaireQuestionAnswerWrapper> questionAnswerList {get; set;}
    public Integer addAnswerIndex {get; set;}
    public ID questionnaireId {get; set;}
    public Map<String, Object> answerChosen {get; set;}
    
    public FillQuestionnaireController() {
        questionnaireId = apexpages.currentpage().getparameters().get('questionnaireId');
        questionAnswerList = new List<QuestionnaireQuestionAnswerWrapper>();
        answerChosen = new Map<String, Object>();
        if (questionnaireId != null) {
            questionnaireToFill = [SELECT Name FROM Questionnaire__c WHERE Id = :questionnaireId];
            questionAnswerList = QuestionnaireUtility.findQuestionAnswerFromQuestionnaireId(questionnaireId);
            answerChosen = QuestionnaireUtility.createMapWithAnswers(questionAnswerList);
        }
    }

    public Pagereference saveQuestionnaireFilled() {
        System.debug('PRINT answerChosen=' + answerChosen);
        PageReference currentPage = new PageReference('/apex/FillQuestionnaire');
        currentPage.getparameters().put('questionnaireId', questionnaireId);
        currentPage.setRedirect(true);
        return currentPage;
    }
}