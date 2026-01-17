using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Strava_DreamTeam_Edition_API.Data;
using Strava_DreamTeam_Edition_API.Models.DTO;

namespace Strava_DreamTeam_Edition_API.Controllers
{
    [ApiController]
    [Route("api/admin/stats")]
    [Authorize(Roles = "Admin")]
    public class AdminStatsController : ControllerBase
    {
        private readonly StravaDreamTeamDbContext _db;
        private readonly StravaDreamTeamAuthDbContext _authDb;

        public AdminStatsController(StravaDreamTeamDbContext db, StravaDreamTeamAuthDbContext authDb)
        {
            _db = db;
            _authDb = authDb;
        }

        [HttpGet("global")]
        public async Task<ActionResult<AdminStatsDto>> GetGlobal(CancellationToken ct)
        {
            var usersCount = await _authDb.Users.AsNoTracking().CountAsync(ct);

            var activitiesCount = await _db.Activities.AsNoTracking().CountAsync(ct);

            var totalDistance = await _db.Activities
                .AsNoTracking()
                .SumAsync(a => (decimal?)a.LengthInKm, ct) ?? 0m;

            var dto = new AdminStatsDto
            {
                UsersCount = usersCount,
                ActivitiesCount = activitiesCount,
                TotalDistanceKm = totalDistance
            };

            return Ok(dto);
        }
    }
}
