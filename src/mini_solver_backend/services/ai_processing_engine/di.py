import os
from kink import di

from modules import (
    LLMModule,
    FileStorageModule,
    MessageQueueModule,
)

from modules.file_storage_module.local_file_storage_impl import LocalFileStorageModule
from modules.message_queue_module.rabbitmq_impl import RabbitMQModule
from modules.llm_module.gemini_llm_module_impl import GeminiLLMModule

from .data.repositories.processing_repository_impl import ProcessingRepositoryImpl
from .domain.repositories.processing_repository import ProcessingRepository
from .domain.usecases.process_request import ProcessRequest


# Configure bindings
async def init_di():
    di[FileStorageModule] = LocalFileStorageModule()
    di[LLMModule] = GeminiLLMModule(model=os.getenv("GEMINI_MODEL", "gemini-2.5-flash"))
    di[MessageQueueModule] = RabbitMQModule()

    # Repository and usecase

    di[ProcessingRepository] = lambda di: ProcessingRepositoryImpl(
        storage=di[FileStorageModule], llm=di[LLMModule], mq=di[MessageQueueModule]
    )

    di[ProcessRequest] = lambda di: ProcessRequest(repo=di[ProcessingRepository])
