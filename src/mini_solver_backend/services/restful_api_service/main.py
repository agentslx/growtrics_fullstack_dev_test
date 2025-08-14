from flask import Flask
from dotenv import load_dotenv

from .di import di, init_di  # ensure DI is wired
from .api.controllers.auth_controller import router as auth_blueprint
from .api.controllers.user_controller import router as users_blueprint
from .api.controllers.docs_controller import router as docs_blueprint
from .api.controllers.health_controller import router as health_blueprint


def create_app() -> Flask:
    load_dotenv()
    app = Flask(__name__)
    # init DI synchronously
    init_di()

    app.register_blueprint(auth_blueprint)
    app.register_blueprint(users_blueprint)

    # Register shared/system blueprints
    app.register_blueprint(docs_blueprint)
    app.register_blueprint(health_blueprint)
    return app


app = create_app()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
