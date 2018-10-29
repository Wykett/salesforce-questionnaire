public class FillQuestionnaireController {
    public Questionnaire__c questionnaireToFill {get; set;}
    public List<QuestionnaireQuestionAnswerWrapper> questionAnswerList {get; set;}
    public Integer addAnswerIndex {get; set;}
    public Id questionnaireId {get; set;}
    public Map<String, Object> answerChosen {get; set;}
    public Map<String, List<SelectOption>> questionSelectType {get; set;}
    public List<System.SelectOption> questionnaireChoices {get; set;}
    public String temporarySelectedValue {get; set;}
    
    public FillQuestionnaireController() {
        questionnaireId = apexpages.currentpage().getparameters().get('questionnaireId');
        questionAnswerList = new List<QuestionnaireQuestionAnswerWrapper>();
        answerChosen = new Map<String, Object>();
        questionSelectType = new Map<String, List<SelectOption>>();
        if (questionnaireId != null) {
            questionnaireToFill = [SELECT Name FROM Questionnaire__c WHERE Id = :questionnaireId];
            questionAnswerList = QuestionnaireUtility.findQuestionAnswerFromQuestionnaireId(questionnaireId);
            for (QuestionnaireQuestionAnswerWrapper questionAnswerItem : questionAnswerList) {
                if (questionAnswerItem.question.QuestionType__c == 'Select') {
                    List<SelectOption> answerOptionList = new List<SelectOption>();
                    for (AnswerIndexWrapper answerIndexWrapperItem : questionAnswerItem.answerIndexWrapperList) {
                        answerOptionList.add(new SelectOption(answerIndexWrapperItem.answer.Id, answerIndexWrapperItem.answer.AnswerLabel__c));
                    }
                    questionSelectType.put(questionAnswerItem.question.Id, answerOptionList);
                }
            }
            answerChosen = QuestionnaireUtility.createMapWithAnswers(questionAnswerList);
        } else {
            questionnaireChoices = QuestionnaireUtility.generateAllQuestionnaireSelectOption();
        }
    }

    public Pagereference saveQuestionnaireFilled() {
        System.debug('PRINT answerChosen=' + answerChosen);
        
        PageUtility.addInfoMessageOnThePage(String.valueOf(answerChosen));
        return null;
    }

    public Pagereference showQuestionnaire() {
        return QuestionnaireUtility.redirectSamePageWithQuestionnaireId('/apex/FillQuestionnaire', questionnaireId);
    }

    public Pagereference populateAnswers() {
        answerChosen.put(temporarySelectedValue, true);
        return null;
    }
}