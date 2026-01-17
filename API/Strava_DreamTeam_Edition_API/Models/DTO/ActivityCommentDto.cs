namespace Strava_DreamTeam_Edition_API.Models.DTO
{
    public class ActivityCommentDto
    {
        public Guid Id { get; set; }
        public string AuthorId { get; set; } = default!;
        public string? AuthorUserName { get; set; }
        public string Content { get; set; } = default!;
        public DateTime CreatedAt { get; set; }
    }

    public class CreateCommentRequest
    {
        public string Content { get; set; } = default!;
    }
}
