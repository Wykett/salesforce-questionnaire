public with sharing class PageUtility {
    public static PageReference toPage(String endpoint) {
        PageReference page = new PageReference('/apex/' + endpoint);
    	page.setRedirect(true);
    	return page;  
    }

    public static void addErrorMessageOnThePage(String message) {
        addMessageOnThePage(ApexPages.severity.ERROR, message);
    }

    public static void addInfoMessageOnThePage(String message) {
        addMessageOnThePage(ApexPages.severity.INFO, message);
    }

    public static void addMessageOnThePage(ApexPages.Severity severity, String message) {
        ApexPages.Message myMsg = new ApexPages.Message(severity, message);
        ApexPages.addMessage(myMsg);
    }
}
