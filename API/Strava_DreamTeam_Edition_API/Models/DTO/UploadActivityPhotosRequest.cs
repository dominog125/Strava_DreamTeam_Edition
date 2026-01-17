namespace Strava_DreamTeam_Edition_API.Models.DTO
{
    public class UploadActivityPhotosRequest
    {
        public IFormFile? UsePhoto { get; set; }
        public IFormFile? MapPhoto { get; set; }
    }
}
