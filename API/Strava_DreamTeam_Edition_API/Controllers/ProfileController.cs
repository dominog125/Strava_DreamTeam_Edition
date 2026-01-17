using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Strava_DreamTeam_Edition_API.Data;
using Strava_DreamTeam_Edition_API.Models.Domain;
using Strava_DreamTeam_Edition_API.Models.DTO;
using System.Security.Claims;

namespace Strava_DreamTeam_Edition_API.Controllers
{
    [ApiController]
    [Route("api/profile")]
    [Authorize(Roles = "User,Admin")]
    public class ProfileController : ControllerBase
    {
        private readonly StravaDreamTeamDbContext _db;

        public ProfileController(StravaDreamTeamDbContext db)
        {
            _db = db;
        }

        [HttpGet("me")]
        public async Task<ActionResult<UserProfileDto>> GetMe(CancellationToken ct)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var profile = await _db.UserProfiles
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.UserId == userId, ct);

            if (profile == null)
                return Ok(new UserProfileDto()); 

            return Ok(new UserProfileDto
            {
                FirstName = profile.FirstName,
                LastName = profile.LastName,
                BirthDate = profile.BirthDate,
                Gender = profile.Gender,
                HeightCm = profile.HeightCm,
                WeightKg = profile.WeightKg,

            });
        }


        [HttpPut("me")]
        public async Task<IActionResult> UpdateMe([FromBody] UpdateUserProfileRequest req, CancellationToken ct)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            if (req.HeightCm is not null && (req.HeightCm <= 0 || req.HeightCm > 300))
                return BadRequest("HeightCm ma niepoprawną wartość.");

            if (req.WeightKg is not null && (req.WeightKg <= 0 || req.WeightKg > 500))
                return BadRequest("WeightKg ma niepoprawną wartość.");

            var profile = await _db.UserProfiles
                .FirstOrDefaultAsync(p => p.UserId == userId, ct);

            if (profile == null)
            {
                profile = new UserProfile { UserId = userId };
                _db.UserProfiles.Add(profile);
            }

            profile.FirstName = req.FirstName?.Trim();
            profile.LastName = req.LastName?.Trim();
            profile.BirthDate = req.BirthDate;
            profile.Gender = req.Gender?.Trim();
            profile.HeightCm = req.HeightCm;
            profile.WeightKg = req.WeightKg;
            profile.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync(ct);
            return NoContent();
        }

  
        [HttpPost("me/avatar")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadAvatar([FromForm] UploadAvatarRequest request,CancellationToken ct)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var file = request.File;
            if (file == null || file.Length == 0)
                return BadRequest("Plik jest wymagany.");

            if (!file.ContentType.StartsWith("image/"))
                return BadRequest("Plik musi być obrazem.");

            if (file.Length > 2 * 1024 * 1024)
                return BadRequest("Maksymalny rozmiar avatara to 2MB.");

            var profile = await _db.UserProfiles
                .FirstOrDefaultAsync(p => p.UserId == userId, ct);

            if (profile == null)
            {
                profile = new UserProfile { UserId = userId };
                _db.UserProfiles.Add(profile);
            }

            using var ms = new MemoryStream();
            await file.CopyToAsync(ms, ct);

            profile.Avatar = ms.ToArray();
            profile.AvatarContentType = file.ContentType;
            profile.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync(ct);
            return NoContent();
        }


        [HttpGet("me/avatar")]
        public async Task<IActionResult> GetMyAvatar(CancellationToken ct)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var profile = await _db.UserProfiles
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.UserId == userId, ct);

            if (profile?.Avatar == null || profile.Avatar.Length == 0)
                return NotFound();

            return File(profile.Avatar, profile.AvatarContentType ?? "application/octet-stream");
        }
        [HttpDelete("me/avatar")]
        public async Task<IActionResult> DeleteMyAvatar(CancellationToken ct)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var profile = await _db.UserProfiles
                .FirstOrDefaultAsync(p => p.UserId == userId, ct);

            if (profile == null)
                return NoContent(); 

            if (profile.Avatar == null || profile.Avatar.Length == 0)
                return NoContent(); 

            profile.Avatar = null;
            profile.AvatarContentType = null;
            profile.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync(ct);
            return NoContent();
        }
        [Authorize(Roles = "User,Admin")]
        [HttpGet("stats")]
        public async Task<ActionResult<ProfileStatsDto>> GetMyStats(CancellationToken ct)
        {
            var userId = User.FindFirstValue(System.Security.Claims.ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var activities = await _db.Activities
                .AsNoTracking()
                .Where(a => a.AuthorId == userId)
                .ToListAsync(ct);

            if (activities.Count == 0)
            {
                return Ok(new ProfileStatsDto
                {
                    TrainingsCount = 0,
                    TotalDistanceKm = 0,
                    AverageSpeedKmPerHour = null
                });
            }

            var trainingsCount = activities.Count;
            var totalDistance = activities.Sum(a => a.LengthInKm);


            var speeds = activities
                .Where(a => a.SpeedKmPerHour.HasValue)
                .Select(a => a.SpeedKmPerHour!.Value)
                .ToList();

            decimal? avgSpeed = speeds.Count > 0
                ? Math.Round(speeds.Average(), 2)
                : null;

            return Ok(new ProfileStatsDto
            {
                TrainingsCount = trainingsCount,
                TotalDistanceKm = Math.Round(totalDistance, 2),
                AverageSpeedKmPerHour = avgSpeed
            });
        }
    }
}
