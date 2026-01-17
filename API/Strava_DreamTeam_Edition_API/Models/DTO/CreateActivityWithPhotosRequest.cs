namespace Strava_DreamTeam_Edition_API.Models.DTO
{
    public class CreateActivityWithPhotosRequest
    {
        public string? Name { get; set; }
        public string? Description { get; set; }
        public decimal? LengthInKm { get; set; }
        public decimal? PaceMinPerKm { get; set; }
        public decimal? SpeedKmPerHour { get; set; }
        public int ActiveSeconds { get; set; }
        public Guid ActivityCategoryId { get; set; }

        public IFormFile? UsePhoto { get; set; }
        public IFormFile? MapPhoto { get; set; }
    }
}
