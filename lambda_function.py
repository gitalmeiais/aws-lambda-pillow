from PIL import Image
import json

def handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps({"ok": True, "pillow": Image.__version__})
    }