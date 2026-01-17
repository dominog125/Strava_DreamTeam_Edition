using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Strava_DreamTeam_Edition_API.Data;
using Strava_DreamTeam_Edition_API.Models.Domain;
using System.Security.Claims;

namespace Strava_DreamTeam_Edition_API.Controllers
{
    [ApiController]
    [Route("api/activities/{activityId:guid}/likes")]
    [Authorize(Roles = "User,Admin")]
    public class ActivityLikesController : ControllerBase
    {
        private readonly StravaDreamTeamDbContext _db;

        public ActivityLikesController(StravaDreamTeamDbContext db)
        {
            _db = db;
        }

        private string? CurrentUserId() => User.FindFirstValue(ClaimTypes.NameIdentifier);

        private async Task<bool> AnyBlockBetweenAsync(string a, string b, CancellationToken ct)
        {
            return await _db.FriendRelations.AsNoTracking().AnyAsync(r =>
                (r.UserId == a && r.OtherUserId == b && r.Status == FriendRelationStatus.Blocked) ||
                (r.UserId == b && r.OtherUserId == a && r.Status == FriendRelationStatus.Blocked), ct);
        }

        private async Task<bool> CanSeeActivityAsync(Guid activityId, string userId, bool isAdmin, CancellationToken ct)
        {
            var item = await _db.Activities
                .AsNoTracking()
                .Where(a => a.ID == activityId)
                .Select(a => new { a.AuthorId })
                .FirstOrDefaultAsync(ct);

            if (item == null) return false;
            if (isAdmin) return true;
            if (item.AuthorId == userId) return true;


            if (await AnyBlockBetweenAsync(userId, item.AuthorId, ct)) return false;

            var accepted = await _db.FriendRelations.AsNoTracking().AnyAsync(r =>
                r.UserId == userId &&
                r.OtherUserId == item.AuthorId &&
                r.Status == FriendRelationStatus.Accepted, ct);

            return accepted;
        }

        [HttpGet("count")]
        public async Task<ActionResult<int>> GetCount(Guid activityId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            if (!await CanSeeActivityAsync(activityId, userId, isAdmin, ct)) return Forbid();

            var count = await _db.ActivityLikes
                .AsNoTracking()
                .CountAsync(l => l.ActivityId == activityId, ct);

            return Ok(count);
        }

        [HttpGet("me")]
        public async Task<ActionResult<bool>> IsLikedByMe(Guid activityId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            if (!await CanSeeActivityAsync(activityId, userId, isAdmin, ct)) return Forbid();

            var liked = await _db.ActivityLikes
                .AsNoTracking()
                .AnyAsync(l => l.ActivityId == activityId && l.UserId == userId, ct);

            return Ok(liked);
        }

        [HttpPost]
        public async Task<IActionResult> Like(Guid activityId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            if (!await CanSeeActivityAsync(activityId, userId, isAdmin, ct)) return Forbid();

            var exists = await _db.ActivityLikes
                .AsNoTracking()
                .AnyAsync(l => l.ActivityId == activityId && l.UserId == userId, ct);

            if (exists) return Conflict("Already liked.");

            _db.ActivityLikes.Add(new ActivityLike
            {
                Id = Guid.NewGuid(),
                ActivityId = activityId,
                UserId = userId,
                CreatedAt = DateTime.UtcNow
            });

            await _db.SaveChangesAsync(ct);
            return NoContent();
        }

        [HttpDelete]
        public async Task<IActionResult> Unlike(Guid activityId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            if (!await CanSeeActivityAsync(activityId, userId, isAdmin, ct)) return Forbid();

            var like = await _db.ActivityLikes
                .FirstOrDefaultAsync(l => l.ActivityId == activityId && l.UserId == userId, ct);

            if (like == null) return NotFound();

            _db.ActivityLikes.Remove(like);
            await _db.SaveChangesAsync(ct);
            return NoContent();
        }
    }
}
