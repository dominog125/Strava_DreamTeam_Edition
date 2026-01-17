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

        public ActivityStatus Status { get; set; }
        public DateTime StartedAt { get; set; }
        public DateTime? FinishedAt { get; set; }

        public decimal? PaceMinPerKm { get; set; }
        public decimal? SpeedKmPerHour { get; set; }
        public int ActiveSeconds { get; set; }
        public byte[]? UsePhoto { get; set; }
        public string? UsePhotoContentType { get; set; }

        public byte[]? MapPhoto { get; set; }
        public string? MapPhotoContentType { get; set; }

        public ICollection<ActivityGpsPoint> GpsPoints { get; set; } = new List<ActivityGpsPoint>();
    }
}
