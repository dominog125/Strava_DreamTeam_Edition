using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Strava_DreamTeam_Edition_API.Data;
using Strava_DreamTeam_Edition_API.Models.DTO;
using System.Security.Claims;
using static Strava_DreamTeam_Edition_API.Models.DTO.MonthlyDistanceRankingDto;

namespace Strava_DreamTeam_Edition_API.Controllers
{
    [ApiController]
    [Route("api/user/stats")]
    [Authorize(Roles = "User,Admin")]
    public class UserStatsController : ControllerBase
    {
        private readonly StravaDreamTeamDbContext _db;
        private readonly StravaDreamTeamAuthDbContext _authDb;

        public UserStatsController(StravaDreamTeamDbContext db, StravaDreamTeamAuthDbContext authDb)
        {
            _db = db;
            _authDb = authDb;
        }

        [HttpGet("ranking/monthly")]
        public async Task<ActionResult<MonthlyDistanceRankingDto>> GetMonthlyDistanceRanking(
            [FromQuery] int? year,
            [FromQuery] int? month,
            [FromQuery] int take = 5,
            CancellationToken ct = default)
        {
            take = Math.Clamp(take, 1, 50);

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var now = DateTime.UtcNow;
            var y = year ?? now.Year;
            var m = month ?? now.Month;

            if (m is < 1 or > 12)
                return BadRequest("month musi być w zakresie 1–12.");
            if (y is < 2000 or > 2100)
                return BadRequest("year ma niepoprawną wartość.");

            var start = new DateTime(y, m, 1, 0, 0, 0, DateTimeKind.Utc);
            var end = start.AddMonths(1);

            var monthly = _db.Activities
                .AsNoTracking()
                .Where(a => a.CreatedAt >= start && a.CreatedAt < end);

            var top = await monthly
                .GroupBy(a => a.AuthorId)
                .Select(g => new
                {
                    UserId = g.Key,
                    Total = g.Sum(x => x.LengthInKm)
                })
                .OrderByDescending(x => x.Total)
                .Take(take)
                .ToListAsync(ct);

            var myTotal = await monthly
                .Where(a => a.AuthorId == userId)
                .SumAsync(a => (decimal?)a.LengthInKm, ct) ?? 0m;

            int? myRank = null;
            if (myTotal > 0m)
            {
                var higherCount = await monthly
                    .GroupBy(a => a.AuthorId)
                    .Select(g => g.Sum(x => x.LengthInKm))
                    .CountAsync(sum => sum > myTotal, ct);

                myRank = higherCount + 1;
            }

            var idsToMap = top.Select(x => x.UserId).Append(userId).Distinct().ToList();

            var users = await _authDb.Users
                .AsNoTracking()
                .Where(u => idsToMap.Contains(u.Id))
                .Select(u => new { u.Id, u.UserName })
                .ToListAsync(ct);

            var result = new MonthlyDistanceRankingDto
            {
                Year = y,
                Month = m,
                TopUsers = top.Select(x => new MonthlyDistanceRankingEntryDto
                {
                    UserId = x.UserId,
                    UserName = users.FirstOrDefault(u => u.Id == x.UserId)?.UserName,
                    TotalDistanceKm = x.Total
                }).ToList(),
                MyRank = myRank,
                MyTotalDistanceKm = myTotal
            };

            return Ok(result);
        }
    }
}
