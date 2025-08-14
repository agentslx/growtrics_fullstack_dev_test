import os
from kink import di

from modules import (
    DocumentDBModule,
    FirebaseFirestoreModule,
    FileStorageModule,
    FirebaseStorageModule,
    LocalFileStorageModule,
    MessageQueueModule,
    RabbitMQModule,
)
from .data.datasources.user_document_db_datasource import UserDocumentDBDataSource
from .data.repositories.user_repository_impl import UserRepositoryImpl
from .domain.repositories.user_repository import UserRepository
from .domain.usecases.register_user import RegisterUser
from .domain.usecases.login_user import LoginUser
from .domain.usecases.refresh_tokens import RefreshTokens
from .domain.usecases.get_user_profile import GetUserProfile
from .domain.repositories.solve_repository import SolveRepository
from .data.repositories.solve_repository_impl import SolveRepositoryImpl
from .domain.usecases.create_and_process_solve_request import CreateAndProcessSolveRequest

def init_di():
    # Modules
    di[DocumentDBModule] = FirebaseFirestoreModule(project_id=os.getenv("FIREBASE_PROJECT_ID"))

    # File storage: prefer local in dev if LOCAL_STORAGE_DIR is set, else Firebase Storage
    if os.getenv("LOCAL_STORAGE_DIR"):
        di[FileStorageModule] = LocalFileStorageModule()
    else:
        di[FileStorageModule] = FirebaseStorageModule()

    # Message queue
    di[MessageQueueModule] = RabbitMQModule()

    # Data sources

    di[UserDocumentDBDataSource] = lambda di: UserDocumentDBDataSource(db=di[DocumentDBModule])

    # Repository

    di[UserRepository] = lambda di: UserRepositoryImpl(ds=di[UserDocumentDBDataSource])
    di[SolveRepository] = lambda di: SolveRepositoryImpl(
        db=di[DocumentDBModule], storage=di[FileStorageModule], mq=di[MessageQueueModule]
    )

    # Use cases

    di[RegisterUser] = lambda di: RegisterUser(repo=di[UserRepository])
    di[LoginUser] = lambda di: LoginUser(repo=di[UserRepository])
    di[RefreshTokens] = lambda di: RefreshTokens(repo=di[UserRepository])
    di[GetUserProfile] = lambda di: GetUserProfile(repo=di[UserRepository])
    di[CreateAndProcessSolveRequest] = lambda di: CreateAndProcessSolveRequest(repo=di[SolveRepository])
