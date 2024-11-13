from fastapi import FastAPI
from dotenv import load_dotenv
from beanie import init_beanie
from contextlib import asynccontextmanager
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware

from .routes import router
from .services.db.schemas import User, Workspace
from .services.db import DATABASE
from .utils import logger

@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_beanie(
        database=DATABASE.a_db,
        document_models=[
            User,
            Workspace
        ],
    )
    yield

app = FastAPI(lifespan=lifespan)
app.include_router(router, prefix='/api')
templates = Jinja2Templates(directory="templates")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Corrected here
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

@app.get("/health")
async def health():
    return {"status": "OK"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
