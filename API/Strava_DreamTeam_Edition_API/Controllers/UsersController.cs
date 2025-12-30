using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Strava_DreamTeam_Edition_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {

        [HttpGet]
        public IActionResult GetAllUsers() 
        {
            string[] usersName = new string[] {"Jan","Andrzej","Maciej" };
            
            return Ok(usersName);
        }

    }
}
