trigger OpportunityTR on Opportunity (
    before insert,
	after insert,
    before update,
    after update,
    before delete,
    after delete
){
	TH_Opportunity.router();
}