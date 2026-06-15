public class GuestReviewProcessor {
    
    
    
    //TO-DO Build out Invocable method processReviews with label and description
    
    public static List<GuestReviewResponse> processReviews(List<GuestReviewRequest> requests){

        GuestReviewResponse response = new GuestReviewResponse();
        
        
        //TO-DO Insert Guest_Review__c record with contact (Contact__c), experience (Experience__c), rating (Rating__c), and review (Comments__c) variables in the processReviews method
        
        //TO-DO Add exception handling code with a try-catch block
        
        //[OPTIONAL] Call CampaignMemberController.createCampaignMemberforRelatedCampaigns() in processReviews method 
        
        //TO-DO Set the output variable response.message from GuestReviewResponse
        
        return new List<GuestReviewResponse> { response };
        
    }
    
    public class GuestReviewRequest{
        //TO-DO Build out GuestReviewRequest class with Invocable variables
        
        public Contact contact;
        
        public Experience__c experience;
        
        public String review;
        
        public String rating;
        
    }
    
    
    public class GuestReviewResponse{
        //TO-DO Build out GuestReviewResponse class with Invocable variables
        
        public String message;
        
    }    
    
}