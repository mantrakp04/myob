from typing import List, Annotated, Optional, Union, Any, Dict
from beanie import Document, Link
from pydantic import BaseModel, Field

from .Users import User

# Role weights - lower number = more privileges
ROLE_WEIGHTS = {
    "SUPERADMIN": -1,
    "OWNER": 0,
    "ADMIN": 1,
    "MEMBER": 2
}

class WorkspaceMember(BaseModel):
    user: Link[User]
    role_weight: int = Field(ge=0, default=ROLE_WEIGHTS["MEMBER"])  # Ensures non-negative
    
class Workspace(Document):
    name: str
    description: str = None
    members: List[WorkspaceMember]
    is_active: bool = True
    is_public: bool = False
    
    class Settings:
        name = "workspaces"
    
    @property
    def owner(self) -> Optional[User]:
        """Get the workspace owner"""
        for member in self.members:
            if member.role_weight == ROLE_WEIGHTS["OWNER"]:
                return member.user
        return None
    
    @property
    def can_edit(self, user: User) -> bool:
        """Check if user can edit the workspace"""
        for member in self.members:
            if member.user == user:
                return member.role_weight <= ROLE_WEIGHTS["MEMBER"]
        return False
