namespace Strava_DreamTeam_Edition_API.Models.DTO
{
    public class UserProfileDto
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public DateTime? BirthDate { get; set; }
        public string? Gender { get; set; }
        public decimal? HeightCm { get; set; }
        public decimal? WeightKg { get; set; }
    
    }

    public class UpdateUserProfileRequest : UserProfileDto
    {

    }
}
