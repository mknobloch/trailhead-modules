public class GuestReviewProcessor {

    @InvocableMethod(
        label='Process Guest Reviews'
        description='Processes guest experience reviews by creating a Guest Review record from chat input'
    )
    public static List<GuestReviewResponse> processReviews(List<GuestReviewRequest> requests) {

        GuestReviewResponse response = new GuestReviewResponse();

        try {
            GuestReviewRequest request = requests[0];

            Guest_Review__c review = new Guest_Review__c(
                Contact__c = request.contact.Id,
                Experience__c = request.experience.Id,
                Comments__c = request.review,
                Rating__c = request.rating
            );
            insert review;

            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            contactMap.put(request.contact.Id, request.contact);
            CampaignMemberController.createCampaignMemberforRelatedCampaigns(contactMap);

            response.message = 'Your review has been successfully recorded. Thank you for your feedback!';
        } catch (Exception e) {
            response.message = 'There has been a problem processing your review. Please try again later.';
        }

        return new List<GuestReviewResponse> { response };
    }

    public class GuestReviewRequest {
        @InvocableVariable(required=true description='The contact record of the guest submitting the review')
        public Contact contact;

        @InvocableVariable(required=true description='The experience record being reviewed')
        public Experience__c experience;

        @InvocableVariable(required=true description='The written review text from the guest')
        public String review;

        @InvocableVariable(required=true description='The numeric rating from 1 to 10')
        public String rating;
    }

    public class GuestReviewResponse {
        @InvocableVariable(label='status' description='The status message indicating success or failure of the review processing')
        public String message;
    }

}
