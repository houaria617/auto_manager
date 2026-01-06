from app import create_app

app = create_app()

# NEW (accepts connections from any device on network)
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)