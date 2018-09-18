public class AnswerIndexWrapper {
    public Integer index {get; set;}
    public QuestionnaireAnswer__c answer {get; set;}

    public AnswerIndexWrapper(Integer indexParam) {
        index = indexParam;
        answer = new QuestionnaireAnswer__c();
    }

    public AnswerIndexWrapper(Integer indexParam, QuestionnaireAnswer__c answerParam) {
        index = indexParam;
        answer = answerParam;
    }
}