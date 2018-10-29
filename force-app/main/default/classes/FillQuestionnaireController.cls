public class FillQuestionnaireController {
    public Questionnaire__c questionnaireToFill {get; set;}
    public List<QuestionnaireQuestionAnswerWrapper> questionAnswerList {get; set;}
    public List<QuestionnaireAnswer__c> questionnaireAnswerList {get; set;}
    public Integer addAnswerIndex {get; set;}
    public Id questionnaireId {get; set;}
    public String customerId {get; set;}
    public Map<String, Object> answerChosen {get; set;}
    public Map<String, List<SelectOption>> questionSelectType {get; set;}
    public List<System.SelectOption> questionnaireChoices {get; set;}
    public String temporarySelectedValue {get; set;}
    
    public FillQuestionnaireController() {
        questionnaireId = apexpages.currentpage().getparameters().get('questionnaireId');
        customerId = apexpages.currentpage().getparameters().get('customerId');
        initVariables();
        if (questionnaireId != null) {
            populateDatas();
        } else {
            questionnaireChoices = QuestionnaireUtility.generateAllQuestionnaireSelectOption();
        }
    }

    public void initVariables() {
        questionAnswerList = new List<QuestionnaireQuestionAnswerWrapper>();
        questionnaireAnswerList = new List<QuestionnaireAnswer__c>();
        answerChosen = new Map<String, Object>();
        questionSelectType = new Map<String, List<SelectOption>>();
    }

    public void populateDatas() {
        questionnaireToFill = QuestionnaireUtility.getQuestionnaireById(questionnaireId);
        questionAnswerList = QuestionnaireUtility.findQuestionAnswerFromQuestionnaireId(questionnaireId);
        
        questionnaireAnswerList = QuestionnaireUtility.retrieveAnswerFromQuestionIdList(questionAnswerList);
        questionSelectType = QuestionnaireUtility.generateSelectOptionMap(questionAnswerList);
        answerChosen = QuestionnaireUtility.createMapWithAnswers(questionAnswerList);
    }

    public Pagereference saveQuestionnaireFilled() {
        List<QuestionnaireSavedAnswer__c> answerToSave = new List<QuestionnaireSavedAnswer__c>();
        Set<String> answerIdList = answerChosen.keySet();
        for (String answerId : answerChosen.keySet()) {
            if (answerChosen.get(answerId) != null && !String.isBlank(answerChosen.get(answerId).toString()) && answerChosen.get(answerId).toString() != 'false') {
                QuestionnaireSavedAnswer__c savedAnswer = new QuestionnaireSavedAnswer__c();
                savedAnswer.Questionnaire__c = questionnaireId;
                System.debug('PRINT answerId=' + answerId);
                String questionId = QuestionnaireUtility.findQuestionIdFromAnswerId(questionnaireAnswerList, answerId);
                if (questionId == '-1') {
                    System.debug('PRINT will bug soon...');
                }
                savedAnswer.QuestionnaireQuestion__c = questionId;
                savedAnswer.QuestionnaireAnswers__c = answerId;
                savedAnswer.AnswerValue__c = answerChosen.get(answerId).toString();
                savedAnswer.Customer__c = customerId;
                answerToSave.add(savedAnswer);
                PageUtility.addInfoMessageOnThePage(String.valueOf(savedAnswer));
                System.debug('PRINT savedAnswer=' + savedAnswer);
                
            }
        }
        Database.insert(answerToSave);
        return null;
    }

    public Pagereference showQuestionnaire() {
        return QuestionnaireUtility.redirectSamePageWithQuestionnaireId('/apex/FillQuestionnaire', questionnaireId);
    }

    public Pagereference populateAnswers() {
        System.debug('PRINT temporarySelectedValue=' + temporarySelectedValue);
        answerChosen.put(temporarySelectedValue, true);
        return null;
    }
}