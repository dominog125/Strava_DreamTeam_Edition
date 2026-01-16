namespace Strava_DreamTeam_Edition_API.Models.Domain
{
    public class ActivityGpsPoint
    {
        public Guid Id { get; set; }
        public Guid ActivityId { get; set; }

        public double Latitude { get; set; }
        public double Longitude { get; set; }

        public DateTime Timestamp { get; set; }

        public Activity Activity { get; set; } = default!;
    }
}
