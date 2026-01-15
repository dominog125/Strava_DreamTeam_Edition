namespace Strava_DreamTeam_Edition_API.Models.Domain
{

    public enum ActivityStatus
    {
        InProgress,
        Paused,
        Finished
    }
    public class Activity
    {
        public Guid ID { get; set; }

        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal LengthInKm { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public required string AuthorId { get; set; }

        public Guid CategoryId { get; set; }
        public ActivityCategory Category { get; set; } = default!;

        // === TRACKING ===
        public ActivityStatus Status { get; set; }

        public DateTime StartedAt { get; set; }
        public DateTime? FinishedAt { get; set; }
        // NOWE POLA
        public decimal? PaceMinPerKm { get; set; }   // tempo
        public decimal? SpeedKmPerHour { get; set; } // prędkość
        public int ActiveSeconds { get; set; }

        public ICollection<ActivityGpsPoint> GpsPoints { get; set; } = new List<ActivityGpsPoint>();
    }
}
