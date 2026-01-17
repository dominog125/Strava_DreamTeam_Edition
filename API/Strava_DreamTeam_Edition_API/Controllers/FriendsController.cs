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
    [Route("api/friends")]
    [Authorize(Roles = "User,Admin")]
    public class FriendsController : ControllerBase
    {
        private readonly StravaDreamTeamDbContext _db;
        private readonly StravaDreamTeamAuthDbContext _authDb;

        public FriendsController(StravaDreamTeamDbContext db, StravaDreamTeamAuthDbContext authDb)
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


        [HttpGet]
        public async Task<ActionResult<IEnumerable<FriendDto>>> GetMyRelations(
        [FromQuery] string? status,
        CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            IQueryable<FriendRelation> query = _db.FriendRelations
                .AsNoTracking()
                .Where(r => r.UserId == userId);

            if (!string.IsNullOrWhiteSpace(status))
            {
                var statuses = status
                    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                    .Select(s => Enum.TryParse<FriendRelationStatus>(s, true, out var parsed)
                        ? (FriendRelationStatus?)parsed
                        : null)
                    .Where(s => s.HasValue)
                    .Select(s => s!.Value)
                    .ToList();

                if (statuses.Count == 0)
                    return BadRequest("Nieprawidłowy status relacji.");

                query = query.Where(r => statuses.Contains(r.Status));
            }

            var relations = await query
                .OrderBy(r => r.Status)
                .ThenByDescending(r => r.CreatedAt)
                .ToListAsync(ct);

            var otherIds = relations.Select(r => r.OtherUserId).Distinct().ToList();
            var nameMap = await MapUserNamesAsync(otherIds, ct);

            var dto = relations.Select(r => new FriendDto
            {
                UserId = r.OtherUserId,
                UserName = nameMap.TryGetValue(r.OtherUserId, out var n) ? n : null,
                Status = r.Status.ToString()
            }).ToList();

            return Ok(dto);
        }

     
        [HttpPost("requests")]
        public async Task<IActionResult> SendRequest([FromBody] SendFriendRequestDto req, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            if (string.IsNullOrWhiteSpace(req.UserName))
                return BadRequest("UserName jest wymagane.");

            var otherUserId = await _authDb.Users
                .AsNoTracking()
                .Where(u => u.UserName == req.UserName.Trim())
                .Select(u => u.Id)
                .FirstOrDefaultAsync(ct);

            if (string.IsNullOrWhiteSpace(otherUserId))
                return NotFound("Użytkownik nie istnieje.");

            if (otherUserId == userId)
                return BadRequest("Nie możesz dodać samego siebie.");

            if (await AnyBlockBetweenAsync(userId, otherUserId, ct))
                return Conflict("Relacja jest zablokowana.");

            var alreadyAccepted = await _db.FriendRelations.AsNoTracking().AnyAsync(r =>
                ((r.UserId == userId && r.OtherUserId == otherUserId) ||
                 (r.UserId == otherUserId && r.OtherUserId == userId))
                && r.Status == FriendRelationStatus.Accepted, ct);

            if (alreadyAccepted)
                return Conflict("Jesteście już znajomymi.");

            var pendingExists = await _db.FriendRelations.AsNoTracking().AnyAsync(r =>
                ((r.UserId == userId && r.OtherUserId == otherUserId) ||
                 (r.UserId == otherUserId && r.OtherUserId == userId))
                && r.Status == FriendRelationStatus.Pending, ct);

            if (pendingExists)
                return Conflict("Zaproszenie już istnieje.");

            _db.FriendRelations.Add(new FriendRelation
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                OtherUserId = otherUserId,
                Status = FriendRelationStatus.Pending,
                InitiatorUserId = userId,
                CreatedAt = DateTime.UtcNow
            });

            _db.FriendRelations.Add(new FriendRelation
            {
                Id = Guid.NewGuid(),
                UserId = otherUserId,
                OtherUserId = userId,
                Status = FriendRelationStatus.Pending,
                InitiatorUserId = userId,
                CreatedAt = DateTime.UtcNow
            });

            await _db.SaveChangesAsync(ct);
            return Ok("Zaproszenie wysłane.");
        }


        [HttpGet("requests/incoming")]
        public async Task<ActionResult<IEnumerable<FriendRequestDto>>> GetIncomingRequests(CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var incoming = await _db.FriendRelations
                .AsNoTracking()
                .Where(r => r.UserId == userId
                            && r.Status == FriendRelationStatus.Pending
                            && r.InitiatorUserId == r.OtherUserId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync(ct);

            var ids = incoming.Select(r => r.OtherUserId).Distinct().ToList();
            var nameMap = await MapUserNamesAsync(ids, ct);

            var dto = incoming.Select(r => new FriendRequestDto
            {
                UserId = r.OtherUserId,
                UserName = nameMap.TryGetValue(r.OtherUserId, out var n) ? n : null,
                CreatedAt = r.CreatedAt
            }).ToList();

            return Ok(dto);
        }

        [HttpGet("requests/outgoing")]
        public async Task<ActionResult<IEnumerable<FriendRequestDto>>> GetOutgoingRequests(CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var outgoing = await _db.FriendRelations
                .AsNoTracking()
                .Where(r => r.UserId == userId
                            && r.Status == FriendRelationStatus.Pending
                            && r.InitiatorUserId == userId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync(ct);

            var ids = outgoing.Select(r => r.OtherUserId).Distinct().ToList();
            var nameMap = await MapUserNamesAsync(ids, ct);

            var dto = outgoing.Select(r => new FriendRequestDto
            {
                UserId = r.OtherUserId,
                UserName = nameMap.TryGetValue(r.OtherUserId, out var n) ? n : null,
                CreatedAt = r.CreatedAt
            }).ToList();

            return Ok(dto);
        }


        [HttpPost("requests/{otherUserId}/accept")]
        public async Task<IActionResult> AcceptRequest(string otherUserId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            if (await AnyBlockBetweenAsync(userId, otherUserId, ct))
                return Conflict("Relacja jest zablokowana.");

            var incoming = await _db.FriendRelations.FirstOrDefaultAsync(r =>
                r.UserId == userId &&
                r.OtherUserId == otherUserId &&
                r.Status == FriendRelationStatus.Pending &&
                r.InitiatorUserId == otherUserId, ct);

            if (incoming == null)
                return NotFound("Brak zaproszenia do akceptacji.");

            var outgoing = await _db.FriendRelations.FirstOrDefaultAsync(r =>
                r.UserId == otherUserId &&
                r.OtherUserId == userId &&
                r.Status == FriendRelationStatus.Pending &&
                r.InitiatorUserId == otherUserId, ct);

            incoming.Status = FriendRelationStatus.Accepted;
            incoming.UpdatedAt = DateTime.UtcNow;

            if (outgoing != null)
            {
                outgoing.Status = FriendRelationStatus.Accepted;
                outgoing.UpdatedAt = DateTime.UtcNow;
            }
            else
            {
                _db.FriendRelations.Add(new FriendRelation
                {
                    Id = Guid.NewGuid(),
                    UserId = otherUserId,
                    OtherUserId = userId,
                    Status = FriendRelationStatus.Accepted,
                    InitiatorUserId = incoming.InitiatorUserId,
                    CreatedAt = DateTime.UtcNow
                });
            }

            await _db.SaveChangesAsync(ct);
            return Ok("Zaproszenie zaakceptowane.");
        }


        [HttpDelete("requests/{otherUserId}")]
        public async Task<IActionResult> RejectRequest(string otherUserId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var incoming = await _db.FriendRelations.FirstOrDefaultAsync(r =>
                r.UserId == userId &&
                r.OtherUserId == otherUserId &&
                r.Status == FriendRelationStatus.Pending &&
                r.InitiatorUserId == otherUserId, ct);

            if (incoming == null)
                return NotFound("Brak zaproszenia do odrzucenia.");

            var outgoing = await _db.FriendRelations.FirstOrDefaultAsync(r =>
                r.UserId == otherUserId &&
                r.OtherUserId == userId &&
                r.Status == FriendRelationStatus.Pending &&
                r.InitiatorUserId == otherUserId, ct);

            _db.FriendRelations.Remove(incoming);
            if (outgoing != null) _db.FriendRelations.Remove(outgoing);

            await _db.SaveChangesAsync(ct);
            return NoContent();
        }


        [HttpDelete("requests/{otherUserId}/cancel")]
        public async Task<IActionResult> CancelOutgoingRequest(string otherUserId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var outgoing = await _db.FriendRelations.FirstOrDefaultAsync(r =>
                r.UserId == userId &&
                r.OtherUserId == otherUserId &&
                r.Status == FriendRelationStatus.Pending &&
                r.InitiatorUserId == userId, ct);

            if (outgoing == null)
                return NotFound("Brak zaproszenia do anulowania.");

            var incoming = await _db.FriendRelations.FirstOrDefaultAsync(r =>
                r.UserId == otherUserId &&
                r.OtherUserId == userId &&
                r.Status == FriendRelationStatus.Pending &&
                r.InitiatorUserId == userId, ct);

            _db.FriendRelations.Remove(outgoing);
            if (incoming != null) _db.FriendRelations.Remove(incoming);

            await _db.SaveChangesAsync(ct);
            return NoContent();
        }


        [HttpDelete("{otherUserId}")]
        public async Task<IActionResult> Remove(string otherUserId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var rel1 = await _db.FriendRelations.FirstOrDefaultAsync(r => r.UserId == userId && r.OtherUserId == otherUserId, ct);
            var rel2 = await _db.FriendRelations.FirstOrDefaultAsync(r => r.UserId == otherUserId && r.OtherUserId == userId, ct);

            if (rel1 == null && rel2 == null)
                return NotFound();

            if (rel1 != null) _db.FriendRelations.Remove(rel1);
            if (rel2 != null) _db.FriendRelations.Remove(rel2);

            await _db.SaveChangesAsync(ct);
            return NoContent();
        }


        [HttpPost("{otherUserId}/block")]
        public async Task<IActionResult> Block(string otherUserId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var rel = await _db.FriendRelations.FirstOrDefaultAsync(r => r.UserId == userId && r.OtherUserId == otherUserId, ct);
            if (rel == null)
            {
                rel = new FriendRelation
                {
                    Id = Guid.NewGuid(),
                    UserId = userId,
                    OtherUserId = otherUserId,
                    Status = FriendRelationStatus.Blocked,
                    InitiatorUserId = userId,
                    CreatedAt = DateTime.UtcNow
                };
                _db.FriendRelations.Add(rel);
            }
            else
            {
                rel.Status = FriendRelationStatus.Blocked;
                rel.UpdatedAt = DateTime.UtcNow;
            }


            var reverse = await _db.FriendRelations.FirstOrDefaultAsync(r => r.UserId == otherUserId && r.OtherUserId == userId, ct);
            if (reverse != null)
                _db.FriendRelations.Remove(reverse);

            await _db.SaveChangesAsync(ct);
            return Ok("Użytkownik zablokowany.");
        }


        [HttpPost("{otherUserId}/unblock")]
        public async Task<IActionResult> Unblock(string otherUserId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var rel = await _db.FriendRelations.FirstOrDefaultAsync(r =>
                r.UserId == userId &&
                r.OtherUserId == otherUserId &&
                r.Status == FriendRelationStatus.Blocked, ct);

            if (rel == null)
                return NotFound("Brak blokady do zdjęcia.");

            _db.FriendRelations.Remove(rel);
            await _db.SaveChangesAsync(ct);

            return Ok("Blokada zdjęta.");
        }


        [HttpGet("feed")]
        public async Task<ActionResult<IEnumerable<ActivityDto>>> GetFriendsFeed([FromQuery] int take = 50, CancellationToken ct = default)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            take = Math.Clamp(take, 1, 200);

            var friendIds = await _db.FriendRelations
                .AsNoTracking()
                .Where(r => r.UserId == userId && r.Status == FriendRelationStatus.Accepted)
                .Select(r => r.OtherUserId)
                .ToListAsync(ct);

   
            var blocked = await _db.FriendRelations
                .AsNoTracking()
                .Where(r => r.UserId == userId && r.Status == FriendRelationStatus.Blocked)
                .Select(r => r.OtherUserId)
                .ToListAsync(ct);

            friendIds = friendIds.Except(blocked).ToList();

            var activities = await _db.Activities
            .AsNoTracking()
            .Include(a => a.Category)
            .Where(a => friendIds.Contains(a.AuthorId))
            .OrderByDescending(a => a.CreatedAt)
            .Take(take)
            .ToListAsync(ct);


            var authorIds = activities.Select(a => a.AuthorId).Distinct().ToList();
            var nameMap = await MapUserNamesAsync(authorIds, ct);

            var items = activities.Select(a => new ActivityDto
            {
                Id = a.ID,
                Name = a.Name,
                Description = a.Description,
                LengthInKm = a.LengthInKm,
                AuthorId = a.AuthorId,
                AuthorUserName = nameMap.TryGetValue(a.AuthorId, out var n) ? n : null,
                ActivityCategoryId = a.CategoryId,
                CategoryName = a.Category?.Name,
                CreatedAt = a.CreatedAt
            }).ToList();

            return Ok(items);


        }


        [HttpGet("{otherUserId}/activities")]
        public async Task<ActionResult<IEnumerable<ActivityDto>>> GetFriendActivities(string otherUserId, CancellationToken ct)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            if (await AnyBlockBetweenAsync(userId, otherUserId, ct))
                return Forbid();

            var rel = await _db.FriendRelations.AsNoTracking().FirstOrDefaultAsync(r =>
                r.UserId == userId &&
                r.OtherUserId == otherUserId &&
                r.Status == FriendRelationStatus.Accepted, ct);

            if (rel == null)
                return Forbid();

            var items = await _db.Activities
                .AsNoTracking()
                .Include(a => a.Category)
                .Where(a => a.AuthorId == otherUserId)
                .OrderByDescending(a => a.CreatedAt)
                .Select(a => new ActivityDto
                {
                    Id = a.ID,
                    Name = a.Name,
                    Description = a.Description,
                    LengthInKm = a.LengthInKm,
                    AuthorId = a.AuthorId,
                    ActivityCategoryId = a.CategoryId,
                    CategoryName = a.Category != null ? a.Category.Name : null,
                    CreatedAt = a.CreatedAt
                })
                .ToListAsync(ct);

            return Ok(items);
        }
        [HttpGet("search")]
        public async Task<ActionResult<IEnumerable<UserSearchResultDto>>> SearchUsers(
        [FromQuery] string query,
        [FromQuery] int take = 20,
        CancellationToken ct = default)
        {
            var userId = CurrentUserId();
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            if (string.IsNullOrWhiteSpace(query))
                return BadRequest("Query jest wymagane.");

            take = Math.Clamp(take, 1, 50);
            query = query.Trim();


            var users = await _authDb.Users
                .AsNoTracking()
                .Where(u =>
                    u.UserName != null &&
                    u.Id != userId &&
                    u.UserName.Contains(query))
                .OrderBy(u => u.UserName)
                .Take(take)
                .Select(u => new
                {
                    u.Id,
                    u.UserName
                })
                .ToListAsync(ct);

            if (users.Count == 0)
                return Ok(new List<UserSearchResultDto>());

            var ids = users.Select(u => u.Id).ToList();

            var relations = await _db.FriendRelations
                .AsNoTracking()
                .Where(r => r.UserId == userId && ids.Contains(r.OtherUserId))
                .ToListAsync(ct);


            var result = users.Select(u =>
            {
                var rel = relations.FirstOrDefault(r => r.OtherUserId == u.Id);

                return new UserSearchResultDto
                {
                    UserId = u.Id,
                    UserName = u.UserName,
                    RelationStatus = rel?.Status.ToString() ?? "None"
                };
            }).ToList();

            return Ok(result);
        }
    }
}
