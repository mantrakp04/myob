import os
import logging
from logging.handlers import RotatingFileHandler

from starlette.config import Config

# Setup logging
log_formatter = logging.Formatter(
    "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)

log_file = os.getcwd() + "/.logs/backend.log"
os.makedirs(os.path.dirname(log_file), exist_ok=True)

file_handler = RotatingFileHandler(log_file, maxBytes=10*1024*1024, backupCount=5)
file_handler.setFormatter(log_formatter)

console_handler = logging.StreamHandler()
console_handler.setFormatter(log_formatter)

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.addHandler(file_handler)
logger.addHandler(console_handler)

# Env
config = Config("env/.env")
