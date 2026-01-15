using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Strava_DreamTeam_Edition_API.Data;
using Strava_DreamTeam_Edition_API.Models.Domain;
using Strava_DreamTeam_Edition_API.Models.DTO;

namespace Strava_DreamTeam_Edition_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ActivityCategoriesController : ControllerBase
    {
        private readonly StravaDreamTeamDbContext _db;

        public ActivityCategoriesController(StravaDreamTeamDbContext db)
        {
            _db = db;
        }

        // GET: api/activitycategories
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ActivityCategoryDto>>> GetAll(CancellationToken ct)
        {
            var items = await _db.ActivityCategories
                .AsNoTracking()
                .OrderBy(c => c.Name)
                .Select(c => new ActivityCategoryDto
                {
                    Id = c.ID,
                    Name = c.Name
                })
                .ToListAsync(ct);

            return Ok(items);
        }

        // GET: api/activitycategories/{id}
        [HttpGet("{id:guid}")]
        public async Task<ActionResult<ActivityCategoryDto>> GetById(Guid id, CancellationToken ct)
        {
            var item = await _db.ActivityCategories
                .AsNoTracking()
                .Where(c => c.ID == id)
                .Select(c => new ActivityCategoryDto
                {
                    Id = c.ID,
                    Name = c.Name
                })
                .FirstOrDefaultAsync(ct);

            if (item == null)
                return NotFound();

            return Ok(item);
        }

        // POST: api/activitycategories
        [HttpPost]
        public async Task<ActionResult<ActivityCategoryDto>> Create(
            [FromBody] CreateActivityCategoryRequest request,
            CancellationToken ct)
        {
            if (string.IsNullOrWhiteSpace(request.Name))
                return BadRequest("Name jest wymagane.");

            var exists = await _db.ActivityCategories
                .AsNoTracking()
                .AnyAsync(c => c.Name == request.Name, ct);

            if (exists)
                return Conflict("Kategoria o tej nazwie już istnieje.");

            var entity = new ActivityCategory
            {
                ID = Guid.NewGuid(),
                Name = request.Name.Trim()
            };

            _db.ActivityCategories.Add(entity);
            await _db.SaveChangesAsync(ct);

            var dto = new ActivityCategoryDto
            {
                Id = entity.ID,
                Name = entity.Name
            };

            return CreatedAtAction(nameof(GetById), new { id = dto.Id }, dto);
        }

        // PUT: api/activitycategories/{id}
        [HttpPut("{id:guid}")]
        public async Task<IActionResult> Update(
            Guid id,
            [FromBody] UpdateActivityCategoryRequest request,
            CancellationToken ct)
        {
            if (string.IsNullOrWhiteSpace(request.Name))
                return BadRequest("Name jest wymagane.");

            var entity = await _db.ActivityCategories
                .FirstOrDefaultAsync(c => c.ID == id, ct);

            if (entity == null)
                return NotFound();

            var name = request.Name.Trim();

            var duplicate = await _db.ActivityCategories
                .AsNoTracking()
                .AnyAsync(c => c.ID != id && c.Name == name, ct);

            if (duplicate)
                return Conflict("Kategoria o tej nazwie już istnieje.");

            entity.Name = name;
            await _db.SaveChangesAsync(ct);

            return NoContent();
        }

        // DELETE: api/activitycategories/{id}
        [HttpDelete("{id:guid}")]
        public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
        {
            var entity = await _db.ActivityCategories
                .FirstOrDefaultAsync(c => c.ID == id, ct);

            if (entity == null)
                return NotFound();

        
            var inUse = await _db.Activities
                .AsNoTracking()
                .AnyAsync(a => a.CategoryId == id, ct);

            if (inUse)
                return Conflict("Nie można usunąć kategorii, ponieważ jest używana przez aktywności.");

            _db.ActivityCategories.Remove(entity);
            await _db.SaveChangesAsync(ct);

            return NoContent();
        }
    }
}
