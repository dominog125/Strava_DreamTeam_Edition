using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Strava_DreamTeam_Edition_API.Data;
using Strava_DreamTeam_Edition_API.Models.Domain;
using Strava_DreamTeam_Edition_API.Models.DTO;
using System.Security.Claims;

namespace Strava_DreamTeam_Edition_API.Controllers
{
    [ApiController]
    [Route("api/activities/{activityId:guid}/comments")]
    [Authorize(Roles = "User,Admin")]
    public class ActivityCommentsController : ControllerBase
    {
        private readonly StravaDreamTeamDbContext _db;
        private readonly StravaDreamTeamAuthDbContext _authDb;

        public ActivityCommentsController(StravaDreamTeamDbContext db, StravaDreamTeamAuthDbContext authDb)
        {
            _db = db;
            _authDb = authDb;
        }

        private string? CurrentUserId() => User.FindFirstValue(ClaimTypes.NameIdentifier);

        private async Task<Dictionary<string, string?>> MapUserNamesAsync(List<string> ids, CancellationToken ct)
        {
            if (ids.Count == 0) return new Dictionary<string, string?>();

            var users = await _authDb.Users
                .AsNoTracking()
                .Where(u => ids.Contains(u.Id))
                .Select(u => new { u.Id, u.UserName })
                .ToListAsync(ct);

            return users.ToDictionary(x => x.Id, x => (string?)x.UserName);
        }

        private async Task<bool> AnyBlockBetweenAsync(string a, string b, CancellationToken ct)
        {
            return await _db.FriendRelations.AsNoTracking().AnyAsync(r =>
                (r.UserId == a && r.OtherUserId == b && r.Status == FriendRelationStatus.Blocked) ||
                (r.UserId == b && r.OtherUserId == a && r.Status == FriendRelationStatus.Blocked), ct);
        }

        private async Task<(bool ok, string? authorId)> CanSeeActivityAsync(Guid activityId, string userId, bool isAdmin, CancellationToken ct)
        {
            var item = await _db.Activities
                .AsNoTracking()
                .Where(a => a.ID == activityId)
                .Select(a => new { a.AuthorId })
                .FirstOrDefaultAsync(ct);

            if (item == null) return (false, null);
            if (isAdmin) return (true, item.AuthorId);
            if (item.AuthorId == userId) return (true, item.AuthorId);

            if (await AnyBlockBetweenAsync(userId, item.AuthorId, ct)) return (false, item.AuthorId);

            var accepted = await _db.FriendRelations.AsNoTracking().AnyAsync(r =>
                r.UserId == userId &&
                r.OtherUserId == item.AuthorId &&
                r.Status == FriendRelationStatus.Accepted, ct);

            return (accepted, item.AuthorId);
        }


        [HttpGet]
        public async Task<ActionResult<IEnumerable<ActivityCommentDto>>> GetAll(Guid activityId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            var access = await CanSeeActivityAsync(activityId, userId, isAdmin, ct);
            if (!access.ok) return Forbid();

            var comments = await _db.ActivityComments
                .AsNoTracking()
                .Where(c => c.ActivityId == activityId)
                .OrderBy(c => c.CreatedAt)
                .Select(c => new ActivityCommentDto
                {
                    Id = c.Id,
                    AuthorId = c.AuthorId,
                    Content = c.Content,
                    CreatedAt = c.CreatedAt
                })
                .ToListAsync(ct);


            var authorIds = comments.Select(x => x.AuthorId).Distinct().ToList();
            var nameMap = await MapUserNamesAsync(authorIds, ct);

            foreach (var c in comments)
                c.AuthorUserName = nameMap.TryGetValue(c.AuthorId, out var n) ? n : null;

            return Ok(comments);
        }

        [HttpGet("count")]
        public async Task<ActionResult<int>> GetCount(Guid activityId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            var access = await CanSeeActivityAsync(activityId, userId, isAdmin, ct);
            if (!access.ok) return Forbid();

            var count = await _db.ActivityComments
                .AsNoTracking()
                .CountAsync(c => c.ActivityId == activityId, ct);

            return Ok(count);
        }

        [HttpPost]
        public async Task<IActionResult> Create(Guid activityId, [FromBody] CreateCommentRequest req, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            if (req == null || string.IsNullOrWhiteSpace(req.Content))
                return BadRequest("Content is required.");

            var isAdmin = User.IsInRole("Admin");
            var access = await CanSeeActivityAsync(activityId, userId, isAdmin, ct);
            if (!access.ok) return Forbid();

            _db.ActivityComments.Add(new ActivityComment
            {
                Id = Guid.NewGuid(),
                ActivityId = activityId,
                AuthorId = userId,
                Content = req.Content.Trim(),
                CreatedAt = DateTime.UtcNow
            });

            await _db.SaveChangesAsync(ct);
            return NoContent();
        }


        [HttpDelete("{commentId:guid}")]
        public async Task<IActionResult> Delete(Guid activityId, Guid commentId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            var isAdmin = User.IsInRole("Admin");


            var access = await CanSeeActivityAsync(activityId, userId, isAdmin, ct);
            if (!access.ok) return Forbid();

            var comment = await _db.ActivityComments
                .FirstOrDefaultAsync(c => c.Id == commentId && c.ActivityId == activityId, ct);

            if (comment == null) return NotFound();

            if (!isAdmin && comment.AuthorId != userId)
                return Forbid();

            _db.ActivityComments.Remove(comment);
            await _db.SaveChangesAsync(ct);
            return NoContent();
        }
    }
}
