namespace Strava_DreamTeam_Edition_API.Models.DTO
{
    public class MonthlyDistanceRankingDto
    {
        public int Year { get; set; }
        public int Month { get; set; }

        public List<MonthlyDistanceRankingEntryDto> TopUsers { get; set; } = new();

        public int? MyRank { get; set; }
        public decimal MyTotalDistanceKm { get; set; }

        public class MonthlyDistanceRankingEntryDto
        {
            public string UserId { get; set; } = default!;
            public string? UserName { get; set; }
            public decimal TotalDistanceKm { get; set; }
        }
    }
}
