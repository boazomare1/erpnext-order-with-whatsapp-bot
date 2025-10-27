#!/usr/bin/env python3

from flask import Flask, request, jsonify
import json

app = Flask(__name__)

@app.route('/webhook', methods=['GET', 'POST'])
def webhook():
    print("=== WEBHOOK RECEIVED ===")
    print(f"Method: {request.method}")
    print(f"Headers: {dict(request.headers)}")
    print(f"Args: {dict(request.args)}")
    
    if request.method == 'GET':
        # Webhook verification
        mode = request.args.get('hub.mode')
        verify_token = request.args.get('hub.verify_token')
        challenge = request.args.get('hub.challenge')
        
        print(f"Verification - Mode: {mode}, Token: {verify_token}, Challenge: {challenge}")
        
        if mode == 'subscribe' and verify_token == 'frappe_verify_token':
            print("✅ Webhook verification successful")
            return challenge
        else:
            print("❌ Webhook verification failed")
            return "Verification failed", 403
    
    elif request.method == 'POST':
        # Handle incoming messages
        try:
            data = request.get_json()
            print(f"📱 Received data: {json.dumps(data, indent=2)}")
            
            # Process WhatsApp messages
            if data.get("object") == "whatsapp_business_account":
                for entry in data.get("entry", []):
                    for change in entry.get("changes", []):
                        if change.get("field") == "messages":
                            value = change.get("value", {})
                            messages = value.get("messages", [])
                            
                            for message in messages:
                                from_number = message.get("from")
                                message_text = message.get("text", {}).get("body", "")
                                message_id = message.get("id")
                                
                                print(f"📱 Message from {from_number}: {message_text}")
                                print(f"📱 Message ID: {message_id}")
                                
                                # Send a simple response
                                send_response(from_number, f"Hello! I received your message: '{message_text}'")
            
            return "OK", 200
            
        except Exception as e:
            print(f"❌ Error processing webhook: {e}")
            return "Error", 500
    
    return "OK", 200

def send_response(to_number, message_text):
    """Send a simple response"""
    try:
        import requests
        
        # Your WhatsApp API details
        WHATSAPP_PHONE_ID = "853129267877967"
        WHATSAPP_TOKEN = "EAAVkO0JZA4L8BPukqQJkxZANCfQj4W2I71X1rmgPIDwatXyE8OhTsWaD7hiFKAXgvLwOfZBu4vgVMsCIobVPMA991MlbwjicPeqBXerLyN401Tz1OM4bxBkj2hsfpjNZBS8SZB96bqGEbf4IfCTPf3gV4i1IhyRrkCzZACZAhDbspB2uTc1QUEz6mMBY4pBxxiWbNajytA5gjwK7fZAak1tlaOOwtk8673C3YtEnCsvblgZDZD"
        
        url = f"https://graph.facebook.com/v22.0/{WHATSAPP_PHONE_ID}/messages"
        headers = {
            "Authorization": f"Bearer {WHATSAPP_TOKEN}",
            "Content-Type": "application/json"
        }
        
        data = {
            "messaging_product": "whatsapp",
            "to": to_number,
            "type": "text",
            "text": {
                "body": message_text
            }
        }
        
        print(f"📤 Sending response to {to_number}: {message_text}")
        response = requests.post(url, headers=headers, json=data)
        
        if response.status_code == 200:
            print(f"✅ Response sent successfully: {response.json()}")
        else:
            print(f"❌ Failed to send response: {response.status_code} - {response.text}")
            
    except Exception as e:
        print(f"❌ Error sending response: {e}")

if __name__ == '__main__':
    print("🚀 Starting Test Webhook Server...")
    print("📡 Webhook URL: http://localhost:5001/webhook")
    print("🔍 Test URL: https://034421cf4f83.ngrok-free.app/webhook")
    print("==================================================")
    app.run(host='0.0.0.0', port=5001, debug=True)











