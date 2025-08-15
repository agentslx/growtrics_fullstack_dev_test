

from typing import Optional, Dict, Any
from datetime import datetime

from modules import DocumentDBModule


class UserDocumentDBDataSource:
    def __init__(self, db: DocumentDBModule, collection: str = "users"):
        self.db = db
        self.collection = collection

    async def get_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        docs = await self.db.list_documents(
            self.collection, filters=[("email", "==", email.lower())], limit=1
        )
        return docs[0] if docs else None

    async def get_by_id(self, user_id: str) -> Optional[Dict[str, Any]]:
        return await self.db.get_document(self.collection, user_id)

    async def create(self, data: Dict[str, Any]) -> str:
        return await self.db.create_document(self.collection, data)

    async def update(self, doc_id: str, data: Dict[str, Any]) -> None:
        await self.db.update_document(self.collection, doc_id, data, merge=True)
