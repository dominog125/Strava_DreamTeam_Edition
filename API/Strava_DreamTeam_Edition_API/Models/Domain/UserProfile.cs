

using System.ComponentModel.DataAnnotations;

namespace Strava_DreamTeam_Edition_API.Models.Domain
{
    public class UserProfile
    {
        [Key]
        public string UserId { get; set; } = default!;

        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public DateTime? BirthDate { get; set; }


        public string? Gender { get; set; }

      
        public decimal? HeightCm { get; set; }
        public decimal? WeightKg { get; set; }

        public byte[]? Avatar { get; set; }
        public string? AvatarContentType { get; set; }

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}