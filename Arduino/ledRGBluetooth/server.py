import firebase_admin
from firebase_admin import credentials, messaging
from flask import Flask, request, jsonify

app = Flask(__name__)

# Ruta al archivo JSON descargado con las credenciales de la cuenta de servicio
cred = credentials.Certificate("C:/Users/Usuario/Downloads/notifs-b6e3c-firebase-adminsdk-j27bf-85f1a18d15.json")
firebase_admin.initialize_app(cred)

@app.route('/send_notification', methods=['POST'])
def send_notification():
    data = request.get_json()
    title = data.get('title')
    body = data.get('body')
    token = data.get('token')

    if not token:
        return jsonify({"message": "Token no proporcionado"}), 400

    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            token=token,
        )

        response = messaging.send(message)
        return jsonify({"message": "Notificación enviada", "response": response}), 200
    except firebase_admin.exceptions.FirebaseError as e:
        return jsonify({"message": "Error al enviar notificación", "details": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
