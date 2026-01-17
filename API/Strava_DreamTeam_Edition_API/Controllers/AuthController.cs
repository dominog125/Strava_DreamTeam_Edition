using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Strava_DreamTeam_Edition_API.Data;
using Strava_DreamTeam_Edition_API.Models.Domain;
using Strava_DreamTeam_Edition_API.Models.DTO;
using Strava_DreamTeam_Edition_API.Repositories;

namespace Strava_DreamTeam_Edition_API.Controllers
{

        [Route("api/[controller]")]
        [ApiController]
        public class AuthController : ControllerBase
        {
            private readonly UserManager<IdentityUser> userManager;
            private readonly RoleManager<IdentityRole> roleManager;
            private readonly StravaDreamTeamDbContext appDb;
            private readonly ITokenRepository tokenRepository;
            

        public AuthController(
                UserManager<IdentityUser> userManager,
                RoleManager<IdentityRole> roleManager,
                ITokenRepository tokenRepository,
                StravaDreamTeamDbContext appDb)
            {
                this.userManager = userManager;
                this.roleManager = roleManager;
                this.tokenRepository = tokenRepository;
                this.appDb = appDb;
        }

            [HttpPost("Register")]
            public async Task<IActionResult> Register(RegisterRequestDto dto, CancellationToken ct)
            {


                bool isFirstUser = !await userManager.Users.AnyAsync();

                var user = new IdentityUser { UserName = dto.Username, Email = dto.Email };
                var result = await userManager.CreateAsync(user, dto.Password);

                if (!result.Succeeded)
                    return BadRequest(result.Errors);
                     var profileExists = await appDb.UserProfiles
                .AsNoTracking()
                .AnyAsync(p => p.UserId == user.Id, ct);

                if (!profileExists)
                {
                    appDb.UserProfiles.Add(new UserProfile
                    {
                        UserId = user.Id,
                    // opcjonalnie: domyślne wartości
                    // FirstName = null,
                    // LastName = null,
                        UpdatedAt = DateTime.UtcNow
                    });

                    await appDb.SaveChangesAsync(ct);
                }

            if (isFirstUser)
                {
                    await userManager.AddToRoleAsync(user, "Admin");
                }
                else if (dto.Roles != null && dto.Roles.Any())
                {
                    await userManager.AddToRolesAsync(user, dto.Roles);
                }
                else
                {
                    await userManager.AddToRoleAsync(user, "User");
                }

                return Ok("User registered successfully.");
            }

            [HttpPost]
            [Route("Login")]
            public async Task<IActionResult> Login(LoginRequestDto loginRequestDto)
            {
                var user = await userManager.FindByEmailAsync(loginRequestDto.Email);

                if (user != null)
                {
                    var checkPasswordResult = await userManager.CheckPasswordAsync(user, loginRequestDto.Password);

                    if (checkPasswordResult)

                    {
                        if (await userManager.IsLockedOutAsync(user))
                        {
                        // Możesz zwrócić 403 lub 423 Locked – 423 jest czytelne semantycznie
                            return StatusCode(StatusCodes.Status423Locked, "Account is blocked.");
                        }
                    var roles = await userManager.GetRolesAsync(user);

                        if (roles != null)
                        {
                            // Create Token
                            var jwtToken = tokenRepository.CreateJWTToken(user, roles.ToList());

                            var response = new LoginResponseDto
                            {
                                JwtToken = jwtToken,
                                Username = user.UserName

                            };

                            return Ok(response);
                        }
                    }
                }

                return BadRequest("Username or password incorrect");
            }
        }
    }

