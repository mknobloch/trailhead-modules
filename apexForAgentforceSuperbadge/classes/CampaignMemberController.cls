public class CampaignMemberController {

    public static void createCampaignMemberforRelatedCampaigns(Map<Id, Contact> recurringCampaignParticipantByContactId){
                
        List<CampaignMember> campaignMemberstoInsert = new List<CampaignMember>();
        
        List<CampaignMember> campaignmembers = [Select Id, Booking__r.Id, CampaignId, Campaign.Type, Campaign.Parent.Name, ContactId From CampaignMember Where ContactId IN : recurringCampaignParticipantByContactId.keyset()];
      System.debug(campaignmembers);
        
        Set<Id> campaignIdsInMembers = new Set<Id>();
        for (CampaignMember cm : campaignMembers) {
            campaignIdsInMembers.add(cm.CampaignId);
        }
        
        Map<String, List<CampaignMember>> relatedCampaigntoCampaignMembers = new Map<String, List<CampaignMember>>();
          
        if(campaignmembers.size()>0){
            for(CampaignMember currentCampaignMember :campaignmembers){
                if(relatedCampaigntoCampaignMembers.containsKey(currentCampaignMember.Campaign.Type)){
                    relatedCampaigntoCampaignMembers.get(currentCampaignMember.Campaign.Type).add(currentCampaignMember);
                } else {
                    relatedCampaigntoCampaignMembers.put(currentCampaignMember.Campaign.Type, new List<CampaignMember> {currentCampaignMember});
                }
          }
          System.debug(relatedCampaigntoCampaignMembers.keySet());
        }
        
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([Select Id,  Name From Campaign Where Type IN : relatedCampaigntoCampaignMembers.keySet()]);

        
        System.debug(campaignMap);
        
        for(Contact contact :recurringCampaignParticipantByContactId.values()){
            for (Id campaignId : campaignMap.keySet()) {
                if (!campaignIdsInMembers.contains(campaignId)) {
                    campaignMemberstoInsert.add(new CampaignMember(
                        CampaignId = campaignId,
                        ContactId = contact.Id,
                        Status = 'Planned'
                    ));
                }
            }
        }
        System.debug(campaignMemberstoInsert);
        if(!campaignMemberstoInsert.isEmpty()){
            insert campaignMemberstoInsert;
        }
        
    }
}