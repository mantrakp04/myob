from typing import Optional, Union, Dict, Any, cast
from datetime import datetime

from beanie import PydanticObjectId
from fastapi.responses import RedirectResponse
from httpx_oauth.clients.google import GoogleOAuth2
from fastapi import APIRouter, Depends, Request, Response
from fastapi_users.authentication import AuthenticationBackend, BearerTransport, JWTStrategy
from fastapi_users import BaseUserManager, InvalidPasswordException, FastAPIUsers
from fastapi_users.db import ObjectIDIDMixin

from backend.src.utils import logging, config
from backend.src.services.smtp import send_email
from backend.src.services.db import DATABASE, get_user_db
from backend.src.services.db.schemas import (
    User,
    UserCreate,
    UserRead,
    UserUpdate,
    Workspace,
    WorkspaceMember,
)
from backend.src.utils import logger

# Configure authentication backend
bearer_transport = BearerTransport(tokenUrl="auth/jwt/login")

def get_jwt_strategy() -> JWTStrategy:
    return JWTStrategy(secret=config("API_SECRET"), lifetime_seconds=3600)

auth_backend = AuthenticationBackend(
    name="jwt",
    transport=bearer_transport,
    get_strategy=get_jwt_strategy,
)

google_oauth_client = GoogleOAuth2(
    client_id=config("GOOGLE_CLIENT_ID"),
    client_secret=config("GOOGLE_CLIENT_SECRET"),
)

class UserManager(ObjectIDIDMixin, BaseUserManager[User, PydanticObjectId]):
    reset_password_token_secret = config("API_SECRET")
    verification_token_secret = config("API_SECRET")
    
    async def validate_password(
        self,
        password: str,
        user: Union[UserCreate, User],
    ) -> None:
        invalid_reason = """Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one digit, and one special character. The password cannot contain the email address and cannot contain spaces."""
        if len(password) < 8 or \
            not any(char.isupper() for char in password) or \
            not any(char.islower() for char in password) or \
            not any(char.isdigit() for char in password) or \
            not any(char in "!@#$%^&*()_+-=[]{};:'\"\\|,.<>/?" for char in password) or \
            user.email.split("@")[0] in password or \
            " " in password:
            raise InvalidPasswordException(invalid_reason)
    
    async def on_after_register(self, user: User, request: Optional[Request] = None):
        try:
            # fill out the user's profile if they signed up with oauth
            if len(user.oauth_accounts) > 0:
                # get the user's google account
                google_account = next(account for account in user.oauth_accounts if account.oauth_name == "google")
                
                # use google public api to get user info
                async with google_oauth_client.get_httpx_client() as client:
                    response = await client.get(
                        "https://people.googleapis.com/v1/people/me",
                        params={"personFields": "names,photos"},
                        headers={**google_oauth_client.request_headers, "Authorization": f"Bearer {google_account.access_token}"},
                    )
                    
                    if response.status_code >= 400:
                        raise ValueError(f"Failed to get user info from Google: {response.json()}")
                    
                    data = cast(Dict[str, Any], response.json())
                    user.first_name = data.get("names", [{}])[0].get("givenName", user.first_name)
                    user.last_name = data.get("names", [{}])[0].get("familyName", user.last_name)
                    user.picture = data.get("photos", [{}])[0].get("url", user.picture)
                    
                    # update user in the database
                    await user.save()
                
            
            # create a workspace for the user
            workspace = Workspace(
                name=f"{user.first_name}'s Workspace",
                description=f"Workspace for {user.first_name} {user.last_name}",
                members=[WorkspaceMember(user=user, role_weight=0)],
            )
            await workspace.insert()
            
            # redirect to verification page
            return RedirectResponse(url=f"{config('FRONTEND_URL')}/verify")
        except Exception as e:
            logging.error(f"Failed to send registration email to {user.email}: {e}")
            raise ValueError(f'Failed to send registration email to {user.email}')
    
    async def on_after_update(self, user: User, update_dict: Dict[str, Any], request: Optional[Request] = None):
        # send email to user with the ip address and timestamp of the update
        await send_email(
            [user.email],
            "Account Update",
            "base",
            {
                "heading": "Account Update",
                "content": f"Your account was updated at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}. If you did not make this change, please contact support immediately."
            }
        )
        return
    
    async def on_after_login(self, user: User, request: Optional[Request] = None, response: Optional[Response] = None):
        # redirect to dashboard
        return RedirectResponse(url=f"{config('FRONTEND_URL')}/dashboard")
    
    async def on_after_request_verify(self, user: User, token: str, request: Optional[Request] = None):
        # send verification email
        await send_email(
            [user.email],
            "Verify Your Email",
            "base",
            {
                "heading": "Verify Your Email",
                "content": f"Click <a href='{config('FRONTEND_URL')}/verify/{token}'>here</a> to verify your email address."
            }
        )
        return
    
    async def on_after_verify(self, user: User, request: Optional[Request] = None):
        # redirect to dashboard
        return RedirectResponse(url=f"{config('FRONTEND_URL')}/dashboard")
    
    async def on_after_forgot_password(self, user: User, token: str, request: Optional[Request] = None):
        # send password reset email
        await send_email(
            [user.email],
            "Reset Your Password",
            "base",
            {
                "heading": "Reset Your Password",
                "content": f"Click <a href='{config('FRONTEND_URL')}/reset-password/{token}'>here</a> to reset your password."
            }
        )
        return
    
    async def on_after_reset_password(self, user: User, request: Optional[Request] = None):
        # send password reset info email
        await send_email(
            [user.email],
            "Password Reset",
            "base",
            {
                "heading": "Password Reset",
                "content": f"Your password was reset at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}. If you did not make this change, please contact support immediately."
            }
        )
    
    async def on_before_delete(self, user: User, request: Optional[Request] = None):
        # remove workspace from the user
        workspace = await Workspace.get_one({"members.user": user.id})
        await workspace.delete()
        return
    
    async def on_after_delete(self, user: User, request: Optional[Request] = None):
        # send email to user with the ip address and timestamp of the deletion
        await send_email(
            [user.email],
            "Account Deletion",
            "base",
            {
                "heading": "Account Deletion",
                "content": f"Your account was deleted at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}. If you did not make this change, please contact support immediately."
            }
        )
        return

async def get_user_manager(user_db=Depends(get_user_db)):
    yield UserManager(user_db)

# Routes
router = APIRouter(prefix='/auth')

fastapi_users = FastAPIUsers[User, PydanticObjectId](
    get_user_manager,
    [auth_backend],
)

router.include_router(
    fastapi_users.get_auth_router(auth_backend, requires_verification=True),
    prefix='/jwt',
    tags=["auth"],
)
router.include_router(
    fastapi_users.get_register_router(UserRead, UserCreate),
    tags=["auth"],
)
router.include_router(
    fastapi_users.get_verify_router(UserRead),
    tags=["auth"],
)
router.include_router(
    fastapi_users.get_reset_password_router(),
    tags=["auth"],
)
router.include_router(
    fastapi_users.get_users_router(UserRead, UserUpdate, requires_verification=True),
    prefix="/users",
    tags=["users"],
)
router.include_router(
    fastapi_users.get_oauth_router(google_oauth_client, auth_backend, config("API_SECRET"), associate_by_email=True, is_verified_by_default=True),
    prefix="/google",
    tags=["auth"],
)
router.include_router(
    fastapi_users.get_oauth_associate_router(google_oauth_client, UserRead, config("API_SECRET")),
    prefix="/associate/google",
    tags=["auth"],
)
