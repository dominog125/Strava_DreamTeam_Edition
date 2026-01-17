namespace Strava_DreamTeam_Edition_API.Models.DTO
{
    public class ProfileStatsDto
    {
        public int TrainingsCount { get; set; }
        public decimal TotalDistanceKm { get; set; }
        public decimal? AverageSpeedKmPerHour { get; set; }
    }
}
