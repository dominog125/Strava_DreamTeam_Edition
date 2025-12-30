namespace Strava_DreamTeam_Edition_API.Models.Domain
{
    public class Activity
    {
        
        public Guid ID { get; set; }
        
        public string Name { get; set; }

        public string Description { get; set; } 

        public string LengthInKm { get; set; }
       
        public Guid ActivityCategory { get; set; }
        
        public ActivityCategory category { get; set; }


    }
}
