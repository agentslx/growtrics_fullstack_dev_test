from fastapi import FastAPI
from dotenv import load_dotenv

from .di import di, init_di  # ensure DI is wired
from .api.controllers.auth_controller import router as auth_router
from .api.controllers.user_controller import router as users_router
from .api.controllers.solve_controller import router as solve_router
from .api.controllers.health_controller import router as health_router
from .api.middlewares.auth_middleware import AuthMiddleware


def create_app() -> FastAPI:
    load_dotenv()
    # Enable FastAPI's built-in docs & OpenAPI
    app = FastAPI(title="Mini Solver API")
    # Register middlewares
    app.add_middleware(AuthMiddleware)
    # init DI synchronously
    init_di()


    # Register shared/system blueprints
    app.include_router(health_router)
    app.include_router(auth_router)
    app.include_router(users_router)
    app.include_router(solve_router)
    return app


app = create_app()

if __name__ == "__main__":
    import uvicorn

    uvicorn.run("services.restful_api_service.main:app", host="0.0.0.0", port=8000, reload=True)
