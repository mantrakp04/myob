import os
from typing import *

from pymongo import MongoClient
from motor.motor_asyncio import AsyncIOMotorClient
from fastapi_users.db import BeanieUserDatabase

from backend.src.utils import logger, config
from .schemas.Users import User, OAuthAccount

class Database:
    def __init__(self):
        self.client = MongoClient(config("MONGO_URI"))
        self.a_client = AsyncIOMotorClient(config("MONGO_URI"), uuidRepresentation="standard")
        
        self.db = self.client["dev"]
        self.a_db = self.a_client["dev"]
        
        self.users = self.db["users"]
        self.a_users = self.a_db["users"]
        
        self.workspace = self.db["workspace"]
        self.a_workspace = self.a_db["workspace"]
        
        # Test connection
        # ping client and log the result
        try:
            self.client.admin.command("ping")
            logger.info("Connected to MongoDB")
        except Exception as e:
            logger.error(f"Failed to connect to MongoDB: {e}")
            raise e
    
async def get_user_db():
    yield BeanieUserDatabase(User, OAuthAccount)

DATABASE = Database()