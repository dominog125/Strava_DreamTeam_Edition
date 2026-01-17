namespace Strava_DreamTeam_Edition_API.Models.DTO
{
    public class UserSearchResultDto
    {
        public string UserId { get; set; } = default!;
        public string? UserName { get; set; }
        public string RelationStatus { get; set; } = "None";
    }
}
