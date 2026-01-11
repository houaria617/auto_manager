from app import create_app

app = create_app()

# starts the server on all interfaces so other devices can connect
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)