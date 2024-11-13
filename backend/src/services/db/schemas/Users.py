from typing import List, Optional

from fastapi_users import schemas
from pydantic import BaseModel, Field
from beanie import Document, PydanticObjectId
from fastapi_users.db import BeanieBaseUser, BaseOAuthAccount

class OAuthAccount(BaseOAuthAccount):
    pass

class UserExtra(BaseModel):
    first_name: Optional[str] = Field(default='')
    last_name: Optional[str] = Field(default='')
    picture: Optional[str] = "https://utfs.io/f/DWnwRLquRPInAo5sM8VOGyBaDm68WZFLw14ugYChqVX9Srtp"
    oauth_accounts: List[OAuthAccount] = Field(default_factory=list)
    workspaces: Optional[List[PydanticObjectId]] = Field(default_factory=list)

class User(BeanieBaseUser, Document, UserExtra):
    pass

class UserRead(schemas.BaseUser[PydanticObjectId], UserExtra):
    pass

class UserCreate(schemas.BaseUserCreate, UserExtra):
    pass

class UserUpdate(schemas.BaseUserUpdate, UserExtra):
    pass
