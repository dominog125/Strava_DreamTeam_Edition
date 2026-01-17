using System.ComponentModel.DataAnnotations;

namespace Strava_DreamTeam_Edition_API.Models.Domain
{
    public enum FriendRelationStatus
    {
        Pending = 0,
        Accepted = 1,
        Blocked = 2
    }
    public class FriendRelation
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public string UserId { get; set; } = default!;

        [Required]
        public string OtherUserId { get; set; } = default!;

        public FriendRelationStatus Status { get; set; } = FriendRelationStatus.Pending;

        [Required]
        public string InitiatorUserId { get; set; } = default!;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }
}
