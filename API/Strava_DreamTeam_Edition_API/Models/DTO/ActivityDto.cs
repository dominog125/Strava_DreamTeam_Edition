using System;

namespace Strava_DreamTeam_Edition_API.Models.DTO
{
    public class ActivityDto
    {
        public Guid Id { get; set; }
        public string? Name { get; set; }
        public string? Description { get; set; }
        public decimal? LengthInKm { get; set; }
        public string AuthorId { get; set; } = default!;
        // NOWE
        public decimal? PaceMinPerKm { get; set; }
        public decimal? SpeedKmPerHour { get; set; }
        public int ActiveSeconds { get; set; }
        public Guid ActivityCategoryId { get; set; }
        public string? CategoryName { get; set; }
        public DateTime? CreatedAt { get; set; }

    }

    public class CreateActivityRequest
    {
        public string? Name { get; set; }
        public string? Description { get; set; }
        public decimal? LengthInKm { get; set; }
        public decimal? PaceMinPerKm { get; set; }
        public decimal? SpeedKmPerHour { get; set; }
        public int ActiveSeconds { get; set; }
        public Guid ActivityCategoryId { get; set; }
        public IFormFile? Photo1 { get; set; }
        public IFormFile? Photo2 { get; set; }

    }
    public class ActivityQuery
    {
     
        public string? AuthorUserName { get; set; }

        public decimal? MinDistanceKm { get; set; }
        public decimal? MaxDistanceKm { get; set; }

        public DateTime? CreatedFrom { get; set; }
        public DateTime? CreatedTo { get; set; }

        public Guid? ActivityCategoryId { get; set; }

        public string? SortBy { get; set; }  // "date" | "distance" | "type"
        public string? SortDir { get; set; } // "asc" | "desc"
    }

    public class UpdateActivityRequest
    {
        public string? Name { get; set; }
        public string? Description { get; set; }
        public decimal? LengthInKm { get; set; }
        public int? ActiveSeconds { get; set; }

        // NOWE
        public decimal? PaceMinPerKm { get; set; }
        public decimal? SpeedKmPerHour { get; set; }
        public Guid ActivityCategoryId { get; set; }

    }
}
