namespace Strava_DreamTeam_Edition_API.Models.Domain
{
    public class ActivityLike
    {
        public Guid Id { get; set; }
        public Guid ActivityId { get; set; }
        public string UserId { get; set; } = default!;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public Activity Activity { get; set; } = default!;
    }
}
