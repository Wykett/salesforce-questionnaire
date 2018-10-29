public class QuestionnaireUtility {
    public static List<QuestionnaireQuestionAnswerWrapper> findQuestionAnswerFromQuestionnaireId(String questionnaireId) {
        List<QuestionnaireQuestionAnswerWrapper> questionAnswerList = new List<QuestionnaireQuestionAnswerWrapper>();
        List<QuestionnaireQuestion__c> questionList = [SELECT Id, QuestionType__c, Order__c, QuestionLabel__c, QuestionnaireMaster__c
                                                        FROM QuestionnaireQuestion__c 
                                                        WHERE QuestionnaireMaster__c = :questionnaireId
                                                        ORDER BY Order__c];
        Integer currentIndex = 0;
        for (QuestionnaireQuestion__c questionItem : questionList) {
            List<AnswerIndexWrapper> answerIndexWrapperList = new List<AnswerIndexWrapper>();
            List<QuestionnaireAnswer__c> answerList = [SELECT AnswerLabel__c FROM QuestionnaireAnswer__c WHERE QuestionnaireQuestion__c = :questionItem.Id];
            for (QuestionnaireAnswer__c answerItem : answerList)
                answerIndexWrapperList.add(new AnswerIndexWrapper(answerIndexWrapperList.size(), answerItem));
            questionAnswerList.add(new QuestionnaireQuestionAnswerWrapper(currentIndex, questionItem, answerIndexWrapperList));
            currentIndex++;
        }
        return questionAnswerList;
    }

    public static Map<String, Object> createMapWithAnswers(List<QuestionnaireQuestionAnswerWrapper> questionAnswerList) {
        Map<String, Object> answerChosen = new Map<String, Object>();
        for (QuestionnaireQuestionAnswerWrapper questionAnswerItem : questionAnswerList) {
            for (AnswerIndexWrapper AnswerIndexWrapperItem : questionAnswerItem.answerIndexWrapperList) {
                answerChosen.put(AnswerIndexWrapperItem.answer.Id, '');
            }
        }
        return answerChosen;
    }

    public static List<System.SelectOption> generateAllQuestionnaireSelectOption() {
        List<Questionnaire__c> questionnaireList = [SELECT Id, Name FROM Questionnaire__c];
        List<System.SelectOption> questionnaireChoices = new List<SelectOption>();
        questionnaireChoices.add(new SelectOption('-1', '--- Select ---'));
        if (questionnaireList != null && questionnaireList.size() > 0)
            for (Questionnaire__c questionnaireItem : questionnaireList)
                questionnaireChoices.add(new SelectOption(questionnaireItem.Id, questionnaireItem.Name));

        return questionnaireChoices;
    }

    public static Pagereference redirectSamePageWithQuestionnaireId(String endpoint, String questionnaireId) {
        PageReference currentPage = new PageReference(endpoint);
        currentPage.getparameters().put('questionnaireId', questionnaireId);
        currentPage.setRedirect(true);
        return currentPage;
    }

    public static Map<String, List<SelectOption>> generateSelectOptionMap(List<QuestionnaireQuestionAnswerWrapper> questionAnswerList) {
        Map<String, List<SelectOption>> questionSelectType = new Map<String, List<SelectOption>>();
        for (QuestionnaireQuestionAnswerWrapper questionAnswerItem : questionAnswerList) {
            if (questionAnswerItem.question.QuestionType__c == 'Select') {
                List<SelectOption> answerOptionList = new List<SelectOption>();
                answerOptionList.add(new SelectOption('-1', '-- Select --'));
                for (AnswerIndexWrapper answerIndexWrapperItem : questionAnswerItem.answerIndexWrapperList) {
                    answerOptionList.add(new SelectOption(answerIndexWrapperItem.answer.Id, answerIndexWrapperItem.answer.AnswerLabel__c));
                }
                questionSelectType.put(questionAnswerItem.question.Id, answerOptionList);
            }
        }
        return questionSelectType;
    }
}