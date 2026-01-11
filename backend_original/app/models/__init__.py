from dataclasses import dataclass, asdict
from typing import Optional

@dataclass
class FCMToken:
    user_id: int  # This is your agency_id
    token: str
    id: Optional[str] = None  # Firestore document ID
    
    def to_dict(self):
        return asdict(self)
from .models import Agency, Client, Car

__all__ = ['Agency', 'Client', 'Car']
