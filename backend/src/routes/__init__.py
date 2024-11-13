from fastapi import APIRouter


router = APIRouter()


# Routes
from .auth import router as auth_router
router.include_router(auth_router, tags=['auth'])

from .admin import router as admin_router
router.include_router(admin_router, tags=['admin'])
