public class QuestionnaireQuestionAnswerWrapper {
    public Integer index {get; set;}
    public QuestionnaireQuestion__c question {get; set;}
    public List<AnswerIndexWrapper> answerIndexWrapperList {get; set;}

    public QuestionnaireQuestionAnswerWrapper(Integer indexParam) {
        index = indexParam;
        question = new QuestionnaireQuestion__c();
        answerIndexWrapperList = new List<AnswerIndexWrapper>();
    }

    public QuestionnaireQuestionAnswerWrapper(Integer indexParam, QuestionnaireQuestion__c questionParam, List<AnswerIndexWrapper> answerIndexWrapperListParam) {
        index = indexParam;
        question = questionParam;
        answerIndexWrapperList = answerIndexWrapperListParam;
    }
}