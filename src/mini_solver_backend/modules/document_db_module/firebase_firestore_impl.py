import os

import asyncio
import firebase_admin
from typing import Any, Dict, List, Optional, Sequence, Tuple, Callable
from google.oauth2 import service_account
from google.cloud import firestore


from .document_db_module import DocumentDBModule, Filter, OrderBy


class FirebaseFirestoreModule(DocumentDBModule):
    """Firebase Firestore implementation of DocumentDBModule.

    Authentication options:
    - Provide path to service account json via FIREBASE_SERVICE_ACCOUNT_FILE
    - Or rely on Application Default Credentials (GOOGLE_APPLICATION_CREDENTIALS)
    - Or if running on GCP, attached service account
    """

    def __init__(self, project_id: Optional[str] = None):
        cred = service_account.Credentials.from_service_account_file(
            os.getenv("FIREBASE_SERVICE_ACCOUNT_FILE", "service_account.json")
        )
        self.firebase_app = firebase_admin.initialize_app(cred)
        self.firestore_db = firestore.client()

    # Firestore client is synchronous. Use asyncio.to_thread to avoid blocking.
    async def create_document(
        self, collection: str, data: Dict[str, Any], doc_id: Optional[str] = None
    ) -> str:
        def _inner():
            col_ref = self.firestore_db.collection(collection)
            # Create with given id or auto-id, then set
            doc_ref = col_ref.document(doc_id) if doc_id else col_ref.document()
            doc_ref.set(data)
            return doc_ref.id

        return await asyncio.to_thread(_inner)

    async def get_document(self, collection: str, doc_id: str) -> Optional[Dict[str, Any]]:
        def _inner():
            doc = self.firestore_db.collection(collection).document(doc_id).get()
            if not doc.exists:
                return None
            d = doc.to_dict() or {}
            d["id"] = doc.id
            return d

        return await asyncio.to_thread(_inner)

    async def update_document(
        self, collection: str, doc_id: str, data: Dict[str, Any], merge: bool = True
    ) -> None:
        def _inner():
            ref = self.firestore_db.collection(collection).document(doc_id)
            if merge:
                ref.set(data, merge=True)
            else:
                ref.set(data)

        return await asyncio.to_thread(_inner)

    async def delete_document(self, collection: str, doc_id: str) -> None:
        def _inner():
            self.firestore_db.collection(collection).document(doc_id).delete()

        return await asyncio.to_thread(_inner)

    async def list_documents(
        self,
        collection: str,
        filters: Optional[Sequence[Filter]] = None,
        order_by: Optional[OrderBy] = None,
        limit: Optional[int] = None,
    ) -> List[Dict[str, Any]]:
        def _inner():
            query = self.firestore_db.collection(collection)
            if filters:
                for field, op, value in filters:
                    query = query.where(field, op, value)
            if order_by:
                field, direction = order_by
                query = query.order_by(field, direction=firestore.Query.DESCENDING if direction == "desc" else firestore.Query.ASCENDING)
            if limit:
                query = query.limit(limit)
            docs = query.stream()
            out: List[Dict[str, Any]] = []
            for doc in docs:
                d = doc.to_dict() or {}
                d["id"] = doc.id
                out.append(d)
            return out

        return await asyncio.to_thread(_inner)

    async def run_transaction(self, func: Callable[[Any], Any]) -> Any:
        def _inner():
            @firestore.transactional
            def txn_runner(transaction):
                return func(transaction)

            transaction = self.firestore_db.transaction()
            return txn_runner(transaction)

        return await asyncio.to_thread(_inner)
