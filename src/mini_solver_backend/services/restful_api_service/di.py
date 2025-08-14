import os
from kink import di

from modules import DocumentDBModule, FirebaseFirestoreModule
from .data.datasources.user_document_db_datasource import UserDocumentDBDataSource
from .data.repositories.user_repository_impl import UserRepositoryImpl
from .domain.repositories.user_repository import UserRepository
from .domain.usecases.register_user import RegisterUser
from .domain.usecases.login_user import LoginUser
from .domain.usecases.refresh_tokens import RefreshTokens
from .domain.usecases.get_user_profile import GetUserProfile

def init_di():
    # Modules
    di[DocumentDBModule] = FirebaseFirestoreModule(project_id=os.getenv("FIREBASE_PROJECT_ID"))

    # Data sources

    di[UserDocumentDBDataSource] = lambda di: UserDocumentDBDataSource(db=di[DocumentDBModule])

    # Repository

    di[UserRepository] = lambda di: UserRepositoryImpl(ds=di[UserDocumentDBDataSource])

    # Use cases

    di[RegisterUser] = lambda di: RegisterUser(repo=di[UserRepository])

    di[LoginUser] = lambda di: LoginUser(repo=di[UserRepository])

    di[RefreshTokens] = lambda di: RefreshTokens(repo=di[UserRepository])

    di[GetUserProfile] = lambda di: GetUserProfile(repo=di[UserRepository])
