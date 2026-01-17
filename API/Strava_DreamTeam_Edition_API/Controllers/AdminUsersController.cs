using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Strava_DreamTeam_Edition_API.Controllers
{
    [ApiController]
    [Route("api/admin/users")]
    [Authorize(Roles = "Admin")]
    public class AdminUsersController : ControllerBase
    {
        private readonly UserManager<IdentityUser> _userManager;

        public AdminUsersController(UserManager<IdentityUser> userManager)
        {
            _userManager = userManager;
        }


        [HttpPost("{userId}/block")]
        public async Task<IActionResult> BlockUser(string userId, [FromBody] BlockUserRequest? request, CancellationToken ct)
        {
            var user = await _userManager.Users.FirstOrDefaultAsync(u => u.Id == userId, ct);
            if (user == null) return NotFound("User not found.");

            var enableRes = await _userManager.SetLockoutEnabledAsync(user, true);
            if (!enableRes.Succeeded) return BadRequest(enableRes.Errors);

            DateTimeOffset lockoutEnd;
            if (request?.Minutes is > 0)
            {
                lockoutEnd = DateTimeOffset.UtcNow.AddMinutes(request.Minutes.Value);
            }
            else
            {
                lockoutEnd = DateTimeOffset.MaxValue;
            }

            var res = await _userManager.SetLockoutEndDateAsync(user, lockoutEnd);
            if (!res.Succeeded) return BadRequest(res.Errors);

            return NoContent();
        }

        [HttpPost("{userId}/unblock")]
        public async Task<IActionResult> UnblockUser(string userId, CancellationToken ct)
        {
            var user = await _userManager.Users.FirstOrDefaultAsync(u => u.Id == userId, ct);
            if (user == null) return NotFound("User not found.");

            var res = await _userManager.SetLockoutEndDateAsync(user, null);
            if (!res.Succeeded) return BadRequest(res.Errors);

            return NoContent();
        }

        [HttpGet("blocked")]
        public async Task<ActionResult<IEnumerable<BlockedUserDto>>> GetBlockedUsers(CancellationToken ct)
        {
            var now = DateTimeOffset.UtcNow;

            var blocked = await _userManager.Users
                .AsNoTracking()
                .Where(u => u.LockoutEnd.HasValue && u.LockoutEnd.Value > now)
                .OrderBy(u => u.UserName)
                .Select(u => new BlockedUserDto
                {
                    UserId = u.Id,
                    UserName = u.UserName,
                    Email = u.Email,
                    LockoutEndUtc = u.LockoutEnd
                })
                .ToListAsync(ct);

            return Ok(blocked);
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<AdminUserDto>>> GetAllUsers(CancellationToken ct)
        {
            var now = DateTimeOffset.UtcNow;

            var users = await _userManager.Users
                .AsNoTracking()
                .OrderBy(u => u.UserName)
                .Select(u => new AdminUserDto
                {
                    UserId = u.Id,
                    UserName = u.UserName,
                    Email = u.Email,
                    IsBlocked = u.LockoutEnd.HasValue && u.LockoutEnd.Value > now,
                    LockoutEndUtc = u.LockoutEnd
                })
                .ToListAsync(ct);

            return Ok(users);
        }

        public class AdminUserDto
        {
            public string UserId { get; set; } = default!;
            public string? UserName { get; set; }
            public string? Email { get; set; }
            public bool IsBlocked { get; set; }
            public DateTimeOffset? LockoutEndUtc { get; set; }
        }
    }


    public class BlockUserRequest
    {
        public int? Minutes { get; set; }
    }

    public class BlockedUserDto
    {
        public string UserId { get; set; } = default!;
        public string? UserName { get; set; }
        public string? Email { get; set; }
        public DateTimeOffset? LockoutEndUtc { get; set; }
    }
}
