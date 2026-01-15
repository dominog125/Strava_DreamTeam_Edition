namespace Strava_DreamTeam_Edition_API.Models.DTO
{
    public class ActivityCategoryDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = default!;
    }

    public class CreateActivityCategoryRequest
    {
        public string Name { get; set; } = default!;
    }

    public class UpdateActivityCategoryRequest
    {
        public string Name { get; set; } = default!;
    }
}
