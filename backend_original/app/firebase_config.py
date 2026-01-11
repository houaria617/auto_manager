from firebase_admin import messaging


# sends a push notification to a single device
def send_notification(token: str, title: str, body: str) -> bool:
    try:
        # build the message with android and ios specific configs
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            token=token,
            # android specific settings
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(
                    sound='default'
                )
            ),
            # ios specific settings
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(
                        sound='default',
                        badge=1
                    )
                )
            )
        )

        # send and log the result
        response = messaging.send(message)
        print(f"✅ Notification sent successfully: {response}")
        return True

    except messaging.UnregisteredError:
        print(f"❌ Token is invalid or expired: {token[:20]}...")
        return False

    except Exception as e:
        print(f"❌ Error sending notification: {e}")
        return False