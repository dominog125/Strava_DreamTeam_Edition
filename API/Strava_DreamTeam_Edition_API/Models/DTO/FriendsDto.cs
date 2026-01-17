namespace Strava_DreamTeam_Edition_API.Models.DTO
{
    public class FriendDto
    {
        public string UserId { get; set; } = default!;
        public string? UserName { get; set; }
        public string Status { get; set; } = default!;
    }

    public class SendFriendRequestDto
    {
        public string UserName { get; set; } = default!;
    }

    public class FriendRequestDto
    {
        public string UserId { get; set; } = default!;
        public string? UserName { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
