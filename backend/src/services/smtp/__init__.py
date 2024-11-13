import os
from typing import List, Dict, Any

from fastapi_mail import FastMail, ConnectionConfig, MessageSchema
from pydantic import EmailStr

from backend.src.utils import config, logger

mailer = FastMail(ConnectionConfig(
    MAIL_USERNAME=config("MAILER_USERNAME"),
    MAIL_PASSWORD=config("MAILER_PASSWORD"),
    MAIL_PORT=config("MAILER_PORT", cast=int),
    MAIL_SERVER=config("MAILER_SERVER"),
    MAIL_STARTTLS=config("MAILER_TLS", cast=bool),
    MAIL_SSL_TLS=config("MAILER_SSL", cast=bool),
    MAIL_FROM=config("MAILER_FROM"),
    USE_CREDENTIALS=config("MAILER_USE_CREDENTIALS", cast=bool),
))

async def send_email(
    recipients: List[EmailStr],
    subject: str,
    template: str,
    data: Dict[str, Any]
):
    try:
        with open(f'backend/src/services/smtp/templates/{template}.html', 'r') as f:
            html = f.read()
            for key, value in data.items():
                html = html.replace(f'{{{{{key}}}}}', value)
        
        message = MessageSchema(
            recipients=recipients,
            subject=subject,
            body=html,
            subtype="html"
        )
        
        await mailer.send_message(message)
        
        return True
    except Exception as e:
        logger.error(f"Failed to send email: {e}")
        raise ValueError(f"Failed to send email: {e}") from e
