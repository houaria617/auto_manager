from firebase_admin import messaging

def send_notification(token: str, title: str, body: str) -> bool:
    """
    Send a push notification to ONE device.
    
    Args:
        token: FCM device token
        title: Notification title
        body: Notification body
    
    Returns:
        True if sent successfully, False otherwise
    """
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            token=token,
            # Android configuration
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(
                    sound='default'
                )
            ),
            # iOS configuration
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(
                        sound='default',
                        badge=1
                    )
                )
            )
        )
        
        response = messaging.send(message)
        print(f"✅ Notification sent successfully: {response}")
        return True
        
    except messaging.UnregisteredError:
        print(f"❌ Token is invalid or expired: {token[:20]}...")
        return False
        
    except Exception as e:
        print(f"❌ Error sending notification: {e}")
        return False