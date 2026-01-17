namespace Strava_DreamTeam_Edition_API.Models.DTO
{
    public class ActivityWithPhotosDto


    {

        public Guid Id { get; set; }
        public string? Name { get; set; }
        public string? Description { get; set; }
        public decimal? LengthInKm { get; set; }
        public string AuthorId { get; set; } = default!;
        public decimal? PaceMinPerKm { get; set; }
        public decimal? SpeedKmPerHour { get; set; }
        public int ActiveSeconds { get; set; }
        public Guid ActivityCategoryId { get; set; }
        public string? CategoryName { get; set; }
        public DateTime? CreatedAt { get; set; }
        public string? UsePhotoBase64 { get; set; }
        public string? UsePhotoContentType { get; set; }

        public string? MapPhotoBase64 { get; set; }
        public string? MapPhotoContentType { get; set; }
    }
}
