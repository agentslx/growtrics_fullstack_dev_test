from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional, Sequence, Tuple, Callable


Filter = Tuple[str, str, Any]
OrderBy = Tuple[str, str]  # (field, 'asc' | 'desc')


class DocumentDBModule(ABC):
    """Abstract interface for a document database module.

    Implementations should provide asynchronous methods for CRUD and query operations
    on schemaless, collection-based document stores (e.g., Firestore).
    """

    @abstractmethod
    async def create_document(
        self,
        collection: str,
        data: Dict[str, Any],
        doc_id: Optional[str] = None,
    ) -> str:
        """Create a document in a collection. Returns the document id."""
        raise NotImplementedError

    @abstractmethod
    async def get_document(self, collection: str, doc_id: str) -> Optional[Dict[str, Any]]:
        """Get a document by id. Returns the document dict including 'id', or None if not found."""
        raise NotImplementedError

    @abstractmethod
    async def update_document(
        self,
        collection: str,
        doc_id: str,
        data: Dict[str, Any],
        merge: bool = True,
    ) -> None:
        """Update (or set) fields on a document."""
        raise NotImplementedError

    @abstractmethod
    async def delete_document(self, collection: str, doc_id: str) -> None:
        """Delete a document by id."""
        raise NotImplementedError

    @abstractmethod
    async def list_documents(
        self,
        collection: str,
        filters: Optional[Sequence[Filter]] = None,
        order_by: Optional[OrderBy] = None,
        limit: Optional[int] = None,
    ) -> List[Dict[str, Any]]:
        """List/query documents in a collection. Returns list of dicts including 'id'."""
        raise NotImplementedError

    @abstractmethod
    async def run_transaction(self, func: Callable[[Any], Any]) -> Any:
        """Run a function inside a DB transaction, returning its result if supported."""
        raise NotImplementedError
