import pytest
from app import create_app


# creates a test app instance with testing mode enabled
@pytest.fixture
def app():
    app = create_app()
    app.config.update({
        "TESTING": True,
    })
    yield app


# provides a test client for making http requests
@pytest.fixture
def client(app):
    return app.test_client()


# provides a cli runner for testing click commands
@pytest.fixture
def runner(app):
    return app.test_cli_runner()