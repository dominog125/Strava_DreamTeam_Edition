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
    [Route("api/[controller]")]
    public class ActivitiesController : ControllerBase
    {
        private readonly StravaDreamTeamDbContext _db;
        private readonly StravaDreamTeamAuthDbContext _authDb;

        public ActivitiesController(StravaDreamTeamDbContext db, StravaDreamTeamAuthDbContext authDb)
        {
            _db = db;
            _authDb = authDb;
        }

        // GET: api/activities
        // User: tylko swoje + filtry + sortowanie
        // Admin: wszystkie + opcjonalny filtr po nazwie użytkownika + filtry + sortowanie
        [Authorize(Roles = "User,Admin")]
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ActivityDto>>> GetAll([FromQuery] ActivityQuery query, CancellationToken ct)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var isAdmin = User.IsInRole("Admin");

            IQueryable<Activity> q = _db.Activities
                .AsNoTracking()
                .Include(a => a.Category);

            // USER: zawsze tylko swoje
            if (!isAdmin)
            {
                q = q.Where(a => a.AuthorId == userId);
            }
            else
            {
                // ADMIN: filtr po nazwie użytkownika (UserName), NIE po Id
                if (!string.IsNullOrWhiteSpace(query.AuthorUserName))
                {
                    var username = query.AuthorUserName.Trim();

                    var foundUserId = await _authDb.Users
                        .AsNoTracking()
                        .Where(u => u.UserName == username)
                        .Select(u => u.Id)
                        .FirstOrDefaultAsync(ct);

                    if (string.IsNullOrWhiteSpace(foundUserId))
                        return Ok(new List<ActivityDto>());

                    q = q.Where(a => a.AuthorId == foundUserId);
                }
            }

            // Filtry
            if (query.MinDistanceKm.HasValue)
                q = q.Where(a => a.LengthInKm >= query.MinDistanceKm.Value);

            if (query.MaxDistanceKm.HasValue)
                q = q.Where(a => a.LengthInKm <= query.MaxDistanceKm.Value);

            if (query.CreatedFrom.HasValue)
                q = q.Where(a => a.CreatedAt >= query.CreatedFrom.Value);

            if (query.CreatedTo.HasValue)
                q = q.Where(a => a.CreatedAt <= query.CreatedTo.Value);

            if (query.ActivityCategoryId.HasValue)
                q = q.Where(a => a.CategoryId == query.ActivityCategoryId.Value);

            // Sortowanie (domyślnie: najnowsze)
            var sortBy = (query.SortBy ?? "date").Trim().ToLowerInvariant();
            var sortDir = (query.SortDir ?? "desc").Trim().ToLowerInvariant();
            var asc = sortDir == "asc";

            q = sortBy switch
            {
                "distance" => asc ? q.OrderBy(a => a.LengthInKm) : q.OrderByDescending(a => a.LengthInKm),
                "type" => asc ? q.OrderBy(a => a.Category.Name) : q.OrderByDescending(a => a.Category.Name),
                "date" or _ => asc ? q.OrderBy(a => a.CreatedAt) : q.OrderByDescending(a => a.CreatedAt)
            };

            var items = await q
                .Select(a => new ActivityDto
                {
                    Id = a.ID,
                    Name = a.Name,
                    Description = a.Description,
                    LengthInKm = a.LengthInKm,
                    PaceMinPerKm = a.PaceMinPerKm,
                    SpeedKmPerHour = a.SpeedKmPerHour,
                    ActiveSeconds = a.ActiveSeconds,
                    AuthorId = a.AuthorId,
                    ActivityCategoryId = a.CategoryId,
                    CategoryName = a.Category != null ? a.Category.Name : null,
                    CreatedAt = a.CreatedAt
                })
                .ToListAsync(ct);

            return Ok(items);
        }

        // GET: api/activities/{id}
        // User: tylko swoje
        // Admin: każde
        [Authorize(Roles = "User,Admin")]
        [HttpGet("{id:guid}")]
        public async Task<ActionResult<ActivityDto>> GetById(Guid id, CancellationToken ct)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var isAdmin = User.IsInRole("Admin");

            IQueryable<Activity> q = _db.Activities
                .AsNoTracking()
                .Include(a => a.Category)
                .Where(a => a.ID == id);

            if (!isAdmin)
                q = q.Where(a => a.AuthorId == userId);

            var item = await q
                .Select(a => new ActivityDto
                {
                    Id = a.ID,
                    Name = a.Name,
                    Description = a.Description,
                    LengthInKm = a.LengthInKm,
                    PaceMinPerKm = a.PaceMinPerKm,
                    SpeedKmPerHour = a.SpeedKmPerHour,
                    ActiveSeconds = a.ActiveSeconds,
                    AuthorId = a.AuthorId,
                    ActivityCategoryId = a.CategoryId,
                    CategoryName = a.Category != null ? a.Category.Name : null,
                    CreatedAt = a.CreatedAt
                })
                .FirstOrDefaultAsync(ct);

            if (item == null)
                return NotFound();

            return Ok(item);
        }
        [Authorize(Roles = "User,Admin")]
        [HttpGet("{id:guid}/photos/{type}")]
        public async Task<IActionResult> GetPhoto(Guid id, string type, CancellationToken ct)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            var isAdmin = User.IsInRole("Admin");

            var item = await _db.Activities
                .AsNoTracking()
                .Where(a => a.ID == id)
                .Select(a => new
                {
                    a.AuthorId,
                    Photo = type == "use" ? a.UsePhoto : a.MapPhoto,
                    ContentType = type == "use" ? a.UsePhotoContentType : a.MapPhotoContentType
                })
                .FirstOrDefaultAsync(ct);

            if (item == null || item.Photo == null) return NotFound();
            if (!isAdmin && item.AuthorId != userId) return Forbid();

            return File(item.Photo, item.ContentType!);
        }


        // POST: api/activities
        // AuthorId zawsze z tokena
        [Authorize(Roles = "User,Admin")]
        [HttpPost]
        public async Task<ActionResult<ActivityDto>> Create([FromBody] CreateActivityRequest request, CancellationToken ct)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            if (request.LengthInKm is null)
                return BadRequest("LengthInKm jest wymagane.");

            var categoryExists = await _db.ActivityCategories
                .AsNoTracking()
                .AnyAsync(c => c.ID == request.ActivityCategoryId, ct);

            if (!categoryExists)
                return BadRequest($"ActivityCategoryId '{request.ActivityCategoryId}' nie istnieje.");

            var entity = new Activity
            {
                ID = Guid.NewGuid(),
                Name = request.Name ?? string.Empty,
                Description = request.Description ?? string.Empty,
                LengthInKm = request.LengthInKm.Value,
                PaceMinPerKm = request.PaceMinPerKm,
                SpeedKmPerHour = request.SpeedKmPerHour,
                ActiveSeconds = request.ActiveSeconds,
                AuthorId = userId,
                CategoryId = request.ActivityCategoryId,
                CreatedAt = DateTime.UtcNow
            };

            _db.Activities.Add(entity);
            await _db.SaveChangesAsync(ct);

            var created = await _db.Activities
                .AsNoTracking()
                .Include(a => a.Category)
                .Where(a => a.ID == entity.ID)
                .Select(a => new ActivityDto
                {
                    Id = a.ID,
                    Name = a.Name,
                    Description = a.Description,
                    LengthInKm = a.LengthInKm,
                    PaceMinPerKm = a.PaceMinPerKm,
                    SpeedKmPerHour = a.SpeedKmPerHour,
                    ActiveSeconds = a.ActiveSeconds,
                    AuthorId = a.AuthorId,
                    ActivityCategoryId = a.CategoryId,
                    CategoryName = a.Category != null ? a.Category.Name : null,
                    CreatedAt = a.CreatedAt
                })
                .FirstAsync(ct);

            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [Authorize(Roles = "User,Admin")]
        [HttpPost("{id:guid}/photos")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadPhotos(Guid id, [FromForm] UploadActivityPhotosRequest req, CancellationToken ct)
        {
            var entity = await _db.Activities.FirstOrDefaultAsync(a => a.ID == id, ct);
            if (entity == null) return NotFound();

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var isAdmin = User.IsInRole("Admin");
            if (!isAdmin && entity.AuthorId != userId) return Forbid();

            if (req.UsePhoto != null)
            {
                using var ms = new MemoryStream();
                await req.UsePhoto.CopyToAsync(ms, ct);
                entity.UsePhoto = ms.ToArray();
                entity.UsePhotoContentType = req.UsePhoto.ContentType;
            }

            if (req.MapPhoto != null)
            {
                using var ms = new MemoryStream();
                await req.MapPhoto.CopyToAsync(ms, ct);
                entity.MapPhoto = ms.ToArray();
                entity.MapPhotoContentType = req.MapPhoto.ContentType;
            }

            await _db.SaveChangesAsync(ct);
            return NoContent();
        }

        [Authorize(Roles = "User,Admin")]
        [HttpPost("with-photos")]
        [Consumes("multipart/form-data")]
        [RequestSizeLimit(15 * 1024 * 1024)]
        public async Task<ActionResult<ActivityDto>> CreateWithPhotos([FromForm] CreateActivityWithPhotosRequest request,CancellationToken ct)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            if (request.LengthInKm is null)
                return BadRequest("LengthInKm jest wymagane.");

            var categoryExists = await _db.ActivityCategories
                .AsNoTracking()
                .AnyAsync(c => c.ID == request.ActivityCategoryId, ct);

            if (!categoryExists)
                return BadRequest($"ActivityCategoryId '{request.ActivityCategoryId}' nie istnieje.");

            var entity = new Activity
            {
                ID = Guid.NewGuid(),
                Name = request.Name ?? string.Empty,
                Description = request.Description ?? string.Empty,
                LengthInKm = request.LengthInKm.Value,
                PaceMinPerKm = request.PaceMinPerKm,
                SpeedKmPerHour = request.SpeedKmPerHour,
                ActiveSeconds = request.ActiveSeconds,
                AuthorId = userId,
                CategoryId = request.ActivityCategoryId,
                CreatedAt = DateTime.UtcNow
            };

            // Minimalna walidacja zdjęć + zapis do BLOB
            const long maxBytes = 5 * 1024 * 1024;

            if (request.UsePhoto != null)
            {
                if (request.UsePhoto.Length <= 0 || request.UsePhoto.Length > maxBytes) return BadRequest("UsePhoto: max 5MB.");
                if (!request.UsePhoto.ContentType.StartsWith("image/")) return BadRequest("UsePhoto: musi być obrazem.");

                await using var ms = new MemoryStream();
                await request.UsePhoto.CopyToAsync(ms, ct);
                entity.UsePhoto = ms.ToArray();
                entity.UsePhotoContentType = request.UsePhoto.ContentType;
            }

            if (request.MapPhoto != null)
            {
                if (request.MapPhoto.Length <= 0 || request.MapPhoto.Length > maxBytes) return BadRequest("MapPhoto: max 5MB.");
                if (!request.MapPhoto.ContentType.StartsWith("image/")) return BadRequest("MapPhoto: musi być obrazem.");

                await using var ms = new MemoryStream();
                await request.MapPhoto.CopyToAsync(ms, ct);
                entity.MapPhoto = ms.ToArray();
                entity.MapPhotoContentType = request.MapPhoto.ContentType;
            }

            _db.Activities.Add(entity);
            await _db.SaveChangesAsync(ct);

            // Zwróć DTO (bez blobów)
            var created = await _db.Activities
                .AsNoTracking()
                .Include(a => a.Category)
                .Where(a => a.ID == entity.ID)
                .Select(a => new ActivityDto
                {
                    Id = a.ID,
                    Name = a.Name,
                    Description = a.Description,
                    LengthInKm = a.LengthInKm,
                    PaceMinPerKm = a.PaceMinPerKm,
                    SpeedKmPerHour = a.SpeedKmPerHour,
                    AuthorId = a.AuthorId,
                    ActivityCategoryId = a.CategoryId,
                    CategoryName = a.Category != null ? a.Category.Name : null,
                    CreatedAt = a.CreatedAt,
  
                })
                .FirstAsync(ct);

            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }



        // PUT: api/activities/{id}
        // User: tylko swoje
        // Admin: każde
        [Authorize(Roles = "User,Admin")]
        [HttpPut("{id:guid}")]
        public async Task<IActionResult> Update(Guid id, [FromBody] UpdateActivityRequest request, CancellationToken ct)
        {
            var entity = await _db.Activities.FirstOrDefaultAsync(a => a.ID == id, ct);
            if (entity == null)
                return NotFound();

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            if (!isAdmin && entity.AuthorId != userId)
                return Forbid();

            var categoryExists = await _db.ActivityCategories
                .AsNoTracking()
                .AnyAsync(c => c.ID == request.ActivityCategoryId, ct);

            if (!categoryExists)
                return BadRequest($"ActivityCategoryId '{request.ActivityCategoryId}' nie istnieje.");

            entity.Name = request.Name ?? entity.Name;
            entity.Description = request.Description ?? entity.Description;
            entity.LengthInKm = request.LengthInKm ?? entity.LengthInKm;
            entity.PaceMinPerKm = request.PaceMinPerKm ?? entity.PaceMinPerKm;
            entity.SpeedKmPerHour = request.SpeedKmPerHour ?? entity.SpeedKmPerHour;
            entity.ActiveSeconds = request.ActiveSeconds ?? entity.ActiveSeconds;
            entity.CategoryId = request.ActivityCategoryId;


            await _db.SaveChangesAsync(ct);
            return NoContent();
        }

        // DELETE: api/activities/{id}
        // User: tylko swoje
        // Admin: każde
        [Authorize(Roles = "User,Admin")]
        [HttpDelete("{id:guid}")]
        public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
        {
            var entity = await _db.Activities.FirstOrDefaultAsync(a => a.ID == id, ct);
            if (entity == null)
                return NotFound();

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            if (!isAdmin && entity.AuthorId != userId)
                return Forbid();

            _db.Activities.Remove(entity);
            await _db.SaveChangesAsync(ct);

            return NoContent();
        }

        [Authorize(Roles = "User,Admin")]
        [HttpGet("{id:guid}/photos/use")]
        public async Task<IActionResult> GetUsePhoto(Guid id, CancellationToken ct)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var isAdmin = User.IsInRole("Admin");

            var item = await _db.Activities
                .AsNoTracking()
                .Where(a => a.ID == id)
                .Select(a => new { a.AuthorId, a.UsePhoto, a.UsePhotoContentType })
                .FirstOrDefaultAsync(ct);

            if (item == null || item.UsePhoto == null) return NotFound();
            if (!isAdmin && item.AuthorId != userId) return Forbid();

            return File(item.UsePhoto, item.UsePhotoContentType!);
        }

        [Authorize(Roles = "User,Admin")]
        [HttpDelete("{id:guid}/photos/use")]
        public async Task<IActionResult> DeleteUsePhoto(Guid id, CancellationToken ct)
        {
            var entity = await _db.Activities.FirstOrDefaultAsync(a => a.ID == id, ct);
            if (entity == null)
                return NotFound();

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            if (!isAdmin && entity.AuthorId != userId)
                return Forbid();

            if (entity.UsePhoto == null)
                return NotFound();

            entity.UsePhoto = null;
            entity.UsePhotoContentType = null;

            await _db.SaveChangesAsync(ct);
            return NoContent();
        }


        [Authorize(Roles = "User,Admin")]
        [HttpGet("{id:guid}/photos/map")]
        public async Task<IActionResult> GetMapPhoto(Guid id, CancellationToken ct)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var isAdmin = User.IsInRole("Admin");

            var item = await _db.Activities
                .AsNoTracking()
                .Where(a => a.ID == id)
                .Select(a => new { a.AuthorId, a.MapPhoto, a.MapPhotoContentType })
                .FirstOrDefaultAsync(ct);

            if (item == null || item.MapPhoto == null) return NotFound();
            if (!isAdmin && item.AuthorId != userId) return Forbid();

            return File(item.MapPhoto, item.MapPhotoContentType!);
        }

        [Authorize(Roles = "User,Admin")]
        [HttpGet("{id:guid}/with-photos")]
        public async Task<ActionResult<ActivityWithPhotosDto>> GetByIdWithPhotos(Guid id, CancellationToken ct)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var isAdmin = User.IsInRole("Admin");

            var item = await _db.Activities
                .AsNoTracking()
                .Include(a => a.Category)
                .Where(a => a.ID == id)
                .Select(a => new
                {
                    a.ID,
                    a.Name,
                    a.Description,
                    a.LengthInKm,
                    a.PaceMinPerKm,
                    a.SpeedKmPerHour,
                    a.ActiveSeconds,
                    a.AuthorId,
                    a.CategoryId,
                    CategoryName = a.Category != null ? a.Category.Name : null,
                    a.CreatedAt,

                    a.UsePhoto,
                    a.UsePhotoContentType,
                    a.MapPhoto,
                    a.MapPhotoContentType
                })
                .FirstOrDefaultAsync(ct);

            if (item == null)
                return NotFound();

            if (!isAdmin && item.AuthorId != userId)
                return Forbid();

            var dto = new ActivityWithPhotosDto
            {
                Id = item.ID,
                Name = item.Name,
                Description = item.Description,
                LengthInKm = item.LengthInKm,
                PaceMinPerKm = item.PaceMinPerKm,
                SpeedKmPerHour = item.SpeedKmPerHour,
                AuthorId = item.AuthorId,
                ActivityCategoryId = item.CategoryId,
                CategoryName = item.CategoryName,
                CreatedAt = item.CreatedAt,

                UsePhotoBase64 = item.UsePhoto != null ? Convert.ToBase64String(item.UsePhoto) : null,
                UsePhotoContentType = item.UsePhotoContentType,

                MapPhotoBase64 = item.MapPhoto != null ? Convert.ToBase64String(item.MapPhoto) : null,
                MapPhotoContentType = item.MapPhotoContentType
            };

            return Ok(dto);
        }


        [Authorize]
        [HttpPost("{id:guid}/gps")]
        public async Task<IActionResult> AddGps(Guid id, AddGpsPointRequestDto dto)
        {
            _db.activityGpsPoints.Add(new ActivityGpsPoint
            {
                Id = Guid.NewGuid(),
                ActivityId = id,
                Latitude = dto.Latitude,
                Longitude = dto.Longitude,
                Timestamp = DateTime.UtcNow
            });

            await _db.SaveChangesAsync();
            return NoContent();
        }


        [Authorize]
        [HttpGet("{id:guid}/gps")]
        public async Task<ActionResult<IEnumerable<ActivityGpsPoint>>> GetGps(Guid id)
        {
            var points = await _db.activityGpsPoints
                .AsNoTracking()
                .Where(p => p.ActivityId == id)
                .OrderBy(p => p.Timestamp)
                .Select(p => new ActivityGpsPoint
                {
                    Id = p.Id,
                    Latitude = p.Latitude,
                    Longitude = p.Longitude,
                    Timestamp = p.Timestamp
                })
                .ToListAsync();

            return Ok(points);
        }
    }
}
